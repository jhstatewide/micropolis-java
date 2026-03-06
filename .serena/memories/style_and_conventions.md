Observed Java style conventions:
- Uses tabs for indentation and Allman/K&R hybrid braces with opening brace on next line for class/method declarations.
- Naming is mixed legacy style: classes are usually PascalCase (`Main`), but some legacy names use underscores (`XML_Helper`). Do not mass-rename legacy identifiers unless task requires it.
- Minimal annotations and lightweight comments; comments are used where behavior is non-obvious.
- Older Java compatibility is intentional in build config (`source`/`target` 1.6), so avoid modern Java-only language features unless build settings are updated.
- GUI startup uses Swing threading convention (`SwingUtilities.invokeLater`).