--团队跨服战战斗相关的操作放在这里
serverWarTeamFightVoApi=
{
	dataExpireTime=0,		--数据过期的时间, 如果serverTime大于这个时间的话就需要重新向后台拉取数据
	playerList=nil,			--所有的玩家数据, table的key是玩家ID, value是serverWarTeamPlayerVo
	cityList=nil,			--所有的据点数据, table的key是城市ID, value是serverWarTeamCityVo
	battleData=nil,			--本场比赛的serverWarTeamBattleVo
	allianceList=nil,		--本次比赛的两个军团, 第一个元素是红方, 第二个元素是蓝方
	baseTroopsLeft={1,1},	--双方剩余主基地NPC数目的起始序号
	connected=false,		--是否已经连接到战斗服务器
	startTime=0,			--本次战斗的开始时间
	order={},				--军团指令, e.g.:{{"a1",4},{"a3",3}}
	selfPlayer=nil,			--玩家自己的serverWarTeamPlayerVo
	buffData=nil,			--自己购买的buff数据
	gems=0,					--玩家带过来的金
	mapCfg=nil,				--本次战斗的地图配置
	pointTb={0,0},			--红蓝双方比分
	pointExpireTime=0,		--比分的过期时间
}

function serverWarTeamFightVoApi:showMap(layerNum,data)
	self.battleData=data
	self.startTime=serverWarTeamVoApi:getOutBattleTime(self.battleData.roundID,self.battleData.battleID)
	self.mapCfg=serverWarTeamFightVoApi:getMapCfg()
	local function onSocketConnected()
		require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamMapScene"
		require "luascript/script/game/gamemodel/serverWarTeam/serverWarTeamCityVo"
		require "luascript/script/game/gamemodel/serverWarTeam/serverWarTeamPlayerVo"
		if(base.serverTime>self.dataExpireTime)then
			local function onRefresh()
				serverWarTeamMapScene:show(layerNum,1)
				base:addNeedRefresh(self)
			end
			self:refreshData(onRefresh)
		else
			serverWarTeamMapScene:show(layerNum,1)
		end
	end
	if(self.connected)then
		onSocketConnected()
	else
		require "luascript/script/netapi/socketHelper2"
		local function connectHandler(...)
			print("成功连接socket2!")
			serverWarTeamFightVoApi.connected=true
			onSocketConnected()
		end
        --[[
		if(platCfg.platServerWarUrl[G_curPlatName()])then
			socketHelper2:socketConnect(platCfg.platServerWarUrl[G_curPlatName()][1],platCfg.platServerWarUrl[G_curPlatName()][2],connectHandler)
		end
        ]]
        if serverWarTeamVoApi.socketHost then
        	socketHelper2:socketConnect(serverWarTeamVoApi.socketHost["host"],serverWarTeamVoApi.socketHost["port"],connectHandler)
        elseif base.kfzUrl~=nil then
        	local kfzArr=Split(base.kfzUrl,",")
        	socketHelper2:socketConnect(kfzArr[1],kfzArr[2],connectHandler)
        end

	end
end

--购买buff的面板
function serverWarTeamFightVoApi:showBuffDialog(buffID,layerNum)
	require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamBuffDialog"
	local sd=serverWarTeamBuffDialog:new(buffID)
	sd:init(layerNum)
end

--点击战场城市, 弹出面板
function serverWarTeamFightVoApi:showCityDialog(cityID,layerNum)
	require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamCitySmallDialog"
	local sd=serverWarTeamCitySmallDialog:new(cityID)
	sd:init(layerNum)
	self.cityDialog=sd
end

--给城市下达指令
function serverWarTeamFightVoApi:showCityOrderDialog(cityID,layerNum)
	require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamCityOrderSmallDialog"
	local sd=serverWarTeamCityOrderSmallDialog:new(cityID)
	sd:init(layerNum)
end

function serverWarTeamFightVoApi:showSelfTroopDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamCurTroopsDialog"
	local td=serverWarTeamCurTroopsDialog:new()
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("serverwarteam_title"),true,layerNum+1)
	sceneGame:addChild(dialog,layerNum+1)
end

--获取地图配置
function serverWarTeamFightVoApi:getMapCfg()
	require "luascript/script/config/gameconfig/serverWarTeam/serverWarTeamMapCfg"
	return serverWarTeamMapCfg
end

