require("keybinds")
require("print")
require("body")

require("player")


FORCE = 1000
MAX_SPEED = 300
MAX_FORCE = FORCE / 10.0
DELTA_ANGLE = math.pi
SPAN = 800
MAX_BOTS = 15


local bots_enabled = true
local debug_draw = false


function spawnShip(proto)
	local ship = Body.new()
	
	if proto then
		ship:setPosition(proto.x, proto.y)
		ship:setSpeed(proto.vx, proto.vy)
		ship:setForce(proto.ax, proto.ay)
		ship:size(proto.width, proto.height)	

		ship.angle = proto.angle
		ship.angular_velocity = proto.angular_velocity
		ship.angular_acc = proto.angular_acc
		ship.mass = proto.mass
<<<<<<< HEAD

		ship.max_speed = proto.max_speed
		ship.max_force = proto.max_force
=======
>>>>>>> 461a78f (Keybinds rework, player assignment and manipulation to player.lua)
	end

	return ship
end


function randomizeShip(ship, near)
	local x = (math.random() - 0.5) * SPAN + near.x
	local y = (math.random() - 0.5) * SPAN + near.y
	ship:setPosition(x, y)

	local angle = math.random() * math.pi * 2
	ship.angle = angle
	
	local speed = math.random() * MAX_SPEED
	ship:setSpeed(speed * math.cos(angle), speed * math.sin(angle))
end


local toggleDebug = function(ispressed, key, scancode, isrepeat)
	if ispressed and not isrepeat then
		debug_draw = not debug_draw
	end
end


local showBots = function(ispressed, key, scancode, isrepeat)
	if ispressed and not isrepeat then
		bots_enabled = not bots_enabled
	end
end


local quitProgram = function()
	love.event.quit()
end


local controller = {}


function controller.keypressed(key, scancode, isrepeat)
	last_scan = scancode
	if not keybinds:press(key, scancode, isrepeat) then
		-- parse the remainder of possible key combos
	end
end


function controller.keyreleased(key, scancode)
	last_scan = scancode
	if not keybinds:release(key, scancode) then
		-- parse the remainder of possible key combos
	end
end


function controller.load()
	love.keyboard.setKeyRepeat(true)

	gwidth = love.graphics.getWidth()
	gheight = love.graphics.getHeight()

	keybinds = Keybinds.new()
	keybinds:onPress("escape", quitProgram)
	keybinds:onPress("space", resetPlayer)
	keybinds:onPress("b", showBots)
	keybinds:onPress("v", toggleDebug)

	keybinds:onPress("w", pullPlayer)
	keybinds:onRelease("w", pullPlayer)
	keybinds:onPress("s", pullPlayer)
	keybinds:onRelease("s", pullPlayer)

	keybinds:onPress("a", rotatePlayer)
	keybinds:onRelease("a", rotatePlayer)
	keybinds:onPress("d", rotatePlayer)
	keybinds:onRelease("d", rotatePlayer)
	
	proto = Body.new()
	proto.mass = 100
	proto.max_speed = MAX_SPEED
	proto.max_force = MAX_FORCE
	proto:setPosition(gwidth / 2.0, gheight / 2.0)
	proto:size(16, 16)
	setPlayer(proto)

	ships = {}
	for i=1,MAX_BOTS do
		ships[i] = spawnShip(player)
		randomizeShip(ships[i], player)
	end
	ships[MAX_BOTS + 1] = player
end


function controller.update(delta)
	updatePlayer(delta)

	local i = 1
	while ships[i] ~= nil do
		if bots_enabled or ships[i] == player then
			ships[i]:update(delta)
		end
		if ships[i] ~= player then
			if math.abs(ships[i].x - player.x) > SPAN / 2.0 or 
			   math.abs(ships[i].y - player.y) > SPAN / 2.0 then
			   	randomizeShip(ships[i], player)
			end
		end

		i = i + 1
	end
end


white = {255, 255, 255}
red = {255, 0, 0}
yellow = {128, 128, 0}
blue = {0, 0, 192}
green = {0, 255, 0}


function controller.draw()
	-- draw stuff

	love.graphics.setColor(yellow)
	if debug_draw then
		love.graphics.rectangle("line", player.x - SPAN / 2.0, player.y - SPAN / 2.0, SPAN, SPAN)
	end

	love.graphics.setColor(white)
	local i = 1
	while ships[i] ~= nil do
		local ship = ships[i]
		
		if ship == player then love.graphics.setColor(yellow) end
		love.graphics.push()
		love.graphics.translate(ship.x, ship.y)
		love.graphics.rotate(ship.angle)
		love.graphics.rectangle("line", -ship.half_w, -ship.half_h, ship.width, ship.height)
		love.graphics.pop()
		if ship == player then love.graphics.setColor(white) end

		i = i + 1
	end

	if debug_draw then
		love.graphics.setColor(green)
		dir = player:direction()
		love.graphics.line(player.x, player.y, player.x + 100 * dir[1], player.y + 100 * dir[2])

		love.graphics.setColor(blue)
		love.graphics.line(player.x, player.y, player.x + player.ax, player.y + player.ay)
		love.graphics.setColor(red)
		love.graphics.line(player.x, player.y, player.x + player.vx, player.y + player.vy)
	
		printReset()
		print("FPS = " .. love.timer.getFPS())
		print("X  = ".. player.x)
		print("Y  = ".. player.y)
		print("Vx = ".. player.vx)
		print("Vy = ".. player.vy)
		print("Ax = ".. player.ax)
		print("Ay = ".. player.ay)
		print("Ang= ".. player.angle)
		print("Wv = ".. player.angular_velocity)
		print("W  = ".. player.angular_acc)
	end
end


return controller
