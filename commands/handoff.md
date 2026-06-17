---
description: "Create a temporary handoff document so another agent session can continue focused work without bloating the current context."
---

# Handoff

Create a handoff document for: **$ARGUMENTS**

Load the **handoff** skill and follow it exactly.

If `$ARGUMENTS` is empty, ask one short question: "What should the next session focus on?"

The output is a markdown file in the OS temp directory, not the repository. Return the absolute path and a one-line summary of what the next session should do.
