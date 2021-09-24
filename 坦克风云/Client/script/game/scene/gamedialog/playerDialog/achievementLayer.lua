--成就系统的显示内容
achievementLayer={}

function achievementLayer:new()
    local nc={
        switchFlag=false, --切换成就模块的标识
        share=share, --玩家分享的成就数据
        avtLv=0, --当前成就等级
        lastAvtLv=0, --旧的成就等级
        selectCup=nil, --当前各个模块选择显示的奖杯数据
        checkBoxTb=nil, --存储各个成就线单选框
        refreshFlagTb=nil, --存储各个成就模块是否需要重新刷新的标识
        avtTvTb=nil, --各个模块的显示tableView
        moduleAvtTb=nil, --存储各个成就模块的成就完成进度的数据
    }
    setmetatable(nc,self)
    self.__index=self

    return nc
end

function achievementLayer:doUserHandler()
	self.sortIdx={"armor","sequip","weapon","hero","plane","accessory","aitroops"}
	self.personAvtCfg,self.serverAvtCfg={},{}
	local cfg=achievementVoApi:getAchievementCfg()
	for k,v in pairs(cfg.person) do
		if self.personAvtCfg[v.type]==nil then
			self.personAvtCfg[v.type]={}
		end
        table.insert(self.personAvtCfg[v.type],{v,k})
	end
    for k,v in pairs(cfg.all) do
        if self.serverAvtCfg[v.type]==nil then
            self.serverAvtCfg[v.type]={}
        end
        table.insert(self.serverAvtCfg[v.type],{v,k})
    end
    self.avtTvTb,self.checkBoxTb,self.selectCup,self.moduleAvtTb={},{},{},{}
    local function sortFunc(a,b)
        local asortId,bsortId=tonumber(RemoveFirstChar(a[2])),tonumber(RemoveFirstChar(b[2]))
        if asortId<bsortId then
            return true
        end
        return false
    end
    for k,v in pairs(self.sortIdx) do
        table.sort(self.personAvtCfg[v],sortFunc)
        table.sort(self.serverAvtCfg[v],sortFunc)

        local cup=achievementVoApi:getSelectCup(v)
        self.selectCup[v]=cup
        self.checkBoxTb[v]={}

        self:updateModuleAvtProgress(v)
    end
	local avtNum=SizeOfTable(self.personAvtCfg)
	self.cellNum=math.floor(avtNum/3)+(avtNum%3>0 and 1 or 0)
    self.avtNum=avtNum
end

--更新模块成就进度
function achievementLayer:updateModuleAvtProgress(moduleId)
    local total,cur=0,0
    local flag=0
    for k,v in pairs(self.personAvtCfg[moduleId]) do
        local avtcfg,avtId=v[1],v[2]
        for idx,num in pairs(avtcfg.needNum) do
            total=total+1
            flag=achievementVoApi:getAvtState(1,avtId,idx)
            if flag==2 then --已获得该成就奖励
                cur=cur+1
            end
        end
    end
    for k,v in pairs(self.serverAvtCfg[moduleId]) do
        local avtcfg,avtId=v[1],v[2]
        for idx,subcfg in pairs(avtcfg.num) do
            for subIdx,num in pairs(subcfg) do
                total=total+1
                flag=achievementVoApi:getAvtState(2,avtId,idx,subIdx)
                if flag==2 then --已获得该成就奖励
                    cur=cur+1
                end
            end     
        end
    end
    self.moduleAvtTb[moduleId]={cur,total}
end