--获取地图尺寸
function serverWarTeamFightVoApi:getMapSize()
	return CCSizeMake(640,960)
end

--返回所有玩家
function serverWarTeamFightVoApi:getPlayers()
	--test data
	-- if(self.playerList)then
	-- 	return self.playerList
	-- end
	-- self.playerList={}
	-- for i=1,99 do
	-- 	local playerVo=serverWarTeamPlayerVo:new()
	-- 	playerVo.uid=i
	-- 	playerVo.serverID=base.curZoneID
	-- 	if(i%2==0)then
	-- 		playerVo.allianceID=playerVoApi:getPlayerAid()
	-- 		playerVo.cityID="a1"
	-- 		playerVo.side=1
	-- 	else
	-- 		playerVo.allianceID=999
	-- 		playerVo.cityID="a15"
	-- 		playerVo.side=2
	-- 	end
	-- 	playerVo.id=playerVo.serverID.."-"..playerVo.allianceID.."-"..playerVo.uid
	-- 	playerVo.name="player"..i
	-- 	playerVo.arriveTime=0
	-- 	playerVo.lastCityID=playerVo.cityID
	-- 	playerVo.canMoveTime=0
	-- 	playerVo.lastEnemyID=nil
	-- 	playerVo.battleTime=0
	-- 	playerVo.battleCity=0
	-- 	playerVo.speedUpNum=0
	-- 	self.playerList[i]=playerVo
	-- end
	-- local playerVo=serverWarTeamPlayerVo:new()
	-- playerVo.uid=playerVoApi:getUid()
	-- playerVo.serverID=base.curZoneID
	-- playerVo.allianceID=playerVoApi:getPlayerAid()
	-- playerVo.cityID="a1"
	-- playerVo.side=1
	-- playerVo.id=playerVo.serverID.."-"..playerVo.allianceID.."-"..playerVo.uid
	-- playerVo.name=playerVoApi:getPlayerName()
	-- playerVo.arriveTime=0
	-- playerVo.lastCityID=playerVo.cityID
	-- playerVo.canMoveTime=0
	-- playerVo.lastEnemyID=nil
	-- playerVo.battleTime=0
	-- playerVo.battleCity=0
	-- playerVo.speedUpNum=0
	-- playerVo.role=
	-- table.insert(self.playerList,playerVo)
	-- self.selfPlayer=playerVo
	-- do return self.playerList end
	--test end
	if(self.playerList)then
		return self.playerList
	else
		return {}
	end
end

--根据ID获取玩家的serverWarTeamPlayerVo
--param ID: 玩家ID, 如果不传的话默认是当前登录用户
function serverWarTeamFightVoApi:getPlayer(id)
	if(id==nil)then
		--test data
		-- if(self.selfPlayer==nil)then
		-- 	self:getPlayers()
		-- end
		--test end
		return self.selfPlayer
	end
	--如果ID是npc-1这样的格式, 那么说明要查找的是NPC
	local pos=string.find(id,"npc-")
	if(pos and pos>=0)then
		local player=serverWarTeamPlayerVo:new()
		index=string.sub(id,pos + 4)
		player.id=id
		player.uid=index
		player.name=getlocal("serverwarteam_npcName",{index})
		player.canMoveTime=0
		player.isNpc=true
		return player
	end
	return self.playerList[id]
end

--根据ID获取城市的serverWarTeamCityVo
--param ID: 城市ID, 如果不传的话默认是当前登录用户
function serverWarTeamFightVoApi:getCity(id)
	return self.cityList[id]
end

--获取本次战斗所有城市的数据
function serverWarTeamFightVoApi:getCityList()
	--test data
	-- if(self.cityList)then
	-- 	return self.cityList
	-- end
	-- self.cityList={}
	-- for id,cityCfg in pairs(self.mapCfg.cityCfg) do
	-- 	local cityVo=serverWarTeamCityVo:new()
	-- 	cityVo:init(cityCfg)
	-- 	self.cityList[id]=cityVo
	-- end
	-- do return self.cityList end
	--test end
	return self.cityList
end

--获取此次对战的两个军团
function serverWarTeamFightVoApi:getAllianceList()
	--test data
	-- self.allianceList={}
	-- for i=1,2 do
	-- 	local allianceVo=serverWarTeamAllianceVo:new()
	-- 	allianceVo:init({aid=i,zid=i,name="alliance"..i,apply_at=i,basetroops=3,commander="commander"..i,level=30,fight=9999,num=30})
	-- 	self.allianceList[i]=allianceVo
	-- end
	--test end
	return self.allianceList
