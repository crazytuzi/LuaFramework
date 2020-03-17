--[[
宝甲:技能升级面板
2015年4月28日17:12:38
zhangshuhui
]]

_G.UIBaoJiaSkillLvlUp = BaseUI:new("UIBaoJiaSkillLvlUp");

UIBaoJiaSkillLvlUp.skillId = nil;

function UIBaoJiaSkillLvlUp:Create()
	self:AddSWF( "baojiaSkillLvlUpPanel.swf", true, nil );
end

function UIBaoJiaSkillLvlUp:OnLoaded( objSwf )
	objSwf.btnClose.click     = function() self:OnBtnCloseClick(); end
	objSwf.skillItem.rollOver = function(e) self:OnSkillRollOver(e); end
	objSwf.skillItem.rollOut  = function() self:OnSkillRollOut(); end
	objSwf.item.rollOver      = function(e) self:OnItemRollOver(e); end
	objSwf.item.rollOut       = function() self:OnItemRollOut(); end
	objSwf.btnLvlUp.click     = function() self:OnOnBtnLvlUpClick(); end
end

function UIBaoJiaSkillLvlUp:OnShow()
	self:UpdateShow();
	self:UpdatePos();
end

function UIBaoJiaSkillLvlUp:OnHide()
	self.skillId = nil;
	self.skillLvl = nil;
end

function UIBaoJiaSkillLvlUp:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local skillId = self.skillId;
	local lvl = self:GetSkillLvl();
	local skillInfo = BaoJiaUtils:GetSkillListVO(skillId, lvl);
	-- 技能图标
	objSwf.skillItem:setData( UIData.encode(skillInfo) );
	-- 技能名字
	objSwf.txtName.text = skillInfo.name;
	-- 技能等级
	objSwf.txtLvl.text = "LV"..lvl;
	-- 是否已学习
	local hasLearn = SkillModel:GetSkill(skillId) ~= nil;
	objSwf.txtLearn.textColor = hasLearn and 0x29cc00 or 0xcc0000;
	objSwf.txtLearn.text = hasLearn and StrConfig['baojia016'] or StrConfig['baojia017'];
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
	local conditionList = SkillUtil:GetLvlUpCondition(skillId, not hasLearn);
	local specialCondition, basicCondition;
	for _, condition in pairs(conditionList) do
		if condition.type == 4 then -- 物品条件
			basicCondition = condition;
		elseif condition.type == 6 then -- 神兵等阶条件
			specialCondition = condition;
		end
	end
	if specialCondition then
		local stateTxt = specialCondition.state and StrConfig['baojia018'] or StrConfig['baojia019'];
		local stateColor = specialCondition.state and "#29cc00" or "#cc0000";
		objSwf.txtCondition.htmlText = string.format( StrConfig['baojia013'], stateColor, specialCondition.num, stateTxt );
	end
	if basicCondition then
		local needItemList = RewardManager:Parse(basicCondition.id..","..basicCondition.num);
		objSwf.item:setData(needItemList[1]);
		local itemCfg = t_item[basicCondition.id];
		objSwf.txtItemName.text = itemCfg and itemCfg.name;
		objSwf.txtItemNum.textColor = basicCondition.state and 0x29cc00 or 0xcc0000;
		objSwf.txtItemNum.text = basicCondition.currNum .. "/" .. basicCondition.num;
	end
end

function UIBaoJiaSkillLvlUp:GetSkillLvl()
	local lvl;
	if self.skillLvl then
		lvl = self.skillLvl;
	else
		local skillCfg = t_passiveskill[self.skillId];
		lvl = skillCfg and skillCfg.level;
	end
	return lvl;
end

function UIBaoJiaSkillLvlUp:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf._x = 0;
	objSwf._y = 0;
end

function UIBaoJiaSkillLvlUp:OnSkillRollOver(e)
	local tipsType = TipsConsts.Type_Skill;
	local tipsShowType = TipsConsts.ShowType_Normal;
	local tipsDir = TipsConsts.Dir_RightDown;
	local tipsInfo = { skillId = self.skillId, condition = true, get = true };
	TipsManager:ShowTips( tipsType, tipsInfo, tipsShowType, tipsDir );
end

function UIBaoJiaSkillLvlUp:OnSkillRollOut()
	TipsManager:Hide();
end

function UIBaoJiaSkillLvlUp:OnItemRollOver(e)
	local itemId = e.target.data.id;
	TipsManager:ShowItemTips(itemId);
end

function UIBaoJiaSkillLvlUp:OnItemRollOut()
	TipsManager:Hide();
end

function UIBaoJiaSkillLvlUp:OnOnBtnLvlUpClick()
	local skillId = self.skillId;
	local lvl = self:GetSkillLvl();
	if lvl == SkillUtil:GetSkillMaxLvl(skillId) then
		FloatManager:AddNormal( StrConfig['baojia025'] );
		return;
	end
	local hasLearn = SkillModel:GetSkill(skillId) ~= nil;
	local conditionList = SkillUtil:GetLvlUpCondition(skillId, not hasLearn);
	local specialCondition, basicCondition;
	for _, condition in pairs(conditionList) do
		if condition.type == 4 then -- 物品条件
			basicCondition = condition;
		elseif condition.type == 6 then -- 神兵等阶条件
			specialCondition = condition;
		end
	end
	if basicCondition and not basicCondition.state then
		FloatManager:AddNormal( StrConfig['baojia014'] );
		return;
	end
	if specialCondition and not specialCondition.state then
		FloatManager:AddNormal( StrConfig['baojia015'] );
		return;
	end
	if not hasLearn then
		SkillController:LearnSkill(skillId)
	else
		SkillController:LvlUpSkill(skillId);
	end
end

function UIBaoJiaSkillLvlUp:OnBtnCloseClick()
	self:Hide();
end

function UIBaoJiaSkillLvlUp:Open(skillId, skillLvl)
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
function UIBaoJiaSkillLvlUp:ListNotificationInterests()
	return {
		NotifyConsts.BaoJiaUpdate,
		NotifyConsts.SkillLearn,
		NotifyConsts.SkillLvlUp,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
	};
end

--处理消息
function UIBaoJiaSkillLvlUp:HandleNotification(name, body)
	if name == NotifyConsts.BaoJiaUpdate then
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

function UIBaoJiaSkillLvlUp:OnSkillLvlUp( skillId, oldSkillId )
	if self.skillId == oldSkillId then
		self.skillId = skillId;
		self.skillLvl = self.skillLvl + 1;
		self:UpdateShow();
	end
end

function UIBaoJiaSkillLvlUp:OnSkillLearn( skillId )
	if self.skillId == skillId then
		self.skillLvl = 1;
		self:UpdateShow();
	end
end

