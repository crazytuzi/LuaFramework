--异次元战场总voapi
dimensionalWarVoApi=
{
	signUpTime=nil,		--报名时间的配置，从后台传回来
	startWarTime=nil,	--开战时间配置，从后台传回来
	openDate=0,		--是奇数还是偶数开放战斗，0是偶数天开,1是奇数天开
	point=0,		--商店积分
	shopList={},	--商店列表
	shopFlag=-1,	--是否初始化过商店信息
	pointDetail={},		--积分明细
	pointDetailFlag=-1,	--积分明细标记

    round2=0,		--亡者回合
    round1=0,		--生者回合
    place=0, 		--所处格子
    bid=0,			--本场战斗id
    point1=0, 		--生者积分
    buff={},
    status=0, 		--状态
    point2=0, 		--亡者积分
    apply_at=0,		--报名时间

    eventList={},	--事件列表
    eventNum=0,		--事件现有数量
    hasMore=false,	--事件是否还有下一页
    rankList={{},{}},

    isInit=false,	--是否初始化过
    initSelfRank=false,	--是否获取自己排行榜数据
    initBattleChatNum=0,	--初始化战场聊天频道次数，最大3次
    lastBuyTime=0,	--上一次购买物品时间
    applynum=0,		--报名人数
}

function dimensionalWarVoApi:getApplynum()
	return self.applynum
end
function dimensionalWarVoApi:setApplynum(applynum)
	self.applynum=applynum
end

function dimensionalWarVoApi:getLastBuyTime()
	return self.lastBuyTime
end
function dimensionalWarVoApi:setLastBuyTime(lastBuyTime)
	self.lastBuyTime=lastBuyTime
end

function dimensionalWarVoApi:getInitBattleChatNum()
	return self.initBattleChatNum
end
function dimensionalWarVoApi:setInitBattleChatNum(initBattleChatNum)
	self.initBattleChatNum=initBattleChatNum
end

function dimensionalWarVoApi:getIsInit()
	return self.isInit
end
function dimensionalWarVoApi:setIsInit(isInit)
	self.isInit=isInit
end

function dimensionalWarVoApi:getInitSelfRank()
	return self.initSelfRank
end
function dimensionalWarVoApi:setInitSelfRank(initSelfRank)
	self.initSelfRank=initSelfRank
end
-------------以下面板---------------
--弹出主面板
function dimensionalWarVoApi:showMainDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/dimensionalWar/dimensionalWarDialog"
	local td=dimensionalWarDialog:new()
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("dimensionalWar_title"),true,layerNum+1)
	sceneGame:addChild(dialog,layerNum+1)
end
--弹出报名面板
function dimensionalWarVoApi:showSignDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/dimensionalWar/dimensionalWarSignDialog"
	local td=dimensionalWarSignDialog:new()
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("allianceWar_sign"),true,layerNum+1)
	sceneGame:addChild(dialog,layerNum+1)
end
--弹出商店面板
function dimensionalWarVoApi:showShopDialog(layerNum)
	-- require "luascript/script/game/scene/gamedialog/dimensionalWar/dimensionalWarShopDialog"
	-- local td=dimensionalWarShopDialog:new()
	-- local tbArr={getlocal("acMayDay_tab2_title"),getlocal("plat_war_sub_title33")}
	-- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("dimensionalWar_shop_title"),true,layerNum+1)
	-- sceneGame:addChild(dialog,layerNum+1)

	local td = allShopVoApi:showAllPropDialog(layerNum,"diff")
end
--弹出信息面板
function dimensionalWarVoApi:showInforDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/dimensionalWar/dimensionalWarInforDialog"
	local td=dimensionalWarInforDialog:new()
	local tbArr={getlocal("google_rank"),getlocal("BossBattle_lookReward"),getlocal("alien_tech_propTitle4")}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("serverWarLocal_information"),true,layerNum+1)
	sceneGame:addChild(dialog,layerNum+1)
end
--弹出事件面板
function dimensionalWarVoApi:showEventDialog(layerNum)
	local function callback( ... )
        require "luascript/script/game/scene/gamedialog/dimensionalWar/dimensionalWarEventDialog"
		local td=dimensionalWarEventDialog:new()
		local tbArr={}
		local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_event_event"),true,layerNum+1)
		sceneGame:addChild(dialog,layerNum+1)
    end
    self:formatEventList(callback,true)
end
-------------以上面板---------------

