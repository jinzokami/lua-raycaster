function love.load()
	scale = 1
	mapWidth = 24
	mapHeight = 24
	--the map our raycaster will be traversing
	map = {
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,1,1,0,1,1,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
		{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
	}

	--walker's position
	posX = 23
	posY = 12

	--walker's direction
	dirX = -1
	dirY = 0

	--the camera plane, perpendicular to the direction
	planeX = 0
	planeY = 0.66

	--the tutorial inits the screen here, but that's handled for us
	--screen dimensions are 800 by 600
	--the game loop is also defined, but again, that's done for us
	screenWidth = love.graphics.getWidth()*scale
	screenHeight = love.graphics.getHeight()*scale

	slices = {} -- the vertical lines to draw
	--{color = {}, x, start, end}

	doorTimer = 5
end

function love.update(dt)
	--the raycaster's loop
	slices = {}
	for x = 0, screenWidth, 1 do
		local cameraX = 2 * x/screenWidth - 1
		local rayPosX = posX
		local rayPosY = posY
		local rayDirX = dirX + planeX * cameraX
		local rayDirY = dirY + planeY * cameraX

		local mapX = math.floor(rayPosX)
		local mapY = math.floor(rayPosY)

		local sideDistX
		local sideDistY

		local deltaDistX = math.sqrt(1 + (rayDirY * rayDirY)/(rayDirX * rayDirX))
		local deltaDistY = math.sqrt(1 + (rayDirX * rayDirX)/(rayDirY * rayDirY))

		local perpWallDist

		local stepX
		local stepY

		local hit = 0
		local side

		if rayDirX < 0 then
			stepX = -1
			sideDistX = (rayPosX - mapX) * deltaDistX
		else
			stepX = 1
			sideDistX = (mapX + 1 - rayPosX) * deltaDistX
		end

		if rayDirY < 0 then
			stepY = -1
			sideDistY = (rayPosY - mapY) * deltaDistY
		else
			stepY = 1
			sideDistY = (mapY + 1 - rayPosY) * deltaDistY
		end

		--perform Digital Differential Analysis
		while hit == 0 do
			if sideDistX < sideDistY then
				sideDistX = sideDistX + deltaDistX
				mapX = mapX + stepX
				side = 0
			else
				sideDistY = sideDistY + deltaDistY
				mapY = mapY + stepY
				side = 1
			end

			if map[mapX][mapY] > 0 then
				hit = 1
			end
		end

		if side == 0 then
			perpWallDist = (mapX - rayPosX + (1 - stepX) / 2) / rayDirX
		else
			perpWallDist = (mapY - rayPosY + (1 - stepY) / 2) / rayDirY
		end

		local lineHeight = math.floor(screenHeight / perpWallDist)

		local drawStart = -lineHeight/2 + screenHeight/2
		if drawStart < 0 then
			drawStart = 0
		end
		local drawEnd = lineHeight/2 + screenHeight/2
		if drawEnd >= screenHeight then
			drawEnd = screenHeight - 1
		end

		local color = {}
		if map[mapX][mapY] == 1 then
			color = {0.5, 0.5, 0.5}
		elseif map[mapX][mapY] == 2 then
			color = {1, 1, 0}
		elseif map[mapX][mapY] == 3 then
			color = {0, 0, 1}
		elseif map[mapX][mapY] == 4 then
			color = {0.75, 0.5, 0.5}
		else
			color = {0, 1, 1}
		end

		if side == 1 then
			color[1] = color[1]/2
			color[2] = color[2]/2
			color[3] = color[3]/2
		end

		for i = 1, math.floor(perpWallDist), 1 do
			color[1] = color[1] * .95
			color[2] = color[2] * .95
			color[3] = color[3] * .95
		end


		if perpWallDist < 20 then
			table.insert(slices, {color, x, drawStart, drawEnd})
		end
	end

	moveSpeed = 5 * dt
	rotationSpeed = 3 * dt

	-- now for the controls
	if love.keyboard.isDown('up') then
		if map[math.floor(posX + dirX * moveSpeed)][math.floor(posY)] == 0 then
			posX = posX + dirX * moveSpeed
		end
		if map[math.floor(posX)][math.floor(posY + dirY * moveSpeed)] == 0 then
			posY = posY + dirY * moveSpeed
		end
	end

	if love.keyboard.isDown('down') then
		if map[math.floor(posX - dirX * moveSpeed)][math.floor(posY)] == 0 then
			posX = posX - dirX * moveSpeed
		end
		if map[math.floor(posX)][math.floor(posY - dirY * moveSpeed)] == 0 then
			posY = posY - dirY * moveSpeed
		end
	end

	if love.keyboard.isDown('right') then
		local oldDirX = dirX
		dirX = dirX * math.cos(-rotationSpeed) - dirY * math.sin(-rotationSpeed)
		dirY = oldDirX * math.sin(-rotationSpeed) + dirY * math.cos(-rotationSpeed)

		local oldPlaneX = planeX
		planeX = planeX * math.cos(-rotationSpeed) - planeY * math.sin(-rotationSpeed)
		planeY = oldPlaneX * math.sin(-rotationSpeed) + planeY * math.cos(-rotationSpeed)
	end

	if love.keyboard.isDown('left') then
		local oldDirX = dirX
		dirX = dirX * math.cos(rotationSpeed) - dirY * math.sin(rotationSpeed)
		dirY = oldDirX * math.sin(rotationSpeed) + dirY * math.cos(rotationSpeed)

		local oldPlaneX = planeX
		planeX = planeX * math.cos(rotationSpeed) - planeY * math.sin(rotationSpeed)
		planeY = oldPlaneX * math.sin(rotationSpeed) + planeY * math.cos(rotationSpeed)
	end
	
	if doorTimer <= 0 then
		map[12][13] = 0
	end
	doorTimer = doorTimer - dt
end

function love.draw()
	--go through the slices and for each
	--draw a rough style line from x, drawStart to x, drawEnd
	love.graphics.scale(1/scale)
	love.graphics.setColor(0.5, 0.5, 1)
	love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight/2)
	love.graphics.setColor(0.125, 0.125, 0.125)
	love.graphics.rectangle("fill", 0, screenHeight/2, screenWidth, screenHeight/2)

	love.graphics.setLineStyle('rough')
	for i = 1, #slices, 1 do
		love.graphics.setColor(slices[i][1])
		love.graphics.line(slices[i][2], slices[i][3], slices[i][2], slices[i][4])
	end
end

function love.keypressed(key, scancode, isRepeat)
	
end
