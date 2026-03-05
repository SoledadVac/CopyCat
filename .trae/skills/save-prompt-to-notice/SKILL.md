---
name: "save-prompt-to-notice"
description: "Saves user prompts to Notice_words.md file. Invoke when user wants to record or save a prompt to Notice_words.md"
---

# Save Prompt to Notice

This skill saves user prompts to the Notice_words.md file in the CopyCat project.

## How to Use

When a user wants to record or save a prompt, follow these steps:

1. Read the current content of Notice_words.md
2. Append the new prompt with a timestamp
3. Write the updated content back to the file

## Prompt Format

Each entry should include:
- Date and time
- User's prompt content

Example format:

```
## YYYY-MM-DD HH:MM

Prompt content goes here...

---
```
