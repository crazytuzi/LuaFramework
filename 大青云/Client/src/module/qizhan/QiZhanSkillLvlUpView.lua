--[[
骑战:技能升级面板

]]

_G.UIQiZhanSkillLvlUp = BaseUI:new("UIQiZhanSkillLvlUp");

UIQiZhanSkillLvlUp.skillId = nil;

function UIQiZhanSkillLvlUp:Create()
	self:AddSWF( "qizhanSkillLvlUpPanel.swf", true, nil );
end

function UIQiZhanSkillLvlUp:OnLoaded( objSwf )
	objSwf.btnClose.click     = function() self:OnBtnCloseClick(); end
	objSwf.skillItem.rollOver = function(e) self:OnSkillRollOver(e); end
	objSwf.skillItem.rollOut  = function() self:OnSkillRollOut(); end
	objSwf.item.rollOver      = function(e) self:OnItemRollOver(e); end
	objSwf.item.rollOut       = function() self:OnItemRollOut(); end
	objSwf.btnLvlUp.click     = function() self:OnOnBtnLvlUpClick(); end
end

function UIQiZhanSkillLvlUp:OnShow()
	self:UpdateShow();
	self:UpdatePos();
end

function UIQiZhanSkillLvlUp:OnHide()
	self.skillId = nil;
	self.skillLvl = nil;
end

function UIQiZhanSkillLvlUp:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local skillId = self.skillId;
	local lvl = self:GetSkillLvl();
	local skillInfo = QiZhanUtils:GetSkillListVO(skillId, lvl);
	-- 技能图标
	objSwf.skillItem:setData( UIData.encode(skillInfo) );
	-- 技能名字 技能等级
	local skillCfg = t_passiveskill[skillId]
	if not skillCfg then
		skillCfg = t_skill[skillId]
	end
	local color = TipsConsts:GetSkillQualityColor( skillCfg.quality )
	local showlv = lvl == 0 and 1 or lvl
	objSwf.txtName.htmlText = string.format( '<font color="%s">%s<font color="#2fe00d">  LV%s</font></font>', color, skillInfo.name, showlv );
	-- 是否已学习
	local hasLearn = SkillModel:GetSkill(skillId) ~= nil;
	objSwf.txtLearn.textColor = hasLearn and 0x00ff00 or 0xff0000;
	objSwf.txtLearn.text = hasLearn and StrConfig['lingzhen016'] or StrConfig['lingzhen017'];
	objSwf.btnLvlUp.labelID = hasLearn and 'lingzhen3' or 'lingzhen2'
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
		elseif condition.type == 10 then -- 骑战等阶条件
			specialCondition = condition;
		end
	end
	if specialCondition then
		local stateTxt = specialCondition.state and StrConfig['lingzhen018'] or StrConfig['lingzhen019'];
		local stateColor = specialCondition.state and "#00ff00" or "#ff0000";
		-- FPrint(StrConfig['lingzhen013'])
		objSwf.txtCondition.htmlText = string.format( StrConfig['lingzhen013'], stateColor, specialCondition.num, stateTxt );
	end
	if basicCondition then
		local needItemList = RewardManager:Parse(basicCondition.id..",0");
		objSwf.item:setData(needItemList[1]);
		local itemCfg = t_item[basicCondition.id];
		if not itemCfg then return end
		objSwf.txtItemName.textColor = TipsConsts:GetItemQualityColorVal( itemCfg.quality );
		objSwf.txtItemName.text = ''
		if itemCfg.name then
			objSwf.txtItemName.text = itemCfg.name;
		end
		objSwf.txtItemNum.textColor = basicCondition.state and 0x00ff00 or 0xff0000;
		objSwf.txtItemNum.text = ''
		if basicCondition.currNum and basicCondition.num then
			objSwf.txtItemNum.text = basicCondition.currNum .. "/" .. basicCondition.num;
		end
	end
end

function UIQiZhanSkillLvlUp:GetSkillLvl()
	local lvl;
	if self.skillLvl then
		lvl = self.skillLvl;
	else
		local skillCfg = t_passiveskill[self.skillId];
		lvl = skillCfg and skillCfg.level;
	end
	return lvl;
end

function UIQiZhanSkillLvlUp:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf._x = 0;
	objSwf._y = 0;
end

function UIQiZhanSkillLvlUp:OnSkillRollOver(e)
	local tipsType = TipsConsts.Type_Skill;
	local tipsShowType = TipsConsts.ShowType_Normal;
	local tipsDir = TipsConsts.Dir_RightDown;
	local tipsInfo = { skillId = self.skillId, condition = true, get = true };
	
	TipsManager:ShowTips( tipsType, tipsInfo, tipsShowType, tipsDir );
end

function UIQiZhanSkillLvlUp:OnSkillRollOut()
	TipsManager:Hide();
end

function UIQiZhanSkillLvlUp:OnItemRollOver(e)
	local itemId = e.target.data.id;
	TipsManager:ShowItemTips(itemId);
end

function UIQiZhanSkillLvlUp:OnItemRollOut()
	TipsManager:Hide();
end

function UIQiZhanSkillLvlUp:OnOnBtnLvlUpClick()
	local skillId = self.skillId;
	local lvl = self:GetSkillLvl();
	if lvl == SkillUtil:GetSkillMaxLvl(skillId) then
		FloatManager:AddNormal( StrConfig['lingzhen022'] );
		return;
	end
	local hasLearn = SkillModel:GetSkill(skillId) ~= nil;
	local conditionList = SkillUtil:GetLvlUpConditionForSkill(skillId, not hasLearn);
	local specialCondition, basicCondition;
	for _, condition in pairs(conditionList) do
		if condition.type == 4 then -- 物品条件
			basicCondition = condition;
		elseif condition.type == 10 then -- 骑战等阶条件
			specialCondition = condition;
		end
	end
	if basicCondition and not basicCondition.state then
		FloatManager:AddNormal( StrConfig['lingzhen014'] );
		return;
	end
	if specialCondition and not specialCondition.state then
		FloatManager:AddNormal( StrConfig['qizhan2'] );
		return;
	end
	if not hasLearn then
		SkillController:LearnSkill(skillId)
	else
		SkillController:LvlUpSkill(skillId);
	end
end

function UIQiZhanSkillLvlUp:OnBtnCloseClick()
	self:Hide();
end

function UIQiZhanSkillLvlUp:Open(skillId, skillLvl)
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
function UIQiZhanSkillLvlUp:ListNotificationInterests()
	return {
		NotifyConsts.QiZhanUpdate,
		NotifyConsts.SkillLearn,
		NotifyConsts.SkillLvlUp,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
	};
end

--处理消息
function UIQiZhanSkillLvlUp:HandleNotification(name, body)
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return; end
	if name == NotifyConsts.QiZhanUpdate then
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

function UIQiZhanSkillLvlUp:OnSkillLvlUp( skillId, oldSkillId )
	if self.skillId == oldSkillId then
		self.skillId = skillId;
		self.skillLvl = self.skillLvl + 1;
		self:UpdateShow();
	end
end

function UIQiZhanSkillLvlUp:OnSkillLearn( skillId )
	if self.skillId == skillId then
		self.skillLvl = 1;
		self:UpdateShow();
	end
end

