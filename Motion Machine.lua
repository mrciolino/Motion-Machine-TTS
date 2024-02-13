-- parameters
moveDuration = 0.1
buttons = {"Circle", "Circle (Up)", "Oscillate", "Oscillate (Up)", "Swing (90)", "Swing (180)", "Spin",
           "Semi Circle Oscillate", "Semi Circle Oscillate (Up)", "Square"}

-- globals
AnimationClock = 0
deltaTime = 0
oldTime = os.clock()
newTime = os.clock()
baseSize = self.getBoundsNormalized().size
finishedLoading = false
isMenuActive = false
count = 0
-----------------------------------------------------------------------------
-------------------------------- Movement -----------------------------------
-----------------------------------------------------------------------------

function onFixedUpdate()

    if animation_active then
        if math.cos(AnimationClock) == 1.00000 then
            print("Animation Clock is at max count: ", count, " value is ", string.format("%.5f", math.cos(AnimationClock)), " clock ", AnimationClock)
            count = count + 1
        end
    end

    if animation_movement == "Circle" and animation_active then
        local currentPosition = self.getPosition()
        local frequency = 1
        local amplitude = 1
        local x = amplitude * math.cos(frequency * AnimationClock)
        local z = amplitude * math.sin(frequency * AnimationClock)
        local newPosition = {currentPosition.x + x, currentPosition.y, currentPosition.z + z}
        self.setPositionSmooth(newPosition, false, false, moveDuration)
    end

    if animation_movement == "Circle (Up)" and animation_active then
        local currentPosition = self.getPosition()
        local frequency = 1
        local amplitude = 1
        local x = amplitude * math.cos(frequency * AnimationClock)
        local y = amplitude * math.sin(frequency * AnimationClock)
        local newPosition = {currentPosition.x + x, currentPosition.y + y, currentPosition.z}
        self.setPositionSmooth(newPosition, false, false, moveDuration)
        if math.cos(frequency * AnimationClock) > 0.99 then
            self.setPositionSmooth(startingPosition, false, false, moveDuration)
        end
    end

    if animation_movement == "Oscillate" and animation_active then
        local currentPosition = self.getPosition()
        local forwardDirection = self.getTransformForward()
        local frequency = 1
        local amplitude = 1
        local newPosition = currentPosition + forwardDirection * (amplitude * math.sin(frequency * AnimationClock))
        self.setPositionSmooth(newPosition, false, false, moveDuration)
    end

    if animation_movement == "Oscillate (Up)" and animation_active then
        local currentPosition = self.getPosition()
        local upwardDirection = self.getTransformUp()
        local frequency = 1
        local amplitude = 1
        local newPosition = currentPosition + upwardDirection * (amplitude * math.sin(frequency * AnimationClock))
        self.setPositionSmooth(newPosition, false, false, moveDuration)
        if math.cos(frequency * AnimationClock) > 0.99 then
            self.setPositionSmooth(startingPosition, false, false, moveDuration)
        end
    end

    if animation_movement == "Swing (90)" and animation_active then
        local currentRotation = self.getRotation()
        local rotation_vector = vector(0, 1, 0)
        local frequency = 1
        local amplitude = 2 * math.pi -- 90 degrees in radians
        local newRotation = currentRotation + rotation_vector * (amplitude * math.sin(frequency * AnimationClock))
        self.setRotationSmooth(newRotation, false, false)
    end

    if animation_movement == "Swing (180)" and animation_active then
        local currentRotation = self.getRotation()
        local rotation_vector = vector(0, 1, 0)
        local frequency = 1
        local amplitude = 4 * math.pi -- 180 degrees in radians
        local newRotation = currentRotation + rotation_vector * (amplitude * math.sin(frequency * AnimationClock))
        self.setRotationSmooth(newRotation, false, false)
    end

    if animation_movement == "Spin" and animation_active then
        local currentRotation = self.getRotation()
        local rotationSpeed = 15 -- Adjust the rotation speed (in degrees per second)
        local newRotation = {currentRotation.x, currentRotation.y + rotationSpeed, currentRotation.z}
        self.setRotationSmooth(newRotation, false, false)
    end

    if animation_movement == "Semi Circle Oscillate" and animation_active then
        local currentPosition = self.getPosition()
        local forwardDirection = self.getTransformForward()
        local rightDirection = self.getTransformRight()
        local frequency = 1
        local amplitude = 1
        local xOffset = amplitude * math.sin(frequency * AnimationClock % (2 * math.pi)) -- Modulo operation
        local yOffset = amplitude * math.sin(2 * frequency * AnimationClock % (2 * math.pi)) -- Modulo operation
        local newPosition = currentPosition + forwardDirection * xOffset + rightDirection * yOffset
        self.setPositionSmooth(newPosition, false, false, moveDuration)
    end

    if animation_movement == "Semi Circle Oscillate (Up)" and animation_active then
        local currentPosition = self.getPosition()
        local forwardDirection = self.getTransformForward()
        local upwardDirection = self.getTransformUp()
        local frequency = 1
        local amplitude = 1
        local xOffset = amplitude * math.sin(frequency * AnimationClock % (2 * math.pi)) -- Modulo operation
        local yOffset = amplitude * math.sin(2 * frequency * AnimationClock % (2 * math.pi)) -- Modulo operation
        local newPosition = currentPosition + forwardDirection * xOffset + upwardDirection * yOffset
        self.setPositionSmooth(newPosition, false, false, moveDuration)
        if math.cos(frequency * AnimationClock) > 0.99 then
            self.setPositionSmooth(startingPosition, false, false, moveDuration)
        end
    end

    -- add a move in square pattern that takes [-1 to 1] from a sin function to move to the 4 corners
    if animation_movement == "Square" and animation_active then
        local currentPosition = self.getPosition()
        local forwardDirection = self.getTransformForward()
        local rightDirection = self.getTransformRight()
        local distance = 1.0
        local corner1 = currentPosition + forwardDirection * distance + rightDirection * distance
        local corner2 = currentPosition + forwardDirection * distance - rightDirection * distance
        local corner3 = currentPosition - forwardDirection * distance - rightDirection * distance
        local corner4 = currentPosition - forwardDirection * distance + rightDirection * distance
        -- move into corners based on time
        local x = AnimationClock % 4
        if x >= 0 and x <= 1 then
            self.setPositionSmooth(corner1, false, false, moveDuration)
        elseif x >= 1 and x <= 2 then
            self.setPositionSmooth(corner2, false, false, moveDuration)
        elseif x >= 2 and x <= 3 then
            self.setPositionSmooth(corner3, false, false, moveDuration)
        elseif x >= 3 and x <= 4 then
            self.setPositionSmooth(corner4, false, false, moveDuration)
        end
    end

    calcDeltaTime()
    if animation_active then
        AnimationClock = AnimationClock + deltaTime
    end
