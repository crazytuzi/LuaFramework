 local CGuideView = class("CGuideView", CViewBase)

CGuideView.LogToggle = 0

function CGuideView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Misc/GuideView.prefab", cb)
	--界面设置
	self.m_DepthType = "Guide"
	
end

function CGuideView.OnCreateView(self)
	self.m_Contanier = self:NewUI(1, CWidget)
	-- self.m_TipsLabel = self:NewUI(2, CLabel)
	self.m_SwipeGuide = self:NewUI(3, CWidget)
	self.m_ParentPanel = self:NewUI(4, CPanel)
	self.m_EventWidget = self:NewUI(5, CWidget)
	self.m_TextureBox = self:NewUI(6, CGuideTextureBox)
	self.m_FocusBox = self:NewUI(7, CGuideFocusBox)
	self.m_DlgBox = self:NewUI(8, CBox)
	self.m_OpenBox = self:NewUI(9, CGuideOpenBox)
	self.m_ContinueLabel = self:NewUI(10, CLabel)
	self.m_SpineBox = self:NewUI(11, CBox)
	self.m_BigDlgBox = self:NewUI(12, CBox)
	self.m_TextDlgBox = self:NewUI(13, CBox)
	self.m_JumpBtn = self:NewUI(14, CBox)
	self.m_OpenBoxBg = self:NewUI(15, CSprite)

	self:InitContent()

	g_GuideCtrl:StopActionWhenGuide()
end

function CGuideView.InitContent(self)
	self.m_GuideUIInfo = nil
	self.m_GuideKey = nil
	self.m_ClickContinue = false
	self.m_ClickContinueCondition = true
	self.m_ClickContinueTimer = nil
	self.m_ClickContinueCacheConfig = {}
	self.m_RefreshTextFunc = nil
	UITools.ResizeToRootSize(self.m_Contanier, 4, 4)
	self.m_FocusBox:SetActive(false)
	self.m_EventWidget:AddUIEvent("click", callback(self, "OnGuideUIClick"))
	self.m_JumpBtn:AddUIEvent("click", callback(self, "OnJump"))
	self.m_DlgBox.m_LeftLabel = self.m_DlgBox:NewUI(1, CLabel)
	self.m_DlgBox.m_LeftBgSpr = self.m_DlgBox:NewUI(2, CSprite)
	self.m_DlgBox.m_LeftNextSpr = self.m_DlgBox:NewUI(3, CSprite)
	self.m_DlgBox.m_LeftTipsTexture = self.m_DlgBox:NewUI(4, CTexture)
	self.m_DlgBox.m_RightLabel = self.m_DlgBox:NewUI(5, CLabel)
	self.m_DlgBox.m_RightBgSpr = self.m_DlgBox:NewUI(6, CSprite)
	self.m_DlgBox.m_RightNextSpr = self.m_DlgBox:NewUI(7, CSprite)
	self.m_DlgBox.m_RightTipsTexture = self.m_DlgBox:NewUI(8, CTexture)
	self.m_SpineBox.m_LeftWidget = self.m_SpineBox:NewUI(1, CBox)
	self.m_SpineBox.m_LeftLabel = self.m_SpineBox:NewUI(2, CLabel) 
	self.m_SpineBox.m_LeftTexture = self.m_SpineBox:NewUI(3, CSpineTexture)
	self.m_SpineBox.m_RightWidget = self.m_SpineBox:NewUI(4, CBox)
	self.m_SpineBox.m_RightLabel = self.m_SpineBox:NewUI(5, CLabel) 
	self.m_SpineBox.m_RightTexture = self.m_SpineBox:NewUI(6, CSpineTexture)
	self.m_BigDlgBox.m_LeftLabel = self.m_BigDlgBox:NewUI(1, CLabel)
	self.m_BigDlgBox.m_LeftBgSpr = self.m_BigDlgBox:NewUI(2, CSprite)
	self.m_BigDlgBox.m_LeftNextSpr = self.m_BigDlgBox:NewUI(3, CSprite)
	self.m_BigDlgBox.m_LeftTipsTexture = self.m_BigDlgBox:NewUI(4, CTexture)
	self.m_BigDlgBox.m_RightLabel = self.m_BigDlgBox:NewUI(5, CLabel)
	self.m_BigDlgBox.m_RightBgSpr = self.m_BigDlgBox:NewUI(6, CSprite)
	self.m_BigDlgBox.m_RightNextSpr = self.m_BigDlgBox:NewUI(7, CSprite)
	self.m_BigDlgBox.m_RightTipsTexture = self.m_BigDlgBox:NewUI(8, CTexture)	
	self.m_TextDlgBox.m_LeftLabel = self.m_TextDlgBox:NewUI(1, CLabel)
	self.m_TextDlgBox.m_LeftBgSpr = self.m_TextDlgBox:NewUI(2, CSprite)
	self.m_TextDlgBox.m_LeftNextSpr = self.m_TextDlgBox:NewUI(3, CSprite)
	self.m_TextDlgBox.m_RightLabel = self.m_TextDlgBox:NewUI(4, CLabel)
	self.m_TextDlgBox.m_RightBgSpr = self.m_TextDlgBox:NewUI(5, CSprite)
	self.m_TextDlgBox.m_RightNextSpr = self.m_TextDlgBox:NewUI(6, CSprite)

	self:SetJumpBtnActive(false)

	-- self.m_TipsLabel:SetText("")
	self:HideAllGuide()
