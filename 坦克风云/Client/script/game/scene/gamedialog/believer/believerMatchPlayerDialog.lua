local believerMatchPlayerDialog=commonDialog:new()

function believerMatchPlayerDialog:new(parent,matchEffectFlag)
    local nc={
        parent=parent,
        troopType=37,
        matchEffectFlag=matchEffectFlag,
    }
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function believerMatchPlayerDialog:doUserHandler()
    spriteController:addPlist("public/vipFinal.plist")
    spriteController:addTexture("public/vipFinal.plist")
    spriteController:addPlist("public/believer/believerEffect.plist")
    spriteController:addTexture("public/believer/believerEffect.png")
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(true)
    self.panelTopLine:setPositionY(G_VisibleSizeHeight-82)

    self.iphoneType=G_getIphoneType()
    self.troopType=believerVoApi:getBattleType()
    self:initMainDialog()
    if self.playerIconSp and (self.matchEffectFlag and self.matchEffectFlag==true) then
        self.bgLayer:setVisible(false)
        local x,y=G_getSpriteWorldPosAndSize(self.playerIconSp)
        local anchorX,anchorY=x/G_VisibleSizeWidth,y/G_VisibleSizeHeight
        
        local function showEffect()
            local function layerEffect()
                self.bgLayer:setVisible(true)
                -- print("x,y,anchorX,anchorY",x,y,anchorX,anchorY)
                self.bgLayer:setAnchorPoint(ccp(anchorX,anchorY))
                self.bgLayer:setPosition(x,y)
                self.bgLayer:setScale(0)
                local acArr=CCArray:create()
                acArr:addObject(CCScaleTo:create(0.2,1.08))
                acArr:addObject(CCScaleTo:create(0.1,0.9))
                acArr:addObject(CCScaleTo:create(0.05,1))
                local seq=CCSequence:create(acArr)
                self.bgLayer:runAction(seq)
                believerVoApi:runBoomBoomFlower(self.layerNum + 1,ccp(x,y))
                -- self.bgLayer:runAction(CCEaseBounceInOut:create(CCScaleTo:create(0.55,1)))
            end
            local delay=CCDelayTime:create(0.2)
            self.bgLayer:runAction(CCSequence:createWithTwoActions(delay,CCCallFunc:create(layerEffect)))
        end
        believerVoApi:showParticFunc(self.layerNum + 1,ccp(x,y),showEffect)
    end
end

