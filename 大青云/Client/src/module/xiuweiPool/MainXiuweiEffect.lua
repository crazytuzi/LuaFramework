
_G.UIXiuweiEffectView = BaseUI:new("UIXiuweiEffectView");

function UIXiuweiEffectView:Create()
	self:AddSWF("mainXiuweiEffect.swf", false, "highTop");
end
function UIXiuweiEffectView:OnShow()
	local objSwf = self.objSwf
	if not objSwf then return; end
	self:SetPos()
	self:ShowNext()
end

function UIXiuweiEffectView:SetPos()
	local objSwf = self.objSwf
	if not objSwf then return end

	local winW,winH = UIManager:GetWinSize();

	objSwf._width = winW*(109/1920)
	objSwf._height = winH*(97/1018)
end
function UIXiuweiEffectView:ShowNext()
	if self.timeKey then
		self:UnRegisterTimer()
	end
	self.timeKey = TimerManager:RegisterTimer(function()
		self:Hide()
	end,1000,1);
end

function UIXiuweiEffectView:UnRegisterTimer()
	TimerManager:UnRegisterTimer(self.timeKey)
	self.timeKey = nil
end

function UIXiuweiEffectView:OnHide()
	self:UnRegisterTimer()
end