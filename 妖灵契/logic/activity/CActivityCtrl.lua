local CActivityCtrl = class("CActivityCtrl", CCtrlBase)

CActivityCtrl.DAILYCULTIVATE_TEAM_CHECK_TIME = 5
CActivityCtrl.DAILYCULTIVATE_TEAM_CHECK_TIME_MAX = 60

--每日历练点击目标的类型
CActivityCtrl.DCClickEnum = 
{
	Task = 1,
	Actor = 2,	
	Map = 3,
}

define.Activity = {
	Event = {
		WorldBossHP = 101,
		WolrdBossLeftTime = 102, 
		WolrdBossScene = 103,
		WorldBossRank = 104,
		WolrdBossShape = 105,
		QAState = 201,
		QAAdd = 202,
		QAResult = 203,
		SAReward = 204,
		SARefresh = 205,

		--每日历练		
		DCAddTeam = 301,
		DCLeaveTeam = 302,  
		DCUpdateTeam = 303,
		DCRefreshTask = 304,

		--每日训练
		DTUpdate = 401,
		DTUpdateDouble = 402,
	},
}
--简单活动这个Ctrl管理，复杂的单独写Ctrl
function CActivityCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CActivityCtrl.ResetCtrl(self)
	self.m_WorldBossInfo = {shape = nil, hp=0, hp_max=0, percent=0, myrank=nil, rank=nil}
	self.m_WolrdBossLeftTime = 0
	self.m_InWorldBossFB = nil


	self.m_QuesionAnswerCtrl = self:CreateQuestoinAnswerCtrl()
	self.m_PEFbCtrl = self:CreatePEFbCtrl()
	self.m_YJFbCtrl = self:CreateYJFbCtrl()

--每日历练相关开始
	self.m_TeamId = nil
	self.m_LeaderId = nil
	self.m_MemberList = nil
	self.m_TargetInfo = nil
	self.m_IsOpenDCView = true
	self.m_LastClickTarget = { clickType = 0, clickTarget = 0}
	self.m_AutoConfig = true
	self.m_TeamPos = nil
	self.m_AutoCheckTeamActiveTimer = nil
	self.m_TeamUnActiveElapseTimer = 0
	self.m_AutoEnter = false
	self.m_AutoEnterTimer = nil
--每日历练相关结束
	self.m_OpenData = {}

--明雷玩法相关开始
	self.m_MLNpcList = {}	

--明雷玩法相关结束

--每日训练相关开始 DailyTrain
	self.m_DTRewardTime = 0
	self.m_DTAutoConfig = true
	self.m_DTDoubleFlag = 1
	self.m_DTRewardList = {}
	self.m_DTClientNpc = {}
	self.m_DTStatus = 0 --每日训练状态   0 表示不在自动训练， 1表示在自动训练
	self.m_DTIsLeader = nil
--每日训练相关结束
end

function CActivityCtrl.SetOpen(self, id, bOpen)
	self.m_OpenData[id] = bOpen
end

function CActivityCtrl.IsOpen(self, id)
	return self.m_OpenData[id] == true
end

function CActivityCtrl.RefreshBossHP(self, hp, hp_max)
	hp = math.max(0, hp)
	self.m_WorldBossInfo["hp"] = hp
	self.m_WorldBossInfo["hp_max"] = hp_max
	self.m_WorldBossInfo["percent"] = hp/hp_max
	self:DelayEvent(define.Activity.Event.WorldBossHP)
end

function CActivityCtrl.SetWorldBossBigboss(self, bigboss)
	self.m_WorldBossInfo["bigboss"] = bigboss
end

function CActivityCtrl.SetWorldBossShape(self, shape)
	self.m_WorldBossInfo["shape"] = shape
	self:DelayEvent(define.Activity.Event.WolrdBossShape)
end

function CActivityCtrl.SetWorldBossRank(self, lRank, dMyRank, dead_cost)
	self.m_WorldBossInfo["rank"] = lRank
	self.m_WorldBossInfo["myrank"] = dMyRank
	self.m_WorldBossInfo["dead_cost"] = dead_cost
	self:DelayEvent(define.Activity.Event.WorldBossRank)
end

function CActivityCtrl.GetWolrdBossInfo(self)
	return self.m_WorldBossInfo
end

function CActivityCtrl.SetInWorldBossFB(self, bIn)
	self.m_InWorldBossFB = bIn
	self:AutoWorldRankTimer(bIn)
	self:DelayEvent(define.Activity.Event.WolrdBossScene)
end

function CActivityCtrl.AutoWorldRankTimer(self, bOpen)
	if bOpen then
		local function update(self)
			if not g_WarCtrl:IsWar() then
				nethuodong.C2GSWorldBoossRank()
			end
			return true
		end
		if not self.m_worldBossRankTimer then
			self.m_worldBossRankTimer = Utils.AddTimer(update, 60, 0)
		end
		nethuodong.C2GSWorldBoossRank()
	else
		if self.m_worldBossRankTimer then
			Utils.DelTimer(self.m_worldBossRankTimer)
			self.m_worldBossRankTimer = nil
		end
	end
