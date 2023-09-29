require("keybinds")
require("print")
require("unvector")
require("entity")

local main = {}

local FORCE = 100
local ANGLE = 5
local SPAN = 600


local ship_body = { 16, 0, -16, -16, -12, -6, -16, -6, -16, 6, -12, 6, -16, 16 }
local ship_poly = { 16, 0, -16, -16, -12, -6, -16, -6, -16, 6, -12, 6, -16, 16 }


local camera = {}
local entities = UnVector.new()
local last_scan = ""
local scale = 1

local scale_t = { min = 0.7, max = 1.5, current = 1.0, step = 0.01  }
local scale = scale_t.current -- quick name

zooming = 0


function createShip()
	local ship = love.physics.newBody(world, 0, 0, "dynamic")
	ship:setMass(100)

--	ship:setAngularDamping(.2)
--	ship:setLinearDamping(.5)

	local fix = love.physics.newFixture(ship, ship_shape)
	return ship
end


function randomizeEntity(entity, near, max_speed)
	if not entity or not near then return end

	angle = math.random() * math.pi * 2
	speed = math.random() * max_speed
	x, y = (math.random() * 2 - 1) * SPAN + near.body:getX(),
	       (math.random() * 2 - 1) * SPAN + near.body:getY()

	entity.body:setPosition(x, y)
	entity.body:setLinearVelocity(speed * math.cos(angle), speed * math.sin(angle))
	entity.body:setAngle(angle)
end


function main.update(delta)
	-- for ship in ships do
	-- 	ship:applyForce(ship.dir * FORCE * ship.nozzle, ship.dir * FORCE * ship.nozzle)
	local angle = player.body:getAngle()
	player.dir = { x = math.cos(angle), y = math.sin(angle) }
	player.body:applyForce(player.dir.x * FORCE * player.nozzle, player.dir.y * FORCE * player.nozzle)
	player.body:setAngularVelocity(player.body:getAngularVelocity() + player.ang_acc * delta * ANGLE)

	world:update(delta)

	-- scale
	scale_t.current = math.min(scale_t.max, math.max(scale_t.min, scale_t.current + scale_t.step * zooming))
	scale = scale_t.current

	camera.transform = love.math.newTransform()
	scale = scale_t.current
	camera.transform:translate(
		width / 2 - player.body:getX() * scale,
		height / 2 - player.body:getY() * scale)
	camera.transform:scale(scale)
	
	for _, ent in ipairs(entities) do
		local transform = love.math.newTransform()
		transform:translate(ent.body:getPosition())
		transform:rotate(ent.body:getAngle())
		ent.transform = transform
	end
end


function main.draw()
	-- World

	-- for entity in entities do
	-- 	love.graphics.replaceTransform(entity.transform)
	-- 	love.graphics.polygon("fill", entity.poly)
	-- end
	love.graphics.push()
	love.graphics.replaceTransform(camera.transform)
	for _, ent in ipairs(entities) do
		love.graphics.push()
		love.graphics.applyTransform(ent.transform)
		
		if ent == player then love.graphics.setColor(1, .89, 0) end
		love.graphics.polygon("fill", ship_poly)
		if ent == player then love.graphics.setColor(1, 1, 1) end

		love.graphics.pop()
	end
	love.graphics.pop()

	-- UI
	printReset()
	print(player.body:getX())
	print(player.body:getY())
	print(player.nozzle)
	print(player.body:getAngle())
	print(last_scan)
	print(scale)
end


function main.load()
	width = love.graphics.getWidth()
	height = love.graphics.getHeight()

	font = love.graphics.newFont("assets/press-start-2p.ttf")
	love.graphics.setFont(font)

	-- Ship creation
	world = love.physics.newWorld(0, 0, true) -- true = allow sleep
	ship_shape = love.physics.newPolygonShape(ship_body)
	
	player = Entity.new()
	player.body = createShip()
	player.body:setPosition(width / 2.0, height / 2.0)
	entities:add(player)

	for i=1,20 do
		local ent = { body = createShip() }
		randomizeEntity(ent, player, 0)
		entities:add(ent)
	end
	
	love.keyboard.setKeyRepeat(true)
	local keybinds = Keybinds.new()
	local handler = defaultKeybindsHandler(keybinds)
	main.keypressed = function(key, scan, isrepeat) 
		last_scan = scan
		return handler.keypressed(key, scan, isrepeat)
	end
	main.keyreleased = handler.keyreleased

	keybinds:onScan("escape", function() love.event.quit() end)

	local function zoom(press, _, scan)
		if not press then
			zooming = 0
		else
			if scan == "-" then
				zooming = -1 
			else -- scan == "="
				zooming = 1
			end
		end
	end

	keybinds:onScan("-", zoom)
	keybinds:onScan("=", zoom)

	local thrust = function(ispressed, key, scancode, isrepeat)
		if ispressed then
			if scancode == "w" and (player.nozzle < player.nozzle_lim.high) then
				player.nozzle = player.nozzle + 1
			elseif scancode == "s" and (player.nozzle > player.nozzle_lim.low) then
				player.nozzle = player.nozzle - 1
			end
		else
			player.nozzle = 0
			player.body:applyForce(0, 0) 
		end
	end

	local rotate = function(ispressed, key, scancode, isrepeat)
		if ispressed then
			if scancode == "a" then
				player.ang_acc = player.ang_acc - 1
			else -- scancode == "d" then
				player.ang_acc = player.ang_acc + 1
			end
		else
			player.ang_acc = 0
		end
	end
	
	keybinds:onScan("w", thrust)
	keybinds:onScan("s", thrust)
	keybinds:onScan("a", rotate)
	keybinds:onScan("d", rotate)
	
	keybinds:onPress("r", function()
		player.body:setPosition(width / 2.0, height / 2)
		player.body:setAngle(0)
		player.body:setAngularVelocity(0)
		player.body:setLinearVelocity(0, 0)
	end)
end


return main
