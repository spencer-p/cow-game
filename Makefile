PORT ?= 8000

GAME_SRCS = \
	camera.lua \
	classic.lua \
	conf.lua \
	cooldown.lua \
	cow-invert.png \
	cow.lua \
	cow.png \
	disneymathmagic.lua \
	flux.lua \
	lose.wav \
	main.lua \
	pie.lua \
	point.wav \
	powerup.lua \
	powerup.wav \
	start.wav \
	timer.lua \
	unce.wav

.PHONY: build clean serve docker

cowgame.love: $(GAME_SRCS)
	zip -r $@ $^

www: cowgame.love index.html cow.png
	npx love.js cowgame.love -c www -t "Cow Game"
	cp index.html www/index.html
	cp cow.png www/cow.png

build: www

clean:
	rm -rf www cowgame.love

serve: www
	cd www && python3 ../server.py $(PORT)

docker: www
	docker buildx build --platform linux/arm64 -t cow-game:latest .