end

function CActivityCtrl.InWorldBossFB(self)
	return self.m_InWorldBossFB 
end

function CActivityCtrl.OnWolrdBossLeftTime(self, ileft)
	self.m_WolrdBossLeftTime = ileft + g_TimeCtrl:GetTimeS()
	self:OnEvent(define.Activity.Event.WolrdBossLeftTime)
end

function CActivityCtrl.GetWolrdBossLeftTimeText(self)
	local leftTime = self.m_WolrdBossLeftTime - g_TimeCtrl:GetTimeS()
	if leftTime <= 0 then
		return nil
	end
	local hour = math.modf(leftTime / 3600)
	local min = math.modf((leftTime % 3600) / 60)
	local sec = leftTime % 60
	return string.format("%02d:%02d:%02d", hour, min, sec)
end

function CActivityCtrl.FindWolrdBoss(self)
	local function autowalk()
		if g_MapCtrl:GetMapID() ~= mapId or g_MapCtrl.m_MapLoding or math.floor(mapId/100) ~= g_MapCtrl.m_ResID then
			return true
		else
			g_MapTouchCtrl:WalkToPos(pos, npcid, define.Walker.Npc_Talk_Distance + g_DialogueCtrl:GetTalkDistanceOffset(), function ()
				local npcid = g_MapCtrl:GetNpcIdByNpcType(nd.id)
				local oNpc = g_MapCtrl:GetNpc(npcid)
				if oNpc and oNpc.Trigger then
					oNpc:Trigger()
				end
			end)
		end
	end
	
	local curMapID = g_MapCtrl:GetMapID()
	if g_MapCtrl:GetMapID() ~= mapId then
		local oHero = g_MapCtrl:GetHero()
		netscene.C2GSClickWorldMap(g_MapCtrl:GetSceneID(), oHero.m_Eid, mapId)
		if self.m_AutoWalkTimer then
			Utils.DelTimer(self.m_AutoWalkTimer)
		end
		self.m_AutoWalkTimer = Utils.AddTimer(autowalk, 0, 0)
	else
		autowalk()
	end
end

function CActivityCtrl.WorldBossDeathAnim(self, npc_type)
	local npc
	for k,v in pairs(g_MapCtrl.m_Npcs) do
		if v.m_NpcAoi.npctype == npc_type then
			npc = v
			break
		end
	end
	if npc then
		npc.m_Actor:Play("die")
	end
end

function CActivityCtrl.CreateQuestoinAnswerCtrl(self)
	if self.m_QuesionAnswerCtrl then
		self.m_QuesionAnswerCtrl:ResetCtrl()
	else
		self.m_QuesionAnswerCtrl = CQuestionAnswerCtrl.New()
	end
	return self.m_QuesionAnswerCtrl
end

function CActivityCtrl.GetQuesionAnswerCtrl(self)
	return self.m_QuesionAnswerCtrl
end

function CActivityCtrl.CreatePEFbCtrl(self)
	if self.m_PEFbCtrl then
		self.m_PEFbCtrl:ResetCtrl()
	else
		self.m_PEFbCtrl = CPEFubenCtrl.New()
	end
	return self.m_PEFbCtrl
end

function CActivityCtrl.GetPEFbCtrl(self)
	if not self.m_PEFbCtrl then
		self.m_PEFbCtrl = CPEFubenCtrl.New()
	end
	return self.m_PEFbCtrl
end

function CActivityCtrl.CreateYJFbCtrl(self)
	if self.m_YJFbCtrl then
		self.m_YJFbCtrl:ResetCtrl()
	else
		self.m_YJFbCtrl = CYJFubenCtrl.New()
	end
	return self.m_YJFbCtrl
end

function CActivityCtrl.GetYJFbCtrl(self)
	if not self.m_YJFbCtrl then
		self.m_YJFbCtrl = CYJFubenCtrl.New()
	end
	return self.m_YJFbCtrl
end

--------------------------------每日修行相关开始-------------------------------
function CActivityCtrl.DailyCultivateAddTeam(self, iTeamID, iLeader, lMember, tTargetInfo)
	self.m_TeamId = iTeamID or 0
	self.m_LeaderId = iLeader or 0
	self.m_MemberList = lMember or {}
	self.m_MemberDic = {}
	if lMember ~= nil then
		for k,v in pairs(lMember) do
			self.m_MemberDic[v.pid] = v
		end
	end
	self.m_TargetInfo = tTargetInfo or {}
	self.m_IsOpenDCView = true
	--开始每日修行时，开打每日修行界面
	--CDailyCultivateView:ShowView()
	self:DailyCultivateSettingReset()
	self:OnEvent(define.Activity.Event.DCAddTeam)
