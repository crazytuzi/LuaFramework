local CEquipFubenCtrl = class("CEquipFubenCtrl", CCtrlBase)

CEquipFubenCtrl.AutoDivtionTime = 0.5 --退出战斗后，自动副本的时间间隔

define.EquipFb = {
	Event = 
	{
		BeginFb = 1,
		EndFb = 2,	
		UpdateInfo = 3,	
		CompleteFB = 4,	
		SwpeepResult = 5,
	},
}

CEquipFubenCtrl.m_NpcMarkSprName = 
{
	[1] = "task_npcaccept", --战斗
}

CEquipFubenCtrl.ConditionText = 
{
	[1] = "击败Boss",
	[2] = "无伙伴阵亡",
	[3] = "内通关",
}

function CEquipFubenCtrl.ctor(self)
	CCtrlBase.ctor(self)

	self.m_FubenInfoList = {}

	self.m_CurFubenInfo = nil
	self.m_PassFubenInfo = nil
	if self.m_AutoFubenTimer then
		Utils.DelTimer(self.m_AutoFubenTimer)
		self.m_AutoFubenTimer = nil
	end	
	self.m_ClickMapStopAtup = false
	self.m_IsSendOverTime  = false
	self.m_TodayBuy = 0
	self.m_PathList = nil
	self.m_EffectList = {}
	self.m_MapEffId = nil
	self.m_ReOpenEquip = false
	self.m_ReOpenEquipFbId = nil
	if self.m_ShowGuideTipsTimer then
		Utils.DelTimer(self.m_ShowGuideTipsTimer)
		self.m_ShowGuideTipsTimer = nil
	end

	self.m_AutoEnterFb = false  	--进副本时是否回自动战斗
end

--请求打开装备副本主界面
function CEquipFubenCtrl.CtrlC2GSOpenEquipFBMain(self, OpenFbId )
	if OpenFbId then
		self.m_ReOpenEquip = true
		self.m_ReOpenEquipFbId = OpenFbId
	end
	nethuodong.C2GSOpenEquipFBMain()
end

--请求打开副本详情界面
function CEquipFubenCtrl.CtrlC2GSOpenEquipFB(self, fubenId)
	nethuodong.C2GSOpenEquipFB(fubenId)
end

--请求进入副本
function CEquipFubenCtrl.CtrlC2GSEnterEquiFB(self, floor)
	if g_AnLeiCtrl:IsInAnLei() then 
		g_NotifyCtrl:FloatMsg("目前正在探索中，请退出后再尝试。")

	elseif g_TaskCtrl:IsDoingEscortTask() then
		g_NotifyCtrl:FloatMsg("请先完成护送任务")
	else
		nethuodong.C2GSEnterEquiFB(floor)
	end
end

--请求退出副本
function CEquipFubenCtrl.CtrlC2GSGooutEquipFB(self)
	nethuodong.C2GSGooutEquipFB()
end

--打开装备副本主界面协议返回
function CEquipFubenCtrl.CtrlGS2COpenEquipFubenMain(self, info, remain)
 	self.m_FubenInfoList = table.copy(info)  
 	self.m_TodayBuy = 0
 	self.m_RemainTime = remain or 0
 	if self.m_FubenInfoList and next(self.m_FubenInfoList) then
 		for i = 1, #self.m_FubenInfoList do
 			local d = self.m_FubenInfoList[i] 		
 			d.floor = d.floor or 0
 			d.left = d.left or 0
 			d.max = d.max or 99
 			d.buy = d.buy or 0
 			d.tili_cost = d.tili_cost or 10
 			d.redpoint = d.redpoint or 0
 		end
 	end

	local maxFloor = 0
	if self.m_FubenInfoList and next(self.m_FubenInfoList) then
		for k, v in pairs(self.m_FubenInfoList) do
			local floor = v.floor or 0
			if floor > maxFloor then
				maxFloor = floor
			end
		end
	end

	if maxFloor > 0 then
		g_GuideCtrl:CompleteEquipTipsGuide()
	end

	local path = string.format("equipfuben_max_pass_floor")
	IOTools.SetRoleData(path, maxFloor)

 	local oView = CEquipFubenMainView:GetView()
 	if oView then
 		oView:RefreshAll()
 		self:OnEvent(define.EquipFb.Event.UpdateInfo)
 	else
 		CEquipFubenMainView:ShowView()
 	end
 end 

