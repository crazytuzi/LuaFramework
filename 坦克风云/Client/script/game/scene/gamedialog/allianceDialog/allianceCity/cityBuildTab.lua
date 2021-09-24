cityBuildTab={}

function cityBuildTab:new()
    local nc={}
    setmetatable(nc, self)
    self.__index=self

    return nc
end

function cityBuildTab:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self.expandFlagTb={false,true}
    self.refreshIdx=0
    self.rtick=0
    self.cityVo=allianceCityVoApi:getAllianceCity()
    self.mydef=allianceCityVoApi:getMyDef()
    self.defState=0

    local myAlliance=allianceVoApi:getSelfAlliance()
    local function touchTip()
        allianceCityVoApi:showHelpDialog(self.layerNum+1)
    end
    G_addMenuInfo(self.bgLayer,self.layerNum,ccp(G_VisibleSizeWidth-50,G_VisibleSizeHeight-170-28),nil,nil,1,nil,touchTip,true)

    local addH=0
    if G_isIphone5()==true then
        addH=-30
    end
    local kuangWidth,kuangHeight=212,212
    local kuangSp=G_getThreePointBg(CCSizeMake(kuangWidth,kuangHeight),function () end,ccp(0,1),ccp(20,G_VisibleSizeHeight-170+addH),self.bgLayer)

    local mcoords=allianceCityVoApi:getCityXY() --获取主城坐标
    local function focus()
        activityAndNoteDialog:closeAllDialog()
        mainUI:changeToWorld(mcoords,8)
    end

    local citySp=allianceCityVoApi:getAllianceCityIcon(focus)
    citySp:setTouchPriority(-(self.layerNum-1)*20-4)
    citySp:setPosition(kuangWidth/2,kuangHeight/2+15)
    citySp:setScale(0.8)
    kuangSp:addChild(citySp)

    local coordsSp=CCSprite:createWithSpriteFrameName("acYijizaitan_dingwei.png")
    coordsSp:setAnchorPoint(ccp(0,0.5))
    coordsSp:setPosition(20,25)
    coordsSp:setScale(0.6)
    kuangSp:addChild(coordsSp)
    local coordinateLb=G_getCoordinateLb(kuangSp,mcoords,20,focus,-(self.layerNum-1)*20-3)
    coordinateLb:setAnchorPoint(ccp(0,0.5))
    coordinateLb:setPosition(60,coordsSp:getPositionY())

    local leftTextPosX=260
    local cityLvLb=GetTTFLabelWrap(getlocal("ltzdz_city_level",{allianceCityVoApi:getAllianceCityLv()}),24,CCSizeMake(280,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    cityLvLb:setAnchorPoint(ccp(0,0.5))
    cityLvLb:setPosition(leftTextPosX,G_VisibleSizeHeight-170-cityLvLb:getContentSize().height/2-20+addH)
    -- cityLvLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(cityLvLb)

    local function createResLb(reslbStr,resPic,valueStr,pos)
        local resSp=CCSprite:createWithSpriteFrameName(resPic)
        resSp:setAnchorPoint(ccp(0,0.5))
        resSp:setPosition(pos)
        local scale=32/resSp:getContentSize().width
        resSp:setScale(scale)
        self.bgLayer:addChild(resSp)

        local resLb=GetTTFLabelWrap(reslbStr.." "..valueStr,24,CCSizeMake(240,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        resLb:setAnchorPoint(ccp(0,0.5))
        resLb:setPosition(pos.x + 40,pos.y)
        self.bgLayer:addChild(resLb)
        return resLb
    end

    local priority=-(self.layerNum-1)*20-5
    local spaceY=-30
    local crPic=allianceCityVoApi:getCrPic()
    local crValueLb=createResLb(getlocal("ownAllianceCr"),crPic,FormatNumber(self.cityVo.cr),ccp(leftTextPosX,cityLvLb:getPositionY()-cityLvLb:getContentSize().height/2+spaceY))

    --维护
    local mainCost,addCost=allianceCityVoApi:getMaintainCost()
    local maintainLb=createResLb(getlocal("maintainCostStr"),crPic,getlocal("hourSpeed2",{FormatNumber(mainCost-addCost),math.ceil(allianceCityCfg.mainTime/60)}),ccp(leftTextPosX,crValueLb:getPositionY()-crValueLb:getContentSize().height/2+spaceY))
    local addMaintainLb=GetTTFLabel("+"..addCost,24)
    addMaintainLb:setAnchorPoint(ccp(0,0.5))
    addMaintainLb:setPosition(maintainLb:getPositionX()+maintainLb:getContentSize().width+10,maintainLb:getPositionY())
    addMaintainLb:setColor(G_ColorGreen)
    self.bgLayer:addChild(addMaintainLb)
    if addCost<=0 then
        addMaintainLb:setVisible(false)
    end

    local crystal,crystalLimit=allianceCityVoApi:getCrystal()
    local crystalVauleLb=createResLb(getlocal("ownCrystal"),"IconCrystal-.png",getlocal("curProgressStr",{FormatNumber(crystal),FormatNumber(crystalLimit)}),ccp(leftTextPosX,maintainLb:getPositionY()-maintainLb:getContentSize().height/2+spaceY))
    local function addCrystalHandler()
        local downFlag=allianceCityVoApi:isCityDown()
        if downFlag==false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26003"),28)
            do return end
        end
        local flag=allianceCityVoApi:isPrivilegeEnough()
        if flag==false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage8008"),28)
            do return end
        end
        local crystal,crystalLimit=allianceCityVoApi:getCrystal()
        if crystal>=crystalLimit then --已达上限
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("addCrystalPromptStr2"),28)
            do return end
        end
        local cityLv=allianceCityVoApi:getAllianceCityLv()
        if allianceCityCfg.city[cityLv]==nil then
            do return end
        end
        local cost=allianceCityCfg.city[cityLv].giveOne
        local function realAddCrystal()
            if cost>self.cityVo.cr then --稀土不足
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26008"),28)
                do return end
            end
            local function addCallBack()
                self:refreshLbs()
            end
            allianceCityVoApi:addCrystal(addCallBack)
        end
        local desInfo={25,G_ColorYellowPro,kCCTextAlignmentCenter}    
        G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("addCrystalPromptStr",{cost}),false,realAddCrystal,nil,nil,desInfo)
    end
    local addBtn=G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth-80,crystalVauleLb:getPositionY()),nil,"newAddBtn.png","newAddBtn.png","newAddBtn.png",addCrystalHandler,1,priority)
    self.crValueLb=crValueLb
    self.maintainValueLb=maintainLb
    self.addMaintainLb=addMaintainLb
    self.crystalVauleLb=crystalVauleLb
    self:refreshLbs()
    self:updateDefList()

    local btnScale=180/205
    local function defCityHandler()
        local downFlag=allianceCityVoApi:isCityDown()
        if downFlag==false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26003"),28)
            do return end
        end
        if self.mydef then --有部队正在驻防
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("hasDefCityTroops"),28)
            do return end
        end
        local mcoords=allianceCityVoApi:getCityXY()
        require "luascript/script/game/scene/gamedialog/warDialog/tankAttackDialog"
        local td=tankAttackDialog:new(8,{type=8,x=mcoords.x,y=mcoords.y,allianceName=myAlliance.name,isDef=myAlliance.aid,oid=myAlliance.aid},4)
        local tbArr={getlocal("AEFFighting"),getlocal("dispatchCard"),getlocal("repair")}
        local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("AEFFighting"),true,7)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    self.defBtn=G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth-130,60),{getlocal("city_garrison"),25},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",defCityHandler,btnScale,priority)

    local function defSpeedHandler()
        if self.mydef==nil then
            do return end
        end
        local function cronBack()
            local function cronAttackCallBack(fn,data)
                local retTb=G_Json.decode(tostring(data))
                if base:checkServerData(data)==true then
                    self:refreshMyDefSlot()
                    if(self.mydef.targetid[1] and self.mydef.targetid[2])then
                        eventDispatcher:dispatchEvent("worldScene.mineChange",{{x=self.mydef.targetid[1],y=self.mydef.targetid[2]}})
                    end
                    if base.heroSwitch==1 then
                        --请求英雄数据
                        local function heroGetlistHandler(fn,data)
                            local ret,sData=base:checkServerData(data)
                            if ret==true then
                                if base.he==1 and sData and sData.data and sData.data.equip and heroEquipVoApi then
                                    heroEquipVoApi:formatData(sData.data.equip)
                                    heroEquipVoApi.ifNeedSendRequest=true
                                end
                            end
                        end
                        socketHelper:heroGetlist(heroGetlistHandler)
                    end
                end
            end
            local cronidSend=self.mydef.slotId
            local targetSend=self.mydef.targetid
            local attackerSend=playerVoApi:getUid()
            socketHelper:cronAttack(cronidSend,targetSend,attackerSend,1,cronAttackCallBack)
        end
        local lefttime=self.mydef.dist-base.serverTime
        if lefttime>=0 then
            local needGemsNum=TimeToGems(lefttime)
            local needGems=getlocal("speedUp",{needGemsNum})
            if needGemsNum>playerVoApi:getGems() then --金币不足
                GemsNotEnoughDialog(nil,nil,needGemsNum-playerVoApi:getGems(),self.layerNum+1,needGemsNum)
            else
                local desInfo={25,G_ColorWhite,kCCTextAlignmentCenter}
                G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),needGems,nil,cronBack,nil,nil,desInfo)
            end
         end
    end
    self.defSpeedBtn=G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth-130,60),{getlocal("accelerateBuild")..getlocal("alienMines_march"),25},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",defSpeedHandler,btnScale,priority)

    local function backHandler()
        if self.mydef==nil then
            do return end
        end
        local function realBackTroops()
            local function serverBack(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    allianceCityVoApi:updateData(sData.data,true)
                    self:refresh()
                    local selfAlliance=allianceVoApi:getSelfAlliance()
                    if selfAlliance then
                        local cityVo=allianceCityVoApi:getAllianceCity()
                        local aid=selfAlliance.aid
                        local prams={uid=playerVoApi:getUid(),alliancecity=cityVo,subtype=1}
                        chatVoApi:sendUpdateMessage(49,prams,aid+1)
                    end
                end
            end
            socketHelper:troopBack(self.mydef.slotId,serverBack,nil,1)
        end
        local desInfo={25,G_ColorWhite,kCCTextAlignmentCenter}
        G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("backDefCityConfirmStr"),nil,realBackTroops,nil,nil,desInfo)
    end
    self.backBtn=G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth-130,60),{getlocal("coverFleetBack"),25},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",backHandler,btnScale,priority)

    local function backSpeedHandler()
        if self.mydef==nil then
            do return end
        end
        local function speedBack()
            local function troopBackSpeedupCallBack(fn,data)
                local retTb=G_Json.decode(tostring(data))
                if base:checkServerData(data)==true then
                    self.mydef=nil
                    self:removeMyDefSlot()
                    self:refreshDefButtonState()
                end
            end
            -- print("self.mydef.slotId------>>",self.mydef.slotId)
            socketHelper:troopBackSpeedup(self.mydef.slotId,troopBackSpeedupCallBack)
        end
        local lefttime=self.mydef.bs-base.serverTime
        if lefttime>=0 then
            local needGemsNum=TimeToGems(lefttime)
            local needGems=getlocal("speedUp",{needGemsNum})
            if needGemsNum>playerVoApi:getGems() then --金币不足
                GemsNotEnoughDialog(nil,nil,needGemsNum-playerVoApi:getGems(),self.layerNum+1,needGemsNum)
            else
                local desInfo={25,G_ColorWhite,kCCTextAlignmentCenter}
                G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),needGems,nil,speedBack,nil,nil,desInfo)
            end
        end
    end
    self.troopsBackSpeedBtn=G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth-130,60),{getlocal("accelerateBuild")..getlocal("coverFleetBack"),25},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",backSpeedHandler,btnScale,priority)

    self:refreshMyDefSlot()
    self:refreshDefButtonState()

    self:updateCellHeight()
    self:initTableView()

    local function refreshCity(event,data)
        self:refresh()
    end
    self.refreshCityListener=refreshCity
    eventDispatcher:addEventListener("alliancecity.refreshCity",refreshCity)

    return self.bgLayer
