local CDialogueAniUnit = class("CDialogueAniUnit")

function CDialogueAniUnit.ctor(self, id, idx, triggerNpc)
	self.m_Id = id
	self.m_Idx = idx
	self.m_CmdList = {}
	self.m_CurCmdIdx = 1
	self.m_NpcList = {}
	self.m_EffectList = {}
	self.m_SettingList = {}
	self.m_ElapseTime = 0 --已执行时间
	self.m_EndTime = 0
	self.m_Running = false
	self.m_TriggerNpc = triggerNpc
	self.m_EndPlayStoryTaskId = nil --结束剧本时，触发开篇动画Id
	self.m_EndTriggerGuiedKey = nil  --结束剧本时，触发引导
	self.m_EndPlayDialogueAniId = nil --结束剧本时，触发另外一段剧本
	self.endCloseDialogueAniView = true  --结束剧本是否关闭，剧情界面
	self.m_EndPlayDialogueFlag = nil --结束剧本时，记住播放记录
	self.m_Config = {}
	self.m_IsClear = false
	self.m_EffectRootBg = nil
	self.m_EffectRootFg = nil
	self.m_EffectRoot = nil	
	self.m_CurCamIdx = nil
	self.m_TarCamIdx = nil
	self.m_CamTarget = nil
	self.m_CamMoveTimer = nil
	self.m_NeedLayer = false
	self.m_Layer = UnityEngine.LayerMask.NameToLayer("Defalut")
	self.m_LayerMask = UnityEngine.LayerMask.GetMask("Defalut")	
end

function CDialogueAniUnit.BuildCmds(self)
	self.m_CmdList = {}
	local d
	-- local oView = CEditorDialogueNpcAnimView:GetView()
	-- if oView then
	-- 	d = oView.m_CmdLists
	-- 	self.m_Config = oView.m_Config
	-- else
	local t = g_DialogueAniCtrl:GetFileData(self.m_Id)
	if t then
		d = t.DATA
		self.m_Config = t.CONFIG
	end
	--end
	if not d then
		printc(string.format("没有找到剧本数据 剧本id = %d", self.m_Id))
		return
	end
	for i = 1, #d do
		local queue = d[i]
		for idx = 1, #queue.cmdList do
			local oCmd = CDialogueAniCmd.New(queue.cmdList[idx].func, queue.startTime, queue.cmdList[idx].args, self)
			table.insert(self.m_CmdList, oCmd)			
		end
		self.m_EndTime = queue.startTime + queue.delay
	end
	printc(" 指令生成完毕", self.m_Id)
end

function CDialogueAniUnit.Start(self)
	self.m_Running = true
	self.m_IsClear = false
	printc(" 剧本开始")
	if self:IsTargetAniType(1) then
		nettask.C2GSEnterShow(1, 0)
		g_DialogueAniCtrl:SetCacheProto(true)	

	elseif self:IsTargetAniType(3) then
		local mapId = 3012
		if self.m_Config.mapInfo and self.m_Config.mapInfo ~= "" then
			mapId = tonumber(self.m_Config.mapInfo)
		end
		CDialogueLayerAniView:ShowView(function (oView)
			oView:SetData({mapId = mapId})
		end)
	end
	self:ProcressStartCmd()
end

function CDialogueAniUnit.End(self, isForce)
	printc(" 剧本结束", self.m_Id)
	self.m_Running = false
	self:ClearAll()
	g_DialogueAniCtrl:StopDialgueAni(self.m_Id, true, true)
	if self:IsTargetAniType(1) then
		if tonumber(self.m_Id) ~= 888 and tonumber(self.m_Id) ~= 10509 and tonumber(self.m_Id) ~= 889 then
			nettask.C2GSEnterShow(0, 1)
		else
			if tonumber(self.m_Id) ~= 888 then
				nettask.C2GSEnterShow(0, 0)
			end
		end
		g_DialogueAniCtrl:SetCacheProto(false)
	elseif self:IsTargetAniType(3) then
		local oView = CDialogueLayerAniView:GetView()
		if oView then
			oView:DelayClose()
		end
	end

	if isForce ~= true then
		if self.m_EndPlayDialogueAniId then
			if not (tonumber(self.m_EndPlayDialogueAniId) == 888 and g_GuideCtrl.m_Flags and g_GuideCtrl.m_Flags["welcome_two"] == true) then		
				g_DialogueAniCtrl:UtilsEndPlayOtherDiialoueAni(self.m_EndPlayDialogueAniId)
			end
			
		elseif self.m_EndPlayStoryTaskId then		
			g_DialogueCtrl:PlayStartStory(self.m_EndPlayStoryTaskId)
		
		elseif self.m_EndTriggerGuiedKey then
			if g_GuideCtrl.m_Flags then
				g_GuideCtrl.m_Flags[self.m_EndTriggerGuiedKey] = true
			end
			g_GuideCtrl:CtrlCC2GSFinishGuidance({[1] = self.m_EndTriggerGuiedKey})				
		end

		if self.m_EndPlayDialogueFlag and g_GuideCtrl.m_Flags then
			g_GuideCtrl.m_Flags[self.m_EndPlayDialogueFlag] = true
			g_GuideCtrl:CtrlCC2GSFinishGuidance({[1] = self.m_EndPlayDialogueFlag})				
		end
	end
