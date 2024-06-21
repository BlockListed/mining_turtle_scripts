local ores = {
    ["minecraft:coal_ore"] = true,
    ["minecraft:deepslate_coal_ore"] = true,
    ["minecraft:copper_ore"] = true,
    ["minecraft:deepslate_copper_ore"] = true,
    ["minecraft:iron_ore"] = true,
    ["minecraft:deepslate_iron_ore"] = true,
    ["minecraft:gold_ore"] = true,
    ["minecraft:deepslate_gold_ore"] = true,
    ["minecraft:lapis_ore"] = true,
    ["minecraft:deepslate_lapis_ore"] = true,
    ["minecraft:redstone_ore"] = true,
    ["minecraft:deepslate_redstone_ore"] = true,
    ["minecraft:diamond_ore"] = true,
    ["minecraft:deepslate_diamond_ore"] = true,
    ["minecraft:emerald_ore"] = true,
    ["minecraft:deepslate_emerald_ore"] = true,
}

local lane_length = 100

local excavate = require("ore_excavate")

-- returns the amount of lanes to skip
-- aka the previous final lane
local function load_current_lane()
    local f, failReason = io.open("mine_status.txt")
    if not f then
        print("couldn't open mine_status.txt: ", failReason)
        return 0
    end

    local raw_lane = f:read("a")

    f:close()

    if not raw_lane then
        print("couldn't read number from mine_status.txt")
        return 0
    end

    local lane = math.floor(tonumber(raw_lane, 10))

    print("continueing from lane: ", math.floor(lane))

    return math.floor(lane)
end

local skip_lanes = ...

if not skip_lanes then
    skip_lanes = load_current_lane()
end

local current_lane = 1 + skip_lanes

local function save_current_lane(lane)
    local f, failReason = io.open("mine_status.txt", "r")
    if not f then
        print("couldn't open mine_status.txt for writing: ", failReason)
        return false
    end

    local write_result = f:write(lane)

    if not write_result then
        print("couldn't write lane to file")
    end

    f:flush()
    f:close()
end

local function turnAround()
    turtle.turnLeft()
    turtle.turnLeft()
end

local function tryMine(inspect_fn)
    local w, i = inspect_fn()
    if w then
        -- mine all forge ores
        if ores[i.name] or i.tags["forge:ores"] then
            local blockTest_fn = excavate.blockTest(i.name)
            excavate.mine(blockTest_fn)
        end
    end
end

local function checkCurrent()
    tryMine(turtle.inspect)
    tryMine(turtle.inspectDown)

    turtle.turnLeft()
    tryMine(turtle.inspect)
    turnAround()
    tryMine(turtle.inspect)

    turtle.up()
    tryMine(turtle.inspect)
    turtle.turnLeft()
    tryMine(turtle.inspectUp)
    tryMine(turtle.inspect)

    turtle.turnLeft()
    tryMine(turtle.inspect)

    turtle.down()
    turtle.turnRight()
end

local function estimateFuelConsumption()
    local toLaneAndBack = current_lane * 4 * 2

    local lane = math.ceil(lane_length + (lane_length * 3) + (lane_length * 0.5))

    return toLaneAndBack + lane
end

local function mineLane()
    turnAround()
    for i=1,current_lane*4 do
        turtle.dig()
        turtle.forward()
        turtle.digUp()
    end
    turtle.turnLeft()

    for i=1,lane_length do
        turtle.dig()
        turtle.forward()
        turtle.digUp()
        checkCurrent()
    end

    turnAround()

    while turtle.forward() do end

    turtle.turnRight()

    while turtle.forward() do end

    current_lane = current_lane + 1
    save_current_lane(current_lane)
end

local function needRefuel()
    return turtle.getFuelLevel() < estimateFuelConsumption()
end

-- only run at station
local function doRefuel()
    while needRefuel() do
        if not turtle.suckUp() then
            return false, "No more fuel"
        end

        turtle.refuel()
    end
    return true
end

local function rearm()
    for i=1,16 do
        turtle.select(i)
        
        local isFuel = turtle.refuel(0)

        if isFuel then
            turtle.dropUp()
        else
            turtle.drop()
        end
    end

    turtle.select(1)

    return doRefuel()
end

local function iteration()
    local success, failReason = rearm()

    if not success then
        print(failReason)
        return false
    end

    mineLane()

    return true
end

while true do
    if not iteration() then
        sleep(10)
    end
end
