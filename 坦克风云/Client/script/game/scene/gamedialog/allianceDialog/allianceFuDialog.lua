--require "luascript/script/componet/commonDialog"
allianceFuDialog=commonDialog:new()

function allianceFuDialog:new(tabType,layerNum,closeCallback)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.leftBtn=nil
    self.expandIdx={}
    self.layerNum=layerNum
    self.closeCallback = closeCallback
    self.rewardWidget=nil
    self.ownNumLb=nil
    self.availableNumLb=nil
    self.chapterCount=0
    self.rewardShow=false
    return nc
end

--设置或修改每个Tab页签
-- function allianceFuDialog:resetTab()

--     local index=0
--     for k,v in pairs(self.allTabs) do
--          local  tabBtnItem=v

--          if index==0 then
--          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
--          elseif index==1 then
--          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
--          elseif index==2 then
--          tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)

--          end
--          if index==self.selectedTabIndex then
--              tabBtnItem:setEnabled(false)
--          end
--          index=index+1
--     end    
    
-- end

        
--设置对话框里的tableView
function allianceFuDialog:initTableView()


    if self.panelLineBg then
        self.panelLineBg:setVisible(false)
    end
  
    if self.panelTopLine then
        self.panelTopLine:setVisible(false)
    end

    -- 去渐变线
    local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
    panelBg:setAnchorPoint(ccp(0.5,0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
    panelBg:setPosition(G_VisibleSizeWidth/2,2)
    self.bgLayer:addChild(panelBg)


    self.chapterCount=SizeOfTable(allianceFubenVoApi:getChapterCfg())
    local baseCount=allianceFubenVoApi:getBaseChapterNum()
    if self.chapterCount==baseCount and base.fbboss==1 then
        self.chapterCount=self.chapterCount+1
    end
    local function refreshFuben()
        if(self and self.bgLayer and tolua.cast(self.bgLayer,"CCNode"))then
            if self and self.tv then
                self:doUserHandler()
                self.tv:reloadData()
            else
                self:initTableView2()
            end
        end
    end
    if allianceFubenVoApi:getFlag(1)==-1 then
        local function achallengeGetHandler(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if base.fbboss==1 then
                    local function allianceBossGetHandler(fn,bossdata)
                        local cret,cData=base:checkServerData(bossdata)
                        if cret==true then
                            refreshFuben()
                            allianceFubenVoApi:setFlag(1,1)
                        end   
                    end
                    socketHelper:allianceBossGet(allianceBossGetHandler)
                else
                    refreshFuben()
                    allianceFubenVoApi:setFlag(1,1)
                end
            end
        end
        socketHelper:achallengeGet(achallengeGetHandler)
    else
        refreshFuben()
    end
end


--设置对话框里的tableView
function allianceFuDialog:initTableView2()
    
    local function nilFunc( ... )
    end
    local tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilFunc)
    tvBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,G_VisibleSizeHeight-340))
    tvBg:setAnchorPoint(ccp(0.5,0))
    tvBg:setIsSallow(false)
    tvBg:setTouchPriority(-(self.layerNum-1)*20-2)
    tvBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,120))
    self.bgLayer:addChild(tvBg)

    local function callBack4(...)
       return self:eventHandler4(...)
    end
    local hd4= LuaEventHandler:createHandler(callBack4)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd4,CCSizeMake(self.bgLayer:getContentSize().width-40,G_VisibleSizeHeight-350),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,125))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    local rect = CCRect(0, 0, 50, 50)
    -- local capInSet = CCRect(60, 20, 1, 1)
    local capInSet = CCRect(20, 20, 10, 10)
    local function touch(hd,fn,idx)

    end
    local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png",CCRect(15,15,2,2),function ( ) end)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, 120))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0,0))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    backSprie:setPosition(ccp(20,self.bgLayer:getContentSize().height-214))
    self.bgLayer:addChild(backSprie)

    local fubenVo=allianceFubenVoApi:getFuben()
    local attackCount=fubenVo.attackCount or 0

    local attackMaxNum=allianceFubenVoApi:getDailyAttackNum()
    self.attackNumLb=GetTTFLabel(getlocal("alliance_fuben_attack_num",{attackCount,attackMaxNum}),20,true)
    self.attackNumLb:setAnchorPoint(ccp(0,0.5))
    self.attackNumLb:setPosition(10,backSprie:getContentSize().height/2+15)
    backSprie:addChild(self.attackNumLb,1)

    local descLb=GetTTFLabelWrap(getlocal("alliance_fuben_desc"),20,CCSizeMake(self.bgLayer:getContentSize().width-140,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    descLb:setAnchorPoint(ccp(0,0.5))
    descLb:setPosition(10,backSprie:getContentSize().height/2-20)
    backSprie:addChild(descLb,1)
    descLb:setColor(G_ColorYellowPro)

    local function touchTip()
        local tabStr= {}
        for i=1,7 do
            table.insert(tabStr,getlocal("alliance_fuben_tip_"..i))
        end
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
    end
    G_addMenuInfo(backSprie,self.layerNum,ccp(backSprie:getContentSize().width-50,backSprie:getContentSize().height/2),{},nil,nil,28,touchTip,true)
    
    self:initGetAllRewardsView()

end

function allianceFuDialog:eventHandler4(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.chapterCount
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-40,140)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local fubenVo=allianceFubenVoApi:getFuben()
        local isBossFu=allianceFubenVoApi:isBossFuben(idx+1)
        local chapterCfg=allianceFubenVoApi:getChapterCfg()
        local unlockId=fubenVo.unlockId or 1
        local playerLv=playerVoApi:getPlayerLevel()
        local limitLv=0
        local chapter
        local unlock=false
        local preComplete=true --当前章节的前一个章节是否完成
        local killNum=0
        local maxKillStr=""
        local awardNum=0
        local maxAwardStr=""
        local unlockStr
        if isBossFu==true then
            limitLv=allianceFubenVoApi:getBossFubenLimitLv()
            chapter=allianceFubenVoApi:getBossChapterCfg()
            unlock=allianceFubenVoApi:isBossFubenUnlock()
            local baseCount=allianceFubenVoApi:getBaseFubenNum()
            if unlockId>=tonumber(baseCount+1) then
                preComplete=true
            else
                preComplete=false
            end
            if playerLv<tonumber(limitLv) then
                unlock=false
            end
            killNum=allianceFubenVoApi:getAllianceBossKillCount()
            awardNum=allianceFubenVoApi:getbcount()
            maxKillStr=getlocal("infinity")
            maxAwardStr=getlocal("infinity")
        else
            limitLv=allianceFubenVoApi:getBaseFubenLimitLv(tonumber(idx+1))
            chapter=chapterCfg[idx+1]
            local unlockChapterId=math.ceil(unlockId/chapter.maxNum)
            if tonumber(idx+1)>1 then
                if idx<unlockChapterId and unlockId>=tonumber(idx)*tonumber(chapter.maxNum) then
                    preComplete=true
                else
                    preComplete=false
                end
            end
            if tonumber(idx+1)<=unlockChapterId and playerLv>=tonumber(limitLv) then
                unlock=true
            end
            local killNumTab=fubenVo.killCount or {}
            local awardNumTab=fubenVo.rewardCount or {}

            if killNumTab and SizeOfTable(killNumTab)>0 then
                for k,v in pairs(killNumTab) do
                    if tonumber(v) and tonumber(v)>(((idx+1)-1)*chapter.maxNum) and tonumber(v)<=((idx+1)*chapter.maxNum) then
                        killNum=killNum+1
                    end
                end
            end
            if awardNumTab and SizeOfTable(awardNumTab)>0 then
                for k,v in pairs(awardNumTab) do
                    if tonumber(v) and tonumber(v)>(((idx+1)-1)*chapter.maxNum) and tonumber(v)<=((idx+1)*chapter.maxNum) then
                        awardNum=awardNum+1
                    end
                end
            end
            maxKillStr=tostring(chapter.maxNum)
            maxAwardStr=tostring(chapter.awardMaxNum)
        end
  
        local capInSet = CCRect(20, 20, 10, 10)
        local function cellClick(hd,fn,idx)
        end
        -- local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",capInSet,cellClick)    
        local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
        backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40, 140))
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0.5,0))
        backSprie:setTag(idx)
        backSprie:setIsSallow(false)
        backSprie:setOpacity(0)
        backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprie:setPosition(ccp((self.bgLayer:getContentSize().width-40)/2,0))
        cell:addChild(backSprie,1)


        local fubenSp=CCSprite:createWithSpriteFrameName(chapter.icon)
        fubenSp:setAnchorPoint(ccp(0.5,0.5))
        local scale=1
        fubenSp:setScaleX(scale)
        fubenSp:setPosition(ccp(10+fubenSp:getContentSize().width/2*scale,fubenSp:getContentSize().height/2+10))
        backSprie:addChild(fubenSp,1)

        local function nilFunc( ... )
            -- body
        end
        local titleSpire = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),nilFunc)
        titleSpire:setContentSize(CCSizeMake(G_VisibleSizeWidth-150-40,32))
        titleSpire:setAnchorPoint(ccp(0,0.5))
        backSprie:addChild(titleSpire)
        titleSpire:setPosition(ccp(10,backSprie:getContentSize().height-20))

        local nameLb=GetTTFLabel(getlocal(chapter.name),25,true)
        nameLb:setAnchorPoint(ccp(0,0.5))
        nameLb:setPosition(ccp(25,titleSpire:getContentSize().height/2))
        titleSpire:addChild(nameLb,1)
        nameLb:setColor(G_ColorYellowPro)

        if preComplete==false then
            unlockStr=getlocal("alliance_unlock_str1")
        elseif playerLv<tonumber(limitLv) then
            unlockStr=getlocal("alliance_unlock_str2",{limitLv})
        end
        if unlock==false then
            local function touchLuaSpr()
             
            end

            fubenSp:setColor(ccc3(80,80,80))
            -- nameLb:setColor(G_ColorGray)
            
            local lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
            lockSp:setAnchorPoint(CCPointMake(0.5,0.5))
            lockSp:setPosition(ccp(10+fubenSp:getContentSize().width/2*scale,backSprie:getContentSize().height/2))
            local lockScale=0.8
            lockSp:setScaleX(lockScale*1/scale)
            lockSp:setScaleY(lockScale)
            backSprie:addChild(lockSp,2)

            if unlockStr then
                local unlockLb=GetTTFLabel(unlockStr,25,true)
                unlockLb:setAnchorPoint(ccp(1,0))
                unlockLb:setPosition(ccp(backSprie:getContentSize().width-30,backSprie:getContentSize().height/2+30))
                backSprie:addChild(unlockLb,1)
                unlockLb:setColor(G_ColorRed)
            end
        end

        local star=chapter.star
        local starNum=math.ceil(star)
        local starSize=26
        local spaceWidth=28
        for i=1,starNum do
            local cStar
            local starScale=1
            if i==starNum and ((star*2)%2)>0 then
                -- cStar=CCSprite:createWithSpriteFrameName("starIconEmpty.png")
                cStar=CCSprite:createWithSpriteFrameName("gameoverstar_black.png")
                starScale=starSize/cStar:getContentSize().width
            else
                cStar=CCSprite:createWithSpriteFrameName("StarIcon.png")
                -- cStar=CCSprite:createWithSpriteFrameName("gameoverstar_gray.png")
                starScale=starSize/cStar:getContentSize().width
            end
            cStar:setAnchorPoint(ccp(0.5,0.5))
            cStar:setScale(starScale)

            local firstX=(fubenSp:getContentSize().width*scale-(spaceWidth*starNum))/2
            cStar:setPosition(ccp(firstX+starSize/2+spaceWidth*(i-1),fubenSp:getContentSize().height/2*scale))
            -- cStar:setPosition(ccp(30+fubenSp:getContentSize().width*scale+difficultyLb:getContentSize().width+spaceWidth*(i-1),68))
            -- backSprie:addChild(cStar,1)
            fubenSp:addChild(cStar,1)
        end
      
        local killNumLb=GetTTFLabel(getlocal("alliance_fuben_kill",{killNum,maxKillStr}),22,true)
        killNumLb:setAnchorPoint(ccp(0,0))
        killNumLb:setPosition(ccp(20+fubenSp:getContentSize().width*scale,60))
        backSprie:addChild(killNumLb,1)

        local awardNumLb=GetTTFLabel(getlocal("alliance_fuben_award",{awardNum,maxAwardStr}),22,true)
        awardNumLb:setAnchorPoint(ccp(0,0))
        awardNumLb:setPosition(ccp(20+fubenSp:getContentSize().width*scale,20))
        backSprie:addChild(awardNumLb,1)

        -- local awardNumLb=GetTTFLabel(getlocal("scheduleChapter",{0,chapter.awardMaxNum}),25)
        -- awardNumLb:setAnchorPoint(ccp(0.5,1))
        -- awardNumLb:setPosition(ccp(backSprie:getContentSize().width-75,backSprie:getContentSize().height-50))
        -- backSprie:addChild(awardNumLb,1)

        local function enterFubenHandler(tag,object)
            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                PlayEffect(audioCfg.mouseClick)
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                
                local chapterId=tag
                local isBossFu=allianceFubenVoApi:isBossFuben(chapterId)
                local playerLv=playerVoApi:getPlayerLevel()
                local baseLimit=allianceFubenVoApi:getBaseFubenLimitLv(tag) --普通副本限制等级
                local bossLimit=allianceFubenVoApi:getBossFubenLimitLv() --boss副本限制等级
                if playerLv<baseLimit and tag>1 and isBossFu==false then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_fuben_lvlimit",{baseLimit}),30)
                    do return end
                elseif playerLv<bossLimit and tag>1 and isBossFu==true then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_fuben_lvlimit",{bossLimit}),30)
                    do return end
                end

                local isCall=false
                if isBossFu==true then
                    -- local killCount=allianceFubenVoApi:getAllianceBossKillCount()
                    -- local function allianceBossGetHandler(fn,bossdata)
                    --     local cret,cData=base:checkServerData(bossdata)
                    --     if cret==true then
                    --         allianceFubenScene:setShow(self.layerNum+1,chapterId)
                    --         local curKill=allianceFubenVoApi:getAllianceBossKillCount()
                    --         if tonumber(curKill)~=tonumber(killCount) then
                    --             allianceFubenVoApi:setFlag(1,0)
                    --         end
                    --     end
                    -- end
                    -- socketHelper:allianceBossGet(allianceBossGetHandler)
                    allianceFubenScene:setShow(self.layerNum+1,chapterId)
                else
                    local fubenVo1=allianceFubenVoApi:getFuben()
                    local unlockId1=fubenVo1.unlockId or 1
                    local unlockChapterId1=math.ceil(unlockId1/chapter.maxNum)
                    local minsid=(chapterId-1)*chapter.maxNum+1
                    local maxsid=chapterId*chapter.maxNum
                    for i=minsid,maxsid do
                        if fubenVo1.tank==nil or (fubenVo1.tank~=nil and fubenVo1.tank[i]==nil) then
                            isCall=true
                        end
                    end
                    if idx+1<=unlockChapterId1 then
                        -- if allianceFubenVoApi:getFlag(3)<=0 then
                        if isCall==true then
                            local function achallengeListCallback(fn,data)
                                local ret,sData=base:checkServerData(data)
                                if ret==true then
                                    -- allianceFubenVoApi:setFlag(3,1)
                                    allianceFubenScene:setShow(self.layerNum+1,chapterId)
                                end
                            end
                            socketHelper:achallengeList(minsid,maxsid,achallengeListCallback)
                        else
                            allianceFubenScene:setShow(self.layerNum+1,chapterId)
                        end
                    end
                end
            end
        end
        local viewItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png.png","newGreenBtn.png",enterFubenHandler,idx+1,getlocal("alliance_list_check_info"),30)
        local btnScale=0.8
        viewItem:setScale(btnScale)
        local viewMenu=CCMenu:createWithItem(viewItem)
        viewMenu:setAnchorPoint(ccp(0.5,0.5))
        viewMenu:setPosition(ccp(backSprie:getContentSize().width-viewItem:getContentSize().width/2*btnScale-10-20,viewItem:getContentSize().height/2*btnScale+20))
        viewMenu:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprie:addChild(viewMenu,2)

        if unlock==false then
            viewItem:setEnabled(false)
        end

        local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
        lineSp:setContentSize(CCSizeMake(G_VisibleSizeWidth-40-10, 2))
        lineSp:setPosition((G_VisibleSizeWidth-40)/2,5)
        cell:addChild(lineSp, 2)

        return cell

    elseif fn=="ccTouchBegan" then
           self.isMoved=false
           return true
    elseif fn=="ccTouchMoved" then
           self.isMoved=true
    elseif fn=="ccTouchEnded"  then
           
    elseif fn=="ccScrollEnable" then
        if newGuidMgr:isNewGuiding()==true then
            return 0
        else
            return 1
        end
    end