end

function CDialogueAniUnit.ClearAll(self)
	if self.m_IsClear == true then
		return
	end
	if self.m_SettingList["bgMusic"] ~= nil then
		if self.m_SettingList["bgMusic"].m_MusicRate then
			g_AudioCtrl:SetMusicRate(self.m_SettingList["bgMusic"].m_MusicRate)
		end
		g_AudioCtrl:CheckMusic()
		if self.m_SettingList["bgMusic"].m_Music then
			g_MapCtrl:CheckMusic(g_MapCtrl:GetResID())
		end
		self.m_SettingList["bgMusic"] = nil
	end
	if self:IsTargetAniType(1) then
		g_AudioCtrl:StopMusic()
		g_DialogueAniCtrl:ReSetPlaySpeed()
	end
	if self.m_SettingList["DialogueAniView"] == true then
		local oView = CDialogueAniView:GetView()
		if oView then
			if self.endCloseDialogueAniView then
				oView:CloseView()
			else				
				oView:SetContent()
				oView:SetNpcSay({content="none"})
				oView:ShowLive2D(false)
			end			
		end
	end
	if self.m_SettingList["CameraFollow"] == true then
		g_DialogueAniCtrl:SetDelayCheckDialogueAniCamera()
		g_MapCtrl:CheckCamTarget()
	end

	if self.m_SettingList["CameraDistance"] then
		local dis = self.m_SettingList["CameraDistance"]
		local oCam = g_CameraCtrl:GetMainCamera()
		local iCurSize = oCam:GetOrthographicSize()
		if dis ~= iCurSize then
			g_CameraCtrl:SetMapCameraSize(dis)
		end
		self.m_SettingList["CameraDistance"] = nil
	end

	if self.m_SettingList["ShowSwitchBox"] then
		local d = self.m_SettingList["ShowSwitchBox"] 
		local path = d.path
		local time = d.time
		local fadeIn = d.fadeIn
		if path ~= "none" then
			g_NotifyCtrl:ShowAniSwitchTextureBg(path, time, fadeIn)
		else
			g_NotifyCtrl:ShowAniSwitchBlackBg(time, fadeIn)
		end
		self.m_SettingList["ShowSwitchBox"] = nil
	end

	if self.m_SettingList["ShowSwitchProcress"] then
		g_DialogueAniCtrl:SwitchEffect(self.m_SettingList["ShowSwitchProcress"])
		self.m_SettingList["ShowSwitchProcress"] = nil
	end

	if self.m_SettingList["voice"] then
		g_AudioCtrl:OnStopPlay()
		self.m_SettingList["voice"] = nil

	end

	self:ClearAllEffect()

	--printy(" >>>>>>>>>>>>>>  end  vself.m_EffectRoot ", self.m_EfftRoot, self:GetEffctRoot())
	if self.m_EfftRoot then
		--printy(" >>>>>>>>>>>>>>>>>>>>>>>>>>>> Destroy")
		self.m_EfftRoot:Destroy()
		self.m_EffectRootBg = nil
		self.m_EffectRootFg = nil
		self.m_EfftRoot = nil
	end

	if self.m_CamTarget then
		self.m_CamTarget:Destroy()
		self.m_CamTarget = nil
	end

	if self.m_CamMoveTimer then
		Utils.DelTimer(self.m_CamMoveTimer)
		self.m_CamMoveTimer = nil
	end	

	self:ClearNpcs()
	self.m_IsClear = true
end

function CDialogueAniUnit.Update(self, dt)	
	if not self:IsRunning() then
		return
	end
	if self.m_NeedLayer then
		local oView = CDialogueAniView:GetView()
		if not oView then
			return
		end
	end
	if self:IsTargetAniType(1) or self:IsTargetAniType(3) then
		if tonumber(self.m_Id) ~= 888 and tonumber(self.m_Id) ~= 889 then			
			dt = dt * g_DialogueAniCtrl:GetAniPlaySpeed()
		end		
	end
	-- if tonumber(self.m_Id) == 888 then
	--printc(" >>>>>>>> ", self.m_ElapseTime, dt)
	-- end
	self.m_ElapseTime = self.m_ElapseTime + dt

	local jumpTime = g_DialogueAniCtrl.m_JumpTimeCache[self.m_Id]
	if jumpTime and jumpTime > self.m_ElapseTime then
		self.m_ElapseTime = jumpTime
		g_DialogueAniCtrl.m_JumpTimeCache[self.m_Id] = nil
	end

	if next(self.m_CmdList) and self.m_CurCmdIdx <= #self.m_CmdList then
		for i = self.m_CurCmdIdx, #self.m_CmdList do
			local oCmd = self.m_CmdList[i]
			if self.m_ElapseTime >= oCmd.m_StartTime then
				xxpcall(oCmd.Excute, oCmd)
				self.m_CurCmdIdx = self.m_CurCmdIdx + 1			
			else
				break
			end		
		end
		for i = 1, #self.m_EffectList do
			local oEff = self.m_EffectList[i] 
			if oEff then
				if self.m_ElapseTime >= oEff.endTime then
					if not Utils.IsNil(oEff.obj) then
						oEff.obj:Destroy()						
						table.remove(self.m_EffectList, i)
						break
					end
				end
			end			
		end
	else

		if self.m_EndTime == 0 then
			self:End()			
		elseif self.m_ElapseTime >= self.m_EndTime then
			--如果是循环剧情，则重播
			if self:IsLoop() then 				
				if g_HouseCtrl:IsInHouse() then
					self.m_ElapseTime = 0
					self.m_CurCmdIdx = 1
				else					
					self:ClearAll()
					local b = g_DialogueAniCtrl:CheckTriggerInScreen(self.m_TriggerNpc)
					--如果触发点在屏幕，重新播放(需要检测同一组的剧情)
					if self.m_ElapseTime >= self.m_EndTime + self:GetLoopTime() then
						if b == define.DialogueAni.TriggerEnum.InScreen or b == define.DialogueAni.TriggerEnum.OutScreen then
							self:End()
							g_DialogueAniCtrl:RePlayDialgueAni(self.m_Id, self.m_TriggerNpc)
						--触发点不在了，直接停止
						else
							self:End()			
						end		
					end
				end
						
			else
				self:End()				
			end			
		end
	end
