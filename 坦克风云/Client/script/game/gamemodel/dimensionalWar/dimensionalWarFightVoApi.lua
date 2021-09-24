--异次元战场战斗voapi
dimensionalWarFightVoApi=
{
	dataExpireTime=0,		--数据过期的时间, 如果serverTime大于这个时间的话就需要重新向后台拉取数据
	endFlag=false,			--战斗结束的标识
	groundList={},			--所有的地块数据，key是地块编号，value是dimensionalWarGroundVo
	startTime=0,			--本次战斗的开始时间
	totalPlayers=0,			--战场内存活总人数
	playerStatus=0,			--玩家当前的状态：0活着，1亡者，2彻底挂掉
	playerEnerge=0,			--玩家当前的行动力
	playerPos=nil,			--玩家所在格子,{x,y}
	troops=nil,				--玩家的部队
	eventTb=nil,			--玩家在回合内发生的事件
	eventRound=0,			--玩家发生事件的回合
	zombieRound=nil,		--玩家第几回合变僵尸的
	dieRound=nil,			--玩家第几回合彻底挂掉的
	buffData=nil,			--buff数据
	explodeArr=nil,			--爆炸的顺序
	buyTime={},				--购买三种战场效果的次数，一个table，{1,2,3}
	point=0,				--玩家获得的积分
	over=nil,				--结算信息
	curRound=nil,			--当前回合
	actionRound=nil,		--行动的回合
	roundAction=nil,		--本回合选择的行动
	moveRound=nil,			--移动的回合
	tmpAction={},			--每个回合生成action的时候记录一个临时tb，以防关闭战场再次打开的时候同一回合可能刷出不同的action
}

--进入战场，显示地图
function dimensionalWarFightVoApi:showMap(layerNum)
	local status=dimensionalWarVoApi:getStatus()
	if(status>=10 and status<=20)then
		require "luascript/script/game/scene/gamedialog/dimensionalWar/dimensionalWarMapScene"
		require "luascript/script/game/gamemodel/dimensionalWar/dimensionalWarGroundVo"
		if(base.serverTime>self.dataExpireTime or self:getResult())then
			local function onRefresh()
				if(dimensionalWarVoApi:battleEndIsShowBtn() or self:getResult())then
					if(self:getResult())then
						if(self:getResult().status==0)then
							require "luascript/script/game/scene/gamedialog/dimensionalWar/dimensionalWarSmallDialog"
							local sd=dimensionalWarSmallDialog:new(5)
							sd:init(layerNum)
						else
							require "luascript/script/game/scene/gamedialog/dimensionalWar/dimensionalWarSmallDialog"
							local sd=dimensionalWarSmallDialog:new(4)
							sd:init(layerNum)
						end
					else
						smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("world_war_matchStatus2"),30)
					end
					do return end
				else
					dimensionalWarMapScene:show(layerNum)
				end
			end
			self:refreshData(onRefresh)
		else
			dimensionalWarMapScene:show(layerNum)
		end
	else
		do return end
	end
end

