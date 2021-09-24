--叛军相关的voapi
rebelVoApi={
	rebelList={{},{},{},{}},	--{发现列表，击杀列表，未击杀列表，叛军天眼buff搜索的叛军列表}
	killcount=0,	--军团当天击杀次数
	--与个人相关的数据放在下面
	rebelData=
	{
		comboExpire=0,	 	--连击过期时间
		lastAttackPos={},   --上次攻击的叛军坐标
		attackCombo=0,	  	--攻击叛军次数
		energy=0,		  	--能量点数
		energyRecoverTs=0,  --上次攻击或者购买能量的时间戳
		buyEnergy=0,		--购买能量次数
		lastBuyTs=0,		--上次购买能量的时间
	},
	midautumnRebelList={}, --中秋赏月活动叛军列表
	rebelMap=nil, --用于映射对应地图叛军数据的列表
	findList=nil, --发现叛军的列表，只作为军团建筑叛军图标显示用，请求叛军信息后清空
    pr_restartCDTimer=0,  --保存当前重置个人叛军时间戳

}

function rebelVoApi:clear()
	self:clearList()
	self.killcount=0
	self.rebelData=nil
	self.midautumnRebelList={}
	self.rebelMap=nil
	self.findList=nil
	self.lastRefreshRebelTime=nil
	self.pr_restartCDTimer=0
	self:pr_clear()
end

function rebelVoApi:clearList()
	self.rebelList={{},{},{},{}}
end

--保存当前个人叛军能量点数，攻击或购买的时间戳
function rebelVoApi:setCurEnergy(curEnergy,energyRecoverTs)
	if self.rebelData==nil then
		self.rebelData = {}
	end
	if curEnergy and energyRecoverTs and self.rebelData  then
		self.rebelData.energy = curEnergy
		self.rebelData.energyRecoverTs = energyRecoverTs
	end
	
end

--保存当前重置个人叛军时间戳
function rebelVoApi:setNowCDTimer(nowCDTimer)
	if self.pr_restartCDTimer == nil then 
        self.pr_restartCDTimer = 0
	end
	if nowCDTimer then
		self.pr_restartCDTimer = nowCDTimer
	end
end

--登录时获取当前重置个人叛军时间戳
function rebelVoApi:getNowCDTimer()
	if self.pr_restartCDTimer then
		return self.pr_restartCDTimer
	end
end

