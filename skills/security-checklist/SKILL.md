# Security Checklist Skill

Use this checklist to evaluate security implications at every workflow stage. Based on OWASP Top 10 (2021), CWE/SANS Top 25 (2024), and documented AI-generated code vulnerability patterns (Perry et al. CCS 2023, Pearce et al. IEEE S&P 2022).

**Key finding:** ~40% of AI-generated code contains security vulnerabilities. AI-assisted developers are more likely to believe their code is secure while producing less secure code. Apply these checks rigorously.

---

## How to Use This Checklist

- **During /research:** Identify which categories apply to the feature being researched. Flag existing security patterns in the codebase.
- **During /plan:** Evaluate the proposed approach against relevant categories. Reject approaches that violate rules. Include security requirements in phase success criteria.
- **During /implement:** Before writing code, check which categories apply. After writing, verify against the specific rules. Before committing, do a final scan.
- **During /review:** Use the full checklist as a review dimension.

**Not all categories apply to every task.** Identify which are relevant and focus on those. But when a category IS relevant, every rule in it is mandatory.

---

## Category 1: Injection

**Applies when:** Code handles user input, database queries, shell commands, template rendering, or dynamic code generation.

| Rule | Bad Pattern | Secure Pattern |
|------|-------------|----------------|
| SQL: Never concatenate input into queries | `"SELECT * FROM users WHERE id = " + id` | Parameterized: `query("SELECT * FROM users WHERE id = ?", [id])` |
| Command: Never pass input to shell | `os.system("ping " + host)` | `subprocess.run(["ping", "-c", "4", host], shell=False)` |
| Code: Never eval/exec user data | `eval(userInput)` | `JSON.parse(userInput)` or `ast.literal_eval()` |
| XSS: Never insert input into HTML raw | `element.innerHTML = userInput` | `element.textContent = userInput` or DOMPurify |
| Template: Never disable auto-escaping | `|safe` / `{!! $var !!}` on user data | Let framework auto-escape; sanitize if HTML is needed |

**Test:** Can any external input reach a query, command, or HTML output without being parameterized/escaped?

---

## Category 2: Cryptographic Failures

**Applies when:** Code handles passwords, secrets, tokens, encryption, hashing, or random value generation.

| Rule | Bad Pattern | Secure Pattern |
|------|-------------|----------------|
| Never hardcode secrets | `API_KEY = "sk-abc123"` | `API_KEY = os.environ["API_KEY"]` |
| Never use broken hash algorithms | `md5(password)`, `sha1(password)` | `bcrypt.hash(password)`, `argon2.hash()` |
| Never use insecure ciphers/modes | `AES.new(key, AES.MODE_ECB)` | `AES-GCM`, `Fernet`, `ChaCha20-Poly1305` |
| Never use weak randomness | `Math.random()`, `random.random()` | `crypto.randomBytes()`, `secrets.token_hex()` |
| Never store passwords reversibly | Plaintext or AES-encrypted passwords | One-way hash with salt: bcrypt/argon2/scrypt |
| Never suggest deprecated libraries | `pycrypto`, `mcrypt`, `DES` | `cryptography` (Python), built-in `crypto` (Node) |

**Test:** Are any secrets visible in source code? Is any crypto function using a known-broken algorithm?

---

## Category 3: Broken Access Control

**Applies when:** Code involves user-facing endpoints, file access, multi-user data, or resource ownership.

| Rule | Bad Pattern | Secure Pattern |
|------|-------------|----------------|
| Never skip server-side auth checks | `if (user.isAdmin)` only in UI | Server-side: `if (req.user.id !== resource.ownerId) return 403` |
| Never trust user-supplied file paths | `open(userPath)` | `realpath()` + verify within allowed directory |
| Never use sequential IDs without auth | `/api/invoices/123` — any user can iterate | Verify ownership; prefer UUIDs |
| Never allow unrestricted file uploads | `save(upload.originalFilename)` | Validate MIME + magic bytes, random filename, outside webroot |

**Test:** Can a logged-in user access another user's data by changing an ID/path? Can an unauthenticated user reach a protected endpoint?

---

## Category 4: CSRF / Cross-Origin

**Applies when:** Code handles form submissions, state-changing API endpoints, cookies, or CORS configuration.

| Rule | Bad Pattern | Secure Pattern |
|------|-------------|----------------|
| Never accept POST/PUT/DELETE without CSRF | Form without `csrf_token` | Include CSRF token in forms and validate server-side |
| Never allow CORS wildcard on auth endpoints | `Access-Control-Allow-Origin: *` | Whitelist specific origins |
| Never omit cookie security flags | `Set-Cookie: session=abc` | `Secure; HttpOnly; SameSite=Strict` |

**Test:** Can a malicious page trigger a state-changing request using a user's session?

---

## Category 5: Authentication & Session

