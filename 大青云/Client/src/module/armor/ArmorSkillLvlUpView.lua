--[[
宝甲:技能升级面板
2015年1月30日10:22:40
haohu
]]

_G.UIArmorSkillLvlUp = BaseUI:new("UIArmorSkillLvlUp");

UIArmorSkillLvlUp.skillId = nil;

function UIArmorSkillLvlUp:Create()
	self:AddSWF( "armorSkillLvlUpPanel.swf", true, nil );
end

function UIArmorSkillLvlUp:OnLoaded( objSwf )
	objSwf.btnClose.click     = function() self:OnBtnCloseClick(); end
	objSwf.skillItem.rollOver = function(e) self:OnSkillRollOver(e); end
	objSwf.skillItem.rollOut  = function() self:OnSkillRollOut(); end
	objSwf.item.rollOver      = function(e) self:OnItemRollOver(e); end
	objSwf.item.rollOut       = function() self:OnItemRollOut(); end
	objSwf.btnLvlUp.click     = function() self:OnOnBtnLvlUpClick(); end
end

function UIArmorSkillLvlUp:OnShow()
	self:UpdateShow();
	self:UpdatePos();
end

function UIArmorSkillLvlUp:OnHide()
	self.skillId = nil;
	self.skillLvl = nil;
end

function UIArmorSkillLvlUp:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local skillId = self.skillId;
	local lvl = self:GetSkillLvl();
	local skillInfo = ArmorUtils:GetSkillListVO(skillId, lvl);
	-- 技能图标
	objSwf.skillItem:setData( UIData.encode(skillInfo) );
	-- 技能名字 技能等级
	local skillCfg = t_passiveskill[skillId]
	local color = TipsConsts:GetSkillQualityColor( skillCfg.quality )
	objSwf.txtName.htmlText = string.format( '<font color="%s">%s<font color="#00FF00">  LV%s</font></font>', color, skillInfo.name, lvl );
	-- 是否已学习
	local hasLearn = SkillModel:GetSkill(skillId) ~= nil;
	objSwf.txtLearn.textColor = hasLearn and 0x00FF00 or 0xFF0000;
	objSwf.txtLearn.text = hasLearn and StrConfig['armor016'] or StrConfig['armor017'];
	-- 升级/学习按钮
	objSwf.btnLvlUp.label = hasLearn and StrConfig['armor031'] or StrConfig['armor032']
	-- 技能升级条件
	if lvl == SkillUtil:GetSkillMaxLvl(skillId) then
		objSwf.txtCondition._visible = false;
		objSwf.item._visible         = false;
		objSwf.txtItemName._visible  = false;
		objSwf.txtItemNum._visible   = false;
		objSwf.maxLvlMC._visible     = true;
		return;
	end
	objSwf.txtCondition._visible = true;
	objSwf.item._visible         = true;
	objSwf.txtItemName._visible  = true;
	objSwf.txtItemNum._visible   = true;
	objSwf.maxLvlMC._visible     = false;
	local conditionList = SkillUtil:GetLvlUpConditionForSkill(skillId, not hasLearn);
	local specialCondition, basicCondition;
	for _, condition in pairs(conditionList) do
		if condition.type == 4 then -- 物品条件
			basicCondition = condition;
		elseif condition.type == 17 then -- 宝甲等阶条件
			specialCondition = condition;
		end
	end
	if specialCondition then
		local stateTxt = specialCondition.state and StrConfig['armor018'] or StrConfig['armor019'];
		local stateColor = specialCondition.state and "#00FF00" or "#FF0000";
		local conditionTitle = hasLearn and StrConfig['armor029'] or StrConfig['armor030']
		objSwf.txtCondition.htmlText = string.format( StrConfig['armor013'], conditionTitle, stateColor, specialCondition.num, stateTxt );
	end
	if basicCondition then
		local needItemList = RewardManager:Parse(basicCondition.id..","..basicCondition.num);
		objSwf.item:setData(needItemList[1]);
		local itemCfg = t_item[basicCondition.id];
		if not itemCfg then return end
		objSwf.txtItemName.textColor = TipsConsts:GetItemQualityColorVal( itemCfg.quality );
		objSwf.txtItemName.text = itemCfg.name;
		objSwf.txtItemNum.textColor = basicCondition.state and 0x00FF00 or 0xFF0000;
		objSwf.txtItemNum.text = basicCondition.currNum .. "/" .. basicCondition.num;
	end
