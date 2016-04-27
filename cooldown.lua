--[[
	Class for the cooldown at game over
]]

Cooldown = Pie:new()

function Cooldown:new()
	local object = {}
	setmetatable(object, self)
	self.__index = self

	object.pos = { x = love.graphics.getWidth()/2, y = love.graphics.getHeight()/2 }
	object.radius = 300
	object.color = g.colors.grey
	object.speed = 1/8
	object.scale = 1

	return object
end

function Cooldown:action()
	flux.to(self, 0.1, { speed = 1 } ):ease("quadin")
end

function Cooldown:inaction()
	flux.to(self, 0.1, { speed = 1/8 } ):ease("quadout")
end

function Cooldown:reset()
	self.timer = self.timerlen
	self.speed = 1/8
	self.exists = true
	self.tapped = false
	self.processed = false
	self.scale = 0
	flux.to(self, 0.25, { scale = 1 } )
end

function Cooldown:touchpressed(id, x, y)
	self.tapped = true
	self:action()
end

function Cooldown:touchreleased(id, x, y)
	self:inaction()
end
