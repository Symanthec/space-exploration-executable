local license = require("license")
local controller = require("controller")
require("keybinds")
require("print")
require("body")


FORCE = 1000
MAX_SPEED = 300
MAX_FORCE = FORCE / 10
DELTA_ANGLE = math.pi 
MAX_BOTS = 10
SPAN = 800


push = 0 -- whether ship flies or not
bots_enabled = true
debug_draw = false


local main = {}


function spawnShip(near)
	local ship = Body.new()
	local x = (love.math.random() - 0.5) * SPAN + near.x
	local y = (love.math.random() - 0.5) * SPAN + near.y
	ship:setPosition(x, y)

	local angle = math.random() * math.pi * 2
	ship.angle = angle

	speed = (math.random() + 0.3) * MAX_SPEED
	ship:setSpeed(speed * math.cos(angle), speed * math.sin(angle))

	ship:size(16, 16)
	
	return ship
end


function main.load()
	love.keyboard.setKeyRepeat(true)

	gwidth = love.graphics.getWidth()
	gheight = love.graphics.getHeight()

	player = Body.new()
	player.mass = 100
	player.max_speed = MAX_SPEED
	player.max_force = MAX_FORCE
	player:setPosition(400, 300)
	player:size(16, 16)

	ships = {}
	for i=1,MAX_BOTS do
		ships[i] = spawnShip(player)
	end
end


function main.update(delta)
	if push ~= 0.0 then
		dir = player:direction()
		player:addForce( dir[1] * FORCE * push,  dir[2] * FORCE * push )
	end

	player:update(delta)
	
	if bots_enabled then
		for i=1,MAX_BOTS do
			ships[i]:update(delta)
			if math.abs(ships[i].x - player.x) > SPAN / 2.0 or 
			   math.abs(ships[i].y - player.y) > SPAN / 2.0 then
				ships[i] = spawnShip(player) -- replace with new ship)
			end
		end
	end
end


function main.keypressed(key, scancode, isrepeat)
	-- process input
	if scancode == "escape" then love.event.quit() end
	
	if scancode == "space" then
		player:setForce( 0, 0 )
		player:setSpeed( 0, 0 )
		player:setPosition( gwidth / 2.0, gheight / 2.0 )
		player.angle = 0.0
		player.angular_acc = 0.0
		player.angular_velocity = 0.0
	elseif scancode == "w" then
		push = math.min(3.0, push + 1) 
	elseif scancode == "s" then
		push = math.max(-3.0, push - 1)
	elseif scancode == "a" then
		player.angular_acc = math.max(-3 * DELTA_ANGLE, player.angular_acc - DELTA_ANGLE)
	elseif scancode == "d" then
		player.angular_acc = math.min(3 * DELTA_ANGLE, player.angular_acc + DELTA_ANGLE)
	elseif scancode == "b" then
		bots_enabled = not bots_enabled
	elseif scancode == "e" then
		debug_draw = not debug_draw
	end
end


function main.keyreleased(key, scancode, isrepeat)
	if scancode == "w" then
		push = 0
		player:setForce( 0, 0)
	elseif scancode == "s" then
		push = 0
		player:setForce( 0, 0)
	elseif scancode == "a" then
		player.angular_acc = 0
	elseif scancode == "d" then
		player.angular_acc = 0
	end
end


white = {255, 255, 255}
red = {255, 0, 0}
player_color = {128, 128, 0}
blue = {0, 64, 192}
green = {64, 255, 64}


function main.draw()
	-- draw stuff
	printReset()
	love.graphics.setColor(player_color)
	love.graphics.push()
	love.graphics.translate(player.x, player.y)
	love.graphics.rotate(player.angle)
	love.graphics.rectangle("fill", -player.half_w, -player.half_h, player.width, player.height)
	love.graphics.pop()

	if bots_enabled then
		if debug_draw then
			love.graphics.rectangle("line", player.x - SPAN / 2.0, player.y - SPAN / 2.0, SPAN, SPAN)
		end

		love.graphics.setColor(white)
		for i=1,MAX_BOTS do
			local ship = ships[i]
			if ship then
				love.graphics.push()
				love.graphics.translate(ship.x, ship.y)
				love.graphics.rotate(ship.angle)
				love.graphics.rectangle("line", -ship.half_w, -ship.half_h, ship.width, ship.height)
				love.graphics.pop()
			end
		end
	end

	if debug_draw then
		love.graphics.setColor(green)
		dir = player:direction()
		love.graphics.line(player.x, player.y, player.x + 100 * dir[1], player.y + 100 * dir[2])

		love.graphics.setColor(blue)
		love.graphics.line(player.x, player.y, player.x + player.ax, player.y + player.ay)
		love.graphics.setColor(red)
		love.graphics.line(player.x, player.y, player.x + player.vx, player.y + player.vy)
	
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


-- Main initialization
function love.load()
	-- Check whether lic is accepted
	ctrl = (license.isAccepted() and main) or license.controller(main)
	controller.switch(ctrl)
end
