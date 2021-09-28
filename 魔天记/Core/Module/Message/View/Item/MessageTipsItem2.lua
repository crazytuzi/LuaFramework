require "Core.Module.Message.View.Item.MessageItem"

local MessageTipsItem2 = class("MessageTipsItem2", MessageItem)
local MaxTime = 1.5
local AlphaTime = 0.3
local AlphaHideTime = MaxTime - AlphaTime -- 开始隐藏时间
local StartY = 0
local UpSpeed = 3

function MessageTipsItem2:_Init()
    self._widget = UIUtil.GetComponent(self._txtLabel, "UIWidget")
    self.gameObject = self.transform.gameObject
    self:Disable()
end

function MessageTipsItem2:UpdateShow(deltaTime)
    self._showTime = self._showTime + deltaTime

    self.y = self.y + UpSpeed
    Util.SetLocalPos(self.transform, 0, self.y, 0)
    -- Warning(self.gameObject.name .. '___' .. self.y ..'-'..self._showTime)
    if self._showTime <= AlphaTime then
        self._widget.alpha = self._widget.alpha +(deltaTime / AlphaTime)
    elseif self._showTime >= AlphaHideTime then
        self._widget.alpha = self._widget.alpha -(deltaTime / AlphaTime)
    end

    if self._showTime >= MaxTime then
        self:Disable()
    end
end

function MessageTipsItem2:_Enable()
    self.y = StartY
    Util.SetLocalPos(self.transform, 0, self.y, 0)
    self._widget.alpha = 0
    self._showTime = 0
    self.gameObject:SetActive(true)
end

function MessageTipsItem2:_Disable()
    self.gameObject:SetActive(false)
end

function MessageTipsItem2:_Show(data)
    self:Update(data)
end

--[[
function MessageTipsItem2:Fly(data)
	self:Show(data)
	LuaDOTween.DOKill(self.transform, false)
	local pos = self.oPos + Vector3(0, 45, 0)
	local comfun = DelegateFactory.DG_Tweening_TweenCallback(function() self:OnFlyEnd() end)
    LuaDOTween.OnComplete(LuaDOTween.DOLocalMove(self.transform, pos, 0.15), comfun)
end

function MessageTipsItem2:OnFlyEnd()
	self:Disable()
end
]]

return MessageTipsItem2