end

function CDialogueAniUnit.IsRunning(self)
	return self.m_Running
end

function CDialogueAniUnit.ClearNpcs(self)
	g_MapCtrl:DelUnitDialogueNpc(self.m_Id)
end

function CDialogueAniUnit.AddPlayer(self, idx, npc)
	self.m_NpcList[idx] = npc
	g_MapCtrl:AddDialogueNpc(npc, self.m_Id, idx, self:IsTargetAniType(1))	
end

function CDialogueAniUnit.SetPlayerPos(self, idx, pos, rotateY)
	local npcId = self.m_Id * 100 + idx
	local npc = g_MapCtrl:GetDialogueNpc(npcId)
	if npc then
		if g_HouseCtrl:IsInHouse() then
			npc:SetTempPos(Vector3.New(pos.x, 0, pos.y))
			if npc:CanPlayDialogueAni() then
				npc:SetPos(Vector3.New(pos.x, 0, pos.y))
			end
		else
			npc:SetPos(pos)
		end
	end
end

function CDialogueAniUnit.PlayerShowSocialEmoji(self, idx, emoji, visible)
	local npcId = self.m_Id * 100 + idx
	local npc = g_MapCtrl:GetDialogueNpc(npcId)
	if npc then
		if visible == true then
			npc:SetSocialEmoji(emoji)		
		else
			npc:SetSocialEmoji()		
		end
	end
end

function CDialogueAniUnit.SetDialogueAniEndSwitchProcress(self, id)
	if id and id ~= 0 then
		self.m_SettingList["ShowSwitchProcress"] = id
	end
end

function CDialogueAniUnit.SetPlayerActive(self, idx, visible)
	local npcId = self.m_Id * 100 + idx
	local npc = g_MapCtrl:GetDialogueNpc(npcId)
	if npc then
		if g_HouseCtrl:IsInHouse() and not npc:CanPlayDialogueAni() then
			return
		end
		npc:SetVisible(visible)
	end
end

function CDialogueAniUnit.SetPlayerFaceTo(self, idx, rotateY)
	local npcId = self.m_Id * 100 + idx
	local npc = g_MapCtrl:GetDialogueNpc(npcId)
	if npc then
		if g_HouseCtrl:IsInHouse() then
			npc:SetTempRotate(rotateY)
			if not npc:CanPlayDialogueAni() then
				return
			end
		end
		npc.m_Actor:SetLocalRotation(Quaternion.Euler(0, rotateY, 0))
	end
end

function CDialogueAniUnit.PlayerSay(self, idx, msg)
	local npcId = self.m_Id * 100 + idx
	local npc = g_MapCtrl:GetDialogueNpc(npcId)
	if npc then
		if g_HouseCtrl:IsInHouse() and not npc:CanPlayDialogueAni() then
			return
		end
		npc:SendMessage(msg)	
	end
end

function CDialogueAniUnit.PlayerRunto(self, idx, pos, rotateY)
	local npcId = self.m_Id * 100 + idx
	local npc = g_MapCtrl:GetDialogueNpc(npcId)
	rotateY = rotateY or 360
	if npc and pos then
		if g_HouseCtrl:IsInHouse() then
			npc:SetTempPos(Vector3.New(pos.x, 0, pos.y))
			if not npc:CanPlayDialogueAni() then
				return
			end
		end
		if rotateY ~= 360 then
			local cb = function ( )
				if not Utils.IsNil(npc) then
					npc.m_Actor:SetLocalRotation(Quaternion.Euler(0, rotateY, 0))
				end
			end
			npc:WalkTo(pos.x, pos.y, cb)
		else
			npc:WalkTo(pos.x, pos.y)
		end
	end
end

function CDialogueAniUnit.PlayerDoAction(self, idx, action)
	local npcId = self.m_Id * 100 + idx
	local npc = g_MapCtrl:GetDialogueNpc(npcId)
	if npc then
		
		if g_HouseCtrl:IsInHouse() then
			npc:SetTempMotion(action)
			if not npc:CanPlayDialogueAni() then
				return
			end
		end
		local function f()
			--暂时不用动作回归
			-- if not Utils.IsNil(npc) then
			-- 	npc:CrossFade("idleCity", 0.1)
			-- end			
		end
		npc:CrossFade(action, 0.1, 0, 1, f)	
	end