end

--添加驻防队列显示
function cityBuildTab:addMyDefSlot()
    if self.slotTimerSp==nil and self.mydef then
        local slotTimerSp
        if self.mydef.isGather==5 and self.mydef.isDef>0 and self.mydef.bs==nil then --驻防中
            slotTimerSp=AddProgramTimer(self.bgLayer,ccp(20,60),9,12,"","res_progressbg.png","resyellow_progress.png",11)
        else
            slotTimerSp=AddProgramTimer(self.bgLayer,ccp(20,60),9,12,"","TeamTravelBarBg.png","TeamTravelBar.png",11)
        end
        local slotTimerBg=tolua.cast(self.bgLayer:getChildByTag(11),"CCSprite")
        local lbPer=tolua.cast(slotTimerSp:getChildByTag(12),"CCLabelTTF")
        local scaleX=350/slotTimerSp:getContentSize().width
        local scaleY=40/slotTimerSp:getContentSize().height
        slotTimerSp:setAnchorPoint(ccp(0,0.5))
        slotTimerBg:setAnchorPoint(ccp(0,0.5))
        slotTimerSp:setScaleX(scaleX)
        slotTimerSp:setScaleY(scaleY)
        slotTimerBg:setScaleX(scaleX)
        slotTimerBg:setScaleY(scaleY)
        lbPer:setScaleX(1/scaleX)
        lbPer:setScaleY(1/scaleY)
        self.slotTimerSp=slotTimerSp
        self.slotTimerBg=slotTimerBg
    end
