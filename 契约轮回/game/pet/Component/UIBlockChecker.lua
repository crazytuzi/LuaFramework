---
--- Created by R2D2.
--- DateTime: 2019/4/20 16:58
---
UIBlockChecker = UIBlockChecker or class("UIBlockChecker")

function UIBlockChecker:ctor()

end

function UIBlockChecker:dctor()
    --print("<<color=#00ff00>------------" .. tostring(self) .. "------------</color>")
    local toucher = self.touchObj:GetComponent(typeof(Toucher))
    if (toucher) then
        GameObject.Destroy(toucher)
    end

    self.touchObj = nil
    self.BlockObj = nil
    self.callBack = nil
end

---设置点击到区域外的回调
function UIBlockChecker:SetOverBlockCallBack(callBack)
    self.callBack = callBack
end

---touchObj=>放置Toucher组件的GameObject
---其它参数为进行差别的RectTransfrom
function UIBlockChecker:InitUI(touchObj, ...)
    self.touchObj = touchObj

    self:SetBlock(...)

    local toucher = touchObj:AddComponent(typeof(Toucher))
    toucher:SetClickEvent(handler(self, self.OnTouchBegin))

    local touchRect = touchObj:GetComponent("RectTransform").rect
    self.fullSize = Vector2(touchRect.width, touchRect.height)

    ---用非满屏Panel做范围的UI则直接使用全屏幕尺寸
    if (self.fullSize.x < ScreenWidth or self.fullSize.y < ScreenHeight) then
        self.fullSize = Vector2(ScreenWidth, ScreenHeight)
    end
end

---设置阻挡
function UIBlockChecker:SetBlock(...)
    local blocks = { ... }
    self.BlockObj = {}

    for _, v in ipairs(blocks) do
        if (v.transform) then
            table.insert(self.BlockObj, v.transform)
        end
    end

end

---添加阻挡
function UIBlockChecker:AddBlock(block)
    if (block and block.transform) then
        table.insert(self.BlockObj, block.transform)
    end
end


function UIBlockChecker:OnTouchBegin(x, y)

    for _, v in ipairs(self.BlockObj) do
        if (self:CheckBlock(v, x, y)) then
            return
        end
    end
    if (self.callBack) then
        self.callBack()
    end
end

function UIBlockChecker:CheckBlock(objRectTransform, x, y)

    local touchPos = LayerManager:UIScreenToViewportPoint(x, y, 0)
    touchPos = Vector2(touchPos.x * self.fullSize.x, touchPos.y * self.fullSize.y)
    x = touchPos.x
    y = touchPos.y

    local pivot = objRectTransform.pivot
    local size = objRectTransform.sizeDelta
    local pos = objRectTransform.position

    local offset = Vector2(pivot.x * size.x, pivot.y * size.y)
    pos = LayerManager:UIWorldToViewportPoint(pos.x, pos.y, 0)
    pos = Vector2(pos.x * self.fullSize.x, pos.y * self.fullSize.y)

    local pos1 = Vector2.__sub(pos, offset)
    local pos2 = Vector2.__add(pos1, size)

    return (x >= pos1.x and x <= pos2.x and pos1.y <= y and pos2.y >= y)
end

function UIBlockChecker:GetArea(tipSize, viewPos)
    local areas = {
        { x = -1, y = 1 }, --左上角
        { x = 1, y = 1 }, --右上角
        { x = 1, y = -1 }, --右下角
        { x = -1, y = -1 } --左下角
    }

    ---视口坐标转成窗口坐标
    local clickPos = Vector2(self.fullSize.x * viewPos.x, self.fullSize.y * viewPos.y)

    for _, v in ipairs(areas) do
        local newPos = Vector2.__mul(v, 50) ---50为偏移量
        local offset = Vector2(v.x * tipSize.x, v.y * tipSize.y)
        newPos = newPos + clickPos + offset
        --print("<<color=#00ff00>" .. tostring(v) .. " ->" .. tostring(newPos) .. "</color>")
        if (newPos.x >= 0 and newPos.x <= self.fullSize.x and newPos.y >= 0 and newPos.y <= self.fullSize.y) then
            return v, newPos
        end
    end

    --如果都不合适就放顶左上角
    return areas[1], Vector2(50, self.fullSize.y - 50)
end