end

function CGuideView.HideAllGuide(self)
	self:SetJumpBtnActive(false)
	self.m_SwipeGuide:SetActive(false)
	self.m_DlgBox:SetActive(false)
	self.m_BigDlgBox:SetActive(false)
	self.m_TextDlgBox:SetActive(false)
	self.m_TextureBox:SetActive(false)
	self.m_OpenBox:SetActive(false)
	self.m_ContinueLabel:SetActive(false)
	if self.m_SpineLoopTimer then
		Utils.DelTimer(self.m_SpineLoopTimer)
		self.m_SpineLoopTimer = nil
	end
	self.m_SpineBox:SetActive(false)
	self.m_SpineBox.m_LeftTexture:SetMainTextureNil()
	self.m_SpineBox.m_RightTexture:SetMainTextureNil()
	if self.m_SpineLoopTimer then

	end 
	self.m_OpenBoxBg:SetActive(false)
end

function CGuideView.SetCenterText(self, sText)
	self:HideAllGuide()
	self.m_TipsLabel:SetText(sText)
end

function CGuideView.SwipeGuide(self, bActive)
	self:HideAllGuide()
	self.m_SwipeGuide:SetActive(bActive)
end

function CGuideView.ClickGuide(self, oUI, func, aplha, ownerView)
	if oUI.m_Delegate then
		for i, func in ipairs(self.m_EventWidget.m_Delegate:GetFunctions()) do
			oUI.m_Delegate:AddFunction(function(...) func(..., oUI) end)
		end
	end

	
	self.m_GuideUIInfo = {
		ui = oUI,
		parent = oUI:GetParent(),
		sibling = oUI:GetSiblingIndex(),
		cb = func,
		ownerView = ownerView or "",
	}	
	oUI:SetParent(self.m_ParentPanel.m_Transform, true)
	UITools.MarkParentAsChanged(oUI.m_GameObject)
	self.m_EventWidget:SetActive(true)
	if aplha then
		self:SetCoverAplha(aplha)
	end
end

function CGuideView.DlgGuide(self, lTexts, bPlayTween, sSprName, vPos, bNextTip, sTipsSprName, bIsLeft, aplha)
	if bIsLeft == nil then
		bIsLeft = true
	end
	sTipsSprName = sTipsSprName or "guide_3"
	self.m_DlgBox:SetActive(true)
	self.m_NextTip = bNextTip
	if bIsLeft then
		self.m_DlgBox.m_LeftLabel:SetActive(true)
		self.m_DlgBox.m_RightLabel:SetActive(false)
		if sSprName then
			self.m_DlgBox.m_LeftBgSpr:SetSpriteName(sSprName)
		end
		if sTipsSprName then
			local tipsPath = string.format("Texture/Guide/%s.png", sTipsSprName)
			self.m_DlgBox.m_LeftTipsTexture:LoadPath(tipsPath)
		end	
		self:NewTextFunc(lTexts, self.m_DlgBox.m_LeftLabel, self.m_DlgBox.m_LeftNextSpr, self.m_DlgBox.m_LeftBgSpr)		
	else
		self.m_DlgBox.m_LeftLabel:SetActive(false)
		self.m_DlgBox.m_RightLabel:SetActive(true)
		if sSprName then
			self.m_DlgBox.m_RightBgSpr:SetSpriteName(sSprName)
		end
		if sTipsSprName then
			local tipsPath = string.format("Texture/Guide/%s.png", sTipsSprName)
			self.m_DlgBox.m_RightTipsTexture:LoadPath(tipsPath)
		end	
		self:NewTextFunc(lTexts, self.m_DlgBox.m_RightLabel, self.m_DlgBox.m_RightNextSpr, self.m_DlgBox.m_RightBgSpr)
	end
	if vPos then
		self.m_DlgBox:SetPos(vPos)
	end
	if bPlayTween then
		self.m_DlgBox:UITweenPlay()
	else
		self.m_DlgBox:UITweenStop()
	end
	if aplha then
		self:SetCoverAplha(aplha)
	end
