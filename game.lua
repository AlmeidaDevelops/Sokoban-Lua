--==============================================================================
-- C O N S T A N T S
--==============================================================================

local TILES = {
    WALL = "🧱",
    FLOOR = "🟦",
    GOAL = "❎"
}

local OBJECTS = {
    PLAYER = "👷",
    BOX = "📦",
    BOX_ON_GOAL = "🎯"
}

-- Mapeo de emojis de portales a su color y dirección de salida
local PORTAL_DEFINITIONS = {
    ["👉"] = {dx = 1, dy = 0, color = "orange"},
    ["👈"] = {dx = -1, dy = 0, color = "orange"},
    ["👆"] = {dx = 0, dy = -1, color = "orange"},
    ["👇"] = {dx = 0, dy = 1, color = "orange"},
    ["➡️"] = {dx = 1, dy = 0, color = "blue"},
    ["⬅️"] = {dx = -1, dy = 0, color = "blue"},
    ["⬆️"] = {dx = 0, dy = -1, color = "blue"},
    ["⬇️"] = {dx = 0, dy = 1, color = "blue"}
}

--==============================================================================
-- G A M E   S T A T E
--==============================================================================

-- Cargar los niveles desde el archivo externo
local levels = require("levels")

-- Tabla principal para almacenar todos los datos del juego
local gameData = {
    player = {},
    boxes = {},
    goals = {},
    portals = { orange = {}, blue = {} },
    levelMap = {},
    running = true,
    currentLevel = 1,
    originalLevel = {} -- Para poder reiniciar el nivel
}

--==============================================================================
-- L E V E L   P A R S I N G
--==============================================================================

-- Guarda una copia profunda del mapa del nivel para la función de reinicio.
local function deepCopyLevel(level)
    local copy = {}
    for y = 1, #level do
        copy[y] = {}
        for x = 1, #level[y] do
            copy[y][x] = level[y][x]
        end
    end
    return copy
end

-- Analiza el mapa del nivel y extrae las posiciones de todos los objetos.
function parseLevel(levelDefinition)
    gameData.originalLevel = deepCopyLevel(levelDefinition)
    
    -- Limpiar los datos del nivel anterior
    gameData.player = {}
    gameData.boxes = {}
    gameData.goals = {}
    gameData.portals = {orange = {}, blue = {}}
    gameData.levelMap = {}
    
    -- Recorrer el mapa para extraer los objetos y crear un mapa base limpio
    for y = 1, #levelDefinition do
        gameData.levelMap[y] = {}
        for x = 1, #levelDefinition[y] do
            local cell = levelDefinition[y][x]
            local portalInfo = PORTAL_DEFINITIONS[cell]

            if cell == OBJECTS.PLAYER then
                gameData.player = {x = x, y = y}
                gameData.levelMap[y][x] = TILES.FLOOR
            elseif cell == OBJECTS.BOX then
                table.insert(gameData.boxes, {x = x, y = y})
                gameData.levelMap[y][x] = TILES.FLOOR
            elseif cell == TILES.GOAL then
                table.insert(gameData.goals, {x = x, y = y})
                gameData.levelMap[y][x] = TILES.FLOOR
            elseif portalInfo then
                local portal = { x = x, y = y, dx = portalInfo.dx, dy = portalInfo.dy, emoji = cell }
                table.insert(gameData.portals[portalInfo.color], portal)
                gameData.levelMap[y][x] = TILES.FLOOR
            else
                gameData.levelMap[y][x] = cell
            end
        end
    end
end

--==============================================================================
-- G A M E   Q U E R I E S   (Funciones que consultan el estado)
--==============================================================================

function getBoxAt(x, y)
    for i, box in ipairs(gameData.boxes) do
        if box.x == x and box.y == y then return i end
    end
    return nil
end

function getPortalAt(x, y)
    for _, portal in ipairs(gameData.portals.orange) do
        if portal.x == x and portal.y == y then return portal, "orange" end
    end
    for _, portal in ipairs(gameData.portals.blue) do
        if portal.x == x and portal.y == y then return portal, "blue" end
    end
    return nil, nil
end

function getExitPortal(entryColor)
    local exitColor = (entryColor == "orange") and "blue" or "orange"
    if gameData.portals[exitColor] and #gameData.portals[exitColor] > 0 then
        return gameData.portals[exitColor][1]
    end
    return nil
end

function isGoalAt(x, y)
    for _, goal in ipairs(gameData.goals) do
        if goal.x == x and goal.y == y then return true end
    end
    return false
end

function isWallAt(x, y)
    return not gameData.levelMap[y] or not gameData.levelMap[y][x] or gameData.levelMap[y][x] == TILES.WALL
end

function countBoxesInGoals()
    local count = 0
    for _, box in ipairs(gameData.boxes) do
        if isGoalAt(box.x, box.y) then count = count + 1 end
    end
    return count
end

function checkWin()
    if #gameData.goals == 0 then return false end
    return countBoxesInGoals() == #gameData.boxes
end

--==============================================================================
-- D R A W I N G
--==============================================================================

