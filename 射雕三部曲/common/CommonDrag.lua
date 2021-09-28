--[[
    文件名：CommonDrag
	描述：封装处理某个页面上的控件拖动操作
	创建人：peiyaoqiang
	创建时间：2017.07.17
-- ]]

-- 指定列表的数据格式
--[[
{
    showIndex = 1,      -- 必选参数，该阵位的排序，拖动后返回最新顺序列表
    pos,                -- 必选参数，该阵位的显示pos
    
    -- 以下内容在拖动的时候会互相交换数据
    nodeSprite,         -- 必选参数，该阵位的显示内容
    zorder,             -- 可选参数，该阵位的加载顺序，不传默认为1
    ...                 -- 其他自定义内容
}
--]]
local CommonDrag = {}

-- 注册拖动事件
--[[
    参数 params:
        parent: 需要注册拖动的Layer
        callback: 拖放结束后的回调
        posList: 位置列表
        itemList: 数据列表，详情请参考页面顶部的数据格式
        nodeHalfW: 可拖动node的一半宽度
        nodeHalfH: 可拖动node的一半高度
--]]
function CommonDrag:registerDragTouch(params)
    local parentLayer = params.parent
    self.callback = params.callback
    self.itemList = clone(params.itemList)
    self.nodeHalfW = params.nodeHalfW
    self.nodeHalfH = params.nodeHalfH
    
    -- 计算最大的order顺序
    self.maxZorder = 1
    for _,v in pairs(self.itemList) do
        local tmpZorder = v.zorder or 0
        if (self.maxZorder < tmpZorder) then
            self.maxZorder = tmpZorder
        end
    end
    self.maxZorder = self.maxZorder + 1

    -- 注册
    ui.registerSwallowTouch({
        node = parentLayer,
        allowTouch = false,
        beganEvent = function(touch, event)
            local touchPos = parentLayer:convertTouchToNodeSpace(touch)
            self:onBeganEvent(touchPos.x, touchPos.y)
            return true
        end,
        movedEvent = function(touch, event)
            local touchPos = parentLayer:convertTouchToNodeSpace(touch)
            self:onMovedEvent(touchPos.x, touchPos.y)
        end,
        endedEvent = function(touch, event)
            local touchPos = parentLayer:convertTouchToNodeSpace(touch)
            self:onEndedEvent(touchPos.x, touchPos.y)
        end,
    })
end

-- 辅助函数：返回点击位置所处的node
function CommonDrag:getClickItem(posX, posY)
    local retItem = nil
    for _,v in ipairs(self.itemList) do
        local pos = v.pos
        if ((posX >= (pos.x - self.nodeHalfW)) and (posX <= (pos.x + self.nodeHalfW)) and (posY >= pos.y - self.nodeHalfH) and (posY <= (pos.y + self.nodeHalfH))) then
            retItem = v
            break
        end
    end

    return retItem
end

function CommonDrag:onBeganEvent(posX, posY)
    -- 找到被点击的node，并记录当前位置
    self.lastClickPos = nil     -- 记录移动位置
    self.lastNodePos = nil      -- 记录node位置
    self.clickItem = self:getClickItem(posX, posY)
    if (self.clickItem ~= nil) then
        self.clickItem.nodeSprite:setLocalZOrder(self.maxZorder)
        self.lastNodePos = self.clickItem.pos
    else
        self.clickItem = nil
    end
end

function CommonDrag:onMovedEvent(posX, posY)
    -- 和上个位置距离超过3才移动
    if (self.lastClickPos == nil) then
        self.lastClickPos = cc.p(posX, posY)
    else
        local xOffset = posX - self.lastClickPos.x
        local yOffset = posY - self.lastClickPos.y
        if ((math.abs(xOffset) >= 3) or (math.abs(yOffset) >= 3)) then
            if ((self.clickItem ~= nil) and (self.lastNodePos ~= nil)) then
                self.lastNodePos = cc.p(self.lastNodePos.x + xOffset, self.lastNodePos.y + yOffset)
                self.clickItem.nodeSprite:setPosition(self.lastNodePos)
            end
            self.lastClickPos = cc.p(posX, posY)
        end
    end
end

function CommonDrag:onEndedEvent(posX, posY)
    if ((self.clickItem == nil) or (self.lastClickPos == nil)) then
        return
    end

    -- 计算落点的位置
    local endItem = self:getClickItem(posX, posY)
    if (endItem ~= nil) and (endItem.slotId ~= self.clickItem.slotId) then
        self.clickItem.nodeSprite:setLocalZOrder(endItem.zorder)
        self.clickItem.nodeSprite:runAction(cc.MoveTo:create(0.1, endItem.pos))
        endItem.nodeSprite:runAction(cc.MoveTo:create(0.1, self.clickItem.pos))

        -- 交换数据
        for k,v in pairs(self.clickItem) do
            if (k ~= "showIndex") and (k ~= "pos") then
                local oldValue = clone(v)
                self.clickItem[k] = endItem[k]
                endItem[k] = oldValue
            end
        end

        -- 执行回调
        if self.callback then
            self.callback(self.itemList)
        end
    else
        -- 落在其他范围
        self.clickItem.nodeSprite:runAction(cc.MoveTo:create(0.1, self.clickItem.pos))
    end

    self.clickItem = nil
    self.lastClickPos = nil
    self.lastNodePos = nil
end

return CommonDrag