function achievementLayer:initLayer(layerNum,share)
    self.share=share
    self.layerNum=layerNum
    self:doUserHandler() --初始化一些数据

    spriteController:addPlist("public/youhuaUI3.plist")
    spriteController:addTexture("public/youhuaUI3.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
    spriteController:addPlist("public/avt_images.plist")
    spriteController:addTexture("public/avt_images.png")
    spriteController:addPlist("public/avt_images1.plist")
    spriteController:addTexture("public/avt_images1.png")
    spriteController:addPlist("public/avt_images2.plist")
    spriteController:addTexture("public/avt_images2.png")
    spriteController:addPlist("public/emblem/emblemImage.plist")
    spriteController:addTexture("public/emblem/emblemImage.png")
    spriteController:addPlist("public/youhuaUI4.plist")
    spriteController:addTexture("public/youhuaUI4.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    spriteController:addPlist("public/packsImage.plist")
    spriteController:addTexture("public/packsImage.png")

    self.bgLayer=CCLayer:create()

    self.mainLayer=CCLayer:create()
    self.mainLayer:setPosition(0,0)
    self.bgLayer:addChild(self.mainLayer)

	local bgWidth,bgHeight=616,120
    local upBackSprie=LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png",CCRect(15,15,2,2),function () end)
    upBackSprie:setContentSize(CCSizeMake(bgWidth,bgHeight))
    upBackSprie:setAnchorPoint(ccp(0.5,1))
    upBackSprie:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-85)
    self.bgLayer:addChild(upBackSprie)
    self.upBackSprie=upBackSprie
    if self.share then --分享的数据处理
        local iconWidth=80
        local picName=playerVoApi:getPersonPhotoName(self.share.pic)
        local playerIconSp=playerVoApi:GetPlayerBgIcon(picName,nil,nil,nil,iconWidth,self.share.hfid)
        playerIconSp:setAnchorPoint(ccp(0,0.5))
        playerIconSp:setPosition(15,bgHeight/2)
        upBackSprie:addChild(playerIconSp)

        --玩家名字
        local nameLb=GetTTFLabel(self.share.name,20)
        nameLb:setAnchorPoint(ccp(0,1))
        nameLb:setPosition(playerIconSp:getPositionX()+iconWidth+20,playerIconSp:getPositionY()+iconWidth/2)
        upBackSprie:addChild(nameLb)
        --玩家等级
        local levelLb=GetTTFLabel(getlocal("fightLevel",{self.share.level}),20)
        levelLb:setAnchorPoint(ccp(0,0.5))
        levelLb:setPosition(nameLb:getPositionX(),playerIconSp:getPositionY())
        upBackSprie:addChild(levelLb)
        if self.share.personAvts and self.share.personAvts.level then
            self.avtLv=self.share.personAvts.level
            self.lastAvtLv=self.avtLv
            --玩家成就等级
            local avtLb=GetTTFLabel(getlocal("achievement_level",{self.avtLv}),20)
            avtLb:setAnchorPoint(ccp(0,0))
            avtLb:setPosition(nameLb:getPositionX(),playerIconSp:getPositionY()-iconWidth/2)
            upBackSprie:addChild(avtLb)
        end
    else
        self.avtLv=achievementVoApi:getAchievementLv()
        self.lastAvtLv=self.avtLv
        --成就等级
        local avtLevelLb=GetTTFLabel(getlocal("achievement_level",{self.avtLv}),22)
        avtLevelLb:setAnchorPoint(ccp(0,0.5))
        avtLevelLb:setPosition(10,bgHeight-avtLevelLb:getContentSize().height/2-20)
        upBackSprie:addChild(avtLevelLb)
        self.avtLevelLb=avtLevelLb

        self:createUnlockEffectLb()

        --分享
        local function shareHandler()
            local playerName=playerVoApi:getPlayerName() 
            local message=getlocal("achievement_share_msg",{playerName})
            local tipStr=getlocal("send_share_sucess",{getlocal("google_achievement")})
            local personAvts=achievementVoApi:getPersonAvtData()
            local data={stype=6,uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),level=playerVoApi:getPlayerLevel(),pic=playerVoApi:getPic(),hfid=playerVoApi:getHfid(),personAvts=personAvts}
            G_shareHandler(data,message,tipStr,self.layerNum+1)
        end
        local priority=-(self.layerNum-1)*20-6
        local shareBtn=G_createBotton(upBackSprie,ccp(bgWidth-40,bgHeight/2),nil,"newShareBtn.png","newShareBtn_Down.png","newShareBtn_Down.png",shareHandler,1,priority)
    end

    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)

    local escale=1
    if self.share then --是分享页面的话适配需求
        escale=0.98
    end
    local mainEffectSp=CCSprite:create("public/avt_mainbg.jpg")
    mainEffectSp:setAnchorPoint(ccp(0.5,1))
    mainEffectSp:setScale(escale)
    mainEffectSp:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-215)
    self.mainLayer:addChild(mainEffectSp)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    local barSp=CCSprite:createWithSpriteFrameName("monthlyBar.png")
    barSp:setAnchorPoint(ccp(0.5,1))
    barSp:setPosition(mainEffectSp:getPositionX(),mainEffectSp:getPositionY()+5)
    self.mainLayer:addChild(barSp,5)

    local effectClipper=CCClippingNode:create()
    effectClipper:setContentSize(CCSizeMake(mainEffectSp:getContentSize().width,mainEffectSp:getContentSize().height))
    effectClipper:setAnchorPoint(ccp(0.5,1))
    effectClipper:setScale(escale)
    effectClipper:setPosition(mainEffectSp:getPosition())
    local stencil=CCDrawNode:getAPolygon(CCSizeMake(mainEffectSp:getContentSize().width,mainEffectSp:getContentSize().height),1,1)
    effectClipper:setStencil(stencil)
    self.mainLayer:addChild(effectClipper,1)
    self.effectClipper=effectClipper

    self:playMainLayerEffect()

    self.tvWidth, self.tvHeight, self.cellHeight = 620, mainEffectSp:getPositionY() - mainEffectSp:getContentSize().height - 35, 330
	local function callBack(...)
       return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition((G_VisibleSizeWidth-self.tvWidth)/2,mainEffectSp:getPositionY()-mainEffectSp:getContentSize().height-self.tvHeight-15)
    self.mainLayer:addChild(self.tv)
    if self.cellNum>1 then
        self.tv:setMaxDisToBottomOrTop(80)
        --添加上部的触摸屏蔽层 start
        local top = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function()end)
        top:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - self.tvHeight - self.tv:getPositionY() - 85))
        top:setAnchorPoint(ccp(0.5, 0))
        top:setPosition(G_VisibleSizeWidth / 2, self.tv:getPositionY() + self.tvHeight)
        self.mainLayer:addChild(top)
        top:setTouchPriority(-(self.layerNum - 1) * 20 - 3)
        top:setVisible(false)
        --添加上部的触摸屏蔽层 end
    else
        self.tv:setMaxDisToBottomOrTop(0)
    end

    local function refreshAvts(event,data)
        self:refresh()
    end
    self.refreshListener=refreshAvts
    eventDispatcher:addEventListener("main.avt.refresh",self.refreshListener)

    return self.bgLayer
end

