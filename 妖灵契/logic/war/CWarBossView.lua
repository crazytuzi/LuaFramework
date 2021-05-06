local CWarBossView = class("CWarBossView", CViewBase)

function CWarBossView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarBossView.prefab", cb)
	self.m_DepthType = "Menu"
	self.m_WarType = nil
	self.m_BossID = nil
	self.m_AlphaAction = nil
end

function CWarBossView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_BossHPSlider = self:NewUI(2, CSlider)
	self.m_SkillTipsBtn = self:NewUI(3, CButton)
	self.m_SkillExplainWidget = self:NewUI(4, CWidget)
	self.m_SkillExplainTable = self:NewUI(5, CTable)
	self.m_SkillExplainBox = self:NewUI(6, CBox)
	self.m_FieldBossBox = self:NewUI(7, CBox)
	self.m_BossShapeSpr = self:NewUI(8, CSprite)
	self.m_SkillBG = self:NewUI(9, CSprite)
	self.m_DescLabel = self:NewUI(10, CLabel)
	self.m_StarGrid = self:NewUI(11, CGrid)
	self.m_StarLight = self:NewUI(12, CSprite)
	self.m_StarDark = self:NewUI(13, CSprite)
	self.m_BossBG = self:NewUI(14, CSprite)
	self.m_BossBuffBox = self:NewUI(15, CBox)
	self.m_LevelLabel = self:NewUI(16, CLabel)
	self.m_StarLight:SetActive(false)
	self.m_StarDark:SetActive(false)

	UITools.ResizeToRootSize(self.m_Container)
	self:InitFieldBossBox()
	self:InitContent()
end

function CWarBossView.InitContent(self)
	self.m_BossHPSlider:SetSliderText("")
	self.m_SkillExplainBox:SetActive(false)
	self.m_SkillExplainWidget:SetActive(false)
	self.m_FieldBossBox:SetActive(false)
	self.m_SkillTipsBtn:AddUIEvent("click", callback(self, "OnSkillTipsBtn"))

	self:InitBossBuffBox()
end

function CWarBossView.InitFieldBossBox(self)
	self.m_FieldBossBox.m_Label = self.m_FieldBossBox:NewUI(1, CLabel)
end

function CWarBossView.OnSkillTipsBtn(self, oBtn)
	if self.m_AlphaAction then
		g_ActionCtrl:DelAction(self.m_AlphaAction)
	end
	self.m_SkillExplainWidget:SetAlpha(1)
	self.m_SkillExplainWidget:SetActive(true)
	self.m_AlphaAction = CActionFloat.New(self.m_SkillExplainWidget, 2.5, "SetAlpha", 1, 0)
	self.m_AlphaAction:SetEndCallback(callback(self.m_SkillExplainWidget, "SetActive", false))
	g_ActionCtrl:AddAction(self.m_AlphaAction, 2.5)
	self:RefreshSkillExplainTable()
end

function CWarBossView.RefreshSkillExplainTable(self)
	self.m_SkillExplainTable:Clear()
	--[[
	local showskills = self.m_Warrior.m_ShowSkills or {}
	for i,v in pairs(showskills) do
		local data = data.skilldata.DESC[v]
		local oBox = self.m_SkillExplainBox:Clone()
		oBox:SetActive(true)
		oBox.m_DescLabel = oBox:NewUI(1, CLabel)
		oBox.m_DescLabel:SetText(string.format("%s\n%s\n", data.skill_name, data.skill_desc))
		self.m_SkillExplainTable:AddChild(oBox)
	end
	self.m_SkillExplainTable:Reposition()
	]]
	local showskills = self.m_Warrior.m_ShowSkills or {}
	local desc = ""
	for i,v in pairs(showskills) do
		local data = data.skilldata.DESC[v]
		desc = desc .. string.format("%s\n%s\n\n", data.skill_name, data.skill_desc)
	end
	self.m_DescLabel:SetText(desc)
end

function CWarBossView.RefreshHPSlider(self, value, txt)
	local oldValue = self.m_BossHPSlider:GetValue()
	if value <= oldValue then --防止文字提示反弹
		txt = txt or ""
		self.m_BossHPSlider:SetSliderText(txt)
		self.m_BossHPSlider:SetValue(value)
	end
end

