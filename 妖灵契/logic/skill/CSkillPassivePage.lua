local CSkillPassivePage = class("CSkillPassivePage", CPageBase)

function CSkillPassivePage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CSkillPassivePage.OnInitPage(self)
	print("初始化被动技能模块")
	self.m_SkillBox = {}
	for i=1,7,1 do
		local Box = self:NewUI(i, CBox)
		table.insert(self.m_SkillBox,Box)
	end
	self.m_CurIndex = 1
	self.m_SkillName = self:NewUI(8, CLabel)
	self.m_SkillDesc = self:NewUI(9, CLabel)
	self.m_SkillType = self:NewUI(10, CLabel)
	self.m_SkillValue = self:NewUI(11, CLabel)
	self.m_NextSkillType = self:NewUI(12, CLabel)
	self.m_NextSkillValue = self:NewUI(13, CLabel)
	self.m_CostBox = self:NewUI(14, CCurrencyBox)
	self.m_SilverBox = self:NewUI(16, CCurrencyBox)
	self.m_EachUpBtn = self:NewUI(18, CButton)
	self.m_AllUpBtn = self:NewUI(19, CButton)
	self.m_Content = self:NewUI(20,CObject)
	self.m_OpenInfoLbl = self:NewUI(21,CLabel)
	self:InitContent()
end

function CSkillPassivePage.InitContent(self)
	self:RefreshSkillBox()

	self.m_CostBox:SetCurrencyType(define.Currency.Type.Silver, true)
	self.m_SilverBox:SetCurrencyType(define.Currency.Type.Silver)

	for k,v in ipairs(self.m_SkillBox) do
		v:AddUIEvent("click", callback(self, "OnSkillSelect"))
	end
	self.m_EachUpBtn:AddUIEvent("click", callback(self, "OnClickEachUpSkill"))
	self.m_AllUpBtn:AddUIEvent("click", callback(self, "OnClickAllUpSkill"))
	g_SkillCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self:DefaultSelect()
end

--协议数据返回
function CSkillPassivePage.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Skill.Event.LoginSkill then
		self:RefreshContent(self.m_CurIndex)
		self:RefreshSkillBox()
	elseif oCtrl.m_EventID == define.Skill.Event.PassiveRefresh then
		self:RefreshContent(self.m_CurIndex)
		self:RefreshSkillBox()
	end
end

--刷新左边技能Box
function CSkillPassivePage.RefreshSkillBox(self)
	for i=1,7,1 do
		local NameLbl = self.m_SkillBox[i]:NewUI(1,CLabel)
		local LockSp = self.m_SkillBox[i]:NewUI(2,CSprite)
		local IconSp = self.m_SkillBox[i]:NewUI(3,CSprite)
		local Widget = self.m_SkillBox[i]:NewUI(4,CWidget)
		local YellowSp = self.m_SkillBox[i]:NewUI(5,CSprite)
		if g_SkillCtrl:GetPassiveSkillList()[i] then
			NameLbl:SetActive(true)
			local Id = g_SkillCtrl:GetPassiveSkillList()[i].sk			
			local NameStr = data.skilldata.PASSIVE[Id].name
			local LevelStr
			local LevelVal
			if not g_SkillCtrl:GetPassiveSkillList()[i].level then
				LevelVal = 0
			else
				LevelVal = g_SkillCtrl:GetPassiveSkillList()[i].level
			end
			LevelStr = " Lv."..LevelVal
			if LevelVal > 0 then				
				IconSp:SetGrey(false)
			else
				IconSp:SetGrey(true)
			end
			NameLbl:SetText(NameStr..LevelStr)
			IconSp:SetActive(true)
			LockSp:SetActive(false)
			Widget:SetGroup(11)
			YellowSp:SetActive(true)
			IconSp:SetSpriteName(tostring(Id))
		else
			NameLbl:SetActive(false)
			IconSp:SetActive(false)
			LockSp:SetActive(true)
			Widget:SetGroup(10)
			YellowSp:SetActive(false)
		end
	end
end

--刷新完技能Box之后默认选中第一个
function CSkillPassivePage.DefaultSelect(self)
	local Box = self.m_SkillBox[1]
	if Box then
		self:OnSkillSelect(Box)
	end