end

--获取所有的购买buff的数据
function serverWarTeamFightVoApi:getBuffData()
	return self.buffData or {}
end

--获取比分
function serverWarTeamFightVoApi:getPoints()
	--test data
	-- do return {37800,99999} end
	--test end
	return self.pointTb
end

--获取基地剩余NPC部队的数目
function serverWarTeamFightVoApi:getBaseTroopsLeft()
	return self.baseTroopsLeft
end

--获取某座城市里面某一方活着的玩家列表
function serverWarTeamFightVoApi:getLivePlayersInCity(cityID,side)
	local result={}
	for id,player in pairs(self.playerList) do
		if(player.canMoveTime<=base.serverTime and player.arriveTime<=base.serverTime and player.cityID==cityID and player.side==side)then
			table.insert(result,player)
		end
	end
	return result
end

--获取某座城里面某一方所有玩家的列表
function serverWarTeamFightVoApi:getAllPlayersInCity(cityID,side)
	local result={}
	for id,player in pairs(self:getPlayers()) do
		if(player.arriveTime<=base.serverTime and player.cityID==cityID and player.side==side)then
			table.insert(result,player)
		end
	end
	return result
end

--获取本次军团战开启的时间戳
function serverWarTeamFightVoApi:getStartTime()
	return self.startTime
end

--获取玩家携带的金币数
function serverWarTeamFightVoApi:getGems()
	return self.gems
end

--检查某个城市是否可以过去
--param cityID: 要去的城市ID
--return 0: 可以出发
--return 1: 玩家死了, 处于无法移动的状态
--return 2: 玩家正在路上, 无法移动
--return 3: 要去的城市与玩家当前城市不相邻
--return 4: 围城的部队无法向非友方城市撤退
--return 5: 当前就在这个城, 还去个毛线
function serverWarTeamFightVoApi:checkCityCanReach(cityID)
	local player=self:getPlayer()
	if(player.canMoveTime>base.serverTime)then
		return 1
	end
	if(player.arriveTime>base.serverTime)then
		return 2
	end
	if(player.cityID==cityID)then
		return 5
	end
	local startCity=self:getCity(player.cityID)
	local canReach=false
	for k,v in pairs(startCity.cfg.adjoin) do
		if(v==cityID and startCity.cfg.distance[k]>0)then
			if(startCity.cfg.roadType[k]==1 or (startCity.cfg.roadType[k]==2 and self:checkShowCountryRoad()))then
				canReach=true
				break
			end
		end
	end
	if(canReach==false)then
		return 3
	end
	local targetCity=self:getCity(cityID)
	if(startCity:getSide()~=player.side and targetCity:getSide()~=player.side)then
		return 4
	end
	return 0	
end

--检查小路是否出现
--小路不是一开战就会出现的, 而是在战斗进行了一段时间之后才会出现
function serverWarTeamFightVoApi:checkShowCountryRoad()
	if(base.serverTime>=self.startTime + serverWarTeamCfg.countryRoadTime)then
		return true
	else
		return false
	end
end

--检查一下当前是否在显示玩家战斗所在城市的面板
--因为如果在这种情况下玩家的死亡弹板要延迟4秒弹出
function serverWarTeamFightVoApi:checkShowSelfCity()
	if(self.cityDialog)then
		if(self.cityDialog.cityID==self.selfPlayer.battleCity and self.selfPlayer.arriveTime<=base.serverTime)then
			return true
		end
	end
	return false
end

--检查空中轰炸是否激活
function serverWarTeamFightVoApi:checkAirAttackEffective(side)
	for cityID,cfg in pairs(serverWarTeamFightVoApi:getMapCfg().flyCity) do
		if(self.cityList[cityID]:getSide()==side)then
			local playerNum=#(serverWarTeamFightVoApi:getAllPlayersInCity(cityID,side))
			if(playerNum>=serverWarTeamFightVoApi:getMapCfg().flyNeed)then
				return true
			end
			break
		end
	end
	return false
end

