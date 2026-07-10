local function shellescape(value)
	return vim.fn.shellescape(value)
end

local function current_file()
	return vim.api.nvim_buf_get_name(0)
end

local runners = {
	python = function(file)
		return "python3 " .. shellescape(file)
	end,
	javascript = function(file)
		return "node " .. shellescape(file)
	end,
	php = function(file)
		return "php " .. shellescape(file)
	end,
	lua = function(file)
		return "lua " .. shellescape(file)
	end,
	sh = function(file)
		return "bash " .. shellescape(file)
	end,
	rust = function(file)
		local output = vim.fn.tempname()
		return "rustc " .. shellescape(file) .. " -o " .. shellescape(output) .. " && " .. shellescape(output)
	end,
	cpp = function(file)
		local output = vim.fn.tempname()
		return "g++ " .. shellescape(file) .. " -o " .. shellescape(output) .. " && " .. shellescape(output)
	end,
}

for ft, runner in pairs(runners) do
	vim.api.nvim_create_autocmd("FileType", {
		pattern = ft,
		callback = function()
			vim.keymap.set("n", "<localleader>r", function()
				local file = current_file()
				if file == "" then
					vim.notify("Save the file before running it", vim.log.levels.WARN)
					return
				end

				vim.cmd("vs")
				vim.fn.termopen(runner(file))
				vim.cmd("startinsert")
			end, { buffer = true, desc = "Run current file in terminal" })
		end,
	})
end
