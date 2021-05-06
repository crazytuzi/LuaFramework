local CAnLeiCtrl = class("CAnLeiCtrl", CCtrlBase)

CAnLeiCtrl.AnLeiPointMax = 200			--最大探索点的上限

CAnLeiCtrl.AnLeiStatus = 
{		
	Normal = 0,				--非探索
	Patrol = 1,				--探索
	Boss = 2,				--Boss
	Trust = 3,				--托管
}

define.AnLei = {
	Event = 
	{
		BeginPatrol = 1,
		EndPatrol = 2,		
		UpdateInfo = 3,		
	},
}

function CAnLeiCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_TodyPointBought = 0	--今日已经购买的探索点的数量
	self.m_NpcList = {}
	self.m_ItemList = {}
	self.m_CacheList = {}
	self.m_AutoLock = true		--锁定出战单位
	self.m_Status = CAnLeiCtrl.AnLeiStatus.Normal
	self.m_OffLineRewardList = nil
	self.m_ShowRewardTimer = nil
	self.m_MonsterRare = {}
end

function CAnLeiCtrl.GoToPatrol(self, mapId)
	local b = false
	if g_TaskCtrl:IsDoingEscortTask() then
		g_NotifyCtrl:FloatMsg("请先完成护送任务")
	elseif g_TeamCtrl:IsJoinTeam() and not g_TeamCtrl:IsLeader() then
		g_NotifyCtrl:FloatMsg("只有队长可以发起探索")

	elseif g_AttrCtrl.trapmine_point <= 0 then				
		local windowConfirmInfo = {
			msg				= "探索点不足，是否购买探索点？",
			okCallback		= function ()				
				CAnLeiAddTipsView:ShowView()	
			end,
			okStr = "是",
			cancelStr = "否",			
		}
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)	
	else
		--切换地图，服务器来负责
		-- if mapId then
		-- 	local curMapID = g_MapCtrl:GetMapID()
		-- 	if curMapID ~= mapId then
		-- 		local oHero = g_MapCtrl:GetHero()
		-- 		netscene.C2GSClickWorldMap(g_MapCtrl:GetSceneID(), oHero.m_Eid, mapId)
		-- 	end
		-- end
		self:ResetTotalReward()
		self:CtrlC2GSStartTrapmine(mapId)
		b = true
	end
	return b
end

function CAnLeiCtrl.StartPatrol(self)
	local oHero = g_MapCtrl:GetHero()
	if oHero then
		oHero:StartPatrol()						
	end
end

function CAnLeiCtrl.StopPatrol(self)
	local oHero = g_MapCtrl:GetHero()
	if oHero then	
		oHero:StopPatrol()	
		oHero:StopWalk()
	end
end

--是否在暗雷探索
function CAnLeiCtrl.IsInAnLei(self)
	return self.m_Status == CAnLeiCtrl.AnLeiStatus.Patrol
end

--购买探索点
function CAnLeiCtrl.AddAnLeiPoint(self , count)
	if count == 0 then
		g_NotifyCtrl:FloatMsg("请输入购买探索点数量")
		return 		
	end
	if g_NetCtrl:IsValidSession(netdefines.C2GS_BY_NAME["C2GSExchangeTrapminePoint"]) then
		netstore.C2GSExchangeTrapminePoint(count)
	end
end

--获取可购买探索点的最大上限
function CAnLeiCtrl.GetCanAddPointCount(self)
	local point = CAnLeiCtrl.AnLeiPointMax - g_AttrCtrl.trapmine_point --最大上限 - 当前的探索点
	local dailyMax = tonumber(data.globaldata.GLOBAL.daily_buy_trapmine_point.value) 	--每日可购买最大上限
	if point > dailyMax - self.m_TodyPointBought then
		point = dailyMax - self.m_TodyPointBought 
	end
	return point
end

