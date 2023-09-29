-- controller.lua


local T = {}


-- One utility function for scene/controller/state switch
function T.switch(controller)
	if controller.load then controller.load() end
	-- Don't want to mess much
	-- Just copy into "love" table every kv-pair of controller
	love.draw = controller.draw			or love.draw
	love.update = controller.update			or love.update
	love.keypressed = controller.keypressed		or love.keypressed
	love.keyreleased = controller.keyreleased 	or love.keyreleased
end


return T
