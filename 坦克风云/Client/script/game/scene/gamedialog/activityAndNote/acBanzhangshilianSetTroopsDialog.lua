acBanzhangshilianSetTroopsDialog=commonDialog:new()

function acBanzhangshilianSetTroopsDialog:new(cIndex,parent)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.cIndex=cIndex --关卡
    self.parent=parent
    self.setTroops={{},{},{},{},{},{}}  --出战部队
    return nc
end

function acBanzhangshilianSetTroopsDialog:initTableView()
    local function callBack(...)
        -- return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
    self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40, G_VisibleSizeHeight-100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))

    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,400),nil)
    -- self.bgLayer:addChild(self.tv)
    self.tv:setPosition(ccp(20,G_VisibleSizeHeight-480))
    self.tv:setAnchorPoint(ccp(0,0))
    -- self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
    -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    -- self.tv:setMaxDisToBottomOrTop(120)

    self:initPageLayer()
    self:initPageFlag()
    self:initLayer()
end

function acBanzhangshilianSetTroopsDialog:initPageLayer()
    local bgWidth=self.bgLayer:getContentSize().width
    local bgHeight=self.bgLayer:getContentSize().height

    self.list={}
    -- self.dlist={}

    -- local spScaleX=1.15
    -- local spScaleY=1.8
    local buildPosition={
        {{100,200},{300,100},{900,50},{500,250},{800,150},},
        {{600,50},{200,280},{700,250},{900,100},{300,150},},
        {{500,250},{100,50},{330,150},{900,200},{600,100},},
    }
    for i=1,3 do
        local picStr="scene/world_map_mi.jpg"
        -- local picStr="public/Battleshow.jpg"
        -- if i==2 then
        --     picStr="public/Battleshow1.jpg"
        -- end
        local posterSp=CCSprite:create(picStr)
        posterSp:setAnchorPoint(ccp(0.5,1))
        posterSp:setPosition(ccp(bgWidth/2,bgHeight-90))
        self.bgLayer:addChild(posterSp,1)
        local spScaleX=(bgWidth-50)/posterSp:getContentSize().width
        local spScaleY=300/posterSp:getContentSize().height
        posterSp:setScaleX(spScaleX)
        posterSp:setScaleY(spScaleY)
        
        self.list[i]=posterSp
        -- self.dlist[i]=atDialog

        local ppp={}
        for k=1,5 do
            local buildSp=CCSprite:createWithSpriteFrameName("world_island_"..k..".png")
            local posX,posY=buildPosition[i][k][1],buildPosition[i][k][2]
            buildSp:setPosition(ccp(posX,posY))
            buildSp:setScaleX(1/spScaleX)
            buildSp:setScaleY(1/spScaleY)
            posterSp:addChild(buildSp,1)
        end
    end

    self.tankLayer=pageDialog:new()
    local page=1
    local isShowBg=false
    local isShowPageBtn=false
    local function onPage(topage)
        if (battleScene and battleScene.isBattleing==true) then
            do return end
        end
        -- self.curTankTab=self.dlist[topage]
        self.curPageFlag:setPositionX(self.pageFlagPosXTb[topage])
    end
    local posY=(G_VisibleSizeHeight-155-((G_VisibleSizeHeight-160)/3+40))/2+(G_VisibleSizeHeight-160)/3+40
    local leftBtnPos=ccp(40,posY)
    local rightBtnPos=ccp(self.bgLayer:getContentSize().width-40,posY)
    self.tankLayer:create("panelItemBg.png",CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight),CCRect(20, 20, 10, 10),self.bgLayer,ccp(0,0),self.layerNum,page,self.list,isShowBg,isShowPageBtn,onPage,leftBtnPos,rightBtnPos)
    -- self.curTankTab=self.dlist[1]

    local maskSpHeight=self.bgLayer:getContentSize().height-120
    for k=1,3 do
        local leftMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
        leftMaskSp:setAnchorPoint(ccp(0,0))
        -- leftMaskSp:setPosition(0,pos.y+25)
        leftMaskSp:setPosition(0,38)
        leftMaskSp:setScaleY(maskSpHeight/leftMaskSp:getContentSize().height)
        self.bgLayer:addChild(leftMaskSp,6)

        local rightMaskSp=CCSprite:createWithSpriteFrameName("maskBgLeftUse.png")
        -- rightMaskSp:setRotation(180)
        rightMaskSp:setFlipX(true)
        rightMaskSp:setAnchorPoint(ccp(0,0))
        -- rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,pos.y+25)
        rightMaskSp:setPosition(self.bgLayer:getContentSize().width-rightMaskSp:getContentSize().width,38)
        rightMaskSp:setScaleY(maskSpHeight/rightMaskSp:getContentSize().height)
        self.bgLayer:addChild(rightMaskSp,6)
    end