end

--点击tab页签 idx:索引
function allianceFuDialog:tabClick(idx)
    PlayEffect(audioCfg.mouseClick)
    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            self:tabClickColor(idx)
            self:doUserHandler()
         else
            v:setEnabled(true)
         end
    end
    self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function allianceFuDialog:doUserHandler()

    if self.attackNumLb then
        local attackMaxNum=allianceFubenVoApi:getDailyAttackNum()
        local fubenVo=allianceFubenVoApi:getFuben()
        self.attackNumLb:setString(getlocal("alliance_fuben_attack_num",{fubenVo.attackCount,attackMaxNum}))
    end

end

--显示一键领取奖励的面板
function allianceFuDialog:initGetAllRewardsView()
    local ownNum,availableNum,costDonate,fubenIdTb,bcount,bossCount,remainbcount=allianceFubenVoApi:getFunbenRewards()
    if self.rewardWidget==nil then
        local function nilFun()
        end
        local rewardBgSP=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),nilFun)
        rewardBgSP:setContentSize(CCSizeMake(G_VisibleSize.width-40,100))
        rewardBgSP:setAnchorPoint(ccp(0.5,0))
        rewardBgSP:setPosition(self.bgLayer:getContentSize().width/2,-3*rewardBgSP:getContentSize().height-20)
        self.bgLayer:addChild(rewardBgSP,2)
        rewardBgSP:setOpacity(0)

        local ownNumLb=GetTTFLabel(getlocal("alliance_own_rewards",{ownNum}),25,true)
        ownNumLb:setAnchorPoint(ccp(0,0))
        ownNumLb:setPosition(15,rewardBgSP:getContentSize().height/2+5)
        rewardBgSP:addChild(ownNumLb)

        local availableNumLb=GetTTFLabel(getlocal("alliance_rewards_available",{availableNum}),25,true)
        availableNumLb:setAnchorPoint(ccp(0,1))
        availableNumLb:setPosition(15,rewardBgSP:getContentSize().height/2-5)
        rewardBgSP:addChild(availableNumLb)

        self.rewardWidget=rewardBgSP
        self.ownNumLb=ownNumLb
        self.availableNumLb=availableNumLb

        local function rewardsHandler()

            PlayEffect(audioCfg.mouseClick)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            -- local ownNum,availableNum,costDonate,fubenIdTb,bcount,bossCount,remainbcount=allianceFubenVoApi:getFunbenRewards()
            -- if tonumber(availableNum)<=0 then
            --     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage8038"),30)
            --     do return end
            -- end

            local ownNum,availableNum,costDonate,fubenIdTb,bcount,bossCount,remainbcount,freeBoxFubenIdTb,costBoxFubenIdTb,needCostDonate=allianceFubenVoApi:getFunbenRewards(true)
            local freeBoxCount = SizeOfTable(freeBoxFubenIdTb)
            -- local costBoxCount = SizeOfTable(costBoxFubenIdTb)+bcount

            local function confirmHandler(param)
                local fubenIdTb = (param == 1) and freeBoxFubenIdTb or fubenIdTb
                local bcount = (param == 1) and 0 or bcount
                local function rewardsCallBack(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        local reward=sData.data.reward
                        local rewardTab=FormatItem(reward)

                        for k,v in pairs(rewardTab) do
                            G_addPlayerAward(v.type,v.key,v.id,v.num)
                        end
                        for k,fubenId in pairs(fubenIdTb) do
                            allianceFubenVoApi:setRewardCount(tonumber(fubenId))
                        end
                        allianceFubenVoApi:setBossRewardCount(bcount)
                        local uid=playerVoApi:getUid()
                        local canUseDonate=allianceMemberVoApi:getCanUseDonate(uid) --可以使用的个人贡献值
                        local costDonate = (param == 1) and 0 or costDonate
                        allianceMemberVoApi:setUseDonate(uid,allianceMemberVoApi:getUseDonate(uid)+costDonate)
                        self:refreshRewardWidget()
                        --弹出奖励面板
                        require "luascript/script/game/scene/gamedialog/allianceDialog/allianceFubenSmallDialog"
                        local customNum=tonumber(availableNum)-tonumber(bossCount)
                        local bossCount = (param == 1) and 0 or bossCount
                        local data={customNum=customNum,bcount=bcount,bossCount=bossCount,remainbcount=remainbcount,curDonate=canUseDonate,costDonate=costDonate,rewardTab=rewardTab}
                        smallDialog:showAllianceRewardsDialog("TankInforPanel.png",CCSizeMake(550,680),CCRect(0,0,400,350),CCRect(130,50,1,1),data,nil,false,false,self.layerNum+1)
                        if self and self.tv then
                            self.tv:reloadData()
                        end
                    end
                end
                socketHelper:allianceRewardGetOneTime(fubenIdTb,bcount,rewardsCallBack)
            end
            --测试用
            -- local reward=allianceFubenVoApi:getBossFubenRewards()
            -- local rewardTab=FormatItem(reward) 
            -- local uid=playerVoApi:getUid()
            -- local curDonate=allianceMemberVoApi:getDonate(uid)
            -- --弹出奖励面板
            -- require "luascript/script/game/scene/gamedialog/allianceDialog/allianceFubenSmallDialog"
            -- local data={customNum=SizeOfTable(fubenIdTb),bcount=bcount,bossCount=bossCount,remainbcount=remainbcount,curDonate=curDonate,costDonate=costDonate,rewardTab=rewardTab}
            -- smallDialog:showAllianceRewardsDialog("TankInforPanel.png",CCSizeMake(550,680),CCRect(0,0,400,350),CCRect(130,50,1,1),data,nil,false,false,self.layerNum+1)

            --  if costDonate>0 then
            --     local keyName = "alliance_getReward_cost"
            --     local function secondTipFunc(sbFlag)
            --         local sValue=base.serverTime .. "_" .. sbFlag
            --         G_changePopFlag(keyName,sValue)
            --     end
            --     if G_isPopBoard(keyName) then
            --        G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des4",{costDonate}),true,confirmHandler,secondTipFunc) --     else
            --         confirmHandler()
            --     end
            -- else
            --     confirmHandler()
            -- end

            require "luascript/script/game/scene/gamedialog/allianceDialog/allianceFubenSmallDialog"
            smallDialog:showAllianceFubenGetBoxTipsDialog({freeBoxCount,ownNum,needCostDonate}, self.layerNum + 1, function(param, closeBackFunc)
                if param == 2 then
                    local canUseDonate=allianceMemberVoApi:getCanUseDonate(playerVoApi:getUid()) --可以使用的个人贡献值
                    if needCostDonate > canUseDonate then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage8038"),30)
                        do return end
                    end
                    local keyName = "alliance_getReward_cost"
                    local function secondTipFunc(sbFlag)
                        local sValue=base.serverTime .. "_" .. sbFlag
                        G_changePopFlag(keyName,sValue)
                    end
                    if G_isPopBoard(keyName) then
                        G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des4",{needCostDonate}),true,function()
                            confirmHandler(param)
                            if closeBackFunc then
                                closeBackFunc()
                            end
                        end,secondTipFunc)
                    else
                        confirmHandler(param)
                        if closeBackFunc then
                            closeBackFunc()
                        end
                    end
                else
                    confirmHandler(param)
                    if closeBackFunc then
                        closeBackFunc()
                    end
                end
            end)

        end
        local getBtn = GetButtonItem("yh_taskReward.png","yh_taskReward_down.png","yh_taskReward.png",rewardsHandler,11,nil,nil)
        local spScale=1
        getBtn:setScale(spScale)
        local getMenu = CCMenu:createWithItem(getBtn)
        getMenu:setPosition(ccp(rewardBgSP:getContentSize().width-getBtn:getContentSize().width/2*spScale-20,rewardBgSP:getContentSize().height/2))
        getMenu:setTouchPriority(-(self.layerNum-1)*20-4)
        rewardBgSP:addChild(getMenu,1)
    end
    if tonumber(ownNum)>0 then
        self:showRewardWidget()
    else
        self:hideRewardWidget()
    end
