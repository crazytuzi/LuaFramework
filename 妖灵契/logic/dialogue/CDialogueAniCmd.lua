local CDialogueAniCmd = class("CDialogueAniCmd")

CDialogueAniCmd.LogToggle = 1

function CDialogueAniCmd.ctor(self, funcname, starttime, args, dialogueUnit)
	self.m_FuncName = funcname
	self.m_StartTime = starttime
	self.m_Args = args
	self.m_DilaogueUnit = dialogueUnit
	--printc(" CDialogueAniCmd.ctor  funcname = ", funcname)
end

function CDialogueAniCmd.Excute(self)
	--printc("CDialogueAniCmd ?????????  excute  ", self.m_FuncName)
	local f = CDialogueAniCmd[self.m_FuncName]
	if f then
		f(self)
	end
end

function CDialogueAniCmd.AddPlayer(self)
	local name = tostring(self.m_Args[1][1])
	local model = tonumber(self.m_Args[2][1])
	local pos = Vector3.New(tonumber(self.m_Args[3][1]), tonumber(self.m_Args[3][2]), 0)
	local rotateY = tonumber(self.m_Args[4][1])
	local idx = tonumber(self.m_Args[5][1])
	local haveMagic = false
	if self.m_Args[6] and self.m_Args[6][1] then
		haveMagic = tonumber(self.m_Args[6][1]) == 1 and true or false
	end
	local info = {}
	local model_info = {}
	if model == 0 then
		if g_HouseCtrl:IsInHouse() and g_HouseCtrl:IsInFriendHouse() then
			local friendData = g_FriendCtrl:GetFriend(g_HouseCtrl.m_OwnerPid)
			model = friendData.shape
			name = friendData.name
			-- model_info.weapon = g_AttrCtrl.model_info.weapon
		else
			model = g_AttrCtrl.model_info.shape
			name = g_AttrCtrl.name
			model_info.weapon = g_AttrCtrl.model_info.weapon
		end
	end
	model_info.scale = 1
	model_info.shape = model
	local pos_info = {}
	pos_info.x = pos.x * 1000
	pos_info.y = pos.y * 1000
	info.rotateY = rotateY
	info.model_info = model_info
	info.pos_info = pos_info
	info.name = name
	info.npcid = self.m_DilaogueUnit.m_Id * 100 + idx     --剧情npcid  剧本id*100  + 人物编号
	info.haveMagic = haveMagic
	if CDialogueAniCmd.LogToggle then
		printc(" AddPlayer ", name , model, pos, rotateY, haveMagic)
	end
	
	self.m_DilaogueUnit:AddPlayer(idx, info)
end

function CDialogueAniCmd.SetPlayerPos(self)
	local idx = tonumber(self.m_Args[1][1])
	local pos = Vector3.New(tonumber(self.m_Args[2][1]), tonumber(self.m_Args[2][2]), 0)
	if CDialogueAniCmd.LogToggle then
		printc(" SetPlayerPos ", idx , pos)
	end
	self.m_DilaogueUnit:SetPlayerPos(idx, pos)
end

function CDialogueAniCmd.SetPlayerActive(self)
	local idx = tonumber(self.m_Args[1][1])
	local visible = tonumber(self.m_Args[2][1]) == 1 and true or false
	if CDialogueAniCmd.LogToggle then
		printc(" SetPlayerActive ", idx , visible)
	end
	self.m_DilaogueUnit:SetPlayerActive(idx, visible)
end

function CDialogueAniCmd.SetPlayerFaceTo(self)
	local idx = tonumber(self.m_Args[1][1])
	local rotateY = tonumber(self.m_Args[2][1])
	if CDialogueAniCmd.LogToggle then
		printc(" SetPlayerFaceTo ", idx , rotateY)
	end
	self.m_DilaogueUnit:SetPlayerFaceTo(idx, rotateY)
end

