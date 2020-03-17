--[[
神武:技能升级面板
2016年1月5日09:59:28
haohu
]]

_G.UIShenWuSkillLvlUp = BaseUI:new("UIShenWuSkillLvlUp")

UIShenWuSkillLvlUp.skillId = nil

function UIShenWuSkillLvlUp:Create()
	self:AddSWF( "shenWuSkillLvlUpPanel.swf", true, nil )
end

function UIShenWuSkillLvlUp:OnLoaded( objSwf )
	objSwf.btnClose.click     = function() self:OnBtnCloseClick(); end
	objSwf.skillItem.rollOver = function(e) self:OnSkillRollOver(e); end
	objSwf.skillItem.rollOut  = function() self:OnSkillRollOut(); end
	objSwf.item.rollOver      = function(e) self:OnItemRollOver(e); end
	objSwf.item.rollOut       = function() self:OnItemRollOut(); end
	objSwf.btnLvlUp.click     = function() self:OnOnBtnLvlUpClick(); end
end

function UIShenWuSkillLvlUp:OnShow()
	self:UpdateShow();
	self:UpdatePos();
end

function UIShenWuSkillLvlUp:OnHide()
	self.skillId = nil;
	self.skillLvl = nil;
end

function UIShenWuSkillLvlUp:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local skillId = self.skillId;
	local lvl = self:GetSkillLvl();
	local skillInfo = ShenWuUtils:GetSkillListVO(skillId, lvl);
	-- 技能图标
	objSwf.skillItem:setData( UIData.encode(skillInfo) );
	-- 技能名字 技能等级
	local skillCfg = t_passiveskill[skillId]
	local color = TipsConsts:GetSkillQualityColor( skillCfg.quality )
	objSwf.txtName.htmlText = string.format( '<font color="%s">%s<font color="#00FF00">  LV%s</font></font>', color, skillInfo.name, lvl );
	-- 是否已学习
	local hasLearn = SkillModel:GetSkill(skillId) ~= nil;
	objSwf.txtLearn.textColor = hasLearn and 0x00FF00 or 0xFF0000;
	objSwf.txtLearn.text = hasLearn and StrConfig['magicWeapon016'] or StrConfig['magicWeapon017']; -- ok
	-- 升级/学习按钮
	objSwf.btnLvlUp.label = hasLearn and StrConfig['magicWeapon031'] or StrConfig['magicWeapon032'] -- ok
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
		elseif condition.type == 14 then -- 神w等阶条件
			specialCondition = condition;
		end
	end

	if specialCondition then
		local stateTxt = specialCondition.state and StrConfig['magicWeapon018'] or StrConfig['magicWeapon019']; --o,
		local stateColor = specialCondition.state and "#00FF00" or "#FF0000";
		local conditionTitle = hasLearn and StrConfig['magicWeapon029'] or StrConfig['magicWeapon030'] -- ok
		objSwf.txtCondition.htmlText = string.format( StrConfig['magicWeapon013'], conditionTitle, stateColor, specialCondition.num, stateTxt );
	end -- ok
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

function UIShenWuSkillLvlUp:GetSkillLvl()
	local lvl;
	if self.skillLvl then
		lvl = self.skillLvl;
	else
		local skillCfg = t_passiveskill[self.skillId];
		lvl = skillCfg and skillCfg.level;
	end
	return lvl;
end

function UIShenWuSkillLvlUp:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf._x = 0;
	objSwf._y = 0;
end

function UIShenWuSkillLvlUp:OnSkillRollOver(e)
	local tipsInfo = { skillId = self.skillId, condition = true, get = true };
	TipsManager:ShowTips( TipsConsts.Type_Skill, tipsInfo, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end

function UIShenWuSkillLvlUp:OnSkillRollOut()
	TipsManager:Hide();
end

function UIShenWuSkillLvlUp:OnItemRollOver(e)
	local itemId = e.target.data.id;
	TipsManager:ShowItemTips(itemId);
end

function UIShenWuSkillLvlUp:OnItemRollOut()
	TipsManager:Hide();
end

function UIShenWuSkillLvlUp:OnOnBtnLvlUpClick()
	local skillId = self.skillId;
	local lvl = self:GetSkillLvl();
	if lvl == SkillUtil:GetSkillMaxLvl(skillId) then
		FloatManager:AddNormal( StrConfig['magicWeapon025'] );
		return;
	end
	local hasLearn = SkillModel:GetSkill(skillId) ~= nil;
	local conditionList = SkillUtil:GetLvlUpConditionForSkill(skillId, not hasLearn);
	local specialCondition, basicCondition;
	for _, condition in pairs(conditionList) do
		if condition.type == 4 then -- 物品条件
			basicCondition = condition;
		elseif condition.type == 14 then -- 神w等阶条件
			specialCondition = condition;
		end
	end
	if basicCondition and not basicCondition.state then
		FloatManager:AddNormal( StrConfig['magicWeapon014'] ); -- ok
		return;
	end
	if specialCondition and not specialCondition.state then
		FloatManager:AddNormal( StrConfig['shenwu21'] );
		return;
	end
	if not hasLearn then
		SkillController:LearnSkill(skillId)
	else
		SkillController:LvlUpSkill(skillId);
	end
end

function UIShenWuSkillLvlUp:OnBtnCloseClick()
	self:Hide();
end

function UIShenWuSkillLvlUp:Open(skillId, skillLvl)
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
function UIShenWuSkillLvlUp:ListNotificationInterests()
	return {
		NotifyConsts.ShenWuLevel,
		NotifyConsts.SkillLearn,
		NotifyConsts.SkillLvlUp,
		NotifyConsts.BagItemNumChange,
	};
end

--处理消息
function UIShenWuSkillLvlUp:HandleNotification(name, body)
	if name == NotifyConsts.ShenWuLevel then
		self:UpdateShow();
	elseif name == NotifyConsts.SkillLearn then
		self:OnSkillLearn(body.skillId);
	elseif name == NotifyConsts.SkillLvlUp then
		self:OnSkillLvlUp(body.skillId, body.oldSkillId);
	elseif name == NotifyConsts.BagItemNumChange then
		self:UpdateShow();
	end
end

function UIShenWuSkillLvlUp:OnSkillLvlUp( skillId, oldSkillId )
	if self.skillId == oldSkillId then
		FloatManager:AddNormal(StrConfig["shenwu28"]);
		self.skillId = skillId;
		self.skillLvl = self.skillLvl + 1;
		self:UpdateShow();
	end
end

function UIShenWuSkillLvlUp:OnSkillLearn( skillId )
	if self.skillId == skillId then
		FloatManager:AddNormal(StrConfig["shenwu27"]);
		self.skillLvl = 1;
		self:UpdateShow();
	end
end

