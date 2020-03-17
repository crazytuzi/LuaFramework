--[[
帮派:帮派列表面板
liyuan
2014年11月20日16:22:09
]]


_G.UIUnionSkill = BaseUI:new("UIUnionSkill")
UIUnionSkill.selectedIndex = nil
UIUnionSkill.isStudy = false
function UIUnionSkill:Create()
	self:AddSWF("unionSkillPanel.swf", true, "center")
end

function UIUnionSkill:OnLoaded(objSwf, name)
	for i=60, 68 do 
		objSwf['labUnion60'].text = UIStrConfig['union60']
		objSwf['labUnion61'].text = UIStrConfig['union61']
		objSwf['labUnion62'].text = UIStrConfig['union62']
		objSwf['labUnion63'].text = UIStrConfig['union63']
		objSwf['labUnion68'].text = UIStrConfig['union68']
		
	end
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end										
	-- objSwf.btnLevelUpMaster.click = function() self:OnMasterLevelUp() end
	objSwf.btnLevelUp.click = function() self:OnLevelUp() end
	objSwf.skillIconLoader.loaded = function()
									objSwf.skillIconLoader.content._width = 48
									objSwf.skillIconLoader.content._height = 48
								end
	for j = 1, 8 do 
		objSwf['unionSkillItem'..j].click = function() 
			self.selectedIndex = j
			self:UpdateSkillList()
			self:SelectedSkillItem()
		end
		
		objSwf['unionSkillItem'..j].iconLoader.loaded = function()
			objSwf['unionSkillItem'..j].iconLoader.content._width = 48
			objSwf['unionSkillItem'..j].iconLoader.content._height = 48
		end
	end
	
	for k = 1, 8 do 
		objSwf['btnDisOpen'..k].rollOver = function(e)
			if not UnionUtils:GetSkillIsOpenByGroup(k) then
				-- FPrint('wwwwwwwwwwwwwww'..k)
				local cfg = t_guildskillgroud[k]
				TipsManager:ShowBtnTips(string.format(StrConfig['union52'],cfg.need_guildlv));
			end
		end
		
		objSwf['btnDisOpen'..k].rollOut = function()
			TipsManager:Hide()
		end
	end
	
	objSwf.tilelListSkill.itemRollOver = function(e) self:OnSkillItemOver(e) end
	objSwf.tilelListSkill.itemRollOut = function(e) self:OnSkillItemOut(e) end
end

function UIUnionSkill:OnShow(name)
	if not self.selectedIndex then
		self.selectedIndex = 1
	end
	self:UpdateSkillList()
	self:SelectedSkillItem()
	self:UpdateContribution()
end

function UIUnionSkill:GetWidth(name)
	return 658
end

function UIUnionSkill:GetHeight(name)
	return 441
end

function UIUnionSkill:UpdateContribution()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.numFight.num = UnionModel.MyUnionInfo.contribution
end

--消息处理
function UIUnionSkill:HandleNotification(name,body)
	if not self.bShowState then return end
	local objSwf = self.objSwf
	if not objSwf then return end
	
	if name == NotifyConsts.UpdateMyUnionMemInfo then
		self:UpdateContribution()
	elseif name == NotifyConsts.UpdateLevelUpMyGuildSkill then
		self:OnShow()
	elseif name == NotifyConsts.OpenGuildSkill then
		if self.isStudy then
			FloatManager:AddSysNotice(2005048)--成功学习新帮派技能
		else	
			FloatManager:AddSysNotice(2005046)--帮派技能等级上限提升成功
		end
		
		self:OnShow()
	elseif name == NotifyConsts.UpdateGuildInfo then
		self:OnShow()
	end
end

-- 消息监听
function UIUnionSkill:ListNotificationInterests()
	return {NotifyConsts.UpdateMyUnionMemInfo,
			NotifyConsts.UpdateLevelUpMyGuildSkill,
			NotifyConsts.UpdateGuildInfo,
			NotifyConsts.OpenGuildSkill}
end

------------------------------------------------------------------------------
--									逻辑处理
------------------------------------------------------------------------------