function CDialogueAniCmd.PlayerSay(self)
	local idx = tonumber(self.m_Args[1][1])
	local msg = tostring(self.m_Args[2][1])
	if CDialogueAniCmd.LogToggle then
		printc(" PlayerSay ", idx , msg)
	end
	self.m_DilaogueUnit:PlayerSay(idx, msg)
end

function CDialogueAniCmd.PlayerRunto(self)
	local idx = tonumber(self.m_Args[1][1])
	local pos = Vector3.New(tonumber(self.m_Args[2][1]), tonumber(self.m_Args[2][2]), 0)
	local rotateY = 360
	if self.m_Args[3] and self.m_Args[3][1] then
		rotateY = tonumber(self.m_Args[3][1])
	end

	if CDialogueAniCmd.LogToggle then
		printc(" PlayerRunto ", idx , pos, rotateY)
	end
	self.m_DilaogueUnit:PlayerRunto(idx, pos, rotateY)
end

function CDialogueAniCmd.PlayerDoAction(self)
	local idx = tonumber(self.m_Args[1][1])
	local action = tostring(self.m_Args[2][1])
	if CDialogueAniCmd.LogToggle then
		printc(" PlayerDoAction ", idx , action)
	end
	self.m_DilaogueUnit:PlayerDoAction(idx, action)
end

function CDialogueAniCmd.PlayerDoEffect(self)
	local idx = tonumber(self.m_Args[1][1])
	local effect = tostring(self.m_Args[2][1])
	local pos = Vector3.New(tonumber(self.m_Args[3][1]), tonumber(self.m_Args[3][2]), tonumber(self.m_Args[3][3]))
	local rotate = Vector3.New(0,0,0)
	if self.m_Args[4] then
		rotate.x = tonumber(self.m_Args[4][1]  or 0 )
		rotate.y = tonumber(self.m_Args[4][2]  or 0 )
		rotate.z = tonumber(self.m_Args[4][3]  or 0 )
	end
	local aLiveTime = tonumber(self.m_Args[5][1])
	if CDialogueAniCmd.LogToggle then
		printc(" PlayerDoEffect ", idx, effect, pos, rotate, aLiveTime)
	end
	self.m_DilaogueUnit:PlayerDoEffect(idx, effect, pos, rotate, aLiveTime)
end

function CDialogueAniCmd.PlayerUISay(self)
	local idx = tonumber(self.m_Args[1][1])
	local content = tostring(self.m_Args[2][1])
	local time = tonumber(self.m_Args[3][1])
	local isLeft = tonumber(self.m_Args[4][1])
	local isClose = tonumber(self.m_Args[5][1])
	local isPause = tonumber(self.m_Args[6][1])
	local showIcon = true 
	if self.m_Args[7] and self.m_Args[7][1] ~= nil then
		showIcon = tonumber(self.m_Args[7][1]) == 1 and true or false
	end
	local voiceid = 0
	if self.m_Args[8] and self.m_Args[8][1] ~= nil then
		voiceid = tonumber(self.m_Args[8][1])
	end	
	local isSpineIcon = false
	if self.m_Args[9] and self.m_Args[9][1] ~= nil then
		isSpineIcon = tonumber(self.m_Args[9][1]) == 1 and true or false
	end		
	local spineAni = "idle"
	if self.m_Args[10] and self.m_Args[10][1] ~= nil then
		spineAni = tostring(self.m_Args[10][1])
	end	
	local delayShowSay = 0
	if self.m_Args[11] and self.m_Args[11][1] ~= nil then
		delayShowSay = tonumber(self.m_Args[11][1])
	end	
	local isFadeIn = true
	if self.m_Args[12] and self.m_Args[12][1] ~= nil then
		isFadeIn = tonumber(self.m_Args[12][1]) == 1 and true or false
	end	

	local isFadeIn = true
	if self.m_Args[12] and self.m_Args[12][1] ~= nil then
		isFadeIn = tonumber(self.m_Args[12][1]) == 1 and true or false
	end	
	local jumpTime = 0
	if self.m_Args[13] and self.m_Args[13][1] ~= nil then
		jumpTime = tonumber(self.m_Args[13][1])
	end	
	if CDialogueAniCmd.LogToggle then
		printc(" PlayerUISay ", idx, content, time, isLeft, isClose, isPause, showIcon, voiceid, isSpineIcon, spineAni, delayShowSay, isFadeIn, jumpTime)
	end
	self.m_DilaogueUnit:PlayerUISay(idx, content, time, isLeft, isClose, isPause, showIcon, voiceid, isSpineIcon, spineAni, delayShowSay, isFadeIn, jumpTime)