--打开装备副本详细协议返回
 function CEquipFubenCtrl.CtrlGS2COpenEquiFuben(self, info, floor, maxFloor, remain)
 	if info and info.f_id then
 		floor = floor or {}
 		maxFloor = maxFloor or 0
 		local oView = CEquipFubenDetailView:GetView()
 		if oView then
 			oView:SelectVipRewardRefresh(info.f_id, floor, maxFloor)
 		else
 			CEquipFubenDetailView:ShowView(function (oView)
	 			oView:SetContent(info.f_id, floor, maxFloor)
	 		end)
 		end
		
 	end
 	self.m_RemainTime = remain
 end

 --成功进入副本协议返回
 function CEquipFubenCtrl.CtrlGS2CRefreshEquipFBScene(self, floor, time, auto, sceneId, estimate, nidList, count) 
 	printc(" 开始进入装备副本.........")
	CEquipFubenDetailView:CloseView()
	CEquipFubenMainView:CloseView()
	local isUpdata = false 
	local oldAuto = nil

	if self.m_CurFubenInfo ~= nil then
		oldAuto = self.m_CurFubenInfo.auto
		isUpdata = true
	end
	if floor ~= nil or self.m_CurFubenInfo == nil then
		self.m_CurFubenInfo = {}	
	end
	self.m_CurFubenInfo.floor = floor ~= nil and floor or self.m_CurFubenInfo.floor
	if floor ~= nil then
		self.m_CurFubenInfo.floor = floor
	else
		self.m_CurFubenInfo.floor = self.m_CurFubenInfo.floor
	end
	if time ~= nil then
		self.m_CurFubenInfo.time = (g_TimeCtrl:GetTimeS() - time)
	else
		self.m_CurFubenInfo.time = self.m_CurFubenInfo.time
	end
	if auto ~= nil then
		self.m_CurFubenInfo.auto = (auto ~= 0)
	else
		self.m_CurFubenInfo.auto = self.m_CurFubenInfo.auto
	end
	if nidList ~= nil then
		self.m_CurFubenInfo.nidList = nidList
	else
		self.m_CurFubenInfo.nidList = self.m_CurFubenInfo.nidList
	end
	if sceneId ~= nil then
		self.m_CurFubenInfo.sceneId = sceneId
	else
		self.m_CurFubenInfo.sceneId = self.m_CurFubenInfo.sceneId
	end
	if estimate ~= nil then
		self.m_CurFubenInfo.estimate = estimate
	else
		self.m_CurFubenInfo.estimate = self.m_CurFubenInfo.estimate
	end
	self.m_CurFubenInfo.mapId = g_MapCtrl:GetMapID()

 	local t = 
 	{
 		[1] = false,
 		[2] = false,
 		[3] = false,
	}
	t[1] = MathBit.andOp(self.m_CurFubenInfo.estimate, 1) ~= 0	--通关	
	t[2] = MathBit.andOp(self.m_CurFubenInfo.estimate, 2) ~= 0	--未死亡
	t[3] = MathBit.andOp(self.m_CurFubenInfo.estimate, 4) ~= 0	--超时		
	self.m_CurFubenInfo.condition = t

	if isUpdata then
		self:OnEvent(define.EquipFb.Event.UpdateInfo)		
		if self.m_CurFubenInfo.auto and oldAuto ~= nil then
			self:AutoFuben(true)	
		end

		--不是玩家点击地面停止的自动副本
		if self.m_CurFubenInfo.auto == false and self.m_ClickMapStopAtup == false then
			local oHero = g_MapCtrl:GetHero()
			if oHero then
				oHero:StopWalk()
			end
		end
		--self:ReCheckGuideAutoFuben()
	else
		self.m_IsSendOverTime  = false
		self:OnEvent(define.EquipFb.Event.BeginFb)
		self:AutoFuben()	
	end

	self.m_CurFubenInfo.count = count

	--战前配置由服务器来负责
	--g_WarCtrl:SetLockPreparePartner(define.War.Type.EquipFuben, self.m_CurFubenInfo.auto)
	self.m_ClickMapStopAtup = false
	self.m_PassFubenInfo = nil
	self:ShowMapGuideEffect()
 end