end

function UIArmorSkillLvlUp:GetSkillLvl()
	local lvl;
	if self.skillLvl then
		lvl = self.skillLvl;
	else
		local skillCfg = t_passiveskill[self.skillId];
		lvl = skillCfg and skillCfg.level;
	end
	return lvl;
end

function UIArmorSkillLvlUp:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf._x = 0;
	objSwf._y = 0;
end

function UIArmorSkillLvlUp:OnSkillRollOver(e)
	local tipsType = TipsConsts.Type_Skill;
	local tipsShowType = TipsConsts.ShowType_Normal;
	local tipsDir = TipsConsts.Dir_RightDown;
	local tipsInfo = { skillId = self.skillId, condition = true, get = true };
	TipsManager:ShowTips( tipsType, tipsInfo, tipsShowType, tipsDir );
end

function UIArmorSkillLvlUp:OnSkillRollOut()
	TipsManager:Hide();
end

function UIArmorSkillLvlUp:OnItemRollOver(e)
	local itemId = e.target.data.id;
	TipsManager:ShowItemTips(itemId);
end

function UIArmorSkillLvlUp:OnItemRollOut()
	TipsManager:Hide();
end

function UIArmorSkillLvlUp:OnOnBtnLvlUpClick()
	local skillId = self.skillId;
	local lvl = self:GetSkillLvl();
	if lvl == SkillUtil:GetSkillMaxLvl(skillId) then
		FloatManager:AddNormal( StrConfig['armor025'] );
		return;
	end
	local hasLearn = SkillModel:GetSkill(skillId) ~= nil;
	local conditionList = SkillUtil:GetLvlUpConditionForSkill(skillId, not hasLearn);
	local specialCondition, basicCondition;
	for _, condition in pairs(conditionList) do
		if condition.type == 4 then -- 物品条件
			basicCondition = condition;
		elseif condition.type == 6 then -- 宝甲等阶条件
			specialCondition = condition;
		end
	end
	if basicCondition and not basicCondition.state then
		FloatManager:AddNormal( StrConfig['armor014'] );
		return;
	end
	if specialCondition and not specialCondition.state then
		FloatManager:AddNormal( StrConfig['armor015'] );
		return;
	end
	if not hasLearn then
		SkillController:LearnSkill(skillId)
	else
		SkillController:LvlUpSkill(skillId);
	end
end

function UIArmorSkillLvlUp:OnBtnCloseClick()
	self:Hide();
end

function UIArmorSkillLvlUp:Open(skillId, skillLvl)
	self.skillId = skillId;
	self.skillLvl = skillLvl;
	if self:IsShow() then
		self:UpdateShow();
	else
		self:Show();
	end
end


---------------------------消息处理---------------------------------
--监听消息列表
function UIArmorSkillLvlUp:ListNotificationInterests()
	return {
		NotifyConsts.ArmorLevelUp,
		NotifyConsts.SkillLearn,
		NotifyConsts.SkillLvlUp,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
	};
end

--处理消息
function UIArmorSkillLvlUp:HandleNotification(name, body)
	if name == NotifyConsts.ArmorLevelUp then
		self:UpdateShow();
	elseif name == NotifyConsts.SkillLearn then
		self:OnSkillLearn(body.skillId);
	elseif name == NotifyConsts.SkillLvlUp then
		self:OnSkillLvlUp(body.skillId, body.oldSkillId);
	elseif name == NotifyConsts.BagAdd or name == NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate then
		if body.type == BagConsts.BagType_Bag then
			self:UpdateShow();
		end
	end
end

function UIArmorSkillLvlUp:OnSkillLvlUp( skillId, oldSkillId )
	if self.skillId == oldSkillId then
		self.skillId = skillId;
		self.skillLvl = self.skillLvl + 1;
		self:UpdateShow();
	end
end

function UIArmorSkillLvlUp:OnSkillLearn( skillId )
	if self.skillId == skillId then
		self.skillLvl = 1;
		self:UpdateShow();
	end
end