end

--刷新右边被动技能描述
function CSkillPassivePage.RefreshContent(self,pIndex)
	if g_SkillCtrl:GetPassiveSkillList()[pIndex] then
		local Skill = g_SkillCtrl:GetPassiveSkillList()[pIndex]
		local Id = Skill.sk			
		local NameStr = data.skilldata.PASSIVE[Id].name
		local DescStr = data.skilldata.PASSIVE[Id].desc
		local SkillType = data.skilldata.PASSIVE[Id].skilltype
		self.m_SkillName:SetText(NameStr)
		self.m_SkillDesc:SetText(DescStr)
		self.m_SkillType:SetText(SkillType)
		self.m_NextSkillType:SetText(SkillType)	

		--计算被动技能强度
		local Effect = data.skilldata.PASSIVE[Id].skill_effect[1]
		local SkillValue
		local NextSkillValue
		if not Effect then
			SkillValue = 0
			NextSkillValue = 0
		else
			local Index = string.find(Effect,"=") + 1
			local Str = string.sub(Effect,Index,-1)
			local NumStr
			local NextNumStr
			local LevelVal
			if not Skill.level then
				LevelVal = 0
			else
				LevelVal = Skill.level
			end
			if LevelVal > 0 then				
				if Skill.level < data.skilldata.PASSIVE[Id].limit_level then
					NumStr = string.gsub(Str,"level",tostring(Skill.level))
					NextNumStr = string.gsub(Str,"level",tostring(Skill.level+1))
				else
					NumStr = string.gsub(Str,"level",tostring(Skill.level))
					NextNumStr = nil
				end
			else
				NumStr = string.gsub(Str,"level",tostring(1))
				NextNumStr = string.gsub(Str,"level",tostring(2))
			end
			if NumStr then
				local Value = load(string.format([[return (%s)]], NumStr))()
				SkillValue = math.floor(tonumber(Value))
			end
			if NextNumStr then
				local Value = load(string.format([[return (%s)]], NextNumStr))()
				NextSkillValue = math.floor(tonumber(Value))
			else
				NextSkillValue = "当前已达最高等级"
			end
		end
		self.m_SkillValue:SetText(SkillValue)
		self.m_NextSkillValue:SetText(string.format("#G%s#n",NextSkillValue))

		if not Skill.level or Skill.level <= 0 then
			self.m_Content:SetActive(false)			
			self.m_OpenInfoLbl:SetActive(true)
			self.m_OpenInfoLbl:SetText(DataTools.GetPassiveSkillData(Id).open_level.."级开启")
		else
			if Skill.level >= data.skilldata.PASSIVE[Id].limit_level then
				self.m_Content:SetActive(false)
				self.m_OpenInfoLbl:SetActive(true)
				self.m_OpenInfoLbl:SetText("当前已达最高等级")
			else
				self.m_Content:SetActive(true)
				self.m_OpenInfoLbl:SetActive(false)		
			end
		end

		self:RefreshCost(Skill.needcost)
	end
end

--刷新右边消耗和金钱
function CSkillPassivePage.RefreshCost(self,pCost)
	self.m_CostBox:SetCurrencyCount(pCost)
	self.m_SilverBox:SetWarningValue(pCost)
end

--点击事件，点击选择某个技能Box
function CSkillPassivePage.OnSkillSelect(self, pBox)
	local Index = tonumber(string.sub(pBox:GetName(),-1,-1))
	pBox:SetSelected(true)

	if not g_SkillCtrl:GetPassiveSkillList()[Index] then
		g_NotifyCtrl:FloatMsg("技能尚未开放，敬请期待")
	else
		self.m_CurIndex = Index
		self:RefreshContent(Index)
	end
end

--点击事件，点击单个升级
function CSkillPassivePage.OnClickEachUpSkill(self)
	netskill.C2GSLearnSkill(define.Skill.Type.PassiveSkill, g_SkillCtrl:GetPassiveSkillList()[self.m_CurIndex].sk)
end

--点击事件，点击一键升级
function CSkillPassivePage.OnClickAllUpSkill(self)
	netskill.C2GSFastLearnSkill(define.Skill.Type.PassiveSkill)
end

return CSkillPassivePage