--param onlySelf: 是否只获取自己的数据
function rebelVoApi:rebelGet(callback,onlySelf,isRealRequest)
	local function rebelGetCallback(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			self:clearList()
			self.findList={} --清空已发现列表的假数据
			if sData and sData.data and sData.data.userforces then
				local userforces=sData.data.userforces
				if userforces and userforces.killcount then
					self.killcount=tonumber(userforces.killcount) or 0
					if self.killcount and self.killcount>rebelCfg.rewardLimit then
						self.killcount=rebelCfg.rewardLimit
					end
				end
				if(self.rebelData==nil)then
					self.rebelData={}
				end
				if(userforces.info)then
					if(userforces.info[1] and type(userforces.info[1])=="table")then
						userforces.info=userforces.info[1]
					end
					self.rebelData.comboExpire=tonumber(userforces.info[3]) or 0
					if(userforces.info[2] and self.rebelData.comboExpire>tonumber(userforces.info[2]))then
						self.rebelData.comboExpire=tonumber(userforces.info[2])
					end
					self.rebelData.lastAttackPos={}
					local mid=tonumber(userforces.info[1]) or 0
					local x=mid%600
					if(x==0)then
						x=600
					end
					local y=math.ceil(mid/600)
					self.rebelData.lastAttackPos[1]=x
					self.rebelData.lastAttackPos[2]=y
					self.rebelData.attackCombo=tonumber(userforces.info[4]) or 0
				end
				self.rebelData.energy=tonumber(userforces.energy) or 0
				self.rebelData.energyRecoverTs=tonumber(userforces.energyts)
				self.rebelData.buyEnergy=tonumber(userforces.energybuy) or 0
				self.rebelData.lastBuyTs=tonumber(userforces.buyts) or 0
			end
			if sData and sData.data and sData.data.forcesfind then
            	local forcesfind=sData.data.forcesfind
            	for k,v in pairs(forcesfind) do
            		local mapId=tonumber(v[1])
            		local fleeTime=tonumber(v[2])
            		local id=mapId.."-"..fleeTime
            		local level=tonumber(v[3])
            		local num=tonumber(v[4])
            		local maxLife=tonumber(v[5])
            		local curLife=tonumber(v[6])
            		local place={tonumber(v[7]),tonumber(v[8])}

            		local vo=rebelVo:new()
					vo:initWithData(id,fleeTime,level,num,maxLife,curLife,place)
					table.insert(self.rebelList[1],vo)
            	end
            end
            if sData and sData.data and sData.data.killlog then
            	local killlog=sData.data.killlog
            	for k,v in pairs(killlog) do
                	local num=tonumber(v[1]) or 0
            		local id=v[2]
            		local killTime=tonumber(v[3]) or 0
            		local level=tonumber(v[4]) or 0
            		local killName=v[5] or "" --击杀玩家的名字
            		local arr=Split(id,"-")
            		local mapId=tonumber(arr[1]) or 0
            		local fleeTime=tonumber(arr[2]) or 0

            		local vo=rebelVo:new()
					vo:initWithData(id,fleeTime,level,num,nil,nil,nil,killTime,killName)
					table.insert(self.rebelList[2],vo)
            	end
            end
            if sData and sData.data and sData.data.overlist then
            	local overlist=sData.data.overlist
            	for k,v in pairs(overlist) do
                	local num=tonumber(v[1]) or 0
            		local id=v[2]
            		local killTime=tonumber(v[3]) or 0
            		local level=tonumber(v[4]) or 0
            		local killName=v[5] or "" --击杀军团的名字
            		local arr=Split(id,"-")
            		local mapId=tonumber(arr[1]) or 0
            		local fleeTime=tonumber(arr[2]) or 0

            		local vo=rebelVo:new()
					vo:initWithData(id,fleeTime,level,num,nil,nil,nil,killTime,killName)
					table.insert(self.rebelList[3],vo)
            	end
            end
            if sData and sData.data and sData.data.forceslist then --天眼搜索的叛军列表
            	for k,v in pairs(sData.data.forceslist) do
            		--格式：{x坐标,y坐标,等级,部队id,过期时间,叛军id,叛军状态(0未交战 1已交战 2已击杀)}
            		local x,y,rebelLv,troopId,expireTs,tankType,dis=v[1],v[2],(v[3] or 0),v[4],v[5],0,0
                    local tankId=rebelVoApi:getRebelIconTank(rebelLv,troopId)
            		tankId=tonumber(RemoveFirstChar(tankId))
            		if tankCfg[tankId] and tankCfg[tankId].type then
            			tankType=tankCfg[tankId].type --坦克的类型
            		end
            		local mapx,mapy=playerVoApi:getMapX(),playerVoApi:getMapY()
            		local dis=worldScene:getDistanceByPos({x=mapx,y=mapy},{x=x,y=y}) --叛军离基地的距离
            		local rebel={mid=k,x=x,y=y,rebelLv=rebelLv,troopId=troopId,expireTs=expireTs,rebelId=v[6],rs=(v[7] or 0),tankType=tankType,dis=dis}
       				table.insert(self.rebelList[4],rebel)
            	end
            	self:sortForceslist() --排序
            end
    		if sData and sData.data and sData.data.midautumn then
				self.midautumnRebelList=sData.data.midautumn
			end
			if callback then
				callback()
			end
		end
	end
	local cmd,params,handler
	if isRealRequest~=nil and isRealRequest==false then
		cmd="alliancerebel.get"
		params={get=onlySelf}
		handler=rebelGetCallback
	else
		socketHelper:alliancerebelGet(rebelGetCallback,onlySelf)
	end
	return cmd,params,handler
end

function rebelVoApi:getKillcount()
	return self.killcount
end

function rebelVoApi:getRebelList(rType)
	if rType and self.rebelList[rType] then
		return self.rebelList[rType]
	end
	return {}
end

function rebelVoApi:removeRebel(rType,id)
	if rType and id and self.rebelList[rType] then
		for k,v in pairs(self.rebelList[rType]) do
			if v and v.id and v.id==id then
				table.remove(self.rebelList[rType],k)
			end
		end
	end
end

--获取叛军连击数，连击概念：在一段时间内连续攻击同一支叛军
--param x,y: 坐标
function rebelVoApi:getAttackCombo(x,y)
	if(self.rebelData and self.rebelData.lastAttackPos and self.rebelData.lastAttackPos[1]==x and self.rebelData.lastAttackPos[2]==y)then
		if(base.serverTime<self.rebelData.comboExpire)then
			return self.rebelData.attackCombo
		else
			return 0
		end
	else
		return 0
	end
end

--获取连击加成结束时间
function rebelVoApi:getComboLeftTime()
	if(self.rebelData and self.rebelData.comboExpire)then
		return self.rebelData.comboExpire
	end
	return 0
end

--获取击败叛军的奖励
--param baseVo: 叛军的数据worldBaseVo
function rebelVoApi:getRebelReward(baseVo)
	local rewardCfg=rebelCfg.troops.showList[baseVo.level]
	local cfgStr=G_Json.encode(rewardCfg)
	local rewardTankCfg=rebelCfg.troops.tank[baseVo.lvIndex][baseVo.rebelIndex][1]
	for k,v in pairs(rewardTankCfg) do
		local tankID=Split(v,"_")[2]
		cfgStr=string.gsub(cfgStr,"tank"..k,tankID)
	end
	rewardCfg=G_Json.decode(cfgStr)
	local rewardTb=FormatItem(rewardCfg,false,true)
	return rewardTb
end

--获取攻击叛军的能量点数
function rebelVoApi:getRebelEnergy(fsync)
	if(self.rebelData and self.rebelData.energy)then
		local recoverTime = rebelVoApi:getRebelEnergyRecoverTime()
		local recoverEnergy
		if(self.rebelData.energyRecoverTs and self.rebelData.energyRecoverTs>0 and base.serverTime>=self.rebelData.energyRecoverTs + recoverTime)then
			recoverEnergy=math.floor((base.serverTime - self.rebelData.energyRecoverTs)/recoverTime)
		else
			recoverEnergy=0
		end
		local energy = math.min(self.rebelData.energy + recoverEnergy, rebelCfg.energyMax)
		if fsync == true and recoverEnergy > 0 then
			if energy >= rebelCfg.energyMax then
				self.rebelData.energyRecoverTs = 0
			else
				self.rebelData.energyRecoverTs = self.rebelData.energyRecoverTs + recoverEnergy * recoverTime
				self.rebelData.energy = energy	
			end
		end
		return energy
	end
	return 0
end

--能量恢复时间
function rebelVoApi:getRebelEnergyRecoverTime()
	local rate = planeRefitVoApi:getSkvByType(63)
    return math.floor(rebelCfg.recoverTime * (1 - rate))
end

--获取叛军名字
--param lv: 叛军等级
--param index: 叛军编号
--param addLv: 是否加Lv.(name+Lv.1)
--param rpic: 叛军头像id(相当于worldBaseVo 里的pic字段)
function rebelVoApi:getRebelName(lv,index,addLv,rpic)
	local rebelName=""
	if rpic and tonumber(rpic)>=100 then
		rebelName=self:getSpecialRebelName(rpic)
		if addLv==true then
			rebelName=rebelName..getlocal("fightLevel",{lv})
		end
	else
		local tankID=tonumber(RemoveFirstChar(rebelVoApi:getRebelIconTank(lv,index)))
		local tankName=getlocal(tankCfg[tankID].name)
		if addLv==true then
			rebelName=getlocal("worldRebel_name_and_level",{tankName,lv})
		else
			rebelName=getlocal("worldRebel_name",{tankName})
		end
	end
	return rebelName
end

--获取叛军的显示坦克ID
--param lv: 叛军等级
--param index: 叛军编号
function rebelVoApi:getRebelIconTank(lv,index)
	local cfgIndex
	for k,v in pairs(rebelCfg.troops.tanklv) do
		if(lv<v)then
			cfgIndex=k - 1
			break
		end
	end
	if(cfgIndex==nil)then
		cfgIndex=#rebelCfg.troops.tanklv
	end
	return rebelCfg.troops.tankIcon[cfgIndex][index]
end

--获取今日购买能量的次数
function rebelVoApi:getBuyEnergy()
	if(self.rebelData==nil)then
		return 0
	end
	if(self.rebelData.lastBuyTs==nil or self.rebelData.lastBuyTs<G_getWeeTs(base.serverTime))then
		self.rebelData.buyEnergy=0
	end
	return self.rebelData.buyEnergy
end

--是否可以购买能量
function rebelVoApi:checkCanBuyRebelEnergy()
	local buyEnergy=self:getBuyEnergy()
	if(buyEnergy<rebelCfg.vipBuyLimit[playerVoApi:getVipLevel() + 1])then
		return true
	else
		return false
	end
end

--获取下次能量回复的时间戳
function rebelVoApi:getEnergyRecoverTs()
	local recoverTime = self:getRebelEnergyRecoverTime()
	local lastChangeTs=self.rebelData.energyRecoverTs
	local num=math.ceil((base.serverTime - lastChangeTs)/recoverTime)
	local nextTs=lastChangeTs + num*recoverTime
	return nextTs
end

--获取当前可以购买的最大能量
function rebelVoApi:getEnergyBuyMax()
	local max1=rebelCfg.energyMax - self:getRebelEnergy()
	local buyEnergy=self:getBuyEnergy()
	local max2=rebelCfg.vipBuyLimit[playerVoApi:getVipLevel() + 1] - buyEnergy
	local max=math.max(math.min(max1,max2),0)
	return max
end

--获取购买能量消耗的金币
--param type: 1是买1点，2是补到可以买的最大值
function rebelVoApi:getBuyRebelEneryCost(type)
	local buyEnergy=self:getBuyEnergy()
	if(type==1)then
		return rebelCfg.needMoney[buyEnergy + 1] or 0
	end
	local max=self:getEnergyBuyMax()
	local totalCost=0
	for i=1,max do
		totalCost=totalCost + (rebelCfg.needMoney[buyEnergy + i] or rebelCfg.needMoney[#rebelCfg.needMoney])
	end
	return totalCost
end

--购买能量
--param buyNum: 要购买几点能量
function rebelVoApi:buyRebelEnergy(buyNum,callback)
	local cost
	if(buyNum==1)then
		cost=self:getBuyRebelEneryCost(1)
	else
		cost=self:getBuyRebelEneryCost(2)
	end
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			playerVoApi:setGems(playerVoApi:getGems() - cost)
			if sData and sData.data and sData.data.userforces then
				local userforces=sData.data.userforces
				if(userforces.info)then
					if(userforces.info[1] and type(userforces.info[1])=="table")then
						userforces.info=userforces.info[1]
					end
					self.rebelData.comboExpire=tonumber(userforces.info[3]) or 0
					if(userforces.info[2] and self.rebelData.comboExpire>tonumber(userforces.info[2]))then
						self.rebelData.comboExpire=tonumber(userforces.info[2])
					end
					self.rebelData.lastAttackPos={}
					local mid=tonumber(userforces.info[1]) or 0
					local x=mid%600
					if(x==0)then
						x=600
					end
					local y=math.ceil(mid/600)
					self.rebelData.lastAttackPos[1]=x
					self.rebelData.lastAttackPos[2]=y
					self.rebelData.attackCombo=tonumber(userforces.info[4]) or 0
				end
				self.rebelData.energy=tonumber(userforces.energy) or 0
				self.rebelData.energyRecoverTs=tonumber(userforces.energyts)
				self.rebelData.buyEnergy=tonumber(userforces.energybuy) or 0
				self.rebelData.lastBuyTs=tonumber(userforces.buyts) or 0
			end
			if(callback)then
				callback()
			end
		end
	end
	socketHelper:rebelBuyEnergy(buyNum,cost,onRequestEnd)
end

--侦察叛军
function rebelVoApi:rebelScout(paramX,paramY,callback)
	local baseVo=worldBaseVoApi:getBaseVo(paramX,paramY)
	if(baseVo==nil or baseVo.type~=7)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage4001"),28)
		do return end
	end
	local costGold=rebelCfg.troops.scoutConsume[baseVo.level]
	if(costGold==nil)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage4001"),28)
		do return end
	end
	local function onRequestEnd(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if base.isCheckCode==1 then
				local checkcodeNum=CCUserDefault:sharedUserDefault():getIntegerForKey(G_checkCodeKey..playerVoApi:getUid())
				CCUserDefault:sharedUserDefault():setIntegerForKey(G_checkCodeKey..playerVoApi:getUid(),(checkcodeNum+10))
				CCUserDefault:sharedUserDefault():setIntegerForKey(G_lastMapscoutTime..playerVoApi:getUid(),base.serverTime)
				CCUserDefault:sharedUserDefault():flush()
			end
			playerVoApi:setGold(playerVoApi:getGold() - costGold)
			local reportTb
			if sData.data.mail and sData.data.mail.report then
				reportTb=sData.data.mail.report
			end
			local eid
			if reportTb then
				for k,v in pairs(reportTb) do
					eid=v.eid
				end
			end
			if(callback)then
				callback(eid)
			end
		end
	end
	local target={x=paramX,y=paramY}
	socketHelper:mapRebelscout(target,onRequestEnd)
end

--获取特殊叛军的名称和icon
--param: pic 相当于地图数据worldBaseVo中的pic
function rebelVoApi:getSpecialRebelName(pic)
	local name
	if pic then
		if tonumber(pic)==100 then
			local ver = (acMidAutumnVoApi and acMidAutumnVoApi.getVersion) and acMidAutumnVoApi:getVersion() or 1
			name=ver == 3 and getlocal("midautumn_rebel_v2_name") or getlocal("midautumn_rebel_name")
		end
	end
	return name
end

--获取特殊叛军的icon名字
--param: pic 相当于地图数据worldBaseVo中的pic
function rebelVoApi:getSpecialRebelPic(pic)
	local picName
	if pic then
		if tonumber(pic)==100 then
			picName="midautumn_rabbit.png"
		end
	end
	return picName
end

function rebelVoApi:isMidautumnRebel(expirationTs,rebelId)
	local flag=false
	expirationTs=tostring(expirationTs)
	if self.midautumnRebelList and self.midautumnRebelList[expirationTs] then
		local rebels=self.midautumnRebelList[expirationTs]
		for k,v in pairs(rebels) do
			if tonumber(v)==tonumber(rebelId) then
				flag=true
				do break end
			end
		end
	end
	return flag
end

--该方法仅是为军团建筑“已发现叛军”提示做的（已发现叛军的假数据）
function rebelVoApi:addRebelFind(reflectId)
	if self.findList==nil then
		self.findList={}
	end
	if reflectId then
		self.findList[reflectId]=1
	end
end

function rebelVoApi:getFindRebelList()
	return self.findList or {}
end

--添加叛军映射关系
function rebelVoApi:addReflectRebel(reflectId,x,y)
	if self.rebelMap==nil then
		self.rebelMap={}
	end
	self.rebelMap[reflectId]={x,y}
end

--删除映射关系
function rebelVoApi:removeRebelByReflectId(id)
	if self.rebelMap and self.rebelMap[id] then
		self.rebelMap[id]=nil
	end
end

--根据映射关系获取叛军的坐标
function rebelVoApi:getRebelByReflectId(id)
	local rebel
	if self.rebelMap and self.rebelMap[id] then
		rebel=self.rebelMap[id]
	end
	return rebel
end

--初始化叛军的发现列表
function rebelVoApi:formatRebelPartData(data)
	if data==nil then
		do return end
	end
	self:clearList()
	local forcesfind=data.forcesfind
	for k,v in pairs(forcesfind) do
		local mapId=tonumber(v[1])
		local fleeTime=tonumber(v[2])
		local id=mapId.."-"..fleeTime
		local level=tonumber(v[3])
		local num=tonumber(v[4])
		local maxLife=tonumber(v[5])
		local curLife=tonumber(v[6])
		local place={tonumber(v[7]),tonumber(v[8])}

		local vo=rebelVo:new()
		vo:initWithData(id,fleeTime,level,num,maxLife,curLife,place)
		table.insert(self.rebelList[1],vo)
	end
end

--排序天眼搜索到的叛军列表
--排序规则：
-- 1.已交战>未交战>已击杀
-- 2.坦克>火箭车>歼击车>火炮>其它（采矿车等）
-- 3.高等级>低等级
-- 4.当前坐标距叛军直线距离 近>远
function rebelVoApi:sortForceslist()
	local tankSortTb={[1]=4,[8]=3,[2]=2,[4]=1}
	local function sortFunc(r1,r2)
		local w1=(2-r1.rs)*math.pow(10,7)+tankSortTb[tonumber(r1.tankType)]*math.pow(10,6)+r1.rebelLv*math.pow(10,5)-r1.dis/10000
		local w2=(2-r2.rs)*math.pow(10,7)+tankSortTb[tonumber(r2.tankType)]*math.pow(10,6)+r2.rebelLv*math.pow(10,5)-r2.dis/10000
		if w1>w2 then
			return true
		end
		return false
	end
	table.sort(self.rebelList[4],sortFunc)
end

--清除指定叛军列表
function rebelVoApi:clearRebelList(rType)
	if rType and self.rebelList[rType] then
		self.rebelList[rType]={}
	end
end

function rebelVoApi:getRebelBuffSp(target,pos,zorder,layerNum,callback)
	--叛军特有buff显示
	local function touchHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
		if callback then
			callback()
		end
	end
	local rebelBuffSp=LuaCCSprite:createWithSpriteFrameName("ydcz_rebel.png",touchHandler)
	rebelBuffSp:setAnchorPoint(ccp(0.5,0.5))
	rebelBuffSp:setPosition(pos)
	rebelBuffSp:setTouchPriority(-(layerNum-1)*20-4)
	target:addChild(rebelBuffSp,(zorder or 0))
	--放大镜
	local magnifierNode=CCNode:create()
	magnifierNode:setAnchorPoint(ccp(0.5,0.5))
	magnifierNode:setPosition(134,70.5)
	rebelBuffSp:addChild(magnifierNode)

	local circelCenter=getCenterPoint(magnifierNode)
	local radius,rt,rtimes,circelAc=10,2,2,nil
	local magnifierSp=CCSprite:createWithSpriteFrameName("ydcz_magnifier.png")
	magnifierSp:setPosition(circelCenter)
	magnifierNode:addChild(magnifierSp)

	local acArr=CCArray:create()
	local moveTo=CCMoveTo:create(0.5,ccp(magnifierNode:getContentSize().width/2,radius))
	local function rotateBy()
		G_requireLua("componet/CircleBy")
		circelAc=CircleBy:create(magnifierSp,rt,circelCenter,radius,rtimes)
	end
	local function removeRotateBy()
		if circelAc and circelAc.stop then
			circelAc:stop()
		end
	end
	local moveTo2=CCMoveTo:create(0.5,ccp(magnifierNode:getContentSize().width/2,magnifierNode:getContentSize().height/2))
	local delay=CCDelayTime:create(1)
	acArr:addObject(moveTo)
	acArr:addObject(CCCallFunc:create(rotateBy))
	acArr:addObject(CCDelayTime:create(rt))
	acArr:addObject(CCCallFunc:create(removeRotateBy))
	acArr:addObject(moveTo2)
	acArr:addObject(delay)
	local seq=CCSequence:create(acArr)
	magnifierSp:runAction(CCRepeatForever:create(seq))

    local activeBg=CCSprite:createWithSpriteFrameName("allianceHeaderBg_black.png")
    rebelBuffSp:addChild(activeBg)
    local bgWidth,bgHeight=120,30
    activeBg:setScaleX(bgWidth/activeBg:getContentSize().width)
    activeBg:setScaleY(bgHeight/activeBg:getContentSize().height)
    activeBg:setPosition(rebelBuffSp:getContentSize().width/2,bgHeight/2+10)
    local activeStr,color
	local flag=playerVoApi:isRebelBuffActive() --叛军特有buff生效
	if flag==true then
		activeStr,color=getlocal("serverwarteam_activated"),G_ColorYellowPro
	else
		activeStr,color=getlocal("serverwarteam_notActivated"),G_ColorWhite
	end
    local activeLb=GetTTFLabel(activeStr,18)
    activeLb:setScaleX(1/activeBg:getScaleX())
    activeLb:setScaleY(1/activeBg:getScaleY())
    activeLb:setColor(color)
    activeBg:addChild(activeLb)
    activeLb:setPosition(getCenterPoint(activeBg))
	return rebelBuffSp,activeLb,activeBg
end

---------------------------------------【个人叛军】---------------------------------------

function rebelVoApi:pr_getCfg(npcType)
	--中怪和大怪使用以前的世界叛军的配置
	if npcType == 3 or npcType == 4 then
		return rebelCfg
	end
	local prCfg = G_requireLua("config/gameconfig/rebelGroupCfg")
	return prCfg
	-- require "luascript/script/config/gameconfig/rebelGroupCfg"
	-- return rebelGroupCfg
end

--个人叛军是否开启
function rebelVoApi:pr_isOpen()
	if base.prSwitch == 1 then
		return true
	end
	return false
end

--显示个人叛军主界面
function rebelVoApi:pr_showMainDialog(layerNum)
	self:pr_requestGet(function()
		require "luascript/script/game/scene/gamedialog/allianceDialog/personalRebelDialog"
		local td = personalRebelDialog:new(layerNum)
		local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {}, nil, nil, getlocal("personalRebel_titleText"), true, layerNum)
		sceneGame:addChild(dialog, layerNum)
	end)
end

--显示个人叛军的战报界面
function rebelVoApi:pr_showReportDialog(layerNum)
	self:pr_requestReportList(function(reportList)
		require "luascript/script/game/scene/gamedialog/allianceDialog/personalRebelReportDialog"
		local td = personalRebelReportDialog:new(layerNum, reportList)
		local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {}, nil, nil, getlocal("fight_content_fight_title"), true, layerNum)
		sceneGame:addChild(dialog, layerNum)
	end)
end

--显示个人叛军的战报详情界面
--@ eid : 战报id或侦查报告数据
function rebelVoApi:pr_showReportDetailDialog(layerNum, eid, onEnterCallback)
	local function onEnterDialog(report)
		local titleStr = getlocal("scout_content_scout_title")
		if report.eid then
			titleStr = getlocal("fight_content_fight_title")
		end
		require "luascript/script/game/scene/gamedialog/allianceDialog/personalRebelReportDetailDialog"
		local td = personalRebelReportDetailDialog:new(layerNum, report)
		local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), {}, nil, nil, titleStr, true, layerNum)
		sceneGame:addChild(dialog, layerNum)
		if type(onEnterCallback) == "function" then
			onEnterCallback()
		end
	end
	if type(eid) == "table" then
		onEnterDialog(eid)
	else
		self:pr_requestReportRead(onEnterDialog, eid)
	end
