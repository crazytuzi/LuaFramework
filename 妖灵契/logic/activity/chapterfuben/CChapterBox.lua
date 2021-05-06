local CChapterBox = class("CChapterBox", CBox)

function CChapterBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_LevelBoxDic = {}
	self.m_ForceLevel = nil
	self.m_GuideLevel = nil
	self.m_IsDoingOpenEffect = true
	self:InitBox()
end

function CChapterBox.InitBox(self)
	self.m_LevelWidget = self:NewUI(1, CWidget)
	self.m_LevelBox = self:NewUI(2, CBox)
    self.m_HeroBox = self:NewUI(3, CBox)
    self.m_ActorTexture = self:NewUI(4, CActorTexture)
    self.m_ChapterFuBenLavelPart = self:NewUI(5, CChapterFuBenLavelPart)
    self.m_LeftWidget = self:NewUI(6, CWidget)
    self.m_RightWidget = self:NewUI(7, CWidget)
    self.m_ForceMaskSpr = self:NewUI(8, CSprite)
    self.m_DifficultTexture = self:NewUI(9, CTexture)
	self:InitContent()
end

function CChapterBox.SetParentView(self, oView)
	self.m_ParentView = oView
end

function CChapterBox.InitContent(self)
	self.m_ChapterType = nil
	self.m_ChapterID = nil
	self.m_CurDialogueID = nil --普通剧场
	self.m_DialogueTimer = nil
	self.m_CurTaskDialogueID = nil --任务剧场
	self.m_TaskDialogueTimer = nil
	self.m_BookShape = nil --立体书模型
	self.m_LevelBox:SetActive(false)
	self.m_ForceMaskSpr:SetActive(false)
	self.m_DifficultTexture:SetActive(false)
	self:InitHeroBox()
	self.m_ChapterFuBenLavelPart:SetHideCallBack(callback(self, "OnShowLavelPart", false))
	self.m_ChapterFuBenLavelPart:SetLineUpCallBack(callback(self, "EnableAnimator", false))
	g_ChapterFuBenCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnChapterFuBenEvent"))
end

function CChapterBox.InitHeroBox(self)
	local oHeroBox = self.m_HeroBox
	oHeroBox:SetActive(false)
 	oHeroBox.m_AvterTexture = oHeroBox:NewUI(2, CTexture)
 	oHeroBox.m_DuiHuaLabel = oHeroBox:NewUI(3, CLabel)
 	oHeroBox.m_SocialEmoji = oHeroBox:NewUI(4, CSprite)
 	oHeroBox.m_AvterWidget = oHeroBox:NewUI(5, CWidget)
 	oHeroBox.m_SocialEmojiBG = oHeroBox:NewUI(6, CSprite)
 	oHeroBox.m_DuiHuaLabel:SetActive(false)
 	oHeroBox.m_SocialEmojiBG:SetActive(false)
	local school = g_AttrCtrl.school
	local sex = g_AttrCtrl.sex
	local shape = 1502
	for i,v in ipairs(data.roletypedata.DATA) do
		if v.school == school and v.sex == sex then
			shape = v.shape
			break
		end
	end
 	oHeroBox.m_AvterTexture:LoadPath(string.format("Texture/ChapterFuBen/yuan_%d.png", shape), function () end)
 	oHeroBox.m_TweenRotation = oHeroBox:GetComponent(classtype.TweenRotation)
 	oHeroBox.m_TweenAlpha = oHeroBox:GetComponent(classtype.TweenAlpha)
 	oHeroBox.m_TweenRotation.enabled = false
 	oHeroBox.m_TweenAlpha.enabled = false
end

function CChapterBox.RefreshHeroBox(self, oBox)
	local oHeroBox = self.m_HeroBox
	if oBox then
		oHeroBox:SetActive(true)
	 	oHeroBox.m_TweenRotation.enabled = true
	 	oHeroBox.m_TweenAlpha.enabled = true
		oHeroBox:SetParent(self.m_LevelWidget.m_Transform)
		local dData = oBox.m_Data
		if dData.isrotate == 1 then
			oHeroBox.m_AvterTexture:SetLocalRotation(Quaternion.Euler(0, 0, 0))
		else
			oHeroBox.m_AvterTexture:SetLocalRotation(Quaternion.Euler(0, 180, 0))
		end
	 	oHeroBox.m_AvterWidget:SetLocalScale(Vector3.New(dData.ui_scale, dData.ui_scale, dData.ui_scale))
		oHeroBox:SetLocalPos(Vector3.New(dData.hero_pos.x, dData.hero_pos.y, 0))
	else
		oHeroBox.m_TweenRotation:ResetToBeginning()
		oHeroBox.m_TweenAlpha:ResetToBeginning()
 		oHeroBox.m_TweenRotation.enabled = false
 		oHeroBox.m_TweenAlpha.enabled = false
		oHeroBox:SetActive(false)
	end
