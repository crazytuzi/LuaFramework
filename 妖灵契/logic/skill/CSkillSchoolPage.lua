---------------------------------------------------------------
--技能界面的 技能学习 子界面


---------------------------------------------------------------

local CSkillSchoolPage = class("CSkillSchoolPage", CPageBase)

function CSkillSchoolPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
	CSkillSchoolPage.ResetSkillOpenLevel = tonumber(data.globalcontroldata.GLOBAL_CONTROL.reset_skill_point.open_grade) 
	CSkillSchoolPage.ResetSkillCostItemSId = tonumber(data.globaldata.GLOBAL.wash_schoolskill_itemid.value) 
	self.m_SelectIndex = nil	
	self.m_SchoolBranch = g_AttrCtrl.school_branch
end

function CSkillSchoolPage.OnInitPage(self)
	self.m_TipsBtn = self:NewUI(1, CButton)
	self.m_SkillListGrid = self:NewUI(2, CGrid)
	self.m_CurSkillPointLabel = self:NewUI(3, CLabel)
	self.m_ResetBox = self:NewUI(5, CBox)
	self.m_DesBox = self:NewUI(6, CBox)
	self.m_SkillIconSprite = self:NewUI(7, CSprite)
	self.m_SkillNameLabel = self:NewUI(8, CLabel)
	self.m_SkillLevelLabel = self:NewUI(9, CLabel)
	self.m_SkillDesLabel = self:NewUI(10, CLabel)
	self.m_AttrFromLabel = self:NewUI(11, CLabel)
	self.m_AttrToLabel = self:NewUI(12, CLabel)
	self.m_AttrToBg = self:NewUI(13, CSprite)
	self.m_DesBottomBox = self:NewUI(14, CBox)
	self.m_DesOtherLabel = self:NewUI(15, CLabel)
	self.m_CostSkillPointLabel = self:NewUI(16, CLabel)
	self.m_LearnSkillBtn = self:NewUI(17, CButton)
	self.m_LearnSkillLabel = self:NewUI(18, CLabel)
	self.m_ResetEnableBtn = self:NewUI(19, CButton)
	self.m_ResetUnableBtn = self:NewUI(20, CButton)
	self.m_NextLevelCostLabel = self:NewUI(21, CLabel)
	self.m_SchoolSwitchBtn = self:NewUI(22, CBox)
	self.m_SchoolIconSprite = self:NewUI(23, CSprite)
	self.m_SkillITypeSprite = self:NewUI(24, CSprite)
	self.m_CostNuqiLabel = self:NewUI(25, CLabel)
	self.m_CurSkillSecondBox = self:NewUI(26, CBox)
	self.m_CurSkillBox = self:NewUI(27, CBox)
	self.m_CurSkillPointSecondLabel = self:NewUI(28, CLabel)

	self:InitContent()
end

function CSkillSchoolPage.InitContent(self)
	self.m_TipsBtn:AddUIEvent("click", callback(self, "OnClick", "Tips"))
	self.m_ResetEnableBtn:AddUIEvent("click", callback(self, "OnClick", "Reset"))
	self.m_ResetUnableBtn:AddUIEvent("click", callback(self, "OnClick", "UnReset"))
	self.m_LearnSkillBtn:AddUIEvent("click", callback(self, "OnClick", "Learn"))
	self.m_SchoolSwitchBtn:AddUIEvent("click", callback(self, "OnClick", "SwitchSchool"))

	g_SkillCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlSkilllEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlItemlEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrlEvent"))
	g_GuideCtrl:AddGuideUI("skill_point_label", self.m_CurSkillSecondBox)
	g_GuideCtrl:AddGuideUI("skill_switch_btn", self.m_SchoolSwitchBtn)
	g_GuideCtrl:AddGuideUI("skill_learn_btn", self.m_LearnSkillBtn)
	g_GuideCtrl:AddGuideUI("skill_des_other_label", self.m_DesOtherLabel)
	
	self:InitGrid()
	self:SwitchSkill(1, true)
	