--获取当前水晶可购买的最大数量
function CAnLeiCtrl.GetCanBuyPointCountByCoin(self)
	local t = {[1] = {price = 1, max = 50,},[2] = {price = 2, max = 150,},}
	local coin = g_AttrCtrl.goldcoin
	local point = 0
	if self.m_TodyPointBought > t[1].max then
		point = math.floor(coin / t[2].price)  
	else
		local temp_point_1 = t[1].max - self.m_TodyPointBought
		if temp_point_1 * t[1].price > coin then
			point = math.floor(coin / t[1].price) 
		else
			point = temp_point_1 + math.floor(( coin - temp_point_1 * t[1].price ) / t[2].price) 
		end
	end
	return point
end

function CAnLeiCtrl.GetBuyAnleiPointPrice(self, point)
	local t = {[1] = {price = 1, max = 50},[2] = {price = 2, max = 150},}
	local p = point + self.m_TodyPointBought
	local price = 0
	if p > t[1].max then
		if self.m_TodyPointBought > t[1].max then		
			price = point * t[2].price
		else
			local temp = t[1].max - self.m_TodyPointBought
			price = t[1].price * temp + t[2].price * (point - temp)
		end
	else
		price = point * t[1].price
	end
	return price
end


--开始探索 协议请求
function CAnLeiCtrl.CtrlC2GSStartTrapmine(self, mapId)
	if g_ActivityCtrl:IsDailyTraining() then
		g_ActivityCtrl:CtrlGS2CQuitTrain()
	end	
	local map = mapId or g_MapCtrl:GetMapID()
	nethuodong.C2GSStartOfflineTrapmine(map)
end

--取消探索 协议请求
function CAnLeiCtrl.CtrlC2GSCancelTrapmine(self)
	local map = g_MapCtrl:GetMapID()
	nethuodong.C2GSCancelOfflineTrapmine(map)
end

--探索状态协议返回
function CAnLeiCtrl.CtrlGS2CTrapmineStatus(self, status)
	status = status or CAnLeiCtrl.AnLeiStatus.Normal
	if self.m_Status ~= status then
		local isStop = false		
		if self:IsInAnLei() and status == CAnLeiCtrl.AnLeiStatus.Normal then
			isStop = true
		end		
		self.m_Status = status
		if isStop then
			self:StopPatrol()
			g_WarCtrl:SetLockPreparePartner(define.War.Type.AnLei, false)		--暗雷结束时，自动暗雷自动出战配置关闭
			self:OnEvent(define.AnLei.Event.EndPatrol)
			if self.m_OffLineRewardList then
				local cb = function ()
					local t = self.m_OffLineRewardList or {}
					CAnLeiRewardListView:ShowView(function (oView)
						oView:SetContent(t.itemlist, t.time, t.cost)
					end)
					self.m_OffLineRewardList = nil
				end
				self:StopShowTimer()
				self.m_ShowRewardTimer = Utils.AddTimer(cb, 0, 1)				
				return
			end
			if g_AttrCtrl.trapmine_point == 0 then
				local cb = function ()
					CAnLeiRewardListView:ShowView(function (oView)
						oView:SetContent(self.m_CacheList)
						self.m_CacheList = {}
					end)
				end
				self:StopShowTimer()
				self.m_ShowRewardTimer = Utils.AddTimer(cb, 0, 1)
			end
		end
		if status == CAnLeiCtrl.AnLeiStatus.Patrol then
			self:StartPatrol()
			self:OnEvent(define.AnLei.Event.BeginPatrol)
			self:UpdateTeamTargetInfo()
		end		
	end
end

function CAnLeiCtrl.IsTrust(self)
	return self.m_Status == CAnLeiCtrl.AnLeiStatus.Trust
end