function draw()
    os.execute("cls")
    
    -- 1. Crear una copia del mapa base para dibujar sobre ella
    local display = deepCopyLevel(gameData.levelMap)
    
    -- 2. Dibujar elementos en orden de prioridad (de atrás hacia adelante)
    for _, portal in ipairs(gameData.portals.orange) do display[portal.y][portal.x] = portal.emoji end
    for _, portal in ipairs(gameData.portals.blue) do display[portal.y][portal.x] = portal.emoji end
    
    for _, goal in ipairs(gameData.goals) do
        if not getPortalAt(goal.x, goal.y) then
            display[goal.y][goal.x] = TILES.GOAL
        end
    end
    
    for _, box in ipairs(gameData.boxes) do
        display[box.y][box.x] = isGoalAt(box.x, box.y) and OBJECTS.BOX_ON_GOAL or OBJECTS.BOX
    end
    
    display[gameData.player.y][gameData.player.x] = OBJECTS.PLAYER
    
    -- 3. Imprimir el tablero completo
    for y = 1, #display do
        io.write(table.concat(display[y]))
        io.write("\n")
    end
    
    -- 4. Imprimir información y controles
    print("--------------------------------------------------")
    print("WASD para moverse | R para reiniciar | Q para salir")
    print("Nivel: " .. gameData.currentLevel .. "/" .. #levels .. " | Cajas en metas: " .. countBoxesInGoals() .. "/" .. #gameData.boxes)
    print("🌀 Portales naranjas (👉👈👆👇) y azules (➡️⬅️⬆️⬇️) te teletransportan.")
    print("--------------------------------------------------")
end

--==============================================================================
-- G A M E   L O G I C
--==============================================================================

-- Intenta teletransportar una entidad (jugador o caja).
-- Devuelve true si el teletransporte fue exitoso.
function teleportEntity(entity, allowPush)
    local portal, color = getPortalAt(entity.x, entity.y)
    if not portal then return false end

    local exitPortal = getExitPortal(color)
    if not exitPortal then return false end

    local exitX, exitY = exitPortal.x + exitPortal.dx, exitPortal.y + exitPortal.dy

    if isWallAt(exitX, exitY) then return false end
    if entity ~= gameData.player and gameData.player.x == exitX and gameData.player.y == exitY then return false end

    local blockingBoxIndex = getBoxAt(exitX, exitY)
    if blockingBoxIndex then
        if not allowPush then return false end -- No se permite empujar

        local blockingBox = gameData.boxes[blockingBoxIndex]
        local pushToX, pushToY = blockingBox.x + exitPortal.dx, blockingBox.y + exitPortal.dy

        -- Verificar si el espacio para empujar la caja está libre
        if not isWallAt(pushToX, pushToY) and not getBoxAt(pushToX, pushToY) and not (gameData.player.x == pushToX and gameData.player.y == pushToY) then
            blockingBox.x, blockingBox.y = pushToX, pushToY -- Empujar caja
        else
            return false -- El empuje está bloqueado
        end
    end

    -- Teletransportar la entidad
    entity.x, entity.y = exitX, exitY
    return true
end

-- Mueve al jugador y gestiona las colisiones y empujes.
function movePlayer(dx, dy)
    local player = gameData.player
    local targetX, targetY = player.x + dx, player.y + dy

    if isWallAt(targetX, targetY) then return end

    local boxIndex = getBoxAt(targetX, targetY)

    if not boxIndex then -- Movimiento libre
        player.x, player.y = targetX, targetY
    else -- Hay una caja, intentar empujar
        local box = gameData.boxes[boxIndex]
        local boxTargetX, boxTargetY = box.x + dx, box.y + dy

        -- Verificar si el destino de la caja es un portal
        local portalAtBoxTarget, color = getPortalAt(boxTargetX, boxTargetY)
        if portalAtBoxTarget then
            local exitPortal = getExitPortal(color)
            if not exitPortal then return end -- No hay salida de portal, movimiento bloqueado
            
            boxTargetX = exitPortal.x + exitPortal.dx
            boxTargetY = exitPortal.y + exitPortal.dy
        end

        -- Verificar si la posición final de la caja está libre
        if not isWallAt(boxTargetX, boxTargetY) and not getBoxAt(boxTargetX, boxTargetY) then
            box.x, box.y = boxTargetX, boxTargetY -- Mover caja
            player.x, player.y = targetX, targetY -- Mover jugador
        end
    end
    
    -- Después de cualquier movimiento, verificar si el jugador debe ser teletransportado
    teleportEntity(player, true)
    
    if checkWin() then
        loadNextLevel()
    end
end

function loadNextLevel()
    draw()
    gameData.currentLevel = gameData.currentLevel + 1
    
    if gameData.currentLevel > #levels then
        gameData.running = false
        print("🎉🎉🎉 ¡FELICITACIONES! ¡Has completado todos los niveles! 🎉🎉🎉")
        io.read()
    else
        print("🎊 ¡NIVEL COMPLETADO! 🎊 Presiona Enter para continuar...")
        io.read()
        parseLevel(levels[gameData.currentLevel])
    end
end

function processInput()
    local input = io.read()
    if input == "w" then movePlayer(0, -1)
    elseif input == "s" then movePlayer(0, 1)
    elseif input == "a" then movePlayer(-1, 0)
    elseif input == "d" then movePlayer(1, 0)
    elseif input == "q" then gameData.running = false
    elseif input == "r" then parseLevel(gameData.originalLevel)
    end
end

--==============================================================================
-- M A I N   L O O P
--==============================================================================

local function setupConsole()
    os.execute("cls")
    io.output():setvbuf("no")
    os.execute("chcp 65001 > nul")
end

local function showWelcomeScreen()
    print("🌀 BIENVENIDO A SOKOBAN CON PORTALES 🌀")
    print("Niveles disponibles: " .. #levels)
    print("Presiona Enter para comenzar...")
    io.read()
end

local function main()
    setupConsole()

    if not levels or #levels == 0 then
        print("Error: No se encontraron niveles en 'levels.lua'.")
        return
    end

    showWelcomeScreen()
    parseLevel(levels[gameData.currentLevel])

    while gameData.running do
        draw()
        processInput()
    end

    print("¡Gracias por jugar!")
end

-- Iniciar el juego
main()