end

function CSkillSchoolPage.InitGrid(self)
	self.m_SkillListGrid:InitChild(function (obj, index)
		local oBox = CBox.New(obj)
		oBox.m_IconSprite = oBox:NewUI(1, CSprite)
		oBox.m_LevelLabel = oBox:NewUI(2, CLabel)
		oBox.m_NormalWidget = oBox:NewUI(3, CBox)
		oBox.m_UnlockLevelLabel = oBox:NewUI(4, CLabel)
		oBox.m_TypeSprite1 = oBox:NewUI(5, CSprite)
		oBox.m_SelectSprite = oBox:NewUI(6, CSprite)
		oBox.m_LockWidget = oBox:NewUI(7, CBox)
		oBox.m_CanUpSprite = oBox:NewUI(8, CSprite)
		oBox.m_NameLabel = oBox:NewUI(9, CLabel)
		oBox.m_TypeSprite2 = oBox:NewUI(10, CSprite)
		oBox:AddUIEvent("click", callback(self, "OnClick", "SelectSkill", index))
		oBox:SetGroup(self.m_SkillListGrid:GetInstanceID())
		g_GuideCtrl:AddGuideUI(string.format("skill_skillbtn_%d", index), oBox)
		return oBox
	end)

end

function CSkillSchoolPage.RefreshAll( self)
	self:RefreshSkillList()
	self:RefreshCurSkillPoint()
	self:RefreshCostSkillPoint()
	self:RefreshDes()
	self:RefreshAttrGrid()
	self:RefreshWeapon()
end

function CSkillSchoolPage.RefreshSkillList( self)
	local d = g_SkillCtrl:GetMySchoolSkillListData()
	for i = 1, self.m_SkillListGrid:GetCount() do
		local oBox = self.m_SkillListGrid:GetChild(i)
		if i <= #d and d[i] ~= nil then			
			oBox:SetActive(true)
			local skillLevel = d[i].level
			local skillId = d[i].sk
			local baseData = g_SkillCtrl:GetSkillBaseDataById(skillId)
			local levelData = g_SkillCtrl:GetSkillLevelDataByIdAndLevel(skillId, skillLevel) 
			local nextLevelData = g_SkillCtrl:GetSkillLevelDataByIdAndLevel(skillId, skillLevel + 1) 
			oBox.m_CanUpSprite:SetActive(false)
			if baseData.unlock_grade > g_AttrCtrl.grade then
				oBox.m_LockWidget:SetActive(true)				
				oBox.m_LevelLabel:SetActive(false)
				oBox.m_UnlockLevelLabel:SetText("LV "..tostring(baseData.unlock_grade))
			else			
				if nextLevelData and g_AttrCtrl.grade >= nextLevelData.player_level and g_AttrCtrl.skill_point >= levelData.skill_point then
					oBox.m_CanUpSprite:SetActive(true)
				end			
				oBox.m_LevelLabel:SetActive(true)
				oBox.m_LockWidget:SetActive(false)							
				oBox.m_LevelLabel:SetText(tostring(skillLevel))
			end
			oBox.m_SelectSprite:SetActive(false)
			if self.m_SelectIndex ~= nil then
				if self.m_SelectIndex == i then
					oBox.m_SelectSprite:SetActive(true)					
				end
			end			
			oBox.m_IconSprite:SpriteSkill(baseData.icon)
			oBox.m_TypeSprite1:SetActive(baseData.type == 2)
			oBox.m_TypeSprite2:SetActive(baseData.type == 3)
			oBox.m_NameLabel:SetText(baseData.skill_name)
			oBox.m_SkillId = skillId
			oBox.m_SkillLevel = skillLevel				
		else
			oBox:SetActive(false)
			oBox.m_SkillId = nil
			oBox.m_SkillLevel = nil
			oBox.m_SkiType = nil
		end
	end
end

