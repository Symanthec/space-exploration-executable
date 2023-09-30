require("keybinds")
require("print")
require("unvector")
require("entity")
require("camera")


local main = {}

local FORCE = 10
local ANGLE = 5
local SPAN = 600


local ship_body = { 8, 0, -8, -8, -6, -3, -8, -3, -8, 3, -6, 3, -8, 8 }
local ship_poly = { 8, 0, -8, -8, -6, -3, -8, -3, -8, 3, -6, 3, -8, 8 }
local asteroid_poly = { -8, 16, 8, 16, 16, 8, 16, -8, 8, -16, -8, -16, -16, -8, -16, 8 }


local entities = UnVector.new()
local last_scan = ""


local scale = 1
local scale_t = { min = 0.7, max = 2, current = 1.0, step = 0.01  }
local scale = scale_t.current -- quick name
local zooming = 0


function createBody(mass, shape)
	local body = love.physics.newBody(world, 0, 0, "dynamic")
	body:setMass(tonumber(mass) or 1.0)
	local fix = love.physics.newFixture(body, shape)
	return body
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
	local angle = player.body:getAngle()
	player.dir = { x = math.cos(angle), y = math.sin(angle) }
	player.body:applyForce(player.dir.x * FORCE * player.nozzle, player.dir.y * FORCE * player.nozzle)
	player.body:setAngularVelocity(player.body:getAngularVelocity() + player.ang_acc * delta * ANGLE)

	world:update(delta)

	-- scale
	scale_t.current = math.min(scale_t.max, math.max(scale_t.min, scale_t.current + scale_t.step * zooming))
	scale = scale_t.current
	camera:setScale(scale)
	camera:update(delta)
	
	for _, ent in ipairs(entities) do
		local transform = love.math.newTransform()
		transform:translate(ent.body:getPosition())
		transform:rotate(ent.body:getAngle())
		ent.transform = transform
	end
end


function main.draw()
	-- World
	love.graphics.push()
	love.graphics.replaceTransform(camera.transform)
	for _, ent in ipairs(entities) do
		love.graphics.push()
		love.graphics.applyTransform(ent.transform)
		
		love.graphics.setColor(ent.color)
		love.graphics.polygon("fill", ent.polygon)

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

	for k, v in ipairs(camera) do
		print(tostring(k).." "..tostring(v))
	end
end


function main.load()
	width = love.graphics.getWidth()
	height = love.graphics.getHeight()

	font = love.graphics.newFont("assets/press-start-2p.ttf")
	love.graphics.setFont(font)

	-- Ship creation
	world = love.physics.newWorld(0, 0, true) -- true = allow sleep
	local ship_shape = love.physics.newPolygonShape(ship_body)
	
	player = Entity.new()
	player.body = createBody(100, ship_shape)
	player.color = {1, .89, 0}
	player.polygon = ship_poly
	player.body:setPosition(width / 2.0, height / 2.0)
	entities:add(player)
	camera = Camera
	camera:setTarget(player)

	local rate = .8
	camera:setStep(function(dt) return 1 - rate * math.exp(-dt) end)


	local asteroid_shape = love.physics.newPolygonShape(asteroid_poly)
	for i=1,20 do
		local ent = Entity.new()
		ent.body = createBody(1000, asteroid_shape)
		ent.polygon = asteroid_poly
		ent.color = {1, 1, 1}
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
