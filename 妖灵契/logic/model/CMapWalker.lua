local CMapWalker = class("CMapWalker", CWalker, CBindObjBase)

define.MapWalker = {
	Patrol_Idle_Time = 1,
	BindObjs = {
		team_leader = {hud = "CTeamHud", body="head", type="hud"},
		auto_find = {hud = "CAutoFindHud", body="head", type="hud"},
		fight = {hud = "CFightHud", body="head", type="hud"},
		patrol = {hud = "CPatrolHud", body="head", type="hud"},
		taskmark = {hud = "CTaskHud", body="head", type="hud"},
		social_emoji = {hud = "CSocialEmojiHud", body="head", type="hud"},
		anleipatrol = {hud = "CAnLeiPatrolHud", body="head", type="hud"},
		dialogtips = {hud = "CDialogTipsHud", body="head", type="hud"},
		sceneexam = {hud = "CSceneExamHud", body="head", type="hud"},
		guideTipsHud = {hud = "CGuideTipsHud", body="foot", type="hud"},
		touchtips = {path="Effect/Game/game_eff_1001/Prefabs/game_eff_1001.prefab",body="foot", type="effect", offset=Vector3.New(0, 0, 0),cached= true},
		monsteratkcity = {hud = "CMonsterAtkCityHud", body="head", type="hud"},
		blood = {hud = "CBloodHud", body="head", type="hud"},
		anleiTime = {hud = "CAnLeiTimeHud", body="head", type="hud"},
		taskChat = {hud = "CTaskChatHud", body="head", type="hud"},
		auto_dialytrain = {hud = "CDailyTrainHud", body="head", type="hud"},
	}
}

define.MapWalkerHudPos = {
	title = {type=1, child = { [1]={UIType="CSprite", Y = 30}, [2]={UIType="CHudLabel", Y = 14} },},

	auto_find = {type=2, child = {[1]={UIType="CSprite", Y = 20} },},
	patrol = {type=2, child = {[1]={UIType="CSprite", Y = 30} },},
	fight = {type=2, child = {[1]={UIType="CSprite", Y = 20} },},
	anleipatrol = {type=2, child = {[1]={UIType="CSprite", Y = 30}, [2]={UIType="CSprite", Y = 30} },},
	auto_dialytrain = {type=2, child = {[1]={UIType="CSprite", Y = 30} },},

	team_leader = {type=3, child = {[1]={UIType="CSprite", Y = 30} },},
}

CMapWalker.TARGET_TYPE = 
{	
	NONE = 1,
	DAILY_TRAIN = 2,
}

function CMapWalker.ctor(self)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/MapWalker.prefab")
	CWalker.ctor(self, obj)
	CBindObjBase.ctor(self, obj)
	self:Init2DWalker()
	self:SetParent(g_MapCtrl:GetWalkerRoot().m_Transform)
	self:SetBindData(define.MapWalker.BindObjs)
	self:SetMapID(g_MapCtrl:GetResID())
	local tConfigObjs = {
		size_obj = self,
		collider = self:GetComponent(classtype.CapsuleCollider),
		head_trans = self.m_HeadTrans,
		waist_trans = self.m_WaistTrans,
		foot_trans = self.m_FootTrans,
	}
	self.m_Actor:SetConfigObjs(tConfigObjs)
	self.m_TeamID = nil
	self.m_Name = ""
	self.m_ColorName = ""
	self.m_HeadTitleInfo = nil
	self.m_ArenaTitleInfo = nil
	self.m_FootTitleInfo = nil
	self.m_EmojiTimer = nil
	self.m_TitleHeadTrans = nil
	self.m_TaskNpcFollowers = {}--任务NPC跟随列表
	self.m_TargetType = CMapWalker.TARGET_TYPE.NONE
	self:SetNeedShadow(true)

	--hud
	self:AddInitHud("team_leader")
	self:AddInitHud("auto_find")
	self:AddInitHud("fight")
	self:AddInitHud("taskmark")
	self:AddInitHud("special_title")
	self:AddInitHud("anleipatrol")
	self:AddInitHud("dialogtips")
	self:AddInitHud("touchtips")
	self:AddInitHud("social_emoji")
	self:AddInitHud("sceneexam")
	self:AddInitHud("guideTipsHud")
	self:AddInitHud("monsteratkcity")
	self:AddInitHud("blood")
	self:AddInitHud("anleitime")
	self:AddInitHud("taskchat")
	self:AddInitHud("auto_dialytrain")

	if self.m_WalkEventHandler then
		self:SetHudLoadCb(function(oHud) 
				oHud:SetWalkEventHandler(self.m_WalkEventHandler)
			end)
	end