end

function CDialogueAniCmd.SetBgMusic(self)
	local music = tostring(self.m_Args[1][1])	
	local isPlay = 1
	if self.m_Args[2] and self.m_Args[2][1] ~= nil then
		isPlay = tonumber(self.m_Args[2][1]) == 1 and true or false
	end	
	if CDialogueAniCmd.LogToggle then
		printc(" SetBgMusic ", music, isPlay)
	end
	self.m_DilaogueUnit:SetBgMusic(music, isPlay)
end

function CDialogueAniCmd.SetEffectMusic(self)
	local music = tostring(self.m_Args[1][1])	
	if CDialogueAniCmd.LogToggle then
		printc(" SetEffectMusic ", music)
	end
	self.m_DilaogueUnit:SetEffectMusic(music)
end

function CDialogueAniCmd.SetCameraFollow(self)
	local idx = tonumber(self.m_Args[1][1])
	local moveTime = 0
	if self.m_Args[2] and self.m_Args[2][1] then
		moveTime = tonumber(self.m_Args[2][1])
	end
	if CDialogueAniCmd.LogToggle then
		printc(" SetCameraFollow ", idx, moveTime)
	end	
	self.m_DilaogueUnit:SetCameraFollow(idx, moveTime)
end

function CDialogueAniCmd.SetDialogueAniViewActive(self)
	local visible = tonumber(self.m_Args[1][1]) == 1 and true or false
	local bulletvisible = true 
	if self.m_Args[2] and self.m_Args[2][1] ~= nil then
		bulletvisible = tonumber(self.m_Args[2][1]) == 1 and true or false
	end	
	local endClose = true
	if self.m_Args[3] and self.m_Args[3][1] ~= nil then
		endClose = tonumber(self.m_Args[3][1]) == 1 and true or false
	end		
	local bgTextrue = ""
	if self.m_Args[4] and self.m_Args[4][1] ~= nil then
		bgTextrue = tostring(self.m_Args[4][1])
	end		
	local live2d = 0
	if self.m_Args[5] and self.m_Args[5][1] ~= nil then
		live2d = tonumber(self.m_Args[5][1])
	end	
	local maskmode = 0
	if self.m_Args[6] and self.m_Args[6][1] ~= nil then
		maskmode = tonumber(self.m_Args[6][1])
	end	
	local centerTextrue = ""
	if self.m_Args[7] and self.m_Args[7][1] ~= nil then
		centerTextrue = tostring(self.m_Args[7][1])
	end			
	local spineAnim = ""
	if self.m_Args[8] and self.m_Args[8][1] ~= nil then
		spineAnim = tostring(self.m_Args[8][1])
	end
	local mustNeedLayer = false
	if self.m_Args[9] and self.m_Args[9][1] ~= nil then
		mustNeedLayer = tonumber(self.m_Args[9][1]) == 1 and true or false
	end
	if CDialogueAniCmd.LogToggle then
		printc(" SetDialogueAniViewActive ", visible, bulletvisible, endClose, bgTextrue, live2d, maskmode, centerTextrue, spineAnim, mustNeedLayer)
	end
	self.m_DilaogueUnit:SetDialogueAniViewActive(visible, bulletvisible, endClose, bgTextrue, live2d, maskmode, centerTextrue, spineAnim, mustNeedLayer)
end


