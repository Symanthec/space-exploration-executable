-- Primitive printing util, which mimics terminal

local line = 0


function print(text, color)
	if color then
		local oldcol = love.graphics.getColor()
		love.graphics.setColor(unpack(color))
	end
	love.graphics.print(text, 10, 10 + line * love.graphics.getFont():getHeight())
	if oldcol then love.graphics.setColor(oldcol) end
	line = line + 1
end


function printReset() line = 0 end