end

function CDialogueAniUnit.PlayerDoEffect(self, idx, effect, pos, rotate, time)
	local npcId = self.m_Id * 100 + idx
	local npc = g_MapCtrl:GetDialogueNpc(npcId)
	if npc then
		if g_HouseCtrl:IsInHouse() and not npc:CanPlayDialogueAni() then
			return
		end
		local aLiveTime
		if time == 0 then
			aLiveTime = self.m_EndTime - self.m_ElapseTime
		else
			aLiveTime = time
		end
		rotate = rotate or Vector3.New(0, 0 , 0)
		local localPath = string.format("Effect/UI/ui_eff_story/Prefabs/%s.prefab", effect)
		local oEff = CDialogueEffect.New(localPath, npc.m_FootTrans)
		oEff:SetLocalPos(pos)
		oEff:SetLocalRotation(Quaternion.Euler(rotate.x, rotate.y, rotate.z))
		self:AddEffect(oEff, aLiveTime)				
	end
end

function CDialogueAniUnit.PlayerUISay(self, idx, content, time, isLeft, isClose, isPause, showIcon, voiceId, isSpineIcon, spineAni, delayShowSay, isFadeIn, jumpTime)
	local npcId = self.m_Id * 100 + idx
	local npc = g_MapCtrl:GetDialogueNpc(npcId)
	local oView = CDialogueAniView:GetView()
	--开始进游戏，第一段剧情，可能由于清理地图，把猫小萌删掉了
	if not npc and tonumber(self.m_Id) == 888 then 
		npc = {}
		npc.m_Name = "喵小萌"
		npc.m_ClientNpc = {}
		npc.m_ClientNpc.model_info = {}
		npc.m_ClientNpc.model_info.shape = 0
	end
	if npc and oView then
		local d = {}
		d.content = content
		d.endTime = time
		d.isLeft = isLeft
		d.isClose = isClose
		d.isPause = isPause
		d.name = npc.m_Name
		d.shape = npc.m_ClientNpc.model_info.shape
		d.showIcon = showIcon 
		d.voiceId = voiceId
		d.isSpineIcon = isSpineIcon
		d.spineAni = spineAni
		d.delayShowSay = delayShowSay
		d.isFadeIn = isFadeIn
		d.jumpTime = jumpTime
		oView:SetNpcSay(d)		

		if voiceId and voiceId ~= 0 then
			self.m_SettingList["voice"] = true
		end
	end
end

function CDialogueAniUnit.SetBgMusic(self, music, isPlay)
	if self.m_SettingList["bgMusic"] == nil then
		self.m_SettingList["bgMusic"] = {}
		self.m_SettingList["bgMusic"].m_MusicRate = g_AudioCtrl:GetMusicRate()
	end	
	music = music .. ".ogg"
	if isPlay then
		g_AudioCtrl:PlayMusic(music)
		self.m_SettingList["bgMusic"].m_Music = music
		if self.m_SettingList["bgMusic"].m_MusicRate then
			g_AudioCtrl:SetMusicRate(self.m_SettingList["bgMusic"].m_MusicRate)
			self.m_SettingList["bgMusic"].m_MusicRate = nil
		end
	else
		g_AudioCtrl:StopMusic()
		g_AudioCtrl:SetMusicRate(0)
		self.m_SettingList["bgMusic"].m_Music = nil
	end
end

function CDialogueAniUnit.SetEffectMusic(self, music)
	g_AudioCtrl:PlaySound(music)
end

function CDialogueAniUnit.SetCameraFollow(self, idx, moveTime)
	if self.m_CamMoveTimer then
		Utils.DelTimer(self.m_CamMoveTimer)
		self.m_CamMoveTimer = nil
	end

	if idx == 0 then
		g_MapCtrl:CheckCamTarget()
	else		
		local npcId = self.m_Id * 100 + idx
		local npc = g_MapCtrl:GetDialogueNpc(npcId)
		if npc then
			if moveTime ~= 0 then
				self.m_TarCamIdx = idx
				self:SetCameraMove(moveTime)
			else
				self.m_CurCamIdx = idx
				local oCam = g_CameraCtrl:GetMapCamera()
				oCam:Follow(npc.m_Transform)
				oCam:SyncTargetPos()
			end			
		else
			self.m_CurCamIdx = idx
			g_DialogueAniCtrl:SetDelayCheckDialogueAniCamera(npcId)
		end
	end
	self.m_SettingList["CameraFollow"] = true
end