--向后台发请求拉所有数据, 刷新本地缓存
function serverWarTeamFightVoApi:refreshData(callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData2(data)
		--刷新时间是一个在battleRefreshTime附近浮动的随机值
		self.dataExpireTime=base.serverTime + serverWarTeamCfg.battleRefreshTime + math.random()*3 - 6
		if ret==true then
			if sData and sData.data then
				local serverData=sData.data.acrossserver
				if(serverData.over)then
					self:over(serverData.over)
					do return end
				end
				if(self.allianceList==nil)then
					self.allianceList={}
					if(serverData.alliancesInfo)then
						local alliance1,alliance2
						for id,value in pairs(serverData.alliancesInfo) do
							local allianceVo=serverWarTeamAllianceVo:new()
							allianceVo:init(value)
							if(alliance1)then
								alliance2=allianceVo
							else
								alliance1=allianceVo
							end
						end
						if(alliance1.signTime==alliance2.signTime)then
							if(tonumber(alliance1.serverID)==tonumber(alliance2.serverID))then
								if(alliance1.aid<alliance2.aid)then
									self.allianceList[1]=alliance1
									self.allianceList[2]=alliance2
								else
									self.allianceList[1]=alliance2
									self.allianceList[2]=alliance1
								end
							elseif(tonumber(alliance1.serverID)<tonumber(alliance2.serverID))then
								self.allianceList[1]=alliance1
								self.allianceList[2]=alliance2
							else
								self.allianceList[1]=alliance2
								self.allianceList[2]=alliance1
							end
						elseif(alliance1.signTime<alliance2.signTime)then
							self.allianceList[1]=alliance1
							self.allianceList[2]=alliance2
						else
							self.allianceList[1]=alliance2
							self.allianceList[2]=alliance1
						end
					end
				end
				if(serverData.usersActionInfo)then
					if(self.playerList==nil)then
						self.playerList={}
					end
					local eventTb={}
					for id,value in pairs(serverData.usersActionInfo) do
						if(self.playerList[id]==nil)then
							local playerVo=serverWarTeamPlayerVo:new()
							self.playerList[id]=playerVo
						end
						self.playerList[id]:init(value)
						if(self.playerList[id].serverID==tostring(base.curZoneID) and self.playerList[id].uid==playerVoApi:getUid())then
							self.selfPlayer=self.playerList[id]
						end
						table.insert(eventTb,self.playerList[id])
					end
					eventDispatcher:dispatchEvent("serverWarTeam.battle",{type="player",data=eventTb})
				end
				if(serverData.userinfo)then
					local buffTime=tonumber(serverData.userinfo.buff_at) or 0
					local todayTs=G_getWeeTs(self.startTime)
					if(self.buffData==nil)then
						self.buffData={}
					end
					for buffID,buffCfg in pairs(serverWarTeamCfg.buffSkill) do
						if(buffTime>=todayTs and serverData.userinfo[buffID])then
							self.buffData[buffID]=tonumber(serverData.userinfo[buffID])
						else
							self.buffData[buffID]=0
						end
					end
					self.gems=tonumber(serverData.userinfo.gems) or 0
				end
				if(serverData.placesInfo)then
					if(self.cityList==nil)then
						self.cityList={}
						for id,cityCfg in pairs(self.mapCfg.cityCfg) do
							local cityVo=serverWarTeamCityVo:new()
							cityVo:init(cityCfg)
							self.cityList[id]=cityVo
						end
					end
					local eventTb={}
					for cityID,allianceID in pairs(serverData.placesInfo) do
						if(self.cityList[cityID])then
							self.cityList[cityID].allianceID=allianceID
							table.insert(eventTb,self.cityList[cityID])
						end
					end
					eventDispatcher:dispatchEvent("serverWarTeam.battle",{type="city",data=eventTb})
				end
				if(serverData.points)then
					for allianceID,point in pairs(serverData.points) do
						for index,alliance in pairs(self.allianceList) do
							if(allianceID==alliance.id)then
								self.pointTb[index]=tonumber(point)
								break
							end
						end
					end
					self.pointExpireTime=base.serverTime + 10
				end
				if(serverData.placesBlood)then
					local eventTb={}
					for id,hurt in pairs(serverData.placesBlood) do
						local city=self.cityList[id]
						if(city)then
							city.hp=serverWarTeamCfg.baseBlood - tonumber(hurt)
							table.insert(eventTb,city)
						end
					end
					eventDispatcher:dispatchEvent("serverWarTeam.battle",{type="hurt",data=eventTb})
				end
				if(serverData.basetroops)then
					for id,num in pairs(serverData.basetroops) do
						if(id==self.mapCfg.baseCityID[1])then
							self.baseTroopsLeft[1]=tonumber(num) + 1
						else
							self.baseTroopsLeft[2]=tonumber(num) + 1
						end
					end
					eventDispatcher:dispatchEvent("serverWarTeam.battle",{type="npc"})
				end
				if(serverData.command and type(serverData.command)=="table")then
					self.order={}
					for k,v in pairs(serverData.command) do
						if(v[1] and self.cityList[v[1]] and type(v[2])=="number")then
							self.order[k]={v[1],v[2]}
						end
					end
					local eventTb=self.order
					eventDispatcher:dispatchEvent("serverWarTeam.battle",{type="order",data=eventTb})
				end
			end
			if(callback)then
				callback()
			end
		end
	end
	self.dataExpireTime=base.serverTime + 30 + math.random()*3 - 6
	local isShowLoading
	if(self.allianceList==nil)then
		isShowLoading=true
	else
		isShowLoading=false
	end
	socketHelper2:serverWarTeamFightInit(serverWarTeamVoApi:getServerWarId(),playerVoApi:getPlayerAid(),self.battleData.roundID,self.battleData.battleID,onRequestEnd,isShowLoading)
end

--向目标城市移动
--param targetID: 要去的城市ID
function serverWarTeamFightVoApi:move(targetID,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData2(data)
		if ret==true then
			if sData and sData.data and sData.data.acrossserver then
				local serverData=sData.data.acrossserver
				if(serverData.over)then
					self:over(serverData.over)
					do return end
				end
				local playerData=serverData.usersActionInfo
				local player=self:getPlayer()
				player:init(playerData)
				if(callback)then
					callback()
				end
			end
		end
	end
	socketHelper2:serverWarTeamMove(serverWarTeamVoApi:getServerWarId(),playerVoApi:getPlayerAid(),self.battleData.roundID,self.battleData.battleID,targetID,onRequestEnd)
end

--购买buff
function serverWarTeamFightVoApi:buyBuff(buffID,callback)
	local function onRequestEnd(fb,data)
		local ret,sData=base:checkServerData2(data)
		if(ret==true)then
			local serverData=sData.data.acrossserver
			if(serverData.over)then
				self:over(serverData.over)
				do return end
			end
			if(serverData.userinfo)then
				for buffID,buffCfg in pairs(serverWarTeamCfg.buffSkill) do
					if(serverData.userinfo[buffID])then
						self.buffData[buffID]=tonumber(serverData.userinfo[buffID])
					else
						self.buffData[buffID]=0
					end
				end
				self.gems=tonumber(serverData.userinfo.gems)
			end
			eventDispatcher:dispatchEvent("serverWarTeam.battle",{type="buff"})
			if(callback)then
				callback()
			end
		end
	end
	socketHelper2:serverWarTeamBuyBuff(serverWarTeamVoApi:getServerWarId(),playerVoApi:getPlayerAid(),self.battleData.roundID,self.battleData.battleID,buffID,onRequestEnd)
end

--加速
function serverWarTeamFightVoApi:accelerate(callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData2(data)
		if(ret==true)then
			local serverData=sData.data.acrossserver
			if(serverData.over)then
				self:over(serverData.over)
				do return end
			end
			if(serverData.usersActionInfo)then
				self.selfPlayer:init(serverData.usersActionInfo)
			end
			if(serverData.userinfo)then
				self.gems=tonumber(serverData.userinfo.gems)
			end
			if(callback)then
				callback()
			end
		end
	end
	socketHelper2:serverWarTeamAccelerate(serverWarTeamVoApi:getServerWarId(),playerVoApi:getPlayerAid(),self.battleData.roundID,self.battleData.battleID,onRequestEnd)
end

--复活
function serverWarTeamFightVoApi:revive(callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData2(data)
		if(ret==true)then
			local serverData=sData.data.acrossserver
			if(serverData.over)then
				self:over(serverData.over)
				do return end
			end
			if(serverData.usersActionInfo)then
				self.selfPlayer:init(serverData.usersActionInfo)
			end
			if(serverData.userinfo)then
				self.gems=tonumber(serverData.userinfo.gems)
			end
			if(callback)then
				callback()
			end
		end
	end
	socketHelper2:serverWarTeamRevive(serverWarTeamVoApi:getServerWarId(),playerVoApi:getPlayerAid(),self.battleData.roundID,self.battleData.battleID,onRequestEnd)
end

function serverWarTeamFightVoApi:refreshPoints(callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData2(data)
		if(ret==true)then
			local serverData=sData.data.acrossserver
			if(serverData.over)then
				self:over(serverData.over)
				do return end
			end
			if(serverData.points)then
				for allianceID,point in pairs(serverData.points) do
					for index,alliance in pairs(self.allianceList) do
						if(allianceID==alliance.id)then
							self.pointTb[index]=tonumber(point)
							break
						end
					end
				end
				self.pointExpireTime=base.serverTime + 10
			end
			eventDispatcher:dispatchEvent("serverWarTeam.battle",{type="points"})
			if(callback)then
				callback()
			end
		end
	end
	socketHelper2:serverWarTeamGetPoints(serverWarTeamVoApi:getServerWarId(),playerVoApi:getPlayerAid(),self.battleData.roundID,self.battleData.battleID,onRequestEnd,false)
end

--处理后台的推送请求
function serverWarTeamFightVoApi:receiveServerPush(data)
	if(data.usersActionInfo)then
		local eventTb={}
		for id,value in pairs(data.usersActionInfo) do
			if(self.playerList[id]==nil)then
				local playerVo=serverWarTeamPlayerVo:new()
				self.playerList[id]=playerVo
			end
			self.playerList[id]:init(value)
			if(self.playerList[id].serverID==tostring(base.curZoneID) and self.playerList[id].uid==playerVoApi:getUid())then
				self.selfPlayer=self.playerList[id]
			end
			table.insert(eventTb,self.playerList[id])
		end
		eventDispatcher:dispatchEvent("serverWarTeam.battle",{type="player",data=eventTb})
	end
	if(data.placesInfo)then
		local eventTb={}
		for cityID,allianceID in pairs(data.placesInfo) do
			if(self.cityList[cityID])then
				self.cityList[cityID].allianceID=allianceID
				table.insert(eventTb,self.cityList[cityID])
			end
		end
		eventDispatcher:dispatchEvent("serverWarTeam.battle",{type="city",data=eventTb})
	end
	if(data.points)then
		for allianceID,point in pairs(serverData.points) do
			for index,alliance in pairs(self.allianceList) do
				if(allianceID==alliance.id)then
					self.pointTb[index]=tonumber(point)
					break
				end
			end
		end
		self.pointExpireTime=base.serverTime + 10
		eventDispatcher:dispatchEvent("serverWarTeam.battle",{type="points"})
	end
	if(data.basetroops)then
		for id,num in pairs(data.basetroops) do
			if(id==self.allianceList[1].id)then
				self.baseTroopsLeft[1]=tonumber(num) + 1
			else
				self.baseTroopsLeft[2]=tonumber(num) + 1
			end
		end
		eventDispatcher:dispatchEvent("serverWarTeam.battle",{type="npc"})
	end
	if(data.placesBlood)then
		local eventTb={}
		for id,hurt in pairs(data.placesBlood) do
			local city=self.cityList[id]
			if(city)then
				city.hp=serverWarTeamCfg.baseBlood - tonumber(hurt)
				table.insert(eventTb,city)
			end
		end
		eventDispatcher:dispatchEvent("serverWarTeam.battle",{type="hurt",data=eventTb})
	end
	if(data.command and type(data.command)=="table")then
		self.order={}
		for k,v in pairs(data.command) do
			if(v[1] and self.cityList[v[1]] and type(v[2])=="number")then
				self.order[k]={v[1],v[2]}
			end
		end
		local eventTb=self.order
		eventDispatcher:dispatchEvent("serverWarTeam.battle",{type="order",data=eventTb})
	end
	if(data.isBomb and tonumber(data.isBomb)==1)then
		eventDispatcher:dispatchEvent("serverWarTeam.battle",{type="bomb"})
	end
	if(data.over)then
		self:over(data.over)
	end
end

--发送指挥命令
--param cityID: 指令所指向的城市
--param type: 指令类型
function serverWarTeamFightVoApi:sendOrder(cityID,type,callback)
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
		local ret,sData=base:checkServerData2(data)
		if(ret==true)then
			local serverData=sData.data.acrossserver
			if(serverData.over)then
				self:over(serverData.over)
				do return end
			end
			if(callback)then
				callback()
			end
		end
	end
	socketHelper2:serverWarTeamOrder(serverWarTeamVoApi:getServerWarId(),playerVoApi:getPlayerAid(),self.battleData.roundID,self.battleData.battleID,self.order,onRequestEnd)
end

--后台报了错误码
--param code: 错误码
function serverWarTeamFightVoApi:serverError(code)
	self.dataExpireTime=0
	local localCode=0 - code
	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage"..localCode),30)
end

function serverWarTeamFightVoApi:over(data)
	if(serverWarTeamMapScene and serverWarTeamMapScene.isShow)then
		local formatData={alliance=self.allianceList,points={0,0},kills={0,0},personNum={0,0},myPoint=0,winnerID=nil	}
		if(self.allianceList and #self.allianceList==2)then
			for id,point in pairs(data.points) do
				if(id==self.allianceList[1].id)then
					formatData.points[1]=tonumber(point)
				else
					formatData.points[2]=tonumber(point)
				end
			end
			for id,kill in pairs(data.kills) do
				if(id==self.allianceList[1].id)then
					formatData.kills[1]=tonumber(kill)
				else
					formatData.kills[2]=tonumber(kill)
				end
			end
			for id,player in pairs(self.playerList) do
				if(player.side==1)then
					formatData.personNum[1]=formatData.personNum[1] + 1
				else
					formatData.personNum[2]=formatData.personNum[2] + 1
				end
			end
			for allianceID,allianceTb in pairs(data.uPoints) do
				if(allianceID==base.curZoneID.."-"..playerVoApi:getPlayerAid())then
					for uid,score in pairs(allianceTb) do
						if(tonumber(uid)==tonumber(playerVoApi:getUid()))then
							formatData.myPoint=tonumber(score)
							break
						end
					end
				end
			end
			if(data.winner)then
				formatData.winnerID=data.winner
			end
		end
		smallDialog:showTeamServerWarResultDialog("PanelHeaderPopup.png",CCSizeMake(550,520),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,7,getlocal("serverwarteam_record"),formatData)
	end
	--自己请求后台刷新数据
	serverWarTeamVoApi:updateAfterBattle()
	--发聊天通知全服其他玩家战斗结束，请求后台刷新数据
	if self.battleData and self.battleData.roundID and self.battleData.battleID then
		local warId=serverWarTeamVoApi:getServerWarId()
		if warId then
            local params={warId,self.battleData.roundID,self.battleData.battleID}
            chatVoApi:sendUpdateMessage(12,params,1)
        end
	end
	eventDispatcher:dispatchEvent("serverWarTeam.battle",{type="over"})
	self:clear()
end

--tick无需解释
function serverWarTeamFightVoApi:tick()
	if(self.connected~=true)then
		do return end
	end
	if(base.serverTime == self.startTime + 10 or base.serverTime>=self.dataExpireTime)then
		self:refreshData()
	end
	if(base.serverTime>=self.pointExpireTime)then
		self:refreshPoints()
	end
	local eventTb={}
	for id,player in pairs(self.playerList) do
		if(player.arriveTime==base.serverTime or player.canMoveTime==base.serverTime)then
			table.insert(eventTb,player)
		end
	end
	if(#eventTb>0)then
		eventDispatcher:dispatchEvent("serverWarTeam.battle",{type="player",data=eventTb})
	end
	if(base.serverTime==self.startTime + serverWarTeamCfg.countryRoadTime)then
		eventDispatcher:dispatchEvent("serverWarTeam.battle",{type="countryRoad"})
	end
end

--断开跨服连接
function serverWarTeamFightVoApi:disconnectSocket2()
	require "luascript/script/netapi/socketHelper2"
	socketHelper2:disConnect()
	socketHelper2:dispose()
	self.connected=nil
end


function serverWarTeamFightVoApi:clear()
	self.connected=false
	base:removeFromNeedRefresh(self)
	self.dataExpireTime=0
	self.playerList=nil
	self.cityList=nil
	self.battleData=nil
	self.allianceList=nil
	self.startTime=0
	self.selfPlayer=nil
	self.buffData=nil
	self.gems=0
	self.mapCfg=nil
	self.pointTb={0,0}
	self.pointExpireTime=0
	self.baseTroopsLeft={1,1}
	if(socketHelper2)then
		socketHelper2:disConnect()
	end
end