end

function cityBuildTab:removeMyDefSlot()
    if self.slotTimerSp then
        self.slotTimerSp:removeFromParentAndCleanup(true)
        self.slotTimerSp=nil
    end
    if self.slotTimerBg then
        self.slotTimerBg:removeFromParentAndCleanup(true)
        self.slotTimerBg=nil
    end
end

function cityBuildTab:hideMyDefSlot()
    if self.slotTimerSp then
        self.slotTimerSp:setVisible(false)
    end
    if self.slotTimerBg then
        self.slotTimerBg:setVisible(false)
    end
end

function cityBuildTab:refreshMyDefSlot()
    if self.mydef then --驻防部队返回，刷新一下驻防信息
        if self.mydef.isGather==0 and self.mydef.isDef>0 and self.mydef.bs==nil then --驻防行军中
            self.rtick=0
            if self.defState~=1 then
                self:removeMyDefSlot()
                self:addMyDefSlot()
            end
            self.defState=1
            if self.slotTimerSp then
                local totaltime=self.mydef.dist-self.mydef.st --航行
                local lefttime=self.mydef.dist-base.serverTime
                local lbPer=tolua.cast(self.slotTimerSp:getChildByTag(12),"CCLabelTTF")
                lbPer:setString(getlocal("attckarrivade",{GetTimeStr(lefttime)}))
                local per=(totaltime-lefttime)/totaltime*100
                self.slotTimerSp:setPercentage(per)
                if lefttime<=0 then
                    self:hideMyDefSlot()
                end
            end
        elseif self.mydef.isGather==5 and self.mydef.isDef>0 and self.mydef.bs==nil then --驻防中
            if self.defState~=2 then
                self:removeMyDefSlot()
                self:addMyDefSlot()
            end
            self.defState=2
            if self.rtick==0 then
                self:refreshDefRewards()
            end
            if self.rtick>=1 then
                self.rtick=0
            else
                self.rtick=self.rtick+1
            end
        elseif self.mydef.isGather==6 and self.mydef.isDef>0 and self.mydef.bs~=nil then --驻防部队返回中
            self.rtick=0
            if self.defState~=3 then
                self:removeMyDefSlot()
                self:addMyDefSlot()
            end
            self.defState=3
            if self.slotTimerSp then
                local lbPer=tolua.cast(self.slotTimerSp:getChildByTag(12),"CCLabelTTF")
                local totaltime=self.mydef.bs-self.mydef.st --返回
                local lefttime=self.mydef.bs-base.serverTime
                lbPer:setString(getlocal("returnarrivade",{GetTimeStr(lefttime)}))
                local per=(totaltime-lefttime)/totaltime*100
                self.slotTimerSp:setPercentage(per)
                if lefttime<=0 then
                    self.mydef=nil
                    self:hideMyDefSlot()
                end
            end
        end
    else
        self:removeMyDefSlot()
    end
    self:refreshDefButtonState()    
