UnVector = {}
UnVector.__index = UnVector


function UnVector.new(copy)
	local vec = {}
	vec.size = 0
	setmetatable(vec, UnVector)
	
	if type(copy) == "table" then
		for k, v in ipairs(copy) do
			vec[k] = v
		end
	end

	return vec
end


-- create iterator
function UnVector.add(vec, item)
	vec.size = vec.size + 1
	vec[vec.size] = item
end



function UnVector.remove(vec, item)
	for i=1,vec.size do
		if vec[i] == item then
			vec[i] = vec[vec.size]
			vec[vec.size] = nil
			vec.size = vec.size - 1
		end
	end
end


function UnVector.removeByIndex(vec, index)
	if 1 <= index and index <= vec.size then
		vec[index] = vec[vec.size]
		vec[vec.size] = nil
		vec.size = vec.size - 1
	end
end

return UnVector