end

function CChapterBox.OnChapterFuBenEvent(self, oCtrl)
	if oCtrl.m_EventID == define.ChapterFuBen.Event.OnUpdateChapterExtraReward then
		self:RefreshChapterInfo()
	elseif oCtrl.m_EventID == define.ChapterFuBen.Event.OnChapterInfo then
		self:RefreshChapterInfo()
	end
end

function CChapterBox.SetChapter(self, chapterid, chaptertype)
	printc("剧情章节：", chapterid)
	self:EnableAnimator(true)
	self.m_ChapterID = chapterid
	self.m_ChapterType = chaptertype
	self.m_DifficultTexture:SetActive(self.m_ChapterType == define.ChapterFuBen.Type.Difficult)
	nethuodong.C2GSGetChapterInfo(self.m_ChapterID, self.m_ChapterType)
	self:SetChapterInfo()
	local dData = DataTools.GetChapterInfo(self.m_ChapterType, self.m_ChapterID)
	if self.m_BookShape == dData.shape then
		self.m_ActorTexture:SetActive(false)
		local function delay(obj)
			if Utils.IsNil(obj) then
				return
			end
			obj.m_ActorTexture:SetActive(true)
		end
		Utils.AddTimer(objcall(self, delay), 0, 0)
	else
		self.m_BookShape = dData.shape
		self.m_ActorTexture:ChangeShape(self.m_BookShape, {})
	end

	self:StopDialogue()
	self:SetDialogue(true)
end

function CChapterBox.EnableAnimator(self, b)
	if self.m_ActorTexture and self.m_ActorTexture.m_ActorCamera then
		local model = self.m_ActorTexture.m_ActorCamera:GetModel()
		if model then
			local mainModel = model:GetMainModel()
			if mainModel then
				local animator = mainModel:GetComponent(classtype.Animator)
				if animator then
					animator.enabled = b
				end
			end
		end
	end
end

function CChapterBox.GetChapterID(self)
	return self.m_ChapterID
end

function CChapterBox.ClearLevelBoxDic(self)
	for i,v in pairs(self.m_LevelBoxDic) do
		v:SetActive(false)
		v:Destroy()
	end
	self.m_LevelBoxDic = {}
end

function CChapterBox.SetChapterInfo(self)
	self:ClearLevelBoxDic()
	local dChapter = DataTools.GetChapterConfig(self.m_ChapterType, self.m_ChapterID)
	for i,v in pairs(dChapter) do
		local oBox = self:CreateLevelBox(v)
		if i == 1 or i == 2 or i == 3 then
			g_GuideCtrl:AddGuideUI(string.format("chapter_fuben_btn_%d", i), oBox.m_AvterTexture)
		end
		self.m_LevelBoxDic[v.level] = oBox
	end
	g_GuideCtrl:TriggerJQFBGuide()
end