end

function cityBuildTab:updateDefList()
    self.deflist=G_clone(self.cityVo.deflist)
    self.defcount=SizeOfTable(self.deflist)
    self.mydefuser=nil
    local myAlliance=allianceVoApi:getSelfAlliance()
    if self.defcount>myAlliance.num then
        self.defcount=myAlliance.num
    end
    local function sortFunc(a,b)
        if (a[4] or 0)>(b[4] or 0) then
            return true
        end
        return false
    end
    table.sort(self.deflist,sortFunc)

    local uid=playerVoApi:getUid() --筛选出自己
    for k,v in pairs(self.deflist) do
        v.rank=k
        if v[2]==uid then
            self.mydefuser=v
        end
    end
    if self.mydefuser then
        table.remove(self.deflist,self.mydefuser.rank)
    end

    self.mydef=allianceCityVoApi:getMyDef()
end

function cityBuildTab:refresh()
    self.cityVo=allianceCityVoApi:getAllianceCity()
    self:updateDefList()
    self:refreshDefButtonState()
    if self.tv then
        self.tv:reloadData()
    end
    self:refreshLbs()
end

function cityBuildTab:refreshLbs()
    if self.crValueLb and self.maintainValueLb and self.crystalVauleLb and self.addMaintainLb then
        self.cityVo=allianceCityVoApi:getAllianceCity()
        self.crValueLb:setString(getlocal("ownAllianceCr").." "..FormatNumber(self.cityVo.cr))
        local mainCost,addCost=allianceCityVoApi:getMaintainCost()
        self.maintainValueLb:setString(getlocal("maintainCostStr").." "..getlocal("hourSpeed2",{FormatNumber(mainCost-addCost),math.ceil(allianceCityCfg.mainTime/60)}))
        if addCost>0 then
            self.addMaintainLb:setString("+"..addCost)
            self.addMaintainLb:setVisible(true)
        else
            self.addMaintainLb:setVisible(false)
        end
        local crystal,crystalLimit=allianceCityVoApi:getCrystal()
        self.crystalVauleLb:setString(getlocal("ownCrystal").." "..getlocal("curProgressStr",{FormatNumber(crystal),FormatNumber(crystalLimit)}))
        if crystal<crystalLimit*0.1 then --当前水晶量低于上限的10%，文字显示红色
            self.crystalVauleLb:setColor(G_ColorRed)
        else
            self.crystalVauleLb:setColor(G_ColorWhite)
        end
    end
end

function cityBuildTab:refreshDefButtonState()
    if self.defBtn and self.backBtn and self.defSpeedBtn and self.troopsBackSpeedBtn then
        if self.mydef==nil then
            self.defBtn:setVisible(true)
            self.defBtn:setEnabled(true)
            self.backBtn:setVisible(false)
            self.backBtn:setEnabled(false)
            self.defSpeedBtn:setEnabled(false)
            self.defSpeedBtn:setVisible(false)
            self.troopsBackSpeedBtn:setEnabled(false)
            self.troopsBackSpeedBtn:setVisible(false)
            -- self.progressTimer:setVisible(false)
            -- self.progressBg:setVisible(false)
        else
            self.defBtn:setVisible(false)
            self.defBtn:setEnabled(false)
            if self.mydef.isGather==0 and self.mydef.bs==nil then
                local lefttime=self.mydef.dist-base.serverTime
                if lefttime>0 then
                    self.defSpeedBtn:setEnabled(true)
                    self.defSpeedBtn:setVisible(true)
                else
                    self.defSpeedBtn:setEnabled(false)
                    self.defSpeedBtn:setVisible(false)
                end
            else
                self.defSpeedBtn:setEnabled(false)
                self.defSpeedBtn:setVisible(false)
            end
            if self.mydef.isGather==5 and self.mydef.bs==nil then
                self.backBtn:setVisible(true)
                self.backBtn:setEnabled(true)
            else
                self.backBtn:setVisible(false)
                self.backBtn:setEnabled(false)
            end
            if self.mydef.bs~=nil then
                local lefttime=self.mydef.bs-base.serverTime
                if lefttime>0 then
                    self.troopsBackSpeedBtn:setVisible(true)
                    self.troopsBackSpeedBtn:setEnabled(true)
                else
                    self.troopsBackSpeedBtn:setVisible(false)
                    self.troopsBackSpeedBtn:setEnabled(false)
                end
            else
                self.troopsBackSpeedBtn:setVisible(false)
                self.troopsBackSpeedBtn:setEnabled(false)
            end
        end
    end
end

