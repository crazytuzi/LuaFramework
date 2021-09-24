require "luascript/script/config/gameconfig/allianceCityCfg"
require "luascript/script/game/gamemodel/alliance/allianceCity/allianceCityVo"

allianceCityVoApi={
	cityVo=nil, --城市数据
	acityuser=nil, --个人数据
	addRequestFlag=false, --是否在刚进入游戏把初始化军团城市数据接口添加过请求队列的标识
	oldmapx=0,
	oldmapy=0,
	buffTankList=nil, --军团城市军团编制技能加成的坦克列表
}

--是否可以建造军团城市 return 0：可以建造,1：权限不够,2：条件不满足
function allianceCityVoApi:isCanBuildCity(isMoving)
	local flag=-1
	local myAlliance=allianceVoApi:getSelfAlliance()
	if myAlliance and base.allianceCitySwitch==1 then
		if myAlliance.role and tonumber(myAlliance.role)~=2 then
			return 1
		end
		if isMoving==true then --如果是搬迁的话
			flag=0
			return flag
		end
		--当军团等级，军团成员个数，军团活跃等级达到条件后才能建造城市
		local alv,memberc,activelv=(myAlliance.level or 0),(myAlliance.num or 9999),(myAlliance.alevel or 0)
		local bcCfg=allianceCityCfg.buildCondition
		if alv<bcCfg[1] or memberc<bcCfg[2] or activelv<bcCfg[3] then
			return 2
		end
		flag=0
	end
	return flag
end

--是否可以拓展或者回收领地，判断权限
function allianceCityVoApi:isPrivilegeEnoughOfTerritory()
	local myAlliance=allianceVoApi:getSelfAlliance()
	if myAlliance and base.allianceCitySwitch==1 then
		if myAlliance.role and tonumber(myAlliance.role)~=2 then
			return false
		end
	end
	return true
end

--判断是不是有权限
function allianceCityVoApi:isPrivilegeEnough()
	local myAlliance=allianceVoApi:getSelfAlliance()
	if myAlliance and base.allianceCitySwitch==1 then
		if myAlliance.role and tonumber(myAlliance.role)==0 then
			return false
		end
	end
	return true
end

--判断城市是不是放下的状态
function allianceCityVoApi:isCityDown()
	local cityVo=self:getAllianceCity()
	if cityVo and cityVo.state and cityVo.state==1 then --城市所占地块有数据，说明有城市
		return true
	end
	return false
end

