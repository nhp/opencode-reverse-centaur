import type { Plugin } from "@opencode-ai/plugin"
import * as path from "node:path"
import * as fs from "node:fs"
import * as os from "node:os"

/**
 * Git Worktree Plugin
 *
 * Provides tools for creating and managing git worktrees, enabling parallel
 * OpenCode sessions on different tickets. Each worktree gets its own branch
 * and isolated working directory.
 *
 * Tools:
 *   worktree_create — Create a worktree for a ticket with convention-based branch naming
 *   worktree_list   — List all active worktrees
 *   worktree_delete — Remove a worktree (optionally snapshot-commit first)
 *
 * File sync:
 *   - thoughts/.secrets/ → symlinked (shared, single source of truth)
 *   - thoughts/.credentials → copied (independent per worktree)
 *
 * Security:
 *   - Branch names sanitized against shell metacharacters
 *   - Worktree paths validated against traversal attacks
 *   - No git push — ever
 */

// ── Helpers ─────────────────────────────────────────────────────────

/** Sanitize a string for use in git branch names. */
function sanitizeBranchSegment(input: string): string {
  return input
    .toLowerCase()
    .replace(/[^a-z0-9-]/g, "-") // only allow alphanumeric and hyphens
    .replace(/-+/g, "-") // collapse multiple hyphens
    .replace(/^-|-$/g, "") // strip leading/trailing hyphens
    .slice(0, 50) // reasonable length limit
}

/** Read a single-line file, returning null if missing. */
function readTrimmedFile(filePath: string): string | null {
  try {
    return fs.readFileSync(filePath, "utf-8").trim() || null
  } catch {
    return null
  }
}

/** Get the base directory for worktrees. */
function getWorktreeBase(projectName: string): string {
  return path.join(os.homedir(), ".opencode-worktrees", projectName)
}

/** Validate that a path doesn't escape the base directory. */
function isPathSafe(base: string, target: string): boolean {
  const resolved = path.resolve(base, target)
  return resolved.startsWith(path.resolve(base))
}

// ── Plugin ──────────────────────────────────────────────────────────

