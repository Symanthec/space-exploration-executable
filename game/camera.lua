Camera = {
	transform = love.math.newTransform(),
	scale = 1.0,
	x = 0,
	y = 0,
	stepfunc = function(delta) return 1.0 - delta end,
	target = nil
}


function Camera:setScale(scale)
	self.scale = scale
end


function Camera:setStep(step)
	self.stepfunc = step
end


function Camera:setTarget(tgt)
	self.target = tgt
end


function Camera:update(delta)
	if not self.target then return end

	local dx, dy = self.target.body:getPosition()
	dx, dy = dx - self.x, dy - self.y
	
	local step = self.stepfunc(delta)
	self.x, self.y = self.x + dx * step, self.y + dy * step
	
	self.transform = love.math.newTransform()
	self.transform:translate(
		width / 2 - self.x * self.scale,
		height/ 2 - self.y * self.scale)
	self.transform:scale(self.scale)
end


return Camera