end

function CGuideView.TextDlgGuide(self, lTexts, bPlayTween, vPos, bNextTip, bIsLeft, aplha)
	bIsLeft = nil and true or bIsLeft
	self.m_TextDlgBox:SetActive(true)
	self.m_NextTip = bNextTip
	if bIsLeft then
		self.m_TextDlgBox.m_LeftLabel:SetActive(true)
		self.m_TextDlgBox.m_RightLabel:SetActive(false)
		self:NewTextFunc(lTexts, self.m_TextDlgBox.m_LeftLabel, self.m_TextDlgBox.m_LeftNextSpr, self.m_TextDlgBox.m_LeftBgSpr)		
	else
		self.m_TextDlgBox.m_LeftLabel:SetActive(false)
		self.m_TextDlgBox.m_RightLabel:SetActive(true)
		self:NewTextFunc(lTexts, self.m_TextDlgBox.m_RightLabel, self.m_TextDlgBox.m_RightNextSpr, self.m_TextDlgBox.m_RightBgSpr)
	end
	if vPos then
		self.m_TextDlgBox:SetPos(vPos)
	end
	if bPlayTween then
		self.m_TextDlgBox:UITweenPlay()
	else
		self.m_TextDlgBox:UITweenStop()
	end
	if aplha then
		self:SetCoverAplha(aplha)
	end
end

function CGuideView.BigDlgGuide(self, lTexts, bPlayTween, vPos, bNextTip, bIsLeft, bIsFlip, aplha)
	bIsLeft = nil and true or bIsLeft
	bIsFlip = nil and false or bIsFlip

	local sTipsSprName = bIsFlip and "guide_2" or "guide_1"
	self.m_BigDlgBox:SetActive(true)
	self.m_NextTip = bNextTip
	if bIsLeft then
		self.m_BigDlgBox.m_LeftLabel:SetActive(true)
		self.m_BigDlgBox.m_RightLabel:SetActive(false)
		if sTipsSprName then
			local tipsPath = string.format("Texture/Guide/%s.png", sTipsSprName)
			self.m_BigDlgBox.m_LeftTipsTexture:LoadPath(tipsPath)
		end
		if bIsFlip then
			self.m_BigDlgBox.m_LeftTipsTexture:SetFlip(enum.UIBasicSprite.Horizontally)
			self.m_BigDlgBox.m_LeftTipsTexture:SetLocalPos(Vector3.New(0, -90, 0))
		else
			self.m_BigDlgBox.m_LeftTipsTexture:SetFlip(enum.UIBasicSprite.Nothing)
			self.m_BigDlgBox.m_LeftTipsTexture:SetLocalPos(Vector3.New(-11, -124, 0))
		end	
		self:NewTextFunc(lTexts, self.m_BigDlgBox.m_LeftLabel, self.m_BigDlgBox.m_LeftNextSpr, self.m_BigDlgBox.m_LeftBgSpr, true)		
	else
		self.m_BigDlgBox.m_LeftLabel:SetActive(false)
		self.m_BigDlgBox.m_RightLabel:SetActive(true)
		if sTipsSprName then
			local tipsPath = string.format("Texture/Guide/%s.png", sTipsSprName)
			self.m_BigDlgBox.m_RightTipsTexture:LoadPath(tipsPath)
		end	
		if bIsFlip then
			self.m_BigDlgBox.m_RightTipsTexture:SetFlip(enum.UIBasicSprite.Nothing)
			self.m_BigDlgBox.m_RightTipsTexture:SetLocalPos(Vector3.New(0, -90, 0))
		else
			self.m_BigDlgBox.m_RightTipsTexture:SetFlip(enum.UIBasicSprite.Horizontally)
			self.m_BigDlgBox.m_RightTipsTexture:SetLocalPos(Vector3.New(11, -124, 0))
		end		
		self:NewTextFunc(lTexts, self.m_BigDlgBox.m_RightLabel, self.m_BigDlgBox.m_RightNextSpr, self.m_BigDlgBox.m_RightBgSpr, true)
	end
	if vPos then
		self.m_BigDlgBox:SetPos(vPos)
	end
	if bPlayTween then
		self.m_BigDlgBox:UITweenPlay()
	else
		self.m_BigDlgBox:UITweenStop()
	end
	if aplha then
		self:SetCoverAplha(aplha)
	end