function CDialogueAniUnit.SetDialogueAniViewActive(self, visible, bulletvisible, endClose, bgTexture, live2d, maskMode, centerTexture, spineAnim, mustNeedLayer)
	self.m_NeedLayer = mustNeedLayer or false
	local oView = CDialogueAniView:GetView()
	if visible == true then		
		bulletvisible = bulletvisible == nil and true or bulletvisible
		self.endCloseDialogueAniView = endClose == nil and true or endClose
		bgTexture = bgTexture or "none"
		live2d = live2d or 0
		maskMode = maskMode or 0
		centerTexture = centerTexture or "none"
		spineAnim = spineAnim or "none"
		if not oView then
			local d = {id = self.m_Id}
			CDialogueAniView:ShowView(function(oView)				
				oView:SetBulletActive(bulletvisible)				
				oView:SetContent(d)				
				oView:ShowAniBgTexture(bgTexture ~= "none", bgTexture)	
				oView:ShowLive2D(live2d ~= 0, live2d)
				oView:ShowCoverMask(maskMode ~= 0, maskMode)	
				oView:SetDialogueMidTexture(centerTexture ~= "none", centerTexture, spineAnim)
			end)
		else
			local d = {id = self.m_Id}
			oView:SetBulletActive(bulletvisible)
			oView:SetContent(d)
			oView:ShowAniBgTexture(bgTexture ~= "none", bgTexture)					
			oView:ShowLive2D(live2d ~= 0, live2d)	
			oView:ShowCoverMask(maskMode ~= 0, maskMode)	
			oView:SetDialogueMidTexture(centerTexture ~= "none", centerTexture, spineAnim)
		end
		self.m_SettingList["DialogueAniView"] = true
	else
		self.endCloseDialogueAniView = true
		if oView then
			oView:CloseView()
		end
	end
end

function CDialogueAniUnit.SetDialogueAniViewShowLive2D(self, visible, model)
	local oView = CDialogueAniView:GetView()
	if oView then
		oView:ShowLive2D(visible, model)
	end
end

function CDialogueAniUnit.SetDialogueAniViewRename(self, visible)
	local oView = CDialogueAniView:GetView()
	if oView then
		oView:ShowReNameBox(visible)
	end
end

function CDialogueAniUnit.SetDialogueAniViewBgTexture(self, visible, path)
	local oView = CDialogueAniView:GetView()
	if oView then
		oView:ShowAniBgTexture(visible, path)
	end
end

function CDialogueAniUnit.SetDialogueAniViewCoverMask(self, visible, mode , showAlpahTextrue)
	local oView = CDialogueAniView:GetView()
	if oView then
		oView:ShowCoverMask(visible, mode, showAlpahTextrue)
	end
end

function CDialogueAniUnit.SetDialogueAniViewCoverMaskSay(self, visible, msg , isCenter)
	local oView = CDialogueAniView:GetView()
	if oView then
		oView:ShowCoverMaskSay(visible, msg, isCenter)
	end
end

function CDialogueAniUnit.SetDialogueAniViewPause(self)
	local oView = CDialogueAniView:GetView()
	if oView then
		oView:PauseAni()
	end
end

function CDialogueAniUnit.SetDialogueAniViewShowResumeBtn(self, visible, msg)
	local oView = CDialogueAniView:GetView()
	if oView then
		oView:ShowResumeBtn(visible, msg)
	end
end

function CDialogueAniUnit.SetDialogueAniEndTriggerGuide(self, key)
	self.m_EndTriggerGuiedKey = key
end

function CDialogueAniUnit.SetDialogueAniEndTriggerStoryTask(self, storyTaskId)	
	self.m_EndPlayStoryTaskId = storyTaskId
end

function CDialogueAniUnit.SetDialogueAniEndTriggerOtherDialogueAni(self, dialogueAniId)	
	self.m_EndPlayDialogueAniId = dialogueAniId
end

function CDialogueAniUnit.SetDialogueAniEndFlag(self, flag, cacheNow)	
	if cacheNow == true then
		g_GuideCtrl:ReqCustomGuideFinish(flag)	
	else
		self.m_EndPlayDialogueFlag = flag
	end
end

function CDialogueAniUnit.SetDialogueAniEndSwitchBox(self, visible, path, doNow, time, fadeIn)		
	if doNow then
		if visible == true then
			if path ~= "none" then
				g_NotifyCtrl:ShowAniSwitchTextureBg(path, time, fadeIn)
			else
				g_NotifyCtrl:ShowAniSwitchBlackBg(time, fadeIn)
			end			
		else
			self.m_SettingList["ShowSwitchBox"] = nil
			g_NotifyCtrl:CloseAniSwitchBox()
		end
	else
		if visible == true then
			local d = {path=path, time = time, fadeIn = fadeIn}
			self.m_SettingList["ShowSwitchBox"] = d
		else
			self.m_SettingList["ShowSwitchBox"] = nil
			g_NotifyCtrl:CloseAniSwitchBox()
		end
	end
end

function CDialogueAniUnit.PlayerDoSkillMagic(self, attack, beAttack, modeId, skillIdx)	
	local attakId = self.m_Id * 100 + attack
	local attackNpc = g_MapCtrl:GetDialogueNpc(attakId)
	local beAttakId = self.m_Id * 100 + beAttack
	local beAttackNpc = g_MapCtrl:GetDialogueNpc(beAttakId)
	if attackNpc and beAttackNpc and modeId and skillIdx then

		local requiredata = {
			refAtkObj = weakref(attackNpc),
			refVicObjs = {weakref(beAttackNpc)},
		}

		local skillId = 0
		if modeId == 0 then
			if g_AttrCtrl.model_info.shape == 110 or g_AttrCtrl.model_info.shape == 120 then
				if g_AttrCtrl.school_branch == 2 then 
					modeId = 31
				else
					modeId = 30
				end		
			elseif g_AttrCtrl.model_info.shape == 130 or g_AttrCtrl.model_info.shape == 140 then
				if g_AttrCtrl.school_branch == 2 then 
					modeId = 33
				else
					modeId = 32
				end
			elseif g_AttrCtrl.model_info.shape == 150 or g_AttrCtrl.model_info.shape == 160 then
				if g_AttrCtrl.school_branch == 2 then 
					modeId = 35
				else
					modeId = 34
				end
			end
		end
		skillId = tonumber(string.format("%d0%d", modeId, skillIdx))
		local oMagicUnit = g_MagicCtrl:NewMagicUnit(define.Magic.SpcicalID.DialogueAni, skillId, requiredata)

		oMagicUnit:SetLayer(self.m_Layer)
		oMagicUnit:Start()
	end
