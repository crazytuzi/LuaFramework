ltzdzCityDialog={}

function ltzdzCityDialog:new(cityId,parent)
	local nc={
		cityId=cityId,
        parent=parent,
        syncFlag=false,
	}
  	setmetatable(nc,self)
    self.__index=self

    return nc
end

function ltzdzCityDialog:init(layerNum)
    ltzdzVoApi:addOrRemoveOpenDialog(1,"ltzdzCityDialog",self)
    spriteController:addPlist("public/ltzdz/ltzdzCityImages.plist")
    spriteController:addTexture("public/ltzdz/ltzdzCityImages.png")

    self:handleTankRes() --加载坦克的资源

	self.cityCfg=ltzdzCityVoApi:getCityCfg(self.cityId) --城市配置
    self:pullCity()
    self.roomid=ltzdzVoApi.clancrossinfo.roomid

    self.layerNum=layerNum
    self.bgLayer=CCLayer:create()
    -- self.bgLayer:setTouchEnabled(true)
    -- self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-10)
    -- self.bgLayer:setBSwallowsTouches(true)

    self:initUpLayer()
    self:initCityLayer()

    local function refreshCityFunc(event,cityTb)
        local city=cityTb[self.cityId]
        -- print("self.cityId,city------->",self.cityId,city)
        if city then
            self:refreshTotalCity()
        end
    end
    self.refreshCityListener=refreshCityFunc
    eventDispatcher:addEventListener("ltzdz.refreshCity",refreshCityFunc)
    -- 刷新资源
    local function refreshResFunc(event,data)
       self:refreshResLb()
    end
    self.resChangedListener=refreshResFunc
    eventDispatcher:addEventListener("ltzdz.resChanged",refreshResFunc)

    local function checkAutoUpgradeHander(event,data)
       self:checkAutoUpgrade()
    end
    self.checkUpgradeListener=checkAutoUpgradeHander
    eventDispatcher:addEventListener("ltzdz.checkAutoUpgrade",checkAutoUpgradeHander)

    --如果是定级赛并且城市没有任何建筑，则引导城市建设教学
    if ltzdzVoApi:isQualifying()==true then
        if self.city and self.city.buildings and SizeOfTable(self.city.buildings)==0 then
            if otherGuideMgr:checkGuide(56)==false then
                otherGuideMgr:showGuide(56)
            end
        end
    end

    return self.bgLayer
end