--获取副本进行实践
 function CEquipFubenCtrl.GetDoingTimeStr(self)
	local time = self:GetDoingTime()
	local str = ""
	if time	< 0 then
		str = ""
	else
		local h = math.floor(time / 3600)
		local min = math.floor(time % 3600 / 60)
		local sec = time % 60
		str = (h ~= 0 ) and str..tostring(h).."时" or str
		str = (min ~= 0 ) and str..tostring(min).."分" or str
		str = str..tostring(sec).."秒"
	end
	return str, time
 end

 function CEquipFubenCtrl.GetDoingTime(self)
	if not self.m_CurFubenInfo or self.m_CurFubenInfo.time == false then
		return 0
	end
	local time = g_TimeCtrl:GetTimeS() - self.m_CurFubenInfo.time
	--如果超过副本时间，则同步超时状态
	if time > self:GetFubenTime() then
	 	self:CtrlC2GSRefreshEquipFBScene()
	end
 	return time
 end

 --获取副本通关时间
 function CEquipFubenCtrl.GetFubenTimeStr(self, floor)
 	local time = self:GetFubenTime(floor)
 	local str = ""
 	if time > 0 then
		local h = math.floor(time / 3600)
		local min = math.floor(time % 3600 / 60)
		local sec = time % 60
		str = (h ~= 0 ) and str..tostring(h).."时" or str
		str = (min ~= 0 ) and str..tostring(min).."分" or str
		--str = str..tostring(sec)
	end
	return str
 end

 --获取副本通关时间
 function CEquipFubenCtrl.GetFubenTime(self, floor)
	local time = 0
	local floorInfo = nil
	if floor then
		floorInfo = self:GetFloorBaseInfoByFloor(floor)

	elseif self.m_CurFubenInfo then
		floorInfo = self:GetFloorBaseInfoByFloor(self.m_CurFubenInfo.floor)	
	end
	if floorInfo and floorInfo.time then
		time = floorInfo.time * 60
	end
	return time
 end

 function CEquipFubenCtrl.IsOverTime(self )
 	local timeFb = self:GetFubenTime()
 	local timeDoing = self:GetDoingTime()
 	local b = false
 	if timeDoing > timeFb and timeDoing > 0 and timeFb > 0 then
 		b = true
 	end
 	return b
 end

 function CEquipFubenCtrl.GetPassCondition(self)
 	local t = nil
 	if self.m_CurFubenInfo and self.m_CurFubenInfo.condition then
 		t = self.m_CurFubenInfo.condition
 	end
 	return t
 end

--成功退出副本协议返回
function CEquipFubenCtrl.CtrlGS2CEndFBScene(self)
	if self.m_AutoFubenTimer ~= nil then
		Utils.DelTimer(self.m_AutoFubenTimer)
		self.m_AutoFubenTimer = nil
	end	
	self.m_CurFubenInfo = nil
	self:ShowMapGuideEffect()
	self:OnEvent(define.EquipFb.Event.EndFb)
end

--获取副本的基本信息
function CEquipFubenCtrl.GetFubenDetailInfo(self, fubenId)
	local t = {}
	if fubenId then
		local baseInfo = CEquipFubenCtrl.FubenInfo[fubenId] 
		if baseInfo then
			t.baseInfo = baseInfo
			t.infoList = CEquipFubenCtrl.FubenInfoList
		end
	end
	return t
end

--是否在装备副本中
function CEquipFubenCtrl.IsInEquipFB(self)
	return self.m_CurFubenInfo ~= nil
end

--层数转换
function CEquipFubenCtrl.CountConvert(self, count)
	local t = 
	{
		[1] = "一",
		[2] = "二",
		[3] = "三",
		[4] = "四",
		[5] = "五",
		[6] = "六",
		[7] = "七",
		[8] = "八",
		[9] = "九",
		[10] = "十",
	}
	local str = ""
	count = tonumber(count)
	if count <= 10 then
		str = t[count]
	elseif count < 20 then
		str = string.format("十%s", t[count % 10] ) 
	end
	return str