function CDialogueAniCmd.SetDialogueAniViewShowLive2D(self)
	local visible = tonumber(self.m_Args[1][1]) == 1 and true or false
	local model = tostring(self.m_Args[2][1])
	if CDialogueAniCmd.LogToggle then
		printc(" SetDialogueAniViewShowLive2D ", visible)
	end
	self.m_DilaogueUnit:SetDialogueAniViewShowLive2D(visible, model)
end

function CDialogueAniCmd.SetDialogueAniViewRename(self)
	local visible = tonumber(self.m_Args[1][1]) == 1 and true or false
	if CDialogueAniCmd.LogToggle then
		printc(" SetDialogueAniViewRename ", visible)
	end
	self.m_DilaogueUnit:SetDialogueAniViewRename(visible)
end

function CDialogueAniCmd.SetDialogueAniViewBgTexture(self)
	local visible = tonumber(self.m_Args[1][1]) == 1 and true or false
	local path = tostring(self.m_Args[2][1])
	if CDialogueAniCmd.LogToggle then
		printc(" SetDialogueAniViewBgTexture ", visible, path)
	end
	self.m_DilaogueUnit:SetDialogueAniViewBgTexture(visible, path)
end

function CDialogueAniCmd.SetDialogueAniViewCoverMask(self)
	local visible = tonumber(self.m_Args[1][1]) == 1 and true or false
	local mode = tonumber(self.m_Args[2][1])
	local showAlpahTextrue = false
	if self.m_Args[3] and self.m_Args[3][1] then
		showAlpahTextrue = tonumber(self.m_Args[3][1]) == 1 and true or false
	end
	if CDialogueAniCmd.LogToggle then
		printc("SetDialogueAniViewCoverMask", visible, mode, showAlpahTextrue)
	end
	self.m_DilaogueUnit:SetDialogueAniViewCoverMask(visible, mode, showAlpahTextrue)
end

function CDialogueAniCmd.SetDialogueAniViewCoverMaskSay(self )
	local visible = tonumber(self.m_Args[1][1]) == 1 and true or false
	local msg = tostring(self.m_Args[2][1])
	local isCenter = false
	if self.m_Args[3] and self.m_Args[3][1] then
		isCenter = tonumber(self.m_Args[3][1]) == 1 and true or false
	end

	if CDialogueAniCmd.LogToggle then
		printc("SetDialogueAniViewCoverMaskSay", visible, msg, isCenter)
	end
	self.m_DilaogueUnit:SetDialogueAniViewCoverMaskSay(visible, msg, isCenter)
end

function CDialogueAniCmd.SetDialogueAniViewPause(self)
	-- if CDialogueAniCmd.LogToggle then
	-- 	printc("SetDialogueAniViewPause", visible, msg)
	-- end
	self.m_DilaogueUnit:SetDialogueAniViewPause()
end

function CDialogueAniCmd.SetDialogueAniViewShowResumeBtn(self)
	local visible = tonumber(self.m_Args[1][1]) == 1 and true or false
	local msg = tostring(self.m_Args[2][1])
	if CDialogueAniCmd.LogToggle then
		printc("SetDialogueAniViewShowResumeBtn", visible, msg)
	end
	self.m_DilaogueUnit:SetDialogueAniViewShowResumeBtn(visible, msg)
end

function CDialogueAniCmd.SetDialogueAniEndTriggerGuide(self)
	local key = tostring(self.m_Args[1][1])
	if CDialogueAniCmd.LogToggle then
		printc("SetDialogueAniEndTriggerGuide", key)
	end
	self.m_DilaogueUnit:SetDialogueAniEndTriggerGuide(key)
end

function CDialogueAniCmd.SetDialogueAniEndTriggerStoryTask(self)
	local storyTaskId = tostring(self.m_Args[1][1])
	if CDialogueAniCmd.LogToggle then
		printc("SetDialogueAniEndTriggerStoryTask", storyTaskId)
	end
	self.m_DilaogueUnit:SetDialogueAniEndTriggerStoryTask(storyTaskId)