function ltzdzCityDialog:initUpLayer()
    local function nilFunc()
    end
    local upLayer=LuaCCSprite:createWithSpriteFrameName("ltzdz_cityUpBg.png",nilFunc)
    upLayer:setTouchPriority(-(self.layerNum-1)*20-8)
    upLayer:setAnchorPoint(ccp(0.5,1))
    upLayer:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight))
    self.bgLayer:addChild(upLayer,1)
    print ("height ->",upLayer:getContentSize().height)

    local posY=upLayer:getContentSize().height-25
    local gems,metal,oil,reserve=0,0,0,(self.city.reserve or 0)
    local myinfo=ltzdzFightApi:getUserInfo()
    if myinfo then
        gems=myinfo.gems or 0
        metal=myinfo.metal or 0
        oil=myinfo.oil or 0
    end
    self.gemsLb=self:getResLb(1,upLayer,ccp(160,posY),gems)
    self.oilLb=self:getResLb(2,upLayer,ccp(280,posY),oil)
    self.metalLb=self:getResLb(3,upLayer,ccp(400,posY),metal)
    self.reserveLb=self:getResLb(4,upLayer,ccp(520,posY),reserve)

    local nameWidth=135
	local cityName=ltzdzCityVoApi:getCityName(self.cityId)
	local cityNameLb=GetTTFLabelWrap(cityName,22,CCSize(nameWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	cityNameLb:setPosition(nameWidth/2,posY)
	upLayer:addChild(cityNameLb)

    posY=25
    local rc,oc,mc=ltzdzCityVoApi:getCityCapacity(self.cityId)
	self.ocLb=self:getCapacityLb(1,upLayer,ccp(15,posY),oc)
	self.mcLb=self:getCapacityLb(2,upLayer,ccp(240,posY),mc)
	self.rcLb=self:getCapacityLb(3,upLayer,ccp(460,posY),rc)

    local supplyFlag=self.city.defTroops[5] or 0
	local function supplyHandler()
        local function supplyCallBack()
            self:pullCity()
            self:refreshAutoSupplyState()
        end
        local supplyFlag=self.city.defTroops[5] or 0
        if supplyFlag==1 then
            ltzdzFightApi:setTroopsSocket(supplyCallBack,2,0,self.cityId)
        else
            ltzdzFightApi:setTroopsSocket(supplyCallBack,2,1,self.cityId)
        end
	end
	self.supplyBox,self.unSupplyBox=self:getCheckBox(self.bgLayer,ccp(20,180),getlocal("ltzdz_autosupply_str"),200,supplyHandler)
    self:refreshAutoSupplyState()

	local function upgradeHandler()
		if self.city.upCount>0 then
            local function cancelAutoUpgrade()
                self.city.upCount=0
                self:refreshAutoUpgradeState()
            end
            ltzdzCityVoApi:ltzdzBuildingOperate({action=6,roomid=self.roomid,cid=self.cityId},cancelAutoUpgrade) --主基地升级
        else
            if self.selectLayer then
                self:closeSelectUpgradeNumLayer()
            else
                self:showSelectUpgradeNumLayer(self.bgLayer,ccp(G_VisibleSizeWidth-240,200))
            end
        end
	end
	self.upgradeBox,self.unUpgradeBox,self.upgradeLb=self:getCheckBox(self.bgLayer,ccp(G_VisibleSizeWidth-250,180),getlocal("ltzdz_autoupgrade_str"),200,upgradeHandler)
    self:refreshAutoUpgradeState()
end

--显示选择自动升级次数的页面
function ltzdzCityDialog:showSelectUpgradeNumLayer(target,pos)
    local fontSize,scale=22,0.8
    local warCfg=ltzdzVoApi:getWarCfg()

    local function touchLuaSpr()    
    end
    local selectLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    selectLayer:setAnchorPoint(ccp(0,0))
    selectLayer:setTouchPriority(-(self.layerNum-1)*20-13)
    local rect=CCSizeMake(300,(#warCfg.autoUpgradeCount)*60*scale+20)
    selectLayer:setContentSize(rect)
    selectLayer:setOpacity(180)
    selectLayer:setPosition(pos)
    target:addChild(selectLayer)
    self.selectLayer=selectLayer

    for k,num in pairs(warCfg.autoUpgradeCount) do
        local function selectHandler()
            self:closeSelectUpgradeNumLayer()
            local function selectAutoUpgrade()
                self:pullCity()
                self:refreshAutoUpgradeState()
                self:refreshAllBuilding()
            end
            ltzdzCityVoApi:ltzdzBuildingOperate({action=5,roomid=self.roomid,cid=self.cityId,num=num},selectAutoUpgrade) --主基地升级
        end
        local posX,posY=10,self.selectLayer:getContentSize().height-35-(k-1)*60*scale
        local str=getlocal("ltzdz_autoupgrade_numStr",{num})
        local selectBox,unSelectBox=self:getCheckBox(self.selectLayer,ccp(posX,posY),str,200,selectHandler)
    end
end

function ltzdzCityDialog:closeSelectUpgradeNumLayer()
    if self.selectLayer then
        self.selectLayer:removeFromParentAndCleanup(true)
        self.selectLayer=nil
    end
end

function ltzdzCityDialog:refreshAutoUpgradeState()
    if self.upgradeBox and self.unUpgradeBox and self.upgradeLb then
        if self.city.upCount>0 then
            self.upgradeBox:setVisible(true)
            self.unUpgradeBox:setVisible(false)
            self.upgradeLb:setString(getlocal("ltzdz_autoupgrade_str").."("..self.city.upCount..")")
        else
            self.upgradeBox:setVisible(false)
            self.unUpgradeBox:setVisible(true)
            self.upgradeLb:setString(getlocal("ltzdz_autoupgrade_str"))
        end
    end
end

function ltzdzCityDialog:refreshAutoSupplyState()
    if self.supplyBox and self.unSupplyBox then
        local supplyFlag=self.city.defTroops[5] or 0
        if supplyFlag==1 then --当前处于自动补充状态
            self.supplyBox:setVisible(true)
            self.unSupplyBox:setVisible(false)
        else
            self.supplyBox:setVisible(false)
            self.unSupplyBox:setVisible(true)
        end
    end
end

function ltzdzCityDialog:initCityLayer()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    local baseSp=CCSprite:create("public/ltzdz/ltzdzCityBg.jpg")
    if G_getIphoneType() == G_iphoneX then
        baseSp:setAnchorPoint(ccp(0.5,1))
        baseSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-100)
        baseSp:setScaleY((G_VisibleSizeHeight-100)/baseSp:getContentSize().height)
    else
        baseSp:setPosition(getCenterPoint(self.bgLayer))
    end
    self.bgLayer:addChild(baseSp)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

    local function showDefenseDialog()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        local function refreshTroops()
            self:refreshDefenseTanks()
        end
        ltzdzFightApi:showTroopDialog(self.layerNum+1,self.cityId,refreshTroops)
    end
    local tanksLayer=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),showDefenseDialog)
    tanksLayer:setContentSize(CCSizeMake(300,140))
    tanksLayer:setTouchPriority(-(self.layerNum-1)*20-12)
    tanksLayer:setOpacity(0)
    tanksLayer:setPosition(250,280)
    baseSp:addChild(tanksLayer)

    self.cityBg=baseSp

    local mbType=self.city.mbType--主基地类型
    local mbLv=self.city.mbLv--主基地等级
    local mbet=self.city.mbet --主基地升级结束时间
    local nameStr,descStr,buildPic=ltzdzCityVoApi:getBuildInfoByType(mbType)
    local function clickMainBuilding()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
    	local function upgradeHandler()
            local state=ltzdzCityVoApi:isCanUpgrade(self.city,mbType)
            if state~=1 then
                --state：1：可以升级，2：资源不足，3：已经升级到最大等级，4：正在升级
                self:showBuildingStateStr(state)
                do return end
            end
            local function upgradeCallBack()
                self:pullCity()
                self:refreshMainBuilding()
            end
            local args={action=1,roomid=self.roomid,cid=self.cityId,type=mbType}
            ltzdzCityVoApi:ltzdzBuildingOperate(args,upgradeCallBack) --主基地升级
        end
        local state=ltzdzCityVoApi:isCanUpgrade(self.city,mbType)
        if state==4 then --正在升级时打开使用道具加速的面板
            local stratagemId="t6"
            local strnameStr=ltzdzVoApi:getStratagemInfoById(stratagemId)
            ltzdzFightApi:showMarchAcc(self.layerNum+1,true,true,nil,getlocal("ltzdz_use_ploy"),nil,getlocal("ltzdz_use_acc_des2",{strnameStr,nameStr}),stratagemId,self.cityId)
            if otherGuideMgr.isGuiding and otherGuideMgr.curStep==64 then
                otherGuideMgr:endNewGuid()
            end
            do return end
        end
        local build={btype=self.city.mbType,lv=self.city.mbLv}
        ltzdzCityVoApi:showBuildingUpgradeOrRemoveDialog(build,self.layerNum+1,true,false,upgradeHandler)
    end
    local mainBuildSp=LuaCCSprite:createWithSpriteFrameName(buildPic,clickMainBuilding)
    mainBuildSp:setTouchPriority(-(self.layerNum-1)*20-12)
    mainBuildSp:setPosition(311.5,789.5)
    baseSp:addChild(mainBuildSp)

    otherGuideMgr:setGuideStepField(64,mainBuildSp)

    local mainNameLb=GetTTFLabel(nameStr..getlocal("fightLevel",{mbLv}),22)
    self.mainNameLb=mainNameLb
    local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),function () end)
    nameBg:setContentSize(CCSizeMake(mainNameLb:getContentSize().width+30,mainNameLb:getContentSize().height))
    nameBg:setPosition(mainBuildSp:getContentSize().width/2,35)
    nameBg:setOpacity(150)
    mainBuildSp:addChild(nameBg)
    mainNameLb:setPosition(getCenterPoint(nameBg))
    nameBg:addChild(mainNameLb)

    AddProgramTimer(mainBuildSp,ccp(mainBuildSp:getContentSize().width/2,mainBuildSp:getContentSize().height/2),21,22," ","res_progressbg.png","resyellow_progress.png",23,nil,nil,nil,nil,18)
    local timerSpriteLv=tolua.cast(mainBuildSp:getChildByTag(21),"CCProgressTimer")
    local timerSpriteBg=tolua.cast(mainBuildSp:getChildByTag(23),"CCSprite")
    local scaleX=100/timerSpriteLv:getContentSize().width
    local scaleY=20/timerSpriteLv:getContentSize().height
    timerSpriteLv:setScaleX(scaleX)
    timerSpriteLv:setScaleY(scaleY)
    timerSpriteBg:setScaleX(scaleX)
    timerSpriteBg:setScaleY(scaleY)
    local timeLb=tolua.cast(timerSpriteLv:getChildByTag(22),"CCLabelTTF")
    timeLb:setColor(G_ColorWhite)
    timeLb:setScaleX(1/scaleX)
    timeLb:setScaleY(1/scaleY)
    timerSpriteLv:setVisible(false)
    timerSpriteBg:setVisible(false)
    self.mainTimeSp={timerSpriteLv,timerSpriteBg,timeLb}
    if mbet and mbet>=base.serverTime then
        local lefttime=mbet-base.serverTime
        if lefttime>0 then
            local bcfg=ltzdzVoApi:getBuildingCfg()[mbType]
            local totaltime=bcfg.timeConsumeArr[mbLv+1] or 0
            local percent=0
            if totaltime==0 then
                percent=100
            else
                percent=100-(lefttime/totaltime)*100
            end
            timerSpriteLv:setVisible(true)
            timerSpriteBg:setVisible(true)
            timerSpriteLv:setPercentage(percent)
            local timeStr=GetTimeStr(lefttime)
            timeLb:setString(timeStr)
        end
    end

    local buildingCfg=ltzdzVoApi:getBuildingCfg()

    -- for k,v in pairs(landPosCfg) do
    --     print("ccp("..v.x..","..(1024-v.y)..")")
    -- end
    self.buildSpTb={}
    self.timeSpTb={}
    local step63Idx=1
    local buildCount=self.cityCfg.maxBldCount
    for i=1,buildCount do
        local bid="b"..i
    	local function clickBuilding()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            local bdata=self.city.buildings[bid]
            if bdata then --有建筑则显示升级或者移除的板子
                local btype=bdata[1]
                local blv=bdata[2]
                local function upgradeOrRemoveHandler(batchFlag,removeFlag)
                    local state=1
                    if removeFlag and removeFlag==true then
                    elseif batchFlag and batchFlag==true then
                        state=ltzdzCityVoApi:isCanUpgrade(self.city,btype)
                    else
                        state=ltzdzCityVoApi:isCanUpgrade(self.city,btype,bid)
                    end
                    if state~=1 then
                        self:showBuildingStateStr(state)
                        do return end
                    end
                    local function upgradeOrRemoveCallBack()
                        if batchFlag and batchFlag==true then
                            self:refreshAllBuilding()
                        else
                            self:refreshBuilding(bid,true)
                        end
                        if removeFlag and removeFlag==true then
                            self:pullCity()
                            self:refreshCapacityLb()
                        end
                    end
                    local args={}
                    if batchFlag and batchFlag==true then
                        args={action=4,roomid=self.roomid,cid=self.cityId,type=btype}
                    elseif removeFlag and removeFlag==true then
                        args={action=2,roomid=self.roomid,cid=self.cityId,type=btype,bid=bid}
                    else
                        args={action=1,roomid=self.roomid,cid=self.cityId,type=btype,bid=bid}
                    end
                    ltzdzCityVoApi:ltzdzBuildingOperate(args,upgradeOrRemoveCallBack)
                end
                local state=ltzdzCityVoApi:isCanUpgrade(self.city,btype,bid)
                if state==4 then --正在升级时打开使用道具加速的面板
                    local stratagemId="t5"
                    local strnameStr=ltzdzVoApi:getStratagemInfoById(stratagemId)
                    ltzdzFightApi:showMarchAcc(self.layerNum+1,true,true,nil,getlocal("ltzdz_use_ploy"),nil,getlocal("ltzdz_use_acc_des3",{strnameStr,nameStr}),stratagemId,self.cityId)
                    do return end
                end
                local build={btype=btype,lv=blv}
                ltzdzCityVoApi:showBuildingUpgradeOrRemoveDialog(build,self.layerNum+1,true,false,upgradeOrRemoveHandler)
            else --没有建筑的话就显示建造的板子
                local function buildHandler(btype,batchFlag)
                    local state=1
                    if batchFlag and batchFlag==true then
                        state=ltzdzCityVoApi:isCanBuild(self.city,btype)
                    else
                        state=ltzdzCityVoApi:isCanBuild(self.city,btype,bid)
                    end
                    if state~=1 then
                        self:showBuildingStateStr(state)
                        if otherGuideMgr.isGuiding and (otherGuideMgr.curStep==58 or otherGuideMgr.curStep==60 or otherGuideMgr.curStep==62) then
                            otherGuideMgr:toNextStep()
                        end
                        do return end
                    end
                    local function buildCallBack()
                        if batchFlag and batchFlag then
                            self:refreshAllBuilding()
                        else
                            self:refreshBuilding(bid,true)
                        end
                        if otherGuideMgr.isGuiding and (otherGuideMgr.curStep==58 or otherGuideMgr.curStep==60 or otherGuideMgr.curStep==62) then
                            otherGuideMgr:toNextStep()
                        end
                    end
                    local args={}
                    if batchFlag and batchFlag==true then
                        args={action=3,roomid=self.roomid,cid=self.cityId,type=btype}
                    else
                        args={action=1,roomid=self.roomid,cid=self.cityId,type=btype,bid=bid}
                    end
                    ltzdzCityVoApi:ltzdzBuildingOperate(args,buildCallBack)
                end
                ltzdzCityVoApi:showBuildingSelectDialog(self.layerNum+1,true,false,buildHandler)
                if otherGuideMgr.isGuiding and (otherGuideMgr.curStep==57 or otherGuideMgr.curStep==59 or otherGuideMgr.curStep==61) then
                    otherGuideMgr:toNextStep()
                end
            end
    	end

    	local buildSp=LuaCCSprite:createWithSpriteFrameName("di_kuai_normal.png",clickBuilding) --地块
        buildSp:setTouchPriority(-(self.layerNum-1)*20-12)
        buildSp:setOpacity(0)
    	baseSp:addChild(buildSp)
        self.buildSpTb[bid]=buildSp

        self:refreshBuilding(bid)
        --刷新城市防守部队
        self:refreshDefenseTanks()
        if i==4 then
            otherGuideMgr:setGuideStepField(57,buildSp)
        elseif i==8 then
            otherGuideMgr:setGuideStepField(59,buildSp)
        elseif i==10 then
            otherGuideMgr:setGuideStepField(61,buildSp)
        else
            otherGuideMgr:setGuideStepField(63,nil,nil,{buildSp,step63Idx})
            step63Idx=step63Idx+1
        end
    end