function achievementLayer:createUnlockEffectLb()
    if self.unlockLb and tolua.cast(self.unlockLb,"CCLabelTTF") then
        self.unlockLb:removeFromParentAndCleanup(true)
        self.unlockLb=nil
    end
    if self.upBackSprie==nil then
        do return end
    end
    local unlockLv=achievementVoApi:getNextEffectUnlockLv()
    local unlockStr,colorTb="",{}
    if unlockLv then
        unlockStr=getlocal("achievement_unlock_effectstr",{unlockLv})
        colorTb={nil,G_ColorRed,nil}
    else --全部解锁
        unlockStr=getlocal("achievement_unlock_effectstr3")
        colorTb={G_ColorYellowPro}
    end
    local unlockLb,lbHeight=G_getRichTextLabel(unlockStr,colorTb,20,480,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    unlockLb:setAnchorPoint(ccp(0,1))
    unlockLb:setPosition(10,20+lbHeight)
    self.upBackSprie:addChild(unlockLb)
    self.unlockLb=unlockLb
end

function achievementLayer:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.tvWidth,self.cellHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local spaceX,iconWidth,iconHeight=16,190,260
        local firstPosX=(self.tvWidth-2*spaceX-3*iconWidth)/2
        for i=1,3 do
            local avtIdx=3*idx+i
        	local avttype=self.sortIdx[avtIdx]
        	if avttype==nil then
        		do break end
        	end
            local unlockFlag,openLv=achievementVoApi:getAvtModuleUnlockFlag(avttype,self.share)
            local avtSp
            local function touchHandler()
                if self.share then
                    do return end
                end
                if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                    local function realTouch()
                        if unlockFlag~=1 then
                            if unlockFlag==0 then
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("backstage9000"),28)
                            elseif unlockFlag==2 then
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("equip_explore_unlock",{openLv}),28)
                            elseif unlockFlag==3 then
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("achievement_unlock_effectstr2",{openLv}),28)
                            end
                            do return end
                        end
                        self:showAvtLayer(avttype,avtIdx)
                    end
                    G_touchedItem(avtSp,realTouch,0.8)
                end
            end
        	avtSp=achievementVoApi:getAvtModuleShowIcon(avttype,touchHandler,self.share)
        	avtSp:setPosition(firstPosX+(2*i-1)/2*iconWidth+(i-1)*spaceX,self.cellHeight-35-iconHeight/2)
            avtSp:setTouchPriority(-(self.layerNum-1)*20-2)
        	cell:addChild(avtSp)

        	local avtNameLb=GetTTFLabelWrap(getlocal("achievement_"..avttype.."_name"),20,CCSizeMake(iconWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom,"Helvetica-bold")
        	avtNameLb:setAnchorPoint(ccp(0.5,0))
        	avtNameLb:setPosition(avtSp:getPositionX(),avtSp:getPositionY()+iconHeight/2+5)
        	cell:addChild(avtNameLb)

            local stateStr,colorTb
            if unlockFlag==0 then
                stateStr,colorTb=getlocal("achievement_willOpen"),{}
            elseif unlockFlag==2 then
                stateStr,colorTb=getlocal("alliance_unlock_str2",{"<rayimg>"..openLv.."<rayimg>"}),{nil,G_ColorRed,nil}
            elseif unlockFlag==3 then
                stateStr,colorTb=getlocal("achievement_unlock_effectstr2",{"<rayimg>"..openLv.."<rayimg>"}),{nil,G_ColorRed,nil}
            end
            if stateStr then
                local stateLb,lbHeight=G_getRichTextLabel(stateStr,colorTb,18,iconWidth,kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                stateLb:setAnchorPoint(ccp(0.5,1))
                stateLb:setPosition(iconWidth/2,iconHeight/2+lbHeight/2)
                avtSp:addChild(stateLb,3)
            end

            --判断该成就模块是否有奖励激活
            local function hasReward()
                local flag=false
                for k,v in pairs(self.personAvtCfg[avttype]) do
                    flag=achievementVoApi:isActivateByAvtId(1,v[2])
                    if flag==true then
                        do return flag end
                    end
                end
                for k,v in pairs(self.serverAvtCfg[avttype]) do
                    flag=achievementVoApi:isActivateByAvtId(2,v[2])
                    if flag==true then
                        do return flag end
                    end
                end
                return flag
            end
            if unlockFlag==1 and self.share==nil then --该模块成就已经解锁并且有可以领取的奖励时显示礼包图标，分享的不用显示礼包
                local flag=hasReward()
                if flag==true then
                    local scale=0.4
                    local rewardSp=CCSprite:createWithSpriteFrameName("packs5.png")
                    rewardSp:setScale(scale)
                    rewardSp:setPosition(iconWidth-rewardSp:getContentSize().width*scale/2+10,iconHeight-rewardSp:getContentSize().height*scale/2+10)
                    avtSp:addChild(rewardSp,3)

                    G_addShake(rewardSp) --礼包晃动
                end
            end

            if self.moduleAvtTb[avttype] and self.share==nil then
                local cur,total=self.moduleAvtTb[avttype][1],self.moduleAvtTb[avttype][2]
                local str,color="",G_ColorWhite
                if total>0 and cur>=total then --成就全部达成
                    str,color=getlocal("achievemeng_all_finished"),G_ColorGreen
                else
                    str=getlocal("schedule_count",{cur,total})
                end
                local avtProgressLb=GetTTFLabel(str,18)
                avtProgressLb:setPosition(avtSp:getPositionX(),avtProgressLb:getContentSize().height/2+5)
                avtProgressLb:setColor(color)
                cell:addChild(avtProgressLb)
            end
        end
        return cell
    elseif fn=="ccTouchBegan" then
           self.isMoved=false
           return true
    elseif fn=="ccTouchMoved" then
           self.isMoved=true
    elseif fn=="ccTouchEnded"  then  
    elseif fn=="ccScrollEnable" then
    end
end

function achievementLayer:showMainLayer()
    if self.avtLayer then
        self.avtLayer:setPosition(-99999,0)
        self.avtLayer:setVisible(false)
    end
    self.mainLayer:setPosition(0,0)
    self.mainLayer:setVisible(true)
    self.selectAvtIdx=0
    self:playMainLayerEffect() --成就等级发生变化时，更新主界面动画效果展示
end

function achievementLayer:showAvtLayer(avttype,avtIdx)
    -- print("avttype,avtIdx=====",avttype,avtIdx)
    self.checkBoxTb[avttype]={}
    local avtBgWidth,avtBgHeight=616,G_VisibleSizeHeight-320
    if self.avtLayer==nil then
        self.avtLayer=CCLayer:create()
        self.bgLayer:addChild(self.avtLayer,1)

        local avtBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function () end)
        avtBg:setContentSize(CCSizeMake(avtBgWidth,avtBgHeight))
        avtBg:setAnchorPoint(ccp(0.5,1))
        avtBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-210)
        self.avtLayer:addChild(avtBg)

        local forbidUp=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),function () end)
        forbidUp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-avtBg:getPositionY()-25))
        forbidUp:setAnchorPoint(ccp(0.5,0))
        forbidUp:setOpacity(0)
        forbidUp:setTouchPriority(-(self.layerNum-1)*20-5)
        forbidUp:setPosition(G_VisibleSizeWidth/2,avtBg:getPositionY()-60)
        self.avtLayer:addChild(forbidUp,10)

        local forbidDown=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),function () end)
        forbidDown:setContentSize(CCSizeMake(G_VisibleSizeWidth,avtBg:getPositionY()-avtBgHeight))
        forbidDown:setAnchorPoint(ccp(0.5,0))
        forbidDown:setOpacity(0)
        forbidDown:setTouchPriority(-(self.layerNum-1)*20-5)
        forbidDown:setPosition(G_VisibleSizeWidth/2,0)
        self.avtLayer:addChild(forbidDown,10)

        local nameBg=CCSprite:createWithSpriteFrameName("believerTitleBg.png")
        nameBg:setAnchorPoint(ccp(0.5,1))
        nameBg:setPosition(avtBgWidth/2,avtBgHeight-2)
        avtBg:addChild(nameBg)

        local avtNameLb=GetTTFLabel("",24,true)
        avtNameLb:setPosition(getCenterPoint(nameBg))
        avtNameLb:setColor(G_ColorYellowPro)
        nameBg:addChild(avtNameLb)
        self.avtNameLb=avtNameLb
        -- 添加遮罩层
        local clipperAvt=CCClippingNode:create()
        clipperAvt:setContentSize(CCSizeMake(avtBgWidth-6,avtBgHeight-6))
        clipperAvt:setAnchorPoint(ccp(0.5,1))
        clipperAvt:setPosition(avtBg:getPosition())
        local stencil=CCDrawNode:getAPolygon(CCSizeMake(clipperAvt:getContentSize().width,clipperAvt:getContentSize().height),1,1)
        clipperAvt:setStencil(stencil)
        self.avtLayer:addChild(clipperAvt,3)
        self.clipperAvt=clipperAvt

        local function rightPageHandler()
            if self.switchFlag==true then
                do return end
            end
            self:rightPageHandler()
        end
        local function leftPageHandler()
            if self.switchFlag==true then
                do return end
            end
            self:leftPageHandler()
        end
        self.arrowTb={}
        local arrowPosY=avtBg:getPositionY()-avtBgHeight/2
        local arrowCfg={
            {startPos=ccp(45,arrowPosY),targetPos=ccp(25,arrowPosY),callback=leftPageHandler,angle=0},
            {startPos=ccp(G_VisibleSizeWidth-45,arrowPosY),targetPos=ccp(G_VisibleSizeWidth-25,arrowPosY),callback=rightPageHandler,angle=180}
        }
        for i=1,2 do
            local cfg=arrowCfg[i]
            local arrowBtn=GetButtonItem("leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",function () end,11,nil,nil)
            arrowBtn:setRotation(cfg.angle)
            local arrowMenu=CCMenu:createWithItem(arrowBtn)
            arrowMenu:setAnchorPoint(ccp(0.5,0.5))
            arrowMenu:setTouchPriority(-(self.layerNum-1)*20-5)
            arrowMenu:setPosition(cfg.startPos)
            self.avtLayer:addChild(arrowMenu,3)

            local arrowTouchSp=LuaCCScale9Sprite:createWithSpriteFrameName("newBlackBg.png",CCRect(4,4,1,1),cfg.callback)
            arrowTouchSp:setTouchPriority(-(self.layerNum-1)*20-6)
            arrowTouchSp:setAnchorPoint(ccp(0.5,0.5))
            arrowTouchSp:setContentSize(CCSizeMake(100,100))
            arrowTouchSp:setPosition(cfg.startPos)
            arrowTouchSp:setOpacity(0)
            self.avtLayer:addChild(arrowTouchSp,4)

            local moveTo=CCMoveTo:create(0.5,cfg.targetPos)
            local fadeIn=CCFadeIn:create(0.5)
            local carray=CCArray:create()
            carray:addObject(moveTo)
            carray:addObject(fadeIn)
            local spawn=CCSpawn:create(carray)

            local moveTo2=CCMoveTo:create(0.5,cfg.startPos)
            local fadeOut=CCFadeOut:create(0.5)
            local carray2=CCArray:create()
            carray2:addObject(moveTo2)
            carray2:addObject(fadeOut)
            local spawn2=CCSpawn:create(carray2)

            local seq=CCSequence:createWithTwoActions(spawn2,spawn)
            arrowMenu:runAction(CCRepeatForever:create(seq))

            self.arrowTb[i]={arrowTouchSp,arrowMenu}
        end

        --返回
        local function back()
            self:showMainLayer()
        end
        local priority=-(self.layerNum-1)*20-6
        local backBtn=G_createBotton(self.avtLayer,ccp(G_VisibleSizeWidth/2,60),{getlocal("coverFleetBack"),22},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",back,0.8,priority)
    end
    self.mainLayer:setPosition(-99999,0)
    self.mainLayer:setVisible(false)
    self.avtLayer:setPosition(0,0)
    self.avtLayer:setVisible(true)

    local avtNameStr=getlocal("achievement_"..avttype.."_name")
    self.avtNameLb:setString(avtNameStr)

    self.selectAvtIdx=avtIdx
    if self.avtTvTb[self.selectAvtIdx]==nil then
        self.avtTvTb[self.selectAvtIdx]=self:initAvtContent(avttype)
    end
    for k,v in pairs(self.avtTvTb) do
        if k==self.selectAvtIdx then
            self.avtTvTb[k]:setPosition(0,0)
            self.avtTvTb[k]:setVisible(true)
        else
            self.avtTvTb[k]:setPosition(999,0)
            self.avtTvTb[k]:setVisible(false)
        end
    end
    local flag=0
    self.maxPage=0
    for k,v in pairs(self.sortIdx) do
        flag=achievementVoApi:getAvtModuleUnlockFlag(v)
        if flag==1 then
            self.maxPage=self.maxPage+1
        end
    end
    for k,v in pairs(self.arrowTb) do
        local touchSp,arrowSp=v[1],v[2]
        if touchSp and arrowSp then
            if self.maxPage<=1 then
                touchSp:setVisible(false)
                arrowSp:setVisible(false)
            else
                touchSp:setVisible(true)
                arrowSp:setVisible(true)
            end
        end
    end
end

function achievementLayer:switchEnd()
    local avttype=self.sortIdx[self.selectAvtIdx]
    local avtNameStr=getlocal("achievement_"..avttype.."_name")
    self.avtNameLb:setString(avtNameStr)

    self.switchFlag=false
    --切换成就也完成后如果有数据刷新了，则刷新一下
    local moduleId=self.sortIdx[self.selectAvtIdx]
    if self.refreshFlagTb and self.refreshFlagTb[moduleId] and self.refreshFlagTb[moduleId]==1 then
        local avtTv=self.avtTvTb[self.selectAvtIdx]
        if avtTv then
            local recordPoint=avtTv:getRecordPoint()
            avtTv:reloadData()
            avtTv:recoverToRecordPoint(recordPoint)
        end
        self.refreshFlagTb[moduleId]=0
    end
end

function achievementLayer:initAvtContent(avttype)
    local personAvts,serverAvts=self.personAvtCfg[avttype],self.serverAvtCfg[avttype]
    local pavtNum,savtNum=SizeOfTable(personAvts),SizeOfTable(serverAvts) --成就线的个数
    local tvWidth,tvHeight=self.clipperAvt:getContentSize().width,self.clipperAvt:getContentSize().height-60
    local cellHeightTb={60+(math.floor(pavtNum/3)+(pavtNum%3>0 and 1 or 0))*260,60+(math.floor(savtNum/3)+(savtNum%3>0 and 1 or 0))*260}
    local avtTv
    local function avtHandler(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 2
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(tvWidth,cellHeightTb[idx+1])
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local cellWidth,cellHeight=tvWidth,cellHeightTb[idx+1]
            local avtNum=(idx==0) and pavtNum or savtNum
            avtNum=(math.floor(avtNum/3)+(avtNum%3>0 and 1 or 0))*3
            local titleStr=(idx==0) and getlocal("achievement_person_svt") or getlocal("achievement_server_svt")
            local avtscfg=(idx==0) and personAvts or serverAvts
            local titleBg,titleLb=G_createNewTitle({titleStr,20},CCSizeMake(200,0),nil,nil,"Helvetica-bold")
            titleBg:setPosition(cellWidth/2,cellHeight-30)
            cell:addChild(titleBg)

            local spaceX,iconWidth,iconHeight=12,190,260
            local firstPosX=(cellWidth-2*spaceX-3*iconWidth)/2
            for i=1,avtNum do
                local avtSp    
                local avtcfg=avtscfg[i]
                if avtcfg==nil then --该成就不存在的话，敬请期待
                    avtSp=achievementVoApi:getAvtShowIcon(idx+1)
                else
                    local avtId=avtcfg[2]
                    local function touchHandler()
                        if avtTv and avtTv:getScrollEnable()==true and avtTv:getIsScrolled()==false then
                            local function realTouch() --显示成就线成就详情
                                achievementVoApi:showAvtDetailDialog(idx+1,avtId,self.layerNum+1,self)
                            end
                            G_touchedItem(avtSp,realTouch,0.8)
                        end
                    end
                    avtSp=achievementVoApi:getAvtShowIcon(idx+1,avtId,nil,nil,touchHandler)
                    local stateStr,color="",G_ColorWhite
                    local flag=achievementVoApi:isActivateByAvtId(idx+1,avtId)
                    if flag==true then --可激活
                        stateStr,color=getlocal("achievement_isActivate"),G_LowfiColorGreen
                    else
                        local gtime=achievementVoApi:getActivateTimeByAvtId(idx+1,avtId)
                        if gtime>0 then
                            stateStr=getlocal("activity_xinfulaba_PlayerName",{G_getDataTimeStr(gtime,true,true)})
                            color=G_ColorGray2
                        end
                    end
                    local stateLb=GetTTFLabelWrap(stateStr,18,CCSizeMake(iconWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    stateLb:setPosition(iconWidth/2,25)
                    stateLb:setColor(color)
                    avtSp:addChild(stateLb)

                    local function onSelect(object,fn,tag)
                        if avtTv and avtTv:getScrollEnable()==true and avtTv:getIsScrolled()==false then
                            if G_checkClickEnable()==false then
                                do
                                    return
                                end
                            else
                                base.setWaitTime=G_getCurDeviceMillTime()
                            end
                        end
                        local flag=achievementVoApi:isCupCanSelect(idx+1,avtId) --是否可以选择该成就线的奖杯来显示
                        if flag==false then
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("achievement_cup_disselect"),28)
                            do return end
                        end
                        if self.selectCup and self.selectCup[avttype] then
                            local cup=self.selectCup[avttype]
                            if cup[1]==(idx+1) and cup[2]==avtId then
                                -- print("do not select same cup!!!")
                                do return end
                            end
                        end
                        local function selectCallBack()
                            self.selectCup[avttype]={idx+1,avtId}
                            if self.checkBoxTb[avttype] then
                                for k,v in pairs(self.checkBoxTb[avttype]) do
                                    for kk,vv in pairs(v) do
                                        local checkBox,uncheckBox=vv[1],vv[2]
                                        if checkBox and uncheckBox and tolua.cast(checkBox,"LuaCCSprite") and tolua.cast(uncheckBox,"LuaCCSprite") then
                                            if k==(idx+1) and kk==avtId then
                                                checkBox:setVisible(true)
                                                uncheckBox:setVisible(false)
                                            else
                                                checkBox:setVisible(false)
                                                uncheckBox:setVisible(true)
                                            end
                                        end
                                    end
                                end
                            end
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("achievement_cup_replace_tip"),28)
                        end
                        achievementVoApi:socketAchievementCup(1,avtId,idx+1,nil,selectCallBack)
                    end
                    local selectFlag=achievementVoApi:isCupCanSelect(idx+1,avtId)
                    if selectFlag==true then
                        local checkBoxSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),onSelect)
                        checkBoxSp:setTouchPriority(-(self.layerNum-1)*20-5)
                        checkBoxSp:setContentSize(CCSizeMake(50,50))
                        checkBoxSp:setOpacity(0)
                        checkBoxSp:setPosition(iconWidth-25,75)
                        avtSp:addChild(checkBoxSp,3)
        
                        local function nilFunc()
                        end
                        local checkBox=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtn.png",nilFunc)
                        checkBox:setPosition(getCenterPoint(checkBoxSp))
                        checkBox:setScale(0.6)
                        checkBoxSp:addChild(checkBox)
                        local uncheckBox=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",nilFunc)
                        uncheckBox:setPosition(getCenterPoint(checkBoxSp))
                        uncheckBox:setScale(0.6)
                        checkBoxSp:addChild(uncheckBox)
                        if self.checkBoxTb[avttype][idx+1]==nil then
                            self.checkBoxTb[avttype][idx+1]={}
                        end
                        self.checkBoxTb[avttype][idx+1][avtId]={checkBox,uncheckBox}

                        if self.selectCup and self.selectCup[avttype] then
                            local cup=self.selectCup[avttype]
                            if cup[1]==(idx+1) and cup[2]==avtId then
                                checkBox:setVisible(true)
                                uncheckBox:setVisible(false)
                            end
                        end
                    end

                    --是否可以激活领奖
                    if flag==true then
                        local scale=0.4
                        local rewardSp=CCSprite:createWithSpriteFrameName("packs5.png")
                        rewardSp:setScale(scale)
                        rewardSp:setPosition(iconWidth-rewardSp:getContentSize().width*scale/2+10,iconHeight-rewardSp:getContentSize().height*scale/2+10)
                        avtSp:addChild(rewardSp,3)

                        G_addShake(rewardSp) --礼包晃动
                    end
                end
                avtSp:setPosition(firstPosX+(2*i-1)/2*iconWidth+(i-1)*spaceX,cellHeight-iconHeight/2-40)
                avtSp:setTouchPriority(-(self.layerNum-1)*20-4)
                cell:addChild(avtSp)
            end

            return cell
        elseif fn=="ccTouchBegan" then
               return true
        elseif fn=="ccTouchMoved" then
        elseif fn=="ccTouchEnded" then
        end
    end

    local function callBack(...)
       return avtHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    avtTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
    avtTv:setTableViewTouchPriority(-(self.layerNum-1)*20-5)
    avtTv:setMaxDisToBottomOrTop(80)
    self.clipperAvt:addChild(avtTv)

    return avtTv
