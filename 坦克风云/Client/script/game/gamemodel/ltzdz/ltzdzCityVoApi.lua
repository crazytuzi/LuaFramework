require "luascript/script/game/gamemodel/ltzdz/ltzdzFightApi"
ltzdzCityVoApi={}

function ltzdzCityVoApi:getCityCfg(cityId)
	local cfg=ltzdzVoApi:getMapCfg()
	return cfg.citycfg[cityId]
end

function ltzdzCityVoApi:getCityName(cityId)
	return getlocal("ltzdz_city_name_"..cityId)
end

function ltzdzCityVoApi:getBuildInfoByType(btype,lv)
	local lv=lv or 1
    local reserve,oil,metal=ltzdzCityVoApi:getBuildingCapacity(btype,lv)
    local nameStr,descStr,resPic="",""
    if btype==3 then
    	descStr=getlocal("ltzdz_building_desc3",{oil})
    	resPic="ltzdzOilIcon.png"
   	elseif btype==4 then
    	descStr=getlocal("ltzdz_building_desc4",{reserve})
    	resPic="ltzdzReserveIcon.png"
	elseif btype==5 then
    	descStr=getlocal("ltzdz_building_desc5",{metal})
    	resPic="ltzdzMetalIcon.png"
    elseif btype==1 or btype==2 then
    	descStr=getlocal("ltzdz_building_desc1",{oil,reserve})
    	nameStr=getlocal("ltzdz_building_name1")
    end
    if btype>=3 then
    	nameStr=getlocal("ltzdz_building_name"..btype)
    end
	local pic="ltzdzBuilding"..btype..".png"
	return nameStr,descStr,pic,resPic
end

function ltzdzCityVoApi:getCity(cityId)
    require "luascript/script/game/gamemodel/ltzdz/ltzdzFightApi"
    local data=ltzdzFightApi:getTargetCityByCid(cityId)
    if data then
    	local city={}
    	city.id=cityId
		city.mbType=data.b[1] or 1--主基地类型
		city.mbLv=data.b[2] or 1--主基地等级
		city.mbet=data.b[3] --主基地升级结束时间
		city.buildings=data.b[4] or {}--基地建筑队列（包括升级）
		city.upCount=data.b[5] or 0--自动升级已完成的次数
		city.reserve=data.n or 0 --预备役
		city.oid=data.oid --占领的玩家uid
		city.defTroops=data.d or {} --城市的防守部队
		return city
    end
    return nil
end

--获取城市的各种资源的产量(附加计算城市建筑数)
function ltzdzCityVoApi:getCityCapacity(cityId)
	local time=60 --时间单位是分钟
	local reserve,oil,money=0,0,0
	local rbNum,obNum,mebNum=0,0,0 --坦克工厂数量，油井数量，市场数量
    local city=self:getCity(cityId)
	local buildingCfg=ltzdzVoApi:getBuildingCfg()
	local baseCfg=buildingCfg[city.mbType]
	reserve=baseCfg.tankProducetArr[city.mbLv] or 0
	oil=baseCfg.oilProducetArr[city.mbLv] or 0
	money=baseCfg.mineProducetArr[city.mbLv] or 0

	for k,v in pairs(city.buildings) do
		local btype,lv=v[1],(v[2] or 0)
		local cfg=buildingCfg[btype]
		if btype==3 then
			oil=oil+(cfg.oilProducetArr[lv] or 0)
			obNum=obNum+1
		elseif btype==4 then
			reserve=reserve+(cfg.tankProducetArr[lv] or 0)
			rbNum=rbNum+1
		elseif btype==5 then
			money=money+(cfg.mineProducetArr[lv] or 0)
			mebNum=mebNum+1
		end
	end
	--资源产量计算公式：基础产量*（1+段位加成）*开战后资源加成
	--开战后资源加成
	local resUp=1
	local battleFlag=ltzdzFightApi:isTrueBattle()
	if battleFlag==true then
		local warCfg=ltzdzVoApi:getWarCfg()
		resUp=warCfg.resUp
	end
	--段位加成
	local rescbuff=ltzdzFightApi:getTitleBuff()
	reserve=math.ceil(reserve*time*(1+rescbuff)*resUp)
	oil=math.ceil(oil*time*(1+rescbuff)*resUp)
	money=math.ceil(money*time*(1+rescbuff)*resUp)
	return reserve,oil,money,rbNum,obNum,mebNum,city.reserve
end