function CAnLeiCtrl.CtrlGS2CCreateHuodongNpc(self, info)	
	local npc = table.copy(info)
	if npc then
		npc.pos_info = self:InitPosInfoTable(npc.pos_info)
		if npc.pos_info.x < 1000 then
			npc.pos_info.x = npc.pos_info.x * 1000
			npc.pos_info.y = npc.pos_info.y * 1000
		end				
		table.insert(self.m_NpcList, npc) 	
		self:RefreshNpc()
	end
	local isMblr = false --是否是密保猎人
	local isYwtm = false --是否是野外头目
	local d = data.anleidata.NPC[npc.npctype]
	if d then
		if d.monster_type == 2 then
			isYwtm = true
		else
			isMblr = true
		end
	end
	if isMblr and g_SysSettingCtrl:GetSysSetting("trapmine_vibrate_mb") then
		--手机震动
		C_api.Utils.Vibrate()
	elseif isYwtm and  g_SysSettingCtrl:GetSysSetting("trapmine_vibrate_tm") then
		C_api.Utils.Vibrate()
	end

	--打完怪，不会走到暗雷怪面前
	--self:WalkToNpc()

	--显示走马灯
	self:ShowMonsterTips(npc.npcid)

	--延时一帧 刷新主界面的暗雷提示
	local function cb()
		self:CtrlC2GSStartTrapmine()			--刷出稀有怪的时候，要在给服务器请求继续探索
		self:OnEvent(define.AnLei.Event.UpdateInfo)
	end
	Utils.AddTimer(cb, 0, 0)
end

function CAnLeiCtrl.RefreshNpc(self)
	for _,v in ipairs(self.m_NpcList) do
		if v.map_id == g_MapCtrl:GetMapID() then
			--g_MapCtrl:AddDynamicNpc(v)
		end		
	end
	table.print(self.m_NpcList)
end

function CAnLeiCtrl.GetNpcById(self, npcId)
	local t
	for _, npc in ipairs(self.m_NpcList) do
		if npc.npcid == npcId then
			t = npc
			break
		end
	end
	return t
end

function CAnLeiCtrl.CtrlGS2CTrapmineTotalReward(self, itemList)
	itemList = itemList or {}
	if itemList and next(itemList) then
		for i = 1, #itemList do
			itemList[i].virtual = itemList[i].virtual or 0
		end
	end
	self.m_ItemList = itemList
	if next(itemList) then
		self.m_CacheList = itemList
	end
	self:OnEvent(define.AnLei.Event.UpdateInfo)
end

function CAnLeiCtrl.ResetTotalReward(self)
	self.m_ItemList = {}
	self:OnEvent(define.AnLei.Event.UpdateInfo)
end

function CAnLeiCtrl.GetConfig(self)
	return data.anleidata.DATA[1]
end

function CAnLeiCtrl.LoginHuodongInfo(self, list, rare_monster)
	self.m_NpcList = {}
	local npcList = table.copy(list)
	if npcList and next(npcList) then
		for i = 1, #npcList do
			npcList[i].pos_info = self:InitPosInfoTable(npcList[i].pos_info)
			if npcList[i].pos_info.x < 1000 then
				npcList[i].pos_info.x = npcList[i].pos_info.x * 1000
				npcList[i].pos_info.y = npcList[i].pos_info.y * 1000
			end				
			table.insert(self.m_NpcList, npcList[i]) 		
		end
		self:RefreshNpc()
	end
	self.m_MonsterRare = rare_monster or {}
end

function CAnLeiCtrl.CtrlGS2CRemoveHuodongNpc(self, npcId)
	for k, v in ipairs(self.m_NpcList) do
		if v.npcid == npcId then
			--g_MapCtrl:DelDynamicNpc(npcId)
			table.remove(self.m_NpcList, k)
			break
		end		
	end

	--延时一帧 刷新主界面的暗雷提示
	local function cb()
		self:OnEvent(define.AnLei.Event.UpdateInfo)
	end
	Utils.AddTimer(cb, 0, 0)
end

function CAnLeiCtrl.IsAnLeiMap(self, mapId)
	local resId = mapId or g_MapCtrl:GetResID() * 100
	if resId then
		local d = data.anleidata.MAP_GROUP
		for _, map in pairs(d) do
			if map == resId then
				return true
			end
		end
	end
	return false