end

--显示个人叛军的道具背包界面(小弹板)
function rebelVoApi:pr_showBagSmallDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/allianceDialog/personalRebelSmallDialog"
	personalRebelSmallDialog:showBagDialog(layerNum, getlocal("personalRebel_itemBagText"))
end

--显示个人叛军的信息界面(小弹板)
function rebelVoApi:pr_showInfoSmallDialog(layerNum, params)
	rebelVoApi:rebelGet(function()
		require "luascript/script/game/scene/gamedialog/allianceDialog/personalRebelSmallDialog"
		personalRebelSmallDialog:showInfoDialog(layerNum, params)
	end, 1)
end

--显示个人叛军的奖励展示界面(小弹板)
function rebelVoApi:pr_showRewardSmallDialog(layerNum, params)
	require "luascript/script/game/scene/gamedialog/allianceDialog/personalRebelSmallDialog"
	personalRebelSmallDialog:showRewardDialog(layerNum, params)
end

--显示个人叛军的购买行动力界面(小弹板)
function rebelVoApi:pr_showBuyEnergySmallDialog(layerNum, params)
	require "luascript/script/game/scene/gamedialog/allianceDialog/personalRebelSmallDialog"
	personalRebelSmallDialog:showBuyEnergyDialog(layerNum, params)