end

function achievementLayer:leftPageHandler()
    if self.selectAvtIdx<=1 then
        do return end
    end
    local curAvtTv=self.avtTvTb[self.selectAvtIdx]
    if self.selectAvtIdx>1 then
        self.selectAvtIdx=self.selectAvtIdx-1
    end
    local tvWidth=self.clipperAvt:getContentSize().width
    local leftAvtPosX,centerAvtPosX,rightAvtPosX=-tvWidth,0,tvWidth
    self.switchFlag=true
    local newAvtTv=self.avtTvTb[self.selectAvtIdx]
    if newAvtTv==nil then
        newAvtTv=self:initAvtContent(self.sortIdx[self.selectAvtIdx])
        self.avtTvTb[self.selectAvtIdx]=newAvtTv
    end
    newAvtTv:setPosition(leftAvtPosX,0)
    newAvtTv:setVisible(true)

    local mt=0.5
    local moveTo1=CCMoveTo:create(mt,ccp(rightAvtPosX,0))
    local moveTo2=CCMoveTo:create(mt,ccp(centerAvtPosX,0))
    local function moveEnd()
       curAvtTv:setVisible(false)
       self:switchEnd()
    end
    curAvtTv:runAction(moveTo1)
    newAvtTv:runAction(CCSequence:createWithTwoActions(moveTo2,CCCallFunc:create(moveEnd)))
