local CDrawWhPage = class("CDrawWhPage", CPageBase)

function CDrawWhPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CDrawWhPage.OnInitPage(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_ShareBox = self:NewUI(2, CBox)
	self.m_CardClone = self:NewUI(3, CBox)
	self.m_AgainBtn = self:NewUI(4, CButton)
	self.m_ShareTipLabel = self:NewUI(5, CLabel)
	self.m_GetBtn = self:NewUI(6, CButton)
	self.m_JoinUpBtn = self:NewUI(7, CButton)
	self.m_CloseBtn2 = self:NewUI(8, CButton)
	self.m_BtnContainer = self:NewUI(9, CObject)
	self.m_HelpPartnerBtn = self:NewUI(10, CButton)
	self.m_SkillBox = self:NewUI(11, CBox)
	self.m_SkillClick = self:NewUI(12, CWidget)
	self.m_SkillBtn = self:NewUI(13, CButton)
	
	self.m_EffectObj = self:NewUI(14, CWidget)
	self.m_EffectNameLabel = self:NewUI(15, CLabel)
	self.m_CostLabel = self:NewUI(16, CLabel)
	self.m_ShareSpr = self:NewUI(17, CButton)
	self.m_SharePart = self:NewUI(18, CBox)
	self.m_BaodiLabel = self:NewUI(19, CLabel)
	self.m_BaodiLabel2 = self:NewUI(20, CLabel)
	self.m_FreeLabel = self:NewUI(21, CLabel)
	self.m_ResultLabel = self:NewUI(22, CLabel)
	self.m_CardClone:SetActive(false)
	self.m_ShareBox:SetActive(false)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CloseBtn2:AddUIEvent("click", callback(self, "OnClose"))
	self.m_AgainBtn:AddUIEvent("click", callback(self, "OnChangeChip"))
	self.m_ShareSpr:AddUIEvent("click", callback(self, "DoShare"))
	self.m_ShareBox:AddUIEvent("click", callback(self, "DoShare"))
	self.m_GetBtn:AddUIEvent("click", callback(self, "OnGetChip"))
	g_GuideCtrl:AddGuideUI("close_wh_result_rt", self.m_CloseBtn)
	g_GuideCtrl:AddGuideUI("close_wh_result_lb", self.m_CloseBtn2)
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPartnerEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	self.m_HelpPartnerBtn:AddUIEvent("click", callback(self, "OnPartnerHelp"))
	self.m_SkillBtn:AddUIEvent("click", callback(self, "SwitchSkillBox"))
	-- local cost = g_PartnerCtrl:GetChoukaCost()
	-- self.m_CostLabel:SetText(tostring(cost))
	-- self.m_CostLabel:SetActive(false)
	self:UpdateBaodi()
	self:InitBtns()
	self:InitCart()
	self:InitSkill()
	self:InitShare()
end

function CDrawWhPage.InitCart(self)
	local oCard = self.m_CardClone
	oCard.m_NameLabel = oCard:NewUI(1, CLabel)
	oCard.m_RareSpr = oCard:NewUI(2, CSprite)
	oCard.m_Texture = oCard:NewUI(3, CActorTexture)
	oCard.m_StarGrid = oCard:NewUI(4, CGrid)
	oCard.m_StarBox = oCard:NewUI(5, CBox)
	oCard.m_Explain = oCard:NewUI(6, CLabel)
	oCard.m_StarBox:SetActive(false)
end

function CDrawWhPage.InitBtns(self)
	local _, h = UITools.GetRootSize()
	h = -h / 2 + 70
	local controlData = data.globalcontroldata.GLOBAL_CONTROL.partnerrecommend
	--900
	local btnList = {}
	self.m_GetBtn:SetActive(false)
	self.m_AgainBtn:SetActive(false)
	if g_AttrCtrl.grade >= controlData.open_grade and controlData.is_open == "y" then
		self.m_HelpPartnerBtn:SetActive(true)
		btnList = {self.m_HelpPartnerBtn}
	else
		self.m_HelpPartnerBtn:SetActive(false)
		btnList = {}
	end
	self.m_HelpPartnerBtn:SetActive(false)
	--btnList = {self.m_HelpPartnerBtn}
	-- if g_ShareCtrl:IsShowShare() and false then
	-- 	table.insert(btnList, 1, self.m_ShareSpr)
	-- end
	-- local btnList = {}
	-- local iStart = -129
	-- local iWidth = 350
	-- local iAmount = #btnList
	-- local midIdx = iAmount/2 + 0.5
	-- for i, btn in ipairs(btnList) do
	-- 	local x = (i-midIdx) * iWidth + iStart
	-- 	btn:SetLocalPos(Vector3.New(x, h, 0))
	-- end
	-- self.m_AgainBtn:ResetAndUpdateAnchors()
end

function CDrawWhPage.InitSkill(self)
	local box = self.m_SkillBox
	self.m_SkillGrid = box:NewUI(1, CGrid)
	self.m_SkillSpr = box:NewUI(2, CSprite)
	self.m_SkillScrollView = box:NewUI(3, CScrollView)
	self.m_SKillDescLabel = box:NewUI(4, CLabel)
	self.m_SkillNameLabel = box:NewUI(5, CLabel)
	self.m_SKillCostLabel = box:NewUI(6, CLabel)
	self.m_SkillSpr:SetActive(false)
	box:SetActive(true)
end

function CDrawWhPage.InitShare(self)
	self.m_SharePart:SetActive(false)
	self.m_ShareSpr:SetActive(g_ShareCtrl:IsShowShare() and false)
	self.m_ShareTexture = self.m_SharePart:NewUI(1, CTexture)
	self.m_ShareName = self.m_SharePart:NewUI(2, CLabel)
	self.m_ShareServerName = self.m_SharePart:NewUI(3, CLabel)
	self.m_FullTexture = self.m_SharePart:NewUI(4, CTexture)
	
	self.m_ShareServerName:SetText(g_ServerCtrl:GetCurServerName())
	self.m_ShareName:SetText(g_AttrCtrl.name)

	if g_AttrCtrl:IsHasGameShare() then
		self.m_ShareTipLabel:SetActive(false)
	else
		self.m_ShareTipLabel:SetActive(true)
	end
end

function CDrawWhPage.OnPartnerEvent(self, oCtrl)
	-- if oCtrl.m_EventID == define.Partner.Event.UpdateChoukaConfig then
	-- 	local cost = g_PartnerCtrl:GetChoukaCost()
	-- 	self.m_CostLabel:SetText(tostring(cost))
	-- 	self:UpdateBaodi()
	-- end
end

function CDrawWhPage.OnAttrEvent(self, oCtrl)
	if g_AttrCtrl:IsHasGameShare() then
		self.m_ShareTipLabel:SetActive(false)
	else
		self.m_ShareTipLabel:SetActive(true)
	end
end

function CDrawWhPage.UpdateBaodi(self)
	local baodi = g_PartnerCtrl:GetBaodiTimes() or 9
	if baodi == 1 then
		self.m_BaodiLabel:SetActive(false)
		self.m_BaodiLabel2:SetActive(true)
	else
		self.m_BaodiLabel:SetText(tostring(baodi))
		self.m_BaodiLabel:SetActive(true)
		self.m_BaodiLabel2:SetActive(false)
	end
end

function CDrawWhPage.SetResult(self, parlist, desc, redraw_cost)
	g_GuideCtrl:DelGuideUIEffect("close_wh_result_lb", "round")
	self.m_CardClone:SetActive(true)
	self:SetCardPartner(self.m_CardClone, parlist[1], desc)
	self.m_RedrawCost = redraw_cost
	self.m_AgainBtn:SetActive(false)
	self.m_GetBtn:SetActive(false)
	self.m_ParID = parlist[1]
	self.m_SendChance = true
end

function CDrawWhPage.SetBtnShow(self, bShow)
	self.m_BtnContainer:SetActive(bShow)
	local bFlag = (self.m_RedrawCost ~= 0)
	if not bShow then
		bFlag = false
	end
	self.m_GetBtn:SetActive(bFlag)
	self.m_AgainBtn:SetActive(bFlag)
	self.m_GetBtn:AddUIEvent("click", callback(self, "OnGetChip"))
end

function CDrawWhPage.SetCardPartner(self, oCard, parid, desc)
	local oPartner = g_PartnerCtrl:GetPartner(parid)
	if not oPartner then
		return
	end
	oCard.m_NameLabel:SetText(oPartner:GetValue("name"))
	local sRare = g_PartnerCtrl:GetRareText(oPartner:GetValue("rare"))
	self.m_ShareBox:SetActive( sRare == "SSR" and g_ShareCtrl:IsShowShare())
	oCard.m_RareSpr:SetSpriteName("text_dadengji_"..tostring(oPartner:GetValue("rare")))
	self.m_ResultLabel:SetText(desc)
	oCard.m_StarGrid:Clear()
	for i = 1, 5 do
		local starbox = oCard.m_StarBox:Clone()
		starbox.m_StarSpr = starbox:NewUI(1, CSprite)
		starbox.m_GreySpr = starbox:NewUI(2, CSprite)
		starbox.m_StarSpr:SetActive(oPartner:GetValue("star") >= i)
		starbox.m_GreySpr:SetActive(oPartner:GetValue("star") < i)
		starbox:SetActive(true)
		oCard.m_StarGrid:AddChild(starbox)
	end
	oCard.m_StarGrid:Reposition()
	oCard.m_Explain:SetText(oPartner:GetValue("explain"))
	self:UpdateSkill(oPartner)
end

function CDrawWhPage.UpdateSkill(self, oPartner)
	self.m_SkillGrid:Clear()
	local skilllist = oPartner:GetValue("skill")
	local list = table.copy(skilllist)
	if oPartner:GetValue("awake_type") == 2 and oPartner:GetValue("awake") == 0 then
		local num = tonumber(oPartner:GetValue("awake_effect"))
		if num then
			local skillobj = {sk=num, level=0}
			table.insert(list, skillobj)
		end
	end
	table.sort(list, function (a, b) return a["sk"] < b["sk"] end)

	local d = data.skilldata.PARTNERSKILL
	for _, skillobj in ipairs(list) do
		local spr = self.m_SkillSpr:Clone()
		if d[skillobj["sk"]] and d[skillobj["sk"]]["icon"] then
			spr:SpriteSkill(d[skillobj["sk"]]["icon"])
		end
		spr:AddUIEvent("click", callback(self, "OnClickSkill"))
		spr.m_SkillID = skillobj["sk"]
		spr.m_Level = skillobj["level"]
		spr.m_IsAwake = oPartner:GetValue("awake") == 1
		spr:SetGroup(self.m_SkillGrid:GetInstanceID())
		spr:SetActive(true)
		self.m_SkillGrid:AddChild(spr)
	end
	self.m_SkillGrid:Reposition()
	local defaultBox = self.m_SkillGrid:GetChild(1)
	if defaultBox then
		defaultBox:SetSelected(true)
		self:OnClickSkill(defaultBox)
	end
end

function CDrawWhPage.OnClickSkill(self, box)
	local iSkillID = box.m_SkillID
	local level = box.m_Level
	local d = data.skilldata.PARTNER
	local md = data.skilldata.PARTNERSKILL
	if d[iSkillID] then
		self.m_SkillNameLabel:SetText(string.format("技能%d", iSkillID))
		self.m_SKillCostLabel:SetActive(false)
		if md[iSkillID] then
			self.m_SkillNameLabel:SetText(string.format("%s", md[iSkillID]["name"]))
			self.m_SKillCostLabel:SetText(string.format("%d", md[iSkillID]["sp"]))
		else
			self.m_SKillCostLabel:SetText("0")
		end
		self.m_SKillCostLabel:SetActive(true)
		
		local strlist = {}
		if d[iSkillID][1] then
			local maindesc = d[iSkillID][1]["desc"]
			local otherdesc = md[iSkillID]["otherdesc"]
			table.insert(strlist, maindesc)
			table.insert(strlist, "")
			table.insert(strlist, otherdesc)
			table.insert(strlist, "")
		end
		
		if level == 0 then
			table.insert( strlist, "觉醒后解锁该技能")
		
		elseif #d[iSkillID] < 2 then
			table.insert( strlist, "技能无法升级")
		
		else
			for i, obj in ipairs(d[iSkillID]) do
				if i > 1 then
					if i <= level then
						table.insert( strlist, string.format("lv%d %s", i, d[iSkillID][i]["desc"]))
					else
						table.insert( strlist, string.format("lv%d %s", i, d[iSkillID][i]["desc"]))
					end
				end
			end
		end
		self.m_SKillDescLabel:SetText(table.concat(strlist, "\n"))
	end
	self.m_SkillScrollView:ResetPosition()
end

function CDrawWhPage.OnGetChip(self)
	netpartner.C2GSReceivePartnerChip()
end

function CDrawWhPage.OnChangeChip(self)
	local windowConfirmInfo = {
			msg				= string.format("是否消耗#w2 2000重新进行招募？", g_PartnerCtrl:GetChoukaCost()),
			okCallback		= function ()
				netpartner.C2GSReDrawPartner()
			end,
	}
	g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
end

function CDrawWhPage.SendBullet(self, name)
	if string.len(name) == 0 then 
		g_NotifyCtrl:FloatMsg("请输入发送内容")
		return
	end
	name = string.gsub(name, "#%u", "")
	if g_MaskWordCtrl:IsContainMaskWord(name) then
		local windowConfirmInfo = {
			msg				= "存在敏感词汇，是否发送？",
			okCallback		= function()
				self:OnSend(g_MaskWordCtrl:ReplaceMaskWord(name))
			end
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		self:OnSend(name)
	end
end

function CDrawWhPage.OnSend(self, text)
	self.m_SendChance = false
	netother.C2GSBarrage("partner", text, not  g_MaskWordCtrl:IsContainHideStr(text))
	CBulletInputView:CloseView()
end

function CDrawWhPage.SwitchSkillBox(self)
	if self.m_SkillBox:GetActive() then
		self.m_SkillBox:SetActive(false)
		self.m_SkillBtn:SetSpriteName("pic_chouka_jinengguan")
	else
		self.m_SkillBox:SetActive(true)
		self.m_SkillBtn:SetSpriteName("pic_chouka_jinengkai")
	end
end

function CDrawWhPage.OnPartnerHelp(self)
	--self.m_ParentView:CloseView()
	local oPartner = g_PartnerCtrl:GetPartner(self.m_ParID)
	if oPartner then
		CPowerGuideMainView:ShowView(function (oView)
			oView:ShowPartnerCommand(oPartner:GetValue("partner_type"), true)
		end)
	end
end

function CDrawWhPage.OnAgain(self, iType)
	local bUp = self.m_JoinUpBtn:GetSelected()
	local iSend = bUp and 1 or 0
	iType = iType or 0
	local istate = IOTools.GetRoleData("chouka_bullet") or 1
	netpartner.C2GSDrawWuHunCard(iSend, istate == 0, iType, 1)
end

function CDrawWhPage.ShowWuHunTip(self)
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

function CDrawWhPage.ShowWuHunTip2(self)
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

function CDrawWhPage.CloseConfirmTip(self)
	self:OnAgain()
end

function CDrawWhPage.OnClose(self)
	if self.m_RedrawCost ~= 0 then
		local windowConfirmInfo = {
			msg				= "碎片奖励未领取，将保留此次招募结果，此次不消耗一发入魂契约。下次使用一发入魂契约则默认为此次奖励内容，是否关闭界面？",
			okCallback		= function () self.m_ParentView:OnClose() end,
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		self.m_ParentView:OnClose()
	end
end

function CDrawWhPage.DoResultEffect(self, iParID)
	local oPartner = g_PartnerCtrl:GetPartner(iParID)
	if not oPartner then
		return
	end
	self.m_EffectNameLabel:SetText(oPartner:GetValue("name"))
	self.m_EffectObj:SetActive(true)
	
	if self.m_EffectTimer then
		Utils.DelTimer(self.m_EffectTimer)
	end
	local t = 0
	local scaleList = {
		0.1, 0.3, 0.2, 0.2, 0.3,
		0.3, 0.3, 0.3, 0.3, 0.3,
		0.3, 0.3, 0.3, 0.3, 0.3,
		0.25, 0.22, 0.2, 0.1, 0,
	}
	self.m_EffectObj:SetLocalScale(Vector3.New(0, 0, 0))
	local function update(dt)
		t = t + dt
		local idx = math.floor(t/0.05)
		if idx > 20 then
			self.m_EffectObj:SetAlpha(0)
			return
		end
		local size = (scaleList[idx] or 0) * 3
		if size then
			self.m_EffectObj:SetLocalScale(Vector3.New(size, size, size))
		end
		if idx < 16 then
			self.m_EffectObj:SetAlpha(1)
		else
			self.m_EffectObj:SetAlpha((20-idx)/5)
		end
		return true
	end
	self.m_EffectTimer = Utils.AddTimer(update, 0.05, 0.05)

end

function CDrawWhPage.DoShare(self)
	g_ChoukaCtrl:CloseWHEffect()
	self.m_BtnContainer:SetActive(false)
	self.m_ParentView.m_GoldContainer:SetActive(false)
	self.m_SharePart:SetActive(true)
	g_NotifyCtrl:HideView(true)
	g_ChoukaCtrl:ShowActor(false)
	
	self.m_CardClone.m_Explain:SetActive(false)
	self.m_CardClone.m_StarGrid:SetActive(false)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_ParID)
	local iShape = oPartner:GetValue("shape")
	self.m_FullTexture:SetActive(false)
	self.m_FullTexture:LoadFullPhoto(iShape, function () 
		self.m_FullTexture:SnapFullPhoto(iShape, 1.2)
		self.m_FullTexture:SetActive(true)
		Utils.AddTimer(callback(self, "PrintSceen"), 0, 0)
	end)

	local oView = CBulletScreenView:GetView()
	if oView then
		oView:SetActive(false)
	end
	if not self.m_ShareTexture.m_Init then
		local tex = Utils.CreateQRCodeTex(define.Url.OffcialWeb, self.m_ShareTexture.m_UIWidget.width)
		self.m_ShareTexture:SetMainTexture(tex)
		self.m_ShareTexture.m_Init = true
		local t = self.m_ShareTexture:GetComponentsInChildren(classtype.UITexture, true)
		t[1].gameObject:SetActive(true)
	end
end

function CDrawWhPage.PrintSceen(self)
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
	local sTip = string.format("【#妖灵契#玄不改非，氪不改命，其实我是不信的~%s】", define.Url.OffcialWeb)
	g_ShareCtrl:ShareImage(path, sTip, function () 
		if not g_AttrCtrl:IsHasGameShare() then
			netplayer.C2GSGameShare("draw_card_share")
		end
	end, callback(self, "EndShare"))
end

function CDrawWhPage.EndShare(self)
	self.m_BtnContainer:SetActive(true)
	self.m_ParentView.m_GoldContainer:SetActive(true)
	self.m_SharePart:SetActive(false)
	g_NotifyCtrl:HideView(false)
	g_ChoukaCtrl:ShowActor(true)
	self.m_CardClone.m_Explain:SetActive(true)
	self.m_CardClone.m_StarGrid:SetActive(true)
	self.m_ParentView:InitBulletState()
end

return CDrawWhPage