local utils = {}

function utils.get_marks(bufnr, vmode)
	local start_mark, finish_mark = "[", "]"
	if utils.is_visual(vmode) then
		start_mark, finish_mark = "<", ">"
	end

	local pos_start = vim.api.nvim_buf_get_mark(bufnr, start_mark)
	local pos_finish = vim.api.nvim_buf_get_mark(bufnr, finish_mark)

	return {
		start = {
			row = pos_start[1],
			col = pos_start[2],
		},
		finish = {
			row = pos_finish[1],
			col = pos_finish[2],
		},
	}
end

function utils.is_visual(vmode)
	return vmode:match("[vV]") or utils.is_blockwise(vmode)
end

function utils.is_blockwise(vmode)
	return vmode:byte() == 22 or vmode == "block" or vmode == "b"
end

function utils.get_text(bufnr, start, finish, vmode)
	if start.row > finish.row then
		return { "" }
	end

	local regtype = utils.get_register_type(vmode)
	if "l" == regtype then
		return vim.api.nvim_buf_get_lines(bufnr, start.row - 1, finish.row, false)
	end

	if "b" == regtype then
		local text = {}
		for row = start.row, finish.row, 1 do
			local current_row_len = vim.fn.getline(row):len()

			local end_col = current_row_len > finish.col and utils.get_next_char_bytecol(finish.row, finish.col)
				or current_row_len
			if start.col > end_col then
				end_col = start.col
			end

			local lines = vim.api.nvim_buf_get_text(bufnr, row - 1, start.col, row - 1, end_col, {})

			for _, line in pairs(lines) do
				table.insert(text, line)
			end
		end

		return text
	end

	return vim.api.nvim_buf_get_text(
		0,
		start.row - 1,
		start.col,
		finish.row - 1,
		utils.get_next_char_bytecol(finish.row, finish.col),
		{}
	)
end

function utils.get_register_type(vmode)
	if utils.is_blockwise(vmode) or "b" == vmode then
		return "b"
	end

	if vmode == "V" or vmode == "line" or vmode == "l" then
		return "l"
	end

	return "c"
end

function utils.get_next_char_bytecol(linenr, colnr)
	local line = vim.fn.getline(linenr)
	local utf_index = vim.str_utfindex(line, math.min(line:len(), colnr + 1))

	return vim.str_byteindex(line, utf_index)
end

function utils.substitute_text(bufnr, start, finish, regtype, replacement)
	regtype = utils.get_register_type(regtype)

	if "l" == regtype then
		vim.api.nvim_buf_set_lines(bufnr, start.row - 1, finish.row, false, { replacement })

		local end_mark_col = string.len(replacement) + 1
		local end_mark_row = start.row

		return { { start = { row = start.row, col = 0 }, finish = { row = end_mark_row, col = end_mark_col } } }
	end

	if start.row > finish.row then
		vim.api.nvim_buf_set_text(bufnr, start.row - 1, start.col, start.row - 1, start.col, { replacement })
	else
		local current_row_len = vim.fn.getline(finish.row):len()

		vim.api.nvim_buf_set_text(
			bufnr,
			start.row - 1,
			start.col,
			finish.row - 1,
			current_row_len > finish.col and utils.get_next_char_bytecol(finish.row, finish.col) or current_row_len,
			{ replacement }
		)
	end

	local end_mark_col = string.len(replacement) + start.col
	local end_mark_row = start.row

	return { { start = start, finish = { row = end_mark_row, col = end_mark_col } } }
end

return utils