end

--刷新主基地
function ltzdzCityDialog:refreshMainBuilding()
    if self.mainNameLb and self.mainTimeSp then
        local mbType=self.city.mbType--主基地类型
        local mbLv=self.city.mbLv--主基地等级
        local mbet=self.city.mbet
        local timerSpriteLv=tolua.cast(self.mainTimeSp[1],"CCProgressTimer")
        local timerSpriteBg=tolua.cast(self.mainTimeSp[2],"CCSprite")
        local timeLb=tolua.cast(self.mainTimeSp[3],"CCLabelTTF")
        if timerSpriteBg and timerSpriteLv and timeLb then
            if mbet==nil or mbet==0 then
                timerSpriteLv:setVisible(false)
                timerSpriteBg:setVisible(false)
            end
            local nameStr,descStr,buildPic=ltzdzCityVoApi:getBuildInfoByType(mbType)
            self.mainNameLb:setString(nameStr..getlocal("fightLevel",{mbLv}))
        end
    end
end

--刷新城内所有的建筑
function ltzdzCityDialog:refreshAllBuilding()
    self:pullCity()
    if self.buildSpTb then
        for bid,v in pairs(self.buildSpTb) do
            self:refreshBuilding(bid)
        end
    end
end

--重新拉一下城市数据
function ltzdzCityDialog:pullCity()
    self.city=ltzdzCityVoApi:getCity(self.cityId) --城市数据