end

function CAnLeiCtrl.GoToAnleiMapTips(self)	
	if not self:IsAnLeiMap() then
		local anleiMapTable = data.anleidata.MAP_GROUP
		local mapTable = data.scenedata.DATA				
		table.print(mapTable)
		local str = ""
		for i = 1, #anleiMapTable do 
			local mapId = anleiMapTable[i]
			for k, v in pairs(mapTable) do				
				if v.map_id == mapId then
					if str ~= "" then
						str = str .. "、"..v.scene_name
					else
						str = v.scene_name
					end
					break
				end
			end			
		end

		if str ~= "" then
			g_NotifyCtrl:FloatMsg(string.format("请到%s进行探索", str))
		end
	end
end

function CAnLeiCtrl.HeroPatrolCheck(self)
	local oHero = g_MapCtrl:GetHero()
	if oHero then
		if g_AnLeiCtrl:IsInAnLei() and not oHero:IsPatroling() then
			oHero:StartPatrol()	
		end				
	end	
end


function CAnLeiCtrl.GetNpcByNpcId(self, npcId)
	local npc = nil
	if self.m_NpcList then
		for k, v in pairs(self.m_NpcList) do
			if v.npcid == npcId then
				npc = v
				break
			end
		end
	end
	return npc
end

function CAnLeiCtrl.WalkToNpcByPid(self, npcId)
	local npc = self:GetNpcByNpcId(npcId)
	if npc then
		local temp = {}
		table.insert(temp, npc)
		local taskData = 
		{
			acceptnpc = npc.npctype,
			clientnpc = temp,
			findPathCb = function ()
				local oNpc = g_MapCtrl:GetNpc(npcId) 			
				if not Utils.IsNil(oNpc) then
					oNpc:OnTouch()
					oNpc:Trigger()
				end				
			end,			
		}
		local oTask = CTask.NewByData(taskData)
		g_TaskCtrl:ClickTaskLogic(oTask)			
	end
end

function CAnLeiCtrl.WalkToNpc(self)
	if self.m_NpcList and #self.m_NpcList > 0 then
		self:WalkToNpcByPid(self.m_NpcList[1].npcid)
		return true
	else
		g_NotifyCtrl:FloatMsg("还没有触发稀有怪")
		return false
	end
end

function CAnLeiCtrl.WalkToNpcByType(self, type)
	if self.m_NpcList and #self.m_NpcList > 0 then
		local npc = self:GetAnLeiMonster(type)
		if npc then
			self:WalkToNpcByPid(npc.npcid)
		else
			if type == 1 then
				g_NotifyCtrl:FloatMsg("没有发现宝箱怪")	
			elseif type == 2 then
				g_NotifyCtrl:FloatMsg("没有发现稀有怪")	
			end	
		end
	else
		g_NotifyCtrl:FloatMsg("还没有触发稀有怪")
		return false
	end
end