end

function CDialogueAniUnit.AddMapEffect(self, name, path, pos, rotateY, time, isFront, isIgnoreStroy)	
	local oRoot 
	if isIgnoreStroy then
		oRoot = g_DialogueAniCtrl:GetEffctBaseRoot()
	else
		oRoot = self:GetEffctRoot()
	end
	 
	if oRoot then
		local z = 0
		if isFront ~= true then
			z = 50
		end
		local localPath = string.format("Effect/UI/ui_eff_story/Prefabs/%s.prefab", path)
		local cb = function (obj)
			if not Utils.IsNil(obj) then
				obj:SetLocalPos(Vector3(pos.x, pos.y, z))
			end
		end		
		local oEff = CDialogueEffect.New(localPath, oRoot.m_Transform, self.m_Layer, false, cb)
		oEff:SetName(name)
		oEff:SetParent(oRoot.m_Transform)
		if isIgnoreStroy then
			time = time or 10
			Utils.AddTimer(callback(oEff, "Destroy"), 0 , time)
			g_EffectCtrl:AddEffect(oEff)
		else						
			local aLiveTime
			if time == 0 then
				aLiveTime = self.m_EndTime - self.m_ElapseTime
			else
				aLiveTime = time
			end
			self:AddEffect(oEff, aLiveTime, name)	
		end	
	end	
end

function CDialogueAniUnit.AddCamerakEffect(self, name, path, x, y, time, isAdjust)
	local oCam = g_CameraCtrl:GetMainCamera()
	if oCam then
		local localPath = string.format("Effect/UI/ui_eff_story/Prefabs/%s.prefab", path)
		local cb = function (obj)
			if not Utils.IsNil(obj) then
				obj:SetLocalPos(Vector3(x, y, 0))
			end
		end			
		local oEff = CDialogueEffect.New(localPath, oCam.m_Transform, self.m_Layer, false, cb)
		oEff:SetParent(oCam.m_Transform)
		oEff:SetName(name)
		local aLiveTime
		if time == 0 then
			aLiveTime = self.m_EndTime - self.m_ElapseTime
		else
			aLiveTime = time
		end
		self:AddEffect(oEff, aLiveTime, name)		
	end	
end

function CDialogueAniUnit.DoEffectMoveOption(self, name , oPos, tPos, time)
	local config = {}
	config.name = name 
	config.oPos = oPos
	config.tPos = tPos
	config.time = time
	self:DoEffectOption(1, config)
end

function CDialogueAniUnit.DoEffectOption(self, type, config, config2, config3, config4)
	local oEff = nil
	config = config or {}
	local name = config.name
	if self.m_EffectList and next(self.m_EffectList) then
		for k,v in pairs(self.m_EffectList) do
			if v.name == name then
				oEff = v.obj
			end
		end
	end
	if oEff then
		if type == 1 then
			local oPos = oEff:GetLocalPos()
			config.tPos.z = oPos.z
			local tween = DOTween.DOMove(oEff.m_Transform, config.tPos, config.time)

		end
	end
end

function CDialogueAniUnit.AddUIScreenEffect(self, name, path, pivot, time, pos, scale, isTop, isAdjust)
	local oRoot = nil
	if isTop then
		oRoot = g_NotifyCtrl:GetUIScreenEffectRoot()
	else
		local oView = CBottomView:GetView()
		if oView then
			oRoot = oView.m_DialogueAniEffctBottomRoot
		end		
	end
	if oRoot then
		local localPath = string.format("Effect/UI/ui_eff_story/Prefabs/%s.prefab", path)
		local cb = function (obj)
			if not Utils.IsNil(obj) then
				local w, h = UITools.GetRootSize()	
				local adjustScale = 1
				if isAdjust then
					adjustScale = 1334 / 750 *  h / w
				end
				if scale then
					obj:SetLocalScale(Vector3.New(scale.x, scale.y * adjustScale, 1))
				end
				local vPos = Vector3.New(0, 0, 0)
				if pivot == 1 then
					vPos.y = h / 2
				elseif pivot == 2 then
					vPos.y = - h / 2
				elseif pivot == 3 then
					vPos.x = - w / 2
				elseif pivot == 4 then
					vPos.x = w / 2
				end		
				local x = pos.x or 0
				local y = pos.y or 0
				vPos.x = vPos.x + x
				vPos.y = vPos.y + y
				obj:SetLocalPos(vPos)		
			end
		end			
		local oEff = CUIDialogueAniEffect.New(oRoot, localPath, cb)		
		oEff:SetParent(oRoot.m_Transform)
		oEff:SetName(name)
		local aLiveTime
		if time == 0 then
			aLiveTime = self.m_EndTime - self.m_ElapseTime
		else
			aLiveTime = time
		end
		self:AddEffect(oEff, aLiveTime, name)		
	end	
