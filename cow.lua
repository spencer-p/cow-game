--[[
	Class for pop-up tappable cow
]]

Cow = Pie:extend()

function Cow:new()
	Cow.super.new(self)
	self.pos = { x = nil, y = nil }
	self.img = g.cowsettings.img
	self.radius = g.cowsettings.radius
	self.color = g.colors.grey
	self:setPosition()
	self:setSpeed()
	self.scale = 0
	flux.to(self, 0.1, { scale = 1*g.cowsettings.scale } ):ease("backout")
end

function Cow:setSpeed()
	self.speed = speed() * g.cowsettings.speedmultiplier
end

function Cow:setPosition()

	local function spaced()
		for i, c in ipairs(g.cows) do
			if self:distanceTo(c.pos.x, c.pos.y) < self.radius*2 then
				return false
			end
		end
		return true
	end

	repeat
		self.pos.x = love.math.random(self.radius*2, g.width-self.radius*2)
		self.pos.y = love.math.random(self.radius*2, g.height-self.radius*2)
	until #g.cows == 0 or spaced()

end

function Cow:action()
	flux.to(self, 0.1, { scale = 0 } ):ease("circout"):oncomplete( function() self.exists = false end )
end
