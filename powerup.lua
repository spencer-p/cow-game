--[[
	Class for powerups
]]

Powerup = Cow:extend()
Powerup.dur = 3

function Powerup:new()
	Powerup.super.new(self)
	self.img = g.powerup.img
	self.color = g.colors.darkgrey
end

function Powerup:action()
	flux.to(self, 0.1, { scale = 0 } ):ease("backin"):oncomplete( function() self.exists = false end )

	n = love.math.random(1, 4)
	flux.to(g.powerup, 0, { message = n }):after(g.powerup, 0, { message = 0 }):delay(Powerup.dur)
	if n == 1 then
		freeze()
	elseif n == 2 then
		grow(3/2)
	elseif n == 3 then
		grow(2/3)
	elseif n == 4 then
		scoremultiplier(2)
	end
end

function freeze()
	for i, c in ipairs(g.cows) do
		if c ~= self then
			flux.to(c, 0.1, { speed = 0.1*c.speed })
		end
	end
	flux.to(g.cowsettings, 0, { speedmultiplier = 0.1 }):after(g.cowsettings, 1, {speedmultiplier = 1}):delay(Powerup.dur)
end

function grow(f)
	for i, c in ipairs(g.cows) do
		if c ~= self then
			flux.to(c, 0.1, { scale = f })
		end
	end
	flux.to(g.cowsettings, 0, { scale = f }):after(g.cowsettings, 0, { scale = 1 }):delay(Powerup.dur)
end

function scoremultiplier(m)
	flux.to(g, 0, { points = m }):after(g, 0, { points = 1 }):delay(Powerup.dur)
end