-- 显示选中的技能
function UIUnionSkill:SelectedSkillItem()
	local objSwf = self.objSwf
	if not objSwf then return end

	local skillGroupId = self.selectedIndex
	
	local curSkillId = UnionUtils:GetSkillIdByGroup(skillGroupId)
	local skillCfg = t_guildskill[curSkillId]
	if not skillCfg then return end
	
	local skillGroupCfg = t_guildskillgroud[skillGroupId]
	local skillIcon = ResUtil:GetSkillIconUrl(skillGroupCfg.icon)
	if objSwf.skillIconLoader.source ~= skillIcon then
		objSwf.skillIconLoader.source = skillIcon
	else
		if objSwf.skillIconLoader.source == '' then
			objSwf.skillIconLoader:unload()
		end
	end
	
	-- 技能名 等级 效果
	objSwf.labSkillName.text = skillGroupCfg.groupname
	local maxLevel = self:GetSkillMaxLevel(skillGroupId)
	objSwf.txtLevel.text = string.format(StrConfig['union31'], maxLevel )
	objSwf.txtEffect.htmlText = UnionUtils:GetAttrStr(skillCfg.att)
	
	--消耗贡献
	local colorStr = '#2fe00d'
	local bReachedStr = StrConfig['union210']
	objSwf.btnLevelUp.disabled = false
	if skillCfg.need_contribute then
		if UnionModel.MyUnionInfo.contribution < skillCfg.need_contribute then
			colorStr = '#cc0000'
			objSwf.btnLevelUp.disabled = true
			bReachedStr = StrConfig['union211']
		end
		objSwf.txtContribution.htmlText = '<font color="'..colorStr..'">'..skillCfg.need_contribute..'</font>'..bReachedStr
	else
		objSwf.txtContribution.text = ''
	end
	
	if skillCfg.level >= maxLevel then
		objSwf.btnLevelUp.disabled = true
		objSwf.btnLevelUp._visible = false
		objSwf.labUnion62._visible = false
		objSwf.txtNextEffect._visible = false
		objSwf.labUnion63._visible = false
		objSwf.txtContribution._visible = false
		objSwf.mcMaxLevelGuildSkill._visible = true
	else	
		objSwf.btnLevelUp._visible = true
		objSwf.labUnion62._visible = true
		objSwf.txtNextEffect._visible = true
		objSwf.labUnion63._visible = true
		objSwf.txtContribution._visible = true
		objSwf.mcMaxLevelGuildSkill._visible = false
	end
	
	-- 下级技能
	if skillCfg.nextlv == 0 then
		objSwf.btnLevelUp.disabled = true
		objSwf.txtContribution.text = ''
		objSwf.txtNextEffect.text = ''
		
	else
		local nextSkillCfg = t_guildskill[skillCfg.nextlv]
		if nextSkillCfg then 
			objSwf.txtNextEffect.htmlText = UnionUtils:GetAttrStr(nextSkillCfg.att)
		else
			objSwf.txtNextEffect.text = ''
		end
	end
	
	self:UpdateUnionLevel(skillGroupId)
	-- self:UpdateUnionMoney(skillGroupId)
	-- self:UpdateUnionResList(skillGroupId)
end

-- 更新技能列表
function UIUnionSkill:UpdateSkillList()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local skillList = UnionModel.MyUnionInfo.GuildSkillList
	objSwf.tilelListSkill.dataProvider:cleanUp() 
	for i, unionSkill in pairs(skillList) do
		local skillId = UnionUtils:GetSkillIdByGroup(i)
		local uSkill = {}
		uSkill.openFlag = unionSkill.openFlag
		uSkill.skillGroupId = i
		if self.selectedIndex == i then
			uSkill.isSelected = true	--是否选中
			-- unionSkill.openFlag = 1
		else
			uSkill.isSelected = false
		end
		
		local iconUrl = ''
		local skillCfg = t_guildskill[skillId]
		if unionSkill.openFlag == 1 then
			--已开启
			uSkill.isDisabled = false	
			local skillVo = t_guildskillgroud[i]
			iconUrl = ResUtil:GetSkillIconUrl(skillVo.icon)
			
			if skillCfg and skillCfg.level and skillCfg.group then
				uSkill.skillLevel = '<font size="14" color="#2fe00d">'..skillCfg.level..'/'..self:GetSkillMaxLevel(i)..'</font>'
				uSkill.level = skillCfg.level
			end
			objSwf['btnDisOpen'..i]._visible = false
			objSwf['btnDisOpen'..i].hitTestDisable = true
		else
			uSkill.isOpenReached = false
			uSkill.isDisabled = true
			iconUrl = ''	
			uSkill.skillLevel = '<font size="14" color="#cc0000">'..StrConfig['union167']..'</font>'
			objSwf['btnDisOpen'..i]._visible = true
			objSwf['btnDisOpen'..i].hitTestDisable = false
		end 
		uSkill.iconUrl = iconUrl
		
		-- FTrace(uSkill)
		objSwf.tilelListSkill.dataProvider:push( UIData.encode(uSkill) )
	end
	objSwf.tilelListSkill:invalidateData()
