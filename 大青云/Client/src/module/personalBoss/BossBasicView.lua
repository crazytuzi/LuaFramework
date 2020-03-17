--[[
	2015年11月24日00:27:59
	BOSS
	wangyanwei
]]

_G.UIBossBasic = BaseUI:new('UIBossBasic');

--- 世界 地宫 野外 个人
s_showList = {FuncConsts.WorldBoss,FuncConsts.personalCaveBoss, FuncConsts.FieldBoss, FuncConsts.PersonalBoss,FuncConsts.PalaceBoss}

function UIBossBasic:Create()
	self:AddSWF("MainBossPanel.swf", true, "center");
	
	self:AddChild(UIWorldBoss,FuncConsts.WorldBoss);
	self:AddChild(UIFieldBoss,FuncConsts.FieldBoss);
	self:AddChild(UIPersonalBoss,FuncConsts.PersonalBoss);
	self:AddChild(UIPersonalCaveBoss,FuncConsts.personalCaveBoss);
    self:AddChild(UIPalaceBoss,FuncConsts.PalaceBoss);
end

function UIBossBasic:OnLoaded(objSwf)
	self:GetChild(FuncConsts.WorldBoss):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.personalCaveBoss):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.FieldBoss):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.PersonalBoss):SetContainer(objSwf.childPanel);
	self:GetChild(FuncConsts.PalaceBoss):SetContainer(objSwf.childPanel);
	--
	objSwf.btn_close.click = function () self:OnCloseClick(); end
	--
	for i = 1, 5 do
		objSwf["PageBtn" .. i].click = function()
			self:OnTabClickHandler(i)
		end
		if i~=1 and i ~=5 then
			objSwf['PageBtn' ..i].visible = false
		end
	end
end

function UIBossBasic:OnDelete()
	return true
end

function UIBossBasic:GetIndex(name)
	for k, v in pairs(s_showList) do
		if name == v then
			return k
		end
	end
end

function UIBossBasic:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return end

	self:OnTabClickHandler(self.args and self:GetIndex(self.args[1]) or 1);
end

--点击标签
function UIBossBasic:OnTabClickHandler(nIndex)
	local objSwf = self.objSwf;
	if not objSwf then return end
	local name = s_showList[nIndex]
	if not name then return end

	local child = self:GetChild(name);
	if not child then
		return
	end
	objSwf['PageBtn' .. nIndex].selected = true
	
	self:ShowChild(name)
end

--关闭按钮
function UIBossBasic:OnCloseClick()
	self:Hide();
end

function UIBossBasic:OnHide()
	
end

function UIBossBasic:GetWidth()
	return 1060
end

function UIBossBasic:GetHeight()
	return 678
end

--父面板处理↓↓↓↓↓↓↓↓↓↓↓

function UIBossBasic:IsTween()
	return true;
end

function UIBossBasic:WithRes()
	return {"personalCavebossPanel.swf"};
end

function UIBossBasic:IsShowSound()
	return true;
end

function UIBossBasic:GetPanelType()
	return 1;
end

function UIBossBasic:IsShowLoading()
	return true;
end