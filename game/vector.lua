Vector = {}
Vector.__index = Vector
Vector.__metatable = Vector


Vector.__index = function(t, k)
	if type(k) ~= "number" then
		error("Invalid key type - " .. type(k))
	elseif k < 1 or t.__size < k then
		error("Key out of range: " .. k)
	else
		return t[k]
	end
end


Vector.__newindex = function(t, k, v)
	if t.__lock then
		error("Modifying locked container")
	elseif type(k) ~= "number" or t.__size < k or k < 1 then
		error("Only keys in range 1 to " .. t.__size .. " are valid")
	else
		t[k] = v
	end
end


function Vector.new(copy)
	local vec = {
		__lock = false
		__size = 0
	}
	setmetatable(vec, Vector)
end


function Vector.size(vector)
	return vector.__size
end


function Vector.add(vector, item)
	if vector.__lock then error("attempt to modify vector that was locked") end

	vector.__size = vector.__size + 1
	vector[vector.__size] = item
	return vector.__size -- item's index
end


function Vector.removeIndex(vector, index)
	if vector.__lock then error("attempt to modify vector that was locked") end

	local prev = vector[index]
	for i = index, vector.__size - 1 do
		vector[i] = vector[i+1]
	end
	vector.__size = vector.__size - 1
	return prev
end


function Vector.remove(vector, item)
	if vector.__lock then error("attempt to modify vector that was locked") end

	-- search items
	local size, i = vector.__size, 1
	repeat
		if vector[i] == item then
			vector:removeIndex(i)
			-- return the index the item was at
			return i 
		end
		i = i + 1
	until i > vector.__size
	return nil -- not found
end


function Vector.forEach(vector, consumer)
	vector.__lock = true
	for i=1,vector.__size do
		consumer(vector[i], i)
	end
	vector.__lock = false
end


function Vector.map(vector, consumer, context)
	vector.__lock = true
	local mapped = Vector.new()
	vector:forEach(function (item, index)
		value, context = consumer(item, index, context)
		mapped:add(value)
	end)
	vector.__lock = false
	return mapped
end


function Vector.reduce(vector, consumer, context)
	vector.__lock = true
	local reduced = Vector.new()
	vector:forEach(function (item, index)
		condition, context = consumer(item, index, context)
		if condition then reduced:add(item) end
	end)
	vector.__lock = false
	return reduced
end
