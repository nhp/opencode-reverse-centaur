import type { Plugin } from "@opencode-ai/plugin"

/**
 * Ticket Status Reminder Plugin
 *
 * Watches for `git add` and `git commit` commands. When detected, checks if
 * any staged files or recent commits reference a ticket ID. If so, reads the
 * local ticket file and reminds the agent to update the ticket status.
 *
 * Also sends desktop notifications (Linux: notify-send) when the session
 * becomes idle (agent needs input or task is complete).
 */

const TICKET_ID_PATTERN = /[A-Z]+-\d{4}/g

/**
 * Extract ticket IDs from a string (file paths, commit messages, etc.)
 */
function findTicketIds(text: string): string[] {
  const matches = text.match(TICKET_ID_PATTERN)
  if (!matches) return []
  return [...new Set(matches)]
}

/**
 * Read ticket status from a local ticket file.
 * Returns the status string or null if not found.
 */
function extractStatus(content: string): string | null {
  const match = content.match(/^\*\*Status:\*\*\s*(.+)$/m)
  return match ? match[1].trim() : null
}

/**
 * Build a reminder message for tickets that need status updates.
 */
function buildReminder(ticketId: string, status: string): string | null {
  if (status === "Open") {
    return (
      `Ticket ${ticketId} has status 'Open'. ` +
      `If you're working on it, update status to 'In Progress'. ` +
      `If this commit completes it, update to 'Done'. ` +
      `Remember to stage the ticket file after updating.`
    )
  }
  if (status === "In Progress") {
    return (
      `Ticket ${ticketId} has status 'In Progress'. ` +
      `If this commit completes it, update status to 'Done'. ` +
      `Remember to stage the ticket file after updating.`
    )
  }
  return null
}

/**
 * Send a desktop notification on Linux using notify-send.
 */
async function sendNotification($: any, title: string, message: string) {
  try {
    await $`notify-send ${title} ${message}`.quiet().nothrow()
  } catch {
    // notify-send not available — silently ignore
  }
}

export default (async ({ $, directory }) => {
  const thoughtsDir = `${directory}/thoughts`
  const ticketsDir = `${thoughtsDir}/shared/tickets`

  return {
    "tool.execute.after": async (event: any) => {
      // Only process bash tool calls
      if (event.tool !== "bash") return

      const command: string = event.input?.command || ""

      // Only trigger on git add or git commit
      if (!command.startsWith("git add") && !command.startsWith("git commit")) {
        return
      }

      try {
        // Get staged files
        const stagedOutput = await $`git diff --cached --name-only`
          .quiet()
          .nothrow()
          .text()
        const stagedFiles = stagedOutput.trim()

        // Find ticket IDs in staged file paths
        let ticketIds = findTicketIds(stagedFiles)

        // If none in staged files, check recent commits
        if (ticketIds.length === 0) {
          const logOutput = await $`git log --oneline -10`
            .quiet()
            .nothrow()
            .text()
          ticketIds = findTicketIds(logOutput)
        }

        if (ticketIds.length === 0) return

        // Check each ticket's status
        const reminders: string[] = []

        for (const ticketId of ticketIds) {
          // Find ticket file
          const findOutput =
            await $`find ${ticketsDir} -name "*${ticketId}*" -type f`
              .quiet()
              .nothrow()
              .text()
          const ticketFile = findOutput.trim().split("\n")[0]

          if (!ticketFile) continue

          // Read ticket file
          const { readFile } = await import("fs/promises")
          const content = await readFile(ticketFile, "utf-8").catch(() => null)
          if (!content) continue

          const status = extractStatus(content)
          if (!status) continue

          const reminder = buildReminder(ticketId, status)
          if (reminder) reminders.push(reminder)
        }

        if (reminders.length > 0) {
          return {
            additionalContext: reminders.join("\n\n"),
          }
        }
      } catch {
        // Don't break the workflow if ticket checking fails
      }
    },

    "session.idle": async () => {
      await sendNotification(
        $,
        "OpenCode",
        "Agent needs your input or has completed the task.",
      )
    },
  }
}) satisfies Plugin
