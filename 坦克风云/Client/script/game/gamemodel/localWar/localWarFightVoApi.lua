--区域战战斗相关的操作放在这里
localWarFightVoApi=
{
	dataExpireTime=0,		--数据过期的时间, 如果serverTime大于这个时间的话就需要重新向后台拉取数据
	initFlag=nil,		--是否已经进行过初始化
	endFlag=false,			--战斗结束的标识
	playerList={},			--所有的玩家数据, table的key是玩家ID, value是localWarPlayerVo
	cityList={},			--所有的据点数据, table的key是城市ID, value是localWarCityVo
	cityDamageList={},		--每个城市每个军团造成的伤害排行
	allianceList={},		--本次比赛的4个军团
	defenderAlliance=nil,	--本次比赛的防守方
	startTime=0,			--本次战斗的开始时间
	baseBlock=false,		--主基地已经被爆掉的标识
	selfPlayer=nil,			--玩家自己的localWarPlayerVo
	lastBattleTime=0,		--上一次战斗的时间戳
	order={},				--军团指令, e.g.:{{"a1",4},{"a3",3}}
}

function localWarFightVoApi:showMap(layerNum)
	local status=localWarVoApi:checkStatus()
	if(status==20 or status==21)then
		local signupTime=G_getWeeTs(base.serverTime)
		self.startTime=signupTime+localWarCfg.startWarTime[1]*3600+localWarCfg.startWarTime[2]*60
		require "luascript/script/config/gameconfig/localWar/localWarMapCfg"
		require "luascript/script/game/scene/gamedialog/localWar/localWarMapScene"
		require "luascript/script/game/gamemodel/localWar/localWarCityVo"
		require "luascript/script/game/gamemodel/localWar/localWarPlayerVo"
		require "luascript/script/game/gamemodel/localWar/localWarAllianceVo"
		if(base.serverTime>self.dataExpireTime)then
			local function onRefresh()
				localWarMapScene:show(layerNum,1)
			end
			self:refreshData(onRefresh)
		else
			localWarMapScene:show(layerNum)
		end
	else
		do return end
	end
end

--点击战场城市, 弹出面板
function localWarFightVoApi:showCityDialog(cityID,layerNum)
	require "luascript/script/game/scene/gamedialog/localWar/localWarCitySmallDialog"
	local sd=localWarCitySmallDialog:new(cityID)
	sd:init(layerNum)
	self.cityDialog=sd
end

--给城市下达指令
function localWarFightVoApi:showCityOrderDialog(cityID,layerNum)
	require "luascript/script/game/scene/gamedialog/localWar/localWarCityOrderSmallDialog"
	local sd=localWarCityOrderSmallDialog:new(cityID)
	sd:init(layerNum)
end

--返回所有玩家
function localWarFightVoApi:getPlayers()
	if(self.playerList)then
		return self.playerList
	else
		return {}
	end
end

--根据ID获取玩家的localWarPlayerVo
--param ID: 玩家ID, 如果不传的话默认是当前登录用户
function localWarFightVoApi:getPlayer(id)
	if(id==nil)then
		return self.selfPlayer
	end
	return self.playerList[id]
end

--根据ID获取城市的localWarCityVo
--param ID: 城市ID
function localWarFightVoApi:getCity(id)
	return self.cityList[id]
end

--获取本次战斗所有城市的数据
function localWarFightVoApi:getCityList()
	return self.cityList
end

--获取某个城市的军团伤害列表
--param ID: 城市ID
function localWarFightVoApi:getCityDamageList(cityID)
	return self.cityDamageList[cityID] or {}
end

--获取此次对战的军团
function localWarFightVoApi:getAllianceList()
	return self.allianceList
end

--获取此次战斗的防守方军团
function localWarFightVoApi:getDefenderAlliance()
	return self.defenderAlliance
end

