local status_ok, comment = pcall(require, "Comment")
if not status_ok then
	return
end

local ts_utils_ok, ts_utils = pcall(require, "ts_context_commentstring.utils")
local ts_internal_ok, ts_internal = pcall(require, "ts_context_commentstring.internal")

comment.setup({
	pre_hook = function(ctx)
		if not ts_utils_ok or not ts_internal_ok then
			return
		end

		local U = require("Comment.utils")

		local location = nil
		if ctx.ctype == U.ctype.block then
			local ok, value = pcall(ts_utils.get_cursor_location)
			if ok then
				location = value
			end
		elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
			local ok, value = pcall(ts_utils.get_visual_start_location)
			if ok then
				location = value
			end
		end

		local ok, commentstring = pcall(ts_internal.calculate_commentstring, {
			key = ctx.ctype == U.ctype.line and "__default" or "__multiline",
			location = location,
		})

		if ok then
			return commentstring
		end
	end,
})
