# Shared Development Standards

Universal rules for all projects using the opencode workflow template. This file is symlinked from the template repository and updates automatically.

**Project-specific instructions are in `AGENTS.md`.** Both files apply.

## Development Conventions

### Branch Naming

If `thoughts/.user-acronym` exists, read the acronym and follow:
`[type]/[acronym]/[ticket-id]/[description]`

If no acronym is configured, omit the acronym segment:
`[type]/[ticket-id]/[description]`

Examples (with acronym "nhp"):
- `feature/nhp/PROJ-0001/add-new-feature`
- `bugfix/nhp/PROJ-0002/fix-checkout-bug`

Examples (without acronym):
- `feature/PROJ-0001/add-new-feature`
- `bugfix/PROJ-0002/fix-checkout-bug`

### Commit Messages

Use conventional commits with ticket IDs:

```
[TICKET-ID] Short summary of changes

* Why this change was needed
* Additional context

Refs: TICKET-IDs
```

## Security Awareness

**AI-generated code is statistically less secure than human-written code** (Perry et al., CCS 2023; Pearce et al., IEEE S&P 2022). Treat all generated code as untrusted and apply these rules rigorously.

### NEVER (Security)

- **NEVER** concatenate user input into SQL, shell commands, LDAP queries, or template strings — use parameterized queries, subprocess with argument lists, and auto-escaping templates
- **NEVER** hardcode secrets, API keys, passwords, or tokens in source code — use environment variables or a secrets manager
- **NEVER** use `eval()`, `exec()`, `Function()`, or `system()` with user-influenced data
- **NEVER** use MD5, SHA1, DES, RC4, or ECB mode for any security purpose — use bcrypt/argon2 for passwords, AES-GCM for encryption, SHA-256+ for hashing
- **NEVER** use `Math.random()` / `random.random()` for tokens, session IDs, or security-sensitive values — use `crypto.randomBytes()` / `secrets.token_hex()`
- **NEVER** accept file paths from users without canonicalization (`realpath()`) and directory boundary checks
- **NEVER** skip server-side authorization checks — UI-level hiding is not access control
- **NEVER** deserialize untrusted data with `pickle`, `yaml.load()`, or Java `ObjectInputStream` — use JSON or `yaml.safe_load()`
- **NEVER** fetch user-supplied URLs without validating scheme, hostname, and blocking internal/metadata IPs (SSRF)
- **NEVER** disable SSL/TLS verification (`verify=False`) or CSRF protection — fix the root cause instead
- **NEVER** return stack traces, internal error details, or database errors to end users
- **NEVER** set `Access-Control-Allow-Origin: *` on authenticated endpoints
- **NEVER** store passwords in plaintext or reversible encryption
- **NEVER** suggest deprecated or unmaintained security libraries (verify libraries are current and maintained)

### ALWAYS (Security)

- **ALWAYS** validate all external input: type, length, format, range — use allowlists over denylists
- **ALWAYS** use parameterized queries for ALL database access, without exception
- **ALWAYS** set security headers: `Content-Security-Policy`, `X-Content-Type-Options: nosniff`, `Strict-Transport-Security`, `X-Frame-Options`
- **ALWAYS** set cookie flags: `Secure`, `HttpOnly`, `SameSite=Strict` (or `Lax`)
- **ALWAYS** use CSRF tokens for state-changing requests (POST/PUT/DELETE)
- **ALWAYS** regenerate session IDs after authentication
- **ALWAYS** flag security concerns explicitly when proposing an implementation — do not silently choose an insecure approach

## Implementation Discipline

- **Tests are NOT a separate phase.** Each implementation phase includes BOTH the feature AND its tests.
- Commit after each verified logical step.
- Use `todowrite` to plan and track complex implementations.
- Research existing patterns before implementing new features.
- Never defer testing — a phase is only complete when tests pass.

## Git Discipline

- Commit after each verified logical step (conventional commits).
- **NEVER** run `git push` — the human decides when to push.
- **NEVER** use `git commit --amend`.
- Keep commits atomic and focused.