function CSkillSchoolPage.RefreshCurSkillPoint( self)
	local itemData = data.itemdata.OTHER[CSkillSchoolPage.ResetSkillCostItemSId]
	self.m_CurSkillPointLabel:SetText(string.format("%d", g_AttrCtrl.skill_point))
	self.m_CurSkillPointSecondLabel:SetText(string.format("%d", g_AttrCtrl.skill_point))
	if g_AttrCtrl.grade < CSkillSchoolPage.ResetSkillOpenLevel then
		self.m_CurSkillBox:SetActive(false)		
		self.m_CurSkillSecondBox:SetActive(true)
		self.m_ResetBox:SetActive(true)
		self.m_ResetEnableBtn:SetActive(false)
		self.m_ResetUnableBtn:SetActive(true)
	else
		self.m_CurSkillBox:SetActive(true)		
		self.m_CurSkillSecondBox:SetActive(false)
		self.m_ResetBox:SetActive(true)
		self.m_ResetEnableBtn:SetActive(true)
		self.m_ResetUnableBtn:SetActive(false)
	end
end

function CSkillSchoolPage.RefreshCostSkillPoint( self)
	if self.m_SelectIndex == nil then
		return
	end
	local oBox = self.m_SkillListGrid:GetChild(self.m_SelectIndex)
	if oBox == nil then
		self.m_CostSkillPointLabel:SetText("--")
	else
		local levelData = g_SkillCtrl:GetSkillLevelDataByIdAndLevel(oBox.m_SkillId, oBox.m_SkillLevel) 
		if levelData then
			local str = levelData.skill_point ~= 0 and string.format("%d", levelData.skill_point) or "--"
			self.m_CostSkillPointLabel:SetText(str)
		else
			self.m_CostSkillPointLabel:SetText("--")
		end	
	end
end

function CSkillSchoolPage.RefreshDes( self)
	if self.m_SelectIndex == nil then
		self.m_DesBox:SetActive(false)
		return
	end
	self.m_DesBox:SetActive(true)
	local oBox = self.m_SkillListGrid:GetChild(self.m_SelectIndex)
	if oBox == nil then
		self.m_DesBox:SetActive(false)
	else
		local baseData = g_SkillCtrl:GetSkillBaseDataById(oBox.m_SkillId)
		local levelData = g_SkillCtrl:GetSkillLevelDataByIdAndLevel(oBox.m_SkillId, oBox.m_SkillLevel) 
		self.m_SkillIconSprite:SpriteSkill(baseData.icon)
		self.m_SkillNameLabel:SetText(baseData.skill_name)
		self.m_SkillLevelLabel:SetText("LV "..tostring(oBox.m_SkillLevel))
		self.m_SkillDesLabel:SetText(levelData.desc)
		if levelData.skill_effect_addtion ~= "" then
			self.m_DesBottomBox:SetActive(true)
			self.m_DesOtherLabel:SetText(levelData.skill_effect_addtion)
		else
			self.m_DesBottomBox:SetActive(false)
		end
		local magic = data.magicdata.DATA[oBox.m_SkillId]
		if magic and magic.sp ~= 0 then
			self.m_CostNuqiLabel:SetActive(true)
			self.m_CostNuqiLabel:SetText(string.format("%d (怒气)", magic.sp / 20))
		else
			self.m_CostNuqiLabel:SetActive(false)
		end
	end	
end

