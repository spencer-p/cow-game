--[[
	God forbidden expension of pie to be only a timer
]]

Timer = Pie:extend()

function Timer:new()
	Timer.super.new(self)
	self:setSpeed()
end

function Timer:setSpeed()
	self.speed = 3*speed()
end

function Timer:reset()
	self.timer = self.timerlen
	self:setSpeed()
	self.exists = true
	self.tapped = false
	self.processed = false
end