end

function allianceFuDialog:showRewardWidget()
    if self.rewardWidget then
        self:resetTv(false)
        self.rewardWidget:setVisible(true)
        local moveTo=CCMoveTo:create(1,CCPointMake(G_VisibleSize.width/2,10))
        self.rewardWidget:runAction(moveTo)
        self.rewardShow=true
    end
end

function allianceFuDialog:hideRewardWidget()
    if self.rewardWidget then
        self:resetTv(true)
        self.rewardWidget:setVisible(true)
        local moveTo=CCMoveTo:create(1,CCPointMake(G_VisibleSize.width/2,-3*self.rewardWidget:getContentSize().height))
        self.rewardWidget:runAction(moveTo)
        self.rewardShow=false
    end
end

function allianceFuDialog:doSendOnClose( ... )
    if self.closeCallback and type(self.closeCallback) == "function" then
        self.closeCallback()
    end
end

function allianceFuDialog:resetTv(isExpand)
    self.tv:removeFromParentAndCleanup(true)
    self.tv=nil
    local function callBack4(...)
       return self:eventHandler4(...)
    end
    local hd4= LuaEventHandler:createHandler(callBack4)
    self.tv=LuaCCTableView:createWithEventHandler(hd4,CCSizeMake(self.bgLayer:getContentSize().width-40,G_VisibleSizeHeight-350),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,125))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function allianceFuDialog:refreshRewardWidget()
    local ownNum,availableNum,costDonate,fubenIdTb,bcount=allianceFubenVoApi:getFunbenRewards()
    if self.ownNumLb and self.availableNumLb then
        self.ownNumLb:setString(getlocal("alliance_own_rewards",{ownNum}))
        self.availableNumLb:setString(getlocal("alliance_rewards_available",{availableNum}))
    end
    if tonumber(ownNum)>0 then
        if self.rewardShow==false then
            self:showRewardWidget()
        end
    else
        if self.rewardShow==true then
            self:hideRewardWidget()
        end
    end
