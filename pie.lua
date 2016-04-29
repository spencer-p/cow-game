--[[
	Class for pop-up tappable areas
]]

Object = require "classic"

Pie = Object:extend()

-- Takes object { img, pos, radius, color, speed }
function Pie:new()
	self.timerlen = 1
	self.timer = self.timerlen
	self.exists = true
	self.tapped = false
	self.processed = false
end

function Pie:update(dt)
	self.timer = self.timer - dt*self.speed
	if self.timer <= 0 then
		self.exists = false
	end
	return self.exists
end

function Pie:drawArc()
	if self.exists then
		love.graphics.setColor(self.color)
		love.graphics.arc("fill", self.pos.x, self.pos.y, self.radius*self.scale, 3*math.pi/2, -2*math.pi*(self.timer/self.timerlen)+3*math.pi/2, 32)
	end
end

function Pie:drawImg()
	if self.exists then
		local s = self.scale > 1 and 1 or self.scale
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.img, self.pos.x-(self.img:getWidth()/2)*s, self.pos.y-(self.img:getWidth()/2)*s, 0, s, s)
	end
end

function Pie:draw()
	self:drawArc()
	self:drawImg()
end

function Pie:touchpressed(id, x, y)
	if not self.tapped then
		if self:distanceTo(x, y) <= self.radius * self.scale then
			self.tapped = true
			self:action()
		end
	end
end

function Pie:touchreleased(id, x, y)
	if self:distanceTo(x, y) <= self.radius * self.scale then
		self:inaction()
	end
end

function Pie:distanceTo(x, y)
	return math.dist(self.pos.x, self.pos.y, x, y)
end

function Pie:action()
	self.exists = false
end

function Pie:reset()
	self.timer = self.timerlen
	self.exists = true
	self.tapped = false
	self.processed = false
	self.speed = 1
end
