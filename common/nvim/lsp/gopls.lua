return {
	on_new_config = function(new_config, new_root_dir)
		print("gopls on_new_config called for: " .. new_root_dir)
		if new_root_dir == "/Users/armahishi/dev/work/db/cockroach" then
			new_config.settings.gopls.env = {
				GOPACKAGESDRIVER = "./build/bazelutil/gopackagesdriver.sh",
			}
			new_config.settings.gopls.directoryFilters = {
				"-bazel-bin",
				"-bazel-out",
				"-bazel-testlogs",
				"-bazel-mypkg",
			}
		end
	end,
	filetypes = { "go", "gomod", "gowork", "gotmpl", "gosum" },
	cmd = { "gopls" },
	settings = {
		gopls = {
			directoryFilters = {
				"-\\.bazel$",
				"-_bazel$",
				"-\\.cache$",
				"-\\.git$",
				"-c-deps$",
			},
		},
	},
}
