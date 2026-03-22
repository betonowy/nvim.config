--- SECTION general editor config

vim.cmd.set("expandtab")
vim.cmd.set("tabstop=4")
vim.cmd.set("softtabstop=0")
vim.cmd.set("shiftwidth=0")
vim.cmd.set("relativenumber")
vim.cmd.set("number")
vim.cmd.set("completeopt+=menuone,noselect,popup")
vim.cmd.set("scrolloff=1000")
vim.cmd.set("sidescrolloff=20")

--- SECTION inspect environment

local im_at_home = (function()
	local hostname = vim.uv.os_gethostname()
	local username = vim.uv.os_get_passwd().username
	return hostname == "arch" and username == "araara"
end)()

--- SECTION safe discord extension

if im_at_home then
	vim.pack.add({ "https://github.com/vyfor/cord.nvim" })
	require("cord").setup()
end

--- SECTION colorscheme

vim.pack.add({ "https://github.com/tiagovla/tokyodark.nvim" })
require("tokyodark.config").setup({ transparent_background = true, gamma = 2.0 })
vim.cmd.colorscheme("tokyodark")

--- SECTION file manager

vim.pack.add({ "https://github.com/stevearc/oil.nvim" })
require("oil").setup()
vim.keymap.set("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory in Oil" })

--- SECTION mini icons

vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" })
require("mini.icons").setup()

--- SECTION autoclose brackets

vim.pack.add({ "https://github.com/m4xshen/autoclose.nvim" })
require("autoclose").setup({ options = { pair_spaces = true } })

--- SECTION surround brackets

vim.pack.add({ "https://github.com/kylechui/nvim-surround" })
require("nvim-surround").setup()

--- SECTION telescope