export default (async ({ $, directory }) => {
  const projectName = path.basename(directory)

  return {
    tool: {
      worktree_create: {
        description:
          "Create a git worktree for a ticket. Generates a branch name from the ticket ID " +
          "and description following the project's naming convention. Symlinks secrets and " +
          "copies credentials to the new worktree. Returns the path to navigate to.",
        parameters: {
          type: "object" as const,
          properties: {
            ticketId: {
              type: "string",
              description:
                "Ticket ID (e.g., PROJ-0001). Used in branch name.",
            },
            description: {
              type: "string",
              description:
                'Short description for the branch name (e.g., "add-dark-mode").',
            },
            type: {
              type: "string",
              description:
                'Branch type prefix. Defaults to "feature".',
              enum: ["feature", "bugfix", "hotfix", "refactor", "chore"],
            },
          },
          required: ["ticketId", "description"],
        },
        async execute(args: {
          ticketId: string
          description: string
          type?: string
        }) {
          const branchType = args.type || "feature"
          const acronym = readTrimmedFile(
            path.join(directory, "thoughts", ".user-acronym"),
          )
          const descSlug = sanitizeBranchSegment(args.description)

          if (!descSlug) {
            return "Error: description produced an empty slug after sanitization."
          }

          // Build branch name: feature/nhp/PROJ-0001/add-dark-mode
          const branchParts = [branchType]
          if (acronym) branchParts.push(acronym)
          branchParts.push(args.ticketId, descSlug)
          const branch = branchParts.join("/")

          // Determine worktree path
          const worktreeBase = getWorktreeBase(projectName)
          const worktreePath = path.join(worktreeBase, descSlug)

          if (!isPathSafe(worktreeBase, descSlug)) {
            return "Error: invalid description — path traversal detected."
          }

          // Check if branch already exists as a worktree
          const listResult = await $`git -C ${directory} worktree list --porcelain`
            .quiet()
            .nothrow()
            .text()

          if (listResult.includes(`branch refs/heads/${branch}`)) {
            return `Error: a worktree for branch '${branch}' already exists.`
          }

          // Create the worktree directory
          fs.mkdirSync(worktreeBase, { recursive: true })

          // Create worktree with new branch
          const createResult =
            await $`git -C ${directory} worktree add ${worktreePath} -b ${branch}`
              .quiet()
              .nothrow()

          if (createResult.exitCode !== 0) {
            const stderr = (await createResult.text()).trim()
            return `Error creating worktree: ${stderr}`
          }

          // ── Sync gitignored files ──

          // Symlink thoughts/.secrets/ (shared state)
          const secretsSrc = path.join(directory, "thoughts", ".secrets")
          const secretsDst = path.join(worktreePath, "thoughts", ".secrets")
          if (fs.existsSync(secretsSrc)) {
            try {
              // Remove the directory that git checkout created (if any)
              if (fs.existsSync(secretsDst)) {
                fs.rmSync(secretsDst, { recursive: true })
              }
              fs.mkdirSync(path.dirname(secretsDst), { recursive: true })
              fs.symlinkSync(secretsSrc, secretsDst, "dir")
            } catch (e: any) {
              // Non-fatal — secrets may not be needed
            }
          }

          // Copy thoughts/.credentials (independent per worktree)
          const credsSrc = path.join(directory, "thoughts", ".credentials")
          const credsDst = path.join(worktreePath, "thoughts", ".credentials")
          if (fs.existsSync(credsSrc)) {
            try {
              fs.mkdirSync(path.dirname(credsDst), { recursive: true })
              fs.copyFileSync(credsSrc, credsDst)
            } catch {
              // Non-fatal
            }
          }

          // Copy thoughts/.ticket-prefix and .user-acronym (gitignored)
          for (const file of [".ticket-prefix", ".user-acronym"]) {
            const src = path.join(directory, "thoughts", file)
            const dst = path.join(worktreePath, "thoughts", file)
            if (fs.existsSync(src)) {
              try {
                fs.mkdirSync(path.dirname(dst), { recursive: true })
                fs.copyFileSync(src, dst)
              } catch {
                // Non-fatal
              }
            }
          }

          return [
            `Worktree created successfully.`,
            ``,
            `  Branch: ${branch}`,
            `  Path:   ${worktreePath}`,
            ``,
            `To start working in the worktree:`,
            `  1. Open a new terminal`,
            `  2. cd ${worktreePath}`,
            `  3. opencode`,
            ``,
            `Note: thoughts/.secrets/ is symlinked — changes affect the main repo.`,
            `Run /commit before deleting the worktree.`,
          ].join("\n")
        },
      },

      worktree_list: {
        description:
          "List all active git worktrees for this project with their branches and paths.",
        parameters: {
          type: "object" as const,
          properties: {},
        },
        async execute() {
          const result = await $`git -C ${directory} worktree list`
            .quiet()
            .nothrow()
            .text()

          const lines = result.trim()
          if (!lines) return "No worktrees found."

          return `Active worktrees:\n\n${lines}`
        },
      },

      worktree_delete: {
        description:
          "Remove a git worktree. By default does NOT auto-commit — run /commit first. " +
          "Use snapshot=true for a safety snapshot commit before removal.",
        parameters: {
          type: "object" as const,
          properties: {
            worktreePath: {
              type: "string",
              description:
                "Path to the worktree to remove. Use worktree_list to find paths.",
            },
            snapshot: {
              type: "boolean",
              description:
                'If true, runs "git add -A && git commit" with a snapshot message before removal. ' +
                "Default: false (run /commit manually first).",
            },
          },
          required: ["worktreePath"],
        },
        async execute(args: { worktreePath: string; snapshot?: boolean }) {
          const targetPath = args.worktreePath

          // Validate the path exists and is a worktree
          if (!fs.existsSync(targetPath)) {
            return `Error: path does not exist: ${targetPath}`
          }

          // Check it's actually a worktree (has .git file, not directory)
          const dotGit = path.join(targetPath, ".git")
          if (!fs.existsSync(dotGit)) {
            return `Error: ${targetPath} does not appear to be a git worktree.`
          }
          const dotGitStat = fs.statSync(dotGit)
          if (dotGitStat.isDirectory()) {
            return `Error: ${targetPath} is the main repository, not a worktree.`
          }

          // Get the branch name before we remove it
          let branch = ""
          try {
            branch = (
              await $`git -C ${targetPath} rev-parse --abbrev-ref HEAD`
                .quiet()
                .nothrow()
                .text()
            ).trim()
          } catch {
            branch = "(unknown)"
          }

          // Optional snapshot commit
          if (args.snapshot) {
            await $`git -C ${targetPath} add -A`.quiet().nothrow()
            await $`git -C ${targetPath} commit -m ${"chore(worktree): snapshot before removal"} --allow-empty`
              .quiet()
              .nothrow()
          }

          // Remove the worktree
          const removeResult =
            await $`git -C ${directory} worktree remove ${targetPath} --force`
              .quiet()
              .nothrow()

          if (removeResult.exitCode !== 0) {
            const stderr = (await removeResult.text()).trim()
            return `Error removing worktree: ${stderr}\n\nTry committing or stashing changes first, or use snapshot=true.`
          }

          return [
            `Worktree removed successfully.`,
            ``,
            `  Branch: ${branch} (still exists — merge or delete manually)`,
            `  Path:   ${targetPath} (removed)`,
            ``,
            `The branch '${branch}' still has your commits.`,
            `To merge: git merge ${branch}`,
            `To delete: git branch -d ${branch}`,
          ].join("\n")
        },
      },
    },
  }
}) satisfies Plugin