**Applies when:** Code handles login, registration, session management, JWT, OAuth, or password reset.

| Rule | Bad Pattern | Secure Pattern |
|------|-------------|----------------|
| Never ship default credentials | `admin/admin`, `user/password` | Force password change on first login; no defaults |
| Never expose session IDs in URLs | `?sid=abc123` | Session ID in cookie only (HttpOnly, Secure) |
| Never skip session regeneration | Same session ID before and after login | Regenerate session ID on authentication |
| Never use JWT `alg: none` | `{"alg": "none"}` | Enforce RS256/ES256; validate algorithm server-side |
| Never put secrets in JWT payload | `{"password": "..."}` in JWT | JWT payload is base64, not encrypted — only non-sensitive claims |
| Never allow unlimited auth attempts | No rate limiting on login | Progressive delays or lockout after N failures |

**Test:** Can an attacker brute-force credentials? Can a session be hijacked or fixated?

---

## Category 6: Security Misconfiguration

**Applies when:** Code involves server configuration, error handling, HTTP headers, debug settings, or deployment.

| Rule | Bad Pattern | Secure Pattern |
|------|-------------|----------------|
| Never enable debug in production | `app.run(debug=True)`, `DEBUG=True` | Environment-based config; debug off in production |
| Never expose internal errors | `return {"error": str(e), "trace": traceback}` | `return {"error": "Internal error"}`, log details server-side |
| Never disable SSL verification | `requests.get(url, verify=False)` | Fix certificates; never bypass verification |
| Never omit security headers | Missing CSP, HSTS, X-Frame-Options | Set all security headers via middleware |
| Never use permissive file permissions | `chmod 777`, world-readable configs | Minimum necessary permissions; 600 for secrets |

**Test:** Does the error page reveal framework version, file paths, or stack traces?

---

## Category 7: SSRF (Server-Side Request Forgery)

**Applies when:** Code makes HTTP requests based on user input (URL imports, webhooks, link previews, file fetchers).

| Rule | Bad Pattern | Secure Pattern |
|------|-------------|----------------|
| Never fetch arbitrary user URLs | `requests.get(user_url)` | Validate scheme (https only), resolve DNS, block private/internal IPs |
| Never allow access to metadata endpoints | Fetching `http://169.254.169.254/` | Block link-local, loopback, and private IP ranges |
| Never follow redirects blindly | `allow_redirects=True` to internal hosts | Re-validate destination after redirect |

**Test:** Can user input cause the server to make requests to internal services or cloud metadata?

---

## Category 8: Insecure Deserialization

**Applies when:** Code deserializes data from external sources (API requests, file uploads, message queues, caches).

| Rule | Bad Pattern | Secure Pattern |
|------|-------------|----------------|
| Never unpickle untrusted data | `pickle.loads(user_data)` | `json.loads(user_data)` |
| Never use unsafe YAML loader | `yaml.load(data)` | `yaml.safe_load(data)` |
| Never deserialize Java objects from untrusted sources | `ObjectInputStream.readObject()` | JSON/Protobuf + allowlisted types |

**Test:** Can an attacker send a crafted serialized object to trigger code execution?

---

## Category 9: AI-Specific Pitfalls

**These patterns are amplified by AI code generation. Watch for them in all AI-generated code.**

| Pattern | Risk | Mitigation |
|---------|------|------------|
| Placeholder credentials that persist | `"password123"`, `"changeme"` survive to production | Always use `os.environ["VAR"]` with a comment explaining it must be configured |
| Happy-path-only code | No input validation, no error handling | For every external input: validate type, length, format, range |
| Deprecated library suggestions | AI training data includes old code | Verify library is actively maintained and CVE-free before using |
| SSL/security feature bypass | `verify=False` to "make it work" | Never bypass; fix the root cause |
| Missing authorization | Code works but doesn't check WHO is calling | Every endpoint that modifies data needs explicit authorization |
| Edge cases in security logic | Symlinks, `../`, null bytes, unicode normalization | Enumerate and test edge cases explicitly for security-critical paths |

---

## Quick Decision Matrix

When you encounter a security-relevant pattern, use this matrix:

| If you're doing... | Check categories |
|---------------------|-----------------|
| Database queries | 1 (Injection) |
| User authentication | 2 (Crypto), 5 (Auth) |
| File handling | 3 (Access Control) |
| Form processing | 1 (Injection), 4 (CSRF) |
| API endpoints | 3 (Access Control), 4 (CSRF), 6 (Misconfig) |
| HTTP client requests | 7 (SSRF) |
| Data parsing/import | 1 (Injection), 8 (Deserialization) |
| Configuration | 2 (Crypto — secrets), 6 (Misconfig) |
| Error handling | 6 (Misconfig — info disclosure) |
| Any user-facing output | 1 (XSS) |
