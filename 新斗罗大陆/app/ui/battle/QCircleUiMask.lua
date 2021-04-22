
local QBaseUiMask = import(".QBaseUiMask")
local QCircleUiMask = class("QCircleUiMask", QBaseUiMask)

function QCircleUiMask:ctor(options)
    QCircleUiMask.super.ctor(self, options)
end

function QCircleUiMask:update(percent)
    if self:preUpdate(percent) == QDEF.HANDLED then
        return 
    end

    local stencil = self._stencil

    -- create stencil polygon
    local size = self._maskSize

    -- consider the center of the ploygon as ccp(0, 0)
    local w = size.width / 2
    local h = size.height / 2
    -- radius of the circle for the polygon
    local r = math.sqrt(w * w + h * h)

    -- local vertices = CCPointArray:create(7)
    -- vertices:add(ccp(0, 0))
    -- vertices:add(ccp(0, h))
    -- vertices:add(ccp(-w, h))
    -- vertices:add(ccp(-w, -h))
    -- vertices:add(ccp(w, -h))
    -- vertices:add(ccp(w, h))
    -- vertices:add(ccp(0, 0)) -- dont need this point, just added as placeholder and for future replacing

    local vertices = {}
    table.insert(vertices, {0, 0})
    table.insert(vertices, {0, h})
    table.insert(vertices, {-w, h})
    table.insert(vertices, {-w, -h})
    table.insert(vertices, {w, -h})
    table.insert(vertices, {w, h})
    table.insert(vertices, {0, 0})

    local count = 3

    if percent < 1/8 then
        -- do nothing
    elseif percent < 3/8 then
        count = 4
    elseif percent < 5/8 then
        count = 5
    elseif percent < 7/8 then
        count = 6
    else
        count = 7
    end

    local angle = (1 - percent) * math.pi * 2
    -- local lastPt = ccp(math.sin(angle) * r, math.cos(angle) * r)
    -- vertices:replace(lastPt, count - 1)
    vertices[count] = {math.sin(angle) * r, math.cos(angle) * r}

    local vertexCount = table.nums(vertices)
    while vertexCount > count do
        table.remove(vertices, vertexCount)
        vertexCount = table.nums(vertices)
    end

    local stencilColor = ccc4f(0, 0, 0, 0)

    --TBD: memory leak: points, check collect.CCPoint and see if it can release it
    -- local points = vertices:fetchPoints()

    local param = {
        fillColor = stencilColor,
        borderWidth = 1,
        borderColor = stencilColor
    }

    stencil:clear()
    stencil:drawPolygon(vertices, param)
end

return QCircleUiMask