function dimensionalWarFightVoApi:showTroopDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/dimensionalWar/dimensionalWarTroopDialog"
	local td=dimensionalWarTroopDialog:new()
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("local_war_my_troops"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

function dimensionalWarFightVoApi:refreshData(callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			local flag=false
			for k,v in pairs(base.allNeedRefreshDialogs) do
				if(v==self)then
					flag=true
					break
				end
			end
			if(flag==false)then
				base:addNeedRefresh(self)
			end
			if sData and sData.data then
				self:formatData(sData.data)
			end
			self.dataExpireTime=self.dataExpireTime + 300
			if(callback)then
				callback()
			end
		else
			self.dataExpireTime=self.dataExpireTime + 60 + math.random(1,10)
		end
	end
	socketHelper:dimensionalWarRefresh(onRequestEnd)
end

--检查当前的行动状态
--return 0: 准备阶段，玩家做出行动选择
--return 1: 行动阶段，后台计算结果，前端播放动画
function dimensionalWarFightVoApi:checkActionStatus()
	local prepareTime=userWarCfg.roundTime
	local actionTime=userWarCfg.roundAccountTime
	local totalTime=prepareTime + actionTime
	local tmpTime=(base.serverTime - self:getStartTime())%totalTime
	if(tmpTime<prepareTime)then
		return 0
	else
		return 1
	end
end

--检查本回合是否爆炸，如果有的话返回要爆炸的区域
--return : 没有爆炸就是nil,有的话就是ABCDEF或者12345,第二个结果是具体哪个格子
function dimensionalWarFightVoApi:checkExplode()
	local curRound=self:getCurRound()
	if(userWarCfg.blast[curRound] and userWarCfg.blast[curRound]>0 and self.explodeArr[userWarCfg.blast[curRound]])then
		local keyMap={"A","B","C","D","E","F"}
		local groundIndex=self.explodeArr[userWarCfg.blast[curRound]]
		local x = groundIndex%10
		local y = math.floor(groundIndex/10)
		--跟下一回合爆炸的格子相比较来决定到底是显示横行还是竖列
		--此处需要注意，在explodeArr里面必须把所有格子都加上，包括最后那个不炸的格子，否则就没法算了，只能走else里面的随机
		local nextGroundIndex=self.explodeArr[userWarCfg.blast[curRound] + 1]
		if(nextGroundIndex)then
			local nextX=math.floor(nextGroundIndex/10)
			local nextY=nextGroundIndex%10
			if(math.abs(nextY - y)>=math.abs(nextX - x))then
				return y,{x,y}
			else
				return keyMap[x],{x,y}
			end
		else
			if(math.random()>0.5)then
				return y,{x,y}
			else
				return keyMap[x],{x,y}
			end
		end
	end
end

--当前回合数
function dimensionalWarFightVoApi:getCurRound()
	if(self.curRound==nil)then
		local prepareTime=userWarCfg.roundTime
		local actionTime=userWarCfg.roundAccountTime
		local totalTime=prepareTime + actionTime
		local round=math.max(math.floor((base.serverTime - self:getStartTime())/totalTime) + 1,1)
		self.curRound=round
	end
	return self.curRound
end

--获取到下一状态的倒计时
--如果当前是准备阶段，那么这个倒计时就是到行动阶段的倒计时
--如果当前是行动阶段，那么这个倒计时就是到下一回合准备阶段的倒计时
function dimensionalWarFightVoApi:getCountDown()
	local prepareTime=userWarCfg.roundTime
	local actionTime=userWarCfg.roundAccountTime
	local totalTime=prepareTime + actionTime
	local tmpTime=(base.serverTime - self:getStartTime())%totalTime
	if(tmpTime<=prepareTime)then
		return prepareTime - tmpTime
	else
		return totalTime - tmpTime
	end
end

--玩家当前的状态：0活着，1亡者，2彻底挂掉
function dimensionalWarFightVoApi:getPlayerStatus()
	return self.playerStatus
end

--玩家的行动力
function dimensionalWarFightVoApi:getEnergy()
	return self.playerEnerge
end

--全战场的幸存者
function dimensionalWarFightVoApi:getSurvivers()
	return self.totalPlayers
end

--获取地块列表
function dimensionalWarFightVoApi:getGroundList()
	return self.groundList
end

--获取玩家的部队
function dimensionalWarFightVoApi:getTroops()
	return self.troops
end

--获取玩家位置
function dimensionalWarFightVoApi:getPosition()
	return self.playerPos
end

--获取本回合发生的事件
function dimensionalWarFightVoApi:getEvent()
	if(self.eventTb==nil)then
		self.eventTb={}
	end
	local explodeFlag,actionFlag=false,false
	for k,v in pairs(self.eventTb) do
		if(v[2]==1)then
			explodeFlag=true
		elseif(v[2]==2)then
			actionFlag=true
		end
	end
	if(actionFlag==false)then
		local action
		if(self.actionRound==nil or self.actionRound<self:getCurRound())then
			if(self:getPlayerStatus()==0)then
				action=0
			else
				action=101
			end
		else
			action=self.roundAction
		end
		table.insert(self.eventTb,1,{getlocal("dimensionalWar_roundAction",{getlocal("dimensionalWar_operateAct"..action)}),2})
	end
	if(explodeFlag==false)then
		local explodeLine,explodePos=self:checkExplode()
		if(explodeLine)then
			local keyMap={"A","B","C","D","E","F"}
			action=keyMap[explodePos[1]]..explodePos[2]
			table.insert(self.eventTb,1,{getlocal("dimensionalWar_eventExplode",{action}),1})
		end
	end
	return self.eventTb
end

--获取buff和debuff
function dimensionalWarFightVoApi:getBuffData()
	if(self:getPlayerStatus()==1)then
		if(self.buffData==nil)then
			self.buffData={}
		end
		if(self.buffData.add==nil)then
			self.buffData.add={}
		end
		if(self.buffData.add.b3==nil)then
			self.buffData.add.b3=1
		end
	end
	return self.buffData or {}
end

--获取buff和debuff的描述
--param id: 状态的id
--param type: 1是buff，2是debuff
function dimensionalWarFightVoApi:getBuffDesc(id,type)
	local prefix,param
	if(type==1)then
		prefix="dimensionalWar_buffDesc"
		if(id=="b3")then
			param={userWarCfg.delbuff.delhp*100,userWarCfg.delbuff.win*100,userWarCfg.delbuff.addbuff.accuracy*100}
		else
			param={userWarCfg.eventUpBuff.list[id].per*100}
		end
	else
		prefix="dimensionalWar_debuffDesc"
		param={userWarCfg.eventDownBuff.list[id].per*100}
	end
	local desc=getlocal(prefix..id,param)
	return desc
end

--获取玩家本回合可以进行哪些操作
function dimensionalWarFightVoApi:getAction()
	--变成僵尸之后固定只有战斗和污染两个操作
	if(self:getPlayerStatus()==1)then
		return {101,102}
	else
		if(self.tmpAction[self:getCurRound()]==nil)then
			local randomTotal=0
			for k,v in pairs(userWarCfg.randAction.normal.list) do
				randomTotal=randomTotal + v
			end
			for i=1,10 do
				math.random(1,randomTotal)
			end
			local randomFree=math.random(1,randomTotal)
			local tmp=0
			local freeAct
			for k,v in pairs(userWarCfg.randAction.normal.list) do
				tmp=tmp + v
				if(tmp>=randomFree)then
					freeAct=userWarCfg.cardsName[k]
					break
				end
			end
			local randomTotal=0
			for k,v in pairs(userWarCfg.randAction.gems.list) do
				randomTotal=randomTotal + v
			end
			local randomGem=math.random(1,randomTotal)
			for i=1,10 do
				math.random(1,randomTotal)
			end
			local tmp=0
			local gemAct
			for k,v in pairs(userWarCfg.randAction.gems.list) do
				tmp=tmp + v
				if(tmp>=randomGem)then
					gemAct=userWarCfg.cardsName[k]
					break
				end
			end
			self.tmpAction[self:getCurRound()]={0,freeAct,gemAct}
		end
		return self.tmpAction[self:getCurRound()]
	end
end

--玩家第几回合变僵尸的
function dimensionalWarFightVoApi:getZombieRound()
	return self.zombieRound
end

--玩家第几回合彻底挂掉的
function dimensionalWarFightVoApi:getDieRound()
	return self.dieRound
end

--购买某种战场效果的次数
function dimensionalWarFightVoApi:getBuyTime(index)
	return self.buyTime[index] or 0
end

--玩家获得的积分
function dimensionalWarFightVoApi:getPoint()
	return self.point
end

--获取战场结果
function dimensionalWarFightVoApi:getResult()
	return self.over
end

--上次发生移动的回合
function dimensionalWarFightVoApi:getMoveRound()
	return self.moveRound
end

--上次发生行动的回合
function dimensionalWarFightVoApi:getActionRound()
	return self.actionRound
end

--战斗开始时间
function dimensionalWarFightVoApi:getStartTime()
	if(self.startTime==0)then
		self.startTime=G_getWeeTs(base.serverTime) + userWarCfg.startWarTime[1]*3600 + userWarCfg.startWarTime[2]*60
	end
	return self.startTime
end

--战场移动
function dimensionalWarFightVoApi:move(x,y,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data then
				self.moveRound=self:getCurRound()
				self:formatData(sData.data)
				if(callback)then
					callback()
				end
			end
		else
			self.dataExpireTime=self.dataExpireTime + 60 + math.random(1,10)
		end
	end
	socketHelper:dimensionalWarMove(x,y,onRequestEnd)
end

--战场操作
--param type: 0 = 普通休整,1 = 普通探索,2 = 战斗,3 = 设置陷阱,4 = 高级休整,5 = 高级探索,6 = 躲猫猫,101 = 猎杀(僵尸的战斗),102 = 污染(僵尸放陷阱)
function dimensionalWarFightVoApi:action(type,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data then
				self.actionRound=self:getCurRound()
				self.roundAction=type
				local costGem
				if(type==4)then
					costGem=userWarCfg.stay2.cost.gems
				elseif(type==5)then
					costGem=userWarCfg.discovery2.cost.gems
				elseif(type==6)then
					costGem=userWarCfg.hide.cost.gems
				end
				if(costGem and costGem>0)then
					playerVoApi:setGems(playerVoApi:getGems() - costGem)
				end
				self:formatData(sData.data)
				-- local flag=false
				-- for k,v in pairs(self.eventTb) do
				-- 	if(v[2]==3)then
				-- 		flag=true
				-- 		break
				-- 	end
				-- end
				-- local rewardTb={}
				-- if(sData.data.reward)then
				-- 	rewardTb=sData.data.reward
				-- end
				-- if(flag==false)then
				-- 	local eventStr=dimensionalWarVoApi:getEventDescStr(self.roundAction,self:getPosition()[1].."-"..self:getPosition()[2],rewardTb)
				-- 	table.insert(self.eventTb,1,{eventStr,3})
				-- end
				if(callback)then
					callback()
				end
			end
		else
			self.dataExpireTime=self.dataExpireTime + 60 + math.random(1,10)
		end
	end
	if(type==0)then
		socketHelper:dimensionalWarStay(1,onRequestEnd)
	elseif(type==1)then
		socketHelper:dimensionalWarSearch(1,onRequestEnd)
	elseif(type==2)then
		socketHelper:dimensionalWarFight(onRequestEnd)
	elseif(type==3)then
		socketHelper:dimensionalWarTrap(1,onRequestEnd)
	elseif(type==4)then
		socketHelper:dimensionalWarStay(2,onRequestEnd)
	elseif(type==5)then
		socketHelper:dimensionalWarSearch(2,onRequestEnd)
	elseif(type==6)then
		socketHelper:dimensionalWarHide(onRequestEnd)
	elseif(type==101)then
		socketHelper:dimensionalWarFight(onRequestEnd)
	elseif(type==102)then
		socketHelper:dimensionalWarTrap(2,onRequestEnd)
	end
end

--战场中购买buff
--param index: 1
function dimensionalWarFightVoApi:buy(index,callback)
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData and sData.data then
				self:formatData(sData.data)
				local costGem
				if(index==1)then
					costGem=userWarCfg.support.energy.cost.gems
				elseif(index==2)then
					costGem=userWarCfg.support.troops.cost.gems
				else
					costGem=userWarCfg.support.clearStatus.cost.gems
				end
				if(costGem and costGem>0)then
					playerVoApi:setGems(playerVoApi:getGems() - costGem)
				end
				if(callback)then
					callback()
				end
			end
		else
			self.dataExpireTime=self.dataExpireTime + 60 + math.random(1,10)
		end
	end
	if(index==1)then
		socketHelper:dimensionalWarBuyEnergy(onRequestEnd)
	elseif(index==2)then
		socketHelper:dimensionalWarBuyTroop(onRequestEnd)
	elseif(index==3)then
		socketHelper:dimensionalWarBuyDebuff(onRequestEnd)
	end
end

--处理后台的推送数据
--推送的数据格式和其他接口不一样，所以需要处理一下
function dimensionalWarFightVoApi:receiveServerPush(data)
	local packData={}
	if(data.event)then
		packData.event={}
		packData.event.content=data.event
	end
	if(data.over)then
		packData.over={}
		packData.over.status=data.over[1]
		packData.over.count=data.over[2]
		packData.over.round1=data.over[3]
		packData.over.round2=data.over[4]
		packData.over.point=data.over[5]
		packData.over.point1=data.over[6]
		packData.over.point2=data.over[7]
	end
	if(data.userwar)then
		packData.userwar={}
		packData.userwar.energy=data.userwar[1]
		packData.userwar.status=data.userwar[2]
		packData.userwar.point1=data.userwar[3]
		packData.userwar.point2=data.userwar[4]
		packData.userwar.round1=data.userwar[5]
		packData.userwar.round2=data.userwar[6]
		packData.userwar.troops=data.userwar[7]
		packData.userwar.buff=data.userwar[8]
		packData.userwar.support1=data.userwar[9]
		packData.userwar.support2=data.userwar[10]
		packData.userwar.support3=data.userwar[11]
		packData.userwar.mapx=data.userwar[12]
		packData.userwar.mapy=data.userwar[13]
	end
	if(data.map)then
		packData.map=data.map
	end
	self:formatData(packData)
end

--统一处理后台数据
function dimensionalWarFightVoApi:formatData(data)
	if(data==nil)then
		do return end
	end
	local eventData={}
	if(data.map)then
		local mapData=data.map
		if(mapData.battlest)then
			self.startTime=tonumber(mapData.battlest)
		end
		if(mapData.mapData)then
			for yIndex,xValue in pairs(mapData.mapData) do
				if(self.groundList[yIndex]==nil)then
					self.groundList[yIndex]={}
				end
				for xIndex,value in pairs(xValue) do
					if(self.groundList[yIndex][xIndex]==nil)then
						self.groundList[yIndex][xIndex]=dimensionalWarGroundVo:new(xIndex,yIndex,value)
					else
						self.groundList[yIndex][xIndex]:update(value)
					end
				end
			end
			table.insert(eventData,"map")
		end
		if(mapData.survival)then
			self.totalPlayers=tonumber(mapData.survival)
			table.insert(eventData,"survivers")
		end
	end
	if(data.userwar)then
		local userData=data.userwar
		if(userData.status)then
			if(self.playerStatus~=tonumber(userData.status))then
				table.insert(eventData,"playerstatus")
			end
			self.playerStatus=tonumber(userData.status)
		end
		if(self.playerStatus>0)then
			if(userData.round1)then
				self.zombieRound=tonumber(userData.round1) + 1
			end
			if(self.playerStatus==2)then
				if(userData.round2)then
					self.dieRound=self.zombieRound + tonumber(userData.round2)
				end
			end
		end
		if(userData.buff)then
			self.buffData=userData.buff
			table.insert(eventData,"buff")
		end
		if(userData.energy)then
			self.playerEnerge=tonumber(userData.energy)
			table.insert(eventData,"energy")
		end
		if(userData.mapx)then
			if(self.playerPos==nil)then
				self.playerPos={}
			end
			self.playerPos[1]=tonumber(userData.mapx)
		end
		if(userData.mapy)then
			if(self.playerPos==nil)then
				self.playerPos={}
			end
			self.playerPos[2]=tonumber(userData.mapy)
		end
		if(userData.mapx or userData.mapy)then
			table.insert(eventData,"position")
		end
		if(userData.info)then
			self.troops=userData.info
			table.insert(eventData,"troop")
		end
		if(userData.troops and #userData.troops>0)then
			if(self.troops==nil)then
				self.troops={}
			end
			self.troops.troops=userData.troops
		end
		if(userData.support1)then
			self.buyTime[1]=tonumber(userData.support1)
		end
		if(userData.support2)then
			self.buyTime[2]=tonumber(userData.support2)
		end
		if(userData.support3)then
			self.buyTime[3]=tonumber(userData.support3)
		end
		if(userData.support1 or userData.support2 or userData.support3)then
			table.insert(eventData,"buy")
		end
		if(userData.point1 or userData.point2)then
			local point1=tonumber(userData.point1) or 0
			local point2=tonumber(userData.point2) or 0
			self.point=point1 + point2
		end
	end
	if(data.blast)then
		self.explodeArr=data.blast
	end
	local curRound=self:getCurRound()
	if(data.event)then
		local eventServer=data.event
		if(self.eventTb==nil)then
			self.eventTb={}
		end
		local voArr=dimensionalWarVoApi:getEvent(eventServer)
		if(voArr)then
			for k,v in pairs(voArr) do
				table.insert(self.eventTb,{dimensionalWarVoApi:getEventDesc(v),4})
			end
		end
	end
	if(data.over)then
		if(data.over.status)then
			self.playerStatus=tonumber(data.over.status)
		end
		self.over=data.over
		table.insert(eventData,"over")
	end
	if(#eventData>0)then
		eventDispatcher:dispatchEvent("dimensionalWar.battle",eventData)
	end
end

function dimensionalWarFightVoApi:tick()
	local prepareTime=userWarCfg.roundTime
	local actionTime=userWarCfg.roundAccountTime
	local totalTime=prepareTime + actionTime
	local round=math.max(math.floor((base.serverTime - self:getStartTime())/totalTime) + 1,1)
	self.curRound=round
	if(self.eventRound==nil or self.eventRound<self:getCurRound())then
		self.eventRound=self.curRound
		self.eventTb={}
	end
	self:getAction()
end

function dimensionalWarFightVoApi:clear()
	base:removeFromNeedRefresh(self)
	self.dataExpireTime=0
	self.endFlag=false
	self.groundList={}
	self.startTime=0
	self.totalPlayers=0
	self.playerStatus=0
	self.playerEnerge=0
	self.playerPos=nil
	self.troops=nil
	self.eventTb=nil
	self.eventRound=0
	self.zombieRound=nil
	self.dieRound=nil
	self.buffData=nil
	self.explodeArr=nil
	self.buyTime={}
	self.point=0
	self.over=nil
	self.curRound=nil
	self.actionRound=nil
	self.roundAction=nil
	self.moveRound=nil
	self.tmpAction={}
end