--每分钟资源的产量
function ltzdzCityVoApi:getBuildingCapacity(btype,lv)
	local time=60 --时间单位是分钟
	local reserve,oil,money=0,0,0
	local buildingCfg=ltzdzVoApi:getBuildingCfg()
	local cfg=buildingCfg[btype]
	if cfg and lv<=cfg.maxLevel then
		if cfg.tankProducetArr and cfg.tankProducetArr[lv] then
			reserve=math.ceil(cfg.tankProducetArr[lv]*time)
		end
		if cfg.oilProducetArr and cfg.oilProducetArr[lv] then
			oil=math.ceil(cfg.oilProducetArr[lv]*time)
		end
		if cfg.mineProducetArr and cfg.mineProducetArr[lv] then
			money=math.ceil(cfg.mineProducetArr[lv]*time)
		end
	end
	return reserve,oil,money
end

function ltzdzCityVoApi:upgradeCallBack(cityId,bid)
	local city=ltzdzFightApi:getTargetCityByCid(cityId)
	local buildingCfg=ltzdzVoApi:getBuildingCfg()	
	if city and city.b[bid] and buildingCfg[bid] then
		local cfg=buildingCfg[city.b[bid][1]]
		local curLv=city.b[bid][2]
		if cfg.maxLevel>curLv then
			city.b[bid][2]=curLv+1 --等级+1
			city.b[bid][3]=0 --升级结束时间变为0
		end
	end
end

--领土争夺战 城市建筑建造，升级和移除的操作
function ltzdzCityVoApi:ltzdzBuildingOperate(args,callback)
	local function requestHandler(fn,data)
		local ret,sData=base:checkServerData2(data)
		if ret==true then
			ltzdzFightApi:syncMyRes(sData.data.metal,sData.data.oil,sData.data.gems)
			if sData.data.city then
				ltzdzFightApi:updateCity(sData.data.city)
			end
			local action=args.action
			if action==1 or action==3 or action==4 or action==5 then --建造或者升级时需要检测数据是否正常
				local errFlag=self:isCityAbnormal(sData.data.city)
				-- print("------->>>>>>>errFlag,args.cid---->",errFlag,args.cid)
				if errFlag==true then --如果数据异常则同步城市数据
	        		self:syncCity(args.cid)
				end
			end
			if callback then
				callback()
			end
		end
	end
	local tid=ltzdzVoApi.clancrossinfo.tid
	socketHelper2:ltzdzBuildingOperate(args,requestHandler,tid)
end

--判断服务器返回的城市建筑数据是否异常
function ltzdzCityVoApi:isCityAbnormal(cityTb)
	local errFlag=false
	for k,v in pairs(cityTb) do
		if v.b then
			if v.b[3] and tonumber(v.b[3])<base.serverTime and tonumber(v.b[3])>0 then --主基地升级时间异常（结束时间比本地时间小）
				errFlag=true
				do break end
			end
			if v.b[4] then
				for sk,sv in pairs(v.b[4]) do
					-- print("k,sk,sv[1],sv[2],sv[3],base.serverTime------->>>",k,sk,sv[1],sv[2],sv[3],base.serverTime)
					if sv[3] and tonumber(sv[3])<base.serverTime and tonumber(sv[3])>0 then --资源建筑升级时间异常
						-- print("------>>>>DDDDDDDDDD")
						errFlag=true
						do break end
					end
				end
			end
		end
	end
	return errFlag
end

function ltzdzCityVoApi:syncCity(cid,callBack,action)
    local function syncHandler(fn,data)
        local ret,sData=base:checkServerData2(data)
        if ret==true then
        	if sData and sData.data and  sData.data.city then
	        	if cid then
		        	local errFlag=self:isCityAbnormal(sData.data.city)
		        	-- print("errFlag--------->",errFlag)
		        	if errFlag==true then --有异常数据
		        		self:syncCity(cid,callBack,action)
		        		do return end
		        	end
	        	end
	        	ltzdzFightApi:updateCity(sData.data.city)
	        end

    		
			ltzdzFightApi:syncMyRes(sData.data.metal,sData.data.oil,sData.data.gems)
			if sData and sData.data and sData.data.user then
				ltzdzFightApi:updateUser(sData.data.user)
			end

            if callBack then
            	if action==2 then --如果是侦查的话，当侦查个数达到上限后需要清除最早的侦查数据
            		local flag,clearCid=ltzdzFightApi:clearPremierScoutCity()
            		if flag==true and clearCid then
	            		callBack(clearCid)
	            	else
	            		callBack()
            		end
            	else
            		callBack()
            	end
            end
        end
    end
    local uid=tonumber(playerVoApi:getUid())
    local roomid=ltzdzVoApi.clancrossinfo.roomid
    local tid=ltzdzVoApi.clancrossinfo.tid
    socketHelper2:ltzdzGetCity(roomid,cid,syncHandler,action,tid)
