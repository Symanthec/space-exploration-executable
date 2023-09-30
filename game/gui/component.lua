-- GUI library
--
-- Possible component events
-- Click
-- Key
-- Mouse
-- Drag?
-- Resize
-- Change (radio, check)
-- any (poll for "event_name" labeled events)

Component = {}
Component.__newindex = nil
Component.__metatable = Component


function protectTable(table)
	assert(type(table) == "table")
	local mt = {}
	mt.__index = table
	mt.__newindex = function(table, key, value)
		if table[key] then
			error("Trying to modify read-only table")
		else
			table[key] = value
		end
	end
	return mt
end


function Component.new()
	local comp = { _ = {} }
	setmetatable(comp, Component)
	return comp
end


function Component.addEventListener(comp, eventName, callback)
	assert(type(eventName) == "string" and type(callback) == "function")
	if eventName._listeners[eventName]
	eventName._listeners[eventName] = callback
end


function Component.draw(component) end


function Component.handleEvent(component, event) end


function Component.resize(width, height) end
