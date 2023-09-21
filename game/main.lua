local license = require("license")
local controller = require("controller")
local main = require("space")


-- Main initialization
function love.load()
	-- Check whether lic is accepted
	ctrl = (license.isAccepted() and main) or license.controller(main)
	controller.switch(ctrl)
end
