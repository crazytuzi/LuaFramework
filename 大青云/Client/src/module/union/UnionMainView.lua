--[[
帮派:主面板
liyuan
2014年9月24日16:22:09
]]


_G.UIUnion = BaseUI:new("UIUnion")

UIUnion.tabButton = {}

function UIUnion:Create()
	self:AddSWF("unionMainPanel.swf", true, "center")

	self:AddChild(UIUnionInfo,         UnionConsts.TabUnionInfo)  --帮派信息
	self:AddChild(UIUnionMember,       UnionConsts.TabUnionMember)
	--self:AddChild(UIUnionPlayerNearby, UnionConsts.TabUnionActive)
	self:AddChild(UIUnionList, UnionConsts.TabUnionList)
	self:AddChild(UIDiplomacyPanel, UnionConsts.TabUnionDip)
	self:AddChild(UIUnionDungeonMain, UnionConsts.TabUnionDungeon)
	self:AddChild(UIUnionWareHouse, UnionConsts.TabUnionWarehouse)
end

function UIUnion:WithRes()
	return {"unionInfoPanel.swf"}
end

function UIUnion:IsTween()
	return true;
end

function UIUnion:GetPanelType()
	return 1;
end

function UIUnion:OnLoaded(objSwf, name)
	-- set child panel
	-- 资源id
	UnionConsts.QingtongTokenId = t_consts[11].val1							
	UnionConsts.BaiyingTokenId = t_consts[12].val1
	UnionConsts.HuangjinTokenId = t_consts[13].val1
	UnionConsts.MoneyId = toint(t_consts[14].val1)
	-- 资源获得帮派贡献数
	UnionConsts.QingtongTokenContribution = t_consts[11].val2							
	UnionConsts.BaiyingTokenContribution = t_consts[12].val2
	UnionConsts.HuangjinTokenContribution = t_consts[13].val2
	-- 银两
	UnionConsts.MoneyNeed = toint(t_consts[14].val3)
	UnionConsts.MoneyContribution = t_consts[14].val2
	UnionConsts.MoneyUnionMoney = t_consts[14].val3
	UnionConsts.ContrbutionList = split(t_consts[14].param, ',')
	UnionConsts.AutoAgreeList = split(t_consts[18].param, ',')
	
	self:GetChild(UnionConsts.TabUnionInfo):SetContainer(objSwf.childPanel)
	self:GetChild(UnionConsts.TabUnionMember):SetContainer(objSwf.childPanel)
	 --self:GetChild(UnionConsts.TabUnionActive):SetContainer(objSwf.childPanel)
	self:GetChild(UnionConsts.TabUnionList):SetContainer(objSwf.childPanel)
	self:GetChild(UnionConsts.TabUnionDip):SetContainer(objSwf.childPanel)
	self:GetChild(UnionConsts.TabUnionDungeon):SetContainer(objSwf.childPanel)
	
	self:GetChild(UnionConsts.TabUnionWarehouse):SetContainer(objSwf.childPanel)
	--tab button 
	self.tabButton[UnionConsts.TabUnionInfo] = objSwf.btnUnionInfo
	self.tabButton[UnionConsts.TabUnionMember] = objSwf.btnMember
	 self.tabButton[UnionConsts.TabUnionActive] = objSwf.btnUnionActivity
	self.tabButton[UnionConsts.TabUnionList] = objSwf.btnUnionList
	 -- self.tabButton[UnionConsts.TabUnionDip] = objSwf.btnUnionDip
	-- objSwf.btnUnionDip.disabled = true;
	 self.tabButton[UnionConsts.TabUnionDungeon] = objSwf.btnUnionDungeon
	self.tabButton[UnionConsts.TabUnionWarehouse] = objSwf.btnUnionWareHouse
	for btnName, btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(btnName) end
	end
	--close button
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
end

function UIUnion:OnDelete()
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

function UIUnion:OnHide()

	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil;
	end

	UIUnionAidPanel:Hide()
	--是否有组队提示
	TeamUtils:UnRegisterNotice(self:GetName())

	
end

function UIUnion:OnShow(name)
	self:TurnToSubpanel( self:GetFirstTab() )
	self:InitRedPoint()
	self:RegisterTimes()
end

-- 帮派有新队员申请
--adder:houxudong
--date:2016/8/1 11:54:12
UIUnion.timerKey = nil;
function UIUnion:RegisterTimes()
	self.timerKey = TimerManager:RegisterTimer(function()
		self:InitRedPoint()
	end,1000,0); 
end

function UIUnion:InitRedPoint()
	local objSwf = self.objSwf
	if not objSwf then return; end
	local isNewApply,applayNum = UnionUtils:CheckJoinNewpattern()
	--新的队员申请
	if isNewApply then
		PublicUtil:SetRedPoint(objSwf.btnMember, RedPointConst.showNum , applayNum)
	else
		PublicUtil:SetRedPoint(objSwf.btnMember, RedPointConst.showNum , 0)
	end

	--帮派升级
	if UnionUtils:CheckCanUnionLvUp( ) then
		PublicUtil:SetRedPoint(objSwf.btnUnionInfo, nil, 1)
	else
		PublicUtil:SetRedPoint(objSwf.btnUnionInfo, nil, 0)
	end
end

function UIUnion:SetSwf()

end

function UIUnion:GetWidth(name)
	return 1080
end

function UIUnion:GetHeight(name)
	return 731
end

function UIUnion:OnTabButtonClick(btnName)
	self:TurnToSubpanel(btnName)
	-- 在帮派活动子界面显示时点击左侧帮派活动页签，切到帮派活动主界面
	if btnName == UnionConsts.TabUnionDungeon and UIUnionDungeonMain:IsShow() then
		UIUnionDungeonMain:InitShow();
	end
end

function UIUnion:TurnToSubpanel(panelName)
	local tabBtn = self.tabButton[panelName]
	if tabBtn then
		tabBtn.selected = true
		local child = self:GetChild(panelName)
		if child and not child:IsShow() then
			self:ShowChild(panelName)
		end
		UIUnionSkill:Hide()
	end
end

function UIUnion:OnBtnCloseClick()
	self:Hide()
	UIUnionContributionPanel:Hide()
	UIUnionAidPanel:Hide()
end

function UIUnion:GetFirstTab()
	if self.firstTab then
		local tab = self.firstTab;
		self.firstTab = nil; --确保仅生效一次
		return tab;
	end
	return UnionConsts.TabUnionInfo;
end
--面板类型
function UIUnion:GetPanelType()
	return 1;
end
-- 生效一次后失效
function UIUnion:SetFirstTab( panelName )
	self.firstTab = panelName;
end

function UIUnion:IsShowSound()
	return true;
end

function UIUnion:IsShowLoading()
	return true;
end