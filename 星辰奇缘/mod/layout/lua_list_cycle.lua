-- 滚动循环列表
-- 定高定宽
-- 黄耀聪

LuaListCycle = LuaListCycle or {}

local LuaListCycle = LuaListCycle
local __floor = math.floor
local __ceil = math.ceil

local SetSizeDelta = function(trans, x, y)
    trans.sizeDelta = Vector2(x, y)
end

local SetAPosition = function(trans, x, y, z)
    trans.anchoredPosition = Vector3(x, y, z)
end

local GetAPosition = function(trans)
    local anchoredPos = trans.anchoredPosition
    return anchoredPos.x, anchoredPos.y
end

-- container : Transform
-- setting = {
--     cellX = 格子宽度
--     cellY = 格子高度
--     itemList = 格子对象列表

--     top = 顶部距离（可选）
--     bottom = 底部距离（可选）
--     left = 左边距离（可选）
--     right = 右边距离（可选）
--     spacingY = 格子竖直间隔（可选）
--     spacingX = 格子水平间隔（可选）
-- }

function LuaListCycle.Init(container, setting)
    local proxy = {}
    proxy.container = container
    proxy.parent = container.parent
    proxy.rectWidth = proxy.parent.rect.width
    proxy.rectHeight = proxy.parent.rect.height

    local setting = setting or {}
    proxy.cellX = setting.cellX or 100
    proxy.cellY = setting.cellY or 100

    proxy.top = setting.top or 0
    proxy.bottom = setting.bottom or 0
    proxy.left = setting.left or 0
    proxy.right = setting.right or 0
    proxy.spacingX = setting.spacingX or 0
    proxy.spacingY = setting.spacingY or 0
    proxy.itemList = setting.itemList or {}
    proxy.itemLength = #proxy.itemList
    proxy.width = 0
    proxy.height = 0
    proxy.dataList = {}     -- 数据
    proxy.length = 0        -- 数据长度
    proxy.direct = setting.direct or LuaLayoutEnum.Direct.Vertical
    proxy.special = nil     -- 特殊数据

    proxy.column = setting.column or 1 -- 每行元素个数,多行与多列排版都需要用
    proxy.row = setting.row or 1 -- 每列元素个数,多行排版用,一般用于翻页

    -- 显示的数据范围
    proxy.beginIndex = 0
    proxy.endIndex = 0

    return proxy
end

function LuaListCycle.SetDatalist(proxy, dataList)
    proxy.length = #dataList
    if proxy.direct == LuaLayoutEnum.Direct.Horizontal then
        proxy.height = proxy.top + proxy.cellY * proxy.row + (proxy.row - 1) * proxy.spacingY + proxy.bottom
        if proxy.length == 0 then
            proxy.width = proxy.left + proxy.right
        else
            if proxy.row == 1 then
                proxy.width = proxy.left + proxy.right + (proxy.length - 1) * proxy.spacingX + proxy.length * proxy.cellX
            else
                proxy.width = proxy.left + proxy.right + (__ceil(proxy.length / proxy.row / proxy.column) * proxy.column) * proxy.spacingX + __ceil(proxy.length / proxy.row / proxy.column) * proxy.column * proxy.cellX
            end
        end
    elseif proxy.direct == LuaLayoutEnum.Direct.Vertical then
        proxy.width = proxy.left + proxy.cellX * proxy.column + (proxy.column - 1) * proxy.spacingX + proxy.right
        if proxy.length == 0 then
            proxy.height = proxy.top + proxy.bottom
        else
            proxy.height = proxy.top + proxy.bottom + (__ceil(proxy.length / proxy.column) - 1) * proxy.spacingY + __ceil(proxy.length / proxy.column) * proxy.cellY
        end
    end
    SetSizeDelta(proxy.container, proxy.width, proxy.height)
    local __max_length = (proxy.itemLength < proxy.length) and proxy.itemLength or proxy.length
    for i=1,__max_length do
        proxy.itemList[i]:SetActive(true)
    end
    for i=__max_length + 1,proxy.itemLength do
        proxy.itemList[i]:SetActive(false)
    end

    proxy.dataList = dataList
    proxy.itemIndexList = {}
    LuaListCycle.OnValueChanged(proxy)
end

