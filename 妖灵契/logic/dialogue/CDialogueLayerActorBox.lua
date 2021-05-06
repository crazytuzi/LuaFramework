local CDialogueLayerActorBox = class("CDialogueLayerActorBox", CBox)

function CDialogueLayerActorBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_TweenAlpha = self:GetComponent(classtype.TweenAlpha)
	self.m_TweenRotation = self:GetComponent(classtype.TweenRotation)
	self.m_AvterTexture = self:NewUI(2, CTexture)
	self.m_AvterTexture.m_TweenPos = self.m_AvterTexture:GetComponent(classtype.TweenPosition)
 	self.m_DuiHuaLabel = self:NewUI(3, CLabel)
 	self.m_SocialEmoji = self:NewUI(4, CSprite)
 	self.m_AvterWidget = self:NewUI(5, CWidget)
 	self.m_SocialEmojiBG = self:NewUI(6, CSprite)
 	self.m_YingZiSpr = self:NewUI(7, CSprite)
 	self.m_ZhenjingAvterTexture = self:NewUI(8, CTexture)
 	self.m_DuiHuaBgSpr = self:NewUI(9, CSprite)

 	self.m_BaseData = {}
 	self.m_CurAction = nil

 	--寻路
 	self.m_Path = {}
 	self.m_PathIdx = 1
 	self.m_LastWalkLayerPos = nil
 	self.m_WalkTimer = nil

 	--击飞
 	self.m_FlyRotation = 0 	

 	self.m_ActionTimer = nil
 	self.m_SayTimer = nil
 	self.m_EmojiTimer = nil

 	self.m_FaceRight = nil

 	self.m_NormarScale = Vector3.New(1, 1, 1)
 	self.m_Offset = Vector3.New(0, 0, 0)

 	self.m_PS = g_DialogueAniCtrl:GetAniPlaySpeed()--播放速度

 	self:InitContent()
end

function CDialogueLayerActorBox.InitContent(self)
 	self.m_DuiHuaLabel:SetActive(false)
 	self.m_SocialEmojiBG:SetActive(false)
end

function CDialogueLayerActorBox.SetBaseData(self, d)
	self.m_BaseData = d
end

function CDialogueLayerActorBox.WalkTo(self, x, y)
	local oPos = self:GetLocalPos()
	local oCell = g_DialogueAniCtrl:GetCellNaviPos(oPos)
	local tCell = g_DialogueAniCtrl:GetCellNaviPos({x=x, y=y})
	local path = g_DialogueAniCtrl:FindMapPath(oCell, tCell, 3012)
	-- printc(">>>>>>>>>开始寻路 ",x ,y, oCell, tCell)
	-- table.print(oCell)
	-- table.print(tCell)
	-- table.print(path)
 	self.m_Path = {}
 	self.m_PathIdx = 1	
 	self.m_LastWalkLayerPos = nil
 	self:StopWalkTimer()
	if not next(path) then
		return
	end
	self.m_Path = path
	self.m_WalkerTimer = Utils.AddTimer(callback(self, "CheckWalke"), 0.1, 0)
end

function CDialogueLayerActorBox.CheckWalke(self)
	if self.m_PathIdx > #self.m_Path then
		self:CrossFade("idle")
		return false
	end
 	local speed = 1
 	if self.m_PS ~= 1 then
		speed = 2
 	end

	local curNaviPos = self.m_Path[self.m_PathIdx]
	local curLayerPos = g_DialogueAniCtrl:GetCellLayerPos(curNaviPos.x, curNaviPos.y)
	if self.m_LastWalkLayerPos and curLayerPos.x ~= self.m_LastWalkLayerPos.x then
		self:SetFaceRight(curLayerPos.x > self.m_LastWalkLayerPos.x)
	end
	self:SetLocalPos(Vector3.New(curLayerPos.x, curLayerPos.y, 0))
	self.m_PathIdx = self.m_PathIdx + speed
	self.m_LastWalkLayerPos = curLayerPos
	self:CrossFade("walk")
	return true
end

function CDialogueLayerActorBox.SetFaceRight(self, b)
	self.m_FaceRight = b
	local s = self.m_NormarScale 
	if b then
		self.m_AvterTexture:SetLocalScale(Vector3.New(s.x, s.y, s.z))
	else
		self.m_AvterTexture:SetLocalScale(Vector3.New(-s.x, s.y, s.z))
	end