function CSkillSchoolPage.RefreshAttrGrid( self)
	if self.m_SelectIndex == nil then
		return
	end
	local oBox = self.m_SkillListGrid:GetChild(self.m_SelectIndex)
	if oBox ~= nil then
		local curLevelData = g_SkillCtrl:GetSkillLevelDataByIdAndLevel(oBox.m_SkillId, oBox.m_SkillLevel) 
		local nextLevelData = g_SkillCtrl:GetSkillLevelDataByIdAndLevel(oBox.m_SkillId, oBox.m_SkillLevel + 1) 
		if 	curLevelData ~= nil then
			local str = (curLevelData.skill_effect and curLevelData.skill_effect ~= "") and curLevelData.skill_effect or "无"			
			local t = string.split(str, '|')
			local fromText = ""
			for i = 1, #t do
				fromText = fromText .. t[i] .. "\n"		
			end
			self.m_AttrFromLabel:SetText(fromText)
		else
			self.m_AttrFromLabel:SetText("")
		end
		if nextLevelData ~= nil then
			local str = (nextLevelData.skill_effect and nextLevelData.skill_effect ~= "") and nextLevelData.skill_effect or "已经到达最高级"		
			local t = string.split(str, '|')
			local toText = ""
			for i = 1, #t do
				toText = toText .. t[i] .. "\n"
			end
			self.m_AttrToLabel:SetText(toText)
			if  nextLevelData.skill_point ~= 0 then
				self.m_NextLevelCostLabel:SetActive(true)
				self.m_NextLevelCostLabel:SetText("下级需要等级:"..tostring(nextLevelData.player_level))
			else
				self.m_NextLevelCostLabel:SetActive(false)
			end			
		else
			self.m_AttrToLabel:SetText("已经到达最高级")
			self.m_NextLevelCostLabel:SetActive(false)
		end		
	end
end

function CSkillSchoolPage.SwitchSkill(self, index , froce)
	if self.m_SelectIndex == index then
		return
	end
	if froce or self:CanSwitch(index) then
		self.m_SelectIndex = index
		self:RefreshAll()
	end
end

function CSkillSchoolPage.OnClick(self, sKey, arg1)

	if sKey == "Tips" then
		local title = "技能"
		local tContent = {
			[1] = "玩家可以通提高技能来提高战斗力。技能是行走江湖的第一课",
			[2] = " ",
			[3] = " ",
		}
		
		g_WindowTipCtrl:SetWindowItemTipsWindow(title, tContent,
			{widget=  self.m_TipsBtn, side = enum.UIAnchor.Side.Bottom ,offset = Vector2.New(-50, -20)})
	elseif sKey == "UnReset" then
		g_NotifyCtrl:FloatMsg(string.format("%d级开放此功能", CSkillSchoolPage.ResetSkillOpenLevel)) 

	elseif sKey == "Reset" then
		self:OnResetPoint()

	elseif sKey == "Learn" then
		self:LearnSkill()		

	elseif sKey == "SelectSkill" then
		self:DelayCall(0.1, "SwitchSkill", arg1)
		--self:SwitchSkill(arg1)

	elseif sKey == "SwitchSchool" then
		if g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.switchschool.open_grade then
			g_NotifyCtrl:FloatMsg(string.format("%d级开启切换流派", data.globalcontroldata.GLOBAL_CONTROL.switchschool.open_grade))
		else
			local args = 
			{
				msg = "是否要切换流派?",
				okCallback = function ( )
					g_AttrCtrl:C2GSChangeSchool()
				end
			}
			g_WindowTipCtrl:SetWindowConfirm(args)
		end

	end
end

function CSkillSchoolPage.OnResetPoint(self)
	local ownCount = g_ItemCtrl:GetTargetItemCountBySid(CSkillSchoolPage.ResetSkillCostItemSId)
	--如果没学习技能则提示不需要重置
	if not g_SkillCtrl:IsLearnskill() then
		Utils.AddTimer(callback(self, "NoNeedResetPoint"), 0, 0.1)

	elseif ownCount > 0 then
		local args = 
		{
			msg = "使用洗点石重置技能点吗？",
			okCallback = function ( )
				g_SkillCtrl:C2GSWashSchoolSkill(1)
			end
		}
		g_WindowTipCtrl:SetWindowConfirm(args)

	else
		local oItem = CItem.NewBySid(CSkillSchoolPage.ResetSkillCostItemSId)
		local price = oItem:GetValue("buy_price") == 0 and 200 or oItem:GetValue("buy_price")
		local args = 
		{
			msg = string.format("确认使用%d#w2重置技能点吗？", price),
			okCallback = function ( )
				g_SkillCtrl:C2GSWashSchoolSkill(0)
			end
		}
		g_WindowTipCtrl:SetWindowConfirm(args)
	end		