end

function CDialogueAniCmd.SetDialogueAniEndTriggerOtherDialogueAni(self)
	local dialogueAniId = tostring(self.m_Args[1][1])
	if CDialogueAniCmd.LogToggle then
		printc("SetDialogueAniEndTriggerOtherDialogueAni", dialogueAniId)
	end
	self.m_DilaogueUnit:SetDialogueAniEndTriggerOtherDialogueAni(dialogueAniId)
end

function CDialogueAniCmd.SetDialogueAniEndFlag(self)
	local flag = tostring(self.m_Args[1][1])
	local cacheNow = tonumber(self.m_Args[2][1]) == 1 and true or false
	if CDialogueAniCmd.LogToggle then
		printc("SetDialogueAniEndFlag", flag, cacheNow)
	end
	self.m_DilaogueUnit:SetDialogueAniEndFlag(flag, cacheNow)
end

function CDialogueAniCmd.SetDialogueMidTexture(self)
	local visible = tonumber(self.m_Args[1][1]) == 1 and true or false
	local path = tostring(self.m_Args[2][1])
	if CDialogueAniCmd.LogToggle then
		printc("SetDialogueMidTexture", visible, path)
	end
	self.m_DilaogueUnit:SetDialogueMidTexture(visible, path)
end

function CDialogueAniCmd.PlayerShowBottomMagic(self)
	local idx = tonumber(self.m_Args[1][1])
	local visible = tonumber(self.m_Args[2][1]) == 1 and true or false
	if CDialogueAniCmd.LogToggle then
		printc(" PlayerShowBottomMagic ", idx , visible)
	end
	self.m_DilaogueUnit:PlayerShowBottomMagic(idx, visible)
end

function CDialogueAniCmd.SetCameraDistance(self)
	local dis = tonumber(self.m_Args[1][1])
	local time = tonumber(self.m_Args[2][1])
	if CDialogueAniCmd.LogToggle then
		printc("SetCameraDistance", dis, time)
	end
	self.m_DilaogueUnit:SetCameraDistance(dis, time)
end

function CDialogueAniCmd.SetPhoneShake(self)	
	local shake = tonumber(self.m_Args[1][1]) == 1 and true or false
	if CDialogueAniCmd.LogToggle then
		printc(" SetPhoneShake ", shake)
	end
	self.m_DilaogueUnit:SetPhoneShake(shake)
end

function CDialogueAniCmd.SetDialogueAniEndSwitchBox(self)
	local visible = tonumber(self.m_Args[1][1]) == 1 and true or false
	local path = tostring(self.m_Args[2][1])	
	local doStart = tonumber(self.m_Args[3][1]) == 1 and true or false
	local time = 0 
	if self.m_Args[4] and self.m_Args[4][1] then
		time = tonumber(self.m_Args[4][1])
	end
	local fadeIn = false
	if self.m_Args[5] and self.m_Args[5][1] then
		fadeIn = tonumber(self.m_Args[5][1]) == 1 and true or false
	end
	if CDialogueAniCmd.LogToggle then
		printc("SetDialogueAniEndSwitchBox", visible, path, doStart, time, fadeIn)
	end
	self.m_DilaogueUnit:SetDialogueAniEndSwitchBox(visible, path, doStart, time, fadeIn)
end

function CDialogueAniCmd.PlayerDoSkillMagic(self)
	local attack = tonumber(self.m_Args[1][1])
	local beAttack = tonumber(self.m_Args[2][1])
	local modeId = tonumber(self.m_Args[3][1])
	local skillIdx = tonumber(self.m_Args[4][1])
	if CDialogueAniCmd.LogToggle then
		printc("PlayerDoSkillMagic", attack, beAttack, modeId, skillIdx)
	end
	self.m_DilaogueUnit:PlayerDoSkillMagic(attack, beAttack, modeId, skillIdx)
end