function cityBuildTab:refreshDefRewards()
    if self.mydef==nil or self.slotTimerSp==nil then
        do return end
    end
    if self.mydef.isGather~=5 then
        do return end
    end
    local flag,collectTb,maxTb,totaltime,deftime=allianceCityVoApi:getDefincome(self.mydef)
    local percentStr,percent="",0
    if flag==true then
        local fullFlag,changeNum=false,3 --荣耀是否已经采集满的标识
        if totaltime==0 or deftime>=totaltime then
            fullFlag,changeNum=true,2
        end
        self.refreshIdx=self.refreshIdx+1
        if self.refreshIdx>changeNum then
            self.refreshIdx=1
        end
        if self.refreshIdx==1 then
            local acityuser=allianceCityVoApi:getAllianceCityUser()
            local rkey="h"
            local collect,max=(collectTb[rkey] or 0),maxTb[rkey]
            if max==0 then
                percent=100
            else
                percent=collect/max*100
            end
            if percent>=100 then
                percentStr=getlocal("honorReachFullStr")
            else
                percentStr=getlocal("defCityGlory",{getlocal("curProgressStr",{FormatNumber(collect),FormatNumber(max)})})
            end
        elseif self.refreshIdx==2 and fullFlag==false then
            if totaltime==0 then
                percent=100
            else
                if deftime>totaltime then
                    deftime=totaltime
                end
                percent=deftime/totaltime*100
            end
            percentStr=getlocal("defCityTime",{getlocal("curProgressStr",{GetTimeStr(deftime),GetTimeStr(totaltime)})})
        elseif self.refreshIdx==3 or (fullFlag==true and self.refreshIdx==2)then
            local acityuser=allianceCityVoApi:getAllianceCityUser()
            local rkey="s"
            local collect,max=(collectTb[rkey] or 0),maxTb[rkey]
            if max==0 then
                percent=100
            else
                percent=collect/max*100
            end
            if self.cityVo.crystal<=0 then
                percentStr=getlocal("alliancecity_no_crystal")
            elseif percent>=100 then
                percentStr=getlocal("addCrystalPromptStr2")
            else
                percentStr=getlocal("defCityCrystal",{getlocal("curProgressStr",{FormatNumber(collect),FormatNumber(max)})})
            end
        end
    end
    self.slotTimerSp:setPercentage(percent)
    local lbPer=tolua.cast(self.slotTimerSp:getChildByTag(12),"CCLabelTTF")
    lbPer:setString(percentStr)
end

function cityBuildTab:updateCellHeight()
    local height=418
    if G_isIphone5()==true then
        height=520
    end
    self.normalHeightTb,self.expandHeightTb={48,48},{408,height}
end

function cityBuildTab:initTableView()
    local addH=0
    if G_isIphone5()==true then
        addH=-50
    end
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    local tvWidth,tvHeight=616,(G_VisibleSizeHeight-490+addH)
    self.cellWidth=tvWidth
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    self.tv:setPosition((G_VisibleSizeWidth-tvWidth)/2,100)
    self.tv:setMaxDisToBottomOrTop(120)
    self.bgLayer:addChild(self.tv)
end

function cityBuildTab:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 2
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        if self.expandFlagTb[idx+1]==true then
            tmpSize=CCSizeMake(self.cellWidth,self.expandHeightTb[(idx+1)])
        else
            tmpSize=CCSizeMake(self.cellWidth,self.normalHeightTb[(idx+1)])
        end
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local expandFlag=self.expandFlagTb[(idx+1)]
        local cellHeight=0
        local itemPic,arrowDir="newCell.png",0
        if expandFlag==true then
            itemPic,arrowDir="newExpandCell.png",90
            cellHeight=self.expandHeightTb[(idx+1)]
        else
            cellHeight=self.normalHeightTb[(idx+1)]
        end

        local capInSet=CCRect(23,23,1,1)
        local function cellClick()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            local expandIdx=idx+1
            if self.expandFlagTb[expandIdx]==true then
                self.expandFlagTb[expandIdx]=false
            else
                self.expandFlagTb[expandIdx]=true
            end
            for k,v in pairs(self.expandFlagTb) do
                if k~=expandIdx and self.expandFlagTb[expandIdx]==true then
                    self.expandFlagTb[k]=false
                end
            end
            if self.tv then
                self.tv:reloadData()
            end
        end
        local itemBg=LuaCCScale9Sprite:createWithSpriteFrameName(itemPic,capInSet,cellClick)
        itemBg:setContentSize(CCSizeMake(self.cellWidth,48))
        itemBg:ignoreAnchorPointForPosition(false)
        itemBg:setAnchorPoint(ccp(0,0))
        itemBg:setIsSallow(false)
        itemBg:setTouchPriority(-(self.layerNum-1)*20-2)
        itemBg:setPosition(ccp(0,cellHeight-itemBg:getContentSize().height))
        cell:addChild(itemBg,1)

        local titleStr,valueStr
        if idx==0 then
            titleStr=getlocal("ltzdz_player_buildinginfo")
            local cityNum,total=allianceCityVoApi:getTerritoryCount()
            cityNum=cityNum+1
            total=total+1
            valueStr=cityNum.."/"..total
        elseif idx==1 then
            titleStr=getlocal("city_garrison")
            local myAlliance=allianceVoApi:getSelfAlliance()
            valueStr=self.defcount.."/"..myAlliance.num
        end
        if titleStr and valueStr then
            local titleLb=GetTTFLabel(titleStr,24)
            titleLb:setAnchorPoint(ccp(0,0.5))
            titleLb:setPosition(20,itemBg:getContentSize().height/2)
            itemBg:addChild(titleLb)
            local valueLb=GetTTFLabel(valueStr,24)
            valueLb:setAnchorPoint(ccp(0,0.5))
            valueLb:setPosition(460,itemBg:getContentSize().height/2)
            itemBg:addChild(valueLb)
        end

        local arrowSp=CCSprite:createWithSpriteFrameName("expandBtn.png")
        arrowSp:setPosition(self.cellWidth-arrowSp:getContentSize().width/2-10,itemBg:getContentSize().height/2)
        arrowSp:setRotation(arrowDir)    
        itemBg:addChild(arrowSp)
        if expandFlag==true then --显示展开信息
            self:openExpandCell(cell,idx)
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