--初始化军团城市数据
function allianceCityVoApi:initCity(callback,waiting)
	if base.allianceCitySwitch==0 then
		do return end
	end
	local function initCallBack(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data then
				self:updateData(sData.data)
				if callback then
					callback()
				end
			end
			local point=self:getCityXY()
			if point then
				self:setCityOldMapPoint(point.x,point.y)
			end
		end
	end
	local myAlliance=allianceVoApi:getSelfAlliance()
	if myAlliance and myAlliance.aid then
		socketHelper:getAllianceCity(myAlliance.aid,initCallBack,waiting)
	end
end

function allianceCityVoApi:initAllianceCity(data)
	self.cityVo=self:getAllianceCity()
	self.cityVo:initWithData(data)
end
--初始化个人的数据
function allianceCityVoApi:initAllianceCityUser(data)
	self.acityuser=self:getAllianceCityUser()
	if data.skill then
		self.acityuser.skill=data.skill --个人技能的数据
	end
	if data.glory then
		local lastGlory=self.acityuser.glory
		self.acityuser.glory=data.glory --个人荣耀值
		if tonumber(lastGlory)~=tonumber(self.acityuser.glory) then
			eventDispatcher:dispatchEvent("alliancecity.tipRefresh")
		end
	end
	if data.collect then
		self.acityuser.collect=data.collect --当天采集量， --{r=0,s=0,h=0,t=0}, 采集信息{r稀土，s水晶，h荣耀，t上一次采集时间}
	end
	if data.grab then
		self.acityuser.grab=data.grab --当天掠夺数据   --{r=0,h=0}, 抢夺信息{稀土，荣耀}
	end
end

function allianceCityVoApi:updateData(data,noRefresh)
	if data.alliancecity then
		self:initAllianceCity(data.alliancecity)
	end
	if data.acityuser then
		self:initAllianceCityUser(data.acityuser)
	end
	if noRefresh==true then
		do return end
	end
	if data.alliancecity or data.acityuser then
		eventDispatcher:dispatchEvent("alliancecity.refreshCity",{})
		if data.alliancecity and data.alliancecity.skill then
			eventDispatcher:dispatchEvent("alliancecity.refreshSkils")
		end
	end
end

function allianceCityVoApi:getAllianceCityUser()
	if self.acityuser==nil then
		self.acityuser={skill={},glory=0,collect={},grab={}}
	end
	return self.acityuser
end

--cityData：城市数据（cityVo的pinfo字段）
--encode后传入mapData
--removeFlag：是否是移除军团城市相关的地图数据
function allianceCityVoApi:encodeMapData(cityData,mapData,removeFlag)
	if cityData==nil or mapData==nil then
		do return end
	end
	local myAlliance=allianceVoApi:getSelfAlliance()
	if myAlliance==nil or myAlliance.aid==nil or myAlliance.aid==0 then
		do return end
	end
	local mainCity=cityData[1] or {}
	for k,mid in pairs(mainCity) do
		local basePos=worldBaseVoApi:getPosByMid(mid)
		local baseVo=worldBaseVoApi:getBaseVo(basePos.x,basePos.y)
		local bdata={id=mid,x=basePos.x,y=basePos.y}
		if removeFlag==true then
			bdata.type,bdata.oid,bdata.level,bdata.allianceName=0,0,0,""
			if baseVo and baseVo.aid==myAlliance.aid then
				bdata.aid=0
			end
		else
			local oldBaseVo=worldBaseVoApi:getBaseVo(self.oldmapx,self.oldmapy)
			if oldBaseVo then --保留保护罩时间
				bdata.ptEndTime=oldBaseVo.ptEndTime
			end
			bdata.type,bdata.oid,bdata.level,bdata.allianceName=8,myAlliance.aid,self:getAllianceCityLv(),myAlliance.name
		end
		-- print("main   bdata.type,basePos.x,basePos.y,removeFlag----->",bdata.type,basePos.x,basePos.y,removeFlag)
		mapData[tostring(mid)]=bdata
	end
	for i=2,3 do
		local territories=cityData[i] or {}
		for k,mid in pairs(territories) do
			local basePos=worldBaseVoApi:getPosByMid(mid)
			local bdata={id=mid,x=basePos.x,y=basePos.y}
			local baseVo=worldBaseVoApi:getBaseVo(basePos.x,basePos.y)
			if baseVo==nil then
				if removeFlag==true then
					bdata.aid,bdata.type=0,0
				else
					bdata.aid,bdata.type=myAlliance.aid,0
				end
			else
				if removeFlag==true then
					if baseVo.aid==myAlliance.aid then
						bdata.aid=0
					end
					if baseVo.type==8 and baseVo.oid==myAlliance.aid then
						bdata.type,bdata.oid=0,0
						if baseVo.aid==myAlliance.aid then
							bdata.aid=0
						end
					end
				else
					if (baseVo.aid==0 and baseVo.type~=8) or (baseVo.type==8 and baseVo.oid==myAlliance.aid) then
						bdata.aid=myAlliance.aid
					end
					if baseVo.type==8 and baseVo.oid==myAlliance.aid then
						bdata.type,baseVo.oid=0,0
					end
				end
			end
			mapData[tostring(mid)]=bdata
		end
	end
end

--创建或者搬迁城市
function allianceCityVoApi:createOrMoveAllianceCity(pos,moveFlag,callback)
	local myAlliance=allianceVoApi:getSelfAlliance()
	if myAlliance==nil then
		do return end
	end
	local function requestCallBack(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			local ptEndTime=0
			local oldBaseVo=worldBaseVoApi:getBaseVo(self.oldmapx,self.oldmapy)
			if oldBaseVo then --保留保护罩时间
				ptEndTime=oldBaseVo.ptEndTime
			end
			local alliance={aid=myAlliance.aid,name=myAlliance.name,level=self:getAllianceCityLv(),ptEndTime=ptEndTime,banner=myAlliance.banner}
			local oldpinfo
			local changeType=1
			if moveFlag==true then
				oldpinfo=self:getAllianceCity().pinfo
				worldScene:removeAllianceCity(oldpinfo,alliance)
				changeType=2
			end
			if sData.data then
				self:updateData(sData.data)
			end
			local newpinfo=self:getAllianceCity().pinfo
			worldScene:createAllianceCity(newpinfo,alliance)

			local params={type=changeType,uid=playerVoApi:getUid(),oldpinfo=oldpinfo,pinfo=newpinfo,alliance=alliance}
			chatVoApi:sendUpdateMessage(46,params)

			if callback then
				callback(params)
			end
			local point=self:getCityXY()
			if point then
				self:setCityOldMapPoint(point.x,point.y)
			end
		end
	end
	local oldpos
	if moveFlag==true then
		local citypos=self:getCityXY()
		oldpos={citypos.x,citypos.y}
		if pos[1] and pos[2] and citypos.x==pos[1] and citypos.y==pos[2] then --如果搬迁位置跟之前是同一个位置，不能搬迁
        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("moveCityDisableStr"),28)
        	do return end
		end
	end
	socketHelper:createOrMoveAllianceCity(myAlliance.aid,pos,moveFlag,requestCallBack,oldpos)
end

--创建或者收回领地
function allianceCityVoApi:createOrRecycleTerritory(action,pos,callback)
	local myAlliance=allianceVoApi:getSelfAlliance()
	if myAlliance and myAlliance.aid then
		local function requestCallBack(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				if sData.data then
					self:updateData(sData.data)

					local x,y=pos[1],pos[2]
					local mid=worldBaseVoApi:getMidByPos(x,y)
					local alliance={aid=myAlliance.aid}
					local changeType,recycleFlag=4,false
					if action==1 then --拓展领地
						changeType,recycleFlag=3,false
					elseif action==2 then --回收领地
						changeType,recycleFlag=4,true
					end
					if mid then
						worldScene:createOrRecycleTerritory(mid,alliance,recycleFlag)
						local params={uid=playerVoApi:getUid(),type=changeType,mid=mid,alliance=alliance}
						chatVoApi:sendUpdateMessage(46,params)
					end
					if callback then
						callback(params)
					end
				end
			end
		end
		socketHelper:createOrRecycleTerritory(action,myAlliance.aid,pos,requestCallBack)
	end
end

--提高军团城市个人技能的等级上限和升级技能
function allianceCityVoApi:upgradePersonalSkill(action,sid,callback,level)
	local myAlliance=allianceVoApi:getSelfAlliance()
	if myAlliance and myAlliance.aid then
		local function requestCallBack(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				if sData.data then
					self:updateData(sData.data)
				end
				if callback then
					callback()
				end
				if action==1 then
					local cityVo=self:getAllianceCity()
					local params={uid=playerVoApi:getUid(),alliancecity={skill=cityVo.skill}}
					chatVoApi:sendUpdateMessage(52,params,myAlliance.aid+1)
				end
			end
		end
		socketHelper:upgradePersonalSkill(action,myAlliance.aid,sid,requestCallBack,level)
	end
end

--补充水晶
function allianceCityVoApi:addCrystal(callback)
	local myAlliance=allianceVoApi:getSelfAlliance()
	if myAlliance and myAlliance.aid then
		local function addCallback(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				if sData.data then
					self:updateData(sData.data)
				end
				if callback then
					callback()
				end
                local cityVo=self:getAllianceCity()
                local aid=myAlliance.aid
                local prams={uid=playerVoApi:getUid(),alliancecity={cr=cityVo.cr,crystal=cityVo.crystal},subtype=1}
                chatVoApi:sendUpdateMessage(49,prams,aid+1) --通知军团玩家刷新资源数据
			end
		end
		socketHelper:addCitCrystal(myAlliance.aid,addCallback)
	end
end

--遣返部队
function allianceCityVoApi:backDefCityTroops(action,memberId,callback)
	local myAlliance=allianceVoApi:getSelfAlliance()
	if myAlliance and myAlliance.aid then
		local function backCallBack(fn,data)
			local ret,sData=base:checkServerData(data)
			if ret==true then
				if sData.data then
					self:updateData(sData.data)
				end
				if callback then
					callback()
				end
			end
		end
		socketHelper:backDefCityTroops(action,myAlliance.aid,memberId,backCallBack)
	end
end
--获取军团城市的等级（军团城市等级只能这样取）
function allianceCityVoApi:getAllianceCityLv()
	local level=allianceSkillVoApi:getSkillLevel(22)
	if level==0 or level==nil then
		level=1
	end
	return level
end

function allianceCityVoApi:getAllianceCityName(allianceName,lv)
	local nameStr=allianceName..getlocal("alliance_city")
	if lv then
		nameStr=nameStr..getlocal("fightLevel",{lv})
	end
	return nameStr
end

--获取军团城市等级限制的一个数据
function allianceCityVoApi:getCityLimitCfg()
	local lv=self:getAllianceCityLv()
	return allianceCityCfg.city[lv]
end

--是否已经获取过城市的数据
function allianceCityVoApi:hasGetCity()
	local cityVo=self:getAllianceCity()
	if cityVo.state==nil then
		return false
	end
	return true
end

--判断是否有军团城市
function allianceCityVoApi:hasCity()
	local cityVo=self:getAllianceCity()
	if cityVo and cityVo.pinfo and cityVo.pinfo[1] and #cityVo.pinfo[1]>0 and cityVo.state and cityVo.state==1 then --城市所占地块有数据，说明有城市
		return true
	end
	return false
end

function allianceCityVoApi:getAllianceCity()
	if self.cityVo==nil then
		self.cityVo=allianceCityVo:new()
	end
	return self.cityVo
end

--获取稀土的图片
function allianceCityVoApi:getCrPic()
	return "alliancecr.png"
end

--建造城市的处理逻辑
function allianceCityVoApi:buildCity(callback)
	
end

--获取城市在世界地图中的坐标
function allianceCityVoApi:getCityXY()
	local mid=0
	if self.cityVo.pinfo and self.cityVo.pinfo[1] then
		for k,v in pairs(self.cityVo.pinfo[1]) do
			if tonumber(v)>mid then
				mid=tonumber(v)
			end
		end
		local coords=worldBaseVoApi:getPosByMid(mid)
		return coords
	end
	return nil
end

function allianceCityVoApi:setCityOldMapPoint(x,y)
	self.oldmapx,self.oldmapy=x,y
end

--获取技能描述
function allianceCityVoApi:getPersonalSkillDesc(sid,lv)
   	local skillTb=allianceCityCfg.personSkill
   	local skillCfg=skillTb[sid]
   	if sid=="s6" then
   		lv=(lv==0) and 1 or lv
   		local tankTb={}
        local versionLimitCfg=playerVoApi:getMaxLvByKey("unlockCitySkill")
		versionSid,vsersionLv=versionLimitCfg[1],versionLimitCfg[2]
		if versionSid and vsersionLv and versionSid==sid and vsersionLv>0 then
			if lv>vsersionLv then
				lv=vsersionLv
			end
		end
   		local valueCfg=skillCfg.value
		local svcfg=valueCfg[lv]
		local sk=1
		for i=#svcfg,1,-1 do
			if svcfg[i]>0 then
				sk=i
				do break end
			end
		end
		if sk==1 then
   			tankTb=allianceCityCfg.s6skill1		
		elseif sk==2 then
			tankTb=allianceCityCfg.s6skill2
		end
   		local tankNameStr=""
   		for k,v in pairs(tankTb) do
   			local tankId=tonumber(RemoveFirstChar(v))
   			local tank=tankCfg[tankId]
   			if tank and tank.name then
   				if k==1 then
   					tankNameStr=getlocal(tank.name)
   				else
					tankNameStr=tankNameStr..","..getlocal(tank.name)
   				end
   			end
   		end
   		return getlocal(skillCfg.skilDes,{"<rayimg>"..tankNameStr.."<rayimg>"})
   	end
   	return getlocal(skillCfg.skilDes)
end

--获取技能加成值
function allianceCityVoApi:getPersonalSkillValue(sid,lv)
	local sv,svStr=0,nil
   	local skillTb=allianceCityCfg.personSkill
   	local skillCfg=skillTb[sid]
   	if skillCfg and skillCfg.value then
   		local valueCfg=skillCfg.value
		sv=valueCfg[lv] or 0
		if sid~="s5" and sid~="s6" then
			sv=sv*100
			svStr=getlocal("percentStr",{sv})
		elseif sid=="s6" then
			local svcfg=valueCfg[lv] or {0,0}
			local sk=1
			for i=#svcfg,1,-1 do
				if svcfg[i]>0 then
					sk=i
					sv=svcfg[i]
					do break end
				end
			end
	   		svStr=getlocal("percentStr",{sv*100})
		else
			svStr=tostring(sv)
		end
   	end
   	return svStr,sv
end

--获取当前军团编制技能所加的buff描述
function allianceCityVoApi:getSkill6Desc()
	local sid="s6"
	local cityVo=self:getAllianceCity()
   	local skillTb=allianceCityCfg.personSkill
   	local skillCfg=skillTb[sid]
    local acityuser=self:getAllianceCityUser()
    local lv,limitLv=(acityuser.skill[sid] or 0),(cityVo.skill[sid] or 0)
    local levelLimit=allianceCityCfg.allianceSkill[sid].levelLimit
    if lv>levelLimit then
        lv=levelLimit
    end
    if lv>limitLv then --技能等级不能超过该技能等级限制
    	lv=limitLv
    end
    local versionLimitCfg=playerVoApi:getMaxLvByKey("unlockCitySkill")
    local versionSid,vsersionLv=versionLimitCfg[1],versionLimitCfg[2]
    if versionSid and vsersionLv and versionSid==sid and vsersionLv>0 then
        if lv>vsersionLv then --技能等级不能超过version等级限制
            lv=vsersionLv
        end
    end

    local value=skillCfg.value[lv] or {0,0}
    local s6skillCfg={allianceCityCfg.s6skill1,allianceCityCfg.s6skill2}
		local tankNameStrTb={}
		for k,v in pairs(s6skillCfg) do
			tankNameStrTb[k]=""
   		for tk,tid in pairs(v) do
   			local tankId=tonumber(RemoveFirstChar(tid))
   			local tank=tankCfg[tankId]
   			if tank and tank.name then
   				if tk==1 then
   					tankNameStrTb[k]=getlocal(tank.name)
   				else
					tankNameStrTb[k]=tankNameStrTb[k]..","..getlocal(tank.name)
   				end
   			end
   		end
		end
    local descTb={}
    for k,v in pairs(tankNameStrTb) do
    	descTb[k]=getlocal(skillCfg.skilDes,{"<rayimg>"..v.."<rayimg>"})..getlocal("percentStr",{(value[k]*100 or 0)})
    end
    return descTb
end

--获取当前城市维护每小时的消耗
function allianceCityVoApi:getMaintainCost()
	local cost,addCost=0,0
	local cityLv=self:getAllianceCityLv()
	local cityVo=self:getAllianceCity()	
	local cfg=allianceCityCfg.city[cityLv]
	if cfg then
		if cityVo.pinfo and cityVo.pinfo[3] then
			local territoryCount=SizeOfTable(cityVo.pinfo[3])
			cost=cost+territoryCount*cfg.tableCostR
		end
		cost=cost+cfg.mainCostR
	end
	if cityVo.maintain and cityVo.maintain.f then --维护增长
		local lvalue=allianceCityCfg.lossValue*cityVo.maintain.f
		if lvalue>allianceCityCfg.valueLimit then
			lvalue=allianceCityCfg.valueLimit
		end
		addCost=cost*lvalue
	end
	return cost+addCost,addCost
end

--获取水晶的数量和上限
function allianceCityVoApi:getCrystal()
	local crystal,limit=0,0
	local cityVo=self:getAllianceCity()
	crystal=cityVo.crystal
	local cityLv=self:getAllianceCityLv()
	local cfg=allianceCityCfg.city[cityLv]
	if cfg then
		limit=cfg.allianceLimitS
	end
	return crystal,limit
end

--获取扩展的领地的个数
function allianceCityVoApi:getTerritoryCount()
	local cityVo=self:getAllianceCity()
	local cityLv=self:getAllianceCityLv()
	if cityVo and cityVo.pinfo and cityVo.pinfo[3] then
		return SizeOfTable(cityVo.pinfo[3]),math.floor(cityLv/2)
	end
	return 0,0
end

--获取最近拓展的领地的坐标
function allianceCityVoApi:getLastTerritoryXY()
	local cityVo=self:getAllianceCity()
	if cityVo and cityVo.pinfo and cityVo.pinfo[3] then
		local tc=SizeOfTable(cityVo.pinfo[3])
		if tc>0 then
			local coords=worldBaseVoApi:getPosByMid(cityVo.pinfo[3][tc])
			return coords
		end
	end
	return {x=0,y=0}
end

function allianceCityVoApi:getAllianceCityIcon(callback,iconType)
	local citySp
	if callback==nil then
		citySp=CCSprite:createWithSpriteFrameName("allianceCity.png")
	else
		local function touchCity()
			if callback then
				callback()
			end
		end
		citySp=LuaCCSprite:createWithSpriteFrameName("allianceCity.png",touchCity)
	end

	local radarSp=CCSprite:createWithSpriteFrameName("acityRadar1.png")
	radarSp:setAnchorPoint(ccp(0.5,0.5))
	radarSp:setPosition(132,163)
	citySp:addChild(radarSp)

	if iconType and iconType==1 then
		local frameArr=CCArray:create()
		for kk=1,6 do
			local nameStr="acityRadar"..kk..".png"
			local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
			frameArr:addObject(frame)
		end
		local animation=CCAnimation:createWithSpriteFrames(frameArr)
		animation:setDelayPerUnit(0.3)
		local animate=CCAnimate:create(animation)
		local delayAction=CCDelayTime:create(1.5)
		local seq=CCSequence:createWithTwoActions(animate,delayAction)
		local repeatForever=CCRepeatForever:create(seq)
		radarSp:runAction(repeatForever)
	end

	return citySp
end

function allianceCityVoApi:showAllianceCityDialog(layerNum,isJump)
	if base.allianceCitySwitch~=1 then
     	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26000"),28)
		do return end
	end
	local joinFlag=allianceVoApi:isHasAlliance()
	if joinFlag==false then
     	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("enterCityNoAlliance"),28)
		do return end
	end
    local function initHandler()
      local flag=self:hasCity()
      if flag==true then --有城市数据打开城市页面
        require "luascript/script/game/scene/gamedialog/allianceDialog/allianceCity/allianceCityDialog"
        local td=allianceCityDialog:new()
        local tbArr={getlocal("cityBuilded"),getlocal("skillDevelop")}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),tbArr,nil,nil,getlocal("alliance_city"),true,layerNum)
        sceneGame:addChild(dialog,layerNum)
      else --否则打开建造城市的页面
      	if isJump==true then

      	end
        require "luascript/script/game/scene/gamedialog/allianceDialog/allianceCity/allianceCityCreateDialog"
        local td=allianceCityCreateDialog:new()
        local tbArr={}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0,0,400,350),CCRect(168,86,10,10),tbArr,nil,nil,getlocal("alliance_city"),true,layerNum)
        sceneGame:addChild(dialog,layerNum)
      end
    end
    self:initCity(initHandler)
