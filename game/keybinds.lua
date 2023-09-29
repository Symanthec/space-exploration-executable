-- Keyboard input controller
-- Keybind structure:
-- function cb(ispressed, key, scancode, isrepeat), omit isrepeat if on release

function defaultKeybindsHandler(keybinds)
	local handler = {}

	function handler.keypressed(key, scancode, isrepeat)
		return keybinds:press(key, scancode, isrepeat)
	end

	function handler.keyreleased(key, scancode)
		return keybinds:release(key, scancode)
	end

	return handler
end


Keybinds = {}
Keybinds.__index = Keybinds


function Keybinds.new(copy)
	local binds = {}
	binds._onPress = {}
	binds._onRelease = {}
	if type(copy) == "table" then
		for scan, cb in ipairs(copy._onPress) do
			binds._onPress[scan] = cb
		end
		for scan, cb in ipairs(copy._onRelease) do
			binds._onRelease[scan] = cb
		end
	end
	setmetatable(binds, Keybinds)
	return binds
end


function Keybinds.onScan(binds, scancode, callback)
	if callback == nil then
		-- get callback for given scancode
		return binds._onPress[scancode] or binds._onRelease[scancode]
	elseif type(callback) == "function" then
		old = binds._onRelease[scancode]
		binds._onPress[scancode] = callback
		binds._onRelease[scancode] = callback
		return old
	else -- callback present, but of the wrong type
		error("Incorrect type of callback: " .. type(callback))
	end
end


function Keybinds.onPress(binds, scancode, callback)
	if callback == nil then
		-- get callback for given scancode
		return binds._onPress[scancode]
	elseif type(callback) == "function" then
		old = binds._onPress[scancode]
		binds._onPress[scancode] = callback
		return old
	else -- callback present, but of the wrong type
		error("Incorrect type of callback: " .. type(callback))
	end
end


function Keybinds.press(binds, key, scancode, isrepeat) -- return true if event handled
	local cb = binds._onPress[scancode]
	if cb then
		response = cb(true, key, scancode, isrepeat)
	end
	return (response and true) or false
end


function Keybinds.onRelease(binds, scancode, callback)
	if callback == nil then
		-- get callback for given scancode
		return binds._onRelease[scancode]
	elseif type(callback) == "function" then
		old = binds._onRelease[scancode]
		binds._onRelease[scancode] = callback
		return old
	else -- callback present, but of the wrong type
		error("Incorrect type of callback: " .. type(callback))
	end
end


function Keybinds.release(binds, key, scancode) -- return true if event handled
	local cb = binds._onRelease[scancode]
	if cb then
		response = cb(false, key, scancode, isrepeat)
	end
	return (response and true) or false
end


function Keybinds.clear(binds)
	binds.onPress = {}
	binds.onRelease = {}
end


return Keybinds, defaultKeyboardHandler
