--[[
	新天神
]]

_G.UINewTianshenStar = BaseUI:new('UINewTianshenStar');

UINewTianshenStar.selectIndex = nil
function UINewTianshenStar:Create()
	self:AddSWF('newTianshenStar.swf',true,nil);
	self:AddChild(UINewTianshenStarUp,"starup")
	self:AddChild(UINewTianshenLvUp, "lvup")
end

function UINewTianshenStar:OnLoaded(objSwf)
	self:GetChild("starup"):SetContainer(objSwf.childPanel)
	self:GetChild('lvup'):SetContainer(objSwf.childPanel1)

	objSwf.starBtn.click = function()
		self:ShowChild("starup", nil, self.selectIndex)
	end
	objSwf.lvBtn.click = function()
		self:ShowChild("lvup", nil, self.selectIndex)
	end
	for i = 0, 5 do
		objSwf['fight' ..i].itemBtn.click = function()
			if NewTianshenModel:GetTianshenByFightSize(i) and self.selectIndex ~= i then
				self.selectIndex = i
				self:ShowLvUpInfo()
				self:DrawModel()
				for j = 0, 5 do
					if i ~= j then
						objSwf['fight' ..j].itemBtn.selected = false
					end
				end
			end
		end
		objSwf['fight' ..i].itemBtn.rollOver = function(e)
			local tianshen = NewTianshenModel:GetTianshenByFightSize(i)
			if not tianshen then return end
			TipsManager:ShowNewTianshenTips(tianshen)
		end
		objSwf['fight' ..i].itemBtn.rollOut = function(e)
			TipsManager:Hide()
		end
		objSwf['fight' ..i].itemBtn1.click = function()
			UINewTianshenBasic:OnPageBtnClick(1)
		end
	end
	objSwf.InitiativeSkill.itemRollOver = function(e) self:OnSkillRollOver(e); end
	objSwf.InitiativeSkill.itemRollOut = function() self:OnSkillRollOut(); end
	objSwf.PassivitySkill.itemRollOver = function(e) self:OnSkillRollOver(e); end
	objSwf.PassivitySkill.itemRollOut = function() self:OnSkillRollOut(); end

	objSwf.btnVipLvUp.click = function() UIVip:Show() end	
	objSwf.btnVipLvUp.rollOver = function(e) 
		local attMap = PublicUtil.GetVipShowPro(NewTianshenUtil:GetAllPro())
		VipController:ShowAttrTips( attMap, UIVipAttrTips.ts,VipConsts.TYPE_SUPREME)
	end
	objSwf.btnVipLvUp.rollOut = function(e) VipController:HideAttrTips() end

	objSwf.btnRules.rollOver =  function() TipsManager:ShowBtnTips(StrConfig["newtianshen202"],TipsConsts.Dir_RightDown); end
	objSwf.btnRules.rollOut = function(e) TipsManager:Hide(); end
end

function UINewTianshenStar:OnShow()
	self.selectIndex = self.args and self.args[1] or -2
	local tianshen = NewTianshenModel:GetTianshenByFightSize(self.selectIndex)
	if not tianshen then
		self.selectIndex = NewTianshenUtil:GetShowTianshenIndex()
	end
	self:ShowFightInfo()
	self:ShowLvUpInfo()
	self:DrawModel()
	self:RegisterTimes()
end

function UINewTianshenStar:OnSkillRollOver(e)
	TipsManager:ShowTips(TipsConsts.Type_Skill, { skillId = e.item.skillId }, TipsConsts.ShowType_Normal,
	TipsConsts.Dir_RightUp);
end

function UINewTianshenStar:OnSkillRollOut(e)
	TipsManager:Hide();
end

--这里设置选中天神的详细信息
function UINewTianshenStar:ShowLvUpInfo()
	self:ShowSkillInfo()
	self:ShowTianshenInfo()
end