end

-----------------------------------------------------------------------------
---------------------------------- Logic -------------------------------------
-----------------------------------------------------------------------------

function calcDeltaTime()
    old = newTime
    newTime = os.clock()
    deltaTime = newTime - old
    return deltaTime
end

function animate(player, movement)
    -- change menus
    removeAllButtons()
    createStopButton()
    -- set animation state and save the state
    AnimationClock = 0
    startingPosition = self.getPosition()
    animation_movement = movement
    animation_active = true
    saveState()
end

function animateStop()
    -- change menus
    removeAllButtons()
    createMainButton()
    -- set animation state and save the state
    animation_movement = "Stop"
    animation_active = false
    saveState()
end

function mainButtonPress(obj, player_clicker_color, alt_click)
    if alt_click then
        btn_targetObject(obj, player_clicker_color, alt_click)
    else
        toggleMenu(obj, player_clicker_color, alt_click)
    end
end

function toggleMenu(obj, player_clicker_color, alt_click)
    if not isMenuActive then
        createMenuOptions()
    else
        removeAllButtons()
        createMainButton()
    end
end

function removeAllButtons()
    isMenuActive = false
    self.clearButtons()
end

-----------------------------------------------------------------------------
---------------------------------- Menu -------------------------------------
-----------------------------------------------------------------------------

