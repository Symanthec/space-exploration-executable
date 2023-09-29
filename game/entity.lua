Entity = {}


function Entity.new()
	local ent = {}
	setmetatable(ent, Entity)
	return ent
end

-- Entity prototype --
local proto = Entity.new()
proto.nozzle = 0
proto.nozzle_lim = { low = -2, high = 3 }
proto.ang_acc = 0.0
Entity.__index = proto


return Entity
