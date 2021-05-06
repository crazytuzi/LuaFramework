local CWarRB = class("CWarRB", CBox)

function CWarRB.ctor(self, obj)
	CBox.ctor( self, obj)
	self.m_MagicMenu = self:NewUI(1, CWarMagicMenu)
	self.m_AutoMenu = self:NewUI(2, CWarAutoMenu)
	self.m_SpSlider = self:NewUI(3, CSlider)
	self.m_BgSprite = self:NewUI(4, CSprite)
	self.m_FengGeGrid = self:NewUI(5, CGrid)
	self.m_SpeedBox = self:NewUI(6, CBox)
	self.m_ForeBgSpr = self:NewUI(7, CSprite)
	self.m_ForeSpr = self:NewUI(8, CSprite)
	self.m_ForeSpr1 = self:NewUI(9, CSprite)
	self.m_ForeSpr2 = self:NewUI(10, CSprite)
	self.m_Sp = nil
	self.m_RotateSpeed = nil
	self.m_AutoMenu:SetParentView(self)
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	self.m_FengGeGrid:InitChild(function(obj, idx)
		local oSprite = CSprite.New(obj)
		oSprite.m_Idx = idx
		oSprite.m_NeedValue = idx * 20
		return oSprite
	end)
	self.m_SpeedBox.m_Btn = self.m_SpeedBox:NewUI(1, CButton)
	self.m_SpeedBox.m_X1Sprite = self.m_SpeedBox:NewUI(2, CSprite)
	self.m_SpeedBox.m_X2Sprite = self.m_SpeedBox:NewUI(3, CSprite)
	self.m_SpeedBox.m_LockSprite = self.m_SpeedBox:NewUI(4, CSprite)
	self.m_SpeedBox.m_Btn:AddUIEvent("click", callback(self, "OnChangeSpeed"))
	g_GuideCtrl:AddGuideUI("war_speed_btn", self.m_SpeedBox.m_Btn)		
	g_GuideCtrl:AddGuideUI("war_fore_bg_sprite", self.m_ForeSpr)		
	self.m_SpeedBox:InitUITwener(true)
	local rootW, rootH = UITools.GetRootSize()
	self.m_EffRatio = 1/1334*rootW
	self:DelayCall(0, "RefreshSpeedBox")
	self:RefreshSP()
	self:SetActive(false)
end

function CWarRB.CheckSpeedBoxShow(self)
	if self:IsCanShowSpeed() then
		-- self.m_SpeedBox.m_LockSprite:SetActive(g_AttrCtrl.grade < 4)
		self.m_SpeedBox:SetActive(true)
		--self:RefreshSpeedBox()
	else
		self.m_SpeedBox:SetActive(false)
	end
end

function CWarRB.IsCanShowSpeed(self)
	local types = define.War.Type
	local wartype = g_WarCtrl:GetWarType()
	if wartype == types.PVP or 
		wartype == types.FieldBossPVP or 
		wartype == types.Arena or
		wartype == types.EqualArena or
		wartype == types.TeamPvp or
		wartype == types.Guide3 or
		wartype == types.Terrawar then
		return false
	end
	if g_WarCtrl.m_EnemyPlayerCnt > 0 then
		--用敌人是玩家判断
		return false
	end
	return true
end

function CWarRB.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.AutoWar then
		-- if not g_ShowWarCtrl:IsShowWar() and not g_WarOrderCtrl:IsCanOrder() and not oCtrl:IsAutoWar() then
			-- if g_WarCtrl:GetWarType() ~= define.War.Type.Guide1 and g_WarCtrl:GetWarType() ~= define.War.Type.Guide2 then
				-- g_NotifyCtrl:FloatMsg("已取消自动战斗，下回合可操作")
		-- 	end
		-- end
		self:DelayCall(0, "CheckShow")
		self:DelayCall(0, "RefreshSpeedBox")
	elseif oCtrl.m_EventID == define.War.Event.AutoMagic or oCtrl.m_EventID == define.War.Event.PartnerChange then
		self.m_AutoMenu:DelayUpdateMenu()
	elseif oCtrl.m_EventID == define.War.Event.Replace or oCtrl.m_EventID == define.War.Event.Pause then
		self:DelayCall(0, "CheckShow")
	elseif oCtrl.m_EventID == define.War.Event.SP then
		if oCtrl.m_EventData.ally then
			self:RefreshSP()
		end
	elseif oCtrl.m_EventID == define.War.Event.PlaySpeed then
		self:DelayCall(0, "RefreshSpeedBox")
	end  
end

function CWarRB.OnChangeSpeed(self)
	-- if g_AttrCtrl.grade < 4 then
	-- 	g_NotifyCtrl:FloatMsg("4级开启战斗加速")
	-- 	return 
	-- end
	if g_TeamCtrl:IsJoinTeam() then
		if not g_TeamCtrl:IsLeader() and not g_TeamCtrl:IsLeave(g_AttrCtrl.pid) then
			g_NotifyCtrl:FloatMsg("战斗加速同步队长的加速状态，请让队长进行修改")
			return 
		end
	end
	local iSpeed = g_WarCtrl:GetAnimSpeed()
	if iSpeed == 1 then
		iSpeed = 2
	elseif iSpeed == 2 then
		iSpeed = 1
	end
	g_WarCtrl:SetAnimSpeed(iSpeed)
	if g_GuideCtrl:IsInTargetGuide("WarSpeed") then
		g_GuideCtrl:CompleteWarSpeedGuide()
	end
	--self:RefreshSpeedBox()