end

function CDialogueLayerActorBox.SetResRight(self, b)
	if not b then
		self.m_AvterTexture:SetFlip(enum.UIBasicSprite.Horizontally)
	end
end

--飞出 开始
function CDialogueLayerActorBox.DoFlyOut(self, config)
	local isLeft = true
	local sideMsg = nil
	if config and config ~= "none" then
		local list = string.split(config, ",")
		if list[1] then
			local side = tostring(list[1])
			if side == "right" or side == "you" then
				isLeft = false
			end
		end	
		if list[2] then
			sideMsg = tostring(list[2])
		end		
	end
	local w = self.m_BaseData.width
	local h = self.m_BaseData.height
	local tPos = {}
	if isLeft then
		tPos = {x = -w/2, y = h /2, 0, z = 0}
	else
		tPos = {x = w/2, y = h/2, z = 0}
	end
	self.m_YingZiSpr:SetActive(false)
	self.m_FlyOutMoveAction = CActionVector.New(self, 1 / self.m_PS, "SetLocalPos", self:GetLocalPos(), tPos)
	g_ActionCtrl:AddAction(self.m_FlyOutMoveAction)
	self:SetAlphaDuration(1, 0, 1 / self.m_PS)
	self.m_FlyOutMoveAction:SetEndCallback(callback(self, "FlyOutEnd", isLeft, sideMsg))
	self.m_ActionTimer = Utils.AddTimer(callback(self, "CheckFlyOut"), 0, 0)
end

function CDialogueLayerActorBox.CheckFlyOut(self, dt)
	local rotationSpeed = -1800	
	self.m_FlyRotation = self.m_FlyRotation + rotationSpeed * dt * self.m_PS
	self.m_AvterTexture:SetLocalRotation(Quaternion.Euler(0, 0, self.m_FlyRotation))	
	return true
end

function CDialogueLayerActorBox.FlyOutEnd(self, isLeft, msg)
	self:StopActionTimer()
	self.m_AvterTexture:SetLocalRotation(Quaternion.Euler(0, 0, 0))	
	self.m_YingZiSpr:SetActive(true)
	self.m_AvterTexture:SetAlpha(1)
	if msg and msg ~= "" then
		local oView = CDialogueLayerAniView:GetView()
		if oView then
			oView:ShowSideSay(msg, isLeft)
		end
	end
end
--飞出 结束

function CDialogueLayerActorBox.CrossFade(self, action, config)	
	if action == self.m_CurAction then
		return
	end
	config = config or {}
	self:QuitLastActjion()
	if action == "walk" then
		self.m_AvterTexture.m_TweenPos.enabled = true

	elseif action == "idle" then

	elseif action == "flyout" then
		self:DoFlyOut(config)
		
	elseif action == "zhenjing" then
		self:DoZhenjingAction()

	elseif action == "pengzhuang" then
		self:DoPengZhuangAction()

	elseif action == "houtui" then
		self:DoHouTuiAction(config)

	elseif action == "tiaodong" then
		self:DoTiaoDongAction(config)

	elseif action == "xuanzhuan" then
		self:DoXuanZhuanAction(config)		

	elseif action == "yasuo" then
		self:DoYaSuoAction()

	end
	self.m_CurAction = action
end