function CChapterBox.CreateLevelBox(self, dLevel)
	local oBox = self.m_LevelBox:Clone()
 	oBox.m_LevelLabel = oBox:NewUI(2, CLabel)
 	oBox.m_RewardSpr = oBox:NewUI(3, CSprite)
 	oBox.m_StarGrid = oBox:NewUI(4, CGrid)
 	oBox.m_AvterTexture = oBox:NewUI(5, CTexture)
 	oBox.m_RedDotSpr = oBox:NewUI(6, CSprite)
 	oBox.m_DuiHuaLabel = oBox:NewUI(7, CLabel)
 	oBox.m_OtherObj = oBox:NewUI(8, CObject)
 	oBox.m_SocialEmoji = oBox:NewUI(9, CSprite)
 	oBox.m_AvterWidget = oBox:NewUI(10, CWidget)
 	oBox.m_SocialEmojiBG = oBox:NewUI(11, CSprite)
 	oBox.m_LockSpr = oBox:NewUI(12, CSprite)
	
 	oBox.m_PartnerBox = oBox:NewUI(13, CBox)
	oBox.m_PartnerBox.m_IconSprite = oBox.m_PartnerBox:NewUI(1, CSprite)
	oBox.m_PartnerBox.m_CountLabel = oBox.m_PartnerBox:NewUI(2, CLabel)
	oBox.m_PartnerBox.m_BorderSpr = oBox.m_PartnerBox:NewUI(3, CSprite) --伙伴背景
	oBox.m_PartnerBox.m_ChipSpr = oBox.m_PartnerBox:NewUI(4, CSprite) --伙伴碎片

	oBox.m_TweenRotation = oBox.m_RewardSpr:GetComponent(classtype.TweenRotation)
	oBox.m_TweenRotation.enabled = false
 	oBox.m_RedDotSpr:SetActive(false)
 	oBox.m_DuiHuaLabel:SetActive(false)
 	oBox.m_SocialEmojiBG:SetActive(false)
 	oBox.m_OtherObj:SetActive(false)
 	oBox.m_RewardSpr:SetActive(false)
 	oBox.m_PartnerBox:SetActive(false)
 	oBox.m_StarGrid:InitChild(function (obj, idx)
 		local oSpr = CSprite.New(obj)
 		oSpr:SetSpriteName("pic_chapter_star_kong")
 		return oSpr
 	end)
 	oBox.m_Data = dLevel
 	oBox.m_SpriteStr1 = "pic_baoxiang_3" 
	oBox.m_SpriteStr2 = "pic_baoxiang_3_h"
 	oBox.m_LevelLabel:SetText(string.format("%d-%d", dLevel.chapterid, dLevel.level))
 	oBox:SetParent(self.m_LevelWidget.m_Transform)
 	local pos = Vector3.New(dLevel.ui_pos.x, dLevel.ui_pos.y, 0)
 	oBox:SetLocalPos(pos)
 	oBox.m_AvterWidget:SetLocalScale(Vector3.New(dLevel.ui_scale, dLevel.ui_scale, dLevel.ui_scale))
 	if dLevel.isrotate == 1 then
 		oBox.m_AvterTexture:SetLocalRotation(Quaternion.Euler(0, 180, 0))
 	else
 		oBox.m_AvterTexture:SetLocalRotation(Quaternion.Euler(0, 0, 0))
 	end
 	oBox.m_AvterTexture:AddUIEvent("click", callback(self, "OnLevel", oBox))
 	if oBox.m_Data.type == define.ChapterFuBen.Type.Simple then
	 	oBox.m_RewardSpr:SetActive(#dLevel.extra_reward > 0)
	 	oBox.m_RewardSpr:AddUIEvent("click", callback(self, "OnReward", oBox))
	elseif oBox.m_Data.type == define.ChapterFuBen.Type.Difficult then
		local bAct= dLevel.partnerclip > 0
		oBox.m_PartnerBox:SetActive(bAct)
		if bAct then
			local sid = dLevel.partnerclip
			local oItem = CItem.NewBySid(tonumber(sid))
			oBox.m_PartnerBox.m_IconSprite:SpriteAvatar(oItem:GetValue("icon"))
			local rare = oItem:GetValue("rare")
			oBox.m_PartnerBox.m_BorderSpr:SetSpriteName(g_PartnerCtrl:GetRareBorderSpriteName(rare))
			oBox.m_PartnerBox.m_ChipSpr:SetActive(true)
			oBox.m_PartnerBox.m_ChipSpr:SetSpriteName(g_PartnerCtrl:GetChipMarkSpriteName(rare))
			oBox.m_PartnerBox.m_IconSprite:AddUIEvent("click", callback(self, "OnPartner", sid, oBox.m_PartnerBox))
		end
	end
 	return oBox
end

function CChapterBox.ShowLevelBox(self, bDelay)
 	if self.m_DelayTimer then
 		Utils.DelTimer(self.m_DelayTimer)
 		self.m_DelayTimer = nil
 	end
 	if bDelay then
	 	local idx = 0
	 	local function delay()
	 		idx = idx + 1
	 		if idx == 1 then
			 	for i,v in pairs(self.m_LevelBoxDic) do
			 		if not Utils.IsNil(v) then
						v:SetActive(true)
						v.m_AvterTexture:AutoResizeBoxCollider(true)
					end
				end
				return true
			elseif idx == 2 then
				for i,v in pairs(self.m_LevelBoxDic) do
			 		if not Utils.IsNil(v) then

						v.m_OtherObj:SetActive(true)
					end
				end
				self.m_IsDoingOpenEffect = false
				return true
			end
			return false
	 	end
	 	self.m_DelayTimer = Utils.AddTimer(delay, 1, 1)
	else
		for i,v in pairs(self.m_LevelBoxDic) do
	 		if not Utils.IsNil(v) then
				v:SetActive(true)
				v.m_OtherObj:SetActive(true)
				v.m_AvterTexture:AutoResizeBoxCollider(true)
			end
		end		
	end
end

function CChapterBox.OnReward(self, oBox)
	self:DelGuideLevel()
	if oBox.m_RewardStatus then
		nethuodong.C2GSGetExtraReward(oBox.m_Data.chapterid, oBox.m_Data.level, oBox.m_Data.type)
	else
		CChapterFuBenRewardView:ShowView(function (oView)
			oView:SetLevelData(oBox.m_Data)
		end)
	end
end

function CChapterBox.OnPartner(self, sid, oBox)
	g_WindowTipCtrl:SetWindowItemTipsSimpleItemInfo(sid, {widget = oBox}, nil)
end

function CChapterBox.OnLevel(self, oBox)
	local dData = oBox.m_Data
	local bOpen = g_ChapterFuBenCtrl:CheckChapterLevelOpen(dData.type, dData.chapterid, dData.level)
	if bOpen then
		self:OnShowLavelPart(true, oBox)
	else
		self:OnLock(oBox)
	end
	self:DelGuideLevel()
end

function CChapterBox.OnShowLavelPart(self, bShow, oBox)
	if Utils.IsNil(self) then
		return
	end
	if bShow and oBox then
		self.m_LevelID = oBox.m_Data.level
		oBox:SetParent(self.m_Transform)
		local widget
		if oBox.m_Data.isrotate == 0 then
			widget = self.m_LeftWidget
		else
			widget = self.m_RightWidget
		end
		local pos1 = oBox:GetLocalPos()
		local pos2 = widget:GetLocalPos()
		local x = pos2.x - pos1.x * 1.7
		local y = pos2.y - pos1.y * 1.7
		oBox:SetParent(self.m_LevelWidget.m_Transform)
		DOTween.DOKill(self.m_LevelWidget.m_Transform)
		local tween1 = DOTween.DOScale(self.m_LevelWidget.m_Transform, Vector3.New(1.7, 1.7, 1.7), 0.5)
		local tween2 = DOTween.DOLocalMove(self.m_LevelWidget.m_Transform, Vector3.New(x, y, 0), 0.5)
		--self.m_LevelWidget:SetLocalScale(Vector3.New(2, 2, 2))
		--self.m_LevelWidget:SetLocalPos(Vector3.New(x, y, 0))
		self.m_ChapterFuBenLavelPart:SetActive(true)
		self.m_ChapterFuBenLavelPart:SetChapterLevel(oBox.m_Data.type, oBox.m_Data.chapterid, oBox.m_Data.level)
		self:RefreshHeroBox(oBox)
		self:StopDialogue()
		self:CheckTaskDialogue(oBox)
		self.m_ParentView:ShowOther(false)
		self:ShowOther(false)
	else
		DOTween.DOKill(self.m_LevelWidget.m_Transform)
		self:ShowOther(true)
		self.m_LevelID = nil
		self:RefreshHeroBox()
		self:CheckTaskDialogue(nil)
		self:SetDialogue(true)
		self.m_LevelWidget:SetLocalScale(Vector3.New(1, 1, 1))
		self.m_LevelWidget:SetLocalPos(Vector3.New(0, 0, 0))
		self.m_ParentView:ShowOther(true)
	end
end

function CChapterBox.ShowOther(self, bShow)
	for i,v in pairs(self.m_LevelBoxDic) do
		if v.m_Data.level == self.m_LevelID then
			if self.m_ChapterType == define.ChapterFuBen.Type.Simple then
				v.m_RewardSpr:SetActive(#v.m_Data.extra_reward > 0 and bShow)
			elseif self.m_ChapterType == define.ChapterFuBen.Type.Difficult then
				v.m_PartnerBox:SetActive(v.m_Data.partnerclip > 0 and bShow)
			end
			v.m_LevelLabel:SetActive(bShow)
			v.m_StarGrid:SetActive(bShow)
		else
			v:SetActive(bShow)
		end
	end
end

function CChapterBox.SetForceLevel(self, level)
	self.m_ForceLevel = level
end

function CChapterBox.ForceLevel(self)
	self.m_ForceMaskSpr:SetActive(true)
	local function delay(obj)
		local oBox = obj.m_LevelBoxDic[obj.m_ForceLevel]
		if oBox then
			obj:OnLevel(oBox)
		end
		obj.m_ForceLevel = nil
		obj.m_ForceMaskSpr:SetActive(false)
	end
	Utils.AddTimer(objcall(self, delay), 1, 1)
end

function CChapterBox.SetGuideLevel(self, level)
	self.m_GuideLevel = level
end

function CChapterBox.GuideLevel(self, level)
	local oBox = self.m_LevelBoxDic[self.m_GuideLevel]
	if oBox then
		oBox.m_AvterTexture:AddEffect("Finger4", nil, Vector3.New(0, 125, 0))
		local scale = oBox:GetLocalScale()
		local oEff = oBox.m_AvterTexture.m_Effects["Finger4"]
		if oEff then
			oEff:SetLocalScale(Vector3.New(1/scale.x, 1/scale.y, 1/scale.z))
		end
	end
end

function CChapterBox.DelGuideLevel(self)
	if self.m_GuideLevel then
		local oBox = self.m_LevelBoxDic[self.m_GuideLevel]
		if oBox then
			oBox.m_AvterTexture:DelEffect("Finger4")
		end
		self.m_GuideLevel = nil
	end
end

function CChapterBox.OnLock(self, oBox)
	local dData = oBox.m_Data
	local dLevelInfo = g_ChapterFuBenCtrl:GetChapterLevelInfo(dData.type, dData.chapterid, dData.level)
	local dConfig = DataTools.GetChapterConfig(dData.type, dData.chapterid, dData.level)
	g_ChapterFuBenCtrl:CheckLevelCondition(dData.type, dData.chapterid, dData.level)
end

--~table.print(g_ChapterFuBenCtrl:GetChapterExtraReward(1,5).reward_status)
function CChapterBox.RefreshChapterInfo(self)
	--收到服务器协议再刷新
	if self.m_GuideLevel then
		self:GuideLevel()
	end
	if self.m_ForceLevel then
		self:ShowLevelBox()
		self:ForceLevel()
	else
		self:ShowLevelBox(true)
	end
	local dLevelInfos = g_ChapterFuBenCtrl:GetChapterLevelInfos(self.m_ChapterType, self.m_ChapterID)
	if not dLevelInfos then
		for i,oBox in pairs(self.m_LevelBoxDic) do
			oBox.m_LockSpr:SetActive(true)
			oBox.m_AvterTexture:SetColor(Color.New(70/255, 70/255, 70/255, 255/255))
			oBox.m_AvterTexture:LoadPath(string.format("Texture/ChapterFuBen/%s.png", oBox.m_Data.yuanicon), function () end)
		end
		return
	end
	table.print(dLevelInfos,"-刷新章节信息")
	for i,oBox in pairs(self.m_LevelBoxDic) do
		local dLevel = oBox.m_Data
		local dInfo = dLevelInfos[oBox.m_Data.level]
		if dInfo then
			local bOpen = g_ChapterFuBenCtrl:CheckChapterLevelOpen(oBox.m_Data.type, oBox.m_Data.chapterid, oBox.m_Data.level)
			oBox.m_LockSpr:SetActive(not bOpen)
			local color = Color.white
			if bOpen then
				for i=1,dInfo.star do
					local oStar = oBox.m_StarGrid:GetChild(i)
					oStar:SetSpriteName("pic_chapter_star_putong")
				end
				local dExtraReward = g_ChapterFuBenCtrl:GetChapterExtraReward(oBox.m_Data.type, oBox.m_Data.chapterid, oBox.m_Data.level)
				--table.print(dExtraReward, "-关卡奖励信息")
				oBox.m_RewardStatus = dInfo.star == 3 and dExtraReward.reward_status ~= 1
				if dInfo.pass == 1 then
					--printc(dInfo.star, dExtraReward.reward_status, not dExtraReward.reward_status ~= 1, dInfo.star == 3 and not dExtraReward.reward_status ~= 1)
					if oBox.m_RewardStatus then
						oBox.m_RedDotSpr:SetActive(true)
						oBox.m_TweenRotation.enabled = true
					elseif dExtraReward.reward_status == 1 then
						oBox.m_RewardSpr:SetSpriteName(oBox.m_SpriteStr1)
						oBox.m_RedDotSpr:SetActive(false)
						oBox.m_TweenRotation.enabled = false
						oBox:SetLocalRotation(Quaternion.Euler(0, 0, 0))
					end
				end
			else
				color = Color.New(70/255, 70/255, 70/255, 255/255)
			end
			oBox.m_AvterTexture:SetColor(color)
 			oBox.m_AvterTexture:LoadPath(string.format("Texture/ChapterFuBen/%s.png", dLevel.yuanicon), function () end)
		else
			oBox.m_LockSpr:SetActive(true)
			oBox.m_AvterTexture:SetColor(Color.New(70/255, 70/255, 70/255, 255/255))
			oBox.m_AvterTexture:LoadPath(string.format("Texture/ChapterFuBen/%s.png", dLevel.yuanicon), function () end)
		end
	end
end

function CChapterBox.SetEmoji(self, type, oBox)
	local spriteName = "pic_emoji_wuyu_1"
	if type == "dian" then
		spriteName = "pic_emoji_dian"
	elseif type == "kaixin" then
		spriteName = "pic_emoji_kaixin"
	elseif type == "mengbi" then
		spriteName = "pic_emoji_mengbi"
	elseif type == "mihu" then
		spriteName = "pic_emoji_mihu"
	elseif type == "shengqi" then
		spriteName = "pic_emoji_shengqi"
	elseif type == "weiqu" then
		spriteName = "pic_emoji_weiqu"
	elseif type == "wuyu1" then
		spriteName = "pic_emoji_wuyu_1"
	elseif type == "wuyu2" then
		spriteName = "pic_emoji_wuyu_2"
	elseif type == "wuyu3" then
		spriteName = "pic_emoji_wuyu_3"
	elseif type == "zhenjing" then
		spriteName = "pic_emoji_zhenjing"
	end
	oBox.m_SocialEmojiBG:SetActive(true)
	oBox.m_SocialEmoji:SetSpriteName(spriteName)
	oBox.m_SocialEmoji:MakePixelPerfect()
end

function CChapterBox.SetDuiHua(self, content, oBox)
	oBox.m_DuiHuaLabel:SetActive(true)
	oBox.m_DuiHuaLabel:SetText(content)
end

function CChapterBox.SetDialogue(self, bReset)
	self.m_CurDialogueID = nil
	local delay
	if bReset then
		delay = tonumber(data.globaldata.GLOBAL.chapter_dialogue_delay.value)
	else
		delay = tonumber(data.globaldata.GLOBAL.chapter_dialogue_intervel.value)
	end
	local function dialogue()
		if Utils.IsNil(self) then
			return
		end
		local dChapter = DataTools.GetChapterInfo(self.m_ChapterType, self.m_ChapterID)
		if dChapter and #dChapter.dialogue > 0 then
			local tmp = table.copy(dChapter.dialogue)
			if self.m_CurDialogueID then
				local idx = table.index(tmp, self.m_CurDialogueID)
				table.remove(tmp, idx)
			end
			self.m_CurDialogueID = table.randomvalue(dChapter.dialogue)
		end
		if self.m_CurDialogueID then
			local lDialogue = data.chapterfubendata.Dialogue[self.m_CurDialogueID]
			self:OpenDialogue(lDialogue)
		end
	end
	self.m_DialogueTimer = Utils.AddTimer(dialogue, 0.1, delay)
end

function CChapterBox.StopDialogue(self)
	if self.m_DialogueTimer then
		Utils.DelTimer(self.m_DialogueTimer)
		self.m_DialogueTimer = nil
	end
	for i,oBox in pairs(self.m_LevelBoxDic) do
		self:StopBoxDialogue(oBox)
	end
	self:StopBoxDialogue(self.m_HeroBox)
end

function CChapterBox.StopBoxDialogue(self, oBox)
	if oBox.m_Timer then
		Utils.DelTimer(oBox.m_Timer)
		oBox.m_Timer = nil
	end
	oBox.m_DuiHuaLabel:SetActive(false)
	oBox.m_SocialEmojiBG:SetActive(false)
end

function CChapterBox.OpenDialogue(self, lDialogue)
	self:StopDialogue()
	local time = 0
	local lDialogue = table.copy(lDialogue) or {}
	local dOne = table.remove(lDialogue, 1)
	local function dialogue()
		if Utils.IsNil(self) then
			return
		end
		if dOne and time >= dOne.start_time then
			self:ShowOneDialogue(dOne)
			dOne = table.remove(lDialogue, 1)
		end
		if not dOne then
			self:SetDialogue()
			return false
		end
		time = time + 0.1
		return true
	end
	self.m_DialogueTimer = Utils.AddTimer(dialogue, 0.1, 0.1)
end

function CChapterBox.ShowOneDialogue(self, d)
	local oBox = self.m_LevelBoxDic[d.level]
	if oBox then
		self:StopBoxDialogue(oBox)
		if d.content and d.content ~= "" then
			self:SetDuiHua(d.content, oBox)
		elseif d.emoji and d.emoji ~= "" then
			self:SetEmoji(d.emoji, oBox)
		end
		local function done()
			if Utils.IsNil(oBox) or Utils.IsNil(self) then
				return
			end
			if oBox then
				oBox.m_DuiHuaLabel:SetActive(false)
				oBox.m_SocialEmojiBG:SetActive(false)
			end
		end
		oBox.m_Timer = Utils.AddTimer(done, d.end_time, d.end_time)
	end
end

function CChapterBox.CheckTaskDialogue(self, oBox)
	self.m_CurTaskDialogueID = nil
	self:StopTaskDialogue()
	if oBox and oBox.m_Data then
		--[[
		self.m_CurTaskDialogueID = oBox.m_Data.task_dialogue
		local iStory = g_TaskCtrl:GetLastStoryTaskId()
		local lDialogue
		if iStory > 0 and self.m_CurTaskDialogueID == iStory then
			lDialogue = data.chapterfubendata.TaskDialogue[self.m_CurTaskDialogueID]
		elseif self.m_CurTaskDialogueID == 0 then
			lDialogue = table.randomvalue(data.chapterfubendata.TaskDialogue)
		end
		if lDialogue then
			self:OpenTaskDialogue(lDialogue)
		end
		]]
		self.m_CurTaskDialogueID = oBox.m_Data.task_dialogue
		local lDialogue = data.chapterfubendata.TaskDialogue[self.m_CurTaskDialogueID]
		self:OpenTaskDialogue(lDialogue)
	end
end

function CChapterBox.StopTaskDialogue(self)
	if self.m_TaskDialogueTimer then
		Utils.DelTimer(self.m_TaskDialogueTimer)
		self.m_TaskDialogueTimer = nil
	end
	for i,oBox in pairs(self.m_LevelBoxDic) do
		self:StopBoxDialogue(oBox)
	end
	self:StopBoxDialogue(self.m_HeroBox)
end

function CChapterBox.OpenTaskDialogue(self, lDialogue)
	if lDialogue then
		local time = 0
		local lDialogue = table.copy(lDialogue)
		local dOne = table.remove(lDialogue, 1)
		local function dialogue()
			if Utils.IsNil(self) then
				return
			end
			if dOne and time >= dOne.start_time then
				self:ShowOneTaskDialogue(dOne)
				dOne = table.remove(lDialogue, 1)
			end
			time = time + 0.1
			return true
		end
		self.m_TaskDialogueTimer = Utils.AddTimer(dialogue, 0.1, 0.1)
	end
end

function CChapterBox.ShowOneTaskDialogue(self, d)
	local oBox
	if d.speeker == 1 then
		oBox = self.m_HeroBox
	elseif d.speeker == 0 then
		oBox = self.m_LevelBoxDic[self.m_LevelID]
	end
	if oBox then
		self:StopBoxDialogue(oBox)
		if d.content and d.content ~= "" then
			self:SetDuiHua(d.content, oBox)
		elseif d.emoji and d.emoji ~= "" then
			self:SetEmoji(d.emoji, oBox)
		end
		local function done()
			if Utils.IsNil(oBox) or Utils.IsNil(self) then
				return
			end
			if oBox then
				oBox.m_DuiHuaLabel:SetActive(false)
				oBox.m_SocialEmojiBG:SetActive(false)
			end
		end
		oBox.m_Timer = Utils.AddTimer(done, d.end_time, d.end_time)
	end
end

return CChapterBox