function cityBuildTab:openExpandCell(cell,idx)
    local fontPosx2,fontSubPosx3 = 25,-10
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        fontPosx2,fontSubPosx3 = 0,0
    end
    local expendHeight=self.expandHeightTb[(idx+1)]-48
    local itemKuangSp=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    itemKuangSp:setContentSize(CCSizeMake(self.cellWidth,expendHeight))
    itemKuangSp:setAnchorPoint(ccp(0.5,1))
    itemKuangSp:setPosition(self.cellWidth/2,expendHeight)
    cell:addChild(itemKuangSp)
    local tc,tclimit=allianceCityVoApi:getTerritoryCount()
    local tcoords=allianceCityVoApi:getLastTerritoryXY()
    if idx==0 then --建设
        local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function () end)
        lineSp:setContentSize(CCSizeMake(itemKuangSp:getContentSize().width-10,2))
        lineSp:setRotation(180)
        lineSp:setPosition(getCenterPoint(itemKuangSp))
        itemKuangSp:addChild(lineSp)

        local territoryBuff=allianceCityVoApi:getTerritoryBuff()
        local mcoords=allianceCityVoApi:getCityXY() --获取主城坐标
        local itemHeight=180
        local infoCfg={
            {getlocal("myOwnNum",{getlocal("world_ground_name_6"),1,1}),{mcoords.x,mcoords.y},getlocal("alliance_city_desc")},
            {getlocal("myOwnNum",{getlocal("alliance_territory"),tc,tclimit}),{tcoords.x,tcoords.y}}
        }
        for i=1,2 do
            local cfg=infoCfg[i]
            local ownStr,wx,wy,descStr=cfg[1],cfg[2][1],cfg[2][2],cfg[3]
            local ownNumLb=GetTTFLabel(ownStr,20)
            ownNumLb:setAnchorPoint(ccp(0,0.5))
            ownNumLb:setPosition(20 + fontSubPosx3,expendHeight-ownNumLb:getContentSize().height/2-10-(i-1)*itemHeight)
            itemKuangSp:addChild(ownNumLb)

            local coords={x=wx,y=wy}
            local function focus()
                if (i==1) or (i==2 and tc>0) then
                    activityAndNoteDialog:closeAllDialog()
                    if i==1 then
                        mainUI:changeToWorld(coords,8)
                    else
                        mainUI:changeToWorld(coords)
                    end
                end
            end
            local kuangWidth,kuangHeight=140,132
            local kuangSp=LuaCCScale9Sprite:createWithSpriteFrameName("newKuang2.png",CCRect(7,7,1,1),focus)
            kuangSp:setContentSize(CCSizeMake(kuangWidth,kuangHeight))
            kuangSp:setAnchorPoint(ccp(0,1))
            kuangSp:setPosition(10,expendHeight-40-(i-1)*itemHeight)
            kuangSp:setTouchPriority(-(self.layerNum-1)*20-3)
            itemKuangSp:addChild(kuangSp)
            local buildingSp
            if i==1 then
                buildingSp=allianceCityVoApi:getAllianceCityIcon()
                buildingSp:setScale(0.5)
                buildingSp:setPosition(kuangWidth/2,kuangHeight/2+10)
            else
                buildingSp=CCSprite:createWithSpriteFrameName("territoryIcon.png")
                buildingSp:setPosition(kuangWidth/2,kuangHeight/2+15)
                -- buildingSp:setScale(1)
            end
            kuangSp:addChild(buildingSp)

            local coordsSp=CCSprite:createWithSpriteFrameName("acYijizaitan_dingwei.png")
            coordsSp:setAnchorPoint(ccp(0,0.5))
            coordsSp:setPosition(10,18)
            coordsSp:setScale(0.5)
            kuangSp:addChild(coordsSp)

            local priority=-(self.layerNum-1)*20-2

            local coordinateLb=G_getCoordinateLb(kuangSp,coords,18,focus,priority)
            coordinateLb:setAnchorPoint(ccp(0,0.5))
            coordinateLb:setPosition(32,coordsSp:getPositionY())
            
            if i==1 then
                local descLb=GetTTFLabelWrap(descStr,20,CCSizeMake(self.cellWidth-320,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                descLb:setAnchorPoint(ccp(0,1))
                descLb:setPosition(ccp(160,expendHeight-60-(i-1)*itemHeight + fontPosx2))
                itemKuangSp:addChild(descLb)
            else
                local descTb={
                    {getlocal("alliance_territory_desc1")},
                    {getlocal("alliance_territory_desc2")},
                    {getlocal("alliance_territory_desc3",{territoryBuff[1]*100}),{nil,G_ColorGreen,nil},nil,true},
                    {getlocal("alliance_territory_desc4",{territoryBuff[3]}),{nil,G_ColorGreen,nil},nil,true},
                    {getlocal("alliance_territory_desc5",{territoryBuff[2]*100}),{nil,G_ColorGreen,nil},nil,true},
                }
                local desTv=G_LabelTableViewNew(CCSizeMake(self.cellWidth-320,itemHeight-15),descTb,20,kCCTextAlignmentLeft,nil,nil,nil)
                itemKuangSp:addChild(desTv)
                desTv:setPosition(160,5)
                desTv:setAnchorPoint(ccp(0,0))
                desTv:setTableViewTouchPriority(priority)
                desTv:setMaxDisToBottomOrTop(100)
            end

            if i==1 then
                --搬迁
                local function migrateHandler()
                    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                        local downFlag=allianceCityVoApi:isCityDown()
                        if downFlag==false then
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26003"),28)
                            do return end
                        end
                        local flag=allianceCityVoApi:isCanBuildCity(true)
                        if flag~=0 then
                            if flag==1 then
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage8008"),28)
                            end
                            do return end
                        end
                        if allianceCityVoApi:ishasDefList()==true or allianceCityVoApi:ishasAttackList()==true then --如果有驻防或者敌军来袭则不能搬家
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26015"),28)    
                            do return end
                        end
                        local cost,cr=allianceCityVoApi:getMoveCost(),self.cityVo.cr
                        if cost>cr then
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26008"),28)
                            do return end
                        end
                        local function changeToWorld()
                            activityAndNoteDialog:closeAllDialog()
                            local coords=allianceCityVoApi:getCityXY()
                            mainUI:changeToWorld(coords,8)
                            worldScene:createBuildLayer(coords.x,coords.y,2)
                        end
                        local desInfo={25,G_ColorYellowPro,kCCTextAlignmentCenter}    
                        local addStrTb={
                            {getlocal("moveCityPromptStr2"),G_ColorRed,25,kCCTextAlignmentCenter,20}
                        }
                        G_showSecondConfirm(self.layerNum+1,true,true,getlocal("moveCityStr"),getlocal("moveCityPromptStr",{cost}),false,changeToWorld,nil,nil,desInfo,addStrTb)
                    end
                end
                local migrateBtn=G_createBotton(itemKuangSp,ccp(itemKuangSp:getContentSize().width-35,expendHeight-itemHeight/2-(i-1)*itemHeight),nil,"migrateBtn.png","migrateBtnDown.png","migrateBtnDown.png",migrateHandler,1,priority)

                local function upgradeHandler() --跳转到军团科技"城市等级"科技页面
                    G_goAllianceFunctionDialog("alliance_technology",self.layerNum+1,22)
                end
                local upgradeBtn=G_createBotton(itemKuangSp,ccp(itemKuangSp:getContentSize().width-115,expendHeight-itemHeight/2-(i-1)*itemHeight),nil,"yh_BtnUp.png","yh_BtnUp_Down.png","yh_BtnUp_Down.png",upgradeHandler,1,priority)
            elseif i==2 then
                if tc<=0 then --拓展领地个数为0时，隐藏领地坐标显示
                    coordinateLb:setVisible(false)
                    coordsSp:setVisible(false)
                end
                --建造领地
                local function buildHandler()
                    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                        local downFlag=allianceCityVoApi:isCityDown()
                        if downFlag==false then
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26003"),28)
                            do return end
                        end
                        local flag=allianceCityVoApi:isPrivilegeEnoughOfTerritory()
                        if flag==false then --权限不足
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage8008"),28)
                            do return end
                        end
                        local tc,limit=allianceCityVoApi:getTerritoryCount()
                        if tc>=limit then --领土数量已达上限
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26009"),28)
                            do return end
                        end
                        local cost,cr=allianceCityVoApi:getCreateTerritoryCost(),self.cityVo.cr
                        local function confirm()
                            if cost>cr then --稀土数量不足
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26008"),28)
                                do return end
                            end
                            activityAndNoteDialog:closeAllDialog()
                            local coords=allianceCityVoApi:getCityXY()
                            mainUI:changeToWorld(coords)
                            worldScene:createBuildLayer(coords.x,coords.y,3)
                        end
                        local desInfo={25,G_ColorWhite,kCCTextAlignmentCenter}
                        local addStrTb={
                            {getlocal("addTerritoryPromptStr2"),G_ColorRed,25,kCCTextAlignmentCenter,20}
                        }
                        G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("addTerritoryPromptStr",{cost}),false,confirm,nil,nil,desInfo,addStrTb)
                    end
                end
                local buildBtn=G_createBotton(itemKuangSp,ccp(itemKuangSp:getContentSize().width-35,expendHeight-itemHeight/2-(i-1)*itemHeight),nil,"newBuildBtn.png","newBuildBtnDown.png","newBuildBtnDown.png",buildHandler,1,priority)
                --回收领地
                local function recycleHandler()
                    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                        local downFlag=allianceCityVoApi:isCityDown()
                        if downFlag==false then
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26003"),28)
                            do return end
                        end
                        local flag=allianceCityVoApi:isPrivilegeEnoughOfTerritory()
                        if flag==false then --权限不足
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage8008"),28)
                            do return end
                        end
                        local tc=allianceCityVoApi:getTerritoryCount()
                        if tc==0 then --当前没有可以回收的领地
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26007"),28)
                            do return end
                        end
                        local function confirm()
                            local coords=allianceCityVoApi:getLastTerritoryXY()
                            if coords then
                                activityAndNoteDialog:closeAllDialog()
                                mainUI:changeToWorld(coords)
                                worldScene:createBuildLayer(coords.x,coords.y,4) --跳转到要回收领地的位置
                            end
                        end
                        local desInfo={25,G_ColorWhite,kCCTextAlignmentCenter}
                        G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("recycleTerritoryStr"),false,confirm,nil,nil,desInfo)
                    end
                end
                local recycleBtn=G_createBotton(itemKuangSp,ccp(itemKuangSp:getContentSize().width-115,expendHeight-itemHeight/2-(i-1)*itemHeight),nil,"recycleBtn.png","recycleBtnDown.png","recycleBtnDown.png",recycleHandler,1,priority)
            end
        end
    elseif idx==1 then --驻防
        if self.defcount==0 then
            local tipLb=GetTTFLabelWrap(getlocal("cityNoDeflist"),24,CCSizeMake(self.cellWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            tipLb:setPosition(getCenterPoint(itemKuangSp))
            itemKuangSp:addChild(tipLb)
            do return end
        end
        local tv,isMoved,cellWidth,cellHeight=nil,false,self.cellWidth,80
        local function eventHandler(handler,fn,idx,cel)
            if fn=="numberOfCellsInTableView" then
                return self.defcount
            elseif fn=="tableCellSizeForIndex" then
                local tmpSize=CCSizeMake(self.cellWidth,cellHeight)
                return  tmpSize
            elseif fn=="tableCellAtIndex" then
                local cell=CCTableViewCell:new()
                cell:autorelease()
                local defuser
                if self.mydefuser then
                    if idx==0 then
                        defuser=self.mydefuser
                    else
                        defuser=self.deflist[idx]
                    end
                else
                    defuser=self.deflist[idx+1]
                end
                if defuser then
                    local mydefFlag=false
                    if self.mydefuser and idx==0 then
                        local itemBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankOtherBg.png",CCRect(5,5,1,1),function ()end)
                        itemBg:setContentSize(CCSizeMake(self.cellWidth-6,cellHeight))
                        itemBg:setPosition(self.cellWidth/2,cellHeight/2)
                        cell:addChild(itemBg)
                        mydefFlag=true
                    else
                        local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function () end)
                        lineSp:setContentSize(CCSizeMake(self.cellWidth-10,2))
                        lineSp:setRotation(180)
                        lineSp:setPosition(cellWidth/2,0)
                        cell:addChild(lineSp)
                    end
                    local slotId,uid,name,fightValue=defuser[1],defuser[2],(defuser[3] or ""),(defuser[4] or 0)
                    if tonumber(defuser.rank)<=3 then
                        local rankSp=CCSprite:createWithSpriteFrameName("top"..defuser.rank..".png")
                        rankSp:setScale(40/rankSp:getContentSize().width)
                        rankSp:setPosition(30,cellHeight/2)
                        cell:addChild(rankSp)
                    else
                        local rankLb=GetTTFLabelWrap(tostring(defuser.rank),20,CCSizeMake(G_VisibleSizeWidth-260,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                        rankLb:setPosition(30,cellHeight/2)
                        cell:addChild(rankLb)
                    end

                    local nameLb=GetTTFLabelWrap(name,20,CCSizeMake(G_VisibleSizeWidth-260,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                    nameLb:setAnchorPoint(ccp(0,0.5))
                    nameLb:setPosition(160,cellHeight/2)
                    cell:addChild(nameLb)

                    local fightSp=CCSprite:createWithSpriteFrameName("fightValueIcon.png")
                    fightSp:setAnchorPoint(ccp(0,0.5))
                    fightSp:setPosition(360,cellHeight/2)
                    cell:addChild(fightSp)
                    local fightValueLb=GetTTFLabel(FormatNumber(tonumber(fightValue)),20)
                    fightValueLb:setAnchorPoint(ccp(0,0.5))
                    fightValueLb:setPosition(fightSp:getPositionX()+fightSp:getContentSize().width+10,cellHeight/2)
                    cell:addChild(fightValueLb)

                    if mydefFlag==false then
                        local function backHandler()
                            if tv and tv:getScrollEnable()==true and tv:getIsScrolled()==false then
                                local downFlag=allianceCityVoApi:isCityDown()
                                if downFlag==false then
                                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage26003"),28)
                                    do return end
                                end
                                local flag=allianceCityVoApi:isPrivilegeEnough()
                                if flag==false then --权限不足
                                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage8008"),28)
                                    do return end
                                end
                                local function allback()
                                    local function callback()
                                        self:refresh()
                                    end
                                    allianceCityVoApi:backDefCityTroops(2,nil,callback)
                                end
                                local function back()
                                    local function callback()
                                        self:refresh()
                                    end
                                    allianceCityVoApi:backDefCityTroops(1,uid,callback)
                                end
                                local desInfo={25,G_ColorWhite,kCCTextAlignmentCenter}
                                local addStrTb={
                                    {getlocal("backDefCityTroopsTipStr"),G_ColorRed,25,kCCTextAlignmentCenter,20}
                                }
                                G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("backDefCityConfirmStr2",{name}),false,allback,nil,back,desInfo,addStrTb,{getlocal("backCityDefTroops1")},{getlocal("backCityDefTroops2")},true)
                            end
                        end
                        local scale,priority=1,-(self.layerNum-1)*20-1
                        local backBtn=G_createBotton(cell,ccp(cellWidth-60,cellHeight/2),{},"repatriateBtn.png","repatriateBtnDown.png","repatriateBtnDown.png",backHandler,1,priority)
                    end
                end

                return cell
            elseif fn=="ccTouchBegan" then
                isMoved=false
                return true
            elseif fn=="ccTouchMoved" then
                isMoved=true
            elseif fn=="ccTouchEnded" then

            end
        end
        local hd=LuaEventHandler:createHandler(eventHandler)
        tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.cellWidth,expendHeight),nil)
        tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
        tv:setPosition(0,0)
        tv:setMaxDisToBottomOrTop(120)
        itemKuangSp:addChild(tv)
    end
end

function cityBuildTab:tick()
    self:refreshMyDefSlot()
end

function cityBuildTab:dispose()
    if self.refreshCityListener then
        eventDispatcher:removeEventListener("alliancecity.refreshCity",self.refreshCityListener)
        self.refreshCityListener=nil
    end
    self.refreshIdx=0
    self.rtick=0
    self.cityVo=nil
    self.mydef=nil
    self.mydefuser=nil
    self.defState=0
    self.slotTimerSp=nil
    self.slotTimerBg=nil
end