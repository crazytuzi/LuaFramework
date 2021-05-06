local CDialogueAniView = class("CDialogueAniView", CViewBase)

function CDialogueAniView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Dialogue/DialogueAniView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	-- self.m_ExtendClose = "Black"
	self.m_Data = nil
end

function CDialogueAniView.OnCreateView(self)
	self.m_JumpBtn = self:NewUI(1, CButton)
	self.m_Input = self:NewUI(2, CInput)
	self.m_InputOkBtn = self:NewUI(3, CButton)
	self.m_ToggleBtn = self:NewUI(4, CButton)
	self.m_Container = self:NewUI(5, CWidget)
	self.m_SayWidget = self:NewUI(6, CBox)
	self.m_LeftName = self:NewUI(7, CLabel)
	self.m_RightName = self:NewUI(8, CLabel)
	self.m_LeftTexture = self:NewUI(9, CTexture)
	self.m_RightTextrue = self:NewUI(10, CTexture)
	self.m_LeftDialogue = self:NewUI(11, CLabelWriteEffect)
	self.m_RightDialogue = self:NewUI(12, CLabelWriteEffect)
	self.m_LeftNameWidget = self:NewUI(13, CBox)
	self.m_RightNameWidget = self:NewUI(14, CBox)
	self.m_AniBgTexture = self:NewUI(15, CTexture)
	self.m_CenterLive2dTexture = self:NewUI(16, CLive2dTexture)
	self.m_TopCoverTexture = self:NewUI(17, CTexture)
	self.m_TopCoverTexture.m_Mat = self.m_TopCoverTexture:GetMaterial()
	self.m_ResumeBtn = self:NewUI(18, CButton)
	self.m_NameInputWidget = self:NewUI(19, CBox)
	self.m_CenterSpineTextrue = self:NewUI(32, CSpineTexture)
	self.m_NameInputOkBtn = self:NewUI(21, CButton)
	self.m_MaskTopSayLabel = self:NewUI(22, CLabel)
	self.m_TopSideBgSprite = self:NewUI(23, CSprite)
	self.m_NanmeInput = self:NewUI(24, CInput)
	self.m_RandomNameBtn = self:NewUI(25, CButton)

	self.m_CoverModeBox1 = self:NewUI(26, CBox)
	self.m_CoverModeBox2 = self:NewUI(27, CBox)

	self.m_CenterTextrueGroup = self:NewUI(28, CBox)
	self.m_CenterTextrue = self:NewUI(29, CTexture)
	self.m_CenterTextrueOldSizeW, self.m_CenterTextrueOldSizeH = self.m_CenterTextrue:GetSize()	
	self.m_CenterNameLabel = self:NewUI(30, CLabel)
	self.m_CenterDialogueLalel = self:NewUI(31, CLabelWriteEffect)
	self.m_PlaySpeedBtn = self:NewUI(33, CButton)

	self.m_LeftVoiceTipsSpr = self:NewUI(34, CSprite)
	self.m_RightVoiceTipsSpr = self:NewUI(35, CSprite)

	self.m_TopMaskSprite = self:NewUI(36, CSprite)
	self.m_TopEffectRoot = self:NewUI(37, CSprite)

	self.m_XingYiXingTextrue = self:NewUI(38, CTexture)

	self.m_LeftSpineTexture = self:NewUI(39, CSpineTexture)
	self.m_RightSpineTextrue = self:NewUI(40, CSpineTexture)

	self.m_SayBottomSprite = self:NewUI(41, CSprite)
	self.m_AlpahTexture = self:NewUI(42, CTexture)
	self.m_AlpahTexture.m_Tween = self.m_AlpahTexture:GetComponent(classtype.TweenAlpha)

	self.m_MaskTopSayCenterLabel = self:NewUI(43, CLabelWriteEffect)
	self.m_SayJumpWidget = self:NewUI(44, CBox)

	self.m_CoverMaskTiemr = nil
	self.m_CoverMaskRemainTimer = 0

	self.m_MaskAniMode2CustionCb1 = nil
	self.m_MaskAniMode2CustionCb2 = nil

	UITools.ResizeToRootSize(self.m_Container)

	self.m_OwnerName = ""
	self.m_MinNameChar = 2
	self.m_MaxNameChar = 6
	self.m_DialogueSayTimer = nil
	self.m_DialogueDelaySayTimer = nil

	self.m_ShowBarrage = false

	g_DialogueAniCtrl.m_ReqName = false

	self:InitCoverBox()
	self:InitContent()
end