end

function achievementLayer:rightPageHandler()
    if self.selectAvtIdx>=self.maxPage then
        do return end
    end
    local curAvtTv=self.avtTvTb[self.selectAvtIdx]
    if self.selectAvtIdx<self.maxPage then
        self.selectAvtIdx=self.selectAvtIdx+1
    end
    local tvWidth=self.clipperAvt:getContentSize().width
    local leftAvtPosX,centerAvtPosX,rightAvtPosX=-tvWidth,0,tvWidth
    self.switchFlag=true
    local newAvtTv=self.avtTvTb[self.selectAvtIdx]
    if newAvtTv==nil then
        newAvtTv=self:initAvtContent(self.sortIdx[self.selectAvtIdx])
        self.avtTvTb[self.selectAvtIdx]=newAvtTv
    end
    newAvtTv:setPosition(rightAvtPosX,0)
    newAvtTv:setVisible(true)

    local mt=0.5
    local moveTo1=CCMoveTo:create(mt,ccp(leftAvtPosX,0))
    local moveTo2=CCMoveTo:create(mt,ccp(centerAvtPosX,0))
    local function moveEnd()
       curAvtTv:setVisible(false)
       self:switchEnd()
    end
    curAvtTv:runAction(moveTo1)
    newAvtTv:runAction(CCSequence:createWithTwoActions(moveTo2,CCCallFunc:create(moveEnd)))
    