function UINewTianshenStar:ShowTianshenInfo()
	local objSwf = self.objSwf
	if not objSwf then return end
	local tianshen = NewTianshenModel:GetTianshenByFightSize(self.selectIndex)
	-- objSwf.txt_name.htmlText = tianshen:GetHtmlName()
	if objSwf.icon1.source ~= tianshen:GetNameIcon() then
		objSwf.icon1.source = tianshen:GetNameIcon()
		objSwf.icon1.loaded = function()
			objSwf.icon1._x = 1150 - objSwf.icon1._width/2
		end
	end
	objSwf.txt_atttype.htmlText = tianshen:GetType()
	objSwf.txt_zizhi.htmlText = string.format("<font color = '%s'>%s</font>", TipsConsts:GetItemQualityColor(tianshen:GetShowQuality()), tianshen:GetZizhi())
	for i = 1, 10 do
		local star = tianshen:GetStar()
		if tianshen:GetMaxStar() < i then
			objSwf.star["graystar" ..i]._visible = false
			objSwf.star["star" ..i]._visible = false
		else
			if i <= star then
				objSwf.star["graystar" ..i]._visible = false
				objSwf.star["star" ..i]._visible = true
			else
				objSwf.star["graystar" ..i]._visible = true
				objSwf.star["star" ..i]._visible = false
			end
		end
	end
	--资质先不设置
	objSwf.txt_lv.htmlText = tianshen:GetLv() .. "级"
	local slot = {}
	for i=1, 8 do
		table.insert(slot, objSwf['txt_pro' ..i])
	end
	PublicUtil:ShowProInfoForUI(tianshen:GetPro(), slot, nil, nil, nil, true,nil,"#FFFFFF")
	if tianshen:IsMaxLv() then
		objSwf.lvBtn.disabled = true
		objSwf.lvBtn.label = UIStrConfig['newtianshen32']
	else
		objSwf.lvBtn.label = UIStrConfig['newtianshen25']
		objSwf.lvBtn.disabled = false
	end
	if tianshen:IsMaxStar() then
		objSwf.starBtn.disabled = true
		objSwf.starBtn.label = UIStrConfig['newtianshen33']
	else
		objSwf.starBtn.disabled = false
		objSwf.starBtn.label = UIStrConfig['newtianshen26']
	end
end

function UINewTianshenStar:ShowSkillInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local tianshen = NewTianshenModel:GetTianshenByFightSize(self.selectIndex)
	
    --被动技能
    local PassivitySkill = objSwf.PassivitySkill;
	PassivitySkill.dataProvider:cleanUp();
	local paskill = tianshen:GetPassSkill()
	for k, v in pairs(paskill) do
		local listVO = NewTianshenUtil:GetSkillListVO(v);
		PassivitySkill.dataProvider:push(UIData.encode(listVO));
	end
	PassivitySkill:invalidateData();

	--主动技能
	local list1 = tianshen:GetSkill()
	local InitiativeSkill = objSwf.InitiativeSkill;
	InitiativeSkill.dataProvider:cleanUp();
	for k, v in pairs(list1) do
		local listVO = NewTianshenUtil:GetSkillListVO(v);
		InitiativeSkill.dataProvider:push(UIData.encode(listVO));
	end
	InitiativeSkill:invalidateData();
end

function UINewTianshenStar:ShowFightInfo()
	local list = NewTianshenModel:GetFightList()
	local fight = 0
	for i = 0, 5 do
		self.objSwf['fight' ..i].txt_limitLv.htmlText = ""
		self.objSwf['fight' ..i].iconLock._visible = false
		self.objSwf['fight' ..i].txt_label.htmlText = ""
		if list[i] then
			if self.selectIndex == i then
				self.objSwf['fight' ..i].itemBtn.selected = true
			else
				self.objSwf['fight' ..i].itemBtn.selected = false
			end
			fight = list[i]:GetFightValue() + fight
			self.objSwf['fight' ..i].itemBtn._visible = true
		else
			self.objSwf['fight' ..i].itemBtn._visible = false
			local openLv = NewTianshenUtil:GetTianshenFightOpenLv(i)
			if MainPlayerModel.humanDetailInfo.eaLevel < openLv then
				self.objSwf['fight' ..i].txt_limitLv.htmlText = openLv .. StrConfig['newtianshen43']
				self.objSwf['fight' ..i].iconLock._visible = true
			else
				self.objSwf['fight' ..i].txt_label.htmlText = StrConfig['newtianshen44']
			end
		end
		NewTianshenUtil:SetTianshenSlot(self.objSwf['fight' ..i], list[i])
	end
	self.objSwf.fightLoader.num = fight
