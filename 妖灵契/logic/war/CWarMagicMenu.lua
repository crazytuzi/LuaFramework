local CWarMagicMenu = class("CWarMagicMenu", CBox)

function CWarMagicMenu.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_MagicGrid = self:NewUI(1, CGrid)
	self.m_MagicBoxClone = self:NewUI(2, CBox)

	self:InitContent() 
end

function CWarMagicMenu.InitContent(self)
	self.m_MagicBoxClone:SetActive(false)
	self:UpdateMenu()
end

function CWarMagicMenu.UpdateMenu(self)
	if self:GetActive() then
		self:RefreshMagicGrid()
	end
end

function CWarMagicMenu.RefreshMagicGrid(self)
	-- self.m_MagicGrid:Clear()
	local sKey = "CWarMagicMenu.MagicBox"
	self.m_MagicGrid:Recycle(function(o) return {magic=o.m_ID} end)
	local magiclist = self:GetMagicList()
	local wid = g_WarOrderCtrl:GetOrderWid()
	self.m_CurSelMagic = nil
	local oGuideBox1, oGuideBox2
	self.m_MagicGrid:SetRepositionLaterEnable(false)
	local oWarrior = g_WarCtrl:GetWarrior(wid)
	for i, magicid in ipairs(magiclist) do
		local oBox = g_ResCtrl:GetObjectFromCache(sKey, {magic=magicid})
		if not oBox then
			oBox = self.m_MagicBoxClone:Clone()
			oBox:SetActive(true)
			oBox.m_IconSpr = oBox:NewUI(1, CSprite)
			oBox.m_BoutLabel = oBox:NewUI(3, CLabel)
			oBox.m_SpLabel = oBox:NewUI(4, CLabel)
			oBox.m_LockSpr = oBox:NewUI(5, CSprite)
			oBox:SetCacheKey(sKey)
			
		end
		oBox:AddUIEvent("click", callback(self, "OnMagic"))
		oBox.m_ID = magicid
		oBox.m_Level = g_WarCtrl:GetMagicLevel(wid, magicid)
		oBox:SetGroup(self.m_MagicGrid:GetInstanceID())
		oBox:ForceSelected(false)
		oBox.m_IconSpr:SpriteMagic(oBox.m_ID)
		local dSkillData = g_SkillCtrl:GetSkillBaseDataById(magicid)
		if dSkillData and dSkillData.unlock_grade then
			oBox.m_GradeLock = dSkillData.unlock_grade > g_AttrCtrl.grade
		else
			oBox.m_GradeLock = false
		end
		oBox.m_BuffSpLock = false

		
		local dData = DataTools.GetMagicData(magicid)
		oBox.m_CD = g_WarCtrl:GetMagicCD(wid, magicid)
		local bInCD = (oBox.m_CD > 0)
		if bInCD then
			oBox.m_BoutLabel:SetText(tostring(oBox.m_CD))
			oBox.m_IconSpr:SetGrey(true)
		else
			oBox.m_IconSpr:SetGrey(false)
			oBox.m_BoutLabel:SetText("")
		end
		oBox.m_SpEnough = true
		if dData and dData.sp and dData.sp > 0 then
			oBox.m_SpLabel:SetActive(true)
			oBox.m_SpLabel:SetText(tostring(dData.sp/20))
			local bEnough = (g_WarCtrl:GetSP() >= dData.sp)
			if not bEnough then
				oBox.m_SpEnough = bEnough
				if not bInCD then
					oBox.m_IconSpr:SetColor(Color.New(0.3,0.3,0.3,1))
				end
			end

			if oWarrior and oWarrior:HasBanSpBuff() then
				oBox.m_BuffSpLock = true
			end
		else
			oBox.m_SpLabel:SetActive(false)
		end 
		oBox.m_LockSpr:SetActive(oBox.m_GradeLock or oBox.m_BuffSpLock)
		self.m_MagicGrid:AddChild(oBox)
		if i == 1 then
			oGuideBox1 = oBox
		elseif i == 2 then
			oGuideBox2 = oBox			
		end
	end
	self.m_MagicGrid:Reposition()
	g_GuideCtrl:AddGuideUI("war_skill_box1", oGuideBox1)
	g_GuideCtrl:AddGuideUI("war_skill_box2", oGuideBox2)
	self.m_MagicGrid:SetRepositionLaterEnable(true)
	self:DelayCall(0, "DefaultMagic")