end

function allianceCityVoApi:isTodayCanOpenShield()
	local cityVo=self:getAllianceCity()
	if cityVo.protectst and G_isToday(cityVo.protectst)==false then
		return true
	end
	return false
end
--城市开启护盾的稀土消耗
function allianceCityVoApi:getOpenShieldCost()
	local skillLv=allianceSkillVoApi:getSkillLevel(23) or 0
    return allianceCityCfg.protectValue+skillLv*allianceCityCfg.protectAdd
end

function allianceCityVoApi:openAllianceCityShield(pos,callback)
	local function shieldHandler(fn,data)
		local ret,sData=base:checkServerData(data)
		if ret==true then
			if sData.data then
				self:updateData(sData.data)
				if sData.data.ptEndTime then --保护结束时间
					local x,y=pos[1],pos[2]
					if x and y then
						worldScene:addCityProtect(x,y,sData.data.ptEndTime)
						local params={type=5,uid=playerVoApi:getUid(),x=x,y=y,ptEndTime=sData.data.ptEndTime}
        				chatVoApi:sendUpdateMessage(46,params) --通知全服更新城市保护罩
						if callback then
							callback(sData.data.ptEndTime)
						end
					end
				end
			end
		end
	end
	local myAlliance=allianceVoApi:getSelfAlliance()
	if myAlliance and myAlliance.aid then
		socketHelper:openAllianceCityShield(myAlliance.aid,pos,shieldHandler)
	end
