return {
	cmd = { "jedi-language-server" },
	filetypes = { "python" },
	root_markers = {
		".git",
		"setup.py",
		"setup.cfg",
		"pyproject.toml",
		"requirements.txt",
		"Pipfile",
		"pyrightconfig.json",
	},
	single_file_support = true,
	settings = {
		jediLanguageServer = {
			markupKindPreferred = "markdown",
		},
	},
}