end
 
 --根据副本id获取该副本所有的关卡
 function CEquipFubenCtrl.GetFbListBaseInfoByFubenId(self, fubenId)
 	local t = {}
 	local d = data.equipfubendata.FLOOR
 	for id, info in pairs(d) do
 		if info.type == fubenId then 		
 			table.insert(t, info)
 		end
 	end
 	if next(t) then
		table.sort(t, function (a, b)
			return a.id < b.id
		end)	
 	end
 	return t
 end

--根据关卡id获取关卡的基本信息
function CEquipFubenCtrl.GetFloorBaseInfoByFloor(self, floor)
	local t = {}
 	local d = data.equipfubendata.FLOOR
 	for id, info in pairs(d) do
 		if info.id == floor then 		
 			t = info 
 			break
 		end
 	end
 	return t
end

--根据副本id，获取副本的基本信息
function CEquipFubenCtrl.GetFubenBaseInfoByFubenId(self, fubenId)
	local t = {}
 	local d = data.equipfubendata.FUBEN
 	for id, info in pairs(d) do
 		if info.id == fubenId then 		
 			t = info 
 			break
 		end
 	end
 	return t
end

--是否自动战斗
function CEquipFubenCtrl.IsAuto(self)
	local b = false
	if self.m_CurFubenInfo then
		b = (self.m_CurFubenInfo.auto == true)
	end
	return b
end

--获取正在进行的副本的信息
function CEquipFubenCtrl.GetCurFubenInfo(self)
	local t = {}
	if self.m_CurFubenInfo then
		t.data = self.m_CurFubenInfo 
		t.floorInfo = self:GetFloorBaseInfoByFloor(t.data.floor)
		t.fubenInfo = self:GetFubenBaseInfoByFubenId(t.floorInfo.type)
	end
	return t
end

--副本时间到的时候，同步到服务器
function CEquipFubenCtrl.CtrlC2GSRefreshEquipFBScene(self)
	local t = self:GetPassCondition()
	if t then
		--如果本地已经超时状态，就不用同步了
		if t[3] == true and self.m_IsSendOverTime == false then
			self.m_IsSendOverTime  = true
			nethuodong.C2GSRefreshEquipFBScene()
		end
	end
end

--设置自动战斗
function CEquipFubenCtrl.CtrlC2GSSetAutoEquipFuBen(self)
	if self.m_CurFubenInfo then
		local b = not self.m_CurFubenInfo.auto
		nethuodong.C2GSSetAutoEquipFuBen((b == true ) and 1 or 0)
	end
end

--通关结算界面协议返回
function CEquipFubenCtrl.CtrlGS2CEquipFBWarResult(self, star, sumStar, estimate, item, useTime, floor)
	self.m_PassFubenInfo = {}
	self.m_PassFubenInfo.star = star or 0
	self.m_PassFubenInfo.sumStar = sumStar or 0
	self.m_PassFubenInfo.estimate = estimate
	self.m_PassFubenInfo.useTime = useTime or 0
	self.m_PassFubenInfo.floor = floor or 0
 	local t = 
 	{
 		[1] = false,
 		[2] = false,
 		[3] = false,
	}
	t[1] = MathBit.andOp(self.m_PassFubenInfo.estimate, 1) ~= 0	--通关	
	t[2] = MathBit.andOp(self.m_PassFubenInfo.estimate, 2) ~= 0	--未死亡
	t[3] = MathBit.andOp(self.m_PassFubenInfo.estimate, 4) ~= 0	--超时		
	self.m_PassFubenInfo.condition = t
	self.m_PassFubenInfo.item = item
	self:OnEvent(define.EquipFb.Event.CompleteFB)
	local oView = CEquipFubenResultView:GetView()
	if oView then
		oView:SetPassContent()
	end
	g_GuideCtrl:CompleteEquipTipsGuide()
end

--通过关卡floorid获取关卡配置
function CEquipFubenCtrl.GetConfigByFloor(selff, floor)
	local t = {}
	local id = floor % 1000
	local d = data.equipfubendata.CONFIG
	if d[id] then
		t = d[id]
	end	
	return t
end

function CEquipFubenCtrl.ConverTimeString(self, time)
	local str = ""
	time = tonumber(time)
	if time	>= 0 then
		local h = math.floor(time / 3600)
		local min = math.floor(time % 3600 / 60)
		local sec = time % 60
		str = (h ~= 0 ) and str..tostring(h).."时" or str
		str = (min ~= 0 ) and str..tostring(min).."分" or str
		str = str..tostring(sec).."秒"
	end
	return str