function LuaListCycle.OnValueChanged(proxy)
    local __SetAPosition = SetAPosition
    local x,y = GetAPosition(proxy.container)
    local isVertical = false
    if proxy.direct == LuaLayoutEnum.Direct.Horizontal then
        if proxy.row == 1 then
            proxy.beginIndex = __floor((-x - proxy.left + proxy.spacingX - 1) / (proxy.spacingX + proxy.cellX))
            proxy.endIndex = __ceil((-x - proxy.left + proxy.spacingX + proxy.rectWidth + 1) / (proxy.spacingX + proxy.cellX))
        else
            proxy.beginIndex = __floor((-x - proxy.left + proxy.spacingX - 1) / (proxy.spacingX + proxy.cellX)) * proxy.row - (proxy.row - 1)
            proxy.endIndex = __ceil((-x - proxy.left + proxy.spacingX + proxy.rectWidth + 1) / (proxy.spacingX + proxy.cellX)) * proxy.row

            -- 算出来的开始和结束索引，按照页数修正一下
            proxy.beginIndex = __floor(proxy.beginIndex / proxy.row / proxy.column) * proxy.row * proxy.column + 1
            proxy.endIndex = __floor(proxy.endIndex / proxy.row / proxy.column + 1) * proxy.row * proxy.column
        end
    elseif proxy.direct == LuaLayoutEnum.Direct.Vertical then
        proxy.beginIndex = __floor((y - proxy.top + proxy.spacingY - 1) / (proxy.spacingY + proxy.cellY)) * proxy.column - (proxy.column - 1)
        proxy.endIndex = __ceil((y - proxy.top + proxy.rectHeight + proxy.spacingY + 1) / (proxy.spacingY + proxy.cellY)) * proxy.column
        isVertical = true
    end
    if proxy.beginIndex < 1 then proxy.beginIndex = 1 end
    if proxy.endIndex > proxy.length then proxy.endIndex = proxy.length end
    proxy.beginItemIndex = (proxy.beginIndex - 1) % proxy.itemLength + 1
    proxy.endItemIndex = (proxy.endIndex - 1) % proxy.itemLength + 1

    local index = nil
    for i=proxy.beginIndex,proxy.endIndex do
        index = (i - 1) % proxy.itemLength + 1
        if proxy.itemIndexList[index] ~= i then
            proxy.itemList[index]:update_my_self(proxy.dataList[i], i, proxy.special)
            if isVertical then
                __SetAPosition(proxy.itemList[index].transform, proxy.left + (index - 1) % proxy.column * (proxy.cellX + proxy.spacingX), -proxy.top - __floor((i - 1) / proxy.column) * proxy.cellY - __floor((i > 1 and (i - 1) or 0) / proxy.column) * proxy.spacingY, 0)
            else
                if proxy.row == 1 then
                    __SetAPosition(proxy.itemList[index].transform, proxy.left + (i - 1) * proxy.cellX + (i > 1 and (i - 1) or 0) * proxy.spacingX, 0, 0)
                else
                    local page = __floor((i - 1) / proxy.column / proxy.row)
                    __SetAPosition(proxy.itemList[index].transform, proxy.left + (page * proxy.column + (i - 1) % proxy.column) * proxy.cellX + ((i - 1) % proxy.column
                         + page * proxy.column) * proxy.spacingX
                        , -proxy.top - __floor((i - 1) % (proxy.column * proxy.row) / proxy.column) * (proxy.cellY + proxy.spacingY), 0)
                end
            end
            proxy.itemIndexList[index] = i
        end
    end
end

function LuaListCycle.Update(proxy, index, data)
    local itemIndex = (index - 1) % proxy.itemLength + 1
    if proxy.itemIndexList[itemIndex] == index then
        proxy.itemList[itemIndex]:update_my_self(data, index)
    end
    proxy.dataList[index] = data
end

function LuaListCycle.SetData(proxy, index, ...)
    local itemIndex = (index - 1) % proxy.itemLength + 1
    if proxy.itemIndexList[itemIndex] == index then
        proxy.itemList[itemIndex]:set_data(index, ...)
    end
end

function LuaListCycle.GetIndex(proxy, index)
    local itemIndex = (index - 1) % proxy.itemLength + 1
    if proxy.itemIndexList[itemIndex] == index then
        return proxy.itemList[itemIndex]
    end
end