end

--显示查看城市内容的页面
function allianceCityVoApi:showCheckCityDialog(data,isOther,layerNum)
    require "luascript/script/game/scene/gamedialog/allianceDialog/allianceCity/allianceCityCheckDialog"
    local sd=allianceCityCheckDialog:new(data,isOther)
    return sd:init(layerNum)
end

--获取驻守收益
function allianceCityVoApi:getDefincome(def)
	if def==nil then
		do return false end
	end
	local cityVo=self:getAllianceCity()
	local acityuser=self:getAllianceCityUser()
	if def.troops==nil or cityVo==nil or acityuser==nil then
		do return false end
	end
	local citylv=self:getAllianceCityLv()
    local dist=def.dist
	local distTime=base.serverTime-dist
	-- print("dist,distTime,base.serverTime-------->",dist,distTime,base.serverTime)
	local troops=def.oldtroops
	if troops==nil then
		troops=def.troops
	end
    if distTime>0 and next(troops) then --已经到达军团城市开始产生驻守收益
      	if acityuser.collect.t and G_getWeeTs(acityuser.collect.t)~=G_getWeeTs(dist) then
        	acityuser.collect={r=0,h=0,s=0,t=dist}
        end
        -- 可采集水晶，稀土，荣耀，驻守每小时获得的荣耀值，荣耀值满时所需的驻守时间
        local cityCfg=allianceCityCfg.city
        local collectS,collectR,collectH,perHourH,deftime=0,0,0,0,0
        local maxS,maxR,maxH=cityCfg[citylv].personLimitS,cityCfg[citylv].collLimitR,self:getCollectHLimit(citylv)

        local perHourH,deftime=0,0
    	local collectTb={["s"]=0,["r"]=0,["h"]=0}
		local limitTb={["s"]=cityCfg[citylv].personLimitS,["r"]=cityCfg[citylv].collLimitR,["h"]=maxH}
        for k,v in pairs(troops) do
            if v and v[1] and v[2] and v[2]>0 then
                local tankId,num=tonumber(RemoveFirstChar(v[1])),v[2]
                if tankCfg[tankId] then
                    collectTb["s"]=collectTb["s"]+tankCfg[tankId].collLimitS*(distTime/3600)*num
                    collectTb["r"]=collectTb["r"]+tankCfg[tankId].collLimitR*(distTime/3600)*num
                    collectTb["h"]=collectTb["h"]+tankCfg[tankId].clooLimitH*(distTime/3600)*num
                    perHourH=perHourH+tankCfg[tankId].clooLimitH*num
                end
            end
        end
        local maxTb={["s"]=0,["r"]=0,["h"]=0}
        for rkey,rcollect in pairs(collectTb) do
        	-- print("limitTb,rkey,acityuser.collect------>",limitTb[rkey],rkey,acityuser.collect[rkey])
        	local leftCollect=limitTb[rkey]-(acityuser.collect[rkey] or 0)
        	if leftCollect<0 then
        		leftCollect=0
        	end
        	if rcollect>leftCollect then
        		rcollect=leftCollect
        	end
        	if rkey=="s" then
        		if rcollect>cityVo.crystal then --水晶可以采集的量不能大于当前城市拥有的量
        			rcollect=cityVo.crystal
        		end
        	end
        	collectTb[rkey]=math.floor(rcollect)
        	maxTb[rkey]=leftCollect
        end
  
        local curCollectH=acityuser.collect.h or 0 --当天已经获得的荣耀
        if curCollectH>maxH then
        	curCollectH=maxH
        end
		deftime=math.ceil((maxH-curCollectH)/perHourH*3600) --驻守时间，单位秒

        return true,collectTb,maxTb,deftime,distTime
    else --队列还在行军中
    	do return false end
    end
