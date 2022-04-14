BaseModelTipView = BaseModelTipView or class("BaseModelTipView",BaseItem)
local BaseModelTipView = BaseModelTipView

function BaseModelTipView:ctor(parent_node,layer)
	self.maxScrollViewHeight = 371
    self.maxViewHeight = 550
    self.minScrollViewHeight = 60
    self.addValueTemp = 140
end

function BaseModelTipView:dctor()
end


function BaseModelTipView:CloseTipView()
    self:destroy()
end

function BaseModelTipView:DelItem(bagId, uid)
    if self.uid == uid then
        self:destroy()
    end
end

function BaseModelTipView:AddClickCloseBtn()
    if self.click_bg_close then
        local tcher = self.gameObject:AddComponent(typeof(Toucher))
        tcher:SetClickEvent(handler(self, self.OnTouchenBengin))
    end
end

function BaseModelTipView:OnTouchenBengin(x, y, isCall)
    local isInViewBG = false
    local isInOperateBtn = false
    local isInModelViewBG = false

    isInViewBG = LayerManager:UIRectangleContainsScreenPoint(self.bgRectTra, x, y)
    isInModelViewBG = LayerManager:UIRectangleContainsScreenPoint(self.modelbgRectTra, x, y)

    if (self.btnSettors) then
        for _, v in ipairs(self.btnSettors) do
            if (LayerManager:UIRectangleContainsScreenPoint(v.transform, x, y)) then
                isInOperateBtn = true
                break
            end
        end
    end

    if (isCall) then
        return isInViewBG or isInOperateBtn or isInModelViewBG
    else
        if not isInViewBG and not isInOperateBtn and not isInModelViewBG then
            self:destroy()
        end
    end
end

function BaseModelTipView:AddOperateBtns()
    for i, v in pairs(self.operate_param or {}) do
        self.btnSettors[#self.btnSettors + 1] = GoodsOperateBtnSettor(self.btns)
        self.btnSettors[#self.btnSettors]:SetData(v)
    end
end

function BaseModelTipView:SetViewPosition()
    local localScale = GetLocalScale(self.transform)
    local parentWidth = 0
    local parentHeight = 0
    local spanX = 0
    local spanY = 0

    local pos = self.parent_node.position

    if self.parentRectTra.anchorMin.x == 0.5 then
        --spanX = 10
        parentWidth = self.parentRectTra.sizeDelta.x / 2 * localScale
        parentHeight = self.parentRectTra.sizeDelta.y / 2 * localScale

        pos.x = pos.x + parentWidth * 0.008
        pos.y = pos.y + parentHeight * 0.01
    else
        parentWidth = self.parentRectTra.sizeDelta.x
        parentHeight = self.parentRectTra.sizeDelta.y
    end

    --local parentRectTra = self.parent_node:GetComponent('RectTransform')

    local x = ScreenWidth / 2 + pos.x * 100 + parentWidth
    local y = pos.y * 100 - ScreenHeight / 2 - parentHeight
    local UITransform = LayerManager.Instance:GetLayerByName(LayerManager.LayerNameList.UI)
    self.transform:SetParent(UITransform)
    SetLocalScale(self.transform, 1, 1, 1)

    local width = self.modelbgRectTra.sizeDelta.x + self.viewRectTra.sizeDelta.x

    --判断是否超出右边界
    if ScreenWidth - (x + parentWidth + width) < 10 then
        if self.parentRectTra.anchorMin.x == 0.5 then
            x = x - width - parentWidth * 2 - 20
        else
            x = x - width - parentWidth
        end
    end
    --判断是否超出左边界
    if x - width < 10 then
        x = 10 + width
    end

    if ScreenHeight + y - self.viewRectTra.sizeDelta.y < 10 then
        spanY = ScreenHeight + y - self.viewRectTra.sizeDelta.y - 10
    end

    self.viewRectTra.anchoredPosition = Vector2(x + spanX, y - spanY)
end

function BaseModelTipView:DealContentHeight()
    if self.height < self.minScrollViewHeight then
        return self.minScrollViewHeight
    end
    
    if self.height > self.maxScrollViewHeight then
        return self.maxScrollViewHeight
    end
    
    return self.height  
end

function BaseModelTipView:DealCreateAttEnd()
    SetSizeDeltaY(self.contentRectTra, self.height)
    
    local srollViewY = self:DealContentHeight()
    SetSizeDeltaY(self.scrollViewRectTra, srollViewY)
    

    --[[local y = srollViewY + self.addValueTemp
    if y > self.maxViewHeight then
        y = self.maxViewHeight
    end
    self.viewRectTra.sizeDelta = Vector2(self.viewRectTra.sizeDelta.x, y)--]]
    --self.bgRectTra.sizeDelta = self.viewRectTra.sizeDelta
end