--获取某座城市里面某个军团活着的玩家列表
function localWarFightVoApi:getLivePlayersInCity(cityID,aid)
	local result={}
	for id,player in pairs(self.playerList) do
		if(player.canMoveTime<=base.serverTime and player.arriveTime<=base.serverTime and player.cityID==cityID and player.allianceID==aid)then
			table.insert(result,player)
		end
	end
	return result
end

--获取城中所有防御者的列表
--按照到达时间和uid排序
function localWarFightVoApi:getDefendersInCity(cityID)
	local cityVo=self:getCity(cityID)
	local result={}
	if(cityVo and cityVo.allianceID>0)then
		for id,player in pairs(self.playerList) do
			if(player.canMoveTime<=base.serverTime and player.arriveTime<=base.serverTime and player.cityID==cityID and player.allianceID==cityVo.allianceID)then
				local insertFlag=false
				for k,v in pairs(result) do
					if(player.arriveTime<v.arriveTime or (player.arriveTime==v.arriveTime and player.uid<v.uid))then
						table.insert(result,k,player)
						insertFlag=true
						break
					end
				end
				if(insertFlag==false)then
					table.insert(result,player)
				end
			end
		end
	end
	if(cityVo and cityVo.npc==1)then
		local playerVo=localWarPlayerVo:new()
		playerVo:init({0,getlocal("local_war_npc_name"),cityVo.allianceID,cityID,0,0,0,cityVo.id,0})
		table.insert(result,playerVo)
	end
	return result
end

--获取城外所有进攻者的列表
function localWarFightVoApi:getAttackersInCity(cityID)
	local cityVo=self:getCity(cityID)
	local result={}
	if(cityVo)then
		for id,player in pairs(self.playerList) do
			if(player.canMoveTime<=base.serverTime and player.arriveTime<=base.serverTime and player.cityID==cityID and player.allianceID~=cityVo.allianceID)then
				local insertFlag=false
				for k,v in pairs(result) do
					if(player.arriveTime<v.arriveTime or (player.arriveTime==v.arriveTime and player.uid<v.uid))then
						table.insert(result,k,player)
						insertFlag=true
						break
					end
				end
				if(insertFlag==false)then
					table.insert(result,player)
				end
			end
		end
		return result
	else
		return result
	end
end

--检测城市是否在战斗状态
--只要城外有进攻者存在就算是战斗状态
function localWarFightVoApi:checkCityInWar(cityID)
	local cityVo=self:getCity(cityID)
	local result={}
	if(cityVo)then
		for id,player in pairs(self.playerList) do
			if(player.canMoveTime<=base.serverTime and player.arriveTime<=base.serverTime and player.cityID==cityID and player.allianceID~=cityVo.allianceID)then
				return true
			end
		end
		return false
	else
		return false
	end
end

--获取本次区域战开启的时间戳
function localWarFightVoApi:getStartTime()
	return self.startTime
end

--检查某个城市是否可以过去
--param cityID: 要去的城市ID
--return 0: 可以出发
--return 1: 玩家死了, 处于无法移动的状态
--return 2: 玩家正在路上, 无法移动
--return 3: 要去的城市与玩家当前城市不相邻
--return 4: 围城的部队无法向非友方城市撤退
--return 5: 主基地被打爆了 , 不能移动
--return 6: 当前就在这个城
--return 7: 不能去集结点
function localWarFightVoApi:checkCityCanReach(cityID)
	if(self:checkBaseBlock())then
		return 5
	end
	local player=self:getPlayer()
	if(player.canMoveTime>base.serverTime)then
		return 1
	end
	if(player.arriveTime>base.serverTime)then
		return 2
	end
	if(player.cityID==cityID)then
		return 6
	end
	local startCity=self:getCity(player.cityID)
	local canReach=false
	for k,v in pairs(startCity.cfg.adjoin) do
		if(v==cityID)then
			canReach=true
			break
		end
	end
	if(canReach==false)then
		return 3
	end
	local targetCity=self:getCity(cityID)
	if(startCity.allianceID~=player.allianceID and targetCity.allianceID~=player.allianceID)then
		return 4
	end
	for k,v in pairs(localWarMapCfg.homeID) do
		if(v==cityID)then
			return 7
		end
	end
	return 0