end

function CEquipFubenCtrl.ShowWarTimeView(self)
	if not CEquipFubenWarView:GetView() then
		CEquipFubenWarView:ShowView()
	end	
end

function CEquipFubenCtrl.SwitchEnv(self, bWar)
	if self:IsInEquipFB() then
		if bWar then
			self:ShowWarTimeView()
		else
			self:AutoFuben()
		end
		self:ShowMapGuideEffect(bWar)
	end
end

--自动副本处理
function CEquipFubenCtrl.AutoFuben(self, force)
	if self.m_AutoFubenTimer ~= nil then
		Utils.DelTimer(self.m_AutoFubenTimer)
		self.m_AutoFubenTimer = nil
	end
	if self:IsAuto() and self:IsInEquipFB() and not g_WarCtrl:IsWar() then		
		local function wrap()
			if not self:IsAuto() then
				return false
			end		
			local oHero = g_MapCtrl:GetHero()
			if not oHero or g_WarCtrl:IsWar() then 
				return true
			end
			if self.m_CurFubenInfo and self.m_CurFubenInfo.nidList and next(self.m_CurFubenInfo.nidList) then				
				local npc = self.m_CurFubenInfo.nidList[1]
				local cNpc = {[1] = {}}
				cNpc[1].pos_info = {x = npc.x, y = npc.y, z = 0}
				cNpc[1].map_id = self.m_CurFubenInfo.mapId
				cNpc[1].npctype = npc.nno
				local taskData = 
				{
					acceptnpc = npc.nno,
					clientnpc = cNpc,
				}
				local oTask = CTask.NewByData(taskData)
				g_TaskCtrl:ClickTaskLogic(oTask, true)		
				return false
			end	
			return true
		end
		if force == true then
			wrap()
		else
			self.m_AutoFubenTimer = Utils.AddTimer(wrap, CEquipFubenCtrl.AutoDivtionTime, CEquipFubenCtrl.AutoDivtionTime)
		end
	end
	-- local oUI = g_GuideCtrl:GetGuideUI("equipfuben_auto_btn")
	-- if oUI then
	-- 	oUI:DelEffect("bordermove")
	-- end

	--新手第一次进副本会自动副本 
	if self:IsAuto() == false and self.m_CurFubenInfo and ((self:IsInEquipFB() and self.m_CurFubenInfo.floor == 1001) or self.m_AutoEnterFb == true) then
		 if not g_GuideCtrl:IsCustomGuideFinishByKey("FirstEnterEquipFb") or self.m_AutoEnterFb == true then		 	
			g_GuideCtrl:ReqCustomGuideFinish("FirstEnterEquipFb")
			Utils.AddTimer(callback(self, "AutoCallBack"), CEquipFubenCtrl.AutoDivtionTime, CEquipFubenCtrl.AutoDivtionTime)
		-- else
		-- 	self:ReCheckGuideAutoFuben()	
		end		
	end
end

function CEquipFubenCtrl.AutoCallBack(self)
	local oHero = g_MapCtrl:GetHero()
	if not oHero or g_WarCtrl:IsWar() or g_MapCtrl:IsLoading() then 
		return true
	end				
	if (self:IsInEquipFB() or self.m_AutoEnterFb == true) and self:IsAuto() == false then
		self:CtrlC2GSSetAutoEquipFuBen()
	end			
	return false
end

--停止自动副本
function CEquipFubenCtrl.StopAutoFuben(self)
	if self:IsAuto() then
		if self.m_AutoFubenTimer ~= nil then
			Utils.DelTimer(self.m_AutoFubenTimer)
			self.m_AutoFubenTimer = nil
		end		
		self.m_ClickMapStopAtup = true
		self:CtrlC2GSSetAutoEquipFuBen()
	end
end

--关卡基本奖励(1星的奖励)
function CEquipFubenCtrl.GetBasePassReward(self, floor)
	local t = {}
	if data.equipfubendata.FLOOR[floor] and data.equipfubendata.FLOOR[floor].star_1_reward then
		if #data.equipfubendata.FLOOR[floor].star_1_reward >= 1 then
			local id = data.equipfubendata.FLOOR[floor].star_1_reward[1]
			if data.rewarddata.EQUIPFUBEN[id] and  next(data.rewarddata.EQUIPFUBEN[id].base_reward) then
				local d = data.rewarddata.EQUIPFUBEN[id].base_reward[1]
				if d.sid and d.sid ~= "" then
					t = d
				end
			end
		end
	end
	return t