end

function CMapWalker.UpdateTitle(self, titleInfoList)
	self.m_HeadTitleInfo = nil
	self.m_ArenaTitleInfo = nil
	self.m_FootTitleInfo = nil
	local tempTitleData = nil
	for k,v in pairs(titleInfoList) do
		tempTitleData = data.titledata.DATA[v.tid]
		if tempTitleData and tempTitleData.isopen == 1 then
			if tempTitleData.show_type == define.Title.ShowType.HeadTitle then
				self.m_HeadTitleInfo = v
			elseif tempTitleData.show_type == define.Title.ShowType.ArenaGrade then
				self.m_ArenaTitleInfo = v
			elseif tempTitleData.show_type == define.Title.ShowType.FootTitle then
				self.m_FootTitleInfo = v
			end
		end
	end
	if self.m_HeadTitleInfo then
		self:SetTitleHud(self.m_HeadTitleInfo)		
	else
		self:DelBindObj("title")
	end
	self:UpdateName(self.m_Name, self.m_ColorName, self.m_Camp)
end

function CMapWalker.UpdateName(self, sName, colorName, iCamp)
	self.m_Name = sName
	self.m_ColorName = colorName or sName
	self.m_Camp = iCamp or 0
	if self.m_Camp ~= 0 and self.m_Camp ~= g_AttrCtrl.camp then
		self:SetNameHud(string.format("[FB2929]%s", sName), self.m_ArenaTitleInfo, self.m_FootTitleInfo)
	else
		self:SetNameHud(self.m_ColorName, self.m_ArenaTitleInfo, self.m_FootTitleInfo)
	end
	
end


function CMapWalker.RecycleShadow(self)
	if self.m_Shadow then
		g_ResCtrl:PutCloneInCache(self.m_Shadow:GetCacheKey(), self.m_Shadow.m_GameObject)
		self.m_Shadow = nil
	end
end

function CMapWalker.Destroy(self)
	self:ClearBindObjs()
	CWalker.Destroy(self)
end

function CMapWalker.IsCanWalk(self)
	return g_MapCtrl.m_CurMapObj and not self.m_IsFollowing
end

function CMapWalker.StopWalk(self)
	CWalker.StopWalk(self)
	self:DelBindObj("auto_find")
end

function CMapWalker.OnStopPath(self)
	CWalker.OnStopPath(self)
	self:DelBindObj("auto_find")
end

function CMapWalker.SetWarTag(self, iWarTag)
	local bFight = iWarTag == 1
	self.m_IsFight = bFight
	if bFight then
		self:AddBindObj("fight")
	else
		self:DelBindObj("fight")
	end
end

function CMapWalker.SetMonsterAtkCityTag(self, npcinfo)
	if npcinfo.inwar then
		self:DelBindObj("monsteratkcity")
		self:SetWarTag(1)
	else
		local trans = self:GetBindTrans("head")
		self:AddHud("monsteratkcity", CMonsterAtkCityHud, trans, function(oHud) oHud:SetNpcType(npcinfo.npctype) end, true)
		self:SetWarTag(0)
	end
end

function CMapWalker.SetBlood(self, percent)
	local trans = self:GetBindTrans("head")
	self:AddHud("blood", CBloodHud, trans, function(oHud) oHud:SetHP(percent) end, false)
end

function CMapWalker.SetAnLeiTag(self, iPatrol)
	local bPatrol = iPatrol == 1
	if bPatrol then
		self:AddBindObj("anleipatrol")
	else
		self:DelBindObj("anleipatrol")
	end
end

function CMapWalker.SetDialogTipsTag(self, isDialog)
	local bDialog = isDialog == 1
	if bDialog then
		self:AddBindObj("dialogtips")
	else
		self:DelBindObj("dialogtips")
	end
end

function CMapWalker.SetTouchTipsTag(self, isTouch)
	local bTouch = isTouch == 1
	if bTouch then
		self:AddBindObj("touchtips")
	else
		self:DelBindObj("touchtips")
	end	
end

function CMapWalker.SetTaskMark(self, spriteName)
	if spriteName then
		local npcid = self.m_NpcId 
		self:AddHud("taskmark", CTaskHud, self.m_HeadTrans, function(oHud)
				oHud:SetTaskMark(spriteName)
				if npcid then
					oHud:SetNpcId(npcid)
				end				
			end, false)
	else
		self:DelBindObj("taskmark")
	end
end