end

-- 开启所需的等级条件
function UIUnionSkill:UpdateUnionLevel(skillGroupId)
	local objSwf = self.objSwf
	if not objSwf then return end
	
	-- objSwf.txtUnionLevel.text = string.format(StrConfig['union31'],UnionModel.MyUnionInfo.level)
	
	objSwf.numGuildLevel.num = UnionModel.MyUnionInfo.level
end

-- 开启所需的帮派资金
function UIUnionSkill:UpdateUnionMoney(skillGroupId)
	-- local objSwf = self.objSwf
	-- if not objSwf then return end
	
	-- local colorStr = '#FFFFFF'
	-- if skillGroupId == -1 then colorStr = '#780000' end
	-- if not UnionUtils:isSkillOpenMoneyReached(skillGroupId) then colorStr = '#780000' end
end

-- 开启所需的帮派资源
function UIUnionSkill:UpdateUnionResList()
	-- local objSwf = self.objSwf
	-- if not objSwf then return end
end

-- 更新权限
function UIUnionSkill:UpdatePermission()
	-- local objSwf = self.objSwf
	-- if not objSwf then return end
	
	-- 升级权限
	-- if UnionUtils:GetUnionPermissionByDuty(UnionModel.MyUnionInfo.pos, UnionConsts.skill_lv) == 1 then
		-- objSwf.btnLevelUpMaster.visible = true
	-- else
		-- objSwf.btnLevelUpMaster.visible = false
	-- end
end

------------------------------------------------------------------------------
--									UI事件处理
------------------------------------------------------------------------------
--[[
function UIUnionSkill:OnMasterLevelUp()
	local skillGroupId = self.selectedIndex
	if not UnionUtils:IsSkillOpenReached(skillGroupId) then
		if self.isStudy then
			FloatManager:AddSysNotice(2005049)--条件不足，无法学习
		else
			FloatManager:AddSysNotice(2005047)--条件不足，无法升级
		end
		return
	end
	local skillGroupId = self.selectedIndex
	UnionController:ReqLvUpGuildSkill(skillGroupId)
end--]]

function UIUnionSkill:OnLevelUp()
	local skillGroupId = self.selectedIndex
	local curSkillId = UnionUtils:GetSkillIdByGroup(skillGroupId)
	local skillCfg = t_guildskill[curSkillId]
	if skillCfg.need_contribute then
		if UnionModel.MyUnionInfo.contribution < skillCfg.need_contribute then
			FloatManager:AddSysNotice(2005045)--当前贡献不足，无法升级
			return
		end
	end
	SoundManager:PlaySfx(2053)
	UnionController:ReqLevelUpMyGuildSkill(skillGroupId)
end

-- 选中一个技能
function UIUnionSkill:OnWuhunListClick(e)
	self:ShowWuhunInfo(e.item.wuhunId)
end

function UIUnionSkill:GetSkillMaxLevel(groupId)
	if not UnionModel.MyUnionInfo or not UnionModel.MyUnionInfo.level then return 0 end
	
	local cfg = t_guild[UnionModel.MyUnionInfo.level]
	if not cfg or not cfg.maxskilllv then return 0 end
	
	return cfg.maxskilllv[groupId]
end

--技能鼠标移上
function UIUnionSkill:OnSkillItemOver(e)
	if not e.item.skillGroupId then return end
	if e.item.isDisabled then
		local cfg = t_guildskillgroud[e.item.skillGroupId]
		TipsManager:ShowTips( TipsConsts.Type_Normal, string.format(StrConfig['union52'],cfg.need_guildlv), TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
	else
		TipsManager:ShowTips(TipsConsts.Type_GuildSkill,{skillGroupId=tonumber(e.item.skillGroupId),level=tonumber(e.item.level)},TipsConsts.ShowType_Normal,
							TipsConsts.Dir_RightUp)
	end
end

--技能鼠标移出
function UIUnionSkill:OnSkillItemOut(e)
	TipsManager:Hide()
end

function UIUnionSkill:OnBtnCloseClick()
	self:Hide()
end

function UIUnionSkill:IsShowSound()
	return true;
end

function UIUnionSkill:IsShowLoading()
	return true;
end