end

--解析奖励道具
function CEquipFubenCtrl.DecodeReward(self, reward)
	local t = {}
	if reward and reward ~= "" then
		local list = string.split(reward, "|")
		if list and next(list) then
			for i = 1, #list do
				local subList = string.split(list[i], ",")
				if subList then
					if #subList == 1 then
						local str = subList[1]
						local sid = nil
						local amount = 1
						if string.find(str, "amount") then
							sid, amount = g_ItemCtrl:SplitSidAndValue(str)
						else
							sid = tonumber(str)
						end														
							local d = {sid = sid, amount = amount}
						table.insert(t, d)

					elseif #subList > 1 then
						for k = 1, #subList do
							local sid = nil
							local amount = 1
							if string.find(list[i], "amount") then
								sid, amount = g_ItemCtrl:SplitSidAndValue(subList[k])
							else
								sid = tonumber(subList[k])
							end								
							local oItem = CItem.NewBySid(sid)
							if oItem:IsFit() then
								local d = {sid = sid, amount = amount}
								table.insert(t, d)
								break
							end
						end					
					end
				end
			end
		end
	end
	return t
end

function CEquipFubenCtrl.ResetCtrl(self)
	self.m_FubenInfoList = {}
	self.m_TodayBuy = 0
	self.m_RemainTime = 0
	self.m_CurFubenInfo = nil
	self.m_PassFubenInfo = nil
	self.m_ClickMapStopAtup = false
	self.m_IsSendOverTime  = false
	if self.m_AutoFubenTimer then
		Utils.DelTimer(self.m_AutoFubenTimer)
		self.m_AutoFubenTimer = nil
	end
	self.m_ReOpenEquip = false
	self.m_AutoEnterFb = false
	self:ClearMapEffect()
	self:OnEvent(define.EquipFb.Event.EndFb)	
end

function CEquipFubenCtrl.GetFubenCanBuyTime(self, fubenId)
	local time = 0
	local d = data.equipfubendata.PLAYER_CONFIG
	if self.m_FubenInfoList and d and d.buy_limit and d.buy_times then
		for i = 1, #self.m_FubenInfoList do
			local info = self.m_FubenInfoList[i] 
			if info.f_id == fubenId then
				local buy_limit = tonumber(d.buy_limit.val)
				local buy_times = tonumber(d.buy_times.val)	
				time = buy_limit - self.m_TodayBuy
				if buy_times - info.buy < time then
					time = buy_times - info.buy								
				end
				break
			end
		end
	end
	return time
end

function CEquipFubenCtrl.GetFubenHaveBuyTime(self, fubenId)
	return self.m_TodayBuy
end

function CEquipFubenCtrl.GetBuyPrice(self, fubenId, curBuy)
	local price = 0
	local haveBuy = self:GetFubenHaveBuyTime(fubenId)	
	for i = (haveBuy + 1), (haveBuy + curBuy) do
		price = self:GetBuyPricePerTime(i) + price		
	end
	return price
end