function CMapWalker.SetGuideTipsHud(self, b)
	if b then
		self:AddHud("guideTipsHud", CGuideTipsHud, self.m_FootTrans, function()	end, false)
	else
		self:DelBindObj("guideTipsHud")
	end
end

function CMapWalker.SetAnLeiTimeHud(self, b, s_time, e_time)
	if b then
		self:AddHud("anleitime", CAnLeiTimeHud, self.m_HeadTrans, 
			function(oHud)
				oHud:SetTime(s_time, e_time, self.m_NpcId)
			end
		, false)
	else
		self:DelBindObj("anleitime")
	end
end

function CMapWalker.SetSocialEmoji(self, type)
	if self.m_EmojiTimer then
		Utils.DelTimer(self.m_EmojiTimer)
		self.m_EmojiTimer = nil
	end
	if type then
		self:AddHud("social_emoji", CSocialEmojiHud, self.m_HeadTrans, function(oHud)
				oHud:SetEmoji(type)
			end, false)
		self.m_EmojiTimer = Utils.AddTimer(callback(self, "DelBindObj", "social_emoji") , 0, 3)
	else
		self:DelBindObj("social_emoji")
	end
end

function CMapWalker.SetSpecialTitleHud(self, title, spriteName)
	local sType = "special_title"
	if title or spriteName then
		self:AddHud("special_title", CSpecialTitleHud, self.m_HeadTrans, function(oHud)
			oHud:SetSpecialTitle(title, spriteName)
		end, false)
	else

		self:HideEffect(sType)
	end 
end

function CMapWalker.SetTaskChatHud(self, b, msg)
	if b and msg then
		self:AddHud("taskchat", CTaskChatHud, self.m_HeadTrans, function(oHud)
			oHud:SetMsg(msg)
		end, false)
	else
		self:DelBindObj("taskchat")
	end 
end

function CMapWalker.SetDailyTrainHud(self, b)
	if b then
		self:AddHud("auto_dialytrain", CDailyTrainHud, self.m_HeadTrans, function(oHud)
		end, false)
	else
		self:DelBindObj("auto_dialytrain")
	end 
end

function CMapWalker.SetSceneExamAmount(self, iAmount, sReward, bIsSelf)
	if self.m_SceneExamTimer then
		Utils.DelTimer(self.m_SceneExamTimer)
		self.m_SceneExamTimer = nil
	end
	
	if iAmount and iAmount > 0 then
		self.m_SceneExamTimer = Utils.AddTimer(function ()
			if not Utils.IsNil(self) then
				self:DelBindObj("sceneexam")
			end
		end, 0, 3)
		self:AddHud("sceneexam", CSceneExamHud, self.m_HeadTrans, function(oHud)
			oHud:SetAmount(iAmount, sReward, bIsSelf)
		end, false)
	else
		self:DelBindObj("sceneexam")
	end
end

function CMapWalker.SetStateTag(self, iState)
	if not iState then
		return
	end
	for i = 0, 31 do
		local a = MathBit.rShiftOp(iState, i)
		local b = MathBit.andOp(a, 1)
		if b == 1 then
			self:CreateStateObj(i+1)
		else
			self:ClearStateObj(i+1)
		end
	end
end

function CMapWalker.CreateStateObj(self, idx)
	self.m_StateObjs = self.m_StateObjs or {}
	local oData = data.aoistatedata.DATA[idx]
	local obj = nil
	self:ClearStateObj(idx)
	if oData.showtype == "warbuff" then
		local ibuff = oData.args[1]
		obj = CWarBuff.New(ibuff, self)
		obj:SetLevel(1)
	end
	self.m_StateObjs[idx] = obj
end

function CMapWalker.ClearStateObj(self, idx)
	if self.m_StateObjs and self.m_StateObjs[idx] then
		self.m_StateObjs[idx]:Clear()
		self.m_StateObjs[idx] = nil
	end
end

function CMapWalker.FaceToHero(self)
	local oHero = g_MapCtrl:GetHero()
	if oHero and not Utils.IsNil(self) then
		local dir = (oHero:GetPos() - self:GetPos()):Normalize()
		if dir.x ~= 0 or dir.y ~= 0 then
			local newRotation = Quaternion.LookRotation(Vector3.New(dir.x, 0, dir.y))
			DOTween.DOLocalRotate(self.m_Actor.m_Transform, newRotation.eulerAngles, 0.2)
		end
	end
end

