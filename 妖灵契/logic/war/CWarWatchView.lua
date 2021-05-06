local CWarWatchView = class("CWarWatchView", CViewBase)

function CWarWatchView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarWatchView.prefab", cb)

	self.m_GroupName = "WarMain"
	self.m_DepthType = "Menu"
end

function CWarWatchView.OnCreateView(self)
	self.m_AllySpeedBox = self:NewUI(1, CWarSpeedControlBox)
	-- self.m_EnemySpeedBox = self:NewUI(2, CWarSpeedControlBox)

	self.m_AllySPSlider = self:NewUI(3, CSlider)
	self.m_EnemySPSlider = self:NewUI(4, CSlider)

	self.m_QuitBtn = self:NewUI(5, CButton)
	self.m_Container = self:NewUI(6, CWidget)
	self.m_BoutLabel = self:NewUI(7, CLabel)
	self.m_Texture = self:NewUI(8, CTexture)
	self.m_Container = self:NewUI(9, CWidget)
	self.m_TerraWarQueueBtn = self:NewUI(10, CButton)
	self.m_BgSprite = self:NewUI(11, CSprite)
	self.m_ChatBox = self:NewUI(12, CWarMenuChatBox)
	self.m_FengGeGridA = self:NewUI(14, CGrid)
	self.m_FengGeGridE = self:NewUI(15, CGrid)
	self.m_ForeSprA = self:NewUI(16, CSprite)
	self.m_ForeSprA1 = self:NewUI(17, CSprite)
	self.m_ForeSprA2 = self:NewUI(18, CSprite)
	self.m_ForeSprE = self:NewUI(19, CSprite)
	self.m_ForeSprE1 = self:NewUI(20, CSprite)
	self.m_ForeSprE2 = self:NewUI(21, CSprite)
	self:InitContent()
end

function CWarWatchView.InitContent(self)
	self.m_FengGeGridA:InitChild(function(obj, idx)
		local oSprite = CSprite.New(obj)
		oSprite.m_Idx = idx
		oSprite.m_NeedValue = idx * 20
		return oSprite
	end)
	self.m_FengGeGridE:InitChild(function(obj, idx)
	 	local oSprite = CSprite.New(obj)
	 	oSprite.m_Idx = idx
 		oSprite.m_NeedValue = idx * 20
	 	return oSprite
	end)

	self.m_TerraWarQueueBtn:SetActive(g_WarCtrl:GetWarType() == define.War.Type.Terrawar)
	self.m_TerraWarQueueBtn:AddUIEvent("click", callback(self, "OnWait"))
	self.m_QuitBtn:AddUIEvent("click", callback(self, "OnQuit"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
	-- self.m_EnemySpeedBox:SetAlly(false)
	-- self.m_EnemySpeedBox:SetXFactor(-1)
	-- self.m_EnemySpeedBox:RefreshSpeedList()
	-- self.m_AllySPSlider:UseClipPanel()
	-- self.m_EnemySPSlider:UseClipPanel()
	-- self.m_EnemySPSlider:SetRightToLeft()
	self.m_AllySPSlider:SetValue(0)
	self.m_EnemySPSlider:SetValue(0)
	self.m_AllySPSlider:SetSliderText("0/5")
	self.m_EnemySPSlider:SetSliderText("0/5")
	local rootW, rootH = UITools.GetRootSize()
	local ratio = 1/1334*rootW
	UITools.ResizeToRootSize(self.m_Container)
	UITools.ResizeToRootSize(self.m_Texture)
end


function CWarWatchView.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.SP then
		self:RefreshSP(oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.War.Event.BoutStart then
		local s = string.format("第%d回合", g_WarCtrl:GetBout())
		self.m_BoutLabel:SetText(s)
	end
end

function CWarWatchView.RefreshSP(self, dData)
	local oSlider, oFengGeGrid
	local sp = dData.sp
	if dData.ally then
		oSlider = self.m_AllySPSlider
		oFengGeGrid = self.m_FengGeGridA
		self:ShowSpEffect(true, sp >= 100)
	else
		oSlider = self.m_EnemySPSlider
		oFengGeGrid = self.m_FengGeGridE
		self:ShowSpEffect(false, sp >= 100)
	end
	for i,oSprite in ipairs(oFengGeGrid:GetChildList()) do
		if sp >= oSprite.m_NeedValue then
			oSprite:SetSpriteName("pic_nuqitiao_fenge")
		else
			oSprite:SetSpriteName("pic_nuqitiao_fenge2")
		end
	end
	oSlider:SetValue(sp/100, 0)
	oSlider:SetSliderText(string.format("%d/5", math.floor(sp/20)))
end

function CWarWatchView.ShowSpEffect(self, bAlly, bShow)
	if bAlly then
		if bShow then
			self.m_ForeSprA:AddEffectByPath("warspA", "Effect/UI/ui_eff_1158/Prefabs/ui_eff_1158_weimange.prefab", Vector3.New(0, 0, 0))
			self.m_ForeSprA1:AddEffectByPath("warspA", "Effect/UI/ui_eff_1158/Prefabs/ui_eff_1158_mange_huo.prefab", Vector3.New(0, 0, 0))
			self.m_ForeSprA2:AddEffectByPath("warspA", "Effect/UI/ui_eff_1158/Prefabs/ui_eff_1158_mange_huo_02.prefab", Vector3.New(0, 0, 0))
			self.m_ForeSprA:RecaluatePanelDepth("warspA")
			self.m_ForeSprA1:RecaluatePanelDepth("warspA")
			self.m_ForeSprA2:RecaluatePanelDepth("warspA")
		else
			self.m_ForeSprA:DelEffectByPath("warspA")
			self.m_ForeSprA1:DelEffectByPath("warspA")
			self.m_ForeSprA2:DelEffectByPath("warspA")
		end
	else
		if bShow then
			self.m_ForeSprE:AddEffectByPath("warspE", "Effect/UI/ui_eff_1158/Prefabs/ui_eff_1158_weimange.prefab", Vector3.New(0, 0, 0))
			self.m_ForeSprE1:AddEffectByPath("warspE", "Effect/UI/ui_eff_1158/Prefabs/ui_eff_1158_mange_huo.prefab", Vector3.New(-45, 0, 0))
		 	self.m_ForeSprE2:AddEffectByPath("warspE", "Effect/UI/ui_eff_1158/Prefabs/ui_eff_1158_mange_huo_02.prefab", Vector3.New(0, 0, 0))
		 	self.m_ForeSprE:RecaluatePanelDepth("warspE")
		 	self.m_ForeSprE1:RecaluatePanelDepth("warspE")
		 	self.m_ForeSprE2:RecaluatePanelDepth("warspE")
		else
		 	self.m_ForeSprE:DelEffectByPath("warspE")
		 	self.m_ForeSprE1:DelEffectByPath("warspE")
		 	self.m_ForeSprE2:DelEffectByPath("warspE")
		end
	end
end

function CWarWatchView.OnQuit(self)
	netplayer.C2GSLeaveWatchWar()
	g_WarCtrl:End()
end

function CWarWatchView.OnWait(self)
	nethuodong.C2GSGetListInfo(g_WarCtrl:GetWarID())
end

return CWarWatchView