end

function acBanzhangshilianSetTroopsDialog:initPageFlag()
    -- self.pageFlagPosXTb={G_VisibleSizeWidth/2-90,G_VisibleSizeWidth/2-30,G_VisibleSizeWidth/2+30,G_VisibleSizeWidth/2+90}
    -- self.pageFlagPosXTb={G_VisibleSizeWidth/2-30,G_VisibleSizeWidth/2+30}
    self.pageFlagPosXTb={G_VisibleSizeWidth/2-60,G_VisibleSizeWidth/2,G_VisibleSizeWidth/2+60}
    for i=1,3 do
        local pageFlag=CCSprite:createWithSpriteFrameName("circlenormal.png")
        pageFlag:setPosition(ccp(self.pageFlagPosXTb[i],G_VisibleSizeHeight-430))
        self.bgLayer:addChild(pageFlag,1)
    end

    self.curPageFlag=CCSprite:createWithSpriteFrameName("circleSelect.png")
    self.curPageFlag:setPosition(ccp(self.pageFlagPosXTb[1],G_VisibleSizeHeight-430))
    self.bgLayer:addChild(self.curPageFlag,2)
end

function acBanzhangshilianSetTroopsDialog:initLayer()
    local bgWidth=self.bgLayer:getContentSize().width
    local bgHeight=self.bgLayer:getContentSize().height

    -- local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",CCRect(20, 20, 10, 10),cellClick)
    -- backSprie:setContentSize(CCSizeMake(bgWidth-40,80))
    -- backSprie:ignoreAnchorPointForPosition(false)
    -- backSprie:setAnchorPoint(ccp(0.5,1))
    -- backSprie:setIsSallow(false)
    -- backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    -- self.bgLayer:addChild(backSprie,1)
    -- backSprie:setPosition(ccp(bgWidth/2,bgHeight-100-posterSp:getContentSize().height*spScaleY))
    -- local titleLb=GetTTFLabel(getlocal("forceInformation"),30)
    -- titleLb:setPosition(getCenterPoint(backSprie))
    -- backSprie:addChild(titleLb,1)

    local function onAttackDialog()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if (battleScene and battleScene.isBattleing==true) then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)

        local isMax=acBanzhangshilianVoApi:getAttackNumIsMax()
        if isMax==true then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_banzhangshilian_attack_num_limit"),30)
            do return end
        end

        local useTankInfo=acBanzhangshilianVoApi:getUseTankInfo()
        if useTankInfo and SizeOfTable(useTankInfo)>0 then
        else
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_banzhangshilian_no_troops"),30)
            do return end
        end

        local hasSetTroops=false
        if self.setTroops and SizeOfTable(self.setTroops)>0 then
            for k,v in pairs(self.setTroops) do
                if v and v[1] and v[2] and v[2]>0 then
                    hasSetTroops=true
                end
            end
        end
        if hasSetTroops==false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_banzhangshilian_not_set_troops"),30)
            do return end
        end
        
        local action="attack"
        local id=self.cIndex
        local fleetinfo=self.setTroops
        if fleetinfo and SizeOfTable(fleetinfo)>0 then
            local function attackCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData and sData.data then
                        local oldIsUnlock
                        local oldIsComplete
                        local cIndex
                        local completeIndex
                        if self.cIndex then
                            cIndex=acBanzhangshilianVoApi:getChapterByCIndex(self.cIndex)
                            completeIndex=cIndex
                            if completeIndex then
                                if completeIndex>5 then
                                    completeIndex=5
                                end
                            end
                            if cIndex then
                                cIndex=cIndex+1
                                if cIndex>5 then
                                    cIndex=5
                                end
                            end
                        end
                        if cIndex then
                            oldIsUnlock=acBanzhangshilianVoApi:getChapterIsUnlock(cIndex)
                        end
                        if completeIndex then
                            oldIsComplete=acBanzhangshilianVoApi:getChapterIsComplete(completeIndex)
                        end

                        if sData.data.banzhangshilian then
                            acBanzhangshilianVoApi:updateData(sData.data.banzhangshilian)
                        end
                        local totalStar=0
                        if sData.data.star then
                            totalStar=tonumber(sData.data.star) or 0
                        end
                        if sData.data.report then
                            local acVo=acBanzhangshilianVoApi:getAcVo()
                            local challengeCfg=acVo.challengeCfg
                            local firstRate=acVo.firstAward
                            local firstStar=0
                            local star=0
                            local tankNum=0
                            local award={}
                            local report=sData.data.report
                            local isAttacker=true
                            local isFuben=true
                            local landform
                            if challengeCfg and challengeCfg[id] then
                                if challengeCfg[id].reward then
                                    local reward=challengeCfg[id].reward
                                    if reward.star and totalStar and totalStar>0 then
                                        star=reward.star
                                        firstStar=totalStar-star
                                    end
                                    if reward.tRate then
                                        tankNum=reward.tRate
                                    end
                                end
                                if challengeCfg[id].land and tonumber(challengeCfg[id].land) then
                                    local landType=tonumber(challengeCfg[id].land)
                                    landform={landType,landType}
                                end
                            end
                            local selectTid=acBanzhangshilianVoApi:getSelectTank()
                            if selectTid and tankNum and tankNum>0 then
                                local rewardTb={o={}}
                                rewardTb.o[selectTid]=tankNum
                                award=FormatItem(rewardTb)
                            end
                            local acData={type="banzhangshilian",award=award,star=star,firstStar=firstStar,firstRate=firstRate}
                            local bData={data={report=report},isAttacker=isAttacker,isFuben=isFuben,acData=acData,landform=landform}
                            battleScene:initData(bData)
                        end
                        acBanzhangshilianVoApi:setCFlag(0)

                        local newIsUnlock
                        if cIndex then
                            newIsUnlock=acBanzhangshilianVoApi:getChapterIsUnlock(cIndex)
                        end
                        local newIsComplete
                        if completeIndex then
                            newIsComplete=acBanzhangshilianVoApi:getChapterIsComplete(completeIndex)
                        end
                        if cIndex and oldIsUnlock~=nil and newIsUnlock~=nil then
                            if oldIsUnlock~=newIsUnlock then
                                acBanzhangshilianVoApi:setUnlockNewIndex(cIndex)
                            end
                        end
                        if completeIndex and oldIsComplete==false and newIsComplete==true then
                            --通关关卡公告
                            local chapterName={key="activity_banzhangshilian_chapter_name_"..(completeIndex),param={}}
                            local acName={key="activity_banzhangshilian_title",param={}}
                            local message={key="activity_banzhangshilian_complete_chat",param={playerVoApi:getPlayerName(),acName,chapterName}}
                            chatVoApi:sendSystemMessage(message)
                        end

                        if self.parent and self.parent.close then
                            self.parent:close()
                        end
                        self:close()
                    end
                end
            end
            socketHelper:activeBanzhangshilian(action,id,fleetinfo,nil,attackCallback)
        else
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("allianceWarNoArmy"),nil,self.layerNum+1)
        end
    end
    local attackItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onAttackDialog,nil,getlocal("activity_banzhangshilian_attack"),25)
    local attackMenu=CCMenu:createWithItem(attackItem)
    attackMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    attackMenu:setAnchorPoint(ccp(0.5,0.5))
    attackMenu:setPosition(ccp(G_VisibleSizeWidth-150,65))
    self.bgLayer:addChild(attackMenu,3)

    local function onMaxPowerDialog()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if (battleScene and battleScene.isBattleing==true) then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)

        local layer=self.bgLayer
        local maxTb=acBanzhangshilianVoApi:getBestTanks()
        for i=1,6,1 do
            local spA=layer:getChildByTag(i):getChildByTag(2)
            if spA~=nil then
                self:deleteTanksTbByType(i)
                spA:removeFromParentAndCleanup(true)
            end
        end
        for k,v in pairs(maxTb) do
            local sp=layer:getChildByTag(k)
            self:setTanksByType(k,v[1],v[2])
            self:addTouchSp(sp,v[1],v[2],self.layerNum,layer)    
        end
    end
    local maxPowerItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onMaxPowerDialog,nil,getlocal("autoMaxPower"),25)
    local maxPowerMenu=CCMenu:createWithItem(maxPowerItem)
    maxPowerMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    maxPowerMenu:setAnchorPoint(ccp(0.5,0.5))
    maxPowerMenu:setPosition(ccp(150,65))
    self.bgLayer:addChild(maxPowerMenu,3)

    local function touchInfo()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if (battleScene and battleScene.isBattleing==true) then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)

        local td=smallDialog:new()
        local str1=getlocal("activity_banzhangshilian_set_troops_tip")
        local str2=getlocal("activity_banzhangshilian_set_troops_tip_1")
        local tabStr={" ",str2,str1," "}
        local colorTab={nil,G_ColorRed,nil,nil}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,colorTab)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local menuItem = GetButtonItem("SlotInfor.png","SlotInfor.png","SlotInfor.png",touchInfo,11,nil,nil)
    local menu = CCMenu:createWithItem(menuItem)
    menu:setPosition(ccp(G_VisibleSizeWidth/2,65))
    menu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(menu,3)

    self:changeHeroOrTank(self.bgLayer,self.layerNum)