function CDialogueLayerActorBox.QuitLastActjion(self)
	if self.m_CurAction == "walk" then
		self:StopWalkTimer()	
		self.m_AvterTexture.m_TweenPos.enabled = false
		self.m_AvterTexture.m_TweenPos:ResetToBeginning()
		self.m_AvterTexture:SetLocalPos(Vector3.New(0, 128 + self.m_Offset.y, 0))
	elseif self.m_CurAction == "flyout" then
		self:StopActionTimer()
		self.m_AvterTexture:SetLocalRotation(Quaternion.Euler(0, 0, 0))	
		self.m_YingZiSpr:SetActive(true)

	elseif self.m_CurAction == "zhenjing" then
		self:StopZhenjingAction()
		self:StopActionTimer()		
		self.m_ZhenjingAvterTexture:SetActive(false)
		self.m_ZhenjingAvterTexture:SetFillAmount(0)
	elseif self.m_CurAction == "pengzhuang" then
		if self.m_PengZhuangAction then
			self.m_PengZhuangAction:StopActions()	
			self.m_PengZhuangAction = nil
		end
		self.m_AvterWidget:SetLocalPos(Vector3.New(0, 0, 0))

	elseif self.m_CurAction == "houtui" then
		self:StopHouTuiAction()

	elseif self.m_CurAction == "tiaodong" then
		self:StopTiaoDongAction()
		self.m_AvterTexture:SetLocalPos(Vector3.New(0, 0, 0))
	elseif self.m_CurAction == "xuanzhuan" then
		self:StopXuanZhuanAction()
		self:SetXuanZhuanLocalRotationY(0)
	elseif self.m_CurAction == "yasuo" then
		self.m_AvterTexture:SetPivot(enum.UIWidget.Pivot.Center)
		self:StopYaSuoAction()
		self.m_AvterTexture:SetLocalScale(self.m_NormarScale)

	end
end

function CDialogueLayerActorBox.StopActionTimer(self)
	if self.m_ActionTimer then
		Utils.DelTimer(self.m_ActionTimer)
		self.m_ActionTimer = nil
	end
end

function CDialogueLayerActorBox.StopWalkTimer(self)
	if self.m_WalkTimer then
		Utils.DelTimer(self.m_WalkTimer)
		self.m_WalkerTimer = nil
	end
end

function CDialogueLayerActorBox.SetAlphaDuration(self, ba, ea, time)
	if self.m_AlphaAction then
		g_ActionCtrl:DelAction(self.m_AlphaAction)
		elf.m_AlphaAction = nil
	end	
	self.m_AvterTexture:SetAlpha(ba)
	self.m_AlphaAction = CActionFloat.New(self.m_AvterTexture, time, "SetAlpha", ba, ea)
	g_ActionCtrl:AddAction(self.m_AlphaAction)
end

function CDialogueLayerActorBox.SayMsg(self, msg, time)
	if not msg or msg == "" then
		return
	end
	time = time or 2
	self:StopSayTimer()
	self.m_DuiHuaLabel:SetText(msg)
	local _w = self.m_DuiHuaLabel:GetWidth()
	if _w > 180 then
		self.m_DuiHuaLabel:SetOverflow(enum.UILabel.Overflow.ResizeHeight)
		self.m_DuiHuaLabel:SetWidth(180)
	end
	self.m_DuiHuaLabel:SetActive(true)
	self.m_SayTimer = Utils.AddTimer(callback(self, "SayMsgEnd"), 0, time / self.m_PS)
	Utils.AddTimer(callback(self, "DelaySetDuiHuaBg"), 0, 0)
end

function CDialogueLayerActorBox.StopSayTimer(self)
	if self.m_SayTimer then
		Utils.DelTimer(self.m_SayTimer)
		self.m_SayTimer = nil
	end
end

function CDialogueLayerActorBox.DelaySetDuiHuaBg(self)
	if not Utils.IsNil(self) then
		local w, h = self.m_DuiHuaLabel:GetSize() 
		self.m_DuiHuaBgSpr:SetSize(w + 24, h + 20)
	end
end

function CDialogueLayerActorBox.SayMsgEnd(self)
	if not Utils.IsNil(self) then
		self.m_DuiHuaLabel:SetText("")
		self.m_DuiHuaLabel:SetOverflow(enum.UILabel.Overflow.ResizeFreely)
		self.m_DuiHuaBgSpr:SetSize(20, 20)
		self.m_DuiHuaLabel:SetActive(false)
	end	
end

function CDialogueLayerActorBox.SetSocialEmoji(self, emoji, visible)
	if self.m_EmojiTimer then
		Utils.DelTimer(self.m_EmojiTimer)
		self.m_EmojiTimer = nil
	end
	if visible then
		self.m_SocialEmojiBG:SetActive(true)
		self.m_SocialEmoji:SetSpriteName(g_DialogueAniCtrl:GetEmojiSprName(emoji))
		self.m_SocialEmoji:MakePixelPerfect()
		self.m_EmojiTimer = Utils.AddTimer(callback(self, "SetSocialEmojiEnd"), 0, 2 / self.m_PS)		
		self.m_CurEmoji = emoji
	else
		self.m_CurEmoji = nil
		self.m_SocialEmojiBG:SetActive(false)
	end