function CAnLeiCtrl.IsHaveNpc(self)
	return (self.m_NpcList and #self.m_NpcList > 0)
end

function CAnLeiCtrl.ResetCtrl(self)
	self.m_NpcList = {}
	self.m_ItemList = {}
	self.m_CacheList = {}
	self.m_Status = CAnLeiCtrl.AnLeiStatus.Normal	
	g_WarCtrl:SetLockPreparePartner(define.War.Type.AnLei, false)		--暗雷结束时，自动暗雷自动出战配置关闭
	self:StopShowTimer()
	self:OnEvent(define.AnLei.Event.EndPatrol)
end

--type == 1 宝相怪， type == 2 稀有怪
function CAnLeiCtrl.GetAnLeiMonster(self, type)
	local npc = nil
	if (self.m_NpcList and #self.m_NpcList > 0) then
		for k, v in pairs(self.m_NpcList) do
			local d = data.anleidata.NPC[v.npctype]
			if d and d.monster_type == type then
				npc = v
				break
			end
		end
	end
	return npc
end

function CAnLeiCtrl.IsHaveBoxMonster(self)
	return self:GetAnLeiMonster(1) ~= nil
end

function CAnLeiCtrl.GetMonsterLeftTime(self, type)
	local str = ""
	local npc = self:GetAnLeiMonster(type)
	if npc then
		local time = g_TimeCtrl:GetTimeS()		
		local leftTime = npc.createtime + 60 * 30 - time
		if leftTime > 0 then
			if leftTime > 60 * 25 then
				leftTime = leftTime - (60 * 25)
				str = self:ConverTimeString(leftTime)
			else
				--如果超过共享时间之后，不显示时间
				str = " "
			end
		end
	end
	return str
end

function CAnLeiCtrl.GetMonsterHudLeftTimeByNpcId(self, npcId, endTime)
	local str = ""
	local npc = self:GetNpcByNpcId(npcId)
	if npc then
		local time = g_TimeCtrl:GetTimeS()		
		local leftTime = npc.createtime + 60 * 5 - time
		if leftTime > 0 then
			str = self:ConverTimeString(leftTime)
		end
	end
	if str == "" then
		str = self:GetLeftTimeStrByEndTime(endTime)
	end
	return str	
end

function CAnLeiCtrl.GetLeftTimeStrByEndTime(self, endTime)
	local str = ""
	local time = g_TimeCtrl:GetTimeS()		
	local leftTime = endTime - time - 60 * 25
	if leftTime > 0 then
		str = self:ConverTimeString(leftTime)
	end
	return str	
end

--type == 1 宝相怪， type == 2 稀有怪
function CAnLeiCtrl.GetMonsterShape(self, type)
	local shape = 0
	if (self.m_NpcList and #self.m_NpcList > 0) then
		for k, v in pairs(self.m_NpcList) do
			local d = data.anleidata.NPC[v.npctype]
			if d and d.monster_type == type then
				shape = d.modelId
				break
			end
		end
	end
	return shape
end

--type == 1 宝相怪， type == 2 稀有怪
function CAnLeiCtrl.GetMonsterName(self, type)
	local name = ""
	if type == 1 then
		name = "宝箱怪"
	elseif type == 2 then
		name = "稀有怪"
	end
	if (self.m_NpcList and #self.m_NpcList > 0) then
		for k, v in pairs(self.m_NpcList) do
			local d = data.anleidata.NPC[v.npctype]
			if d and d.monster_type == type then
				name = d.name
				break
			end
		end
	end
	return name
end

function CAnLeiCtrl.IsHaveNpcMonster(self)
	return self:GetAnLeiMonster(2) ~= nil
end

function CAnLeiCtrl.ConverTimeString(self, time)
	local str = ""
	time = tonumber(time)
	if time	>= 0 then
		local h = math.floor(time / 3600)
		local min = math.floor(time % 3600 / 60)
		local sec = time % 60
		str = string.format("%02d:%02d", min, sec)
	end
	return str
end

function CAnLeiCtrl.ShowMonsterTips(self, npcId)
	local npc = self:GetNpcByNpcId(npcId)
	if npc and npc.name and npc.name ~= "" then
		local dMsg = {
			channel = define.Channel.Bulletin,
			text = string.format("您触发了%s，点击%s图标进行挑战吧。", npc.name, npc.name),
			horse_race = 1,
		}
		g_ChatCtrl:AddMsg(dMsg)
	end	
end

function CAnLeiCtrl.CtrlGS2CTodayInfo(self, info)
	local point = info.trapmine_point_bought or 0
	self.m_TodyPointBought = point
end

function CAnLeiCtrl.ShowWarResult(self, oCmd)
	if oCmd.win then
		CWarResultView:ShowView(function(oView)
			oView:SetWarID(oCmd.war_id)
			oView:SetWin(true)
			oView:SetDelayCloseView()
		end)
	else
		CWarResultView:ShowView(function(oView)
			oView:SetWarID(oCmd.war_id)
			oView:SetWin(false)
		end)
	end
end

function CAnLeiCtrl.AnLeiCreateTeam(self, targetId)
	if targetId == CTeamCtrl.TARGET_AN_LEI_BOX or targetId == CTeamCtrl.TARGET_AN_LEI_NPC then
		CTeamMainView:ShowView(function (oView )
			oView:ShowTeamPage(CTeamMainView.Tab.TeamMain)
		end)

		if not g_TeamCtrl:IsInTeam() then
			g_TeamCtrl:C2GSCreateTeam(targetId)
		else
			local targetInfo = g_TeamCtrl:GetTeamTargetInfo()
			if targetId == CTeamCtrl.TARGET_AN_LEI_BOX then
				if targetInfo.auto_target ~= CTeamCtrl.TARGET_AN_LEI_BOX then
					g_TeamCtrl:C2GSTeamAutoMatch(CTeamCtrl.TARGET_AN_LEI_BOX, targetInfo.min_grade, targetInfo.max_grade, 0)
				end
			else
				if targetInfo.auto_target ~= CTeamCtrl.TARGET_AN_LEI_NPC then
					g_TeamCtrl:C2GSTeamAutoMatch(CTeamCtrl.TARGET_AN_LEI_NPC, targetInfo.min_grade, targetInfo.max_grade, 0)
				end
			end					
		end
	end
end

function CAnLeiCtrl.CacheOffLineRewardList(self, reward)
	self.m_OffLineRewardList = reward	
	self:StopShowTimer()
	local cb = function ()
		if not g_WarCtrl:IsWar() then
			if self.m_OffLineRewardList then
				local t = self.m_OffLineRewardList or {}
				CAnLeiRewardListView:ShowView(function (oView)
					oView:SetContent(t.itemlist, t.time, t.cost)
				end)
				self.m_OffLineRewardList = nil
			end			
		end
	end
	self.m_ShowRewardTimer = Utils.AddTimer(cb, 0, 1)
end

function CAnLeiCtrl.SwitchEnv(self, bWar)
	if not bWar then
		if self.m_OffLineRewardList then
			self:StopShowTimer()
			local cb = function ()
				local t = self.m_OffLineRewardList or {}
				CAnLeiRewardListView:ShowView(function (oView)
					oView:SetContent(t.itemlist, t.time, t.cost)
				end)
				self.m_OffLineRewardList = nil
			end			
			self.m_ShowRewardTimer = Utils.AddTimer(cb, 0, 1)
			return
		end	
	end
end

function CAnLeiCtrl.StopShowTimer(self)
	if self.m_ShowRewardTimer then
		Utils.DelTimer(self.m_ShowRewardTimer)
		self.m_ShowRewardTimer = nil
	end
end

function CAnLeiCtrl.InitPosInfoTable(self, info)
	info = info or {}
	local t = {}
	t.x = info.x or 0
	t.y = info.y or 0
	return t
end

function CAnLeiCtrl.UpdateTeamTargetInfo(self)
	if g_TeamCtrl:IsJoinTeam() and g_TeamCtrl:IsLeader() and self:IsInAnLei() then
		if self:IsInAnLei() then
			local targetInfo = g_TeamCtrl:GetTeamTargetInfo()
			if targetInfo.auto_target ~= CTeamCtrl.TARGET_AN_LEI then
				local min, max = g_TeamCtrl:GetTeamTargetDefaultLevel(CTeamCtrl.TARGET_AN_LEI)
				g_TeamCtrl:C2GSSetTeamTarget(CTeamCtrl.TARGET_AN_LEI, min, max)	
			end
		end
	end
end

function CAnLeiCtrl.GetMapShowIcon(self, mapId)
	local t = {}
	if self.m_MonsterRare and next(self.m_MonsterRare) then
		for i, v in ipairs(self.m_MonsterRare) do
			if v.map_id == mapId then
				t = v.partypes
				break
			end
		end
	end
	return t
end

return CAnLeiCtrl
