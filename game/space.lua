require("keybinds")
require("print")
require("unvector")


local main = {}

local FORCE = 100
local ANGLE = 5
local ship_poly = { 16, 0, -16, -16, -8, 0, -16, 16 }



local player = {
	body = nil,
	ang_acc = 0.0,
	nozzle = 0, -- tangent force measure
	nozzle_lim = { low = -4, high = 7 }
}


function createShip()
	local ship = love.physics.newBody(world, 0, 0, "dynamic")
	ship:setMass(100)

	-- unreal
--	ship:setAngularDamping(10)
	ship:setLinearDamping(.5)

	local fix = love.physics.newFixture(ship, ship_shape)
	return ship
end


function main.update(delta)
	-- for ship in ships do
	-- 	ship:applyForce(ship.dir * FORCE * ship.nozzle, ship.dir * FORCE * ship.nozzle)
	local angle = player.body:getAngle()
	player.dir = { x = math.cos(angle), y = math.sin(angle) }
	player.body:applyForce(player.dir.x * FORCE * player.nozzle, player.dir.y * FORCE * player.nozzle)
	player.body:setAngularVelocity(player.body:getAngularVelocity() + player.ang_acc * delta * ANGLE)
	world:update(delta)
	
	transform = love.math.newTransform()
	transform:translate(player.body:getPosition())
	transform:rotate(player.body:getAngle())
end


function main.draw()
	-- World
	love.graphics.push()
	love.graphics.replaceTransform(transform)
	love.graphics.polygon("line", ship_poly)
	love.graphics.pop()
	
	-- UI
	vx, vy = player.body:getLinearVelocity()

	printReset()
	print(vx)
	print(vy)
	print(player.body:getX())
	print(player.body:getY())
	print(player.nozzle)
	print(player.body:getAngle())
end


function main.load()
	width = love.graphics.getWidth()
	height = love.graphics.getHeight()

	font = love.graphics.newFont("assets/press-start-2p.ttf")
	love.graphics.setFont(font)

	-- Ship creation
	world = love.physics.newWorld(0, 0, true) -- true = allow sleep
	ship_shape = love.physics.newPolygonShape(ship_poly)
	
	player.body = createShip()
	player.body:setPosition(width / 2.0, height / 2.0)
	
	love.keyboard.setKeyRepeat(true)
	local keybinds = Keybinds.new()
	local handler = defaultKeybindsHandler(keybinds)
	main.keypressed = handler.keypressed
	main.keyreleased = handler.keyreleased

	keybinds:onScan("escape", function() love.event.quit() end)

	-- Player controls
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