-------------以下接口---------------
--获取报名信息
function dimensionalWarVoApi:getApplyData(callback,ssbbFlag)
	local function onRequestEnd(fn,data)
        local ret,sData=base:checkServerData(data)
		if(ret==true)then
			if(sData.data.userwar)then
				local infoData=sData.data.userwar
				if infoData.applynum then
					self.applynum=tonumber(infoData.applynum) or 0
				end
				if infoData.warId and tonumber(infoData.warId)>0 then
					self.warid=tonumber(infoData.warId)
				elseif infoData.bid then
					self.warid=tonumber(infoData.bid)
				end
				if infoData.bid then
					self.bid=tonumber(infoData.bid)
				end
	            if(infoData.info)then
					local troops=infoData.info.troops
					local hero=infoData.info.hero
					local emblemID=infoData.info.equip
					local planePos=infoData.info.plane
					local aitroops=infoData.info.aitroops
					local airshipId = infoData.info.ap --飞艇
					-- local status=self:getStatus(self.targetCity)
					-- if status and status==30 then
	    --             else
	                    if troops then
	                        for k,v in pairs(troops) do
	                            if v and v[1] and v[2] then
	                                local id=(tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
	                                local num=tonumber(v[2])
	                                tankVoApi:setTanksByType(33,k,id,num)
	                            else
	                                tankVoApi:deleteTanksTbByType(33,k)
	                            end
	                        end
	                    end
	                    if hero then
	                        heroVoApi:setDimensionalWarHeroList(hero)
	                    end
	                    emblemVoApi:setBattleEquip(33, emblemID)
	                    planeVoApi:setBattleEquip(33, planePos)
            			airShipVoApi:setBattleEquip(33, airshipId)
	                    if aitroops then
	                    	AITroopsFleetVoApi:clearDimensionalWarAITroopsList()
	                    	AITroopsFleetVoApi:setDimensionalWarAITroopsList(aitroops)
	                    end
	                -- end
				end
				if infoData.point then
					self.point=infoData.point
				end
				-- if infoData.pointlog then
				-- 	self.pointlog=infoData.pointlog
				-- 	--商店数据
				-- 	if infoData.pointlog.lm then
				-- 		self:getShopInfo(nil,infoData.pointlog.lm)
				-- 	end
				-- end
				if infoData.round1 then
					self.round1=infoData.round1
				end
				if infoData.round2 then
					self.round2=infoData.round2
				end
				if infoData.place then
					self.place=infoData.place
				end
				if infoData.point1 then
					self.point1=infoData.point1
				end
				if infoData.point2 then
					self.point2=infoData.point2
				end
				if infoData.status then
					self.status=infoData.status
				end
				if infoData.buff then
					self.buff=infoData.buff
				end
				if infoData.apply_at then
					self.apply_at=infoData.apply_at
				end
			else
                self.warid=0
			end
			-- if self.warid==nil or self.warid==0 then
			-- 	if sData.data.oldwarid then
			-- 		self.warid=tonumber(sData.data.oldwarid)
			-- 	end
			-- end

			--后台传回来的报名时间
			if(sData.data.signUpTime)then
				self.signUpTime=
				{
					--报名的开始时间, {时,分}
					start={tonumber(sData.data.signUpTime.start[1]),tonumber(sData.data.signUpTime.start[2])},
					--报名的结束时间, {时,分}
					finish={tonumber(sData.data.signUpTime.finish[1]),tonumber(sData.data.signUpTime.finish[2])}
				}
				-- print("self.signUpTime.start[1]",self.signUpTime.start[1])	
			end
			--后台传回来的开战时间
			if(sData.data.startWarTime)then
				self.startWarTime=sData.data.startWarTime
			end
			--开放战斗，0是偶数天开,1是奇数天开
			if(sData.data.openDate)then
				self.openDate=sData.data.openDate
			end

			if self:getIsInit()==true and ssbbFlag==true then
				if self:isOpenBattle()==true then
					local status=self:getStatus()
					if status>=0 and status<20 then
						if(buildings.allBuildings)then
			                for k,v in pairs(buildings.allBuildings) do
			                    if(v:getType()==16)then
			                        v:setSpecialIconVisible(7,true)
			                        break
			                    end
			                end
			            end
			        end
				end
			end

			if callback then
				callback(true)
			end
		else
			if callback then
				callback(false)
			end
		end
	end
	socketHelper:userwarGetapply(onRequestEnd)
end

--购买物品 id：物品id 
function dimensionalWarVoApi:buyItem(id,callback)
	local function buyHandler(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.ts then
				self:setLastBuyTime(tonumber(sData.ts))
			end
			local shopItems=self:getShopItems()
			for k,v in pairs(self.shopList) do
				if v.id==id then
					self.shopList[k].num=self.shopList[k].num+1
				end
			end
			local cfg=shopItems[id]
			local rewardTb=FormatItem(cfg.reward)
			local price=cfg.price
			self:setPoint(self:getPoint()-price)
			for k,v in pairs(rewardTb) do
				G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
			end
			G_showRewardTip(rewardTb,true)
			if callback then
				callback()
			end
		end
	end
	if id then
	 	socketHelper:userwarBuy(id,buyHandler)
	end
end

--初始化积分明细
function dimensionalWarVoApi:formatPointDetail(callback)
	local function getpointlogCallback(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data and sData.data.point then
				self.point=tonumber(sData.data.point) or 0
			end
			if sData.data and sData.data.pointlog then
				if sData.data.pointlog.bt then
					self:setLastBuyTime(tonumber(sData.data.pointlog.bt))
				end
				--商店数据
				if sData.data.pointlog.lm then
					self:getShopInfo(nil,sData.data.pointlog.lm)
				elseif self.shopList==nil or SizeOfTable(self.shopList)==0 then
					self:initShopInfo()
				end
				-- --测试数据
				-- sData.data.pointlog.rc={
				-- 	{base.serverTime+100,1,10},
				-- 	{base.serverTime+99,2,15,1},
				-- 	{base.serverTime+98,3,20,2},
				-- 	{base.serverTime+97,4,25,3},
				-- }
				if sData.data.pointlog.rc then
					self.pointDetail={}
					--积分明细
					require "luascript/script/game/gamemodel/dimensionalWar/dimensionalWarPointDetailVo"
					local record=sData.data.pointlog.rc
					for k,v in pairs(record) do
						if v then
							local type,time,message,color,round=self:formatMessage(v)
							if type and time and message then
								local vo=dimensionalWarPointDetailVo:new()
								vo:initWithData(type,time,message,color,round)
								table.insert(self.pointDetail,vo)
							end
						end
					end
					if self.pointDetail and SizeOfTable(self.pointDetail)>0 then
						local function sortAsc(a, b)
							if a and b and a.time and b.time and tonumber(a.time) and tonumber(b.time) then
								return tonumber(a.time) > tonumber(b.time)
							end
						end
						table.sort(self.pointDetail,sortAsc)
					end
				end
			end
			if callback then
				callback()
			end
		end
	end
	socketHelper:userwarGetpointlog(getpointlogCallback)
end

--事件列表
function dimensionalWarVoApi:formatEventList(callback,isInit)
	local function eventlistCallback(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			--测试数据
			-- sData.data.userwarlog={
			-- 	{id=1,bid=1,update_at=base.serverTime,type=1,content={1,1,0,0,1,{},3,0},},
			-- 	{id=2,bid=1,update_at=base.serverTime,type=2,content={1,2,0,0,1,{},3,0},},
			-- 	{id=3,bid=1,update_at=base.serverTime,type=3,content={1,2,0,0,1,{},3,0},},
			-- 	{id=4,bid=1,update_at=base.serverTime,type=4,content={1,2,0,0,1,{},3,0},},
			-- 	{id=5,bid=1,update_at=base.serverTime,type=5,content={2,2,0,0,1,{},2,0},},
			-- 	{id=6,bid=1,update_at=base.serverTime,type=6,content={2,1,0,0,1,{},2,0},},
			-- 	{id=7,bid=1,update_at=base.serverTime,type=7,content={2,2,0,0,1,{},2,0},},
			-- 	{id=8,bid=1,update_at=base.serverTime,type=8,content={2,1,0,0,1,{},1,0},},
			-- 	{id=9,bid=1,update_at=base.serverTime,type=9,content={1,1,0,0,1,{},1,0},},
			-- }
			if sData.data and sData.data.count then
				self:setEventNum(sData.data.count)
			end
			local roundNum=0
			if sData.data and sData.data.userwarlog then
				if isInit==true then
					self.eventList={}
				end
				local roundTab={}
				require "luascript/script/game/gamemodel/dimensionalWar/dimensionalWarEventVo"
				local userwarlog=sData.data.userwarlog
				for k,v in pairs(userwarlog) do
					if v and v.id and v.update_at then
						local curZeroTs=G_getWeeTs(base.serverTime)
						local zeroTs=G_getWeeTs(tonumber(v.update_at))
						if zeroTs==curZeroTs or (zeroTs+86400)==curZeroTs then
							if v.content and SizeOfTable(v.content)>0 then
								local sortId=1
								for m,n in pairs(v.content) do
									if n and n[1] and n[2] then
										local eType=n[1]
										local content=n[2] or {}
										local vo=dimensionalWarEventVo:new()
										vo:initWithData(v.id,v.bid,v.update_at,eType,content)
										-- 5.最高-空间震荡
										-- 4.行动力死亡OR战斗死亡
										-- 3.随机触发事件
										-- 3.别人触发自己的事件（别人踩自己陷阱）
										-- 2.行为触发事件(战斗事件，不死)
										-- 1.行为
										vo.sortId=vo.round*100+sortId
										if eType==8 then
											vo.sortId=vo.sortId+90
										elseif eType==3 and vo.aType==2 and vo.subType==4 then
											vo.sortId=vo.sortId+80
										elseif vo.isDie==1 then
											vo.sortId=vo.sortId+70
										elseif vo.aType==1 then
											vo.sortId=vo.sortId+10
										elseif (eType==4 or eType==6) and vo.subType==2 then
											vo.sortId=vo.sortId+40
										elseif vo.aType==2 then
											if eType==3 and vo.subType~=4 then
												vo.sortId=vo.sortId+30
											else
												vo.sortId=vo.sortId+50
											end
										end
										table.insert(self.eventList,vo)
										sortId=sortId+1
									end
								end
							end
							-- local vo=dimensionalWarEventVo:new()
							-- vo:initWithData(v.id,v.bid,v.update_at,v.type,v.content)
							-- table.insert(self.eventList,vo)
						end
					end
				end
				if self.eventList and SizeOfTable(self.eventList)>0 then
					-- local function sortAsc(a, b)
					-- 	if a and b and a.id and b.id and tonumber(a.id) and tonumber(b.id) and tonumber(a.id)~=tonumber(b.id) then
					-- 		return tonumber(a.id) > tonumber(b.id)
					-- 	end
					-- end
					local function sortAsc(a, b)
						if a and b and a.sortId and b.sortId then
							return a.sortId > b.sortId
						end
					end
					table.sort(self.eventList,sortAsc)
					for k,v in pairs(self.eventList) do
						if v and v.round then
							if roundTab[v.round]==nil then
								roundTab[v.round]=v.round
								self.eventList[k].showRound=1
								roundNum=roundNum+1
							end
							-- if roundNum<v.round then
							-- 	roundNum=v.round
							-- end
						end
					end
				end
			end
			self:setHasMore(false)
			if self.eventList then
				local eventNum=self:getEventNum()
				-- local listNum=SizeOfTable(self.eventList)
				-- if listNum<eventNum then
				-- 	self:setHasMore(true)
				-- end
				if roundNum<eventNum then
					self:setHasMore(true)
				end
			end 
			if callback then
				callback()
			end
		end
	end
	local maxeid,mineid=0,0
	if isInit==true then
	else
		mineid,maxeid=dimensionalWarVoApi:getMinAndMaxEid()
	end
	socketHelper:userwarGeteventlist(self.warid,maxeid,mineid,eventlistCallback)
end
--事件战报
function dimensionalWarVoApi:getEventReport(id,callback)
	local function getReportCallback(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data and sData.data.report then
				local report1=sData.data.report
				self:addEventReport(id,report1)
				-- print("SizeOfTable(report1)",SizeOfTable(report1))
				if callback then
					callback(report1)
				end
			end
		end
	end
	local eventVo=self:getEventById(id)
	if eventVo and eventVo.report and SizeOfTable(eventVo.report)>0 then
		local report=G_clone(eventVo.report)
		if callback then
			callback(report)
		end
	else
		socketHelper:userwarGetreport(id,getReportCallback)
	end

end
--排行榜
function dimensionalWarVoApi:formatRankList(status,callback)
	if status then
		local rType=status+1
		local battleStatus=self:getStatus()
		if self.rankList and self.rankList[rType] and SizeOfTable(self.rankList[rType])>0 then
			if callback then
				callback()
			end
		elseif battleStatus and battleStatus>=20 then
			local function ranklistCallback(fn,data)
				local ret,sData=base:checkServerData(data)
				if ret==true then
					if sData.data and sData.data.ranklist then
						self.rankList[rType]={}
						require "luascript/script/game/gamemodel/dimensionalWar/dimensionalWarRankVo"
						for k,v in pairs(sData.data.ranklist) do
							if v and v[1] then
								local vo=dimensionalWarRankVo:new()
								vo:initWithData(v[1],v[2],v[3],v[4],v[5])
								table.insert(self.rankList[rType],vo)
							end
						end
					end
					if callback then
						callback()
					end
				end
			end
			socketHelper:userwarRanklist(status,ranklistCallback)
		else
			if callback then
				callback()
			end
		end
	else
		if callback then
			callback()
		end
	end
end

-------------以上接口---------------
function dimensionalWarVoApi:getRankList(type)
	if type and self.rankList[type] then
		return self.rankList[type]
	else
		return {}
	end
end
function dimensionalWarVoApi:getSelfRank(type)
	if type and self.rankList[type] then
		for k,v in pairs(self.rankList[type]) do
			if v and v.id==playerVoApi:getUid() then
				return k
			end
		end
	end
	return 0
end
-------------以下商店数据---------------
--商店积分
function dimensionalWarVoApi:getPoint()
	return self.point
end
function dimensionalWarVoApi:setPoint(point)
	self.point=point
end
--获取商店里面的道具列表
function dimensionalWarVoApi:getShopList()
	if (self.shopList) then
		return self.shopList
	end
	return {}
end
--根据id获取道具的配置
function dimensionalWarVoApi:getItemById(id)
	local item=nil
	if id then
		local shopList=self:getShopItems()
		if shopList and shopList[id] then
			item=shopList[id]
		end
	end
	return item
end
--初始化商店信息
function dimensionalWarVoApi:initShopInfo()
	require "luascript/script/game/gamemodel/dimensionalWar/dimensionalWarShopVo"
	local shopItems=self:getShopItems()
	self.shopList={}
	for k,v in pairs(shopItems) do
		local vo=dimensionalWarShopVo:new()
		vo:initWithData(k,0)
		table.insert(self.shopList,vo)
	end
	local function sortAsc(a, b)
		if a and b and a.id and b.id then
			local aid=(tonumber(a.id) or tonumber(RemoveFirstChar(a.id)))
			local bid=(tonumber(b.id) or tonumber(RemoveFirstChar(b.id)))
			if aid and bid then
				return aid < bid
			end
		end
	end
	table.sort(self.shopList,sortAsc)
end
--获取商店信息
--param callback: 获取之后的回调函数
function dimensionalWarVoApi:getShopInfo(callback,data)
	local shopFlag=self:getShopFlag()
	if shopFlag==-1 then
		self:initShopInfo()
		self:setShopFlag(1)
	end

	if data then
		if self.shopList==nil or SizeOfTable(self.shopList)==0 then
			self:initShopInfo()
		end
		-- for k,v in pairs(data) do
		-- 	local key=string.sub(k,1,1)
		-- 	if key=="i" then
		-- 		for m,n in pairs(self.commonList) do
		-- 			if n and n.id==k then
		-- 				self.commonList[m].num=v
		-- 			end
		-- 		end
		-- 	elseif key=="a" then
		-- 		for m,n in pairs(self.rareList) do
		-- 			if n and n.id==k then
		-- 				self.rareList[m].num=v
		-- 			end
		-- 		end
		-- 	end
		-- end
		local isBuyToday=G_isToday(self:getLastBuyTime())
		for k,v in pairs(data) do
			for m,n in pairs(self.shopList) do
				if n and n.id==k then
					if isBuyToday==true then
						self.shopList[m].num=v
					else
						self.shopList[m].num=0
					end
				end
			end
		end
	end

	if(callback)then
		callback()
	end
end
function dimensionalWarVoApi:resetBuyNum()
	if self.shopList then
		for k,v in pairs(self.shopList) do
			if v then
				self.shopList[k].num=0
			end
		end
	end
end
--商店配置
function dimensionalWarVoApi:getShopItems()
	return userWarCfg.ShopItems
end
function dimensionalWarVoApi:getShopFlag()
	return self.shopFlag
end
function dimensionalWarVoApi:setShopFlag(shopFlag)
	self.shopFlag=shopFlag
end
-- function dimensionalWarVoApi:getShopShowStatus()
-- 	-- local isJoinBattle=self:isJoinBattle(false)
-- 	local status=self:checkStatus()
-- 	if status and status>=30 then
-- 		-- if isJoinBattle==true then
-- 		-- 	return 2
-- 		-- end
-- 		return 1
-- 	end
-- 	return 0
-- end
-- 获取积分明细
function dimensionalWarVoApi:getPointDetail()
	if (self.pointDetail) then
		return self.pointDetail
	end
	return {}
end
function dimensionalWarVoApi:getPointDetailFlag()
	return self.pointDetailFlag
end
function dimensionalWarVoApi:setPointDetailFlag(pointDetailFlag)
	self.pointDetailFlag=pointDetailFlag
end
-- -- function dimensionalWarVoApi:getDetailExpireTime()
-- -- 	return self.detailExpireTime
-- -- end
-- -- function dimensionalWarVoApi:setDetailExpireTime(detailExpireTime)
-- -- 	self.detailExpireTime=detailExpireTime
-- -- end

function dimensionalWarVoApi:formatMessage(data)
	-- local id
	local type
	local time=0
	local point=0
	-- local targetName=""
	local color=G_ColorGreen
	local round=0
	local itemId
	local params={}
	local message=""
	if data and SizeOfTable(data)>0 then
		type=tonumber(data[2])
		if type and type==1 then
			time=tonumber(data[1]) or 0
			itemId=data[3]
			local name=""
			local shopItems=self:getShopItems()
			if itemId and shopItems and shopItems[itemId] then
				if shopItems[itemId].price then
					point=shopItems[itemId].price or 0
				end
				if shopItems[itemId].reward then
					local reward=shopItems[itemId].reward or 0
					local rewardTb=FormatItem(reward) or {}
					if rewardTb[1] and rewardTb[1].name then
						name=rewardTb[1].name
					end
				end
			end
			color=G_ColorRed
			params={name,point}
			message=getlocal("world_war_point_desc_7",params)
		elseif type and type>1 then
			local index=type-1
			time=tonumber(data[1]) or 0
			point=tonumber(data[3]) or 0
			round=tonumber(data[4]) or 0
			-- print("index,point,round",index,point,round)
			if index==1 or index==4 then
				params={round,point}
			else
				params={point}
			end
			message=getlocal("dimensionalWar_point_detail_"..index,params)
		end
	end
	return type,time,message,color,round
end

function dimensionalWarVoApi:getAreaStr(posStr)
	local str=""
	if posStr then
		local arr=Split(posStr,"-")
		if arr and arr[1] and arr[2] then
			local xStr,yStr=arr[1],arr[2]
			if tonumber(arr[1])==1 then
				xStr="A"
			elseif tonumber(arr[1])==2 then
				xStr="B"
			elseif tonumber(arr[1])==3 then
				xStr="C"
			elseif tonumber(arr[1])==4 then
				xStr="D"
			elseif tonumber(arr[1])==5 then
				xStr="E"
			elseif tonumber(arr[1])==6 then
				xStr="F"
			end
			str=xStr..arr[2]
		end
	end
	return str
end

function dimensionalWarVoApi:clearPointDetail()
	if self.pointDetail~=nil then
		for k,v in pairs(self.pointDetail) do
			self.pointDetail[k]=nil
		end
		self.pointDetail=nil
	end
	self.pointDetail={}
	-- self.page=0
	-- self.hasMore=false
	self.pointDetailFlag=-1
	-- self.detailExpireTime=0
end

-------------以上商店数据---------------
-------------以下事件数据---------------
-- 根据事件列表获取事件
function dimensionalWarVoApi:getEventById(id)
	local list=self:getEventList()
	if list and SizeOfTable(list)>0 then
		for k,v in pairs(list) do
			if v and tonumber(v.id)==id then
				return v
			end
		end
	end
	return nil
end
-- 添加事件战报
function dimensionalWarVoApi:addEventReport(id,report)
	if self.eventList and SizeOfTable(self.eventList)>0 then
		for k,v in pairs(self.eventList) do
			if v and tonumber(v.id)==id and self.eventList[k].report==nil then
				self.eventList[k].report=report
			end
		end
	end
end
-- 获取事件
function dimensionalWarVoApi:getEvent(eventData)
	local eventTb={}
	if eventData and eventData.content then
		local sortId=1
		require "luascript/script/game/gamemodel/dimensionalWar/dimensionalWarEventVo"
		for m,n in pairs(eventData.content) do
			if n and n[1] and n[2] then
				local eType=n[1]
				local content=n[2] or {}
				local vo=dimensionalWarEventVo:new()
				vo:initWithData(eventData.id,eventData.bid,eventData.update_at,eType,content)
				-- 5.最高-空间震荡
				-- 4.行动力死亡OR战斗死亡
				-- 3.随机触发事件
				-- 3.别人触发自己的事件（别人踩自己陷阱）
				-- 2.行为触发事件(战斗事件，不死)
				-- 1.行为
				vo.sortId=vo.round*100+sortId
				if eType==8 then
					vo.sortId=vo.sortId+90
				elseif eType==3 and vo.aType==2 and vo.subType==4 then
					vo.sortId=vo.sortId+80
				elseif vo.isDie==1 then
					vo.sortId=vo.sortId+70
				elseif vo.aType==1 then
					vo.sortId=vo.sortId+10
				elseif (eType==4 or eType==6) and vo.subType==2 then
					vo.sortId=vo.sortId+40
				elseif vo.aType==2 then
					if eType==3 and vo.subType~=4 then
						vo.sortId=vo.sortId+30
					else
						vo.sortId=vo.sortId+50
					end
				end
				table.insert(eventTb,vo)
				sortId=sortId+1
			end
		end
		if eventTb and SizeOfTable(eventTb)>0 then
			local function sortAsc(a, b)
				if a and b and a.sortId and b.sortId then
					return a.sortId < b.sortId
				end
			end
			table.sort(eventTb,sortAsc)
		end
	end
	return eventTb
end
-- 获取事件描述
-- dimensionalWar_event_title1="待机",
-- dimensionalWar_event_title1_1="整备待机",
-- dimensionalWar_event_title2="探索",
-- dimensionalWar_event_title2_1="全面探索",
-- dimensionalWar_event_title3="战斗",
-- dimensionalWar_event_title3_1="猎杀",
-- dimensionalWar_event_title4="陷阱",
-- dimensionalWar_event_title5="隐匿",
-- dimensionalWar_event_title6="污染",
-- dimensionalWar_event_title7="行动力不足",
-- dimensionalWar_event_title8="空间震荡",
-- dimensionalWar_event_title9="被袭击",
-- dimensionalWar_event_title10="被害",
-- dimensionalWar_event_title11_1="辐射",
-- dimensionalWar_event_title11_2="沙尘暴",
-- dimensionalWar_event_title11_3="风暴",
-- dimensionalWar_event_title12_1="战术深化",
-- dimensionalWar_event_title12_2="军事整备",
-- dimensionalWar_event_title13="好运",
function dimensionalWarVoApi:getEventDesc(eventVo)
	local aType=eventVo.aType         --1行动，2事件
	local oldStatus=eventVo.oldStatus --0幸存，1亡者，2死亡
    local status=eventVo.status       --0幸存，1亡者，2死亡
    local eType=eventVo.type           --这次事件具体类型
    local subType=eventVo.subType     --这次事件类型的小类型
    local action=eventVo.action
    local point=eventVo.point
    local round=eventVo.round
    local isHigh=eventVo.isHigh
    local isDie=eventVo.isDie
    local param={}
    local parm={}
    if eventVo.param then
    	-- parm=G_Json.decode(tostring(eventVo.param))
    	parm=eventVo.param
    end
    
    --标题
    local titleStr=getlocal("dimensionalWar_event_action"..aType)
    local acStatus=status
    if oldStatus and oldStatus~=status then
    	acStatus=oldStatus
    end
    if eType==11 or eType==12 then
    	local buffId=parm[1]
    	if eType==11 then
			titleStr=titleStr..getlocal("dimensionalWar_debuffName"..buffId)
		else
			titleStr=titleStr..getlocal("dimensionalWar_buffName"..buffId)
		end
    elseif isHigh==1 or (eType==3 and acStatus==1) then
        titleStr=titleStr..getlocal("dimensionalWar_event_title"..eType.."_1")
    else
        titleStr=titleStr..getlocal("dimensionalWar_event_title"..eType)
    end
    --描述
    if eType==1 then
    	if isHigh==1 then
    		subType=2
    	else
    		subType=1
    	end
    elseif eType==2 then
    	if parm and parm[1] and SizeOfTable(parm[1])>0 then
    		subType=1
    	else
    		subType=2
    	end
   	elseif eType==3 then
   		if aType==1 then
   			subType=5
   		end
    -- elseif (eType==11 or eType==12) and param and param[1] then
    --     subType=(tonumber(param[1]) or tonumber(RemoveFirstChar(param[1])))
    end
    if eType==1 then	--{行动力增加，是否死亡，上一次状态}
    	param=parm
    	-- if parm[2] then
    	-- 	isDie=tonumber(parm[2]) or 0
    	-- end
    elseif eType==2 then
    	if parm and parm[1] and SizeOfTable(parm[1])>0 then
    		if parm[1].point then
    			param={getlocal("serverwar_point").."*"..parm[1].point}
    		else
	    		local rewardTb=FormatItem(parm[1])
	    		if rewardTb and rewardTb[1] then
	    			param={rewardTb[1].name.."*"..rewardTb[1].num}
	    		else
	    			param=parm
	    		end
	    	end
	    else
	    	param=parm
    	end
	    -- if parm and parm[2] then
	    -- 	isDie=tonumber(parm[2]) or 0
	    -- end
    elseif eType==3 then
	    if subType==5 then
	    	if aType==1 then
	    		local area=parm[2]
		    	local areaStr=self:getAreaStr(area)
		    	param={areaStr}
	    		-- if parm and parm[1] then
			    -- 	isDie=tonumber(parm[1]) or 0
			    -- end
			else
				param=parm
	    	end
	    else
	    	-- if parm and parm[2] then
		    -- 	isDie=tonumber(parm[2]) or 0
		    -- end
	    	param={parm[1],point,parm[3]}
	    end 
    elseif eType==4 then
    	if subType==1 then
    		-- if parm and parm[1] then
		    -- 	isDie=tonumber(parm[1]) or 0
		    -- end
		    param=parm
    	elseif subType==2 then
		    local area=parm[2]
	    	local areaStr=self:getAreaStr(area)
	    	param={parm[1],areaStr}
	    else
	    	param=parm
    	end
    elseif eType==5 then
    	-- if parm and parm[1] then
	    -- 	isDie=tonumber(parm[1]) or 0
	    -- end
	    param=parm
	elseif eType==6 then
		if subType==1 then
		    local area=parm[1]
	    	local areaStr=self:getAreaStr(area)
	    	param={areaStr}
	    	-- if parm and parm[2] then
		    -- 	isDie=tonumber(parm[2]) or 0
		    -- end
	    elseif subType==2 and parm[2] then
    		local area=parm[2]
	    	local areaStr=self:getAreaStr(area)
	    	param={parm[1],areaStr}
	    else
	    	param=parm
    	end
    --param={地区id,玩家名字,buffId(b1),buff值},
    elseif eType==10 then
    	local area=parm[1]
    	local areaStr=self:getAreaStr(area)
    	local buffId=parm[3]
    	local buffValue=parm[4] or 0
    	local buffStr=getlocal("dimensionalWar_debuff_desc_"..buffId,{buffValue*100})
    	param={areaStr,parm[2],buffStr}
    --param={buff名字(b1)，值，oldStatus},
    elseif eType==11 or eType==12 then
    	local buffId=parm[1]
    	local buffValue=parm[2] or 0
    	local buffStr=""
    	if eType==11 then
    		buffStr=getlocal("dimensionalWar_debuff_desc_"..buffId,{buffValue*100})
    		eventStr=getlocal("dimensionalWar_debuffName"..buffId)
    	else
    		buffStr=getlocal("dimensionalWar_buff_desc_"..buffId,{buffValue*100})
    		eventStr=getlocal("dimensionalWar_buffName"..buffId)
    	end
    	-- local index=(tonumber(buffId) or tonumber(RemoveFirstChar(buffId)))
    	-- local eventStr=getlocal("dimensionalWar_event_title"..eType.."_"..index)
    	param={eventStr,buffStr}
    elseif eType==13 then
    	param={}
    	-- print("type(parm[1])",type(parm[1]))
    	-- G_dayin(parm)
    	if subType==1 then
	    	if parm and parm[1] and type(parm[1])=="table" then
	    		if parm[1].point then
	    			param={getlocal("serverwar_point").."*"..parm[1].point}
	    		else
		    		local rewardTb=FormatItem(parm[1])
		    		if rewardTb and rewardTb[1] then
		    			param={rewardTb[1].name.."*"..rewardTb[1].num}
		    		end
		    	end
		    else
		    	if parm.point then
	    			param={getlocal("serverwar_point").."*"..parm.point}
	    		else
		    		local rewardTb=FormatItem(parm)
		    		if rewardTb and rewardTb[1] then
		    			param={rewardTb[1].name.."*"..rewardTb[1].num}
		    		end
		    	end
	    	end
	    else
	    	param=parm
	    end
    else
    	param=parm
    end
    local descStr=getlocal("dimensionalWar_event_desc"..eType.."_"..subType,param)
	if eType==3 and subType==1 then
		local addAction=tonumber(parm[3]) or 0
    	if addAction and addAction>0 then
    		descStr=descStr..getlocal("dimensionalWar_event_add_action",{addAction})
    	end
	end
	if isDie and isDie~=0 then
		descStr=descStr..getlocal("dimensionalWar_action_empty")
	end
	local color
	if(eType==8 or (isDie and isDie~=0))then
		color=G_ColorRed
	else
		color=G_ColorWhite
	end
	return descStr,titleStr,color
end

--获取战斗中事件描述
function dimensionalWarVoApi:getEventDescStr(eType,area,rewardTb)
	local descStr=""
	if eType then
		local areaStr=""
		if area then
			areaStr=self:getAreaStr(area)
		end
		local param={areaStr}
		if eType==1 or eType==5 then
			if rewardTb and SizeOfTable(rewardTb)>0 then
				param={}
				if rewardTb.point then
	    			param={getlocal("serverwar_point").."*"..rewardTb.point}
	    		else
		    		local award=FormatItem(rewardTb)
		    		if award and award[1] then
		    			param={award[1].name.."*"..award[1].num}
		    		end
		    	end
		    	descStr=getlocal("dimensionalWar_event_desc2_1",param)
		    else
		    	descStr=getlocal("dimensionalWar_event_desc2_2")
			end
		elseif eType==2 then
			descStr=getlocal("dimensionalWar_event_desc"..(eType+1).."_5",param)
		elseif eType==4 then
			descStr=getlocal("dimensionalWar_event_desc1_2",param)
		elseif eType==6 then
			descStr=getlocal("dimensionalWar_event_desc5_1",param)
		elseif eType==101 then
			descStr=getlocal("dimensionalWar_event_desc4_1",param)
		elseif eType==102 then
			descStr=getlocal("dimensionalWar_event_desc6_1",param)
		else
			descStr=getlocal("dimensionalWar_event_desc"..(eType+1).."_1",param)
		end
	end
	return descStr
end

function dimensionalWarVoApi:getEventList()
	return self.eventList
end

function dimensionalWarVoApi:getMinAndMaxEid()
	local mineid,maxeid=0,0
	local events=self:getEventList()
	if events and SizeOfTable(events)>0 then
		local num=SizeOfTable(events)
		if events~=nil and SizeOfTable(events)~=0 then
			mineid,maxeid=events[num].id,events[1].id
		end
	end
	return mineid,maxeid
end

function dimensionalWarVoApi:getEventNum()
	return self.eventNum
end
function dimensionalWarVoApi:setEventNum(eventNum)
	if eventNum then
		self.eventNum=tonumber(eventNum)
	end
end
function dimensionalWarVoApi:getHasMore()
	return self.hasMore
end
function dimensionalWarVoApi:setHasMore(hasMore)
	self.hasMore=hasMore
end

-------------以上事件数据---------------

-- 异元战场是否开启
function dimensionalWarVoApi:isOpenBattle()
	local weets=G_getWeeTs(base.serverTime)
	weets = weets + base.curTimeZone * 3600
	local day=math.ceil(weets/86400)
	if G_isGlobalServer()==true then
		if (day%2)==self.openDate then
			return false
		else
			return true
		end
	else
		if (day%2)==self.openDate then
			return true
		else
			return false
		end
	end
end

-- 是否报名
function dimensionalWarVoApi:isHadApply()
	if G_isGlobalServer()==true then
		if self.apply_at and self.apply_at>0 and self.bid and self.warid and self.bid==self.warid then
			return true
		else
			return false
		end
	else
		if self:isOpenBattle()==true and self.apply_at and G_isToday(self.apply_at)==true then
			return true
		else
			return false
		end
	end
end
-- 设置报名时间
function dimensionalWarVoApi:setApplyTime(apply_at)
	if apply_at then
		self.apply_at=apply_at
	end
end

function dimensionalWarVoApi:getBattleTime()
	local battleTime=0
	if self.startWarTime then
		local zeroTime=G_getWeeTs(base.serverTime)
		local dayTime=base.serverTime-zeroTime
		local startWarTime=self.startWarTime[1]*3600+self.startWarTime[2]*60
		if self:isOpenBattle()==true then
			if dayTime<=startWarTime+userWarCfg.roundMax*(userWarCfg.roundTime+userWarCfg.roundAccountTime) then
				battleTime=zeroTime+startWarTime
			else
				battleTime=zeroTime+86400*2+startWarTime
			end
		else
			battleTime=zeroTime+86400+startWarTime
		end
	end
	return battleTime
end

function dimensionalWarVoApi:battleEndIsShowBtn()
	if self.startWarTime then
		if self:isOpenBattle()==true then
			local curTime=base.serverTime
			local zeroTime=G_getWeeTs(curTime)
			local dayTime=curTime-zeroTime
			local startWarTime=self.startWarTime[1]*3600+self.startWarTime[2]*60
			if dayTime>startWarTime+userWarCfg.roundMax*(userWarCfg.roundTime+userWarCfg.roundAccountTime) then
				return true
			end
		end
	end
	return false
end

-- 异元战场状态
--return 0: 报名期
--return 1: 准备期
--return 10: 战斗期，战斗前几分钟准备时间
--return 11: 战斗期，战斗中
--return 20: 休整期，战斗结束
function dimensionalWarVoApi:getStatus()
	local endTime=0
	local status=20
	local statusStr=""
	local curTime=base.serverTime
	if self.startWarTime and self.signUpTime then
		local zeroTime=G_getWeeTs(curTime)
		local signUpSt,signUpEt=self.signUpTime.start[1]*3600+self.signUpTime.start[2]*60,self.signUpTime.finish[1]*3600+self.signUpTime.finish[2]*60
		local startWarTime=self.startWarTime[1]*3600+self.startWarTime[2]*60
		local prepareTime=userWarCfg.prepareTime
		local isOpenBattle=self:isOpenBattle()
		if G_isGlobalServer()==true then
			if isOpenBattle==true then
				local dayTime=curTime-zeroTime
				if dayTime<startWarTime-prepareTime then
					status=1
					statusStr=getlocal("dimensionalWar_status_desc1_1")
					endTime=zeroTime+startWarTime-prepareTime
				elseif dayTime>=startWarTime-prepareTime and dayTime<=startWarTime+userWarCfg.roundMax*(userWarCfg.roundTime+userWarCfg.roundAccountTime) then
					if dayTime>=startWarTime-prepareTime and dayTime<startWarTime then
						status=10
					else 
						status=11
					end
					statusStr=getlocal("dimensionalWar_status_desc2")
					endTime=zeroTime+startWarTime+userWarCfg.roundMax*(userWarCfg.roundTime+userWarCfg.roundAccountTime)
				else
					status=20
					statusStr=getlocal("dimensionalWar_status_desc3")
					endTime=zeroTime+86400+signUpSt
				end
			else
				status=0
				statusStr=getlocal("dimensionalWar_status_desc1")
				endTime=zeroTime+signUpEt
			end
		else
			if isOpenBattle==true then
				local dayTime=curTime-zeroTime
				if dayTime<signUpSt then
					status=20
					statusStr=getlocal("dimensionalWar_status_desc3")
					endTime=zeroTime+signUpSt
				elseif dayTime<startWarTime-prepareTime then
					status=0
					statusStr=getlocal("dimensionalWar_status_desc1")
					if dayTime<signUpEt then
						endTime=zeroTime+signUpEt
					else
						endTime=zeroTime+86400*2+signUpSt
					end
				elseif dayTime>=startWarTime-prepareTime and dayTime<=startWarTime+userWarCfg.roundMax*(userWarCfg.roundTime+userWarCfg.roundAccountTime) then
					if dayTime>=startWarTime-prepareTime and dayTime<startWarTime then
						status=10
					else 
						status=11
					end
					statusStr=getlocal("dimensionalWar_status_desc2")
					if dayTime<signUpEt then
						endTime=zeroTime+signUpEt
					else
						endTime=zeroTime+86400*2+signUpSt
					end
				else
					status=20
					statusStr=getlocal("dimensionalWar_status_desc3")
					endTime=zeroTime+86400*2+signUpSt
				end
			else
				status=20
				statusStr=getlocal("dimensionalWar_status_desc3")
				endTime=zeroTime+86400+signUpSt
			end
		end
	end
	local cdTime=endTime-curTime
	if cdTime<0 then
		cdTime=0
	end
	return status,statusStr,cdTime
end

function dimensionalWarVoApi:clear()
	if(dimensionalWarFightVoApi and dimensionalWarFightVoApi.clear)then
		dimensionalWarFightVoApi:clear()
	end

	self.applynum=0
    self.round2=0
    self.round1=0
    self.place=0
    self.bid=0
    self.point1=0
    self.buff={}
    self.status=0
    self.point2=0
    self.apply_at=0

	self.lastBuyTime=0
	self.initBattleChatNum=0
	self.initSelfRank=false
	self.isInit=false
	self.signUpTime=nil
	self.startWarTime=nil
	self.openDate=0
	self.point=0
	self.shopList={}
	self.shopFlag=-1
	self.eventList={}
	self.eventNum=0
	self.hasMore=false
	self.rankList={{},{}}
	self:clearPointDetail()
end