function CMapWalker.FaceToPos(self, pos)
	if pos and not Utils.IsNil(self) then
		local dir = pos - self:GetPos()
		if dir.x ~= 0 or dir.y ~= 0 then
			local newRotation = Quaternion.LookRotation(Vector3.New(dir.x, 0, dir.y))
			DOTween.DOLocalRotate(self.m_Actor.m_Transform, newRotation.eulerAngles, 0.2)
		end
	end
end

--动态物体通用点击处理
function CMapWalker.OnTouch(self, eid)
	g_ActivityCtrl:ClickTargetCheck(CActivityCtrl.DCClickEnum.Actor, eid, false, {targetType = self.m_TargetType})
end

--NPC说话
function CMapWalker.SendMessage(self, msg)
	local oMsg = CChatMsg.New(1,  {channel = 4, text = msg})
	self:ChatMsg(oMsg)
end

--NPC执行对话动画
function CMapWalker.DialogNpcDoAnimation(self, cmd)
	local key = cmd.func
	if key == "GNpcSay" then
		if #cmd.args > 0 then
			local random = Utils.RandomInt(1, 100)		
			local k = 0
			for i = 1, #cmd.args do
				if random <= cmd.args[i].rare then
					k = i
					self:SendMessage(cmd.args[i].str)
					break
				end 
			end	
			if cmd.action[k] and cmd.action[k] ~= "none" then
				self:CrossFade(cmd.action[k], 0.1, 0, 1, objcall(self, function(obj)
						obj:CrossFade("idleCity", 0.1)
					end))
			end
			if cmd.isFacetoHero == 1 then
				self:FaceToHero()
				Utils.AddTimer(objcall(self, function(obj) 
						if obj.ReSetFace then	
							local isReset = true
							local oView = CDialogueMainView:GetView()
							if oView and obj.classname == "CNpc" then
								if obj.m_NpcAoi and oView.m_DialogData and obj.m_NpcAoi.npcid == oView.m_DialogData.npcid then
									isReset = false
								end
							end
							if isReset then
								obj:ReSetFace()
							end
						end
					end), 0, 3)
			end
		end 
	elseif key == "faceto" then
		if #cmd >= 1 then
			local rotateY = tonumber(cmd[1]) 
			if rotateY then
				self.m_Actor:SetLocalRotation(Quaternion.Euler(0, rotateY, 0))
			end			
		end
	elseif key == "runto" then
		if #cmd >= 2 then
			local x = tonumber(cmd[1]) 
			local y = tonumber(cmd[2]) 
			self:WalkTo(x, y)
		end
	elseif key == "visible" then	
		if #cmd == 1 then
			local b = tonumber(cmd[1])
			if b == 1 then
				self:SetActive(true)
			else
				self:SetActive(false)
			end
		end
	elseif key == "pos" then			
		if #cmd == 2 then
			local x = tonumber(cmd[1])
			local y = tonumber(cmd[2])
			self:SetPos(Vector3.New(x, y, 0))

		end

	elseif key == "action" then
		if #cmd >= 3 then
			local action1 = cmd[1]
			local action2 = cmd[2]
			local isLoop = tonumber(cmd[3]) 
			if action2 == "none" then
				action2 = "idleCity"
			end
			if isLoop == 1 then
				self:CrossFadeLoop(action1, 0.1, 0, 1, true)
			else
				self:CrossFade(action1, 0.1, 0, 1, objcall(self, function(obj)
						obj:CrossFade(action2, 0.1)
					end))
			end
		end
	elseif key == "voice" then
		if #cmd >= 1 then
			local voice = tostring(cmd[1])
			g_AudioCtrl:PlaySound(voice) 
		end
	end
end

function CMapWalker.SyncBlockInfo(self, eid, block, func)
	if block.model_info and self.m_Pid and self.m_Pid ~= g_AttrCtrl.pid then
		self:ChangeShape(block.model_info.shape, block.model_info, func)
	end

	if block.title_info ~= nil then
		self:UpdateTitle(block.title_info)
	end

	if block.name ~= nil then
		self:UpdateName(block.name, string.format("[00ff00]%s", block.name), block.camp)
	end

	if block.war_tag then
		self:SetWarTag(block.war_tag)
	end
	
	self:SetStateTag(block.state)
	
	if block.trapmine then
		self:SetAnLeiTag(block.trapmine)
	end
	if block.followers then
		g_MapCtrl:DelAllFollowWalker(eid)
		self.m_FollowersList = block.followers
		if block.followers then
			for k,v in pairs(block.followers) do
				local objName = string.format("e%d-p%d-%s-%s",eid,self.m_Pid,block.name,v.name)
				g_MapCtrl:AddFollowPartner(v, eid, objName, self:GetLocalPos())
			end
		end
	end
	if block.ownerid and block.ownerid > 0 and block.orgid and block.orgid > 0 and block.orgflag and block.owner then
		self:SetTerraWarHud(block.orgid, block.orgflag, block.owner)
	else
		self:DelTerraWarHud()
	end
	if self.DoOtherSet then
		self:DoOtherSet()
	end
	if block.social_display then
		-- table.print(block.social_display, "block.social_display------>")
		g_SocialityCtrl:Play(block.social_display, self)
	end