vim.pack.add({
	{ src = "https://github.com/nvim-telescope/telescope.nvim", version = "v0.2.1" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
})

require("telescope").setup()
local telescope_builtin = require("telescope.builtin")

--- SECTION keymaps

vim.keymap.set("n", "<Esc>", "<cmd>noh<CR>", { desc = "Clear search highlights" })
vim.keymap.set("i", "jk", "<ESC>", { desc = "Patryk gave me this crazy shortcut to escape insert mode" })
vim.keymap.set("n", "<C-n>", "<cmd>tab split<CR>", { desc = "Open new tab" })
vim.keymap.set("n", "<Leader>ff", telescope_builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<Leader>fg", telescope_builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<Leader>fb", telescope_builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<Leader>fh", telescope_builtin.help_tags, { desc = "Telescope help tags" })
vim.keymap.set("n", "<Leader>fca", telescope_builtin.commands, { desc = "Telescope all commands" })
vim.keymap.set("n", "<Leader>fcr", telescope_builtin.command_history, { desc = "Telescope command history" })
vim.keymap.set("t", "<C-,><C-n>", "<C-\\><C-n>", { desc = "Release terminal focus" })

--- SECTION TODO clang-format-recursive

--- local function call_clang_format()
--- 	vim.api.save_buffer(0)
--- 	vim.system({ "clang-format", "-i", vim.api.nvim_buf_get_name(0) })
--- end
---
--- vim.api.nvim_create_user_command("Cfmt", call_clang_format, { desc = "regex clang-format" })

--- SECTION blame

vim.pack.add({ "https://github.com/FabijanZulj/blame.nvim" })
require("blame").setup()

--- SECTION gitsigns

vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" })
require("gitsigns").setup()

--- SECTION format on save

vim.pack.add({ "https://github.com/acro5piano/nvim-format-buffer" })
require("nvim-format-buffer").setup({
	format_rules = {
		{ pattern = { "*.lua" }, command = "stylua -" },
		{
			pattern = { "*.c", "*.cc", "*.cpp", "*.cxx", "*.h", "*.hh", "*.hpp", "*.hxx", "*.glsl", "*.hlsl" },
			command = "clang-format",
		},
	},
})

--- SECTION perfanno perf code heat map

vim.pack.add({ "https://github.com/t-troebst/perfanno.nvim" })
require("perfanno").setup()

--- SECTION debug adapter protocol

vim.pack.add({
	{ src = "https://github.com/mfussenegger/nvim-dap" },
	{ src = "https://github.com/nvim-neotest/nvim-nio" },
	{ src = "https://github.com/rcarriga/nvim-dap-ui" },
})
local dapui = require("dapui")
local dap = require("dap")

dapui.setup()

dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end

dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end

dap.listeners.before.event_terminated.dapui_config = function()
	dapui.close()
end

dap.listeners.before.event_exited.dapui_config = function()
	dapui.close()
end

dap.adapters.gdb = {
	type = "executable",
	command = "gdb",
	args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
}

dap.adapters.lldb = {
	type = "executable",
	command = "bash - /opt/LLVM-22.1.1-Linux-X64/bin/lldb-dap",
	args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
}

dap.configurations.c = {
	{
		name = "lldb",
		type = "lldb",
		request = "launch",
		program = function()
			return vim.fn.input({
				prompt = "Path to Debuggable Executable: ",
				default = vim.fn.getcwd() .. "/",
				completion = "file",
			})
		end,
		args = {},
		cwd = "${workspaceFolder}",
		stopAtBeginningOfMainSubprogram = false,
		console = "integratedTerminal",
	},
}

dap.configurations.cpp = {
	{
		name = "lldb",
		type = "lldb",
		request = "launch",
		program = function()
			return vim.fn.input({
				prompt = "Path to Debuggable Executable: ",
				default = vim.fn.getcwd() .. "/",
				completion = "file",
			})
		end,
		args = {},
		cwd = "${workspaceFolder}",
		stopAtBeginningOfMainSubprogram = false,
		console = "integratedTerminal",
	},
}

--- SECTION diagnostics

vim.diagnostic.config({
	virtual_text = false,
	update_in_insert = true,
	signs = true,
	float = {
		show_header = true,
		source = "if_many",
		border = "rounded",
		focusable = false,
	},
})

vim.keymap.set("n", "<leader>gd", vim.diagnostic.open_float, { desc = "Open diagnostics window at cursor position" })

--- SECTION lsp config

vim.pack.add({ "https://github.com/neovim/nvim-lspconfig" })

vim.lsp.codelens.enable()
vim.lsp.semantic_tokens.enable(true)
vim.lsp.document_color.enable(true)
vim.lsp.enable("clangd")
vim.lsp.enable("lua_ls")
vim.lsp.enable("glsl_analyzer")

vim.lsp.config("*", { capabilities = { textDocument = { semanticTokens = { multilineSupport = true } } } })
--- vim.lsp.config("*", { capabilities = capabilities }) --- Merges cmp_nvim_lsp

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("my.lsp", {}),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

		if client:supports_method("textDocument/completion") then
			--- some language servers don't behave well in this overdrive mode
			--- TODO tune it for glsl_analyzer
			if client.name ~= "glsl_analyzer" then
				local chars = {}
				for i = 32, 126 do
					table.insert(chars, string.char(i))
				end
				client.server_capabilities.completionProvider.triggerCharacters = chars
			end

			vim.lsp.completion.enable(true, client.id, args.buf, {
				autotrigger = true,
				convert = function(item)
					return { abbr = item.label:gsub("%b()", "") }
				end,
			})
		end
	end,
})

vim.keymap.set("n", "<leader>gf", "mfggVG$gq'f", { desc = "Format entire document" })

--- SECTION Lua Language Server config (just for neovim config) source: https://github.com/neovim/nvim-lspconfig/blob/master/lsp/lua_ls.lua

vim.lsp.config("lua_ls", {
	on_init = function(client)
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if
				path ~= vim.fn.stdpath("config")
				and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
			then
				return
			end
		end

		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
			runtime = {
				version = "LuaJIT",
				path = { "lua/?.lua", "lua/?/init.lua" },
			},
			workspace = {
				checkThirdParty = false,
				library = { vim.env.VIMRUNTIME },
			},
		})
	end,
	settings = { Lua = {} },
})

require("config_utils").setup()
