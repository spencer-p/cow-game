--[[
	main.lua
	March 2016

	this is a piece of shit
]]--

function love.load()

	love.math.setRandomSeed(os.time())

	-- Libs
	if love.filesystem.getInfo("love-update") ~= nil then
		package.path = love.filesystem.getSaveDirectory() .. ("/love-update/version-%03d/?.lua;"):format(localVersion)
	end
	require "pie"
	require "cow"
	require "powerup"
	require "cooldown"
	require "timer"
	require "disneymathmagic"
	Camera = require "camera"
	flux = require "flux"

	-- Set up settings
	g = {}
	g.width, g.height = 750, 1334
	g.scale = love.graphics.getWidth()/g.width
	g.cowsettings = {}
	g.powerup = { messages = { "SLOW MOTION", "DOUBLE SIZE", "HALF SIZE", "SCORE x2", "FRENZY" }, message = 0 }
	g.colors = mapk(normcolor, { white = { 256, 256, 256 }, grey = { 244, 244, 244 }, darkgrey = { 236, 236, 236 }, pink = { 247, 189, 190 }, blue = { 188, 247, 246 } })
	g.score = 0
	g.points = 1
	g.insults = { "lol are you being serious?", "pathetic", "excoos u", "ohkei", "THAR.", "all men are pigs", "i will never date you", "my intestines are going nuts", "kick to the uterus\nrun away", "did you even beat 18?\nSUCKER", "losing my faith in you\nso i only watch me", "ugh stats", "duh, you suck", "you make me vomit", "NOICE", "i'll beat you up", "IM SO HARD RN", "murder me", "have you idiots never played this", "you are kale: dum", "this is easy guys", "get good", "just be smart", "pay attention in class", "stay in school", "hey miahn", "that's not necessary miahn", "can i ask you to sit down", "laughing at you, not with you", "how do you feel about what just happened?", "WHO DA MASTHER NOW", "are you currently aware that you suck?", "thtoopid", "huwo?", "i can do this all day", "SHOOT", "um thar r u sarcasmastic?", "um ok", "aasdfj;", "fuck", "w t frickin bananas", "what the hecking", "slurp", "holy shoot", "HURR HURR", "WAIT", "give up", "you suck", "blue cows are not required", "beware the blue cow" }
	g.congrats = { "wau.", "that's not even that good", "perf heart heart" }
	g.stopmessage = ""
	g.cam = Camera(g.width/2, g.height/2, g.scale)
	g.camentropy = 1

	g.sfx = {}
	local sfxFilePrefix = ""
	if love.filesystem.getInfo("love-update") ~= nil then
		sfxFilePrefix = ("love-update/version-%03d/"):format(localVersion)
	end
	g.sfx.point = love.audio.newSource(("%spoint.wav"):format(sfxFilePrefix), "static")
	g.sfx.powerup = love.audio.newSource(("%spowerup.wav"):format(sfxFilePrefix), "static")
	g.sfx.lose = love.audio.newSource(("%slose.wav"):format(sfxFilePrefix), "static")
	g.sfx.start = love.audio.newSource(("%sstart.wav"):format(sfxFilePrefix), "static")
	g.sfx.unce = love.audio.newSource(("%sunce.wav"):format(sfxFilePrefix), "static")

	if love.filesystem.getInfo("highscore.txt") ~= nil then
		g.highscore = tonumber(love.filesystem.read("highscore.txt"), 10)
	else
		g.highscore = 0
	end

	if love.filesystem.getInfo("love-update") ~= nil then
		g.cowsettings.img = love.graphics.newImage(("love-update/version-%03d/cow.png"):format(localVersion))
		g.powerup.img = love.graphics.newImage(("love-update/version-%03d/cow-invert.png"):format(localVersion))
	else
		g.cowsettings.img = love.graphics.newImage("cow.png")
		g.powerup.img = love.graphics.newImage("cow-invert.png")
	end
	g.cowsettings.radius = 128
	g.cowsettings.speedmultiplier = 1
	g.cowsettings.scale = 1
	g.cows = {}

	g.spawn = Timer()

	love.graphics.setBackgroundColor(g.colors.white)
	scoreFont = love.graphics.newFont(256)
	highScoreFont = love.graphics.newFont(32)

	g.running = true

	g.state = "ready"
	g.cooldown = Cooldown()

end

function love.draw()
	g.cam:attach()
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
	g.cam:detach()
end

