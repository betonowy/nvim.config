local function execute_chain(chain, iteration)
	if iteration == nil then
		iteration = 1
	end

	local function check(prev)
		if prev.code ~= 0 then
			print(prev.stdout)
			print(prev.stderr)
		end
	end

	local function last(prev)
		check(prev)
		print("Finished")
	end

	local function next(prev)
		check(prev)
		execute_chain(chain, iteration + 1)
	end

	if iteration == #chain then
		vim.system(chain[iteration], last)
	else
		vim.system(chain[iteration], next)
	end
end

local function config_push()
	execute_chain({
		{ "git", "add", "." },
		{ "git", "commit", "--amend", "-m", ":)" },
		{ "git", "push", "--force" },
	})
end

local function config_pull()
	execute_chain({
		{ "git", "fetch", "origin" },
		{ "git", "reset", "--hard", "origin/master" },
	})
end

local function load_cwd_config(source_candidates)
	for _, candidate in ipairs(source_candidates) do
		if vim.uv.fs_stat(candidate) then
			vim.cmd.source(candidate)
			print("Sourced local config: " .. candidate)
			break
		end
	end
end

local default_config = {
	source_candidates = { "nvim_init.lua", ".nvim_init.lua" },
}

local function setup(config)
	if config == nil then
		config = default_config
	end

	vim.api.nvim_create_user_command("ConfigPush", config_push, { desc = "Push nvim config to remote" })
	vim.api.nvim_create_user_command("ConfigPull", config_pull, { desc = "Pull nvim config from remote" })

	load_cwd_config(config.source_candidates)
end

return { setup = setup }
