-- 战斗中的数据处理展示
ltzdzFightApi={
	mapVo=nil, -- 战场信息
	userInfo=nil, -- 战场中用户数据{uid={},uid={}}
	connected=nil, -- 是否连接跨服机器
	planeList=nil, -- 飞机列表  每一次关闭主板子需要清空，防止长时间在游戏中，数据不更新
	equipList=nil, -- 军徽列表
	heroList=nil,
	attackTanks={{},{},{},{},{},{}}, -- 进攻队列
	temDefenseTanks={{},{},{},{},{},{}}, -- 临时防守队列
	attackHeros={0,0,0,0,0,0}, -- 进攻英雄
	temDefenseHeros={0,0,0,0,0,0}, -- 防守英雄
	attackAITroops={0,0,0,0,0,0}, -- 进攻AI部队
	temDefenseAITroops={0,0,0,0,0,0}, -- 防守AI部队
	syncResTime=nil, --同步资源的过期时间
	-- cityTb={}, --存储升级完成的城市
	expiredTime=nil, -- 过期时间
}

function ltzdzFightApi:clear()
	self.mapVo=nil
	self.userInfo=nil
	self.connected=nil
	self.planeList=nil
	self.equipList=nil
	self.heroList=nil
	self.attackTanks={{},{},{},{},{},{}}
	self.temDefenseTanks={{},{},{},{},{},{}}
	self.attackHeros={0,0,0,0,0,0}
	self.temDefenseHeros={0,0,0,0,0,0}
	self.attackAITroops={0,0,0,0,0,0}
	self.temDefenseAITroops={0,0,0,0,0,0}
	self.expiredTime=nil
end

-- 地图界面
function ltzdzFightApi:showMapDialog(layerNum,callback)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzMapDialog"
	local td=ltzdzMapDialog:new(layerNum,nil,callback)
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal(""),true,layerNum)
	sceneGame:addChild(dialog,layerNum)

	td:approachAction() 
end

function ltzdzFightApi:transMap(refreshFunc,layerNum)
	local blackLayer=CCLayerColor:create(ccc4(0,0,0,255))
    sceneGame:addChild(blackLayer,layerNum+1)
    blackLayer:setScale(0.001)
    -- print("blackLayer:size--->>>",blackLayer:getContentSize().width,blackLayer:getContentSize().height,(G_VisibleSizeWidth)/blackLayer:getContentSize().width,(G_VisibleSizeHeight)/blackLayer:getContentSize().height)
	local scaleTo=CCScaleTo:create(0.3,1)

	local function refreshCallback()
		for i=1,3 do
			local tailingSp=CCSprite:createWithSpriteFrameName("ltzdzTailing.png")
			blackLayer:addChild(tailingSp)
			tailingSp:setAnchorPoint(CCPointMake(0,0))
			tailingSp:setPosition((i-1)*tailingSp:getContentSize().width,G_VisibleSizeHeight)
		end
		local function initCallBack()
			local acArr=CCArray:create()
			acArr:addObject(CCDelayTime:create(0.3))
			local moveAc=CCMoveTo:create(0.5,CCPointMake(0,-G_VisibleSizeHeight-20-225))
		    acArr:addObject(moveAc)
	    	local function removeFunc()
				blackLayer:removeFromParentAndCleanup(true)
			end
			local callFunc2=CCCallFunc:create(removeFunc)
		    acArr:addObject(callFunc2)
		    local seq=CCSequence:create(acArr)
			blackLayer:runAction(seq)
		end
		self:showMapDialog(layerNum,initCallBack)
		if refreshFunc then
			refreshFunc()
		end

	end
	local callFunc1=CCCallFunc:create(refreshCallback)

	local acArr=CCArray:create()
    acArr:addObject(scaleTo)
    acArr:addObject(CCDelayTime:create(0.1))
    acArr:addObject(callFunc1)
    local seq=CCSequence:create(acArr)
	blackLayer:runAction(seq)
end

-- 地图界面
function ltzdzFightApi:showSmallMapDialog(layerNum,istouch,isuseami,callBack,parent)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzSmallMapDialog"
	ltzdzSmallMapDialog:showPropInfo(layerNum,istouch,isuseami,callBack,parent)
end