end

--刷新指定位置的建筑(bid:建筑id（在城市的位置），rtype：刷新的类型--》1：建造，2：升级，3：移除，pullFlag：是否重新拉一下城市数据)
function ltzdzCityDialog:refreshBuilding(bid,pullFlag)
    local landPosCfg={ccp(117.5,633),ccp(106.5,500),ccp(234.5,563),ccp(358.5,626),ccp(103.5,376),ccp(236.5,440),ccp(363.5,503),ccp(489.5,565),ccp(404.5,384),ccp(528.5,448)}
    local buildingPosCfg={ccp(115,658),ccp(104,526),ccp(232,589),ccp(356,651),ccp(101,401),ccp(234,465),ccp(360,528),ccp(487,591),ccp(401,409),ccp(526,473)}
    -- for k,v in pairs(buildingPosCfg) do
    --     print("ccp("..v.x..","..(1024-v.y)..")")
    -- end
    if pullFlag and pullFlag==true then
        self:pullCity()
    end
    local idx=tonumber(RemoveFirstChar(bid))
    local buildSp=tolua.cast(self.buildSpTb[bid],"LuaCCSprite")
    local nameBg=tolua.cast(buildSp:getChildByTag(101),"LuaCCScale9Sprite")
    local timerSpriteLv=tolua.cast(buildSp:getChildByTag(21),"CCProgressTimer")
    local timerSpriteBg=tolua.cast(buildSp:getChildByTag(23),"CCSprite")
    local bdata=self.city.buildings[bid]
    if bdata then
        local btype=bdata[1]
        local lv=bdata[2] or 0
        local et=bdata[3]
        local nameStr,descStr,buildPic,resPic=ltzdzCityVoApi:getBuildInfoByType(btype)
        local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(buildPic)
        if frame then
            buildSp:setDisplayFrame(frame)
            buildSp:setPosition(buildingPosCfg[idx])
            buildSp:setOpacity(255)
        end

        if nameBg then
            local lvLb=tolua.cast(nameBg:getChildByTag(99),"CCLabelTTF")
            if lvLb then
                lvLb:setString(getlocal("fightLevel",{lv}))
            end
        else
            local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),function () end)
            nameBg:setOpacity(150)
            nameBg:setTag(101)
            buildSp:addChild(nameBg)
            if resPic then
                local bgWidth=10
                local resIconSp=CCSprite:createWithSpriteFrameName(resPic)
                resIconSp:setAnchorPoint(ccp(0,0.5))
                local scale=30/resIconSp:getContentSize().height
                resIconSp:setScale(scale)
                nameBg:addChild(resIconSp)
                -- local nameLb=GetTTFLabel(nameStr,20)
                -- nameLb:setAnchorPoint(ccp(0,0.5))
                -- nameBg:addChild(nameLb)
                local lvLb=GetTTFLabel(getlocal("fightLevel",{lv}),20)
                lvLb:setAnchorPoint(ccp(0,0.5))
                lvLb:setTag(99)
                nameBg:addChild(lvLb)
                -- local bgWidth=20+resIconSp:getContentSize().width*scale+nameLb:getContentSize().width+lvLb:getContentSize().width
                local bgWidth=30+resIconSp:getContentSize().width*scale+lvLb:getContentSize().width
                nameBg:setContentSize(CCSizeMake(bgWidth,30))
                nameBg:setPosition(buildSp:getContentSize().width/2,35)
                resIconSp:setPosition(5,nameBg:getContentSize().height/2)
                -- nameLb:setPosition(resIconSp:getPositionX()+resIconSp:getContentSize().width*scale,resIconSp:getPositionY())
                -- lvLb:setPosition(nameLb:getPositionX()+nameLb:getContentSize().width,resIconSp:getPositionY())
                lvLb:setPosition(resIconSp:getPositionX()+resIconSp:getContentSize().width*scale+10,resIconSp:getPositionY())
            end
        end
        if et and et>=base.serverTime then
            local bcfg=ltzdzVoApi:getBuildingCfg()[btype]
            local lefttime=et-base.serverTime
            local totaltime=bcfg.timeConsumeArr[lv+1] or 0
            local percent=0
            if totaltime==0 then
                percent=100
            else
                percent=100-(lefttime/totaltime)*100
            end
            local timeLb
            if timerSpriteLv and timerSpriteBg then
                timeLb=timerSpriteLv:getChildByTag(22)
            else
                AddProgramTimer(buildSp,ccp(buildSp:getContentSize().width/2,buildSp:getContentSize().height/2),21,22," ","res_progressbg.png","resyellow_progress.png",23,nil,nil,nil,nil,18)
                timerSpriteLv=tolua.cast(buildSp:getChildByTag(21),"CCProgressTimer")
                timerSpriteBg=tolua.cast(buildSp:getChildByTag(23),"CCSprite")
                local scaleX=100/timerSpriteLv:getContentSize().width
                local scaleY=20/timerSpriteLv:getContentSize().height
                timerSpriteLv:setScaleX(scaleX)
                timerSpriteLv:setScaleY(scaleY)
                timerSpriteBg:setScaleX(scaleX)
                timerSpriteBg:setScaleY(scaleY)
                timeLb=tolua.cast(timerSpriteLv:getChildByTag(22),"CCLabelTTF")
                timeLb:setColor(G_ColorWhite)
                timeLb:setScaleX(1/scaleX)
                timeLb:setScaleY(1/scaleY)
                self.timeSpTb[bid]={timerSpriteLv,timeLb}
            end
            local timeStr=GetTimeStr(lefttime)
            if timerSpriteLv and timeLb then
                timerSpriteLv:setPercentage(percent)
                timeLb:setString(timeStr)
            end
        else
            if timerSpriteLv and timerSpriteBg then
                timerSpriteBg:removeFromParentAndCleanup(true)
                timerSpriteLv:removeFromParentAndCleanup(true)
                self.timeSpTb[bid]={}
            end
        end
    else
        local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("di_kuai_normal.png")
        if frame then
            buildSp:setDisplayFrame(frame)
            buildSp:setPosition(landPosCfg[idx])
            buildSp:setOpacity(0)
        end
        if nameBg then
            nameBg:removeFromParentAndCleanup(true)
        end
        if timerSpriteLv and timerSpriteBg then
            timerSpriteBg:removeFromParentAndCleanup(true)    
            timerSpriteLv:removeFromParentAndCleanup(true)
            self.timeSpTb[bid]={}    
        end
    end
