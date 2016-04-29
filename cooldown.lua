--[[
	Class for the cooldown at game over
]]

Cooldown = Pie:extend()

function Cooldown:new()
	Cooldown.super.new(self)
	self.pos = { x = g.width/2, y = g.height/2 }
	self.radius = 300
	self.color = g.colors.grey
	self.speed = 1/8
	self.scale = 1
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