end

function CActivityCtrl.DCIsLeader(self, pid)
	pid = pid or g_AttrCtrl.pid
	return pid == self.m_LeaderId
end

--每日修行，重置设置
function CActivityCtrl.DailyCultivateSettingReset(self)
	--设置锁定出战阵容
	g_WarCtrl:SetLockPreparePartner(define.War.Type.Lilian, self.m_AutoConfig)
	--重新开始检测自动修行状态
	self:StartCheckTeamActive()
end

function CActivityCtrl.DailyCultivateDelTeam(self)
	self.m_TeamId = nil
	self.m_LeaderId = nil
	self.m_MemberList = nil
	self.m_TargetInfo = nil
	self.m_LastClickTarget.clickType = 0
	self.m_LastClickTarget.clickTarget = 0	
	self:OnEvent(define.Activity.Event.DCLeaveTeam)
end

function CActivityCtrl.DailyCultivateAddTeamMember(self, info)
	local mem_info = table.copy(info)
	table.insert(self.m_MemberList, mem_info)
	self.m_MemberDic[mem_info.pid] = mem_info
	self:OnEvent(define.Activity.Event.DCUpdateTeam)
end

function CActivityCtrl.DailyCultivateUpdateMemberAttr(self, pid, status_info)
	if self.m_MemberDic[pid] and self.m_MemberDic[pid].status_info then
		self.m_MemberDic[pid].status_info = table.copy(self.m_MemberDic[pid].status_info)
		self.m_MemberDic[pid].status_info = status_info
	end	
	self:OnEvent(define.Activity.Event.DCUpdateTeam)
end

function CActivityCtrl.DailyCultivateRefreshTeamStatus(self, team_status, posinfo)
	if self.m_MemberList and next(self.m_MemberList) and posinfo and next(posinfo) then
		local t = {}
		for i = 1, #posinfo do
			local pid = posinfo[i].pid 
			for k = 1, #self.m_MemberList do
				if pid == self.m_MemberList[k].pid then
					table.insert(t, self.m_MemberList[k])
					break
				end
			end
		end
		self.m_MemberList = t
		self:OnEvent(define.Activity.Event.DCUpdateTeam)
	end
end

function CActivityCtrl.GetDailyCultivateMemberList(self)
	return self.m_MemberList
end

function CActivityCtrl.IsDailyCultivating(self)
	return self.m_TeamId ~= nil
end

function CActivityCtrl.DailyCultivateLeavelTeam(self)
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSLeaveLiLianTeam"]) then
		netteam.C2GSLeaveLiLianTeam()
	end
end

function CActivityCtrl.ShowLilianWarResult(self, oCmd)
	CWarResultView:ShowView(function(oView)
		oView:SetWarID(oCmd.war_id)
		oView:SetWin(oCmd.win)
		oView:SetDelayCloseView()
	end)
end

function CActivityCtrl.ShowDailyTrainWarResult(self, oCmd)
	CWarResultView:ShowView(function(oView)
		oView:SetWarID(oCmd.war_id)
		oView:SetWin(oCmd.win)
		oView:SetDelayCloseView()
	end)
end

--返回true则会中断此次操作
function CActivityCtrl.ClickTargetCheck(self, clickType, clickTarget, ignore, config)
	local config = config or {}
	local b = false
	--每日修行
	if self:IsDailyCultivating() then
		if self.m_LastClickTarget.clickType == clickType and self.m_LastClickTarget.clickTarget == clickTarget and clickType ~= CActivityCtrl.DCClickEnum.Map then			
			self.DailyCultivateLeavelTeam()		
		else
			b = true
			if clickType == CActivityCtrl.DCClickEnum.MAP then
				self.m_LastClickTarget.clickType = 0
				self.m_LastClickTarget.clickTarget = 0
				g_NotifyCtrl:FloatMsg("请先退出修行任务")
			else
				self.m_LastClickTarget.clickType = clickType
				self.m_LastClickTarget.clickTarget = clickTarget
				g_NotifyCtrl:FloatMsg("请先退出修行任务")
			end
		end
	elseif g_ConvoyCtrl:IsConvoying() then
		if not ignore then
			printtrace()
			g_NotifyCtrl:FloatMsg(data.huodongblockdata.DATA.convoy.tips)
			b = true
		end
	end

	--检测是否需要停止每日训练
	self:DailyTrainClickCheck(clickType, config)
	return b
end

