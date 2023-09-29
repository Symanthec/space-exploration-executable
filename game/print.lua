-- Primitive printing util, which mimics terminal

local line = 0


function print(text, color, font)
	local oldcol = { love.graphics.getColor() }
	local oldfont = love.graphics.getFont()
	
	love.graphics.setColor(unpack(color or oldcol))
	love.graphics.setFont(font or oldfont)
	
	love.graphics.print(text or "", 10, 10 + line * love.graphics.getFont():getHeight())

	love.graphics.setColor(oldcol)
	love.graphics.setFont(oldfont)

	line = line + 1
end


function printReset() line = 0 end