end

function CWarRB.RefreshSpeedBox(self)
	if g_WarCtrl:IsCanChangeSpeed() then 
		if g_WarCtrl:IsAutoWar() then
			self.m_SpeedBox:UITweenEnabled(true)
		else
			self.m_SpeedBox:UITweenEnabled(false)
		end
		local iSpeed = g_WarCtrl:GetAnimSpeed()
		if self.m_RotateSpeed and self.m_RotateSpeed == iSpeed then
			return
		end
		self.m_RotateSpeed = iSpeed
		local bX1 = (iSpeed == 1)
		self.m_SpeedBox.m_X1Sprite:SetActive(bX1)
		self.m_SpeedBox.m_X2Sprite:SetActive(not bX1)
		self.m_SpeedBox:SetUITweenDuration(3/math.max(1, iSpeed*0.7))
		g_GuideCtrl:CheckWarSpeedGuide(iSpeed)
	end
end


function CWarRB.RefreshSP(self)
	if self.m_Sp == g_WarCtrl:GetSP() then
		return
	end
	self.m_Sp = g_WarCtrl:GetSP()
	self.m_SpSlider:SetValue(self.m_Sp/100, 0)
	self.m_SpSlider:SetSliderText(string.format("x%d", math.floor(self.m_Sp/20)))
	self:ShowSpEffect(self.m_Sp >= 100)

	for i,oSprite in ipairs(self.m_FengGeGrid:GetChildList()) do
		if self.m_Sp >= oSprite.m_NeedValue then
			oSprite:SetSpriteName("pic_nuqitiao_fenge")
		else
			oSprite:SetSpriteName("pic_nuqitiao_fenge2")
		end
	end
end

function CWarRB.ShowSpEffect(self, bShow)
	if bShow then
		self.m_ForeSpr:AddEffectByPath("warsp", "Effect/UI/ui_eff_1158/Prefabs/ui_eff_1158_weimange.prefab", Vector3.New(0, 0, 0), Vector3.New(self.m_EffRatio, 1, 1))
		self.m_ForeSpr1:AddEffectByPath("warsp", "Effect/UI/ui_eff_1158/Prefabs/ui_eff_1158_mange_huo.prefab", Vector3.New(0, 0, 0))
		self.m_ForeSpr2:AddEffectByPath("warsp", "Effect/UI/ui_eff_1158/Prefabs/ui_eff_1158_mange_huo_02.prefab", Vector3.New(0, 0, 0))
		self.m_ForeSpr:RecaluatePanelDepth("warsp")
		self.m_ForeSpr1:RecaluatePanelDepth("warsp")
		self.m_ForeSpr2:RecaluatePanelDepth("warsp")
	else
		self.m_ForeSpr:DelEffectByPath("warsp")
		self.m_ForeSpr1:DelEffectByPath("warsp")
		self.m_ForeSpr2:DelEffectByPath("warsp")
	end
end

function CWarRB.CheckShow(self)
	self:StopDelayCall("CheckShow")
	if not g_ShowWarCtrl:IsCanOperate() then
		return
	end
	
	local bHideTips = true
	if g_WarCtrl:IsObserverView() then
		self.m_AutoMenu:SetActive(false)
		self.m_MagicMenu:SetActive(false)
	elseif g_WarCtrl:IsReplace() then
		self:SetActive(false)
	else
		self:SetActive(not g_WarCtrl:IsWarStart())
		local bOrder = g_WarOrderCtrl:IsCanOrder()
		local bAutoWar = g_WarCtrl:IsAutoWar()
		--self.m_AutoMenu:SetActive(bOrder or bAutoWar)
		self.m_AutoMenu:DelayUpdateMenu()
		if bOrder and not bAutoWar then
			self.m_MagicMenu:SetActive(true)
			self.m_MagicMenu:UpdateMenu()
		else
			self.m_MagicMenu:SetActive(false)
			self.m_MagicMenu:UpdateMenu()
		end
		bHideTips = false
	end

	if bHideTips then
		local oView = CWarFloatView:GetView()
		if oView then
			oView:HideMagicDesc()
		end
	end
	self:CheckSpeedBoxShow()
	self:RefreshBgSpriteSize()
end

function CWarRB.RefreshBgSpriteSize(self)
	local count2size = {
		[0] = {w=600, h=138},
		[1] = {w=640, h=138},
		[2] = {w=750, h=138},
		[3] = {w=860, h=138},
		[4] = {w=970, h=138},
		[5] = {w=1080, h=138},
	}
	local count2pos = {
		[0] = {x=-405, y=20},
		[1] = {x=-445, y=20},
		[2] = {x=-555, y=20},
		[3] = {x=-665, y=20},
		[4] = {x=-775, y=20},
		[5] = {x=-885, y=20},
	}
	local count
	if self.m_MagicMenu:GetActive() then
		count = self.m_MagicMenu:GetMagicBoxCount()
	elseif self.m_AutoMenu:GetActive() then
		count = self.m_AutoMenu:GetMagicBoxCount()
	end
	count = count or 0
	count = math.min(count, 5)
	self.m_BgSprite:SetSize(count2size[count].w, count2size[count].h)
	self.m_SpSlider:SetLocalPos(Vector3.New(count2pos[count].x, count2pos[count].y, 0))
end

return CWarRB