push = 0


function resetPlayer()
	player:setForce( 0, 0 )
	player:setSpeed( 0, 0 )
	player:setPosition( gwidth / 2.0, gheight / 2.0 )
	player.angle = 0.0
	player.angular_acc = 0.0
	player.angular_velocity = 0.0
end


function pullPlayer(ispressed, _, scancode)
	if ispressed then
		if scancode == "w" then
			push = math.min(3.0, push + 1)
		else
			-- pull backwards
			push = math.max(-3.0, push - 1)
		end
	else
		push = 0
		player:setForce(0, 0)
	end
end


function rotatePlayer(ispressed, _, scancode)
	if ispressed then
		if scancode == "a" then
			player.angular_acc = math.max(-3 * DELTA_ANGLE, player.angular_acc - DELTA_ANGLE)
		elseif scancode == "d" then
			player.angular_acc = math.min(3 * DELTA_ANGLE, player.angular_acc + DELTA_ANGLE)
		end
	else
		player.angular_acc = 0
	end
end


function updatePlayer(delta)
	if push ~= 0.0 then
		dir = player:direction()
		player:addForce( dir[1] * FORCE * push,  dir[2] * FORCE * push )
	end
end


function setPlayer(body)
	player = body
end
