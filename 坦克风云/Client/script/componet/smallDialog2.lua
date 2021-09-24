function smallDialog:showSureAndCancle(bgSrc,size,fullRect,inRect,callBack,title,content,isuseami,layerNum,align,align2,cancleCallBack,leftBtnStr,rightBtnStr,isShowClose,isRichLabel,propId,content2)
      local sd=smallDialog:new()
      sd:initSureAndCancle(bgSrc,size,fullRect,inRect,callBack,title,content,isuseami,layerNum,align,align2,cancleCallBack,leftBtnStr,rightBtnStr,isShowClose,isRichLabel,propId,content2)
      return sd
end

function smallDialog:showSure(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,lbColor,callBackHandler,type)
      local sd=smallDialog:new()
      sd:initSure(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,lbColor,callBackHandler,type)
      return sd
end

function smallDialog:showTableViewSure(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,callBackHandler,isAutoHeight)
      local sd=smallDialog:new()
      sd:initTableViewSure(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,callBackHandler,isAutoHeight)
end

function smallDialog:showTableViewSureWithColorTb(bgSrc,size,fullRect,inRect,title,contentTb,colorTb,isuseami,layerNum,callBackHandler,sizeTab,richColorTb,textAlignment)
  local sd=smallDialog:new()
  sd:initTableViewSureWithColorTb(bgSrc,size,fullRect,inRect,title,contentTb,colorTb,isuseami,layerNum,callBackHandler,sizeTab,richColorTb,textAlignment)
end

function smallDialog:showTableViewRewardSure(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,callBackHandler)
      local sd=smallDialog:new()
      sd:initTableViewRewardSure(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,callBackHandler)
end

function smallDialog:showECRaidDialog(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,lbColor,callBackHandler,isOneByOne)
      local sd=smallDialog:new()
      sd:initECRaidDialog(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,lbColor,callBackHandler,isOneByOne)
end

function smallDialog:showNormal(bgSrc,size,fullRect,inRect,tmpFunc,istouch,isuseami,layerNum,textTab,textSize,textColorTab)
      local sd=smallDialog:new()
      sd:init(bgSrc,size,fullRect,inRect,tmpFunc,istouch,isuseami,layerNum,textTab,textSize,textColorTab)
end

-- flag是否统一提示
function smallDialog:showTipsDialog(bgSrc,size,fullRect,inRect,textContnt,textSize,bgPoint,flag,reward,contentColor,isWait,newLayerNum)
    if flag==nil then
      flag=false
    end
    if base.fs==0 then
      flag=false
    end
    if reward and SizeOfTable(reward)>0 then
        newTipSmallDialog:showNewTipsDialog(bgSrc,size,fullRect,inRect,textContnt,textSize,bgPoint,flag,reward,contentColor)
        -- local sd=newTipSmallDialog:new()
        -- sd:initTipsDialog(bgSrc,size,fullRect,CCRect(268, 35, 1, 1),textContnt,textSize,bgPoint,flag,reward)
        do return end
    end
    if flag==true then
      if isWait==true then
        table.insert(base.allShowTipStrTb,{textContnt,1})--1是两个tip提示之间间隔1秒
      else
        table.insert(base.allShowTipStrTb,textContnt)
      end
      do return end
    else
        local sd=smallDialog:new()
        sd:initTipsDialog(bgSrc,size,fullRect,CCRect(268, 35, 1, 1),textContnt,textSize,bgPoint,contentColor,newLayerNum)
    end

end

function smallDialog:showTaskDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,textContnt,textSize,itemTab,textColorTab,ifDaily,isLocalName)
      local sd=smallDialog:new()
      sd:initTaskDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,textContnt,textSize,itemTab,textColorTab,ifDaily,isLocalName)
end

function smallDialog:showRewardDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,textContnt,textSize,itemTab,textColorTab,ifDaily)
      local sd=smallDialog:new()
      sd:initRewardDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,textContnt,textSize,itemTab,textColorTab,ifDaily)
end

function smallDialog:showPlayerInfoSmallDialog(bgSrc,size,fullRect,inRect,leftStr,leftCallBack,rightStr,rightCallBack,title,content,isuseami,layerNum,type,itemTab,closeCallBack,protected,pic,str3,callBack3,str4,callBack4,rank,serverWarRank,startTime,chenghao,targetName,vipPic,isGM,rpoint,hfid,uid)
      local sd=smallDialog:new()
      sd:initPlayerInfoSmallDialog(bgSrc,size,fullRect,inRect,leftStr,leftCallBack,rightStr,rightCallBack,title,content,isuseami,layerNum,type,itemTab,closeCallBack,protected,pic,str3,callBack3,str4,callBack4,rank,serverWarRank,startTime,chenghao,targetName,vipPic,isGM,rpoint,hfid,uid)
    return sd
end

function smallDialog:showBattleResultDialog(bgSrc,size,fullRect,inRect,isVictory,callBack,isuseami,layerNum,award,resultStar,isFuben,acData,winCondition,swId,robData,upgradeTanks,levelData,challenge)
      local sd=smallDialog:new()
      sd:initBattleResultDialog(bgSrc,size,fullRect,inRect,isVictory,callBack,isuseami,layerNum,award,resultStar,isFuben,acData,winCondition,swId,robData,upgradeTanks,levelData,challenge)
    return sd
end

function smallDialog:showEnemyComingDialog(bgSrc,size,fullRect,inRect,istouch,isuseami,title,layerNum,itemTab,enemyId)
      local sd=smallDialog:new()
      sd:initEnemyComingDialog(bgSrc,size,fullRect,inRect,istouch,isuseami,title,layerNum,itemTab,enemyId)
    return sd
end

function smallDialog:showUpgradeFeedDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callBackHandler)
      local sd=smallDialog:new()
      sd:initUpgradeFeedDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callBackHandler)
    return sd
end

--smallDialog:showCodeRewardDialog("PanelHeaderPopup.png",CCSizeMake(550,450),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,3)
function smallDialog:showCodeRewardDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callBackHandler)
      local sd=smallDialog:new()
      sd:initCodeRewardDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callBackHandler)
      return sd
end

-- isXxjl 是否是陨星降临 addDestr :新的换行描述 addDestr2:标题下面加一行文字
function smallDialog:showSearchEquipDialog(bgSrc,size,fullRect,inRect,title,content,istouch,isuseami,layerNum,callBackHandler,isSizeAmi,isOneByOne,isTip,isRoulette,isRefitTank,msgContent,isAddDesc,addDesc,isRebates,isjunshijiangtan,isVip,isXxjl,addDestr,addDestr2,opacity,canClick,isSpecial)
      local sd=smallDialog:new()
      sd:initSearchEquipDialog(bgSrc,size,fullRect,inRect,title,content,istouch,isuseami,layerNum,callBackHandler,isSizeAmi,isOneByOne,isTip,isRoulette,isRefitTank,msgContent,isAddDesc,addDesc,isRebates,isjunshijiangtan,isVip,isXxjl,addDestr,addDestr2,opacity,canClick,isSpecial)
end

function smallDialog:showSearchDialog(bgSrc,size,fullRect,inRect,title,content,istouch,isuseami,layerNum,callBackHandler,isSizeAmi,isOneByOne,isTip,isRoulette)
      local sd=smallDialog:new()
      sd:initSearchDialog(bgSrc,size,fullRect,inRect,title,content,istouch,isuseami,layerNum,callBackHandler,isSizeAmi,isOneByOne,isTip,isRoulette)
end

--smallDialog:showBindingSureDialog("PanelHeaderPopup.png",CCSizeMake(450,350),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,bindingHandler) bindingHandler回调，1facebook 2自定义
function smallDialog:showBindingSureDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callBackHandler,title)
      local sd=smallDialog:new()
      local dialog=sd:initBindingSureDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callBackHandler,title)
      return sd
end

function smallDialog:showJoinAllianceDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,isShowReward,chatDialog)
      local sd=smallDialog:new()
      local dialog=sd:initJoinAllianceDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,isShowReward,chatDialog)
      return sd
end

function smallDialog:showUrgentTaskDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,leftBtnStr,rightBtnStr,leftCallBack,rightCallBack,isShowClose,item)
      local sd=smallDialog:new()
      local dialog=sd:initUrgentTaskDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,leftBtnStr,rightBtnStr,leftCallBack,rightCallBack,isShowClose,item)
      return sd
end

function smallDialog:showSendFlowerInfoDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,callback,rewardHandler)
      local sd=smallDialog:new()
      local dialog=sd:initSendFlowerInfoDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,callback,rewardHandler)
      return sd
end

function smallDialog:showServerWarRankDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,serverWarRank)
      local sd=smallDialog:new()
      local dialog=sd:initServerWarRankDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,serverWarRank)
      return sd
end

function smallDialog:showTeamSendFlowerInfoDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,callback,rewardHandler)
      local sd=smallDialog:new()
      local dialog=sd:initTeamSendFlowerInfoDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,callback,rewardHandler)
      return sd
end

-- smallDialog:showTeamServerWarResultDialog("PanelHeaderPopup.png",CCSizeMake(550,520),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,getlocal("serverwarteam_record"),nil)
function smallDialog:showTeamServerWarResultDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,data,callback)
      local sd=smallDialog:new()
      local dialog=sd:initTeamServerWarResultDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,data,callback)
      return sd
end

function smallDialog:showBattleFundsDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,callback,dType)
      local sd=smallDialog:new()
      local dialog=sd:initBattleFundsDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,callback,dType)
      return sd
end

function smallDialog:showActivateDefendersDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,callback)
      local sd=smallDialog:new()
      local dialog=sd:initActivateDefendersDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,callback)
      return sd
end

function smallDialog:showFormationDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,callback,type,isShowTank,tankLayerParent)
      local sd=smallDialog:new()
      local dialog=sd:initFormationDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,callback,type,isShowTank,tankLayerParent)
      return sd
end

function smallDialog:showInfo(bgSrc,size,fullRect,inRect,tmpFunc,istouch,isuseami,layerNum,textSize,infoTab,cellSize)
      local sd=smallDialog:new()
      local dialog = sd:initInfo(bgSrc,size,fullRect,inRect,tmpFunc,istouch,isuseami,layerNum,textSize,infoTab,cellSize)
      return dialog
end



function smallDialog:showAlienTechInfoDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callback,tType,techId)
      local sd=smallDialog:new()
      local dialog=sd:initAlienTechInfoDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callback,tType,techId)
      return sd
end

function smallDialog:showAlienTechSkillDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callback,tType,tankId,index)
      local sd=smallDialog:new()
      local dialog=sd:initAlienTechSkillDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callback,tType,tankId,index)
      return sd
end

function smallDialog:showAlienTechUnlockSlotDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callback,type,tankId,unlockSlotIndex)
      local sd=smallDialog:new()
      local dialog=sd:initAlienTechUnlockSlotDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callback,type,tankId,unlockSlotIndex)
      return sd
end

function smallDialog:showAlienTechSlotDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,techId)
      local sd=smallDialog:new()
      local dialog=sd:initAlienTechSlotDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,techId)
      return sd
end

function smallDialog:showHeroInfoDialog(bgSrc,size,fullRect,inRect,tmpFunc,istouch,isuseami,layerNum,heroVo,bType)
      local sd=smallDialog:new()
      sd:initHeroInfoDialog(bgSrc,size,fullRect,inRect,tmpFunc,istouch,isuseami,layerNum,heroVo,bType)
end

function smallDialog:showWorldWarCostTanksDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callback,fleetInfo,battleType,exchangeRate)
      local sd=smallDialog:new()
      local dialog=sd:initCostTanksDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callback,fleetInfo,battleType,exchangeRate)
      return sd
end

function smallDialog:showWorldWarFlowerInfoDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,callback,rewardHandler)
      local sd=smallDialog:new()
      local dialog=sd:initWorldWarFlowerInfoDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,callback,rewardHandler)
      return sd
end

function smallDialog:showWorldWarChampionDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum)
      CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("worldWar/worldWar.plist")
      local sd=smallDialog:new()
      local dialog=sd:initWorldWarChampionDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum)
      return sd
end

function smallDialog:showAcWanchengjieRewardDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,showType,reward)
      local sd=smallDialog:new()
      local dialog=sd:initAcWanchengjieRewardDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,showType,reward)
      return sd
end
function smallDialog:initAcWanchengjieRewardDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,showType,reward)
    self.isTouch=nil
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local version=acWanshengjiedazuozhanVoApi:getVersion()
    local title=getlocal("activity_wanshengjiedazuozhan_pumpkin"..showType)..getlocal("activity_wanshengjiedazuozhan_reward_pool")
    if version>1 then
        title=getlocal("activity_wanshengjiedazuozhan_pumpkin"..showType.."_"..version)..getlocal("activity_wanshengjiedazuozhan_reward_pool")
    end
    -- title="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local titleLb=GetTTFLabelWrap(title,35,CCSize(self.bgSize.width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-50))
    self.bgLayer:addChild(titleLb)

    local lineSp =CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setScaleX(size.width/lineSp:getContentSize().width)
    lineSp:setScaleY(1.2)
    lineSp:setPosition(ccp(size.width/2,size.height-80))
    self.bgLayer:addChild(lineSp,2)

    local strSize2 = 22
    local needPos = 5
    if G_getCurChoseLanguage() =="cn" and G_getCurChoseLanguage() =="ja" and G_getCurChoseLanguage() =="ko" and G_getCurChoseLanguage() =="tw" then
      strSize2 =25
      needPos = 20
    end
    local tvWidth=size.width-60
    local tvHeight=250
    local fy=0
    for i=1,2 do
        local px,py=20,size.height-150-320*(i-1)
        local tabItemSp=CCSprite:createWithSpriteFrameName("RankBtnTab_Down.png")
        local lbStr=getlocal("activity_wanshengjiedazuozhan_tab"..i)
        if version>1 then
            lbStr=getlocal("activity_wanshengjiedazuozhan_tab"..i.."_"..version)
        end
        local lb=GetTTFLabelWrap(lbStr,20,CCSizeMake(tabItemSp:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        lb:setPosition(getCenterPoint(tabItemSp))
        tabItemSp:addChild(lb)
        tabItemSp:setAnchorPoint(ccp(0,0))
        tabItemSp:setPosition(ccp(px+10,py))
        self.bgLayer:addChild(tabItemSp,1)

        local descLb=GetTTFLabel(getlocal("activity_wanshengjiedazuozhan_reward_desc"),strSize2)
        descLb:setAnchorPoint(ccp(0,0))
        descLb:setPosition(ccp(px+10+tabItemSp:getContentSize().width+needPos,py+8))
        self.bgLayer:addChild(descLb,1)

        local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),function ()end)
        tvBg:setTouchPriority(-(layerNum-1)*20-1)
        tvBg:setContentSize(CCSizeMake(tvWidth+10,tvHeight+10))
        tvBg:ignoreAnchorPointForPosition(false)
        tvBg:setAnchorPoint(ccp(0,1))
        tvBg:setPosition(ccp(px,py))
        -- tvBg:setIsSallow(true)
        self.bgLayer:addChild(tvBg,1)

        local awardTb
        if reward and reward[i] then
            awardTb=FormatItem(reward[i],nil,true)
        end
        local num=math.ceil(SizeOfTable(awardTb)/4)
        if awardTb and SizeOfTable(awardTb)>0 then
            local function tvCallBack(handler,fn,idx,cel)
                if fn=="numberOfCellsInTableView" then
                    return 1
                elseif fn=="tableCellSizeForIndex" then
                    local tmpSize=CCSizeMake(tvWidth,num*125)
                    return tmpSize
                elseif fn=="tableCellAtIndex" then
                    local cell=CCTableViewCell:new()
                    cell:autorelease()

                    local cellHeight=num*125
                    for k,v in pairs(awardTb) do
                        local posx,posy=60+120*((k-1)%4),cellHeight-65-120*math.floor((k-1)/4)
                        local sp,scale=G_getItemIcon(v,100,true,layerNum,nil,self["acTv"..i])
                        sp:setPosition(ccp(posx,posy))
                        sp:setTouchPriority(-(layerNum-1)*20-2)
                        cell:addChild(sp)
                        if v and v.type=="h" and v.eType=="h" then
                        else
                            local lb=GetTTFLabel("x"..FormatNumber(v.num),25)
                            lb:setAnchorPoint(ccp(1,0))
                            lb:setPosition(ccp(sp:getContentSize().width-5,5))
                            sp:addChild(lb)
                            lb:setScale(1/scale)
                        end
                    end

                    return cell
                elseif fn=="ccTouchBegan" then
                    isMoved=false
                    return true
                elseif fn=="ccTouchMoved" then
                    isMoved=true
                elseif fn=="ccTouchEnded"  then

                end
            end
            local cellWidth=self.bgLayer:getContentSize().width-40
            local hd= LuaEventHandler:createHandler(tvCallBack)
            self["acTv"..i]=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
            self["acTv"..i]:setTableViewTouchPriority(-(layerNum-1)*20-3)
            self["acTv"..i]:setPosition(ccp(5,5))
            tvBg:addChild(self["acTv"..i],2)
            self["acTv"..i]:setMaxDisToBottomOrTop(120)
        end

        local function sureHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
        local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("ok"),25)
        local sureMenu=CCMenu:createWithItem(sureItem)
        sureMenu:setPosition(ccp(size.width/2,70))
        sureMenu:setTouchPriority(-(layerNum-1)*20-5)
        self.bgLayer:addChild(sureMenu)

        local function forbidClick()
        end
        local rect2 = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        if i==1 then
            local topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
            topforbidSp:setTouchPriority(-(layerNum-1)*20-4)
            topforbidSp:setContentSize(CCSize(size.width,size.height-py))
            topforbidSp:setAnchorPoint(ccp(0,0))
            topforbidSp:setPosition(ccp(0,py))
            self.bgLayer:addChild(topforbidSp)
            topforbidSp:setVisible(false)

            fy=py
        elseif i==2 then
            local middleforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
            middleforbidSp:setTouchPriority(-(layerNum-1)*20-4)
            middleforbidSp:setContentSize(CCSize(size.width,fy-py-tvBg:getContentSize().height))
            middleforbidSp:setAnchorPoint(ccp(0,0))
            middleforbidSp:setPosition(ccp(0,py))
            self.bgLayer:addChild(middleforbidSp)
            middleforbidSp:setVisible(false)

            local bottomforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
            bottomforbidSp:setTouchPriority(-(layerNum-1)*20-4)
            bottomforbidSp:setContentSize(CCSize(size.width,py-tvBg:getContentSize().height))
            bottomforbidSp:setAnchorPoint(ccp(0,0))
            bottomforbidSp:setPosition(ccp(0,0))
            self.bgLayer:addChild(bottomforbidSp)
            bottomforbidSp:setVisible(false)
        end
    end

    local function touchDialog()

    end
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function touchLuaSpr()
        if self.isTouch~=nil then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

function smallDialog:initWorldWarChampionDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum)
    self.isTouch=true
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    if base.worldWarChampion then
        local firstData=base.worldWarChampion or {}
        local serverID=firstData.serverID or 0
        local id=firstData.id or 0
        local power=firstData.power or 0
        local name=firstData.name or ""
        local level=firstData.level or 0

        local shape=120
        local shapeInforSp = CCSprite:createWithSpriteFrameName("ShapeInfor.png")
        shapeInforSp:setAnchorPoint(ccp(0.5,1))
        shapeInforSp:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-20))
        self.bgLayer:addChild(shapeInforSp)
        shapeInforSp:setScaleX(self.bgSize.width/shapeInforSp:getContentSize().width)
        shapeInforSp:setScaleY((shape-20)/shapeInforSp:getContentSize().height)

        -- local cupSp = CCSprite:create("worldWar/ww_champion_cup.png")
        local cupSp = CCSprite:createWithSpriteFrameName("ww_champion_cup.png")
        cupSp:setAnchorPoint(ccp(0.5,0))
        cupSp:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-30))
        self.bgLayer:addChild(cupSp)

        local title=getlocal("world_war_champion_title")

        local tankTitleBg = CCSprite:createWithSpriteFrameName("ShapeTank.png")
        tankTitleBg:setAnchorPoint(ccp(0.5,0))
        tankTitleBg:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-30))
        self.bgLayer:addChild(tankTitleBg)

        local title=getlocal("world_war_champion_title")
        -- title="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        local titleLb=GetTTFLabelWrap(title,35,CCSize(self.bgSize.width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        titleLb:setAnchorPoint(ccp(0.5,0.5))
        titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-70))
        self.bgLayer:addChild(titleLb)

        -- local lineSp1 = CCSprite:createWithSpriteFrameName("LineEntity.png");
        local lineSp1 = CCSprite:createWithSpriteFrameName("LineCross.png");
        lineSp1:setAnchorPoint(ccp(0.5,0.5));
        lineSp1:setPosition(self.bgSize.width/2,self.bgSize.height-shape)
        lineSp1:setScaleY(2)
        lineSp1:setScaleX((self.bgSize.width-60)/lineSp1:getContentSize().width)
        self.bgLayer:addChild(lineSp1)

        local lHeight=(self.bgSize.height-shape)/2+10
        local shapeEagleSp = CCSprite:createWithSpriteFrameName("ShapeEagle.png")
        shapeEagleSp:setAnchorPoint(ccp(0.5,0.5))
        shapeEagleSp:setPosition(ccp(self.bgSize.width/2,lHeight))
        self.bgLayer:addChild(shapeEagleSp)

        local logoSp = CCSprite:createWithSpriteFrameName("ww_logo_1.png")
        logoSp:setAnchorPoint(ccp(0.5,0.5))
        logoSp:setPosition(130,lHeight)
        logoSp:setScale(1.5)
        self.bgLayer:addChild(logoSp)

        local posX=self.bgSize.width-180
        local lineSp2 = CCSprite:createWithSpriteFrameName("LineCross.png");
        lineSp2:setAnchorPoint(ccp(0.5,0.5));
        lineSp2:setPosition(posX,lHeight)
        -- lineSp2:setScaleY(3)
        lineSp2:setScaleX(300/lineSp2:getContentSize().width)
        self.bgLayer:addChild(lineSp2)

        local nameLb=GetTTFLabel(name,25)
        nameLb:setAnchorPoint(ccp(0.5,0.5))
        nameLb:setPosition(ccp(posX,lHeight+nameLb:getContentSize().height/2+20))
        self.bgLayer:addChild(nameLb)
        nameLb:setColor(G_ColorYellowPro)
        local serverName="【"..(GetServerNameByID(serverID) or "").."】"
        local serverNameLb=GetTTFLabel(serverName,25)
        serverNameLb:setAnchorPoint(ccp(0.5,0.5))
        serverNameLb:setPosition(ccp(posX,lHeight+nameLb:getContentSize().height+serverNameLb:getContentSize().height/2+20))
        self.bgLayer:addChild(serverNameLb)
        serverNameLb:setColor(G_ColorYellowPro)

        local levelLb=GetTTFLabel(getlocal("world_war_level",{level}),25)
        levelLb:setAnchorPoint(ccp(0.5,0.5))
        levelLb:setPosition(ccp(posX,lHeight-levelLb:getContentSize().height/2-20))
        self.bgLayer:addChild(levelLb)
        local powerLb=GetTTFLabel(getlocal("world_war_power",{FormatNumber(power)}),25)
        powerLb:setAnchorPoint(ccp(0.5,0.5))
        powerLb:setPosition(ccp(posX,lHeight-levelLb:getContentSize().height-powerLb:getContentSize().height/2-20))
        self.bgLayer:addChild(powerLb)
    end

    local function touchDialog()

    end
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function touchLuaSpr()
        if self.isTouch~=nil then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

function smallDialog:initWorldWarFlowerInfoDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,callback,callBackHandler)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()

    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog()

    end

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    -- self:userHandler()

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)

    if title then
        local titleLb=GetTTFLabel(title,40)
        titleLb:setAnchorPoint(ccp(0.5,0.5))
        titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
        dialogBg:addChild(titleLb)
    end


    self.type="worldWarFlowerInfoDialog"
    self.refreshData={}
    self.refreshData.timeTb={}
    self.refreshData.label={}
    self.refreshData.wwrewardItem={}

    base:addNeedRefresh(self)


    local num=worldWarVoApi:getTotalBetListNum()
    if num==0 then
        local noFlowerLb=GetTTFLabelWrap(getlocal("serverwar_no_flower"),30,CCSize(self.bgSize.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        noFlowerLb:setPosition(getCenterPoint(dialogBg))
        dialogBg:addChild(noFlowerLb,1)
        noFlowerLb:setColor(G_ColorYellowPro)
    else
        local isMoved=false
        local function tvCallBack(handler,fn,idx,cel)
            if fn=="numberOfCellsInTableView" then
                -- local cellNum=worldWarVoApi:getTotalBetListNum()
                -- return cellNum
                return num
            elseif fn=="tableCellSizeForIndex" then
                local cellWidth=self.bgSize.width-40
                local cellHeight=260
                local tmpSize=CCSizeMake(cellWidth,cellHeight)
                return  tmpSize
            elseif fn=="tableCellAtIndex" then
                local cell=CCTableViewCell:new()
                cell:autorelease()

                local cellWidth=self.bgSize.width-40
                local cellHeight=260

                local betList=worldWarVoApi:getTotalBetList()
                -- local list={}
                -- for k,v in pairs(betList) do
                --     if v then
                --         table.insert(list,v)
                --     end
                -- end
                -- local function sortFunc(a,b)
                --     if a and b and a.roundID and b.roundID then
                --         return tonumber(a.roundID)>tonumber(b.roundID)
                --     end
                -- end
                -- table.sort(list,sortFunc)
                local list=betList
                local betVo=list[idx+1]
                local bType=betVo.type        --战斗类型，1大师，2精英
                local roundID=betVo.roundID    --献花的轮次ID
                -- local groupID=betVo.groupID    --给胜者组献花是1, 给败者组献花是2
                local battleID=betVo.battleID  --献花的场次ID
                local playerID=betVo.playerID  --投注的选手ID
                local times=betVo.times        --投注的次数
                local hasGet=betVo.hasGet      --是否已经领取
                local battleVo=worldWarVoApi:getBattleData(bType,roundID,battleID)
                print("hasGet",hasGet)

                if battleVo==nil then
                    do return cell end
                end
                local isWin
                if battleVo.winnerID then
                    if playerID==battleVo.winnerID then
                        isWin=true
                    else
                        isWin=false
                    end
                end

                local timeList=worldWarVoApi:getBattleTimeList(bType)
                local time=timeList[roundID]
                local endTime=time+(worldWarCfg.battleTime*3)
                self.refreshData.timeTb[idx+1]=endTime

                local flowerNum=worldWarVoApi:getSendFlowerNum(bType,roundID,times) or 0
                local point=worldWarVoApi:getSendFlowerNum(bType,roundID,times,true,isWin) or 0
                local playerVo=worldWarVoApi:getPlayer(playerID)

                local server1=""
                local server2=""
                local name1=""
                local name2=""
                local target=""
                if battleVo then
                    if battleVo.player1 then
                        server1="【"..battleVo.player1.serverName.."】"
                        name1=battleVo.player1.name
                    end
                    if battleVo.player2 then
                        server2="【"..battleVo.player2.serverName.."】"
                        name2=battleVo.player2.name
                    end
                end
                if playerVo then
                    target=playerVo.name
                end

                local roundStatus=worldWarVoApi:getRoundStatus(bType,roundID)
                if roundStatus<21 then
                    status=0 --等待中
                elseif roundStatus>=21 and roundStatus<30 then
                    status=1 --正在进行
                elseif roundStatus>=30 then
                    status=2 --结束
                end

                local canReward=false
                local isReward=false
                if hasGet==1 then
                    isReward=true
                end
                if status==2 then
                    canReward=true
                end

                local lbSize=20
                local function touch()
                end
                local bgSprie
                if canReward==true and isReward==false then
                    bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),touch)
                else
                    bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
                end
                bgSprie:setContentSize(CCSizeMake(cellWidth,cellHeight-5))
                bgSprie:setPosition(ccp(cellWidth/2,cellHeight/2))
                bgSprie:setIsSallow(false)
                bgSprie:setTouchPriority(-(layerNum-1)*20-2)
                cell:addChild(bgSprie,1)

                local tStr=G_getDataTimeStr(time)
                local titleStr=worldWarVoApi:getRoundTitleStr(roundID,battleID,bType)
                local roundStr=getlocal("world_war_send_flower_round",{tStr,titleStr})
                -- roundStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
                local roundLable = GetTTFLabelWrap(roundStr,22,CCSize(cellWidth-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                roundLable:setAnchorPoint(ccp(0,0.5))
                roundLable:setPosition(ccp(10,cellHeight-35))
                cell:addChild(roundLable,1)
                roundLable:setColor(G_ColorYellowPro)

                local lineSp1=CCSprite:createWithSpriteFrameName("LineCross.png")
                lineSp1:setAnchorPoint(ccp(0.5,0.5))
                lineSp1:setScaleX(cellWidth/lineSp1:getContentSize().width)
                lineSp1:setPosition(ccp(cellWidth/2,cellHeight-65))
                cell:addChild(lineSp1,1)

                local pHeight=cellHeight-110
                local spWidth=110
                local spHeight=60
                if status==2 then
                    local function replayHandler()
                        if self and self.refreshData and self.refreshData.tableView and self.refreshData.tableView:getScrollEnable()==true and self.refreshData.tableView:getIsScrolled()==false then
                            if G_checkClickEnable()==false then
                                do
                                    return
                                end
                            else
                                base.setWaitTime=G_getCurDeviceMillTime()
                            end
                            PlayEffect(audioCfg.mouseClick)

                            local function callback()
                                if battleVo then
                                    worldWarVoApi:showBattleDialog(bType,battleVo,false,layerNum)
                                end
                            end
                            worldWarVoApi:getScheduleInfo(bType,callback)
                        end
                    end
                    local replayItem=GetButtonItem("cameraBtn.png","cameraBtn_down.png","cameraBtn_down.png",replayHandler,2,nil,nil)
                    local replayMenu=CCMenu:createWithItem(replayItem)
                    replayMenu:setPosition(ccp(cellWidth/2,pHeight))
                    replayMenu:setTouchPriority(-(layerNum-1)*20-2)
                    cell:addChild(replayMenu,3)

                    local rect = CCRect(0, 0, 37, 36)
                    local capInSet = CCRect(15, 15, 10, 10)
                    local function cellClick(hd,fn,idx)
                    end
                    local winnerBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("winnerBg.png",capInSet,cellClick)
                    winnerBgSp:setContentSize(CCSizeMake(spWidth,spHeight))
                    winnerBgSp:ignoreAnchorPointForPosition(false)
                    winnerBgSp:setAnchorPoint(ccp(0.5,0.5))
                    -- winnerBgSp:setPosition(cellWidth/2,pHeight)
                    winnerBgSp:setIsSallow(false)
                    winnerBgSp:setTouchPriority(-(layerNum-1)*20-1)
                    cell:addChild(winnerBgSp,1)
                    local winLb=GetTTFLabel(getlocal("fight_content_result_win"),lbSize)
                    cell:addChild(winLb,2)

                    local loserBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("loserBg.png",capInSet,cellClick)
                    loserBgSp:setContentSize(CCSizeMake(spWidth,spHeight))
                    loserBgSp:ignoreAnchorPointForPosition(false)
                    loserBgSp:setAnchorPoint(ccp(0.5,0.5))
                    -- loserBgSp:setPosition(cellWidth/2,pHeight)
                    loserBgSp:setIsSallow(false)
                    loserBgSp:setTouchPriority(-(layerNum-1)*20-1)
                    cell:addChild(loserBgSp,1)
                    local loseLb=GetTTFLabel(getlocal("fight_content_result_defeat"),lbSize)
                    cell:addChild(loseLb,2)

                    local isLeftWin=false
                    if battleVo.id1==battleVo.winnerID then
                        isLeftWin=true
                    end
                    if isLeftWin==true then
                        -- winnerBgSp:setAnchorPoint(ccp(1,0.5))
                        -- loserBgSp:setAnchorPoint(ccp(0,0.5))
                        winnerBgSp:setPosition(cellWidth/2-spWidth/2,pHeight)
                        loserBgSp:setPosition(cellWidth/2+spWidth/2,pHeight)
                        loserBgSp:setRotation(180)

                        winLb:setPosition(ccp(cellWidth/2-70,pHeight))
                        loseLb:setPosition(ccp(cellWidth/2+70,pHeight))
                    else
                        -- winnerBgSp:setAnchorPoint(ccp(0,0.5))
                        -- loserBgSp:setAnchorPoint(ccp(1,0.5))
                        loserBgSp:setPosition(cellWidth/2-spWidth/2,pHeight)
                        winnerBgSp:setPosition(cellWidth/2+spWidth/2,pHeight)
                        winnerBgSp:setRotation(180)

                        winLb:setPosition(ccp(cellWidth/2+70,pHeight))
                        loseLb:setPosition(ccp(cellWidth/2-70,pHeight))
                    end
                elseif status==1 then
                    local cdTime=endTime-base.serverTime
                    if cdTime<0 then
                        cdTime=0
                    end
                    local resultStr=getlocal("serverwar_result")..GetTimeStr(cdTime)
                    local resultLb=GetTTFLabel(resultStr,lbSize)
                    resultLb:setPosition(ccp(cellWidth/2,pHeight+25))
                    cell:addChild(resultLb,1)
                    resultLb:setColor(G_ColorYellowPro)
                    self.refreshData.label[idx+1]=resultLb

                    local function cellClick(hd,fn,idx)
                    end
                    local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
                    lbBg:setContentSize(CCSizeMake(spWidth*2,40))
                    lbBg:ignoreAnchorPointForPosition(false)
                    lbBg:setAnchorPoint(ccp(0.5,0.5))
                    lbBg:setPosition(ccp(cellWidth/2,pHeight-13))
                    lbBg:setIsSallow(false)
                    lbBg:setTouchPriority(-(layerNum-1)*20-1)
                    cell:addChild(lbBg,1)
                    local statusStr=getlocal("serverwar_ongoing")..getlocal("serverwar_dot")
                    local statusLb=GetTTFLabel(statusStr,lbSize)
                    statusLb:setPosition(getCenterPoint(lbBg))
                    lbBg:addChild(statusLb,1)
                elseif status==0 then
                    local function cellClick(hd,fn,idx)
                    end
                    local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("mainChatBgTo.png",CCRect(10,10,5,5),cellClick)
                    lbBg:setContentSize(CCSizeMake(spWidth*2,40))
                    lbBg:ignoreAnchorPointForPosition(false)
                    lbBg:setAnchorPoint(ccp(0.5,0.5))
                    lbBg:setPosition(ccp(cellWidth/2,pHeight))
                    lbBg:setIsSallow(false)
                    lbBg:setTouchPriority(-(layerNum-1)*20-1)
                    cell:addChild(lbBg,1)
                    local statusStr=getlocal("serverwar_waiting")..getlocal("serverwar_dot")
                    local statusLb=GetTTFLabel(statusStr,lbSize)
                    statusLb:setPosition(getCenterPoint(lbBg))
                    lbBg:addChild(statusLb,1)
                end


                -- server1="啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
                -- server2="啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
                local wSpace=75
                local hSpace=0
                local serverLb1=GetTTFLabelWrap(server1,lbSize,CCSize(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
                serverLb1:setAnchorPoint(ccp(0.5,0))
                serverLb1:setPosition(ccp(wSpace,pHeight+hSpace))
                cell:addChild(serverLb1,1)

                local serverLb2=GetTTFLabelWrap(server2,lbSize,CCSize(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
                serverLb2:setAnchorPoint(ccp(0.5,0))
                serverLb2:setPosition(ccp(cellWidth-wSpace,pHeight+hSpace))
                cell:addChild(serverLb2,1)

                local nameLb1=GetTTFLabel(name1,lbSize)
                nameLb1:setAnchorPoint(ccp(0.5,1))
                nameLb1:setPosition(ccp(wSpace,pHeight-hSpace))
                cell:addChild(nameLb1,1)

                local nameLb2=GetTTFLabel(name2,lbSize)
                nameLb2:setAnchorPoint(ccp(0.5,1))
                nameLb2:setPosition(ccp(cellWidth-wSpace,pHeight-hSpace))
                cell:addChild(nameLb2,1)

                local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
                lineSp2:setAnchorPoint(ccp(0.5,0.5))
                lineSp2:setScaleX(cellWidth/lineSp2:getContentSize().width)
                lineSp2:setPosition(ccp(cellWidth/2,cellHeight-155))
                cell:addChild(lineSp2,1)



                local lbHeight=60
                local hLbSpace=25
                local sendFlowerLb=GetTTFLabel(getlocal("serverwar_send_flower"),lbSize)
                sendFlowerLb:setAnchorPoint(ccp(0,0.5))
                sendFlowerLb:setPosition(ccp(10,lbHeight+hLbSpace))
                cell:addChild(sendFlowerLb,1)
                local flowerNumLb=GetTTFLabel(flowerNum,lbSize)
                flowerNumLb:setAnchorPoint(ccp(0,0.5))
                flowerNumLb:setPosition(ccp(sendFlowerLb:getContentSize().width+8,lbHeight+hLbSpace))
                cell:addChild(flowerNumLb,1)
                flowerNumLb:setColor(G_ColorGreen)

                local sendToLb=GetTTFLabel(getlocal("serverwar_send_to"),lbSize)
                sendToLb:setAnchorPoint(ccp(0,0.5))
                sendToLb:setPosition(ccp(10,lbHeight))
                cell:addChild(sendToLb,1)
                local targetLb=GetTTFLabel(target,lbSize)
                targetLb:setAnchorPoint(ccp(0,0.5))
                targetLb:setPosition(ccp(sendToLb:getContentSize().width+8,lbHeight))
                cell:addChild(targetLb,1)
                targetLb:setColor(G_ColorGreen)

                local getPointLb=GetTTFLabel(getlocal("serverwar_get_point"),lbSize)
                getPointLb:setAnchorPoint(ccp(0,0.5))
                getPointLb:setPosition(ccp(10,lbHeight-hLbSpace))
                cell:addChild(getPointLb,1)
                local pointStr=""
                if status~=2 then
                    pointStr=getlocal("waiting")
                elseif isWin==true then
                    pointStr=getlocal("fight_content_result_win").."+"..point
                else
                    pointStr=getlocal("fight_content_result_defeat").."+"..point
                end
                local pointLb=GetTTFLabel(pointStr,lbSize)
                pointLb:setAnchorPoint(ccp(0,0.5))
                pointLb:setPosition(ccp(getPointLb:getContentSize().width+8,lbHeight-hLbSpace))
                cell:addChild(pointLb,1)
                pointLb:setColor(G_ColorGreen)

                local hadRewardLable = GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSize(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                hadRewardLable:setAnchorPoint(ccp(0.5,0.5))
                hadRewardLable:setPosition(ccp(cellWidth-75,lbHeight))
                cell:addChild(hadRewardLable,1)
                hadRewardLable:setColor(G_ColorGreen)
                hadRewardLable:setVisible(false)

                if isReward==true then
                    -- local hadRewardLable = GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSize(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    -- hadRewardLable:setAnchorPoint(ccp(0.5,0.5))
                    -- hadRewardLable:setPosition(ccp(cellWidth-75,lbHeight))
                    -- cell:addChild(hadRewardLable,1)
                    -- hadRewardLable:setColor(G_ColorGreen)
                    hadRewardLable:setVisible(true)
                elseif canReward==true then
                    local function wwrewardHandler()
                        if self.refreshData.wwrewardItem and self.refreshData.wwrewardItem[idx+1] then
                            self.refreshData.wwrewardItem[idx+1]:setEnabled(false)
                        end
                        if self and self.refreshData and self.refreshData.tableView and self.refreshData.tableView:getScrollEnable()==true and self.refreshData.tableView:getIsScrolled()==false then
                            if G_checkClickEnable()==false then
                                do
                                    return
                                end
                            else
                                base.setWaitTime=G_getCurDeviceMillTime()
                            end
                            PlayEffect(audioCfg.mouseClick)

                            local function callback1(fn,data)
                                local ret,sData=base:checkServerData(data)
                                if ret==true then
                                    print("bType",bType)
                                    print("roundID",roundID)
                                    print("point",point)
                                    worldWarVoApi:betReward(bType,roundID,point)
                                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwar_reward_point",{point}),30)
                                    if self.refreshData.wwrewardItem and self.refreshData.wwrewardItem[idx+1] then
                                        self.refreshData.wwrewardItem[idx+1]:setVisible(false)
                                        self.refreshData.wwrewardItem[idx+1]:setEnabled(false)
                                        hadRewardLable:setVisible(true)
                                    end

                                    if callBackHandler then
                                        callBackHandler()
                                    end

                                    -- if self and self.refreshData and self.refreshData.tableView then
                                    --     self.refreshData.timeTb=nil
                                    --     self.refreshData.label=nil
                                    --     self.refreshData.timeTb={}
                                    --     self.refreshData.label={}
                                    --     local recordPoint = self.refreshData.tableView:getRecordPoint()
                                    --     self.refreshData.tableView:reloadData()
                                    --     self.refreshData.tableView:recoverToRecordPoint(recordPoint)
                                    -- end
                                end
                            end
                            local matchId=worldWarVoApi:getWorldWarId()
                            local detailId=worldWarVoApi:getConnectId(matchId,roundID,battleID)
                            local uid=playerVoApi:getUid()
                            local jointype=bType
                            socketHelper:worldwarGetbetreward(matchId,detailId,uid,jointype,callback1)
                        end
                    end
                    self.refreshData.wwrewardItem[idx+1]=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",wwrewardHandler,2,getlocal("activity_continueRecharge_reward"),25)
                    self.refreshData.wwrewardItem[idx+1]:setScale(0.8)
                    local rewardMenu=CCMenu:createWithItem(self.refreshData.wwrewardItem[idx+1])
                    rewardMenu:setPosition(ccp(cellWidth-75,lbHeight))
                    rewardMenu:setTouchPriority(-(layerNum-1)*20-2)
                    cell:addChild(rewardMenu,1)
                end

                return cell
            elseif fn=="ccTouchBegan" then
                isMoved=false
                return true
            elseif fn=="ccTouchMoved" then
                isMoved=true
            elseif fn=="ccTouchEnded"  then

            end
        end
        local cellWidth=self.bgLayer:getContentSize().width-40
        local hd= LuaEventHandler:createHandler(tvCallBack)
        self.refreshData.tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,self.bgLayer:getContentSize().height-180),nil)
        self.refreshData.tableView:setTableViewTouchPriority(-(layerNum-1)*20-3)
        self.refreshData.tableView:setPosition(ccp(20,100))
        self.bgLayer:addChild(self.refreshData.tableView,2)
        self.refreshData.tableView:setMaxDisToBottomOrTop(120)

        self:addForbidSp(self.bgLayer,size,layerNum)
    end

    if worldWarVoApi:checkStatus()<30 then
        --去献花
        local function sendFlowerHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            if callback then
                if callback()==true then
                    self:close()
                end
            else
                self:close()
            end
        end
        local sendFlowerItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sendFlowerHandler,2,getlocal("serverwar_go_send_flower"),25)
        local sendFlowerMenu=CCMenu:createWithItem(sendFlowerItem);
        sendFlowerMenu:setPosition(ccp(dialogBg:getContentSize().width/2,60))
        sendFlowerMenu:setTouchPriority(-(layerNum-1)*20-4)
        dialogBg:addChild(sendFlowerMenu)
        self.refreshData.sendFlowerMenu=sendFlowerMenu
    end


    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

function smallDialog:initCostTanksDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callback,fleetInfo,battleType,exchangeRate)
    self.isTouch=false
    self.isUseAmi=isuseami
    local titlSiz = 22
    local titPosWidth = 30
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
      titlSiz =26
      titPosWidth =0
    end
    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local function touchHandler()

    end
    -- local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    local dialogBg = G_getNewDialogBg(size,getlocal("world_war_fleet_cost_title"),titlSiz,touchHandler,layerNum,true,close,G_ColorYellowPro)
    self.dialogLayer=CCLayer:create()

    self.bgLayer=dialogBg
    self.bgSize=size
    -- self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog()

    end

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    -- self:userHandler()


    -- local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    -- closeBtnItem:setPosition(ccp(0,0))
    -- closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    -- self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    -- self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    -- self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    -- self.bgLayer:addChild(self.closeBtn,2)



    -- local tankTb={}
    -- local tanksInfo=G_clone(fleetInfo)
    -- if tanksInfo then
    --     for k,v in pairs(tanksInfo) do
    --         if v and v[1] and v[2] then
    --             local tid=v[1]
    --             local num=tonumber(v[2])
    --             local isHas=false
    --             for k,v in pairs(tankTb) do
    --                 if v[1]==tid then
    --                     tankTb[k][2]=v[2]+num
    --                     isHas=true
    --                 end
    --             end
    --             if isHas==false then
    --                 table.insert(tankTb,v)
    --             end
    --         end
    --     end
    -- end

    local tankTb=fleetInfo

    -- local function sortFunc(a,b)
    --     if a and b and a[1] and b[1] then
    --         local t1=(tonumber(a[1]) or tonumber(RemoveFirstChar(a[1])))
    --         local t2=(tonumber(b[1]) or tonumber(RemoveFirstChar(b[1])))
    --         return t1>t2
    --     end
    -- end
    -- table.sort(tankTb,sortFunc)

    -- local titleLb=GetTTFLabelWrap(getlocal("world_war_fleet_cost_title"),titlSiz,CCSize(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    -- titleLb:setAnchorPoint(ccp(0.5,0.5))
    -- titleLb:setPosition(ccp(self.bgSize.width/2-titPosWidth,self.bgSize.height-titleLb:getContentSize().height/2-25))
    -- dialogBg:addChild(titleLb)
    -- titleLb:setColor(G_ColorYellowPro)

    self.refreshData={}
    local cellWidth=self.bgSize.width-40
    local cellHeight=180
    local iSize=150


    local function touch()
    end
    -- local bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
    local bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),touch)
    bgSprie:setContentSize(CCSizeMake(cellWidth,self.bgSize.height-200))
    bgSprie:setAnchorPoint(ccp(0.5,0))
    bgSprie:setPosition(ccp(self.bgSize.width/2,115))
    bgSprie:setIsSallow(false)
    bgSprie:setTouchPriority(-(layerNum-1)*20-1)
    dialogBg:addChild(bgSprie)

    local function nilFunc()
    end
    local descBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
    local rect=CCSizeMake(cellWidth-8,60)
    descBg:setContentSize(rect)
    descBg:setAnchorPoint(ccp(0.5,1))
    descBg:setOpacity(180)
    descBg:setPosition(ccp(bgSprie:getContentSize().width/2,bgSprie:getContentSize().height-5))
    bgSprie:addChild(descBg)

    local desc1=getlocal("world_war_fleet_cost_desc1")
    -- desc1="啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local descLb1=GetTTFLabelWrap(desc1,24,CCSize(self.bgSize.width/2-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    descLb1:setAnchorPoint(ccp(0.5,0.5))
    descLb1:setPosition(ccp(50+iSize/2,self.bgSize.height-120))
    dialogBg:addChild(descLb1,2)
    descLb1:setColor(G_ColorRed)

    local desc2=getlocal("world_war_fleet_cost_desc2")
    -- desc2="啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local descLb2=GetTTFLabelWrap(desc2,24,CCSize(self.bgSize.width/2-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    descLb2:setAnchorPoint(ccp(0.5,0.5))
    descLb2:setPosition(ccp(self.bgSize.width-(50+iSize/2),self.bgSize.height-120))
    dialogBg:addChild(descLb2,2)
    descLb2:setColor(G_ColorGreen)

    local isMoved=false
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            local num=SizeOfTable(tankTb)
            return num
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local tankData=tankTb[idx+1]
            if tankData==nil then
                do return cell end
            end

            local tid=tankData[1]
            local num=tankData[2] or 0
            if tankCfg[tid]==nil then
                do return cell end
            end

            local iconStr=tankCfg[tid].icon
            local nameStr=getlocal(tankCfg[tid].name)
            local tankeTransRate
            if exchangeRate and type(exchangeRate)=="number" then
              tankeTransRate=exchangeRate
            end
            if tankeTransRate==nil then
              if battleType and battleType==1 then
                  tankeTransRate=allianceWar2Cfg.tankeTransRate
              elseif battleType and battleType==3 then --群雄争霸部队兑换比例
                  tankeTransRate=serverWarLocalCfg.tankeTransRate
              else
                  tankeTransRate=worldWarCfg.tankeTransRate
              end
            end
            local costNum=math.ceil(num/tankeTransRate)
            local posX=30+iSize/2
            local posY=cellHeight-iSize/2

            local icon1=tankVoApi:getTankIconSp(tid)--CCSprite:createWithSpriteFrameName(iconStr)
            local scale1=iSize/icon1:getContentSize().width
            icon1:setScale(scale1)
            icon1:setAnchorPoint(ccp(0.5,0.5))
            icon1:setPosition(ccp(posX,posY))
            cell:addChild(icon1)
            --是否精英坦克
            if G_pickedList(tid)~=tid then
                local sp1=CCSprite:createWithSpriteFrameName("picked_icon1.png")
                icon1:addChild(sp1,2)
                sp1:setPosition(icon1:getContentSize().width-30,60)
                sp1:setScale(1/scale1*1.2)
            end

            local icon2=tankVoApi:getTankIconSp(tid)
            local scale2=iSize/icon2:getContentSize().width
            icon2:setScale(scale2)
            icon2:setAnchorPoint(ccp(0.5,0.5))
            icon2:setPosition(ccp(cellWidth-posX,posY))
            cell:addChild(icon2)
            --是否精英坦克
            if G_pickedList(tid)~=tid then
                local sp2=CCSprite:createWithSpriteFrameName("picked_icon1.png")
                icon2:addChild(sp2,2)
                sp2:setPosition(icon2:getContentSize().width-30,60)
                sp2:setScale(1/scale2*1.2)
            end

            local arrow=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
            arrow:setPosition(ccp(cellWidth/2,posY))
            arrow:setFlipX(true)
            cell:addChild(arrow)
            -- arrow:setRotation(-90)

            local numHeight=28
            -- local capInSet = CCRect(5, 5, 1, 1)
            local function touchClick()
            end
            local numIcon1 =LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),touchClick)
            numIcon1:setOpacity(150)
            numIcon1:setContentSize(CCSizeMake(iSize-10,36))
            numIcon1:ignoreAnchorPointForPosition(false)
            numIcon1:setAnchorPoint(CCPointMake(0.5,0))
            numIcon1:setPosition(ccp(iSize/2,5))
            icon1:addChild(numIcon1,1)
            local newsNumLabel1 = GetTTFLabel(costNum,numHeight)
            newsNumLabel1:setPosition(getCenterPoint(numIcon1))
            numIcon1:addChild(newsNumLabel1,1)
            newsNumLabel1:setColor(G_ColorRed)

            local numIcon2 =LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),touchClick)
            numIcon2:setOpacity(150)
            numIcon2:setContentSize(CCSizeMake(iSize-10,36))
            numIcon2:ignoreAnchorPointForPosition(false)
            numIcon2:setAnchorPoint(CCPointMake(0.5,0))
            numIcon2:setPosition(ccp(iSize/2,5))
            icon2:addChild(numIcon2,1)
            local newsNumLabel2 = GetTTFLabel(num,numHeight)
            newsNumLabel2:setPosition(getCenterPoint(numIcon2))
            numIcon2:addChild(newsNumLabel2,1)

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local cellWidth=self.bgLayer:getContentSize().width-40
    local hd= LuaEventHandler:createHandler(tvCallBack)
    self.refreshData.tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,self.bgSize.height-270),nil)
    self.refreshData.tableView:setTableViewTouchPriority(-(layerNum-1)*20-3)
    self.refreshData.tableView:setPosition(ccp(20,120))
    self.bgLayer:addChild(self.refreshData.tableView,2)
    self.refreshData.tableView:setMaxDisToBottomOrTop(120)

    self:addForbidSp(self.bgLayer,size,layerNum)

    local btnScale = 0.7
    --取消
    local function cancleHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local cancleItem
    if rightBtnStr and rightBtnStr~="" then
        cancleItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",cancleHandler,2,rightBtnStr,25/btnScale)
    else
        cancleItem=GetButtonItem("newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn_Down.png",cancleHandler,2,getlocal("cancel"),25/btnScale)
    end
    cancleItem:setScale(btnScale)
    -- local cancleItem=GetButtonItem("BtnGraySmall.png","BtnGraySmall_Down.png","BtnGraySmall_Down.png",cancleHandler,2,rightStr,25)
    local cancleMenu=CCMenu:createWithItem(cancleItem);
    cancleMenu:setPosition(ccp(size.width-120,60))
    cancleMenu:setTouchPriority(-(layerNum-1)*20-4);
    dialogBg:addChild(cancleMenu)
    --确定
    local function sureHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if callback then
            callback()
        end
        self:close()
    end
    local leftStr=getlocal("ok")
    if leftBtnStr and leftBtnStr~="" then
        leftStr=leftBtnStr
    end
    local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",sureHandler,2,leftStr,25/btnScale)
    sureItem:setScale(btnScale)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(120,60))
    sureMenu:setTouchPriority(-(layerNum-1)*20-4);
    dialogBg:addChild(sureMenu)


    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer

end

function smallDialog:initAlienTechSlotDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,techId)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()

    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog()

    end

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    -- self:userHandler()

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)


    local bgWidth=self.bgSize.width
    local bgHeight=self.bgSize.height

    local titleLb=GetTTFLabel(getlocal("world_scene_info"),30)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(bgWidth/2,bgHeight-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)



    if techId and techId~=0 then
        local tCfg=alienTechCfg.talent[techId]
        if tCfg~=nil then
            local iconStr=tCfg[alienTechCfg.keyCfg.icon][1]
            local subIconStr=tCfg[alienTechCfg.keyCfg.icon][2]
            local addAttrTb=tCfg[alienTechCfg.keyCfg.value]
            local level=alienTechVoApi:getTechLevel(techId)

            local spaceX=20
            local SpHeight=60
            local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png");
            --bgSp:setAnchorPoint(ccp(0,0))
            bgSp:setPosition(ccp(bgWidth/2+20,bgHeight-150))
            bgSp:setScaleX(bgWidth/bgSp:getContentSize().width)
            bgSp:setScaleY(SpHeight/bgSp:getContentSize().height)
            dialogBg:addChild(bgSp)

            local name=alienTechVoApi:getTechName(techId).." "..getlocal("fightLevel",{level})
            -- name="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
            local nameLb=GetTTFLabelWrap(name,25,CCSize(bgWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            nameLb:setAnchorPoint(ccp(0.5,0.5))
            nameLb:setPosition(ccp(bgWidth/2,bgHeight-150))
            dialogBg:addChild(nameLb,2)

            local iSize=100
            local posY=bgHeight-270
            local icon=CCSprite:createWithSpriteFrameName(iconStr)
            icon:setScale(iSize/icon:getContentSize().width)
            icon:setAnchorPoint(ccp(0.5,0.5))
            icon:setPosition(ccp(spaceX+iSize/2,posY))
            dialogBg:addChild(icon)
            if subIconStr and subIconStr~="" then
                local subIcon=CCSprite:createWithSpriteFrameName(subIconStr)
                subIcon:setPosition(ccp(subIcon:getContentSize().width/2+10,icon:getContentSize().height-subIcon:getContentSize().height/2-10))
                icon:addChild(subIcon,1)
            end


            local curAddTb
            if level==0 then
                curAddTb=addAttrTb[1]
            else
                curAddTb=addAttrTb[level]
            end
            if curAddTb and SizeOfTable(curAddTb)>0 then
                local desc=""--alienTechVoApi:getTechDesc(techId)
                for k,v in pairs(curAddTb) do
                    local addAttrStr,skillType=alienTechVoApi:getAddAttrStr(k)
                    if skillType==1 then
                        desc=desc..addAttrStr.."+1,"
                    else
                        local addStr="+"..v..","
                        if k and tonumber(k) then
                            local sType=tonumber(k)
                            if sType==102 or sType==103 or sType==104 or sType==105 or sType==110 or sType==111 then
                                addStr="+"..v.."%,"
                            end
                        end
                        desc=desc..addAttrStr..addStr
                    end
                end
                if desc~="" then
                    desc=string.sub(desc,1,-2)
                end
                -- desc="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
                local descLb=GetTTFLabelWrap(desc,25,CCSize(bgWidth-iSize-spaceX-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                descLb:setAnchorPoint(ccp(0,0.5))
                descLb:setPosition(ccp(spaceX+iSize+10,posY))
                dialogBg:addChild(descLb,1)
            end

        end
    end


    --确定
    local function sureHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        self:close()
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("confirm"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(size.width/2,60+10))
    sureMenu:setTouchPriority(-(layerNum-1)*20-5);
    dialogBg:addChild(sureMenu)



    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

function smallDialog:initAlienTechUnlockSlotDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callback,type,tankId,unlockSlotIndex)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()

    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog()

    end

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    -- self:userHandler()

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)


    local bgWidth=self.bgSize.width
    local bgHeight=self.bgSize.height

    local titleLb=GetTTFLabel(getlocal("alien_tech_unlock_slot"),30)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(bgWidth/2,bgHeight-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)



    local iconSize=80
    local iconBg=CCSprite:createWithSpriteFrameName("Icon_BG.png")
    local lockSp=CCSprite:createWithSpriteFrameName("alienTechLock.png")
    lockSp:setPosition(getCenterPoint(iconBg))
    iconBg:addChild(lockSp,1)
    iconBg:setScale(iconSize/iconBg:getContentSize().width)
    -- iconBg:setPosition(ccp(iconSize/2+30,bgHeight-180+10))
    -- dialogBg:addChild(iconBg,2)

    local techBgSp=CCSprite:createWithSpriteFrameName("alienTechBg1.png")
    techBgSp:setPosition(ccp(iconSize/2+35,bgHeight-180+10))
    iconBg:setPosition(getCenterPoint(techBgSp))
    techBgSp:addChild(iconBg,1)
    dialogBg:addChild(techBgSp,1)


    local nameStr=getlocal("alien_tech_slot")
    -- nameStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local nameLb=GetTTFLabelWrap(nameStr,30,CCSize(bgWidth-iconSize-70-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    nameLb:setAnchorPoint(ccp(0,0.5))
    nameLb:setPosition(ccp(iconSize+60,bgHeight-180+35+10))
    dialogBg:addChild(nameLb,2)
    nameLb:setColor(G_ColorYellowPro)

    local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
    local typeStr=getlocal("alien_tech_type",{getlocal(tankCfg[tid].name)})
    -- typeStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local typeLb=GetTTFLabelWrap(typeStr,25,CCSize(bgWidth-iconSize-70-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    typeLb:setAnchorPoint(ccp(0,0.5))
    typeLb:setPosition(ccp(iconSize+60,bgHeight-180-35+10))
    dialogBg:addChild(typeLb,2)



    local spBgWidth=bgWidth-40
    local spBgHeight=260
    local function touch()
    end
    local bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
    bgSprie:setContentSize(CCSizeMake(spBgWidth,spBgHeight))
    bgSprie:setPosition(ccp(bgWidth/2,spBgHeight/2+115+20))
    bgSprie:setIsSallow(false)
    bgSprie:setTouchPriority(-(layerNum-1)*20-2)
    dialogBg:addChild(bgSprie,1)

    local isCanUnlock=false
    local tNum1=0
    local tNum2=0
    local needTankNum=0
    local slotTb=alienTechVoApi:getSlotByTank(tankId)
    local lockNum=0
    for k,v in pairs(slotTb) do
        if v and v==-1 then
            lockNum=lockNum+1
        end
    end
    local id=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
    local slotCost=tankCfg[id].slotCost
    local costCfgNum=SizeOfTable(slotCost)
    local unlockIndex
    local itemTb
    if costCfgNum>0 and costCfgNum>=lockNum then
        unlockIndex=costCfgNum-lockNum+1
        if slotCost[unlockIndex] then
            isCanUnlock=true
            itemTb=FormatItem(slotCost[unlockIndex])
            local itemNum=SizeOfTable(itemTb)
            for k,v in pairs(itemTb) do
                local iSize=100
                local icon,iiScale=G_getItemIcon(v,iSize,true,layerNum)
                icon:setTouchPriority(-(layerNum-1)*20-3)
                local px,py=spBgWidth/2-(itemNum-1)*120/2+(k-1)*120,iSize/2+20
                icon:setPosition(ccp(px,py))
                bgSprie:addChild(icon)

                local num=v.num
                local numLb=GetTTFLabel("x"..FormatNumber(num),20)
                numLb:setAnchorPoint(ccp(1,0))
                numLb:setPosition(ccp(icon:getContentSize().width-10,5))
                icon:addChild(numLb,1)
                numLb:setScale(1/iiScale)
                local color=G_ColorWhite

                if v.type=="u" then
                    local pKey
                    if v.key=="gem" then
                        pKey="gems"
                    else
                        pKey=v.key
                    end
                    if playerVo[pKey] and playerVo[pKey]<num then
                        isCanUnlock=false
                        color=G_ColorRed
                    end
                elseif v.type=="p" then
                    local proid=(tonumber(v.key) or tonumber(RemoveFirstChar(v.key)))
                    local pNum=bagVoApi:getItemNumId(proid)
                    if pNum and pNum<num then
                        isCanUnlock=false
                        color=G_ColorRed
                    end
                elseif v.type=="o" then
                    local tid=(tonumber(v.key) or tonumber(RemoveFirstChar(v.key)))
                    tNum1=tankVoApi:getTankCountByItemId(tid)
                    tNum2=tankVoApi:getTankCountByItemId(tid+40000)
                    local tNum=tNum1+tNum2
                    needTankNum=num
                    if tNum and tNum<num then
                        isCanUnlock=false
                        color=G_ColorRed
                    end
                elseif v.type=="r" then
                    local rNum=alienTechVoApi:getAlienResByType(v.key)
                    if rNum and rNum<num then
                        isCanUnlock=false
                        color=G_ColorRed
                    end
                end
                numLb:setColor(color)
            end
        end
    end

    local checkOutStr=getlocal("alien_tech_check_out")
    -- checkOutStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local checkOutLb=GetTTFLabelWrap(checkOutStr,25,CCSize(spBgWidth-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    checkOutLb:setAnchorPoint(ccp(0.5,0.5))
    checkOutLb:setPosition(ccp(spBgWidth/2,spBgHeight-40))
    bgSprie:addChild(checkOutLb,2)
    checkOutLb:setColor(G_ColorYellowPro)

    local unlockStr=""
    if isCanUnlock==true then
        unlockStr=getlocal("alien_tech_slot_can_unlock")
    else
        unlockStr=getlocal("alien_tech_unlock_res_not_enough")
    end
    -- unlockStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local unlockLb=GetTTFLabelWrap(unlockStr,25,CCSize(spBgWidth-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    unlockLb:setAnchorPoint(ccp(0.5,0.5))
    unlockLb:setPosition(ccp(spBgWidth/2,spBgHeight-100))
    bgSprie:addChild(unlockLb,2)
    if isCanUnlock==true then
        unlockLb:setColor(G_ColorYellowPro)
    else
        unlockLb:setColor(G_ColorRed)
    end


    --解锁
    local function unlockHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local function unlockCallback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if self.unlockAlienTechSlotBtn then
                    self.unlockAlienTechSlotBtn:setEnabled(false)
                end

                alienTechVoApi:setTechData(sData.data.alien)

                if itemTb and SizeOfTable(itemTb)>0 then
                    for k,v in pairs(itemTb) do
                        local num=v.num
                        if v.type=="u" then
                            local pKey
                            if v.key=="gem" then
                                pKey="gems"
                            else
                                pKey=v.key
                            end
                            if playerVo[pKey] then
                                playerVo[pKey]=playerVo[pKey]-num
                                if playerVo[pKey]<0 then
                                    playerVo[pKey]=0
                                end
                            end
                        elseif v.type=="p" then
                            local id=(tonumber(v.key) or tonumber(RemoveFirstChar(v.key)))
                            bagVoApi:useItemNumId(id,num)
                        end
                    end
                end

                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alien_tech_unlock_slot_success"),30)
            end

            if callback then
                callback()
            end

            self:close()
        end
        local solt=unlockSlotIndex

        local enum=0
        if needTankNum>tNum1 then
          enum=needTankNum-tNum1
        end

        local function socketFunc()
            socketHelper:alienOpensolt(tankId,solt,unlockCallback,enum)
        end
        if enum>0 then
          smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),socketFunc,getlocal("dialog_title_prompt"),getlocal("alien_tech_smelt_tip2",{enum}),nil,layerNum+1)
        else
          socketFunc()
        end
    end
    local unlockItem=GetButtonItem("LoadingBtn.png","LoadingBtn_Down.png","LoadingBtn_Down.png",unlockHandler,2,getlocal("alien_tech_unlock"),25)
    local unlockMenu=CCMenu:createWithItem(unlockItem);
    unlockMenu:setPosition(ccp(size.width/2,60+10))
    unlockMenu:setTouchPriority(-(layerNum-1)*20-5);
    dialogBg:addChild(unlockMenu)
    if isCanUnlock==false then
        unlockItem:setEnabled(false)
    end
    self.unlockAlienTechSlotBtn=unlockItem


    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

function smallDialog:initAlienTechSkillDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callback,tType,tankId,index)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()

    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog()

    end

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    -- self:userHandler()

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)


    local bgWidth=self.bgSize.width
    local bgHeight=self.bgSize.height


    local techTb=alienTechVoApi:getCanUseTechTbByTank(tType,tankId)


    local titleLb=GetTTFLabel(getlocal("alien_tech_wear"),32,true)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(bgWidth/2,bgHeight-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)


    self.refreshData={}
    local isMoved=false
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            local num=SizeOfTable(techTb)
            return num
        elseif fn=="tableCellSizeForIndex" then
            local cellWidth=self.bgSize.width-40
            local cellHeight=180
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local cellWidth=self.bgSize.width-40
            local cellHeight=180

            local tachData=techTb[idx+1]
            if tachData==nil or SizeOfTable(tachData)==0 or tachData.tid==nil then
                do return cell end
            end
            local techId=tachData.tid
            local sameTypeTechId=tachData.techId
            if techId and techId~=0 then
            else
                do return cell end
            end
            local status=tachData.status or 3

            local tCfg=alienTechCfg.talent[techId]
            if tCfg==nil then
                do return cell end
            end
            local iconStr=tCfg[alienTechCfg.keyCfg.icon][1]
            local subIconStr=tCfg[alienTechCfg.keyCfg.icon][2]
            local addAttrTb=tCfg[alienTechCfg.keyCfg.value]
            local level=alienTechVoApi:getTechLevel(techId)


            local spaceX=10
            local bgHeight=60
            local bgSp=CCSprite:createWithSpriteFrameName("groupSelf.png");
            --bgSp:setAnchorPoint(ccp(0,0))
            bgSp:setPosition(ccp(cellWidth/2+20,cellHeight-30))
            bgSp:setScaleX(cellWidth/bgSp:getContentSize().width)
            bgSp:setScaleY(bgHeight/bgSp:getContentSize().height)
            cell:addChild(bgSp)

            local name=alienTechVoApi:getTechName(techId).." "..getlocal("fightLevel",{level})
            -- name="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
            local nameLb=GetTTFLabelWrap(name,24,CCSize(cellWidth-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
            nameLb:setAnchorPoint(ccp(0.5,0.5))
            nameLb:setPosition(ccp(cellWidth/2,cellHeight-30))
            cell:addChild(nameLb,2)


            local iSize=100
            local posY=(cellHeight-bgHeight)/2
            local icon=CCSprite:createWithSpriteFrameName(iconStr)
            icon:setScale(iSize/icon:getContentSize().width)
            icon:setAnchorPoint(ccp(0.5,0.5))
            icon:setPosition(ccp(spaceX+iSize/2,posY))
            cell:addChild(icon)
            if subIconStr and subIconStr~="" then
                local subIcon=CCSprite:createWithSpriteFrameName(subIconStr)
                subIcon:setPosition(ccp(subIcon:getContentSize().width/2+10,icon:getContentSize().height-subIcon:getContentSize().height/2-10))
                icon:addChild(subIcon,1)
            end

            local curAddTb
            if level==0 then
                curAddTb=addAttrTb[1]
            else
                curAddTb=addAttrTb[level]
            end
            local numSize=20
            if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
                numSize =20
            end

            if curAddTb and type(curAddTb)=="table" and SizeOfTable(curAddTb)>0 then
                local desc=""
                for k,v in pairs(curAddTb) do
                    local addAttrStr,skillType=alienTechVoApi:getAddAttrStr(k)
                    if skillType==1 then
                        desc=desc..addAttrStr.."+1,"
                    else
                        local addStr="+"..v..","
                        if k and tonumber(k) then
                            local sType=tonumber(k)
                            if sType==102 or sType==103 or sType==104 or sType==105 or sType==110 or sType==111 then
                                addStr="+"..v.."%,"
                            end
                        end
                        desc=desc..addAttrStr..addStr.."\n"
                    end
                end
                if desc~="" then
                    desc=string.sub(desc,1,-2)
                end
                -- desc="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
                local descLb=GetTTFLabelWrap(desc,numSize,CCSize(cellWidth-iSize-spaceX-10-170,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                descLb:setAnchorPoint(ccp(0,0.5))
                descLb:setPosition(ccp(spaceX+iSize+10,posY))
                cell:addChild(descLb,1)
            end

            local posX=444
            if (status==0 or status==2) and level>0 then
                local function wearHandler()
                    if self and self.refreshData and self.refreshData.tableView and self.refreshData.tableView:getScrollEnable()==true and self.refreshData.tableView:getIsScrolled()==false then
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
                        else
                            base.setWaitTime=G_getCurDeviceMillTime()
                        end
                        PlayEffect(audioCfg.mouseClick)

                        -- if sameTypeTechId then

                        -- end

                        local function alienUseCallback(fn,data)
                            local ret,sData=base:checkServerData(data)
                            if ret==true then
                                alienTechVoApi:setTechData(sData.data.alien)
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alien_tech_use_success"),30)

                                if callback then
                                    callback()
                                end

                                self:close()
                            end
                        end
                        if index and index<=4 then
                            local uIdx=0
                            local usedAlienTech=alienTechVoApi:getUsedAlienTech()
                            if usedAlienTech and usedAlienTech[tankId] and SizeOfTable(usedAlienTech[tankId])>0 then
                                local usedTb=usedAlienTech[tankId]
                                for k,v in pairs(usedTb) do
                                    if v and k<=index+uIdx then
                                        if type(v)=="string" then
                                            local talentType=alienTechCfg.talent[v][alienTechCfg.keyCfg.talentType]
                                            if talentType==2 then
                                                uIdx=uIdx+1
                                            end
                                        end
                                    end
                                end
                            end
                            local pos=index+uIdx
                            socketHelper:alienUse(techId,tankId,pos,alienUseCallback)
                        end
                    end
                end
                local wearItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",wearHandler,2,getlocal("alien_tech_wear"),24/0.5,101)
                wearItem:setScale(0.5)
                local btnLb = wearItem:getChildByTag(101)
                if btnLb then
                  btnLb = tolua.cast(btnLb,"CCLabelTTF")
                  btnLb:setFontName("Helvetica-bold")
                end
                local wearMenu=CCMenu:createWithItem(wearItem)
                wearMenu:setPosition(ccp(posX,posY))
                wearMenu:setTouchPriority(-(layerNum-1)*20-2)
                cell:addChild(wearMenu)
            else
                local statusStr=getlocal("alien_tech_used_status_"..status)
                if level==0 then
                    statusStr=getlocal("alien_tech_used_status_3")
                end
                local statusLb=GetTTFLabelWrap(statusStr,20,CCSize(135,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                statusLb:setAnchorPoint(ccp(0.5,0.5))
                statusLb:setPosition(ccp(posX,posY))
                cell:addChild(statusLb,1)
                if status==3 or level==0 then
                    statusLb:setColor(G_ColorRed)
                end
            end

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local cellWidth=self.bgLayer:getContentSize().width-40
    local hd= LuaEventHandler:createHandler(tvCallBack)
    self.refreshData.tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,self.bgSize.height-115),nil)
    self.refreshData.tableView:setTableViewTouchPriority(-(layerNum-1)*20-3)
    self.refreshData.tableView:setPosition(ccp(20,20))
    self.bgLayer:addChild(self.refreshData.tableView,2)
    self.refreshData.tableView:setMaxDisToBottomOrTop(120)

    self:addForbidSp(self.bgLayer,size,layerNum)




    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer

end

function smallDialog:initAlienTechInfoDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callback,tType,techId)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()

    local tCfg=alienTechCfg.talent[techId]
    local icon=tCfg[alienTechCfg.keyCfg.icon][1]
    local subIcon=tCfg[alienTechCfg.keyCfg.icon][2]
    local talentType=tCfg[alienTechCfg.keyCfg.talentType]
    local enableRequireLv=tCfg[alienTechCfg.keyCfg.enableRequireLv]
    local name=alienTechVoApi:getTechName(techId)
    local desc,needPoint=alienTechVoApi:getTechDesc(techId)
    local hasTotalPoint=alienTechVoApi:getPointByType(tType)
    local isUnlock=alienTechVoApi:getTechIsUnlock(techId,tType)
    local effectTroops=G_clone(tCfg[alienTechCfg.keyCfg.effectTroops])
    if effectTroops and type(effectTroops)=="string" and effectTroops~="" then
        effectTroops={effectTroops}
    end
    local isShowGai,tankGaiId=alienTechVoApi:getIsShowTankGaiBySid(techId)
    if isShowGai==true and tankGaiId then
        table.insert(effectTroops,tankGaiId)
    end
    local resourceConsume=tCfg[alienTechCfg.keyCfg.resourceConsume]
    local maxLv=tCfg[alienTechCfg.keyCfg.maxLv]
    local addAttrTb=G_clone(tCfg[alienTechCfg.keyCfg.value])
    if addAttrTb and addAttrTb[1] and addAttrTb[1]==0 then
        addAttrTb={}
    end


    local bgWidth=size.width
    local cellHeight=0
    local function getCellHeight()
        if cellHeight==0 then
            cellHeight=200
            if effectTroops and SizeOfTable(effectTroops)>0 then
                cellHeight=cellHeight+200
            end
            local curLevel=alienTechVoApi:getTechLevel(techId) or 0
            local maxLevel=maxLv
            if curLevel<maxLevel then
                local attrNum=SizeOfTable(addAttrTb[curLevel+1] or {})
                local costTb=resourceConsume[curLevel+1] or 0
                local itemTb=FormatItem(costTb)
                if itemTb and SizeOfTable(itemTb)>0 then
                    cellHeight=cellHeight+attrNum*80+200
                end
            else
                local attrNum=SizeOfTable(addAttrTb[maxLevel] or {})
                cellHeight=cellHeight+attrNum*80
            end
            if talentType and talentType==3 then
                -- local tankId=effectTroops[1]
                -- local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
                -- local unlockDescLb=GetTTFLabelWrap(getlocal("alien_tech_unlock_tank_upgrade",{getlocal(tankCfg[tid].name)}),25,CCSize(bgWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                -- cellHeight=cellHeight+unlockDescLb:getContentSize().height+20
                for k,v in pairs(effectTroops) do
                    local tankId=v
                    local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
                    local unlockDescLb=GetTTFLabelWrap(getlocal("alien_tech_unlock_tank_upgrade",{getlocal(tankCfg[tid].name)}),24,CCSize(bgWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    cellHeight=cellHeight+unlockDescLb:getContentSize().height+10
                end
            end
            if enableRequireLv and SizeOfTable(enableRequireLv)>0 then
                local lb1=GetTTFLabelWrap(getlocal("alien_tech_need_front_tech"),24,CCSize(bgWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                local rHeight=lb1:getContentSize().height+5
                for k,v in pairs(enableRequireLv) do
                    local lb=GetTTFLabelWrap(getlocal("alien_tech_level_tech",{alienTechVoApi:getTechName(k),v}),24,CCSize(bgWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    rHeight=rHeight+lb:getContentSize().height+5
                end
                cellHeight=cellHeight+rHeight+10
            end
        end
        return cellHeight
    end

    local cHeight=getCellHeight()
    --size.height=820
    local bgHeight=cHeight+160
    if cHeight+160>size.height then
        bgHeight=size.height
    end

    self.bgLayer=dialogBg
    self.bgSize=CCSize(size.width,bgHeight)
    self.bgLayer:setContentSize(self.bgSize)
    self:show()

    local function touchDialog()

    end

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    -- self:userHandler()



    local titleLb=GetTTFLabel(name,32,true)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)


    self.refreshData={}
    local spaceY=0
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 1
        elseif fn=="tableCellSizeForIndex" then
            local bgHeight=getCellHeight()
            local tmpSize=CCSizeMake(bgWidth,bgHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local bgHeight=getCellHeight()
            local curLevel=alienTechVoApi:getTechLevel(techId) or 0
            local maxLevel=maxLv
            local addTb
            local addAttrHeight=0
            if curLevel<maxLevel then
                addTb=addAttrTb[curLevel+1] or {}
            else
                addTb=addAttrTb[maxLevel] or {}
            end
            if addTb and SizeOfTable(addTb)>0 then
                addAttrHeight=SizeOfTable(addTb)*80
            else
                -- if talentType and talentType==3 and effectTroops[1] then
                --     local tankId=effectTroops[1]
                --     local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
                --     local unlockDescLb1=GetTTFLabelWrap(getlocal("alien_tech_unlock_tank_upgrade",{getlocal(tankCfg[tid].name)}),25,CCSize(bgWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                --     addAttrHeight=unlockDescLb1:getContentSize().height+20
                -- end
                if talentType and talentType==3 then
                    for k,v in pairs(effectTroops) do
                        local tankId=v
                        local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
                        local unlockDescLb1=GetTTFLabelWrap(getlocal("alien_tech_unlock_tank_upgrade",{getlocal(tankCfg[tid].name)}),24,CCSize(bgWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                        addAttrHeight=addAttrHeight+unlockDescLb1:getContentSize().height+10
                    end
                end
            end

            local rHeight=0
            if enableRequireLv and SizeOfTable(enableRequireLv)>0 then
                local lb1=GetTTFLabelWrap(getlocal("alien_tech_need_front_tech"),24,CCSize(bgWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                rHeight=lb1:getContentSize().height+5
                for k,v in pairs(enableRequireLv) do
                    local lb=GetTTFLabelWrap(getlocal("alien_tech_level_tech",{alienTechVoApi:getTechName(k),v}),24,CCSize(bgWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    rHeight=rHeight+lb:getContentSize().height+5
                end
                addAttrHeight=addAttrHeight+rHeight+10
            end


            local spaceX=30
            local tSize=100
            local tIcon=CCSprite:createWithSpriteFrameName(icon)
            local tScale=tSize/tIcon:getContentSize().width
            tIcon:setScale(tScale)
            tIcon:setPosition(ccp(tSize/2+spaceX,bgHeight-tSize/2+spaceY))
            cell:addChild(tIcon,1)
            if subIcon and subIcon~="" then
                local tSubIcon=CCSprite:createWithSpriteFrameName(subIcon)
                tSubIcon:setPosition(ccp(tSubIcon:getContentSize().width/2+10,tIcon:getContentSize().height-tSubIcon:getContentSize().height/2-10))
                tIcon:addChild(tSubIcon,1)
            end


            local levelLb=GetTTFLabel(getlocal("fightLevel",{curLevel}),24)
            levelLb:setAnchorPoint(ccp(0,0.5))
            levelLb:setPosition(ccp(tSize+spaceX+10,tIcon:getPositionY()))
            cell:addChild(levelLb)
            levelLb:setColor(G_ColorYellowPro)


            local lx,ly=levelLb:getPosition()
            if curLevel<maxLevel then
                local aIcon = CCSprite:createWithSpriteFrameName("heroArrowRight.png")
                aIcon:setAnchorPoint(ccp(0,0.5))
                aIcon:setPosition(ccp(lx+levelLb:getContentSize().width+10,ly))
                cell:addChild(aIcon)

                local nextLevelLb=GetTTFLabel(getlocal("fightLevel",{curLevel+1}),24)
                nextLevelLb:setAnchorPoint(ccp(0,0.5))
                nextLevelLb:setPosition(ccp(lx+levelLb:getContentSize().width+aIcon:getContentSize().width+20,ly))
                cell:addChild(nextLevelLb)
                nextLevelLb:setColor(G_ColorYellowPro)
            end

            -- desc="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
            -- local descLb=G_LabelTableView(CCSize(bgWidth-tSize-60,72),desc,20,kCCTextAlignmentLeft)
            -- descLb:setPosition(ccp(lx,bgHeight-95+spaceY))
            -- descLb:setTableViewTouchPriority(-(layerNum-1)*20-2)
            -- descLb:setMaxDisToBottomOrTop(70)
            local descLb=GetTTFLabelWrap(desc,20,CCSize(bgWidth-tSize-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            descLb:setAnchorPoint(ccp(0,0.5))
            descLb:setPosition(ccp(lx,bgHeight-65+spaceY-15))
            cell:addChild(descLb,1)
            if needPoint<=0 then
                descLb:setVisible(false)
            elseif hasTotalPoint and hasTotalPoint<needPoint then
                descLb:setColor(G_ColorRed)
            end

            if enableRequireLv and SizeOfTable(enableRequireLv)>0 then
                local lb1=GetTTFLabelWrap(getlocal("alien_tech_need_front_tech"),24,CCSize(bgWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                lb1:setAnchorPoint(ccp(0,1))
                lb1:setPosition(ccp(lx-tSize-10,bgHeight-65+spaceY-50))
                cell:addChild(lb1,1)
                rHeight=lb1:getContentSize().height+5
                for k,v in pairs(enableRequireLv) do
                    local lb=GetTTFLabelWrap(getlocal("alien_tech_level_tech",{alienTechVoApi:getTechName(k),v}),24,CCSize(bgWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    lb:setAnchorPoint(ccp(0,1))
                    lb:setPosition(ccp(lx-tSize-10,bgHeight-65+spaceY-50-rHeight))
                    if alienTechVoApi:getTechLevel(k)>=v then
                    else
                        lb:setColor(G_ColorRed)
                    end
                    cell:addChild(lb,1)
                    rHeight=rHeight+lb:getContentSize().height+5
                end
                rHeight=rHeight+10
            end

            local index=0
            if addTb and SizeOfTable(addTb)>0 then
                for k,v in pairs(addTb) do
                    local attrStr,skillType=alienTechVoApi:getAddAttrStr(k)
                    local attrLb=GetTTFLabel(attrStr,24)
                    attrLb:setAnchorPoint(ccp(0,0.5))
                    attrLb:setPosition(ccp(spaceX+20,bgHeight-attrLb:getContentSize().height/2-110-index*80+spaceY-rHeight))
                    cell:addChild(attrLb)
                    attrLb:setColor(G_ColorYellowPro)


                    local proScaleX=1.14
                    local curNum,nextNum=alienTechVoApi:getTechValue(techId,k)
                    local maxNum=addAttrTb[maxLevel][k]
                    if skillType==1 then
                        maxNum=1
                    else
                        maxNum=addAttrTb[maxLevel][k]
                    end
                    if nextNum>maxNum then
                        nextNum=maxNum
                    end
                    local attrPercent=(nextNum/maxNum)*100
                    local attrPercentStr=getlocal("scheduleChapter",{nextNum,maxNum})

                    local curNum=0
                    if curLevel>0 and curLevel<=maxLevel then
                        curNum=addAttrTb[curLevel][k] or 0
                    end
                    if curNum>maxNum then
                        curNum=maxNum
                    end
                    local attrPercent1=(curNum/maxNum)*100
                    local attrPercentStr1=getlocal("scheduleChapter",{curNum,maxNum})

                    if skillType~=1 then
                        if k and tonumber(k) then
                            local sType=tonumber(k)
                            if sType==102 or sType==103 or sType==104 or sType==105 or sType==110 or sType==111 then
                                attrPercentStr=getlocal("alien_tech_scheduleChapter",{nextNum,maxNum})
                                attrPercentStr1=getlocal("alien_tech_scheduleChapter",{curNum,maxNum})
                            end
                        end
                    end

                    AddProgramTimer(cell,ccp(bgWidth/2,bgHeight-attrLb:getContentSize().height-130-index*80+spaceY-rHeight),101+index,201+index,attrPercentStr,"VipIconYellowBarBg.png","VipIconYellowBar.png",301+index,proScaleX,nil,120)
                    local attrProgress=cell:getChildByTag(101+index)
                    tolua.cast(cell:getChildByTag(301+index),"CCSprite"):setVisible(false)
                    tolua.cast(attrProgress:getChildByTag(201+index),"CCLabelTTF"):setVisible(false)

                    AddProgramTimer(cell,ccp(bgWidth/2,bgHeight-attrLb:getContentSize().height-130-index*80+spaceY-rHeight),1001+index,2001+index,attrPercentStr1,"VipIconYellowBarBg.png","VipIconYellowBar.png",3001+index,proScaleX)
                    attrProgress1=cell:getChildByTag(1001+index)

                    attrProgress:setPercentage(attrPercent)
                    attrProgress1:setPercentage(attrPercent1)
                    tolua.cast(attrProgress1:getChildByTag(2001+index),"CCLabelTTF"):setString(attrPercentStr1)

                    index=index+1
                end
            else
                if talentType and talentType==3 then
                    -- local tankId=effectTroops[1]
                    -- local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
                    -- local unlockDescLb=GetTTFLabelWrap(getlocal("alien_tech_unlock_tank_upgrade",{getlocal(tankCfg[tid].name)}),25,CCSize(bgWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    -- unlockDescLb:setAnchorPoint(ccp(0,1))
                    -- unlockDescLb:setPosition(ccp(spaceX+20,bgHeight-110-index*80+spaceY-rHeight))
                    -- cell:addChild(unlockDescLb)
                    -- unlockDescLb:setColor(G_ColorYellowPro)
                    local tempPosy=bgHeight-110-index*80+spaceY-rHeight
                    for k,v in pairs(effectTroops) do
                        local tankId=v
                        local tid=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))
                        local unlockDescLb=GetTTFLabelWrap(getlocal("alien_tech_unlock_tank_upgrade",{getlocal(tankCfg[tid].name)}),24,CCSize(bgWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                        unlockDescLb:setAnchorPoint(ccp(0,1))
                        unlockDescLb:setPosition(ccp(spaceX,tempPosy))
                        cell:addChild(unlockDescLb)
                        unlockDescLb:setColor(G_ColorYellowPro)
                        tempPosy=tempPosy-(unlockDescLb:getContentSize().height+10)
                    end
                end
            end


            local bgSpHeight=60
            local iSize=100
            local isEffectTroops=0
            if effectTroops and SizeOfTable(effectTroops)>0 then
                local bgSp1=CCSprite:createWithSpriteFrameName("RankBtnTab_Down.png")
                bgSp1:setAnchorPoint(ccp(0,0))
                bgSp1:setPosition(ccp(spaceX,bgHeight-160-addAttrHeight+spaceY))
                -- bgSp1:setScaleX(cellWidth/bgSp:getContentSize().width)
                -- bgSp1:setScaleY(bgSpHeight/bgSp:getContentSize().height)
                cell:addChild(bgSp1)
                local subLb1FontSize = 24
                if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
                    subLb1FontSize = 24
                else
                    subLb1FontSize = 20
                end
                local subLb1=GetTTFLabelWrap(getlocal("alien_tech_apply_tank"),subLb1FontSize,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
                subLb1:setPosition(getCenterPoint(bgSp1))
                bgSp1:addChild(subLb1)
                for k,v in pairs(effectTroops) do
                    if v and v~="" then
                        local tankId=(tonumber(v) or tonumber(RemoveFirstChar(v)))
                        local iconStr=tankCfg[tankId].icon
                        local icon=tankVoApi:getTankIconSp(tankId)--CCSprite:createWithSpriteFrameName(iconStr)
                        local iScale=iSize/icon:getContentSize().width
                        icon:setScale(iScale)
                        local px,py=spaceX+iSize/2+(k-1)*(iSize+30),bgHeight-iSize/2-170-addAttrHeight+spaceY
                        icon:setPosition(ccp(px,py))
                        cell:addChild(icon)

                        local name=getlocal(tankCfg[tankId].name)
                        -- name="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
                        local tankNameLb=GetTTFLabelWrap(name,20,CCSize(iSize+20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                        tankNameLb:setPosition(ccp(px,py-iSize/2-30))
                        cell:addChild(tankNameLb,1)
                    end
                end

                isEffectTroops=1
            end



            if curLevel<maxLevel then
                local costTb=resourceConsume[curLevel+1]
                local itemTb=FormatItem(costTb)
                if itemTb and SizeOfTable(itemTb)>0 then
                    local bgSp2=CCSprite:createWithSpriteFrameName("RankBtnTab_Down.png")
                    bgSp2:setAnchorPoint(ccp(0,0))
                    bgSp2:setPosition(ccp(spaceX,bgHeight-190-200*isEffectTroops-addAttrHeight+spaceY))
                    -- bgSp1:setScaleX(cellWidth/bgSp:getContentSize().width)
                    -- bgSp1:setScaleY(bgSpHeight/bgSp:getContentSize().height)
                    cell:addChild(bgSp2)
                    local subLb2FontSize = 24
                    if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
                        subLb2FontSize = 24
                    else
                        subLb2FontSize = 20
                    end
                    local subLb2=GetTTFLabelWrap(getlocal("alien_tech_consume_material"),subLb2FontSize,CCSizeMake(110,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
                    subLb2:setPosition(getCenterPoint(bgSp2))
                    bgSp2:addChild(subLb2)

                    for k,v in pairs(itemTb) do
                        local index=0
                        if v.type=="p" then
                            index=(tonumber(v.key) or tonumber(RemoveFirstChar(v.key)))
                        elseif v.type=="o" then
                            index=(tonumber(v.key) or tonumber(RemoveFirstChar(v.key)))
                        elseif v.type=="r" then
                            index=(tonumber(v.key) or tonumber(RemoveFirstChar(v.key)))+100000
                        end
                        v.index=index
                    end
                    local function sortFunc(a,b)
                        if a and b and a.index and b.index then
                            return a.index<b.index
                        end
                    end
                    table.sort(itemTb,sortFunc)
                    for k,v in pairs(itemTb) do
                        if v then
                            local icon,icScale=G_getItemIcon(v,iSize)
                            local px,py=spaceX+iSize/2+(k-1)*(iSize+30),bgHeight-iSize/2-200-200*isEffectTroops-addAttrHeight+spaceY
                            icon:setPosition(ccp(px,py))
                            cell:addChild(icon)

                            local name=v.name
                            -- name="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
                            local nameLb=GetTTFLabelWrap(name,20,CCSize(iSize+20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                            nameLb:setPosition(ccp(px,py-iSize/2-30))
                            cell:addChild(nameLb,1)

                            local num=v.num
                            local numLb=GetTTFLabel("x"..num,20)
                            numLb:setAnchorPoint(ccp(1,0))
                            numLb:setPosition(ccp(icon:getContentSize().width-10,5))
                            icon:addChild(numLb,1)
                            numLb:setScale(1/icScale)

                            local color=G_ColorWhite
                            if v.type=="u" then
                                local pKey
                                if v.key=="gem" then
                                    pKey="gems"
                                else
                                    pKey=v.key
                                end
                                if playerVo[pKey] and playerVo[pKey]<num then
                                    color=G_ColorRed
                                end
                            elseif v.type=="p" then
                                local proid=(tonumber(v.key) or tonumber(RemoveFirstChar(v.key)))
                                local pNum=bagVoApi:getItemNumId(proid)
                                if pNum and pNum<num then
                                    color=G_ColorRed
                                end
                            elseif v.type=="o" then
                                local tid=(tonumber(v.key) or tonumber(RemoveFirstChar(v.key)))
                                local tNum=tankVoApi:getTankCountByItemId(tid)+tankVoApi:getTankCountByItemId(tid+40000)
                                if tNum and tNum<num then
                                    color=G_ColorRed
                                end
                            elseif v.type=="r" then
                                local rNum=alienTechVoApi:getAlienResByType(v.key)
                                if rNum and rNum<num then
                                    color=G_ColorRed
                                end
                            end
                            numLb:setColor(color)
                        end
                    end
                end
            end

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd= LuaEventHandler:createHandler(tvCallBack)
    self.refreshData.tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgSize.width,self.bgSize.height-180),nil)
    self.refreshData.tableView:setTableViewTouchPriority(-(layerNum-1)*20-3)
    self.refreshData.tableView:setPosition(ccp(0,110))
    self.bgLayer:addChild(self.refreshData.tableView,2)
    self.refreshData.tableView:setMaxDisToBottomOrTop(120)

    self:addForbidSp(self.bgLayer,size,layerNum)



    --升级
    local function upgradeHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)


        local function upgradeTechCallback()
            if self.refreshData.tableView then
                local recordPoint=self.refreshData.tableView:getRecordPoint()
                self.refreshData.tableView:reloadData()
                if getCellHeight()>self.bgSize.height-180 then
                    self.refreshData.tableView:recoverToRecordPoint(recordPoint)
                end
            end

            local teLv=alienTechVoApi:getTechLevel(techId)
            if teLv>=maxLv then
                if self.refreshData.upgradeBtn then
                    self.refreshData.upgradeBtn:setVisible(false)
                    self.refreshData.upgradeBtn:setEnabled(false)
                end
                if self.refreshData.sureBtn then
                    self.refreshData.sureBtn:setPosition(ccp(size.width/2,60))
                end
            end

            if callback then
                callback()
            end
        end
        alienTechVoApi:upgradeTech(techId,upgradeTechCallback,layerNum+1)
    end
    local upgradeItem
    if rightBtnStr and rightBtnStr~="" then
        cancleItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",upgradeHandler,2,rightBtnStr,24/0.8,101)
        cancleItem:setScale(0.8)
        local btnLb = cancleItem:getChildByTag(101)
        if btnLb then
            btnLb = tolua.cast(btnLb,"CCLabelTTF")
            btnLb:setFontName("Helvetica-bold")
        end
    else
        upgradeItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",upgradeHandler,2,getlocal("upgradeBuild"),24/0.8,101)
        upgradeItem:setScale(0.8)
        local btnLb = upgradeItem:getChildByTag(101)
        if btnLb then
            btnLb = tolua.cast(btnLb,"CCLabelTTF")
            btnLb:setFontName("Helvetica-bold")
        end
    end
    local upgradeMenu=CCMenu:createWithItem(upgradeItem);
    upgradeMenu:setPosition(ccp(size.width-120,60))
    upgradeMenu:setTouchPriority(-(layerNum-1)*20-5);
    dialogBg:addChild(upgradeMenu)
    if isUnlock==true then
    else
        upgradeItem:setEnabled(false)
    end
    self.refreshData.upgradeBtn=upgradeItem

    --确定
    local function sureHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local leftStr=getlocal("ok")
    if leftBtnStr and leftBtnStr~="" then
        leftStr=leftBtnStr
    end
    local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",sureHandler,2,leftStr,24/0.8,101)
    sureItem:setScale(0.8)
    local btnLb = sureItem:getChildByTag(101)
    if btnLb then
        btnLb = tolua.cast(btnLb,"CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(120,60))
    sureMenu:setTouchPriority(-(layerNum-1)*20-5);
    dialogBg:addChild(sureMenu)
    self.refreshData.sureBtn=sureMenu

    local teLv=alienTechVoApi:getTechLevel(techId)
    if teLv>=maxLv then
        self.refreshData.upgradeBtn:setVisible(false)
        self.refreshData.upgradeBtn:setEnabled(false)
        self.refreshData.sureBtn:setPosition(ccp(size.width/2,60))
    end


    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end


function smallDialog:initFormationDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,callback,type,isShowTank,tankLayerParent)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local titleStr222 = "formation"
    if type== 35 or type== 36 then--领土争夺战 需要特殊保存
        titleStr222 = "formation2"
    end
    local dialogBg = G_getNewDialogBg(size,getlocal(titleStr222),30,touchHandler,layerNum,true,close)
    --LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()

    self.bgLayer=dialogBg
    self.bgSize=size
    -- self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog()

    end

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    -- self:userHandler()


    -- local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    -- closeBtnItem:setPosition(ccp(0,0))
    -- closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    -- self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    -- self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    -- self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    -- self.bgLayer:addChild(self.closeBtn,2)

    -- if title then
    --     local titleLb=GetTTFLabel(title,40)
    --     titleLb:setAnchorPoint(ccp(0.5,0.5))
    --     titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
    --     dialogBg:addChild(titleLb)
    -- end

    local maxLanNum = 14
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" then
        maxLanNum = 7
    end

    self.refreshData={}

    local bgWidth=self.bgSize.width
    local bgHeight=self.bgSize.height
    strSize4 = 26
    if G_getCurChoseLanguage() =="cn" then
        strSize4 = 33
    end
    local isMoved=false
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            local num=0
            if playerCfg.formation then
                num=SizeOfTable(playerCfg.formation)
            end
            return num
        elseif fn=="tableCellSizeForIndex" then
            local cellWidth=self.bgSize.width-40
            local cellHeight=180
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local cellWidth=self.bgSize.width-40
            -- local cellHeight=180
            local bgHeight=180-5

            local function touch()
            end
            local bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),touch)
            bgSprie:setContentSize(CCSizeMake(cellWidth,bgHeight))
            bgSprie:setPosition(ccp(cellWidth/2,bgHeight/2))
            bgSprie:setIsSallow(false)
            bgSprie:setTouchPriority(-(layerNum-1)*20-2)
            cell:addChild(bgSprie)

            local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
            pointSp1:setPosition(ccp(2,bgSprie:getContentSize().height/2))
            bgSprie:addChild(pointSp1)
            local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
            pointSp2:setPosition(ccp(bgSprie:getContentSize().width-2,bgSprie:getContentSize().height/2))
            bgSprie:addChild(pointSp2)

            local bgSpHeight=60
            local bgSp=CCSprite:createWithSpriteFrameName("newGreenFadeLight.png")
            bgSp:setAnchorPoint(ccp(0.5,1))
            bgSp:setPosition(ccp(cellWidth/2,bgHeight-bgSpHeight*0.3))
            bgSp:setScaleX(cellWidth*0.45/bgSp:getContentSize().width)
            bgSp:setScaleY(bgSpHeight*0.5/bgSp:getContentSize().height)
            bgSprie:addChild(bgSp)

            local newLineSp = CCSprite:createWithSpriteFrameName("LineCross.png")--,CCRect(27,3,1,1),function ()end)
            newLineSp:setPosition(ccp(cellWidth/2,bgHeight-bgSpHeight*0.8))
            newLineSp:setScaleX(cellWidth/newLineSp:getContentSize().width)
            bgSprie:addChild(newLineSp)

            local pointLineAncP = {ccp(1,0.5),ccp(0,0.5)}
            local pointLinePosWscal,pointPosWscal = {0.25,0.75},{0.3,0.7}
            for i=1,2 do
                local pointSp=CCSprite:createWithSpriteFrameName("newPointRect.png")
                pointSp:setAnchorPoint(pointLineAncP[i])
                pointSp:setPosition(ccp(cellWidth*pointPosWscal[i],bgHeight-bgSpHeight*0.4))
                bgSprie:addChild(pointSp,2)

                local pointLine = CCSprite:createWithSpriteFrameName("newPointLine.png")
                pointLine:setAnchorPoint(pointLineAncP[i])
                pointLine:setPosition(ccp(cellWidth*pointLinePosWscal[i],bgHeight-bgSpHeight*0.4))
                bgSprie:addChild(pointLine,2)
                pointLine:setScale(0.7)
                if i ==1 then
                  pointLine:setFlipX(true)
                end
            end


            local oldTankFormationStr= "tankFormation@"
            if type== 35 or type== 36 then--领土争夺战 需要特殊保存
                oldTankFormationStr = "tankFormationltzdz@"
            end
            local oldTankFormation = CCUserDefault:sharedUserDefault():getStringForKey(oldTankFormationStr..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID).."@"..idx);
            local str,str2=getlocal("formation_index",{idx+1}),nil
            if type== 35 or type== 36 then
                str = getlocal("formation2")..idx+1
            end
            local byStr = str
            local needVip=playerCfg.formation[idx+1] or 0
            if needVip and playerVoApi:getVipLevel()<needVip then
                -- str=str..getlocal("vip_open",{needVip})
                str2 = getlocal("raids_vipUnlock",{needVip})
            elseif oldTankFormation ~="" then
                str = oldTankFormation
            end
            -- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"

            local scale=0.85
            if needVip and playerVoApi:getVipLevel()<needVip then

                GetAllTTFLabel(str,25,ccp(0.5,0.5),ccp(cellWidth/2,bgHeight-bgSpHeight/2),bgSprie,2,nil,CCSize(cellWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)

                local needVipLb = GetAllTTFLabel(str2,25)
                needVipLb:setAnchorPoint(ccp(0.5,0.5))
                needVipLb:setColor(G_ColorYellowPro)
                needVipLb:setPosition(ccp(cellWidth*0.5 + needVipLb:getContentSize().width*0.2,bgHeight-bgSpHeight-20))
                bgSprie:addChild(needVipLb)

                local lockingIcon = CCSprite:createWithSpriteFrameName("lockingIcon.png")
                lockingIcon:setAnchorPoint(ccp(1,0.5))
                lockingIcon:setPosition(ccp(needVipLb:getPositionX() - needVipLb:getContentSize().width*0.5-5,needVipLb:getPositionY()+5))
                bgSprie:addChild(lockingIcon,2)

                local function rechargeHandler()
                    if self and self.refreshData and self.refreshData.tableView and self.refreshData.tableView:getScrollEnable()==true and self.refreshData.tableView:getIsScrolled()==false then
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
                        else
                            base.setWaitTime=G_getCurDeviceMillTime()
                        end
                        PlayEffect(audioCfg.mouseClick)

                        vipVoApi:showRechargeDialog(layerNum)
                        self:close()
                    end
                end
                local rechargeItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",rechargeHandler,nil,getlocal("recharge"),strSize4)
                rechargeItem:setScale(scale)
                local rechargeMenu=CCMenu:createWithItem(rechargeItem)
                rechargeMenu:setPosition(ccp(cellWidth/2,45))
                rechargeMenu:setTouchPriority(-(layerNum-1)*20-2)
                bgSprie:addChild(rechargeMenu,2)
            else
                local editTargetBox,curLb = nil,nil
                local writingIcon = CCSprite:createWithSpriteFrameName("writingIcon.png")
                writingIcon:setAnchorPoint(ccp(0.5,0))
                writingIcon:setPosition(ccp(cellWidth-30,newLineSp:getPositionY()+2))
                bgSprie:addChild(writingIcon,2)

                local savingIcon = CCSprite:createWithSpriteFrameName("savingIcon.png")
                savingIcon:setAnchorPoint(ccp(0.5,0))
                savingIcon:setPosition(ccp(cellWidth-30,newLineSp:getPositionY()+2))
                bgSprie:addChild(savingIcon,2)

                -- writingIcon:setVisible(false)
                savingIcon:setVisible(false)
                local function callBackTargetHandler(fn,eB,newStr)
                    if newStr==nil then
                      str=""
                      do return end
                    end
                    str=newStr
                    -- print("str------>",str)
                end

                local function clickCanWriteTarget()
                    savingIcon:setVisible(true)
                    writingIcon:setVisible(false)
                    if editTargetBox and curLb then
                      curLb:setString("")
                        editTargetBox:setPosition(ccp(cellWidth*0.5,bgHeight - bgSpHeight*0.8 + bgSpHeight*0.4))
                        curLb:setPosition(ccp(editTargetBox:getContentSize().width*0.5,editTargetBox:getContentSize().height*0.5))
                    end
                    return false
                end
                -- local strNumSide = 1
                -- if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
                --     strNumSide = 3
                -- end
                local function inputEndBack( )
                    -- print("inputEndBack=--------str>",maxLanNum,str)
                    -- print("inputEndBack=--------#str>",#str,string.len(str))
                    if #str > maxLanNum*3 then
                        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("strIsOutSide",{maxLanNum}),nil,9,nil)
                    else
                        local tankFormationStr= "tankFormation@"
                        if type== 35 or type== 36 then
                            tankFormationStr = "tankFormationltzdz@"
                        end
                        local tankFormation= tankFormationStr..tostring(playerVoApi:getUid()).."@"..tostring(base.curZoneID).."@"..idx
                        CCUserDefault:sharedUserDefault():setStringForKey(tankFormation,str)
                        CCUserDefault:sharedUserDefault():flush()
                    end

                    savingIcon:setVisible(false)
                    writingIcon:setVisible(true)
                    if editTargetBox and curLb then
                        editTargetBox:setPosition(ccp(cellWidth*0.85,bgHeight - bgSpHeight*0.8 + bgSpHeight*0.4))
                        curLb:setPosition(ccp(-cellWidth*0.16,editTargetBox:getContentSize().height*0.5))
                    end
                    if curLb and curLb:getString() == "" then
                        curLb:setString(byStr)
                    end
                end
                editTargetBox=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),function ()end)
                editTargetBox:setContentSize(CCSizeMake(200,bgHeight - newLineSp:getPositionY()))
                editTargetBox:setPosition(ccp(cellWidth*0.85,bgHeight - bgSpHeight*0.8 +bgSpHeight*0.4-5))
                editTargetBox:setIsSallow(false)
                editTargetBox:setTouchPriority(-(layerNum-1)*20-4)
                editTargetBox:setOpacity(0)
                bgSprie:addChild(editTargetBox)
                curLb = GetAllTTFLabel(str,25)
                curLb:setAnchorPoint(ccp(0.5,0.5))
                curLb:setPosition(ccp(-cellWidth*0.16,editTargetBox:getContentSize().height*0.5))

                local customEditBox=customEditBox:new()
                customEditBox:init(editTargetBox,curLb,"BlackAlphaBg.png",nil,-(layerNum-1)*20-4,maxLanNum,callBackTargetHandler,nil,nil,nil,clickCanWriteTarget,nil,nil,inputEndBack,maxLanNum)
                local isNew = nil
                if type== 35 or type== 36 or type==38 then
                  isNew = true
                end
                local isSaved,tank,hero,emblemId1,planePos1,aitroops1,airShipId1=G_getFormationByIndex(idx+1,type,isNew)
                local function storageHandler()
                    if self and self.refreshData and self.refreshData.tableView and self.refreshData.tableView:getScrollEnable()==true and self.refreshData.tableView:getIsScrolled()==false then
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
                        else
                            base.setWaitTime=G_getCurDeviceMillTime()
                        end
                        PlayEffect(audioCfg.mouseClick)

                        local tankTab=tankVoApi:getTanksTbByType(type)
                        local heroTab=heroVoApi:getTroopsHeroList()
                        local aitroops = AITroopsFleetVoApi:getAITroopsTb()
                        local emblemId = emblemVoApi:getTmpEquip(type)
                        local planePos = planeVoApi:getTmpEquip(type)
                        local airShipId = airShipVoApi:getTempLineupId()
                        G_setFormationByIndex(idx+1,tankTab,heroTab,aitroops,type,emblemId,planePos,isNew,airShipId)

                        if self.refreshData.tableView then
                            local recordPoint=self.refreshData.tableView:getRecordPoint()
                            self.refreshData.tableView:reloadData()
                            self.refreshData.tableView:recoverToRecordPoint(recordPoint)
                        end

                        self:close()
                    end
                end
                local saveItem
                local pos
                if isSaved==true then
                    saveItem = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",storageHandler,nil,getlocal("cover"),strSize4)
                    pos=ccp(cellWidth/2-120,60)
                else
                    saveItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",storageHandler,nil,getlocal("storage"),strSize4)
                    pos=ccp(cellWidth/2,60)
                end
                saveItem:setScale(scale)
                local saveMenu=CCMenu:createWithItem(saveItem)
                saveMenu:setPosition(pos)
                saveMenu:setTouchPriority(-(layerNum-1)*20-2)
                bgSprie:addChild(saveMenu,2)


                if isSaved==true then
                    local function readHandler()
                        if self and self.refreshData and self.refreshData.tableView and self.refreshData.tableView:getScrollEnable()==true and self.refreshData.tableView:getIsScrolled()==false then
                            if G_checkClickEnable()==false then
                                do
                                    return
                                end
                            else
                                base.setWaitTime=G_getCurDeviceMillTime()
                            end
                            PlayEffect(audioCfg.mouseClick)

                            if type>=7 and type<=10 then
                            else
                              if type==38 then
                                if championshipWarVoApi:isTroopsCanUse(tank,hero)==false then
                                  smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("championshipWar_troop_disuseable"), 30)
                                  do return end
                                end
                              end
                                heroVoApi:setTroopsByTb(hero)
                                for k,v in pairs(tank) do
                                    if v and SizeOfTable(v)>0 then
                                        tankVoApi:setTanksByType(type,k,v[1],v[2])
                                    else
                                        tankVoApi:deleteTanksTbByType(type,k)
                                    end
                                end

                                G_updateSelectTankLayer(type,tankLayerParent,layerNum-1,isShowTank,tank,hero,emblemId1,planePos1,aitroops1,airShipId1)
                            end

                            if callback then
                                callback(tank,hero)
                            end

                            self:close()
                        end
                    end
                    local readItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",readHandler,nil,getlocal("read"),strSize4)
                    readItem:setScale(scale)
                    local readMenu=CCMenu:createWithItem(readItem)
                    readMenu:setPosition(ccp(cellWidth/2+120,60))
                    readMenu:setTouchPriority(-(layerNum-1)*20-2)
                    bgSprie:addChild(readMenu,2)
                end
            end

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local cellWidth=self.bgLayer:getContentSize().width-40
    local hd= LuaEventHandler:createHandler(tvCallBack)
    self.refreshData.tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,self.bgSize.height-90),nil)
    self.refreshData.tableView:setTableViewTouchPriority(-(layerNum-1)*20-3)
    self.refreshData.tableView:setPosition(ccp(20,20))
    self.bgLayer:addChild(self.refreshData.tableView,2)
    self.refreshData.tableView:setMaxDisToBottomOrTop(120)

    self:addForbidSp(self.bgLayer,size,layerNum)


    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    local touchDialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg2:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg2:setContentSize(rect)
    touchDialogBg2:setOpacity(250)
    touchDialogBg2:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg2)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

function smallDialog:initActivateDefendersDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,callback)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()

    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog()

    end

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    -- self:userHandler()

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)

    if title then
        local titleLb=GetTTFLabel(title,40)
        titleLb:setAnchorPoint(ccp(0.5,0.5))
        titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
        dialogBg:addChild(titleLb)
    end

    local function showInfo()
        PlayEffect(audioCfg.mouseClick)
        local tabStr = {"\n",getlocal("serverwarteam_donate_tip5"),"\n",getlocal("serverwarteam_donate_tip4"),"\n",getlocal("serverwarteam_donate_tip3"),"\n",getlocal("serverwarteam_donate_tip2"),"\n",getlocal("serverwarteam_donate_tip1"),"\n"}
        local tabColor = {nil,G_ColorYellow,nil,G_ColorYellow,nil,G_ColorYellow,nil,G_ColorYellow,nil,G_ColorYellow,nil}
        local td=smallDialog:new()
        local dialog1=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,layerNum+1,tabStr,25,tabColor)
        sceneGame:addChild(dialog1,layerNum+1)
    end
    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    infoItem:setScale(0.8)
    -- infoItem:setAnchorPoint(ccp(1,1))
    local infoBtn = CCMenu:createWithItem(infoItem)
    -- infoBtn:setAnchorPoint(ccp(1,1))
    infoBtn:setPosition(ccp(50,self.bgSize.height-45))
    infoBtn:setTouchPriority(-(layerNum-1)*20-4)
    dialogBg:addChild(infoBtn,3)

    self.type="activateDefendersDialog"
    self.refreshData={}
    base:addNeedRefresh(self)

    local baseDonateTimeCfg=serverWarTeamVoApi:getBaseDonateTimeCfg()
    local donateGems=serverWarTeamCfg.baseDonateGem
    local resItem=serverWarTeamVoApi:getBaseDonateResCfg()
    local resType=resItem.key
    local resNum=resItem.num
    local roundID=1


    local bgWidth=self.bgSize.width
    local bgHeight=self.bgSize.height


    local baseDonateNum=serverWarTeamVoApi:getBaseDonateNum()
    local baseNum=0
    for k,v in pairs(serverWarTeamCfg.baseDonateTime) do
        if baseDonateNum>=v then
            baseNum=baseNum+serverWarTeamCfg.baseDonateNum[k]
        end
    end
    self.refreshData.descLb=GetAllTTFLabel(getlocal("serverwarteam_has_base_defenders",{baseNum}),25,ccp(0.5,0.5),ccp(bgWidth/2,bgHeight-115),dialogBg,1,nil,CCSize(bgWidth-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    -- self.refreshData.descLb=GetAllTTFLabel("啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊",25,ccp(0.5,0.5),ccp(bgWidth/2,bgHeight-115),dialogBg,1,nil,CCSize(bgWidth-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)


    local isMoved=false
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            local cellNum=0
            if baseDonateTimeCfg and SizeOfTable(baseDonateTimeCfg)>0 then
                cellNum=SizeOfTable(baseDonateTimeCfg)
            end
            return cellNum
        elseif fn=="tableCellSizeForIndex" then
            local cellWidth=self.bgSize.width-40
            local cellHeight=100
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local cellWidth=self.bgSize.width-40
            local cellHeight=100

            local function touch()
            end
            local bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
            bgSprie:setContentSize(CCSizeMake(cellWidth,cellHeight-5))
            bgSprie:setPosition(ccp(cellWidth/2,cellHeight/2))
            bgSprie:setIsSallow(false)
            bgSprie:setTouchPriority(-(layerNum-1)*20-2)
            cell:addChild(bgSprie,1)

            local bgHeight=bgSprie:getContentSize().height
            local defendersName=getlocal("serverwarteam_base_defenders").."x"..serverWarTeamCfg.baseDonateNum[idx+1]
            local defendersNameLb=GetAllTTFLabel(defendersName,28,ccp(0,0.5),ccp(20,bgHeight/2),bgSprie,1,nil,CCSize(cellWidth-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)

            local needTime=baseDonateTimeCfg[idx+1]
            local baseDonateNum=serverWarTeamVoApi:getBaseDonateNum()
            local scheduleLb=GetAllTTFLabel(getlocal("scheduleChapter",{baseDonateNum,needTime}),28,ccp(0.5,0.5),ccp(cellWidth-80,bgHeight/2),bgSprie,1,nil)


            local function checkHandler()
                if self and self.refreshData and self.refreshData.tableView and self.refreshData.tableView:getScrollEnable()==true and self.refreshData.tableView:getIsScrolled()==false then
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)

                    serverWarTeamVoApi:showBaseDefendersInfoDialog(layerNum,defendersName,idx+1)
                end
            end
            local checkItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",checkHandler,nil,getlocal("alliance_list_check_info"),25)
            local scale=0.8
            checkItem:setScale(scale)
            local checkMenu=CCMenu:createWithItem(checkItem)
            checkMenu:setPosition(ccp(cellWidth-80,bgHeight/2))
            checkMenu:setTouchPriority(-(layerNum-1)*20-2)
            bgSprie:addChild(checkMenu)

            if baseDonateNum>=needTime then
                scheduleLb:setVisible(false)
                checkItem:setVisible(true)
                checkItem:setEnabled(true)
            else
                scheduleLb:setVisible(true)
                checkItem:setVisible(false)
                checkItem:setEnabled(false)
            end


            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local cellWidth=self.bgLayer:getContentSize().width-40
    local hd= LuaEventHandler:createHandler(tvCallBack)
    self.refreshData.tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,520),nil)
    self.refreshData.tableView:setTableViewTouchPriority(-(layerNum-1)*20-3)
    self.refreshData.tableView:setPosition(ccp(20,200))
    self.bgLayer:addChild(self.refreshData.tableView,2)
    self.refreshData.tableView:setMaxDisToBottomOrTop(120)

    self:addForbidSp(self.bgLayer,size,layerNum)


    local iconHeight=180
    local iconSize=40
    local iconGold=CCSprite:createWithSpriteFrameName("IconGold.png")
    iconGold:setAnchorPoint(ccp(0.5,0.5))
    iconGold:setPosition(ccp(150-45,iconHeight))
    self.bgLayer:addChild(iconGold,1)
    iconGold:setScale(iconSize/iconGold:getContentSize().width)
    local gemsLb=GetAllTTFLabel(donateGems,30,ccp(0.5,0.5),ccp(150+25,iconHeight),self.bgLayer,1,G_ColorYellowPro)
    if donateGems>playerVoApi:getGems() then
        gemsLb:setColor(G_ColorRed)
    end

    local iconRes=CCSprite:createWithSpriteFrameName("IconUranium.png")
    iconRes:setAnchorPoint(ccp(0.5,0.5))
    iconRes:setPosition(ccp(size.width-150-50,iconHeight))
    self.bgLayer:addChild(iconRes,1)
    iconRes:setScale(iconSize/iconRes:getContentSize().width)
    local resLb=GetAllTTFLabel(FormatNumber(resNum),30,ccp(0.5,0.5),ccp(size.width-150+20,iconHeight),self.bgLayer,1,G_ColorYellowPro)
    if playerVo[resType] and resNum>playerVo[resType] then
        resLb:setColor(G_ColorRed)
    end

    local btnHeight=115
    --金币捐献
    local function gemsDonateHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)


        -- if(allianceVoApi:getJoinTime()>0 and allianceVoApi:getJoinTime()>(G_getWeeTs(serverWarTeamVoApi.startTime)+serverWarTeamCfg.preparetime*86400))then
        if serverWarTeamVoApi:canJoinServerWarTeam(nil,false)==false then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("serverwarteam_cannot_donate_base"),nil,layerNum+1)
            do return end
        end

        if serverWarTeamVoApi:canJoinBattleLvLimit()==false then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("serverwarteam_cannot_donate_base1",{serverWarTeamCfg.joinlv}),nil,layerNum+1)
            do return end
        end

        local needGem=donateGems-playerVoApi:getGems()
        if needGem>0 then
            GemsNotEnoughDialog(nil,nil,needGem,layerNum+1,donateGems)
            do return end
        else
            local function sureHandler()
                local function sureCallback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        playerVoApi:setGems(playerVoApi:getGems()-donateGems)
                        if sData.data then
                            serverWarTeamVoApi:setBaseDonateInfo(sData.ts,sData.data.basedonatenum,sData.data.basetroops)
                        end

                        if self and self.refreshData then
                            if self.refreshData.tableView then
                                self.refreshData.tableView:reloadData()
                            end
                            if self.refreshData.descLb then
                                local baseDonateNum=serverWarTeamVoApi:getBaseDonateNum()
                                local baseNum=0
                                for k,v in pairs(serverWarTeamCfg.baseDonateTime) do
                                    if baseDonateNum>=v then
                                        baseNum=baseNum+serverWarTeamCfg.baseDonateNum[k]
                                    end
                                end
                                self.refreshData.descLb:setString(getlocal("serverwarteam_has_base_defenders",{baseNum}))
                            end
                        end
                        if donateGems>playerVoApi:getGems() then
                            gemsLb:setColor(G_ColorRed)
                        end
                        if playerVo[resType] and resNum>playerVo[resType] then
                            resLb:setColor(G_ColorRed)
                        end

                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_donate_success"),30)


                        local cfg=serverWarTeamVoApi:getBaseDonateTimeCfg()
                        if serverWarTeamVoApi:getBaseDonateNum()>=cfg[SizeOfTable(cfg)] then
                            if self.refreshData then
                                if self.refreshData.gemsDonateItem then
                                    self.refreshData.gemsDonateItem:setEnabled(false)
                                end
                                if self.refreshData.resDonateItem then
                                    self.refreshData.resDonateItem:setEnabled(false)
                                end
                            end
                        end

                        local selfAlliance=allianceVoApi:getSelfAlliance()
                        if selfAlliance and sData.data then
                            local aid=selfAlliance.aid
                            local params={sData.ts,sData.data.basedonatenum,sData.data.basetroops}
                            chatVoApi:sendUpdateMessage(11,params,aid+1)
                        end
                    end
                end
                socketHelper:acrossDonate(1,sureCallback)
            end
            if self.refreshData and self.refreshData.checkBtn then
                local switch=self.refreshData.checkBtn:getSelectedIndex()
                if switch==1 then
                    sureHandler()
                else
                    smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),sureHandler,getlocal("dialog_title_prompt"),getlocal("serverwarteam_gems_donate_sure",{donateGems}),nil,layerNum+1)
                end
            else
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),sureHandler,getlocal("dialog_title_prompt"),getlocal("serverwarteam_gems_donate_sure",{donateGems}),nil,layerNum+1)
            end

        end
    end
    self.refreshData.gemsDonateItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",gemsDonateHandler,2,getlocal("serverwarteam_funds_donate_gems"),25)
    local gemsDonateMenu=CCMenu:createWithItem(self.refreshData.gemsDonateItem)
    gemsDonateMenu:setPosition(ccp(150,btnHeight))
    gemsDonateMenu:setTouchPriority(-(layerNum-1)*20-4)
    dialogBg:addChild(gemsDonateMenu)



    --资源捐献
    local function resDonateHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local hasResNum=0
        if playerVo[resType] then
            hasResNum=playerVo[resType]
        end
        if resNum>hasResNum then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("resourcelimit"),nil,layerNum+1)
            do return end
        else
            local function sureHandler()
                local function sureCallback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        playerVo[resType]=playerVo[resType]-resNum
                        if sData.data then
                            serverWarTeamVoApi:setBaseDonateInfo(sData.ts,sData.data.basedonatenum,sData.data.basetroops)
                        end

                        if self and self.refreshData then
                            if self.refreshData.tableView then
                                self.refreshData.tableView:reloadData()
                            end
                            if self.refreshData.descLb then
                                local baseDonateNum=serverWarTeamVoApi:getBaseDonateNum()
                                local baseNum=0
                                for k,v in pairs(serverWarTeamCfg.baseDonateTime) do
                                    if baseDonateNum>=v then
                                        baseNum=baseNum+serverWarTeamCfg.baseDonateNum[k]
                                    end
                                end
                                self.refreshData.descLb:setString(getlocal("serverwarteam_has_base_defenders",{baseNum}))
                            end
                        end
                        if donateGems>playerVoApi:getGems() then
                            gemsLb:setColor(G_ColorRed)
                        end
                        if playerVo[resType] and resNum>playerVo[resType] then
                            resLb:setColor(G_ColorRed)
                        end

                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_donate_success"),30)

                        local cfg=serverWarTeamVoApi:getBaseDonateTimeCfg()
                        if serverWarTeamVoApi:getBaseDonateNum()>=cfg[SizeOfTable(cfg)] then
                            if self.refreshData then
                                if self.refreshData.gemsDonateItem then
                                    self.refreshData.gemsDonateItem:setEnabled(false)
                                end
                                if self.refreshData.resDonateItem then
                                    self.refreshData.resDonateItem:setEnabled(false)
                                end
                            end
                        end

                        local selfAlliance=allianceVoApi:getSelfAlliance()
                        if selfAlliance and sData.data then
                            local aid=selfAlliance.aid
                            local params={sData.ts,sData.data.basedonatenum,sData.data.basetroops}
                            chatVoApi:sendUpdateMessage(11,params,aid+1)
                        end
                    end
                end
                socketHelper:acrossDonate(2,sureCallback)
            end
            if self.refreshData and self.refreshData.checkBtn then
                local switch=self.refreshData.checkBtn:getSelectedIndex()
                if switch==1 then
                    sureHandler()
                else
                    smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),sureHandler,getlocal("dialog_title_prompt"),getlocal("serverwarteam_res_donate_success",{resItem.name,resItem.num}),nil,layerNum+1)
                end
            else
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),sureHandler,getlocal("dialog_title_prompt"),getlocal("serverwarteam_res_donate_success",{resItem.name,resItem.num}),nil,layerNum+1)
            end

        end
    end
    self.refreshData.resDonateItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",resDonateHandler,2,getlocal("serverwarteam_funds_donate_res",{resItem.name}),25)
    local resDonateMenu=CCMenu:createWithItem(self.refreshData.resDonateItem)
    resDonateMenu:setPosition(ccp(size.width-150,btnHeight))
    resDonateMenu:setTouchPriority(-(layerNum-1)*20-4)
    dialogBg:addChild(resDonateMenu)

    local cfg=serverWarTeamVoApi:getBaseDonateTimeCfg()
    if serverWarTeamVoApi:getBaseDonateNum()>=cfg[SizeOfTable(cfg)] then
        if self.refreshData then
            if self.refreshData.gemsDonateItem then
                self.refreshData.gemsDonateItem:setEnabled(false)
            end
            if self.refreshData.resDonateItem then
                self.refreshData.resDonateItem:setEnabled(false)
            end
        end
    end


    local function operateHandler(tag,object)
        PlayEffect(audioCfg.mouseClick)

    end
    local tabBtn=CCMenu:create()
    local switchSp1 = CCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
    local switchSp2 = CCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
    local menuItemSp1 = CCMenuItemSprite:create(switchSp1,switchSp2)
    local switchSp3 = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
    local switchSp4 = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
    local menuItemSp2 = CCMenuItemSprite:create(switchSp3,switchSp4)
    self.refreshData.checkBtn = CCMenuItemToggle:create(menuItemSp1)
    self.refreshData.checkBtn:addSubItem(menuItemSp2)
    self.refreshData.checkBtn:setAnchorPoint(CCPointMake(0.5,0.5))
    -- self.refreshData.checkBtn:setPosition(0,0)
    self.refreshData.checkBtn:registerScriptTapHandler(operateHandler)
    self.refreshData.checkBtn:setSelectedIndex(0)
    tabBtn:addChild(self.refreshData.checkBtn)
    self.refreshData.checkBtn:setTag(11)
    tabBtn:setPosition(ccp(switchSp1:getContentSize().width/2+15,50))
    tabBtn:setTouchPriority(-(layerNum-1)*20-4)
    dialogBg:addChild(tabBtn,2)

    local closeConfimLb=GetAllTTFLabel(getlocal("serverwarteam_close_donate_confim"),25,ccp(0,0.5),ccp(switchSp1:getContentSize().width+20,50),dialogBg,1,nil,CCSize(bgWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- closeConfimLb=GetAllTTFLabel("啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊",25,ccp(0,0.5),ccp(switchSp1:getContentSize().width+20,50),dialogBg,1,nil,CCSize(bgWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)


    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

--dType：nil 跨服战，1 群雄争霸
function smallDialog:initBattleFundsDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,callback,dType)
    print("dType",dType)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function touchHandler()

    end

    local function close()
      PlayEffect(audioCfg.mouseClick)
      return self:close()
    end
    if dType==1 then
      dialogBg=G_getNewDialogBg(size,title,32,nil,layerNum+1,true,close)
    else
      dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    end
    self.dialogLayer=CCLayer:create()

    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog()

    end

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    -- self:userHandler()

    if title and (dType==nil or dType~=1) then
      local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
      closeBtnItem:setPosition(ccp(0,0))
      closeBtnItem:setAnchorPoint(CCPointMake(0,0))

      self.closeBtn = CCMenu:createWithItem(closeBtnItem)
      self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
      self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
      self.bgLayer:addChild(self.closeBtn,2)

      local titleLb=GetTTFLabel(title,40)
      titleLb:setAnchorPoint(ccp(0.5,0.5))
      titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
      dialogBg:addChild(titleLb)
    end

    -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local bgWidth=self.bgSize.width
    local bgHeight=self.bgSize.height
    local lbWidth=bgWidth-100

    local currentLb
    local descLb
    local inputStr=""
    local gems=0
    if dType==1 then
        inputStr=getlocal("serverWarLocal_funds_input")
        gems=serverWarLocalVoApi:getFunds()
    else
        inputStr=getlocal("serverwarteam_funds_input")
        gems=serverWarTeamVoApi:getGems()
    end
    local lbTb={
        {inputStr,25,ccp(0.5,0.5),ccp(bgWidth/2,bgHeight-140),self.bgLayer,1,nil,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
        {getlocal("serverwarteam_funds_current",{gems}),30,ccp(0.5,0.5),ccp(bgWidth/2,bgHeight-220),self.bgLayer,1,G_ColorYellowPro,CCSize(lbWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
        {getlocal("serverwarteam_own_gems",{playerVoApi:getGems()}),30,ccp(0.5,0.5),ccp(bgWidth/2,140),self.bgLayer,1,nil,CCSize(lbWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
    }
    -- lbTb={
    --     {str..str,25,ccp(0.5,0.5),ccp(bgWidth/2,bgHeight-140),self.bgLayer,1,nil,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
    --     {str,30,ccp(0.5,0.5),ccp(bgWidth/2-20,bgHeight-220),self.bgLayer,1,G_ColorYellowPro,CCSize(lbWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
    --     {str,30,ccp(0.5,0.5),ccp(bgWidth/2,140),self.bgLayer,1,nil,CCSize(lbWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
    -- }
    for k,v in pairs(lbTb) do
        if k==2 then
            currentLb=GetAllTTFLabel(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11])
        else
            GetAllTTFLabel(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11])
        end
    end


    local inputValue=0
    local inputLabel=GetTTFLabel(inputValue,30)
    -- local function callBackChangeHandler(fn,eB,str)
    --     if tonumber(str)==nil then
    --         eB:setText(inputValue)
    --     else
    --         if tonumber(str)>=1 and tonumber(str)<=playerVoApi:getGems() then
    --             inputValue=tonumber(str)
    --         else
    --             if tonumber(str)<1 then
    --                 eB:setText(1)
    --                 inputValue=1
    --             end
    --             if tonumber(str)>playerVoApi:getGems() then
    --                 eB:setText(playerVoApi:getGems())
    --                 inputValue=playerVoApi:getGems()
    --             end
    --         end
    --     end
    --     if inputValue then
    --         return inputValue
    --     end
    -- end

    local wSpace=80
    local boxHeight=60
    -- local function cellClick(hd,fn,idx)
    -- end
    -- local inputBox=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),cellClick)
    -- inputBox:setContentSize(CCSizeMake(bgWidth-200-wSpace,boxHeight))
    -- inputBox:setIsSallow(false)
    -- inputBox:setTouchPriority(-(layerNum-1)*20-4)
    -- inputBox:setAnchorPoint(ccp(0.5,0.5))
    -- inputBox:setPosition(ccp(bgWidth/2,bgHeight-290))

    -- inputLabel:setAnchorPoint(ccp(0,0.5))
    -- inputLabel:setPosition(ccp(10+wSpace,inputBox:getContentSize().height/2))

    -- local customEditBox=customEditBox:new()
    -- local length=20
    -- local inputMode=CCEditBox.kEditBoxInputModeUrl
    -- if G_isIOS()==true then
    --     inputMode=CCEditBox.kEditBoxInputModePhoneNumber
    -- end
    -- local inputFlag=nil
    -- customEditBox:init(inputBox,inputLabel,"worldInputBg.png",CCSizeMake(bgWidth-200-wSpace,boxHeight),-(layerNum-1)*20-4,length,callBackChangeHandler,inputFlag,inputMode,nil,nil,nil,ccp(wSpace,0))
    -- dialogBg:addChild(inputBox)

    -- local iconSize=55
    -- local iconGold=CCSprite:createWithSpriteFrameName("IconGold.png")
    -- iconGold:setAnchorPoint(ccp(0.5,0.5))
    -- iconGold:setPosition(ccp(iconSize/2+15,inputBox:getContentSize().height/2))
    -- iconGold:setScale(iconSize/iconGold:getContentSize().width)
    -- inputBox:addChild(iconGold,5)


    local function tthandler()

    end
    local function inputHandler(fn,eB,str,type)
        if type==1 then  --检测文本内容变化
            if  str=="" then
                inputValue=0
                inputLabel:setString(inputValue)
                do
                    return
                end
            end
            if tonumber(str)==nil then
                eB:setText(inputValue)
            else
                if tonumber(str)>=1 and tonumber(str)<=playerVoApi:getGems() then
                    inputValue=tonumber(str)
                else
                    if tonumber(str)<1 then
                        eB:setText(0)
                        inputValue=0
                    end
                    if tonumber(str)>playerVoApi:getGems() then
                        eB:setText(playerVoApi:getGems())
                        inputValue=playerVoApi:getGems()
                    end
                end
            end
            inputLabel:setString(inputValue)
        elseif type==2 then --检测文本输入结束
            eB:setVisible(false)
            inputLabel:setVisible(true)
        end
    end
    inputLabel:setAnchorPoint(ccp(0,0.5))
    -- inputLabel:setVisible(false)
    -- inputLabel:setPosition(ccp(bgWidth/2+wSpace,bgHeight-290))
    -- dialogBg:addChild(inputLabel,2)

    local box=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),tthandler)
    box:setOpacity(0)
    local editBox=CCEditBox:createForLua(CCSize(bgWidth-200-wSpace+20,boxHeight-15),box,nil,nil,inputHandler)

    editBox:setPosition(ccp(bgWidth/2+wSpace,bgHeight-290))
    if G_isIOS()==true then
        editBox:setInputMode(CCEditBox.kEditBoxInputModePhoneNumber)
    else
        editBox:setInputMode(CCEditBox.kEditBoxInputModeAny)
    end
    editBox:setVisible(false)
    dialogBg:addChild(editBox,3)

    local function tthandler2()
        PlayEffect(audioCfg.mouseClick)
        inputLabel:setVisible(false)
        editBox:setVisible(true)
    end
    local boxBg=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),tthandler2)
    boxBg:setPosition(ccp(bgWidth/2,bgHeight-290))
    boxBg:setContentSize(CCSize(bgWidth-200-wSpace,boxHeight))
    boxBg:setTouchPriority(-(layerNum-1)*20-4)
    dialogBg:addChild(boxBg)

    inputLabel:setPosition(ccp(wSpace,boxBg:getContentSize().height/2))
    boxBg:addChild(inputLabel)


    local iconSize=55
    local iconGold=CCSprite:createWithSpriteFrameName("IconGold.png")
    iconGold:setAnchorPoint(ccp(0.5,0.5))
    iconGold:setPosition(ccp(iconSize/2+15,boxBg:getContentSize().height/2))
    iconGold:setScale(iconSize/iconGold:getContentSize().width)
    boxBg:addChild(iconGold,5)







    local function cellClick()
    end
    local backSprie
    if dType==1 then
      backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20,20,1,1),cellClick)
    else
      backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
    end
    backSprie:setContentSize(CCSizeMake(lbWidth,130))
    backSprie:setAnchorPoint(ccp(0.5,0))
    backSprie:setPosition(ccp(bgWidth/2,180))
    dialogBg:addChild(backSprie)

    local descStr=""
    if dType==1 then
        descStr=getlocal("serverWarLocal_funds_desc")
    else
        descStr=getlocal("serverwarteam_funds_desc")
    end
    local desTv,desLabel = G_LabelTableView(CCSizeMake(lbWidth-10,120),descStr,23,kCCTextAlignmentLeft,G_ColorYellowPro)
    backSprie:addChild(desTv)
    desTv:setPosition(ccp(5,5))
    desTv:setAnchorPoint(ccp(0,0))
    backSprie:setTouchPriority(-(layerNum-1)*20-1)
    desTv:setTableViewTouchPriority(-(layerNum-1)*20-3)
    desTv:setMaxDisToBottomOrTop(100)


    if dType==1 then --群雄争霸
      local btnScale=0.8
        --注入
        local function injectHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            local function setBattleInfoHandler(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("save_success"),30)
                    local gems=serverWarLocalVoApi:getFunds()+inputValue
                    serverWarLocalVoApi:setFunds(gems)
                    playerVoApi:setGems(playerVoApi:getGems()-inputValue)
                    if callBack then
                        callBack()
                    end
                    self:close()
                end
            end
            local status=serverWarLocalVoApi:getSetFundsStatus()
            if status==0 then
                if inputValue then
                    if inputValue<=0 then
                        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("serverwarteam_funds_null"),nil,layerNum+1)
                        do return end
                    end
                    local useGem=inputValue-playerVoApi:getGems()
                    if useGem>0 then
                        GemsNotEnoughDialog(nil,nil,useGem,layerNum+1,inputValue)
                        do return end
                    end
                    -- local aName
                    -- if allianceVoApi:isHasAlliance() then
                    --     local selfAlliance=allianceVoApi:getSelfAlliance()
                    --     if selfAlliance and selfAlliance.name then
                    --         aName=selfAlliance.name
                    --     end
                    -- end
                    serverWarLocalVoApi:setFleetAndFunds(inputValue,nil,nil,nil,setBattleInfoHandler)
                end
            elseif status>=1 and status<=5 then
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("serverWarLocal_cannot_set_funds"..status),nil,layerNum+1)
            end
        end
        local injectItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",injectHandler,2,getlocal("serverwarteam_funds_inject"),25/btnScale)
        injectItem:setScale(btnScale)
        local injectMenu=CCMenu:createWithItem(injectItem)
        injectMenu:setPosition(ccp(100,60))
        injectMenu:setTouchPriority(-(layerNum-1)*20-2)
        dialogBg:addChild(injectMenu)
        if serverWarLocalVoApi:getSetFundsStatus()==0 then
        else
            injectItem:setEnabled(false)
        end

        --提取全部
        local function extractHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            local function setBattleInfoHandler(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    local leftFunds=sData.data.salaries or 0
                    serverWarLocalVoApi:setFunds(0)
                    playerVoApi:setGems(playerVoApi:getGems()+leftFunds)
                    playerVoApi:setServerWarLocalUsegems(0)
                    if callBack then
                        callBack()
                    end
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_extract_success",{leftFunds}),30)
                    self:close()
                end
            end

            local gems=serverWarLocalVoApi:getFunds()
            if gems<=0 then
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("serverwarteam_funds_extract_null"),nil,layerNum+1)
                do return end
            end
            if gems>0 then
                local function onConfirm()
                    local setFundsStatus=serverWarLocalVoApi:getSetFundsStatus()
                    if (setFundsStatus and (setFundsStatus==0 or setFundsStatus==4)) then
                        socketHelper:areateamwarTakegems(gems,setBattleInfoHandler)
                    else
                        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("serverWarLocal_cannot_set_funds"..setFundsStatus),nil,layerNum+1)
                    end
                end
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("serverwarteam_funds_extract_num"),nil,layerNum+1)
            end
        end
        local extractItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",extractHandler,2,getlocal("serverwarteam_funds_extract"),25/btnScale)
        extractItem:setScale(btnScale)
        local extractMenu=CCMenu:createWithItem(extractItem)
        extractMenu:setPosition(ccp(self.bgSize.width/2,60))
        extractMenu:setTouchPriority(-(layerNum-1)*20-2)
        dialogBg:addChild(extractMenu)
        local setFundsStatus=serverWarLocalVoApi:getSetFundsStatus()
        local gems=serverWarLocalVoApi:getFunds()
        if gems and gems>0 and (setFundsStatus and (setFundsStatus==0 or setFundsStatus==4)) then
        else
            extractItem:setEnabled(false)
        end
    else
        --注入
        local function injectHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            local function setBattleInfoHandler(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    local gems=serverWarTeamVoApi:getGems()+inputValue
                    serverWarTeamVoApi:setGems(gems)
                    playerVoApi:setGems(playerVoApi:getGems()-inputValue)
                    if callBack then
                        callBack()
                    end
                    self:close()
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("save_success"),30)
                end
            end
            local status=serverWarTeamVoApi:getSetFleetStatus()
            if status==0 then
                if inputValue then
                    if inputValue<=0 then
                        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("serverwarteam_funds_null"),nil,layerNum+1)
                        do return end
                    end
                    local useGem=inputValue-playerVoApi:getGems()
                    if useGem>0 then
                        GemsNotEnoughDialog(nil,nil,useGem,layerNum+1,inputValue)
                        do return end
                    end
                    local aName
                    if allianceVoApi:isHasAlliance() then
                        local selfAlliance=allianceVoApi:getSelfAlliance()
                        if selfAlliance and selfAlliance.name then
                            aName=selfAlliance.name
                        end
                    end
                    socketHelper:acrossSetinfo(inputValue,nil,nil,aName,nil,setBattleInfoHandler)
                end
            elseif (status>=1 and status<=5) or (status>=7 and status<=8) then
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("serverwar_cannot_set_fleet"..status),nil,layerNum+1)
            end
        end
        local injectItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",injectHandler,2,getlocal("serverwarteam_funds_inject"),25)
        local injectMenu=CCMenu:createWithItem(injectItem)
        injectMenu:setPosition(ccp(100,60))
        injectMenu:setTouchPriority(-(layerNum-1)*20-2)
        dialogBg:addChild(injectMenu)
        if serverWarTeamVoApi:canSetFleet()==true then
        else
            injectItem:setEnabled(false)
        end


        --提取全部
        local function extractHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            local function setBattleInfoHandler(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then

                    local gems=serverWarTeamVoApi:getGems()
                    serverWarTeamVoApi:setGems(0)
                    playerVoApi:setGems(playerVoApi:getGems()+gems)
                    if callBack then
                        callBack()
                    end
                    local leftFunds=sData.data.salaries or 0
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwarteam_extract_success",{leftFunds}),30)
                    self:close()
                end
            end
            local gems=serverWarTeamVoApi:getGems()
            if gems<=0 then
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("serverwarteam_funds_extract_null"),nil,layerNum+1)
                do return end
            end
            if gems>0 then
                local function onConfirm()
                    socketHelper:acrossTakegems(setBattleInfoHandler)
                end
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("serverwarteam_funds_extract_num"),nil,layerNum+1)
            end
        end
        local extractItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",extractHandler,2,getlocal("serverwarteam_funds_extract"),25)
        local extractMenu=CCMenu:createWithItem(extractItem)
        extractMenu:setPosition(ccp(self.bgSize.width/2,60))
        extractMenu:setTouchPriority(-(layerNum-1)*20-2)
        dialogBg:addChild(extractMenu)
        local setFleetStatus=serverWarTeamVoApi:getSetFleetStatus()
        local gems=serverWarTeamVoApi:getGems()
        if gems and gems>0 and (setFleetStatus and setFleetStatus==0 or setFleetStatus==4 or setFleetStatus==6) then
        else
            extractItem:setEnabled(false)
        end
    end

    --充值
    local function rechargeHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        vipVoApi:showRechargeDialog(layerNum+1)

        if callBack then
            callBack()
        end
        self:close()
    end
    local rechargeItem
    if dType==1 then
      local btnScale=0.8
      rechargeItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",rechargeHandler,2,getlocal("recharge"),25/btnScale)
      rechargeItem:setScale(btnScale)
    else
      rechargeItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",rechargeHandler,2,getlocal("recharge"),25)
    end
    local rechargeMenu=CCMenu:createWithItem(rechargeItem)
    rechargeMenu:setPosition(ccp(size.width-100,60))
    rechargeMenu:setTouchPriority(-(layerNum-1)*20-2)
    dialogBg:addChild(rechargeMenu)




    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

function smallDialog:initTeamServerWarResultDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,data,callback)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()

    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog()

    end

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    -- self:userHandler()

    local function close()
        PlayEffect(audioCfg.mouseClick)
        if(callback)then
            callback()
        end
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)

    if title then
        local titleLb=GetTTFLabel(title,40)
        titleLb:setAnchorPoint(ccp(0.5,0.5))
        titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
        dialogBg:addChild(titleLb)
    end

    local wSpace=20
    local cellWidth=self.bgSize.width
    local cellHeight=self.bgSize.height
    local roundIndex=serverWarTeamVoApi:getCurrentRoundIndex()
    local battleID=serverWarTeamVoApi:getBattleID(roundIndex)
    local time=base.serverTime

    local alliance1=data.alliance[1]
    local alliance2=data.alliance[2]
    local winnerID=data.winnerID

    -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊"

    local server1=""
    local server2=""
    local name1=""
    local name2=""
    local target=""
    if alliance1 then
        server1="【"..alliance1.serverName.."】"
        name1=alliance1.name
    end
    if alliance2 then
        server2="【"..alliance2.serverName.."】"
        name2=alliance2.name
    end

    -- server1=str
    -- server2=str
    -- name1=str
    -- name2=str
    -- target=str


    local canReward=false
    local isReward=false

    local lbSize=22
    local function touch()
    end

    local spHeight=150
    local pHeight=cellHeight-100-spHeight/2
    local spWidth=cellWidth/2-wSpace


    local function showRecordHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if(callback)then
            callback()
        end
        self:close()
        serverWarTeamVoApi:showRecordDialog(layerNum,roundIndex,battleID)
    end
    local recordItem=GetButtonItem("worldBtnModify_Up.png","worldBtnModify_Down.png","worldBtnModify_Down.png",showRecordHandler,2,nil,nil)
    local recordMenu=CCMenu:createWithItem(recordItem)
    recordMenu:setPosition(ccp(cellWidth/2,pHeight))
    recordMenu:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer:addChild(recordMenu,3)

    local leftPosX=self.bgSize.width/4
    local hSpace=40
    local lbWid=self.bgSize.width/2-wSpace-20
    local rect = CCRect(0, 0, 37, 36)
    local capInSet = CCRect(15, 15, 10, 10)
    local function cellClick(hd,fn,idx)
    end
    local winnerBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("winnerBg.png",capInSet,cellClick)
    winnerBgSp:setContentSize(CCSizeMake(spWidth,spHeight))
    winnerBgSp:ignoreAnchorPointForPosition(false)
    winnerBgSp:setAnchorPoint(ccp(0.5,0.5))
    -- winnerBgSp:setPosition(cellWidth/2,pHeight)
    winnerBgSp:setIsSallow(false)
    winnerBgSp:setTouchPriority(-(layerNum-1)*20-1)
    self.bgLayer:addChild(winnerBgSp,1)
    local winLb=GetTTFLabel(getlocal("fight_content_result_win"),lbSize)
    self.bgLayer:addChild(winLb,2)

    local loserBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("loserBg.png",capInSet,cellClick)
    loserBgSp:setContentSize(CCSizeMake(spWidth,spHeight))
    loserBgSp:ignoreAnchorPointForPosition(false)
    loserBgSp:setAnchorPoint(ccp(0.5,0.5))
    -- loserBgSp:setPosition(cellWidth/2,pHeight)
    loserBgSp:setIsSallow(false)
    loserBgSp:setTouchPriority(-(layerNum-1)*20-1)
    self.bgLayer:addChild(loserBgSp,1)
    local loseLb=GetTTFLabel(getlocal("fight_content_result_defeat"),lbSize)
    self.bgLayer:addChild(loseLb,2)

    local isLeftWin=false
    if winnerID and alliance1 and alliance1.id and  winnerID==alliance1.id then
        isLeftWin=true
    end
    if isLeftWin==true then
        -- winnerBgSp:setAnchorPoint(ccp(1,0.5))
        -- loserBgSp:setAnchorPoint(ccp(0,0.5))
        winnerBgSp:setPosition(cellWidth/2-spWidth/2,pHeight)
        loserBgSp:setPosition(cellWidth/2+spWidth/2,pHeight)
        loserBgSp:setRotation(180)

        winLb:setPosition(ccp(leftPosX,pHeight+hSpace))
        loseLb:setPosition(ccp(self.bgSize.width-leftPosX,pHeight+hSpace))
    else
        -- winnerBgSp:setAnchorPoint(ccp(0,0.5))
        -- loserBgSp:setAnchorPoint(ccp(1,0.5))
        loserBgSp:setPosition(cellWidth/2-spWidth/2,pHeight)
        winnerBgSp:setPosition(cellWidth/2+spWidth/2,pHeight)
        winnerBgSp:setRotation(180)

        winLb:setPosition(ccp(self.bgSize.width-leftPosX,pHeight+hSpace))
        loseLb:setPosition(ccp(leftPosX,pHeight+hSpace))
    end

    local redFlageSp=CCSprite:createWithSpriteFrameName("IconWarRedFlage.png")
    redFlageSp:setPosition(55,pHeight+45)
    self.bgLayer:addChild(redFlageSp)
    local blueFlageSp=CCSprite:createWithSpriteFrameName("IconWarBlueFlage.png")
    blueFlageSp:setPosition(cellWidth-55,pHeight+45)
    self.bgLayer:addChild(blueFlageSp)
    blueFlageSp:setFlipX(true)


    local lbTb={
        {server1,lbSize,ccp(0.5,0.5),ccp(leftPosX,pHeight),self.bgLayer,1,G_ColorYellowPro},
        {server2,lbSize,ccp(0.5,0.5),ccp(self.bgSize.width-leftPosX,pHeight),self.bgLayer,1,G_ColorYellowPro},
        {name1,lbSize,ccp(0.5,0.5),ccp(leftPosX,pHeight-hSpace),self.bgLayer,1,G_ColorYellowPro},
        {name2,lbSize,ccp(0.5,0.5),ccp(self.bgSize.width-leftPosX,pHeight-hSpace),self.bgLayer,1,G_ColorYellowPro},
    }
    for k,v in pairs(lbTb) do
        GetAllTTFLabel(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11])
    end


    local point1=data.points[1]
    local point2=data.points[2]
    local destory1=data.kills[1]
    local destory2=data.kills[2]
    local memNum1=data.personNum[1]
    local memNum2=data.personNum[2]
    local myPoint=data.myPoint

    local lbHeight=50
    local hLbSpace=60
    local lbPosX=20
    local lbPosX1=250
    local lbPosX2=400
    local lbWidth=200

    local lbTab={
        {getlocal("serverwarteam_totle_point"),lbSize,ccp(0,0.5),ccp(lbPosX,lbHeight+hLbSpace*3),self.bgLayer,1,nil,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
        {point1,lbSize,ccp(0,0.5),ccp(lbPosX1,lbHeight+hLbSpace*3),self.bgLayer,1,G_ColorGreen},
        {point2,lbSize,ccp(0,0.5),ccp(lbPosX2,lbHeight+hLbSpace*3),self.bgLayer,1,G_ColorGreen},
        {getlocal("serverwarteam_member_num"),lbSize,ccp(0,0.5),ccp(lbPosX,lbHeight+hLbSpace*2),self.bgLayer,1,nil,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
        {memNum1,lbSize,ccp(0,0.5),ccp(lbPosX1,lbHeight+hLbSpace*2),self.bgLayer,1,G_ColorGreen},
        {memNum2,lbSize,ccp(0,0.5),ccp(lbPosX2,lbHeight+hLbSpace*2),self.bgLayer,1,G_ColorGreen},
        {getlocal("serverwarteam_totle_destory"),lbSize,ccp(0,0.5),ccp(lbPosX,lbHeight+hLbSpace),self.bgLayer,1,nil,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter},
        {destory1,lbSize,ccp(0,0.5),ccp(lbPosX1,lbHeight+hLbSpace),self.bgLayer,1,G_ColorGreen},
        {destory2,lbSize,ccp(0,0.5),ccp(lbPosX2,lbHeight+hLbSpace),self.bgLayer,1,G_ColorGreen},
        {getlocal("serverwarteam_my_point",{myPoint}),lbSize,ccp(0.5,0.5),ccp(self.bgSize.width/2,lbHeight),self.bgLayer,1,G_ColorYellowPro,CCSize(self.bgSize.width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter},
    }
    for k,v in pairs(lbTab) do
        -- v[1]=str
        GetAllTTFLabel(v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10],v[11])
    end

    -- local totlePointLb=GetAllTTFLabel(getlocal("serverwarteam_totle_point"),lbSize,ccp(0,0.5),ccp(lbPosX,lbHeight+hLbSpace*3),self.bgLayer,1,nil,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- local pointLb1=GetAllTTFLabel(point1,lbSize,ccp(0,0.5),ccp(lbPosX1,lbHeight+hLbSpace*3),self.bgLayer,1,G_ColorGreen)
    -- local pointLb2=GetAllTTFLabel(point2,lbSize,ccp(0,0.5),ccp(lbPosX2,lbHeight+hLbSpace*3),self.bgLayer,1,G_ColorGreen)

    -- local memberNumLb=GetAllTTFLabel(getlocal("serverwarteam_member_num"),lbSize,ccp(0,0.5),ccp(lbPosX,lbHeight+hLbSpace*2),self.bgLayer,1,nil,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- local memNumLb1=GetAllTTFLabel(memNum1,lbSize,ccp(0,0.5),ccp(lbPosX1,lbHeight+hLbSpace*2),self.bgLayer,1,G_ColorGreen)
    -- local memNumLb2=GetAllTTFLabel(memNum2,lbSize,ccp(0,0.5),ccp(lbPosX2,lbHeight+hLbSpace*2),self.bgLayer,1,G_ColorGreen)

    -- local destoryNumLb=GetAllTTFLabel(getlocal("serverwarteam_totle_destory"),lbSize,ccp(0,0.5),ccp(lbPosX,lbHeight+hLbSpace),self.bgLayer,1,nil,CCSize(lbWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    -- local destoryLb1=GetAllTTFLabel(destory1,lbSize,ccp(0,0.5),ccp(lbPosX1,lbHeight+hLbSpace),self.bgLayer,1,G_ColorGreen)
    -- local destoryLb2=GetAllTTFLabel(destory2,lbSize,ccp(0,0.5),ccp(lbPosX2,lbHeight+hLbSpace),self.bgLayer,1,G_ColorGreen)

    -- local myPointLb=GetAllTTFLabel(getlocal("serverwarteam_my_point",{myPoint}),lbSize,ccp(0.5,0.5),ccp(self.bgSize.width/2,lbHeight),self.bgLayer,1,G_ColorYellowPro,CCSize(self.bgSize.width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)


    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

function smallDialog:initTeamSendFlowerInfoDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,callback,rewardHandler)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()

    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog()

    end

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    -- self:userHandler()

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)

    local strSize2 = 24
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =40
    end
    if title then
        local titleLb=GetTTFLabel(title,strSize2)
        titleLb:setAnchorPoint(ccp(0.5,0.5))
        titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
        dialogBg:addChild(titleLb)
    end

    self.type="teamSendFlowerInfoDialog"
    self.refreshData={}
    -- self.refreshData.timeTb={}
    -- self.refreshData.label={}

    base:addNeedRefresh(self)

    local betList=serverWarTeamVoApi:getBetList()
    local num=0
    if betList and SizeOfTable(betList)>0 then
        num=SizeOfTable(betList)
    end
    if num==0 then
        local noFlowerLb=GetTTFLabelWrap(getlocal("serverwar_no_flower"),30,CCSize(self.bgSize.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        noFlowerLb:setPosition(getCenterPoint(dialogBg))
        dialogBg:addChild(noFlowerLb,1)
        noFlowerLb:setColor(G_ColorYellowPro)
    else
        local isMoved=false
        local function tvCallBack(handler,fn,idx,cel)
            if fn=="numberOfCellsInTableView" then
                local cellNum=0
                local betList=serverWarTeamVoApi:getBetList()
                if betList and SizeOfTable(betList)>0 then
                    cellNum=SizeOfTable(betList)
                end
                return cellNum
            elseif fn=="tableCellSizeForIndex" then
                local cellWidth=self.bgSize.width-40
                local cellHeight=260
                local tmpSize=CCSizeMake(cellWidth,cellHeight)
                return  tmpSize
            elseif fn=="tableCellAtIndex" then
                local cell=CCTableViewCell:new()
                cell:autorelease()

                local cellWidth=self.bgSize.width-40
                local cellHeight=260

                local betList=serverWarTeamVoApi:getBetList()
                local list={}
                for k,v in pairs(betList) do
                    if v then
                        table.insert(list,v)
                    end
                end
                local function sortFunc(a,b)
                    if a and b and a.roundID and b.roundID then
                        return tonumber(a.roundID)>tonumber(b.roundID)
                    end
                end
                table.sort(list,sortFunc)
                local betVo=list[idx+1]
                local roundID=betVo.roundID    --献花的轮次ID
                local battleID=betVo.battleID  --献花的场次ID
                local allianceID=betVo.allianceID  --投注的选手ID
                local times=betVo.times        --投注的次数
                local hasGet=betVo.hasGet      --是否已经领取
                local battleVo=serverWarTeamVoApi:getBattleVoByID(roundID,battleID)

                if battleVo==nil then
                    do return cell end
                end

                local isWin
                if allianceID and battleVo.winnerID and allianceID==battleVo.winnerID then
                    isWin=true
                else
                    isWin=false
                end

                local time=serverWarTeamVoApi:getOutBattleTime(roundID,battleID)
                -- local endTime=time+(serverWarTeamCfg.warTime)
                -- self.refreshData.timeTb[idx+1]=endTime

                local flowerNum=serverWarTeamVoApi:getSendFlowerNum(roundID,times) or 0
                local point=serverWarTeamVoApi:getSendFlowerNum(roundID,times,true,isWin) or 0
                local allianceVo=serverWarTeamVoApi:getTeam(allianceID)

                local battleVo=serverWarTeamVoApi:getBattleVoByID(roundID,battleID)
                local alliance1,alliance2=serverWarTeamVoApi:getRedAndBlueAlliance(battleVo)
                local battleStatus=serverWarTeamVoApi:getOutBattleStatus(roundID,battleID)

                local server1=""
                local server2=""
                local name1=""
                local name2=""
                local target=""
                if alliance1 then
                    server1="【"..alliance1.serverName.."】"
                    name1=alliance1.name
                end
                if alliance2 then
                    server2="【"..alliance2.serverName.."】"
                    name2=alliance2.name
                end
                if allianceVo then
                    target=allianceVo.name
                end

                local warStatus=serverWarTeamVoApi:checkStatus()
                local status
                if warStatus<20 then
                    status=0 --等待中
                elseif warStatus==20 then
                    if battleStatus<20 then
                        status=0 --等待中
                    elseif battleStatus==20 then
                        status=1 --正在进行
                    elseif battleStatus>20 then
                        status=2 --结束
                    end
                elseif warStatus>20 then
                    status=2 --结束
                end

                local canReward=false
                local isReward=false
                if hasGet==1 then
                    isReward=true
                end
                if status==2 then
                    canReward=true
                end

                local lbSize=20
                local function touch()
                end
                local bgSprie
                if canReward==true and isReward==false then
                    bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),touch)
                else
                    bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
                end
                bgSprie:setContentSize(CCSizeMake(cellWidth,cellHeight-5))
                bgSprie:setPosition(ccp(cellWidth/2,cellHeight/2))
                bgSprie:setIsSallow(false)
                bgSprie:setTouchPriority(-(layerNum-1)*20-2)
                cell:addChild(bgSprie,1)

                local tStr=G_getDataTimeStr(time)
                local roundStr=getlocal("serverwarteam_send_flower_round",{tStr,roundID})

                -- roundStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
                local roundLable = GetTTFLabelWrap(roundStr,22,CCSize(cellWidth-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                roundLable:setAnchorPoint(ccp(0,0.5))
                roundLable:setPosition(ccp(10,cellHeight-35))
                cell:addChild(roundLable,1)
                roundLable:setColor(G_ColorYellowPro)

                local lineSp1=CCSprite:createWithSpriteFrameName("LineCross.png")
                lineSp1:setAnchorPoint(ccp(0.5,0.5))
                lineSp1:setScaleX(cellWidth/lineSp1:getContentSize().width)
                lineSp1:setPosition(ccp(cellWidth/2,cellHeight-65))
                cell:addChild(lineSp1,1)

                local pHeight=cellHeight-110
                local spWidth=110
                local spHeight=60
                if status==2 then
                    local function replayHandler()
                        if self and self.refreshData and self.refreshData.tableView and self.refreshData.tableView:getScrollEnable()==true and self.refreshData.tableView:getIsScrolled()==false then
                            if G_checkClickEnable()==false then
                                do
                                    return
                                end
                            else
                                base.setWaitTime=G_getCurDeviceMillTime()
                            end
                            PlayEffect(audioCfg.mouseClick)

                            self:close()
                            serverWarTeamVoApi:showRecordDialog(layerNum,roundID,battleID)
                        end
                    end
                    local replayItem=GetButtonItem("worldBtnModify_Up.png","worldBtnModify_Down.png","worldBtnModify_Down.png",replayHandler,2,nil,nil)
                    local replayMenu=CCMenu:createWithItem(replayItem)
                    replayMenu:setPosition(ccp(cellWidth/2,pHeight))
                    replayMenu:setTouchPriority(-(layerNum-1)*20-2)
                    cell:addChild(replayMenu,3)

                    local rect = CCRect(0, 0, 37, 36)
                    local capInSet = CCRect(15, 15, 10, 10)
                    local function cellClick(hd,fn,idx)
                    end
                    local winnerBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("winnerBg.png",capInSet,cellClick)
                    winnerBgSp:setContentSize(CCSizeMake(spWidth,spHeight))
                    winnerBgSp:ignoreAnchorPointForPosition(false)
                    winnerBgSp:setAnchorPoint(ccp(0.5,0.5))
                    -- winnerBgSp:setPosition(cellWidth/2,pHeight)
                    winnerBgSp:setIsSallow(false)
                    winnerBgSp:setTouchPriority(-(layerNum-1)*20-1)
                    cell:addChild(winnerBgSp,1)
                    local winLb=GetTTFLabel(getlocal("fight_content_result_win"),lbSize)
                    cell:addChild(winLb,2)

                    local loserBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("loserBg.png",capInSet,cellClick)
                    loserBgSp:setContentSize(CCSizeMake(spWidth,spHeight))
                    loserBgSp:ignoreAnchorPointForPosition(false)
                    loserBgSp:setAnchorPoint(ccp(0.5,0.5))
                    -- loserBgSp:setPosition(cellWidth/2,pHeight)
                    loserBgSp:setIsSallow(false)
                    loserBgSp:setTouchPriority(-(layerNum-1)*20-1)
                    cell:addChild(loserBgSp,1)
                    local loseLb=GetTTFLabel(getlocal("fight_content_result_defeat"),lbSize)
                    cell:addChild(loseLb,2)

                    local isLeftWin=false
                    if alliance1.id==battleVo.winnerID then
                        isLeftWin=true
                    end
                    if isLeftWin==true then
                        -- winnerBgSp:setAnchorPoint(ccp(1,0.5))
                        -- loserBgSp:setAnchorPoint(ccp(0,0.5))
                        winnerBgSp:setPosition(cellWidth/2-spWidth/2,pHeight)
                        loserBgSp:setPosition(cellWidth/2+spWidth/2,pHeight)
                        loserBgSp:setRotation(180)

                        winLb:setPosition(ccp(cellWidth/2-70,pHeight))
                        loseLb:setPosition(ccp(cellWidth/2+70,pHeight))
                    else
                        -- winnerBgSp:setAnchorPoint(ccp(0,0.5))
                        -- loserBgSp:setAnchorPoint(ccp(1,0.5))
                        loserBgSp:setPosition(cellWidth/2-spWidth/2,pHeight)
                        winnerBgSp:setPosition(cellWidth/2+spWidth/2,pHeight)
                        winnerBgSp:setRotation(180)

                        winLb:setPosition(ccp(cellWidth/2+70,pHeight))
                        loseLb:setPosition(ccp(cellWidth/2-70,pHeight))
                    end
                elseif status==1 then
                    -- local cdTime=endTime-base.serverTime
                    -- if cdTime<0 then
                    --     cdTime=0
                    -- end
                    -- local resultStr=getlocal("serverwar_result")..GetTimeStr(cdTime)
                    -- local resultLb=GetTTFLabel(resultStr,lbSize)
                    -- resultLb:setPosition(ccp(cellWidth/2,pHeight+25))
                    -- cell:addChild(resultLb,1)
                    -- resultLb:setColor(G_ColorYellowPro)
                    -- self.refreshData.label[idx+1]=resultLb

                    local function cellClick(hd,fn,idx)
                    end
                    local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
                    lbBg:setContentSize(CCSizeMake(spWidth*2,40))
                    lbBg:ignoreAnchorPointForPosition(false)
                    lbBg:setAnchorPoint(ccp(0.5,0.5))
                    lbBg:setPosition(ccp(cellWidth/2,pHeight-13))
                    lbBg:setIsSallow(false)
                    lbBg:setTouchPriority(-(layerNum-1)*20-1)
                    cell:addChild(lbBg,1)
                    local statusStr=getlocal("serverwar_ongoing")..getlocal("serverwar_dot")
                    local statusLb=GetTTFLabel(statusStr,lbSize)
                    statusLb:setPosition(getCenterPoint(lbBg))
                    lbBg:addChild(statusLb,1)
                elseif status==0 then
                    local function cellClick(hd,fn,idx)
                    end
                    local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("mainChatBgTo.png",CCRect(10,10,5,5),cellClick)
                    lbBg:setContentSize(CCSizeMake(spWidth*2,40))
                    lbBg:ignoreAnchorPointForPosition(false)
                    lbBg:setAnchorPoint(ccp(0.5,0.5))
                    lbBg:setPosition(ccp(cellWidth/2,pHeight))
                    lbBg:setIsSallow(false)
                    lbBg:setTouchPriority(-(layerNum-1)*20-1)
                    cell:addChild(lbBg,1)
                    local statusStr=getlocal("serverwar_waiting")..getlocal("serverwar_dot")
                    local statusLb=GetTTFLabel(statusStr,lbSize)
                    statusLb:setPosition(getCenterPoint(lbBg))
                    lbBg:addChild(statusLb,1)
                end


                -- server1="啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
                -- server2="啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
                local wSpace=75
                local hSpace=0
                local serverLb1=GetTTFLabelWrap(server1,lbSize,CCSize(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
                serverLb1:setAnchorPoint(ccp(0.5,0))
                serverLb1:setPosition(ccp(wSpace,pHeight+hSpace))
                cell:addChild(serverLb1,1)

                local serverLb2=GetTTFLabelWrap(server2,lbSize,CCSize(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
                serverLb2:setAnchorPoint(ccp(0.5,0))
                serverLb2:setPosition(ccp(cellWidth-wSpace,pHeight+hSpace))
                cell:addChild(serverLb2,1)

                local nameLb1=GetTTFLabel(name1,lbSize)
                nameLb1:setAnchorPoint(ccp(0.5,1))
                nameLb1:setPosition(ccp(wSpace,pHeight-hSpace))
                cell:addChild(nameLb1,1)

                local nameLb2=GetTTFLabel(name2,lbSize)
                nameLb2:setAnchorPoint(ccp(0.5,1))
                nameLb2:setPosition(ccp(cellWidth-wSpace,pHeight-hSpace))
                cell:addChild(nameLb2,1)

                local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
                lineSp2:setAnchorPoint(ccp(0.5,0.5))
                lineSp2:setScaleX(cellWidth/lineSp2:getContentSize().width)
                lineSp2:setPosition(ccp(cellWidth/2,cellHeight-155))
                cell:addChild(lineSp2,1)



                local lbHeight=60
                local hLbSpace=25
                local sendFlowerLb=GetTTFLabel(getlocal("serverwar_send_flower"),lbSize)
                sendFlowerLb:setAnchorPoint(ccp(0,0.5))
                sendFlowerLb:setPosition(ccp(10,lbHeight+hLbSpace))
                cell:addChild(sendFlowerLb,1)
                local flowerNumLb=GetTTFLabel(flowerNum,lbSize)
                flowerNumLb:setAnchorPoint(ccp(0,0.5))
                flowerNumLb:setPosition(ccp(sendFlowerLb:getContentSize().width+8,lbHeight+hLbSpace))
                cell:addChild(flowerNumLb,1)
                flowerNumLb:setColor(G_ColorGreen)

                local sendToLb=GetTTFLabel(getlocal("serverwar_send_to"),lbSize)
                sendToLb:setAnchorPoint(ccp(0,0.5))
                sendToLb:setPosition(ccp(10,lbHeight))
                cell:addChild(sendToLb,1)
                local targetLb=GetTTFLabel(target,lbSize)
                targetLb:setAnchorPoint(ccp(0,0.5))
                targetLb:setPosition(ccp(sendToLb:getContentSize().width+8,lbHeight))
                cell:addChild(targetLb,1)
                targetLb:setColor(G_ColorGreen)

                local getPointLb=GetTTFLabel(getlocal("serverwar_get_point"),lbSize)
                getPointLb:setAnchorPoint(ccp(0,0.5))
                getPointLb:setPosition(ccp(10,lbHeight-hLbSpace))
                cell:addChild(getPointLb,1)
                local pointStr=""
                if status~=2 then
                    pointStr=getlocal("waiting")
                elseif isWin==true then
                    pointStr=getlocal("fight_content_result_win").."+"..point
                else
                    pointStr=getlocal("fight_content_result_defeat").."+"..point
                end
                local pointLb=GetTTFLabel(pointStr,lbSize)
                pointLb:setAnchorPoint(ccp(0,0.5))
                pointLb:setPosition(ccp(getPointLb:getContentSize().width+8,lbHeight-hLbSpace))
                cell:addChild(pointLb,1)
                pointLb:setColor(G_ColorGreen)


                if isReward==true then
                    local hadRewardLable = GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSize(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    hadRewardLable:setAnchorPoint(ccp(0.5,0.5))
                    hadRewardLable:setPosition(ccp(cellWidth-75,lbHeight))
                    cell:addChild(hadRewardLable,1)
                    hadRewardLable:setColor(G_ColorGreen)
                elseif canReward==true then
                    local function rewardHandler1()
                        if self and self.refreshData and self.refreshData.tableView and self.refreshData.tableView:getScrollEnable()==true and self.refreshData.tableView:getIsScrolled()==false then
                            if G_checkClickEnable()==false then
                                do
                                    return
                                end
                            else
                                base.setWaitTime=G_getCurDeviceMillTime()
                            end
                            PlayEffect(audioCfg.mouseClick)

                            local function callback1(fn,data)
                                local ret,sData=base:checkServerData(data)
                                if ret==true then
                                    serverWarTeamVoApi:betReward(roundID,point)
                                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwar_reward_point",{point}),30)
                                    if rewardHandler then
                                        rewardHandler()
                                    end

                                    if self and self.refreshData and self.refreshData.tableView then
                                        -- self.refreshData.timeTb=nil
                                        -- self.refreshData.label=nil
                                        -- self.refreshData.timeTb={}
                                        -- self.refreshData.label={}
                                        local recordPoint = self.refreshData.tableView:getRecordPoint()
                                        self.refreshData.tableView:reloadData()
                                        self.refreshData.tableView:recoverToRecordPoint(recordPoint)
                                    end
                                end
                            end
                            local matchId=serverWarTeamVoApi:getServerWarId()
                            local detailId=serverWarTeamVoApi:getConnectId(matchId,2,roundID,battleID)
                            socketHelper:acrossGetbetreward(matchId,detailId,callback1)
                        end
                    end
                    local rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rewardHandler1,2,getlocal("activity_continueRecharge_reward"),25)
                    rewardItem:setScale(0.8)
                    local rewardMenu=CCMenu:createWithItem(rewardItem)
                    rewardMenu:setPosition(ccp(cellWidth-75,lbHeight))
                    rewardMenu:setTouchPriority(-(layerNum-1)*20-2)
                    cell:addChild(rewardMenu,1)
                end

                return cell
            elseif fn=="ccTouchBegan" then
                isMoved=false
                return true
            elseif fn=="ccTouchMoved" then
                isMoved=true
            elseif fn=="ccTouchEnded"  then

            end
        end
        local cellWidth=self.bgLayer:getContentSize().width-40
        local hd= LuaEventHandler:createHandler(tvCallBack)
        self.refreshData.tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,self.bgLayer:getContentSize().height-180),nil)
        self.refreshData.tableView:setTableViewTouchPriority(-(layerNum-1)*20-3)
        self.refreshData.tableView:setPosition(ccp(20,100))
        self.bgLayer:addChild(self.refreshData.tableView,2)
        self.refreshData.tableView:setMaxDisToBottomOrTop(120)

        self:addForbidSp(self.bgLayer,size,layerNum)
    end

    if serverWarTeamVoApi:checkStatus()<30 then
        --去献花
        local function sendFlowerHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            if callback then
                if callback()==true then
                    self:close()
                end
            else
                self:close()
            end
        end
        local sendFlowerItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sendFlowerHandler,2,getlocal("serverwar_go_send_flower"),25)
        local sendFlowerMenu=CCMenu:createWithItem(sendFlowerItem);
        sendFlowerMenu:setPosition(ccp(dialogBg:getContentSize().width/2,60))
        sendFlowerMenu:setTouchPriority(-(layerNum-1)*20-4)
        dialogBg:addChild(sendFlowerMenu)
        self.refreshData.sendFlowerMenu=sendFlowerMenu
    end


    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end



function smallDialog:showUsePropsDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,pid,callback)
    local sd=smallDialog:new()
    local dialog=sd:initUsePropsDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,pid,callback)
    return sd
end
function smallDialog:initUsePropsDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,pid,callback)
    self.isTouch=nil
    self.isUseAmi=isuseami

    self.type="usePropsDialog"

    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()


    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)

    -- if title then
    --     local titleLb=GetTTFLabel(title,40)
    --     titleLb:setAnchorPoint(ccp(0.5,0.5))
    --     titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
    --     dialogBg:addChild(titleLb)
    -- end

    if pid and propCfg[pid] then
        local id=tonumber(pid) or tonumber(RemoveFirstChar(pid))
        local num=bagVoApi:getItemNumId(id)
        local itemData={p={}}
        itemData.p[pid]=num
        local itemTb=FormatItem(itemData,false)
        local item=itemTb[1]
        self.maxNum=num

        if item then
            local sprite=bagVoApi:getItemIcon(pid)
            if sprite then
                sprite:setAnchorPoint(ccp(0,0.5))
                sprite:setPosition(25,size.height-160)
                dialogBg:addChild(sprite,2)
            end

            local nameLb=GetTTFLabelWrap(item.name,30,CCSize(self.bgSize.width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            nameLb:setAnchorPoint(ccp(0,0.5))
            nameLb:setPosition(ccp(25,size.height-65))
            dialogBg:addChild(nameLb,1)
            nameLb:setColor(G_ColorGreen)

            local descLb=GetTTFLabelWrap(getlocal(item.desc),25,CCSize(self.bgSize.width-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            descLb:setAnchorPoint(ccp(0,0.5))
            descLb:setPosition(ccp(140,size.height-160))
            dialogBg:addChild(descLb,1)


            local height=200
            local numBg=CCSprite:createWithSpriteFrameName("groupSelf.png")
            numBg:setPosition(ccp(size.width/2+20,height))
            numBg:setScaleY(100/numBg:getContentSize().height)
            numBg:setScaleX(size.width/numBg:getContentSize().width)
            dialogBg:addChild(numBg)

            self.useNum=1
            self.numLb=GetTTFLabel(getlocal("scheduleChapter",{self.useNum,item.num}),40)
            self.numLb:setAnchorPoint(ccp(0.5,0.5))
            self.numLb:setPosition(ccp(size.width/2,height))
            dialogBg:addChild(self.numLb,1)


            local scale=1
            -- local function changeHandler(tag,object)
            --     -- if G_checkClickEnable()==false then
            --     --     do
            --     --         return
            --     --     end
            --     -- else
            --     --     base.setWaitTime=G_getCurDeviceMillTime()
            --     -- end
            --     -- PlayEffect(audioCfg.mouseClick)
            --     -- print("tag",tag)
            --     -- print("self.useNum",self.useNum)
            --     -- if tag==11 then
            --     --     -- if self.useNum>1 then
            --     --     --     self.useNum=self.useNum-1
            --     --     -- end
            --     --     if self.useNum<=1 then
            --     --         -- self.useNum=1
            --     --         self.reduceBtn:setEnabled(false)
            --     --     end
            --     --     -- self.numLb:setString(getlocal("scheduleChapter",{self.useNum,item.num}))
            --     --     -- self.increaseBtn:setEnabled(true)
            --     -- elseif tag==12 then
            --     --     -- if self.useNum<item.num then
            --     --     --     self.useNum=self.useNum+1
            --     --     -- end
            --     --     if self.useNum>=item.num then
            --     --         -- self.useNum=item.num
            --     --         self.increaseBtn:setEnabled(false)
            --     --     end
            --     --     -- self.numLb:setString(getlocal("scheduleChapter",{self.useNum,item.num}))
            --     --     -- self.reduceBtn:setEnabled(true)
            --     -- end
            -- end
            -- self.reduceBtn=GetButtonItem("leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",changeHandler,11,nil,nil,nil,1)
            -- self.reduceBtn:setScale(scale)
            -- local reduceMenu=CCMenu:createWithItem(self.reduceBtn)
            -- reduceMenu:setAnchorPoint(ccp(0.5,0.5))
            -- reduceMenu:setPosition(ccp(150,height))
            -- reduceMenu:setTouchPriority(-(layerNum-1)*20-2)
            -- dialogBg:addChild(reduceMenu,1)
            -- self.reduceBtn:setEnabled(false)

            self.reduceSp1=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
            self.reduceSp1:setAnchorPoint(ccp(0.5,0.5))
            self.reduceSp1:setPosition(ccp(150,height))
            self.reduceSp1:setScale(scale)
            dialogBg:addChild(self.reduceSp1,1)
            self.reduceSp2=GraySprite:createWithSpriteFrameName("leftBtnGreen.png")
            self.reduceSp2:setAnchorPoint(ccp(0.5,0.5))
            self.reduceSp2:setPosition(ccp(150,height))
            self.reduceSp2:setScale(scale)
            dialogBg:addChild(self.reduceSp2,1)


            -- self.increaseBtn=GetButtonItem("leftBtnGreen.png","leftBtnGreen.png","leftBtnGreen.png",changeHandler,12,nil,nil)
            -- self.increaseBtn:setRotation(180)
            -- self.increaseBtn:setScale(scale)
            -- local increaseMenu=CCMenu:createWithItem(self.increaseBtn)
            -- increaseMenu:setAnchorPoint(ccp(0.5,0.5))
            -- increaseMenu:setPosition(ccp(size.width-150,height))
            -- increaseMenu:setTouchPriority(-(layerNum-1)*20-2)
            -- dialogBg:addChild(increaseMenu,1)

            self.increaseSp1=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
            self.increaseSp1:setAnchorPoint(ccp(0.5,0.5))
            self.increaseSp1:setPosition(ccp(size.width-150,height))
            self.increaseSp1:setRotation(180)
            self.increaseSp1:setScale(scale)
            dialogBg:addChild(self.increaseSp1,1)
            self.increaseSp2=GraySprite:createWithSpriteFrameName("leftBtnGreen.png")
            self.increaseSp2:setAnchorPoint(ccp(0.5,0.5))
            self.increaseSp2:setPosition(ccp(size.width-150,height))
            self.increaseSp2:setRotation(180)
            self.increaseSp2:setScale(scale)
            dialogBg:addChild(self.increaseSp2,1)

            self.reduceSp1:setVisible(false)
            self.reduceSp2:setVisible(true)
            self.increaseSp1:setVisible(true)
            self.increaseSp2:setVisible(false)


            local function maxNumHandler(tag,object)
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                self.useNum=item.num
                self.numLb:setString(getlocal("scheduleChapter",{self.useNum,item.num}))
                -- self.reduceBtn:setEnabled(true)
                -- self.increaseBtn:setEnabled(false)

                self.reduceSp1:setVisible(true)
                self.reduceSp2:setVisible(false)
                self.increaseSp1:setVisible(false)
                self.increaseSp2:setVisible(true)
            end
            local maxNumItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",maxNumHandler,2,getlocal("prop_use_max_num"),30)
            maxNumItem:setScale(0.6)
            local maxNumMenu=CCMenu:createWithItem(maxNumItem)
            maxNumMenu:setPosition(ccp(size.width-70,height))
            maxNumMenu:setTouchPriority(-(layerNum-1)*20-2)
            dialogBg:addChild(maxNumMenu,1)


            local function useHandler(tag,object)
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                -- print("self.useNum",self.useNum)
                if callback then
                    callback(self.useNum)
                end
                self:close()
            end
            local useItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",useHandler,2,getlocal("use"),25)
            -- useItem:setScale(0.8)
            local useMenu=CCMenu:createWithItem(useItem)
            useMenu:setPosition(ccp(size.width/2,80))
            useMenu:setTouchPriority(-(layerNum-1)*20-2)
            dialogBg:addChild(useMenu,1)


            local function touchLayerHandler(eventType,x,y,touch)
                if eventType=="began" then
                    -- print("eventType",eventType,x,y,touch)
                    local reduceWidth,reduceHeight=self.reduceSp1:getContentSize().width*scale,self.reduceSp1:getContentSize().height*scale
                    local increaseWidth,increaseHeight=self.increaseSp1:getContentSize().width*scale,self.increaseSp1:getContentSize().height*scale
                    local reduceX,reduceY=self.reduceSp1:getPosition()
                    local increaseX,increaseY=self.increaseSp1:getPosition()
                    local rx=(G_VisibleSizeWidth-size.width)/2+reduceX
                    local ry=(G_VisibleSizeHeight-size.height)/2+reduceY
                    local ix=G_VisibleSizeWidth-rx
                    local iy=ry

                    if x>rx-reduceWidth/2 and x<rx+reduceWidth/2 and y>ry-reduceHeight/2 and y<ry+reduceHeight/2 then
                        self.isAdd=false
                        self.fastTickIndex=0
                        base:addNeedRefresh(self)
                    elseif x>ix-increaseWidth/2 and x<ix+increaseWidth/2 and y>iy-increaseHeight/2 and y<iy+increaseHeight/2 then
                        self.isAdd=true
                        self.fastTickIndex=0
                        base:addNeedRefresh(self)
                    end
                    return true
                elseif eventType=="moved" then
                    -- base:removeFromNeedRefresh(self)
                elseif eventType=="ended"  then
                    base:removeFromNeedRefresh(self)
                end
            end
            local touchLayer=CCLayer:create()
            self.dialogLayer:addChild(touchLayer,5)
            touchLayer:setTouchEnabled(true)
            touchLayer:registerScriptTouchHandler(touchLayerHandler,false,-(layerNum-1)*20-5,false)
            local rect=size
            touchLayer:setContentSize(rect)
            touchLayer:setPosition(getCenterPoint(self.dialogLayer))

        end
    end





    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function touchLuaSpr()
        if self.isTouch~=nil then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end



function smallDialog:showCheckPointDetailDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,sid)
      local sd=smallDialog:new()
      local dialog=sd:initCheckPointDetailDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,sid)
      return sd
end
function smallDialog:initCheckPointDetailDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,sid)
    self.isTouch=nil
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)

    if title then
        local titleLb=GetTTFLabel(title,40)
        titleLb:setAnchorPoint(ccp(0.5,0.5))
        titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
        dialogBg:addChild(titleLb)
    end



    local chapterDetail=checkPointVoApi:getChapterDetail(sid)
    if chapterDetail~=nil then
        local reward=chapterDetail.reward or {}
        local pool=chapterDetail.pool or {}
        local tank=chapterDetail.tank or {}

        self.refreshData={}
        local function tvCallBack(handler,fn,idx,cel)
            if fn=="numberOfCellsInTableView" then
                return 3
            elseif fn=="tableCellSizeForIndex" then
                local cellWidth=self.bgSize.width-20
                local cellHeight
                if idx==0 then
                    cellHeight=230
                elseif idx==1 then
                    if pool and SizeOfTable(pool)>0 then
                        local rowNum=math.ceil(SizeOfTable(pool)/2)
                        cellHeight=50+160*rowNum+20
                    else
                        cellHeight=50
                    end
                else
                    cellHeight=550
                end
                local tmpSize=CCSizeMake(cellWidth,cellHeight)
                return  tmpSize
            elseif fn=="tableCellAtIndex" then
                local cell=CCTableViewCell:new()
                cell:autorelease()

                local cellWidth=self.bgSize.width-20
                local cellHeight
                if idx==0 then
                    cellHeight=230
                elseif idx==1 then
                    if pool and SizeOfTable(pool)>0 then
                        local rowNum=math.ceil(SizeOfTable(pool)/2)
                        cellHeight=50+160*rowNum+20
                    else
                        cellHeight=50
                    end
                else
                    cellHeight=550
                end

                local rect = CCRect(0, 0, 50, 50)
                local capInSet = CCRect(20, 20, 10, 10)
                local function cellClick(hd,fn,idx)
                end
                local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
                backSprie:setContentSize(CCSizeMake(cellWidth, 50))
                backSprie:ignoreAnchorPointForPosition(false)
                backSprie:setAnchorPoint(ccp(0.5,1))
                backSprie:setIsSallow(false)
                backSprie:setTouchPriority(-(layerNum-1)*20-2)
                cell:addChild(backSprie,1)
                backSprie:setPosition(ccp(cellWidth/2,cellHeight))

                local titleLabel
                if idx==0 then
                    titleLabel=GetTTFLabel(getlocal("checkPointReward"),30)
                elseif idx==1 then
                    titleLabel=GetTTFLabel(getlocal("check_point_drop_detail"),30)
                else
                    titleLabel=GetTTFLabel(getlocal("alliance_challenge_enemy_info"),30)
                end
                titleLabel:setPosition(getCenterPoint(backSprie))
                backSprie:addChild(titleLabel,2)


                local itemTb
                if idx==0 then
                    itemTb=reward
                elseif idx==1 then
                    itemTb=pool
                else
                    itemTb=tank
                end
                for k,v in pairs(itemTb) do
                    local posX
                    local posY
                    if idx==0 or idx==1 then
                        posX=140+((k-1)%2)*250
                        posY=cellHeight-50-70-math.floor((k-1)/2)*160
                    else
                        posX=390-(math.ceil(k/3)-1)*250
                        posY=cellHeight-(((k-1)%3)*160+120)

                        local bgSp=CCSprite:createWithSpriteFrameName("BgEmptyTank.png")
                        bgSp:setScale(100/bgSp:getContentSize().width)
                        bgSp:setPosition(ccp(posX,posY))
                        cell:addChild(bgSp)
                    end
                    if v and SizeOfTable(v)>0 then
                        local icon,iconScale=G_getItemIcon(v,100,false)
                        local name=v.name or ""
                        local num=tonumber(v.num) or 0
                        if icon then
                            icon:setPosition(ccp(posX,posY))
                            cell:addChild(icon,2)

                            local str=(name)
                            if idx~=1 then
                                str=str.."("..tostring(num)..")"
                            end
                            -- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
                            local nameLb=GetTTFLabelWrap(str,22,CCSizeMake(240,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                            nameLb:setAnchorPoint(ccp(0.5,0.5))
                            nameLb:setPosition(ccp(posX,posY-75))
                            cell:addChild(nameLb,2)
                        end
                    end
                end

                return cell
            elseif fn=="ccTouchBegan" then
                isMoved=false
                return true
            elseif fn=="ccTouchMoved" then
                isMoved=true
            elseif fn=="ccTouchEnded"  then

            end
        end
        local cellWidth=self.bgSize.width-20
        local hd= LuaEventHandler:createHandler(tvCallBack)
        self.refreshData.tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,self.bgLayer:getContentSize().height-190),nil)
        self.refreshData.tableView:setTableViewTouchPriority(-(layerNum-1)*20-3)
        self.refreshData.tableView:setPosition(ccp(10,100))
        self.bgLayer:addChild(self.refreshData.tableView,2)
        self.refreshData.tableView:setMaxDisToBottomOrTop(120)

        self:addForbidSp(self.bgLayer,size,layerNum)

    end


    --确定
    local function sureHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        self:close()
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,1,getlocal("ok"),25)
    local sureMenu=CCMenu:createWithItem(sureItem)
    sureMenu:setPosition(ccp(self.bgSize.width/2,50))
    sureMenu:setTouchPriority(-(layerNum-1)*20-4)
    dialogBg:addChild(sureMenu)


    local function touchDialog()

    end
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function touchLuaSpr()
        if self.isTouch~=nil then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end


function smallDialog:initServerWarRankDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,serverWarRank)
    self.isTouch=true
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local wrIcon=nil
    if serverWarRank and serverWarRank>0 and serverWarPersonalVoApi then
        local icon,sType,cfg=serverWarPersonalVoApi:getRankIcon(serverWarRank)
        if icon and cfg then
            wrIcon=CCSprite:createWithSpriteFrameName(icon)
            if wrIcon then
                wrIcon:setPosition(ccp(wrIcon:getContentSize().width/2+25,size.height/2))
                self.bgLayer:addChild(wrIcon,2)
            end
            local lbWidth=130
            local titleLb=GetTTFLabelWrap(getlocal(cfg.title),30,CCSize(self.bgSize.width-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom)
            titleLb:setAnchorPoint(ccp(0,0))
            titleLb:setPosition(ccp(lbWidth,size.height/2+10))
            dialogBg:addChild(titleLb,1)
            titleLb:setColor(G_ColorYellowPro)

            local descLb=GetTTFLabelWrap(getlocal(cfg.desc),25,CCSize(self.bgSize.width-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            descLb:setAnchorPoint(ccp(0,1))
            descLb:setPosition(ccp(lbWidth,size.height/2-10))
            dialogBg:addChild(descLb,1)
        end
    end

    local function touchDialog()

    end
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function touchLuaSpr()
        if self.isTouch~=nil then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

function smallDialog:initSendFlowerInfoDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,callback,rewardHandler)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()

    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog()

    end

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    -- self:userHandler()

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)

    if title then
        local titleLb=GetTTFLabel(title,40)
        titleLb:setAnchorPoint(ccp(0.5,0.5))
        titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
        dialogBg:addChild(titleLb)
    end

    self.type="sendFlowerInfoDialog"
    self.refreshData={}
    self.refreshData.timeTb={}
    self.refreshData.label={}

    base:addNeedRefresh(self)

    local betList=serverWarPersonalVoApi:getBetList()
    local num=0
    if betList and SizeOfTable(betList)>0 then
        num=SizeOfTable(betList)
    end
    if num==0 then
        local noFlowerLb=GetTTFLabelWrap(getlocal("serverwar_no_flower"),30,CCSize(self.bgSize.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        noFlowerLb:setPosition(getCenterPoint(dialogBg))
        dialogBg:addChild(noFlowerLb,1)
        noFlowerLb:setColor(G_ColorYellowPro)
    else
        local isMoved=false
        local function tvCallBack(handler,fn,idx,cel)
            if fn=="numberOfCellsInTableView" then
                local cellNum=0
                local betList=serverWarPersonalVoApi:getBetList()
                if betList and SizeOfTable(betList)>0 then
                    cellNum=SizeOfTable(betList)
                end
                return cellNum
            elseif fn=="tableCellSizeForIndex" then
                local cellWidth=self.bgSize.width-40
                local cellHeight=260
                local tmpSize=CCSizeMake(cellWidth,cellHeight)
                return  tmpSize
            elseif fn=="tableCellAtIndex" then
                local cell=CCTableViewCell:new()
                cell:autorelease()

                local cellWidth=self.bgSize.width-40
                local cellHeight=260

                local betList=serverWarPersonalVoApi:getBetList()
                local list={}
                for k,v in pairs(betList) do
                    if v then
                        table.insert(list,v)
                    end
                end
                local function sortFunc(a,b)
                    if a and b and a.roundID and b.roundID then
                        return tonumber(a.roundID)>tonumber(b.roundID)
                    end
                end
                table.sort(list,sortFunc)
                local betVo=list[idx+1]
                local roundID=betVo.roundID    --献花的轮次ID
                local groupID=betVo.groupID    --给胜者组献花是1, 给败者组献花是2
                local battleID=betVo.battleID  --献花的场次ID
                local playerID=betVo.playerID  --投注的选手ID
                local times=betVo.times        --投注的次数
                local hasGet=betVo.hasGet      --是否已经领取
                local battleVo=serverWarPersonalVoApi:getBattleData(roundID,groupID,battleID)

                if battleVo==nil then
                    do return cell end
                end

                local isWin
                if battleVo.winnerID then
                    if playerID==battleVo.winnerID then
                        isWin=true
                    else
                        isWin=false
                    end
                end

                local timeList=serverWarPersonalVoApi:getBattleTimeList()
                local time=timeList[roundID+1]
                local endTime=time+(serverWarPersonalCfg.battleTime*3)
                self.refreshData.timeTb[idx+1]=endTime

                local flowerNum=serverWarPersonalVoApi:getSendFlowerNum(roundID,times) or 0
                local point=serverWarPersonalVoApi:getSendFlowerNum(roundID,times,true,isWin) or 0
                local playerVo=serverWarPersonalVoApi:getPlayer(playerID)

                local server1=""
                local server2=""
                local name1=""
                local name2=""
                local target=""
                if battleVo then
                    server1="【"..battleVo.player1.serverName.."】"
                    server2="【"..battleVo.player2.serverName.."】"
                    name1=battleVo.player1.name
                    name2=battleVo.player2.name
                end
                if playerVo then
                    target=playerVo.name
                end

                local roundStatus=serverWarPersonalVoApi:getRoundStatus(roundID)
                if roundStatus<21 then
                    status=0 --等待中
                elseif roundStatus>=21 and roundStatus<30 then
                    status=1 --正在进行
                elseif roundStatus>=30 then
                    status=2 --结束
                end

                local canReward=false
                local isReward=false
                if hasGet==1 then
                    isReward=true
                end
                if status==2 then
                    canReward=true
                end

                local lbSize=20
                local function touch()
                end
                local bgSprie
                if canReward==true and isReward==false then
                    bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),touch)
                else
                    bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
                end
                bgSprie:setContentSize(CCSizeMake(cellWidth,cellHeight-5))
                bgSprie:setPosition(ccp(cellWidth/2,cellHeight/2))
                bgSprie:setIsSallow(false)
                bgSprie:setTouchPriority(-(layerNum-1)*20-2)
                cell:addChild(bgSprie,1)

                local tStr=G_getDataTimeStr(time)
                local roundStr
                if roundID==0 then
                    roundStr=getlocal("serverwar_send_flower_round1",{tStr})
                else
                    roundStr=getlocal("serverwar_send_flower_round2",{tStr,roundID})
                end
                -- roundStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
                local roundLable = GetTTFLabelWrap(roundStr,22,CCSize(cellWidth-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                roundLable:setAnchorPoint(ccp(0,0.5))
                roundLable:setPosition(ccp(10,cellHeight-35))
                cell:addChild(roundLable,1)
                roundLable:setColor(G_ColorYellowPro)

                local lineSp1=CCSprite:createWithSpriteFrameName("LineCross.png")
                lineSp1:setAnchorPoint(ccp(0.5,0.5))
                lineSp1:setScaleX(cellWidth/lineSp1:getContentSize().width)
                lineSp1:setPosition(ccp(cellWidth/2,cellHeight-65))
                cell:addChild(lineSp1,1)

                local pHeight=cellHeight-110
                local spWidth=110
                local spHeight=60
                if status==2 then
                    local function replayHandler()
                        if self and self.refreshData and self.refreshData.tableView and self.refreshData.tableView:getScrollEnable()==true and self.refreshData.tableView:getIsScrolled()==false then
                            if G_checkClickEnable()==false then
                                do
                                    return
                                end
                            else
                                base.setWaitTime=G_getCurDeviceMillTime()
                            end
                            PlayEffect(audioCfg.mouseClick)

                            local function callback()
                                if battleVo then
                                    serverWarPersonalVoApi:showBattleDialog(battleVo,roundID,layerNum+1)
                                end
                            end
                            serverWarPersonalVoApi:getScheduleInfo(callback)
                        end
                    end
                    local replayItem=GetButtonItem("cameraBtn.png","cameraBtn_down.png","cameraBtn_down.png",replayHandler,2,nil,nil)
                    local replayMenu=CCMenu:createWithItem(replayItem)
                    replayMenu:setPosition(ccp(cellWidth/2,pHeight))
                    replayMenu:setTouchPriority(-(layerNum-1)*20-2)
                    cell:addChild(replayMenu,3)

                    local rect = CCRect(0, 0, 37, 36)
                    local capInSet = CCRect(15, 15, 10, 10)
                    local function cellClick(hd,fn,idx)
                    end
                    local winnerBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("winnerBg.png",capInSet,cellClick)
                    winnerBgSp:setContentSize(CCSizeMake(spWidth,spHeight))
                    winnerBgSp:ignoreAnchorPointForPosition(false)
                    winnerBgSp:setAnchorPoint(ccp(0.5,0.5))
                    -- winnerBgSp:setPosition(cellWidth/2,pHeight)
                    winnerBgSp:setIsSallow(false)
                    winnerBgSp:setTouchPriority(-(layerNum-1)*20-1)
                    cell:addChild(winnerBgSp,1)
                    local winLb=GetTTFLabel(getlocal("fight_content_result_win"),lbSize)
                    cell:addChild(winLb,2)

                    local loserBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("loserBg.png",capInSet,cellClick)
                    loserBgSp:setContentSize(CCSizeMake(spWidth,spHeight))
                    loserBgSp:ignoreAnchorPointForPosition(false)
                    loserBgSp:setAnchorPoint(ccp(0.5,0.5))
                    -- loserBgSp:setPosition(cellWidth/2,pHeight)
                    loserBgSp:setIsSallow(false)
                    loserBgSp:setTouchPriority(-(layerNum-1)*20-1)
                    cell:addChild(loserBgSp,1)
                    local loseLb=GetTTFLabel(getlocal("fight_content_result_defeat"),lbSize)
                    cell:addChild(loseLb,2)

                    local isLeftWin=false
                    if battleVo.id1==battleVo.winnerID then
                        isLeftWin=true
                    end
                    if isLeftWin==true then
                        -- winnerBgSp:setAnchorPoint(ccp(1,0.5))
                        -- loserBgSp:setAnchorPoint(ccp(0,0.5))
                        winnerBgSp:setPosition(cellWidth/2-spWidth/2,pHeight)
                        loserBgSp:setPosition(cellWidth/2+spWidth/2,pHeight)
                        loserBgSp:setRotation(180)

                        winLb:setPosition(ccp(cellWidth/2-70,pHeight))
                        loseLb:setPosition(ccp(cellWidth/2+70,pHeight))
                    else
                        -- winnerBgSp:setAnchorPoint(ccp(0,0.5))
                        -- loserBgSp:setAnchorPoint(ccp(1,0.5))
                        loserBgSp:setPosition(cellWidth/2-spWidth/2,pHeight)
                        winnerBgSp:setPosition(cellWidth/2+spWidth/2,pHeight)
                        winnerBgSp:setRotation(180)

                        winLb:setPosition(ccp(cellWidth/2+70,pHeight))
                        loseLb:setPosition(ccp(cellWidth/2-70,pHeight))
                    end
                elseif status==1 then
                    local cdTime=endTime-base.serverTime
                    if cdTime<0 then
                        cdTime=0
                    end
                    local resultStr=getlocal("serverwar_result")..GetTimeStr(cdTime)
                    local resultLb=GetTTFLabel(resultStr,lbSize)
                    resultLb:setPosition(ccp(cellWidth/2,pHeight+25))
                    cell:addChild(resultLb,1)
                    resultLb:setColor(G_ColorYellowPro)
                    self.refreshData.label[idx+1]=resultLb

                    local function cellClick(hd,fn,idx)
                    end
                    local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),cellClick)
                    lbBg:setContentSize(CCSizeMake(spWidth*2,40))
                    lbBg:ignoreAnchorPointForPosition(false)
                    lbBg:setAnchorPoint(ccp(0.5,0.5))
                    lbBg:setPosition(ccp(cellWidth/2,pHeight-13))
                    lbBg:setIsSallow(false)
                    lbBg:setTouchPriority(-(layerNum-1)*20-1)
                    cell:addChild(lbBg,1)
                    local statusStr=getlocal("serverwar_ongoing")..getlocal("serverwar_dot")
                    local statusLb=GetTTFLabel(statusStr,lbSize)
                    statusLb:setPosition(getCenterPoint(lbBg))
                    lbBg:addChild(statusLb,1)
                elseif status==0 then
                    local function cellClick(hd,fn,idx)
                    end
                    local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("mainChatBgTo.png",CCRect(10,10,5,5),cellClick)
                    lbBg:setContentSize(CCSizeMake(spWidth*2,40))
                    lbBg:ignoreAnchorPointForPosition(false)
                    lbBg:setAnchorPoint(ccp(0.5,0.5))
                    lbBg:setPosition(ccp(cellWidth/2,pHeight))
                    lbBg:setIsSallow(false)
                    lbBg:setTouchPriority(-(layerNum-1)*20-1)
                    cell:addChild(lbBg,1)
                    local statusStr=getlocal("serverwar_waiting")..getlocal("serverwar_dot")
                    local statusLb=GetTTFLabel(statusStr,lbSize)
                    statusLb:setPosition(getCenterPoint(lbBg))
                    lbBg:addChild(statusLb,1)
                end


                -- server1="啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
                -- server2="啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
                local wSpace=75
                local hSpace=0
                local serverLb1=GetTTFLabelWrap(server1,lbSize,CCSize(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
                serverLb1:setAnchorPoint(ccp(0.5,0))
                serverLb1:setPosition(ccp(wSpace,pHeight+hSpace))
                cell:addChild(serverLb1,1)

                local serverLb2=GetTTFLabelWrap(server2,lbSize,CCSize(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
                serverLb2:setAnchorPoint(ccp(0.5,0))
                serverLb2:setPosition(ccp(cellWidth-wSpace,pHeight+hSpace))
                cell:addChild(serverLb2,1)

                local nameLb1=GetTTFLabel(name1,lbSize)
                nameLb1:setAnchorPoint(ccp(0.5,1))
                nameLb1:setPosition(ccp(wSpace,pHeight-hSpace))
                cell:addChild(nameLb1,1)

                local nameLb2=GetTTFLabel(name2,lbSize)
                nameLb2:setAnchorPoint(ccp(0.5,1))
                nameLb2:setPosition(ccp(cellWidth-wSpace,pHeight-hSpace))
                cell:addChild(nameLb2,1)

                local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
                lineSp2:setAnchorPoint(ccp(0.5,0.5))
                lineSp2:setScaleX(cellWidth/lineSp2:getContentSize().width)
                lineSp2:setPosition(ccp(cellWidth/2,cellHeight-155))
                cell:addChild(lineSp2,1)



                local lbHeight=60
                local hLbSpace=25
                local sendFlowerLb=GetTTFLabel(getlocal("serverwar_send_flower"),lbSize)
                sendFlowerLb:setAnchorPoint(ccp(0,0.5))
                sendFlowerLb:setPosition(ccp(10,lbHeight+hLbSpace))
                cell:addChild(sendFlowerLb,1)
                local flowerNumLb=GetTTFLabel(flowerNum,lbSize)
                flowerNumLb:setAnchorPoint(ccp(0,0.5))
                flowerNumLb:setPosition(ccp(sendFlowerLb:getContentSize().width+8,lbHeight+hLbSpace))
                cell:addChild(flowerNumLb,1)
                flowerNumLb:setColor(G_ColorGreen)

                local sendToLb=GetTTFLabel(getlocal("serverwar_send_to"),lbSize)
                sendToLb:setAnchorPoint(ccp(0,0.5))
                sendToLb:setPosition(ccp(10,lbHeight))
                cell:addChild(sendToLb,1)
                local targetLb=GetTTFLabel(target,lbSize)
                targetLb:setAnchorPoint(ccp(0,0.5))
                targetLb:setPosition(ccp(sendToLb:getContentSize().width+8,lbHeight))
                cell:addChild(targetLb,1)
                targetLb:setColor(G_ColorGreen)

                local getPointLb=GetTTFLabel(getlocal("serverwar_get_point"),lbSize)
                getPointLb:setAnchorPoint(ccp(0,0.5))
                getPointLb:setPosition(ccp(10,lbHeight-hLbSpace))
                cell:addChild(getPointLb,1)
                local pointStr=""
                if status~=2 then
                    pointStr=getlocal("waiting")
                elseif isWin==true then
                    pointStr=getlocal("fight_content_result_win").."+"..point
                else
                    pointStr=getlocal("fight_content_result_defeat").."+"..point
                end
                local pointLb=GetTTFLabel(pointStr,lbSize)
                pointLb:setAnchorPoint(ccp(0,0.5))
                pointLb:setPosition(ccp(getPointLb:getContentSize().width+8,lbHeight-hLbSpace))
                cell:addChild(pointLb,1)
                pointLb:setColor(G_ColorGreen)


                if isReward==true then
                    local hadRewardLable = GetTTFLabelWrap(getlocal("activity_hadReward"),25,CCSize(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                    hadRewardLable:setAnchorPoint(ccp(0.5,0.5))
                    hadRewardLable:setPosition(ccp(cellWidth-75,lbHeight))
                    cell:addChild(hadRewardLable,1)
                    hadRewardLable:setColor(G_ColorGreen)
                elseif canReward==true then
                    local function rewardHandler()
                        if self and self.refreshData and self.refreshData.tableView and self.refreshData.tableView:getScrollEnable()==true and self.refreshData.tableView:getIsScrolled()==false then
                            if G_checkClickEnable()==false then
                                do
                                    return
                                end
                            else
                                base.setWaitTime=G_getCurDeviceMillTime()
                            end
                            PlayEffect(audioCfg.mouseClick)

                            local function callback1(fn,data)
                                local ret,sData=base:checkServerData(data)
                                if ret==true then
                                    serverWarPersonalVoApi:betReward(roundID,point)
                                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwar_reward_point",{point}),30)
                                    if rewardHandler then
                                        rewardHandler()
                                    end

                                    if self and self.refreshData and self.refreshData.tableView then
                                        self.refreshData.timeTb=nil
                                        self.refreshData.label=nil
                                        self.refreshData.timeTb={}
                                        self.refreshData.label={}
                                        local recordPoint = self.refreshData.tableView:getRecordPoint()
                                        self.refreshData.tableView:reloadData()
                                        self.refreshData.tableView:recoverToRecordPoint(recordPoint)
                                    end
                                end
                            end
                            local matchId=serverWarPersonalVoApi:getServerWarId()
                            local detailId=serverWarPersonalVoApi:getConnectId(matchId,roundID,groupID,battleID)
                            socketHelper:crossGetbetreward(matchId,detailId,callback1)
                        end
                    end
                    local rewardItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rewardHandler,2,getlocal("activity_continueRecharge_reward"),25)
                    rewardItem:setScale(0.8)
                    local rewardMenu=CCMenu:createWithItem(rewardItem)
                    rewardMenu:setPosition(ccp(cellWidth-75,lbHeight))
                    rewardMenu:setTouchPriority(-(layerNum-1)*20-2)
                    cell:addChild(rewardMenu,1)
                end

                return cell
            elseif fn=="ccTouchBegan" then
                isMoved=false
                return true
            elseif fn=="ccTouchMoved" then
                isMoved=true
            elseif fn=="ccTouchEnded"  then

            end
        end
        local cellWidth=self.bgLayer:getContentSize().width-40
        local hd= LuaEventHandler:createHandler(tvCallBack)
        self.refreshData.tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,self.bgLayer:getContentSize().height-180),nil)
        self.refreshData.tableView:setTableViewTouchPriority(-(layerNum-1)*20-3)
        self.refreshData.tableView:setPosition(ccp(20,100))
        self.bgLayer:addChild(self.refreshData.tableView,2)
        self.refreshData.tableView:setMaxDisToBottomOrTop(120)

        self:addForbidSp(self.bgLayer,size,layerNum)
    end

    if serverWarPersonalVoApi:checkStatus()<30 then
        --去献花
        local function sendFlowerHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            if callback then
                if callback()==true then
                    self:close()
                end
            else
                self:close()
            end
        end
        local sendFlowerItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sendFlowerHandler,2,getlocal("serverwar_go_send_flower"),25)
        local sendFlowerMenu=CCMenu:createWithItem(sendFlowerItem);
        sendFlowerMenu:setPosition(ccp(dialogBg:getContentSize().width/2,60))
        sendFlowerMenu:setTouchPriority(-(layerNum-1)*20-4)
        dialogBg:addChild(sendFlowerMenu)
        self.refreshData.sendFlowerMenu=sendFlowerMenu
    end


    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

function smallDialog:initUrgentTaskDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,leftBtnStr,rightBtnStr,leftCallBack,rightCallBack,isShowClose,item)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()

    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog()

    end

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    if isShowClose==true then
        local function close()
            PlayEffect(audioCfg.mouseClick)
            return self:close()
        end
        local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
        closeBtnItem:setPosition(ccp(0,0))
        closeBtnItem:setAnchorPoint(CCPointMake(0,0))

        self.closeBtn = CCMenu:createWithItem(closeBtnItem)
        self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
        self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
        self.bgLayer:addChild(self.closeBtn,2)
    end

    if title then
        local titleLb=GetTTFLabel(title,40)
        titleLb:setAnchorPoint(ccp(0.5,0.5))
        titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
        dialogBg:addChild(titleLb)
    end

    if item then
        local pic=item.pic
        local icon = CCSprite:createWithSpriteFrameName(pic)
        icon:setAnchorPoint(ccp(0.5,0.5))
        icon:setPosition(ccp(75,self.bgSize.height/2+20))
        self.bgLayer:addChild(icon,1)

        -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        -- local nameLable = GetTTFLabelWrap(str,25,CCSize(self.bgSize.width-180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        local nameLable = GetTTFLabelWrap(getlocal(item.name),25,CCSize(self.bgSize.width-150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        nameLable:setAnchorPoint(ccp(0.5,0.5))
        nameLable:setPosition(ccp((self.bgSize.width-150)/2+130,self.bgSize.height-120))
        self.bgLayer:addChild(nameLable,1)
        nameLable:setColor(G_ColorGreen)

        -- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        -- local descLable = GetTTFLabelWrap(str,25,CCSize(self.bgSize.width-180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        local descLable = GetTTFLabelWrap(getlocal(item.desc),25,CCSize(self.bgSize.width-150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        descLable:setAnchorPoint(ccp(0.5,0.5))
        descLable:setPosition(ccp((self.bgSize.width-150)/2+133,180))
        self.bgLayer:addChild(descLable,1)
    end

    --取消
    local function rightHandler()
         PlayEffect(audioCfg.mouseClick)
         if rightCallBack~=nil then
            rightCallBack()
         end
         self:close()
    end
    local cancleItem
    if rightBtnStr and rightBtnStr~="" then
        cancleItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rightHandler,2,rightBtnStr,25)
    else
        cancleItem=GetButtonItem("BtnGraySmall.png","BtnGraySmall_Down.png","BtnGraySmall_Down.png",rightHandler,2,getlocal("cancel"),25)
    end
    -- local cancleItem=GetButtonItem("BtnGraySmall.png","BtnGraySmall_Down.png","BtnGraySmall_Down.png",rightHandler,2,rightStr,25)
    local cancleMenu=CCMenu:createWithItem(cancleItem);
    cancleMenu:setPosition(ccp(size.width-120,60))
    cancleMenu:setTouchPriority(-(layerNum-1)*20-2);
    dialogBg:addChild(cancleMenu)
    --确定
    local function leftHandler()
        PlayEffect(audioCfg.mouseClick)
        if leftCallBack then
            leftCallBack()
        end
        self:close()
    end
    local leftStr=getlocal("ok")
    if leftBtnStr and leftBtnStr~="" then
        leftStr=leftBtnStr
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",leftHandler,2,leftStr,25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(120,60))
    sureMenu:setTouchPriority(-(layerNum-1)*20-2);
    dialogBg:addChild(sureMenu)

    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end



--关卡科技信息面板
function smallDialog:showTechInfoDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,cid)
      local sd=smallDialog:new()
      local dialog=sd:initTechInfoDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,cid)
      return sd
end
function smallDialog:initTechInfoDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,cid)
    self.isTouch=true
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg

    local challengeTechCfg=checkPointVoApi:getChallengeTechCfg()
    local id=(tonumber(cid) or tonumber(RemoveFirstChar(cid)))
    local cfg=challengeTechCfg[cid]

    local pic=cfg.icon
    local valueTab=cfg.value
    local isEffect,level=checkPointVoApi:getTechIsEffect(id)
    local isRewardTb=checkPointVoApi:getTechEffectTab(id)

    local lbSize=18
    local lbHeight=0
    local tempLbHeight=0
    local wSpace=20+30
    local hSpace=5
    local heiSpace=160

    for k,v in pairs(valueTab) do
        local cRewardCfg,star=checkPointVoApi:getCRewardCfgByTech(id,k)
        if cRewardCfg and cRewardCfg.sid then
            local nameStr=getlocal(cfg.name,{k})
            -- nameStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
            local nameLb=GetTTFLabelWrap(nameStr,22,CCSize(size.width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

            local effectStr=""
            local color
            local isReward=1
            if isReward==1 then
                if k>1 then
                    for i=1,k do
                        local isReward1=0
                        if isReward1==0 then
                            effectStr=getlocal("not_effect")
                            color=G_ColorRed
                        end
                    end
                end
                if level==k then
                    effectStr=getlocal("into_effect")
                    color=G_ColorYellowPro
                end
            end
            -- effectStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
            local effectLb=GetTTFLabelWrap(effectStr,22,CCSize(150,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentTop)

            local tmpHeight
            if nameLb:getContentSize().height>effectLb:getContentSize().height then
                tmpHeight=nameLb:getContentSize().height
            else
                tmpHeight=effectLb:getContentSize().height
            end

            local percent=(tonumber(cfg.value[k])*100).."%%"
            local descStr=getlocal(cfg.description,{percent})
            -- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
            -- descStr=str
            -- local desc1=GetTTFLabelWrap(str,lbSize,CCSize(size.width-wSpace-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            local desc1=GetTTFLabelWrap(getlocal("effect"),lbSize,CCSize(size.width-wSpace-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            local desc2=GetTTFLabelWrap(descStr,lbSize,CCSize(size.width-wSpace-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)


            local getConditionsStr=""
            local desc3=GetTTFLabelWrap(getlocal("get_conditions"),lbSize,CCSize(size.width-wSpace-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            local cRewardCfg,star=checkPointVoApi:getCRewardCfgByTech(id,k)
            if cRewardCfg and cRewardCfg.sid then
                getConditionsStr=getlocal("challenge_tech_get_conditions",{cRewardCfg.sid,star})
            end
            local desc4=GetTTFLabelWrap(getConditionsStr,lbSize,CCSize(size.width-wSpace-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)

            local openConditionsStr=""
            local desc5
            local desc6
            if k>1 then
                desc5=GetTTFLabelWrap(getlocal("open_conditions"),lbSize,CCSize(size.width-wSpace-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                -- local cRewardCfg,star=checkPointVoApi:getCRewardCfgByTech(id,k)
                -- if cRewardCfg and cRewardCfg.sid then
                    openConditionsStr=getlocal("challenge_tech_open_conditions",{getlocal("sample_challenge_tech_name_"..id),k-1})
                -- end
                desc6=GetTTFLabelWrap(openConditionsStr,lbSize,CCSize(size.width-wSpace-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            end

            if desc5 and desc6 then
                tempLbHeight=tempLbHeight+tmpHeight+desc1:getContentSize().height+desc2:getContentSize().height+desc3:getContentSize().height+desc4:getContentSize().height+desc5:getContentSize().height+desc6:getContentSize().height+hSpace*7+10
            else
                tempLbHeight=tempLbHeight+tmpHeight+desc1:getContentSize().height+desc2:getContentSize().height+desc3:getContentSize().height+desc4:getContentSize().height+hSpace*5+10
            end
        end
    end

    size.height=tempLbHeight+heiSpace+50
    self.bgSize=size
    self.bgLayer:setContentSize(size)



    local spSize=100
    local iconSp = CCSprite:createWithSpriteFrameName(pic)
    local scale=spSize/iconSp:getContentSize().width
    iconSp:setAnchorPoint(ccp(0.5,0.5))
    iconSp:setPosition(ccp(spSize/2+20,size.height-spSize/2-40))
    self.bgLayer:addChild(iconSp,1)
    iconSp:setScale(scale)

    local titleStr=getlocal("sample_challenge_tech_name_"..id)
    -- titleStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local titleLb=GetTTFLabelWrap(titleStr,25,CCSize(size.width-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    titleLb:setAnchorPoint(ccp(0,1))
    titleLb:setPosition(ccp(120,size.height-40))
    self.bgLayer:addChild(titleLb,1)
    titleLb:setColor(G_ColorGreen)

    local levelStr
    local color
    if isEffect==true then
        levelStr=getlocal("current_level",{level})
        color=G_ColorWhite
    else
        levelStr=getlocal("not_open")
        color=G_ColorRed
    end
    -- levelStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local levelLb=GetTTFLabelWrap(levelStr,22,CCSize(size.width-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    levelLb:setAnchorPoint(ccp(0,0.5))
    levelLb:setPosition(ccp(120,size.height-120))
    self.bgLayer:addChild(levelLb,1)
    levelLb:setColor(color)

    local lineSP=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSP:setAnchorPoint(ccp(0.5,0.5))
    lineSP:setScaleX(size.width/lineSP:getContentSize().width)
    lineSP:setPosition(ccp(size.width/2,size.height-150))
    self.bgLayer:addChild(lineSP,1)


    for k,v in pairs(valueTab) do
        local cRewardCfg,star=checkPointVoApi:getCRewardCfgByTech(id,k)
        if cRewardCfg and cRewardCfg.sid then
            local lbPosY=size.height-heiSpace-lbHeight

            local nameStr=getlocal(cfg.name,{k})
            -- nameStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
            local nameLb=GetTTFLabelWrap(nameStr,22,CCSize(size.width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            nameLb:setAnchorPoint(ccp(0,1))
            nameLb:setPosition(ccp(wSpace-30,lbPosY))
            self.bgLayer:addChild(nameLb,1)

            local effectStr=""
            local color
            local isReward=0
            if isRewardTb and isRewardTb[k] then
                isReward=isRewardTb[k]
            end
            if isReward==1 then
                if k>1 then
                    for i=1,k do
                        local isReward1=0
                        if isRewardTb and isRewardTb[i] then
                            isReward1=isRewardTb[i]
                        end
                        if isReward1==0 then
                            effectStr=getlocal("not_effect")
                            color=G_ColorRed
                        end
                    end
                end
                if level==k then
                    effectStr=getlocal("into_effect")
                    color=G_ColorYellowPro
                end
            end
            -- effectStr="啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
            local effectLb=GetTTFLabelWrap(effectStr,22,CCSize(150,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentTop)
            effectLb:setAnchorPoint(ccp(1,1))
            effectLb:setPosition(ccp(size.width-30,lbPosY))
            self.bgLayer:addChild(effectLb,1)
            if color then
                effectLb:setColor(color)
            end

            local tmpHeight
            if nameLb:getContentSize().height>=effectLb:getContentSize().height then
                tmpHeight=nameLb:getContentSize().height
            else
                tmpHeight=effectLb:getContentSize().height
            end

            local percent=(tonumber(cfg.value[k])*100).."%%"
            local descStr=getlocal(cfg.description,{percent})
            -- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
            -- descStr=str
            -- local desc1=GetTTFLabelWrap(str,lbSize,CCSize(size.width-wSpace-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            local desc1=GetTTFLabelWrap(getlocal("effect"),lbSize,CCSize(size.width-wSpace-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            desc1:setAnchorPoint(ccp(0,1))
            desc1:setPosition(ccp(wSpace,lbPosY-tmpHeight-hSpace))
            self.bgLayer:addChild(desc1,1)
            local desc2=GetTTFLabelWrap(descStr,lbSize,CCSize(size.width-wSpace-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            desc2:setAnchorPoint(ccp(0,1))
            desc2:setPosition(ccp(wSpace+30,lbPosY-tmpHeight-desc1:getContentSize().height-hSpace*2))
            self.bgLayer:addChild(desc2,1)
            desc2:setColor(G_ColorYellowPro)


            local getConditionsStr=""
            local desc3=GetTTFLabelWrap(getlocal("get_conditions"),lbSize,CCSize(size.width-wSpace-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            desc3:setAnchorPoint(ccp(0,1))
            desc3:setPosition(ccp(wSpace,lbPosY-tmpHeight-desc1:getContentSize().height-desc2:getContentSize().height-hSpace*3))
            self.bgLayer:addChild(desc3,1)
            local cRewardCfg,star=checkPointVoApi:getCRewardCfgByTech(id,k)
            if cRewardCfg and cRewardCfg.sid then
                getConditionsStr=getlocal("challenge_tech_get_conditions",{cRewardCfg.sid,star})
            end
            local desc4=GetTTFLabelWrap(getConditionsStr,lbSize,CCSize(size.width-wSpace-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            desc4:setAnchorPoint(ccp(0,1))
            desc4:setPosition(ccp(wSpace+30,lbPosY-tmpHeight-desc1:getContentSize().height-desc2:getContentSize().height-desc3:getContentSize().height-hSpace*4))
            self.bgLayer:addChild(desc4,1)

            local checkPointVo=checkPointVoApi:getCheckPointVoBySid(cRewardCfg.sid)
            if checkPointVo.starNum and checkPointVo.starNum>=star then
                desc4:setColor(G_ColorYellowPro)
            else
                desc4:setColor(G_ColorRed)
            end

            local openConditionsStr=""
            local desc5
            local desc6
            if k>1 then
                desc5=GetTTFLabelWrap(getlocal("open_conditions"),lbSize,CCSize(size.width-wSpace-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                desc5:setAnchorPoint(ccp(0,1))
                desc5:setPosition(ccp(wSpace,lbPosY-tmpHeight-desc1:getContentSize().height-desc2:getContentSize().height-desc3:getContentSize().height-desc4:getContentSize().height-hSpace*5))
                self.bgLayer:addChild(desc5,1)
                -- local cRewardCfg,star=checkPointVoApi:getCRewardCfgByTech(id,k)
                -- if cRewardCfg and cRewardCfg.sid then
                    openConditionsStr=getlocal("challenge_tech_open_conditions",{getlocal("sample_challenge_tech_name_"..id),k-1})
                -- end
                desc6=GetTTFLabelWrap(openConditionsStr,lbSize,CCSize(size.width-wSpace-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                desc6:setAnchorPoint(ccp(0,1))
                desc6:setPosition(ccp(wSpace+30,lbPosY-tmpHeight-desc1:getContentSize().height-desc2:getContentSize().height-desc3:getContentSize().height-desc4:getContentSize().height-desc5:getContentSize().height-hSpace*6))
                self.bgLayer:addChild(desc6,1)
                desc6:setColor(G_ColorYellowPro)
                for i=1,(k-1) do
                    local isReward2=0
                    if isRewardTb and isRewardTb[i] then
                        isReward2=isRewardTb[i]
                    end
                    if isReward2==0 then
                        desc6:setColor(G_ColorRed)
                    end
                end
            end

            local lineSP=CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSP:setAnchorPoint(ccp(0.5,0.5))
            lineSP:setScaleX(size.width/lineSP:getContentSize().width)
            if desc5 and desc6 then
                lineSP:setPosition(ccp(size.width/2,lbPosY-tmpHeight-desc1:getContentSize().height-desc2:getContentSize().height-desc3:getContentSize().height-desc4:getContentSize().height-desc5:getContentSize().height-desc6:getContentSize().height-hSpace*7-5))
            else
                lineSP:setPosition(ccp(size.width/2,lbPosY-tmpHeight-desc1:getContentSize().height-desc2:getContentSize().height-desc3:getContentSize().height-desc4:getContentSize().height-hSpace*5-5))
            end
            self.bgLayer:addChild(lineSP,1)

            if desc5 and desc6 then
                lbHeight=lbHeight+tmpHeight+desc1:getContentSize().height+desc2:getContentSize().height+desc3:getContentSize().height+desc4:getContentSize().height+desc5:getContentSize().height+desc6:getContentSize().height+hSpace*7+10
            else
                lbHeight=lbHeight+tmpHeight+desc1:getContentSize().height+desc2:getContentSize().height+desc3:getContentSize().height+desc4:getContentSize().height+hSpace*5+10
            end
        end
    end

    self:show()

    local function touchDialog()

    end

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function touchLuaSpr()
        if self.isTouch~=nil then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

function smallDialog:initJoinAllianceDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,isShowReward,chatDialog)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()

    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog()

    end

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)

    if title then
        local titleLb=GetTTFLabel(title,40)
        titleLb:setAnchorPoint(ccp(0.5,0.5))
        titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
        dialogBg:addChild(titleLb)
    end

    local capInSet = CCRect(20, 20, 10, 10)
    local function touch(hd,fn,idx)
    end
    local headBg=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",capInSet,touch)
    headBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,120))
    headBg:ignoreAnchorPointForPosition(false)
    headBg:setAnchorPoint(ccp(0.5,1))
    headBg:setIsSallow(false)
    headBg:setTouchPriority(-(layerNum-1)*20-1)
    headBg:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-90))
    self.bgLayer:addChild(headBg,1)

    local inRect=CCRect(168, 86, 10, 10)
    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",inRect,touch)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,self.bgSize.height-110-headBg:getContentSize().height-80))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(layerNum-1)*20-1)
    backSprie:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-90-headBg:getContentSize().height))
    self.bgLayer:addChild(backSprie,1)


    if isShowReward==true then
        local rewardTab=FormatItem(playerCfg.firstJoinAllianceCfg.reward) or {}
        local reward=rewardTab[1]
        if reward then
            local scale
            local rewardSp,scale=G_getItemIcon(reward,100,true,layerNum)
            rewardSp:setAnchorPoint(ccp(0.5,0.5))
            rewardSp:setPosition(ccp(70,headBg:getContentSize().height/2))
            headBg:addChild(rewardSp,1)
            G_addRectFlicker(rewardSp,1.4,1.4)
            rewardSp:setScale(0.9)
        end

        local descTv=G_LabelTableView(CCSize(280,headBg:getContentSize().height-10),getlocal("join_alliance_reward"),22,kCCTextAlignmentLeft)
        descTv:setTableViewTouchPriority(-(layerNum-1)*20-2)
        descTv:setPosition(ccp(130,5))
        headBg:addChild(descTv,2)
        descTv:setMaxDisToBottomOrTop(50)

        local function rewardHandler(tag,object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            local function rewardCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    base.joinReward=1
                    if self.menuItemAward then
                        self.menuItemAward:setEnabled(false)
                    end
                    if sData.data and sData.data.reward then
                        local reward=FormatItem(sData.data.reward)
                        for k,v in pairs(reward) do
                            G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),false,true)
                        end
                        G_showRewardTip(reward,true)
                    end
                    self:close()
                end
            end
            socketHelper:allianceOncereward(rewardCallback)
        end
        self.menuItemAward=GetButtonItem("TaskBtnGet.png","TaskBtnGet_Down.png","TaskBtnGet_Down.png",rewardHandler,nil,nil,0)
        local menuAward=CCMenu:createWithItem(self.menuItemAward)
        menuAward:setPosition(ccp(self.bgSize.width-100,headBg:getContentSize().height/2))
        menuAward:setTouchPriority(-(layerNum-1)*20-4)
        headBg:addChild(menuAward,1)
        if allianceVoApi:isHasAlliance() and base.joinReward==0 then
            self.menuItemAward:setEnabled(true)
        else
            self.menuItemAward:setEnabled(false)
        end
    else
        local allianceSp = CCSprite:createWithSpriteFrameName("gong_hui_building.png")
        allianceSp:setAnchorPoint(ccp(0.5,0.5))
        allianceSp:setPosition(ccp(75,headBg:getContentSize().height/2-5))
        headBg:addChild(allianceSp,1)
        allianceSp:setScale(0.4)

        local descTv=G_LabelTableView(CCSize(380,headBg:getContentSize().height-10),getlocal("join_alliance_desc"),22,kCCTextAlignmentLeft,G_ColorYellowPro)
        descTv:setTableViewTouchPriority(-(layerNum-1)*20-2)
        descTv:setPosition(ccp(150,5))
        headBg:addChild(descTv,2)
        descTv:setMaxDisToBottomOrTop(50)
    end

    if allianceVoApi:isHasAlliance() then
        backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,self.bgSize.height-110-headBg:getContentSize().height))
    else
        local function gotoAllianceHandler(tag,object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            self:close()
            if chatDialog then
                chatDialog:close()
            end
            -- if allianceVoApi:isHasAlliance()==false then
            --     require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialog"
            --     local td=allianceDialog:new(1,3)
            --     G_AllianceDialogTb[1]=td
            --     local tbArr={getlocal("alliance_list_scene_list"),getlocal("alliance_list_scene_create")}
            --     local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_list_scene_name"),true,3)
            --     sceneGame:addChild(dialog,3)
            --     if tag==1 then
            --         td:tabClick(1)
            --     end
            -- else
            --     allianceEventVoApi:clear()
            --     require "luascript/script/game/scene/gamedialog/allianceDialog/allianceExistDialog"
            --     local td=allianceExistDialog:new(1,3)
            --     G_AllianceDialogTb[1]=td
            --     local tbArr={getlocal("alliance_info_title"),getlocal("alliance_function"),getlocal("alliance_list_scene_list")}
            --     local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_list_scene_name"),true,3)
            --     sceneGame:addChild(dialog,3)
            -- end
            allianceVoApi:showAllianceDialog(layerNum+1)
        end
        local createItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",gotoAllianceHandler,1,getlocal("create_alliance"),25,101)
        local createdMenu=CCMenu:createWithItem(createItem)
        createdMenu:setPosition(ccp(size.width/2-120,50))
        createdMenu:setTouchPriority(-(layerNum-1)*20-4)
        dialogBg:addChild(createdMenu)

        local joinItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",gotoAllianceHandler,2,getlocal("join_alliance"),25,101)
        local joinMenu=CCMenu:createWithItem(joinItem)
        joinMenu:setPosition(ccp(size.width/2+120,50))
        joinMenu:setTouchPriority(-(layerNum-1)*20-4)
        dialogBg:addChild(joinMenu)
    end


    local msgTab={
        {title="join_alliance_title_1",desc="join_alliance_desc_1",height=0},
        {title="join_alliance_title_2",desc="join_alliance_desc_2",height=0},
        {title="join_alliance_title_3",desc="join_alliance_desc_3",height=0},
        {title="join_alliance_title_4",desc="join_alliance_desc_4",height=0},
        {title="join_alliance_title_5",desc="join_alliance_desc_5",height=0},
    }
    local isMoved=false
    local cellWidth=backSprie:getContentSize().width-10
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return SizeOfTable(msgTab)
        elseif fn=="tableCellSizeForIndex" then
            local msg=msgTab[idx+1]
            local title=getlocal(msg.title) or ""
            local desc=getlocal(msg.desc) or ""
            if msg.height==0 then
                local starSize=36
                local titleLb=GetTTFLabelWrap(title,25,CCSize(cellWidth-starSize-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                local descLb=GetTTFLabelWrap(desc,22,CCSize(cellWidth-starSize-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                msg.height=titleLb:getContentSize().height+descLb:getContentSize().height+50
            end
            local tmpSize=CCSizeMake(cellWidth,msg.height)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local msg=msgTab[idx+1] or {}
            local title=getlocal(msg.title) or ""
            local desc=getlocal(msg.desc) or ""
            local cellHeight=msg.height or 0

            local starSize=36
            local titleLb=GetTTFLabelWrap(title,25,CCSize(cellWidth-starSize-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            local descLb=GetTTFLabelWrap(desc,22,CCSize(cellWidth-starSize-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            if msg.height==0 then
                msg.height=titleLb:getContentSize().height+descLb:getContentSize().height+50
                cellHeight=msg.height
            end

            local starSprie = CCSprite:createWithSpriteFrameName("StarIcon.png")
            starSprie:setAnchorPoint(ccp(0.5,0.5))
            starSprie:setPosition(ccp(starSize/2+5,cellHeight-starSize/2-5))
            -- starSprie:setScale(starSize/starSprie:getContentSize().width)
            cell:addChild(starSprie,1)

            titleLb:setAnchorPoint(ccp(0,1))
            titleLb:setPosition(ccp(starSize+15,cellHeight-10))
            cell:addChild(titleLb,1)
            titleLb:setColor(G_ColorGreen)

            descLb:setAnchorPoint(ccp(0,1))
            descLb:setPosition(ccp(starSize+15,cellHeight-titleLb:getContentSize().height-20))
            cell:addChild(descLb,1)

            local lineSP=CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSP:setAnchorPoint(ccp(0.5,0.5))
            lineSP:setScaleX(cellWidth/lineSP:getContentSize().width)
            -- lineSP:setScaleY(1.2)
            lineSP:setPosition(ccp(cellWidth/2,5))
            cell:addChild(lineSP,2)

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local descTableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,backSprie:getContentSize().height-10),nil)
    descTableView:setTableViewTouchPriority(-(layerNum-1)*20-2)
    descTableView:setPosition(ccp(5,5))
    backSprie:addChild(descTableView,2)
    descTableView:setMaxDisToBottomOrTop(120)


    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end


function smallDialog:initBindingSureDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callBackHandler,title)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()

    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog()

    end

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)

    if title then
        local titleLb=GetTTFLabel(title,40)
        titleLb:setAnchorPoint(ccp(0.5,0.5))
        titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
        dialogBg:addChild(titleLb)
    end

    local function bindingAccountHandler(tag,object)
         PlayEffect(audioCfg.mouseClick)
         if callBackHandler~=nil then
            callBackHandler(tag,object)
         end
         self:close()
    end
    --facebook账号绑定按钮
    local facebookItem=GetButtonItem("BtnFacebook.png","BtnFacebookDown.png","BtnFacebookDown.png",bindingAccountHandler,1,getlocal("facebook_account"),25,101)
    local facebookMenu=CCMenu:createWithItem(facebookItem);
    facebookMenu:setPosition(ccp(size.width/2,190))
    facebookMenu:setTouchPriority(-(layerNum-1)*20-2);
    dialogBg:addChild(facebookMenu)

    local textLable = tolua.cast(facebookItem:getChildByTag(101),"CCLabelTTF")
    textLable:setPosition(textLable:getPositionX()+20,textLable:getPositionY())

    --自定义账号绑定按钮
    local customItem=GetButtonItem("LoadingBtn.png","LoadingBtn_Down.png","LoadingBtn_Down.png",bindingAccountHandler,2,getlocal("custom_account"),25,101)
    local customMenu=CCMenu:createWithItem(customItem);
    customMenu:setPosition(ccp(size.width/2,90))
    customMenu:setTouchPriority(-(layerNum-1)*20-2);
    dialogBg:addChild(customMenu)

    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

function smallDialog:showRewardItemDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,award,title,desc,callBack)
      local sd=smallDialog:new()
      sd:initRewardItemDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,award,title,desc,callBack)
      return sd
end
function smallDialog:initRewardItemDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,award,title,desc,callBack)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    self.isTouch=nil
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()

    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)

    self.dialogLayer:addChild(self.bgLayer,1);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function closeHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local closeBtnItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",closeHandler,nil,getlocal("confirm"),30)
    closeBtnItem:setPosition(0,0)
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(size.width/2-closeBtnItem:getContentSize().width/2,20))
    self.bgLayer:addChild(self.closeBtn,2)


    local bgHeight=0
    if (award and SizeOfTable(award)>0) then
        height=120
        bgHeight=bgHeight+height
        if award then
            local awardNum=SizeOfTable(award)

            local awardHeight=(math.ceil(awardNum/2)+1)*120+20
            for k,v in pairs(award) do
                if v and v.name and v.num then
                    local awidth = 30+((k-1)%2)*280
                    local aheight = awardHeight-(math.floor((k+1)/2))*120+80-50
                    local iconSize=100
                    local icon,scale=G_getItemIcon(v,iconSize,true,layerNum)
                    if icon then
                        icon:setAnchorPoint(ccp(0,0))
                        icon:setPosition(ccp(awidth,aheight+bgHeight-height))
                        icon:setTouchPriority(-(layerNum-1)*20-3)
                        self.bgLayer:addChild(icon,1)
                        icon:setScale(scale)
                    end

                    -- local nameLable = GetTTFLabel(v.name,25)
                    local nameLable = GetTTFLabelWrap(v.name,25,CCSize(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    nameLable:setAnchorPoint(ccp(0,0.5))
                    nameLable:setPosition(ccp(awidth+iconSize+5,aheight+100+bgHeight-height-15))
                    self.bgLayer:addChild(nameLable,1)

                    local numLable = GetTTFLabel(v.num,25)
                    numLable:setAnchorPoint(ccp(0,0))
                    numLable:setPosition(ccp(awidth+iconSize+5,aheight+5+bgHeight-height))
                    self.bgLayer:addChild(numLable,1)
                end
            end
            bgHeight=bgHeight+awardHeight
        else
            bgHeight=bgHeight+120+40+20
        end

        -- bgHeight=bgHeight+60

    end

    local fontSize = 35
    if G_getCurChoseLanguage()~="cn" then
        fontSize = 30
    end

    -- 礼包名称
    local titleStr = getlocal("Exchange_reward")
    if title and title~="" then
        titleStr = title
    end
    local titleLb=GetTTFLabelWrap(titleStr,fontSize,CCSizeMake(size.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:addChild(titleLb,1)

    fontSize = 25
    if G_getCurChoseLanguage()~="cn" then
        fontSize = 22
    end

    -- 礼包描述
    local descStr = getlocal("code_reward_desc")
    if desc and desc~="" then
        descStr = desc
    end
    descLb = GetTTFLabelWrap(descStr,fontSize,CCSizeMake(size.width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    descLb:setAnchorPoint(ccp(0,1))

    self.bgLayer:addChild(descLb,1)

    bgHeight = bgHeight + descLb:getContentSize().height

    local bgSize=CCSizeMake(size.width,bgHeight)
    self.bgLayer:setContentSize(bgSize)

    titleLb:setPosition(ccp(size.width/2,bgHeight-45))
    descLb:setPosition(ccp(30,bgHeight-100))

    -- titleLb=GetTTFLabel(title,30)
    -- titleLb:setAnchorPoint(ccp(0.5,1))
    -- titleLb:setPosition(ccp(size.width/2,bgHeight-25))
    -- self.bgLayer:addChild(titleLb,1)

    local bgSize=CCSizeMake(size.width,bgHeight)
    --self.bgSize=bgSize
    self.bgLayer:setContentSize(bgSize)
    if self.isUseAmi then
        self:show()
    end

    local function touchLuaSpr()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchLuaSpr);
        touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
        local rect=CCSizeMake(640,G_VisibleSizeHeight)
        touchDialogBg:setContentSize(rect)
        touchDialogBg:setOpacity(0)
        touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
        self.bgLayer:addChild(touchDialogBg,1);

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    return self.dialogLayer
end

function smallDialog:initSearchEquipDialog(bgSrc,size,fullRect,inRect,title,content,istouch,isuseami,layerNum,callBackHandler,isSizeAmi,isOneByOne,isTip,isRoulette,isRefitTank,msgContent,isAddDesc,addDesc,isRebates,isJunshijiangtan,isVip,isXxjl,addDestr,addDestr2,opacity,canClick,isSpecial)
print(isAddDesc,addDesc)
    self.isTouch=istouch
    self.isUseAmi=isuseami
    self.isSizeAmi=isSizeAmi
    local function touchHander()

    end

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHander)
    if self.isSizeAmi==true then
        dialogBg:setOpacity(200)
    end
    if opacity then
      dialogBg:setOpacity(opacity)
    end

    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()

    if bgSrc == "rewardPanelBg1.png" then
        local lineSp1=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
        lineSp1:setAnchorPoint(ccp(0.5,1))
        lineSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height))
        self.bgLayer:addChild(lineSp1)
        local lineSp2=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
        lineSp2:setAnchorPoint(ccp(0.5,0))
        lineSp2:setPosition(ccp(self.bgLayer:getContentSize().width/2,lineSp2:getContentSize().height))
        self.bgLayer:addChild(lineSp2)
        lineSp2:setRotation(180)
    end


    local lbSize=20
    local pos1 = 0
    local pos2 = 20
    local pos3 = 25
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        lbSize =20
        pos1 =0
        pos2 =0
        pos3 =0
    end

    local titleLb=GetTTFLabelWrap(title,24,CCSizeMake(size.width-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(size.width/2,size.height-55-pos1))
    dialogBg:addChild(titleLb)

    if addDestr2 then
      titleLb:setPosition(ccp(size.width/2,size.height-40-pos1))
      local headTip=GetTTFLabelWrap(addDestr2,25,CCSizeMake(size.width-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
      headTip:setAnchorPoint(ccp(0.5,0.5))
      headTip:setPosition(ccp(size.width/2,size.height-70-pos1))
      dialogBg:addChild(headTip)
    end
    local cellWidth=490
    local cellHeight=120
    local isMoved=false

    print(isOneByOne,type(content),SizeOfTable(content))
    if isOneByOne==true and type(content)=="table" and SizeOfTable(content)>1 then
        self.message={}
    else
        self.message=content
    end

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return SizeOfTable(self.message)
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            if bgSrc == "rewardPanelBg1.png" then
                local upM_Line = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)--modifiersLine2
                upM_Line:setContentSize(CCSizeMake(cellWidth-10,upM_Line:getContentSize().height))
                upM_Line:setPosition(ccp(cellWidth*0.5,2))
                upM_Line:setAnchorPoint(ccp(0.5,0.5))
                cell:addChild(upM_Line,2)
            end
            local item=self.message[idx+1] or {}
            local award=item.award
            local point=item.point
            if award and award.name then
                local width=0
                local iconSize=100
                local icon
                if award.type and (award.type=="h" or award.type=="se") then
                    if canClick then
                      icon = G_getItemIcon(award,iconSize,true,layerNum,nil,self.tv,nil,nil,nil,nil,true)
                      icon:setTouchPriority(-(layerNum-1)*20-2)
                    else
                      icon = G_getItemIcon(award,iconSize,false,layerNum)
                    end
                elseif award.type and award.type=="e" then
                    if award.eType then
                        if award.eType=="a" then
                            icon = accessoryVoApi:getAccessoryIcon(award.key,80,iconSize)
                        elseif award.eType=="f" then
                            icon = accessoryVoApi:getFragmentIcon(award.key,80,iconSize)
                        elseif award.pic and award.pic~="" then
                            icon = CCSprite:createWithSpriteFrameName(award.pic)
                        end
                    end
                elseif award.type and award.type=="word" then
                   icon=CCSprite:createWithSpriteFrameName(award.pic)
                elseif award.equipId then
                    local eType=string.sub(award.equipId,1,1)
                    if eType=="a" then
                        icon = accessoryVoApi:getAccessoryIcon(award.equipId,80,iconSize)
                    elseif eType=="f" then
                        icon = accessoryVoApi:getFragmentIcon(award.equipId,80,iconSize)
                    elseif eType=="p" then
                        icon = CCSprite:createWithSpriteFrameName(accessoryCfg.propCfg[award.equipId].icon)
                    end
                elseif award.pic and award.pic~="" then
                    if award.key and award.key == "p677" then
                        icon = GetBgIcon(award.pic,nil,nil,80,100)
                    elseif award.type and award.type=="p" then
                        if canClick then
                          icon = G_getItemIcon(award,iconSize,true,layerNum,nil,self.tv)
                          icon:setTouchPriority(-(layerNum-1)*20-2)
                        else
                          icon = G_getItemIcon(award,iconSize,false,layerNum)
                        end

                    else
                        icon = CCSprite:createWithSpriteFrameName(award.pic)
                    end
                end

                local descStr=""
                if icon then
                    icon:setAnchorPoint(ccp(0.5,0.5))
                    local scale=iconSize/icon:getContentSize().width
                    icon:setScale(scale)
                    icon:setPosition(ccp(width+iconSize/2,cellHeight/2))

                    if isRefitTank==true and point==1 then
                        G_addRectFlicker(icon,1.4*(icon:getContentSize().width/iconSize),1.4*(icon:getContentSize().width/iconSize))
                    end
                    cell:addChild(icon,1)
                    local rewardLb
                    if msgContent and SizeOfTable(msgContent)>0 then
                        icon:setPosition(ccp(width+iconSize/2+30,cellHeight/2))

                        local showData=msgContent[idx+1]
                        local showStr
                        local color=G_ColorWhite
                        if type(showData)=="table" then
                            showStr=showData[1]
                            color=showData[2]
                        else
                            showStr=showData
                        end

                        -- if award.type=="h" and award.eType=="h" then
                        --     showStr=getlocal("congratulationsGet",{award.name})
                        -- else
                        --     showStr=getlocal("congratulationsGet",{award.name.." x"..award.num})
                        -- end
                        rewardLb=GetTTFLabelWrap(showStr,lbSize,CCSizeMake(cellWidth-120-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                        if color then
                            rewardLb:setColor(color)
                        end
                    elseif isTip==true then
                        rewardLb=GetTTFLabelWrap(getlocal("activity_equipSearch_desc_tip",{award.name,award.num,point}),lbSize,CCSizeMake(cellWidth-120-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                    elseif isVip==true then
                          rewardLb=GetTTFLabelWrap(getlocal("vip_tequanlibao_geshihua",{award.name,award.num}),lbSize,CCSizeMake(cellWidth-120-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                    elseif award.type=="p" and award.equipId then
                        local eType=string.sub(award.equipId,1,1)
                        if (eType=="a" or eType=="f") and award.equipId~="f0" then
                            if isRoulette==true then
                                descStr=getlocal("active_lottery_reward_tank",{award.name,"*"..award.num})
                            elseif isRefitTank==true then
                                descStr=getlocal("active_lottery_reward_tank",{award.name,"*"..award.num})
                            elseif isAddDesc==true then
                                descStr=getlocal("active_kuangnuzhishi_getreward",{award.name,"*"..award.num,addDesc,"*"..point})
                            else
                                descStr=getlocal("activity_equipSearch_reward_inbag",{award.name,award.num,point})
                            end
                            rewardLb=GetTTFLabelWrap(descStr,lbSize,CCSizeMake(cellWidth-120-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                        else
                            if isRoulette==true then
                                descStr=getlocal("active_lottery_reward_tank",{award.name,"*"..award.num})
                            elseif isRefitTank==true then
                                descStr=getlocal("activity_equipSearch_reward",{award.name,award.num,point})
                            elseif isAddDesc==true then
                                descStr=getlocal("active_kuangnuzhishi_getreward",{award.name,award.num,addDesc,"*"..point})
                            else
                                descStr=getlocal("activity_equipSearch_reward",{award.name,award.num,point})
                            end
                            rewardLb=GetTTFLabelWrap(descStr,lbSize,CCSizeMake(cellWidth-120-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                        end
                    else
                        if isRoulette==true then
                            descStr=getlocal("active_lottery_reward_tank",{award.name,"*"..award.num})
                        elseif isRefitTank==true then
                            descStr=getlocal("active_lottery_reward_tank",{award.name,"*"..award.num})
                        elseif isAddDesc==true then
                            descStr=getlocal("active_kuangnuzhishi_getreward",{award.name,"*"..award.num,addDesc,"*"..point})
                        elseif isRebates == true then
                            local vo = activityVoApi:getActivityVo("shengdankuanghuan")
                            local strLb ="activity_shengdankuanghuan_RebatesAllRewardTip"
                            if vo and acShengdankuanghuanVoApi:getVersion()~=nil and acShengdankuanghuanVoApi:getVersion() ==3 then
                              strLb="activity_munitionsSacles_RebatesAllRewardTip"
                            end
                            descStr=getlocal(strLb,{award.name,point,award.num})
                        elseif isJunshijiangtan == true then
                            descStr=getlocal("active_junshijiangtan_getreward",{award.name,award.num,award.point})
                        elseif isXxjl==true then
                            descStr=getlocal("activity_meteoriteLanding_reward",{award.name,award.num,point})
                        else
                            descStr=getlocal("activity_equipSearch_reward",{award.name,award.num,point})
                        end
                        rewardLb=GetTTFLabelWrap(descStr,lbSize,CCSizeMake(cellWidth-120-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                    end
                    rewardLb:setAnchorPoint(ccp(0,0.5))
                    rewardLb:setPosition(ccp(width+iconSize+10+30,cellHeight/2-pos2))
                    cell:addChild(rewardLb,1)

                    if addDestr then
                      local addStr = addDestr[idx+1]
                      if addStr then
                        rewardLb:setPosition(ccp(width+iconSize+10+30,cellHeight/2-pos2+20))

                        local addStrLb=GetTTFLabelWrap(addStr,lbSize,CCSizeMake(cellWidth-120-30,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                        addStrLb:setAnchorPoint(ccp(0,0.5))
                        addStrLb:setPosition(ccp(width+iconSize+10+30,cellHeight/2-pos2-20))
                        cell:addChild(addStrLb,1)
                        addStrLb:setColor(G_ColorYellowPro)
                      end
                    end

                end
                if isSpecial and icon then
                    local specShowTb = {y=3,b=1,p=2,g=4}
                    G_addRectFlicker2(icon,1.1,1.1,specShowTb[isSpecial[idx+1]],isSpecial[idx+1],nil,55)
                end
            end


            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)

    local isEnd=true
    if isTip==true or isVip==true then
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,520),nil)
        if canClick then
          self.tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
        else
          self.tv:setTableViewTouchPriority(-(layerNum-1)*20-2)
        end
        self.tv:setPosition(ccp(60/2,45))
        self.bgLayer:addChild(self.tv,2)
        self.tv:setMaxDisToBottomOrTop(120)
    else
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,460),nil)
        if canClick then
          self.tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
        else
          self.tv:setTableViewTouchPriority(-(layerNum-1)*20-2)
        end
        self.tv:setPosition(ccp(60/2,105))
        self.bgLayer:addChild(self.tv,2)
        self.tv:setMaxDisToBottomOrTop(120)
        --确定
        local function confirmHandler(tag,object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            if isEnd==true then
                if callBackHandler~=nil then
                    callBackHandler()
                end
                self:close()
            elseif isEnd==false then
                if self and self.bgLayer and self.tv then
                    self.bgLayer:stopAllActions()
                    self.message=content
                    local recordPoint=self.tv:getRecordPoint()
                    self.tv:reloadData()
                    recordPoint.y=0
                    self.tv:recoverToRecordPoint(recordPoint)
                    tolua.cast(self.sureBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("ok"))
                end
                isEnd=true
            end
        end

        self.sureBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",confirmHandler,1,getlocal("ok"),24,11)
        local btnLb = self.sureBtn:getChildByTag(11)
        if btnLb then
          btnLb = tolua.cast(self.sureBtn:getChildByTag(11),"CCLabelTTF")
          btnLb:setFontName("Helvetica-bold")
        end
        if bgSrc == "rewardPanelBg1.png" then
          self.sureBtn:setScale(0.9)
        end
        local sureMenu=CCMenu:createWithItem(self.sureBtn);
        sureMenu:setPosition(ccp(size.width/2,60-pos3))
        sureMenu:setTouchPriority(-(layerNum-1)*20-4);
        dialogBg:addChild(sureMenu)
        if SizeOfTable(content)>1 then
            isEnd=false
            tolua.cast(self.sureBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("gemCompleted"))
        end
        if not isOneByOne then
          isEnd=true
          tolua.cast(self.sureBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("ok"))
        end
    end

    if canClick then
      self.refreshData.tableView=self.tv
      self:addForbidSp(self.bgLayer,size,layerNum)
    end

    local function touchLuaSpr()
        if self.isTouch==true and isMoved==false then
            if self.bgLayer~=nil then
                PlayEffect(audioCfg.mouseClick)
                self:close()
            end
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(220)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
    if isOneByOne==true and type(content)=="table" and SizeOfTable(content)>1 then
        local acArr=CCArray:create()
        for k,v in pairs(content) do
            local function showNextMsg()
                if self and self.tv and v then
                    local award=v.award
                    local point=v.point
                    if award and award.name then
                        table.insert(self.message,v)
                    end

                    self.tv:insertCellAtIndex(k-1)

                    if k==SizeOfTable(content) then
                        tolua.cast(self.sureBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("ok"))
                        isEnd=true
                    end

                    local index=v.index
                    local pBen
                    if award.pBen then
                        pBen = award.pBen
                    end

                    if callBackHandler~=nil and isRefitTank==nil and isAddDesc==nil then
                        callBackHandler(index,pBen)
                    end
                end
            end
            local callFunc1=CCCallFuncN:create(showNextMsg)
            local delay=CCDelayTime:create(0.5)

            acArr:addObject(delay)
            acArr:addObject(callFunc1)

        end
        local seq=CCSequence:create(acArr)
        self.bgLayer:runAction(seq)

    end
    if bgSrc == "rewardPanelBg1.png" and self.sureBtn == nil then
        local clickLbPosy=-80
        local tmpLb=GetTTFLabel(getlocal("click_screen_continue"),25)
        local clickLb=GetTTFLabelWrap(getlocal("click_screen_continue"),25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        clickLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,clickLbPosy))
        self.bgLayer:addChild(clickLb)
        local arrowPosx1,arrowPosx2
        local realWidth,maxWidth=tmpLb:getContentSize().width,clickLb:getContentSize().width
        if realWidth>maxWidth then
            arrowPosx1=self.bgLayer:getContentSize().width/2-maxWidth/2
            arrowPosx2=self.bgLayer:getContentSize().width/2+maxWidth/2
        else
            arrowPosx1=self.bgLayer:getContentSize().width/2-realWidth/2
            arrowPosx2=self.bgLayer:getContentSize().width/2+realWidth/2
        end
        local smallArrowSp1=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
        smallArrowSp1:setPosition(ccp(arrowPosx1-15,clickLbPosy))
        self.bgLayer:addChild(smallArrowSp1)
        local smallArrowSp2=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
        smallArrowSp2:setPosition(ccp(arrowPosx1-25,clickLbPosy))
        self.bgLayer:addChild(smallArrowSp2)
        smallArrowSp2:setOpacity(100)
        local smallArrowSp3=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
        smallArrowSp3:setPosition(ccp(arrowPosx2+15,clickLbPosy))
        self.bgLayer:addChild(smallArrowSp3)
        smallArrowSp3:setRotation(180)
        local smallArrowSp4=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
        smallArrowSp4:setPosition(ccp(arrowPosx2+25,clickLbPosy))
        self.bgLayer:addChild(smallArrowSp4)
        smallArrowSp4:setOpacity(100)
        smallArrowSp4:setRotation(180)

        local space=20
        smallArrowSp1:runAction(G_actionArrow(1,space))
        smallArrowSp2:runAction(G_actionArrow(1,space))
        smallArrowSp3:runAction(G_actionArrow(-1,space))
        smallArrowSp4:runAction(G_actionArrow(-1,space))
    end
end


function smallDialog:initSearchDialog(bgSrc,size,fullRect,inRect,title,content,istouch,isuseami,layerNum,callBackHandler,isSizeAmi,isOneByOne,isTip,isRoulette,clickCallBack)
    self.isTouch=istouch
    self.isUseAmi=isuseami
    self.isSizeAmi=isSizeAmi
    flickers = {}
    local function removeAllFlickers()
        for k,v in pairs(flickers) do
            if v[1] ~= nil and v[2] ~= nil then
                v[1]:removeFromParentAndCleanup(true)
            end
        end
        flickers = nil
    end

    local function touchHander()

    end

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHander)
    if self.isSizeAmi==true then
        dialogBg:setOpacity(150)
    end
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()

    local titleLb=GetTTFLabelWrap(title,25,CCSizeMake(size.width-50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(size.width/2,size.height-55))
    dialogBg:addChild(titleLb)

    local lbSize=22
    local cellWidth=490
    local cellHeight=120
    local isMoved=false

    if isOneByOne==true and type(content)=="table" and SizeOfTable(content)>1 then
        self.message={}
    else
        self.message=content
    end

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return SizeOfTable(self.message)
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local con = self.message[idx+1]
            local pic = con.icon
            local item = con.item
            local iconSize = 100
            local icon
            if item then
                icon = G_getItemIcon(item,100)
            else
                icon = CCSprite:createWithSpriteFrameName(pic)
            end
            icon:setAnchorPoint(ccp(0.5,0.5))
            local scale=iconSize/icon:getContentSize().width
            icon:setScale(scale)
            icon:setPosition(ccp(20+iconSize/2,cellHeight/2))
            cell:addChild(icon,1)
            local addFlicker = con.addFlicker
            if addFlicker == true then
                local sp = G_addRectFlicker(icon,1.4,1.4)
                table.insert(flickers, {sp=sp,icon=icon})
            end

            local tip=con.msg or ""
            local rewardLb=GetTTFLabelWrap(tip,lbSize,CCSizeMake(cellWidth-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            rewardLb:setAnchorPoint(ccp(0,0.5))
            rewardLb:setPosition(ccp(40 + iconSize,cellHeight/2))
            cell:addChild(rewardLb,2)

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)

    local isEnd=true
    if isTip==true then
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,520),nil)
        self.tv:setTableViewTouchPriority(-(layerNum-1)*20-2)
        self.tv:setPosition(ccp(60/2,45))
        self.bgLayer:addChild(self.tv,2)
        self.tv:setMaxDisToBottomOrTop(120)
    else
        self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,460),nil)
        self.tv:setTableViewTouchPriority(-(layerNum-1)*20-2)
        self.tv:setPosition(ccp(60/2,105))
        self.bgLayer:addChild(self.tv,2)
        self.tv:setMaxDisToBottomOrTop(120)
        --确定
        local function confirmHandler(tag,object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            if isEnd==true then
                if callBackHandler~=nil then
                    callBackHandler()
                end
                if clickBackHandler~=nil then
                    clickBackHandler()
                end
                removeAllFlickers()
                self:close()
            elseif isEnd==false then
                if self and self.bgLayer and self.tv then
                    self.bgLayer:stopAllActions()
                    self.message=content
                    local recordPoint=self.tv:getRecordPoint()
                    self.tv:reloadData()
                    recordPoint.y=0
                    self.tv:recoverToRecordPoint(recordPoint)
                    tolua.cast(self.sureBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("ok"))
                end
                isEnd=true
            end
        end
        self.sureBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",confirmHandler,1,getlocal("ok"),25,11)
        local sureMenu=CCMenu:createWithItem(self.sureBtn);
        sureMenu:setPosition(ccp(size.width/2,60))
        sureMenu:setTouchPriority(-(layerNum-1)*20-3);
        dialogBg:addChild(sureMenu)
        if SizeOfTable(content)>1 then
            isEnd=false
            tolua.cast(self.sureBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("gemCompleted"))
        end
    end

    local function touchLuaSpr()
        if self.isTouch==true and isMoved==false then
            if self.bgLayer~=nil then
                PlayEffect(audioCfg.mouseClick)
                removeAllFlickers()
                self:close()
            end
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
    if isOneByOne==true and type(content)=="table" and SizeOfTable(content)>1 then
        local acArr=CCArray:create()
        for k,v in pairs(content) do
            local function showNextMsg()
                if self and self.tv and v then
                    table.insert(self.message,v)
                    self.tv:insertCellAtIndex(k-1)

                    if k==SizeOfTable(content) then
                        tolua.cast(self.sureBtn:getChildByTag(11),"CCLabelTTF"):setString(getlocal("ok"))
                        isEnd=true
                    end

                    local index=v.index
                    if callBackHandler~=nil then
                        callBackHandler(index)
                    end
                end
            end
            local callFunc1=CCCallFuncN:create(showNextMsg)
            local delay=CCDelayTime:create(0.5)

            acArr:addObject(delay)
            acArr:addObject(callFunc1)

        end
        local seq=CCSequence:create(acArr)
        self.bgLayer:runAction(seq)

    end

end
--战力增长，数字从number1变到number2的特效
--posX和posY是动画出现的位置, 可以不传, 如果不传的话就默认出现在屏幕中间再偏上一点的位置
function smallDialog:showPowerChangeEffect(number1,number2,posX,posY)
    if(number1==number2)then
        do return end
    end
    local sd=smallDialog:new()
    sd:initPowerChangeEffect(number1,number2,posX,posY)
    return sd
end

-- bgSrc:9宫格背景图片 size:对话框大小 callBack:确定回调函数 title:标题 content:内容 isuseami:是否有动画效果 layerNum:层次 propId道具id(在确定按钮上方显示道具数量),leftStrSize:左边按钮的size,isRichLabel:不用了
function smallDialog:initSureAndCancle(bgSrc,size,fullRect,inRect,callBack,title,content,isuseami,layerNum,align,align2,cancleCallBack,leftBtnStr,rightBtnStr,isShowClose,isRichLabel,propId,content2,leftStrSize,isLeftInMiddle)
    self.isTouch=istouch
    self.isUseAmi=isuseami

    local showBottomH = 100 -- 下边按钮高度100
    local showContentH = size.height - showBottomH

    local function touchHandler()

    end
    local dialogBg
    if isShowClose==true then
        local function close()
            self:close()
        end
        -- 66高度
        dialogBg = G_getNewDialogBg(size, title, 40, nil, layerNum, true, close)
        showContentH = showContentH - 66
    else
        dialogBg = G_getNewDialogBg2(size, layerNum, touchHandler)
        showContentH = showContentH - 50

        -- 标题
        local titleTb={title,30, G_ColorWhite}
        local titleLbSize=CCSizeMake(300,0)
        local titleBg,titleL,subHeight=G_createNewTitle(titleTb,titleLbSize,nil,true)
        titleBg:setPosition(ccp(size.width/2,size.height-50))
        dialogBg:addChild(titleBg)

        local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
        dialogBg2:setContentSize(CCSizeMake(size.width-40,size.height-150))
        dialogBg2:setAnchorPoint(ccp(0.5,1))
        dialogBg2:setPosition(size.width/2,size.height-50)
        dialogBg:addChild(dialogBg2)
    end

    self.dialogLayer=CCLayer:create()
    self.dialogLayer:addChild(dialogBg,2)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    self.bgSize=size
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(size)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))

    self:show()
    self:userHandler()

    local btnOk1,btnOk2,btnCancle1,btnCancle2,btnLbSize = "newGreenBtn.png","newGreenBtn_down.png","newGrayBtn.png","newGrayBtn_Down.png",25
    local realalign,realValign=kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter
    if align~=nil then
        realalign=align
    end

    local realalign2=kCCTextAlignmentLeft
    if align2~=nil then
        realalign2=align2
    end

    local contentLb
    contentLb=GetTTFLabelWrap(content,25,CCSize(size.width-60,0),realalign,realValign)
    contentLb:setAnchorPoint(ccp(0.5,0.5))
    contentLb:setPosition(ccp(size.width/2, showBottomH+showContentH/2))
    contentLb:setTag(518)
    dialogBg:addChild(contentLb)

    if content2 then
        local contentLb2=GetTTFLabelWrap(content2,25,CCSize(size.width-60,0),realalign2,kCCVerticalTextAlignmentTop)
        contentLb2:setAnchorPoint(ccp(0,1))
        contentLb:setPosition(size.width/2,showBottomH+showContentH/2+20)
        contentLb2:setPosition(ccp(30,contentLb:getPositionY()-contentLb:getContentSize().height/2-10))
        dialogBg:addChild(contentLb2)
        contentLb2:setColor(G_ColorYellowPro)
    end

    local alterBtnScale = 0.7
    --取消
    local function cancleHandler()
        PlayEffect(audioCfg.mouseClick)
        if cancleCallBack~=nil then
            cancleCallBack()
        end
        self:close()
    end
    local cancleItem
    if rightBtnStr and rightBtnStr~="" then
        cancleItem=GetButtonItem(btnOk1, btnOk2, btnOk2, cancleHandler, 2, rightBtnStr, btnLbSize/alterBtnScale)
    else
        cancleItem=GetButtonItem(btnCancle1, btnCancle2, btnCancle2, cancleHandler, 2, getlocal("cancel"), btnLbSize/alterBtnScale)
    end
    cancleItem:setScale(alterBtnScale)
    local cancleMenu=CCMenu:createWithItem(cancleItem);
    cancleMenu:setPosition(ccp(size.width-120,60))
    cancleMenu:setTouchPriority(-(layerNum-1)*20-2);
    dialogBg:addChild(cancleMenu)
    --确定
    local function sureHandler()
        PlayEffect(audioCfg.mouseClick)
        callBack()
        self:close()
    end
    local leftStr=getlocal("ok")
    local leftSize = btnLbSize
    if leftStrSize then
        leftSize =leftStrSize
    end
    if leftBtnStr and leftBtnStr~="" then
        leftStr=leftBtnStr
    end
    local sureItem=GetButtonItem(btnOk1, btnOk2, btnOk2, sureHandler, 2, leftStr, leftSize/alterBtnScale)
    sureItem:setScale(alterBtnScale)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(120,60))
    sureMenu:setTouchPriority(-(layerNum-1)*20-2);
    dialogBg:addChild(sureMenu)

    if isLeftInMiddle ==true then
        sureMenu:setPosition(ccp(dialogBg:getContentSize().width*0.5,60))
        cancleMenu:setVisible(false)
    end

    if propId and propCfg["p"..propId] then
        local itemNum=bagVoApi:getItemNumId(propId) or 0
        local itemNumLb=GetTTFLabel(getlocal(propCfg["p"..propId].name)..": "..itemNum,25)
        itemNumLb:setPosition(ccp(120,115))
        dialogBg:addChild(itemNumLb,1)
    end

    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end

function smallDialog:initTableViewSure(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,callBackHandler,isAutoHeight)
    self.isTouch=istouch
    self.isUseAmi=isuseami
    local function touchHander()

    end

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHander)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true);
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

        local function touchDialog()

        end

  self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()

    local titleLb=GetTTFLabel(title,40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)

    local tvWidth=size.width-60
    local tvHeight=570
    if isAutoHeight and isAutoHeight==true then
        tvHeight=size.height-230
    end
    local contentLb=GetTTFLabelWrap(content,28,CCSizeMake(tvWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    local cellHeight=contentLb:getContentSize().height+300
    if cellHeight>2048 then
        cellHeight=2048
    end
    local cellWidth=tvWidth
    local isMoved=false

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 1
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local contentLb1=GetTTFLabelWrap(content,28,CCSizeMake(tvWidth,cellHeight),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            contentLb1:setAnchorPoint(ccp(0,1))
            contentLb1:setPosition(0,cellHeight)
            cell:addChild(contentLb1,1)

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd= LuaEventHandler:createHandler(tvCallBack)
    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,tvHeight),nil)
    tableView:setTableViewTouchPriority(-(layerNum-1)*20-2)
    tableView:setPosition(ccp(60/2,130))
    self.bgLayer:addChild(tableView,2)
    tableView:setMaxDisToBottomOrTop(120)

    --确定
    local function cancleHandler()
         PlayEffect(audioCfg.mouseClick)
         if callBackHandler~=nil then
            callBackHandler()
         end
         self:close()
    end

    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",cancleHandler,2,getlocal("ok"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(size.width/2,80))
    sureMenu:setTouchPriority(-(layerNum-1)*20-3);
    dialogBg:addChild(sureMenu)

    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
        touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
        local rect=CCSizeMake(640,G_VisibleSizeHeight)
        touchDialogBg:setContentSize(rect)
        touchDialogBg:setOpacity(180)
        touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
        self.dialogLayer:addChild(touchDialogBg,1);
    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end

function smallDialog:initTableViewSureWithColorTb(bgSrc,size,fullRect,inRect,title,contentTb,colorTb,isuseami,layerNum,callBackHandler,sizeTab,richColorTb,textAlignment)
    self.isTouch=istouch
    self.isUseAmi=isuseami
    local function touchHander()
    end

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHander)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true);
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()

    local tvHeight
    if title then
        local titleLb=GetTTFLabel(title,40)
        titleLb:setAnchorPoint(ccp(0.5,0.5))
        titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
        dialogBg:addChild(titleLb)
        tvHeight=size.height-200
    else
        tvHeight=size.height-150
    end

    if textAlignment==nil then
        textAlignment=kCCTextAlignmentLeft
    end
    local tvWidth=size.width-60
    local lbTb={}
    local posY=0
    local lbSize=21
    for k,v in pairs(contentTb) do
        local contentLb,lbHeight=nil,0
        if G_isShowRichLabel()==true and richColorTb and richColorTb[k] and SizeOfTable(richColorTb[k])>0 then
            if(sizeTab and sizeTab[k]) then
                lbSize=tonumber(sizeTab[k])
            end
            contentLb,lbHeight=G_getRichTextLabel(v,richColorTb[k],lbSize,tvWidth,textAlignment,kCCVerticalTextAlignmentTop,0)
            -- contentLb:setAnchorPoint(ccp(0,1))
        else
            contentLb=GetTTFLabelWrap(v,lbSize,CCSizeMake(tvWidth,0),textAlignment,kCCVerticalTextAlignmentTop,nil,true)
            if(colorTb and colorTb[k])then
                contentLb:setColor(colorTb[k])
            end
            if(sizeTab and sizeTab[k]) then
                contentLb:setFontSize(tonumber(sizeTab[k]))
            end
            lbHeight=contentLb:getContentSize().height
        end
        local lbpx=0
        if textAlignment==kCCTextAlignmentLeft then
            contentLb:setAnchorPoint(ccp(0,1))
            lbpx=0
        elseif textAlignment==kCCTextAlignmentCenter then
            contentLb:setAnchorPoint(ccp(0.5,1))
            lbpx=tvWidth/2
        else
            contentLb:setAnchorPoint(ccp(1,1))
            lbpx=tvWidth
        end
        if contentLb then
            posY=posY+lbHeight
            contentLb:setPosition(ccp(lbpx,posY))
            table.insert(lbTb,contentLb)
        end
    end
    local cellHeight=posY+20
    if cellHeight>2048 then
        cellHeight=2048
    end
    local cellWidth=tvWidth
    local isMoved=false

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 1
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            for k,v in pairs(lbTb) do
              cell:addChild(v,1)
            end
            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd= LuaEventHandler:createHandler(tvCallBack)
    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
    tableView:setTableViewTouchPriority(-(layerNum-1)*20-2)
    -- tableView:setAnchorPoint(ccp(0.5,1))
    tableView:setPosition(ccp(30,110))
    self.bgLayer:addChild(tableView,2)
    tableView:setMaxDisToBottomOrTop(150)

    --确定
    local function cancleHandler()
         PlayEffect(audioCfg.mouseClick)
         if callBackHandler~=nil then
            callBackHandler()
         end
         self:close()
    end

    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",cancleHandler,2,getlocal("ok"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(size.width/2,60))
    sureMenu:setTouchPriority(-(layerNum-1)*20-3);
    dialogBg:addChild(sureMenu)

    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
        touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
        local rect=CCSizeMake(640,G_VisibleSizeHeight)
        touchDialogBg:setContentSize(rect)
        touchDialogBg:setOpacity(180)
        touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
        self.dialogLayer:addChild(touchDialogBg,1);
    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end

function smallDialog:initTableViewRewardSure(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,callBackHandler)
    self.isTouch=istouch
    self.isUseAmi=isuseami
    local function touchHander()

    end

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHander)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true);
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

        local function touchDialog()

        end

  self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()


    local backSprie=CCSprite:createWithSpriteFrameName("orangeMask.png")
    backSprie:setPosition(ccp(size.width/2,size.height-60))
    dialogBg:addChild(backSprie)
    -- title="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local titleLb=GetTTFLabelWrap(title,25,CCSizeMake(size.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb:setPosition(getCenterPoint(backSprie))
    backSprie:addChild(titleLb)

    local tvWidth=size.width-60
    local tvHeight
    -- local tvHeight=570
    -- if isAutoHeight and isAutoHeight==true then
        tvHeight=size.height-230
    -- end
    -- local contentLb=GetTTFLabelWrap(content,28,CCSizeMake(tvWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    -- local cellHeight=contentLb:getContentSize().height+300
    -- if cellHeight>2048 then
    --     cellHeight=2048
    -- end
    local cellHeight=140
    local cellWidth=tvWidth
    local colNum=3  --一行有几个
    local spaceW=150
    local cellNum=0
    if content and SizeOfTable(content)>0 then
        cellNum=math.ceil(SizeOfTable(content)/colNum)
    end

    local isMoved=false
    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return cellNum
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(cellWidth,cellHeight)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            if content then
                for i=1,colNum do
                    local index=(idx)*3+i
                    local item=content[index]
                    if item then
                        local icon,scale=G_getItemIcon(item,100,true,layerNum)
                        if icon then
                            local px,py=cellWidth/2-spaceW+spaceW*(i-1),cellHeight/2
                            icon:setPosition(px,py)
                            icon:setTouchPriority(-(layerNum-1)*20-3)
                            icon:setIsSallow(false)
                            cell:addChild(icon,1)
                            local lb=GetTTFLabel("x"..item.num,25)
                            lb:setAnchorPoint(ccp(1,0))
                            lb:setPosition(ccp(icon:getContentSize().width-5,5))
                            icon:addChild(lb,1)
                            lb:setScale(1/scale)
                        end
                    end
                end
            end

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd= LuaEventHandler:createHandler(tvCallBack)
    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,tvHeight),nil)
    tableView:setTableViewTouchPriority(-(layerNum-1)*20-2)
    tableView:setPosition(ccp(60/2,130))
    self.bgLayer:addChild(tableView,2)
    tableView:setMaxDisToBottomOrTop(120)

    --确定
    local function cancleHandler()
         PlayEffect(audioCfg.mouseClick)
         if callBackHandler~=nil then
            callBackHandler()
         end
         self:close()
    end

    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",cancleHandler,2,getlocal("ok"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(size.width/2,80))
    sureMenu:setTouchPriority(-(layerNum-1)*20-3);
    dialogBg:addChild(sureMenu)

    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
        touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
        local rect=CCSizeMake(640,G_VisibleSizeHeight)
        touchDialogBg:setContentSize(rect)
        touchDialogBg:setOpacity(180)
        touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
        self.dialogLayer:addChild(touchDialogBg,1);
    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end

function smallDialog:initECRaidDialog(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,lbColor,callBackHandler,isOneByOne)
    self.isTouch=istouch
    self.isUseAmi=isuseami
    local function touchHander()

    end

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHander)
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true);
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

        local function touchDialog()

        end

  self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()

    local titleLb=GetTTFLabel(title,40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)

    local lbSize=25
    local tvWidth=size.width-60
    local tvHeight=570
    local contentLb
    local cellHeight=0
    local cellWidth=tvWidth
    self.message=nil
    local isMoved=false

    if type(content)=="table" then
        self.message={}
        if isOneByOne==true then
            local msg=content[1] or ""
            if type(msg)=="table" then
                local msgHeight=0
                for k,v in pairs(msg) do
                    if v and v~="" then
                        contentLb=GetTTFLabelWrap(v,lbSize,CCSizeMake(tvWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                        msgHeight=msgHeight+contentLb:getContentSize().height
                    end
                end
                table.insert(self.message,{msg=msg,height=msgHeight+10})
            else
                contentLb=GetTTFLabelWrap(msg,lbSize,CCSizeMake(tvWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                table.insert(self.message,{msg=msg,height=contentLb:getContentSize().height+10})
            end
        else
            for k,v in pairs(content) do
                contentLb=GetTTFLabelWrap(v,lbSize,CCSizeMake(tvWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                table.insert(self.message,{msg=v,height=contentLb:getContentSize().height+10})
            end
        end
    else
        self.message=content
        contentLb=GetTTFLabelWrap(self.message,lbSize,CCSizeMake(tvWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        cellHeight=contentLb:getContentSize().height+300
    end
    if cellHeight>2048 then
        cellHeight=2048
    end

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            if self.message and type(self.message)=="table" then
                return SizeOfTable(self.message)
            else
                return 1
            end
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize
            if self.message and type(self.message)=="table" and self.message[idx+1] then
                tmpSize=CCSizeMake(cellWidth,(self.message[idx+1].height or 0))
            else
                tmpSize=CCSizeMake(cellWidth,cellHeight)
            end
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local color=G_ColorWhite
            if lbColor then
                if type(lbColor)=="table" and SizeOfTable(lbColor)>0 and lbColor[idx+1] then
                    color=lbColor[idx+1]
                else
                    color=lbColor
                end
            end

            if type(self.message)=="table" then
                local msg=""
                local height=0
                if self.message[idx+1] then
                    msg=self.message[idx+1].msg
                    height=self.message[idx+1].height
                end
                if type(msg)=="table" then
                    local msgHeight=0
                    for k,v in pairs(msg) do
                        if v and v~="" then
                            local contentLb1=GetTTFLabelWrap(v,lbSize,CCSizeMake(tvWidth,height+100),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                            contentLb1:setAnchorPoint(ccp(0,1))

                            local diffHeight=0
                            if k==1 then
                            else
                                for i=1,(k-1) do
                                    local contentLb2=GetTTFLabelWrap(msg[i],lbSize,CCSizeMake(tvWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                                    diffHeight=diffHeight+contentLb2:getContentSize().height
                                end

                            end

                            contentLb1:setPosition(0,height-diffHeight)
                            cell:addChild(contentLb1,1)
                            if color and type(color)=="table" and SizeOfTable(color)>0 then
                                contentLb1:setColor(color[k])
                            end
                        end
                    end
                else
                    local contentLb1=GetTTFLabelWrap(msg,lbSize,CCSizeMake(tvWidth,height+100),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    contentLb1:setAnchorPoint(ccp(0,1))
                    contentLb1:setPosition(0,height)
                    cell:addChild(contentLb1,1)
                    contentLb1:setColor(color)
                end
            else
                local contentLb1=GetTTFLabelWrap(self.message,lbSize,CCSizeMake(tvWidth,cellHeight),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                contentLb1:setAnchorPoint(ccp(0,1))
                contentLb1:setPosition(0,cellHeight)
                cell:addChild(contentLb1,1)
                contentLb1:setColor(color)
            end

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd= LuaEventHandler:createHandler(tvCallBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(layerNum-1)*20-2)
    self.tv:setPosition(ccp(60/2,130))
    self.bgLayer:addChild(self.tv,2)
    self.tv:setMaxDisToBottomOrTop(120)

    --确定
    local function cancleHandler()
         PlayEffect(audioCfg.mouseClick)
         if callBackHandler~=nil then
            callBackHandler()
         end
         self:close()
    end

    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",cancleHandler,2,getlocal("ok"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(size.width/2,80))
    sureMenu:setTouchPriority(-(layerNum-1)*20-3);
    dialogBg:addChild(sureMenu)
    if SizeOfTable(content)>1 then
        sureItem:setEnabled(false)
    end

    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
        touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
        local rect=CCSizeMake(640,G_VisibleSizeHeight)
        touchDialogBg:setContentSize(rect)
        touchDialogBg:setOpacity(180)
        touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
        self.dialogLayer:addChild(touchDialogBg,1);
    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))


    if isOneByOne==true and type(content)=="table" then
        if SizeOfTable(content)>1 then
            local acArr=CCArray:create()
            for k,v in pairs(content) do
                if k>1 then
                    local function showNextMsg()
                        if self and self.tv then
                            if type(v)=="table" then
                                local msgHeight=0
                                for m,n in pairs(v) do
                                    if n and n~="" then
                                        contentLb=GetTTFLabelWrap(n,lbSize,CCSizeMake(tvWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                                        msgHeight=msgHeight+contentLb:getContentSize().height
                                    end
                                end
                                table.insert(self.message,{msg=v,height=msgHeight+10})
                            else
                                contentLb=GetTTFLabelWrap(v,lbSize,CCSizeMake(tvWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                                table.insert(self.message,k,{msg=v,height=contentLb:getContentSize().height+10})
                            end

                            self.tv:insertCellAtIndex(k-1)

                            if k==SizeOfTable(content) then
                                sureItem:setEnabled(true)
                            end
                        end
                    end
                    local callFunc1=CCCallFuncN:create(showNextMsg)
                    local delay=CCDelayTime:create(1)

                    acArr:addObject(delay)
                    acArr:addObject(callFunc1)
                end
            end
            local seq=CCSequence:create(acArr)
            self.bgLayer:runAction(seq)
        end
    end

end

function smallDialog:initSure(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,lbColor,callBackHandler,type)
    self.isTouch=istouch
    self.isUseAmi=isuseami

    local showBottomH = 100 -- 下边按钮高度100
    local showContentH = size.height - showBottomH

    local function touchHandler()

    end
    local dialogBg = G_getNewDialogBg2(size, layerNum, touchHandler)
    showContentH = showContentH - 50

    -- 标题
    local titleTb={title, 30, G_ColorWhite}
    local titleLbSize=CCSizeMake(300,0)
    local titleBg,titleL,subHeight=G_createNewTitle(titleTb,titleLbSize,nil,true)
    titleBg:setPosition(ccp(size.width/2,size.height-50))
    dialogBg:addChild(titleBg)

    local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(size.width-40,size.height-150))
    dialogBg2:setAnchorPoint(ccp(0.5,1))
    dialogBg2:setPosition(size.width/2,size.height-50)
    dialogBg:addChild(dialogBg2)

    self.dialogLayer=CCLayer:create()
    self.dialogLayer:addChild(dialogBg,2)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    self.bgSize=size
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(size)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))

    self:show()
    self:userHandler()

    local contentLb=GetTTFLabelWrap(content,28,CCSize(size.width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    contentLb:setAnchorPoint(ccp(0.5,0.5))
    contentLb:setPosition(ccp(size.width/2,showBottomH + showContentH/2))
    dialogBg:addChild(contentLb)
    if lbColor~=nil then
        contentLb:setColor(lbColor)
    end

    --确定
    local function cancleHandler()
        PlayEffect(audioCfg.mouseClick)
        if callBackHandler~=nil then
            callBackHandler()
        end
        self:close()
    end

    local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",cancleHandler,2,getlocal("ok"),25/0.7)
    sureItem:setScale(0.7)
    local sureMenu=CCMenu:createWithItem(sureItem)
    sureMenu:setPosition(ccp(size.width/2,55))
    sureMenu:setTouchPriority(-(layerNum-1)*20-3)
    dialogBg:addChild(sureMenu)

    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)
    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
end
--bgSrc:9宫格背景图片 size:对话框大小     tmpFunc:nil istouch:点击屏幕任意位置关闭 isuseami:是否有弹板动画
function smallDialog:initShowBuilding(bgSrc,size,fullRect,inRect,tmpFunc,istouch,isuseami,layerNum)
    self.isTouch=istouch
    self.isUseAmi=isuseami
      local function tmpFunc()

      end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,tmpFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size

    self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog()
        if self.isTouch~=nil then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);

  self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()
    return self.dialogLayer,self.bgLayer


end

--bgSrc:9宫格背景图片 size:对话框大小     tmpFunc:nil istouch:点击屏幕任意位置关闭 isuseami:是否有弹板动画 isRichLabel:是否使用变色label
function smallDialog:init(bgSrc,size,fullRect,inRect,tmpFunc,istouch,isuseami,layerNum,textTab,textSize,textColorTab,title,isUseSize,isRichLabel,tabAlignment)
    self.isTouch=istouch
    self.isUseAmi=isuseami
    local function tmpFunc()

    end
    local dialogBg,lineSp1,lineSp2 = G_getNewDialogBg2(CCSizeMake(size.width, 0),layerNum,tmpFunc)
    self.dialogLayer = CCLayer:create()
    self.bgLayer = dialogBg
    local bgLayerSize = CCSizeMake(500, 20)
    if isUseSize ~= nil and isUseSize == true then
        bgLayerSize = CCSizeMake(size.width, bgLayerSize.height)
    end
    self.bgSize = bgLayerSize

    -- 计算lable
    local sizeLb = 10

    for k,v in pairs(textTab) do
        local alignment=kCCTextAlignmentLeft
        if tabAlignment and type(tabAlignment)=="table" and tabAlignment[k] then
            alignment=tabAlignment[k]
        end

        local textWidth = 450
        if isUseSize~=nil and isUseSize == true then
            textWidth = size.width - 40
        end
        local lable=nil
        local purStr = nil
        local sizeLable = nil
        if isRichLabel~=nil then
            -- 返回label和纯字符串（计算label的height）
            lable ,purStr = getRichLabel(v,textSize,CCSize(textWidth,0))
            sizeLable = GetTTFLabelWrap(purStr,textSize,CCSize(textWidth,0),alignment,kCCVerticalTextAlignmentTop)
        else
            lable = GetTTFLabelWrap(v,textSize,CCSize(textWidth,0),alignment,kCCVerticalTextAlignmentTop)
            sizeLable = lable
        end

        if textColorTab~=nil and isRichLabel==nil then
            if textColorTab[k]~= nil then
                lable:setColor(textColorTab[k])
            else
                lable:setColor(G_ColorWhite)
            end
        end

        lable:setAnchorPoint(ccp(0,0))
        if isRichLabel~=nil then
            lable:setPosition(ccp(30, sizeLb + sizeLable:getContentSize().height))
        else
            lable:setPosition(ccp(30, sizeLb))
        end

        self.bgLayer:addChild(lable,2)

        sizeLb = sizeLb + sizeLable:getContentSize().height
    end

    -- 有标题
    if title~=nil and title ~= "" then
        -- 线
        local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
        lineSprite:setPosition(ccp(self.bgSize.width/2, sizeLb + lineSprite:getContentSize().height/2))
        lineSprite:setScaleX((self.bgSize.width-60)/lineSprite:getContentSize().width)
        self.bgLayer:addChild(lineSprite,2)
        -- 标题
        local titleLb = GetTTFLabel(title, 30)
        titleLb:setColor(G_ColorYellowPro)
        titleLb:setAnchorPoint(ccp(0.5,0.5))
        titleLb:setPosition(ccp(self.bgSize.width/2, lineSprite:getPositionY() + titleLb:getContentSize().height/2 + 20))
        self.bgLayer:addChild(titleLb)

        sizeLb = sizeLb + lineSprite:getContentSize().height + titleLb:getContentSize().height + 20
    end
    
    if sizeLb == 10 then
        -- 没有内容按传过来的参数
        bgLayerSize.width = size.width
        bgLayerSize.height = size.height
        self.bgLayer:setContentSize(size)
    else
        -- 自适应大小size
        bgLayerSize.height = bgLayerSize.height + sizeLb
        self.bgLayer:setContentSize(bgLayerSize)
    end
    self:show()
    lineSp1:setPositionY(bgLayerSize.height)
    lineSp2:setPositionY(lineSp2:getContentSize().height)

    local function touchDialog()
        if self.isTouch~=nil then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)
    self.dialogLayer:setPosition(ccp(0,0))
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()

    return self.dialogLayer
end

function smallDialog:initInfo(bgSrc,size,fullRect,inRect,tmpFunc,istouch,isuseami,layerNum,textSize,infoTab,cellSize)
  self.isTouch=istouch
  self.isUseAmi=isuseami
  local function tmpFunc()
  end
  local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),tmpFunc)
  self.dialogLayer=CCLayer:create()
  self.bgLayer=dialogBg
  self.bgSize=size

  self.bgLayer:setContentSize(size)
  self:show()

  local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return SizeOfTable(infoTab)
        elseif fn=="tableCellSizeForIndex" then
            local tmpSize=CCSizeMake(100,100)
            return  tmpSize
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            local tab = infoTab[idx+1]
            local icon = CCSprite:createWithSpriteFrameName(tab[1])
            icon:setScale(2)
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setPosition(ccp(10,cell:getContentSize().height/2))
            cell:addChild(icon)

            local label = GetTTFLabel(tab[2],25)
            label:setAnchorPoint(ccp(0,0.5))
            cell:addChild(label)
            label:setPosition(100,cell:getContentSize().height/2)

            return cell
        elseif fn=="ccTouchBegan" then
            isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            isMoved=true
        elseif fn=="ccTouchEnded"  then

        end
    end

    local hd= LuaEventHandler:createHandler(tvCallBack)
    local tv=LuaCCTableView:createWithEventHandler(hd,cellSize,nil)
    tv:setAnchorPoint(ccp(0,0))
    tv:setPosition(ccp(10,30))
    tv:setTableViewTouchPriority(-(layerNum-1)*20-6)
    tv:setMaxDisToBottomOrTop(100)
    self.bgLayer:addChild(tv,1)



  local function touchDialog()
      if self.isTouch~=nil then
          PlayEffect(audioCfg.mouseClick)
          self:close()
      end
  end
  local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
  touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
  local rect=CCSizeMake(640,G_VisibleSizeHeight)
  touchDialogBg:setContentSize(rect)
  touchDialogBg:setOpacity(180)
  touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))

  self.dialogLayer:addChild(touchDialogBg,1);
  self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
  self.dialogLayer:addChild(self.bgLayer,2);
  self.dialogLayer:setPosition(ccp(0,0))
  self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
  self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)
  self:userHandler()
  return self.dialogLayer
end

function smallDialog:initHeroInfoDialog(bgSrc,size,fullRect,inRect,tmpFunc,istouch,isuseami,layerNum,heroVo,bType)
    self.isTouch=istouch
    self.isUseAmi=isuseami
    local function tmpFunc()
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),tmpFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size

    self.bgLayer:setContentSize(size)
    self:show()

    local heroIcon = heroVoApi:getHeroIcon(heroVo.hid,heroVo.productOrder)
    heroIcon:setPosition(ccp(115,size.height-100))
    heroIcon:setScale(0.8)
    self.bgLayer:addChild(heroIcon)

    -- 添加nameLabel
    local heroName = GetTTFLabel(heroVoApi:getHeroName(heroVo.hid),30)
    heroName:setAnchorPoint(ccp(0,0))
    heroName:setColor(heroVoApi:getHeroColor(heroVo.productOrder))
    heroName:setPosition(ccp(270,size.height-100))
    self.bgLayer:addChild(heroName)

    -- 添加等级
    local heroLevel = GetTTFLabel(getlocal("scheduleChapter",{G_LV() .. heroVo.level,tostring(heroCfg.heroLevel[heroVo.productOrder])}),25)
    heroLevel:setAnchorPoint(ccp(0,0))
    heroLevel:setPosition(ccp(270,size.height-150))
    self.bgLayer:addChild(heroLevel)

    -- 添加光亮线
    local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSp:setAnchorPoint(ccp(0,0));
    lineSp:setPosition(ccp(10,size.height-200));
    self.bgLayer:addChild(lineSp,1)

    local atb = {}
    for k,v in pairs(heroListCfg[heroVo.hid].heroAtt) do
      atb[k]=v[1]*heroVo.productOrder+v[2]*1
    end

    local tb={atk={icon="attributeARP.png",lb={getlocal("dmg"),}},
            hlp={icon="attributeArmor.png",lb={getlocal("hlp"),}},
            hit={icon="skill_01.png",lb={getlocal("sample_skill_name_101"),}},
            eva={icon="skill_02.png",lb={getlocal("sample_skill_name_102"),}},
            cri={icon="skill_03.png",lb={getlocal("sample_skill_name_103"),}},
            res={icon="skill_04.png",lb={getlocal("sample_skill_name_104"),}},
           }
    local adTb = {}
    for k,v in pairs(heroListCfg[heroVo.hid].heroAtt) do
      table.insert(adTb, k )
    end


    local lbTb1={}
    for i=1,SizeOfTable(heroListCfg[heroVo.hid].heroAtt) do
        local attackSp = CCSprite:createWithSpriteFrameName(tb[adTb[i]].icon)
        local iconScale= 50/attackSp:getContentSize().width
        attackSp:setAnchorPoint(ccp(0,0.5))
        local width=i%2
        local chanWidth=230
        if width==0 then
            width=2
            chanWidth=chanWidth+30
        end
        attackSp:setPosition(ccp(-170+chanWidth*width,size.height-160-math.ceil(i/2)*75))
        self.bgLayer:addChild(attackSp,2)
        attackSp:setScale(iconScale)

        local strLb1=GetTTFLabel(tb[adTb[i]].lb[1],40)
        strLb1:setAnchorPoint(ccp(0,0.5))
        strLb1:setPosition(ccp(attackSp:getContentSize().width+10,attackSp:getContentSize().height/2))
        attackSp:addChild(strLb1)

        local strLb2=GetTTFLabel("+"..atb[adTb[i]].."%",40)
        strLb2:setAnchorPoint(ccp(0,0.5))
        strLb2:setPosition(ccp(attackSp:getContentSize().width+10+strLb1:getContentSize().width+5,attackSp:getContentSize().height/2))
        attackSp:addChild(strLb2)
        lbTb1[i]=strLb2
    end


    local atb1=heroVoApi:getAddBuffTb(heroVo)
    for i=1,SizeOfTable(lbTb1) do
      local lb= tolua.cast(lbTb1[i],"CCLabelTTF")
      lb:setString("+"..atb1[adTb[i]].."%")
    end

    local honorSkills
    local cellNum=SizeOfTable(heroListCfg[heroVo.hid].skills)
    if heroVoApi:heroHonorIsOpen()==true and heroVo and heroVo.hid then
        if bType and ltzdzFightApi and (bType==35 or bType==36) then
          honorSkills=ltzdzFightApi:getUsedRealiseSkill(hid)
        else
          honorSkills=heroVoApi:getUsedRealiseSkill(heroVo.hid)
        end

        if honorSkills then
            cellNum=cellNum + #honorSkills
        end
    end
    local function tvCallBack(handler,fn,idx,cel)
          if fn=="numberOfCellsInTableView" then
              return cellNum
          elseif fn=="tableCellSizeForIndex" then
              local tmpSize
              if honorSkills and idx==cellNum - #honorSkills then
                  if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="in" then
                      tmpSize=CCSizeMake(400,200+60)
                  else
                      tmpSize=CCSizeMake(400,150+60)
                  end
              else
                  if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="in" then
                      tmpSize=CCSizeMake(400,200)
                  else
                      tmpSize=CCSizeMake(400,150)
                  end
              end
             return  tmpSize
          elseif fn=="tableCellAtIndex" then
              local cell=CCTableViewCell:new()
              cell:autorelease()
              local rect = CCRect(0, 0, 50, 50);
              local capInSet = CCRect(20, 20, 10, 10);
              local function cellClick(hd,fn,idx)
              end
              local hei
              if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="in" then
                  hei=200
              else
                  hei=150
              end
              local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
              backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, hei))
              backSprie:ignoreAnchorPointForPosition(false);
              backSprie:setAnchorPoint(ccp(0,0));
              backSprie:setTag(1000+idx)
              backSprie:setIsSallow(false)
              backSprie:setTouchPriority(-(layerNum-1)*20-2)
              cell:addChild(backSprie,1)

              local sid
              local lvStr,value
              if honorSkills and idx>=cellNum - #honorSkills then
                  if(idx==cellNum - #honorSkills)then
                      local subTitleSp=CCSprite:createWithSpriteFrameName("RankBtnTab_Down.png")
                      subTitleSp:setAnchorPoint(ccp(0,1))
                      subTitleSp:setPosition(ccp(5,hei+50))
                      cell:addChild(subTitleSp,2)
                      local subTitleLb=GetTTFLabel(getlocal("hero_honor_used_honor_skill"),25)
                      subTitleLb:setPosition(getCenterPoint(subTitleSp))
                      subTitleSp:addChild(subTitleLb,1)
                  end

                  sid=honorSkills[cellNum - idx][1]
                  if bType and ltzdzFightApi and (bType==35 or bType==36) then
                    lvStr,value=ltzdzFightApi:getHeroHonorSkillLvAndValue(heroVo.hid,sid,heroVo.productOrder)
                  else
                    lvStr,value=heroVoApi:getHeroHonorSkillLvAndValue(heroVo.hid,sid,heroVo.productOrder)
                  end

              else
                  sid=heroListCfg[heroVo.hid].skills[idx+1][1]
                  if bType and ltzdzFightApi and (bType==35 or bType==36) then
                    lvStr,value=ltzdzFightApi:getHeroSkillLvAndValue(heroVo.hid,sid,heroVo.productOrder)
                  else
                    lvStr,value=heroVoApi:getHeroSkillLvAndValue(heroVo.hid,sid,heroVo.productOrder)
                  end

              end
              local icon = CCSprite:create(heroVoApi:getSkillIconBySid(sid))
              icon:setAnchorPoint(ccp(0,0.5))
              icon:setPosition(ccp(10,backSprie:getContentSize().height/2))
              backSprie:addChild(icon)

              local titleStrHeight = nil
              local lableStrHeight = nil
              if G_getCurChoseLanguage()=="de" or G_getCurChoseLanguage()=="en" or G_getCurChoseLanguage()=="in" then
                titleStrHeight=35
                lableStrHeight=120
              else
                titleStrHeight=20
                lableStrHeight=100
              end
              local greSize =27
              if G_getCurChoseLanguage() =="fr" then
                greSize =22
              end

              -- print("sid============="..sid)
              if heroVo.skill[sid]==nil and equipCfg[heroVo.hid]["e1"].awaken.skill then
                  local awakenSkill=equipCfg[heroVo.hid]["e1"].awaken.skill
                  if awakenSkill[sid] then
                    sid=awakenSkill[sid]
                    -- print("000000000000000000000"..sid)

                  end
              end
              -- print("sid=============+++++++"..sid)


              local lbTB={
              {str=getlocal(heroSkillCfg[sid].name)..lvStr,size=greSize,pos={140,backSprie:getContentSize().height-titleStrHeight},aPos={0,0.5},color=G_ColorGreen},
              {str=getlocal(heroSkillCfg[sid].des,(type(value)=="table") and value or {value}),size=23,pos={140,backSprie:getContentSize().height-lableStrHeight},aPos={0,0.5},},

              }
              for k,v in pairs(lbTB) do
                local strLb=GetTTFLabelWrap(v.str,v.size,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                if v.aPos then
                strLb:setAnchorPoint(ccp(v.aPos[1],v.aPos[2]))
                end
                if v.color then
                strLb:setColor(v.color)
                end
                strLb:setPosition(ccp(v.pos[1],v.pos[2]-8))
                backSprie:addChild(strLb)
              end

              if idx+1 >heroVo.productOrder then

                local function touchLuaSpr( ... )
                end
                local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
                touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
                local rect=CCSizeMake(backSprie:getContentSize().width,backSprie:getContentSize().height)
                touchDialogBg:setContentSize(rect)
                touchDialogBg:setOpacity(200)
                touchDialogBg:setPosition(getCenterPoint(backSprie))
                backSprie:addChild(touchDialogBg,4)


                local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
                titleBg:setContentSize(CCSizeMake(120,100))
                titleBg:setPosition(ccp(60,backSprie:getContentSize().height/2))
                backSprie:addChild(titleBg)

                local numLabel = GetTTFLabel(tostring(idx+1),30)
                titleBg:addChild(numLabel)
                numLabel:setPosition(titleBg:getContentSize().width/2-15,titleBg:getContentSize().height/2+20)
                numLabel:setColor(G_ColorRed)

                local spriteStar = CCSprite:createWithSpriteFrameName("StarIcon.png")
                titleBg:addChild(spriteStar)
                spriteStar:setPosition(titleBg:getContentSize().width/2+15,titleBg:getContentSize().height/2+20)
                spriteStar:setScale(0.8)

                local lockLabel = GetTTFLabel(getlocal("activity_fbReward_unlock"),30)
                titleBg:addChild(lockLabel)
                lockLabel:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2-20)
                lockLabel:setColor(G_ColorRed)
              end
              return cell
          elseif fn=="ccTouchBegan" then
              isMoved=false
              return true
          elseif fn=="ccTouchMoved" then
              isMoved=true
          elseif fn=="ccTouchEnded"  then

          end
      end

      local hd= LuaEventHandler:createHandler(tvCallBack)
      local tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width,self.bgLayer:getContentSize().height-390),nil)
      tv:setAnchorPoint(ccp(0,0))
      tv:setPosition(ccp(30,30))
      tv:setTableViewTouchPriority(-(layerNum-1)*20-3)
      tv:setMaxDisToBottomOrTop(100)
      self.bgLayer:addChild(tv,1)



    local function touchDialog()
        if tv:getIsScrolled()==true then
            do return end
          end
        if self.isTouch~=nil then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-3)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))

    self.dialogLayer:addChild(touchDialogBg,1);
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setPosition(ccp(0,0))
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)
    self:userHandler()
    sceneGame:addChild(self.dialogLayer,layerNum)
end

function smallDialog:getHeroSkillLvAndValue(hid,sid,productOrder,level)

  local skillsCfg={}
  for k,v in pairs(heroListCfg[hid].skills) do
    if v[1]==sid then
      skillsCfg=v
      break
    end
  end
  local level = level
  local lvStr = G_LV()..level.."/"..skillsCfg[2][productOrder]
  if level==0 then
    level=1
    lvStr=G_LV()..level
  end

  local value=1*heroSkillCfg[sid].attValuePerLv*100
  local valueStr=value.."%%"
  if heroSkillCfg[sid].attType=="antifirst" or heroSkillCfg[sid].attType=="first" then
    valueStr=value/100
  end

  return lvStr,valueStr
end


--bgSrc:9宫格背景图片 size:对话框大小    tmpFunc:nil istouch:点击屏幕任意位置关闭 isuseami:是否有弹板动画 heroVo：英雄信息
function smallDialog:initHeroInfo(bgSrc,size,fullRect,inRect,tmpFunc,istouch,isuseami,layerNum,heroVo,textSize,textColorTab,title,isUseSize)
    local strSize2 = 22
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
        strSize2 =25
    end
    self.isTouch=istouch
    self.isUseAmi=isuseami
      local function tmpFunc()

      end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30,30,1,1),tmpFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size

    local iconSp = heroVoApi:getHeroIcon(heroVo.hid, heroVo.productOrder, false)
    self.bgLayer:addChild(iconSp)
    iconSp:setPosition(ccp(120,size.height-110))
    iconSp:setScale(0.9)


    local heroNameLable = GetTTFLabel(heroVoApi:getHeroName(heroVo.hid), 30)
    self.bgLayer:addChild(heroNameLable)
    heroNameLable:setAnchorPoint(ccp(0, 0))
    heroNameLable:setPosition(ccp(240, size.height-90))
    heroNameLable:setColor(heroVoApi:getHeroColor(heroVo.productOrder))

    local heroCountry = GetTTFLabelWrap(getlocal("nation_of_hero", {heroVoApi:getHeroNation(heroVo.hid)}), 25,CCSizeMake(230,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    heroCountry:setAnchorPoint(ccp(0, 0))
    self.bgLayer:addChild(heroCountry)
    heroCountry:setPosition(ccp(240, size.height-60-45-45))

    if G_getCurChoseLanguage() =="ja" then
        heroCountry:setVisible(false)
    end



    local function click(hd,fn,idx)

    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),click)
    backSprie:ignoreAnchorPointForPosition(false);
    backSprie:setContentSize(CCSize(430, size.height-220))
    backSprie:setAnchorPoint(ccp(0,0));
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer:addChild(backSprie)
    backSprie:setPosition(ccp(35, 30))

    local backSprieSize = backSprie:getContentSize()


    local heroDesTitle = GetTTFLabel(getlocal("story_of_hero"), strSize2)
    backSprie:addChild(heroDesTitle)
    heroDesTitle:setPosition(backSprieSize.width/2, backSprieSize.height-27)
    heroDesTitle:setColor(G_ColorYellowPro)

    local lable = GetTTFLabelWrap(heroVoApi:getHeroDes(heroVo.hid),25,CCSize(400, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    backSprie:addChild(lable)
    lable:setPosition(ccp(15, backSprieSize.height-47))
    lable:setAnchorPoint(ccp(0, 1))


    self.bgLayer:setContentSize(size)
    self:show()

        local function touchDialog()
            if self.isTouch~=nil then
                PlayEffect(audioCfg.mouseClick)
                self:close()
            end

        end
        -- 这个是弹出的透明层
        local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
        touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
        local rect=CCSizeMake(640,G_VisibleSizeHeight)
        touchDialogBg:setContentSize(rect)
        touchDialogBg:setOpacity(180)
        touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
        self.dialogLayer:addChild(touchDialogBg,1);
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setPosition(ccp(0,0))
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()


    local clickLbPosy=-80
    local tmpLb=GetTTFLabel(getlocal("click_screen_continue"),25)
    local clickLb=GetTTFLabelWrap(getlocal("click_screen_continue"),25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    clickLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,clickLbPosy))
    self.bgLayer:addChild(clickLb)
    local arrowPosx1,arrowPosx2
    local realWidth,maxWidth=tmpLb:getContentSize().width,clickLb:getContentSize().width
    if realWidth>maxWidth then
        arrowPosx1=self.bgLayer:getContentSize().width/2-maxWidth/2
        arrowPosx2=self.bgLayer:getContentSize().width/2+maxWidth/2
    else
        arrowPosx1=self.bgLayer:getContentSize().width/2-realWidth/2
        arrowPosx2=self.bgLayer:getContentSize().width/2+realWidth/2
    end
    local smallArrowSp1=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp1:setPosition(ccp(arrowPosx1-15,clickLbPosy))
    self.bgLayer:addChild(smallArrowSp1)
    local smallArrowSp2=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp2:setPosition(ccp(arrowPosx1-25,clickLbPosy))
    self.bgLayer:addChild(smallArrowSp2)
    smallArrowSp2:setOpacity(100)
    local smallArrowSp3=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp3:setPosition(ccp(arrowPosx2+15,clickLbPosy))
    self.bgLayer:addChild(smallArrowSp3)
    smallArrowSp3:setRotation(180)
    local smallArrowSp4=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp4:setPosition(ccp(arrowPosx2+25,clickLbPosy))
    self.bgLayer:addChild(smallArrowSp4)
    smallArrowSp4:setOpacity(100)
    smallArrowSp4:setRotation(180)

    local space=20
    smallArrowSp1:runAction(G_actionArrow(1,space))
    smallArrowSp2:runAction(G_actionArrow(1,space))
    smallArrowSp3:runAction(G_actionArrow(-1,space))
    smallArrowSp4:runAction(G_actionArrow(-1,space))

    return self.dialogLayer


end

-- bgSrc:9宫格背景图片 size:对话框大小 callBack:确定回调函数 textContnt:文字内容 textSize:字体大小
function smallDialog:initTipsDialog(bgSrc,size,fullRect,inRect,textContnt,textSize,bgPoint,contentColor,newLayerNum)

    local function tmpFunc()

    end
    local rrect=CCRect(0, 50, 1, 1)
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("tipsBg.png",rrect,tmpFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size

    --local lable = GetTTFLabelWrap(textContnt,textSize,CCSizeMake(size.width-60,size.height-60),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    --lable:setPosition(getCenterPoint(self.bgLayer));


  -- 计算lable
    local textWrapNum = 400/textSize
    local lable = GetTTFLabel(textContnt,textSize);

    local heightNum = lable:getContentSize().width/((textWrapNum-2)*textSize)+1
    heightNum=heightNum+1
    if lable:getContentSize().width>400 then
        label=nil
        lable = GetTTFLabelWrap(textContnt,textSize,CCSize(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    end
    lable:setAnchorPoint(ccp(0.5,0.5));
    if contentColor then
      lable:setColor(contentColor)
    end
    local layerHeight=35+math.max(66,lable:getContentSize().height+10)
    -- if G_isIOS()==true then
    --     layerHeight =100-textSize+textSize*(heightNum-1)
    -- else
    --     layerHeight =110-textSize+textSize*(heightNum)
    -- end
    self.bgLayer:setContentSize(CCSize(611,layerHeight))
    --self.bgLayer:setContentSize(CCSize(611,lable:getContentSize().height+80))
    lable:setPosition(ccp(self.bgLayer:getContentSize().width/2+20,self.bgLayer:getContentSize().height/2-15));
    self.bgLayer:addChild(lable,1);
    self.bgLayer:setIsSallow(false);
    self.dialogLayer:addChild(self.bgLayer,1);
    sceneGame:addChild(self.dialogLayer,newLayerNum or 299)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth/2-20,G_VisibleSizeHeight/2+180))
  if bgPoint~=nil then
    self.bgLayer:setPosition(bgPoint)
  end
    self.bgLayer:setScale(0)
    self.bgLayer:setOpacity(180)
    --base:addTipsQueue(self)

    self:showTips()

end
--显示面板,加效果
function smallDialog:showTips()

    local function realClose()
        base:playNextTip()
        return self:realClose()
    end
     base:removeFromNeedRefresh(self) --停止刷新
   local fc= CCCallFunc:create(realClose)
   local moveTo1=CCMoveTo:create(0.3,CCPointMake(G_VisibleSize.width/2,G_VisibleSizeHeight/2))
   local moveTo2=CCMoveTo:create(0.1,CCPointMake(G_VisibleSize.width/2,G_VisibleSizeHeight/2))
   local moveTo3=CCMoveTo:create(0.2,CCPointMake(G_VisibleSize.width*2,G_VisibleSizeHeight/2))
   local delayTime = CCDelayTime:create(1.2);
 local scale1=CCScaleTo:create(0.1,1.3)
 local scale2=CCScaleTo:create(0.1,1)

 local move=CCMoveTo:create(0.4,CCPointMake(G_VisibleSize.width/2,G_VisibleSizeHeight/2+400))
 local fade=CCFadeTo:create(0.4,0)

 local carray1=CCArray:create()
 carray1:addObject(move)
 carray1:addObject(fade)
 local spa2=CCSpawn:create(carray1)

   local acArr=CCArray:create()
   acArr:addObject(scale1)
   acArr:addObject(scale2)
   acArr:addObject(delayTime)
   acArr:addObject(spa2)
   acArr:addObject(fc)
   local seq=CCSequence:create(acArr)
    self.bgLayer:runAction(seq)

end

function smallDialog:initTaskDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,textTab,textSize,itemTab,textColorTab,ifDaily,isLocalName)
    self.isTouch=nil
    self.isUseAmi=isuseami
    local function tmpFunc()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,tmpFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size

      local isMoved=false
      local sizeLb=0
      if ifDaily then
            if ifDaily==1 then
                  sizeLb=200
                  if itemTab and itemTab.pic and itemTab.desc then
                        local width = 30
                        local height = sizeLb-120
                        local icon = CCSprite:createWithSpriteFrameName(itemTab.pic)
                    icon:setAnchorPoint(ccp(0,0))
                        icon:setPosition(ccp(width,height))
                        self.bgLayer:addChild(icon,1)
                        if icon:getContentSize().width>100 then
                              icon:setScaleX(100/150)
                              icon:setScaleY(100/150)
                        end

                        local txtSize = 20
                        local descLable = GetTTFLabelWrap(getlocal(itemTab.desc),txtSize,CCSize(15*txtSize,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    descLable:setAnchorPoint(ccp(0,0))
                    descLable:setPosition(ccp(width+105,height))
                        self.bgLayer:addChild(descLable,1)
                  end

                  local function clickAreaHandler()
                  end
                  local selectSp=LuaCCScale9Sprite:createWithSpriteFrameName("guide_res.png",CCRect(28,28,2,2),clickAreaHandler)
                  --selectSp:setAnchorPoint(ccp(0.5,0.5))
                  selectSp:setAnchorPoint(ccp(0,0))
                  selectSp:setTouchPriority(0)
                  selectSp:setIsSallow(false)
                  --selectSp:setPosition(ccp(self.bgSize.width/2,self.bgSize.height/2))
                  selectSp:setPosition(ccp(-3,-3))
                  selectSp:setContentSize(CCSizeMake(self.bgSize.width+56,self.bgSize.height-60))
                  self.bgLayer:addChild(selectSp,10)

                  local fadeOut=CCTintTo:create(0.5,150,150,150)
                  local fadeIn=CCTintTo:create(0.5,255,255,255)
                  local seq=CCSequence:createWithTwoActions(fadeOut,fadeIn)
                  selectSp:runAction(CCRepeatForever:create(seq))
            elseif ifDaily==2 then
                  local itemNum=SizeOfTable(itemTab)
                  local cellHeight=85
                  local cellWidth=self.bgSize.width-20

                  local tvHeight=550
                  sizeLb=sizeLb+tvHeight
                local function tvCallBack(handler,fn,idx,cel)
                        if fn=="numberOfCellsInTableView" then
                              local num=math.ceil(itemNum/2)
                              return num
                        elseif fn=="tableCellSizeForIndex" then
                              --local cellWidth=self.bgLayer:getContentSize().width-50
                              --local cellHeight=110
                              local tmpSize=CCSizeMake(cellWidth,cellHeight)
                              return  tmpSize
                        elseif fn=="tableCellAtIndex" then
                              local cell=CCTableViewCell:new()
                              cell:autorelease()

                              local index=idx*2
                              for k=1,2 do
                                    local width=(k-1)*240
                                    local height=0
                                    local v=itemTab[index+k]
                                    if v and v.pic and v.name and v.num then
                                          --local width = 30+((k-1)%2)*250
                                          --local height = sizeLb-(math.floor((k+1)/2))*60
                                          local icon = CCSprite:createWithSpriteFrameName(v.pic)
                                      icon:setAnchorPoint(ccp(0,0))
                                          icon:setPosition(ccp(width,height))
                                          cell:addChild(icon,1)
                                          local scaleX=1
                                          local scaleY=1
                                          local scaleNum=0.8
                                          if icon:getContentSize().width>100 then
                                                scaleX=100/150*scaleNum
                                                scaleY=100/150*scaleNum
                                          else
                                                scaleX=scaleNum
                                                scaleY=scaleNum
                                          end
                                          icon:setScaleX(scaleX)
                                          icon:setScaleY(scaleY)
                                          width=width+icon:getContentSize().width*scaleX
                                          height=height+10

                                          local nameLable = GetTTFLabelWrap(v.name,textSize,CCSizeMake(textSize*6,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                                      nameLable:setAnchorPoint(ccp(0,0))
                                      nameLable:setPosition(ccp(width+5,height+textSize*1.5))
                                          cell:addChild(nameLable,1)

                                          local numLable = GetTTFLabel("x"..v.num,textSize)
                                      numLable:setAnchorPoint(ccp(0,0))
                                      numLable:setPosition(ccp(width+5,height))
                                          cell:addChild(numLable,1)
                                    end
                              end

                              return cell
                        elseif fn=="ccTouchBegan" then
                              isMoved=false
                              return true
                        elseif fn=="ccTouchMoved" then
                              isMoved=true
                        elseif fn=="ccTouchEnded"  then

                        end
                end
                  --local cellWidth=self.bgLayer:getContentSize().width-100
                local hd= LuaEventHandler:createHandler(tvCallBack)
                  local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,tvHeight),nil)
                tableView:setTableViewTouchPriority(-(layerNum-1)*20-3)
                tableView:setPosition(ccp(35,20))
                self.bgLayer:addChild(tableView,2)
                tableView:setMaxDisToBottomOrTop(120)
            end
      else
          local addPosx = bgSrc == "rewardPanelBg1.png" and 10 or 0
          sizeLb=sizeLb+(math.ceil(SizeOfTable(itemTab)/2)+1)*120-90
            for k,v in pairs(itemTab) do
                  if v and v.pic and v.name and v.num then
                        local width = 30+((k-1)%2)*250 + addPosx
                        local height = sizeLb-(math.floor((k+1)/2))*120
                        -- local icon = CCSprite:createWithSpriteFrameName(v.pic)
                        local icon = G_getItemIcon(v,100)
                    icon:setAnchorPoint(ccp(0,0))
                        icon:setPosition(ccp(width,height))
                        self.bgLayer:addChild(icon,1)
                        -- if icon:getContentSize().width>100 then
                        --       icon:setScaleX(100/150)
                        --       icon:setScaleY(100/150)
                        -- end

                local nameStr
                if isLocalName==true then
                    nameStr=v.name
                else
                    nameStr=getlocal(v.name)
                end
                        local nameLable = GetTTFLabelWrap(nameStr,textSize,CCSizeMake(textSize*6,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    nameLable:setAnchorPoint(ccp(0,0.5))
                    nameLable:setPosition(ccp(width+100+5,height+75))
                        self.bgLayer:addChild(nameLable,1)


                        local numLable = GetTTFLabel(FormatNumber(v.num),textSize)
                    numLable:setAnchorPoint(ccp(0,0))
                    numLable:setPosition(ccp(width+100+5,height+5))
                        self.bgLayer:addChild(numLable,1)
                  end
            end
      end

    local textWrapNum = size.width/textSize

    for k,v in pairs(textTab) do
        local lable = GetTTFLabel(v,textSize);

            local textWidth=textSize*19
            --if lable:getContentSize().width>textWidth then
                  local heightNum = math.ceil(lable:getContentSize().width/textWidth)
            lable=nil
            if k==5 and G_isIOS()==false then
                lable = GetTTFLabelWrap(v,textSize,CCSize(textWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            else
                lable = GetTTFLabelWrap(v,textSize,CCSize(textWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            end
        --end
        lable:setAnchorPoint(ccp(0,0));
        lable:setPosition(ccp(40,sizeLb));
        self.bgLayer:addChild(lable,2);

        if textColorTab~=nil then
            if textColorTab[k]~= nil then
                lable:setColor(textColorTab[k])
            else
                lable:setColor(G_ColorWhite)
            end
        end

        sizeLb = sizeLb+lable:getContentSize().height;
        self.bgLayer:setContentSize(CCSizeMake(550,sizeLb+25))

        if ifDaily~=2 and v and string.gsub(v, "%s", "")~="" and k~=SizeOfTable(textTab) then
              if bgSrc == "rewardPanelBg1.png" then
                local  lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(26,0,2,6),function() end)
                lineSp:setPosition(self.bgLayer:getContentSize().width * 0.5,sizeLb+textSize * 0.5)
                lineSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 80,lineSp:getContentSize().height))
                self.bgLayer:addChild(lineSp)

              else
                local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
                lineSprite:setAnchorPoint(ccp(0.5,0.5))
                lineSprite:setPosition(ccp(self.bgLayer:getContentSize().width * 0.5,sizeLb+textSize * 0.5))
                self.bgLayer:addChild(lineSprite,2)
                lineSprite:setScaleX(0.8)
                lineSprite:setScaleY(0.5)
              end
        end

        if k == 1 and bgSrc == "rewardPanelBg1.png" then
            local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
            dialogBg2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width - 50,sizeLb - 50 ))
            dialogBg2:setAnchorPoint(ccp(0.5,0))
            dialogBg2:setPosition(self.bgLayer:getContentSize().width * 0.5,20)
            self.bgLayer:addChild(dialogBg2)
        end
    end


    self.bgLayer:setContentSize(CCSizeMake(550,sizeLb+25+15))
    self:show()

    local function touchDialog()
            if isMoved==false then
              PlayEffect(audioCfg.mouseClick)
            self:close()
            end
    end
    --local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchDialog);
      local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    --touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
      touchDialogBg:setPosition(ccp(0,0))
    --self.bgLayer:addChild(touchDialogBg,1);
      self.dialogLayer:addChild(touchDialogBg)
      self.dialogLayer:setBSwallowsTouches(true)

    self.dialogLayer:addChild(self.bgLayer,1);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
      self.dialogLayer:setBSwallowsTouches(false)
    self:userHandler()

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(getCenterPoint(sceneGame))


    if bgSrc == "rewardPanelBg1.png" then
        local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
        pointSp1:setPosition(ccp(5,self.bgLayer:getContentSize().height/2))
        self.bgLayer:addChild(pointSp1)
        local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
        pointSp2:setPosition(ccp(self.bgLayer:getContentSize().width-5,self.bgLayer:getContentSize().height/2))
        self.bgLayer:addChild(pointSp2)

        local lineSp1=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
        lineSp1:setAnchorPoint(ccp(0.5,1))
        lineSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height))
        self.bgLayer:addChild(lineSp1)
        local lineSp2=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
        lineSp2:setAnchorPoint(ccp(0.5,0))
        lineSp2:setPosition(ccp(self.bgLayer:getContentSize().width/2,lineSp2:getContentSize().height))
        self.bgLayer:addChild(lineSp2)
        lineSp2:setRotation(180)


        -- 下面的点击屏幕继续
        local clickLbPosy=-80
        local tmpLb=GetTTFLabel(getlocal("click_screen_continue"),25)
        local clickLb=GetTTFLabelWrap(getlocal("click_screen_continue"),25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        clickLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,clickLbPosy))
        self.bgLayer:addChild(clickLb)
        local arrowPosx1,arrowPosx2
        local realWidth,maxWidth=tmpLb:getContentSize().width,clickLb:getContentSize().width
        if realWidth>maxWidth then
            arrowPosx1=self.bgLayer:getContentSize().width/2-maxWidth/2
            arrowPosx2=self.bgLayer:getContentSize().width/2+maxWidth/2
        else
            arrowPosx1=self.bgLayer:getContentSize().width/2-realWidth/2
            arrowPosx2=self.bgLayer:getContentSize().width/2+realWidth/2
        end
        local smallArrowSp1=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
        smallArrowSp1:setPosition(ccp(arrowPosx1-15,clickLbPosy))
        self.bgLayer:addChild(smallArrowSp1)
        local smallArrowSp2=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
        smallArrowSp2:setPosition(ccp(arrowPosx1-25,clickLbPosy))
        self.bgLayer:addChild(smallArrowSp2)
        smallArrowSp2:setOpacity(100)
        local smallArrowSp3=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
        smallArrowSp3:setPosition(ccp(arrowPosx2+15,clickLbPosy))
        self.bgLayer:addChild(smallArrowSp3)
        smallArrowSp3:setRotation(180)
        local smallArrowSp4=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
        smallArrowSp4:setPosition(ccp(arrowPosx2+25,clickLbPosy))
        self.bgLayer:addChild(smallArrowSp4)
        smallArrowSp4:setOpacity(100)
        smallArrowSp4:setRotation(180)

        local space=20
        smallArrowSp1:runAction(G_actionArrow(1,space))
        smallArrowSp2:runAction(G_actionArrow(1,space))
        smallArrowSp3:runAction(G_actionArrow(-1,space))
        smallArrowSp4:runAction(G_actionArrow(-1,space))


    end


      return self.dialogLayer
end

function smallDialog:initRewardDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,textTab,textSize,itemTab,textColorTab,ifDaily)
    self.isTouch=nil
    self.isUseAmi=isuseami
    local function tmpFunc()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,tmpFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size

    local isMoved=false
    local sizeLb=0
    sizeLb=sizeLb+(SizeOfTable(itemTab)+1)*84

    local width = 30
    local height

    for k,v in pairs(itemTab) do
       if v and v.name and v.num then

                if height ~= nil then
                    height = height + 84
                else
                    height = 80
                end

                local icon = G_getItemIcon(v,80)
                icon:setAnchorPoint(ccp(0,0.5))
                icon:setPosition(ccp(width,height))
                self.bgLayer:addChild(icon,1)
                if icon:getContentSize().width>80 then
                    local iconW = icon:getContentSize().width
                    local iconH = icon:getContentSize().height
                    icon:setScaleX(80/iconW)
                    icon:setScaleY(80/iconH)
                end

                local nameLable = GetTTFLabel(v.name.." x "..v.num,textSize)
                nameLable:setAnchorPoint(ccp(0,0.5))
                nameLable:setPosition(ccp(width+100,height))
                self.bgLayer:addChild(nameLable,1)
        end
    end
    local textWrapNum = size.width/textSize

    for k,v in pairs(textTab) do
        local lable = GetTTFLabel(v,textSize);

        local textWidth=textSize*19
        local heightNum = math.ceil(lable:getContentSize().width/textWidth)
        lable=nil
        if k==5 and G_isIOS()==false then
            lable = GetTTFLabelWrap(v,textSize,CCSize(textWidth,(heightNum+1)*(textSize+5)),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        else
            lable = GetTTFLabelWrap(v,textSize,CCSize(textWidth,heightNum*(textSize+5)),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        end
        lable:setAnchorPoint(ccp(0,0));
        lable:setPosition(ccp(30,sizeLb));
        self.bgLayer:addChild(lable,2);

        if textColorTab~=nil then
            if textColorTab[k]~= nil then
                lable:setColor(textColorTab[k])
            else
                lable:setColor(G_ColorWhite)
            end
        end
        sizeLb = sizeLb+lable:getContentSize().height;
    end

    self.bgLayer:setContentSize(CCSizeMake(550,sizeLb+25))
    self:show()

    local function touchDialog()
        if isMoved==false then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
    local rect=CCSizeMake(G_VisibleSize.width,G_VisibleSize.height)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg)
    self.dialogLayer:setBSwallowsTouches(true)

    self.dialogLayer:addChild(self.bgLayer,1);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(false)
    self:userHandler()

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(getCenterPoint(sceneGame))

    return self.dialogLayer
end

function smallDialog:showFriendInfoSmallDialog(isMyFriend,callback,bgSrc,size,fullRect,inRect,title,vo,layerNum,isuseami)
      local sd=smallDialog:new()
      sd:initFriendInfoSmallDialog(isMyFriend,callback,bgSrc,size,fullRect,inRect,title,vo,layerNum,isuseami)
      return sd
end

--好友info板子
function smallDialog:initFriendInfoSmallDialog(isMyFriend,callback,bgSrc,size,fullRect,inRect,title,vo,layerNum,isuseami)
    --GM判断
    local myChenghaoH=0
    if playerVoApi:getSwichOfGXH() and vo.title and tostring(vo.title)~="" and tostring(vo.title)~="0" then
        myChenghaoH=65
        size.height=size.height+myChenghaoH
    end
    self.isTouch=nil
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)

    self.dialogLayer=CCLayer:create()

    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    if self.isUseAmi then
        self:show()
    end

    local function touchDialog()

    end

    self.dialogLayer:addChild(self.bgLayer,1);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

  local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd,fn,idx)
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",inRect,cellClick)

    backSprie:setContentSize(CCSizeMake(size.width-20, size.height-260))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0,0))
    backSprie:setPosition(ccp(10,size.height-360-myChenghaoH))
    dialogBg:addChild(backSprie,1)

    if playerVoApi:getSwichOfGXH() and vo.title and tostring(vo.title)~="" and tostring(vo.title)~="0"  then
      local function nilFunc()
      end
      local titleBg =LuaCCScale9Sprite:createWithSpriteFrameName("iconTitlebg.png",CCRect(27, 29, 2, 2),nilFunc)
      titleBg:setContentSize(CCSizeMake(size.width-200, 60))
      titleBg:ignoreAnchorPointForPosition(false);
      titleBg:setAnchorPoint(ccp(0.5,1));
      backSprie:addChild(titleBg)
      titleBg:setPosition(backSprie:getContentSize().width/2, backSprie:getContentSize().height-10)
      for i=1,2 do
        local cStar=CCSprite:createWithSpriteFrameName("StarIcon.png")
        titleBg:addChild(cStar)
        if i==1 then
          cStar:setPosition(titleBg:getContentSize().width-cStar:getContentSize().width/2+10, titleBg:getContentSize().height/2)
        else
          cStar:setPosition(cStar:getContentSize().width/2-10, titleBg:getContentSize().height/2)
        end

      end


      local nameStr = "player_title_name_" .. vo.title
      local nameLb = GetTTFLabel(getlocal(nameStr),25)
      nameLb:setPosition(titleBg:getContentSize().width/2, titleBg:getContentSize().height/2)
      nameLb:setColor(G_ColorYellowPro)
      titleBg:addChild(nameLb)

    end

  local function close()
        PlayEffect(audioCfg.mouseClick)
    if closeCallBack then
      closeCallBack()
    end
      return self:close()
  end
  local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
  closeBtnItem:setPosition(0,0)
  closeBtnItem:setAnchorPoint(CCPointMake(0,0))

  self.closeBtn = CCMenu:createWithItem(closeBtnItem)
  self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
  self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
  dialogBg:addChild(self.closeBtn)

    local titleLb=GetTTFLabel(title,30)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height-5))
    dialogBg:addChild(titleLb,1)

    if vo and vo.pic then
        -- local personPhotoName="photo"..vo.pic..".png"
        -- local playerPic = GetBgIcon(personPhotoName)
         local personPhotoName=playerVoApi:getPersonPhotoName(vo.pic)
         local playerPic
        if GM_UidCfg[tonumber(vo.uid)] then
           playerPic = playerVoApi:GetPlayerBgIcon(personPhotoName,nil,nil,50,nil,vo.bpic,tonumber(vo.uid))
        else
           playerPic = playerVoApi:GetPlayerBgIcon(personPhotoName,nil,nil,nil,nil,vo.bpic)
        end
        playerPic:setAnchorPoint(ccp(0,1))
        playerPic:setPosition(ccp(10,size.height-5))
        dialogBg:addChild(playerPic,1)
    end

    local hSpace=65
    local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSprite:setAnchorPoint(ccp(0.5,0.5))
    lineSprite:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height-2-(hSpace)-myChenghaoH))
    backSprie:addChild(lineSprite,2)
    lineSprite:setScaleX(0.8)

    local content1=getlocal("player_message_info_name",{vo.nickname,vo.level,playerVoApi:getRankName(vo.rank)})

    local contentLb = GetTTFLabelWrap(content1,30,CCSizeMake(backSprie:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    contentLb:setAnchorPoint(ccp(0,1))
    local height = backSprie:getContentSize().height-20-myChenghaoH
    contentLb:setPosition(ccp(20,height))
    backSprie:addChild(contentLb,2)


    local contentLb = GetTTFLabelWrap(getlocal("player_message_info_power").."    "..vo.fc,25,CCSizeMake(backSprie:getContentSize().width-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter);
    contentLb:setAnchorPoint(ccp(0,1))
    local height = backSprie:getContentSize().height-20-((2-1)*hSpace)-myChenghaoH
    contentLb:setPosition(ccp(20,height))
    backSprie:addChild(contentLb,2)

    if bagVoApi:isShowSearchBtn()==true then
        local function showSelectSmallDialog()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            bagVoApi:showSelectSearchSmallDialog(vo.nickname,layerNum+1)
        end
        local selectItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",showSelectSmallDialog,101,getlocal("scout_btn"),25)
        selectItem:setScale(0.6)
        selectMenu=CCMenu:createWithItem(selectItem)
        local height1 = height-selectItem:getContentSize().height/2*0.8+10
        selectMenu:setPosition(ccp(backSprie:getContentSize().width-70,height1))
        selectMenu:setTouchPriority(-(layerNum-1)*20-2)
        backSprie:addChild(selectMenu)
    end

    local function leftHandler()
      require "luascript/script/game/scene/gamedialog/emailDetailDialog"
      local lyNum=layerNum+2
      emailVoApi:showWriteEmailDialog(lyNum,getlocal("email_write"),vo.nickname)
      self:close()
    end

    local leftItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",leftHandler,2,getlocal("email_write"),25)
    local leftMenu=CCMenu:createWithItem(leftItem);
    leftMenu:setPosition(ccp(150,size.height-400-myChenghaoH))
    leftMenu:setTouchPriority(-(layerNum-1)*20-2);
    dialogBg:addChild(leftMenu)

    local function rightHandler()
      if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end
      PlayEffect(audioCfg.mouseClick)
      chatVoApi:showChatDialog(layerNum+1,nil,vo.uid,vo.nickname,true)
      self:close()
    end

    local rightItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rightHandler,2,getlocal("chat_private"),25)
    local rightMenu=CCMenu:createWithItem(rightItem);
    rightMenu:setPosition(ccp(size.width-150,size.height-400-myChenghaoH))
    rightMenu:setTouchPriority(-(layerNum-1)*20-2);
    dialogBg:addChild(rightMenu)

    local btnStr=""
    if isMyFriend==true then
       btnStr=getlocal("delFriend")
    else
       btnStr=getlocal("addFriend")
    end

    if tonumber(vo.uid)~=playerVoApi:getUid() then

            local function call( ... )
              callback()
              self:close()
            end

            local callItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",call,2,btnStr,25)
            if GM_UidCfg[tonumber(vo.uid)] then
              callItem:setEnabled(false)
            end
            local callMenu=CCMenu:createWithItem(callItem);
            callMenu:setPosition(ccp(150,size.height-480-myChenghaoH))
            callMenu:setTouchPriority(-(layerNum-1)*20-2);
            dialogBg:addChild(callMenu)
     end

    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg)

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(getCenterPoint(sceneGame))

    return self.dialogLayer

end

--type 1聊天玩家信息 2自己的基地 3别人的基地 4资源岛 5收藏 6跨平台战聊天玩家信息
function smallDialog:initPlayerInfoSmallDialog(bgSrc,size,fullRect,inRect,leftStr,leftCallBack,rightStr,rightCallBack,title,content,isuseami,layerNum,type,itemTab,closeCallBack,protected,pic,str3,callBack3,str4,callBack4,rank,serverWarRank,startTime,chenghao,targetName,vipPic,isGM,rpoint,hfid,uid)
    if isGM == nil then
      isGM = false
    end
    -- 如果有称号
    local myChenghaoH,gmUseSubHeight = 0,0
    local useInGM_Tb = {}
    -- chenghao = 12
    if playerVoApi:getSwichOfGXH() and chenghao and tostring(chenghao)~="" and tostring(chenghao)~="0" then
      myChenghaoH=65
      size.height=size.height+myChenghaoH
    end
    if isGM then
        gmUseSubHeight = 50
        size.height = size.height - gmUseSubHeight
    end
    self.isTouch=nil
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()

    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    if self.isUseAmi then
        self:show()
    else
        table.insert(G_SmallDialogDialogTb,self)
    end

    local function touchDialog()

    end

    self.dialogLayer:addChild(self.bgLayer,1);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local capInSet = CCRect(20, 20, 10, 10)
    local function cellClick(hd,fn,idx)
    end
    local backSprie = type== 1 and LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),cellClick) or LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",inRect,cellClick)
    if (str3 and callBack3) or (str4 and callBack4) then
        backSprie:setContentSize(CCSizeMake(size.width-20, size.height-260-gmUseSubHeight))
    else
        backSprie:setContentSize(CCSizeMake(size.width-20, size.height-180-gmUseSubHeight))
    end
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0,0))
    backSprie:setPosition(ccp(10,size.height-360-myChenghaoH))
    if type==1 then
      backSprie:setOpacity(0)
    end

    dialogBg:addChild(backSprie,1)

    if playerVoApi:getSwichOfGXH() and chenghao and tostring(chenghao)~="" and tostring(chenghao)~="0"  then
      local nameStr = "player_title_name_" .. chenghao
      local nameLb = GetTTFLabel(getlocal(nameStr),25)

      local function nilFunc()
        if G_checkClickEnable()==false then
            do return  end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        local scaleTo1=CCScaleTo:create(0.1,0.9)
        local scaleTo2=CCScaleTo:create(0.1,1)
        local function callBack()
          local nameStr = getlocal("player_title_name_" .. chenghao)
          local desStr = getlocal("player_title_des_" .. chenghao)
          local td=smallDialog:new()
          local textTab={desStr}
          local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,layerNum+1,textTab,25,nil,nameStr)
          sceneGame:addChild(dialog,layerNum+1)
        end
        local callFunc=CCCallFunc:create(callBack)

        local acArr=CCArray:create()
        acArr:addObject(scaleTo1)
        acArr:addObject(callFunc)
        acArr:addObject(scaleTo2)
        local seq=CCSequence:create(acArr)
        self.titleBg:runAction(seq)
      end
      local adaH = 0
      if str3==nil and callback3==nil and str4==nil and callback4==nil and isGM==true then
        adaH = 50
      end
      local titleBg =LuaCCScale9Sprite:createWithSpriteFrameName("iconTitlebg.png",CCRect(27, 29, 2, 2),nilFunc)
      titleBg:setContentSize(CCSizeMake(nameLb:getContentSize().width+210, 60))
      titleBg:ignoreAnchorPointForPosition(false);
      titleBg:setAnchorPoint(ccp(0.5,1));
      backSprie:addChild(titleBg)
      titleBg:setTouchPriority(-(layerNum-1)*20-4)
      titleBg:setOpacity(0)
      self.titleBg=titleBg

      local function lightAction()
        local fadeIn=CCFadeIn:create(0.4)
        local fadeOut=CCFadeOut:create(0.4)
        local arr=CCArray:create()
        arr:addObject(fadeIn)
        arr:addObject(fadeOut)
        local seq=CCSequence:create(arr)
        return seq
      end

      local function sbCallback()
      end
      local title1Bg =LuaCCScale9Sprite:createWithSpriteFrameName("playerTitleBg1.png",CCRect(120, 22, 1, 1),sbCallback)
      title1Bg:setContentSize(CCSizeMake(titleBg:getContentSize().width/2,45))
      title1Bg:setAnchorPoint(ccp(0,0.5));
      titleBg:addChild(title1Bg)
      title1Bg:setPosition(0,titleBg:getContentSize().height/2-adaH)

      local guang1Sp=CCSprite:createWithSpriteFrameName("playerTitleBg4.png")
      title1Bg:addChild(guang1Sp)
      guang1Sp:setPosition(55,40)
      guang1Sp:setOpacity(0)

      -- guang1Sp:runAction(lightAction(0,2))

      local function sbCallback()
      end
      local title2Bg =LuaCCScale9Sprite:createWithSpriteFrameName("playerTitleBg2.png",CCRect(44, 22, 1, 1),sbCallback)
      title2Bg:setContentSize(CCSizeMake(titleBg:getContentSize().width/2,45))
      title2Bg:setAnchorPoint(ccp(1,0.5));
      titleBg:addChild(title2Bg)
      title2Bg:setPosition(titleBg:getContentSize().width,titleBg:getContentSize().height/2-adaH)
      local guang2Sp=CCSprite:createWithSpriteFrameName("playerTitleBg4.png")
      title2Bg:addChild(guang2Sp)
      guang2Sp:setPosition(title2Bg:getContentSize().width-30,30)
      guang2Sp:setOpacity(0)



      local function acCallback()
        local lightNum=math.random(0,9)
        if lightNum<5 then
          guang1Sp:runAction(lightAction())
        else
          guang2Sp:runAction(lightAction())
        end
      end
      local callFunc=CCCallFunc:create(acCallback)
      local delay=CCDelayTime:create(3)
      local seq=CCSequence:createWithTwoActions(callFunc,delay)
      local repeatForever=CCRepeatForever:create(seq)
      self.bgLayer:runAction(repeatForever)


      -- guang2Sp:runAction(lightAction(1,1))

      local title3Bg=CCSprite:createWithSpriteFrameName("playerTitleBg3.png")
      title3Bg:setPosition(titleBg:getContentSize().width/2,titleBg:getContentSize().height/2-10-adaH)
      titleBg:addChild(title3Bg)

      local subPosY = type== 1 and 0 or 10
      titleBg:setPosition(backSprie:getContentSize().width/2, backSprie:getContentSize().height-subPosY)
      -- for i=1,2 do
      --   local cStar=CCSprite:createWithSpriteFrameName("StarIcon.png")
      --   titleBg:addChild(cStar)
      --   if i==1 then
      --     cStar:setPosition(titleBg:getContentSize().width-cStar:getContentSize().width/2+10, titleBg:getContentSize().height/2)
      --   else
      --     cStar:setPosition(cStar:getContentSize().width/2-10, titleBg:getContentSize().height/2)
      --   end

      -- end


      -- local nameStr = "player_title_name_" .. chenghao
      -- local nameLb = GetTTFLabel(getlocal(nameStr),25)

      nameLb:setPosition(titleBg:getContentSize().width/2, titleBg:getContentSize().height/2+15-adaH)
      nameLb:setColor(G_ColorYellowPro)
      titleBg:addChild(nameLb,3)

      local posX,posY=nameLb:getPosition()

      local posTb={ccp(posX+1,posY),ccp(posX-1,posY),ccp(posX,posY+1),ccp(posX,posY-1)}
      for k,v in pairs(posTb) do
        local nameLb = GetTTFLabel(getlocal(nameStr),25)
        nameLb:setPosition(v)
        nameLb:setColor(G_ColorBlack)
        titleBg:addChild(nameLb)
        -- if k==4 then
        --   nameLb:setColor(G_ColorYellowPro)
        -- end
      end

    end

      local function close()
          PlayEffect(audioCfg.mouseClick)
          if closeCallBack then
                closeCallBack()
          end
          return self:close()
      end
      local closeImg,closeImgDown = "closeBtn.png","closeBtn_Down.png"
      if type== 1 then
          closeImg,closeImgDown = "newCloseBtn.png","newCloseBtn_Down.png"
      end
      local closeBtnItem = GetButtonItem(closeImg,closeImgDown,closeImgDown,close,nil,nil,nil);
      -- closeBtnItem:setPosition(0,0)
      closeBtnItem:setAnchorPoint(CCPointMake(1,1))

      self.closeBtn = CCMenu:createWithItem(closeBtnItem)
      self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
      self.closeBtn:setPosition(ccp(dialogBg:getContentSize().width-5,dialogBg:getContentSize().height-5))
      dialogBg:addChild(self.closeBtn)

      local titleLb=GetTTFLabel(title,30)
      titleLb:setAnchorPoint(ccp(0.5,0.5))
      titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height-5))
      dialogBg:addChild(titleLb,1)
      local titleBackspire
      if type== 1 then
        titleBackspire =CCSprite:createWithSpriteFrameName("newTitleBg.png")
        titleBackspire:setAnchorPoint(ccp(0.5,1))
        titleBackspire:setPosition(size.width/2,size.height)
        dialogBg:addChild(titleBackspire)
      end

      local useWidthInType_1 = 0
      local useScaleInType_1 = 1.5
      local useScaleHeigtTbInType_1 = {}
      local playerPicPosX,playerPicPosY = 0,0
      local usePlayerNameInType_1 = ""
      local iconsBg,vipIcon,vipIconWidth = nil,nil,0
      if type== 1 then
          iconsBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
          -- iconsBg:setContentSize(CCSizeMake(backSprie:getContentSize().width-10,50))
          iconsBg:setOpacity(0)
          iconsBg:setAnchorPoint(ccp(0.5,0))
          iconsBg:setPosition(ccp(backSprie:getContentSize().width*0.5,30))
          backSprie:addChild(iconsBg)
          if vipPic and G_chatVip==true and isGM == false then
              local function showTip()
                  -- print("vip~~~~~~~")
                  if G_checkClickEnable()==false then
                      do return  end
                  else
                      base.setWaitTime=G_getCurDeviceMillTime()
                  end
                  PlayEffect(audioCfg.mouseClick)
                  local function callback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                      if sData and sData.data and sData.data.vipRewardCfg then
                        vipVoApi:setVipReward(sData.data.vipRewardCfg)
                        local vf = vipVoApi:getVf(vf)
                        for k,v in pairs(vf) do
                          vipVoApi:setRealReward(v)
                        end
                        vipVoApi:setVipFlag(true)
                        vipVoApi:openVipDialog(layerNum+1,true)
                        self:close()
                      end
                    end
                  end
                  if vipVoApi:getVipFlag()==false then
                    socketHelper:vipgiftreward(callback)
                  else
                    vipVoApi:openVipDialog(layerNum+1,true)
                    self:close()
                  end
              end
              vipIcon=LuaCCSprite:createWithSpriteFrameName(vipPic,showTip)
              vipIcon:setTouchPriority(-(layerNum-1)*20-4)
              -- vipIcon = CCSprite:createWithSpriteFrameName(vipPic)
              local vipIconScale = 0.9
              vipIcon:setScale(vipIconScale)
              vipIconWidth = vipIcon:getContentSize().width*vipIconScale
              vipIcon:setAnchorPoint(ccp(0,0.5))
              iconsBg:setContentSize(CCSizeMake(vipIconWidth,vipIcon:getContentSize().height))
              vipIcon:setPosition(ccp(0,iconsBg:getContentSize().height*0.25))
              iconsBg:addChild(vipIcon)
          end
      end
      if (type==1 or type==2 or type==3) and pic then
            --local playerPic = CCSprite:createWithSpriteFrameName("Photo01.png")
            -- local personPhotoName="photo"..pic..".png"
            -- local playerPic = GetBgIcon(personPhotoName)
            local personPhotoName=playerVoApi:getPersonPhotoName(pic)
            local playerPic = isGM and CCSprite:createWithSpriteFrameName(GM_Icon) or playerVoApi:GetPlayerBgIcon(personPhotoName,nil,nil,nil,nil,hfid)
            playerPic:setAnchorPoint(ccp(0,1))
            if type== 1 then
              playerPic:setPosition(ccp(20,backSprie:getContentSize().height-myChenghaoH))
              playerPic:setScale(useScaleInType_1)
              backSprie:addChild(playerPic,1)
              useWidthInType_1 = playerPic:getContentSize().width*useScaleInType_1
              playerPicPosY = playerPic:getPositionY()
              playerPicPosX = playerPic:getPositionX()
              useScaleHeigtTbInType_1 = {playerPicPosY-5,playerPicPosY-useWidthInType_1*0.54,playerPicPosY-useWidthInType_1*0.78,playerPicPosY-useWidthInType_1-20}
            else
              playerPic:setPosition(ccp(10,size.height-5))
              dialogBg:addChild(playerPic,1)
            end
            if isGM then
                useScaleInType_1 = 0.9
                playerPic:setScale(useScaleInType_1)
                useWidthInType_1 = playerPic:getContentSize().width*useScaleInType_1
                useScaleHeigtTbInType_1 = {playerPicPosY-5,playerPicPosY-useWidthInType_1*0.54,playerPicPosY-useWidthInType_1*0.78,playerPicPosY-useWidthInType_1-20}
                useInGM_Tb[1] = playerPic
            end
      end

      local hSpace=65
      if content~=nil then
          --for k,v in pairs(content) do
            for k=1,4 do
                  if type==4 then
                  elseif type== 1 then
                        if k == 1 then
                            local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
                            lineSp:setAnchorPoint(ccp(0.5,0.5))
                            lineSp:setPosition(ccp(backSprie:getContentSize().width*0.5,useScaleHeigtTbInType_1[4]-60))
                            backSprie:addChild(lineSp,2)
                            lineSp:setScaleX(0.8)
                        end
                  elseif type==5 then
                        if k==2 then
                              local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
                              lineSprite:setAnchorPoint(ccp(0.5,0.5))
                              lineSprite:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height-2-(k*hSpace)))
                              backSprie:addChild(lineSprite,2)
                              lineSprite:setScaleX(0.8)
                        end
                  elseif k~=1 and k~=SizeOfTable(content) then
                        local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
                        lineSprite:setAnchorPoint(ccp(0.5,0.5))
                        lineSprite:setPosition(ccp(backSprie:getContentSize().width/2,backSprie:getContentSize().height-myChenghaoH-2-(k*hSpace)))
                        backSprie:addChild(lineSprite,2)
                        lineSprite:setScaleX(0.8)
                  end
                  local v=content[k]
                  if v~=nil then
                        local message=v[1]
                        if type==1 and k == 1 then
                            usePlayerNameInType_1 = message
                        end
                        local size=v[2]
                        local color=v[3]
                        if message==nil then
                              message=""
                        end
                        if size==nil then
                              size=30
                        end
                        local contentSize = backSprie:getContentSize().width-100
                        if G_getCurChoseLanguage() =="ar" then
                            contentSize = 300
                            playerPicPosX = 0
                        end
                        if isGM then
                          if k == 1 then
                              -- message = GM_Name
                          else
                              message = ""
                          end
                        end
                        local contentLb = GetTTFLabelWrap(message,size,CCSizeMake(contentSize,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter);
                        contentLb:setAnchorPoint(ccp(0,1))
                        local height = backSprie:getContentSize().height-myChenghaoH-20-((k-1)*hSpace)
                        contentLb:setPosition(ccp(20+useWidthInType_1,height))
                        if isGM and k == 1 then
                            useInGM_Tb[2] = contentLb
                        end

                        if type== 1 then

                            if k == 4 then
                              contentLb:setPosition(ccp(playerPicPosX+5,useScaleHeigtTbInType_1[k]))
                            else
                              contentLb:setPosition(ccp(10+useWidthInType_1+playerPicPosX,useScaleHeigtTbInType_1[k]))
                            end
                        end
                        backSprie:addChild(contentLb,2)

                        if color~=nil then
                            contentLb:setColor(color)
                        end
                        if (type==1 or type==6) and k==1 and isGM == false then
                          --军衔图标
                          local rankSpWidth = 0
                          local rankSp=nil
                          local spScale=0.8
                          if rank and rank>0 then
                            local pic=playerVoApi:getRankIconName(rank)
                            if pic then
                              if type== 1 then
                                  local function showTip()
                                      -- print("ranksp~~~~~~~")
                                      if G_checkClickEnable()==false then
                                          do return  end
                                      else
                                          base.setWaitTime=G_getCurDeviceMillTime()
                                      end
                                      PlayEffect(audioCfg.mouseClick)
                                      require "luascript/script/game/scene/gamedialog/playerDialog/playerRankDialog"
                                      local dialog=playerRankDialog:new()
                                      local layer=dialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("help2_t1_t3"),true,layerNum+1)
                                      sceneGame:addChild(layer,layerNum+1)
                                      self:close()
                                  end
                                  rankSp=LuaCCSprite:createWithSpriteFrameName(pic,showTip)
                                  rankSp:setTouchPriority(-(layerNum-1)*20-4)
                              else
                                  rankSp=CCSprite:createWithSpriteFrameName(pic)
                              end
                              if rankSp then
                                  local contentLb1 = GetTTFLabel(message,size)
                                  local lbWidth=contentLb1:getContentSize().width
                                  if contentLb1:getContentSize().width>contentLb:getContentSize().width then
                                      lbWidth=contentLb:getContentSize().width
                                  end
                                  rankSp:setScale(spScale)
                                  rankSp:setPosition(lbWidth+rankSp:getContentSize().width/2*spScale+30,height-rankSp:getContentSize().height/2*spScale+5)
                                  if G_getCurChoseLanguage()=="ar" then
                                    rankSp:setPositionX(lbWidth+rankSp:getContentSize().width/2*spScale+30+lbWidth/2)
                                  end
                                  if type== 1 then
                                      iconsBg:setContentSize(CCSizeMake(iconsBg:getContentSize().width + rankSp:getContentSize().width + 5,iconsBg:getContentSize().height))
                                      rankSp:setPosition(ccp(vipIconWidth+5,iconsBg:getContentSize().height*0.25))
                                      rankSp:setAnchorPoint(ccp(0,0.5))
                                      iconsBg:addChild(rankSp)
                                      rankSpWidth = rankSp:getContentSize().width*spScale+5
                                  else
                                      backSprie:addChild(rankSp,2)
                                  end
                              end
                            end
                          end

                          --领土争夺战段位图标
                      --[[local segIcon=nil
                          local segIconScale=1
                          local segIconWidth=0
                          if rpoint then
                            local seg,smallLevel,totalSeg=ltzdzVoApi:getSegment(rpoint)
                            if seg then
                              local function segIconClickCallback()
                                G_goToDialog2("ltzdz",3,true)
                                self:close()
                              end
                              segIcon=ltzdzVoApi:getSegIcon(seg,smallLevel,segIconClickCallback,1)

                              local contentLb1 = GetTTFLabel(message,size)
                              local lbWidth=contentLb1:getContentSize().width
                              if contentLb1:getContentSize().width>contentLb:getContentSize().width then
                                  lbWidth=contentLb:getContentSize().width
                              end
                              if rankSp then
                                lbWidth=lbWidth+rankSp:getContentSize().width*spScale
                              end
                              segIcon:setTouchPriority(-(layerNum-1)*20-4)
                              segIcon:setScale(segIconScale)
                              segIcon:setPosition(ccp(20+lbWidth+segIcon:getContentSize().width/2*segIconScale+15,height-segIcon:getContentSize().height/2*segIconScale+5))
                              if type== 1 then
                                  iconsBg:setContentSize(CCSizeMake(iconsBg:getContentSize().width + segIcon:getContentSize().width*segIconScale + 5,iconsBg:getContentSize().height))
                                  segIcon:setPosition(ccp(rankSpWidth+vipIconWidth+5,iconsBg:getContentSize().height*0.25))
                                  segIcon:setAnchorPoint(ccp(0,0.5))
                                  iconsBg:addChild(segIcon)
                                  segIconWidth = segIcon:getContentSize().width*segIconScale+5
                              else
                                  backSprie:addChild(segIcon,2)
                              end
                            end
                          end--]]

                          --跨服战排名前3名称号图标--
                          if type==1 then
                              local wrIcon=nil
                              local iconScale=0.7
                              local serverWarRank=serverWarRank or 0
                              local startTime=startTime or 0

                              --假数据 策划看完需要删除！！！！！！！！！！@@@@@@@@@###################%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                              -- wrIcon=CCSprite:createWithSpriteFrameName("serverWarTopMedal1.png")
                              -- wrIcon:setScale(iconScale)
                              -- iconsBg:setContentSize(CCSizeMake(iconsBg:getContentSize().width + wrIcon:getContentSize().width*iconScale + 5,iconsBg:getContentSize().height))
                              -- wrIcon:setPosition(ccp(rankSpWidth+vipIconWidth+5,iconsBg:getContentSize().height*0.25))
                              -- wrIcon:setAnchorPoint(ccp(0,0.5))
                              -- iconsBg:addChild(wrIcon)

                              if serverWarRank and serverWarRank>0 and startTime and startTime>0 and serverWarPersonalVoApi then
                                local icon,sType=serverWarPersonalVoApi:getRankIcon(serverWarRank,startTime)--serverWarTopMedal1
                                if icon and (sType==1 or sType==2) then
                                    local function showTip()
                                        if G_checkClickEnable()==false then
                                            do return  end
                                        else
                                            base.setWaitTime=G_getCurDeviceMillTime()
                                        end
                                        PlayEffect(audioCfg.mouseClick)
                                        smallDialog:showServerWarRankDialog("TankInforPanel.png",CCSizeMake(550,250),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),true,layerNum+1,serverWarRank)
                                    end
                                    wrIcon=LuaCCSprite:createWithSpriteFrameName(icon,showTip)
                                    if wrIcon then
                                      local contentLb1 = GetTTFLabel(message,size)
                                      local lbWidth=contentLb1:getContentSize().width
                                      if contentLb1:getContentSize().width>contentLb:getContentSize().width then
                                          lbWidth=contentLb:getContentSize().width
                                      end
                                      if segIcon then
                                        lbWidth=lbWidth+segIcon:getContentSize().width*segIconScale
                                      elseif rankSp then
                                        lbWidth=lbWidth+rankSp:getContentSize().width*spScale
                                      end
                                      wrIcon:setTouchPriority(-(layerNum-1)*20-4)
                                      wrIcon:setScale(iconScale)
                                      wrIcon:setPosition(ccp(20+lbWidth+wrIcon:getContentSize().width/2*iconScale+15,height-wrIcon:getContentSize().height/2*iconScale+5))
                                      if type== 1 then
                                          iconsBg:setContentSize(CCSizeMake(iconsBg:getContentSize().width + wrIcon:getContentSize().width*iconScale + 5,iconsBg:getContentSize().height))
                                          wrIcon:setPosition(ccp(rankSpWidth+(segIconWidth or 0)+vipIconWidth+5,iconsBg:getContentSize().height*0.25))
                                          wrIcon:setAnchorPoint(ccp(0,0.5))
                                          iconsBg:addChild(wrIcon)
                                      else
                                          backSprie:addChild(wrIcon,2)
                                      end

                                      if sType==2 then
                                        local graySp=GraySprite:createWithSpriteFrameName(icon)
                                        if graySp then
                                          graySp:setPosition(getCenterPoint(wrIcon))
                                          wrIcon:addChild(graySp,1)
                                          wrIcon:setOpacity(0)
                                        end
                                      end
                                    end
                                end
                              end
                          end
                        end
                        --侦查按钮，弹出侦查敌人基地和部队的选择按钮面板
                        if type==1 and k==2 and targetName and bagVoApi:isShowSearchBtn()==true then
                          local function showSelectSmallDialog()
                              if G_checkClickEnable()==false then
                                  do return end
                              else
                                  base.setWaitTime=G_getCurDeviceMillTime()
                              end
                              PlayEffect(audioCfg.mouseClick)
                              bagVoApi:showSelectSearchSmallDialog(targetName,layerNum+1)
                          end
                          local selectItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",showSelectSmallDialog,101,getlocal("scout_btn"),25)
                          selectItem:setScale(0.6)
                          selectMenu=CCMenu:createWithItem(selectItem)
                          local height1 = height-selectItem:getContentSize().height/2*0.8+10
                          selectMenu:setPosition(ccp(backSprie:getContentSize().width-70,height1))
                          selectMenu:setTouchPriority(-(layerNum-1)*20-2)
                          if type~= 1 then
                              backSprie:addChild(selectMenu)
                          end
                        end
                  end
            end
      end

      if protected==true and type==3 then
            local protectedLb = GetTTFLabel(getlocal("city_info_protected_state"),25)
          protectedLb:setAnchorPoint(ccp(1,1))
          protectedLb:setPosition(ccp(backSprie:getContentSize().width-20,backSprie:getContentSize().height-20-(3*hSpace)))
            backSprie:addChild(protectedLb,2)
            protectedLb:setColor(G_ColorRed)
      end

      if itemTab then
            for k,v in pairs(itemTab) do
                  if v~=nil then
                        itemTab[k]:setTouchPriority(-(layerNum-1)*20-2)
                        backSprie:addChild(itemTab[k],2)
                        if type==5 then
                              if k==1 then
                                    itemTab[k]:setPosition(ccp(70,5))
                              end
                        elseif type==3 or type==2 or type==4 then
                              itemTab[k]:setPosition(ccp(470,backSprie:getContentSize().height-38-((k-1)*hSpace)))
                        end
                  end
            end
      end

    --左按钮

      local leftMenu
      local rightMenu
      if type==6 then

      else
          local leftItem
          if leftStr and leftCallBack then
              local function leftHandler()
                  if G_checkClickEnable()==false then
                      do return end
                  else
                      base.setWaitTime=G_getCurDeviceMillTime()
                  end
                  if type==1 then
                        local success=leftCallBack()
                        if success then
                            close()
                        else
                            PlayEffect(audioCfg.mouseClick)
                        end
                  else
                      if type==5 then
                          close()
                      else
                          PlayEffect(audioCfg.mouseClick)
                          if type==2 then
                              self:realClose()
                          end
                      end
                      leftCallBack()
                  end
              end
              local textSize = 25
              if type==2 then
                  if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
                      textSize=20
                  end
              end
              local leftBtnUpName,leftBtnDownName = "BtnOkSmall.png","BtnOkSmall_Down.png"
              if type== 1 then
                  leftBtnUpName,leftBtnDownName = "emailToPlayer_2.png","emailToPlayer_1.png"
                  leftStr = nil
              end
              leftItem=GetButtonItem(leftBtnUpName,leftBtnDownName,leftBtnUpName,leftHandler,2,leftStr,textSize)
              leftMenu=CCMenu:createWithItem(leftItem);
              if type== 1 then

                  leftItem:setScale(1)
                  leftItem:setAnchorPoint(ccp(1,1))
                  leftMenu:setPosition(ccp(backSprie:getContentSize().width - 25,playerPicPosY - useWidthInType_1*0.5-10+10))
                  backSprie:addChild(leftMenu)
                  if isGM then
                    useInGM_Tb[3] = leftMenu
                  end
              else
                  leftMenu:setPosition(ccp(150,size.height-400-myChenghaoH))
                  dialogBg:addChild(leftMenu)
              end
              leftMenu:setTouchPriority(-(layerNum-1)*20-2);
          end
        --右按钮
          local rightItem
          if rightStr and rightCallBack then
              local function rightHandler()
                if G_checkClickEnable()==false then
                    do return end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                if type==1 or type==5 then
                    local success=rightCallBack()
                    if success then
                          close()
                    else
                        PlayEffect(audioCfg.mouseClick)
                    end
                else
                    PlayEffect(audioCfg.mouseClick)
                    --if protected==true and type==3 then
                    if type==3 or type==4 then
                        rightCallBack()
                    else
                        close()
                        rightCallBack()
                    end
                end
              end
              local rightBtnUpName,rightBtnDownName = "BtnOkSmall.png","BtnOkSmall_Down.png"
              if type== 1 then
                  rightBtnUpName,rightBtnDownName = "privateChat_2.png","privateChat_1.png"
                  rightStr = nil
              end
              rightItem=GetButtonItem(rightBtnUpName,rightBtnDownName,rightBtnUpName,rightHandler,2,rightStr,25)
              rightMenu=CCMenu:createWithItem(rightItem);
              if type== 1 then
                  rightItem:setScale(1)
                  rightItem:setAnchorPoint(ccp(1,1))
                  rightMenu:setPosition(ccp(backSprie:getContentSize().width - 25,playerPicPosY - useWidthInType_1-21+10))
                  backSprie:addChild(rightMenu)
                  if isGM then
                      useInGM_Tb[4] = rightMenu
                  end
              else
                rightMenu:setPosition(ccp(size.width-150,size.height-400-myChenghaoH))
                dialogBg:addChild(rightMenu)
              end
              rightMenu:setTouchPriority(-(layerNum-1)*20-2);
          end
      end

      if type==2 then
            if leftMenu then leftMenu:setPosition(ccp(size.width/2,50)) end
      end

    --目前只有聊天屏蔽按钮用，type==1
    if str3 and callBack3 then
        local function clickHandler3()
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            if type==1 then
              local function confirmHandler( ... )

                local blackList=G_getBlackList()
                for k,v in pairs(blackList) do
                  if tonumber(v.uid) == tonumber(uid) then
                      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shieldSuccess",{content[1][1]}),28)
                      do return end
                  end
                end
                if SizeOfTable(G_getBlackList())>=G_blackListNum then
                  smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("blackListMax"),28)
                  do return end
                end
                local function saveBlackCallback()
                   smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shieldSuccess",{content[1][1]}),28)
                   self:close()
                end
                local toBlackTb={uid=uid,name=content[1][1]}
                local flag = G_saveNameAndUidInBlackList(toBlackTb,saveBlackCallback)
              end
                G_showSecondConfirm(layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("friend_newSys_shieldConfirm"),false,confirmHandler)
            end
        end
        local btnUp,btnDown = "BtnCancleSmall.png","BtnCancleSmall_Down.png"
        if type== 1 then
          btnUp,btnDown = "shieldPlayerInfo_2.png","shieldPlayerInfo_1.png"
          str3 = nil
        end
        local shieldItem=GetButtonItem(btnUp,btnDown,btnUp,clickHandler3,11,str3,25)
        shieldItem:setAnchorPoint(ccp(1,1))
        self.newFrshieldItem = shieldItem
        shieldMenu=CCMenu:createWithItem(shieldItem)
        if type== 1 then
            shieldMenu:setPosition(ccp(backSprie:getContentSize().width-25,playerPicPosY+10))
            shieldItem:setScale(1)
            backSprie:addChild(shieldMenu)
            local blackList=G_getBlackList()
            if isGM then
              shieldItem:setVisible(false)
              shieldMenu:setVisible(false)
            end
        else
            shieldItem:setScale(0.5)
            shieldMenu:setPosition(ccp(150,size.height-480-myChenghaoH))
            dialogBg:addChild(shieldMenu)
        end
        shieldMenu:setTouchPriority(-(layerNum-1)*20-2)
    end

    -- print("str4",str4)
    -- print("callBack4",callBack4)
    local bottomBtnScale = 0.8
    if type==1 then
        bottomBtnScale = 0.7
    end
    if str4 and callBack4 then
        local realStr = ""
        local listItem
        local listMenu
        local function clickHandler4()
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            if type==1 then
              if realStr == getlocal("friend_newSys_fr_apply") then
                if #friendInfoVo.friendTb + 1 > friendInfoVoApi:getfriendCfg(2) then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_err_12003"),28)
                else
                  if uid then
                    local function callback(fn,data)
                    local ret,sData=base:checkServerData(data)
                      if ret==true then
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("addMailListSuccess",{content[1][1]}),28)
                            callBack4()
                            self:close()
                      end
                     end
                    socketHelper:sendfriendApply(uid,callback)
                  end
                end
              elseif realStr == getlocal("delFriend") then
                local function confirmHandler( ... )

                  local function callback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                          smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_fr_del"),28)
                          friendInfoVoApi:removeFriend(uid)
                          friendInfoVo.friendChanegFlag = 1
                          friendInfoVo.friendGiftFlag = 1
                          callBack4()
                          self:close()
                      end
                  end
                socketHelper:friendsDel(uid,content[1][1],callback)
                end
                G_showSecondConfirm(layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("friend_newSys_delConfirm"),false,confirmHandler)
              end
            else
              callback4()
            end
        end
        if type== 1 then
          if friendInfoVoApi:juedgeIsMyfriend(uid) == false then
            listItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",clickHandler4,11,str4,25,1016)
            listMenu=CCMenu:createWithItem(listItem)
            listItem:setAnchorPoint(ccp(0,0))
            listItem:setScale(bottomBtnScale)
            listMenu:setPosition(ccp(50,30+20))
            realStr = getlocal("friend_newSys_fr_apply")
            local btnLabel = tolua.cast(listItem:getChildByTag(1016),"CCLabelTTF")
            btnLabel:setString(realStr)
          else
            listItem=GetButtonItem("newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn.png",clickHandler4,11,str4,25,1016)
            listMenu=CCMenu:createWithItem(listItem)
            listItem:setAnchorPoint(ccp(0,0))
            listItem:setScale(bottomBtnScale)
            listMenu:setPosition(ccp(50,30+20))
            realStr = getlocal("delFriend")
            local btnLabel = tolua.cast(listItem:getChildByTag(1016),"CCLabelTTF")
            btnLabel:setString(realStr)
          end
        else
          listItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",clickHandler4,11,str4,25)
          listMenu=CCMenu:createWithItem(listItem)
          istItem:setAnchorPoint(ccp(1,0))
          listItem:setScale(bottomBtnScale)
          listMenu:setPosition(ccp(size.width-150,size.height-480-myChenghaoH))
        end
        listMenu:setTouchPriority(-(layerNum-1)*20-2)
        dialogBg:addChild(listMenu)
        if isGM then
            useInGM_Tb[7] = listItem
        end
    end

    local function touchLuaSpr()  end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
        touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
        local rect=CCSizeMake(640,G_VisibleSizeHeight)
        touchDialogBg:setContentSize(rect)
        touchDialogBg:setOpacity(180)
        touchDialogBg:setPosition(ccp(0,0))
        self.dialogLayer:addChild(touchDialogBg);
    local menuBtn1,menuBtn2 = nil,nil
    if type==1 then
        G_AllianceDialogTb["chatSmallDialog"]=self

        --新增
        local function touchMenu(tag)
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
            end
            PlayEffect(audioCfg.mouseClick)
            local pid="p"..tag
            local haveNum=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid)))
            if 1>haveNum then
                local nameStr=getlocal(propCfg[pid].name)
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("satellite_des4",{nameStr}),30)
                return
            end
            local function refreshCallback()
                self:close()
            end
            bagVoApi:showSearchSmallDialog(layerNum+1,pid,refreshCallback,usePlayerNameInType_1)
        end

        local function menuFunc1()
          touchMenu(3305)
        end
        local function menuFunc2()
          touchMenu(3304)
        end

        local detectMenuItem1=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",menuFunc1,101,getlocal("dailyNews_scout_troop"),25)
        local detectMenuItem2=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",menuFunc2,2,getlocal("dailyNews_scout_base"),25)
        local adaHchat = 0
        local adaWchat1 = 0
        local adaWchat2 = 0
        local arcp1 = ccp(0,0)
        local arcp2 = ccp(0.5,0)
        if type==1 then
            detectMenuItem1=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",menuFunc1,101,getlocal("dailyNews_scout_troop"),25)
            detectMenuItem2=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",menuFunc2,2,getlocal("dailyNews_scout_base"),25)
            adaHchat = 20
            adaWchat1 = size.width*0.5 - 50
            adaWchat2 = size.width - 50 - size.width*0.5
            arcp1 = ccp(0.5,0)
            arcp2 = ccp(1,0)
        end
        menuBtn1 = CCMenu:createWithItem(detectMenuItem1)
        detectMenuItem1:setAnchorPoint(arcp1)
        detectMenuItem1:setScale(bottomBtnScale)
        menuBtn1:setPosition(ccp(50+adaWchat1,30+adaHchat))
        menuBtn1:setTouchPriority(-(layerNum-1)*20-2);
        dialogBg:addChild(menuBtn1)

        menuBtn2 = CCMenu:createWithItem(detectMenuItem2)
        detectMenuItem2:setAnchorPoint(arcp2)
        detectMenuItem2:setScale(bottomBtnScale)
        menuBtn2:setPosition(ccp(size.width*0.5+adaWchat2,30+adaHchat))
        menuBtn2:setTouchPriority(-(layerNum-1)*20-2);
        dialogBg:addChild(menuBtn2)

        if isGM then
            useInGM_Tb[5] = detectMenuItem1
            useInGM_Tb[6] = detectMenuItem2
        end
    end

    if type==1 then
        local subHeight,GM_UseHeight2,GM_UseHeight3 = 40,0,0
        if uid == playerVoApi:getUid() then
            menuBtn1:setVisible(false)
            menuBtn2:setVisible(false)
            leftMenu:setVisible(false)
            rightMenu:setVisible(false)
            if isGM then
              subHeight = subHeight + 120
              GM_UseHeight2 = -50
              GM_UseHeight3 = gmUseSubHeight*3
              useInGM_Tb[1]:setPositionY(useInGM_Tb[1]:getPositionY()+GM_UseHeight2)
              useInGM_Tb[2]:setPositionY(useInGM_Tb[2]:getPositionY()+GM_UseHeight2)
            end
        elseif isGM then--非GM自己
          subHeight = 100
            GM_UseHeight2,GM_UseHeight3 = 0,100
            -- useInGM_Tb[1]:setPositionY(useInGM_Tb[1]:getPositionY()+50)
            -- useInGM_Tb[2]:setPositionY(useInGM_Tb[2]:getPositionY()+50)
            useInGM_Tb[3]:setPositionY(useInGM_Tb[3]:getPositionY()+30*1.6)
            useInGM_Tb[4]:setPositionY(useInGM_Tb[4]:getPositionY()+30)
            useInGM_Tb[5]:setEnabled(false)
            useInGM_Tb[6]:setEnabled(false)
            useInGM_Tb[7]:setEnabled(false)
        end
        self.bgLayer:setContentSize(CCSizeMake(size.width,size.height-subHeight))
        self.closeBtn:setPositionY(self.closeBtn:getPositionY()-subHeight)
        backSprie:setPosition(ccp(10,size.height-360-myChenghaoH-subHeight-20+GM_UseHeight3))
        backSprie:setContentSize(CCSizeMake(backSprie:getContentSize().width,backSprie:getContentSize().height+20+GM_UseHeight2))
        titleLb:setPosition(ccp(size.width/2,titleLb:getPositionY()-subHeight))
        if titleBackspire then
          titleBackspire:setPosition(ccp(size.width/2,titleBackspire:getPositionY()-subHeight))
        end
    end

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    return self.dialogLayer
end

function smallDialog:initBattleResultDialog(bgSrc,size,fullRect,inRect,isVictory,callBack,isuseami,layerNum,award,resultStar,isFuben,acData,winCondition,swId,robData,upgradeTanks,levelData,challenge)
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    local strSize2 = 15
    local strSize3 = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize2= 22
        strSize3 = 25
    end
    self.isTouch=nil
    self.isUseAmi=isuseami
    if newGuidMgr:isNewGuiding() then
        layerNum=layerNum-1
    end
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()

    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)

    self.dialogLayer:addChild(self.bgLayer,1);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local levelAgainMenu=nil
    if levelData and SizeOfTable(levelData)~=0 and isVictory and playerVoApi:getPlayerLevel()>=20 and challenge and challenge==1 then
        local function touchLevelAgain()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            if playerVoApi:getEnergy()==0 then
                local function buyEnergy()
                      G_buyEnergy(layerNum+1)
                end
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyEnergy,getlocal("dialog_title_prompt"),getlocal("energyis0"),nil,layerNum+1)
                do
                    return
                end
            end

            if callBack then
                callBack(tag,object)
            end

            local function serverResponse(fn,data)
                local cresult,retTb=base:checkServerData(data)
                if cresult==true then
                      retTb.levelTb=levelData
                      battleScene:initData(retTb)
                      -- self:close(false)

                end
            end
            socketHelper:startBattleForNPC(levelData,serverResponse)

            self:realClose()
        end
        local levelAgainItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",touchLevelAgain,19,getlocal("another_battle"),strSize3)
        levelAgainItem:setAnchorPoint(ccp(0.5,0))
        levelAgainMenu = CCMenu:createWithItem(levelAgainItem)
        levelAgainMenu:setTouchPriority(-(layerNum-1)*20-4)
        levelAgainMenu:setPosition(ccp(size.width/2+120,20))
        self.bgLayer:addChild(levelAgainMenu,2)
    end

    -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    if isVictory and robData and robData.flopReward and SizeOfTable(robData.flopReward)>0 then
        local flopReward=FormatItem(robData.flopReward)
        local getRewardItem
        if flopReward and flopReward[1] then
            getRewardItem=flopReward[1]
        end
        self.isFlop=false
        local bgHeight=size.height
        -- local bgSize=CCSizeMake(size.width,bgHeight)
        -- self.bgLayer:setContentSize(bgSize)

        local victorySpBg = CCSprite:createWithSpriteFrameName("SuccessHeader.png")
        victorySpBg:setPosition(ccp(size.width/2,bgHeight))
        self.bgLayer:addChild(victorySpBg,2)

        local posY=bgHeight-140
        local robFid=robData.swFid
        if robFid and superWeaponCfg.fragmentCfg[robFid] then
            local fCfg=superWeaponCfg.fragmentCfg[robFid]
            local nameStr=""
            if superWeaponCfg.weaponCfg[fCfg.output] then
                local wid=fCfg.output
                local cfg=superWeaponCfg.weaponCfg[wid]
                local weaponVo=superWeaponVoApi:getWeaponByID(wid)
                local level=0
                if weaponVo and weaponVo.lv and tonumber(weaponVo.lv) then
                    level=tonumber(weaponVo.lv) or 0
                end
                nameStr=getlocal(cfg.name)..getlocal("fightLevel",{level})
            end
            local descStr=getlocal("super_weapon_rob_success_reward",{nameStr})
            -- descStr=str
            local descLb=GetTTFLabelWrap(descStr,25,CCSizeMake(size.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            descLb:setAnchorPoint(ccp(0.5,0.5))
            descLb:setPosition(ccp(size.width/2,posY))
            self.bgLayer:addChild(descLb,1)
            descLb:setColor(G_ColorYellowPro)
        else
            local descStr=getlocal("super_weapon_rob_not_fragment")
            -- descStr=str
            local descLb=GetTTFLabelWrap(descStr,25,CCSizeMake(size.width/2+50,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            descLb:setAnchorPoint(ccp(0.5,0.5))
            descLb:setPosition(ccp(size.width/2-100,posY))
            self.bgLayer:addChild(descLb,1)
            descLb:setColor(G_ColorYellowPro)

            if challenge and challenge==1 then

                local function robAgainHandler(tag,object)
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)

                    if self.isFlop~=true then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_rob_get_reward"),30)
                        do return end
                    end

                    local energy=superWeaponVoApi:getEnergy()
                    if energy and energy<=0 then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage17041"),30)
                        do return end
                    end

                    local callBackParams=robData.callBackParams
                    local function weaponBattleCallback(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            if sData.data.weapon then
                                superWeaponVoApi:formatData(sData.data.weapon)
                                superWeaponVoApi:setFragmentFlag(0)
                            end
                            if sData.data and sData.data.flop then
                                local award=FormatItem(sData.data.flop) or {}
                                for k,v in pairs(award) do
                                    G_addPlayerAward(v.type,v.key,v.id,v.num)
                                end
                            end
                            if sData.data and sData.data.accessory then
                                accessoryVoApi:onRefreshData(sData.data.accessory)
                            end
                            if sData.data and sData.data.report then
                                sData.battleType=3
                                sData.callBackParams=callBackParams
                                sData.robData={targetData=robData.targetData}
                                battleScene:initData(sData)
                            end
                            self:close(false)
                        end
                    end
                    socketHelper:weaponBattle(callBackParams,weaponBattleCallback)
                    if callBack then
                        callBack(tag,object)
                    end
                    self:realClose()
                end
                local robAgainItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",robAgainHandler,19,getlocal("super_weapon_rob_again"),strSize3)
                local robAgainMenu = CCMenu:createWithItem(robAgainItem)
                robAgainMenu:setTouchPriority(-(layerNum-1)*20-4)
                robAgainMenu:setPosition(ccp(size.width-robAgainItem:getContentSize().width/2-50,posY))
                self.bgLayer:addChild(robAgainMenu,2)
            end
        end

        posY=posY-80
        local lotteryStr=getlocal("super_weapon_rob_lottery")
        -- lotteryStr=str
        local lotteryLb=GetTTFLabelWrap(lotteryStr,25,CCSizeMake(size.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        lotteryLb:setAnchorPoint(ccp(0.5,0.5))
        lotteryLb:setPosition(ccp(size.width/2,posY))
        self.bgLayer:addChild(lotteryLb,1)
        lotteryLb:setColor(G_ColorYellowPro)

        posY=posY-145
        local xSpace=20
        local pool=G_clone(FormatItem(weaponrobCfg.flopReward))
        for k,v in pairs(pool) do
            if getRewardItem and getRewardItem.type==v.type and getRewardItem.key==v.key then
                table.remove(pool,k)
            end
        end
        for i=1,3 do
            local function flopHandler(object,name,tag)
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                self.isFlop=true
                for k=1,3 do
                    local cardSp1=tolua.cast(self.bgLayer:getChildByTag(100+k),"LuaCCSprite")
                    local function onFlipHandler()
                        if cardSp1 then
                            cardSp1:removeFromParentAndCleanup(true)
                        end
                        local poolTb=G_clone(pool)
                        for j=1,3 do
                            local cardSp2=CCSprite:createWithSpriteFrameName("rewardCard2.png")
                            local px=size.width/2-cardSp2:getContentSize().width-xSpace+(cardSp2:getContentSize().width+xSpace)*(j-1)
                            cardSp2:setPosition(ccp(px,posY))
                            self.bgLayer:addChild(cardSp2,2)
                            cardSp2:setFlipX(true)
                            local icon,name,num
                            if tag==100+j then
                                if getRewardItem then
                                    icon=G_getItemIcon(getRewardItem,100)
                                    name=getRewardItem.name
                                    num=getRewardItem.num
                                    G_addRectFlicker(cardSp2,2,2.4)
                                end
                            else
                                if poolTb and SizeOfTable(poolTb)>0 then
                                    local index=math.random(1,SizeOfTable(poolTb))
                                    local item=poolTb[index]
                                    if item then
                                        icon=G_getItemIcon(item,100)
                                        name=item.name
                                        num=item.num
                                        table.remove(poolTb,index)
                                    end
                                end
                            end
                            icon:setPosition(ccp(cardSp2:getContentSize().width/2,110))
                            cardSp2:addChild(icon,2)
                            local nameLb=GetTTFLabelWrap(name,strSize2,CCSizeMake(cardSp2:getContentSize().width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                            nameLb:setPosition(ccp(cardSp2:getContentSize().width/2,35))
                            cardSp2:addChild(nameLb,2)
                            local numLb=GetTTFLabel("x"..num,25)
                            numLb:setAnchorPoint(ccp(0,0))
                            numLb:setPosition(ccp(5,5))
                            icon:addChild(numLb,2)
                            numLb:setFlipX(true)
                            icon:setFlipX(true)
                            nameLb:setFlipX(true)

                            local function onFlipHandler2()
                                if flopReward and SizeOfTable(flopReward)>0 then
                                    G_showRewardTip(flopReward)
                                end
                            end
                            local callFunc=CCCallFunc:create(onFlipHandler2)
                            local orbitCamera=CCOrbitCamera:create(0.5,1,0,90,90,0,0)
                            local acArr=CCArray:create()
                            acArr:addObject(orbitCamera)
                            acArr:addObject(callFunc)
                            local seq=CCSequence:create(acArr)
                            cardSp2:runAction(seq)
                        end
                    end
                    if cardSp1 then
                        local callFunc=CCCallFunc:create(onFlipHandler)
                        local delay=CCDelayTime:create(2)
                        --旋转的时间，起始半径，半径差，起始z角，旋转z角差，起始x角，旋转x角差
                        local angleDiff=12
                        local angleDiffZ=90
                        if k==1 then
                            angleDiffZ=angleDiffZ-angleDiff
                        elseif k==2 then
                        elseif k==3 then
                            angleDiffZ=angleDiffZ+angleDiff
                        end
                        local orbitCamera=CCOrbitCamera:create(0.5,1,0,0,angleDiffZ,0,0)
                        local acArr=CCArray:create()
                        acArr:addObject(orbitCamera)
                        acArr:addObject(callFunc)
                        local seq=CCSequence:create(acArr)
                        cardSp1:runAction(seq)
                    end
                end
            end
            local cardSp=LuaCCSprite:createWithSpriteFrameName("rewardCard1.png",flopHandler)
            local px=size.width/2-cardSp:getContentSize().width-xSpace+(cardSp:getContentSize().width+xSpace)*(i-1)
            cardSp:setAnchorPoint(ccp(0.5,0.5))
            cardSp:setPosition(ccp(px,posY))
            cardSp:setTouchPriority(-(layerNum-1)*20-4)
            self.bgLayer:addChild(cardSp,2)
            cardSp:setTag(100+i)
        end

        local function sureHandler(tag,object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            if self.isFlop~=true then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_rob_get_reward"),30)
                do return end
            end
            if callBack then
                callBack(tag,object)
            end
            self:realClose()
        end
        local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("ok"),25)
        local sureMenu=CCMenu:createWithItem(sureItem)
        sureMenu:setPosition(ccp(size.width-160,80))
        sureMenu:setTouchPriority(-(layerNum-1)*20-2)
        dialogBg:addChild(sureMenu)

        local function sendHandler(tag,object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)

            if self.isFlop~=true then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("super_weapon_rob_get_reward"),30)
                do return end
            end
            local targetName=""
            if robData and robData.targetData and SizeOfTable(robData.targetData)>0 then
                targetName=robData.targetData.name
            end
            local content=getlocal("super_weapon_rob_chat_report",{playerVoApi:getPlayerName(),targetName})
            local report=robData.report
            G_sendReportChat(layerNum,content,report,9)
            if callBack then
                callBack(tag,object)
            end
            self:realClose()
        end
        local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sendHandler,2,getlocal("super_weapon_rob_send_report"),strSize3)
        local sureMenu=CCMenu:createWithItem(sureItem);
        sureMenu:setPosition(ccp(160,80))
        sureMenu:setTouchPriority(-(layerNum-1)*20-2);
        dialogBg:addChild(sureMenu)

        if self.isUseAmi then
            self:show()
        end
    else
        local isAcBanzhangshilian=false
        if acData and acData.type and acData.type=="banzhangshilian" then
            isAcBanzhangshilian=true
            if isVictory==true then
                award=acData.award
            end
        end

          local function operateHandler(tag,object)
            if G_checkClickEnable()==false then
                        do
                            return
                        end
            end
            --PlayEffect(audioCfg.mouseClick)
            if callBack then
                      callBack(tag,object)
                end

            if isFuben~=true then
                storyScene.checkPointDialog[1]=nil
                for i=#base.commonDialogOpened_WeakTb,1,-1 do
                    if(base.commonDialogOpened_WeakTb[i] and base.commonDialogOpened_WeakTb[i].bgLayer and base.commonDialogOpened_WeakTb[i].setDisplay)then
                        base.commonDialogOpened_WeakTb[i]:setDisplay(true)
                    end
                    if(base.commonDialogOpened_WeakTb[i]~=storyScene)then
                        base.commonDialogOpened_WeakTb[i]:close(false)
                    end
                end
            end

                local dlayerNum=6
                if tag==1 then
                      --"研发科技"
                      local bid=3
                      local type=8
                      local buildVo=buildingVoApi:getBuildiingVoByBId(bid)
                      if buildVo and buildVo.status>0 then
                    require "luascript/script/game/scene/gamedialog/portbuilding/techCenterDialog"
                            local td=techCenterDialog:new(bid,dlayerNum,true)
                            local bName=getlocal(buildingCfg[type].buildName)
                            local tbArr={getlocal("building"),getlocal("startResearch")}
                            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true,dlayerNum)
                            td:tabClick(1)
                            sceneGame:addChild(dialog,dlayerNum)
                      end
                elseif tag==2 then
                      --“建造舰船”
                      local bid=11
                      local type=6
                      local buildVo=buildingVoApi:getBuildiingVoByBId(bid)
                      if buildVo and buildVo.status>0 then
                    require "luascript/script/game/scene/gamedialog/portbuilding/tankFactoryDialog"
                            local td=tankFactoryDialog:new(bid,dlayerNum,true)
                      local bName=getlocal(buildingCfg[type].buildName)
                      local tbArr={getlocal("buildingTab"),getlocal("startProduce"),getlocal("chuanwu_scene_process")}
                      local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,bName.."("..G_LV()..buildVo.level..")",true,dlayerNum)
                      td:tabClick(1)
                            sceneGame:addChild(dialog,dlayerNum)
                      end
                elseif tag==3 then
                      --"提升统率"
            -- local td=playerDialog:new(1,dlayerNum,true)
            -- local tbArr={getlocal("playerInfo"),getlocal("skillTab"),getlocal("buildingTab")}
            -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("playerRole"),true,dlayerNum)
            -- td:tabClick(0)
                      -- sceneGame:addChild(dialog,dlayerNum)
            local td=playerVoApi:showPlayerDialog(1,dlayerNum,true)
            td:tabClick(0)
                elseif tag==4 then
                      --"提升技能"
            -- local td=playerDialog:new(2,dlayerNum,true)
            -- local tbArr={getlocal("playerInfo"),getlocal("skillTab"),getlocal("buildingTab")}
            -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("playerRole"),true,dlayerNum)
            -- td:tabClick(1)
                      -- sceneGame:addChild(dialog,dlayerNum)
            local td=playerVoApi:showPlayerDialog(2,dlayerNum,true)
            td:tabClick(1)
                elseif tag==5 then
                      --"修理舰船"
                require "luascript/script/game/scene/gamedialog/warDialog/tankDefenseDialog"
                      local td=tankDefenseDialog:new(dlayerNum,true)
                local tbArr={getlocal("fleetCard"),getlocal("dispatchCard"),getlocal("repair")}
                local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("defenceSetting"),true,dlayerNum)
                td:tabClick(2)
                      sceneGame:addChild(dialog,dlayerNum)
                      if award then
                        local tipReward=playerVoApi:getTrueReward(award)
                        G_showRewardTip(tipReward,true,nil)
                      end
                end
            self:realClose()

          end
        local function closeHandler(tag,object)
            PlayEffect(audioCfg.mouseClick)
            if newGuidMgr:isNewGuiding()==true then
                activityAndNoteDialog:closeAllDialog()
                storyScene:close()
                newGuidMgr:toNextStep()
            end
            self.bgLayer:setVisible(false)
            local flag=checkPointVoApi:getRefreshFlag()
            if flag==0 and G_WeakTb.checkPoint then
                G_WeakTb.checkPoint:refresh()
            end

            if award then
              local tipReward=playerVoApi:getTrueReward(award)
              G_showRewardTip(tipReward,true,nil)
            end
            if callBack then
                      callBack(tag,object)
                end
                self:realClose()
        end
          local closeBtnItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",closeHandler,6,getlocal("fight_close"),25)
          closeBtnItem:setPosition(0,0)
          closeBtnItem:setAnchorPoint(CCPointMake(0.5,0))
          self.closeBtn = CCMenu:createWithItem(closeBtnItem)
          self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
          self.closeBtn:setPosition(ccp(size.width/2,20))
          self.bgLayer:addChild(self.closeBtn,2)

          if levelAgainMenu then
            self.closeBtn:setPositionX(size.width/2 - 120)
            levelAgainMenu:setPosition(ccp(size.width/2+120,20))
          end

          --判断是否有需要修理的坦克
          local repairTanks=tankVoApi:getRepairTanks()
          local isShowRepair=false
          if repairTanks~=nil then
                local RepairNum=SizeOfTable(repairTanks)
                if RepairNum>0 then
                      isShowRepair=true
                end
          end
          if isAcBanzhangshilian==true then
              isShowRepair=false
          end

          local bgHeight=0
          if isVictory and resultStar==3 and newGuidMgr:isNewGuiding()==false then
                if G_isShowShareBtn() then --只有facebook显示分享
                      local function sendFeedHandler()
                            local function sendFeedCallback()
                                  local function feedsawardHandler(fn,data)
                                        if base:checkServerData(data)==true then
                                if G_curPlatName()=="12" or G_curPlatName()=="androidzhongshouyouru" or G_curPlatName()=="0" or G_curPlatName()=="andgamesdealru" then
                                              smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shareSuccess"),28)
                                end
                                              closeHandler()
                                        end
                                  end
                                  if(G_isKakao()==false)then
                                      socketHelper:feedsaward(1,feedsawardHandler)
                                  else
                                      closeHandler()
                                  end
                            end
                            G_sendFeed(1,sendFeedCallback)
                      end
                local btnTextSize = 30
                if G_getCurChoseLanguage()=="ru" then
                    btnTextSize = 25
                end
                    local feedBtn
                    if(G_isKakao())then
                        feedBtn=LuaCCSprite:createWithFileName("zsyImage/kakaoFeedBtn.png",sendFeedHandler)
                        feedBtn:setScaleY(0.95)
                        feedBtn:setScaleX(0.7)
                        feedBtn:setPosition(ccp(size.width/2 - 120,25))
                        -- closeBtnItem:setScaleX(1.2)
                    else
                        local feedBtnItem
                        feedBtnItem = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",sendFeedHandler,7,getlocal("feedBtn"),btnTextSize)
                        feedBtnItem:setPosition(0,0)
                        feedBtnItem:setAnchorPoint(CCPointMake(0.5,0))
                        feedBtn = CCMenu:createWithItem(feedBtnItem)
                        feedBtn:setPosition(ccp(size.width/2 - 120,20))
                    end
                    feedBtn:setAnchorPoint(ccp(0.5,0))
                    feedBtn:setTouchPriority(-(layerNum-1)*20-4)
                    self.bgLayer:addChild(feedBtn,2)

                    self.closeBtn:setPosition(ccp(size.width/2+120,20))
                    if levelAgainMenu then
                      feedBtn:setPositionX(size.width/2 - 185)
                      levelAgainMenu:setPosition(ccp(size.width/2+185,20))
                      self.closeBtn:setPosition(ccp(size.width/2,20))
                    end
                local textS_ize
                if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
                    textS_ize=18
                else
                    textS_ize=25
                end
                if(G_isKakao()==false)then
                    local feedDescLable = GetTTFLabelWrap(getlocal("feedDesc"),textS_ize,CCSizeMake(25*20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
                    feedDescLable:setAnchorPoint(ccp(0.5,0))
                    feedDescLable:setPosition(ccp(self.bgLayer:getContentSize().width/2,100))
                    self.bgLayer:addChild(feedDescLable,1)
                    bgHeight=bgHeight+20
                end
              end
          end
        --local titleStr
          local isVictoryLabel
          if isVictory or (award and SizeOfTable(award)>0) then
                height=120
                bgHeight=bgHeight+height
                if upgradeTanks and SizeOfTable(upgradeTanks)>0 then
                  bgHeight=bgHeight+height
                end
                if isShowRepair==true then
                      local repairLb=GetTTFLabelWrap(getlocal("fight_fail_tip_5"),25,CCSize(size.width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    repairLb:setAnchorPoint(ccp(0,0))
                    repairLb:setPosition(ccp(30,bgHeight+30))
                    self.bgLayer:addChild(repairLb,2)

                      local repairItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",operateHandler,5,getlocal("fight_fail_tip_15"),25)
                      repairItem:setAnchorPoint(ccp(0,0))
                      local repairItemMenu = CCMenu:createWithItem(repairItem)
                      repairItemMenu:setTouchPriority(-(layerNum-1)*20-4)
                      repairItemMenu:setPosition(ccp(size.width-repairItem:getContentSize().width-20,bgHeight+20))
                      self.bgLayer:addChild(repairItemMenu,2)
                end

                if upgradeTanks and SizeOfTable(upgradeTanks)>0 then
                    local upgradeNum = 0
                    for k,v in pairs(upgradeTanks) do
                      upgradeNum=upgradeNum+v
                    end
                    local chakanLb=GetTTFLabelWrap(getlocal("battleResultTankUpgrade",{upgradeNum}),25,CCSize(size.width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                    chakanLb:setAnchorPoint(ccp(0,0))
                    chakanLb:setPosition(ccp(30,bgHeight-60))
                    self.bgLayer:addChild(chakanLb,2)

                    local function checkUpgrade()
                        tankVoApi:showTankUpgrade(layerNum,upgradeTanks,callBack)
                        if award then
                          local tipReward=playerVoApi:getTrueReward(award)
                          G_showRewardTip(tipReward,true,nil)
                        end
                        self:realClose()
                    end

                    local chakanItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",checkUpgrade,nil,getlocal("alliance_list_check_info"),25)
                    chakanItem:setAnchorPoint(ccp(0,0))
                    local chakanItemMenu = CCMenu:createWithItem(chakanItem)
                    chakanItemMenu:setTouchPriority(-(layerNum-1)*20-4)
                    chakanItemMenu:setPosition(ccp(size.width-chakanItem:getContentSize().width-20,bgHeight-80))
                    self.bgLayer:addChild(chakanItemMenu,2)
                end

                if award then
                    local playerHonors =playerVoApi:getHonors() --用户当前的总声望值
                    local maxLevel =playerVoApi:getMaxLvByKey("roleMaxLevel") --当前服 最大等级
                    local honTb =Split(playerCfg.honors,",")
                    local maxHonors =honTb[maxLevel] --当前服 最大声望值
                    local expTb =Split(playerCfg.level_exps,",")
                    local maxExp = expTb[maxLevel] --当前服 最大经验值
                    local playerExp = playerVoApi:getPlayerExp() --用户当前的经验值
                    local AllGems = 0 --用于满级后的水晶数量

                    local awardNum=SizeOfTable(award)
                    local awardHeight=(math.ceil(awardNum/2)+1)*120+20
                    for k,v in pairs(award) do
                        if v and v.name and v.num then
                            local awidth = 30+((k-1)%2)*280
                            local aheight = awardHeight-(math.floor((k+1)/2))*120+80
                            local iconSize=100
                            local icon
                            if v.type and v.type=="e" then
                                if v.eType then
                                    if v.eType=="a" then
                                        icon = accessoryVoApi:getAccessoryIcon(v.key,nil,iconSize)
                                    elseif v.eType=="f" then
                                        icon = accessoryVoApi:getFragmentIcon(v.key,nil,iconSize)
                                    elseif v.pic and v.pic~="" then
                                        icon = CCSprite:createWithSpriteFrameName(v.pic)
                                    end
                                end
                            elseif v.type and v.type=="w" and (v.eType=="f" or v.eType=="c") then
                                icon = G_getItemIcon(v,iconSize)
                            elseif v.type and (v.type=="p" or v.type=="f" or v.type=="m" or v.type=="n") then
                                icon = G_getItemIcon(v,iconSize)
                            elseif v.type=="t" then                   --糖果
                                local bgname = "equipBg_green.png"
                                local pic ="sweet_1.png"                 --糖果
                                for i=1,4 do
                                    if v.key =="t1" then
                                         pic ="sweet_1.png"
                                        bgname="equipBg_green.png"
                                    elseif v.key =="t2" then
                                         pic ="sweet_2.png"
                                        bgname="equipBg_blue.png"
                                    elseif v.key =="t3" then
                                         pic ="sweet_3.png"
                                        bgname="equipBg_purple.png"
                                    elseif v.key =="t4" then
                                         pic ="sweet_4.png"
                                        bgname="equipBg_orange.png"
                                    end
                                    icon = GetBgIcon(pic,nil,bgname)
                                end
                            elseif v.pic and v.pic~="" then
                              if v.type=="ac" and v.eType == "o" then
                                icon = G_getItemIcon(v,iconSize)
                              else
                                icon = CCSprite:createWithSpriteFrameName(v.pic)
                              end
                            end
                            if v.name ==getlocal("honor") and base.isConvertGems==1 and tonumber(playerHonors) >=tonumber(maxHonors) then
                                local nameLb =tolua.cast(self.bgLayer:getChildByTag(331),"CCLabelTTF")
                                  if nameLb ==nil then

                                    icon = CCSprite:createWithSpriteFrameName("resourse_normal_gold.png")
                                    icon:setAnchorPoint(ccp(0,0))
                                    icon:setPosition(ccp(awidth,aheight+bgHeight-height))
                                    self.bgLayer:addChild(icon,1)
                                    local scale=iconSize/icon:getContentSize().width
                                    icon:setScale(scale)

                                    local nameLable = GetTTFLabelWrap(getlocal("money"),25,CCSize(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                                    nameLable:setAnchorPoint(ccp(0,0.5))
                                    nameLable:setPosition(ccp(awidth+iconSize+5,aheight+100+bgHeight-height-15))
                                    self.bgLayer:addChild(nameLable,1)
                                    nameLable:setTag(331)

                                    local gems = playerVoApi:convertGems(2,v.num)
                                    AllGems =gems
                                    local numLable = GetTTFLabel(gems,25)
                                    numLable:setAnchorPoint(ccp(0,0))
                                    numLable:setPosition(ccp(awidth+iconSize+5,aheight+5+bgHeight-height))
                                    self.bgLayer:addChild(numLable,1)
                                    numLable:setTag(333)
                                  else
                                    local gems = playerVoApi:convertGems(2,v.num)
                                    local numLb =tolua.cast(self.bgLayer:getChildByTag(333),"CCLabelTTF")
                                    numLb:setString(AllGems+gems)
                                  end
                            elseif v.name ==getlocal("sample_general_exp") and base.isConvertGems==1 and tonumber(playerExp) >=tonumber(maxExp) then
                                local nameLb =tolua.cast(self.bgLayer:getChildByTag(331),"CCLabelTTF")
                                  if nameLb ==nil then

                                    icon = CCSprite:createWithSpriteFrameName("resourse_normal_gold.png")
                                    icon:setAnchorPoint(ccp(0,0))
                                    icon:setPosition(ccp(awidth,aheight+bgHeight-height))
                                    self.bgLayer:addChild(icon,1)
                                    local scale=iconSize/icon:getContentSize().width
                                    icon:setScale(scale)

                                    local nameLable = GetTTFLabelWrap(getlocal("money"),25,CCSize(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                                    nameLable:setAnchorPoint(ccp(0,0.5))
                                    nameLable:setPosition(ccp(awidth+iconSize+5,aheight+100+bgHeight-height-15))
                                    self.bgLayer:addChild(nameLable,1)
                                    nameLable:setTag(331)

                                    local gems = playerVoApi:convertGems(1,v.num)
                                    AllGems =gems
                                    local numLable = GetTTFLabel(gems,25)
                                    numLable:setAnchorPoint(ccp(0,0))
                                    numLable:setPosition(ccp(awidth+iconSize+5,aheight+5+bgHeight-height))
                                    self.bgLayer:addChild(numLable,1)
                                    numLable:setTag(333)
                                  else
                                    local gems = playerVoApi:convertGems(1,v.num)
                                    local numLb =tolua.cast(self.bgLayer:getChildByTag(333),"CCLabelTTF")
                                    numLb:setString(AllGems+gems)
                                  end
                            else

                                -- if base.isConvertGems==1 and tonumber(playerHonors) >=tonumber(maxHonors) and tonumber(playerExp) >=tonumber(maxExp) and k >1 then
                                --     awidth = 30+((k-2)%2)*280
                                --     aheight = awardHeight-(math.floor((k+0)/2))*120+80
                                -- end

                                if icon then
                                    icon:setAnchorPoint(ccp(0,0))
                                    icon:setPosition(ccp(awidth,aheight+bgHeight-height))
                                    self.bgLayer:addChild(icon,1)
                                    local scale=iconSize/icon:getContentSize().width
                                    if icon:getContentSize().height>icon:getContentSize().width then
                                      scale=iconSize/icon:getContentSize().height
                                    end
                                    icon:setScale(scale)
                                end

                                -- local nameLable = GetTTFLabel(v.name,25)
                                local nameLable = GetTTFLabelWrap(v.name,25,CCSize(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                                nameLable:setAnchorPoint(ccp(0,0.5))
                                nameLable:setPosition(ccp(awidth+iconSize+5,aheight+100+bgHeight-height-15))
                                self.bgLayer:addChild(nameLable,1)

                                local numLable = GetTTFLabel(v.num,25)
                                numLable:setAnchorPoint(ccp(0,0))
                                numLable:setPosition(ccp(awidth+iconSize+5,aheight+5+bgHeight-height))
                                self.bgLayer:addChild(numLable,1)
                            end


                            if awardNum==1 and isAcBanzhangshilian==true then
                                local hei1=aheight+100+bgHeight-height-15
                                local hei2=aheight+5+bgHeight-height-50
                                if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
                                    hei2=aheight+5+bgHeight-height+15
                                end
                                -- local hei2=aheight+5+bgHeight-height+15
                                local star=acData.star or 0
                                local firstStar=acData.firstStar or 0
                                local firstRate=acData.firstRate or 0
                                local totalStar=star+firstStar
                                local cStar=getlocal("activity_banzhangshilian_complete_reward")
                                local starLb=GetTTFLabel(totalStar,25)
                                starLb:setAnchorPoint(ccp(0,0.5))
                                starLb:setPosition(ccp(self.bgLayer:getContentSize().width/2+10,hei1))
                                self.bgLayer:addChild(starLb,1)
                                local starSp1=CCSprite:createWithSpriteFrameName("StarIcon.png")
                                starSp1:setAnchorPoint(ccp(0,0.5))
                                starSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2+40,hei1))
                                self.bgLayer:addChild(starSp1,1)
                                local completeLb=GetTTFLabelWrap(getlocal("activity_banzhangshilian_complete_reward"),25,CCSize(150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                                completeLb:setAnchorPoint(ccp(0,0.5))
                                completeLb:setPosition(ccp(self.bgLayer:getContentSize().width/2+starSp1:getContentSize().width+50,hei1))
                                self.bgLayer:addChild(completeLb,1)


                                if firstStar and firstStar>0 then
                                    -- local firstStarLb=GetTTFLabel(firstStar,25)
                                    -- firstStarLb:setAnchorPoint(ccp(0,0.5))
                                    -- firstStarLb:setPosition(ccp(self.bgLayer:getContentSize().width/2+10,hei2))
                                    -- self.bgLayer:addChild(firstStarLb,1)
                                    -- local starSp2=CCSprite:createWithSpriteFrameName("StarIcon.png")
                                    -- starSp2:setAnchorPoint(ccp(0,0.5))
                                    -- starSp2:setPosition(ccp(self.bgLayer:getContentSize().width/2+40,hei2))
                                    -- self.bgLayer:addChild(starSp2,1)
                                    local firstCompleteLb=GetTTFLabelWrap(getlocal("activity_banzhangshilian_first_complete_reward",{firstRate}),25,CCSize(self.bgLayer:getContentSize().width/2-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                                    firstCompleteLb:setAnchorPoint(ccp(0,0.5))
                                    -- firstCompleteLb:setPosition(ccp(self.bgLayer:getContentSize().width/2+starSp2:getContentSize().width+50,hei2))
                                    firstCompleteLb:setPosition(ccp(self.bgLayer:getContentSize().width/2+10,hei2))
                                    self.bgLayer:addChild(firstCompleteLb,1)
                                    firstCompleteLb:setColor(G_ColorYellowPro)
                                end
                            end
                        end
                    end
                    bgHeight=bgHeight+awardHeight
                else
                    bgHeight=bgHeight+120+40+20
                end

                bgHeight=bgHeight+60
                local victoryBg = CCSprite:createWithSpriteFrameName("TeamHeaderBg.png")
              victoryBg:setAnchorPoint(ccp(0.5,1))
                victoryBg:setPosition(ccp(size.width/2,bgHeight-40))
                self.bgLayer:addChild(victoryBg)

                if award then
                      isVictoryLabel=GetTTFLabel(getlocal("fight_award"),25)
                else
                      isVictoryLabel=GetTTFLabel(getlocal("fight_award")..getlocal("fight_content_null"),25)
                end
              isVictoryLabel:setAnchorPoint(ccp(0.5,0.5))
              isVictoryLabel:setPosition(getCenterPoint(victoryBg))
              victoryBg:addChild(isVictoryLabel,1)

            if isVictory then
              --titleStr=getlocal("fight_win")

                local victorySpBg = CCSprite:createWithSpriteFrameName("SuccessHeader.png")
              --victorySpBg:setAnchorPoint(ccp(0.5,1))
                victorySpBg:setPosition(ccp(size.width/2,bgHeight+48))
                self.bgLayer:addChild(victorySpBg,2)


                if PlatformManage~=nil then
                    --if  platCfg.platCfgShowWinOrLose[G_curPlatName()]~=nil and G_getBHVersion()==1  then
                    if G_getCurChoseLanguage()~="cn" and platCfg.platCfgShowWinOrLose[G_curPlatName()]~=nil then
                        local victorySp = CCSprite:createWithSpriteFrameName("SuccessShape.png")
                        victorySp:setAnchorPoint(ccp(0.5,1))
                        local spPos=getCenterPoint(victorySpBg)
                        victorySp:setPosition(spPos.x,spPos.y-10)
                        victorySpBg:addChild(victorySp,2)
                    end
                end




                --星星动画
                if isAcBanzhangshilian==true then
                    battleScene:showStarAni(victorySpBg,3)
                elseif resultStar and resultStar>0 then
                    battleScene:showStarAni(victorySpBg,resultStar)
                end
            else
                --titleStr=getlocal("fight_defeated")

                local loseSpBg = CCSprite:createWithSpriteFrameName("LoseHeader.png")
                --loseSpBg:setAnchorPoint(ccp(0.5,1))
                loseSpBg:setPosition(ccp(size.width/2,bgHeight+48))
                self.bgLayer:addChild(loseSpBg,2)

                if PlatformManage~=nil then
                    --if  platCfg.platCfgShowWinOrLose[G_curPlatName()]~=nil and G_getBHVersion()==1 then
                    if G_getCurChoseLanguage()~="cn" and platCfg.platCfgShowWinOrLose[G_curPlatName()]~=nil then
                        local loseSp = CCSprite:createWithSpriteFrameName("LoseShape.png")
                        loseSp:setAnchorPoint(ccp(0.5,1))
                        local spPos=getCenterPoint(loseSpBg)
                        loseSp:setPosition(spPos.x,spPos.y-10)
                        loseSpBg:addChild(loseSp,2)
                    end
                end




                --星星动画
                if resultStar and resultStar>0 then
                    battleScene:showStarAni(loseSpBg,resultStar)
                end
            end

          else
              local showCondition=false
              if winCondition and SizeOfTable(winCondition)>0 then
                  for k,v in pairs(winCondition) do
                      if v and v==0 then
                          showCondition=true
                      end
                  end
              end
              if showCondition==true and swId then
                  bgHeight=bgHeight+350
                  local conditionStr=superWeaponVoApi:getClearConditionStr(swId)..getlocal("super_weapon_challenge_not_reach")
                  local promotionStr=getlocal("super_weapon_challenge_promotion_condition",{conditionStr})
                  local promotionLb=GetTTFLabelWrap(promotionStr,25,CCSize(size.width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
                  promotionLb:setPosition(ccp(size.width/2,200))
                  self.bgLayer:addChild(promotionLb,2)
              elseif isAcBanzhangshilian==true then
                  bgHeight=bgHeight+350
              else
                  bgHeight=bgHeight+350+200
                  local height

                  local showTab={"1","2","3","4","5"}
                  local hSpace=80
                  --判断是否显示修理按钮
                  if isShowRepair==false then
                        table.remove(showTab,5)
                  end
                  --判断是否建造科技中心
                  local techCenterVo=buildingVoApi:getBuildiingVoByBId(3)
                  local isShowTech=true
                  if techCenterVo.status==-1 or techCenterVo.status==0 then
                        isShowTech=false
                  end
                  if isShowTech==false then
                        table.remove(showTab,1)
                  end
                  --判断是否建造坦克营
                  local tankTuningVo=buildingVoApi:getBuildiingVoByBId(11)
                  if tankTuningVo.status==-1 or tankTuningVo.status==0 then
                        if isShowTech==false then
                              table.remove(showTab,1)
                        else
                              table.remove(showTab,2)
                        end
                  end
                  hSpace=hSpace+(5-SizeOfTable(showTab))*20

                  local tabNum=SizeOfTable(showTab)
                  for k,v in pairs(showTab) do
                        height=bgHeight-20-hSpace*k
                        local operateLb=GetTTFLabelWrap(getlocal("fight_fail_tip_"..tostring(v)),25,CCSize(size.width-220,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                      operateLb:setAnchorPoint(ccp(0,0.5))
                      operateLb:setPosition(ccp(30,height+20))
                      self.bgLayer:addChild(operateLb,2)
                        operateLb:setColor(G_ColorYellow)

                        local operateItem
                  local btnTextSize = 30
                  if G_getCurChoseLanguage()=="pt" then
                      btnTextSize = 25
                  end
                  if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
                      btnTextSize=20
                  end
                        if tonumber(v)==3 then
                              operateItem = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",operateHandler,tonumber(v),getlocal("fight_fail_tip_1"..tostring(v)),btnTextSize)
                        else
                              operateItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",operateHandler,tonumber(v),getlocal("fight_fail_tip_1"..tostring(v)),btnTextSize)
                        end
                        operateItem:setAnchorPoint(ccp(0,0.5))
                        local operateItemMenu = CCMenu:createWithItem(operateItem)
                        operateItemMenu:setTouchPriority(-(layerNum-1)*20-4)
                        operateItemMenu:setPosition(ccp(size.width-operateItem:getContentSize().width-20,height+15))
                        self.bgLayer:addChild(operateItemMenu,2)
                  end

                  bgHeight=bgHeight+50
                  isVictoryLabel=GetTTFLabel(getlocal("fight_fail_tip"),25)
                  isVictoryLabel:setAnchorPoint(ccp(0,1))
                  isVictoryLabel:setPosition(ccp(20,bgHeight-50))
                  self.bgLayer:addChild(isVictoryLabel,1)
              end

                --titleStr=getlocal("fight_defeated")

              local loseSpBg = CCSprite:createWithSpriteFrameName("LoseHeader.png")
            --loseSpBg:setAnchorPoint(ccp(0.5,1))
              loseSpBg:setPosition(ccp(size.width/2,bgHeight+48))
              self.bgLayer:addChild(loseSpBg,2)

              if PlatformManage~=nil then
              --if  platCfg.platCfgShowWinOrLose[G_curPlatName()]~=nil and G_getBHVersion()==1  then
                  if G_getCurChoseLanguage()~="cn" and platCfg.platCfgShowWinOrLose[G_curPlatName()]~=nil then
                    local loseSp = CCSprite:createWithSpriteFrameName("LoseShape.png")
                    loseSp:setAnchorPoint(ccp(0.5,1))
                    local spPos=getCenterPoint(loseSpBg)
                    loseSp:setPosition(spPos.x,spPos.y-10)
                    loseSpBg:addChild(loseSp,2)
                  end
              end
          end

          bgHeight=bgHeight+50
          --[[
          titleLb=GetTTFLabel(titleStr,30)
        titleLb:setAnchorPoint(ccp(0.5,1))
        titleLb:setPosition(ccp(size.width/2,bgHeight-25))
        self.bgLayer:addChild(titleLb,1)
          ]]


          local bgSize=CCSizeMake(size.width,bgHeight)
        --self.bgSize=bgSize
        self.bgLayer:setContentSize(bgSize)
          if self.isUseAmi then
          self:show()
          end
    end

    local function touchLuaSpr()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchLuaSpr);
        touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
        local rect=CCSizeMake(640,G_VisibleSizeHeight)
        touchDialogBg:setContentSize(rect)
        touchDialogBg:setOpacity(0)
        touchDialogBg:setPosition(getCenterPoint(self.bgLayer))
        self.bgLayer:addChild(touchDialogBg,1);

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    return self.dialogLayer
end

function smallDialog:initEnemyComingDialog(bgSrc,size,fullRect,inRect,istouch,isuseami,title,layerNum,itemTab,enemyId)
      --[[
    if itemTab==nil or itemTab=={} then
            do return end
      end
      ]]
      self.isTouch=istouch
    self.isUseAmi=isuseami
    self.type="enemyComingDialog"
      local function tmpFunc()

      end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,tmpFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)

    self:show()

    local titleLb=GetTTFLabel(title,40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)

      base:addNeedRefresh(self)
      self.refreshData.countdownTab={}
      if enemyId then
          self.refreshData.enemyId=enemyId
      end
      local isMoved=false
    local function tvCallBack(handler,fn,idx,cel)
            if fn=="numberOfCellsInTableView" then
                  if enemyId then
                      return 1
                  else
                      local enemyAll=enemyVoApi:getEnemyAll()
                      local num=SizeOfTable(enemyAll)
                      return num
                  end
            elseif fn=="tableCellSizeForIndex" then
                  local cellWidth=self.bgLayer:getContentSize().width-40
                  local cellHeight=130
                  local tmpSize=CCSizeMake(cellWidth,cellHeight)
                  return  tmpSize
            elseif fn=="tableCellAtIndex" then
                  local cell=CCTableViewCell:new()
                  cell:autorelease()
                  local cellWidth=self.bgLayer:getContentSize().width-40
                  local cellHeight=130
                  local enemyVo
                  if enemyId then
                      enemyVo=enemyVoApi:getEnemyById(enemyId)
                  else
                      local enemyAll=enemyVoApi:getEnemyAll()
                      enemyVo=enemyAll[idx+1]
                  end
                  if enemyVo==nil then
                        do return cell end
                  end

                  local function touch()
                  end
                  local bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemRedBg.png",CCRect(20, 20, 10, 10),touch)
                bgSprie:setContentSize(CCSizeMake(cellWidth,cellHeight-5))
                bgSprie:setPosition(ccp(cellWidth/2,cellHeight/2))
                  bgSprie:setIsSallow(false)
                  bgSprie:setTouchPriority(-(layerNum-1)*20-2)
                cell:addChild(bgSprie,1)

                  local icon=CCSprite:createWithSpriteFrameName("Icon_warn.png")
                  icon:setAnchorPoint(ccp(0,0.5))
                  icon:setPosition(ccp(10,cellHeight/2-5))
                icon:setScaleX(0.75)
                icon:setScaleY(0.75)
                  bgSprie:addChild(icon,2)

                  local height=bgSprie:getContentSize().height-10
                  local width=icon:getContentSize().width-10

                  local nameStr=enemyVo.attackerName
                  local nameLabel
                  if enemyVo.islandType==6 then
                        nameLabel=GetTTFLabel(getlocal("enemyComingPlayer",{nameStr}),28)
                  elseif enemyVo.islandType==8 then
                        nameLabel=GetTTFLabel(getlocal("enemyComingAllianceCity",{nameStr}),28)
                  else
                        nameLabel=GetTTFLabel(getlocal("enemyComingIslands",{nameStr}),28)
                  end
                nameLabel:setAnchorPoint(ccp(0,1))
                nameLabel:setPosition(ccp(width,height))
                bgSprie:addChild(nameLabel,2)

                  local locationLabel=GetTTFLabel(getlocal("city_info_coordinate")..":"..getlocal("city_info_coordinate_style",{enemyVo.place[1],enemyVo.place[2]}),25)
                locationLabel:setAnchorPoint(ccp(0,0.5))
                --locationLabel:setPosition(ccp(cellWidth-150,height))
                  locationLabel:setPosition(ccp(width,height/2+5))
                bgSprie:addChild(locationLabel,2)

                  local time=enemyVo.time-base.serverTime
                  if time<0 then
                        time=0
                  end
                  local timeStr=GetTimeStr(time)
                  local countdownLabel=GetTTFLabel(getlocal("attackedTime",{timeStr}),25)
                countdownLabel:setAnchorPoint(ccp(0,0))
                countdownLabel:setPosition(ccp(width,10))
                bgSprie:addChild(countdownLabel,2)
                  --self.refreshData.countdownTab[idx+1]={time=time,label=countdownLabel}
                  self.refreshData.countdownTab[idx+1]={label=countdownLabel}

                  return cell
            elseif fn=="ccTouchBegan" then
                  isMoved=false
                  return true
            elseif fn=="ccTouchMoved" then
                  isMoved=true
            elseif fn=="ccTouchEnded"  then

            end
    end
      local cellWidth=self.bgLayer:getContentSize().width-40
    local hd= LuaEventHandler:createHandler(tvCallBack)
      self.refreshData.tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,self.bgLayer:getContentSize().height-170),nil)
    self.refreshData.tableView:setTableViewTouchPriority(-(layerNum-1)*20-3)
    self.refreshData.tableView:setPosition(ccp(20,50))
    self.bgLayer:addChild(self.refreshData.tableView,2)
    if enemyId then
        self.refreshData.tableView:setMaxDisToBottomOrTop(0)
    else
        self.refreshData.tableView:setMaxDisToBottomOrTop(120)
    end
      --[[
      local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,self.bgLayer:getContentSize().height-170),nil)
    tableView:setTableViewTouchPriority(-(layerNum-1)*20-3)
    tableView:setPosition(ccp(50,50))
    self.bgLayer:addChild(tableView,2)
    tableView:setMaxDisToBottomOrTop(120)
      ]]

    local function touchDialog()
        if self.isTouch~=nil and isMoved==false then
                  if self.bgLayer~=nil then
                        PlayEffect(audioCfg.mouseClick)
                  self:close()
                  end
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchDialog)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-2)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg);

    self.dialogLayer:addChild(self.bgLayer,1);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self:userHandler()

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    return self.dialogLayer
end

function smallDialog:initUpgradeFeedDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callBackHandler)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()

    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog()

    end

      self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

      local function close()
        PlayEffect(audioCfg.mouseClick)
          return self:close()
      end
      local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
      closeBtnItem:setPosition(ccp(0,0))
      closeBtnItem:setAnchorPoint(CCPointMake(0,0))

      self.closeBtn = CCMenu:createWithItem(closeBtnItem)
      self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
      self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
      self.bgLayer:addChild(self.closeBtn,2)

      local bvo=buildingVoApi:getBuildiingVoByBId(1)
      local bcfg=buildingCfg[bvo.type]

      local buildIcon = CCSprite:createWithSpriteFrameName("Icon_zhu_ji_di.png")
    buildIcon:setAnchorPoint(ccp(0.5,0.5))
      buildIcon:setPosition(ccp(buildIcon:getContentSize().width/2+40,self.bgSize.height-buildIcon:getContentSize().height/2-40))
      self.bgLayer:addChild(buildIcon,1)

      local titleStr=getlocal("congratulation")..getlocal("promptBuildFinish",{getlocal(bcfg.buildName),bvo.level})
      local txtSize = 28
      local titleLable = GetTTFLabelWrap(titleStr,txtSize,CCSize(8*txtSize,4*txtSize),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLable:setAnchorPoint(ccp(0.5,0.5))
    titleLable:setPosition(ccp(self.bgSize.width/2+25,self.bgSize.height-90))
      self.bgLayer:addChild(titleLable,1)

      --local lineSp = CCSprite:createWithSpriteFrameName("LineEntity.png")
      local lineSp = CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setAnchorPoint(ccp(0.5,0.5))
      lineSp:setPosition(ccp(self.bgSize.width/2,self.bgSize.height/2+30))
      self.bgLayer:addChild(lineSp,1)
      lineSp:setScale(0.8)

      local descStr=buildingVoApi:unlockBuildingDesc()
      local txtSize = 24
      local descLable = GetTTFLabelWrap(descStr,txtSize,CCSize(20*txtSize,5*txtSize),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    descLable:setAnchorPoint(ccp(0.5,0.5))
    descLable:setPosition(ccp(self.bgSize.width/2,self.bgSize.height/2-50))
      self.bgLayer:addChild(descLable,1)
      descLable:setColor(G_ColorYellowPro)

    --分享
      local function sendFeedHandler()
            PlayEffect(audioCfg.mouseClick)
            local function sendFeedCallback()
                  local function feedsawardHandler(fn,data)
                        if base:checkServerData(data)==true then
                              if G_curPlatName()=="12" or G_curPlatName()=="androidzhongshouyouru" or G_curPlatName()=="0" or G_curPlatName()=="andgamesdealru" then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shareSuccess"),28)
                    end
                              closeHandler()
                        end
                  end
                  if(G_isKakao()==false)then
                      socketHelper:feedsaward(1,feedsawardHandler)
                  else
                      closeHandler()
                  end
            end
            G_sendFeed(3,sendFeedCallback)
      end
    local btnTextSize = 30
    if G_getCurChoseLanguage()=="ru" then
        btnTextSize = 25
    end
      local feedBtn
      if(G_isKakao())then
          feedBtn=LuaCCSprite:createWithFileName("zsyImage/kakaoFeedBtn.png",sendFeedHandler)
          feedBtn:setScaleY(0.95)
          feedBtn:setScaleX(0.9)
          feedBtn:setPosition(ccp(size.width/2 + 30,25))
      else
          local feedBtnItem
          feedBtnItem = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",sendFeedHandler,7,getlocal("feedBtn"),btnTextSize)
          feedBtnItem:setPosition(0,0)
          feedBtnItem:setAnchorPoint(CCPointMake(0,0))
          feedBtn = CCMenu:createWithItem(feedBtnItem)
          feedBtn:setPosition(ccp(size.width/2 + 50,20))
      end
      feedBtn:setAnchorPoint(ccp(0,0))
      feedBtn:setTouchPriority(-(layerNum-1)*20-4)
      self.bgLayer:addChild(feedBtn,2)

      if(G_isKakao()==false)then
          local feedDescLable = GetTTFLabelWrap(getlocal("feedDesc"),22,CCSizeMake(22*20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
          feedDescLable:setAnchorPoint(ccp(0.5,0))
          feedDescLable:setPosition(ccp(self.bgSize.width/2,100))
          self.bgLayer:addChild(feedDescLable,1)
      end

    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
      touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
      local rect=CCSizeMake(640,G_VisibleSizeHeight)
      touchDialogBg:setContentSize(rect)
      touchDialogBg:setOpacity(180)
      touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
      --touchDialogBg:setPosition(ccp(0,0))
      self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
      self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

function smallDialog:initCodeRewardDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callBackHandler)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()

    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog()

    end

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)

    local titleLb=GetTTFLabel(getlocal("input_code_gift"),40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.bgSize.width/2-15,self.bgSize.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)

    local inputLable = GetTTFLabelWrap(getlocal("input_code"),25,CCSizeMake(self.bgSize.width-100,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter)
    -- local inputLable = GetTTFLabel(getlocal("input_code"),25)
    inputLable:setAnchorPoint(ccp(0,0.5))
    inputLable:setPosition(ccp(50,self.bgSize.height-155))
    self.bgLayer:addChild(inputLable,1)

    local function callBackTargetHandler(fn,eB,str)

    end
    local function tthandler()
    end
    local editTargetBox=LuaCCScale9Sprite:createWithSpriteFrameName("mail_input_bg.png",CCRect(10,10,5,5),tthandler)
    editTargetBox:setContentSize(CCSizeMake(self.bgSize.width-100,50))
    editTargetBox:setIsSallow(false)
    editTargetBox:setTouchPriority(-(layerNum-1)*20-4)
    editTargetBox:setPosition(ccp(50+editTargetBox:getContentSize().width/2,self.bgSize.height-230))
    local targetBoxLabel=GetTTFLabel("",25)
    targetBoxLabel:setAnchorPoint(ccp(0,0.5))
    targetBoxLabel:setPosition(ccp(10,editTargetBox:getContentSize().height/2))
    local customEditBox=customEditBox:new()
    local length=100
    customEditBox:init(editTargetBox,targetBoxLabel,"mail_input_bg.png",nil,-(layerNum-1)*20-4,length,callBackTargetHandler,nil,nil)
    self.bgLayer:addChild(editTargetBox,2)

    -- local searchDescLable=GetTTFLabelWrap(getlocal("alliance_search_desc"),25,CCSize(self.bgSize.width-100,500),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    -- searchDescLable:setAnchorPoint(ccp(0,1))
    -- searchDescLable:setPosition(ccp(50,self.bgSize.height-225))
    -- self.bgLayer:addChild(searchDescLable,1)
    -- searchDescLable:setColor(G_ColorGreen)

    local function rewardHandler()
        PlayEffect(audioCfg.mouseClick)

        local targetStr=targetBoxLabel:getString()
        if targetStr==nil or targetStr=="" then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("nullCharacter"),28)
            -- self:close()
            return
        else
            -- local targetNum=G_utfstrlen(targetStr,true)
            -- if targetNum and targetNum>length then
            --     -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("nullCharacter"),28)
            --     -- self:close()
            --     return
            -- else
                local function rewardCallback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if sData and sData.data and sData.data.giftbagget and sData.data.giftbagget.reward then
                            local award=FormatItem(sData.data.giftbagget.reward) or {}
                            for k,v in pairs(award) do
                                G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                            end
                            local rewardInfo = sData.data.giftbagget.cardInfo
                            local title = ""
                            local desc = ""
                            if rewardInfo and type(rewardInfo)=="table" then
                                title = rewardInfo.title
                                desc = rewardInfo.desc
                            end
                            if award and SizeOfTable(award)>0 then
                                smallDialog:showRewardItemDialog("PanelHeaderPopup.png",CCSizeMake(600,600),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,layerNum+1,award,title,desc,nil)
                            end
                            -- G_showRewardTip(award)
                        end
                        if callBackHandler~=nil then
                            callBackHandler(targetStr)
                        end
                        if self.sureItem then
                            self.sureItem:setEnabled(false)
                        end
                        self:close()
                    end
                end
                socketHelper:giftbagGet(targetStr,rewardCallback)
            -- end
        end
    end
    self.sureItem=GetButtonItem("BtnRecharge.png","BtnRecharge_Down.png","BtnRecharge_Down.png",rewardHandler,2,getlocal("code_gift"),25)
    local sureMenu=CCMenu:createWithItem(self.sureItem);
    sureMenu:setPosition(ccp(size.width/2,90))
    sureMenu:setTouchPriority(-(layerNum-1)*20-2);
    dialogBg:addChild(sureMenu)
    -- if false then
    --     self.sureItem:setEnabled(false)
    -- end

    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

--战力增长，数字从number1变到number2的特效
function smallDialog:initPowerChangeEffect(number1,number2,posX,posY)
    self.isTouch=false
    self.isUseAmi=true
    self.type="powerchangeeffect"
    local str1=tostring(number1)
    local str2=tostring(number2)
    --如果数字1大于数字2, 那么数字变化趋势是减少, 否则就是增加
    if(number1>number2)then
        self.powerChangeFlag=0
        self.powerChangeStrlen=string.len(str1)
    else
        self.powerChangeFlag=1
        self.powerChangeStrlen=string.len(str2)
    end
    --如果数字位数大于五位, 那就所有数字一起转, 否则就是一位一位地转
    if(number2>=100000)then
        self.powerChangeRollTogether=true
    else
        self.powerChangeRollTogether=false
    end
    self.powerChangeStart=number1
    self.powerChangeEnd=number2
    self.powerChangeStartTb={}
    self.powerChangeEndTb={}
    self.powerChangeTmpTb={}
    self.powerChangeFlagTb={}
    for i=1,self.powerChangeStrlen do
        self.powerChangeFlagTb[i]=0
    end
    local length=string.len(str1)
    for i=1,length do
        local num=tonumber(string.sub(str1,0-i,0-i))
        table.insert(self.powerChangeStartTb,num)
        table.insert(self.powerChangeTmpTb,num)
    end
    length=string.len(str2)
    for i=1,length do
        table.insert(self.powerChangeEndTb,tonumber(string.sub(str2,0-i,0-i)))
    end
    local capInSet = CCRect(20, 20, 10, 10);
    local function nilFunc(hd,fn,idx)
    end
    self.dialogLayer=CCLayer:create()
    self.bgLayer=self.dialogLayer

    local lb=GetBMLabel(number1,G_GoldFontSrc,30)
    lb:setAnchorPoint(ccp(0,0.5))
    self.powerChangeLb=lb
    self.bgLayer:addChild(lb)

    local prefixLb=GetTTFLabel(getlocal("showAttackRank"),55)
    prefixLb:setColor(G_ColorYellowPro)
    prefixLb:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(prefixLb)

    local totalWidth=lb:getContentSize().width+prefixLb:getContentSize().width+10
    if(posX~=nil and posY~=nil)then
        prefixLb:setPosition(ccp(posX-totalWidth/2,posY))
        lb:setPosition(ccp(posX+totalWidth/2-lb:getContentSize().width,posY))
    else
        prefixLb:setPosition(ccp((G_VisibleSizeWidth-totalWidth)/2,G_VisibleSizeHeight/2))
        lb:setPosition(ccp((G_VisibleSizeWidth+totalWidth)/2-lb:getContentSize().width,G_VisibleSizeHeight/2))
    end

    sceneGame:addChild(self.dialogLayer,9)

    local function onScaleShow()
        self.fastTickIndex=0
        base:addNeedRefresh(self)
    end
    local callFunc=CCCallFunc:create(onScaleShow)
    local scaleTo1=CCScaleTo:create(0.2, 1.1);
    local scaleTo2=CCScaleTo:create(0.1, 1);
    local delay=CCDelayTime:create(0.5)
    local acArr=CCArray:create()
    acArr:addObject(scaleTo1)
    acArr:addObject(scaleTo2)
    acArr:addObject(delay)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    self.powerChangeLb:runAction(seq)

    table.insert(G_SmallDialogDialogTb,self)
end


function smallDialog:showBuyResDialog(type,layerNum,callBack)
      local sd=smallDialog:new()
      local dialog=sd:initBuyResDialog(type,layerNum,callBack)
      return sd
end
function smallDialog:initBuyResDialog(type,layerNum,callBack)
    self.layerNum=layerNum
    self.isTouch=true
    self.isUseAmi=true
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
      self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)

    local size=CCSizeMake(600,650)
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()


    local function touchDialog()

    end
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function touchLuaSpr()
        if self.isTouch~=nil then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)

    local parent =self.bgLayer
    local tb={}
    local addx1=400
    local addx2=200
    local addx3=0

    if type==1 then
          tb={
          {pid="p21",m_height=addx1},
          {pid="p26",m_height=addx2},
          {pid="p2",m_height=addx3},
            }
      elseif type==2 then
            tb={
          {pid="p22",m_height=addx1},
          {pid="p27",m_height=addx2},
          {pid="p2",m_height=addx3},
            }
      elseif type==3 then
            tb={
          {pid="p23",m_height=addx1},
          {pid="p28",m_height=addx2},
          {pid="p2",m_height=addx3},
            }
      elseif type==4 then
            tb={
          {pid="p24",m_height=addx1},
          {pid="p29",m_height=addx2},
          {pid="p2",m_height=addx3},
            }
  elseif type==5 then
    tb={
      {pid="p10",m_height=addx1},
      {pid="p25",m_height=addx2},
      {pid="p2",m_height=addx3},
    }
      end

    for k,v in pairs(tb) do
      local pid=v.pid
          local m_height=v.m_height
          local lbName=GetTTFLabelWrap(getlocal(propCfg[pid].name),26,CCSizeMake(26*12,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
          lbName:setPosition(130,150+m_height)
          lbName:setAnchorPoint(ccp(0,0.5));
          parent:addChild(lbName,2)

          local lbNum=GetTTFLabel(getlocal("propHave")..bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid))),22)
          lbNum:setPosition(490,23+m_height+10)
          lbNum:setAnchorPoint(ccp(0.5,0.5));
          parent:addChild(lbNum,2)

          local sprite = CCSprite:createWithSpriteFrameName(propCfg[pid].icon);
          sprite:setAnchorPoint(ccp(0,0.5));
          sprite:setPosition(20,120+m_height)
          parent:addChild(sprite,2)

          local labelSize = CCSize(270, 100);
          local lbDescription=GetTTFLabelWrap(getlocal(propCfg[pid].description),22,labelSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
          lbDescription:setPosition(130,75+m_height)
          lbDescription:setAnchorPoint(ccp(0,0.5));
          parent:addChild(lbDescription,2)

           local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png");
           gemIcon:setPosition(ccp(470,50+m_height+110));
           parent:addChild(gemIcon,2)
          local lbPrice=GetTTFLabel(propCfg[pid].gemCost,24)
          lbPrice:setPosition(gemIcon:getPositionX()+30,gemIcon:getPositionY())
          lbPrice:setAnchorPoint(ccp(0,0.5));
          parent:addChild(lbPrice,2)

          local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png");
          lineSprite:setAnchorPoint(ccp(0,0.5));
          lineSprite:setPosition(20,m_height)
          parent:addChild(lineSprite,2)

          if bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid)))>0 then
              local function touchUse()
                PlayEffect(audioCfg.mouseClick)
                local function callbackUseProc(fn,data)
                    if base:checkServerData(data)==true then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("use_prop_success",{getlocal(propCfg[pid].name)}),28)
                        self:close()
                        if callBack then
                          callBack()
                        end
                    end
                end
                socketHelper:useProc(tonumber(RemoveFirstChar(pid)),nil,callbackUseProc)
            end
            local useMenuItem = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",touchUse,11,getlocal("use"),26)
              local useMenu = CCMenu:createWithItem(useMenuItem)
              useMenu:setPosition(ccp(490,100+m_height))
              useMenu:setTouchPriority(-(self.layerNum-1)*20-3)
              parent:addChild(useMenu,3)
          else
            local  function touch1()
                  local  function touchBuy()
                  local function callbackUseProc(fn,data)
                          if base:checkServerData(data)==true then
                              smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("use_prop_success",{getlocal(propCfg[pid].name)}),28)
                              self:close()
                              if callBack then
                                callBack()
                              end
                          end
                      end
                  socketHelper:useProc(tonumber(RemoveFirstChar(pid)),1,callbackUseProc)
                end
                local function buyGems()
                        if G_checkClickEnable()==false then
                            do
                                return
                            end
                        end
                        vipVoApi:showRechargeDialog(self.layerNum+1)
                    end

                    if playerVo.gems<tonumber(propCfg[pid].gemCost) then
                        local num=tonumber(propCfg[pid].gemCost)-playerVo.gems
                        local smallD=smallDialog:new()
                             smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{tonumber(propCfg[pid].gemCost),playerVo.gems,num}),nil,self.layerNum+1)
                    else

                        local smallD=smallDialog:new()
                             smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchBuy,getlocal("dialog_title_prompt"),getlocal("prop_buy_tip",{propCfg[pid].gemCost,getlocal(propCfg[pid].name)}),nil,self.layerNum+1)
                    end



                   end

                  local buyUseMenuItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",touch1,11,getlocal("buyAndUse"),25)
            local buyUseMenu = CCMenu:createWithItem(buyUseMenuItem);
            buyUseMenu:setPosition(ccp(490,40+m_height+60));
            buyUseMenu:setTouchPriority(-(self.layerNum-1)*20-3);
            parent:addChild(buyUseMenu,3);

          end

    end




    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

function smallDialog:showSearchForDialog(layerNum)
      local sd=smallDialog:new()
      sd:initSearchForDialog(layerNum)
      return sd
end

function smallDialog:initSearchForDialog(layerNum)
    self.isTouch=istouch
    self.isUseAmi=isuseami

    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),touchHandler)
    self.dialogLayer=CCLayer:create()

    local size=CCSizeMake(550,500)

    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog()

    end

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
    closeBtnItem:setPosition(0,0)
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
    dialogBg:addChild(self.closeBtn)

    local iconSp=CCSprite:createWithSpriteFrameName("Icon_buff2.png")
    iconSp:setAnchorPoint(ccp(0,0.5))
    iconSp:setPosition(40,dialogBg:getContentSize().height-150)
    dialogBg:addChild(iconSp,6)

    local verticalLine = CCSprite:createWithSpriteFrameName("LineCross.png")
    --verticalLine:setScaleX(bgH/verticalLine:getContentSize().width)
    verticalLine:setPosition(ccp(dialogBg:getContentSize().width/2 ,dialogBg:getContentSize().height-230))
    dialogBg:addChild(verticalLine,2)

    local titleLb=GetTTFLabel(getlocal("sample_prop_name_409"),40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)
    local realalign,realValign=kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter
    if align~=nil then
        realalign=align
    end
    if valign~=nil then
        realValign=valign
    end
    local contentLb=GetTTFLabelWrap(getlocal("sample_prop_des_409"),25,CCSize(300,0),realalign,realValign)
    contentLb:setAnchorPoint(ccp(0,0.5))
    --contentLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height-contentLb:getContentSize().height/2-50))
    contentLb:setPosition(ccp(iconSp:getPositionX()+iconSp:getContentSize().width+10,iconSp:getPositionY()))
    dialogBg:addChild(contentLb)

    local serLb=GetTTFLabel(getlocal("spyRadarSerch"),30)
    serLb:setAnchorPoint(ccp(0,0.5))
    serLb:setColor(G_ColorGreen)
    serLb:setPosition(ccp(20,dialogBg:getContentSize().height-260))
    dialogBg:addChild(serLb)

    local serNoteLb=GetTTFLabel(getlocal("spyRadarSerchNote"),24)
    serNoteLb:setAnchorPoint(ccp(0,0.5))
    serNoteLb:setColor(G_ColorRed)
    serNoteLb:setPosition(ccp(20,dialogBg:getContentSize().height-370))
    dialogBg:addChild(serNoteLb)


    local nameStr=""

    --确定
    local function sureHandler()
        PlayEffect(audioCfg.mouseClick)
        if nameStr=="" then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("nameNullCharacter"),true,6,G_ColorRed)
            do
                return
            end
        end

        local function callSure()
            local function callbackUseProc(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData.data~=nil and sData.data.location~=nil then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("successSerch",{sData.data.location.nickname,sData.data.location.x,sData.data.location.y}),30)

                    end

                end

            end
            socketHelper:useProc(409,nil,callbackUseProc,nil,nameStr)
            self:close()
        end

        smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),callSure,getlocal("dialog_title_prompt"),getlocal("serchSure",{nameStr}),nil,layerNum+1)


    end
    local leftStr=getlocal("alliance_list_scene_search")
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,leftStr,25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(dialogBg:getContentSize().width/2,60))
    sureMenu:setTouchPriority(-(layerNum-1)*20-2);
    dialogBg:addChild(sureMenu)

    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1);

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))



    local function tthandler()

    end
    local function callBackUserNameHandler(fn,eB,str,type)
       if str~=nil then
           nameStr=str
           nameStr=G_stringGsub(nameStr," ","")
        end
    end

    local accountBox=LuaCCScale9Sprite:createWithSpriteFrameName("LegionInputBg.png",CCRect(10,10,1,1),tthandler)
    accountBox:setContentSize(CCSize(445,60))
    accountBox:setPosition(ccp(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height-320))
    dialogBg:addChild(accountBox)

    local lbSize=25

    local targetBoxLabel=GetTTFLabel("",lbSize)
    targetBoxLabel:setAnchorPoint(ccp(0,0.5))
    targetBoxLabel:setPosition(ccp(10,accountBox:getContentSize().height/2))
    local customEditAccountBox=customEditBox:new()
    local length=12
    customEditAccountBox:init(accountBox,targetBoxLabel,"inputNameBg.png",nil,-(layerNum-1)*20-4,length,callBackUserNameHandler,nil,nil)



end


-- 显示验证码
function smallDialog:showCheckCodeDialog(layerNum,successCallBack)
      local sd=smallDialog:new()
      local dialog=sd:initCheckCodeDialog(layerNum,successCallBack)
      return sd
end
function smallDialog:initCheckCodeDialog(layerNum,successCallBack)
    --如果验证码已弹出则不再弹
    if self.showFlag and self.showFlag==true then
      do return end
    end
    self.showFlag=true
    self.layerNum=layerNum
    self.isTouch=true
    self.isUseAmi=true
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
      self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)

    local size=CCSizeMake(520,570+60)
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()


    local function touchDialog()

    end
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function touchLuaSpr()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local LbY = 530+60
    -- 说明文本
    local subLb=GetTTFLabel(getlocal("inputCheckCodeLabel"),22)
    subLb:setPosition(40,LbY)
    subLb:setAnchorPoint(ccp(0,1));
    self.bgLayer:addChild(subLb,2)

    local function codeSpHandler()

    end

    -- 验证码背景
    local codeSp = LuaCCScale9Sprite:createWithSpriteFrameName("smallBlackQuadrateBg.png",CCRect(20, 20, 1, 1),codeSpHandler)
    codeSp:setContentSize(CCSizeMake(364,60))
    codeSp:setPosition(80,LbY-subLb:getContentSize().height-20)
    codeSp:setAnchorPoint(ccp(0,1));
    self.bgLayer:addChild(codeSp,1)

    -- local lineNode = CCNode:create()
    -- lineNode:setContentSize(CCSizeMake(300,60))
    -- lineNode:setPosition(30,codeSp:getContentSize().height)
    -- lineNode:setAnchorPoint(ccp(0,1))
    -- codeSp:addChild(lineNode,4)

    local lineNode = CCNode:create()
    lineNode:setContentSize(CCSizeMake(300,56))
    lineNode:setPosition(0,codeSp:getContentSize().height)
    lineNode:setAnchorPoint(ccp(0,1))
    -- codeSp:addChild(lineNode,4)

    -- 添加遮罩层
    local clipper=CCClippingNode:create()
    clipper:setContentSize(CCSizeMake(300,56))
    clipper:setAnchorPoint(ccp(0,1))
    clipper:setPosition(30,codeSp:getContentSize().height-2)
    local stencil=CCDrawNode:getAPolygon(CCSizeMake(300,56),1,1)
    clipper:setStencil(stencil) --遮罩
    clipper:addChild(lineNode)
    codeSp:addChild(clipper)

    -- 生成干扰线
    local function createLine( ... )
        local lineNum = 0
        if lineNode then
            lineNode:removeAllChildrenWithCleanup(true)
        end
        local allLineName = {"yellowPoint.png","bluePoint.png","greenPoint.png","orangePoint.png","purplePoint.png"}
        for i=0,30 do
            local temW = math.random()*100
            if temW>50 and lineNum<12 then
                lineNum=lineNum+1
                local lineX = math.random()*100+lineNode:getContentSize().width/2-50
                local lineY = math.random()*55
                local lineRotation = 1
                if lineY<25 then
                    lineRotation=-math.random()*15
                else
                    lineRotation=math.random()*15
                end
                if lineX<50 then
                    lineX=lineX*2
                end
                local function touchLine( ... )
                  -- body
                end
                local lineName = allLineName[math.ceil(math.random()*(#allLineName))]
                local lineSp1 = LuaCCScale9Sprite:createWithSpriteFrameName(lineName,CCRect(0, 0, 1, 1),touchLine)
                lineSp1:setAnchorPoint(ccp(0.5,0));
                lineSp1:setPosition(lineX,lineY)
                lineNode:addChild(lineSp1,3)
                lineSp1:setContentSize(CCSizeMake(temW*2,4))
                lineSp1:setRotation(lineRotation*3)
            end
            if lineNum>=10 then
                break
            end
        end
    end


    local codeLb=GetTTFLabel(getlocal(""),38)
    codeLb:setPosition(codeSp:getContentSize().width/2-codeLb:getContentSize().width/2,codeSp:getContentSize().height-10)
    codeLb:setAnchorPoint(ccp(0,1));
    codeSp:addChild(codeLb,2)
    codeLb:setColor(G_ColorGreen2)

    local lineSp2 = CCSprite:createWithSpriteFrameName("LineCross.png");
    lineSp2:setAnchorPoint(ccp(0.5,0.5));
    lineSp2:setPosition(self.bgLayer:getContentSize().width/2,codeSp:getPositionY()-codeSp:getContentSize().height-10)
    self.bgLayer:addChild(lineSp2,2)
    lineSp2:setScaleX((self.bgLayer:getContentSize().width-30)/lineSp2:getContentSize().width)
    -- lineSp2:setScaleY(2)
    -- 生成验证码
    local code
    local function createCode()
      local firstNum = math.floor(math.random()*10)
      local secondNum = math.floor(math.random()*10)
      local thirdNum = math.floor(math.random()*10)
      local fourNum = math.floor(math.random()*10)
      code = firstNum..secondNum..thirdNum..fourNum
      local showCodeStr = firstNum.."  "..secondNum.."  "..thirdNum.."  "..fourNum
      codeLb:setString(showCodeStr)
      codeLb:setPosition(codeSp:getContentSize().width/2-codeLb:getContentSize().width/2,codeSp:getContentSize().height-10)
      createLine()
    end
    local inputCodeStr=""
    createCode()

    -- 显示输入的验证码文本
    local function inputCodeSpHandler( ... )
    end
    local inputCodeSp = LuaCCScale9Sprite:createWithSpriteFrameName("smallGreen2QuadrateBg.png",CCRect(20, 20, 10, 10),inputCodeSpHandler)
    inputCodeSp:setContentSize(CCSizeMake(364,60))
    inputCodeSp:setPosition(self.bgLayer:getContentSize().width/2-inputCodeSp:getContentSize().width/2,codeSp:getPositionY()-codeSp:getContentSize().height-20)
    inputCodeSp:setAnchorPoint(ccp(0,1))
    inputCodeSp:setTouchPriority(-(layerNum-1)*20-3)
    self.bgLayer:addChild(inputCodeSp,1)

    local inputCodeLb=GetTTFLabel("",30)
    inputCodeLb:setPosition(inputCodeSp:getContentSize().width/2-inputCodeLb:getContentSize().width/2,inputCodeSp:getContentSize().height-10)
    inputCodeLb:setAnchorPoint(ccp(0,1));
    inputCodeSp:addChild(inputCodeLb,2)

    -- 刷新验证码
    local function refreshCodeHandler()
      PlayEffect(audioCfg.mouseClick)
      createCode()
      inputCodeStr=""
      inputCodeLb:setString(inputCodeStr)
      inputCodeLb:setPosition(inputCodeSp:getContentSize().width/2-inputCodeLb:getContentSize().width/2,inputCodeSp:getContentSize().height-10)
    end

    local refreshBtn = LuaCCScale9Sprite:createWithSpriteFrameName("smallBlackQuadrateBg.png",CCRect(20, 20, 1, 1),refreshCodeHandler)
    refreshBtn:setContentSize(CCSizeMake(50,50))
    refreshBtn:setPosition(codeSp:getContentSize().width-refreshBtn:getContentSize().width-5,codeSp:getContentSize().height-5)
    refreshBtn:setAnchorPoint(ccp(0,1));
    refreshBtn:setTouchPriority(-(layerNum-1)*20-3)
    codeSp:addChild(refreshBtn,1)

    local refreshIcon = CCSprite:createWithSpriteFrameName("refreshIcon.png")
    refreshIcon:setPosition(refreshBtn:getContentSize().width/2,refreshBtn:getContentSize().height/2)
    refreshBtn:addChild(refreshIcon)

    -- 初始化输入板，可以升级为动态位置
    local function inputHandler(hd,fn,idx)
      PlayEffect(audioCfg.mouseClick)
      if idx==10 then
          return
      end
      if idx==12 then
          -- 删除键
          if string.len(inputCodeStr)>0 then
              inputCodeStr = string.sub(inputCodeStr,1,(string.len(inputCodeStr)-1))
              inputCodeLb:setString(inputCodeStr)
              inputCodeLb:setPosition(inputCodeSp:getContentSize().width/2-inputCodeLb:getContentSize().width/2,inputCodeSp:getContentSize().height-10)
          end
      else
          -- 输入数字
          if string.len(inputCodeStr)<4 then
              if idx==11 then
                  inputCodeStr=inputCodeStr.."0"
              else
                  inputCodeStr=inputCodeStr..idx
              end
              inputCodeLb:setString(inputCodeStr)
              inputCodeLb:setPosition(inputCodeSp:getContentSize().width/2-inputCodeLb:getContentSize().width/2,inputCodeSp:getContentSize().height-10)
              if string.len(inputCodeStr)==4 then
                  if tostring(inputCodeStr)==tostring(code) then
                      -- 验证成功,需要发奖
                      if successCallBack then
                          successCallBack()
                      end
                      self.showFlag=false
                      self:close()
                  else
                      -- 验证失败
                      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("inputCheckCodeError"),30)
                      createCode()
                      inputCodeStr=""
                      inputCodeLb:setString(inputCodeStr)
                      inputCodeLb:setPosition(inputCodeSp:getContentSize().width/2-inputCodeLb:getContentSize().width/2,inputCodeSp:getContentSize().height-10)
                  end
              end
          end
      end
    end
    for i=0,11 do
        local inputBtnSp = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),inputHandler)
        inputBtnSp:setContentSize(CCSizeMake(120,80))
        inputBtnSp:setTouchPriority(-(layerNum-1)*20-3)
        local tmpX = inputCodeSp:getPositionX()+math.floor(i%3)*(inputBtnSp:getContentSize().width+2)
        local tmpY = inputCodeSp:getPositionY()-math.floor(i/3)*(inputBtnSp:getContentSize().height+2)-inputCodeSp:getContentSize().height-8
        inputBtnSp:setPosition(tmpX,tmpY)
        inputBtnSp:setTag(i+1)
        inputBtnSp:setAnchorPoint(ccp(0,1));
        self.bgLayer:addChild(inputBtnSp,1)

        if i ~= 9 and i ~= 11 then
          local inputBtnLb
          if i==10 then
              inputBtnLb=GetTTFLabel("0",30)
          else
              inputBtnLb=GetTTFLabel(tostring(i+1),30)
          end
          inputBtnLb:setPosition(inputBtnSp:getContentSize().width/2,inputBtnSp:getContentSize().height/2)
          -- inputBtnLb:setAnchorPoint(ccp(0,1));
          inputBtnSp:addChild(inputBtnLb,2)
        elseif i ==9 then

        elseif i ==11 then
          local deleteIcon = CCSprite:createWithSpriteFrameName("deleteIcon.png")
          deleteIcon:setPosition(inputBtnSp:getContentSize().width/2,inputBtnSp:getContentSize().height/2)
          inputBtnSp:addChild(deleteIcon)
        end
    end
    local successStr = getlocal("inputCheckCodeSuccess")
    -- if G_curPlatName()=="0" then
    --     local checkcodeNum=CCUserDefault:sharedUserDefault():getIntegerForKey(G_checkCodeKey..playerVoApi:getUid())
    --     successStr=successStr.."num:"..checkcodeNum
    -- end
    local rewardLb=GetTTFLabelWrap(successStr,22,CCSize(self.bgLayer:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    rewardLb:setAnchorPoint(ccp(0.5,0.5))
    rewardLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,50))
    self.bgLayer:addChild(rewardLb)

    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end

-- 能量结晶信息面板
-- crystalName:结晶的名称，iconSp：结晶的icon，attlist:结晶的加成列表，btnType：按钮类型-1:不显示按钮，1：镶嵌，2：卸载，3：替换，callBack：按钮回调,crystalLevel:结晶的等级
function smallDialog:showCrystalInfoDilaog(crystalName,iconSp,attList,layerNum,btnType,callBack,crystalLevel)
      local sd=smallDialog:new()
      local dialog=sd:initCrystalInfoDilaog(crystalName,iconSp,attList,layerNum,btnType,callBack,crystalLevel)
      return sd
end
function smallDialog:initCrystalInfoDilaog(crystalName,iconSp,attList,layerNum,btnType,callBack,crystalLevel)
    self.layerNum=layerNum
    self.isTouch=true
    self.isUseAmi=true
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
      self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)

    local size=CCSizeMake(520,300)
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()


    local function touchDialog()

    end
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function touchLuaSpr()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local nameLb=GetTTFLabel(crystalName,38)
    nameLb:setPosition(ccp(30,self.bgLayer:getContentSize().height-28))
    nameLb:setAnchorPoint(ccp(0,1));
    self.bgLayer:addChild(nameLb,2)
    if crystalLevel<=4 then
        nameLb:setColor(G_ColorGreen)
    elseif crystalLevel<=7 and crystalLevel>4 then
        nameLb:setColor(G_ColorBlue3)
    else
        nameLb:setColor(G_ColorPurple)
    end


    iconSp:setAnchorPoint(ccp(0,1))
    iconSp:setPosition(ccp(30,nameLb:getPositionY()-nameLb:getContentSize().height-20))
    self.bgLayer:addChild(iconSp)

    local i = 1
    for k,v in pairs(attList) do
        local msg = getlocal(buffEffectCfg[k].name)
        if tonumber(k)>200 then
            msg=msg..":+"..v
        else
            msg=msg..":+"..(tonumber(v)*100).."%"
        end
        self["skillLb"..i]=GetTTFLabel(msg,25)
        self["skillLb"..i]:setAnchorPoint(ccp(0,1))
        self["skillLb"..i]:setPosition(ccp(iconSp:getPositionX()+iconSp:getContentSize().width+20,iconSp:getPositionY()+(self["skillLb"..i]:getContentSize().height+10)*(i-1)))
        self.bgLayer:addChild(self["skillLb"..i])
        i=i+1
    end


    if btnType~=-1 then
        local function btnHandler( ... )
            if callBack then
                PlayEffect(audioCfg.mouseClick)
                callBack(btnType)
            end
            self:close()
        end
        local btnName
        if btnType==1 then
            btnName="super_weapon_setGem"
        elseif btnType==2 then
            btnName="super_weapon_unload"
        else
            btnName="hero_honor_change"
        end
        local btn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",btnHandler,11,getlocal(btnName),25)
        btn:setAnchorPoint(ccp(0.5,0))
        local btnMenu=CCMenu:createWithItem(btn)
        btnMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,30))
        self.bgLayer:addChild(btnMenu,2)

    end
    local function close( ... )
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
    closeBtnItem:setPosition(0, 0)
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgLayer:getContentSize().width-closeBtnItem:getContentSize().width-5,self.bgLayer:getContentSize().height-closeBtnItem:getContentSize().height-5))
    self.bgLayer:addChild(self.closeBtn)
    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer
end
-- 能量结晶套装面板
function smallDialog:showCrystalSuitDilaog(suitList,layerNum)
      local sd=smallDialog:new()
      local dialog=sd:initCrystalSuitDilaog(suitList,layerNum)
      return sd
end
function smallDialog:initCrystalSuitDilaog(suitList,layerNum)
    self.layerNum=layerNum
    self.isTouch=true
    self.isUseAmi=true
    local function touchHandler()
        return self:close()
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
      self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)

    local size=CCSizeMake(520,600)
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function touchLuaSpr()
        return self:close()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    -- local function close()
    --     PlayEffect(audioCfg.mouseClick)
    --     return self:close()
    -- end
    -- local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    -- closeBtnItem:setPosition(ccp(0,0))
    -- closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    -- self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    -- self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    -- self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    -- self.bgLayer:addChild(self.closeBtn,2)

    local titleLb=GetTTFLabel(getlocal("crystal_suit_title2"),35)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(size.width/2,size.height-50))
    self.bgLayer:addChild(titleLb)

    local lineSp =CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setScaleX((size.width-20)/lineSp:getContentSize().width)
    lineSp:setScaleY(1.2)
    lineSp:setPosition(ccp(size.width/2,size.height-80))
    self.bgLayer:addChild(lineSp,2)

    local index = 1
    local topH = 55+40
    for k,v in pairs(suitList) do
        local title = v["title"]
        local desc = v["desc"]
        local msg = ""
        for i=1,#desc do
            msg=msg..tostring(desc[i]).."\n"
        end
        self["titleLb"..index]=GetTTFLabel(title,24)
        self["titleLb"..index]:setAnchorPoint(ccp(0,1))
        self.bgLayer:addChild(self["titleLb"..index])

        self["descLb"..index]=GetTTFLabel(msg,20)
        self["descLb"..index]:setAnchorPoint(ccp(0.5,1))
        self.bgLayer:addChild(self["descLb"..index])
        if index == 1 then
            self["titleLb"..index]:setPosition(ccp(30,self.bgLayer:getContentSize().height-topH))

        else
            self["titleLb"..index]:setPosition(ccp(30,self["descLb"..(index-1)]:getPositionY()-self["descLb"..(index-1)]:getContentSize().height-5))
        end
        if v["titleColor"] then
            self["titleLb"..index]:setColor(v["titleColor"])
            self["descLb"..index]:setColor(v["titleColor"])
        end
        self["descLb"..index]:setPosition(ccp(self.bgLayer:getContentSize().width/2,self["titleLb"..index]:getPositionY()-self["titleLb"..index]:getContentSize().height-5))
        index=index+1
    end


    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer
end


-- 一键合成结晶面板,ctype:颜色类型，1，2，3
function smallDialog:showMergeAllCrystalDilaog(list,ctype,layerNum,closeCallBack)
      local sd=smallDialog:new()
      local dialog=sd:initMergeAllCrystalDilaog(list,ctype,layerNum,closeCallBack)
      return sd
end
function smallDialog:initMergeAllCrystalDilaog(list,ctype,layerNum,closeCallBack)
  local needPos2 = 40
  local strSize2 = 22
  local kCCTextAlignment2 = kCCTextAlignmentRight
    if G_getCurChoseLanguage() =="cn" and G_getCurChoseLanguage() =="ja" and G_getCurChoseLanguage() =="ko" and G_getCurChoseLanguage() =="tw" then
      strSize2 =25
      needPos2 = 80
      kCCTextAlignment2 =kCCTextAlignmentLeft
    end

    self.layerNum=layerNum
    self.isTouch=true
    self.isUseAmi=true
    local function touchHandler()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
      self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)

    local size=CCSizeMake(520,520)
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local isNeedCallBack = false
    local function close()
        PlayEffect(audioCfg.mouseClick)

        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)
    local formStr={getlocal("redTitle"),getlocal("yellowTitle"),getlocal("blueTitle")}

    local titleLb=GetTTFLabel(getlocal("merge_all_title",{formStr[ctype]}),32)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(size.width/2,size.height-50))
    self.bgLayer:addChild(titleLb)
    titleLb:setColor(G_ColorYellowPro)

    local lineSp =CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setScaleX((size.width-20)/lineSp:getContentSize().width)
    lineSp:setScaleY(1.2)
    lineSp:setPosition(ccp(size.width/2,size.height-80))
    self.bgLayer:addChild(lineSp,2)

    for level=1,4 do
        local flag = 0--是否可以融合，1是可以
        if list[tostring(level)] then
            flag=1
        end

        local levelLb=GetTTFLabel(getlocal("level_title",{level}),25)
        local posY = lineSp:getPositionY()-levelLb:getContentSize().height/2-30-(levelLb:getContentSize().height+50)*(level-1)
        levelLb:setAnchorPoint(ccp(0,0.5))
        levelLb:setPosition(ccp(needPos2,posY))
        self.bgLayer:addChild(levelLb)

        local aIcon = CCSprite:createWithSpriteFrameName("heroArrowRight.png")
        aIcon:setAnchorPoint(ccp(0,0.5))
        aIcon:setPosition(ccp(levelLb:getPositionX()+levelLb:getContentSize().width+10,posY))
        self.bgLayer:addChild(aIcon)

        local nextLevelLb=GetTTFLabel(getlocal("level_title",{level+1}),25)
        nextLevelLb:setAnchorPoint(ccp(0,0.5))
        nextLevelLb:setPosition(ccp(aIcon:getPositionX()+aIcon:getContentSize().width+20,posY))
        self.bgLayer:addChild(nextLevelLb)

        local function mergeAllHandler( ... )
            print("----dmj0------mergeAllHandler.level:"..level)
            local function callBack(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    isNeedCallBack=true
                    if(sData.data.weapon)then
                        superWeaponVoApi:formatData(sData.data.weapon)
                    end
                    local successList = sData.data.success
                    local failList = sData.data.lose
                    if isNeedCallBack==true and closeCallBack then
                        closeCallBack()
                    end
                    self:close()
                    self:showMergeAllCrystalResultDialog(successList,failList,level+1,level-1,self.layerNum)
                end
            end
            local function sureHandler( ... )
                socketHelper:mergeAllCrystal(level,ctype,callBack)
            end
            local str = ""
            for k,v in pairs(list[tostring(level)]) do
                if str=="" then
                    str=getlocal("more_prop_title",{v.num,v.name})
                else
                    str=str..","..getlocal("more_prop_title",{v.num,v.name})
                end

            end
            local contentStr = getlocal("merge_all_desc2",{str})
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),sureHandler,getlocal("dialog_title_prompt"),contentStr,nil,layerNum+1)
        end
        if flag==1 then
            local mergeAllBtn=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",mergeAllHandler,11,getlocal("merge_btn"),strSize2)
            mergeAllBtn:setAnchorPoint(ccp(1,0.5))
            local mergeAllBtnMenu=CCMenu:createWithItem(mergeAllBtn)
            mergeAllBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width-40,posY))
            mergeAllBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
            self.bgLayer:addChild(mergeAllBtnMenu,2)
        else
            local noDataLb=GetTTFLabelWrap(getlocal("no_enough_crystal"),25,CCSizeMake(self.bgLayer:getContentSize().width*0.5-40,0),kCCTextAlignment2,kCCVerticalTextAlignmentCenter)
            noDataLb:setAnchorPoint(ccp(1,0.5))
            noDataLb:setPosition(ccp(self.bgLayer:getContentSize().width-needPos2,posY))
            self.bgLayer:addChild(noDataLb)
            noDataLb:setColor(G_ColorRed)

            levelLb:setColor(G_ColorRed)
            nextLevelLb:setColor(G_ColorRed)
        end
    end

    local lineSp2 =CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp2:setScaleX((size.width-20)/lineSp2:getContentSize().width)
    lineSp2:setScaleY(1.2)
    lineSp2:setPosition(ccp(size.width/2,100))
    self.bgLayer:addChild(lineSp2,2)

    local descLb=GetTTFLabelWrap(getlocal("merge_all_desc"),22,CCSizeMake(self.bgLayer:getContentSize().width-120,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    descLb:setAnchorPoint(ccp(0.5,0.5))
    descLb:setPosition(ccp(self.bgLayer:getContentSize().width/2-40,lineSp2:getPositionY()-lineSp2:getContentSize().height-descLb:getContentSize().height/2))
    self.bgLayer:addChild(descLb)
    descLb:setColor(G_ColorRed)

    -- 帮助按钮信息
    local function showInfo()
        PlayEffect(audioCfg.mouseClick)

        local td=smallDialog:new()
        local tabStr = {" ",getlocal("merge_all_tip2"),getlocal("merge_all_tip1")," "}
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    infoItem:setScale(0.9)
    local infoBtn = CCMenu:createWithItem(infoItem)
    infoBtn:setPosition(ccp(self.bgLayer:getContentSize().width-60,60))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(infoBtn,2)


    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer
end

-- 能量结晶套装面板
function smallDialog:showMergeAllCrystalResultDialog(successList,failList,successLevel,failLevel,layerNum)
      local sd=smallDialog:new()
      local dialog=sd:initMergeAllCrystalResultDialog(successList,failList,successLevel,failLevel,layerNum)
      return sd
end
function smallDialog:initMergeAllCrystalResultDialog(successList,failList,successLevel,failLevel,layerNum)
    self.layerNum=layerNum
    self.isTouch=true
    self.isUseAmi=true
    local function touchHandler()
    end
    -- local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),touchHandler)
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),touchHandler)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)

    local failData = false
    if failList and SizeOfTable(failList)>0 then
        failData=true
    end
    local successData=false
    if successList and SizeOfTable(successList)>0 then
        successData=true
    end
    local size=CCSizeMake(520,300-50)
    if failData==true and successData==true then
        size=CCSizeMake(520,450-50)
    end
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()

    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    local function touchLuaSpr()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    -- touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)


    local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-40,self.bgLayer:getContentSize().height-40))
    dialogBg2:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(dialogBg2)
    local lineSp1=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
    lineSp1:setAnchorPoint(ccp(0.5,1))
    lineSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height))
    self.bgLayer:addChild(lineSp1)
    local lineSp2=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
    lineSp2:setAnchorPoint(ccp(0.5,0))
    lineSp2:setPosition(ccp(self.bgLayer:getContentSize().width/2,lineSp2:getContentSize().height))
    self.bgLayer:addChild(lineSp2)
    lineSp2:setRotation(180)
    local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp1:setPosition(ccp(5,self.bgLayer:getContentSize().height/2))
    self.bgLayer:addChild(pointSp1)
    local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp2:setPosition(ccp(self.bgLayer:getContentSize().width-5,self.bgLayer:getContentSize().height/2))
    self.bgLayer:addChild(pointSp2)

    -- local function close()
    --     PlayEffect(audioCfg.mouseClick)
    --     return self:close()
    -- end
    -- local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    -- closeBtnItem:setPosition(ccp(0,0))
    -- closeBtnItem:setAnchorPoint(CCPointMake(0,0))

    -- self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    -- self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    -- self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    -- self.bgLayer:addChild(self.closeBtn,2)

    -- local titleLb=GetTTFLabel(getlocal("merge_all_result"),32)
    -- titleLb:setAnchorPoint(ccp(0.5,0.5))
    -- titleLb:setPosition(ccp(size.width/2,size.height-50))
    -- self.bgLayer:addChild(titleLb)
    -- titleLb:setColor(G_ColorYellowPro)
    local titlePos=self.bgLayer:getContentSize().height+40
    local titleLb = GetTTFLabel(getlocal("sw_fusion_results"),35)
    titleLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,titlePos+20))
    self.bgLayer:addChild(titleLb,1)
    titleLb:setColor(G_ColorYellow)
    local tmpBg=CCSprite:createWithSpriteFrameName("rewardPanelSuccessBg.png")
    local originalWidth=tmpBg:getContentSize().width
    local titleBgWidth=titleLb:getContentSize().width+260
    if titleBgWidth<originalWidth then
        titleBgWidth=originalWidth
    end
    if titleBgWidth>(G_VisibleSizeWidth) then
        titleBgWidth=G_VisibleSizeWidth
    end
    local rewardTitleBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelSuccessBg.png",CCRect(originalWidth/2, 20, 1, 1),function ()end)
    rewardTitleBg:setContentSize(CCSizeMake(titleBgWidth,tmpBg:getContentSize().height))
    rewardTitleBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,titlePos))
    self.bgLayer:addChild(rewardTitleBg)
    local rewardTitleLineSp=CCSprite:createWithSpriteFrameName("rewardPanelSuccessLight.png")
    rewardTitleLineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,titlePos))
    self.bgLayer:addChild(rewardTitleLineSp)

    -- local lineSp =CCSprite:createWithSpriteFrameName("LineCross.png")
    -- lineSp:setScaleX((size.width-20)/lineSp:getContentSize().width)
    -- lineSp:setScaleY(1.2)
    -- lineSp:setPosition(ccp(size.width/2,size.height-80))
    -- self.bgLayer:addChild(lineSp,2)

    -- local posY = lineSp:getPositionY()-30
    local posY = size.height-50
    local successLb=GetTTFLabel(getlocal("merge_all_success"),25)
    successLb:setAnchorPoint(ccp(0,0.5))
    successLb:setPosition(ccp(30,posY))
    self.bgLayer:addChild(successLb)
    successLb:setColor(G_ColorGreen)
    -- local successLvLb=GetTTFLabel(getlocal("city_info_level",{successLevel}),25)
    -- successLvLb:setAnchorPoint(ccp(0,0.5))
    -- successLvLb:setPosition(ccp(successLb:getPositionX()+successLb:getContentSize().width,posY))
    -- self.bgLayer:addChild(successLvLb)

    posY = successLb:getPositionY()-successLb:getContentSize().height/2-10
    local bgSprie1=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),touchLuaSpr)
    bgSprie1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,120))
    bgSprie1:setPosition(ccp(self.bgLayer:getContentSize().width/2,posY))
    self.bgLayer:addChild(bgSprie1)
    bgSprie1:setAnchorPoint(ccp(0.5,1))
    bgSprie1:setOpacity(0)

    local function showCrystal(list,parentSp)
        local index = 0
        local listNum=SizeOfTable(list)
        for k,v in pairs(list) do
            local swCrystalVO = swCrystalVo:new()
            swCrystalVO:initWithData(k,v)
            local function clickIconHandler( ... )
                smallDialog:showCrystalInfoDilaog(swCrystalVO:getNameAndLevel(),swCrystalVO:getIconSp(touchLuaSpr),swCrystalVO:getAtt(),self.layerNum+1,-1,nil,swCrystalVO:getLevel())
            end
            local iconSp=swCrystalVO:getIconSp(clickIconHandler)
            -- local posX = 28+(iconSp:getContentSize().width+15)*(index)
            -- if listNum==1 then
            --     posX=parentSp:getContentSize().width/2-iconSp:getContentSize().width/2
            -- end
            index=index+1
            local posXTb=G_getIconSequencePosx(2,iconSp:getContentSize().width+15,parentSp:getContentSize().width/2,listNum)
            local posX = posXTb[index]
            iconSp:setPosition(ccp(posX,parentSp:getContentSize().height/2))
            iconSp:setTouchPriority(-(self.layerNum-1)*20-3)
            iconSp:setAnchorPoint(ccp(0.5,0.5))
            parentSp:addChild(iconSp)

            -- 等级
            local levelLb=GetTTFLabel(tostring(swCrystalVO:getLevelStr()),20)
            levelLb:setPosition(ccp(iconSp:getContentSize().width/2,iconSp:getContentSize().height-5))
            levelLb:setAnchorPoint(ccp(0.5,1));
            iconSp:addChild(levelLb)
            -- 数量
            local numLb=GetTTFLabel(tostring(swCrystalVO:getNumStr()),20)
            numLb:setPosition(ccp(iconSp:getContentSize().width-5,5))
            numLb:setAnchorPoint(ccp(1,0));
            iconSp:addChild(numLb)
        end
    end

    if successData==true then
        showCrystal(successList,bgSprie1)
    else
        -- local noDataLb1=GetTTFLabel(getlocal("alliance_info_content"),25)
        -- noDataLb1:setAnchorPoint(ccp(0.5,0.5))
        -- noDataLb1:setPosition(ccp(bgSprie1:getContentSize().width/2,bgSprie1:getContentSize().height/2))
        -- bgSprie1:addChild(noDataLb1)
    end
-- city_info_level
    posY = bgSprie1:getPositionY()-bgSprie1:getContentSize().height-10
    local failLb=GetTTFLabel(getlocal("merge_all_fail"),25)
    failLb:setAnchorPoint(ccp(0,1))
    failLb:setPosition(ccp(30,posY))
    self.bgLayer:addChild(failLb)
    failLb:setColor(G_ColorRed)
    -- local failLvLb=GetTTFLabel(getlocal("city_info_level",{successLevel}),25)
    -- failLvLb:setAnchorPoint(ccp(0,1))
    -- failLvLb:setPosition(ccp(failLb:getPositionX()+failLb:getContentSize().width,posY))
    -- self.bgLayer:addChild(failLvLb)

    posY = failLb:getPositionY()-failLb:getContentSize().height-10
    local bgSprie2=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),touchLuaSpr)
    bgSprie2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,120))
    bgSprie2:setPosition(ccp(self.bgLayer:getContentSize().width/2,posY))
    self.bgLayer:addChild(bgSprie2)
    bgSprie2:setAnchorPoint(ccp(0.5,1))
    bgSprie2:setOpacity(0)

    if failData==true then
        showCrystal(failList,bgSprie2)
    else
        -- local noDataLb2=GetTTFLabel(getlocal("alliance_info_content"),25)
        -- noDataLb2:setAnchorPoint(ccp(0.5,0.5))
        -- noDataLb2:setPosition(ccp(bgSprie2:getContentSize().width/2,bgSprie2:getContentSize().height/2))
        -- bgSprie2:addChild(noDataLb2)
    end

    if successData==true and failData==false then
        bgSprie2:setVisible(false)
        failLb:setVisible(false)
        -- failLvLb:setVisible(false)
        -- posY = lineSp:getPositionY()-30
        posY = size.height-50
        successLb:setPosition(ccp(30,posY))
        -- successLvLb:setPosition(ccp(successLb:getPositionX()+successLb:getContentSize().width,posY))
        posY = successLb:getPositionY()-successLb:getContentSize().height/2-10
        bgSprie1:setPosition(ccp(self.bgLayer:getContentSize().width/2,posY))
    elseif successData==false and failData==true then
        bgSprie1:setVisible(false)
        successLb:setVisible(false)
        -- successLvLb:setVisible(false)
        -- posY = lineSp:getPositionY()-30
        posY = size.height-50+failLb:getContentSize().height/2
        failLb:setPosition(ccp(30,posY))
        -- failLvLb:setPosition(ccp(failLb:getPositionX()+failLb:getContentSize().width,posY))
        posY = failLb:getPositionY()-failLb:getContentSize().height-10
        bgSprie2:setPosition(ccp(self.bgLayer:getContentSize().width/2,posY))
    end

    local clickLbPosy=-80
    local tmpLb=GetTTFLabel(getlocal("click_screen_continue"),25)
    local clickLb=GetTTFLabelWrap(getlocal("click_screen_continue"),25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    clickLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,clickLbPosy))
    self.bgLayer:addChild(clickLb)
    local arrowPosx1,arrowPosx2
    local realWidth,maxWidth=tmpLb:getContentSize().width,clickLb:getContentSize().width
    if realWidth>maxWidth then
        arrowPosx1=self.bgLayer:getContentSize().width/2-maxWidth/2
        arrowPosx2=self.bgLayer:getContentSize().width/2+maxWidth/2
    else
        arrowPosx1=self.bgLayer:getContentSize().width/2-realWidth/2
        arrowPosx2=self.bgLayer:getContentSize().width/2+realWidth/2
    end
    local smallArrowSp1=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp1:setPosition(ccp(arrowPosx1-15,clickLbPosy))
    self.bgLayer:addChild(smallArrowSp1)
    local smallArrowSp2=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp2:setPosition(ccp(arrowPosx1-25,clickLbPosy))
    self.bgLayer:addChild(smallArrowSp2)
    smallArrowSp2:setOpacity(100)
    local smallArrowSp3=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp3:setPosition(ccp(arrowPosx2+15,clickLbPosy))
    self.bgLayer:addChild(smallArrowSp3)
    smallArrowSp3:setRotation(180)
    local smallArrowSp4=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp4:setPosition(ccp(arrowPosx2+25,clickLbPosy))
    self.bgLayer:addChild(smallArrowSp4)
    smallArrowSp4:setOpacity(100)
    smallArrowSp4:setRotation(180)

    local space=20
    smallArrowSp1:runAction(G_actionArrow(1,space))
    smallArrowSp2:runAction(G_actionArrow(1,space))
    smallArrowSp3:runAction(G_actionArrow(-1,space))
    smallArrowSp4:runAction(G_actionArrow(-1,space))

    sceneGame:addChild(self.dialogLayer,layerNum)
    return self.dialogLayer
end