function CDialogueAniView.InitContent(self)
	self.m_JumpBtn:AddUIEvent("click", callback(self, "OnJump"))
	self.m_ToggleBtn:AddUIEvent("click", callback(self, "OnToggle"))
	self.m_InputOkBtn:AddUIEvent("click", callback(self, "OnBarrage"))
	self.m_Input:AddUIEvent("focuschange", callback(self, "OnFocusChange"))
	self.m_ResumeBtn:AddUIEvent("click", callback(self, "OnResume"))
	self.m_NameInputOkBtn:AddUIEvent("click", callback(self, "OnInputNameOk"))
	self.m_RandomNameBtn:AddUIEvent("click", callback(self, "RandomName"))
	self.m_PlaySpeedBtn:AddUIEvent("click", callback(self, "OnPlaySpeed"))
	self.m_SayJumpWidget:AddUIEvent("click", callback(self, "OnClickSayJump"))
	if g_DialogueAniCtrl:GetAniPlaySpeed() == 1 then
		self.m_PlaySpeedBtn:SetText("快进")
	else
		self.m_PlaySpeedBtn:SetText("快进中")
	end
	self.m_SayWidget:SetActive(false)	
	self.m_LeftVoiceTipsSpr:SetActive(false)
	self.m_RightVoiceTipsSpr:SetActive(false)	
	self.m_TopMaskSprite:SetActive(false)
	self.m_AlpahTexture:SetActive(false)
	g_DialogueAniCtrl:HideViewsWhenShowDialougeAniView()
end

function CDialogueAniView.SetContent(self, data)
	self.m_Data = data
	self.m_MaskAniMode2CustionCb1 = nil
	self.m_MaskAniMode2CustionCb2 = nil
	if self.m_Data then
		if self.m_ShowBarrage then			
			--netopenui.C2GSOpenInterface(define.OpenInterfaceType.Barrage)
			CBulletScreenView:ShowView(function ()
				g_TaskCtrl:CtrlC2GSGetTaskBarrage(data.id)
				self:InitBulletState()
			end)
		else
			CBulletScreenView:CloseView()
		end	
	end
end

function CDialogueAniView.OnJump(self)
	if not self.m_Data then
		self:CloseView()
		return
	end	
	g_DialogueAniCtrl:StopDialgueAni(self.m_Data.id, false, true)
end

function CDialogueAniView.OnToggle(self)
	local oView = CBulletScreenView:GetView()
	if not oView then
		return
	end
	if self.m_ToggleBtn:GetSelected() then
		IOTools.SetRoleData("dialogue_ani_bullet", 1)
		oView:SetActive(true)
		self.m_Input:SetActive(true)
		self.m_InputOkBtn:SetActive(true)
	else
		IOTools.SetRoleData("dialogue_ani_bullet", 0)
		oView:SetActive(false)		
		self.m_Input:SetActive(false)
		self.m_InputOkBtn:SetActive(false)		
	end
end

function CDialogueAniView.InitBulletState(self)
	local istate = IOTools.GetRoleData("dialogue_ani_bullet") or 1
	local oView = CBulletScreenView:GetView()
	if oView then
		oView:SetActive(istate == 1)
	end
	self.m_Input:SetActive(istate == 1)
	self.m_InputOkBtn:SetActive(istate == 1)
	self.m_ToggleBtn:SetSelected(istate == 0)
end

function CDialogueAniView.Destroy(self)	
	--g_ViewCtrl:CloseInterface(define.OpenInterfaceType.Barrage)	
	if self.m_CoverMaskRemainTimer ~= nil then
		Utils.DelTimer(self.m_CoverMaskRemainTimer)
		self.m_CoverMaskRemainTimer = nil
	end
	if self.m_DialogueSayTimer then
		Utils.DelTimer(self.m_DialogueSayTimer)
		self.m_DialogueSayTimer = nil
	end
	if self.m_DialogueDelaySayTimer then
		Utils.DelTimer(self.m_DialogueDelaySayTimer)
		self.m_DialogueDelaySayTimer = nil
	end	
	g_DialogueAniCtrl:ShowViewsWhenCloseDialougeAniView()
	self.m_CenterLive2dTexture:Destroy()
	CBulletScreenView:CloseView()
	g_TaskCtrl.m_BarrageId = nil
	CViewBase.Destroy(self)	
end