end

function CDialogueAniUnit.SetDialogueMidTexture(self, visible, path)		
	local oView = CDialogueAniView:GetView()
	if oView then
		oView:SetDialogueMidTexture(visible, path)
	end
end

function CDialogueAniUnit.PlayerLive2dDoAction(self, action)		
	local oView = CDialogueAniView:GetView()
	if oView then
		oView:DoLive2dAction(action)
	end
end

function CDialogueAniUnit.AddUIXingYiXingEffect(self, path, visible)		
	local oView = CDialogueAniView:GetView()
	if oView then
		oView:ShowXingYiXingEffect(path, visible)
	end
end

function CDialogueAniUnit.HideSayWidget(self, hide )
	local oView = CDialogueAniView:GetView()
	if oView then
		oView:HideSayWidget(hide)
	end
end

function CDialogueAniUnit.PlayerShowBottomMagic(self, idx, visible )
	local npcId = self.m_Id * 100 + idx
	local npc = g_MapCtrl:GetDialogueNpc(npcId)
	if npc then
		if visible then
			npc:SetTouchTipsTag(1)
		else
			npc:SetTouchTipsTag(0)
		end			
	end
end

function CDialogueAniUnit.SetCameraDistance(self, dis, time)
	local oCam = g_CameraCtrl:GetMainCamera()
	local iCurSize = oCam:GetOrthographicSize()
	if iCurSize == dis then
		return
	end
	self.m_SettingList["CameraDistance"] = iCurSize
	if time == 0 then
		g_CameraCtrl:SetMapCameraSize(dis)
		return
	end
	local offset = dis - iCurSize
	local speed = offset / time
	local t = 0
	local function cb( dt )
		if Utils.IsNil(self) then
			return false
		end
		t = t + dt	
		if t > time then
			return false
		end
		local oCam = g_CameraCtrl:GetMainCamera()
		local iCurSize = oCam:GetOrthographicSize()
		local iNewSize = iCurSize + speed * dt
		if iNewSize ~= iCurSize then
			g_CameraCtrl:SetMapCameraSize(iNewSize)

		end
		return true
	end
	Utils.AddTimer(cb, 0, 0)
end

function CDialogueAniUnit.SetPhoneShake(self, shake)
	if shake == true then
		C_api.Utils.Vibrate()
	end
end

--触发点离开时，是否还继续
function CDialogueAniUnit.IsTrigger(self)
	return self.m_Config.isTrigger == 1
end

function CDialogueAniUnit.GetTriggerNpc(self)
	return self.m_TriggerNpc
end

function CDialogueAniUnit.IsLoop(self)
	return self.m_Config.isLoop == 1
end

function CDialogueAniUnit.GetLoopTime(self)
	return self.m_Config.loopTime or 0
end

function CDialogueAniUnit.AddEffect(self, obj, aLiveTime, name)
	local time = self.m_ElapseTime + aLiveTime
	local d = {obj = obj, endTime = time, name = name}
	table.insert(self.m_EffectList, d)
end

function CDialogueAniUnit.ClearAllEffect(self)
	for i = 1, #self.m_EffectList do
		local oEff = self.m_EffectList[i]
		if oEff then
			if not Utils.IsNil(oEff.obj) then
				oEff.obj:Destroy()
			end
		end
	end
	self.m_EffectList = {}
end

--处理一些需要开场处理的指令
function CDialogueAniUnit.ProcressStartCmd(self)
	for i,v in ipairs(self.m_CmdList) do
		if v.m_FuncName == "SetDialogueAniViewActive" or 
		   v.m_FuncName == "SetDialogueAniEndTriggerGuide" or 
		   v.m_FuncName == "SetDialogueAniEndTriggerStoryTask" or  
		   v.m_FuncName == "SetDialogueAniEndTriggerOtherDialogueAni" or
		   v.m_FuncName == "SetDialogueAniEndSwitchProcress" then
			 v:Excute()		
		elseif v.m_FuncName == "SetDialogueAniEndFlag" then
			local flag = tostring(v.m_Args[1][1])
			local cacheNow = tonumber(v.m_Args[2][1]) == 1 and true or false
			if cacheNow ~= true then
				v:Excute()
			end
		-- elseif v.m_FuncName == "SetDialogueAniEndSwitchBox" then
		-- 	local visible = tonumber(v.m_Args[1][1]) == 1 and true or false
		-- 	local path = tostring(v.m_Args[2][1])
		-- 	local doStart = tonumber(v.m_Args[3][1]) == 1 and true or false
		-- 	local time = 0
		-- 	if v.m_Args[4] and v.m_Args[4][1] then
		-- 		time = tonumber(v.m_Args[4][1])
		-- 	end
		-- 	local fadeIn = false
		-- 	if v.m_Args[5] and v.m_Args[5][1] then
		-- 		fadeIn = tonumber(v.m_Args[5][1]) == 1 and true or false
		-- 	end	
		-- 	if doStart == true then
		-- 		self:SetDialogueAniEndSwitchBox(visible, path, true, time, fadeIn)
		-- 	end
		end
	end