function CDialogueAniCmd.AddMapEffect(self)
	local name = tostring(self.m_Args[1][1])
	local path = tostring(self.m_Args[2][1])
	local pos = Vector3.New(tonumber(self.m_Args[3][1]), tonumber(self.m_Args[3][2]), 0)
	local rotateY = tonumber(self.m_Args[4][1])
	local time = tonumber(self.m_Args[5][1])
	local isFront = tonumber(self.m_Args[6][1]) == 1 and true or false
	local isIgnoreStroy = false
	if self.m_Args[7] and self.m_Args[7][1] then
		isIgnoreStroy = tonumber(self.m_Args[7][1]) == 1 and true or false
	end
	if CDialogueAniCmd.LogToggle then
		printc("AddMapEffect", name, path, pos, rotateY, time, isFront, isIgnoreStroy)
	end
	self.m_DilaogueUnit:AddMapEffect(name, path, pos, rotateY, time, isFront, isIgnoreStroy)
end

function CDialogueAniCmd.AddCamerakEffect(self)
	local name = tostring(self.m_Args[1][1])
	local path = tostring(self.m_Args[2][1])
	local x = tonumber(self.m_Args[3][1])
	local y = tonumber(self.m_Args[4][1])
	local time = tonumber(self.m_Args[5][1])
	local isAdjust = tonumber(self.m_Args[6][1]) == 1 and true or false
	if CDialogueAniCmd.LogToggle then
		printc("AddCamerakEffect", name, path, x, y, time, isAdjust)
	end
	self.m_DilaogueUnit:AddCamerakEffect(name, path, x, y, time, isAdjust)
end

function CDialogueAniCmd.DoEffectMoveOption(self)
	local name = tostring(self.m_Args[1][1])
	local oPos = Vector3.New(tonumber(self.m_Args[2][1]), tonumber(self.m_Args[2][2]), 0)
	local tPos = Vector3.New(tonumber(self.m_Args[3][1]), tonumber(self.m_Args[3][2]), 0)
	local time = tonumber(self.m_Args[4][1])

	if CDialogueAniCmd.LogToggle then
		printc(" DoEffectMoveOption ", name , oPos, tPos, time)
	end
	self.m_DilaogueUnit:DoEffectMoveOption(name , oPos, tPos, time)
end

function CDialogueAniCmd.AddUIScreenEffect(self)
	local name = tostring(self.m_Args[1][1])
	local path = tostring(self.m_Args[2][1])
	local pivot = tonumber(self.m_Args[3][1])
	local time = tonumber(self.m_Args[4][1])
	local pos = Vector3.New(tonumber(self.m_Args[5][1]), tonumber(self.m_Args[5][2]), 0)
	local scale = Vector3.New(tonumber(self.m_Args[6][1]), tonumber(self.m_Args[6][2]), 0)
	local isTop = tonumber(self.m_Args[7][1]) == 1 and true or false
	local isAdjust = tonumber(self.m_Args[7][1]) == 1 and true or false

	if CDialogueAniCmd.LogToggle then
		printc(" AddUIScreenEffect ", name , path, pivot, time, pos, scale, isTop, isAdjust)
	end
	self.m_DilaogueUnit:AddUIScreenEffect(name , path, pivot, time, pos, scale, isTop, isAdjust)
end

function CDialogueAniCmd.PlayerLive2dDoAction(self)
	local action = tostring(self.m_Args[1][1])
	if CDialogueAniCmd.LogToggle then
		printc(" PlayerLive2dDoAction ", action)
	end
	self.m_DilaogueUnit:PlayerLive2dDoAction(action)
end

function CDialogueAniCmd.AddUIXingYiXingEffect(self)
	local path = tostring(self.m_Args[1][1])
	local visible = tonumber(self.m_Args[2][1]) == 1 and true or false
	if CDialogueAniCmd.LogToggle then
		printc(" AddUIXingYiXingEffect ", path, visible)
	end
	self.m_DilaogueUnit:AddUIXingYiXingEffect(path, visible)
end

