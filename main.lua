--[[
	main.lua
	March 2016

	this is a piece of shit
]]--

function love.load()

	love.math.setRandomSeed(os.time())

	-- Libs
	require "pie"
	require "cow"
	require "cooldown"
	flux = require "flux"

	-- Set up settings
	g = {}
	g.cowsettings = {}
	g.colors = { white = { 256, 256, 256 }, grey = { 244, 244, 244 }, pink = { 247, 189, 190 } }
	g.score = 0

	if love.filesystem.exists("highscore.txt") then
		g.highscore = tonumber(love.filesystem.read("highscore.txt"), 10)
	else
		g.highscore = 0
	end

	if love.filesystem.exists("love-update") then
		g.cowsettings.img = love.graphics.newImage(("love-update/version-%03d/cow.png"):format(localVersion))
	else
		g.cowsettings.img = love.graphics.newImage("cow.png")
	end
	g.cowsettings.radius = 128

	g.cows = {}

	love.graphics.setBackgroundColor(g.colors.white)
	scoreFont = love.graphics.newFont(256)
	highScoreFont = love.graphics.newFont(32)

	g.running = true

	g.state = "ready"
	g.cooldown = Cooldown:new()

end

function love.draw()
	if g.state == "go" then
		for i, c in ipairs(g.cows) do
			c:drawArc()
		end
		printscore()
		for i, c in ipairs(g.cows) do
			c:drawImg()
		end
	elseif g.state == "stop" then
		g.cooldown:drawArc()
		printscore()
	elseif g.state == "ready" then
		printscore()
	end
end

function love.update(dt)

	if not g.running then return end

	flux.update(dt)

	if g.state == "go" then
		for i, c in ipairs(g.cows) do
			if c.tapped and not c.processed then -- If it was tapped, we need a new cow
				g.score = g.score + 1
				table.insert(g.cows, Cow:new())
				c.processed = true
			elseif not c.tapped and c.exists then -- Update it if it's still around
				c:update(dt)
			end
			if not c.exists then
				table.remove(g.cows, i)
				if #g.cows == 0 then
					g.state = "stop"
					g.cooldown:reset()
					if g.score > g.highscore then
						g.highscore = g.score
						love.filesystem.write("highscore.txt", tostring(g.score))
					end
				end
			end
		end
	elseif g.state == "stop" then
		if g.cooldown.exists then
			g.cooldown:update(dt)
		else
			g.state = "ready"
		end
	end
end

function love.focus(f) g.running = f end

function love.touchpressed(id, x, y, dx, dy, pressure)
	if g.state == "go" then
		for i, c in ipairs(g.cows) do
			c:touchpressed(id, x, y)
		end
	elseif g.state == "stop" then
		g.cooldown:touchpressed(id, x, y)
	elseif g.state == "ready" then
		g.score = 0
		table.insert(g.cows, Cow:new())
		g.state = "go"
	end
end

function love.touchreleased(id, x, y)
	if g.state == "stop" then
		g.cooldown:touchreleased(id, x, y)
	end
end


-- Touch press wrapper for testing on desktop
function love.mousepressed(x, y)
	love.touchpressed(0, x, y)
end

function love.mousereleased(x, y)
	love.touchreleased(0, x, y)
end

--[[
	Other functions
]]

function speed(a, b, c, d)
	local a = a or 1.25
	local b = b or 1
	local c = c or 0.1
	local d = d or 75
	return 1/(a - b/(1+2.718^(-c*(g.score-d))))
end

function printscore()
	love.graphics.setColor(g.colors.pink)
	love.graphics.setFont(scoreFont)
	love.graphics.printf(tostring(g.score), 0, love.graphics.getHeight()/3, love.graphics.getWidth(), 'center')
	love.graphics.setFont(highScoreFont)
	love.graphics.printf("high score: "..tostring(g.highscore), 0, love.graphics.getHeight()/3+256, love.graphics.getWidth(), 'center')
	if g.state == "ready" then
		love.graphics.printf("tap to play", 0, love.graphics.getHeight()/3+256+32, love.graphics.getWidth(), 'center')
	end
end
