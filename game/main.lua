local license = require("license")
local controller = require("controller")
local main = require("space")


width, height = love.graphics.getWidth(), love.graphics.getHeight()


function love.resize(new_w, new_h)
	width, height = new_w, new_h
end


-- Main initialization
function love.load()
	-- Check whether lic is accepted
	ctrl = (license.isAccepted() and main) or license.controller(main)
	controller.switch(ctrl)
end