function CWarBossView.SetBossWarrior(self, oWarrior)
	--table.print(oWarrior.m_ServerInfo)
	--table.print(oWarrior.m_ServerInfo.model_info.shape)
	self.m_Warrior = oWarrior
	self.m_SkillTipsBtn:SetActive(self.m_Warrior and self.m_Warrior.m_ShowSkills and #self.m_Warrior.m_ShowSkills > 0)
	self.m_BossShapeSpr:SpriteBossAvatar(oWarrior.m_ServerInfo.status.model_info.shape)
	if 	oWarrior.m_NpcSpSkill and oWarrior.m_NpcSpSkill and 
		oWarrior.m_NpcSpSkill.cur_grid and oWarrior.m_NpcSpSkill.sum_grid then
		self:SetStar(oWarrior.m_NpcSpSkill.cur_grid, oWarrior.m_NpcSpSkill.sum_grid)
	end
	if oWarrior.m_Level then
		self:SetLevel(oWarrior.m_Level)
	end
end

function CWarBossView.SetLevel(self, lv)
	self.m_LevelLabel:SetText(lv and string.format("lv.%d", lv) or "")
end

function CWarBossView.SetStar(self, iCur, iMax)
	self.m_StarGrid:Clear()
	if not (iCur and iMax) then
		return
	end
	for i=1, iMax do
		local oClone
		if i <= iCur then
			oClone = self.m_StarLight:Clone()
		else
			oClone = self.m_StarDark:Clone()
		end
		oClone:SetActive(true)
		self.m_StarGrid:AddChild(oClone)
	end
	self.m_StarGrid:Reposition()
end

function CWarBossView.SetWarType(self, iWarType)
	self.m_WarType = iWarType
	self:CheckBossType()
end

function CWarBossView.CheckBossType(self)
	if self.m_WarType == define.War.Type.Boss or self.m_WarType == define.War.Type.BossKing then
		g_ActivityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnActivityEvent"))
		self.m_BossBG:SetActive(true)
		self:RefreshBossHP()
	elseif self.m_WarType == define.War.Type.OrgBoss then
		g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgEvent"))
		self.m_BossBG:SetActive(true)
		self:RefreshOrgBossHP()
	elseif self.m_WarType == define.War.Type.FieldBoss then
		g_FieldBossCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFieldBossEvent"))
		self.m_BossBG:SetActive(true)
		self:RefreshFieldBossHP()
	elseif self.m_WarType == define.War.Type.FieldBossPVP then
		g_FieldBossCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFieldBossEvent"))
		self.m_BossBG:SetActive(false)
		self.m_FieldBossBox:SetActive(true)
		self:RefreshFieldBossHP()
	elseif self.m_WarType == define.War.Type.MonsterAtkCity then
		g_MonsterAtkCityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMonsterAtkCityEvent"))
		self.m_BossBG:SetActive(true)
		self:RefreshMSBossHP()
	end
end

function CWarBossView.OnActivityEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Activity.Event.WorldBossHP then
		self:RefreshBossHP()
	end
end

function CWarBossView.RefreshBossHP(self)
	local dInfo = g_ActivityCtrl:GetWolrdBossInfo()
	local percent = math.floor(dInfo.percent*100)
	local sText = "0%"
	if percent > 1 then
		sText = string.format("%d%%", percent)
	elseif percent > 0 then
		sText = string.format("%.2f%%", percent)
	end
	self:RefreshHPSlider(dInfo.percent, sText)
end

function CWarBossView.OnOrgEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.OnOrgFBBossHP then
		self:RefreshOrgBossHP()
	end
end

function CWarBossView.RefreshOrgBossHP(self)
	local dInfo = g_OrgCtrl:GetOrgBossInfo()
	if dInfo then
		local percent = math.floor(dInfo.percent*100)
		local sText = "0%"
		if percent > 1 then
			sText = string.format("%d%%", percent)
		elseif percent > 0 then
			sText = string.format("%.2f%%", percent)
		end
		self:RefreshHPSlider(dInfo.percent, sText)
	end
end

function CWarBossView.OnMonsterAtkCityEvent(self, oCtrl)
	if oCtrl.m_EventID == define.MonsterAtkCity.Event.RefreshHP then
		self:RefreshMSBossHP()
	end
end

function CWarBossView.RefreshMSBossHP(self)
	local hp = g_MonsterAtkCityCtrl.m_BossHP
	local hp_max = g_MonsterAtkCityCtrl.m_BossHPMax
	local dInfo = g_ActivityCtrl:GetWolrdBossInfo()
	local value = hp/hp_max
	local percent = math.floor(value * 100)
	local sText = "0%"
	if percent > 1 then
		sText = string.format("%d%%", percent)
	elseif percent > 0 then
		sText = string.format("%.2f%%", percent)
	end
	self:RefreshHPSlider(value, sText)
end

function CWarBossView.OnFieldBossEvent(self, oCtrl)
	if oCtrl.m_EventID == define.FieldBoss.Event.RefreshHP then
		self:RefreshFieldBossHP()
	end
end

function CWarBossView.RefreshFieldBossHP(self)
	local hp, maxhp = g_FieldBossCtrl:GetBossHP()
	if not (hp and maxhp) then
		return
	end
	local percent = hp/maxhp * 100
	
	if self.m_WarType == define.War.Type.FieldBoss then
		local sText = "0%"
		if percent > 1 then
			sText = string.format("%d%%", percent)
		elseif percent > 0 then
			sText = string.format("%.2f%%", percent)
		end
		self:RefreshHPSlider(hp/maxhp, sText)
	
	elseif self.m_WarType == define.War.Type.FieldBossPVP then
		local sText = string.format("Boss剩余血量%d", hp)
		self.m_FieldBossBox.m_Label:SetText(sText)
	end
	
	if hp == 0 then
		self.m_FieldBossBox:SetActive(true)
		self.m_FieldBossBox.m_Label:SetText("Boss已阵亡，下回合为你结算")
	end
end

--                                                   buff --start
function CWarBossView.InitBossBuffBox(self)
	self.m_BossBuffBox.m_Table = self.m_BossBuffBox:NewUI(1, CTable)
	self.m_BossBuffBox.m_BuffBox = self.m_BossBuffBox:NewUI(2, CBox)
	self.m_BossBuffBox.m_FloatTable = self.m_BossBuffBox:NewUI(3, CTable)
	self.m_BossBuffBox.m_FloatBox = self.m_BossBuffBox:NewUI(4, CFloatBox)
	self.m_BossBuffBox.m_BuffBox:SetActive(false)
	self.m_BossBuffBox.m_FloatBox:SetActive(false)
	self.m_BossBuffBox.m_Buffs = {}
end

function CWarBossView.OnShowDetail(self)
	if self.m_Warrior then
		CWarTargetDetailView:ShowView(function(oView)
				oView:SetWarrior(self.m_Warrior)
			end)
	end
end

function CWarBossView.RefreshBuff(self, buffid, bout, level, bTips)
	local dCurBuff = self.m_BossBuffBox.m_Buffs[buffid]
	local iCurLevel = dCurBuff and dCurBuff.level or 0
	local iNewLevel = (bout<=0) and 0 or level
	local iCnt = iNewLevel - iCurLevel
	if iNewLevel == 0 then
		self.m_BossBuffBox.m_Buffs[buffid] = nil
	else
		self.m_BossBuffBox.m_Buffs[buffid] = {level=level}
	end
	local lBoxes = self.m_BossBuffBox.m_Table:GetChildList()
	if iCnt > 0 then
		local iSilbingIndex
		for i, oBox in ipairs(lBoxes) do
			if oBox.m_BuffID == buffid then
				iSilbingIndex = i
				break
			end
		end
		for i=1, iCnt do
			bTips = bTips and (i==1 and iCurLevel==0)
			local oBox = self:CreateBox(buffid, bTips)
			self.m_BossBuffBox.m_Table:AddChild(oBox, iSilbingIndex)
		end
	elseif iCnt < 0 then
		local lDelList = {}
		for i, oBox in ipairs(lBoxes) do
			if oBox.m_BuffID == buffid then
				table.insert(lDelList, oBox)
				if #lDelList == math.abs(iCnt) then
					break
				end
			end
		end
		for i, oBox in ipairs(lDelList) do
			self.m_BossBuffBox.m_Table:RemoveChild(oBox)
		end
	end
	for i, oBox in ipairs(self.m_BossBuffBox.m_Table:GetChildList()) do
		if oBox.m_BuffID == buffid then
			if bout == define.War.Infinite_Buff_Bout then
				oBox.m_BoutLabel:SetText("")
			else
				oBox.m_BoutLabel:SetText(tostring(bout))
			end
		end
	end
	self.m_BossBuffBox.m_Table:Reposition()
end


function CWarBossView.CreateBox(self, buffid, bTips)
	local oBox = self.m_BossBuffBox.m_BuffBox:Clone()
	oBox:SetActive(true)
	oBox.m_BuffID = buffid
	oBox.m_BoutLabel = oBox:NewUI(1, CLabel)
	oBox.m_BuffSpr = oBox:NewUI(2, CSprite)
	oBox.m_BuffSpr:SpriteBuff(buffid)
	oBox.m_BuffSpr:AddUIEvent("click", callback(self, "OnShowDetail"))
	self.m_BossBuffBox.m_Table:AddChild(oBox)
	local dBuff = data.buffdata.DATA[buffid]
	if bTips and dBuff and dBuff.tips_effect and dBuff.tips_effect ~= "" then
		--self:AddBuffTips(dBuff.tips_effect)
	end
	return oBox
end

function CWarBossView.AddBuffTips(self, text)
	local oBox = self.m_BossBuffBox.m_FloatBox:Clone()
	oBox:SetActive(true)
	oBox:SetText(text)
	--oBox:ResizeBg()
	oBox:SetTimer(2, callback(self, "OnTimerUp"))
	self.m_BossBuffBox.m_FloatTable:AddChild(oBox)
	local v3 = oBox:GetLocalPos()
	oBox:SetLocalPos(Vector3.New(v3.x, v3.y-20, v3.z))
	oBox:SetAsFirstSibling()
end

function CWarBossView.OnTimerUp(self, oBox)
	self.m_BossBuffBox.m_FloatTable:RemoveChild(oBox)
	self.m_BossBuffBox.m_FloatTable:Reposition()
end
--                                                  buff --end

return CWarBossView