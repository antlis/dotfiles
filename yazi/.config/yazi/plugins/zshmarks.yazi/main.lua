-- zshmarks bridge: jump to a directory bookmarked with zshmarks (~/.bookmarks).
-- The file format is one `PATH|name` per line, where PATH may contain a
-- literal `$HOME`. Picks with fzf (shows the name) and cd's to the path.

local M = {}

function M:entry()
	local _permit = ya.hide()

	local home = os.getenv("HOME")
	local file = io.open(home .. "/.bookmarks", "r")
	if not file then
		return ya.notify { title = "zshmarks", content = "No ~/.bookmarks file found", timeout = 5, level = "error" }
	end

	local lines = {}
	for line in file:lines() do
		local dir, name = line:match("^(.-)|(.+)$")
		if dir and name then
			dir = dir:gsub("%$HOME", home)
			lines[#lines + 1] = string.format("%s\t%s", name, dir)
		end
	end
	file:close()

	if #lines == 0 then
		return ya.notify { title = "zshmarks", content = "No bookmarks found", timeout = 5, level = "error" }
	end

	local child, err = Command("fzf")
		:arg({ "--delimiter=\t", "--with-nth=1", "--preview", "ls -la {2}" })
		:stdin(Command.PIPED)
		:stdout(Command.PIPED)
		:spawn()
	if not child then
		return ya.notify { title = "zshmarks", content = "Failed to start fzf: " .. tostring(err), timeout = 5, level = "error" }
	end

	child:write_all(table.concat(lines, "\n") .. "\n")
	child:flush()

	local output = child:wait_with_output()
	if not output or not output.status.success then
		return -- cancelled (esc) or fzf error
	end

	local dir = output.stdout:gsub("[\r\n]+$", ""):match("\t(.+)$")
	if dir then
		ya.emit("cd", { dir })
	end
end

return M