function CDialogueAniView.OnBarrage(self)
	local text = self.m_Input:GetText()
	if string.len(text) == 0 then 
		g_NotifyCtrl:FloatMsg("请输入发送内容")
		return
	end
	text = string.gsub(text, "#%u", "")
	if g_MaskWordCtrl:IsContainMaskWord(text) then
		local windowConfirmInfo = {
			msg				= "存在敏感词汇，是否发送？",
			okCallback		= function()
				self:OnSend(g_MaskWordCtrl:ReplaceMaskWord(text))
			end
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
	else
		self:OnSend(text)
	end
end

function CDialogueAniView.OnSend(self, text)
	g_TaskCtrl:CtrlC2GSSetTaskBarrage(self.m_Data.id, text)
	self.m_Input:SetText("")
end

function CDialogueAniView.SetNpcSay(self, sayData)
	if self.m_DialogueSayTimer then
		Utils.DelTimer(self.m_DialogueSayTimer)
		self.m_DialogueSayTimer = nil
	end
	
	if self.m_DialogueDelaySayTimer then
		Utils.DelTimer(self.m_DialogueDelaySayTimer)
		self.m_DialogueDelaySayTimer = nil
	end
	if not sayData then
		self.m_SayWidget:SetActive(false)
		self:ReSetAllTextureNil()
		if self.m_DialogueVoice then
			g_AudioCtrl:OnStopPlay()
			self.m_DialogueVoice = nil
		end		
		self.m_LeftVoiceTipsSpr:SetActive(false)
		self.m_RightVoiceTipsSpr:SetActive(false)
		self.m_SayJumpWidget:SetActive(false)		
		return
	end
	self.m_SayWidget:SetActive(true)
	self.m_LeftNameWidget:SetActive(false)
	self.m_RightNameWidget:SetActive(false)
	self.m_LeftDialogue:SetActive(false)
	self.m_RightDialogue:SetActive(false)
	self.m_CenterNameLabel:SetActive(false)
	self.m_CenterDialogueLalel:SetActive(false)
	self.m_SayBottomSprite:SetActive(false)
	self.m_LeftVoiceTipsSpr:SetActive(false)
	self.m_RightVoiceTipsSpr:SetActive(false)
	self.m_SayJumpWidget:SetActive(false)		

	local isLeft = sayData.isLeft == 0 and true or false
	local isClose = sayData.isClose == 1 and true or false
	local endTime = sayData.endTime or 3
	local isPause = sayData.isPause == 1 and true or false
	local content = sayData.content 
	local isCenter = sayData.isLeft == 2 and true or false
	local voiceId = sayData.voiceId or 0
	local isSpineIcon = sayData.isSpineIcon or false
 	local spineAni = sayData.spineAni or "idle"
 	local delayShowSay = sayData.delayShowSay
 	local isFadeIn = sayData.isFadeIn == nil and true or sayData.isFadeIn
 	local jumpTime = sayData.jumpTime

	if string.find(content, "@owner") then
		content = string.replace(content, "@owner", self.m_OwnerName)		
	end
	if content == "none" then
		self.m_SayWidget:SetActive(false)
		self:ReSetAllTextureNil()
		if self.m_DialogueVoice then
			g_AudioCtrl:OnStopPlay()
			self.m_DialogueVoice = nil				
		end				
		self.m_LeftVoiceTipsSpr:SetActive(false)
		self.m_RightVoiceTipsSpr:SetActive(false)			
		return
	end
	local name = sayData.name
	if name == "" then
		name = "我"
	end
	local shape = sayData.shape

	local isShowIcon = (sayData.showIcon == nil) and true or sayData.showIcon
	if isCenter then
		if not delayShowSay or delayShowSay == 0 then
			self.m_CenterNameLabel:SetActive(true)			
			self.m_SayBottomSprite:SetActive(true)
			self.m_CenterNameLabel:SetText(name)
			self.m_CenterDialogueLalel:SetActive(true)		
			if isFadeIn == false then
				self.m_CenterDialogueLalel:SetText(content)
			else
				self.m_CenterDialogueLalel:SetEffectText(content)
			end
		end

		if isShowIcon and shape then
			local path = string.format("Spine/Common/%s/Prefabs/Spine%s.prefab", tostring(shape), tostring(shape))
			if isSpineIcon and g_ResCtrl:IsExist(path) then
				self:SetDialogueMidTexture(true, shape, spineAni)
			else
				self:SetDialogueMidTexture(true, shape)
			end
		end
		self.m_LeftTexture:SetMainTextureNil()
		self.m_LeftTexture.npcShape = nil	
		self.m_LeftSpineTexture:SetMainTextureNil()
		self.m_LeftSpineTexture.npcShape = nil
		self.m_RightTextrue:SetMainTextureNil()
		self.m_RightTextrue.npcShape = nil	
		self.m_RightSpineTextrue:SetMainTextureNil()
		self.m_RightSpineTextrue.npcShape = nil			

	elseif isLeft then
		if not delayShowSay or delayShowSay == 0 then
			self.m_LeftNameWidget:SetActive(true)
			self.m_SayBottomSprite:SetActive(true)
			self.m_LeftName:SetText(name)
			self.m_LeftDialogue:SetActive(true)
			self.m_LeftDialogue:SetEffectText(content)		
		end
		local fuc1 = function(s)
			self.m_LeftSpineTexture:SetMainTextureNil()
			self.m_LeftSpineTexture.npcShape = nil
			if self.m_LeftTexture.npcShape ~= s then
				self.m_LeftTexture:LoadDialogPhoto(s)
				self.m_LeftTexture.npcShape = s
			end	
		end
		if isShowIcon then
			if isSpineIcon and shape then
				if self.m_LeftSpineTexture.npcShape ~= shape then
					local config = g_DialogueCtrl:GetDialogueSpineConfig(shape)	
					if config and #config >= 4 then
						self.m_LeftSpineTexture:SetSize(config[1], config[2])
						self.m_LeftSpineTexture:SetLocalPos(Vector3.New(-200 + config[3] , -200 + config[4], 0))
					end
					self.m_LeftSpineTexture:ShapeCommon(tostring(shape), function ()
						if spineAni == "default" then
							self.m_LeftSpineTexture:SetSequenceAnimation({"idle"})
						else
							self.m_LeftSpineTexture:SetSequenceAnimation(self:GetSpineAnisFromAni(spineAni))
						end	
						
					end, 1.73)	
				else
					fuc1(shape)
				end
			else
				fuc1(shape)
			end
		else
			self.m_LeftTexture:SetMainTextureNil()
			self.m_LeftTexture.npcShape = nil		
			self.m_LeftSpineTexture:SetMainTextureNil()
			self.m_LeftSpineTexture.npcShape = nil
		end
		self.m_RightTextrue:SetMainTextureNil()
		self.m_RightTextrue.npcShape = nil		
		self.m_RightSpineTextrue:SetMainTextureNil()
		self.m_RightSpineTextrue.npcShape = nil
	else
		if not delayShowSay or delayShowSay == 0 then
			self.m_RightNameWidget:SetActive(true)			
			self.m_SayBottomSprite:SetActive(true)
			self.m_RightName:SetText(name)
			self.m_RightDialogue:SetActive(true)
			self.m_RightDialogue:SetEffectText(content)
		end

		local fuc1 = function(s)
			self.m_RightSpineTextrue:SetMainTextureNil()
			self.m_RightSpineTextrue.npcShape = nil
			if self.m_RightTextrue.npcShape ~= s then
				self.m_RightTextrue:LoadDialogPhoto(s)
				self.m_RightTextrue.npcShape = s
			end	
		end		
		if isShowIcon then 
			if isSpineIcon and shape then
				if self.m_RightSpineTextrue.npcShape ~= shape then
					local config = g_DialogueCtrl:GetDialogueSpineConfig(shape)	
					if config and #config >= 4 then
						self.m_RightSpineTextrue:SetSize(config[1], config[2])
						self.m_RightSpineTextrue:SetLocalPos(Vector3.New(200 - config[3] , -200 + config[4], 0))
					end
					self.m_RightSpineTextrue:ShapeCommon(tostring(shape), function ()
						if spineAni == "default" then
							self.m_RightSpineTextrue:SetSequenceAnimation({"idle"})
						else
							self.m_RightSpineTextrue:SetSequenceAnimation(self:GetSpineAnisFromAni(spineAni))
						end														
					end, 1.73)	
				else
					fuc1(shape)
				end
			else
				fuc1(shape)
			end
		else
			self.m_RightTextrue:SetMainTextureNil()
			self.m_RightTextrue.npcShape = nil		
			self.m_RightSpineTextrue:SetMainTextureNil()
			self.m_RightSpineTextrue.npcShape = nil			

		end
		self.m_LeftTexture:SetMainTextureNil()
		self.m_LeftTexture.npcShape = nil		
		self.m_LeftSpineTexture:SetMainTextureNil()
		self.m_LeftSpineTexture.npcShape = nil
	end

	if not isCenter then
		self:SetDialogueMidTexture(false)
	end

	if voiceId and voiceId ~= 0 then
		if voiceId ~= -1 then
			g_AudioCtrl:PlayVoice(voiceId)
		end		
		self.m_DialogueVoice = voiceId

		if not delayShowSay or delayShowSay == 0 then
			if not isCenter then
				if isLeft then
					self.m_LeftVoiceTipsSpr:SetActive(true)
				else
					self.m_RightVoiceTipsSpr:SetActive(true)
				end
			end		
		end
	else
		g_AudioCtrl:OnStopPlay()
		self.m_DialogueVoice = nil
	end

	self.m_Endtime = 0
	local wrap = function (dt)
		if g_DialogueAniCtrl:IsPause() then
			return true
		end
		if tonumber(self.m_Data.id) ~= 888 then
			dt = dt * g_DialogueAniCtrl:GetAniPlaySpeed()
		end
		self.m_Endtime = self.m_Endtime + dt
		if self.m_Endtime >= endTime then
			if not Utils.IsNil(self) then			
				if isClose then
					self.m_SayWidget:SetActive(false)
					self:ReSetAllTextureNil()
					self.m_LeftVoiceTipsSpr:SetActive(false)
					self.m_RightVoiceTipsSpr:SetActive(false)						
					if self.m_DialogueVoice then
						g_AudioCtrl:OnStopPlay()
						self.m_DialogueVoice = nil
					end		
				end
			end
			return false
		end
		return true
	end

	self.m_DialogueSayTimer = Utils.AddTimer(wrap, 0, 0)

	--延时显示说话处理
	if delayShowSay and delayShowSay ~= 0 then
		local delayShow = function ()
			if Utils.IsNil(self) then
				return
			end
			if isCenter then
				self.m_CenterNameLabel:SetActive(true)	
				self.m_SayBottomSprite:SetActive(true)
				self.m_CenterNameLabel:SetText(name)
				self.m_CenterDialogueLalel:SetActive(true)		
				if isFadeIn == false then
					self.m_CenterDialogueLalel:SetText(content)
				else
					self.m_CenterDialogueLalel:SetEffectText(content)
				end
			elseif isLeft then
				self.m_LeftNameWidget:SetActive(true)
				self.m_SayBottomSprite:SetActive(true)
				self.m_LeftName:SetText(name)
				self.m_LeftDialogue:SetActive(true)
				self.m_LeftDialogue:SetEffectText(content)	
			else
				self.m_RightNameWidget:SetActive(true)	
				self.m_SayBottomSprite:SetActive(true)
				self.m_RightName:SetText(name)
				self.m_RightDialogue:SetActive(true)
				self.m_RightDialogue:SetEffectText(content)
			end
			if voiceId and voiceId ~= 0 then
				if not isCenter then
					if isLeft then					
						self.m_LeftVoiceTipsSpr:SetActive(true)
					else							
						self.m_RightVoiceTipsSpr:SetActive(true)
					end
				end	
			end	
		end
		self.m_DialogueDelaySayTimer = Utils.AddTimer(delayShow, 0, delayShowSay)
	end

	self:ProcressSayJump(jumpTime)
end

function CDialogueAniView.OnFocusChange(self)
	local isFocus = self.m_Input:IsFocus()
	if isFocus then
		g_DialogueAniCtrl:PauseStoryAni()			
	else
		g_DialogueAniCtrl:ResumeStoryAni()
	end
	self.m_LeftDialogue:SetPause(isFocus)
	self.m_RightDialogue:SetPause(isFocus)
end

function CDialogueAniView.SetBulletActive(self, b)
	--self.m_JumpBtn:SetActive(b and Utils.IsEditor())
	self.m_JumpBtn:SetActive(b)
	self.m_ToggleBtn:SetActive(b)
	self.m_Input:SetActive(b)
	self.m_InputOkBtn:SetActive(b)
	self.m_TopSideBgSprite:SetActive(b)
	self.m_PlaySpeedBtn:SetActive(b)
	self.m_ShowBarrage = b
end

function CDialogueAniView.ShowLive2D(self, b, model)
	self.m_CenterLive2dTexture:SetActive(b)
	if b and model then
		self.m_CenterLive2dTexture:SetDefaultMotion("idle_1")
		self.m_CenterLive2dTexture:LoadModel(tonumber(model))
		self.m_CenterLive2dTexture.m_LiveModel:PlayMotion("idle_1", false)
		self.m_CenterLive2dTexture.m_LiveModel:SetRandomMotionList({"idle_1"})
	end
end

function CDialogueAniView.DoLive2dAction(self, action)
	if self.m_CenterLive2dTexture and action and action ~= "none" then
		self.m_CenterLive2dTexture:SetDefaultMotion("idle_1")
		self.m_CenterLive2dTexture.m_LiveModel:PlayMotion(action, false)
	end
end

function CDialogueAniView.ShowReNameBox(self, b)
	self.m_NameInputWidget:SetActive(b)
	if b then
		g_DialogueAniCtrl:PauseStoryAni()
		self:RandomName()
	end
end

function CDialogueAniView.OnPlaySpeed(self)
	g_DialogueAniCtrl:ChangeAniPlaySpeed()
	if g_DialogueAniCtrl:GetAniPlaySpeed() == 1 then
		self.m_PlaySpeedBtn:SetText("快进")
	else
		self.m_PlaySpeedBtn:SetText("快进中")
	end
end

function CDialogueAniView.OnClickSayJump(self)
	self.m_SayJumpWidget:SetActive(false)
	g_DialogueAniCtrl:SetDialogueAniJump(self.m_Data.id, self.m_SayJumpWidget.m_JumpTime)
	self.m_SayJumpWidget.m_JumpTime = nil
	self:SetNpcSay()
end

function CDialogueAniView.ShowAniBgTexture(self, b, path)
	if b then
		local sPath = string.format("Texture/"..path..".png")	
		self.m_AniBgTexture:LoadPath(sPath)
	else
		self.m_AniBgTexture:SetMainTextureNil()
	end
end

function CDialogueAniView.ShowCoverMask(self, b, mode, showAlpahTextrue)
	if b then
		mode = mode or 1
		local oCoverBox = nil		
		if mode == 0 then			
			self.m_TopMaskSprite:SetActive(false)
			return

		elseif mode == 1 then
			local cb = function (obj)
				if not Utils.IsNil(self) then
					self.m_TopMaskSprite:SetActive(false)	
					self:AdjustBiYanEffSize(obj)
				end			
			end
			local cb2 = function ()		
				if not Utils.IsNil(self) then		
					if showAlpahTextrue then
						self.m_AlpahTexture:SetActive(false)
					end		
				end
			end			
			local localPath = "Effect/UI/ui_eff_story/Prefabs/ui_eff_story_12_zhayan.prefab"
			local oEff = CUIDialogueAniEffect.New(self.m_TopEffectRoot, localPath, cb)
			oEff:SetParent(self.m_TopEffectRoot.m_Transform)
			Utils.AddTimer(callback(oEff, "Destroy"), 0 , 4)
			Utils.AddTimer(cb2, 0 , 3)
			g_EffectCtrl:AddEffect(oEff)

			if showAlpahTextrue then
				self.m_AlpahTexture:SetActive(true)
				self.m_AlpahTexture.m_Tween:Toggle()
			else
				self.m_AlpahTexture:SetActive(false)
			end
		
			return
		elseif mode == 2 then
			local cb = function ()	
				if not Utils.IsNil(self) then			
					self.m_TopMaskSprite:SetActive(true)				
				end
			end
			local localPath = "Effect/UI/ui_eff_story/Prefabs/ui_eff_story_12_biyan.prefab"
			local oEff = CUIDialogueAniEffect.New(self.m_TopEffectRoot, localPath, function (obj)
				if not Utils.IsNil(self) then					
					self:AdjustBiYanEffSize(obj)
				end	
			end)
			Utils.AddTimer(cb, 0 , 1.5)
			Utils.AddTimer(callback(oEff, "Destroy"), 0 , 4)
			oEff:SetParent(self.m_TopEffectRoot.m_Transform)
			g_EffectCtrl:AddEffect(oEff)
			return

		elseif mode == 3 then			
			self.m_TopMaskSprite:SetActive(true)
			return	

		elseif mode == 4 then			
			local cb1 = function ()		
				if not Utils.IsNil(self) then			
					self.m_TopMaskSprite:SetActive(true)				
					if self.m_MaskAniMode2CustionCb1 then
						self.m_MaskAniMode2CustionCb1()
					end
				end
			end
			local localPath = "Effect/UI/ui_eff_story/Prefabs/ui_eff_story_12_biyan.prefab"
			local oEff = CUIDialogueAniEffect.New(self.m_TopEffectRoot, localPath, function (obj )
				if not Utils.IsNil(self) then					
					self:AdjustBiYanEffSize(obj)
				end	
			end)
			Utils.AddTimer(cb1, 0 , 1.5)
			Utils.AddTimer(callback(oEff, "Destroy"), 0 , 2)
			oEff:SetParent(self.m_TopEffectRoot.m_Transform)
			g_EffectCtrl:AddEffect(oEff)

			local cb2 = function ()				
				local cb3 = function (obj)		
					if not Utils.IsNil(self) then			
						self.m_TopMaskSprite:SetActive(false)		
						self:AdjustBiYanEffSize(obj)		
					end
				end
				local localPath2 = "Effect/UI/ui_eff_story/Prefabs/ui_eff_story_12_zhayan.prefab"
				local oEff2 = CUIDialogueAniEffect.New(self.m_TopEffectRoot, localPath2, cb3)
				g_EffectCtrl:AddEffect(oEff2)
				Utils.AddTimer(callback(oEff2, "Destroy"), 0 , 3)
				oEff2:SetParent(self.m_TopEffectRoot.m_Transform)

				local cb4 = function ()
					if not Utils.IsNil(self) then	
						if self.m_MaskAniMode2CustionCb2 then
							self.m_MaskAniMode2CustionCb2()
						end
					end
				end
				Utils.AddTimer(cb4, 0 , 3.5)					
			end			
			Utils.AddTimer(cb2, 0 , 3)					

		elseif mode == 5 then
			if self.m_MaskAniMode2CustionCb1 then
				self.m_MaskAniMode2CustionCb1()
			end
			local cb1 = function (obj)		
				if not Utils.IsNil(self) then		
					self.m_TopMaskSprite:SetActive(false)				
					self:AdjustBiYanEffSize(obj)
				end
			end
			local localPath2 = "Effect/UI/ui_eff_story/Prefabs/ui_eff_story_12_zhayan.prefab"
			local oEff2 = CUIDialogueAniEffect.New(self.m_TopEffectRoot, localPath2, cb1)
			g_EffectCtrl:AddEffect(oEff2)
			Utils.AddTimer(callback(oEff2, "Destroy"), 0 , 3)
			oEff2:SetParent(self.m_TopEffectRoot.m_Transform)

			local cb2 = function ()
				if not Utils.IsNil(self) then
					if self.m_MaskAniMode2CustionCb2 then
						self.m_MaskAniMode2CustionCb2()
					end
				end
			end
			self.m_TopMaskSprite:SetActive(true)	
			Utils.AddTimer(cb2, 0 , 3.5)			
			return
		end
		-- if not oCoverBox then
		-- 	return
		-- end
		-- local time = oCoverBox.m_Time
		-- local gotime = 0
		-- local function cb(dt)
		-- 	if mode == 2 then
		-- 		if gotime >= time /2 then
		-- 			if self.m_MaskAniMode2CustionCb1 then
		-- 				self.m_MaskAniMode2CustionCb1()
		-- 				self.m_MaskAniMode2CustionCb1 = nil
		-- 			end
		-- 		end
		-- 	end

		-- 	if Utils.IsNil(self) or Utils.IsNil(oCoverBox) or gotime > time then
		-- 		if mode == 2 then
		-- 			if self.m_MaskAniMode2CustionCb2 then
		-- 				self.m_MaskAniMode2CustionCb2()
		-- 				self.m_MaskAniMode2CustionCb2 = nil
		-- 			end
		-- 		end
		-- 		return false
		-- 	end		
		-- 	gotime = gotime + dt	
		-- 	local w = math.floor( math.max(oCoverBox.m_W:GetLocalPos().y, 0)) / 100 
		-- 	local h = math.floor( math.max(oCoverBox.m_H:GetLocalPos().y, 0)) / 100 
		-- 	local a = math.floor( math.max(oCoverBox.m_A:GetLocalPos().y, 0))
		-- 	self.m_TopCoverTexture:SetActive(false)							
		-- 	self.m_TopCoverTexture.m_Mat:SetVector("_SkipRange", Vector4.New(0.5, 0.5,  w , h))	
		-- 	self.m_TopCoverTexture:SetAlpha(a/255)	
		-- 	self.m_TopCoverTexture:SetActive(true)	


		-- 	return true
		-- end
		-- oCoverBox.m_W.m_Tween:Toggle()
		-- oCoverBox.m_H.m_Tween:Toggle()
		-- oCoverBox.m_A.m_Tween:Toggle()
		-- Utils.AddTimer(cb, 0, 0)		
	else
		self.m_TopMaskSprite:SetActive(false)
	end
end

function CDialogueAniView.ShowCoverMaskSay(self, b, msg, isCenter)
	if isCenter then
		self.m_MaskTopSayCenterLabel:SetActive(b)
		self.m_MaskTopSayCenterLabel:SetEffectText(msg)
	else
		self.m_MaskTopSayLabel:SetActive(b)
		self.m_MaskTopSayLabel:SetText(msg)
	end
end

function CDialogueAniView.PauseAni(self)
	g_DialogueAniCtrl:PauseStoryAni()
end

function CDialogueAniView.ShowResumeBtn(self, b, msg)
	g_DialogueAniCtrl.m_ReqName = false
	self.m_ResumeBtn:SetActive(b)
	if b then
		self.m_ResumeBtn:SetText(msg)
		g_DialogueAniCtrl:PauseStoryAni()
	end
end

function CDialogueAniView.OnResume(self)
	self.m_ResumeBtn:SetActive(false)
	if self.m_DialogueVoice then
		g_AudioCtrl:OnStopPlay()
		self.m_DialogueVoice = nil
	end	
 	g_DialogueAniCtrl:ResumeStoryAni()
end

function CDialogueAniView.OnInputNameOk(self)
	if g_DialogueAniCtrl.m_ReqName == true then
		return
	end
	local sName = self.m_NanmeInput:GetText()
	local nameLen = #CMaskWordTree:GetCharList(sName)
	if nameLen < self.m_MinNameChar or nameLen > self.m_MaxNameChar then
		g_NotifyCtrl:FloatMsg("角色名字为2-6个字")
		return
	end
	if g_MaskWordCtrl:IsContainMaskWord(sName) then
		g_NotifyCtrl:FloatMsg("名字中包含屏蔽字")
		return
	end
	if not string.isIllegal(sName) then
		g_NotifyCtrl:FloatMsg("含有特殊字符，请重新输入")
		return
	end
	g_DialogueAniCtrl.m_ReqName = true
	self.m_OwnerName = sName
	netplayer.C2GSInitRoleName(sName)	
end

function CDialogueAniView.RandomName(self, oBtn)
	local function getone()
		local sName = ""
		local len = string.len(sName)
		local first,mid,last= "", "", ""
		local firstdata, randomvalue 
		while len == 0 or len > 18 do
			firstdata = table.randomvalue(data.randomnamedata.FIRST)
			first = firstdata.first
			mid = ""
			randomvalue = Utils.RandomInt(1, 100)
			if randomvalue <= 70 and firstdata.mid then
				randomvalue = Utils.RandomInt(1, #firstdata.mid)
				mid = firstdata.mid[randomvalue] or ""
			end

			last = ""
			if g_AttrCtrl.sex == 1 then
				last = table.randomvalue(data.randomnamedata.MALE)
			else
				last = table.randomvalue(data.randomnamedata.FEMALE)
			end
			sName = first..mid..last
			len = string.len(sName)
		end
		sName = string.gsub(sName, "^%s*(.-)%s*$", "%1")
		return sName
	end
	local sName = getone()
	if not sName then
		sName = "一个名字"
	end
	self.m_NanmeInput:SetText(sName)

	if oBtn then
		-- g_UploadDataCtrl:CreateRoleUpload({time=self.m_ShowPageTime, click= "随机取名"})
	end
end

function CDialogueAniView.InitCoverBox(self)
	local function InitConverBox(oBox)
		if not oBox then
			return
		end
		oBox.m_W = oBox:NewUI(1, CSprite)
		oBox.m_H = oBox:NewUI(2, CSprite)
		oBox.m_A = oBox:NewUI(3, CSprite)
		oBox.m_W.m_Tween = oBox.m_W:GetComponent(classtype.TweenPosition)
		oBox.m_H.m_Tween = oBox.m_H:GetComponent(classtype.TweenPosition)
		oBox.m_A.m_Tween = oBox.m_A:GetComponent(classtype.TweenPosition)
		oBox.m_Time = oBox.m_W.m_Tween.duration
	end
	InitConverBox(self.m_CoverModeBox1)
	InitConverBox(self.m_CoverModeBox2)
end

function CDialogueAniView.SetDialogueMidTexture(self, visible, path, spineAnim)
	if spineAnim and spineAnim ~= "none" and spineAnim ~= "" then
		--超级大模型和一般spine大小区别
		if self.m_CenterSpineTextrue.npcShape ~= tonumber(path) then
			local config = g_DialogueCtrl:GetDialogueSpineConfig(tonumber(path), true)	
			if config and #config >= 4 then
				self.m_CenterSpineTextrue:SetSize(config[1], config[2])
				self.m_CenterSpineTextrue:SetLocalPos(Vector3.New(config[3], config[4], 0))
			else
				self.m_CenterSpineTextrue:SetSize(600, 600)
				self.m_CenterSpineTextrue:SetLocalPos(Vector3.New(0, -65, 0))
			end
			self.m_CenterSpineTextrue.npcShape = tonumber(path)
			self.m_CenterSpineTextrue:ShapeCommon(path, function ()
				if spineAnim == "default" then
					self.m_CenterSpineTextrue:SetSequenceAnimation({"idle"})
				else
					self.m_CenterSpineTextrue:SetSequenceAnimation(self:GetSpineAnisFromAni(spineAnim))
				end			
			end, 1.73)	
		else
			if spineAnim == "default" then
				self.m_CenterSpineTextrue:SetSequenceAnimation({"idle"})
			else
				self.m_CenterSpineTextrue:SetSequenceAnimation(self:GetSpineAnisFromAni(spineAnim))
			end		
		end		
		self.m_CenterTextrue:SetMainTextureNil()
		self.m_CenterTextrue.npcShape = nil
	elseif visible == true and path ~= "none" and path ~= "" then			
		local cb = function( )
			self.m_CenterTextrue:MakePixelPerfect()
		end
		if self.m_CenterTextrue.npcShape ~= tonumber(path) then
			self.m_CenterTextrue.npcShape = tonumber(path)
			self.m_CenterTextrue:LoadFullPhoto(tonumber(path), cb)
		end
		self.m_CenterSpineTextrue:SetMainTextureNil()
		self.m_CenterSpineTextrue.npcShape = nil
	else
		self.m_CenterTextrue:SetMainTextureNil()
		self.m_CenterTextrue.npcShape = nil
		self.m_CenterSpineTextrue:SetMainTextureNil()
		self.m_CenterSpineTextrue.npcShape = nil
	end
end

function CDialogueAniView.SetMaskAniMode2Cb(self, cb1, cb2)
	self.m_MaskAniMode2CustionCb1 = cb1
	self.m_MaskAniMode2CustionCb2 = cb2
end

function CDialogueAniView.ShowXingYiXingEffect(self, path, visible)
	self.m_XingYiXingTextrue:SetActive(visible == true)
end

function CDialogueAniView.ReSetAllTextureNil(self)
	self.m_LeftTexture:SetMainTextureNil()
	self.m_LeftTexture.npcShape = nil		
	self.m_LeftSpineTexture:SetMainTextureNil()
	self.m_LeftSpineTexture.npcShape = nil
	self.m_RightTextrue:SetMainTextureNil()
	self.m_RightTextrue.npcShape = nil	
	self.m_RightSpineTextrue:SetMainTextureNil()
	self.m_RightSpineTextrue.npcShape = nil
	self.m_CenterTextrue:SetMainTextureNil()
	self.m_CenterTextrue.npcShape = nil
	self.m_CenterSpineTextrue:SetMainTextureNil()	
	self.m_CenterSpineTextrue.npcShape = nil
end

function CDialogueAniView.HideSayWidget(self, hide)
	if hide then
		self.m_SayWidget:SetActive(false)
		self.m_LeftVoiceTipsSpr:SetActive(false)
		self.m_RightVoiceTipsSpr:SetActive(false)
		self:ReSetAllTextureNil()
	end
end

function CDialogueAniView.GetSpineAnisFromAni(self, ani)
	local t = {"idle"}
	local list = string.split(ani, ",")
	if list and next(list) then
		t = list
	end
	return t
end

function CDialogueAniView.AdjustBiYanEffSize(self, oEff)
	if oEff then
		local w, h = UITools.GetRootSize()	
		local s = 1
		if w > 1334 then
			s = w / 1334
		end
		local ratio = 1334 / 750 *  h / w
		if oEff.m_Eff then
			local oBox = CBox.New(oEff.m_Eff.m_GameObject)
			oBox.m_Effect = oBox:NewUI(1, CBox)
			if oBox.m_Effect then
				oBox.m_Effect:SetLocalScale(Vector3.New(s , s * ratio, 1))
			end
		end
	end
end

function CDialogueAniView.ProcressSayJump(self, jumpTime)
	if not jumpTime or jumpTime == 0 then
		return
	end	
	self.m_SayJumpWidget:SetActive(true)
	self.m_SayJumpWidget.m_JumpTime = jumpTime
end

return CDialogueAniView