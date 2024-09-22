local evalReplace = {}

function evalReplace.operator(options)
	options = options or {}
	vim.o.operatorfunc = "v:lua.eval_operator_callback"
	vim.api.nvim_feedkeys("g@" .. (options.motion or ""), "mi", false)
end

function evalReplace.line(options)
	options = options or {}
	local count = options.count or (vim.v.count > 0 and vim.v.count or "")
	evalReplace.operator({
		motion = count .. "_",
	})
end

function evalReplace.visual(options)
	options = options or {}

	vim.o.operatorfunc = "v:lua.eval_operator_callback"
	vim.api.nvim_feedkeys("g@`<", "ni", false)
end

function eval_operator_callback(vmode)
	local utils = require("utils")
	local marks = utils.get_marks(0, vmode)

	local lines = utils.get_text(0, marks.start, marks.finish, vmode)

	local text = table.concat(lines, " ")

	local result = tostring(load("return " .. text)())
	utils.substitute_text(0, marks.start, marks.finish, vmode, result)
end

return evalReplace
