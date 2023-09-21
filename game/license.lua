-- game/main.lua


local controller = require("controller")


license = [[
Please read this tiny LICENSE before using the game.
This game was originally created by Ilya Reznik in 2023
and any distribution of this game with or without the
source code must contain this LICENSE and mention the
original author EXPLICITLY. ALL modifications to the
game files including, but not limited to source code,
texts, sounds, images, scripts must be listed and end
user must be informed of these changes. 

- You may not use this product without accepting this LICENSE

- You may do anything with this product 

If you PUBLISH this game on website, gaming console, personal
computer, mobile phone, mobile tablet or any other electronic
device or if you PORT this game to new platform or new language
you are asked to inform the former author, though not strict,
by E-Mail (rez2004ilya@gmail.com) and leave a note to end
users that this port or publication is unofficial and was
made without authors consent.

I hope you will enjoy my game as much as I enjoyed making it.
]]


-- Available functions:
-- license.isAccepted()
-- license.controller(next)


local licenseAccepted = true


local T = {}


function T.isAccepted()
	if licenseAccepted == nil then
		-- load info from file
	end
	return licenseAccepted
end


local function acceptLicense()
	-- placeholder for file 
	licenseAccepted = true
	return
end


-- License controller which Love runs
local _licenseController = {
	-- Controller to switch to upon accepting the license
	_nextTarget = nil
}


function _licenseController.draw()
	love.graphics.print(license, 10, 10)
end


function _licenseController.keypressed(key, scan, isrepeat)
	if scan == "return" then
		acceptLicense()
		controller.switch(_licenseController._nextTarget)
	elseif scan == "escape" then
		love.event.quit()
	end
end


function T.controller(nextController)
	_licenseController._nextTarget = nextController
	return _licenseController
end


return T
