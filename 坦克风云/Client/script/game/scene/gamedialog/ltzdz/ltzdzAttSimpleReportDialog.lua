require "luascript/script/game/gamemodel/ltzdz/ltzdzFightApi"
require "luascript/script/game/gamemodel/ltzdz/ltzdzCityVoApi"
require "luascript/script/game/gamemodel/ltzdz/ltzdzReportVoApi"

ltzdzAttSimpleReportDialog=commonDialog:new()

function ltzdzAttSimpleReportDialog:new(reportVo)
    local nc={
        reportVo=reportVo,
    }
    setmetatable(nc,self)
    self.__index=self

    return nc
end

function ltzdzAttSimpleReportDialog:initTableView()
	-- self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-36))
	-- self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-98))
    self.panelLineBg:setVisible(false)
    if otherGuideMgr:checkGuide(71)==false then
        otherGuideCfg[71].otherRectTb=nil
    end
    self.guildItem=nil --战报教学的显示元素
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-190),nil)
    self.tv:setPosition(ccp(20,105))
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.tv:setMaxDisToBottomOrTop(0)
    self.bgLayer:addChild(self.tv)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)

    local priority=-(self.layerNum-1)*20-4
    local function detailHandler() --战报详情
        ltzdzReportVoApi:showReportDetailDialog(self.reportVo,self.layerNum+1)
    end
    G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth/2-150,60),{getlocal("ltzdz_detail_report"),25},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",detailHandler,0.8,priority)
    local function playReportHandler() --播放战报
        local attackerFlag=ltzdzReportVoApi:isAttacker(self.reportVo)
        local report=G_clone(self.reportVo.report)
        local flag=ltzdzReportVoApi:isAttackCityOrNpc(self.reportVo)
        if flag==1 then
            local cid=report.p[1][1]
            local cityName=ltzdzCityVoApi:getCityName(cid)
            report.p[1][1]=cityName --城市名字
            report.p[1][2]=1 --城市等级，野城默认等级是1
        elseif flag==2 then
            local npcId=report.p[1][1]
            local npcUser=ltzdzFightApi:getUserInfo(npcId)
            report.p[1][1]=npcUser.nickname
        end
        local data={data={report=report},isAttacker=attackerFlag,isReport=true}
        battleScene:initData(data)
    end
    local replayItem=G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth/2+150,60),{getlocal("ltzdz_report_play"),25},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",playReportHandler,0.8,priority)
    if self.reportVo.report==nil or SizeOfTable(self.reportVo.report)==0 then
        replayItem:setEnabled(false)
    end

    local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine3.png",CCRect(2,1,1,1),function () end)
    lineSp:setContentSize(CCSizeMake(G_VisibleSize.width-60,2))
    lineSp:setPosition(G_VisibleSize.width/2,110)
    self.bgLayer:addChild(lineSp)

    if otherGuideMgr:checkGuide(71)==false and ltzdzVoApi:isQualifying()==true then
        if self.guildItem then
            local x,y,width,height=G_getSpriteWorldPosAndSize(self.guildItem)
            y=y+G_VisibleSizeHeight
            otherGuideCfg[71].otherRectTb={{x,y,width+10,height+10}}
        end
        otherGuideMgr:showGuide(71)
    end
end

function ltzdzAttSimpleReportDialog:getCellHeight(idx)
    local cellHeight=0
    if idx==1 then
        cellHeight=140
    elseif idx==2 then
        cellHeight=ltzdzReportVoApi:getBothStrengthReportHeight()
    elseif idx==3 then
        cellHeight=400
    end
    return cellHeight
end

