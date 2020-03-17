--[[
	新天神
]]

_G.UINewTianshenBasic = BaseUI:new('UINewTianshenBasic');

UINewTianshenBasic.showPage = 1

local s_showIndex = {"main", "star", "resolve"}
function UINewTianshenBasic:Create()
	self:AddSWF("newTianshenPanel.swf", true, "center");
	
	self:AddChild(UINewTianshenMain,s_showIndex[1])
	self:AddChild(UINewTianshenStar,s_showIndex[2])
	self:AddChild(UINewTianshenResolve,s_showIndex[3])
end

function UINewTianshenBasic:OnLoaded(objSwf)
	for i = 1, 3 do
		self:GetChild(s_showIndex[i]):SetContainer(objSwf.childPanel)
	end
	objSwf.btnClose.click = function() self:Hide() end
	for i = 1, 3 do
		objSwf['pageBtn' ..i].click = function()
			if self.showPage == i then
				return
			end
			self:OnPageBtnClick(i)
		end
		if i == 3 then
			objSwf.pageBtn3._visible = false
		end
	end
end

function UINewTianshenBasic:OnResize()
	local objSwf = self.objSwf
	if not objSwf then return end

	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.btnClose._x = math.min( math.max( wWidth - 50, 1410), 1500)
	self:ShowMask();
end

function UINewTianshenBasic:ShowMask()
	local objSwf = self.objSwf
	local x,y = self:GetPos();
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf.mask._x = -x;
	objSwf.mask._y = -y;
	objSwf.mask._width = wWidth;
	objSwf.mask._height = wHeight;
end

function UINewTianshenBasic:OnShow()
	if self.args and self.args[1] == true then
		self.showPage = 1
	else
		self:CheckStarLvUp()
	end
	
	self:OnPageBtnClick(self.showPage)
	self:OnShowPageBtn()
	self:RegisterTimes()
	self:OnResize()
end

function UINewTianshenBasic:CheckStarLvUp()
	if NewTianshenUtil:IsHaveTianshenCanFight() then
		self.showPage = 1
	elseif NewTianshenUtil:IsHaveTianshenCanLvUp() or NewTianshenUtil:IsHaveTianshenCanStarUp() then
		self.showPage = 2
	else
		self.showPage = 1
	end
end

function UINewTianshenBasic:OnHide()
	self.showPage = 1
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil
	end
end

function UINewTianshenBasic:GetWidth()
	return 1700
end

function UINewTianshenBasic:GetHeight()
	return 1000
end

function UINewTianshenBasic:OnShowPageBtn()
	if not NewTianshenModel:IsHaveTianshenFight() then
		self.objSwf.pageBtn2._visible = false
		self.objSwf.pageBtn3._x = self.objSwf.pageBtn2._x
	else
		self.objSwf.pageBtn2._visible = true
		self.objSwf.pageBtn3._x = 350
	end
end

function UINewTianshenBasic:OnPageBtnClick(index, pos)
	if not self:IsShow() then
		return
	end
	self.showPage = index
	self.objSwf['pageBtn' ..self.showPage].selected = true
	self:ShowChild(s_showIndex[index], nil, pos);
end

function UINewTianshenBasic:IsTween()
	return true;
end

function UINewTianshenBasic:GetPanelType()
	return 1;
end

function UINewTianshenBasic:IsShowSound()
	return true;
end

function UINewTianshenBasic:HandleNotification(name,body)
	self:OnShowPageBtn()
end

function UINewTianshenBasic:ListNotificationInterests()
	return {NotifyConsts.tianShenOutUpdata}
end

function UINewTianshenBasic:InitSmithingRedPoint(  )
	local objSwf = self.objSwf
	if not objSwf then return end
	
	if NewTianshenUtil:IsHaveTianshenCanStarUp() or NewTianshenUtil:IsHaveTianshenCanLvUp() then
		PublicUtil:SetRedPoint(objSwf.pageBtn2, nil, 1)
	else
		PublicUtil:SetRedPoint(objSwf.pageBtn2, nil, 0)
	end
end

function UINewTianshenBasic:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil
	end
	self.timerKey = TimerManager:RegisterTimer(function()
		self:InitSmithingRedPoint()
	end,1000,0); 
	self:InitSmithingRedPoint()
end