function CDialogueAniCmd.HideSayWidget(self)	
	local hide = tonumber(self.m_Args[1][1]) == 1 and true or false
	if CDialogueAniCmd.LogToggle then
		printc(" HideSayWidget ", hide)
	end
	self.m_DilaogueUnit:HideSayWidget(hide)
end

function CDialogueAniCmd.PlayerShowSocialEmoji(self)
	local idx = tonumber(self.m_Args[1][1])
	local emoji = tostring(self.m_Args[2][1])
	local visible = tonumber(self.m_Args[3][1]) == 1 and true or false
	if CDialogueAniCmd.LogToggle then
		printc(" PlayerShowSocialEmoji ", idx , emoji, visible)
	end
	self.m_DilaogueUnit:PlayerShowSocialEmoji(idx, emoji, visible)
end

function CDialogueAniCmd.SetDialogueAniEndSwitchProcress(self)
	local id = tonumber(self.m_Args[1][1])
	if CDialogueAniCmd.LogToggle then
		printc(" SetDialogueAniEndSwitchProcress ", id)
	end
	self.m_DilaogueUnit:SetDialogueAniEndSwitchProcress(id)
end


---------------------------界面动画----------------------------
function CDialogueAniCmd.AddLayerAniPlayer(self)
	local name = tostring(self.m_Args[1][1])
	local model = tonumber(self.m_Args[2][1])
	local pos = Vector3.New(tonumber(self.m_Args[3][1]), tonumber(self.m_Args[3][2]), 0)
	local faceright = tonumber(self.m_Args[4][1]) == 1 and true or false
	local resourceright = tonumber(self.m_Args[5][1]) == 1 and true or false
	local idx = tonumber(self.m_Args[6][1])
	local addeffectmode = tostring(self.m_Args[7][1])
	local depth = 10
	if self.m_Args[8] and self.m_Args[8][1] then
		depth = tonumber(self.m_Args[8][1])
	end
	local scale = 1
	local yoffset = 0
	if self.m_Args[9] and self.m_Args[9][1] and self.m_Args[9][2] then
		scale = tonumber(self.m_Args[9][1])
		yoffset = tonumber(self.m_Args[9][2])
	end
	local info = {}
	local model_info = {}
	if model == 0 then
		model = g_AttrCtrl.model_info.shape
		name = g_AttrCtrl.name
		model_info.weapon = g_AttrCtrl.model_info.weapon
	end
	model_info.scale = 1
	model_info.shape = model
	local pos_info = {}
	pos_info.x = pos.x 
	pos_info.y = pos.y 
	info.rotateY = 0
	info.faceright = faceright
	info.resourceright = resourceright
	info.model_info = model_info
	info.pos_info = pos_info
	info.name = name
	info.addeffectmode = addeffectmode
	info.depth = depth
	info.scale = scale
	info.yoffset = yoffset
	if CDialogueAniCmd.LogToggle then
		printc(" AddLayerAniPlayer ", name , model, pos, faceright, resourceright, depth, scale, yoffset)
	end
	self.m_DilaogueUnit:AddLayerAniPlayer(idx, info)
end

function CDialogueAniCmd.SetLayerAniPlayerPos(self)
	local idx = tonumber(self.m_Args[1][1])
	local pos = Vector3.New(tonumber(self.m_Args[2][1]), tonumber(self.m_Args[2][2]), 0)
	local faceright = tonumber(self.m_Args[3][1]) == 1 and true or false
	if CDialogueAniCmd.LogToggle then
		printc(" SetLayerAniPlayerPos ", idx , pos, faceright)
	end
	self.m_DilaogueUnit:SetLayerAniPlayerPos(idx, pos, faceright)
end

function CDialogueAniCmd.SetLayerAniPlayerActive(self)
	local idx = tonumber(self.m_Args[1][1])
	local visible = tonumber(self.m_Args[2][1]) == 1 and true or false
	local isfade = false
	if self.m_Args[3] and self.m_Args[3][1] then
		isfade = tonumber(self.m_Args[3][1]) == 1 and true or false
	end	
	if CDialogueAniCmd.LogToggle then
		printc(" SetLayerAniPlayerActive ", idx , visible, isfade)
	end
	self.m_DilaogueUnit:SetLayerAniPlayerActive(idx, visible, isfade)
