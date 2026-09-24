local M = {}

local SCRIPT = os.getenv("HOME") .. "/.config/yazi/smart-enter.sh"
local SIGNAL = "/tmp/.yazi-smart-enter"

local function sq(s) return "'" .. s:gsub("'", "'\\''") .. "'" end

local get_hovered = ya.sync(function()
	local h = cx.active.current.hovered
	if not h then return nil, nil end
	return tostring(h.url), h.cha.is_dir
end)

function M:entry()
	local path, is_dir = get_hovered()
	if not path then return end
	if not is_dir then ya.emit("open", { hovered = true }); return end

	os.remove(SIGNAL)

	ya.emit("shell", {
		sq(SCRIPT) .. " " .. sq(path) .. " " .. sq(SIGNAL),
		block = true,
	})

	local f = io.open(SIGNAL, "r")
	if f then f:close(); os.remove(SIGNAL); ya.emit("enter", {}) end
end

return M
