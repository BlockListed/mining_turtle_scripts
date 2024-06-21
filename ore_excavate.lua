local function blockTest(block)
    return function(inspect_fn)
        local w, i = inspect_fn()

        if w then
            if i.name == block then
                return true
            end
        end

        return false
    end
end

local function turnAround()
    turtle.turnLeft()
    turtle.turnLeft()
end

local function mine(blockTest_fn)
    -- up
    if blockTest_fn(turtle.inspectUp) then
        turtle.digUp()
        turtle.up()
        mine(blockTest_fn)
        turtle.down()
    end

    -- down
    if blockTest_fn(turtle.inspectDown) then
        turtle.digDown()
        turtle.down()
        mine(blockTest_fn)
        turtle.up()
    end

    -- forward
    if blockTest_fn(turtle.inspect) then
        turtle.dig()
        if turtle.forward() then
            mine(blockTest_fn)
            turtle.back()
        end
    end

    -- left
    turtle.turnLeft()
    if blockTest_fn(turtle.inspect) then
        turtle.dig()
        if turtle.forward() then
            mine(blockTest_fn)
            turtle.back()
        end
    end
    
    -- back
    turtle.turnLeft()
    if blockTest_fn(turtle.inspect) then
        turtle.dig()
        if turtle.forward() then
            mine(blockTest_fn)
            turtle.back()
        end
    end

    -- right
    turtle.turnLeft()
    if blockTest_fn(turtle.inspect) then
        turtle.dig()
        if turtle.forward() then
            mine(blockTest_fn)
            turtle.back()
        end
    end

    turtle.turnLeft()
end

return {
    blockTest = blockTest,
    mine = mine,
}