end

function CDialogueAniCmd.SetLayerAniPlayerFaceTo(self)
	local idx = tonumber(self.m_Args[1][1])
	local faceright = tonumber(self.m_Args[2][1]) == 1 and true or false
	if CDialogueAniCmd.LogToggle then
		printc(" SetLayerAniPlayerFaceTo ", idx , faceright)
	end
	self.m_DilaogueUnit:SetLayerAniPlayerFaceTo(idx, faceright)
end

function CDialogueAniCmd.LayerAniPlayerSay(self)
	local idx = tonumber(self.m_Args[1][1])
	local msg = tostring(self.m_Args[2][1])
	local time = 2
	if self.m_Args[3] and self.m_Args[3][1] then
		time = tonumber(self.m_Args[3][1])
	end
	if CDialogueAniCmd.LogToggle then
		printc(" LayerAniPlayerSay ", idx , msg, time)
	end
	self.m_DilaogueUnit:LayerAniPlayerSay(idx, msg, time)
end

function CDialogueAniCmd.LayerAniPlayerRunto(self)
	local idx = tonumber(self.m_Args[1][1])
	local pos = Vector3.New(tonumber(self.m_Args[2][1]), tonumber(self.m_Args[2][2]), 0)
	local faceright = tonumber(self.m_Args[3][1]) == 1 and true or false

	if CDialogueAniCmd.LogToggle then
		printc(" LayerAniPlayerRunto ", idx , pos, faceright)
	end
	self.m_DilaogueUnit:LayerAniPlayerRunto(idx, pos, faceright)
end

function CDialogueAniCmd.LayerAniPlayerDoAction(self)
	local idx = tonumber(self.m_Args[1][1])
	local action = tostring(self.m_Args[2][1])
	local config = tostring(self.m_Args[3][1])
	if CDialogueAniCmd.LogToggle then
		printc(" LayerAniPlayerDoAction ", idx , action, config)
	end
	self.m_DilaogueUnit:LayerAniPlayerDoAction(idx, action, config)
end

function CDialogueAniCmd.LayerAniPlayerShowSocialEmoji(self)
	local idx = tonumber(self.m_Args[1][1])
	local emoji = tostring(self.m_Args[2][1])
	local visible = tonumber(self.m_Args[3][1]) == 1 and true or false
	if CDialogueAniCmd.LogToggle then
		printc(" LayerAniPlayerShowSocialEmoji ", idx , emoji, visible)
	end
	self.m_DilaogueUnit:LayerAniPlayerShowSocialEmoji(idx, emoji, visible)
end

function CDialogueAniCmd.LayerAniCameraScale(self)
	local idx = tonumber(self.m_Args[1][1])
	local isscale = tonumber(self.m_Args[2][1]) == 1 and true or false
	local center = Vector3.New(tonumber(self.m_Args[3][1]), tonumber(self.m_Args[3][2]), 0)
	local time = tonumber(self.m_Args[4][1])
	local scale = tonumber(self.m_Args[5][1])
	if CDialogueAniCmd.LogToggle then
		printc(" LayerAniCameraScale ", isscale, center, time, scale)
	end
	self.m_DilaogueUnit:LayerAniCameraScale(isscale, center, time, scale)
end

function CDialogueAniCmd.SetLayerAniPlayerDepth(self)
	local idx = tonumber(self.m_Args[1][1])
	local depth = tonumber(self.m_Args[2][1])
	if CDialogueAniCmd.LogToggle then
		printc(" SetLayerAniPlayerDepth ", idx, depth)
	end
	self.m_DilaogueUnit:SetLayerAniPlayerDepth(idx, depth)	
end

return CDialogueAniCmd