end

function acBanzhangshilianSetTroopsDialog:addTouchSp(parent,id,num,layerNum,layer)
    local function touchSpAdd()
        if (battleScene and battleScene.isBattleing==true) then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)

        -- tankVoApi:deleteTanksTbByType(type,parent:getTag())
        self:deleteTanksTbByType(parent:getTag())
        local spA=parent:getChildByTag(2)
        spA:removeFromParentAndCleanup(true)
    end
    local addLayer=CCLayer:create();
    parent:addChild(addLayer)
    addLayer:setTag(2)
    
    local capInSet = CCRect(20, 20, 10, 10);
    local touchSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touchSpAdd)
    touchSp:setContentSize(CCSizeMake(parent:getContentSize().width, parent:getContentSize().height))
    --local scX=parent:getContentSize().width/touchSp:getContentSize().width
    --local scY=parent:getContentSize().height/touchSp:getContentSize().height
    --touchSp:setScaleX(scX)
    --touchSp:setScaleY(scY)
    touchSp:setPosition(getCenterPoint(parent))
    touchSp:setTouchPriority(-(layerNum-1)*20-5)
    touchSp:setIsSallow(true)
    --touchSp:setOpacity(0)
    addLayer:addChild(touchSp)

    local spAdd=LuaCCSprite:createWithSpriteFrameName(tankCfg[id].icon,touchSpAdd);
    spAdd:setScale(0.6)
    spAdd:setAnchorPoint(ccp(0,0.5));
    spAdd:setIsSallow(true)
    spAdd:setPosition(ccp(5,parent:getContentSize().height/2))
    spAdd:setTouchPriority(-(layerNum-1)*20-5)
    addLayer:addChild(spAdd)

    local cnOrDeXheightPos = nil
    local cnOrDeTheightPos = nil
    local cnOrDeXWidPos = nil
    local cnOrDeTNumheiPos = nil
    if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" then
        cnOrDeXheightPos=25
        cnOrDeXWidPos=25
        cnOrDeTheightPos=55
        cnOrDeTNumheiPos=40
    else
        cnOrDeXheightPos=40
        cnOrDeXWidPos=40
        cnOrDeTheightPos=50
        cnOrDeTNumheiPos=30
    end

    local spDelect=LuaCCSprite:createWithSpriteFrameName("IconFault.png",touchSpAdd);
    spDelect:setAnchorPoint(ccp(0.5,0.5));
    spDelect:setPosition(ccp(parent:getContentSize().width-cnOrDeXWidPos,cnOrDeXheightPos))
    addLayer:addChild(spDelect)
    
    local soldiersLbName = GetTTFLabelWrap(getlocal(tankCfg[id].name),22,CCSizeMake(170,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop);
    soldiersLbName:setAnchorPoint(ccp(0,1));
    soldiersLbName:setPosition(ccp(spAdd:getContentSize().width*0.6+5,parent:getContentSize().height/2+cnOrDeTheightPos));
    addLayer:addChild(soldiersLbName,2);
    
    local soldiersLbNum = GetTTFLabel(num,22);
    soldiersLbNum:setAnchorPoint(ccp(0,0.5));
    soldiersLbNum:setPosition(ccp(spAdd:getContentSize().width*0.6+10,parent:getContentSize().height/2-cnOrDeTNumheiPos));
    addLayer:addChild(soldiersLbNum,2);

end
function acBanzhangshilianSetTroopsDialog:changeHeroOrTank(layer,layerNum)
    local tHeight = G_VisibleSize.height-400

    local function touch(object,name,tag)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        if (battleScene and battleScene.isBattleing==true) then
            do return end
        end
        PlayEffect(audioCfg.mouseClick)

        local function callBack(id,num)
            local sp=layer:getChildByTag(tag)
            -- tankVoApi:setTanksByType(type,tag,id,num)
            self:setTanksByType(tag,id,num)
            self:addTouchSp(sp,id,num,layerNum,layer)
        end
        require "luascript/script/game/scene/gamedialog/warDialog/selectTankDialog"
        local tankData=self:getAllTanksInByType()
        if tankData and tankData[1] and tankData[2] then
            local acVo=acBanzhangshilianVoApi:getAcVo()
            local troopsLimit
            if acVo and acVo.peakNum then
                troopsLimit=acVo.peakNum
            end
            selectTankDialog:showSelectTankDialog(nil,layerNum+1,callBack,tankData,troopsLimit,nil,true)
        end
    end

    local rect = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(20, 20, 10, 10);
    for i=0,1,1 do
        for j=0,2,1 do
            -- local tag=((j+1)+(i*3))*10
            -- if layer:getChildByTag(tag) then
            --     local sp1=layer:getChildByTag(tag)
            --     if sp1 then
            --         sp1:removeFromParentAndCleanup(true)
            --     end
            -- end
            tag=((j+1)+(i*3))
            if layer:getChildByTag(tag) then
                local sp2=layer:getChildByTag(tag)
                if sp2 then
                    sp2:removeFromParentAndCleanup(true)
                end
            end

            local scale=0.9
            local touchSp=LuaCCSprite:createWithSpriteFrameName("emptyTank.png",touch)
            -- touchSp:setPosition(470-300*i,tHeight-100-140*j);
            touchSp:setTag((j+1)+(i*3))
            touchSp:setScale(scale)
            touchSp:setIsSallow(true)

            local tankX=470
            local tankY=120
            layer:addChild(touchSp,2)
            touchSp:setTouchPriority(-(layerNum-1)*20-4)
            touchSp:setPosition(tankX-300*i,tHeight-tankY-130*j)
            if G_isIphone5()==true then
                touchSp:setPosition(tankX-300*i,tHeight-tankY-170*j)
            end
        end
    end
end

--格式化成选取tank面板需要的格式
function acBanzhangshilianSetTroopsDialog:getAllTanksInByType()
    local keyTab={}
    local tab={}
    local tanks=G_clone(acBanzhangshilianVoApi:getAllTanks())
    for k,v in pairs(tanks) do
        if v and v[1] and v[2] then
            for m,n in pairs(self.setTroops) do
                if n and n[1] and n[2] then
                    if v[1]==n[1] then
                        tanks[k][2]=tanks[k][2]-n[2]
                        if tanks[k][2]<0 then
                            tanks[k][2]=0
                        end
                    end
                end
            end
        end
    end
    for k,v in pairs(tanks) do
        if v and v[1] and v[2] and v[2]>0 then
            table.insert(keyTab,{key=v[1]})
            tab[v[1]]={v[2]}
        end
    end
    local tankData={keyTab,tab}
    return tankData
end
function acBanzhangshilianSetTroopsDialog:deleteTanksTbByType(id)
    self.setTroops[id]=nil
    self.setTroops[id]={}
end
function acBanzhangshilianSetTroopsDialog:setTanksByType(id,tid,num)
    self.setTroops[id]={tid,num}
end

function acBanzhangshilianSetTroopsDialog:tick()
    local vo=acBanzhangshilianVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

end

function acBanzhangshilianSetTroopsDialog:refresh()

end

function acBanzhangshilianSetTroopsDialog:dispose()
    self.cIndex=nil
    self.setTroops={{},{},{},{},{},{}}  --出战部队
end