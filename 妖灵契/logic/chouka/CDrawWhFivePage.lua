local CDrawWhFivePage = class("CDrawWhFivePage", CPageBase)

function CDrawWhFivePage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CDrawWhFivePage.OnInitPage(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_CartGrid = self:NewUI(2, CGrid)
	self.m_ShareBtn = self:NewUI(3, CButton)
	self.m_SharePart = self:NewUI(4, CBox)
	self.m_SmallCardBox = self:NewUI(5, CBox)
	self.m_ShareTipLabel = self:NewUI(6, CLabel)
	self.m_CloseBtn2 = self:NewUI(7, CButton)
	self.m_BtnContainer = self:NewUI(8, CObject)
	self.m_AgainBtn = self:NewUI(9, CButton)
	self.m_AgainCostLabel = self:NewUI(10, CLabel)
	self.m_Again5Btn = self:NewUI(11, CButton)
	self.m_Again5CostLabel = self:NewUI(12, CLabel)
	self.m_BaodiLabel = self:NewUI(13, CLabel)
	self.m_BaodiLabel2 = self:NewUI(14, CLabel)
	self.m_FreeLabel = self:NewUI(15, CLabel)
	self:InitShare()
	self:UpdateCost()
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CloseBtn2:AddUIEvent("click", callback(self, "OnClose"))
	self.m_AgainBtn:AddUIEvent("click", callback(self, "ShowWuHunTip"))
	self.m_Again5Btn:AddUIEvent("click", callback(self, "OnAgainMore"))
	self.m_ShareBtn:AddUIEvent("click", callback(self, "DoShare"))
	self.m_SmallCardBox:SetActive(false)
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPartnerEvent"))
	g_GuideCtrl:AddGuideUI("close_wl_result_rt", self.m_CloseBtn)
	g_GuideCtrl:AddGuideUI("close_wl_result_lb", self.m_CloseBtn2)
end

function CDrawWhFivePage.InitShare(self)
	self.m_SharePart:SetActive(false)
	self.m_ShareTexture = self.m_SharePart:NewUI(1, CTexture)
	self.m_ShareName = self.m_SharePart:NewUI(2, CLabel)
	self.m_ShareServerName = self.m_SharePart:NewUI(3, CLabel)
	self.m_TextureBox = self.m_SharePart:NewUI(4, CBox)
	self.m_TextureNode = self.m_SharePart:NewUI(5, CObject)
	self.m_TextureBox:SetActive(false)
	self.m_ShareServerName:SetText(g_ServerCtrl:GetCurServerName())
	self.m_ShareName:SetText(g_AttrCtrl.name)
	if g_ShareCtrl:IsShowShare() and false then
		self.m_ShareBtn:SetActive(true)
		self.m_AgainBtn:SetLocalPos(Vector3.New(-150, -230, 0))
		self.m_Again5Btn:SetLocalPos(Vector3.New(168, -230, 0))
	else
		self.m_ShareBtn:SetActive(false)
		self.m_AgainBtn:SetLocalPos(Vector3.New(-350, -230, 0))
		self.m_Again5Btn:SetLocalPos(Vector3.New(50, -230, 0))
	end
	self.m_AgainBtn:ResetAndUpdateAnchors()
	self.m_Again5Btn:ResetAndUpdateAnchors()
	if g_AttrCtrl:IsHasGameShare() then
		self.m_ShareTipLabel:SetActive(false)
	else
		self.m_ShareTipLabel:SetActive(true)
	end
end

function CDrawWhFivePage.OnPartnerEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.UpdateChoukaConfig then
		self:UpdateCost()
	end
end

function CDrawWhFivePage.UpdateCost(self)
	local cost = g_PartnerCtrl:GetChoukaCost()
	self.m_AgainCostLabel:SetText(tostring(cost))
	local cost5 = g_PartnerCtrl:GetChoukaMulCost()
	self.m_Again5CostLabel:SetText(tostring(cost5))
	local baodi = g_PartnerCtrl:GetBaodiTimes() or 9
	if baodi == 1 then
		self.m_BaodiLabel:SetActive(false)
		self.m_BaodiLabel2:SetActive(true)
	else
		self.m_BaodiLabel:SetText(tostring(baodi))
		self.m_BaodiLabel:SetActive(true)
		self.m_BaodiLabel2:SetActive(false)
	end
	if g_PartnerCtrl:IsChoukaFree() then
		self.m_FreeLabel:SetActive(true)
		self.m_AgainCostLabel:SetActive(false)
	else
		self.m_FreeLabel:SetActive(false)
		self.m_AgainCostLabel:SetActive(true)
	end
end

function CDrawWhFivePage.SyncCardPos(self, oCard, iEffectIdx)
	local oEffect = g_ChoukaCtrl.m_WLEffectList[iEffectIdx]
	local oPos = oEffect:GetPos()
	local oChoukaCam = g_CameraCtrl:GetChoukaCamera()
	local oUICam = g_CameraCtrl:GetUICamera()
	local viewPos = oWarCam:WorldToViewportPoint(warpos)
	local oUIPos = oUICam:ViewportToWorldPoint(viewPos)
	oUIPos.z = 0
	oCard:SetPos(oUIPos)
end

function CDrawWhFivePage.SetResult(self, parlist)
	g_GuideCtrl:DelGuideUIEffect("close_wl_result_lb", "round")
	self.m_CartGrid:Clear()
	self.m_CartGrid:SetActive(true)
	self.m_ResultList = parlist
	local amount = #parlist
	for i, parid in ipairs(parlist) do
		local oPartner = g_PartnerCtrl:GetPartner(parid)
		if oPartner then
			local smallbox = self.m_SmallCardBox:Clone()
			local box = smallbox:NewUI(1, CBox)
			smallbox.m_CardBox = box
			self:InitCardBox(box)
			self:SetCardPartner(box, parid)
			local v = box:GetLocalPos()
			local x = math.floor(math.abs(i - (1 + amount)/2))
			v.y = v.y + x*5
			box:SetLocalPos(v)
			box:SetDepth(box:GetDepth()+3-math.abs(3-i))
			smallbox:SetActive(true)
			self.m_CartGrid:AddChild(smallbox)
			g_ChoukaCtrl:SyncCardPos(smallbox, i)
		end
	end

	if g_GuideCtrl:IsCustomGuideFinishByKey("Open_ZhaoMu") and not g_GuideCtrl:IsCustomGuideFinishByKey("DrawCard") then
		self.m_IsInDrawCardGuide = true
	end
end

function CDrawWhFivePage.SetBtnShow(self, bShow)
	self.m_BtnContainer:SetActive(bShow)
end

function CDrawWhFivePage.SetCardPartner(self, box, parid)
	local oPartner = g_PartnerCtrl:GetPartner(parid)
	box.m_NameLabel:SetText(oPartner:GetValue("name"))
	box:SetActive(false)
	box.m_StarGrid:Clear()
	for i = 1, 5 do
		local starbox = box.m_StarBox:Clone()
		starbox.m_StarSpr = starbox:NewUI(1, CSprite)
		starbox.m_GreySpr = starbox:NewUI(2, CSprite)
		starbox.m_StarSpr:SetActive(oPartner:GetValue("star") >= i)
		starbox.m_GreySpr:SetActive(oPartner:GetValue("star") < i)
		starbox:SetActive(true)
		box.m_StarGrid:AddChild(starbox)
	end
	box.m_RareSpr:SetSpriteName("text_xiaodengji_"..tostring(oPartner:GetValue("rare")))
	box.m_PartnerTexture:ChangeShape(oPartner:GetValue("shape"), {}, function () box:SetActive(true) end)
end

function CDrawWhFivePage.InitCardBox(self, box)
	box.m_NameLabel = box:NewUI(1, CLabel)
	box.m_RareSpr = box:NewUI(2, CSprite)
	box.m_PartnerTexture = box:NewUI(3, CActorTexture)
	box.m_StarGrid = box:NewUI(4, CGrid)
	box.m_StarBox = box:NewUI(5, CBox)
	box.m_StarBox:SetActive(false)
end

function CDrawWhFivePage.OnAgain(self, iType)
	--g_ChoukaCtrl:ClearActor()
	iType = iType or 0
	local istate = IOTools.GetRoleData("chouka_bullet") or 1
	netpartner.C2GSDrawWuHunCard(0, false, iType, 1)
end

function CDrawWhFivePage.ShowWuHunTip(self)
	if not g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSDrawWuHunCard"], 5) then
		return
	end
	self.m_UseSSRItem = 0
	if g_ItemCtrl:GetBagItemAmountBySid(10019) + g_ItemCtrl:GetBagItemAmountBySid(10018) <= 0 then
		self:ShowWuHunTip2()
	else
		CDrawSelectView:ShowView(function (oView)
			oView:SetCallBack(callback(self, "OnAgain"))
		end)
	end
end

function CDrawWhFivePage.ShowWuHunTip2(self)
	local isfree = (g_TimeCtrl:GetTimeS() - g_PartnerCtrl:GetChoukaFreeCD()) >= 0
	if g_ItemCtrl:GetBagItemAmountBySid(10021) < 1 and not isfree and g_WindowTipCtrl:IsShowTips("draw_whcard_tip") then
		local windowConfirmInfo = {
			msg				= string.format("你的王者契约不足，是否消耗#w2%d进行招募？", g_PartnerCtrl:GetChoukaCost()),
			okCallback		= callback(self, "CloseConfirmTip"),
			selectdata		={
				text = "今日内不再提示",
				CallBack = callback(g_WindowTipCtrl, "SetTodayTip", "draw_whcard_tip")
			},
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		self:OnAgain()
	end
end

function CDrawWhFivePage.CloseConfirmTip(self)
	self:OnAgain()
end

function CDrawWhFivePage.OnAgainMore(self)
	netpartner.C2GSDrawWuHunCard(0, false, 0, 5)
end

function CDrawWhFivePage.OnDrawFiveWuHun(self)
	if g_WindowTipCtrl:IsShowTips("draw_five_tip") then
		local windowConfirmInfo = {
			msg				= string.format("你的王者契约不足，是否消耗#w2%d进行招募？", g_PartnerCtrl:GetChoukaMulCost()),
			okCallback		= callback(self, "OnAgainMore"),
			selectdata		={
				text = "今日内不再提示",
				CallBack = callback(g_WindowTipCtrl, "SetTodayTip", "draw_five_tip")
			},
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		self:OnAgainMore()
	end
end

function CDrawWhFivePage.OnClose(self)
	self.m_ParentView:ShowMain()
	g_ChoukaCtrl:ShowMainPage(1)
	if self.m_IsInDrawCardGuide == true then
		g_GuideCtrl:DelayShowDrawCloseLBEffect()
	end
end

function CDrawWhFivePage.DoShare(self)
	-- self.m_ResultList = {}
	-- local k = 0
	-- for _, v in pairs(g_PartnerCtrl:GetPartnerList()) do
	-- 	if k >= 5 then
	-- 		break
	-- 	end
	-- 	k = k + 1
	-- 	table.insert(self.m_ResultList, v.m_ID)
	-- end
	g_ChoukaCtrl:CloseWLEffect()
	self.m_BtnContainer:SetActive(false)
	self.m_ParentView.m_BulletSelBtn:SetActive(false)
	self.m_ParentView.m_GoldContainer:SetActive(false)
	self.m_SharePart:SetActive(true)
	g_NotifyCtrl:HideView(true)
	self.m_CartGrid:SetActive(false)

	if not self.m_ShareTexture.m_Init then
		local tex = Utils.CreateQRCodeTex(define.Url.OffcialWeb, self.m_ShareTexture.m_UIWidget.width)
		self.m_ShareTexture:SetMainTexture(tex)
		self.m_ShareTexture.m_Init = true
	end
	self.m_ShareTextureList = self.m_ShareTextureList or {}
	self.m_LoadFinish = 0
	for i, iParID in ipairs(self.m_ResultList) do
		local oBox = self.m_ShareTexture[i]
		if not oBox then
			oBox = self.m_TextureBox:Clone()
			oBox.m_FullTexture = oBox:NewUI(1, CTexture)
			oBox.m_RareSpr = oBox:NewUI(2, CSprite)
			oBox.m_NameLabel = oBox:NewUI(3, CLabel)
			self.m_ShareTexture[i] = oBox
			oBox:SetParent(self.m_TextureNode.m_Transform)
			oBox.m_FullTexture:SetDepth(8-math.abs(3-i))
			oBox:SetLocalPos(Vector3.New((i-3)*250, math.abs(3-i)*50 - 100, 0))
		end
		oBox:SetActive(false)
		local oPartner = g_PartnerCtrl:GetPartner(iParID)
		local iShape = oPartner:GetValue("shape")
		local sName = oPartner:GetValue("name")
		local iRare = oPartner:GetValue("rare")
		if oPartner then
			oBox.m_FullTexture:LoadFullPhoto(iShape, function ()
				oBox.m_FullTexture:SnapFullPhoto(iShape, 0.8)
				oBox.m_FullTexture:SetActive(true)
				oBox.m_NameLabel:SetText(sName)
				oBox.m_RareSpr:SetSpriteName("text_xiaodengji_"..tostring(iRare))
				self.m_LoadFinish = self.m_LoadFinish + 1
				oBox:SetActive(true)
				Utils.AddTimer(callback(self, "PrintSceen"), 0, 0)
			end)
		end
	end
end

function CDrawWhFivePage.PrintSceen(self)
	if self.m_LoadFinish < 5 then
		return
	end
	local w, h = UITools.GetRootSize()
	local rt = UnityEngine.RenderTexture.New(w, h, 16)
	local oCam2 = g_CameraCtrl:GetChoukaCamera()
	local oCam = g_CameraCtrl:GetUICamera()
	oCam2:SetTargetTexture(rt)
	oCam2:Render()
	oCam:SetTargetTexture(rt)
	oCam:Render()
	oCam:SetTargetTexture(nil)
	oCam2:SetTargetTexture(nil)
	local texture2D = UITools.GetRTPixels(rt)
	local filename = os.date("%Y%m%d%H%M%S", g_TimeCtrl:GetTimeS())
	local path = IOTools.GetRoleFilePath(string.format("/Screen/%s.jpg", filename))
	IOTools.SaveByteFile(path, texture2D:EncodeToJPG())
	--self:EndShare(self)
	local sTip = string.format("【#妖灵契#玄不改非，氪不改命，其实我是不信的~%s】", define.Url.OffcialWeb)
	g_ShareCtrl:ShareImage(path, sTip, function () 
		if not g_AttrCtrl:IsHasGameShare() then
			netplayer.C2GSGameShare("draw_card_share")
		end
	end, callback(self, "EndShare"))
end

function CDrawWhFivePage.EndShare(self)
	self.m_BtnContainer:SetActive(true)
	self.m_ParentView.m_GoldContainer:SetActive(true)
	self.m_SharePart:SetActive(false)
	self.m_CartGrid:SetActive(true)
	g_NotifyCtrl:HideView(false)
end

return CDrawWhFivePage