function believerMatchPlayerDialog:initMainDialog()
    local infoBgSize,troopsBgSize=CCSizeMake(616,200),CCSizeMake(616,152*3+140)
    if self.iphoneType==G_iphone4 then
        infoBgSize,troopsBgSize=CCSizeMake(616,190),CCSizeMake(616,550)
    end
    local baseInfoBg=LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png",CCRect(15,15,2,2),function () end)
    baseInfoBg:setAnchorPoint(ccp(0.5,1))
    baseInfoBg:setContentSize(infoBgSize)
    baseInfoBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-90)
    self.bgLayer:addChild(baseInfoBg)
    self.baseInfoBg=baseInfoBg

    local iphoneXAddH=0
    if self.iphoneType==G_iphoneX then
        iphoneXAddH=-30
    end
    local troopsBg=G_getTroopsBg(troopsBgSize)
    troopsBg:setPosition(G_VisibleSizeWidth/2,baseInfoBg:getPositionY()-baseInfoBg:getContentSize().height-5+iphoneXAddH)
    self.bgLayer:addChild(troopsBg)
    self.troopsBg=troopsBg

    local matchInfo=believerVoApi:getMatchInfo()
    if matchInfo then
        self:refreshMatchInfo() --刷新匹配信息
    end
    local believerCfg=believerVoApi:getBelieverCfg()
    local btnScale,priority=0.8,-(self.layerNum-1)*20-4
    --介绍信息
    local function infoHandler()
        local args={
            arg3={believerCfg.troopsNum},
        }
        local strTb={}
        for i=1,5 do
            local str=getlocal("believer_troop_set_info_"..i,args["arg"..i])
            table.insert(strTb,str)
        end
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),strTb)
    end
    local infoItem=G_addMenuInfo(self.baseInfoBg,self.layerNum,ccp(infoBgSize.width-65,infoBgSize.height/2+50),{},nil,nil,28,infoHandler,true)
    --显示克制关系介绍
    local function showKeZhiHandler()
        believerVoApi:showTankKezhiSmallDialog(self.layerNum+1)
    end
    local kezhiItem=G_createBotton(self.baseInfoBg,ccp(infoBgSize.width-65,infoBgSize.height/2-50),{},"kezhiBtn.png","kezhiBtnDown.png","kezhiBtnDown.png",showKeZhiHandler,1,priority)

    local btnAddedH=0
    if self.iphoneType==G_iphoneX then
        btnAddedH=50
    end
    local btnPosY=55+btnAddedH
    local costGems=believerVoApi:getResetMatchCost() --是否花费钻石重置匹配
    --更换对手
    local function rechangeMatchHandler()
        if believerVoApi:checkSeasonStatus()~=1 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage28106"),28)
            do return end
        end
        local costGems=believerVoApi:getResetMatchCost() --是否花费钻石重置匹配
        local function changeMatchHandler()
            local function matchHandler()
                local function showMatchInfo()
                    if self.parent and self.parent.goToSubDialogHandler then
                        self.parent:goToSubDialogHandler()
                    end
                    believerVoApi:showMatchInfoDialog(self.layerNum+1,self.parent,false,true)
                end
                believerVoApi:showMatchSmallDialog(self.layerNum+1,showMatchInfo)
            end
            believerVoApi:requestMatch(matchHandler,costGems)
            self:close()
        end
        if costGems~=nil and costGems>0 then
            local function onConfirm()
                if(costGems>playerVoApi:getGems())then
                    GemsNotEnoughDialog(nil,nil,costGems-playerVoApi:getGems(),self.layerNum+1,costGems)
                    do return end
                else
                    changeMatchHandler()
                end
            end
            G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("believer_match_change_cost",{costGems}),false,onConfirm)
        else
            changeMatchHandler()
        end
    end
    local rechangeItem,rachangeMenu=G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth/2-200,btnPosY),{getlocal("believer_match_change"),25},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",rechangeMatchHandler,btnScale,priority)

    --钻石icon
    local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIcon:setAnchorPoint(ccp(1,0.5))
    goldIcon:setPosition(ccp(G_VisibleSizeWidth/2-200-10,btnPosY+55))
    self.bgLayer:addChild(goldIcon)
    
    local goldStr=getlocal("daily_lotto_tip_2")
    if costGems~=nil then
        goldStr=costGems
    end
    --花费数量
    local goldLb=GetTTFLabel(goldStr,22)
    goldLb:setAnchorPoint(ccp(0,0.5))
    goldLb:setPosition(ccp(G_VisibleSizeWidth/2-200-8,btnPosY+55))
    self.bgLayer:addChild(goldLb)
    self.goldLb=goldLb

    --阵型
    local function formationHandler()
        local function readCallBack() --读取完阵型后的处理
            self:refreshMyTroopsInfo()
        end
        believerVoApi:showTroopsFormationSmallDialog(self.troopType,self.layerNum+1,readCallBack)
    end
    local formationItem,formationMenu=G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth/2,btnPosY),{getlocal("formation"),25},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",formationHandler,btnScale,priority)

    --部署
    local function attackHandler()
        local tankTb=tankVoApi:getTanksTbByType(self.troopType)
        local fleetNum=0 --上阵坦克数，必须六个位置都上，1200坦克
        for k,v in pairs(tankTb) do
            if v and v[2] and v[2]==believerCfg.troopsNum then
                fleetNum=fleetNum+1
            end
        end
        if fleetNum==6 then
            local function battle(data)
                if data and data.battle then
                    believerVoApi:enterBattle(data.battle)
                end
                tankVoApi:clearTanksTbByType(self.troopType)
                self:close()
            end
            believerVoApi:believerBattle()
            believerVoApi:showWaitingBattleDialog(self.layerNum+1,battle)    
        else
            --有空位，则提示
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("believer_attack_not_enough"),30)
        end
        
    end
    local attackItem,attackMenu=G_createBotton(self.bgLayer,ccp(G_VisibleSizeWidth/2+200,btnPosY),{getlocal("alliance_challenge_fight"),25},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",attackHandler,btnScale,priority)

    local mLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function () end)
    mLine:setPosition(ccp(G_VisibleSizeWidth/2,btnPosY+50))
    mLine:setContentSize(CCSizeMake(G_VisibleSizeWidth-10,mLine:getContentSize().height))
    self.bgLayer:addChild(mLine)