end

function CDialogueLayerActorBox.SetSocialEmojiEnd(self)
	self.m_SocialEmojiBG:SetActive(false)
	self.m_CurEmoji = nil
end

function CDialogueLayerActorBox.Destroy(self)
	if self.m_AlphaAction then
		g_ActionCtrl:DelAction(self.m_AlphaAction)
	end
	if self.m_FlyOutMoveAction then
		g_ActionCtrl:DelAction(self.m_FlyOutMoveAction)
	end
	if self.m_PengZhuangAction then
		self.m_PengZhuangAction:StopActions()	
		self.m_PengZhuangAction = nil
	end	
	self:StopSayTimer()
	self:StopYaSuoAction()
	self:StopXuanZhuanAction()
	self:StopTiaoDongAction()
	self:StopSetNpcActiveAction()
	self:StopHouTuiAction()
	self:StopZhenjingAction()
	self:StopActionTimer()
	self:StopWalkTimer()
	CObject.Destroy(self)
end

function CDialogueLayerActorBox.ChangeShape(self, iShape)
	if not iShape then
		iShape = 130
	end
	self.m_AvterTexture:LoadPath(string.format("Texture/ChapterFuBen/yuan_%d.png", iShape), function () end)
	self.m_ZhenjingAvterTexture:LoadPath(string.format("Texture/ChapterFuBen/yuan_%d.png", iShape), function () end)
end

function CDialogueLayerActorBox.AddEffectMode(self, mode)
	if mode == "rotation" then
		self.m_TweenAlpha.enabled = true
		self.m_TweenRotation.enabled = true

	elseif mode == "fadein" then
		self.m_TweenAlpha.enabled = true

	elseif mode == "none" then

	end
end

--震惊开始
function CDialogueLayerActorBox.DoZhenjingAction(self)
	self:StopZhenjingAction()
	self:StopActionTimer()
	self.m_ZhenjingActjion1 = CActionVector.New(self.m_AvterTexture, 0.2 / self.m_PS, "SetLocalPos", Vector3.New(0, 128 + self.m_Offset.y, 0), Vector3.New(0, 158 + self.m_Offset.y, 0))
	self.m_ZhenjingActjion1:SetEndCallback(callback(self, "ZhenjingActionStepTwo"))
	g_ActionCtrl:AddAction(self.m_ZhenjingActjion1)
	self.m_ZhenjingAvterTexture:SetActive(true)
	self.m_ZhenjingAvterTexture:SetFillAmount(0)
end

function CDialogueLayerActorBox.ZhenjingActionStepTwo(self)
	self.m_ZhenjingActjion2 = CActionVector.New(self.m_AvterTexture, 0.2 / self.m_PS, "SetLocalPos", Vector3.New(0, 158 + self.m_Offset.y , 0), Vector3.New(0, 128 + self.m_Offset.y, 0))
	self.m_ZhenjingActjion2:SetEndCallback(callback(self, "ZhenjingActionStepThree"))
	g_ActionCtrl:AddAction(self.m_ZhenjingActjion2)
end

function CDialogueLayerActorBox.ZhenjingActionStepThree(self)
	self.m_ZhenjingActjion3 = CActionFloat.New(self.m_ZhenjingAvterTexture, 1 / self.m_PS, "SetFillAmount", 0, 1)
	g_ActionCtrl:AddAction(self.m_ZhenjingActjion3)	
	self.m_ActionTimer = Utils.AddTimer(callback(self, "ZhenjingActionStepFour"), 0 ,2 / self.m_PS)
end

function CDialogueLayerActorBox.ZhenjingActionStepFour(self)
	self.m_ZhenjingAvterTexture:SetActive(false)
	self.m_ZhenjingAvterTexture:SetFillAmount(0)
end