end

--判断是否有防守部队
function allianceCityVoApi:ishasDefTroops(uid)
	local cityVo=self:getAllianceCity()
	if cityVo.deflist then
		for k,v in pairs(cityVo.deflist) do
			if tonumber(v[2])==tonumber(uid) then
				do return true end
			end
		end
	end
	return false
end

--判断是否有进攻部队
function allianceCityVoApi:ishasAttackTroops(x,y)
	local allSlots=attackTankSoltVoApi:getAllAttackTankSlots()
	for k,v in pairs(allSlots) do
		if v.type==8 and v.isDef==0 and v.targetid and v.targetid[1] and v.targetid[2] and tonumber(v.targetid[1])==tonumber(x) and tonumber(v.targetid[2])==tonumber(y) then
			do return true end
		end
	end
	return false
end

--该城市是否有防守队列
function allianceCityVoApi:ishasDefList()
	local cityVo=self:getAllianceCity()
	if SizeOfTable(cityVo.deflist)>0 then
		return true
	end
	return false
end

--是否有敌军来袭的队列
function allianceCityVoApi:ishasAttackList()
	local cityVo=self:getAllianceCity()
	if SizeOfTable(cityVo.attlist)>0 then
		return true
	end
	return false
end

--判断当前部队数是否满足驻防需求
function allianceCityVoApi:isTroopsNumEnableDef(num)
	local needNum=self:getDefTroopsLimit()
	if num>=needNum then
		return true,needNum
	end
	return false,needNum