end

function CGuideView.TextureGuide(self, sTxtureName, bPlayTween, bFlipY, vPos)
	self.m_TextureBox:SetActive(true)
	self.m_TextureBox.m_PlayTween = bPlayTween
	self.m_TextureBox.m_FlipY = bFlipY
	self.m_TextureBox:SetTextureName(sTxtureName)
	if vPos then
		self.m_TextureBox:SetPos(vPos)
	else
		self.m_TextureBox:SetLocalPos(Vector3.zero)
	end
end

function CGuideView.SpineGuide(self, leftShape, rightShape, lTexts, lSide, aplha, lmotion, rmotion, voiceList)
	self.m_SpineBox:SetActive(true)
	local bIsLeft = nil
	self.m_SpineBox.m_LeftLabel:SetText("")	
	self.m_SpineBox.m_RightLabel:SetText("")
	if leftShape and leftShape ~= " " then
		bIsLeft = true
		self.m_SpineBox.m_LeftWidget:SetActive(true)
		if tostring(leftShape) == "1752" then			
			self.m_SpineBox.m_LeftTexture:ShapeCommon(tostring(leftShape), function ()						
				self:NewSpineTextFunc(lTexts, lSide, self.m_SpineBox.m_LeftLabel, self.m_SpineBox.m_RightLabel, voiceList, bIsLeft, lmotion)
			end, 1.73)	
		end
	else		
		self.m_SpineBox.m_LeftWidget:SetActive(false)
	end

	if rightShape and rightShape ~= " " then
		bIsLeft = false
		self.m_SpineBox.m_RightWidget:SetActive(true)
		if tostring(rightShape) == "1752" then			
			self.m_SpineBox.m_RightTexture:ShapeCommon(tostring(rightShape), function ()		
				 self:NewSpineTextFunc(lTexts, lSide, self.m_SpineBox.m_LeftLabel, self.m_SpineBox.m_RightLabel, voiceList, bIsLeft, rmotion)
			end, 1.73)	
		end
	else
		self.m_SpineBox.m_RightWidget:SetActive(false)
	end	
	
	if aplha then
		self:SetCoverAplha(aplha)
	end	
end

function CGuideView.SetNone(self)
	self:SetCoverAplha(1)
end

function CGuideView.SetFocus(self, x, y, w, h, sEffect, bClickContinue, aplha, mode, pos)
	self.m_FocusBox:SetActive(true)
	self.m_FocusBox:SetFocusCommon(x, y, w, h)
	if sEffect and sEffect ~= "" then
		self.m_FocusBox:SetEffect(sEffect, pos)
	end	
	self.m_EventWidget:SetActive(bClickContinue)
	if aplha then
		self:SetCoverAplha(aplha)
	end
	self.m_FocusBox:SetCoverMode(mode)	
end

function CGuideView.OpenEffect(self, sSpriteName, sOpen, oUI)
	self:HideAllGuide()
	self.m_OpenBox:SetActive(true)
	self.m_OpenBoxBg:SetActive(true)
	self.m_OpenBox:SetOpen(sSpriteName, sOpen, oUI)
end

function CGuideView.ResetView(self)
	self.m_FocusBox:Black()
	self.m_FocusBox:SetActive(false)
	self:HideAllGuide()
	self.m_EventWidget:SetActive(true)
	self:SetJumpBtnActive(false)
end