end

function CSkillSchoolPage.OnGotoShop( self )
	local args = 
	{
		msg = "洗点道具不足，需要去商城购买道具吗?",
		okCallback = function ()
			g_NpcShopCtrl:OpenShop(define.Store.Page.CrystalShop)
		end
	}
	g_WindowTipCtrl:SetWindowConfirm(args)
end

function CSkillSchoolPage.NoNeedResetPoint( self )
	local args = 
	{
		msg = "尚未学习技能,不需要重置",
		thirdStr = "确定",
		thirdCallback = function ()	end,
		hideOk = true,
		hideCancel = true,
	}
	g_WindowTipCtrl:SetWindowConfirm(args)
end

function CSkillSchoolPage.LearnSkill( self )
	local oBox = self.m_SkillListGrid:GetChild(self.m_SelectIndex)
	if oBox then
		local iSk = oBox.m_SkillId		
		local baseData = g_SkillCtrl:GetSkillBaseDataById(oBox.m_SkillId)			
		local curLevelData = g_SkillCtrl:GetSkillLevelDataByIdAndLevel(oBox.m_SkillId, oBox.m_SkillLevel) 
		local nextLevelData = g_SkillCtrl:GetSkillLevelDataByIdAndLevel(oBox.m_SkillId, oBox.m_SkillLevel + 1) 
		if g_AttrCtrl.skill_point < curLevelData.skill_point then		
			g_NotifyCtrl:FloatMsg("技能点不足")
		elseif baseData.unlock_grade > g_AttrCtrl.grade then
			g_NotifyCtrl:FloatMsg("未达到解锁等级")
		elseif not nextLevelData or next(nextLevelData)  == nil then
			g_NotifyCtrl:FloatMsg("已经到达最高级")
		elseif nextLevelData and next(nextLevelData)  ~= nil and nextLevelData.player_level > g_AttrCtrl.grade then
			g_NotifyCtrl:FloatMsg("下级需要等级"..tostring(nextLevelData.player_level))
		else
			g_SkillCtrl:C2GSLearnSkill("school", iSk)
		end	
	end
end

function CSkillSchoolPage.OnCtrlSkilllEvent(self, oCtrl )
	if oCtrl.m_EventID == define.Skill.Event.SchoolRefresh then
		self:RefreshSkillList()
		self:RefreshDes()
		self:RefreshAttrGrid()
		self:RefreshCostSkillPoint()
	end
end

function CSkillSchoolPage.OnCtrlItemlEvent(self, oCtrl )
	if oCtrl.m_EventID == define.Item.Event.RefreshBagItem or
	   oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		self:RefreshCurSkillPoint()
		self:RefreshWeapon()
	end
end

function CSkillSchoolPage.OnCtrlAttrlEvent(self, oCtrl )
	if oCtrl.m_EventID == define.Attr.Event.Change then
		if g_AttrCtrl.school_branch ~= self.m_SchoolBranch then
		   self.m_SchoolBranch = g_AttrCtrl.school_branch
		   self.m_SelectIndex = 1
		else
			self:RefreshSkillList()
			self:RefreshCurSkillPoint()
		end
	end
end

function CSkillSchoolPage.RefreshWeapon(self )
	local weaponString = string.format("pic_dati_wuqi_%d_%d", g_AttrCtrl.school, g_AttrCtrl.school_branch)
	self.m_SchoolIconSprite:SetSpriteName(weaponString)
end

function CSkillSchoolPage.CanSwitch(self, index)
	local b = false
	local oBox = self.m_SkillListGrid:GetChild(index)

	if oBox ~= nil then
		local baseData = g_SkillCtrl:GetSkillBaseDataById(oBox.m_SkillId)
		if baseData.unlock_grade > g_AttrCtrl.grade then
			g_NotifyCtrl:FloatMsg(string.format("%d级开启此技能", baseData.unlock_grade))
		else
			b = true
		end
	end
	return b 
end

return CSkillSchoolPage