end

--获取驻防最低部队数限制
function allianceCityVoApi:getDefTroopsLimit()
	local playerLv=playerVoApi:getPlayerLevel()
	return playerLv*allianceCityCfg.colloctTroops
end

--获取侦查军团城市消耗
function allianceCityVoApi:getSpyCost(lv)
   	return allianceCityCfg.spyCostH+allianceCityCfg.spyValue*lv
end

--当退出军团或者结算军团时清除军团城市 dissolveFlag：是否是解散军团
function allianceCityVoApi:clearMyAllianceCity(dissolveFlag)
	local mapData={}
	local cityVo=self:getAllianceCity()
	local myAlliance=allianceVoApi:getSelfAlliance()
	if dissolveFlag==true then
		local alliance={aid=myAlliance.aid}
		local params={uid=playerVoApi:getUid(),type=6,oldpinfo=cityVo.pinfo,alliance=alliance}
		chatVoApi:sendUpdateMessage(46,params)
		worldScene:removeAllianceCity(cityVo.pinfo,alliance) --移除军团城市
	else
		for k,mid in pairs(cityVo.pinfo[1]) do
			local pos=worldBaseVoApi:getPosByMid(mid)
			mapData[tostring(mid)]={id=mid,x=pos.x,y=pos.y}
		end
		for i=2,3 do
			if cityVo.pinfo[i] then
				for k,mid in pairs(cityVo.pinfo[i]) do
					local pos=worldBaseVoApi:getPosByMid(mid)
					mapData[tostring(mid)]={id=mid,x=pos.x,y=pos.y}
				end
			end
		end
	end	
	return mapData