end

--初始化个人叛军数据
function rebelVoApi:pr_initData(data)
	if type(data) ~= "table" then
		do return end
	end
	--玩家在棋盘上的当前坐标
	self.pr_curPosition = nil
	if data.position then
		local pos = Split(data.position, "-")
		self.pr_curPosition = ccp(tonumber(pos[1]), tonumber(pos[2]))
	end
	--背包道具数据
	self.pr_propItem = nil
	if data.props then
		self.pr_propItem = data.props
	end
	--重置棋盘CD时间戳
	self.pr_restartCDTimer = nil
	if data.expire then
		self.pr_restartCDTimer = data.expire
	end
	--前一天的世界叛军最大等级
	self.pr_maxRebelLv = nil
	if data.level then
		self.pr_maxRebelLv = data.level
	end
	--棋盘数据
	self.pr_gridData = nil
	if data.camp then
		local prCfg = self:pr_getCfg()
		for r, rTb in pairs(data.camp) do
			for c, cTb in pairs(rTb) do
				local tempTb = {}
				if type(cTb) == "table" then
					if cTb.rid then
						local npcType = prCfg.npcList[cTb.rid].type
						tempTb = {
							npcId = cTb.rid,
							npcType = npcType,
							fogState = cTb.state, --迷雾状态 0:未开启, 1:开启
							monsterId = cTb.troops, --具体的怪物索引值
							monsterLv = cTb.monsterLv, --怪物等级
							monsterHp = cTb.hp, --怪物的当前血量
							monsterMaxHp = cTb.maxHp, --怪物的最大血量
							doubleHit = cTb.hc, --连击次数
						}
					else
						--空地
					end
				else
					--迷雾笼罩(未开启)
					tempTb = {
						fogState = 0
					}
				end
				if self.pr_gridData == nil then
					self.pr_gridData = {}
				end
				if self.pr_gridData[r] == nil then
					self.pr_gridData[r] = {}
				end
				self.pr_gridData[r][c] = tempTb
			end
		end
	end