end

--不同成就等级播放的效果是不一样的
function achievementLayer:playMainLayerEffect()
    if self.tankBodySp==nil then
        local tankBodySp=CCSprite:createWithSpriteFrameName("avttank.png")
        tankBodySp:setPosition(233.5,180.5)
        self.effectClipper:addChild(tankBodySp,3)
        self.tankBodySp=tankBodySp

        local originalPos,targetPos=ccp(379,275.5),ccp(351,255.5)
        local paotouSp=CCSprite:createWithSpriteFrameName("avttankpao.png")
        paotouSp:setPosition(originalPos)
        self.effectClipper:addChild(paotouSp,2)

        local acArr=CCArray:create()
        local moveTo1=CCMoveTo:create(0.2,targetPos) --炮管移动到发射点位置
        local moveTo2=CCMoveTo:create(0.5,originalPos) --炮管恢复到原来的位置
        local function shoot()
            local firePos=ccp(targetPos.x+paotouSp:getContentSize().width/2,targetPos.y+paotouSp:getContentSize().height/2)
            G_playParticle(self.effectClipper,firePos,"scene/loadingEffect/fire.plist",nil,true,0.8,nil,2,38)
        end
        local shootFunc=CCCallFunc:create(shoot)
        acArr:addObject(moveTo1)
        acArr:addObject(shootFunc)
        acArr:addObject(moveTo2)
        acArr:addObject(CCDelayTime:create(math.random(3,6)))
        local seq=CCSequence:create(acArr)
        paotouSp:runAction(CCRepeatForever:create(seq))
        local posType=kCCPositionTypeRelative
        --火焰效果
        local firePosY=-40
        local fireCfg={ccp(600,firePosY),ccp(580,firePosY),ccp(540,firePosY),ccp(500,firePosY),ccp(460,firePosY),ccp(60,firePosY)}
        for k,v in pairs(fireCfg) do
            G_playParticle(self.effectClipper,v,"scene/loadingEffect/burn.plist",posType,true,1,ccp(0.5,0),5)
            G_playParticle(self.effectClipper,v,"scene/loadingEffect/flake.plist",posType,true,1,ccp(0.5,0),5)
            G_playParticle(self.effectClipper,v,"scene/loadingEffect/smog.plist",posType,true,1,ccp(0.5,0),5)
        end
        local extraFlakeCfg={ccp(500,190),ccp(640,140),ccp(460,220)}
        local extraSmogCfg={ccp(650,190)}
        for k,v in pairs(extraFlakeCfg) do
            G_playParticle(self.effectClipper,v,"scene/loadingEffect/flake.plist",posType,true,1,ccp(0.5,0),5)
        end
        for k,v in pairs(extraSmogCfg) do
            G_playParticle(self.effectClipper,v,"scene/loadingEffect/smog.plist",posType,true,1,ccp(0.5,0),5)
        end

        local logoSpName=nil
        if platCfg.platCfgGameLogoSingleFile~=nil and platCfg.platCfgGameLogoSingleFile[G_curPlatName()]~=nil then
            logoSpName=platCfg.platCfgGameLogoSingleFile[G_curPlatName()][G_getCurChoseLanguage()]
        else
            logoSpName=platCfg.platCfgGameLogo[G_curPlatName()][G_getCurChoseLanguage()]
        end
        local newLoadingDisabledCfg=platCfg.platCfgNewLoadingDisabled[G_curPlatName()] --不能使用新的loading效果的配置
        if platCfg.platCfgNewLogoEffect[logoSpName] and newLoadingDisabledCfg==nil then
            logoSpName="Logo_zh.png"
        end
        if logoSpName then
            local logoWidth=250
            local logoSp
            if platCfg.platCfgGameLogoSingleFile~=nil and platCfg.platCfgGameLogoSingleFile[G_curPlatName()]~=nil then
                logoSp=CCSprite:create("scene/logoImage/"..logoSpName)
            else
                logoSp=CCSprite:createWithSpriteFrameName(logoSpName~=nil and logoSpName or "Logo.png")
            end
            logoSp:setScale(logoWidth/logoSp:getContentSize().width)
            logoSp:setPosition(logoWidth/2,60)
            self.effectClipper:addChild(logoSp,4)
        end
    end

    local stage=achievementVoApi:getAchievementCfg().stage
    --播放士兵从山坡上移动的效果
    if self.soldierSp==nil and self.avtLv>=stage[1] then
        local originalPos,targetPos=ccp(-22.5,267),ccp(234,190)
        local soldierSp=CCSprite:createWithSpriteFrameName("avtsoldier_1.png")
        soldierSp:setFlipX(true)
        soldierSp:setVisible(false)
        soldierSp:setPosition(originalPos)
        self.effectClipper:addChild(soldierSp)
        self.soldierSp=soldierSp

        local pzArr=CCArray:create()
        for kk=1,6 do
            local nameStr="avtsoldier_"..kk..".png"
            local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            pzArr:addObject(frame)
        end
        local animation=CCAnimation:createWithSpriteFrames(pzArr)
        animation:setDelayPerUnit(0.1)
        local animate=CCAnimate:create(animation)
        local repeatForever=CCRepeatForever:create(animate)
        soldierSp:runAction(repeatForever)

        local acArr=CCArray:create()
        local function moveBegin()
            self.soldierSp:setVisible(true)
        end
        local mt=8
        local moveTo=CCMoveTo:create(mt,targetPos)
        local function moveEnd()
            self.soldierSp:setPosition(originalPos)
            self.soldierSp:setVisible(false)
        end
        acArr:addObject(CCCallFunc:create(moveBegin))
        acArr:addObject(moveTo)
        acArr:addObject(CCCallFunc:create(moveEnd))
        acArr:addObject(CCDelayTime:create(math.random(1,3)))
        local seq=CCSequence:create(acArr)
        soldierSp:runAction(CCRepeatForever:create(seq))

        if self.lastAvtLv<stage[1] then --说明此次是触发新效果的时机，需要给出一闪一闪的着重表现的效果
            local blinkArr=CCArray:create()
            for i=1,3 do
                local fadeOut=CCFadeOut:create(0.5)
                local fadeIn=CCFadeIn:create(0.5)
                blinkArr:addObject(fadeOut)
                blinkArr:addObject(fadeIn)
                blinkArr:addObject(CCDelayTime:create(0.1))
            end
            local blinkSeq=CCSequence:create(blinkArr)
            soldierSp:runAction(blinkSeq)
        end
    end
    --播放战机划过天空的效果
    if self.flyPlaneSp==nil and self.avtLv>=stage[2] then
        local originalPos,targetPos,originalScale,targetScale=ccp(-112.5,293),ccp(752.5,418),0.3,1
        local flyPlaneSp=CCSprite:createWithSpriteFrameName("avtplanes.png")
        flyPlaneSp:setPosition(originalPos)
        flyPlaneSp:setVisible(false)
        flyPlaneSp:setScale(originalScale)
        self.effectClipper:addChild(flyPlaneSp)
        self.flyPlaneSp=flyPlaneSp

        local acArr=CCArray:create()
        local function moveBegin()
            self.flyPlaneSp:setVisible(true)
            self.flyPlaneSp:setScale(originalScale)
        end
        local mt=1.5
        local moveTo=CCMoveTo:create(mt,targetPos)
        local function moveEnd()
            self.flyPlaneSp:setPosition(originalPos)
            self.flyPlaneSp:setVisible(false)
        end
        acArr:addObject(CCCallFunc:create(moveBegin))
        local scaleTo=CCScaleTo:create(mt,targetScale)
        local spawnArr=CCArray:create()
        spawnArr:addObject(moveTo)
        spawnArr:addObject(scaleTo)
        local spawn=CCSpawn:create(spawnArr)
        acArr:addObject(spawn)
        acArr:addObject(CCCallFunc:create(moveEnd))
        acArr:addObject(CCDelayTime:create(math.random(1,3)))
        local seq=CCSequence:create(acArr)
        flyPlaneSp:runAction(CCRepeatForever:create(seq))

        if self.lastAvtLv<stage[2] then --说明此次是触发新效果的时机，需要给出一闪一闪的着重表现的效果
            local blinkArr=CCArray:create()
            for i=1,3 do
                local fadeOut=CCFadeOut:create(0.2)
                local fadeIn=CCFadeIn:create(0.2)
                blinkArr:addObject(fadeOut)
                blinkArr:addObject(fadeIn)
                blinkArr:addObject(CCDelayTime:create(0.1))
            end
            local blinkSeq=CCSequence:create(blinkArr)
            flyPlaneSp:runAction(blinkSeq)
        end
    end
    --播放副将的效果
    local function flickStar(target,pos,scale,dt,intervalt)
        local blingSp=CCSprite:createWithSpriteFrameName("emblemBling.png")
        blingSp:setPosition(pos)
        blingSp:setScale(0)
        blingSp:setOpacity(0)
        target:addChild(blingSp,10)

        local time,rag=0.8,360
        local scaleTo1=CCScaleTo:create(time,scale)
        local fade1=CCFadeIn:create(time)
        local rotate1=CCRotateBy:create(time,rag)
        local spawnArr1=CCArray:create()
        spawnArr1:addObject(scaleTo1)
        spawnArr1:addObject(fade1)
        spawnArr1:addObject(rotate1)
        local spawnArr2=CCArray:create()
        local scaleTo2=CCScaleTo:create(time,0)
        local fade2=CCFadeOut:create(time)
        local rotate2=CCRotateBy:create(time,rag)
        spawnArr2:addObject(scaleTo2)
        spawnArr2:addObject(fade2)
        spawnArr2:addObject(rotate2)
        local spawn1=CCSpawn:create(spawnArr1)
        local spawn2=CCSpawn:create(spawnArr2)
        local acArr=CCArray:create()
        if dt and dt>0 then
            acArr:addObject(CCDelayTime:create(dt))
        end
        acArr:addObject(spawn1)
        acArr:addObject(spawn2)
        if intervalt and intervalt>0 then
            acArr:addObject(CCDelayTime:create(intervalt))
        end
        local seq=CCSequence:create(acArr)
        blingSp:runAction(CCRepeatForever:create(seq))
    end
    if self.viceHeroSp==nil and self.avtLv>=stage[3] then
        local heroSp=CCSprite:createWithSpriteFrameName("avthero1.png")
        heroSp:setPosition(523,128)
        self.effectClipper:addChild(heroSp,6)
        self.viceHeroSp=heroSp

        local function flick()
            flickStar(self.effectClipper,ccp(613.5,239.5),0.6,0,5) --指尖闪光
            flickStar(self.effectClipper,ccp(506.5,113.5),0.5,1,3) --勋章闪光
        end
        if self.lastAvtLv<stage[3] then --说明此次是触发新效果的时机，需要给出一闪一闪的着重表现的效果
            heroSp:setOpacity(0)
            local fadeIn=CCFadeIn:create(2)
            local flickFunc=CCCallFunc:create(flick)
            heroSp:runAction(CCSequence:createWithTwoActions(fadeIn,flickFunc))
        else
            flick()
        end
    end
    --播放主将的效果
    if self.mainHeroSp==nil and self.avtLv>=stage[4] then
        local heroSp=CCSprite:createWithSpriteFrameName("avthero2.png")
        heroSp:setPosition(386,126.5)
        self.effectClipper:addChild(heroSp,7)
        self.mainHeroSp=heroSp
        local function flick()
            flickStar(self.effectClipper,ccp(465.5,112.5),0.4,0.5,3) --勋章闪光
            flickStar(self.effectClipper,ccp(423.5,127.5),0.5,1.5,2) --勋章闪光
        end
        if self.lastAvtLv<stage[4] then --说明此次是触发新效果的时机，需要给出一闪一闪的着重表现的效果
            heroSp:setOpacity(0)
            local fadeIn=CCFadeIn:create(2)
            local flickFunc=CCCallFunc:create(flick)
            heroSp:runAction(CCSequence:createWithTwoActions(fadeIn,flickFunc))
        else
            flick()
        end
    end
    self.lastAvtLv=self.avtLv