end

function CWarMagicMenu.DefaultMagic(self)
	local wid = g_WarOrderCtrl:GetOrderWid()
	local oWarrior = g_WarCtrl:GetWarrior(wid)
	local iLastMagic = g_WarOrderCtrl:GetLastMagicID(wid)
	local oDefalutBox, oLastBox
	for i, oBox in ipairs(self.m_MagicGrid:GetChildList()) do
		local bValid = oBox.m_SpEnough and (oBox.m_CD == 0) and (not oBox.m_LockSpr:GetActive())
		if oBox.m_ID == iLastMagic and bValid then
			oLastBox = oBox
			break
		end
		if not oDefalutBox and  bValid then
			oDefalutBox = oBox
		end
	end
	local oSelBox = oLastBox or oDefalutBox
	if oSelBox then
		self.m_CurSelMagic = oSelBox.m_ID
		self:ShowBoxDesc(oSelBox)
		oSelBox:SetSelected(true)
		g_WarOrderCtrl:SetOrder("Magic", oSelBox.m_ID)
		g_WarCtrl:C2GSSelectCmd(g_WarCtrl:GetWarID(), wid, oSelBox.m_ID)
	end
	self:RefreshMagicIconPos()
end

function CWarMagicMenu.OnShowDesc(self, oBox, bPress)
	if bPress then
		self:ShowBoxDesc(oBox)
	end
end

function CWarMagicMenu.ShowBoxDesc(self, oBox)
	if not self:GetActiveHierarchy() then
		return
	end
	local oView = CWarFloatView:GetView()
	if oView then
		local oDescBox = oView:ShowMagicDesc(oBox.m_ID, oBox.m_Level)
		local list = self.m_MagicGrid:GetChildList()
		if next(list) then
			oBox = list[1]
			UITools.NearTarget(oBox, oDescBox, enum.UIAnchor.Side.TopLeft)
		else
			oDescBox:SetLocalPos(Vector3.zero)
		end
	end
end

function CWarMagicMenu.OnMagic(self, oBox)
	if oBox.m_GradeLock then
		g_NotifyCtrl:FloatMsg("技能未解锁")
		return
	end
	if oBox.m_BuffSpLock then
		g_NotifyCtrl:FloatMsg("异常状态中, 无法使用怒气技")
		return
	end
	self:ShowBoxDesc(oBox)
	if oBox.m_CD > 0 then
		g_NotifyCtrl:FloatMsg("技能冷却中")
		return
	end

	if not oBox.m_SpEnough then
		g_NotifyCtrl:FloatMsg("怒气不足")
		return
	end
	self.m_CurSelMagic = oBox.m_ID
	oBox:ForceSelected(true)
	g_WarOrderCtrl:SetOrder("Magic", oBox.m_ID)
	local wid = g_WarOrderCtrl:GetOrderWid()
	g_WarOrderCtrl:ChangeAutoMagicByWid(wid, oBox.m_ID)
	g_WarCtrl:C2GSSelectCmd(g_WarCtrl:GetWarID(), wid, oBox.m_ID)
	self:RefreshMagicIconPos()
	--新手特殊处理
	g_GuideCtrl.m_war3_step_two_1_click = true
end

function CWarMagicMenu.RefreshMagicIconPos(self)
	for i, oBox in ipairs(self.m_MagicGrid:GetChildList()) do
		if oBox.m_ID == self.m_CurSelMagic then
			oBox.m_IconSpr:SetLocalPos(Vector3.New(0, 15, 0))
		else
			oBox.m_IconSpr:SetLocalPos(Vector3.zero)
		end
	end
end

function CWarMagicMenu.GetMagicList(self)
	local wid = g_WarOrderCtrl:GetOrderWid()
	return g_WarCtrl:GetMagicList(wid)
end

function CWarMagicMenu.GetMagicBoxCount(self)
	return self.m_MagicGrid:GetCount()
end

return CWarMagicMenu