function CDialogueLayerActorBox.StopZhenjingAction(self)
	if self.m_ZhenjingActjion1 then
		g_ActionCtrl:DelAction(self.m_ZhenjingActjion1)
	end
	if self.m_ZhenjingActjion2 then
		g_ActionCtrl:DelAction(self.m_ZhenjingActjion2)
	end
	if self.m_ZhenjingActjion3 then
		g_ActionCtrl:DelAction(self.m_ZhenjingActjion3)
	end
	self.m_ZhenjingActjion1 = nil
	self.m_ZhenjingActjion2 = nil
	self.m_ZhenjingActjion3 = nil
end
--震惊结束

function CDialogueLayerActorBox.SetNpcActive(self, visible, isfade)
	if isfade == false then
		self:SetAlpha(1)
		self:SetActive(visible)
	else
		self:SetActive(true)
		if visible then			
			self:SetAlpha(0)
			self.m_SetNpcActiveAction = CActionFloat.New(self, 1 / self.m_PS, "SetAlpha", 0, 1)
			g_ActionCtrl:AddAction(self.m_SetNpcActiveAction)	
		else		
			self:SetAlpha(1)
			self.m_SetNpcActiveAction = CActionFloat.New(self, 1 / self.m_PS, "SetAlpha", 1, 0)
			g_ActionCtrl:AddAction(self.m_SetNpcActiveAction)	
		end
	end
end

function CDialogueLayerActorBox.StopSetNpcActiveAction(self)
	if self.m_SetNpcActiveAction then
		g_ActionCtrl:DelAction(self.m_SetNpcActiveAction)
		self.m_SetNpcActiveAction = nil
	end
end

--碰撞 开始
function CDialogueLayerActorBox.DoPengZhuangAction(self)
	self.m_AvterWidget:SetLocalPos(Vector3.New(0, 0 ,0))
	local oPos, tPos 
	if self.m_FaceRight then
		oPos = Vector3.New(0, 0, 0)
		tPos = Vector3.New(40, 0, 0)
	else
		oPos = Vector3.New(0, 0, 0)
		tPos = Vector3.New(-40, 0, 0)
	end
	local list = {}
	list[1] = CActionVector.New(self.m_AvterWidget, 0.1 / self.m_PS, "SetLocalPos", oPos, tPos)
	list[2] = CActionVector.New(self.m_AvterWidget, 0.1 / self.m_PS, "SetLocalPos", tPos, oPos)
	self.m_PengZhuangAction = CSequenceAction.New(list)
	self.m_PengZhuangAction:StartActions()	
end
--碰撞 结束

-- 后退 开始
function CDialogueLayerActorBox.DoHouTuiAction(self, config)
	local oPos = self:GetLocalPos()
	local tPos
	local distance = 50
	local time = 0.1
	if config and config ~= "none" then
		local list = string.split(config, ",")
		if list[1] then
			distance = tonumber(list[1])
		end
		if list[2] then
			time = tonumber(list[2])
		end
	end
	if self.m_FaceRight then
		tPos = Vector3.New(oPos.x - distance, oPos.y, 0)
	else		
		tPos = Vector3.New(oPos.x + distance, oPos.y, 0)
	end
	self.m_HouTuiActjion = CActionVector.New(self, time / self.m_PS, "SetLocalPos", oPos, tPos)
	g_ActionCtrl:AddAction(self.m_HouTuiActjion)
end

function CDialogueLayerActorBox.StopHouTuiAction(self)
	if self.m_HouTuiActjion then
		g_ActionCtrl:DelAction(self.m_HouTuiActjion)
		self.m_HouTuiActjion = nil
	end
end
--后退 结束

--跳动 开始
function CDialogueLayerActorBox.DoTiaoDongAction(self, config)	
	local high = 50
	local cnt = 2
	if config and config ~= "none" then
		local list = string.split(config, ",")
		if list[1] then
			high = tonumber(list[1])
		end
		if list[2] then
			cnt = tonumber(list[2])
		end
	end
	local oPos = self.m_AvterTexture:GetLocalPos()
	local tPos = Vector3.New(oPos.x, oPos.y + high, 0)	
	local actionList = {}
	local idx = 1
	for i = 1, cnt do  
		actionList[idx] = CActionVector.New(self.m_AvterTexture , 0.1 / self.m_PS, "SetLocalPos", oPos, tPos)
		idx = idx + 1
		actionList[idx] = CActionVector.New(self.m_AvterTexture, 0.1 / self.m_PS, "SetLocalPos", tPos, oPos)
		idx = idx + 1		
	end
	self.m_TiaoDongAction = CSequenceAction.New(actionList)
	self.m_TiaoDongAction:StartActions()	
