require "Core.Module.Message.View.Item.MessageItem";

MessageTipsItem = class("MessageTipsItem", MessageItem);

function MessageTipsItem:_Init()
	--self.oPos = self.transform.localPosition;
	self:Disable();
end

function MessageTipsItem:_Enable()
	--self.transform.localPosition = self.oPos;
	self.transform.gameObject:SetActive(true);
end

function MessageTipsItem:_Disable()
	self.transform.gameObject:SetActive(false);
end

function MessageTipsItem:_Show(data)
	self:Update(data);
end

--[[
function MessageTipsItem:Fly(data)
	self:Show(data);
	LuaDOTween.DOKill(self.transform, false);
	local pos = self.oPos + Vector3(0, 45, 0);
	local comfun = DelegateFactory.DG_Tweening_TweenCallback(function() self:OnFlyEnd() end);
    LuaDOTween.OnComplete(LuaDOTween.DOLocalMove(self.transform, pos, 0.15), comfun);
end

function MessageTipsItem:OnFlyEnd()
	self:Disable();
end
]]