end

function achievementLayer:refresh()
    local curLv=achievementVoApi:getAchievementLv()
    if curLv~=self.avtLv then --等级发生变化时刷新等级相关
        self.avtLv=curLv

        self:createUnlockEffectLb()

        if self.avtLevelLb and tolua.cast(self.avtLevelLb,"CCLabelTTF") then
            self.avtLevelLb:setString(getlocal("achievement_level",{self.avtLv}))
        end
    end
    self.refreshFlagTb={}
    for k,v in pairs(self.sortIdx) do
        if self.selectAvtIdx==nil or k~=self.selectAvtIdx then
            self.refreshFlagTb[v]=1 --给各个模块设置刷新标识
        end
        self:updateModuleAvtProgress(v)
    end
    if self.tv then
        local recordPoint=self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
    --刷新当前打开的成就模块页面
    if self.selectAvtIdx and self.selectAvtIdx>0 and self.avtTvTb and self.avtTvTb[self.selectAvtIdx] then
        local avtTv=self.avtTvTb[self.selectAvtIdx]
        if avtTv then
            local recordPoint=avtTv:getRecordPoint()
            avtTv:reloadData()
            avtTv:recoverToRecordPoint(recordPoint)
        end
    end
end

function achievementLayer:dispose()
    self.switchFlag=nil
	self.share=nil
    self.avtLv=nil
    self.lastAvtLv=nil
    self.effectClipper=nil
    self.refreshFlagTb=nil
    self.arrowTb=nil
    self.moduleAvtTb=nil
    self.tankBodySp=nil
    self.soldierSp=nil
    self.flyPlaneSp=nil
    self.mainHeroSp=nil
    self.heroSp=nil
    self.sortIdx=nil
    self.personAvtCfg=nil
    self.serverAvtCfg=nil
    self.avtLayer=nil
    self.mainLayer=nil
    self.tv=nil
    self.avtTvTb=nil
    self.checkBoxTb=nil
    self.selectCup=nil
    self.moduleAvtTb=nil
    spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
    spriteController:removePlist("public/avt_images.plist")
    spriteController:removeTexture("public/avt_images.png")
    spriteController:removePlist("public/avt_images1.plist")
    spriteController:removeTexture("public/avt_images1.png")
    spriteController:removePlist("public/avt_images2.plist")
    spriteController:removeTexture("public/avt_images2.png")
    spriteController:removePlist("public/emblem/emblemImage.plist")
    spriteController:removeTexture("public/emblem/emblemImage.png")
    spriteController:removePlist("public/packsImage.plist")
    spriteController:removeTexture("public/packsImage.png")
    if self.refreshListener then
        eventDispatcher:removeEventListener("main.avt.refresh",self.refreshListener)
        self.refreshListener=nil
    end
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
    package.loaded["luascript/script/game/scene/gamedialog/playerDialog/achievementLayer"]=nil
end