end

--获取个人叛军数据
function rebelVoApi:pr_requestGet(callback, isReset)
	local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
            	if sData.data.rebles then
            		self:pr_initData(sData.data.rebles)
            		if isReset == 1 then --重置棋盘
            			self.pr_scoutReport =  nil
            		end
            	end
                if callback then
                    callback()
                end
            end
        end
    end
	socketHelper:pr_getData(socketCallback, isReset)
end

--个人叛军攻打废墟
--@ position : 个人叛军的棋盘坐标[x,y]
function rebelVoApi:pr_requestAttackRuins(callback, position)
	local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
            	if sData.data.rebles then
            		self:pr_initData(sData.data.rebles)
            	end
                if callback then
                    callback(sData.data.reward)
                end
            end
        end
    end
	socketHelper:pr_attackRuins(socketCallback, position)
end

--个人叛军使用道具
--@ pid : 道具id
--@ position : 个人叛军的棋盘坐标[x,y]
function rebelVoApi:pr_requestUseProp(callback, pid, position)
	local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
            	if sData.data.rebles then
            		self:pr_initData(sData.data.rebles)
            	end
            	if pid == "p3" then --重置棋盘
            		self.pr_scoutReport =  nil
            	end
                if callback then
                    callback(sData.data.reward)
                end
            end
        end
    end
	socketHelper:pr_useProp(socketCallback, pid, position)
