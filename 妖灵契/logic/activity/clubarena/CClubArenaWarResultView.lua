local CClubArenaWarResultView = class("CClubArenaWarResultView", CViewBase)

function CClubArenaWarResultView.ctor(self, ob)
	CViewBase.ctor(self, "UI/Activity/ClubArena/ClubArenaWarResultView.prefab", ob)
	self.m_ExtendClose = "Black"
end

function CClubArenaWarResultView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_DelayCloseLabel = self:NewUI(2, CLabel)
	self.m_DescLabel = self:NewUI(3, CLabel)
	self.m_Win = self:NewUI(4, CObject)
	self.m_Fail = self:NewUI(5, CObject)
	self.m_End = self:NewUI(6, CObject)
	self.m_PlayerBox = self:NewUI(7, CBox)
	self.m_EnemyBox = self:NewUI(8, CBox)

	self.m_DelayCloseLabel:SetActive(false)
	self:InitContent()
end
function CClubArenaWarResultView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_WinEffect = CEffect.New("Effect/UI/ui_eff_1159/Prefabs/ui_eff_1159_shengli.prefab", self:GetLayer(), false)
	self.m_WinEffect:SetParent(self.m_Win.m_Transform)
	self.m_FailEffect = CEffect.New("Effect/UI/ui_eff_1159/Prefabs/ui_eff_1159_shibai.prefab", self:GetLayer(), false)
	self.m_FailEffect:SetParent(self.m_Fail.m_Transform)
	self.m_EndEffect = CEffect.New("Effect/UI/ui_eff_1159/Prefabs/ui_eff_1159_zhandoujieshu.prefab", self:GetLayer(), false)
	self.m_EndEffect:SetParent(self.m_End.m_Transform)
	self.m_WinEffect:SetLocalPos(Vector3.New(0, 220, 0))
	self.m_FailEffect:SetLocalPos(Vector3.New(0, 220, 0))
	self.m_EndEffect:SetLocalPos(Vector3.New(0, 220, 0))
	self:InitInfoBox(self.m_PlayerBox)
	self:InitInfoBox(self.m_EnemyBox)

	g_ClubArenaCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarEvnet"))
	netopenui.C2GSOpenInterface(define.OpenInterfaceType.WarResult)
end

function CClubArenaWarResultView.InitInfoBox(self, oInfoBox)
	oInfoBox.m_BgDiwenSpr = oInfoBox:NewUI(1, CSprite)
	oInfoBox.m_JianTouSpr = oInfoBox:NewUI(2, CSprite)
	oInfoBox.m_GuanZhuSpr = oInfoBox:NewUI(3, CSprite)
	oInfoBox.m_PlayerSpr = oInfoBox:NewUI(4, CSprite)
	oInfoBox.m_GradeLabel = oInfoBox:NewUI(5, CLabel)
	oInfoBox.m_NameLabel = oInfoBox:NewUI(6, CLabel)
	oInfoBox.m_ClubLabel = oInfoBox:NewUI(7, CLabel)
	oInfoBox.m_GradeLabel:SetActive(false)
	oInfoBox.m_GuanZhuSpr:SetActive(false)
	function oInfoBox.SetData(self, d)
		oInfoBox.m_NameLabel:SetText(d.player.name)
		oInfoBox.m_PlayerSpr:SpriteAvatar(d.player.shape)
		if d.club then
			oInfoBox.m_ClubLabel:SetText(data.clubarenadata.Config[d.club].desc)
		end
		if d.upordown == 0 then
			oInfoBox.m_JianTouSpr:SetSpriteName("pic_result_pingju")
			oInfoBox.m_BgDiwenSpr:SetSpriteName("pic_result_shibaidiwen")
		elseif d.upordown == 1 then
			oInfoBox.m_JianTouSpr:SetSpriteName("pic_result_shangsheng")
			oInfoBox.m_BgDiwenSpr:SetSpriteName("pic_result_tishidiwen")
		elseif d.upordown == 2 then
			oInfoBox.m_JianTouSpr:SetSpriteName("pic_result_xiajiang")
			oInfoBox.m_BgDiwenSpr:SetSpriteName("pic_result_shibaidiwen")
		elseif d.upordown == 3 then
			oInfoBox.m_JianTouSpr:SetSpriteName("pic_result_shangsheng")
			oInfoBox.m_BgDiwenSpr:SetSpriteName("pic_result_tishidiwen")
			oInfoBox.m_GuanZhuSpr:SetActive(true)
		elseif d.upordown == 4 then
			oInfoBox.m_JianTouSpr:SetSpriteName("pic_result_xiajiang")
			oInfoBox.m_BgDiwenSpr:SetSpriteName("pic_result_tishidiwen")
			oInfoBox.m_GuanZhuSpr:SetActive(true)
		end
		oInfoBox.m_JianTouSpr:MakePixelPerfect()
	end
end

function CClubArenaWarResultView.SetData(self, medal, result, info1, info2)
	self.m_Win:SetActive(false)
	self.m_Fail:SetActive(false)
	self.m_End:SetActive(false)

	self.m_DescLabel:SetText("+"..medal)
	if result == 1 then
		self.m_Win:SetActive(true)
	else
		self.m_Fail:SetActive(true)
	end
	self.m_PlayerBox:SetData(info1)
	self.m_EnemyBox:SetData(info2)
end

function CClubArenaWarResultView.Destroy(self)
	g_ViewCtrl:CloseInterface(define.OpenInterfaceType.WarResult)
	g_MainMenuCtrl:SetMainViewCallback(function ()
		g_ClubArenaCtrl:ShowArena()
	end)
	CViewBase.Destroy(self)
end

function CClubArenaWarResultView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Arena.Event.OnWarEnd then
		local dData = oCtrl.m_EventData
		if dData then
			self:SetData(dData.medal, dData.result, dData.info1, dData.info2)
		end
	end
end

function CClubArenaWarResultView.CloseView(self)
	g_WarCtrl:SetInResult(false)
end

function CClubArenaWarResultView.OnWarEvnet(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.EndWar then
		CViewBase.CloseView(self)
	end
end

function CClubArenaWarResultView.OnShowView(self)
	-- if g_ClubArenaCtrl.m_Result == define.Arena.WarResult.NotReceive then
	-- 	self:SetActive(false)
	-- end
end

return CClubArenaWarResultView
