function love.load()
    sprites = {}
    sprites.background = love.graphics.newImage('sprites/background.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.zombie = love.graphics.newImage('sprites/zombie.png')

    --love.window.setFullscreen(true)
    love.window.setTitle("Top Down Game")

    player = {}
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
    player.speed = 250

    

    myFont = love.graphics.newFont(50)

    zombies = {}
    zombieTimer = 0
    gameState = 1

    score = 0

    bullets = {}
end

function love.update(dt)
    if gameState == 2 then
        if love.keyboard.isDown("d") then
            player.x = player.x + player.speed * dt          
        end
        if love.keyboard.isDown("a") then
            player.x = player.x - player.speed * dt            
        end
        if love.keyboard.isDown("w") then
            player.y = player.y - player.speed * dt            
        end
        if love.keyboard.isDown("s") then
            player.y = player.y + player.speed * dt            
        end
    

        zombieTimer = zombieTimer + dt
        if zombieTimer >= math.random(1, 3) then
            spawnZombie()
            zombieTimer = 0
        end

        for i, z in ipairs(zombies) do
            moveTowardsPlayer(z, dt)

            if distanceBetween(z.x, z.y, player.x, player.y) < 30 then
                for i, z in ipairs(zombies) do
                    zombies[i] = nil
                    gameState = 1
                    player.x = love.graphics.getWidth()/2
                    player.y = love.graphics.getHeight()/2
                end
            end

            for j, b in ipairs(bullets) do
                if distanceBetween(z.x, z.y, b.x, b.y) < 20 then
                    z.dead = true
                    b.dead = true
                    score = score + 1
                end
            end
        end

        for i, b in ipairs(bullets) do
            bulletTowardsZombie(b, dt)

        end

        for i=#bullets, 1, -1 do
            local b = bullets[i]
            if b.dead == true or b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
                table.remove(bullets, i)
            end
            
        end

        for i=#zombies, 1, -1 do
            local z = zombies[i]
            if z.dead == true then
                table.remove(zombies, i)
            end
        end
    end

end

function love.draw()
    love.graphics.draw(sprites.background, 0,0, nil, nil, nil)

    love.graphics.draw(sprites.player, player.x, player.y, playerMouseAngle(), nil, nil, 
    sprites.player:getWidth()/2, sprites.player:getHeight()/2)

    if gameState == 1 then
        love.graphics.setFont(myFont)
        love.graphics.printf("Right click to begin!", 0, 50, love.graphics.getWidth(), "center")
    else
        love.graphics.printf("Score: " .. score, 0, love.graphics.getHeight()-100, love.graphics.getWidth(), "center")
        for i, z in ipairs(zombies) do
            love.graphics.draw(sprites.zombie, z.x, z.y, enemyPlayerAngle(z), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
        end
    
        for i, b in ipairs(bullets) do
            love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.5, 0.5, 
                                    sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
        end
    end 
end

function love.mousepressed( x, y, button )
    if gameState == 1 then
        if button == 2 then
            gameState = 2
            timer = 0
        end
    elseif gameState == 2 then
        if button == 1 then
            spawnBullet()
        end
    end
end

function playerMouseAngle()
    return math.atan2( player.y - love.mouse.getY(), player.x - love.mouse.getX() ) + math.pi
end

function enemyPlayerAngle(enemy)
    return math.atan2( enemy.y - player.y, enemy.x - player.x ) + math.pi
end

function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 500
    bullet.dead = false
    bullet.direction = playerMouseAngle()
    table.insert(bullets, bullet)
end

function spawnZombie()
    local zombie = {}
    zombie.x = 0
    zombie.y = 0
    zombie.speed = math.random(200, 400)
    zombie.dead = false

    local side = math.random(1, 4)

    -- left side
    if side == 1 then
        zombie.x = -30
        zombie.y = math.random(0, love.graphics.getHeight())
    -- right side
    elseif side == 2 then
        zombie.x = love.graphics.getWidth() + 30
        zombie.y = math.random(0, love.graphics.getHeight())
    -- top side
    elseif side == 3 then
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = -30
    -- bottom side
    elseif side == 4 then
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = love.graphics.getHeight() + 30
    end

    table.insert(zombies, zombie)
end

function moveTowardsPlayer(zombie, dt)
    zombie.x = zombie.x + (math.cos ( enemyPlayerAngle(zombie) ) * zombie.speed * dt)
    zombie.y = zombie.y + (math.sin ( enemyPlayerAngle(zombie) ) * zombie.speed * dt)
end

function bulletTowardsZombie(bullet, dt)
    bullet.x = bullet.x + (math.cos ( bullet.direction ) * bullet.speed * dt)
    bullet.y = bullet.y + (math.sin ( bullet.direction ) * bullet.speed * dt)
end

function distanceBetween(x1, y1, x2, y2)
    return math.sqrt( (x2 - x1)^2 + (y2 - y1)^2 )
end