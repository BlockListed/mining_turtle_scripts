local function checkBlocks(block)
    local function inspect(inspect_fn)
        local w, i = inspect_fn()

        if w then
            if i.name == block then
                return true
            end
        end

        return false
    end

    return function()
        local front = inspect(turtle.inspect)
        local up = inspect(turtle.inspectUp)
        local down = inspect(turtle.inspectDown)

        turtle.turnLeft()
        local left = inspect(turtle.inspect)

        turtle.turnLeft()
        local back = inspect(turtle.inspect)

        turtle.turnLeft()
        local right = inspect(turtle.inspect)

        turtle.turnLeft()

        return {
            front = front,
            left = left,
            back = back,
            right = right,
            up = up,
            down = down
        }
    end
end

function turtle.turnAround()
    turtle.turnLeft()
    turtle.turnLeft()
end

local function mineBlock(checkBlocks)
    local blocks = checkBlocks()

    local detected = false

    for _, v in pairs(blocks) do
        detected = detected or v
    end

    if not detected then
        return
    end

    if blocks.up then
        turtle.digUp()
        local moved = turtle.up()

        if moved then
            mineBlock(checkBlocks)
            turtle.down()
        end
    end

    if blocks.down then
        turtle.digDown()

        local moved = turtle.down()

        if moved then
            mineBlock(checkBlocks)

            turtle.up()
        end
    end

    if blocks.front then
        turtle.dig()

        local moved = turtle.forward()

        if moved then
            mineBlock(checkBlocks)
        end

        turtle.turnAround()

        if moved then
            turtle.forward()
        end

        turtle.turnAround()
    end

    if blocks.back then
        turtle.turnAround()

        turtle.dig()

        local moved = turtle.forward()

        if moved then
            mineBlock(checkBlocks)
        end

        turtle.turnAround()

        if moved then
            turtle.forward()
        end
    end

    if blocks.left then
        turtle.turnLeft()

        turtle.dig()

        local moved = turtle.forward()

        if moved then
            mineBlock(checkBlocks)
        end

        turtle.turnAround()

        if moved then
            turtle.forward()
        end

        turtle.turnLeft()
    end

    if blocks.right then
        turtle.turnRight()

        turtle.dig()

        local moved = turtle.forward()

        if moved then
            mineBlock(checkBlocks)
        end

        turtle.turnAround()

        if moved then
            turtle.forward()
        end

        turtle.turnRight()
    end
end

local function mineVein(block)
    local checkBlocks_fn = checkBlocks(block)

    mineBlock(checkBlocks_fn)

    return true
end

local ores = {
    ["minecraft:coal_ore"] = true,
    ["minecraft:iron_ore"] = true,
    ["minecraft:gold_ore"] = true,
    ["minecraft:copper_ore"] = true,
    ["minecraft:redstone_ore"] = true,
    ["minecraft:diamond_ore"] = true,
    ["minecraft:emerald_ore"] = true,
    ["minecraft:lapis_ore"] = true
}

local function mineOres()
    local _, i = turtle.inspect()

    if ores[i.name] then
        mineVein(i.name)
    end

    local _, i = turtle.inspectUp()

    if ores[i.name] then
        mineVein(i.name)
    end

    local _, i = turtle.inspectDown()

    if ores[i.name] then
        mineVein(i.name)
    end

    turtle.turnRight()

    local _, i = turtle.inspect()

    if ores[i.name] then
        mineVein(i.name)
    end

    turtle.turnLeft()

    turtle.turnLeft()

    local _, i = turtle.inspect()

    if ores[i.name] then
        mineVein(i.name)
    end

    turtle.turnRight()
end

local function stripMine(n)
    for i = 1, n do
        turtle.dig()

        turtle.forward()

        turtle.digUp()

        mineOres()

        turtle.up()

        mineOres()

        turtle.down()
    end
end

local function mineTunnel()
    turtle.turnLeft()

    stripMine(100)

    turtle.turnAround()

    for i = 1, 100 do
        turtle.forward()
    end

    turtle.turnLeft()
end

local function refuelTurtle()
    if turtle.getFuelLevel() == "unlimited" then
        return
    end

    if turtle.getFuelLevel() >= 2000 then
        return
    end

    for i = 1, 16 do
        turtle.select(i)

        turtle.refuel()
    end

    turtle.select(1)
end

local junk = {
    ["minecraft:cobblestone"] = true,
    ["minecraft:granite"] = true,
    ["minecraft:diorite"] = true,
    ["minecraft:andesite"] = true,
    ["minecraft:cobbled_deepslate"] = true,
    ["minecraft:gravel"] = true,
    ["minecraft:dirt"] = true
}

local function clearInventory()
    for i = 1, 16 do
        local info = turtle.getItemDetail(i)

        if info then
            if junk[info.name] then
                turtle.select(i)

                turtle.drop()
            end
        end
    end

    turtle.select(1)
end

while true do
    mineTunnel()

    refuelTurtle()

    clearInventory()

    stripMine(4)
end
