_G.UIShampublicity = BaseUI:new("UIShampublicity");

function UIShampublicity:Create()
	self:AddSWF("ShampublicityV.swf",true,"loading");
end

function UIShampublicity:OnLoaded(objSwf)
	objSwf.txt._width = ShampublicConsts.width
	objSwf.txt._height = ShampublicConsts.height
	return
end

function UIShampublicity:OnShow()
	self:Resize()
	self:ShowText()
	self:StartTimer()
end

function UIShampublicity:ShowText()
	local objSwf = self.objSwf
	if not objSwf then return end
	self:Top()
	objSwf.txt.htmlText = ShampublicityModel:GetStr()
end

function UIShampublicity:Resize()
	local objSwf = self.objSwf
	if not objSwf then return end

	local nType = ShampublicityModel:GetShampublicity()
	local winW,winH = UIManager:GetWinSize()
	if nType ~= 1 then
		--左下角
		self:SetPos(ShampublicConsts.x1, winH - ShampublicConsts.y1)
	else
		--右上角
		self:SetPos(winW - ShampublicConsts.x2, ShampublicConsts.y2)
	end
end

function UIShampublicity:OnResize()
	self:Resize()
end

function UIShampublicity:StartTimer()
	if self.timeKey then
		return
	end
	self.timeKey = TimerManager:RegisterTimer(function() self:ShowText() end,ShampublicConsts.time,0)
end

function UIShampublicity:OnHide()
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey)
	end
end