end

function believerMatchPlayerDialog:refreshMatchInfo()
    local matchInfo=believerVoApi:getMatchInfo()
    if matchInfo and self.baseInfoBg and self.troopsBg then
        local believerCfg=believerVoApi:getBelieverCfg()
        local infoBgSize,troopsBgSize=self.baseInfoBg:getContentSize(),self.troopsBg:getContentSize()

        local player=matchInfo.player
        local iconSize,iconTag=150,999
        local iconPosX,textPosX,textPosY=10+iconSize/2,10+iconSize+10,infoBgSize.height-25
        local picName=playerVoApi:getPersonPhotoName(player.pic)

        local iconSp=tolua.cast(self.baseInfoBg:getChildByTag(iconTag),"CCSprite")
        if iconSp then
            iconSp:removeFromParentAndCleanup(true)
            iconSp=nil
            self.playerIconSp=nil
        end
        iconSp=playerVoApi:GetPlayerBgIcon(picName,nil,nil,nil,iconSize,player.hfid)
        iconSp:setPosition(iconPosX,infoBgSize.height/2)
        iconSp:setTag(iconTag)
        self.baseInfoBg:addChild(iconSp)
        self.playerIconSp=iconSp
        textPosY=iconSp:getPositionY()+iconSize/2

        local fontSize,smallFontSize,fontWidth,fontSpace=22,20,infoBgSize.width/2,18

        local nameStr
        local npcNameStr=getlocal("believer_npc_name")
        local enemyNameStr=player.name
        if npcNameStr==enemyNameStr then
            nameStr=getlocal("believer_enemy_namestr2",{enemyNameStr,G_LV()..player.level})
        else
            nameStr=getlocal("believer_enemy_namestr",{GetServerNameByID(player.zid,true),player.name,G_LV()..player.level})
        end
        local segNameStr=getlocal("believer_seg",{""})
        local powerStr=getlocal("world_war_power",{""}).."<rayimg>"..FormatNumber(player.fight).."<rayimg>"
        local killRateStr=getlocal("believer_avedmgRate",{player.killRate/10})
        local weatherStr=getlocal("believer_match_weather_"..matchInfo.match_weather).."："
        local landformStr=getlocal("believer_match_landform",{getlocal("believer_match_landform_"..matchInfo.match_ocean)})

        if self.infoLbTb then
            for k,v in pairs(self.infoLbTb) do
                local lb=tolua.cast(v,"CCLabelTTF")
                if lb then
                    lb:removeFromParentAndCleanup(true)
                    lb=nil
                end
            end
        end
        --名字
        local nameLb=GetTTFLabelWrap(nameStr,fontSize,CCSizeMake(fontWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold",true)
        nameLb:setAnchorPoint(ccp(0,1))
        nameLb:setPosition(textPosX,textPosY)
        self.baseInfoBg:addChild(nameLb)
        --段位
        local gradeLb,gradeLbHeight=G_getRichTextLabel(segNameStr,{G_ColorWhite,G_ColorYellowPro},smallFontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        gradeLb:setAnchorPoint(ccp(0,1))
        gradeLb:setPosition(textPosX,nameLb:getPositionY()-nameLb:getContentSize().height-fontSpace)
        self.baseInfoBg:addChild(gradeLb)
        local tempLb=GetTTFLabel(segNameStr,smallFontSize)
        local realW=tempLb:getContentSize().width
        if realW>fontWidth then
            realW=fontWidth
        end
        local segIconSp=believerVoApi:getSegmentIcon(player.grade,player.queue)
        local iconWidth=0.21*segIconSp:getContentSize().width
        segIconSp:setAnchorPoint(ccp(0,0.5))
        segIconSp:setScale(0.21)
        segIconSp:setPosition(gradeLb:getPositionX()+realW+iconWidth/2-10,gradeLb:getPositionY()-gradeLbHeight/2)
        self.baseInfoBg:addChild(segIconSp)
        --战斗力
        local powerLb,powerLbHeight=G_getRichTextLabel(powerStr,{G_ColorWhite,G_ColorYellowPro},smallFontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        powerLb:setAnchorPoint(ccp(0,1))
        powerLb:setPosition(textPosX,gradeLb:getPositionY()-gradeLbHeight-fontSpace)
        self.baseInfoBg:addChild(powerLb)
        --平均生存率
        local killRateLb=G_getRichTextLabel(killRateStr,{G_ColorWhite,G_ColorYellowPro},smallFontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        killRateLb:setAnchorPoint(ccp(0,1))
        killRateLb:setPosition(textPosX,powerLb:getPositionY()-powerLbHeight-fontSpace)
        self.baseInfoBg:addChild(killRateLb)

        local troopBgWidth,troopBgHeight=282,152
        fontWidth=troopsBgSize.width/2-10
        --天气
        local adaSize = 0
        if G_getCurChoseLanguage() == "ar" then
           adaSize = 30    
        end
        local weatherLb,weatherLbHeight=G_getRichTextLabel(weatherStr,{},smallFontSize,fontWidth-adaSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        
        weatherLb:setAnchorPoint(ccp(0,1))
        weatherLb:setPosition(10,troopsBgSize.height-25+weatherLbHeight/2)
        self.troopsBg:addChild(weatherLb)
        tempLb=GetTTFLabel(weatherStr,smallFontSize)
        realW=tempLb:getContentSize().width
        if realW>fontWidth then
            realW=fontWidth
        end
        iconWidth=40
        local attIconPic=believerVoApi:getWeatherAttType(matchInfo.match_weather)
        -- print("attIconPic---???",attIconPic)
        if attIconPic then
            local attIconSp=CCSprite:createWithSpriteFrameName(attIconPic)
            attIconSp:setAnchorPoint(ccp(0,0.5))
            attIconSp:setScale(iconWidth/attIconSp:getContentSize().width)
            attIconSp:setPosition(weatherLb:getPositionX()+realW+10,weatherLb:getPositionY()-weatherLbHeight/2)
            if G_getCurChoseLanguage() == "ar" then
                attIconSp:setPosition(self.troopsBg:getContentSize().width/2-realW-20-attIconSp:getContentSize().width,weatherLb:getPositionY()-weatherLbHeight/2)
            end
            self.troopsBg:addChild(attIconSp)
            local upArrowSp=CCSprite:createWithSpriteFrameName("vipUpArrow.png")
            upArrowSp:setAnchorPoint(ccp(0.5,0))
            upArrowSp:setScale(1/attIconSp:getScale()*0.7)
            upArrowSp:setPosition(attIconSp:getContentSize().width,0)
            attIconSp:addChild(upArrowSp)
        end
        
        --环境
        local landformLb,landformLbHeight
        landformLb,landformLbHeight=G_getRichTextLabel(landformStr,{G_ColorWhite,G_ColorHighGreen},smallFontSize,fontWidth,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        if G_getCurChoseLanguage() == "ar" then
            landformLb,landformLbHeight=G_getRichTextLabel(landformStr,{G_ColorWhite,G_ColorHighGreen},smallFontSize,fontWidth-30,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        end
        landformLb:setAnchorPoint(ccp(0,1))
        landformLb:setPosition(troopsBgSize.width/2+10,troopsBgSize.height-25+landformLbHeight/2)
        self.troopsBg:addChild(landformLb)

        self.infoLbTb={nameLb,gradeLb,powerLb,killRateLb,weatherLb,landformLb}

        local believerCfg=believerVoApi:getBelieverCfg()
        if self.troopSpTb==nil then
            self.troopSpTb={}
        end
        --部队
        local firstPosY=troopsBgSize.height-50
        local spaceY=20
        if self.iphoneType==G_iphone4 then
            spaceY=2
        end
        --排列舰队
        for i=0,1,1 do
            for j=0,2,1 do
                local index=((j+1)+(i*3))
                local tankBgSp=self.troopSpTb[index]
                if self.troopSpTb[index]==nil then
                    local bgPosX,bgPosY=troopsBgSize.width/2+5-i*(troopBgWidth+10),firstPosY-(troopBgHeight+spaceY)*j
                    tankBgSp=CCSprite:createWithSpriteFrameName("believerTroopsBg.png")
                    tankBgSp:setContentSize(CCSizeMake(troopBgWidth,troopBgHeight))
                    tankBgSp:setAnchorPoint(ccp(0,1))
                    tankBgSp:setPosition(bgPosX,bgPosY)
                    self.troopsBg:addChild(tankBgSp,1)
                    self.troopSpTb[index]=tankBgSp

                    --数字标记
                    local numberSp=CCSprite:createWithSpriteFrameName("tankPos"..index..".png")
                    numberSp:setAnchorPoint(ccp(1,0))
                    numberSp:setScale(0.6)
                    numberSp:setPosition(ccp(tankBgSp:getContentSize().width-12,12))
                    tankBgSp:addChild(numberSp,1)
                end
                self:refreshTroops(index,1) --刷新我方部队
                self:refreshTroops(index,2) --刷新对手部队
            end
        end
        self:refreshFightLb()
    end
    if self.goldLb then
        local costGems=believerVoApi:getResetMatchCost() --是否花费钻石重置匹配
        self.goldLb:setString(costGems)
    end
end

function believerMatchPlayerDialog:refreshTroops(index,troopsType)
    if self.troopSpTb[index]==nil then
        do return end
    end
    if self.baseInfoBg==nil or self.troopsBg==nil then
        do return end
    end
    local tankBgSp=self.troopSpTb[index]
    local believerCfg=believerVoApi:getBelieverCfg()
    local iconWidth=70
    local troopBgWidth,troopBgHeight=tankBgSp:getContentSize().width,tankBgSp:getContentSize().height
    local troopInfo,tankPosX,tankPosY
    if troopsType==1 then --我方部队
        local myTanks=tankVoApi:getTanksTbByType(self.troopType)
        troopInfo=myTanks[index]
        tankPosX,tankPosY=15+iconWidth/2,15+iconWidth/2
    else
        local matchInfo=believerVoApi:getMatchInfo()
        if matchInfo and matchInfo.player and matchInfo.player.troop then
            local player=matchInfo.player
            local tankId=player.troop[index]
            troopInfo={tankId,believerCfg.troopsNum}
        end
        tankPosX,tankPosY=troopBgWidth-15-iconWidth/2,troopBgHeight-15-iconWidth/2
    end
    local tankTag=troopsType*100+index
    local addBtnTag=troopsType*10+index
    local tankSp=tolua.cast(tankBgSp:getChildByTag(tankTag),"LuaCCSprite")
    local addBtnSp=tolua.cast(tankBgSp:getChildByTag(addBtnTag),"LuaCCSprite")
    if troopInfo==nil or troopInfo[1]==nil then
        if troopsType==1 then
            --没有tank的时候显示标记
            if addBtnSp==nil then
                local function showSelectTankDialog()  
                    local function refreshMyTroops(id,num)
                        tankVoApi:setTanksByType(self.troopType,index,id,believerCfg.troopsNum) --设置坦克
                        self:refreshTroops(index,1) --刷新我方部队
                        self:refreshFightLb()
                    end
                    believerVoApi:believerSelectTankSmallDialog(self.layerNum+1,refreshMyTroops,index)
                end
                addBtnSp=LuaCCSprite:createWithSpriteFrameName("st_addIcon.png",showSelectTankDialog)
                addBtnSp:setTouchPriority(-(self.layerNum-1)*20-4)
                addBtnSp:setPosition(tankPosX,tankPosY)
                addBtnSp:setTag(addBtnTag)
                tankBgSp:addChild(addBtnSp,1)
                -- 忽隐忽现
                local fade1=CCFadeTo:create(1,55)
                local fade2=CCFadeTo:create(1,255)
                local seq=CCSequence:createWithTwoActions(fade1,fade2)
                local repeatEver=CCRepeatForever:create(seq)
                addBtnSp:runAction(repeatEver)
            else
                addBtnSp:setPosition(tankPosX,tankPosY)
                addBtnSp:setVisible(true)
            end
            if tankSp then
                tankSp:setVisible(false)
                tankSp:setPosition(-99999,tankPosY)
            end
        end
    else
        if addBtnSp then
            addBtnSp:setPosition(-99999,tankPosY)
            addBtnSp:setVisible(false)
        end
        local tankId=tonumber(troopInfo[1]) or tonumber(RemoveFirstChar(troopInfo[1]))
        -- print("tankId,num-----???",tankId,troopInfo[2])
        local useScale = nil
        if tankSp then
            tankSp:removeFromParentAndCleanup(true)
            tankSp=nil
        end
        -- if tankSp==nil then
            local skinId,isCheckSelf
            if troopsType==2 then
                local matchInfo=believerVoApi:getMatchInfo()
                if matchInfo and matchInfo.player and matchInfo.player.skin then
                    skinId=matchInfo.player.skin[tankSkinVoApi:convertTankId(tankId)]
                end
                isCheckSelf=false
            end
            local function deleteTankHandler()
                tankVoApi:deleteTanksTbByType(self.troopType,index)
                self:refreshTroops(index,1) --刷新我方部队
                self:refreshFightLb()
            end
            local function showTankInfo()
                local matchInfo=believerVoApi:getMatchInfo()
                if matchInfo and matchInfo.player and matchInfo.player.troop then
                    local tankId=matchInfo.player.troop[index]
                    local tankId=tonumber(tankId) or tonumber(RemoveFirstChar(tankId))
                    local id=G_pickedList(tankId)
                    -- print("tankId,id,skin----???",tankId,id,skinId)
                    tankInfoDialog:create(self.bgLayer,tonumber(id),self.layerNum+1,true,nil,nil,true,{skin=skinId},false)
                end
            end
            local handler
            if troopsType==1 then
                handler=deleteTankHandler
            else
                handler=showTankInfo
            end
            tankSp=tankVoApi:getTankIconSp(tankId,skinId,handler,isCheckSelf)--LuaCCSprite:createWithSpriteFrameName(tankCfg[tankId].icon,handler)
            tankSp:setTag(tankTag)
            useScale = iconWidth/tankSp:getContentSize().width
            tankSp:setScale(useScale)
            tankSp:setPosition(tankPosX,tankPosY)
            tankSp:setTouchPriority(-(self.layerNum-1)*20-4)
            tankBgSp:addChild(tankSp,1)
        -- else
            -- local tankFrame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tankCfg[tankId].icon)
            -- if tankFrame then
            --     tankSp:setDisplayFrame(tankFrame)
            --     tankSp:setVisible(true)
            --     tankSp:setPosition(tankPosX,tankPosY)
            -- end
        -- end

        if troopsType==2 and tankSp and useScale and self.matchEffectFlag and self.matchEffectFlag==true then--加限制！！！！！！
            tankSp:setOpacity(0)
            tankSp:setScale(0)
            local fadeIn = CCFadeIn:create(0.3)
            local scaleTo = CCScaleTo:create(0.3,useScale)
            local delayT = CCDelayTime:create(0.3 + index * 0.3)
            local arr = CCArray:create()
            arr:addObject(fadeIn)
            arr:addObject(scaleTo)
            local spawn = CCSpawn:create(arr)
            local scaleTo2 = CCScaleTo:create(0.1,useScale+0.5)
            local scaleTo3 = CCScaleTo:create(0.03,useScale-0.2)
            local scaleTo4 = CCScaleTo:create(0.05,useScale)
            local arr2 = CCArray:create()
            arr2:addObject(delayT)
            arr2:addObject(spawn)
            arr2:addObject(scaleTo2)
            arr2:addObject(scaleTo3)
            arr2:addObject(scaleTo4)
            local seq = CCSequence:create(arr2)
            tankSp:runAction(seq)
            local tankIconSp = tankSp:getChildByTag(158)
            if tankIconSp then
                tankIconSp:setOpacity(0)
                local fadeIn = CCFadeIn:create(0.3)
                tankIconSp:runAction(fadeIn)
            end
        end
    end
end

--刷新我方部队信息
function believerMatchPlayerDialog:refreshMyTroopsInfo()
    for i=1,6 do
        self:refreshTroops(i,1)
    end
    self:refreshFightLb()
end

--刷新战斗力
function believerMatchPlayerDialog:refreshFightLb()
    if self.troopsBg==nil then
        do return end
    end
    local troopsBgSize=self.baseInfoBg:getContentSize(),self.troopsBg:getContentSize()    
    local fontSize=20
    local fightTag=1001
    local myFightStr=getlocal("plat_war_myPower",{FormatNumber(believerVoApi:getTroopsFight())})
    local myFightLb=tolua.cast(self.troopsBg:getChildByTag(fightTag),"CCLabelTTF")
    if myFightLb==nil then
        myFightLb=GetTTFLabelWrap(myFightStr,fontSize,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
        myFightLb:setAnchorPoint(ccp(1,0.5))
        myFightLb:setTag(fightTag)
        if self.iphoneType==G_iphone4 then
            myFightLb:setPosition(troopsBgSize.width-10,20)
        else
            myFightLb:setPosition(troopsBgSize.width-10,25)
        end
        self.troopsBg:addChild(myFightLb)
    else
        myFightLb:setString(myFightStr)
    end
end

function believerMatchPlayerDialog:tick()
    local goldStr=getlocal("daily_lotto_tip_2")
    local costGems=believerVoApi:getResetMatchCost()
    if costGems~=nil then
        goldStr=costGems
    end
    if self.goldLb then
        self.goldLb:setString(goldStr)
    end
end

function believerMatchPlayerDialog:dispose()
    spriteController:removePlist("public/vipFinal.plist")
    spriteController:removeTexture("public/vipFinal.plist")
    spriteController:removePlist("public/believer/believerEffect.plist")
    spriteController:removeTexture("public/believer/believerEffect.png")
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    if self.parent and self.parent.backToMainDialogHandler then
        self.parent:backToMainDialogHandler()
        self.parent=nil
    end
    self.baseInfoBg=nil
    self.troopsBg=nil
    self.infoLbTb=nil
    self.troopSpTb=nil
    self.goldLb=nil
    self.iphoneType=nil
    self=nil
end

return believerMatchPlayerDialog