function love.update(dt)

	if not g.running then return end

	flux.update(dt)

	if g.state == "go" then
		-- Spawn new cows
		g.spawn:update(dt)
		if not g.spawn.exists then
			addcow()
		end

		-- Update the cows
		for i, c in ipairs(g.cows) do
			if c.tapped and not c.processed then -- If it was tapped, we need a new cow
				g.score = g.score + g.points
				if not c:is(Powerup) then
					local n = love.math.random(1, 2)
					local pitch
					if n == 1 then
						pitch = 2^(2/12)
					else
						pitch = 1
					end
					g.sfx.point:setPitch(pitch)
					g.sfx.point:play()
				else
					g.sfx.powerup:play()
				end
				c.processed = true
				if #g.cows <= 1 then -- Add a cow if the last one got removed
					addcow()
				end
				tweencam()
			elseif not c.tapped and c.exists then -- Update it if it's still around
				c:update(dt)
			end
			if not c.exists and ((c.tapped) or (not c.tapped and c:is(Powerup))) then
				table.remove(g.cows, i)
			elseif not c.exists and not c.tapped and not c:is(Powerup) then -- Game over!
				g.sfx.lose:play()
				tweencam({x = g.width/2, y = g.height/2}, 0)
				g.state = "stop"
				g.powerup.message = 0
				g.stopmessage = g.highscore < g.score and love.math.random(1, #g.congrats) or love.math.random(1, #g.insults)
				g.cooldown:reset()
				if g.score > g.highscore then
					g.highscore = g.score
					love.filesystem.write("highscore.txt", tostring(g.score))
				end
				g.cows = {} -- Destroy remaining cows
				break
			end
		end
	elseif g.state == "stop" then
		if g.cooldown.exists then -- Still cooling down
			g.cooldown:update(dt)
		else
			g.state = "ready" -- Cooldown complete
		end
	end
end

function love.focus(f) g.running = f end

function love.touchpressed(id, x, y, dx, dy, pressure)
	local x, y = g.cam:worldCoords(x, y)
	if g.state == "go" then
		g.sfx.unce:play()
		for i, c in ipairs(g.cows) do
			c:touchpressed(id, x, y)
		end
	elseif g.state == "stop" then
		g.cooldown:touchpressed(id, x, y)
	elseif g.state == "ready" then
		g.cowsettings.scale = 1
		g.cowsettings.speedmultiplier = 1
		g.score = 0
		addcow()
		tweencam()
		g.state = "go"
		g.sfx.start:play()
	end
end

function love.touchreleased(id, x, y)
	local x, y = g.cam:worldCoords(x, y)
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

function tweencam(c, r)
	local center = c or { 
		x = g.width/2 + love.math.random(-64, 64), 
		y = g.height/2 + love.math.random(-64, 64) 
	}
	local rot = r or love.math.random(-100, 100)*math.pi/1200
	flux.to(g.cam, speed()/g.cowsettings.speedmultiplier, { x = center.x, y = center.y, rot = rot*g.camentropy^2 })
	flux.to(g.cam, 0.1, { scale = 1.1*g.scale }):after(g.cam, 0.25, { scale = 1*g.scale })
end

function speed(a, b, c, d)
	local a = a or 2
	local b = b or 1.25
	local c = c or 0.05
	local d = d or 50
	return 1/(a - b/(1+2.718^(-c*(g.score-d))))
end

function addcow()
	if #g.cows < 3 then -- Too many creatures creates infinite loops
		local insert
		local function powerupexists()
			for i, c in ipairs(g.cows) do
				if c:is(Powerup) then
					return true
				end
			end
			return false
		end
		if love.math.random(1, 10) == 1 and g.powerup.message == 0 and not powerupexists() then
			insert = Powerup()
		else
			insert = Cow()
		end
		table.insert(g.cows, insert)
	end
	g.spawn:reset()
end

function printscore()
	love.graphics.setColor(g.colors.pink)
	love.graphics.setFont(scoreFont)
	love.graphics.printf(tostring(g.score), 0, g.height/3, g.width, 'center')
	love.graphics.setFont(highScoreFont)
	local subtext = "high score: "..tostring(g.highscore)
	if g.powerup.message ~= 0 then
		subtext = subtext.."\n"..g.powerup.messages[g.powerup.message]
	end
	if g.state == "ready" then
		subtext = subtext.."\ntap to play"
	elseif g.state == "stop" then
		if g.score >= g.highscore then
			subtext = subtext.."\n"..g.congrats[g.stopmessage]
		elseif g.score < g.highscore then
			subtext = subtext.."\n"..g.insults[g.stopmessage]
		end
	end
	love.graphics.printf(subtext, 0, g.height/3+256, g.width, 'center')
end

function normcolor(c)
	return map(function(x) return x/0xff end, c)
end

-- from https://en.wikibooks.org/wiki/Lua_Functional_Programming/Functions
function map(func, array)
	local new_array = {}
	for i,v in ipairs(array) do
		new_array[i] = func(v)
	end
	return new_array
end

function mapk(func, table)
	local new = {}
	for k, v in pairs(table) do
		new[k] = func(v)
	end
	return new
end