function createMenuOptions()
    isMenuActive = true
    for i, movement in ipairs(buttons) do

        local funcName = "menu_button_" .. i
        local func = function(i, c) animate(i, movement) end
        self.setVar(funcName, func)

        self.createButton({
            click_function = funcName,
            function_owner = self,
            label = movement,
            position = {0, 0, 2 + (i - 1) * .5},
            width = 2100,
            height = 200,
            font_size = 175,
            color = {0, 0, 0, 255},
            font_color = {255, 255, 255, 255},
            tooltip = "Activate " .. movement
        })
    end
end

function createMainButton()
    -- Base Size Vector: { 3.999702, 0.1, 2.959487 }
    self.createButton({
        click_function = "mainButtonPress",
        function_owner = self,
        position = {0, baseSize.y / 2, 0.7}, -- {0,.1,.7}
        width = 425 * baseSize.x, -- 1700
        height = 200 * baseSize.z, -- 600
        color = {0, 0, 0, 0},
        font_color = {0, 0, 0, 0},
        tooltip = "[4169E1][b]Left Click[/b][-] - Toggle Menu\n[B22222][b]Right Click[/b][-] - Inject Target"
    })
end

function createStopButton()
    -- Base Size Vector: { 3.999702, 0.1, 2.959487 }
    self.createButton({
        click_function = "animateStop",
        function_owner = self,
        position = {0, baseSize.y / 2, 0},
        width = 475 * baseSize.x, -- 1900
        height = 466 * baseSize.z, -- 1400
        color = {0, 0, 0, 0},
        font_color = {0, 0, 0, 0},
        tooltip = "Stop Animation"
    })
end

-----------------------------------------------------------------------------
----------------------------- Saving/Loading --------------------------------
-----------------------------------------------------------------------------

function detectOneWorld()
    for _, obj in ipairs(getAllObjects()) do
        if obj.getName() == "OW_Hub" then
            return true
        end
    end
end

function addRemoveScriptMenu()
    if string.find(self.getName(), "Motion Machine") then
        broadcastToAll("Cannot remove script from the main Motion Machine Object", Color.SoftYellow)
        return
    else
        self.setLuaScript("")
        self.reload()
    end
end

function addResetMenu()
    self.clearButtons()
    self.clearContextMenu()
    animation_movement = "Stop"
    animation_active = false
    saveState()
    onLoad(self.script_state)
end

function restartAnimation(savedData)
    animation_movement = savedData.animation_movement
    animation_active = savedData.animation_active
    startingPosition = savedData.startingPosition
    createStopButton()
    AnimationClock = 0
    if startingPosition then
        self.setPosition(startingPosition)
    end
end

function onLoad(script_state)

    self.addContextMenuItem("Remove Script", addRemoveScriptMenu)
    self.addContextMenuItem("Reset Animation", addResetMenu)

    if script_state ~= "" then

        -- restart the animation if the saved state has an animating object
        local savedData = JSON.decode(script_state)
        if savedData.animation_active then
            if detectOneWorld() then
                Wait.time(function() restartAnimation(savedData) end, 5)
            else
                restartAnimation(savedData)
            end
        else
            -- saved state but not animating
            createMainButton()
            animation_movement = "Stop"
            animation_active = false
        end

    else
        -- if no saved state, then create the main button
        createMainButton()
        animation_movement = "Stop"
        animation_active = false
    end

    -- finish loading for one world
    self.setVar("finishedLoading", true);
end

-- Save the animation state when the game is saved
function saveState()
    self.script_state = JSON.encode({
        animation_movement = animation_movement,
        animation_active = animation_active,
        startingPosition = startingPosition
    });
end

-----------------------------------------------------------------------------
--------------------------------- Injecting ---------------------------------
-----------------------------------------------------------------------------

function btn_targetObject(obj, player_clicker_color, alt_click)
    player = Player[player_clicker_color]
    local objs = player.getSelectedObjects()
    if #objs > 0 then
        local targetList = {}
        for i, selectedObj in ipairs(objs) do
            table.insert(targetList, selectedObj.guid)
            injectTarget(selectedObj)
        end
        local targetString = table.concat(targetList, ", ")
        broadcastToColor("Targets set to have motion: " .. targetString, player_clicker_color, Color.SoftYellow)
    else
        broadcastToColor("No objects selected! Highlight an object first", player_clicker_color, Color.SoftYellow)
    end
end

function injectTarget(target)
    local code = self.getLuaScript()
    target.setLuaScript(code)
    target.reload()
end