function ltzdzAttSimpleReportDialog:eventHandler(handler,fn,idx,cel)
    if self.reportVo==nil then
        do return end
    end

    if fn=="numberOfCellsInTableView" then
        return 3
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        local width,height=G_VisibleSizeWidth-40,self:getCellHeight(idx+1)
        tmpSize=CCSizeMake(width,height)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local cellWidth,cellHeight=G_VisibleSizeWidth-40,self:getCellHeight(idx+1)
        local attackerFlag=ltzdzReportVoApi:isAttacker(self.reportVo)
        if idx==0 then
            self:addTargetCityReport(cell,attackerFlag,cellWidth,cellHeight)
        elseif idx==1 then
            ltzdzReportVoApi:addBothStrengthReport(cell,self.reportVo,attackerFlag,cellWidth,cellHeight)
        elseif idx==2 then
            self:addLostTroopsReport(cell,attackerFlag,cellWidth,cellHeight)
        end

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function ltzdzAttSimpleReportDialog:addTargetCityReport(cell,isAttacker,cellWidth,cellHeight)
    local itemBg,bgPic
    local isVictory=self.reportVo.isVictory
    if isAttacker==true then
        if isVictory==1 then
            bgPic="public/ltzdz/ltzdzReportBg1.jpg"
        else
            bgPic="public/ltzdz/ltzdzReportBg2.jpg"
        end
    else
        if isVictory==0 then
            bgPic="public/ltzdz/ltzdzReportBg1.jpg"
        else
            bgPic="public/ltzdz/ltzdzReportBg2.jpg"
        end
    end    
    local function nilFunc()    
    end
    local itemBg=CCSprite:create(bgPic)
    -- itemBg:setTouchPriority(-(self.layerNum-1)*20-1)
    -- local rect=CCSizeMake(cellWidth,cellHeight)
    -- itemBg:setContentSize(rect)
    -- itemBg:setOpacity(180)
    itemBg:setPosition(cellWidth/2,cellHeight/2)
    cell:addChild(itemBg)

    local city=self.reportVo.city[2]
    if city then
        local cid,level=city[1],city[2]
        local pic=ltzdzFightApi:getCityPicByCid(cid,level)

        local cityWidth,fontSize=181,22
        local targetCitySp=CCSprite:createWithSpriteFrameName(pic)
        targetCitySp:setScale(cityWidth/targetCitySp:getContentSize().width)
        targetCitySp:setPosition(targetCitySp:getContentSize().width*targetCitySp:getScale()/2+10,cellHeight/2)
        cell:addChild(targetCitySp)

        local nameStr=ltzdzCityVoApi:getCityName(cid)
        nameStr=nameStr..getlocal("fightLevel",{level})
        local nameLb=GetTTFLabelWrap(nameStr,fontSize,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        nameLb:setColor(G_ColorYellowPro)
        local tempLb=GetTTFLabel(nameStr,fontSize)
        local realW=tempLb:getContentSize().width
        if realW>nameLb:getContentSize().width then
            realW=nameLb:getContentSize().width
        end

        local nameBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),nilFunc)
        nameBg:setContentSize(CCSizeMake(realW,nameLb:getContentSize().height))
        nameBg:setPosition(targetCitySp:getContentSize().width/2,0)
        nameBg:setScale(1/targetCitySp:getScale())
        targetCitySp:addChild(nameBg)
        nameLb:setPosition(getCenterPoint(nameBg))
        nameBg:addChild(nameLb)

        local reportNameStr,resultStr,resultColor,lostReserve="","",G_ColorWhite,nil --战报名称，战斗结果，损失的预备役
        if isAttacker==true then
            reportNameStr=getlocal("RankScene_attack")..getlocal("email_report")
            if isVictory==1 then
                resultStr=getlocal("serverwarteam_report_fight_win")
                resultColor=G_ColorGreen
            else
                resultStr=getlocal("serverwarteam_report_fight_fail")
                resultColor=G_ColorRed
            end
        else
            reportNameStr=getlocal("fight_content_defende_type")..getlocal("email_report")
            if isVictory==1 then
                resultStr=getlocal("serverwarteam_report_defend_fail")
                resultColor=G_ColorRed
                lostReserve=self.reportVo.reserve or 0 --防守方失败了会有预备役损失
            else
                resultStr=getlocal("serverwarteam_report_defend_win")
                resultColor=G_ColorGreen
            end
        end
        local reportNameLb=GetTTFLabelWrap(reportNameStr,fontSize,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
        reportNameLb:setAnchorPoint(ccp(0,0.5))
        reportNameLb:setPosition(250,cellHeight-reportNameLb:getContentSize().height/2-10)
        reportNameLb:setColor(G_ColorYellowPro)
        cell:addChild(reportNameLb)

        local resultLb=GetTTFLabelWrap(resultStr,fontSize,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        resultLb:setAnchorPoint(ccp(0,0.5))
        resultLb:setPosition(250,reportNameLb:getPositionY()-reportNameLb:getContentSize().height/2-resultLb:getContentSize().height/2-10)
        resultLb:setColor(resultColor)
        cell:addChild(resultLb)

        if lostReserve then
            local lostLb=GetTTFLabelWrap(getlocal("ltzdz_lost_reserve")..lostReserve,fontSize,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            lostLb:setAnchorPoint(ccp(0,0.5))
            lostLb:setPosition(250,resultLb:getPositionY()-resultLb:getContentSize().height/2-lostLb:getContentSize().height/2-10)
            lostLb:setColor(G_ColorRed)
            cell:addChild(lostLb)
            self.guildItem=lostLb
        end
        if isAttacker==true then
            local dmgStr,color
            if self.reportVo.dmg and tonumber(self.reportVo.dmg)>0 then --有城防伤害
                local city=self.reportVo.city[2]
                local cid=city[1]
                local nameStr=ltzdzCityVoApi:getCityName(cid)
                dmgStr=getlocal("ltzdz_dmg_str1",{getlocal("ltzdz_city_defense",{nameStr}),FormatNumber(self.reportVo.dmg)})
                color=G_ColorRed
            elseif self.reportVo.tank and self.reportVo.tank.d and SizeOfTable(self.reportVo.tank.d)==0 then --如果dmg为0 而且防守方没有坦克，说明没有收到任何的抵抗
                dmgStr=getlocal("ltzdz_dmg_str2")
                color=G_ColorWhite
            end
            if dmgStr and color then
                local dmgStrLb=GetTTFLabelWrap(dmgStr,fontSize,CCSizeMake(cellWidth-250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                dmgStrLb:setAnchorPoint(ccp(0,0.5))
                dmgStrLb:setPosition(250,resultLb:getPositionY()-resultLb:getContentSize().height/2-dmgStrLb:getContentSize().height/2-10)
                dmgStrLb:setColor(color)
                cell:addChild(dmgStrLb)
                self.guildItem=dmgStrLb
            end
        end
        local timeLb=GetTTFLabel(G_getDataTimeStr(self.reportVo.time),fontSize)
        timeLb:setAnchorPoint(ccp(1,0.5))
        timeLb:setPosition(cellWidth-5,cellHeight-timeLb:getContentSize().height/2-10)
        cell:addChild(timeLb)
    end
end

function ltzdzAttSimpleReportDialog:addLostTroopsReport(cell,isAttacker,cellWidth,cellHeight)
    local function nilFunc()    
    end
    local itemBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),nilFunc)
    itemBg:setTouchPriority(-(self.layerNum-1)*20-1)
    itemBg:setOpacity(0)
    local rect=CCSizeMake(cellWidth,cellHeight)
    itemBg:setContentSize(rect)
    itemBg:setPosition(cellWidth/2,cellHeight/2)
    cell:addChild(itemBg)

    local myTankNum,myMaxNum,myLost,enemyTankNum,enemyMaxNum,enemyLost=0,0,0,0,0,0
    local myTank,myLostShip,enemyTank,enemyLostShip,mytskinList,enemytskinList
    if isAttacker==true then
        myTank=self.reportVo.tank.a
        enemyTank=self.reportVo.tank.d
        myLostShip=self.reportVo.destroy.a
        enemyLostShip=self.reportVo.destroy.d
        mytskinList=self.reportVo.tskinList[1] or {}
        enemytskinList=self.reportVo.tskinList[2] or {}
    else
        myTank=self.reportVo.tank.d
        enemyTank=self.reportVo.tank.a
        myLostShip=self.reportVo.destroy.d
        enemyLostShip=self.reportVo.destroy.a
        mytskinList=self.reportVo.tskinList[2] or {}
        enemytskinList=self.reportVo.tskinList[1] or {}
    end
    --计算双方拥有的坦克数量和损失的坦克数量
    for k,v in pairs(myLostShip) do
        local tankId,lost=(v[1] or 0),(v[2] or 0)
        myLost=myLost+lost
    end
    for k,v in pairs(myTank) do
        myMaxNum=myMaxNum+tonumber(v)
    end
    myTankNum=myMaxNum-myLost
    for k,v in pairs(enemyLostShip) do
        local tankId,lost=(v[1] or 0),(v[2] or 0)
        enemyLost=enemyLost+lost
    end
    for k,v in pairs(enemyTank) do
        enemyMaxNum=enemyMaxNum+tonumber(v)
    end
    enemyTankNum=enemyMaxNum-enemyLost

    local showTb={{myTankNum,myMaxNum,myLost,myLostShip,mytskinList},{enemyTankNum,enemyMaxNum,enemyLost,enemyLostShip,enemytskinList}}
    for i=1,2 do
        local posX=40+(i-1)*305
        local tankNum,maxNum,lost=showTb[i][1],showTb[i][2],showTb[i][3]
        local armyLb=GetTTFLabel(getlocal("ltzdz_army"),20)
        armyLb:setAnchorPoint(ccp(0,0.5))
        armyLb:setPosition(posX,cellHeight-armyLb:getContentSize().height/2-5)
        cell:addChild(armyLb)
        local percent=0
        if maxNum>0 then
            percent=(tankNum/maxNum)*100
        end
        local barTag,valueTag,barBgTag=i*1000+1,i*1000+2,i*1000+3
        AddProgramTimer(cell,ccp(armyLb:getPositionX()+armyLb:getContentSize().width,armyLb:getPositionY()),barTag,valueTag," ","res_progressbg.png","resyellow_progress.png",barBgTag,nil,nil,nil,nil,20)
        local barSp=cell:getChildByTag(barTag)
        barSp=tolua.cast(barSp,"CCProgressTimer")
        local scaleX=150/barSp:getContentSize().width
        local scaleY=25/barSp:getContentSize().height
        barSp:setScaleX(scaleX)
        barSp:setScaleY(scaleY)
        barSp:setAnchorPoint(ccp(0,0.5))
        barSp:setPosition(armyLb:getPositionX()+armyLb:getContentSize().width,armyLb:getPositionY())
        barSp:setPercentage(percent)
        local barBg=tolua.cast(cell:getChildByTag(barBgTag),"CCSprite")
        barBg:setScaleX(scaleX)
        barBg:setScaleY(scaleY)
        barBg:setAnchorPoint(ccp(0,0.5))
        barBg:setPosition(barSp:getPosition())

        local valueLb=barSp:getChildByTag(valueTag)
        valueLb=tolua.cast(valueLb,"CCLabelTTF")
        valueLb:setColor(G_ColorWhite)
        valueLb:setScaleX(1/scaleX)
        valueLb:setScaleY(1/scaleY)
        valueLb:setString(tankNum.."/"..maxNum)

        local shipLostLb=GetTTFLabelWrap(getlocal("ltzdz_army_lost",{lost}),20,CCSizeMake(200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        shipLostLb:setAnchorPoint(ccp(0,0.5))
        shipLostLb:setPosition(posX,armyLb:getPositionY()-armyLb:getContentSize().height/2-shipLostLb:getContentSize().height/2-10)
        -- shipLostLb:setColor(G_ColorYellowPro)
        cell:addChild(shipLostLb)

        local firstPosX,firstPosY=(cellWidth/2-100),shipLostLb:getPositionY()-shipLostLb:getContentSize().height/2-10
        if i==2 then
            firstPosX=cellWidth/2+100
        end
        local iconSize=100
        local lostShip=showTb[i][4]
        local tskinTb = showTb[i][5] or {}
        for j=1,6 do
            local posX,posY=0,firstPosY-iconSize/2-math.floor((j-1)%3)*110
            if i==1 then
                posX=firstPosX-math.floor((j-1)/3)*110
            else
                posX=firstPosX+math.floor((j-1)/3)*110
            end
            local tankSp
            local tank=lostShip[j]
            if tank and tank[1] and tank[2] then
                local tankId,lost=tank[1],tank[2]
                local tid=tonumber(RemoveFirstChar(tankId))
                local cfg=tankCfg[tid]
                local skinId = tskinTb[tankSkinVoApi:convertTankId(tankId)]
                tankSp=tankVoApi:getTankIconSp(tankId,skinId,nil,false) --CCSprite:createWithSpriteFrameName(cfg.icon)
                local lostBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
                lostBg:setAnchorPoint(ccp(0.5,0))
                lostBg:setContentSize(CCSizeMake(tankSp:getContentSize().width,36))
                lostBg:setPosition(tankSp:getContentSize().width/2,5)
                tankSp:addChild(lostBg)

                local lostLb=GetTTFLabel("-"..lost,25)
                lostLb:setPosition(getCenterPoint(lostBg))
                lostLb:setColor(G_ColorRed)
                lostBg:addChild(lostLb)

                if G_pickedList(tid)~=tid then
                    local pickedIcon=CCSprite:createWithSpriteFrameName("picked_icon1.png")
                    tankSp:addChild(pickedIcon)
                    pickedIcon:setPosition(tankSp:getContentSize().width*0.7,50)
                end
            else
                tankSp=CCSprite:createWithSpriteFrameName("tankShadeIcon.png")
            end
            tankSp:setScale(iconSize/tankSp:getContentSize().width)
            tankSp:setPosition(posX,posY)
            cell:addChild(tankSp)
        end
    end
end

function ltzdzAttSimpleReportDialog:dispose()
    self.reportVo=nil
end