end

--加入军团后重新刷新世界地图军团城市的领地状态
function allianceCityVoApi:refreshMyCity()
	if worldScene.clayer==nil then
		do return end
	end
	local mapData={}
	local cityVo=self:getAllianceCity()
	for k,mid in pairs(cityVo.pinfo[1]) do
		local pos=worldBaseVoApi:getPosByMid(mid)
		mapData[tostring(mid)]={id=mid,x=pos.x,y=pos.y}
	end
	for i=2,3 do
		if cityVo.pinfo[i] then
			for k,mid in pairs(cityVo.pinfo[i]) do
				local pos=worldBaseVoApi:getPosByMid(mid)
				mapData[tostring(mid)]={id=mid,x=pos.x,y=pos.y}
			end
		end
	end
	worldScene:refreshMapBase(mapData) --刷新军团城市地块数据
end
--获取自己的驻防队列
function allianceCityVoApi:getMyDef()
	local uid=playerVoApi:getUid()
	local allSlots=attackTankSoltVoApi:getAllAttackTankSlots()
	for k,v in pairs(allSlots) do
		if tonumber(v.slotId)==tonumber(uid) and v.type==8 and v.isDef>0 then
			return v
		end
	end
	return nil
end

function allianceCityVoApi:showHelpDialog(layerNum)
	require "luascript/script/game/scene/gamedialog/allianceDialog/allianceCity/allianceCityHelpDialog"
	local td=allianceCityHelpDialog:new(layerNum)
	local tbArr={}
	local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliancecity_help_title"),true,layerNum)
	sceneGame:addChild(dialog,layerNum)
end

--检测军团城市是否真正放置
function allianceCityVoApi:checkCityIsDrop(layerNum)
	local cityVo=self:getAllianceCity()
	if cityVo.state~=1 then
		return false
	end
	return true
end

--刷新世界地图上自己军团城市,比如说城市升级后刷新世界地图等级
function allianceCityVoApi:refreshWorldMapCity(lv)
	if self:hasCity()==true then
		local cityVo=self:getAllianceCity()
		local myAlliance=allianceVoApi:getSelfAlliance()
		if cityVo and cityVo.pinfo[1] then
			local mapData={}
			for k,mid in pairs(cityVo.pinfo[1]) do
				local basePos=worldBaseVoApi:getPosByMid(mid)
				local bdata={id=mid,x=basePos.x,y=basePos.y,level=lv,type=8,allianceName=myAlliance.name}
				mapData[tostring(mid)]=bdata
			end
		 	local params={uid=playerVoApi:getUid(),map=mapData}	
			chatVoApi:sendUpdateMessage(51,params)
			worldScene:refreshMapBase(mapData)
		end
	end
end

--搬家消耗
function allianceCityVoApi:getMoveCost()
	local lv=self:getAllianceCityLv()
	return allianceCityCfg.moveCost*lv*lv
end

--获取拓展地块消耗
function allianceCityVoApi:getCreateTerritoryCost()
	--tableOne*((地块数*2)^2)
	local tc=self:getTerritoryCount()
	tc=(tc+1)*2
	local cost=allianceCityCfg.tableOne*(tc*tc)
	return cost
end