end

--检查一下当前是否在显示玩家战斗所在城市的面板
--因为如果在这种情况下玩家的死亡弹板要延迟弹出
function localWarFightVoApi:checkShowSelfCity()
	if(self.cityDialog)then
		if(self.cityDialog.cityID==self.selfPlayer.battleCity and self.selfPlayer.arriveTime<=base.serverTime)then
			return true
		end
	end
	return false
end

--向后台发请求拉所有数据, 刷新本地数据
function localWarFightVoApi:refreshData(callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data then
				local serverData=sData.data.areaWarserver
				if(self.initFlag~=true)then
					self.initFlag=true
					base:addNeedRefresh(self)
					local function activeListener(event,data)
						localWarFightVoApi:refreshData()
					end
					localWarFightVoApi.activeListener=activeListener
					eventDispatcher:addEventListener("game.active",localWarFightVoApi.activeListener)
				end
				if(base.serverTime<self.startTime)then
					self.dataExpireTime=self.startTime + math.random(0,5)
					self.lastBattleTime=self.startTime
				elseif(base.serverTime<self.startTime + localWarCfg.maxBattleTime)then
					self.dataExpireTime=base.serverTime + 120 + math.random()*3 - 6
					self.lastBattleTime=base.serverTime - base.serverTime%20
				else
					self.dataExpireTime=base.serverTime + 864000
					self.lastBattleTime=self.startTime + localWarCfg.maxBattleTime
				end
				if(#self.allianceList==0)then
					if(serverData.alliancesInfo)then
						for id,value in pairs(serverData.alliancesInfo) do
							local allianceVo=localWarAllianceVo:new()
							allianceVo:init(value)
							if(tonumber(value.ranking)==5)then
								self.defenderAlliance=allianceVo
							else
								table.insert(self.allianceList,allianceVo)
							end
						end
					end
					local function sortFunc(a,b)
						if(a.side==b.side)then
							return a.id<b.id
						else
							return a.side<b.side
						end
					end
					table.sort(self.allianceList,sortFunc)
				end
				if(serverData.usersActionInfo)then
					local eventTb={}
					for key,value in pairs(serverData.usersActionInfo) do
						local uid=tonumber(value[1])
						if(self.playerList[uid]==nil)then
							local playerVo=localWarPlayerVo:new()
							self.playerList[uid]=playerVo
							if(uid==playerVoApi:getUid())then
								self.selfPlayer=playerVo
							end
						end
						self.playerList[uid]:init(value)
						table.insert(eventTb,self.playerList[uid])
					end
					eventDispatcher:dispatchEvent("localWar.battle",{type="player",data=eventTb})
				end
				if(SizeOfTable(self.cityList)==0)then
					for id,cityCfg in pairs(localWarMapCfg.cityCfg) do
						local cityVo=localWarCityVo:new()
						cityVo:init(cityCfg)
						self.cityList[id]=cityVo
					end
				end
				if(serverData.placesInfo)then
					local eventTb={}
					for cityID,cityData in pairs(serverData.placesInfo) do
						if(self.cityList[cityID])then
							self.cityList[cityID].allianceID=tonumber(cityData[1]) or 0
							self.cityList[cityID].hp=tonumber(cityData[2]) or 0
							self.cityList[cityID].npc=tonumber(cityData[3]) or 0
							table.insert(eventTb,self.cityList[cityID])
						end
					end
					eventDispatcher:dispatchEvent("localWar.battle",{type="city",data=eventTb})
				end
				if(serverData.command and type(serverData.command)=="table")then
					self.order={}
					for k,v in pairs(serverData.command) do
						if(v[1] and self.cityList[v[1]] and type(v[2])=="number")then
							self.order[k]={v[1],v[2]}
						end
					end
					local eventTb=self.order
					eventDispatcher:dispatchEvent("localWar.battle",{type="order",data=eventTb})
				end
				if(serverData.allianceDeHp)then
					self.cityDamageList=serverData.allianceDeHp
				end
				self:checkSetBaseBlock()
				if(serverData.over)then
					self:over(serverData.over)
					do return end
				end
			end
			if(callback)then
				callback()
			end
		else
			self.dataExpireTime=base.serverTime + 30 + math.random()*3 - 6
		end
	end
	local isShowLoading
	if(#self.allianceList==0)then
		isShowLoading=true
	else
		isShowLoading=false
	end
	if(isShowLoading)then
		socketHelper:localWarRefresh(true,playerVoApi:getPlayerAid(),onRequestEnd,isShowLoading)
	else
		socketHelper:localWarRefresh(false,playerVoApi:getPlayerAid(),onRequestEnd,isShowLoading)
	end
end

--向目标城市移动
--param targetID: 要去的城市ID
function localWarFightVoApi:move(targetID,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data and sData.data.areaWarserver then
				local serverData=sData.data.areaWarserver
				if(serverData.over)then
					self:over(serverData.over)
					do return end
				end
				local playerData=serverData.usersActionInfo[1]
				local player=self:getPlayer()
				player:init(playerData)
				if(callback)then
					callback()
				end
			end
		end
	end
	socketHelper:localWarMove(playerVoApi:getPlayerAid(),targetID,onRequestEnd)
end

--复活
function localWarFightVoApi:revive(callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if(ret==true)then
			local serverData=sData.data.areaWarserver
			if(serverData.over)then
				self:over(serverData.over)
				do return end
			end
			if(serverData.usersActionInfo and serverData.usersActionInfo[1])then
				self.selfPlayer:init(serverData.usersActionInfo[1])
			end
			if(callback)then
				callback()
			end
		end
	end
	socketHelper:localWarRevive(playerVoApi:getPlayerAid(),playerVoApi:getUid(),onRequestEnd)
end

--发送指挥命令
--param cityID: 指令所指向的城市
--param type: 指令类型
function localWarFightVoApi:sendOrder(cityID,type,callback)
	local flag=false
	for k,v in pairs(self.order) do
		if(v[1]==cityID)then
			v[2]=type
			flag=true
			break
		end
	end
	if(flag==false)then
		table.insert(self.order,{cityID,type})
	end
	if(#self.order>2)then
		table.remove(self.order,1)
	end
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if(ret==true)then
			local serverData=sData.data.areaWarserver
			if(serverData.over)then
				self:over(serverData.over)
				do return end
			end
			if(callback)then
				callback()
			end
		end
	end
	socketHelper:localWarOrder(playerVoApi:getPlayerAid(),playerVoApi:getUid(),self.order,onRequestEnd)
end

--战斗是否已经结束
function localWarFightVoApi:checkIsEnd()
	return self.endFlag
end

--检测自己的主基地是否爆掉了, 如果主基地爆掉了玩家就不能再进行操作了
function localWarFightVoApi:checkBaseBlock()
	return self.baseBlock
end

function localWarFightVoApi:checkSetBaseBlock()
	for cityID,cityVo in pairs(self.cityList) do
		if(cityVo.cfg.type==1)then
			local index
			for k,v in pairs(localWarMapCfg.baseCityID) do
				if(v==cityID)then
					index=k
					break
				end
			end
			if(self.allianceList[index] and cityVo.allianceID~=self.allianceList[index].id)then
				if(self.allianceList[index].id==playerVoApi:getPlayerAid())then
					self.baseBlock=true
					self.selfPlayer=nil
				end
				for uid,player in pairs(self.playerList) do
					if(player.allianceID==self.allianceList[index].id)then
						self.playerList[uid]=nil
					end
				end
			end
		end
	end
end

--处理后台的推送请求
function localWarFightVoApi:receiveServerPush(data)
	if(data.bts)then
		self.lastBattleTime=tonumber(data.bts)
	end
	if(data.usersActionInfo)then
		local eventTb={}
		for k,v in pairs(data.usersActionInfo) do
			local id=tonumber(v[1])
			if(self.playerList[id]==nil)then
				local playerVo=localWarPlayerVo:new()
				self.playerList[id]=playerVo
				if(id==playerVoApi:getUid())then
					self.selfPlayer=playerVo
				end
			end
			self.playerList[id]:init(v)
			table.insert(eventTb,self.playerList[id])
		end
		eventDispatcher:dispatchEvent("localWar.battle",{type="player",data=eventTb})
	end
	if(data.placesInfo)then
		local eventTb={}
		local checkFlag=false
		for cityID,cityData in pairs(data.placesInfo) do
			if(self.cityList[cityID])then
				self.cityList[cityID].allianceID=tonumber(cityData[1]) or 0
				self.cityList[cityID].hp=tonumber(cityData[2]) or 0
				self.cityList[cityID].npc=tonumber(cityData[3]) or 0
				table.insert(eventTb,self.cityList[cityID])
				--如果主基地爆掉了, 那么玩家就不能做操作了
				if(self.cityList[cityID].cfg.type==1)then
					checkFlag=true
				end
			end
		end
		if(checkFlag)then
			self:checkSetBaseBlock()
		end
		eventDispatcher:dispatchEvent("localWar.battle",{type="city",data=eventTb})
	end
	if(data.command and type(data.command)=="table")then
		self.order={}
		for k,v in pairs(data.command) do
			if(v[1] and self.cityList[v[1]] and type(v[2])=="number")then
				self.order[k]={v[1],v[2]}
			end
		end
		local eventTb=self.order
		eventDispatcher:dispatchEvent("localWar.battle",{type="order",data=eventTb})
	end
	if(data.allianceDeHp)then
		self.cityDamageList=data.allianceDeHp
	end
	if(data.over)then
		self:over(data.over)
	end
end

function localWarFightVoApi:over(data)
	if(localWarMapScene and localWarMapScene.isShow and self.endFlag==false)then
		local endTs
		if(data.ts and tonumber(data.ts)>0)then
			endTs=tonumber(data.ts)
		else
			endTs=base.serverTime
		end
		require "luascript/script/game/scene/gamedialog/localWar/localWarResultSmallDialog"
		local sd=localWarResultSmallDialog:new(tonumber(data.winner),endTs)
		sd:init(localWarMapScene.layerNum + 1)
	else
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("world_war_matchStatus2"),30)
	end
	self.endFlag=true
	eventDispatcher:dispatchEvent("localWar.battle",{type="over"})
	localWarVoApi:getApplyData(nil,false)
end

--获取下回合战斗的时间戳
function localWarFightVoApi:getNextBattleTime()
	return self.lastBattleTime + 20
end

--tick无需解释
function localWarFightVoApi:tick()
	if(self.endFlag)then
		do return end
	end
	if(base.serverTime>=self.dataExpireTime)then
		self:refreshData()
	end
	local eventTb={}
	for id,player in pairs(self.playerList) do
		if(player.arriveTime==base.serverTime or player.canMoveTime==base.serverTime)then
			table.insert(eventTb,player)
		end
	end
	if(#eventTb>0)then
		eventDispatcher:dispatchEvent("localWar.battle",{type="player",data=eventTb})
	end
end

function localWarFightVoApi:clear()
	base:removeFromNeedRefresh(self)
	self.dataExpireTime=0
	self.initFlag=nil
	self.endFlag=false
	self.playerList={}
	self.cityList={}
	self.allianceList={}
	self.defenderAlliance=nil
	self.startTime=0
	self.baseBlock=false
	self.selfPlayer=nil
	self.selfTroops=nil
	self.lastBattleTime=0
	self.order={}
	eventDispatcher:removeEventListener("game.active",localWarFightVoApi.activeListener)
end