function CActivityCtrl.StartCheckTeamActive(self)
	local isWar = g_WarCtrl:IsWar()
	local isCultivating = self:IsDailyCultivating()
	local isLeader = self:DCIsLeader()
	if isCultivating and isLeader then
		if not isWar then
			local pos = {}
			if g_MapCtrl:GetHero() then
				pos = g_MapCtrl:GetHero():GetPos()
			end
			local x = pos.x or 0
			local y = pos.y or 0
			x = math.floor(x * 100000)
			y = math.floor(y * 100000)
			local curPos = Vector2.New(x, y)
			if curPos ~= self.m_TeamPos then
				self.m_TeamPos = curPos				
				self.m_TeamUnActiveElapseTimer = 0							
			else
				self.m_TeamUnActiveElapseTimer = self.m_TeamUnActiveElapseTimer + CActivityCtrl.DAILYCULTIVATE_TEAM_CHECK_TIME

				if CActivityCtrl.DAILYCULTIVATE_TEAM_CHECK_TIME_MAX <= self.m_TeamUnActiveElapseTimer then
					self.m_TeamUnActiveElapseTimer = 0
					self.m_TeamPos = nil
					self:DailyCultivateLeavelTeam()				
				end
			end

			--5秒检测1次
			if self.m_AutoCheckTeamActiveTimer ~= nil then
				Utils.DelTimer(self.m_AutoCheckTeamActiveTimer)
				self.m_AutoCheckTeamActiveTimer = nil
			end		
			self.m_AutoCheckTeamActiveTimer = Utils.AddTimer(callback(self, "StartCheckTeamActive"), 0, CActivityCtrl.DAILYCULTIVATE_TEAM_CHECK_TIME)				

		else
			if self.m_AutoCheckTeamActiveTimer ~= nil then
				Utils.DelTimer(self.m_AutoCheckTeamActiveTimer)
				self.m_AutoCheckTeamActiveTimer = nil
			end	
		end

	else
		if self.m_AutoCheckTeamActiveTimer ~= nil then
			Utils.DelTimer(self.m_AutoCheckTeamActiveTimer)
			self.m_AutoCheckTeamActiveTimer = nil
		end	
	end
end

--每日修行战斗和非战斗切换处理
function CActivityCtrl.DCSwitchEnv(self, bWar)
	-- if bWar == false then
	-- 	if self:IsDailyCultivating() then
	-- 		self:DailyCultivateSettingReset()			
	-- 		if self.m_IsOpenDCView then
	-- 			CDailyCultivateView:ShowView()
	-- 		end			
	-- 	end
	-- end
end

function CActivityCtrl.DCResetCtrl(self)
	self:DailyCultivateDelTeam()
end

function CActivityCtrl.AutoEnter(self)
	self.m_AutoEnter = not self.m_AutoEnter
end

--------------------------------每日修行相关结束-------------------------------


--------------------------------明雷玩法相关开始-------------------------------

function CActivityCtrl.CtrlGS2CShowBuyTimeWnd(self, leftTime, perCost, maxTime)
	leftTime = leftTime or 0
	if leftTime > 0 then
		CMingLeiTipsView:ShowView(function(oView)
			oView:SetContent(leftTime, perCost, maxTime)
		end)
	else
		g_NotifyCtrl:FloatMsg("今日购买次数已达到上限，请明天再来尝试。")
	end
end

function CActivityCtrl.CtrlC2GSBuyMingleiTimes(self, buyTime)
	nethuodong.C2GSBuyMingleiTimes(buyTime)
end

--明雷玩法请求组队
function CActivityCtrl.CtrlGS2CGetMingleiTeam(self)
	g_TeamCtrl:QuickBuildTeamByTarget(CTeamCtrl.TARGET_MING_LEI)
end

function CActivityCtrl.CtrlGS2COpenMingleiUI(self, config)
	CMingLeiReadyFightView:ShowView(function (oView)
 		oView:SetContent(config)
	end)
end

--随机切换到有明雷的地图
function CActivityCtrl.GoToMingLeiMap(self)
	local b = false
	local groupid = tonumber(data.globaldata.GLOBAL.minglei_scene_group.value) 
	local mapTable = data.mapdata.SCENE_GROUP[groupid].maplist
	if mapTable and #mapTable > 0 then
		local t = {}
		local curMapID = g_MapCtrl:GetMapID()
		for i = 1, #mapTable do 
			if curMapID ~= mapTable[i] then
				table.insert(t, mapTable[i])
			end
		end
		if #t > 0 then
			local mapId = table.randomvalue(t)
			if mapId then								
				local oHero = g_MapCtrl:GetHero()
				netscene.C2GSClickWorldMap(g_MapCtrl:GetSceneID(), oHero.m_Eid, mapId)				
				b = true
			end
		end
	end
	return b
end

--明雷本地创建引导怪物
function CActivityCtrl.MingLeiCreateGuideNpc(self)
	self.m_MLNpcList = {}
	local npc = {}
	local guideData = data.mingleidata.GUIDE_NPC[64998]
	npc.npctype = guideData.id
	npc.npcid = 0
	npc.name = "[FF7D00]"..guideData.name
	npc.title = guideData.title
	npc.map_id = guideData.sceneId