end

--个人叛军侦察
--@ position : 个人叛军的棋盘坐标[x,y]
function rebelVoApi:pr_requestScout(callback, position)
	local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
            	if sData.data.report then
	            	if self.pr_scoutReport == nil then
						self.pr_scoutReport = {}
					end
					table.insert(self.pr_scoutReport, sData.data.report)
				end
                if callback then
                    callback(sData.data.report)
                end
            end
        end
    end
	socketHelper:pr_scout(socketCallback, position)
end

--个人叛军攻打接口
--@ position : 个人叛军的棋盘坐标[x,y]
--@ fleetinfo: 出战的部队
--@ hero: 出战将领
--@ emblemID: 军徽ID
--@ planePos: 飞机解锁位置
--@ aitroops: AI部队
--@ airShipId: 飞艇ID
function rebelVoApi:pr_requestBattle(callback, position, fleetinfo, hero, emblemID, planePos, aitroops, airShipId)
	local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data then
            	if sData.data.rebles then
            		self:pr_initData(sData.data.rebles)
            	end
                if callback then
                    callback(sData)
                end
            end
        end
    end
	socketHelper:pr_battle(socketCallback, position, fleetinfo, hero, emblemID, planePos, aitroops, airShipId)
end

--个人叛军获取战报列表
function rebelVoApi:pr_requestReportList(callback)
	local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data and sData.data.report then
                if callback then
                    callback(sData.data.report)
                end
            end
        end
    end
	socketHelper:pr_reportList(socketCallback)