function CGuideView.NewTextFunc(self, lTexts, oLabel, oNextSpr, bgSpr, isBig)
	self.m_RestoreActive = self.m_EventWidget:GetActive()
	self.m_EventWidget:SetActive(true)
	lTexts = table.copy(lTexts)
	self.m_RefreshTextFunc = function()
		local text = lTexts[1]
		if text then
			table.remove(lTexts, 1)
			oLabel:SetText(text)
			oLabel:SimulateOnEnable()
			if bgSpr then			
				local w , h = oLabel:GetSize()
				h = h > 56 and h or 56
				if isBig then
					bgSpr:SetSize(w + 116, h + 78)
				else
					bgSpr:SetSize(w + 126, h + 54)
				end
				
			end
		end
		oNextSpr:SetActive(#lTexts > 1 or self.m_NextTip)
		if not next(lTexts) then
			self.m_EventWidget:SetActive(self.m_RestoreActive)
			self.m_RefreshTextFunc = nil
		end
	end
	self.m_RefreshTextFunc()
end


function CGuideView.NewSpineTextFunc(self, lTexts, lSide, leftLabel, rightLabel, voiceList, bIsLeft, motion)
	if Utils.IsNil(self) then
		return
	end
	self.m_RestoreActive = self.m_EventWidget:GetActive()
	self.m_EventWidget:SetActive(true)
	lTexts = table.copy(lTexts)
	lSide = table.copy(lSide)
	voiceList = table.copy(voiceList)
	self.m_RefreshTextFunc = function()
		local text = lTexts[1]
		local side = lSide[1]
		local voice = voiceList[1] or "0"

		if text then
			local cb = function ()
				if voice then
					g_GuideCtrl:PlayGuideAudio(voice)
				end
			end

			if bIsLeft then
				self:SpineLoopProcress(self.m_SpineBox.m_LeftTexture, motion, cb)
			else
				self:SpineLoopProcress(self.m_SpineBox.m_RightTexture, motion, cb)
			end				

			table.remove(lTexts, 1)
			table.remove(lSide, 1)
			table.remove(voiceList, 1)
			if not side or side == "0" then
				leftLabel:SetActive(true)
				rightLabel:SetActive(false)
				leftLabel:SetText(text)
			else
				leftLabel:SetActive(false)
				rightLabel:SetActive(true)
				rightLabel:SetText(text)
			end
		end


		if not next(lTexts) then
			self.m_EventWidget:SetActive(self.m_RestoreActive)
			self.m_RefreshTextFunc = nil
		end
	end
	self.m_RefreshTextFunc()
end

function CGuideView.OnGuideUIClick(self, obj, oGuideUI)
	if self.m_RefreshTextFunc then
		if self.m_ClickContinueCondition then			
			self:m_RefreshTextFunc()
			self:StartClickContineuTimer(self.m_ClickContinueCacheConfig.m_Time, true)
		end
	else
		local dInfo = self.m_GuideUIInfo
		if dInfo then
			if oGuideUI == dInfo.ui then
				dInfo.ui:ClearEffect()
				g_GuideCtrl:Continue()
			else
				if self.m_ClickContinue then
					if self.m_ClickContinueCondition then
						dInfo.ui:ClearEffect()
						g_GuideCtrl:Continue()
					end					
				else
					g_GuideCtrl:ShowWrongTips()
				end
			end
		else
			if self.m_ClickContinue and self.m_ClickContinueCondition then
				g_GuideCtrl:Continue()
			end
		end
	end
end

function CGuideView.StopDelayClose(self)
	if self.m_DelayTimer then
		Utils.DelTimer(self.m_DelayTimer)
		self.m_DelayTimer = nil
	end
	if self.m_DelayActiveTimer then
		Utils.DelTimer(self.m_DelayActiveTimer)
		self.m_DelayActiveTimer = nil
	end
end

function CGuideView.OnJump(self)
	self:CloseView()
	g_GuideCtrl:OnJumpGuide()
end

function CGuideView.CheckGuideInfo(self)
	local dInfo = self.m_GuideUIInfo
	if dInfo then
		local ownerView = nil
		local ownerViewName = dInfo.ownerView or ""
		if ownerViewName ~= "" then
			ownerView = g_ViewCtrl:GetViewByName(ownerViewName)
		end
		if not Utils.IsNil(dInfo.ui) then
			if (ownerViewName == "" or ownerView ~= nil ) and not Utils.IsNil(dInfo.parent) then										
				dInfo.ui:ClearEffect()
				dInfo.ui:SetParent(dInfo.parent, true)		
				dInfo.ui:SetSiblingIndex(dInfo.sibling)
				UITools.MarkParentAsChanged(dInfo.ui.m_GameObject)
			else		
				dInfo.ui:Destroy()
			end			
		end
		if dInfo.cb then
			dInfo.cb()
		end
		self.m_GuideUIInfo = nil
	end
end

function CGuideView.DelayClose(self)
	self:StopDelayClose()
	self:CheckGuideInfo()
	self.m_DelayTimer = Utils.AddTimer(callback(self, "CloseView"), 0, 5)
	self.m_DelayActiveTimer = Utils.AddTimer(callback(self, "SetActive", false), 0, 0.3)
end

function CGuideView.CloseView(self)
	self:CheckGuideInfo()
	g_GuideCtrl:OnEvent(define.Guide.Event.EndGuide)
	CViewBase.CloseView(self)
end

function CGuideView.SetCoverAplha(self, aplha)
	self.m_FocusBox:SetActive(true)
	self.m_FocusBox:CoverTextureSetAplha(aplha)
end

function CGuideView.LoadDone(self)	
	g_GuideCtrl:OnEvent(define.Guide.Event.StartGuide)
	CViewBase.LoadDone(self)
end

function CGuideView.Destroy(self)
	self:StopDelayClose()
	self:StopClickContineuTimer()
	if self.m_SpineLoopTimer then
		Utils.DelTimer(self.m_SpineLoopTimer)
		self.m_SpineLoopTimer = nil
	end
	CViewBase.Destroy(self)
end

function CGuideView.SetEventWidgetActive(self, b)
	self.m_EventWidget:SetActive(b)
end

function CGuideView.SetFocusBoxActive(self, b)
	self.m_FocusBox:SetActive(b)
end

function CGuideView.StartClickContineuTimer(self, time, showContineuLabel)
	time = time or 1
	self.m_ClickContinueCacheConfig.m_Time = time
	self.m_ClickContinueCacheConfig.m_ShowContinueLabel = showContineuLabel
	if time == 0 then
		if self.m_ClickContinueCacheConfig.m_ShowContinueLabel == true then
			self.m_ContinueLabel:SetActive(true)
		end
		self.m_ClickContinueCondition = true
	else
		self.m_ClickContinueCondition = false
		self.m_ContinueLabel:SetActive(false)
		local cb = function ()
			if self.m_ClickContinueCacheConfig.m_ShowContinueLabel == true then
				self.m_ContinueLabel:SetActive(true)
			end		
			self.m_ClickContinueCondition = true
		end
		self.m_ClickContinueTimer = Utils.AddTimer(cb, 0, time)
	end
end

function CGuideView.StopClickContineuTimer(self)
	if self.m_ClickContinueTimer then
		Utils.DelTimer(self.m_ClickContinueTimer)
		self.m_ClickContinueTimer = nil
	end
	self.m_ClickContinueCacheConfig = {}
	self.m_ClickContinueCondition = true
end

function CGuideView.SpineLoopProcress(self, oTexture, ani, func)
	local oTarget = oTexture
	local spineAni = ani
	local cb = func
	if self.m_SpineLoopTimer then
		Utils.DelTimer(self.m_SpineLoopTimer)
		self.m_SpineLoopTimer = nil
	end
	if oTarget then
		if cb then
			cb()
		end
		--local spineAnis = {[1] = "idle", [2] = spineAni, [3] = "idle"}
		local spineAnis = {[1] = spineAni, [2] = "idle"}
		oTarget:SetSequenceAnimation(spineAnis)
		self.m_SpineLoopTimer = Utils.AddTimer(callback(self, "SpineLoopProcress", oTarget, spineAni, cb), 0 , 5)		
	end
end

function CGuideView.ShowShopTalk(self, oInfo)
	self:SpineGuide(1752, nil, {data.npcstoredata.RandomTalk[Utils.RandomInt(1, #oInfo.random_talk)].content}, {[1]=[[0]],}, nil, "dazhaohu", nil, {})
	self.m_EventWidget:AddUIEvent("click", function () self:OnClose() end)
	self.m_EventWidget:SetActive(true)
end

function CGuideView.SetJumpBtnActive(self, b)
	self.m_JumpBtn:SetActive(b)
end

return CGuideView
