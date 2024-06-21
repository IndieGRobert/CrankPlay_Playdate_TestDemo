import "CoreLibs/graphics"
import "CoreLibs/timer"

local gfx = playdate.graphics

-- 定义立方体的顶点
local vertices = {
    {-1, -1, -1},
    { 1, -1, -1},
    { 1,  1, -1},
    {-1,  1, -1},
    {-1, -1,  1},
    { 1, -1,  1},
    { 1,  1,  1},
    {-1,  1,  1},
}

-- 定义立方体的边（顶点索引）
local edges = {
    {1, 2}, {2, 3}, {3, 4}, {4, 1},
    {5, 6}, {6, 7}, {7, 8}, {8, 5},
    {1, 5}, {2, 6}, {3, 7}, {4, 8},
}

local angle = 0

-- 3D 投影函数
local function project3D(x, y, z)
    local scale = 100
    local distance = 3
    local factor = scale / (z + distance)
    local x2d = x * factor + 200
    local y2d = y * factor + 120
    return x2d, y2d
end

-- 旋转函数（绕 Y 轴）
local function rotateY(x, y, z, angle)
    local cosAngle = math.cos(angle)
    local sinAngle = math.sin(angle)
    local xRot = x * cosAngle - z * sinAngle
    local zRot = x * sinAngle + z * cosAngle
    return xRot, y, zRot
end

function playdate.update()
    gfx.clear(gfx.kColorBlack)
    gfx.setColor(gfx.kColorWhite)

    -- 计算旋转角度
    angle = angle + 0.02

    -- 绘制立方体边
    for _, edge in ipairs(edges) do
        local startVertex = vertices[edge[1]]
        local endVertex = vertices[edge[2]]

        local x1, y1, z1 = rotateY(startVertex[1], startVertex[2], startVertex[3], angle)
        local x2, y2, z2 = rotateY(endVertex[1], endVertex[2], endVertex[3], angle)

        local x1Projected, y1Projected = project3D(x1, y1, z1)
        local x2Projected, y2Projected = project3D(x2, y2, z2)

        gfx.drawLine(x1Projected, y1Projected, x2Projected, y2Projected)
    end

    playdate.timer.updateTimers()
    playdate.drawFPS(0, 0)
end