end

--个人叛军阅读战报详情
--@ eid : 战报id
function rebelVoApi:pr_requestReportRead(callback, eid)
	local function socketCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data and sData.data.report then
                if callback then
                    callback(sData.data.report)
                end
            end
        end
    end
	socketHelper:pr_reportRead(socketCallback, eid)
end

--获取个人叛军的棋盘数据
function rebelVoApi:pr_getGridData()
	if self.pr_gridData then
		return self.pr_gridData
	end
end

--获取玩家在棋盘中的位置
function rebelVoApi:pr_getPlayerPos()
	if self.pr_curPosition then
		return self.pr_curPosition
	end
	return ccp(1, 1)
end

--获取前一天的世界叛军最大等级
function rebelVoApi:pr_getMaxRebelLevel()
	if self.pr_maxRebelLv then
		return self.pr_maxRebelLv
	end
	return rebelCfg.troops.tanklv[#rebelCfg.troops.tanklv]
end

--获取个人叛军的背包道具数量
--@ pId : 道具id
function rebelVoApi:pr_getPropNum(pId)
	if self.pr_propItem and self.pr_propItem[pId] then
		return self.pr_propItem[pId]
	end
	return 0
end

--获取个人叛军的棋盘重置CD时间戳
function rebelVoApi:pr_getRestartCDTimer()
	if self.pr_restartCDTimer then
		return self.pr_restartCDTimer
	end
	return 0
end

--获取个人叛军的怪物名称
--@ npcType : npcList中的type值(2为小怪；3为中怪，4为大怪)
--@ tankId : tankID
function rebelVoApi:pr_getMonsterName(npcType, tankId)
	if npcType == 4 then
		return getlocal("personalRebel_leaderText")
	else
		return getlocal("worldRebel_name", { getlocal(tankCfg[tankId].name) })
	end
end

--获取个人叛军的等级库索引值
--@ npcType : npcList中的type值(2为小怪；3为中怪，4为大怪)
function rebelVoApi:pr_getLvIndex(npcType)
	local cfgTankLv = self:pr_getCfg(npcType).troops.tanklv
	if cfgTankLv then
		local maxRebelLv = self:pr_getMaxRebelLevel()
		local lvIndex
		for k, v in pairs(cfgTankLv) do
			if maxRebelLv < v then
				lvIndex = k - 1
				break
			end
		end
		if lvIndex == nil then
			lvIndex = SizeOfTable(cfgTankLv)
		end
		if npcType == 2 or npcType == 3 then
			if npcType == 3 then
				lvIndex = lvIndex - 1
			else
				lvIndex = lvIndex - 2
			end
			if lvIndex <= 0 then
				lvIndex = 1
			end
		end
		return lvIndex
	end
end

--获取个人叛军的怪物IconId
--@ npcType : npcList中的type值(2为小怪；3为中怪，4为大怪)
--@ monsterId : 具体的怪物索引值
function rebelVoApi:pr_getMonsterIconId(npcType, monsterId)
	local cfgTankTb = self:pr_getCfg(npcType).troops.tank
	local lvIndex = self:pr_getLvIndex(npcType)
	if cfgTankTb and cfgTankTb[lvIndex] then
		local tank = cfgTankTb[lvIndex][monsterId]
		if tank and tank[1] and tank[1][1] then
			return Split(tank[1][1], "_")[2]
		end
	end
end

--获取个人叛军的背包道具
function rebelVoApi:pr_getBagItem()
	local prCfg = self:pr_getCfg()
	local propList
	for k, v in pairs(prCfg.propList) do
		if propList == nil then
			propList = { ["rg"] = {} }
		end
		table.insert(propList["rg"], { [v.id] = self:pr_getPropNum(v.id), ["index"] = v.index })
	end
	if propList then
		return FormatItem(propList, nil, true)
	end
end

--获取个人叛军的道具信息(名称，描述，图标)
--@ pId : 个人叛军道具id
function rebelVoApi:pr_getPropInfo(pId)
	local prCfg = self:pr_getCfg()
	local propList = prCfg.propList[pId]
	if propList then
		return getlocal(propList.name), propList.desc, propList.icon
	end
end

--获取个人叛军的奖励
--@ data : 棋盘数据
function rebelVoApi:pr_getReward(data)
	if data and data.monsterLv then
		local prCfg = self:pr_getCfg()
		local cfgReward = prCfg.reward[data.npcId]
		if cfgReward then
			local rewardTb = {}
			for i = 1, 2 do
				local tempReward = cfgReward["reward" .. i]
				if tempReward then
					if tempReward[data.monsterLv] then
						for k, v in pairs(tempReward[data.monsterLv]) do
							if rewardTb[k] == nil then
								rewardTb[k] = {}
							end
							for m, n in pairs(v) do
								table.insert(rewardTb[k], n)
							end
						end
					end
				end
			end
			local rewardJson = G_Json.encode(rewardTb)
			local lvIndex = self:pr_getLvIndex(data.npcType)
			if lvIndex then
				local cfgTankTb = self:pr_getCfg(data.npcType).troops.tank
				if cfgTankTb and cfgTankTb[lvIndex] then
					local rewardTankCfg = cfgTankTb[lvIndex][data.monsterId]
					if rewardTankCfg and rewardTankCfg[1] then
						for k, v in pairs(rewardTankCfg[1]) do
							rewardJson = string.gsub(rewardJson, "tank" .. k, Split(v, "_")[2])
						end
					end
				end
			end
			return FormatItem(G_Json.decode(rewardJson), nil, true)
		end
	end
end

--获取个人叛军所消耗的道具数
--@ npcId : npcList的id
function rebelVoApi:pr_getCostPropNum(npcId)
	local prCfg = self:pr_getCfg()
	if prCfg.npcList[npcId] then
		return prCfg.npcList[npcId].needitem
	end
	return 0
end

--获取个人叛军所消耗的体力
--@ npcId : npcList的id
function rebelVoApi:pr_getCostEnergy(npcId)
	local prCfg = self:pr_getCfg()
	if prCfg.npcList[npcId] then
		return prCfg.npcList[npcId].cost
	end
	return 0
end

--获取个人叛军所消耗的水晶
--@ npcType : npcList中的type值(2为小怪；3为中怪，4为大怪)
--@ monsterLv : 怪的等级
function rebelVoApi:pr_getCostCrystal(npcType, monsterLv)
	local prCfg = self:pr_getCfg(npcType)
	if prCfg.troops and prCfg.troops.scoutConsume then
		if prCfg.troops.scoutConsume[monsterLv] then
			return prCfg.troops.scoutConsume[monsterLv]
		else
			local size = SizeOfTable(prCfg.troops.scoutConsume)
			return prCfg.troops.scoutConsume[size]
		end
	end
	return 0
end

--个人叛军获取侦查报告
function rebelVoApi:pr_getScoutReport()
	if self.pr_scoutReport then
		return self.pr_scoutReport
	end
end

--个人叛军判断是否可以使用迷雾道具
function rebelVoApi:pr_isCanUseFog()
	local gridData = self:pr_getGridData()
	if gridData then
		for k, v in pairs(gridData) do
			if k <= 7 then
				for m, n in pairs(v) do
					if n then
						if n.fogState == 0 then
							return true
						end
					end
				end
			end
		end
	end
	return false
end

function rebelVoApi:pr_clear()
	self.pr_restartCDTimer = nil
	self.pr_propItem = nil
	self.pr_maxRebelLv = nil
	self.pr_curPosition = nil
	self.pr_gridData = nil
	self.pr_scoutReport = nil
end
