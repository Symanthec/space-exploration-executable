-- Keyboard input controller

local binds = {} -- stores key bindings in scancode-function pairs


local T = {} -- functions table
keybinds = T


function keybinds.forScan(scancode, callback)
	if callback == nil then
		-- get callback for given scancode
		return binds[scancode]
	elseif type(callback) == "function" then
		old = binds[scancode]
		binds[scancode] = callback
		return old
	else -- callback present, but of the wrong type
		error("Incorrect type of callback: " .. type(callback))
	end
end


function keybinds.clear()
	binds = {}
end
