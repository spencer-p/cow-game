--[[
	Class for pop-up tappable cow
]]

Cow = Pie:new()

function Cow:new()
	local object = {}
	setmetatable(object, self)
	self.__index = self

	object.pos = { x = nil, y = nil }
	object.img = g.cowsettings.img
	object.radius = g.cowsettings.radius
	object.color = g.colors.grey
	object:setPosition()
	object:setSpeed()
	object.scale = 0
	flux.to(object, 0.1, { scale = 1 } ):ease("backout")

	return object
end

function Cow:setSpeed()
	self.speed = speed()
end

function Cow:setPosition()

	local function spaced()
		for i, c in ipairs(g.cows) do
			if self:distanceTo(c) < self.radius*2 then
				return false
			end
		end
		return true
	end

	repeat
		self.pos.x = love.math.random(self.radius*2, love.graphics.getWidth()-self.radius*2)
		self.pos.y = love.math.random(self.radius*2, love.graphics.getHeight()-self.radius*2)
	until #g.cows == 0 or spaced()

end

function Cow:action()
	flux.to(self, 0.1, { scale = 0 } ):ease("backin"):oncomplete( function() self.exists = false end )
end
