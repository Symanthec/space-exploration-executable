-- Body physics
-- Model uses cartersian coordinates, speeds and forces


Body = {}
Body.__index = Body


function Body.new(mass, x, y, angle, width, height)
	local width = tonumber(width) or 0
	local height = tonumber(height) or 0
	local body = {
		x = tonumber(x) or 0,
		vx = 0,
		ax = 0,

		y = tonumber(y) or 0,
		vy = 0,
		ay = 0,

		angle = tonumber(angle) or 0,
		angular_velocity = 0,
		angular_acc	 = 0,
		
		max_force = math.huge,
		max_speed = math.huge,
		mass = tonumber(mass) or 1.0,
		width = width,
		height = height,
		half_w = width / 2.0,
		half_h = height / 2.0
	}
	setmetatable(body, Body)
	return body
end


function Body.direction(body)
	return { math.cos(body.angle), math.sin(body.angle) }
end


function Body.setPosition(body, x, y)
	body.x = tonumber(x) or body.x
	body.y = tonumber(y) or body.y
end


function Body.size(body, w, h)
	if not w and not h then
		return { body.width, body.height }
	else
		w, h = tonumber(w) or 0.0, tonumber(h) or 0.0
		body.width = w
		body.height = h

		body.half_w = w / 2.0
		body.half_h = h / 2.0
	end
end


function Body.setSpeed(body, vx, vy)
	local vx = tonumber(vx) or 0.0
	local vy = tonumber(vy) or 0.0

	local new_abs = math.sqrt(vx * vx + vy * vy)
	if new_abs > body.max_speed then
		new_abs = body.max_speed / new_abs
		vx = vx * new_abs
		vy = vy * new_abs
	end

	body.vx = vx
	body.vy = vy
end


function Body.setForce(body, ax, ay)
	local ax = tonumber(ax) or 0.0
	local ay = tonumber(ay) or 0.0

	local new_abs = math.sqrt(ax * ax + ay * ay)
	if new_abs > body.max_force then
		new_abs = body.max_force / new_abs
		ax = ax * new_abs
		ay = ay * new_abs
	end

	body.ax = ax
	body.ay = ay
end


function Body.setAngle(body, angle)
	body.angle = tonumber(angle) or body.angle
end


function Body.setAngularVelocity(body, ang_vel)
	body.angular_velocity = tonumber(ang_vel) or body.angular_velocity
end


function Body.addAngularVelocity(body, ang_vel)
	body:setAngularVelocity(body.angular_velocity + (tonumber(ang_vel) or 0.0))
end


function Body.translate(body, x, y)
	body.x = body.x + (tonumber(x) or 0)
	body.y = body.y + (tonumber(y) or 0)
end


function Body.addSpeed(body, vx, vy)
	body:setSpeed(body.vx + vx, body.vy + vy)
end


function Body.rotate(body, angle)
	body.angle = body.angle + (tonumber(angle) or 0)
end


function Body.addForce(body, fx, fy)
	fx = tonumber(fx) or 0.0
	fy = tonumber(fy) or 0.0
	body:setForce(body.ax + fx / body.mass, body.ay + fy / body.mass)
end


function Body.stop(body)
	body:setForce{}
end


function Body.update(body, delta)
	local delta = tonumber(delta) or 0.0
	if delta == 0.0 then return end

	body:translate((body.vx + body.ax * delta / 2.0) * delta,
			(body.vy + body.ay * delta / 2.0) * delta)
	
	body:addSpeed(body.ax * delta, body.ay * delta)
	

	body:addAngularVelocity(body.angular_acc * delta)
	body:setAngle(body.angle + body.angular_velocity * delta)
end


return Body