end

function CDialogueLayerActorBox.StopTiaoDongAction(self)
	if self.m_TiaoDongAction then
		self.m_TiaoDongAction:StopActions()
		self.m_TiaoDongAction = nil
	end
end
--跳动 结束

--旋转 开始
function CDialogueLayerActorBox.DoXuanZhuanAction(self, config)
	local cnt = 2
	local isRight = true
	local time = 0.3
	local rotaion = 720
	if config and config ~= "none" then
		local list = string.split(config, ",")
		if list[1] then
			cnt = tonumber(list[1])
		end
		if list[2] then
			isRight = tostring(list[2])
			if isRight == "ni" then
				rotaion = -cnt * 360
			else
				rotaion = cnt * 360
			end
		end
		if list[3] then
			time = tonumber(list[3])
		end
	end
	self.m_XuanZhuanAction = CActionFloat.New(self, time / self.m_PS, "SetXuanZhuanLocalRotationY", 0, rotaion)
	g_ActionCtrl:AddAction(self.m_XuanZhuanAction)
end

function CDialogueLayerActorBox.SetXuanZhuanLocalRotationY(self, rotationY)
	self:SetLocalRotation(Quaternion.Euler(0, rotationY, 0))
end

function CDialogueLayerActorBox.StopXuanZhuanAction(self)
	if self.m_XuanZhuanAction then
		g_ActionCtrl:DelAction(self.m_XuanZhuanAction)
		self.m_XuanZhuanAction = nil
	end
end
--旋转 结束

--压缩 开始
function CDialogueLayerActorBox.DoYaSuoAction(self)
	local s = self.m_NormarScale
	local oScale = Vector3.New(s.x, s.y, s.z)
	local tScale = Vector3.New(s.x, s.y * 0.5, s.z)
	local actionList = {}
	self.m_AvterTexture:SetPivot(enum.UIWidget.Pivot.Bottom)
	actionList[1] = CActionVector.New(self.m_AvterTexture , 0.1 / self.m_PS, "SetLocalScale", oScale, tScale)
	actionList[2] = CActionVector.New(self.m_AvterTexture, 0.1 / self.m_PS, "SetLocalScale", tScale, oScale)
	actionList[3] = CActionVector.New(self.m_AvterTexture , 0.1 / self.m_PS, "SetLocalScale", oScale, tScale)
	actionList[4] = CActionVector.New(self.m_AvterTexture, 0.1 / self.m_PS, "SetLocalScale", tScale, oScale)	
	self.m_YaSuoAction = CSequenceAction.New(actionList)
	self.m_YaSuoAction:StartActions()		
end

function CDialogueLayerActorBox.StopYaSuoAction(self)
	if self.m_YaSuoAction then
		self.m_YaSuoAction:StopActions()
		self.m_YaSuoAction = nil
	end
end
--压缩 结束

function CDialogueLayerActorBox.SetNpcDepth(self, dp)
	dp = dp or 10
	local depth = 40 + dp
	self.m_AvterTexture:SetDepth(depth)
	self.m_ZhenjingAvterTexture:SetDepth(depth + 1)
end

function CDialogueLayerActorBox.SetNpcNormalScaleAndYOffset(self, scale, yoffset, isInit)
	if yoffset ~= 0 or scale ~= 1 then
		self.m_NormarScale = Vector3.New(scale, scale, scale)
		self.m_Offset = Vector3.New(0, yoffset, 0)
		if isInit then
			self.m_AvterTexture:SetLocalScale(self.m_NormarScale)
			self.m_ZhenjingAvterTexture:SetLocalScale(self.m_NormarScale)
			local pos = self.m_AvterTexture:GetLocalPos()
			self.m_AvterTexture:SetLocalPos(Vector3.New(pos.x, pos.y + yoffset, pos.z))
			self.m_ZhenjingAvterTexture:SetLocalPos(Vector3.New(pos.x, pos.y + yoffset, pos.z))
		end
	end
end

function CDialogueLayerActorBox.SetPlaySpeed(self, speed)
	self.m_PS = speed
end

return CDialogueLayerActorBox