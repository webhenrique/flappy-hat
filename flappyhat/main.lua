local physics = require("physics")
physics.start()

-- set up display groups
local backGroup = display.newGroup()  -- for the background images
local mainGroup = display.newGroup()  -- for the game objects and bird
local uiGroup = display.newGroup()    -- for the score and ads

-- load game assets
local background = display.newImageRect(backGroup, "background.png", 800, 1400)
background.x = display.contentCenterX
background.y = display.contentCenterY

local bird = display.newImageRect(mainGroup, "fedora.png", 50, 50)
bird.x = display.contentCenterX - 50
bird.y = display.contentCenterY
bird:setFillColor(1, 0, 0)  -- change bird color for testing
bird.rotation = 0 

local pipeTop, pipeBottom
local pipeSpeed = 2

local score = 0
local scoreText = display.newText(uiGroup, "Score: " .. score, display.contentCenterX, 50, native.systemFontBold, 48)


local function createPipe()
  local gapHeight = 200
  local pipeWidth = 80
  local pipeHeight = display.contentHeight - gapHeight -- leave some space at top and bottom

  pipeTop = display.newImageRect(mainGroup, "pipe.png", pipeWidth, pipeHeight)
  pipeTop.anchorY = 1 -- anchor at bottom
  pipeTop.x = display.contentWidth + pipeWidth / 2
  pipeTop.y = math.random(pipeHeight / 2) + 100

  pipeBottom = display.newImageRect(mainGroup, "pipe.png", pipeWidth, pipeHeight)
  pipeBottom.anchorY = 0 -- anchor at top
  pipeBottom.x = display.contentWidth + pipeWidth / 2
  pipeBottom.y = pipeTop.y + gapHeight

  physics.addBody(pipeTop, "static", {isSensor=true})
  physics.addBody(pipeBottom, "static", {isSensor=true})
end

createPipe()

-- add physics to game objects
physics.addBody(bird, "dynamic", {radius=25})

  
-- game loop function
local function gameLoop()
  -- move pipes to the left
  
  pipeTop.x = pipeTop.x - pipeSpeed
  pipeBottom.x = pipeBottom.x - pipeSpeed

  -- create new pipes when offscreen
  if pipeTop.x < -pipeTop.width / 2 then
    pipeTop:removeSelf()
    pipeBottom:removeSelf()
    createPipe()
  end
  bird.rotation = math.min(math.max(-30, bird.rotation + 2), 90)  -- limit bird rotation to between -30 and 90 degrees

  if pipeTop.x < bird.x and not pipeTop.scored then
    score = score + 1
    scoreText.text = "Score: " .. score
    pipeTop.scored = true
    pipeSpeed = pipeSpeed + 0.5 -- increase pipe speed when new pipe is created
  end
end

-- game over function
local function gameOver()
    -- stop game loop and show game over message
    Runtime:removeEventListener("enterFrame", gameLoop)
    local gameOverText = display.newText(uiGroup, "Game Over", display.contentCenterX, display.contentCenterY, native.systemFontBold, 54)
  
    -- create restart button
    local restartButton = display.newText(uiGroup, "Restart", display.contentCenterX, display.contentCenterY + 100, native.systemFontBold, 48)
    restartButton:setFillColor(1, 1, 1)
    pipeSpeed = 0
    -- add touch event listener to restart button
    local function restartGame(event)
      if event.phase == "ended" then
        -- remove game over screen elements
        gameOverText:removeSelf()
        restartButton:removeSelf()
        pipeSpeed = 2
        score = 0
        scoreText.text = "Score: " .. score
        -- restart game
        
        bird.x = display.contentCenterX- 50
        bird.y = display.contentCenterY
        bird:setLinearVelocity(0, 0)
        pipeTop.x = display.contentWidth + 100
        pipeBottom.x = display.contentWidth + 100
        physics.start()
        Runtime:addEventListener("enterFrame", gameLoop)
      end
    end
    restartButton:addEventListener("touch", restartGame)
  end

-- add touch event listener to bird
local function flapBird(event)
    if event.phase == "began" then
      bird:setLinearVelocity(0, -250)
      transition.cancel(bird.rotationTransition)
      bird.rotation = -20
      bird.rotationTransition = transition.to(bird, {time=150, rotation=-40, transition=easing.outQuad})
      end
  end
  system.setTapDelay(0.1) -- set a short delay between taps to prevent double-tapping
  Runtime:addEventListener("touch", flapBird)

-- start game loop
Runtime:addEventListener("enterFrame", gameLoop)

-- detect collisions
local function onCollision(event)
  if event.phase == "began" then
    gameOver()
  end
end

local ground = display.newRect(mainGroup, 0, display.contentHeight + 40, display.contentWidth * 2, 10)
ground:setFillColor(0, 1, 0)
ground.anchorX = 0
ground.anchorY = 0
physics.addBody(ground, "static")
ground:addEventListener("collision", onCollision)
bird:addEventListener("collision", onCollision)
pipeTop:addEventListener("collision", onCollision)
pipeBottom:addEventListener("collision", onCollision)