end

function ltzdzCityDialog:refreshDefenseTanks()
    if self.cityBg==nil then
        do return end
    end
    if self.tankSpTb==nil then
        self.tankSpTb={}
    end

    local tankPosCfg={ccp(243.5,346.5),ccp(302.5,315.5),ccp(364.5,285.5),ccp(144.5,299),ccp(207,266),ccp(268.5,234)}
    local tankTb=ltzdzFightApi:getDefenceByCid(self.cityId)
    for i=1,6 do
        local tankSp=tolua.cast(self.tankSpTb[i],"CCSprite")
        local tank=tankTb[i]
        if tank and tank[1] then
            local tankId=tank[1]
            local num=tank[2]
            if tankSp then --判断指定位置是否有坦克
                if tonumber(tankId)==tonumber(tankSp:getTag()) then --坦克类型没有变，只需要刷新坦克数量
                    local numLb=tolua.cast(tankSp:getChildByTag(101),"CCLabelTTF")
                    if numLb then
                        numLb:setString(num)
                    end
                else
                    tankSp:removeFromParentAndCleanup(true)
                    tankSp=nil
                    self.tankSpTb[i]=nil
                end
            end
            if tankSp==nil then
                local function tankInfoHandler()
                end
                local skinId = ltzdzFightApi:getSkinIdByTankId(tankId)
                local tankSp=G_getTankPic(tankId,tankInfoHandler,tankId,true,skinId)
                tankSp:setPosition(tankPosCfg[i])
                tankSp:setScale(0.7)
                self.cityBg:addChild(tankSp)
                self.tankSpTb[i]=tankSp

                local function touchClick()
                end
                local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BattleTankNumBg.png",CCRect(5,5,1,1),touchClick)
                numBg:setContentSize(CCSizeMake(60,25))
                numBg:setPosition(tankSp:getContentSize().width/2,100)
                tankSp:addChild(numBg)
                local numLb=GetTTFLabel(num,22)
                numLb:setColor(G_ColorWhite)
                numLb:setTag(101)
                numLb:setPosition(numBg:getPosition())
                tankSp:addChild(numLb)

                if G_pickedList(tankId)~=tankId then
                    local pickedIcon=CCSprite:createWithSpriteFrameName("picked_icon1.png")
                    tankSp:addChild(pickedIcon)
                    pickedIcon:setPosition(tankSp:getContentSize().width*0.7,tankSp:getContentSize().height*0.5-20)
                end
            end
        else
            if tankSp then
                tankSp:removeFromParentAndCleanup(true)
                tankSp=nil        
                self.tankSpTb[i]=nil
            end
        end
    end
    self:refreshResLb()