-- 部队
function ltzdzFightApi:showTroopDialog(layerNum,cid,refreshFunc)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzTroopDialog"
	local td=ltzdzTroopDialog:new(layerNum,cid,refreshFunc)
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("fleetInfoTitle2"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

-- 出征
function ltzdzFightApi:showExpeDitionDialog(layerNum,targetCid,startCid,targetCityTb,parent)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzExpditionDialog"
	local td=ltzdzExpditionDialog:new(layerNum,targetCid,startCid,targetCityTb,parent)
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("ltzdz_expedition"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

-- 部队选择页面
function ltzdzFightApi:showSelectTankDialog(layerNum,istouch,isuseami,callBack,titleStr,ptype,cid)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzSelectTankSmallDialog"
	ltzdzSelectTankSmallDialog:showTankList(layerNum,istouch,isuseami,callBack,titleStr,ptype,cid)
end

-- 部队运输页面
function ltzdzFightApi:showTransportTankDialog(layerNum,istouch,isuseami,callBack,titleStr,startCid,endCid,targetCityTb,parent)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzTransportTankSmallDialog"
	ltzdzTransportTankSmallDialog:showTransport(layerNum,istouch,isuseami,callBack,titleStr,startCid,endCid,targetCityTb,parent)
end

-- 队列页面
function ltzdzFightApi:showSlotInfo(layerNum,istouch,isuseami,callBack,titleStr,parent)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzSlotSmallDialog"
	ltzdzSlotSmallDialog:showSlotInfo(layerNum,istouch,isuseami,callBack,titleStr,parent)
end

-- 侦察页面
function ltzdzFightApi:showScoutInfo(layerNum,istouch,isuseami,callBack,titleStr,parent,isScout,scoutInfo)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzScoutSmallDialog"
	ltzdzScoutSmallDialog:showScoutInfo(layerNum,istouch,isuseami,callBack,titleStr,parent,isScout,scoutInfo)
end

-- 运输详情
function ltzdzFightApi:showTransInfo(layerNum,istouch,isuseami,callBack,titleStr,parent,transInfo)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzTransInfoSmallDialog"
	ltzdzTransInfoSmallDialog:showTransInfo(layerNum,istouch,isuseami,callBack,titleStr,parent,transInfo)
end

-- 使用加速
function ltzdzFightApi:showMarchAcc(layerNum,istouch,isuseami,callBack,titleStr,parent,accDes,tid,cid,sid)
	require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzMarchAccSmallDialog"
	ltzdzMarchAccSmallDialog:showMarchAcc(layerNum,istouch,isuseami,callBack,titleStr,parent,accDes,tid,cid,sid)
end
--出发城市（算出征兵量）目前仅用于阵型使用
function ltzdzFightApi:setCurStartCid(newStartCid)
	self.curStartCid = newStartCid
end
function ltzdzFightApi:getCurStartCid()
	return self.curStartCid or nil
end
function ltzdzFightApi:joinBattle(refreshFunc)
	local function serverFunc(fn,data)
		local ret,sData = base:checkServerData(data)
		if ret==true then
			if sData and sData.data then
				self:initData(sData.data)
			end
			if refreshFunc then
				refreshFunc()
			end
		end
	end
	socketHelper:ltzdzJoinBattle(serverFunc)
end

-- 连接跨服机器并进入战斗界面
function ltzdzFightApi:showMap(layerNum,refreshFunc,notDirectEnter)
	local function showfight()
		local function showDialog()
			self:syncMyPic()
			if notDirectEnter then
				eventDispatcher:dispatchEvent("ltzdz.enterBattle",{})
			else
				self:transMap(refreshFunc,layerNum)
			end
			
			-- self:showMapDialog(layerNum)
		end
		local et=ltzdzVoApi.clancrossinfo.et or 0
		if G_isToday(et) then
			local function getInfoFunc(fn,data)
				local ret,sData=base:checkServerData2(data)
				if ret==true then
					if sData and sData.data then
						self:initData(sData.data)
					end
					
					
					showDialog()
				end
			end
			local uid=tonumber(playerVoApi:getUid())
			local roomid=ltzdzVoApi.clancrossinfo.roomid
			local tid=ltzdzVoApi.clancrossinfo.tid
			local flag=1 --是否返回binfo的标识(1：不返回binfo，0：返回binfo)
			if self.userInfo==nil or (self.userInfo[tostring(uid)] and self.userInfo[tostring(uid)].binfo==nil) then
				flag=0
			end
			socketHelper2:ltzdzGetinfo(getInfoFunc,uid,roomid,nil,tid,flag)
		else
			local function disSocket2Func()
				self:disconnectSocket2()
			end
			ltzdzFightApi:joinBattle(disSocket2Func)
		end
	end
	
	if(self.connected)then
		-- showfight()
		self:setTid(showfight)
	else
		-- get之前先调用joinBattle  后台要求
		local function getFunc()
			local function pCallback()
				-- print("+++++++++settid")
				self:setTid(showfight)
			end
			local host=ltzdzVoApi.clancrossinfo.host
			local port=ltzdzVoApi.clancrossinfo.port
			-- print("host,port",host,port)
			self:rConnectSocket2(host,port,pCallback)
		end
		if notDirectEnter then -- 刚刚调过joinbattle，就不掉用了
			getFunc()
		else
			ltzdzFightApi:joinBattle(getFunc)
		end
	end
		
end

function ltzdzFightApi:disconnectSocket2()
	require "luascript/script/netapi/socketHelper2"
	socketHelper2:disConnect()
	socketHelper2:dispose()
	self.connected=nil
end

-- function ltzdzFightApi:syncWar(callBack)
--     local function syncHandler(fn,data)
--         local ret,sData=base:checkServerData2(data)
--         if ret==true then
--    			if sData and sData.data then
-- 				self:initData(sData.data)
-- 			end
--             if callBack then
--             	callBack()
--             end
--         end
--     end
--     local uid=tonumber(playerVoApi:getUid())
--     local roomid=ltzdzVoApi.clancrossinfo.roomid
--     socketHelper2:ltzdzGetinfo(syncHandler,uid,roomid,false)
-- end

function ltzdzFightApi:initData(data)
	if data and data.clancrossinfo then
		ltzdzVoApi.clancrossinfo:initWithData(data.clancrossinfo)
	end
	if not self.mapVo then
		-- 初始化战场信息
		require "luascript/script/game/gamemodel/ltzdz/ltzdzMapVo"
		self.mapVo=ltzdzMapVo:new()
		if self.syncResTime==nil then
			self.syncResTime=base.serverTime+60
		end
	end
	if data and data.map then
		self.mapVo:initWithData(data.map)
	end

	if data and data.user then
		if self.userInfo then --如果之前拉取过user数据的话，再从服务器拉取跨服数据时不会返回binfo数据，所以先保存一下userInfo下的binfo数据
			local uid=tostring(playerVoApi:getUid())
			if uid and self.userInfo[uid] and self.userInfo[uid].binfo and data.user[uid] then
				data.user[uid].binfo=self.userInfo[uid].binfo
			end
		end
		self.userInfo=data.user
		self:syncMyPic()
	end
end

--同步玩家自己的最新头像
function ltzdzFightApi:syncMyPic()
	if self.userInfo then
		local myUid=tostring(playerVoApi:getUid())
		local pic=playerVoApi:getPic()
		if self.userInfo[myUid] then
			self.userInfo[myUid].pic=pic
		end
	end
end

function ltzdzFightApi:getExtraTroopsNum(bType,isAddEmblem)
	

	local emblemTroopsAdd = 0
	if bType then
	    if base.emblemSwitch==1 and isAddEmblem~=false then
	        local emblemID = emblemVoApi:getTmpEquip(bType)
	        if emblemID~=nil then
	        	local emTroopVo
	        	if bType==35 or bType==36 then
	        		emTroopVo=self:getEmblemTroopById(emblemID)
	        	end
	            emblemTroopsAdd = emblemVoApi:getTroopsAddById(emblemID,emTroopVo)
	        end
	    end
	end
    return emblemTroopsAdd
end

-- 领土争夺战 基础带兵量（不包含军徽）
function ltzdzFightApi:getFightNum(bType,isAddEmblem)
	local uid=tostring(playerVoApi:getUid())
	local myinfo=self.userInfo[uid]
	local fightNum=myinfo.binfo.tnum or 0
	local extraNum=self:getExtraTroopsNum(bType,isAddEmblem)
	return fightNum+extraNum
end

-- 领土争夺战 带过来英雄的个数
function ltzdzFightApi:numOfhero()
	local uid=tostring(playerVoApi:getUid())
	local myinfo=self.userInfo[uid]
	local heroList=myinfo.binfo.hero
	local heroNum=0
	if heroList then
		heroNum=SizeOfTable(heroList)
	end
	return heroNum
end

-- 领土争夺战 带过来AI部队的个数
function ltzdzFightApi:numOfAITroops()
	local uid=tostring(playerVoApi:getUid())
	local myinfo=self.userInfo[uid]
	local troopsTb=myinfo.binfo.aitroops
	local num=0
	if troopsTb then
		num=SizeOfTable(troopsTb)
	end
	return num
end

-- 领土争夺战 带过来军徽的个数
function ltzdzFightApi:numOfEmblem()
	local uid=tostring(playerVoApi:getUid())
	local myinfo=self.userInfo[uid]
	local emblemList=myinfo.binfo.sequip
	local emblemNum=0
	if emblemList then
		emblemNum=SizeOfTable(emblemList)
	end
	if emblemTroopVoApi:checkIfEmblemTroopIsOpen()==true then --数量中加入军徽部队
		local troopList=myinfo.binfo.smaster
		emblemNum=emblemNum+SizeOfTable(troopList)
	end
	return emblemNum
end

-- 领土争夺战 带过来飞机的个数
function ltzdzFightApi:numOfPlane()
	local uid=tostring(playerVoApi:getUid())
	local myinfo=self.userInfo[uid]
	local planeList=myinfo.binfo.plane
	local planeNum=0
	if planeList then
		planeNum=SizeOfTable(planeList)
	end
	return planeNum
end

-- 得到能出战的飞机
function ltzdzFightApi:getCanBattlePlane()
	local uid=tostring(playerVoApi:getUid())
	local myinfo=self.userInfo[uid]
	local planeList=myinfo.binfo.plane
	if planeList and SizeOfTable(planeList)>0 then
		if self.planeList==nil then
			self.planeList={}
			for k,v in pairs(planeList) do
				local cfg = planeVoApi:getPlaneCfgById(k)
				local vo = planeVo:new(cfg)
				vo:initWithData(v,k)
				table.insert(self.planeList,vo)
			end
		end
		return self.planeList
	else
		return {}
	end
end

--根据解锁位置获取飞机
function ltzdzFightApi:getPlaneVoByPos(pos)
	local planeList=self:getCanBattlePlane()
	if pos and tonumber(pos) then
		for k,vo in pairs(planeList) do
			if k==tonumber(pos) then
				return vo
			end
		end
	end
	return nil
end

function ltzdzFightApi:canUseInPlaneSetFormation(usePId,useType)
	local curCid = self:getCurStartCid()
	local planeList = ltzdzFightApi:getCanBattlePlane()
	for k,vo in pairs(planeList) do
		if vo and vo.idx == tonumber(usePId) then
			if self:checkPlaneCanUse(useType,vo.idx,curCid)==true then
				return true
			end
		end
	end
	return false
end
-- 飞机是否能出站 
-- 能出战 false  不能出战 true
function ltzdzFightApi:planeIsCanBattle(bType,pos,cid)
	return (not self:checkPlaneCanUse(bType,pos,cid))
end

-- 得到能出战的军徽
function ltzdzFightApi:getCanBattleEmblem()
	local uid=tostring(playerVoApi:getUid())
	local myinfo=self.userInfo[uid]
	local emblemList=myinfo.binfo.sequip
	if self.equipList==nil then
		self.equipList={}
		if emblemList and SizeOfTable(emblemList)>0 then
			for k,v in pairs(emblemList) do
				local cfg = emblemVoApi:getEquipCfgById(k)
				local vo = emblemVo:new(cfg)
				vo:initWithData(k,v[1])
				table.insert(self.equipList,vo)
			end
			local function sortFunc(a,b)
				if(a.cfg.color==b.cfg.color)then
					if(a.cfg.lv==b.cfg.lv)then
						return a.cfg.qiangdu>b.cfg.qiangdu
					else
						return a.cfg.lv>b.cfg.lv
					end
				else
					return a.cfg.color>b.cfg.color
				end
			end
			table.sort(self.equipList,sortFunc)
		end
		if emblemTroopVoApi:checkIfEmblemTroopIsOpen()==true then --军徽部队处理
			local troopList={}
			local smaster=myinfo.binfo.smaster
			if smaster then
				for k,v in pairs(smaster) do
			      	local vo=emblemTroopVo:new()
		            vo:initWithData(k,v)
		            vo.num=1 --num会用到，所以此处固定设置为1
					table.insert(troopList,vo)
				end
	      
			end
			--按强度排序
			local function sortFunc(a,b)
			  	if a and b then
	                return a:getTroopStrength()<b:getTroopStrength()
	            end
	            return false
			end
			table.sort(troopList,sortFunc)
			for k,v in pairs(troopList) do
				table.insert(self.equipList,1,v) --军徽部队插入到最前面
			end
		end
	end
	return self.equipList or {}
end

-- 通过id获取军徽已出征的数量
function ltzdzFightApi:getBattleNumById(equipId,cid)
	-- 1判断行军队列中是否占用
	local num=0
	local tqueue=self.mapVo.tqueue or {}
	local myuid=tostring(playerVoApi:getUid())
	local selfTqueue=tqueue[myuid]
	if selfTqueue then
		for k,v in pairs(selfTqueue) do
			-- print("v[8],pos",v[8],equipId)
			if v[9]==equipId then
				num=num+1
			end
		end
	end
	-- 2判断其它防守城是否占用
	local uid=playerVoApi:getUid()
	local cityTb=self.mapVo.city
	if cityTb then
		for k,v in pairs(cityTb) do
			if v.oid and tonumber(v.oid)==tonumber(uid) then -- 是自己的城市
				if k~=cid then -- 不是自己城的防守部队（自己城的防守部队能用）
					if v.d and v.d[3] then
						if v.d[3]==equipId then
							num=num+1
						end
					end
					
				end
			end
		end
	end

	return num
end

-- type:36 进攻队列 35：临时防守队列
function ltzdzFightApi:setTanksByType(type,id,tid,num)
	if type==36 then
		self.attackTanks[id]={tid,num}
	elseif type==35 then
		self.temDefenseTanks[id]={tid,num}
	end
end

function ltzdzFightApi:getTanksTbByType(type)
	if type==36 then
		return self.attackTanks
	elseif type==35 then
		return self.temDefenseTanks
	end
end

function ltzdzFightApi:deleteTanksTbByType(type,id)
	if type==36 then
		self.attackTanks[id]=nil
		self.attackTanks[id]={}
	elseif type==35 then
		self.temDefenseTanks[id]=nil
		self.temDefenseTanks[id]={}
	end
end

function ltzdzFightApi:clearTanksTbByType(type)
	if type==36 then
		self.attackTanks={}
		self.attackTanks={{},{},{},{},{},{}}
	elseif type==35 then
		self.temDefenseTanks={}
		self.temDefenseTanks={{},{},{},{},{},{}}
	end
end

function ltzdzFightApi:setHeroByPos(pos,hid,type)
	if type==36 then
		self.attackHeros[pos]=hid
	elseif type==35 then
		self.temDefenseHeros[pos]=hid
	end
end

function ltzdzFightApi:getHeroTbByType(type)
	if type==36 then
		return self.attackHeros
	elseif type==35 then
		return self.temDefenseHeros
	end
end

function ltzdzFightApi:clearHeroTbByType(type)
	if type==36 then
		self.attackHeros={0,0,0,0,0,0}
	elseif type==35 then
		self.temDefenseHeros={0,0,0,0,0,0}
	end
	heroVoApi:clearTroops()
end

--设置AI部队
function ltzdzFightApi:setAITroopsByPos(pos,atid,type)
	if type==36 then
		self.attackAITroops[pos]=atid
	elseif type==35 then
		self.temDefenseAITroops[pos]=atid
	end
end

function ltzdzFightApi:getAITroopsTbByType(type)
	if type==36 then
		return self.attackAITroops
	elseif type==35 then
		return self.temDefenseAITroops
	end
end

function ltzdzFightApi:clearAITroopsTbByType(type)
	if type==36 then
		self.attackAITroops={0,0,0,0,0,0}
	elseif type==35 then
		self.temDefenseAITroops={0,0,0,0,0,0}
	end
	AITroopsFleetVoApi:clearAITroops()
end

-- 得到部队信息
function ltzdzFightApi:getTankInfoByTid(aid)
	local uid=tostring(playerVoApi:getUid())
	local myinfo=self.userInfo[uid]
	local troops=myinfo.binfo.troops
	return troops[aid]
end

function ltzdzFightApi:getSingleTankFighting(tankID)
	local tankInfo=self:getTankInfoByTid(tankID)
	-- print("tankID",tankID)

	local life=tankInfo.maxhp -- 血量
	local dmg=tankInfo.dmg --伤害
	local weaponType=tankInfo.weaponType
	local accuracy=tankInfo.accuracy --精准
	local evade=tankInfo.evade --闪避
	local evade_reduce=tankInfo.evade_reduce-- 减敌方闪避
	local crit=tankInfo.crit--爆击
	local anticrit=tankInfo.anticrit --免役暴击 韧性 装甲
	local anticrit_reduce=tankInfo.anticrit_reduce-- 减敌方装甲
	local critDmg=tankInfo.critDmg -- 暴击造成的伤害倍数
	local decritDmg=tankInfo.decritDmg -- 减暴击造成的伤害倍数值
	local double_hit=tankInfo.double_hit -- 连击
	local dedouble_hit=tankInfo.dedouble_hit -- 减连击
	local arp=tankInfo.arp -- 穿透
	local armor=tankInfo.armor -- 防护
	local buff_value=tankInfo.buffvalue -- 此值是后来直接赋加在tank上的，原来是动态计算的
	local buffType=tankInfo.buffType
	local abilityID=tankInfo.abilityID
	if abilityID=="" or abilityID==0 then
		abilityID=nil
	end
	local abilityLv=tankInfo.abilityLv
	local dmg_reduce=tankInfo.dmg_reduce  -- 减伤

	-- local fightCfg=ltzdzVoApi:getFightCfg()
	-- local dmgCount=fightCfg.dmgCount
	-- local buffTypeEff=fightCfg.buffTypeEff
	-- local abilityEff=fightCfg.abilityEff

	-- -- print("buffType,abilityID",buffType,abilityID,abilityLv)
	-- local dmgAdd=dmgCount[weaponType] or 1
	-- local buffAdd=buffTypeEff[buffType] or 1
	-- local abilityAdd=1
	-- if abilityID==nil then
	-- 	abilityAdd=1
	-- else
	-- 	abilityAdd=abilityEff[abilityID][abilityLv]
	-- end

	-- local power = life * dmg * dmgAdd  * math.exp(1.8*accuracy+1.8*evade+1.8*evade_reduce+0.7*crit+0.7*anticrit+0.7*anticrit_reduce+0.32*critDmg+0.32*decritDmg+0.5*double_hit+0.5*dedouble_hit+0.005*arp+0.005*armor) * buff_value*buffAdd * abilityAdd / (1-dmg_reduce-buff_value*buffAdd)

	-- print("tankID",tankID)
	local tankid=tonumber(tankID) or tonumber(RemoveFirstChar(tankID))
	local fighting=tonumber(tankCfg[tankid].fighting)

	local abilityAdd
	if abilityID then
		abilityAdd=(1+0.2)
	else
		abilityAdd=(1+0)
	end

	local power=fighting*(1+accuracy/4)*(1+evade/4)*(1+evade_reduce/4)*(1+crit/4)*(1+anticrit/4)*(1+anticrit_reduce/4)*(1*dmg/4)*(1+life/4)*(1+arp/200)*(1+armor/200)*(1+critDmg/5)*(1+decritDmg/5)*(1+dmg_reduce/2)*abilityAdd

	return power
end

function ltzdzFightApi:getHeroList()
	if self.heroList then
		return self.heroList
	end
	self.heroList={}

	-- heroList
	local uid=tostring(playerVoApi:getUid())
	local myinfo=self.userInfo[uid]
	local heroList=myinfo.binfo.hero
	if heroList and SizeOfTable(heroList)>0 then
		local hvalue=myinfo.binfo.hvalue
		for k,v in pairs(hvalue) do
			local arr=Split(v[1],"-")
			local hid=arr[1]
			local tb={}
			tb[1]=tonumber(arr[2])
			tb[2]=0
			tb[3]=tonumber(arr[3])

			local skills=heroListCfg[hid].skills
			-- local skillIdTb={}
			-- local awakenSkill={}
			-- if(equipCfg[hid] and equipCfg[hid]["e1"] and equipCfg[hid]["e1"].awaken and equipCfg[hid]["e1"].awaken.skill)then
			-- 	awakenSkill=equipCfg[hid]["e1"].awaken.skill
			-- end
			-- for k,v in pairs(skills) do
			-- 	skillIdTb[v[1]]=1
			-- 	if(awakenSkill[v[1]])then
			-- 		skillIdTb[awakenSkill[v[1]]]=1
			-- 	end
			-- end

			local skillTb={}
			local hornorSkillTb={}
			local s=heroList[hid].s
			for kk,vv in pairs(s) do

				-- 徐判断一下是不是授勋技能 并且构造出授勋技能 （记得改） 已改
				-- if skillIdTb[vv[1]]==1 then -- 普通技能
				if(kk<=4)then
					skillTb[vv[1]]=vv[2]
				else -- 授勋技能
					table.insert(hornorSkillTb,{[vv[1]]=vv[2]})
				end
				

			end
			tb[4]=skillTb
			tb[5]=hornorSkillTb

			local vo = heroVo:new()
			vo:initWithData(hid,tb)
			table.insert( self.heroList, vo)
		end
		local function sortFunc(a,b)
			local hid1=a.hid
			local hid2=b.hid
			return hvalue[hid1][2]>hvalue[hid2][2]
		end
		table.sort(self.heroList,sortFunc)
	else
		return self.heroList
	end
	return self.heroList
end

function ltzdzFightApi:getAITroopsList()
	if self.aitroopsList then
		return self.aitroopsList
	end
	self.aitroopsList={}

	local uid=tostring(playerVoApi:getUid())
	local myinfo=self.userInfo[uid]
	if myinfo.binfo and myinfo.binfo.aitroops then
		for k,v in pairs(myinfo.binfo.aitroops) do
			 local vo = AITroopsVo:new()
            vo:init(k, v)
            table.insert(self.aitroopsList,vo)
		end
		local function sort(vo1,vo2)
	        if vo1 and vo2 and vo1.getTroopsStrength and vo2.getTroopsStrength then
	            return vo1:getTroopsStrength() > vo2:getTroopsStrength()
	        end
	        return false
		end
		table.sort(self.aitroopsList,sort)
	end
	return self.aitroopsList
end

--获取已经使用领悟技能
function ltzdzFightApi:getUsedRealiseSkill(hid)
	if hid then
		local heroList=self:getHeroList()
		if heroList and SizeOfTable(heroList)>0 then
			for k,v in pairs(heroList) do
				if v and v.hid==hid and v.honorSkill and #v.honorSkill>0 then
					return v.honorSkill
				end
			end
		end
	end
	return {}
end

-- ifAwaken是否已经觉醒了，otherSid是否计算另外一个sid对应的值
function ltzdzFightApi:getHeroSkillLvAndValue(hid,sid,productOrder,ifAwaken,otherSid,lv)
	local isMax = false
	local hVo = self:getHeroByHid(hid)
	local skillsCfg={}
	for k,v in pairs(heroListCfg[hid].skills) do
		if v[1]==sid then
			skillsCfg=v
			break
		end
	end
	local level
	if(lv)then
		level=lv
	else
		level = hVo.skill[sid]
		if level==nil then
			local awakenSkill=equipCfg[hid]["e1"].awaken.skill
			sid=awakenSkill[sid]	
			level = hVo.skill[sid]
		end
	end
	if ifAwaken==true then
		skillsCfg=heroListCfg[hid].skills[1]
	end
	local lvStr = G_LV()..level.."/"..skillsCfg[2][productOrder]
	if level==0 then
		level=1
		lvStr=G_LV()..level
	end
	
	local value=level*heroSkillCfg[sid].attValuePerLv*100
	local oldValue=0
	if ifAwaken==true and otherSid then
		oldValue = level*heroSkillCfg[otherSid].attValuePerLv*100
		value=value-oldValue
	end
	if ifAwaken==false and otherSid then
		oldValue = level*heroSkillCfg[otherSid].attValuePerLv*100
		value=oldValue-value
	end
	local valueStr=value.."%%"
	if heroSkillCfg[sid].attType=="antifirst" or heroSkillCfg[sid].attType=="first" then
		valueStr=value/100
	end
	if hVo.skill[sid]>=skillsCfg[2][productOrder] then
		isMax=true
	end
	return lvStr,valueStr,isMax,level
end

function ltzdzFightApi:getHeroHonorSkillLvAndValue(hid,sid,productOrder,lv)
	local isMax = false
	local hVo = self:getHeroByHid(hid)
	local level=0
	local skillList=hVo.honorSkill
	if(lv)then
		level=lv
	else
		for k,v in pairs(skillList) do
			if v and v[1] and v[2] then
				if sid==v[1] then
					level=v[2]
	    		end
    		end
    	end
    end
	-- local maxLv = self:getSkillMaxLevel(hid)
	if level==0 then
		level=1
    end
	local lvStr = G_LV()..level--.."/"..maxLv
	-- if level>=maxLv then
	-- 	isMax=true
 --    end
	
	local value=level*heroSkillCfg[sid].attValuePerLv*100
	local valueStr=value.."%%"
	if heroSkillCfg[sid].attType=="antifirst" or heroSkillCfg[sid].attType=="first" then
		valueStr=value/100
    end

	return lvStr,valueStr,isMax,level
end

-- 可选择的英雄列表
function ltzdzFightApi:getCanUseHeroList(bType,cid)
	local heroList=G_clone(self:getHeroList())

	local heroUse=self:getHeroTbByType(bType) -- 是否已经选择过
	for k,v in pairs(heroUse) do
		if v and v~=0 then
			for kk,vv in pairs(heroList) do
				if v==vv.hid then
					table.remove(heroList,kk)
					break
				end
			end
		end
	end

	local canUseHeroList={}
	for m,n in pairs(heroList) do
		if self:heroIsCanUse(n.hid,cid) then
			table.insert(canUseHeroList,n)
		end
	end
	-- 现在防守部队已经设置过的
	return canUseHeroList
end

-- 可选择的AI部队列表
function ltzdzFightApi:getCanUseAITroopsList(bType,cid)
	local aitroopsList=G_clone(self:getAITroopsList())
	local used=self:getAITroopsTbByType(bType) -- 是否已经选择过
	for k,v in pairs(used) do
		if v and v~=0 and v~="" then
			for kk,vv in pairs(aitroopsList) do
				if v==vv.id then
					table.remove(aitroopsList,kk)
					break
				end
			end
		end
	end

	local canUseAITroopsList={}
	for m,n in pairs(aitroopsList) do
		if self:AITroopsIsCanUse(n.id,cid) then
			table.insert(canUseAITroopsList,n)
		end
	end
	-- 现在防守部队已经设置过的
	return canUseAITroopsList
end

-- 得到城市防守的军徽
function ltzdzFightApi:getDefenceEmblem(bType,cid)
	local emblemID
	if bType==35 then
		local targetCity=self:getTargetCityByCid(cid)
		local defenseInfo=targetCity.d or {}
		emblemID=defenseInfo[3]
	elseif bType==36 then
	end
	if emblemID==0 then
		emblemID=nil
	end
	return emblemID
end

function ltzdzFightApi:canUseEmblemInSetFormation(useEid,useType)--仅用于领土 阵型“读取”使用,判断军徽是否可用
	if base.emblemSwitch==1 then
		 local reserveNum,fightNum,troops,curCid = self:UseInGetFormation( )
		 local equipList=self:getCanBattleEmblem()
		 for k,v in pairs(equipList) do
		 	if useEid == v.id and self:checkEquipCanUse(useType,v.id,curCid,v.num)==true then
		 		return true
		 	end
		 end
	end
	 return false
end

-- 判断军徽是否可用
function ltzdzFightApi:checkEquipCanUse(bType,equipId,cid,haveNum)
	-- 1判断行军队列中是否占用
	local num=self:getBattleNumById(equipId,cid)
	-- local userInfo=ltzdzFightApi:getUserInfo()
	-- local tqueue=userInfo.tqueue
	-- if tqueue then
	-- 	for k,v in pairs(tqueue) do
	-- 		-- print("v[8],pos",v[8],equipId)
	-- 		if v[8]==equipId then
	-- 			num=num+1
	-- 		end
	-- 	end
	-- end
	-- -- 2判断其它防守城是否占用
	-- local uid=playerVoApi:getUid()
	-- local cityTb=self.mapVo.city
	-- if cityTb then
	-- 	for k,v in pairs(cityTb) do
	-- 		if v.oid and tonumber(v.oid)==tonumber(uid) then -- 是自己的城市
	-- 			if k~=cid then -- 不是自己城的防守部队（自己城的防守部队能用）
	-- 				if v.d and v.d[3] then
	-- 					if v.d[3]==pos then
	-- 						num=num+1
	-- 					end
	-- 				end
					
	-- 			end
	-- 		end
	-- 	end
	-- end

	-- print("++++++haveNum,num",haveNum,num,equipId)
	if haveNum>num then
		return true
	else
		return false
	end
end

-- 最强的军徽
function ltzdzFightApi:getMaxStrongEquip(bType,cid)
	local maxStrongEquipId = nil
	local maxStrong=0
	local cfg1
	local cfg2
	local equipList=self:getCanBattleEmblem()
	for k,v in pairs(equipList) do
		if emblemTroopVoApi:checkIfIsEmblemTroopById(v.id)==true then
	        if v and self:checkEquipCanUse(bType,v.id,cid,v.num)==true then
	            local tStrong=emblemTroopVoApi:getTroopStrengthById(v.id,v)
	            if maxStrongEquipId==nil then
	                maxStrongEquipId=v.id
	                maxStrong=tStrong
	            else
	                if tStrong>maxStrong then
	                    maxStrongEquipId=v.id
	                    maxStrong=tStrong
	                end
	            end
	        end
		else
			cfg1 = v.cfg
			-- 判断是否有剩余装备
			if cfg1.etype==1 and self:checkEquipCanUse(bType,v.id,cid,v.num)==true then
				if maxStrongEquipId==nil then
					maxStrongEquipId = v.id
					maxStrong=cfg1.qiangdu
				else
					if cfg1.qiangdu>maxStrong then
						maxStrongEquipId=v.id
						maxStrong=cfg1.qiangdu
					end
				end
			end
		end
	end
	return maxStrongEquipId
end

-- 得到城市防守的飞机
function ltzdzFightApi:getDefencePlane(bType,cid)
	local planePos
	if bType==35 then
		local targetCity=self:getTargetCityByCid(cid)
		local defenseInfo=targetCity.d or {}
		planePos=defenseInfo[4]
	elseif bType==36 then
	end
	if planePos==0 then
		planePos=nil
	end
	return planePos
end

function ltzdzFightApi:checkPlaneCanUse(bType,pos,cid)
	-- 1判断行军队列中是否占用
	local tqueue=self.mapVo.tqueue or {}
	local myuid=tostring(playerVoApi:getUid())
	local selfTqueue=tqueue[myuid]
	if selfTqueue then
		for k,v in pairs(selfTqueue) do
			if v[10]==pos then
				return false
			end
		end
	end
	-- 2判断其它防守城是否占用
	local uid=playerVoApi:getUid()
	local cityTb=self.mapVo.city
	if cityTb then
		for k,v in pairs(cityTb) do
			if v.oid and tonumber(v.oid)==tonumber(uid) then -- 是自己的城市
				if k~=cid then -- 不是自己城的防守部队（自己城的防守部队能用）
					if v.d and v.d[4] then
						if v.d[4]==pos then
							return 
						end
					end
					
				end
			end
		end
	end

	return true
end

-- 获取强度最大飞机
function ltzdzFightApi:getMaxStrongPlane(bType,cid)
	local maxStrongPlanePos=nil
	local value=0
	for k,vo in pairs(self.planeList) do
		if vo then
			-- print("vo.idx",vo.idx)
			if self:checkPlaneCanUse(bType,vo.idx,cid)==true then
				if maxStrongPlanePos==nil then
					maxStrongPlanePos=vo.idx
				end
				local tmpValue=vo:getStrength() or 0
				if value<tmpValue then
					value=tmpValue
					maxStrongPlanePos=vo.idx
				end
			end
		end
	end
	return maxStrongPlanePos
end



function ltzdzFightApi:getFightMaxTank()
	local troops=ltzdzVoApi.clancrossinfo.troops
	local tankId=nil
	local maxPower=nil
	for k,v in pairs(troops) do
		local power=self:getSingleTankFighting(v)

		-- print("v",v,power)
		if maxPower==nil or power>maxPower then
			maxPower=power
			tankId=v
		end
	end
	return tonumber(RemoveFirstChar(tankId))
end

function ltzdzFightApi:getHeroByHid(hid)
	local heroList=self:getHeroList()
	local adjutants = {} --将领副官数据
	local myinfo = self:getUserInfo()
	if myinfo and myinfo.binfo and myinfo.binfo.hadj then
		local heroAjt = myinfo.binfo.hadj[hid] or {}
		for k,v in pairs(heroAjt) do
			for jid,jlv in pairs(v) do
				adjutants[tonumber(RemoveFirstChar(k))]={jid,jlv}
			end
		end
	end

	for k,v in pairs(heroList) do
		if hid and v.hid==hid then
			return v,adjutants
		end
	end
	return nil,nil
end

function ltzdzFightApi:heroIsCanUse(hid,cid)
	-- 1判断行军队列中是否占用
	-- mapVo
	local tqueue=self.mapVo.tqueue or {}
	local myuid=tostring(playerVoApi:getUid())
	local selfTqueue=tqueue[myuid]
	if selfTqueue then
		for k,v in pairs(selfTqueue) do
			local heroList=v[8]
			if heroList then
				for kk,vv in pairs(heroList) do
					if vv==hid then
						return false
					end
				end
			end
		end
	end

	-- 2判断其它防守城是否占用
	local uid=playerVoApi:getUid()
	local cityTb=self.mapVo.city
	if cityTb then
		for k,v in pairs(cityTb) do
			if v.oid and tonumber(v.oid)==tonumber(uid) then -- 是自己的城市
				if k~=cid then -- 不是自己城的防守部队（自己城的防守部队能用）
					if v.d and v.d[2] then
						for kk,vv in pairs(v.d[2]) do
							if vv==hid then
								return false
							end
						end
					end
					
				end
			end
		end
	end

	return true
end

function ltzdzFightApi:AITroopsIsCanUse(atid,cid)
	-- 1判断行军队列中是否占用
	local tqueue=self.mapVo.tqueue or {}
	local myuid=tostring(playerVoApi:getUid())
	local selfTqueue=tqueue[myuid]
	if selfTqueue then
		for k,v in pairs(selfTqueue) do
			local aitroops=v[12]
			if aitroops then
				for kk,vv in pairs(aitroops) do
					if vv==atid then
						return false
					end
				end
			end
		end
	end

	-- 2判断其它防守城是否占用
	local uid=playerVoApi:getUid()
	local cityTb=self.mapVo.city
	if cityTb then
		for k,v in pairs(cityTb) do
			if v.oid and tonumber(v.oid)==tonumber(uid) then -- 是自己的城市
				if k~=cid then -- 不是自己城的防守部队（自己城的防守部队能用）
					if v.d and v.d[7] then
						for kk,vv in pairs(v.d[7]) do
							if vv==atid then
								return false
							end
						end
					end
				end
			end
		end
	end

	return true
end

function ltzdzFightApi:bestHero(tType,bestTab,cid)
	local tb = {0,0,0,0,0,0}
	local heroList=G_clone(self:getHeroList())
	for k,v in pairs(bestTab) do
		if v and SizeOfTable(v)>0 then
			local temHero=nil
			local temPower=0
			for m,n in pairs(heroList) do
				if self:heroIsCanUse(n.hid,cid) then
					local heroPower=0
					for i,j in pairs(heroListCfg[n.hid].heroAtt) do
						heroPower=heroPower+j[1]*n.productOrder*10+j[2]*n.level*10
					end
					local effectValue=1
					for i,j in pairs(n.skill) do
						local skillCfg=heroSkillCfg[i]
						if skillCfg.conditionType then
							local cType=tonumber(skillCfg.conditionType)
							if cType==21 then 	--前排生效
								effectValue=0
								if k<=3 then
									effectValue=1
								end
							elseif cType==22 then 	--后排生效
								effectValue=0
								if k>3 then
									effectValue=1
								end
							elseif cType>=26 and cType<=29 then 	--坦克类型
								effectValue=0
								local id=(tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
								local tType=tonumber(tankCfg[id].type)
								if cType==26 then	--坦克生效
									if tType==1 then
										effectValue=1
									end
								elseif cType==27 then 	--歼击车生效
									if tType==2 then
										effectValue=1
									end
								elseif cType==28 then 	--自行火炮生效
									if tType==4 then
										effectValue=1
									end
								elseif cType==29 then 	--火箭车生效
									if tType==8 then
										effectValue=1
									end
								end
							elseif cType==34 then
								effectValue=0
								local id=(tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
								local isSpecial=tonumber(tankCfg[id].isSpecial)
								if isSpecial and isSpecial==1 then
									effectValue=1
								end
							end
						end

						heroPower=heroPower+heroSkillCfg[i].skillPower*j*effectValue
					end
					if temHero==nil then
						temHero=n
					end

					if temPower==heroPower then
						local temHid=(tonumber(temHero.hid) or tonumber(RemoveFirstChar(temHero.hid)))
						local hid=(tonumber(n.hid) or tonumber(RemoveFirstChar(n.hid)))
						if temHid>hid then
							temHero=n
							temPower=heroPower
						end
					elseif temPower<heroPower then
						temHero=n
						temPower=heroPower
					end
				end
			end
			if temHero and temHero.hid then
				tb[k]=temHero.hid
				for m,n in pairs(heroList) do
					if temHero.hid==n.hid then
						table.remove(heroList,m)
					end
				end
			end
		end
	end
	return tb
end

--AI部队最大战力
function ltzdzFightApi:bestAITroops(tType,bestTab,cid) 
    local tb = {0, 0, 0, 0, 0, 0}
    if base.AITroopsSwitch==0 then
    	return tb
    end
    local num = 0
    local equipLimitNum = AITroopsFleetVoApi:AITroopsEquipLimitNum()
    local AITroopsTb = G_clone(self:getAITroopsList())
    for k,v in pairs(bestTab) do
     	if num >= equipLimitNum then --达到装配个数限制
            do break end
        end
    	local tankId, tankNum = v[1], v[2]
        if tankId and tankNum and tonumber(tankNum) > 0 then --该位置有坦克
        	for kk,vv in pairs(AITroopsTb) do
        		if self:AITroopsIsCanUse(vv.id,cid)==true then
        			num = num + 1
		            tb[k] = vv.id
		            table.remove(AITroopsTb,kk)
		            do break end
        		end
        	end
        end
    end
    return tb
end

function ltzdzFightApi:UseInGetFormation( )
	local curCid = self:getCurStartCid()
	local reserveNum=self:getReserveNumBuCid(curCid) -- 预备役数量
    -- 实际防守部队
    local realTb=self:getDefenceByCid(curCid)
    local defenseNum=self:getTankNumByTb(realTb)
    reserveNum=reserveNum+defenseNum -- (预备役和防守部队的和)

    local fightNum=self:getFightNum()
    local troops=ltzdzVoApi.clancrossinfo.troops
    return reserveNum,fightNum,troops,curCid
end
-- 最大战力
function ltzdzFightApi:getBestTanks(tType,cid)
	 -- 判断军徽开关，选择强度最高的军徽
    local maxEmblemID = nil
    
    if base.emblemSwitch==1 then
    	local equipList=self:getCanBattleEmblem()
		if #equipList>0 then
	        maxEmblemID = self:getMaxStrongEquip(tType,cid)
	        emblemVoApi:setTmpEquip(maxEmblemID,tType)
	    end
    end
    -- 判断飞机开关，选择强度最高的飞机
    local maxPlanePos = nil
    if base.plane==1 then
    	local planeList=self:getCanBattlePlane()
    	if #planeList>0 then
    		maxPlanePos = self:getMaxStrongPlane(tType,cid)
	        planeVoApi:setTmpEquip(maxPlanePos,tType)
    	end
    end

    local reserveNum=self:getReserveNumBuCid(cid) -- 预备役数量

    -- 实际防守部队
    local realTb=self:getDefenceByCid(cid)
    local defenseNum=self:getTankNumByTb(realTb)
    reserveNum=reserveNum+defenseNum -- (预备役和防守部队的和)


    local fightNum=self:getFightNum()
    local addNum=0
    if maxEmblemID then
    	local emTroopVo
    	if tType==35 or tType==36 then
    		emTroopVo=self:getEmblemTroopById(maxEmblemID)
    	end
    	addNum=emblemVoApi:getTroopsAddById(maxEmblemID,emTroopVo)
    end
    
    local totalNum=fightNum+addNum
    local tankId=self:getFightMaxTank()
    -- print("fightNum,addNum,tankId",fightNum,addNum,tankId)
    local bestTab={}
    for i=1,6 do
    	if reserveNum>totalNum then
    		reserveNum=reserveNum-totalNum
    		table.insert(bestTab, {tankId,totalNum})
    	else
    		if reserveNum==0 then
    		else
    			table.insert(bestTab, {tankId,reserveNum})
    		end
    		break
    	end
    end

    local heroTb=ltzdzFightApi:bestHero(tType,bestTab,cid)
    local AITroops=ltzdzFightApi:bestAITroops(tType,bestTab,cid)

    return bestTab,heroTb,maxEmblemID,maxPlanePos,AITroops
end

-- flag 1:自己  2：同盟 3：敌人 4：无人占领
function ltzdzFightApi:cityBelong(cid)
	local flag=4
	if self.mapVo and self.mapVo.city then
		local city=self.mapVo.city
		if city and city[cid] and city[cid].oid then
			local oid=city[cid].oid
			local uid=playerVoApi:getUid()
			if tonumber(uid)==tonumber(oid) then
				return 1
			end
			local userInfo = self:getUserInfo()
			if userInfo and userInfo.ally and tonumber(userInfo.ally)==tonumber(oid) then
				return 2
			end
			return 3
		end
	end
	return flag
end

-- 直接赋值，得遍历所有城刷新，不是遍历当前city（投降之后变为野城）
function ltzdzFightApi:updateCity2(city)
	if self.mapVo==nil then
		return
	end
	self.mapVo.city=city
end

function ltzdzFightApi:updateCity(city,clearScout)
	if not city then
		return
	end
	if self.mapVo==nil then
		return
	end
	if self.mapVo and self.mapVo.city then
		for cid,data in pairs(city) do
			-- print("clearScout",clearScout)
			if clearScout then
				local oldInfo=self.mapVo.city[cid] or {}
				local newInfo=data
				local oldOid=oldInfo.oid or 0
				local newOid=newInfo.oid or 0
				-- print("clearScout",cid)

				if tonumber(newOid)~=tonumber(oldOid) then -- 城市易主，清除侦察信息
					self:clearScoutByCid(cid)
				end
				
			end
			if data and SizeOfTable(data)==0 then
				self.mapVo.city[cid]=nil
				-- print("投降，数据删除")
			else
				if self.mapVo.city[cid] then
					if self.mapVo.city[cid].n~=data.n then --预备役发生变化推送消息刷新预备役
						eventDispatcher:dispatchEvent("ltzdz.resChanged")
					end
				end
				-- if self.mapVo.city[cid] then
				-- 	for k,value in pairs(data) do -- 差量更新
				-- 		-- print("+++++++k",k)
				-- 		if k=="b" then -- 差量更新b
				-- 			if self.mapVo.city[cid][k] then
				-- 				for kk,vv in pairs(value) do
				-- 					self.mapVo.city[cid][k][kk]=vv
				-- 				end
				-- 			else
				-- 				self.mapVo.city[cid][k]=value
				-- 			end
				-- 		else
				-- 			self.mapVo.city[cid][k]=value
				-- 		end
				-- 	end
				-- else
					self.mapVo.city[cid]=data
				-- end
			end

				
			-- if clearScout
		end
	end
	-- print("刷新city")
	eventDispatcher:dispatchEvent("ltzdz.refreshCity",city)
end

--uid需要获取的玩家数据，uid不传的话默认获取自己
function ltzdzFightApi:getUserInfo(uid)
	if self.userInfo==nil then
		do return nil end
	end
	if uid then
		if tonumber(uid)<100 then
			return self:getNpcInfo(tonumber(uid))
		else
			uid=tostring(uid)
			return self.userInfo[uid]
		end
	else
		local myuid=tostring(playerVoApi:getUid())		
		return self.userInfo[myuid]
	end
	return nil
end

function ltzdzFightApi:getNpcInfo(uid)
	local mapUser=self:getMapUserList()
	local ncpInfo=mapUser[tostring(uid)] or {}
	local fc=ncpInfo.t or 0
	local rpoint=ncpInfo.rp
	local zid=self:getNpcServerZid(uid)
	-- print("uid,zid",uid,zid)
	return {pic=1,uid=uid,most="",rpoint=rpoint,nickname=getlocal("ltzdz_npc_name_" .. uid),defeat=0,record={},fc=fc,zid=zid}
end

function ltzdzFightApi:getNpcServerZid(uid)
	-- GetServerNameByID(id) -- 这个方法改，这个方法就有可能改
	local zid=base.curZoneID

	if serverCfg.realAllServer then
		local zidTb={}
		for kk,vv in pairs(serverCfg.realAllServer) do
            for k,v in pairs(vv) do
            	if v.zoneid then
            		table.insert(zidTb,tonumber(v.zoneid))
            	end
            end
        end
        local idNum=SizeOfTable(zidTb)
        local zid=tonumber(uid)%idNum+1
        return zidTb[zid]
	end
	if serverCfg.allserver then
		local zidTb={}
		for kk,vv in pairs(serverCfg.allserver) do
            for k,v in pairs(vv) do
            	if v.zoneid then
            		table.insert(zidTb,tonumber(v.zoneid))
            	end
            end
        end
        local idNum=SizeOfTable(zidTb)
        -- print("+++++idNum",idNum)
        local zid=tonumber(uid)%idNum+1
        -- print("uid,idNum",uid,idNum,zid,zidTb[zid])
        return zidTb[zid]
	end
	return zid
end



--获取当前房间的用户列表
function ltzdzFightApi:getUserList()
	return self.userInfo or {}
end

function ltzdzFightApi:getMapUserList()
	if self.mapVo==nil then
		return {}
	end
	return self.mapVo.user or {}
end

function ltzdzFightApi:getMyRes()
	local metal,oil,gems=0,0,0
	local myinfo=self:getUserInfo()
	metal=myinfo.metal or 0
	oil=myinfo.oil or 0
	gems=myinfo.gems or 0
	return metal,oil,gems
end

--同步自己的资源数
function ltzdzFightApi:syncMyRes(metal,oil,gems)
	local myuid=tostring(playerVoApi:getUid())
	if self.userInfo and self.userInfo[myuid] then
		local myinfo=self.userInfo[myuid]
		if metal and metal>0 then
			myinfo.metal=metal
		end
		if oil and oil>0 then
			myinfo.oil=oil
		end
		if gems and gems>0 then
			myinfo.gems=gems
		end
	end
    eventDispatcher:dispatchEvent("ltzdz.resChanged")
end

function ltzdzFightApi:isMetalEnough(cost)
	local flag,own,lack=true,0,0
	local myinfo=self:getUserInfo()
	if myinfo then
		own=myinfo.metal or 0
		if cost>own then
			flag=false
			lack=cost-own
		end
	end
	return flag,own,lack
end

--金币够不够
function ltzdzFightApi:isGemsEnough(cost)
	local flag,own,lack=true,0,0
	local myinfo=self:getUserInfo()
	if myinfo then
		own=myinfo.gems or 0
		if cost>own then
			flag=false
			lack=cost-own
		end
	end
	return flag,own,lack
end

--石油够不够
function ltzdzFightApi:isOilEnough(cost)
	local flag,own,lack=true,0,0
	local myinfo=self:getUserInfo()
	if myinfo then
		own=myinfo.oil or 0
		if cost>own then
			flag=false
			lack=cost-own
		end
	end
	return flag,own,lack
end

function ltzdzFightApi:getTargetCityByCid(cid)
	local city=self.mapVo.city
	if not city then
		return nil
	end
	local targetCity=city[cid]
	return targetCity
end

-- 该城市是否设置了防守部队
function ltzdzFightApi:isSetTroops(cid)
	local targetCity=self:getTargetCityByCid(cid)
	if targetCity then
		if targetCity.d and targetCity.d[6] then
			for k,v in pairs(targetCity.d[6]) do
				if v and v[1] then
					return true
				end
			end
		end
	end
	return false
	
end

-- 设置部队
function ltzdzFightApi:setTroopsSocket(refreshFunc,action,state,cid,fleetinfo,hero,sequip,plane,line,reserveNum,aitroops)
	if action==2 and state==1 then
		-- 是否设置了部队，如果没有设置部队，不能自动补充
		if self:isSetTroops(cid)==false then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage25119"),30)
			do return end
		end
	end
	local function setTroopsFunc(fn,data)
		local ret,sData=base:checkServerData2(data)
		if ret==true then
			if sData and sData.data and sData.data.map and sData.data.map.city then
				self:updateCity(sData.data.map.city)
			end
			if sData and sData.data and sData.data.user then
				self:updateUser(sData.data.user)
			end
			if sData and sData.data and sData.data.mtq then -- map下面的队列
				self:updateMapTqueue(sData.data.mtq)
			end
			if sData and sData.data and sData.data.utq then -- user下面的队列
				self:updateUserTqueue(sData.data.utq)
			end
			if refreshFunc then
				refreshFunc()
			end
		else
			if refreshFunc then
				refreshFunc()
			end
		end
	end
	local roomid=ltzdzVoApi.clancrossinfo.roomid
	local tid=ltzdzVoApi.clancrossinfo.tid
	socketHelper2:ltzdzSetTroops(setTroopsFunc,action,roomid,state,cid,fleetinfo,hero,sequip,plane,line,reserveNum,tid,aitroops)
end

-- 赋值更新
function ltzdzFightApi:updateMapTqueue2(mtq)
	if self.mapVo==nil then
		return
	end
	self.mapVo.tqueue=mtq

end

-- 更新地图队列（出征）差量
function ltzdzFightApi:updateMapTqueue(mtq)
	if self.mapVo==nil then
		return
	end
	local mapTqueue=self.mapVo.tqueue or {}
	for k,v in pairs(mtq) do
		for kk,vv in pairs(v) do
			if mapTqueue[k]==nil then
				mapTqueue[k]={}
			end
			if vv and #vv~=0 then
				mapTqueue[k][kk]=vv
			else
				mapTqueue[k][kk]=nil
			end
		end
	end
	local data={}
	data.mtq=mtq
    eventDispatcher:dispatchEvent("ltzdz.refreshMatchLine",data)
end

function ltzdzFightApi:updateUserTqueue2(utq)
	local selfUserInfo=self:getUserInfo()
	if selfUserInfo==nil then
		return
	end
	selfUserInfo.tqueue=utq
end

-- 更新user队列(运输)
function ltzdzFightApi:updateUserTqueue(utq)
	-- local userTqueue=self.use
	local selfUserInfo=self:getUserInfo()
	if selfUserInfo==nil then
		return
	end
	local userTqueue=selfUserInfo.tqueue or {}
	for k,v in pairs(utq) do
		if v and #v~=0 then
			userTqueue[k]=v
		else
			userTqueue[k]=nil
		end
	end
	local data={}
	data.utq=utq
	eventDispatcher:dispatchEvent("ltzdz.refreshMatchLine",data)
end

--如果传segment和slv的话，得到的指定段位的buff加成，如果不传则是玩家当前的buff加成
function ltzdzFightApi:getTitleBuff(segment,slv)
	local seg,smallLevel,totalSeg=0,0,0
	if segment and slv then
		seg=segment
		smallLevel=slv
		totalSeg=ltzdzVoApi:getTotalSeg(seg,smallLevel)
	else
   		seg,smallLevel,totalSeg=ltzdzVoApi:getSegment()
	end
	local warCfg=ltzdzVoApi:getWarCfg()
	local rescbuff,rlbuff=0,0 --rescbuff是三种资源的加成buff，relbuff是城市预备役上限加成
	local buffCfg=warCfg.titleBuff[totalSeg]
	if buffCfg then
		rescbuff=buffCfg[1]
		rlbuff=buffCfg[2]
	end
	return rescbuff,rlbuff,totalSeg
end

function ltzdzFightApi:getMapVo()
	return self.mapVo
end

-- 预备役上限
function ltzdzFightApi:getReserveLimit(cType,cLv)
	local _,reserveBuff,totalSeg=self:getTitleBuff()
	local buildCfg=ltzdzVoApi:getBuildingCfg()
	local capacity=buildCfg[cType].capacity
	return math.ceil((1+reserveBuff)*capacity[cLv])
end

-- 得到当前城市的预备役数量
function ltzdzFightApi:getReserveNumBuCid(cid)
	if self.mapVo and self.mapVo.city then
		local targetCity=self.mapVo.city[cid]
		return targetCity.n or 0
	end
	return 0
	
end

-- 得到城市的防守部队
function ltzdzFightApi:getDefenceByCid(cid)
	local targetCity=self:getTargetCityByCid(cid)
    local defenseInfo=targetCity.d or {}
    local tankD=defenseInfo[1] or {{},{},{},{},{},{}}
    local heroD=defenseInfo[2] or {0,0,0,0,0,0}
    local emblemID=defenseInfo[3]
    local planePos=defenseInfo[4]
    local aitroops=defenseInfo[7] or {0,0,0,0,0,0}
    local tskin = defenseInfo[8] or {}
	return tankD,heroD,emblemID,planePos,aitroops,tskin
end

function ltzdzFightApi:getTankNumByTb(tankTb)
	local num=0
	local slotNum=0
	if tankTb then
		for k,v in pairs(tankTb) do
			if v and v[2] then
                num=num+v[2]
                slotNum=slotNum+1
            end
		end
	end
	return num,slotNum
end

-- 出征部队是否用到防守部队
function ltzdzFightApi:isUseDefense(cid,aTankTb,aHeroTb,aEmblemId,aPlanePos,aAITroops)
	local aNum=self:getTankNumByTb(aTankTb)
	local cityInfo=self:getTargetCityByCid(cid)
	local dNum=cityInfo.n or 0
	if aNum>dNum then
		return true
	end
	local _,heroD,emblemID,planePos,aitroops=self:getDefenceByCid(cid)
	if aHeroTb and heroD then
		for k,v in pairs(aHeroTb) do
			for kk,vv in pairs(heroD) do
				if v==vv and type(v)~="number" then
					return true
				end
			end
		end
	end
	if aAITroops and aitroops then
		for k,v in pairs(aAITroops) do
			for kk,vv in pairs(aitroops) do
				if v==vv and v~=0 and vv~=0 and v~="" and vv~="" then
					return true
				end
			end
		end
	end
	if planePos and aPlanePos then
		if planePos == aPlanePos and aPlanePos~=0 then
			return true
		end
	end
	if emblemID and aEmblemId then
		if emblemID==aEmblemId and aEmblemId~=nil then
			local useNum=self:getBattleNumById(emblemID,cid)
			local equipList=self:getCanBattleEmblem()
			for k,v in pairs(equipList) do
				if v.id==emblemID then
					if v.num==useNum+1 then
						return true
					end
				end
			end
		end
	end
	return false
end

-- 得到能用的最大部队数量
function ltzdzFightApi:getCanUseTroopsNum(pType,cid)
	local reserveNum=self:getReserveNumBuCid(cid)

	-- 实际防守部队
    local realTb=self:getDefenceByCid(cid)
    local defenseNum=self:getTankNumByTb(realTb)

    local defenseTab=tankVoApi:getTanksTbByType(pType)
    local totalUse=self:getTankNumByTb(defenseTab)
    return reserveNum+defenseNum-totalUse

end

-- 是否是真正战斗，城市没有被保护
function ltzdzFightApi:isTrueBattle()
	local clancrossinfo=ltzdzVoApi.clancrossinfo or {}
	local startTime=clancrossinfo.st or 0
	if base.serverTime>=startTime then
		return true
	end
	return false
end

-- 是否是被保护城市
function ltzdzFightApi:isPrtCity(cid)
	local mapCfg=ltzdzVoApi:getMapCfg()
	local prtCity=mapCfg.prtCity
	if prtCity[cid]==1 then
		return true
	end
	return false
end

-- 出征1 运输2 得到可攻打的或者运输的城市列表
function ltzdzFightApi:getTargetCityTb(flag,startCid)
	local targetCityTb={}
	local mapCfg=ltzdzVoApi:getMapCfg()
	local adjoin=mapCfg.citycfg[startCid].adjoin
	local cityTb=self.mapVo.city or {}
	local uid=playerVoApi:getUid()
	local userInfo = self:getUserInfo(tostring(uid))
	local ally=userInfo.ally or 0

	local function searchFunc(cid)
		if targetCityTb[cid]==1 or targetCityTb[cid]==2 or targetCityTb[cid]==3 or startCid==cid then
			return
		end
		if cityTb[cid]==nil then
			targetCityTb[cid]=2 -- 能攻打的城
			return
		end
		local oid=tonumber(cityTb[cid].oid or 0)
		if tonumber(oid)==(uid) then
			targetCityTb[cid]=1 -- 能运输的城
			local adjoin=mapCfg.citycfg[cid].adjoin
			for k,v in pairs(adjoin) do
				searchFunc(k)
			end
		else
			if tonumber(ally)==oid and oid~=0 then
				targetCityTb[cid]=3 -- 同盟（找最短路径要用）
				local adjoin=mapCfg.citycfg[cid].adjoin
				for k,v in pairs(adjoin) do
					searchFunc(k)
				end
			else
				targetCityTb[cid]=2 -- 能攻打的城
				return
			end
		end
	end

	for k,v in pairs(adjoin) do
		searchFunc(k)
	end

	
	-- for k,v in pairs(targetCityTb) do
	-- 	print(k,v)
	-- end
	-- print("===========")
	if flag==2 then
		for k,v in pairs(targetCityTb) do
			if v==2 then
				targetCityTb[k]=nil
			end
		end
	else
		-- 先注掉，记得打开，因为现在配置不正确
		-- -- 判断受保护时间不能攻打的城市
		local startTime=ltzdzVoApi.clancrossinfo.st
		local trueBattleF=(base.serverTime>startTime)
		-- print("trueBattleF",trueBattleF)

		if trueBattleF==false then
			local prtCity=mapCfg.prtCity
			for k,v in pairs(targetCityTb) do
				if prtCity[k]==1 and targetCityTb[k]==2 then
					targetCityTb[k]=nil
				end
			end
		end
	end
	-- for k,v in pairs(targetCityTb) do
	-- 	print(k,v)
	-- end
	return targetCityTb
end

-- 自己的城和同盟的城
function ltzdzFightApi:getAllCityCanWalk(targetCityTb)
	local havaCityTb={}
	for k,v in pairs(targetCityTb) do
        if v~=2 then
            table.insert(havaCityTb,k)
        end
    end
    return havaCityTb
end

-- 行军时间
-- flag 1:自己城  2：不是自己的城
function ltzdzFightApi:getMarchTime(line,flag)
	local time=0
	if line then
		local mapCfg=ltzdzVoApi:getMapCfg()
		local cityCfg=mapCfg.citycfg
		for i=1,#line-1 do
			local adjoin=cityCfg[line[i]].adjoin
			time=time+adjoin[line[i+1]]
		end
	end
	if flag==1 then
		local warCfg=ltzdzVoApi:getWarCfg()
		local transSpeed=warCfg.transSpeed
		time=transSpeed*time
	end
	return time
end

-- 行军耗油
-- flag 1:战斗  2：运输
function ltzdzFightApi:getMarchOil(num,time,flag)
	local warCfg=ltzdzVoApi:getWarCfg()
	local marchOilCost=warCfg.marchOilCost
	return math.ceil(time*num*marchOilCost[flag])
end


--差量更新user数据
function ltzdzFightApi:updateUser(userlist,hardFlag)
	if not userlist then
		return
	end
	if not self.userInfo then
		return
	end
	for k,v in pairs(userlist) do
		local user=self.userInfo[k]
		if user then
			if v.bag then
				user.bag=v.bag
			end
			if v.tmoney then
				user.tmoney=v.tmoney
			end
			local flag=false
			if v.oil then
				user.oil=v.oil
				flag=true
			end
			if v.gems then
				user.gems=v.gems
				flag=true
			end
			if v.metal then
				user.metal=v.metal
				flag=true
			end
			if v.scout then -- 差异更新
				self:updateScout(user,v.scout,hardFlag)
			end
			if v.usenum then
				user.usenum=v.usenum
			end
			if v.task then --更新任务数据
				self:updateTask(v.task)
			end
			if v.point then --功勋值
				user.point=v.point
			end
			local allyChangeFlag=false --外交关系发生变化
			if v.invite then --邀请玩家id
				user.invite=v.invite
				allyChangeFlag=true
			end
			if v.invitelist then --被邀请的id列表
				user.invitelist=v.invitelist
				allyChangeFlag=true
			end
			if v.ally then --盟友id
				user.ally=v.ally
				allyChangeFlag=true
			end
			-- print("allyChangeFlag------>>>>>>",allyChangeFlag)
			if allyChangeFlag==true then
				eventDispatcher:dispatchEvent("ltzdz.allyChanged") --同步外交关系
			end
			if flag==true then
				eventDispatcher:dispatchEvent("ltzdz.resChanged") --同步资源
			end
		else
			self.userInfo[k]=v
		end
	end
end

function ltzdzFightApi:updateScout(user,scout,hardFlag)
	if user.scout==nil then
		user.scout={}
	end
	if hardFlag then
		user.scout=scout
		do return end
	end
	for k,v in pairs(scout) do
		user.scout[k]=v
	end
end

--计策商店购买或者使用道具
function ltzdzFightApi:buyOrUsePropsRequest(action,tid,usegems,callBack,cid,tqid)
	local function buyOrUseCallBack(fn,data)
		local ret,sData=base:checkServerData2(data)
		if ret==true then
			self:updateUser(sData.data.user) --更新用户数据
			if sData and sData.data and sData.data.mtq then -- map下面的队列
				self:updateMapTqueue(sData.data.mtq)
			end
			if sData and sData.data and sData.data.utq then -- user下面的队列
				self:updateUserTqueue(sData.data.utq)
			end
			if sData and sData.data and sData.data.city then --使用与城市有关的道具时更新城市数据
				self:updateCity(sData.data.city)
			end
			if callBack then
				callBack()
			end
			if tid=="t4" and action==2 then --如果使用的补充代币的道具，则发消息检测建筑自动升级状态
				eventDispatcher:dispatchEvent("ltzdz.checkAutoUpgrade")
			end
		end
	end
	local roomid=ltzdzVoApi.clancrossinfo.roomid
	local stid=ltzdzVoApi.clancrossinfo.tid
	socketHelper2:ltzdzBuyOrUseProps(action,tid,usegems,cid,tqid,roomid,buyOrUseCallBack,stid)
end

-- 得到城市图片
function ltzdzFightApi:getCityPic(cType,level)
	if not level then
		level=1
	end
	if level>5 then --测试使用
		level=5
	end
	local cityPic="ltzdzSmallCity1.png"
	if cType==1 then
		cityPic="ltzdzBigCity" .. level .. ".png"
	else
		cityPic="ltzdzSmallCity" .. level .. ".png"
	end
	return cityPic
end

function ltzdzFightApi:getCityPicByCid(cid,level)
	local cityCfg=ltzdzVoApi:getMapCfg().citycfg
	local cfg=cityCfg[cid]
	if cfg and cfg.type then
		return self:getCityPic(cfg.type,level)
	end
	return nil
end

--同步城市的预备役
function ltzdzFightApi:syncCityReserve(ctb)
	local cityTb={}
	if self.mapVo and self.mapVo.city then
		for k,v in pairs(ctb) do
			local city=self.mapVo.city[k]
			if city then
				city.n=tonumber(v)
				cityTb[k]=city
			end
		end
	end
	eventDispatcher:dispatchEvent("ltzdz.refreshCity",cityTb)
end

function ltzdzFightApi:syncResRequest(callback)
	local function requestHandler(fn,data)
		local ret,sData=base:checkServerData2(data)
		if ret==true then
			local myInfo=self:getUserInfo()
			local lastMetal=myInfo.metal
			if sData.data.city then --刷新城市预备役
				self:syncCityReserve(sData.data.city)
			end
			if sData.data.user then
				self:updateUser(sData.data.user)
			end
			if callback then
				callback()
			end
			local metal=myInfo.metal
			-- print("lastMetal,metal---------->>>>>",lastMetal,metal)
			if metal>lastMetal then --金钱增长了则检测建筑自动升级的状态
				eventDispatcher:dispatchEvent("ltzdz.checkAutoUpgrade")
			end
		end
	end
	local roomid=ltzdzVoApi.clancrossinfo.roomid
	local tid=ltzdzVoApi.clancrossinfo.tid
	socketHelper2:ltzdzResSync(requestHandler,roomid,tid)
	self.syncResTime=base.serverTime+60	
end

-- 得到自己的所有队列
function ltzdzFightApi:getSelfAllSlot()
	local selfUserInfo=ltzdzFightApi:getUserInfo()
	if not selfUserInfo then
		return {}
	end
    local userTq=selfUserInfo.tqueue or {} -- 运输

    local mapTq=ltzdzFightApi.mapVo.tqueue or {}
    local uid=tostring(playerVoApi:getUid())
    local mapSelfTq=mapTq[uid] or {} -- 出征

    local creatTq={}
    for k,v in pairs(userTq) do
        table.insert(creatTq,{value=v,sid=k})
    end
    for k,v in pairs(mapSelfTq) do
        table.insert(creatTq,{value=v,sid=k})
    end

    -- 排序
    local function sortFunc(a,b)
		return a.value[4]>b.value[4]
	end
	table.sort(creatTq,sortFunc)

    return creatTq
   
end

-- 队列的部队信息，用的侦察的板子（格式化数据格式）
function ltzdzFightApi:getSlotInfo(slotInfo)
	local trueInfo={}
	trueInfo.tank=slotInfo[7] or {}
	trueInfo.emblem=slotInfo[9]

	local planePos=slotInfo[10]
	local plane
	if planePos and planePos~=0 then
		local planeList=self:getCanBattlePlane()
		for k,v in pairs(planeList) do
			if v.idx==planePos then
				plane=v.pid
				break
			end
		end
	else
		plane=nil
	end
	trueInfo.plane=plane

	local hero=slotInfo[8] or {}
	local userInfo=self:getUserInfo()
	local hvalue=userInfo.binfo.hvalue
	local trueHero={}
	for k,v in pairs(hero) do
		if v and v~=0 then
			trueHero[k]=hvalue[v][1]
		else
			trueHero[k]=0
		end
	end
	trueInfo.hero=trueHero

	local aitroops = slotInfo[12] or {}
	local trueAITroops = {}
	local aitvalue = userInfo.binfo.aitroops
	for k,v in pairs(aitroops) do
		if v and tonumber(v)~=0 and v~="" then
			local vo = AITroopsVo:new()
			vo:init(v, aitvalue[v])
			trueAITroops[k]=vo
		else
			trueAITroops[k]=nil
		end
	end
	trueInfo.aitroops=trueAITroops --AI部队

	trueInfo.slotInfo=slotInfo -- 真sb,又要加信息
	
	return trueInfo
end

-- 是否显示情报（侦察）
function ltzdzFightApi:scoutIsVisible(cid)
	local myUserInfo=self:getUserInfo()
	local scout=myUserInfo.scout
	if scout then
		if scout[cid] then
			-- local warCfg=ltzdzVoApi:getWarCfg()
			-- local spyTime=warCfg.spyTime
			local scoutT=scout[cid].t -- 后台已经算好的过期时间
			if base.serverTime<=scoutT then
				return true,scout[cid]
			end
		end
	end
	return false
end

-- 侦察信息格式化
function ltzdzFightApi:getScoutInfo(cid)
	local myUserInfo=self:getUserInfo()
	local scoutInfo=myUserInfo.scout or {}
	local scout=scoutInfo[cid] or {}

	local warCfg=ltzdzVoApi:getWarCfg()
	local spyTime=warCfg.spyTime

	local reserve=scout.n or 0
	local d=scout.d or {}
	local b=scout.b or {}
	local defence=scout.rn or 0

	local scoutInfo={}
	scoutInfo.tank=d[1] or {}
	scoutInfo.hero=d[2] or {}
	scoutInfo.emblem=d[3]
	scoutInfo.plane=d[4]
	scoutInfo.aitroops=d[7] or {0,0,0,0,0,0} --AI部队信息
	scoutInfo.tskin=d[8] or {} --侦察部队的皮肤数据

	scoutInfo.reserve=reserve
	scoutInfo.defence=defence
	scoutInfo.cType=b[1] or 1
	scoutInfo.cLevel=b[2] or 1
	scoutInfo.st=base.serverTime - ((scout.t or 0) - spyTime)
	return scoutInfo
end

function ltzdzFightApi:clearScoutByCid(cid)
	local myUserInfo=self:getUserInfo()
	if myUserInfo then
		local scout=myUserInfo.scout or {}
		scout[cid]=nil
	end
end

--获取计策商店背包数据
function ltzdzFightApi:getMyBag()
  	local myinfo=ltzdzFightApi:getUserInfo()
    return myinfo.bag or {}
end

-- 取计策的详细信息
function ltzdzFightApi:getTvalueByTid(tid)
	local warCfg=ltzdzVoApi:getWarCfg()
	local tactics=warCfg.tactics
	return tactics[tid]
end

-- 目前拥有计策的数量
function ltzdzFightApi:getPropNumByTid(tid)
	local myInfo=ltzdzFightApi:getUserInfo()
	local propNum=0
	if myInfo and myInfo.bag then
		propNum=myInfo.bag[tid] or 0
	end
	return propNum
end

-- 目前拥有计策的数量
-- return 1:是否可以加速 2已经加速次数  3加速上限
function ltzdzFightApi:isCanAcc(slotInfo)
	local warCfg=ltzdzVoApi:getWarCfg()
	local runTroops=warCfg.runTroops
	if slotInfo[6]>=runTroops then
		return false,runTroops,runTroops
	else
		return true,slotInfo[6],runTroops
	end
end

function ltzdzFightApi:getCityLevel(cid,mCity)
	local level=1
	if mCity and mCity[cid] and mCity[cid].b and mCity[cid].b[2] then
		return mCity[cid].b[2]
	end
	return level
end

function ltzdzFightApi:getPerByCity(cityInfo,cityType)
	-- local warCfg=ltzdzVoApi:getWarCfg()
	-- local cityArmyLimit=warCfg.cityArmyLimit
	local cLv=cityInfo.b[2] or 1
	local reserveLimit=ltzdzFightApi:getReserveLimit(cityType,cLv)
	local haveRe=cityInfo.n or 0
	return haveRe/reserveLimit*100,haveRe,reserveLimit
end

-- 赋值更新，不做差量更新
function ltzdzFightApi:assignmentUpdate(data)
	if data.mtq then
        self:updateMapTqueue2(data.mtq)
    end
    if data.utq then -- user下面的队列
		self:updateUserTqueue2(data.utq)
	end
	local sbData={}
	sbData.delete=1
	eventDispatcher:dispatchEvent("ltzdz.refreshMatchLine",sbData)

end

-- 发生变化，后台推送数据
function ltzdzFightApi:updateFromeServer2(data,cmd)
	if cmd=="clanwar.result" then
		-- print("---------->>>>>>>clanwar.result<<<<<<<<---------- data.cwover",data.cwover)
		if data.cwover then --结算
			self:endBattle(nil,ltzdzVoApi.layerNum+5)
		end
		do return end
	end
	-- print("cmd,data.uover-------->",cmd,data.uover)
	local hardFlag=false
	--uover和clanwar.map.update是有人结算的标识
	if cmd=="clanwar.map.update" or (data.uover and tonumber(data.uover)==1) then --如果有人结算了则更新map下的user
		hardFlag=true
		if data.map and data.map.user then --如果有人结算则更新一下玩家的盟友关系
			local userlist=data.user or {}
			for k,v in pairs(data.map.user) do
				-- print("type(k),k,v,v.s------->>>",type(k),k,v,v.s)
				local user=userlist[k]
				if v.s~=1 then --说明该玩家已经结算
					if user==nil then
						user=self.userInfo[k]
					end
					if user then
						-- print("type(user.ally),user.ally------->",type(user.ally),user.ally)
						if user.ally and tonumber(user.ally)>0 then
							local allyUid=tostring(user.ally)
							allyUser=userlist[allyUid]
							if allyUser==nil then
								allyUser=self.userInfo[allyUid]
							end
							if allyUser and allyUser.ally and tonumber(allyUser.ally)==tonumber(k) then
								-- print("allyUser.ally------->",allyUser.ally)
								allyUser.ally=0
								allyUser.invite=0
								allyUser.invitelist={}
							end
						end
						user.invitelist={}
						user.invite=0
						user.ally=0
					end
				end
			end
		end
	end
	if data.mtq then
        self:updateMapTqueue(data.mtq)
    end
    if data.utq then -- user下面的队列
		self:updateUserTqueue(data.utq)
	end
    if data.map then
    	if data.map.user then
    		self:updateMapUser(data.map.user)
    	end
    end
    if data.user then
    	self:updateUser(data.user,hardFlag)
    end
    if data.city then
        self:updateCity(data.city,true)
    end
    if data.task then
    	self:updateTask(data.task)
    end

    if data.nr then -- 战报（有新的战报）
		require "luascript/script/game/gamemodel/ltzdz/ltzdzReportVoApi"
    	ltzdzReportVoApi:setNewReport(data.nr)
    end
	if cmd=="clanwarserver.invite" then --邀请盟友推送
		eventDispatcher:dispatchEvent("ltzdz.refreshTip",{tipType="invite"})
	end
end

function ltzdzFightApi:updateMapUser(user)
	if self.mapVo then
		self.mapVo.user=user or {}
	end
end

--更新任务数据
function ltzdzFightApi:updateTask(task)
	local myInfo=self:getUserInfo()
	if myInfo then
		myInfo.task=task
		eventDispatcher:dispatchEvent("ltzdz.updateTask")
	end
end

function ltzdzFightApi:getTaskInfo()
	local myInfo=self:getUserInfo()
	if myInfo and myInfo.task then
		return (myInfo.task[1] or {}),(myInfo.task[2] or base.serverTime),myInfo.task[3] or {}
	end
	return {},base.serverTime,{}
end

function ltzdzFightApi:getTaskList()
	local taskList={}
	local taskCfg=ltzdzVoApi:getWarCfg().task
	for k,v in pairs(taskCfg) do
		if taskList[v.type]==nil then
			taskList[v.type]={}
		end
		table.insert(taskList[v.type],k)
	end
	return taskList
end

function ltzdzFightApi:getSortTask(taskType,taskTb)
	local trueTask={}
	local taskCfg=ltzdzVoApi:getWarCfg().task
	for k,v in pairs(taskTb) do
		local state=self:getTaskState(v)
		local cfg=taskCfg[v]
		local index=cfg.sort
		-- if state==1 then --已领取
		-- 	index=index-10000
		-- elseif state==2 then --已完成
		-- 	index=index-1000
		-- elseif state==3 then --未完成
		-- 	index=index-100
		-- end
		local tb={index=index,id=v,state=state}
		table.insert(trueTask,tb)
	end
	local function sortFunc(a,b)
		return a.index<b.index
	end
	table.sort(trueTask,sortFunc)
	return trueTask
end

function ltzdzFightApi:getTaskInfoById(tid,value)
	local nameStr,descStr,simpleDescStr="","",""
	local taskCfg=ltzdzVoApi:getWarCfg().task
	local cfg=taskCfg[tid]
	if cfg then
		local cur=0
		if value then
			cur=value
		else
	        local progressTb,ts,stateTb=self:getTaskInfo()
	 		cur=progressTb[cfg.type] or 0
		end
    	local max=cfg.conditions
		descStr=getlocal("ltzdz_tasktype_desc_"..cfg.type,{cur.."/"..max})
		simpleDescStr=getlocal("ltzdz_tasktype_simpledesc_"..cfg.type,{max})
	end
	return descStr,simpleDescStr,nameStr
end

--获取任务的状态，1：已领取，2：已完成，3：未完成
function ltzdzFightApi:getTaskState(tid)
	local taskCfg=ltzdzVoApi:getWarCfg().task
	local cfg=taskCfg[tid]
	if cfg then
        local progressTb,ts,stateTb=self:getTaskInfo()
        if stateTb[tid]==1 then
        	return 1
        end
	 	local cur=progressTb[cfg.type] or 0
    	local max=cfg.conditions
    	if cur>=max then
    		return 2
    	else
    		return 3
    	end
    end
    return 3
end

--获取当前未完成的任务
function ltzdzFightApi:getCurTask()
    local taskList=self:getTaskList()
    for k,v in pairs(taskList) do
	    local trueTaskTb=self:getSortTask(k,taskList[k])
    	for k,v in pairs(trueTaskTb) do
    		if v.state==3 then
    			do return v end
    		end
    	end
    end
    return nil
end

-- 得到该计策的使用次数(t2除外，记在了行军队列上)
function ltzdzFightApi:getUseNumByTid(tid)
	local selfInfo=self:getUserInfo()
	local usenumTb=selfInfo.usenum or {}
	return usenumTb[tid] or 0
end

-- 计策使用次数是否达到上限
function ltzdzFightApi:isRitchLimit(useNum,limit)
	if useNum>=limit then
		return true
	else
		return false
	end
end

function ltzdzFightApi:getAllCity()
	if self.mapVo and self.mapVo.city then
		return self.mapVo.city
	end
	return {}
end

function ltzdzFightApi:ltzdzAllyOperate(action,uid,callback)
	local function requestHandler(fn,data)
		local ret,sData=base:checkServerData2(data)
		if ret==true then
			if sData.data then
				if sData.data.user then --更新user数据
					self:updateUser(sData.data.user)
				end
				if sData.data.city then --更新盟友城市数据
					self:updateCity(sData.data.city)
				end
			end
			if callback then
				callback(ret)
			end
			if action==2 or action==3 then --当拒绝或者同意玩家盟友申请时，发消息刷新外交按钮红点提示
				eventDispatcher:dispatchEvent("ltzdz.refreshTip",{tipType="invite"})
			end
		elseif sData.ret==-25105 then --结盟后台数据异常的处理
        	if sData.data.user then
        		self:updateUser(sData.data.user)
        	end
		end
	end
	local roomid=ltzdzVoApi.clancrossinfo.roomid
	local tid=ltzdzVoApi.clancrossinfo.tid
	socketHelper2:ltzdzAllyOperate(action,roomid,uid,requestHandler,tid)
end

-- 出征（自己 敌人） 运输 
function ltzdzFightApi:getIconState(slotInfo)
	local iconPic="IconReturn-.png"
	local slotState=""
	if slotInfo[1]==1 then
        -- if slotInfo[11]==0 then -- 出征到自己城
        -- 	iconPic="IconDefense.png"
        -- else -- 攻打
        	iconPic="IconAttack.png"
        -- end
        slotState=getlocal("ltzdz_slot_state1")
    else -- 运输
        iconPic="IconOccupy.png"
        slotState=getlocal("ltzdz_slot_state2")
    end
    return iconPic,slotState
end

--是否可以投降
function ltzdzFightApi:isCanGiveup()
	local st=ltzdzVoApi.clancrossinfo.st
	local surTime=ltzdzVoApi:getWarCfg().surTime
	local gt=st+surTime
	if base.serverTime>=gt then
		return true,gt
	end
	return false,gt
end

--投降
function ltzdzFightApi:giveup(callback,layerNum)
	local function giveupHandler(fn,data)
		local ret,sData=base:checkServerData2(data)
		if ret==true then
			if sData.data.cwover then --投降结算了
				self:endBattle(callback,layerNum)
			end
		end
	end
	local roomid=ltzdzVoApi.clancrossinfo.roomid
	local tid=ltzdzVoApi.clancrossinfo.tid
	socketHelper2:ltzdzGiveUp(roomid,giveupHandler,tid)
end

function ltzdzFightApi:endBattle(callback,layerNum)
	ltzdzVoApi:resetRankExpireTime() --结算后清空排行请求过期时间数据
	-- self:disconnectSocket2() --断开跨服连接
	if ltzdzVoApi.ltzdzOpenDialog then
		for k,v in pairs(ltzdzVoApi.ltzdzOpenDialog) do
			if v and v.close then
				v:close()
			end
		end
	end

	-- self:disconnectSocket2() --断开跨服连接
	local function initCallBack()
		self:disconnectSocket2() --断开跨服连接
		if callback then
			callback()
		end
		self:clear() --结束后清数据
	end
	ltzdzVoApi:crossInit(initCallBack,layerNum)
end
-- 玩家颜色
function ltzdzFightApi:getUserColor(id)
	if id==1 then -- 红
		return ccc3(255,0,0)
	elseif id==2 then -- 橙
		return ccc3(200,130,40)
	elseif id==3 then -- 黄
		return ccc3(255,230,0)
	elseif id==4 then -- 绿
		return ccc3(30,200,0)
	elseif id==5 then -- 青
		return ccc3(0,240,230)
	elseif id==6 then -- 蓝
		return ccc3(0,60,255)
	elseif id==7 then -- 紫
		return ccc3(160,0,240)
	else -- 粉
		return ccc3(255,140,140)
	end
end

function ltzdzFightApi:syncFleet(tqid,refreshFunc)
	local function sync(fn,data)
		local ret,sData=base:checkServerData2(data)
		if ret==true then
			if sData and sData.data and sData.data.upfleet==1 then -- 前后台数据不一致（直接赋值更新不能差量更新）
				self:assignmentUpdate(sData.data)
			else
				self:updateFromeServer2(sData.data)
			end
			if refreshFunc then
				refreshFunc()
			end
		end
	end
	local roomid=ltzdzVoApi.clancrossinfo.roomid
	local tid=ltzdzVoApi.clancrossinfo.tid
	socketHelper2:ltzdzFleetsync(tqid,roomid,sync,tid)
end

--inviteUid：发起邀请的玩家uid，传的话返回的时自己是否被该玩家邀请，如果不传的话返回的是自己有没有被玩家邀请
function ltzdzFightApi:isBeInvited(inviteUid)
	local myInfo=self:getUserInfo()
	if myInfo and myInfo.invitelist then
		if inviteUid then
	      	for k,uid in pairs(myInfo.invitelist) do
	            if tonumber(uid)==tonumber(inviteUid) then
	            	return true
	            end
	        end
	    else
	    	if SizeOfTable(myInfo.invitelist)>0 then
	    		return true
	    	end
		end
	end
	return false
end

-- 程序home键切后台，回来的时候更新
function ltzdzFightApi:EnterForeground()
	-- print("ltzdzVoApi:getWarState()",ltzdzVoApi:getWarState())
	if ltzdzVoApi and ltzdzVoApi:getWarState()~=1 then
		if self.connected and self.userInfo then
			local function sync(fn,data)
				local ret,sData=base:checkServerData2(data)
				if ret==true then
					if sData and sData.data and sData.data.cwover then
						self:endBattle(nil,ltzdzVoApi.layerNum+5)
						return 
					end
					if sData and sData.data and sData.data.user then
						self:updateUser(sData.data.user)
					end
					if sData and sData.data and sData.data.map and sData.data.map.user then
						self:updateMapUser(sData.data.map.user)
					end

					-- 不能差量更新了
					-- if sData and sData.data and sData.data.mtq then
					-- 	self:updateMapTqueue(sData.data.mtq)
					-- end
					if sData and sData.data and sData.data.city then
						-- self:updateCity(sData.data.city)
						self:updateCity2(sData.data.city)
					end
					-- 不能差量更新了
					-- if sData and sData.data and sData.data.utq then
					-- 	self:updateUserTqueue(sData.data.utq)
					-- end
					self:assignmentUpdate(sData.data)
				end
			end
			local roomid=ltzdzVoApi.clancrossinfo.roomid
			local tid=ltzdzVoApi.clancrossinfo.tid
			socketHelper2:ltzdzEnterForegroundSync(roomid,sync,tid)
		end
	end
end

-- settid (网络断开需要重新验证)
function ltzdzFightApi:setTid(pCallback)
	local function verigyFunc(fn,data)
        local ret,sData=base:checkServerData2(data)
        if ret==true then
        	if expiredTime==nil then
        		expiredTime=base.serverTime+300
        	end
        	-- print("setTid成功")
        	if pCallback then
        		pCallback()
        	end
        end
    end
    socketHelper2:ltzdzVerify(verigyFunc,ltzdzVoApi.clancrossinfo.tid)
end

function ltzdzFightApi:rSetTid()
	if ltzdzVoApi and ltzdzFightApi.connected and ltzdzFightApi.userInfo then
		local function pCallback()
			self:EnterForeground()
		end
		ltzdzFightApi:setTid(pCallback)
	end
end

-- 连接socket2 (host ,port 不一致需要重新连接)
function ltzdzFightApi:rConnectSocket2(host,port,pCallback)
	require "luascript/script/netapi/socketHelper2"
	local function connectHandler(...)
		-- print("成功连接socket2!")
		self.connected=true
		if pCallback then
			pCallback()
		end
	end
	socketHelper2:socketConnect(host,port,connectHandler)
end

function ltzdzFightApi:tick()
	-- 已经连接过跨服机器
	if expiredTime and base.serverTime>expiredTime and ltzdzVoApi and ltzdzFightApi.connected and ltzdzFightApi.userInfo then
		local httphost=ltzdzVoApi:getHttphostUrl()
		if httphost then
			expiredTime=base.serverTime+300
			local clancrossinfo=ltzdzVoApi.clancrossinfo
			local roomid=clancrossinfo.roomid

			local httpUrl=httphost.."gethost"
			local reqStr="roomid="..roomid
			-- deviceHelper:luaPrint(httpUrl)
			-- deviceHelper:luaPrint(reqStr)
			local retStr=G_sendHttpRequest(httpUrl .. "?" .. reqStr,"")
			-- deviceHelper:luaPrint(retStr)
			if(retStr~="")then
				local retData=G_Json.decode(retStr)
				if type(retData) == "table" and ( (retData["ret"]==0 or retData["ret"]=="0") and retData.data )then
					local host=retData.data.host
					local port=retData.data.port
					local tid=retData.data.thread
					if clancrossinfo.host==host and clancrossinfo.port==port and clancrossinfo.tid==tid then
					else
						clancrossinfo.host=host
						clancrossinfo.port=port
						clancrossinfo.tid=tid

						-- 重新连接socket2
						local function pCallback()
							ltzdzFightApi:rSetTid()
						end
						ltzdzFightApi:rConnectSocket2(host,port,pCallback)

					end
				end
			end
		end
	end
end

function ltzdzFightApi:getTotalBufferByHid(hid)
	local uid=tostring(playerVoApi:getUid())
	local myinfo=self.userInfo[uid]
	local heroList=myinfo.binfo.hero
	local totalValue=heroList[hid].a or {}
	local neeValue={}
	neeValue.atk=totalValue[1] or 0
	neeValue.hlp=totalValue[2] or 0
	neeValue.hit=totalValue[3] or 0
	neeValue.cri=totalValue[5] or 0
	neeValue.eva=totalValue[4] or 0
	neeValue.res=totalValue[6] or 0

	neeValue[7]=totalValue[7] or 0
	return neeValue
end

--清除当前最早侦查的城市数据（因侦查城市的个数加了限制(15个)，所以达到侦查限制后要清除最早的侦查数据）
--return true清除成功，false未达到上限
function ltzdzFightApi:clearPremierScoutCity()
	local myUserInfo=self:getUserInfo()
	local scout=myUserInfo.scout
	if scout then
		local count=0
		local minScoutTime,cid
		for k,v in pairs(scout) do
			if base.serverTime<v.t then
				if minScoutTime==nil then
					minScoutTime=v.t
					cid=k
				elseif minScoutTime>v.t then
					minScoutTime=v.t
					cid=k
				end
				count=count+1
			end
		end
		-- print("count,cid===>>>",count,cid)
		if cid and count>15 then
			myUserInfo.scout[cid]=nil --清除掉该城市的侦查数据
			return true,cid
		end
	end
	return false
end

--获取军徽部队
function ltzdzFightApi:getEmblemTroopById(troopId)
	local isTroop=emblemTroopVoApi:checkIfIsEmblemTroopById(troopId)
	if isTroop then
		local myinfo=self:getUserInfo()
		if myinfo and myinfo.binfo and myinfo.binfo.smaster and myinfo.binfo.smaster[troopId] then
			local vo=emblemTroopVo:new()
			vo:initWithData(troopId,myinfo.binfo.smaster[troopId])
			return vo
		end
	end
	return nil
end

--获取坦克皮肤数据
function ltzdzFightApi:getTankSkinList()
	local myInfo = self:getUserInfo()
	if myInfo and myInfo.binfo and myInfo.binfo.skin then
		return myInfo.binfo.skin
	end
	return {}
end

function ltzdzFightApi:getSkinIdByTankId(tankId)
	local skinList = self:getTankSkinList()
	return skinList[tankSkinVoApi:convertTankId(tankId)]
end




-- function ltzdzFightApi:tick()
-- 	if self.mapVo and self.mapVo.city then
-- 		for k,v in pairs(self.mapVo.city) do
-- 			local flag=false --是否有建筑升级完成的标识
-- 			if v.b then
-- 				local mbEt=v.b[3] or 0--主基地升级结束时间
-- 				if mbEt~=0 and base.serverTime>=mbEt then --主基地升级完成
-- 					flag=true
-- 				else
-- 					local rbTb=v.b[4] or {} --资源建筑
-- 					for k,sb in pairs(rbTb) do
-- 						local sbEt=sb[3] or 0 --资源建筑升级结束时间
-- 						if sbEt~=0 and base.serverTime>=sbEt then --有资源建筑升级完成
-- 							flag=true
-- 							do break end
-- 						end
-- 					end
-- 				end
-- 			end
-- 			if flag==true and self.cityTb[k]==nil then --城市有建筑升级完成，将此建筑记录下来
-- 				self.cityTb[k]=1
-- 			end
-- 		end
-- 		if self.mapVo.ts and self.mapVo.ts>=(self.syncResTime+70) then
-- 			self.syncResTime=self.mapVo.ts
-- 			local ctb={}

-- 			require "luascript/script/game/gamemodel/ltzdz/ltzdzCityVoApi"
-- 			local function syncCallBack()
-- 			end
-- 			ltzdzCityVoApi:syncCity(cid,callBack,3,false)
-- 		end
-- 	end
-- end