end

--点击了cell或cell上某个按钮
function allianceFuDialog:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        if self.expandIdx["k"..(idx-1000)]==nil then
                self.expandIdx["k"..(idx-1000)]=idx-1000
                self.tv:openByCellIndex(idx-1000,120)
        else
            self.expandIdx["k"..(idx-1000)]=nil
            self.tv:closeByCellIndex(idx-1000,800)
        end
    end
end

function allianceFuDialog:tick()
    
    if self and self.tv then
        local refreshFlag=allianceFubenVoApi:isRefreshData()
        if allianceFubenVoApi:getFlag(1)==0 or refreshFlag==true then
            self:doUserHandler()
            self.tv:reloadData()
            allianceFubenVoApi:setFlag(1,1)
            if refreshFlag==true then
                local function achallengeGetHandler(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        local function allianceBossGetHandler(fn,bossdata)
                            local cret,cData=base:checkServerData(bossdata)
                            if cret==true then
                                if self and self.tv then
                                    self:doUserHandler()
                                    self.tv:reloadData()
                                end
                                local data={changeType=2}
                                eventDispatcher:dispatchEvent("allianceBossFuben.damageChanged",data)
                            end
                        end
                        socketHelper:allianceBossGet(allianceBossGetHandler)
                    end
                end
                socketHelper:achallengeGet(achallengeGetHandler)
            end
            self:refreshRewardWidget()
        end
    end   
end

function allianceFuDialog:regetAllianceBoss()
    local function allianceBossGetHandler(fn,bossdata)
        local cret,cData=base:checkServerData(bossdata)
        if cret==true then
            if self and self.tv then
                self:doUserHandler()
                self.tv:reloadData()
            end
            local data={changeType=2}
            eventDispatcher:dispatchEvent("allianceBossFuben.damageChanged",data)
        end   
    end
    socketHelper:allianceBossGet(allianceBossGetHandler)
end

function allianceFuDialog:dispose()
    local data={key="alliance_duplicate"}
    eventDispatcher:dispatchEvent("allianceFunction.numChanged",data)
    self.expandIdx=nil
    self.rewardWidget=nil
    self.ownNumLb=nil
    self.availableNumLb=nil
    self.chapterCount=0
    self.rewardShow=false
    self=nil
end