function CEquipFubenCtrl.GetBuyPricePerTime(self, time)
	local price = 0
	time = time or 1
	local d = data.equipfubendata.RESET_COST
	if d then
		if time > d[#d].num then
			price = d[#d].cost 			
		else
			for i = 1, #d do
				if time >= d[i].num then
					price = d[i].cost 				
				else
					break
				end
			end
		end
	end
	return price
end

function CEquipFubenCtrl.CtrlC2GSBuyEquipPlayCnt(self, cnt, cost, fubenId)
	nethuodong.C2GSBuyEquipPlayCnt(cnt, cost, fubenId)
end

function CEquipFubenCtrl.ShowWarResult(self, oCmd)
	if oCmd.win then
		if CEquipFubenResultView:GetView() == nil then
			CEquipFubenResultView:ShowView(function (oView)
				if g_EquipFubenCtrl.m_PassFubenInfo and next(g_EquipFubenCtrl.m_PassFubenInfo) ~= nil then
					oView:SetPassContent()
				else
					oView:SetResultContent(true, oCmd.war_id)
				end
				
			end)
		end
	else
		if CEquipFubenResultView:GetView() == nil then
			CEquipFubenResultView:ShowView(function (oView)
				oView:SetResultContent(false, oCmd.war_id)
			end)
		end
	end
end

function CEquipFubenCtrl.CanAutoFuben(self)
	local path = string.format("equipfuben_max_pass_floor")
	local maxFloor = IOTools.GetRoleData(path) or 0
	local curFloor = 99
	if self.m_CurFubenInfo and self.m_CurFubenInfo.floor then
		curFloor = self.m_CurFubenInfo.floor % 1000
	end
	--return maxFloor >= curFloor
	--现在都能自动挂机
	return true
end

function CEquipFubenCtrl.ShowMapGuideEffect(self, bWar)
	if self:IsInEquipFB() and bWar ~= true then
		if self.m_CurFubenInfo and self.m_CurFubenInfo.floor then
			local mapInfo = data.equipfubendata.MAP_TIPS[self.m_CurFubenInfo.floor]
			if not mapInfo then
				self:ClearMapEffect()
				return
			end
			local cnt = self.m_CurFubenInfo.count
			if self.m_MapEffId == self.m_CurFubenInfo.floor * 100 + cnt then
				return
			end
			self:ClearMapEffect()
			self.m_MapEffId = self.m_CurFubenInfo.floor * 100 + cnt
			local t = mapInfo[string.format("step%d", cnt)]
			if t then				
				for i, v in ipairs(t) do
					if v and v ~= "" then
						local info = string.split(v, "|")
						if #info == 3 then
							local path = string.format("Effect/Game/game_eff_1167/Prefabs/game_eff_1167.prefab")
							local function cb(obj)								
								obj:SetLocalRotation(Quaternion.Euler(0, 0, tonumber(info[3]))) 
							end
							local oEffect = CEffect.New(path, UnityEngine.LayerMask.NameToLayer("MapTerrain"), true, cb)
							local worldPos = {}
							worldPos.x = tonumber(info[1])
							worldPos.y = tonumber(info[2])
							worldPos.z = 95
							oEffect:SetPos(worldPos)
							oEffect:SetName(string.format("equipfb_%d_eff_%d", self.m_CurFubenInfo.floor, i))							
							g_EffectCtrl:AddEffect(oEffect)
							table.insert(self.m_EffectList, oEffect) 
						end
					end						
				end
			end
		end
	else
		self:ClearMapEffect()
	end
end

function CEquipFubenCtrl.ClearMapEffect(self)
	if self.m_EffectList and next(self.m_EffectList) then
		for i, v in ipairs(self.m_EffectList) do
				g_EffectCtrl:DelEffect(v:GetInstanceID())
			v = nil
		end
	end
	self.m_MapEffId = nil
end

function CEquipFubenCtrl.ReCheckGuideAutoFuben(self)
	if self:IsAuto() == false and self:IsInEquipFB() and self.m_CurFubenInfo.floor == 1001 and g_GuideCtrl:IsFirstEquipFuben() and not g_WarCtrl:IsWar() then
		if self.m_ShowGuideTipsTimer ~= nil then
			Utils.DelTimer(self.m_ShowGuideTipsTimer)
			self.m_ShowGuideTipsTimer = nil
		end		
		local function cb()
			if not g_WarCtrl:IsWar() and self:IsInEquipFB() and self:IsAuto() == false then				
				local oUI = g_GuideCtrl:GetGuideUI("equipfuben_auto_btn")
				if oUI then
					oUI:AddEffect("bordermove", nil, nil, 5)
				end				
			end	
		end		
		self.m_ShowGuideTipsTimer = Utils.AddTimer(cb, 0, 5)
	end
end

function CEquipFubenCtrl.GetFubenRemainTime(self)
	return self.m_RemainTime 
end

function CEquipFubenCtrl.CtrlGS2CSweepEquipFBResult(self, sweepInfo)
	local dDdata = {
		rewardList = sweepInfo,
	}
	self:OnEvent(define.EquipFb.Event.SwpeepResult, dDdata)
end

return CEquipFubenCtrl

