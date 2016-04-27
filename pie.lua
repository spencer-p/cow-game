--[[
	Class for pop-up tappable areas
]]

Pie = {}

-- Takes object { img, pos, radius, color, speed }
function Pie:new(o)
	local object = o or {}

	object.timerlen = 1
	object.timer = object.timerlen
	object.exists = true
	object.tapped = false
	object.processed = false

	setmetatable(object, self)
	self.__index = self
	return object
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
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(self.img, self.pos.x-(self.img:getWidth()/2)*self.scale, self.pos.y-(self.img:getWidth()/2)*self.scale, 0, self.scale, self.scale)
	end
end

function Pie:draw()
	self:drawArc()
	self:drawImg()
end

function Pie:touchpressed(id, x, y)
	if math.sqrt((y-self.pos.y)^2+(x-self.pos.x)^2) <= self.radius*self.scale then
		self.tapped = true
		self:action()
	end
end

function Pie:touchreleased(id, x, y)
	if math.sqrt((y-self.pos.y)^2+(x-self.pos.x)^2) <= self.radius*self.scale then
		self:inaction()
	end
end

function Pie:distanceTo(p)
	return math.sqrt((self.pos.y-p.pos.y)^2 + (self.pos.x-p.pos.x)^2)
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
