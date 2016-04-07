--[[
	main.lua
	March 2016

	this is a piece of shit
]]--

function love.load()

	if love.filesystem.exists("highscore.txt") then
		highscore = tonumber(love.filesystem.read("highscore.txt"), 10)
	else
		highscore = 0
	end

	score = 0

	cow = love.graphics.newImage("cow.png")
	cowpos = { x = 0, y = 0 }
	cowpos = newpos()

	love.graphics.setBackgroundColor(256, 256, 256)
	love.graphics.setColor(0, 0 ,0)
	scoreFont = love.graphics.newFont(256)
	highScoreFont = love.graphics.newFont(32)

	timerlen = newtimer(score)
	timer = 0

	running = true

	state = "stop"
	cooldown = false
	cooldownlen = 2

    love.math.setRandomSeed(os.time())

end

function love.draw()

	if state == "go" then

		love.graphics.setColor(244, 244, 244)
		love.graphics.arc("fill", cowpos.x+32, cowpos.y+32, 128, 3*math.pi/2, -2*math.pi*(timer/timerlen)+3*math.pi/2, 30)

		printscore()

		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(cow, cowpos.x, cowpos.y)

	elseif state == "stop" then

		if timer > 0 then
			love.graphics.setColor(244, 244, 244)
			love.graphics.arc("fill", love.graphics.getWidth()/2, love.graphics.getHeight()/3+128+32, 300, 3*math.pi/2, -2*math.pi*(timer/cooldownlen)+3*math.pi/2, 30)
		end

		printscore()

	end

end

function love.update(dt)

	if not running then return end

	timer = timer - dt
	if timer <= 0 then
		if cooldown then
			cooldown = false
		elseif state == "go" then
			state = "stop"
			cooldown = true
			timer = cooldownlen
			if score > highscore then
				highscore = score
				love.filesystem.write("highscore.txt", tostring(score))
			end
		end
	end

end

function love.focus(f) running = f end

function love.touchpressed(id, x, y, dx, dy, pressure)
	
	if state == "go" then
		if math.sqrt((y-cowpos.y-32)^2+(x-cowpos.x-32)^2) <= 128 then
			cowpos = newpos()
			timer = timerlen
			score = score + 1
			timerlen = newtimer(score)
		end
	elseif state == "stop" and not cooldown then
		score = 0
		timerlen = newtimer(score)
		timer = timerlen
        cowpos = newpos()
		state = "go"
	end

end


-- Touch press wrapper for testing on desktop
function love.mousepressed(x, y)
	love.touchpressed(0, x, y)
end

--[[
	Other functions
]]

-- Generate an x,y position with padding
function newpos()

	-- Circle r = 128, padding of 64

	local x, y
	repeat
		x = math.random(128, love.graphics.getWidth()-128-64)
		y = math.random(128, love.graphics.getHeight()-128-64)
	until cowpos == nil or math.sqrt((cowpos.y-y)^2 + (cowpos.x-x)^2) >= 300

	return { x = x, y = y }
end

function newtimer(x)
	return 5.25 - 5/(1+2.718^(-0.05*(x-50)))
end

function printscore()
	love.graphics.setColor(247, 189, 190)
	love.graphics.setFont(scoreFont)
	love.graphics.printf(tostring(score), 0, love.graphics.getHeight()/3, love.graphics.getWidth(), 'center')
	love.graphics.setFont(highScoreFont)
	love.graphics.printf("high score: "..tostring(highscore), 0, love.graphics.getHeight()/3+256, love.graphics.getWidth(), 'center')
	if state == "stop" and not cooldown then
		love.graphics.printf("tap to play", 0, love.graphics.getHeight()/3+256+32, love.graphics.getWidth(), 'center')
	end
end