--	npc.createtime = g_TimeCtrl.GetTimeS()
	npc.flag = 3
	npc.sceneid = guideData.sceneId
	local pos_info = {}
	pos_info.x = guideData.x
	pos_info.y = guideData.y
	pos_info.z = guideData.z
	npc.pos_info = pos_info
	local model_info = {}
	model_info.shape = guideData.modelId 
	model_info.scale = guideData.scale
	npc.model_info = model_info

	if npc.pos_info and npc.pos_info.x < 1000 then
		npc.pos_info.x = npc.pos_info.x * 1000
		npc.pos_info.y = npc.pos_info.y * 1000
	end		
	table.insert(self.m_MLNpcList, npc) 	
	self:RefreshMingLeiNpc()
end

--明雷本地删除引导怪物
function CActivityCtrl.MingLeiDelGuideNpc(self)
	self.m_MLNpcList = {}
	g_MapCtrl:DelDynamicNpc(0)
end

--明雷本地删除引导怪物
function CActivityCtrl.OpenReadyFightGuideMingLei(self)
	local dialogData = data.mingleidata.GUIDE_DIALOG[1]
	local guideData = data.mingleidata.GUIDE_NPC[64998]
	local d = {}
	local dialog = {}
	table.insert(dialog, dialogData)
	d.dialog = dialog 
	d.dialog_id = dialogData.dialog_id
	d.npc_id = 0
	d.npc_name = guideData.name
	d.shape = guideData.modelId
	d.isMLGuide = true
	g_DialogueCtrl:GS2CDialog(d)
end

function CActivityCtrl.WalkToMingLeiGuideNpc(self)
	local npc
	for k,v in pairs(self.m_MLNpcList) do
		npc = v 
		break
	end
	if npc then
		local temp = {}
		table.insert(temp, npc)
		local taskData = 
		{
			acceptnpc = npc.npctype,
			clientnpc = temp,
		}
		local oTask = CTask.NewByData(taskData)
		g_TaskCtrl:ClickTaskLogic(oTask)			
	end
end

function CActivityCtrl.RefreshMingLeiNpc(self)
	for _,v in ipairs(self.m_MLNpcList) do
		if v.map_id == g_MapCtrl:GetMapID() then
			g_MapCtrl:AddDynamicNpc(v)
		end		
	end
end

function CActivityCtrl.MingLeiC2GSCallback(self, opIdx)
	if opIdx == 1 then
		if g_TeamCtrl:IsJoinTeam() then 
   			g_NotifyCtrl:FloatMsg("本次指引仅可单人进行。")
  		else
  			nethuodong.C2GSGuideMingleiWar()
  			self:MingLeiDelGuideNpc()
			local guideData = data.guidedata.Tips_MingLei
			if guideData and guideData.guide_list then
				for i, v in ipairs(guideData.guide_list) do
					g_GuideCtrl:ReqTipsGuideFinish(v.necessary_ui, v.open_id, true)
				end
			end
  		end
	end
end

--------------------------------明雷玩法相关结束-------------------------------

--活动通用屏蔽处理
--不需要屏蔽返回true，需要屏蔽返回false
function CActivityCtrl.ActivityBlockContrl(self, blockActivity, showTips, itemSid)
	--战斗中部分特殊处理
	if g_WarCtrl:IsWar() then
		if blockActivity == "pk" then
			g_NotifyCtrl:FloatMsg("战斗中无法进行此操作")
			return false
		elseif blockActivity == "watchwar" then
			g_NotifyCtrl:FloatMsg("战斗中无法进行此操作")
			return false
		elseif blockActivity == "watchreplay" then
			g_NotifyCtrl:FloatMsg("战斗中无法进行此操作")
			return false
		end
		return true
	end

	local b = true		
		if g_AnLeiCtrl:IsInAnLei() then		
			b = self:ActivityBlockProcress("trapmine", blockActivity, showTips, itemSid)			
		-- elseif g_TaskCtrl:IsDoingEscortTask() then
		-- 	b = self:ActivityBlockProcress("escort", blockActivity, showTips, itemSid)			
		elseif self:GetYJFbCtrl():IsInFuben() then
			b = self:ActivityBlockProcress("yjfuben", blockActivity, showTips, itemSid)			
		elseif g_EquipFubenCtrl:IsInEquipFB() then
			b = self:ActivityBlockProcress("equipfuben", blockActivity, showTips, itemSid)					
		elseif g_TreasureCtrl:IsInChuanshuoScene() then
			b = self:ActivityBlockProcress("treasure", blockActivity, showTips, itemSid)						
		elseif g_FieldBossCtrl:IsOpen() then
			b = self:ActivityBlockProcress("fieldboss", blockActivity, showTips, itemSid)							
		elseif g_TeamPvpCtrl:IsInTeamPvpScene() then
			b = self:ActivityBlockProcress("teampvp", blockActivity, showTips, itemSid)
		elseif g_ConvoyCtrl:IsConvoying() then
			b = self:ActivityBlockProcress("convoy", blockActivity, showTips, itemSid)
		elseif g_TeamPvpCtrl:IsInTeamPvpScene() then
			b = self:ActivityBlockProcress("teampvp", blockActivity, showTips, itemSid)			
		elseif g_SceneExamCtrl:IsInExam() then
			b = self:ActivityBlockProcress("sceneexam", blockActivity, showTips, itemSid)			
		elseif self:InWorldBossFB() then
			b = self:ActivityBlockProcress("worldboss", blockActivity, showTips, itemSid)
		elseif g_OrgWarCtrl:IsInOrgWarScene() then
			b = self:ActivityBlockProcress("orgwar", blockActivity, showTips, itemSid)
		elseif self:IsDailyTraining() then
			b = self:ActivityBlockProcress("lilian", blockActivity, showTips, itemSid)				
		elseif g_TeamCtrl:IsJoinTeam() then			
			b = self:ActivityBlockProcress("team", blockActivity, showTips, itemSid)				
		end
	return b