end

function CDialogueAniUnit.GetEffctRoot(self)
	if not self.m_EfftRoot then		
		self.m_EfftRoot = CObject.New(UnityEngine.GameObject.New())
		self.m_EfftRoot:SetName(string.format("DialogueEffctRoot_%d", self.m_Id))
	end
	return self.m_EfftRoot
end

function CDialogueAniUnit.SetCameraMove(self, moveTime)
	local time = moveTime or 1
	if not self.m_CamTarget then
		self.m_CamTarget = CObject.New(UnityEngine.GameObject.New())		
		self.m_CamTarget:SetName("DialogueAniCameraFollower")
	end
	self.m_CamTarget:SetParent(g_MapCtrl:GetWalkerRoot().m_Transform)
	local fId = self.m_Id * 100 + self.m_CurCamIdx
	local tId = self.m_Id * 100 + self.m_TarCamIdx
	local fNpc = g_MapCtrl:GetDialogueNpc(fId)
	local tNpc = g_MapCtrl:GetDialogueNpc(tId)
	if fNpc and tNpc then
		local fPos = fNpc:GetLocalPos()
		local tPos = tNpc:GetLocalPos()
		self.m_CamTarget:SetLocalPos(fPos)
		local oCam = g_CameraCtrl:GetMapCamera()
		oCam:Follow(self.m_CamTarget.m_Transform)
		oCam:SyncTargetPos()
		self.m_CurCamIdx = self.m_TarCamIdx
		self.m_CamMoveAction = CActionVector.New(self.m_CamTarget, time, "SetLocalPos", fPos, tPos)
		g_ActionCtrl:AddAction(self.m_CamMoveAction)
		self.m_CamMoveTimer = Utils.AddTimer(callback(self, "SetCameraFollow", self.m_TarCamIdx, false), 0, time + 1)
	end
end

--类型返回
--"普通剧场", target = 0,
--"主线剧场", target = 1,
--"常驻NPC剧场", target = 2
--"界面剧场", target = 3
function CDialogueAniUnit.IsTargetAniType(self, target)
	return self.m_Config.isStroy == target
end

function CDialogueAniUnit.AddLayerAniPlayer(self, idx, npc)
	if self:IsTargetAniType(3) then
		local oView = CDialogueLayerAniView:GetView()
		if oView then
			oView:AddNpc(idx, npc)
		end	
	end	
end

function CDialogueAniUnit.LayerAniPlayerRunto(self, idx, pos, faceright)
	if self:IsTargetAniType(3) then
		local oView = CDialogueLayerAniView:GetView()
		if oView then
			oView:WalkTo(idx, pos, faceright)
		end
	end
end

function CDialogueAniUnit.SetLayerAniPlayerPos(self, idx, pos, faceright)
	if self:IsTargetAniType(3) then
		local oView = CDialogueLayerAniView:GetView()
		if oView then
			oView:SetPlayerPos(idx, pos, faceright)
		end	
	end	
end

function CDialogueAniUnit.SetLayerAniPlayerActive(self, idx, visible, isfade)
	if self:IsTargetAniType(3) then
		local oView = CDialogueLayerAniView:GetView()
		if oView then
			oView:SetPlayerActive(idx, visible, isfade)
		end	
	end	
end

function CDialogueAniUnit.SetLayerAniPlayerFaceTo(self, idx, faceright)
	if self:IsTargetAniType(3) then
		local oView = CDialogueLayerAniView:GetView()
		if oView then
			oView:SetPlayerFaceTo(idx, faceright)
		end	
	end	
end

function CDialogueAniUnit.LayerAniPlayerSay(self, idx, msg, time)
	if self:IsTargetAniType(3) then
		local oView = CDialogueLayerAniView:GetView()
		if oView then
			oView:SetPlayerSay(idx, msg, time)
		end	
	end	
end

function CDialogueAniUnit.LayerAniPlayerDoAction(self, idx, action, config)
	if self:IsTargetAniType(3) then
		local oView = CDialogueLayerAniView:GetView()
		if oView then
			oView:SetPlayerDoAction(idx, action, config)
		end	
	end	
end

function CDialogueAniUnit.LayerAniPlayerShowSocialEmoji(self, idx, emoji, visible)
	if self:IsTargetAniType(3) then
		local oView = CDialogueLayerAniView:GetView()
		if oView then
			oView:SetPlayerShowSocialEmoji(idx, emoji, visible)
		end	
	end	
end

function CDialogueAniUnit.LayerAniCameraScale(self, isscale, center, time, scale)
	if self:IsTargetAniType(3) then
		local oView = CDialogueLayerAniView:GetView()
		if oView then
			oView:SetCameraScale(isscale, center, time, scale)
		end	
	end	
end

function CDialogueAniUnit.SetLayerAniPlayerDepth(self, idx, depth)
	if self:IsTargetAniType(3) then
		local oView = CDialogueLayerAniView:GetView()
		if oView then
			oView:SetPlayerDepth(idx, depth)
		end	
	end	
end


return CDialogueAniUnit