end

function ltzdzCityVoApi:isMainBuildCanUpgrade(city)
	--state：1：可以升级，2：已经升级到最大等级，3：资源不足，4：正在升级
	local state=1
	local buildingCfg=ltzdzVoApi:getBuildingCfg()
	local metal=ltzdzFightApi:getMyRes()
	local cfg=buildingCfg[city.mbType]
	local et=city.mbet or 0
	if city.mbLv>=cfg.maxLevel then
		state=2
	elseif et>0 then
		state=4
	else
		local cost=cfg.mineConsumeArr[city.mbLv+1]
		if cost>metal then
			state=3
		end
	end
	return state
end

function ltzdzCityVoApi:isCanBuild(city,btype,bid)
	--state：1：可以建造，2：资源不足
	local state=1
	local buildingCfg=ltzdzVoApi:getBuildingCfg()
	local cityCfg=self:getCityCfg(city.id) --城市配置
	local metal=ltzdzFightApi:getMyRes()
	local cfg=buildingCfg[btype]	
	if bid then --升级或建造指定建筑
		local cost=cfg.mineConsumeArr[1]
		if cost>metal then
			state=2
		end
	else --批量建造或升级同类型的建筑
		local allCost=0
	    local buildCount=cityCfg.maxBldCount
	    for i=1,buildCount do
	    	local bid="b"..i
	    	if city.buildings[bid]==nil then
	    		allCost=allCost+cfg.mineConsumeArr[1]
	    	end
	    end
		if allCost>metal then
			state=2
		end
	end
	return state
end

function ltzdzCityVoApi:isCanUpgrade(city,btype,bid)
	--state：1：可以升级，2：资源不足，3：已经升级到最大等级，4：正在升级
	local state=1
	local buildingCfg=ltzdzVoApi:getBuildingCfg()
	local metal=ltzdzFightApi:getMyRes()
	local allCost=0
	if bid or tonumber(btype)<=2 then --升级或建造指定建筑
		local lv,et
		if tonumber(btype)<=2 then --主基地
			lv,et=city.mbLv,city.mbet
		else
			local building=city.buildings[bid]
			lv,et=(building[2] or 0),(building[3] or 0)
		end
		local cfg=buildingCfg[btype]
		if lv>=cfg.maxLevel then
			state=3
		elseif et>0 then --如果升级未结束，则正在升级
			state=4
		else
			allCost=cfg.mineConsumeArr[lv+1]
			if allCost>metal then
				state=2
			end
		end
	else --批量建造或升级同类型的建筑
		for bid,building in pairs(city.buildings) do
			if tonumber(building[1])==tonumber(btype) then
				local lv=building[2] or 0
				local et=building[3] or 0
				local cfg=buildingCfg[btype]
				if lv<cfg.maxLevel and et==0  then
					allCost=cfg.mineConsumeArr[lv+1]+allCost
				end
			end
		end
		if allCost>metal then
			state=2
		end
	end
	return state
end

--建筑升级或者移除的页面
function ltzdzCityVoApi:showBuildingUpgradeOrRemoveDialog(build,layerNum,isuseami,isSizeAmi,callback)
    require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzBuildingSmallDialog"	
	ltzdzBuildingSmallDialog:showBuildingUpgradeOrRemoveDialog(build,layerNum,isuseami,isSizeAmi,callback)
end

--建造资源建筑页面
function ltzdzCityVoApi:showBuildingSelectDialog(layerNum,isuseami,isSizeAmi,callback)
    require "luascript/script/game/scene/gamedialog/ltzdz/ltzdzBuildingSmallDialog"
    ltzdzBuildingSmallDialog:showBuildingSelectDialog(layerNum,isuseami,isSizeAmi,callback)
end

function ltzdzCityVoApi:clear()
end
                


-- --获取城内建筑建造或升级队列
-- function ltzdzCityVoApi:getBuildingSlot(city)
-- 	local mainBld={}
-- 	local buildings={}
-- 	if city then
-- 		local slot=city.upgradeSlot
-- 		for k,v in pairs(slot) do
-- 			local bid=v[3]
-- 			local build={btype=v[1],et=v[2]}
-- 			if bid then --资源建筑
-- 				buildings[bid]=build
-- 			else --主基地
-- 				mainBld=build
-- 			end
-- 		end
-- 	end
-- 	return mainBld,buildings
-- end