--获取领地buff效果
function allianceCityVoApi:getTerritoryBuff()
    local tc,tclimit=self:getTerritoryCount()	
    local buffLv=tc
    local cityVo=self:getAllianceCity()
    if cityVo and cityVo.pinfo and cityVo.pinfo[2] and SizeOfTable(cityVo.pinfo[2]) then
    	buffLv=buffLv+1
    end
	local cfgnum=SizeOfTable(allianceCityCfg.territoryBuff)
	if buffLv>cfgnum then
        buffLv=cfgnum
    end
    local territoryBuff=allianceCityCfg.territoryBuff[buffLv]
    return territoryBuff
end

--获取军团编制所添加的坦克buff加成
function allianceCityVoApi:getSkill6TankBuff(tankId)
	local selfAlliance=allianceVoApi:getSelfAlliance()
    if base.allianceCitySwitch==0 or allianceCityVoApi:hasCity()==false or selfAlliance==nil then
    	return 0
    end
	if self.buffTankList==nil then --如果有军团城市的话，技能坦克生产速度
		self.buffTankList={}
	   	local buffTankCfg={allianceCityCfg.s6skill1,allianceCityCfg.s6skill2}
		for k,v in pairs(buffTankCfg) do
			for kk,vv in pairs(v) do
				self.buffTankList[tonumber(RemoveFirstChar(vv))]=k
			end
		end
	end
	local sid="s6"
	if self.buffTankList[tonumber(tankId)] then
	   	local skillTb=allianceCityCfg.personSkill
	   	local skillCfg=skillTb[sid]
	    local acityuser=allianceCityVoApi:getAllianceCityUser()
	    local cityVo=allianceCityVoApi:getAllianceCity()
	    local buffLv,limitLv=(acityuser.skill[sid] or 0),(cityVo.skill[sid] or 0)
	    if buffLv>limitLv then
	        buffLv=limitLv
	    end
	    local value=skillCfg.value[buffLv] or {0,0}
	    return value[self.buffTankList[tankId]] or 0
	end
   	return 0
end

--下次维护剩余时间
function allianceCityVoApi:getMaintainLeftTime()
	local cityVo=self:getAllianceCity()
	local et=0
	if cityVo.maintain and cityVo.maintain.t then
		et=cityVo.maintain.t+allianceCityCfg.mainTime*60
	else
		et=base.serverTime+allianceCityCfg.mainTime*60
	end
	local lefttime=et-base.serverTime
	if lefttime<=0 then
		lefttime=0
	end
	return lefttime
end

--城市回收后，获取可以重新建造的冷却剩余时间
function allianceCityVoApi:getRebuildCoolingTime()
    local cityVo=self:getAllianceCity()
    if cityVo.state==0  and cityVo.maintain and cityVo.maintain.rt then
        local lefttime=(allianceCityCfg.restartCity*60+cityVo.maintain.rt)-base.serverTime
        if lefttime<0 then
        	lefttime=0
        end
        return lefttime
    end
    return 0
end

--获取开启保护罩的保护时间
function allianceCityVoApi:getShieldTime()
	local sid=23
	local skillLv=allianceSkillVoApi:getSkillLevel(sid) or 0

	local shildTime=allianceCityCfg.protectTime
	if allianceSkillCfg[sid] and allianceSkillCfg[sid].protectValue and allianceSkillCfg[sid].protectValue[skillLv] then
		shildTime=shildTime+allianceSkillCfg[sid].protectValue[skillLv]
	end
	return shildTime
end

--个人荣耀是否可以升级技能
function allianceCityVoApi:isGloryEnoughToUpgrade(sid)
    local cityVo,acityuser=self:getAllianceCity(),self:getAllianceCityUser()
	local function enoughToUpgrade(skillId)
	    local skillLv,limitLv=(acityuser.skill[skillId] or 0),(cityVo.skill[skillId] or 0)
	    if skillLv>=limitLv then
	    	return false
	    end
	    local scfg=allianceCityCfg.personSkill[skillId]
	    if scfg==nil then
	    	return false
	    end
    	local glory,cost=(acityuser.glory or 0),scfg.costH[skillLv+1]
    	if glory>=cost then
    		return true
    	end
    	return false
	end
	if sid then
		return enoughToUpgrade(sid)
	else
		for sid,v in pairs(allianceCityCfg.personSkill) do
			local flag=enoughToUpgrade(sid)
			if flag==true then
				return true
			end
		end
		
	end
	return false
end

--获取个人采集荣耀的上限
function allianceCityVoApi:getCollectHLimit(lv)
	local citylv=lv or self:getAllianceCityLv()
    local cityCfg=allianceCityCfg.city
    local limitH=0
    if cityCfg[citylv] then
    	local battleBuff,skillBuff=warStatueVoApi:getTotalWarStatueAddedBuff("honourLimit")
    	local rate=skillBuff.honourLimit or 0
    	limitH=cityCfg[citylv].collLimitH*(1+rate)
    end
    return limitH
end

function allianceCityVoApi:clear()
	self.cityVo=nil
	self.acityuser=nil
	self.addRequestFlag=false
	self.oldmapx=0
	self.oldmapy=0
	self.buffTankList=nil
end