end

function ltzdzCityDialog:getResLb(rtype,target,pos,num)
    if target==nil then
        return nil,nil
    end
    local function nilFunc()
    end
    local resbg=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdz_resBg.png",CCRect(10,10,10,10),nilFunc)
    resbg:setContentSize(CCSizeMake(100,30))
    resbg:setAnchorPoint(ccp(0,0.5))
    resbg:setPosition(pos)
    target:addChild(resbg)
    local iconStr=ltzdzVoApi:getResPicByType(rtype)
    local resIcon=CCSprite:createWithSpriteFrameName(iconStr)
    -- resIcon:setAnchorPoint(ccp(0,0.5))
    resIcon:setPosition(0,resbg:getContentSize().height/2)
    resbg:addChild(resIcon)
    local numLb=GetTTFLabel(num,20)
    numLb:setAnchorPoint(ccp(0,0.5))
    numLb:setPosition(resIcon:getPositionX()+resIcon:getContentSize().width/2,resIcon:getPositionY())
    resbg:addChild(numLb)

    return numLb,resbg
end

function ltzdzCityDialog:getCapacityLb(ctype,target,pos,capacity)
	if target==nil then
		return nil,nil
	end
    local zorder,fontSize=3,20
    local resNameCfg={getlocal("ltzdz_oil_capacity"),getlocal("ltzdz_metal_capacity"),getlocal("ltzdz_reserve_capacity")}
	local nameStr=resNameCfg[ctype] or ""
   	local nameLb=GetTTFLabelWrap(nameStr,fontSize,CCSize(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    nameLb:setAnchorPoint(ccp(0,0.5))
    -- nameLb:setColor(G_ColorGreen)
    nameLb:setPosition(pos)
    target:addChild(nameLb,zorder)
    local tmpNameLb=GetTTFLabel(nameStr,fontSize)
    local realW=tmpNameLb:getContentSize().width
    if realW>nameLb:getContentSize().width then
    	realW=nameLb:getContentSize().width
    end
	local capacityLb=GetTTFLabel(getlocal("ltzdz_capacity_unit",{capacity}),fontSize)
	capacityLb:setAnchorPoint(ccp(0,0.5))
	capacityLb:setPosition(nameLb:getPositionX()+realW,nameLb:getPositionY())
	target:addChild(capacityLb,zorder)

	return capacityLb
end

function ltzdzCityDialog:refreshResLb()
    if self.gemsLb and self.metalLb and self.oilLb and self.reserveLb and self.city then
        self:pullCity()
        local gems,metal,oil,reserve=0,0,0,(self.city.reserve or 0)
        local myinfo=ltzdzFightApi:getUserInfo()
        if myinfo then
            gems=myinfo.gems or 0
            metal=myinfo.metal or 0
            oil=myinfo.oil or 0
        end
        self.gemsLb:setString(gems)
        self.metalLb:setString(metal)
        self.oilLb:setString(oil)
        self.reserveLb:setString(reserve)
    end
end

function ltzdzCityDialog:refreshCapacityLb()
    if self.rcLb and self.ocLb and self.mcLb then
        local rc,oc,mc=ltzdzCityVoApi:getCityCapacity(self.cityId)
        self.rcLb:setString(getlocal("ltzdz_capacity_unit",{rc}))
        self.ocLb:setString(getlocal("ltzdz_capacity_unit",{oc}))
        self.mcLb:setString(getlocal("ltzdz_capacity_unit",{mc}))
    end
end

function ltzdzCityDialog:getCheckBox(target,pos,str,strW,callback)
    local zorder,fontSize,scale=3,22,0.8
	local function onSelect()
		if callback then
			callback()
		end
	end
    local background=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackFadeBar.png",CCRect(0,0,1,9),onSelect)
    background:setTouchPriority(-(self.layerNum-1)*20-13)
    background:setAnchorPoint(ccp(0,0.5))
    background:setPosition(pos)
    background:setOpacity(255*0.6)
    target:addChild(background,zorder)
    local function nilFunc()
    end
    local checkBox=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtn.png",nilFunc)
    checkBox:setVisible(false)
    checkBox:setScale(scale)
    background:addChild(checkBox,zorder)
    local uncheckBox=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",nilFunc)
    uncheckBox:setScale(scale)
    background:addChild(uncheckBox,zorder)

    local strLb=GetTTFLabelWrap(str,fontSize,CCSize(strW,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    strLb:setAnchorPoint(ccp(0,0.5))
    -- strLb:setColor(G_ColorYellowPro)
    background:addChild(strLb,zorder)
    local strLb2=GetTTFLabel(str,fontSize)
    local realW=strLb2:getContentSize().width
    if realW>strLb:getContentSize().width then
        realW=strLb:getContentSize().width
    end
    background:setContentSize(CCSizeMake(checkBox:getContentSize().width+realW+60,60*scale))
    checkBox:setPosition(ccp(checkBox:getContentSize().width/2,background:getContentSize().height/2))
    uncheckBox:setPosition(ccp(uncheckBox:getContentSize().width/2,background:getContentSize().height/2))
    strLb:setPosition(60*scale,background:getContentSize().height/2)

    return checkBox,uncheckBox,strLb
end

function ltzdzCityDialog:handleTankRes(removeFlag)
    local troops=ltzdzVoApi:getMyActiveTroops()
    for k,v in pairs(troops) do
        local tankId=tonumber(RemoveFirstChar(v))
        if tankId~=10001 and tankId~=50001 and tankId~=99999 and tankId~=99998 then
            local tid=GetTankOrderByTankId(tankId)
            local str="ship/newTank/t"..tid.."newTank.plist"
            local str2="ship/newTank/t"..tid.."newTank.png"
            if removeFlag and removeFlag==true then
                spriteController:removePlist(str)
                spriteController:removeTexture(str2)
            else
                spriteController:addPlist(str)
                spriteController:addTexture(str2)
            end
        end
    end
end

function ltzdzCityDialog:showBuildingStateStr(state)
    local promptStr=""
    if state==2 then
        promptStr=getlocal("backstage25111")
    elseif state==3 then
        promptStr=getlocal("backstage25108")
    elseif state==4 then
        promptStr=getlocal("backstage25110")
    end
    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),promptStr,30)
end

function ltzdzCityDialog:tick()
    if self.city==nil then
        do return end
    end
    local updoneFlag=false --是否有建筑升级完成的标识    
    local mbType=self.city.mbType--主基地类型
    local mbLv=self.city.mbLv--主基地等级
    local mbet=self.city.mbet --主基地升级结束时间
    if self.mainTimeSp and mbet and mbet>0 then
        -- print("mbet,base.serverTime------->",mbet,base.serverTime)
        local timerSpriteLv=tolua.cast(self.mainTimeSp[1],"CCProgressTimer")
        local timerSpriteBg=tolua.cast(self.mainTimeSp[2],"CCSprite")
        local timeLb=tolua.cast(self.mainTimeSp[3],"CCLabelTTF")
        if timerSpriteBg and timerSpriteLv and timeLb then
            local lefttime=mbet-base.serverTime
            if lefttime>0 then
                local bcfg=ltzdzVoApi:getBuildingCfg()[mbType]
                local totaltime=bcfg.timeConsumeArr[mbLv+1] or 0
                local percent=0
                if totaltime==0 then
                    percent=100
                else
                    percent=100-(lefttime/totaltime)*100
                end
                local timeStr=GetTimeStr(lefttime)
                timeLb:setString(timeStr)
                timerSpriteLv:setVisible(true)
                timerSpriteBg:setVisible(true)
                timerSpriteLv:setPercentage(percent)
            else
                -- print("mainbuilding upgrade finished!!!!!!!<<<<<<<<<-------",base.serverTime)
                updoneFlag=true
                timerSpriteLv:setVisible(false)
                timerSpriteBg:setVisible(false)
            end
        end
    end

	if self.timeSpTb then
        for bid,spTb in pairs(self.timeSpTb) do
            local timerSpriteLv=tolua.cast(spTb[1],"CCProgressTimer")
            local timeLb=tolua.cast(spTb[2],"CCLabelTTF")
            if timerSpriteLv and timeLb then
                local bdata=self.city.buildings[bid]
                if bdata then
                    local btype=bdata[1]
                    local lv=bdata[2] or 0
                    local et=bdata[3]
                    if et and et>0 then
                        -- print("bid,et,base.serverTime------->",bid,et,base.serverTime)
                        local bcfg=ltzdzVoApi:getBuildingCfg()[btype]
                        local lefttime=et-base.serverTime
                        if lefttime>0 then
                            local totaltime=bcfg.timeConsumeArr[lv+1] or 0
                            local percent=0
                            if totaltime==0 then
                                percent=100
                            else
                                percent=100-(lefttime/totaltime)*100
                            end
                            -- print("lefttime,totaltime,percent------->",lefttime,totaltime,percent)
                            timerSpriteLv:setPercentage(percent)
                            local timeStr=GetTimeStr(lefttime)
                            timeLb:setString(timeStr)
                        else  --该建筑升级完成
                            timerSpriteLv:setPercentage(100)
                            local timeStr=GetTimeStr(0)
                            timeLb:setString(timeStr)
                            -- print("resbuilding upgrade finished!!!!!!!--->>>>>bid,base.serverTime-->>>>",bid,base.serverTime)     
                            updoneFlag=true
                        end
                    end
                end
            end
        end
    end
    if updoneFlag==true then --有建筑升级完成，同步一下建筑状态
        -- print("self.syncFlag-------->>>>",self.syncFlag)
        if self.syncFlag==false then
            self.syncFlag=true
            self:syncCity()
        end
    end
end


function ltzdzCityDialog:refreshTotalCity()
    self:pullCity()
    local myUid=playerVoApi:getUid()
    -- print("myUid,self.city.oid--------->",myUid,self.city.oid)
    if (self.city and self.city.oid and tonumber(self.city.oid)~=tonumber(myUid)) or (self.city.oid==nil) then --如果该城市不是我自己了，则关闭城市
        if self.parent and self.parent.closeCity then
            -- print("----->>>>>closeCity")
            self.parent:closeCity()
        end
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage25115"),30)
        do return end
    end
    self:refreshMainBuilding()
    self:refreshAllBuilding()
    self:refreshCapacityLb()
    self:refreshAutoUpgradeState()
end

--同步城市数据
function ltzdzCityDialog:syncCity()
    local function syncCallBack()
        self.syncFlag=false
        self:refreshTotalCity()
    end
    ltzdzCityVoApi:syncCity(self.cityId,syncCallBack,1)
end

--检查是否可以自动更新建筑，如果可以拉取城市数据（解决资源补充后，有可以自动升级的建筑，但是没有自动升级，这时需要重新拉取服务器的数据）
function ltzdzCityDialog:checkAutoUpgrade()
    if self.city and self.city.buildings and self.city.upCount>0 then
        local upgradeFlag=false
        local myinfo=ltzdzFightApi:getUserInfo()
        local metal=myinfo.metal or 0
        for k,v in pairs(self.city.buildings) do
            local btype=v[1]
            local lv=v[2]
            local et=v[3] or 0
            local cfg=ltzdzVoApi:getBuildingCfg()[btype]    
            if cfg and et==0 and lv<cfg.maxLevel then --说明该建筑么有在升级
                local costRes=cfg.mineConsumeArr[lv+1] or 0
                if tonumber(costRes)<tonumber(metal) then
                    upgradeFlag=true
                    do break end
                end
            end
        end
        -- print("upgradeFlag--=-->",upgradeFlag)
        if upgradeFlag==true then --检测到有可以自动升级的建筑
            self:syncCity()
        end
    end
end

function ltzdzCityDialog:dispose()
	if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    self.cityCfg=nil
    self.city=nil
    self.gemsLb=nil
    self.metalLb=nil
    self.oilLb=nil
    self.reserveLb=nil
    self.rcLb=nil
    self.ocLb=nil
    self.mcLb=nil
    self.tankSpTb=nil
    self.buildSpTb={}
    self.timeSpTb={}
    self.parent=nil
    self.syncFlag=false
    spriteController:removePlist("public/ltzdz/ltzdzCityImages.plist")
    spriteController:removeTexture("public/ltzdz/ltzdzCityImages.png")
    self:handleTankRes(true) --释放坦克的资源
    if self.refreshCityListener then
        eventDispatcher:removeEventListener("ltzdz.refreshCity",self.refreshCityListener)
        self.refreshCityListener=nil
    end
    if self.resChangedListener then
        eventDispatcher:removeEventListener("ltzdz.resChanged",self.resChangedListener)
        self.resChangedListener=nil
    end
    if self.checkUpgradeListener then
        eventDispatcher:removeEventListener("ltzdz.checkAutoUpgrade",self.checkUpgradeListener)
        self.checkUpgradeListener=nil
    end
    ltzdzVoApi:addOrRemoveOpenDialog(2,"ltzdzCityDialog",self)
    CCTextureCache:sharedTextureCache():removeTextureForKey("public/ltzdz/ltzdzCityBg.jpg")
end