end

function CActivityCtrl.ActivityBlockProcress(self, curActivity, blockActivity, showTips, itemSid)
	local b = true
	local d = data.huodongblockdata.DATA[curActivity]
	if d then	
		if d[blockActivity] then			
			if blockActivity == "item" then
				if d[blockActivity] ~= "" then
					local itemList = string.split(d[blockActivity], ",") 
					if itemList and #itemList > 0 then
						for _, id in pairs(itemList) do
							local sid = tonumber(id)
							itemSid = tonumber(itemSid)
							if sid == itemSid then
								b = false
								if showTips ~= false and d.tips then
									g_NotifyCtrl:FloatMsg(string.format("%s", d.tips))
								end
								break
							end 
						end
					end
				end
			else
				if d[blockActivity] ~= "" then
					local list = string.split(d[blockActivity], ",")
					if #list > 0 then
						local isBloack = list[1]
						if isBloack == "n" then
							b = false
							if showTips ~= false and d.tips then																
								g_NotifyCtrl:FloatMsg(string.format("%s", d.tips))
							end
						end
					end
				end				
			end			
		end
	end
	return b
end

--活动隐藏屏蔽( 需要隐藏返回 false ， 不需要隐藏返回true)
function CActivityCtrl.IsActivityVisibleBlock(self, blockActivity, isVirtualSceneActivity)	
	-- if isVirtualSceneActivity and (not g_MapCtrl:GetSceneID() or not g_MapCtrl:IsVirtualScene() then
	-- 	--return true
	-- end		

	local curActivity = ""
	if g_AnLeiCtrl:IsInAnLei() then		
		curActivity = "trapmine"			
	-- elseif g_TaskCtrl:IsDoingEscortTask() then
	-- 	curActivity = "escort"			
	elseif self:GetYJFbCtrl():IsInFuben() then
		curActivity = "yjfuben"		
	elseif g_EquipFubenCtrl:IsInEquipFB() then
		curActivity = "equipfuben"		
	elseif g_TreasureCtrl:IsInChuanshuoScene() then
		curActivity = "treasure"
	elseif g_FieldBossCtrl:IsOpen() then
		curActivity = "fieldboss"	
	elseif g_TeamPvpCtrl:IsInTeamPvpScene() then
		curActivity = "teampvp"
	elseif g_ConvoyCtrl:IsConvoying() then
		curActivity = "convoy"
	elseif g_TeamPvpCtrl:IsInTeamPvpScene() then
		curActivity = "teampvp"		
	elseif g_SceneExamCtrl:IsInExam() then
		curActivity = "sceneexam"	
	elseif self:InWorldBossFB() then
		curActivity = "worldboss"
	elseif g_OrgWarCtrl:IsInOrgWarScene() then
		curActivity = "orgwar"
	elseif self:IsDailyTraining() then
		curActivity = "lilian"		
	elseif g_TeamCtrl:IsJoinTeam() then
		curActivity = "team"		
	end

	if curActivity == "" then
		return true
	end

	local b = true
	local d = data.huodongblockdata.DATA[curActivity]
	if d then	
		if d[blockActivity] and d[blockActivity] ~= "" then
			local list = string.split(d[blockActivity], ",")
			if #list > 1 then
				local isBloack = list[2]
				if isBloack == "n" then
					b = false
				end
			end
		end				
	end
	return b
end

function CActivityCtrl.CtrlGS2CTrainInfo(self, reward_info, clientnpc, reward_times, ring, reward_siwtch)
	self.m_DTRewardTime = reward_times or 0
	self.m_DTRewardList = reward_info or {}
	if next(self.m_DTClientNpc) then
		for i, v in ipairs(self.m_DTClientNpc) do
			g_MapCtrl:DelDynamicNpc(v.npcid)
		end
	end
	self.m_DTClientNpc = clientnpc or {}
	self.m_DTRing = ring or 0
	self.m_DTDoubleFlag = reward_siwtch or 0
	self:RefreshDTNpc()

	--如果接到任务时，目标不是修行，则客户端主动发起一次修行操作
	if g_TeamCtrl:IsLeader() and self:IsDailyTraining() then
		local target = g_TeamCtrl:GetTeamTargetInfo()			
		if target.auto_target ~= CTeamCtrl.TARGET_DAILY_TRAIN then	
			self:StartDailyTrain()
			self:CtrlC2GSContinueTraining()
		end
	end
	self:OnEvent(define.Activity.Event.DTUpdate)
end

function CActivityCtrl.LoginHuodongInfo(self, info)
	self.m_DTRewardTime = info.reward_times or 0
end

function CActivityCtrl.CtrlC2GSContinueTraining(self)
	if g_TeamCtrl:IsJoinTeam() then
		nethuodong.C2GSContinueTraining()
	end
end

function CActivityCtrl.IsDailyTraining(self)
	return next(self.m_DTClientNpc) ~= nil
end

function CActivityCtrl.RefreshDTNpc(self)
	for i,v in ipairs(self.m_DTClientNpc) do
		if v.map_id == g_MapCtrl:GetMapID() then
			local npc = table.copy(v)
			npc.targetType = CMapWalker.TARGET_TYPE.DAILY_TRAIN
			g_MapCtrl:AddDynamicNpc(npc)
		end
	end
end

function CActivityCtrl.GetDailyTrainTimes(self)
	return self.m_DTRewardTime
end

function CActivityCtrl.CtrlC2GSSetTrainReward(self)
	if self.m_DTDoubleFlag == 1 then
		self.m_DTDoubleFlag = 0
	else
		self.m_DTDoubleFlag = 1
	end
	nethuodong.C2GSSetTrainReward(self.m_DTDoubleFlag )
end

function CActivityCtrl.CtrlGS2CTrainRewardSwitch(self, close)
	self.m_DTDoubleFlag = close
	self:OnEvent(define.Activity.Event.DTUpdateDouble)
end

function CActivityCtrl.CtrlGS2CRemoveTeamNpc(self, taskId, npcId, target )
	for i, v in ipairs(self.m_DTClientNpc) do
		if v.npcid == npcId then
			g_MapCtrl:DelDynamicNpc(npcId)
		end
	end
	self.m_DTClientNpc = {}
	self.m_DTIsLeader = nil
	self:UpdateDTStatus()
	self:OnEvent(define.Activity.Event.DTUpdate)
end

function CActivityCtrl.CtrlGS2CFastCreateTeam(self, target)
	local target = target or 0
	local oView = CTeamMainView:GetView()
	if not oView then
		CTeamMainView:ShowView(function (oView)
			oView:OnSwitchPage(2, target)
			local min, max = g_TeamCtrl:GetTeamTargetDefaultLevel(target)
			oView.m_HandyBuildPage:SetLevelButtonText(min, max)			
		end)
	end
end

function CActivityCtrl.CtrlGS2CRefreshTrainTimes(self, times)
	self.m_DTRewardTime = times or 0
	self:OnEvent(define.Activity.Event.DTUpdate)
end

--客户端触发  开始每日训练
function CActivityCtrl.StartDailyTrain(self)
	local cnt = g_TeamCtrl:GetMemberSize()
	--不满4人，开启每日训练自动匹配
	if g_TeamCtrl:IsLeader() then
		local tData = data.teamdata.AUTO_TEAM[CTeamCtrl.TARGET_DAILY_TRAIN]
		if cnt < 4 then			
			local target = g_TeamCtrl:GetTeamTargetInfo()			
			if target.auto_target ~= CTeamCtrl.TARGET_DAILY_TRAIN then	
				local min, max = g_TeamCtrl:GetTeamTargetDefaultLevel(CTeamCtrl.TARGET_DAILY_TRAIN)		
				g_TeamCtrl:C2GSTeamAutoMatch(CTeamCtrl.TARGET_DAILY_TRAIN, min, max, 1)
			else
				if not g_TeamCtrl:IsTeamAutoMatch() then					
					g_TeamCtrl:C2GSTeamAutoMatch(target.auto_target, target.min_grade, target.max_grade, 1)				
				end
			end
		else
			local target = g_TeamCtrl:GetTeamTargetInfo()			
			if target.auto_target ~= CTeamCtrl.TARGET_DAILY_TRAIN then	
				local min, max = g_TeamCtrl:GetTeamTargetDefaultLevel(CTeamCtrl.TARGET_DAILY_TRAIN)					
				g_TeamCtrl:C2GSSetTeamTarget(CTeamCtrl.TARGET_DAILY_TRAIN, min, max)
			end
		end

		local oHero = g_MapCtrl:GetHero()
		if oHero then
			oHero:SetDailyTrainHud(true)
		end
	end
	self.m_DTStatus = 1
	self.m_DTIsLeader = g_TeamCtrl:IsLeader()
end

--客户端自己触发，停止每日训练
function CActivityCtrl.EndDailyTrain(self)
	if g_TeamCtrl:IsLeader() then
		if self.m_DTStatus == 1 then
			if g_TeamCtrl:IsTeamAutoMatch() then
				local target = g_TeamCtrl:GetTeamTargetInfo()
				if target.auto_target == CTeamCtrl.TARGET_DAILY_TRAIN then
					g_TeamCtrl:C2GSTeamAutoMatch(target.auto_target, target.min_grade, target.max_grade, 0)
				end
			end
		end
		local oHero = g_MapCtrl:GetHero()
		if oHero then
			oHero:SetDailyTrainHud(false)
		end		
	end
	self.m_DTIsLeader = g_TeamCtrl:IsLeader()
	self.m_DTStatus = 0
end

function CActivityCtrl.DailyTrainClickCheck(self, clickTarget, config)
	config = config or {}
	if self:IsDailyTraining() then
		if g_TeamCtrl:IsLeader() then			
			if clickTarget == CActivityCtrl.DCClickEnum.Actor and config.targetType == CMapWalker.TARGET_TYPE.DAILY_TRAIN then
				self:StartDailyTrain()
			else
				self:EndDailyTrain()
			end	
		end	
	end
end

function CActivityCtrl.CheckHeroStartWalk(self, walkConfig)
	local config = walkConfig or {}
	if self:IsDailyTraining() then		
		if config.m_WalkTarget == 1 then
			self:StartDailyTrain()
		else
			self:EndDailyTrain()
		end
	end
end

function CActivityCtrl.UpdateDTStatus(self)
	if self.m_DTStatus == 1 then
		--不是队长，或者已经不再修行
		if not g_TeamCtrl:IsLeader() or not self:IsDailyTraining() then
			self.m_DTStatus = 0	
			local oHero = g_MapCtrl:GetHero()
			if oHero then
				oHero:SetDailyTrainHud(false)
			end					
		elseif g_TeamCtrl:IsLeader() then
			--如果队长改了目标
			local target = g_TeamCtrl:GetTeamTargetInfo()
			if target and target.auto_target ~= CTeamCtrl.TARGET_DAILY_TRAIN then
				self:CtrlGS2CQuitTrain()
			end
		end
	else
		if self.m_DTIsLeader == false and g_TeamCtrl:IsLeader() then
			g_ActivityCtrl:CtrlC2GSContinueTraining()
			self:StartDailyTrain()
		end
	end
end

function CActivityCtrl.CtrlC2GSQuitTrain(self)
	if g_TeamCtrl:IsLeader() then
		nethuodong.C2GSQuitTrain()
	else
		if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSLeaveTeam"]) then
			netteam.C2GSLeaveTeam()
		end	
	end
end

function CActivityCtrl.CtrlGS2CQuitTrain(self)
	if g_TeamCtrl:IsLeader() then
		self:EndDailyTrain()
		local oHero = g_MapCtrl:GetHero()
		if oHero then
			oHero:StopWalk()
		end				
	end
	self.m_DTIsLeader = nil
end

function CActivityCtrl.CreateDailyTrainTeam(self)
	local min, max = g_TeamCtrl:GetTeamTargetDefaultLevel(CTeamCtrl.TARGET_DAILY_TRAIN)		
	g_TeamCtrl:C2GSCreateTeam(CTeamCtrl.TARGET_DAILY_TRAIN, min, max)
	g_TeamCtrl:C2GSTeamAutoMatch(CTeamCtrl.TARGET_DAILY_TRAIN, min, max, 1)
	CTeamMainView:ShowView(function (oView)
		oView:ShowTeamPage(CTeamMainView.Tab.TeamMain)
	end)	
end

function CActivityCtrl.JoinDailyTrainTeam(self)	
	g_NotifyCtrl:FloatMsg("开始匹配每日修行")
	local min, max = g_TeamCtrl:GetTeamTargetDefaultLevel(CTeamCtrl.TARGET_DAILY_TRAIN)	
	g_TeamCtrl:C2GSPlayerAutoMatch(CTeamCtrl.TARGET_DAILY_TRAIN, min, max)
	CTeamMainView:ShowView(function (oView )
		oView:ShowTeamPage(CTeamMainView.Tab.HandyBuild)
		oView.m_HandyBuildPage:OnTargetChange(CTeamCtrl.TARGET_DAILY_TRAIN)
	end)

end

return CActivityCtrl