end

function CMapWalker.AddTaskNpcFollower(self, follower)	
	for i = 1, #self.m_TaskNpcFollowers do
		local oFollower = self.m_TaskNpcFollowers[i]
		if oFollower.m_Name == follower.m_Name and oFollower.m_ClientNpc.npctype and follower.m_ClientNpc.npctype then			
			return
		end
	end
	table.insert(self.m_TaskNpcFollowers, follower)
	follower.m_FollowTargetPid = self.m_Pid
	self:UpdateTaskNpcFollowers()
end

function CMapWalker.DelAllTaskNpcFollowers(self, follower)
	self.m_TaskNpcFollowers = {}
end

function CMapWalker.DelTaskNpcFollower(self, follower)
	for i = 1, #self.m_TaskNpcFollowers do
		local oFollower = self.m_TaskNpcFollowers[i]	
		if oFollower.m_Name == follower.m_Name and oFollower.m_ClientNpc.npctype and follower.m_ClientNpc.npctype then
			follower.m_FollowTargetPid = nil
			table.remove(self.m_TaskNpcFollowers, i)
			self:UpdateTaskNpcFollowers()
			break
		end
	end
end

function CMapWalker.UpdateTaskNpcFollowers(self)
	if not next(self.m_TaskNpcFollowers) then
		return
	end	
	local t = {}
	for k, v in ipairs(self.m_TaskNpcFollowers) do
		if not Utils.IsNil(v) then
			table.insert(t, v)
		end
	end
	self.m_TaskNpcFollowers = t
	local follower = self
	for i = 1, #self.m_TaskNpcFollowers do
		local oFollower = self.m_TaskNpcFollowers[i]		
		oFollower:ChangeFollow(follower)
		follower = oFollower
	end
end

function CMapWalker.SetRandomTalkData(self, sList, iMinTime, iMaxTime)
	if Utils.IsNil(self) then
		return false
	end
	if self.m_RandomTalkTimer == nil then
		self.m_RandomTalkTimer = Utils.AddTimer(callback(self, "RandomTalk", sList, iMinTime, iMaxTime), 0, math.random(iMinTime, iMaxTime))
	end
end

function CMapWalker.RandomTalk(self, sList, iMinTime, iMaxTime)
	self:SendMessage(sList[Utils.RandomInt(1, #sList)])
	self.m_RandomTalkTimer = nil
	self:SetRandomTalkData(sList, iMinTime, iMaxTime)
end

function CMapWalker.IsNeedRefreshPos(self, sType)
	return define.MapWalkerHudPos[sType] ~= nil
end

function CMapWalker.RefreshHudPos(self)
	local typeList = {
					  [1]={type=1, active=false},
					  [2]={type=2, active=false},
					  [3]={type=3, active=false},
					 }
	for k, v in pairs(self.m_Huds) do
		local t = define.MapWalkerHudPos[k]
		if t and v.obj and v.obj:GetOwner() == self then
			typeList[t.type].active = true
		end
	end
	local t = {}
	local pos = 1
	for i, v in ipairs(typeList) do
		if v.active == true then
			t[v.type] = {pos=pos}
			pos = pos + 1
		end
	end
	if not next(t) then
		return
	end
	for k,v in pairs(self.m_Huds) do
		local temp = define.MapWalkerHudPos[k]
		if temp and t[temp.type] then			
			local oHud = v.obj
			if oHud then
				for _i, _v in ipairs(temp.child) do
					local oUI = nil
					if _v.UIType == "CSprite" then
						oUI = oHud:NewUI(_i, CSprite)
					elseif _v.UIType == "CHudLabel" then
						oUI = oHud:NewUI(_i, CHudLabel)
					end
					if oUI then
						local p = oUI:GetLocalPos()
						local pos = Vector3.New(p.x,  55 * (t[temp.type].pos - 1) + _v.Y, p.z)						
						oUI:SetLocalPos(pos)
					end
				end
			end
		end
	end
end


return CMapWalker