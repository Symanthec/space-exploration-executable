local function camera_delta(start, finish, tau)
	-- 0 <= Tau <= 1
	return {
		x = start.x + (finish.x - start.x) * tau,
		y = start.y + (finish.y - start.y) * tau
	}
end


Camera = {}
Camera.__index = Camera


function Camera.new(target)
	local cam = { x = 0.0, y = 0.0, _target = target, _rate = 1.0 }
	setmetatable(cam, Camera)
	return cam
end


function Camera.target(camera, tgt)
	camera._target = tgt
end


function Camera.update(camera, delta)
	if camera._target then
		local range = math.sqrt( math.pow(camera.x - camera._target.x, 2) + math.pow(camera.y - camera._target.y, 2))
		local new_pos = camera_delta(camera, camera._target, camera._rate)
		camera.x = new_pos.x
		camera.y = new_pos.y
	end
end


function Camera.rate(camera, rate)
	camera._rate = tonumber(rate) or camera._rate
end


return Camera