end

--模型展示
function UINewTianshenStar:DrawModel()
	local objSwf = self.objSwf;
	if not objSwf then return end 
	
	local tianshen = NewTianshenModel:GetTianshenByFightSize(self.selectIndex)
	if not tianshen then
		objSwf.icon._visible = false
		objSwf.iconName._visible = false
		return
	end
	objSwf.iconName._visible = true
	if objSwf.iconName.source ~= tianshen:GetMainNameIcon() then
		objSwf.iconName.source = tianshen:GetMainNameIcon()
	end
	objSwf.icon._visible = true
	objSwf.icon._x = -1200
	objSwf.icon._y = -600

	if not self.objUIDraw then
		local viewPort = _Vector2.new(4000, 2000)
		self.objUIDraw = UISceneDraw:new( "UINewTianshenStar", objSwf.icon, viewPort )
	else
		self.objUIDraw:SetUILoader(objSwf.icon)
	end
	self.objUIDraw:SetScene(tianshen:GetScene(), function() self:PlayAnimal() end)
	-- 模型旋转
	self.objUIDraw:SetDraw(true)
end

function UINewTianshenStar:PlayAnimal()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.objUIDraw then return end
	local tianshen = NewTianshenModel:GetTianshenByFightSize(self.selectIndex)
	if not tianshen then return end
	local cfg = t_bianshenmodel[tianshen:GetCfg().model]
	if not cfg then return end
	
	self.objUIDraw:NodeAnimation(cfg.skn_ui, cfg.bianshen_idle)
end

function UINewTianshenStar:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false)
	end
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil
	end
end

function UINewTianshenStar:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UINewTianshenStar:ListNotificationInterests()
	return {NotifyConsts.tianShenLvUpUpdata,NotifyConsts.tianShenStarUpUpdata}
end

function UINewTianshenStar:HandleNotification(name,body)
	self:ShowFightInfo()
	self:ShowLvUpInfo()
end

function UINewTianshenStar:InitSmithingRedPoint(  )
	local objSwf = self.objSwf
	if not objSwf then return end

	if NewTianshenUtil:IsCanStarUpBySize(self.selectIndex) then
		PublicUtil:SetRedPoint(objSwf.starBtn, nil, 1)
		objSwf.starBtn.pfx._visible = true
	else
		PublicUtil:SetRedPoint(objSwf.starBtn, nil, 0)
		objSwf.starBtn.pfx._visible = false
	end

	if NewTianshenUtil:IsCanLvupBySize(self.selectIndex) then
		PublicUtil:SetRedPoint(objSwf.lvBtn, nil, 1)
		objSwf.lvBtn.pfx._visible = true
	else
		PublicUtil:SetRedPoint(objSwf.lvBtn, nil, 0)
		objSwf.lvBtn.pfx._visible = false
	end
	for i = 0, 5 do
		if NewTianshenUtil:IsCanStarUpBySize(i) or NewTianshenUtil:IsCanLvupBySize(i) then
			PublicUtil:SetRedPoint(objSwf['fight' ..i], nil, 1, nil, nil, 90, 0)
		else
			PublicUtil:SetRedPoint(objSwf['fight' ..i], nil, 0, nil, nil, 90, 0)
		end
	end
end

function UINewTianshenStar:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil
	end
	self.timerKey = TimerManager:RegisterTimer(function()
		self:InitSmithingRedPoint()
	end,1000,0); 
	self:InitSmithingRedPoint()
end