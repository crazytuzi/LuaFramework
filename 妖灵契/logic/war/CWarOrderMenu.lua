local CWarOrderMenu = class("CWarOrderMenu", CBox)

function CWarOrderMenu.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_HBtnGrid = self:NewUI(1, CGrid) --横着的按钮


	self.m_HBtnGrid:InitChild(function (obj, idx) return CButton.New(obj) end)
	self.m_PauseBtn = self.m_HBtnGrid:GetChild(1)
	self.m_EscapeBtn = self.m_HBtnGrid:GetChild(2)
	-- self.m_ReplaceBtn = self.m_HBtnGrid:GetChild(3)

	self:InitContent() 
end

CWarOrderMenu.ReplaceGrade = 12
function CWarOrderMenu.InitContent(self)
	self.m_EscapeBtn:AddUIEvent("click", callback(self, "OnEscape"))
	
	-- self.m_ReplaceBtn:AddUIEvent("click", callback(self, "OnRepalce"))
	self.m_PauseBtn:AddUIEvent("click", callback(self, "OnPause"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))

	-- g_GuideCtrl:AddGuideUI("war_replace_btn", self.m_ReplaceBtn)
	-- self.m_ReplaceBtn:SetActive(false)
	-- self.m_ReplaceBtn:SetActive(g_AttrCtrl.grade >= CWarOrderMenu.ReplaceGrade)
	self:UpdateMenu()
end

function CWarOrderMenu.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.Pause then
		self:RefreshPauseBtn()
	end
end

function CWarOrderMenu.SetActive(self, bActive)
	CObject.SetActive(self, bActive)
	if bActive then
		self:UpdateMenu()
	end
end

function CWarOrderMenu.UpdateMenu(self)
	local lIgnore = {
		define.War.Type.PVP,
		define.War.Type.Arena,
		define.War.Type.EqualArena,
		define.War.Type.TeamPvp,
		define.War.Type.FieldBossPVP,
		define.War.Type.Terrawar,
		define.War.Type.Boss,
		define.War.Type.BossKing,
		define.War.Type.OrgBoss,
		define.War.Type.FieldBoss,
		define.War.Type.MonsterAtkCity,
	}
	local bIgnore = not table.index(lIgnore, g_WarCtrl:GetWarType())
	self.m_PauseBtn:SetActive((not g_WarCtrl:IsGuideWar()) and (g_WarCtrl.m_AllyPlayerCnt <= 1) and bIgnore)
	self.m_HBtnGrid:Reposition()
	self:RefreshPauseBtn()
end

function CWarOrderMenu.RefreshPauseBtn(self)
	if self.m_PauseBtn:GetActive() then
		if not g_WarCtrl:IsGuideWar() then
			if g_WarCtrl:IsPause() then
				local oView = CWarFloatView:GetView()
				if oView then
					oView:ShowFliter("继续战斗", callback(self, "OnPause", self.m_PauseBtn))
				end
			else
				local oView = CWarFloatView:GetView()
				if oView then
					oView:CloseFliterWidget()
				end
			end
		end
	end
end

function CWarOrderMenu.OnShowDesc(self, oBox, bPress)
	if bPress then
		self:ShowBoxDesc(oBox)
	end
end

function CWarOrderMenu.OnEscape(self, oBtn)
	if g_WarCtrl:GetWarType() == define.War.Type.Guide3 and g_WarCtrl.m_ProtoBout <= 2 then		
		g_NotifyCtrl:FloatMsg("等会，要跑等我两回合。")
		return 
	end

	if g_WarCtrl:GetWarType() == define.War.Type.Guide1 and not g_GuideCtrl:IsCustomGuideFinishByKey("Partner_FWCD_One_MainMenu") then				
		g_NotifyCtrl:FloatMsg("乖哈，打完这波小坏蛋就任你调戏")
		return 		
	end	

	if g_WarCtrl:GetWarType() == define.War.Type.Guide2 and not g_GuideCtrl:IsCustomGuideFinishByKey("Partner_FWCD_Two_MainMenu") then				
		g_NotifyCtrl:FloatMsg("乖哈，打完这波小坏蛋就任你调戏")
		return 		
	end		

	if g_WarCtrl:GetWarType() == define.War.Type.EndlessPVE then		
		if g_GuideCtrl:IsCustomGuideFinishByKey("YueJian") == true and g_GuideCtrl:IsCustomGuideFinishByKey("YueJianWarMainMenuAfter") == false and g_EndlessPVECtrl:GetAwardCount() < 2 then
			g_NotifyCtrl:FloatMsg("乖哈，打完这波小坏蛋就任你调戏")
			return 
		end		
	end

	if g_WarCtrl:IsAutoWar() then
		local msgStr = "下回合将退出战斗"
		local t = {
			msg = msgStr,
			okCallback = callback(g_WarOrderCtrl, "SetOrder", "Escape"),
		}
		g_WindowTipCtrl:SetWindowConfirm(t)
	else
		local msgStr = "逃跑将视为战斗失败，无法获得战斗奖励\n确认逃跑吗？"
		local t = {
			msg = msgStr,
			okCallback = callback(g_WarOrderCtrl, "SetOrder", "Escape"),
		}
		if g_WarCtrl:GetWarType() == define.War.Type.Arena 
			or g_WarCtrl:GetWarType() == define.War.Type.EndlessPVE 
			or g_WarCtrl:GetWarType() == define.War.Type.EqualArena 
			or g_WarCtrl:GetWarType() == define.War.Type.TeamPvp 
			or g_WarCtrl:GetWarType() == define.War.Type.Convoy
			or g_WarCtrl:GetWarType() == define.War.Type.ClubArena then
			t.msg = "逃跑将视为战斗失败，确认逃跑吗？"
			t.pivot = enum.UIWidget.Pivot.Center
		end
		g_WindowTipCtrl:SetWindowConfirm(t)
	end
end

function CWarOrderMenu.OnRepalce(self, oBtn)
	g_GuideCtrl:FinishWarReplaceGuide()
	
	if g_WarCtrl:IsAutoWar() then
		g_NotifyCtrl:FloatMsg("手动模式下才可进行替换，请先取消自动")
		return
	end
	if g_WarCtrl:IsInAction() and not g_WarOrderCtrl:IsCanOrder() then
		g_NotifyCtrl:FloatMsg("回合已经开始，下回合才能使用噢")
		return
	end
	if g_WarCtrl:IsAllPartnerDead() then
		g_NotifyCtrl:FloatMsg("伙伴已全部阵亡")
		return
	end
	local iCnt = 0
	for _, wid in pairs(g_WarCtrl.m_AlreadyWarPartner) do
		if wid > 0 then
			iCnt = iCnt + 1
		end 
	end
	if iCnt >= 4 then
		g_NotifyCtrl:FloatMsg("最多上场4个伙伴")
	else
		g_WarCtrl:SetReplace(true)
	end
end

function CWarOrderMenu.OnPause(self, oBtn)
	if g_WarCtrl:IsAutoWar() then
		g_NotifyCtrl:FloatMsg("手动模式下才可暂停，请先取消自动")
		return
	end
	if g_WarCtrl:IsInAction() and not g_WarOrderCtrl:IsCanOrder() then
		g_NotifyCtrl:FloatMsg("回合已经开始，下回合才能使用")
		return
	end
	if g_WarCtrl:IsPause() then
		netwar.C2GSWarStart(g_WarCtrl:GetWarID())
	else
		netwar.C2GSWarStop(g_WarCtrl:GetWarID())
	end
end

return CWarOrderMenu