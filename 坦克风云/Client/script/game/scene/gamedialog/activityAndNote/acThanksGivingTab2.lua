acThanksGivingTab2 ={}
function acThanksGivingTab2:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.bgLayer=nil
    self.layerNum=nil
    self.tv = nil
    self.isToday =nil
    return nc;
end
function acThanksGivingTab2:dispose( )
    self.bgLayer=nil
    self.layerNum=nil
    self.tv = nil
    self.isToday=nil
end
function acThanksGivingTab2:init(layerNum)
    self.isToday =acThanksGivingVoApi:isToday()
    self.bgLayer=CCLayer:create()
    self.layerNum = layerNum

    self:initTableView()
    return self.bgLayer
end


function acThanksGivingTab2:initTableView( )
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth,G_VisibleSize.height-200),nil)
    self.tv:setAnchorPoint(ccp(0,0))
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-6)
    self.tv:setPosition(ccp(0,40))
    self.tv:setMaxDisToBottomOrTop(120)
    self.bgLayer:addChild(self.tv)

end
function acThanksGivingTab2:eventHandler( handler,fn,idx,cel )
  if fn=="numberOfCellsInTableView" then
    return 1
  elseif fn=="tableCellSizeForIndex" then
    local needBgAddHeight =150
    if G_isIphone5() then
        needBgAddHeight =-100
    end
    if G_getIphoneType() == G_iphoneX then
        return  CCSizeMake(G_VisibleSizeWidth-42,G_VisibleSizeHeight-200)-- -100
    else
        return  CCSizeMake(G_VisibleSizeWidth-42,G_VisibleSizeHeight)-- -100
    end
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    self:initCellDia(cell)
    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
  end
end

function acThanksGivingTab2:initCellDia(cellLayer)
    local strSize2 = 22
    local timePos = 70
    local awardSize2 =22
    if G_getCurChoseLanguage() =="it" then
        awardSize2 =19
    elseif G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
        timePos=0
        awardSize2 =25
    end
    local lotsAwardTb,singleSwardTb = acThanksGivingVoApi:getFormatRechargeAward()
    local function clickDe(hd,fn,idx)
    end
    local bgDia =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),clickDe)
    if G_getIphoneType() == G_iphoneX then
        bgDia:setContentSize(CCSizeMake(G_VisibleSizeWidth - 42,G_VisibleSizeHeight-200))
    else 
        bgDia:setContentSize(CCSizeMake(G_VisibleSizeWidth - 42,G_VisibleSizeHeight))
    end
    bgDia:ignoreAnchorPointForPosition(false)
    bgDia:setOpacity(0)
    bgDia:setAnchorPoint(ccp(0.5,0.5))
    bgDia:setPosition(ccp(G_VisibleSizeWidth*0.5,G_VisibleSizeHeight*0.5))
    if G_getIphoneType() == G_iphoneX then
        bgDia:setPosition(ccp(G_VisibleSizeWidth*0.5,(G_VisibleSizeHeight-200)*0.5))
    end
    cellLayer:addChild(bgDia)
    
    local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),strSize2)
    acLabel:setAnchorPoint(ccp(0,1))
    acLabel:setPosition(ccp(70,self.bgLayer:getContentSize().height-15))
    if G_getIphoneType() == G_iphoneX then
        acLabel:setPosition(ccp(70,bgDia:getContentSize().height-15))
    end
    acLabel:setColor(G_ColorYellowPro)
    bgDia:addChild(acLabel)

    local acVo = acThanksGivingVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
    local messageLabel=GetTTFLabel(timeStr,strSize2)
    messageLabel:setAnchorPoint(ccp(0,1))
    messageLabel:setPosition(ccp(190+timePos, acLabel:getPositionY()))
    bgDia:addChild(messageLabel)

-- "activity_vipAction_tab1"

    local function touch33(...)
        self:openInfo()
    end
    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon2.png",touch33,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(0.75)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-2)
    menuDesc:setPosition(ccp(bgDia:getContentSize().width-5,acLabel:getPositionY()))
    bgDia:addChild(menuDesc)

    local taskTitle = GetTTFLabelWrap(getlocal("activity_ganenjiehuikui_eveTask"),30,CCSizeMake(bgDia:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    taskTitle:setPosition(ccp(bgDia:getContentSize().width*0.5,acLabel:getPositionY()-50))
    taskTitle:setColor(G_ColorYellowPro)
    bgDia:addChild(taskTitle) 

    -- "CorpsLevel"
    local SizeBgHeight = 120
    if G_getIphoneType() == G_iphoneX then
        SizeBgHeight = 135
    elseif G_isIphone5() then
        SizeBgHeight =150
    end
    local function callbackSure( ... )
        -- print(" choose Sure--------")
        local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end 
    local taskStrTb={"activity_ganenjiehuikui_taskStr_1","activity_ganenjiehuikui_taskStr_2","activity_ganenjiehuikui_taskStr_3"}
    local function click(tag,object)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
        end
        PlayEffect(audioCfg.mouseClick)
        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
            if tag ==0 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_hadReward"),30) --飘板
            elseif tag ==30 then
                 activityAndNoteDialog:closeAllDialog()
                 vipVoApi:showRechargeDialog(self.layerNum+1)--充值板子
            end
            if tag >0 and tag <4 then
                self:goTask(tag)
            elseif tag>4 and tag<14 then
                self:recAwardWithTask(tag)
            elseif tag>20 and tag <24 then
                self:getRechargeAward(tag-20)
            elseif tag>50 and tag<55 then
                local rechargeedTb = acThanksGivingVoApi:getRechargedLogTb( )
                if rechargeedTb[tag-50] ==1 then
                else
                    local sd=acThanksGivingSmallDialog:new(self.layerNum + 1,tag-50)
                    local dialog= sd:init(callbackSure,lotsAwardTb)
                end
                -- return false
            end
        end
    end
    
    for i=1,3 do
        local headBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
        headBg:setContentSize(CCSizeMake(bgDia:getContentSize().width,SizeBgHeight))
        headBg:setAnchorPoint(ccp(0.5,1))
        headBg:setPosition(ccp(bgDia:getContentSize().width*0.5,taskTitle:getPositionY()-20-(i-1)*SizeBgHeight))
        bgDia:addChild(headBg) 

        local taskAward = GetTTFLabelWrap(getlocal("award"),awardSize2,CCSizeMake(115,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
        taskAward:setPosition(ccp(headBg:getContentSize().width*0.08+15,headBg:getContentSize().height*0.35))
        headBg:addChild(taskAward)

----显示奖励信息 
        local needTaskNum = 0 
        local taskedNum = 0
        local awardList ={}
        local factorValue = 0 --拿到的条件限制
        local whiKey = nil
        -- local needIdxInAward = nil
        local isRec = 0 --领奖颜色标示
        if i ==1 then
             whiKey = "jg"
             taskedNum = math.floor(acThanksGivingVoApi:getMerit( ))
        elseif i ==2 then
             whiKey = "res"
             taskedNum = math.floor(acThanksGivingVoApi:getCargo( ))
        elseif i ==3 then
             whiKey = "challenge"
             taskedNum = math.floor(acThanksGivingVoApi:getGameLevel( ))
        end
        local needIdxInAward,isOver,showAwardIdx,AwardedIdx = acThanksGivingVoApi:getNeedIdxInAward(i) --
        awardList,factorValue= acThanksGivingVoApi:getUpDiaAward(needIdxInAward,whiKey)
        -- print("tonumber(factorValue) <= tonumber(taskedNum)------>",tonumber(factorValue) , tonumber(taskedNum))

        local fTaskedNum = 0
        if tonumber(taskedNum) >tonumber(factorValue) then
            taskedNum =factorValue
        end
        if i ==3 then
            needTaskNum =tonumber(factorValue)
        else     
            needTaskNum = FormatNumber(factorValue)
        end
        if taskedNum >0 then
            fTaskedNum =FormatNumber(taskedNum)
        end

        local taskStr = GetTTFLabelWrap(getlocal(taskStrTb[i],{needTaskNum}),25,CCSizeMake(bgDia:getContentSize().width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        taskStr:setAnchorPoint(ccp(0,0.5))
        taskStr:setPosition(ccp(headBg:getContentSize().width*0.08,headBg:getContentSize().height-25))
        headBg:addChild(taskStr)

        local taskNumsStr = GetTTFLabelWrap(fTaskedNum.."/"..needTaskNum,25,CCSizeMake(bgDia:getContentSize().width-100,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
        taskNumsStr:setAnchorPoint(ccp(1,0.5))
        taskNumsStr:setPosition(ccp(headBg:getContentSize().width-20,headBg:getContentSize().height-30))
        headBg:addChild(taskNumsStr)

        for j=1,SizeOfTable(awardList) do
            local pic = G_getItemIcon(awardList[j],80,true,self.layerNum,nil,self.tv,nil)
            local iconNum = awardList[j].num
            local needWidth = headBg:getContentSize().width*0.15+headBg:getContentSize().width*0.12*j+headBg:getContentSize().width*0.04*(j-1)
            local needHeight = headBg:getContentSize().height*0.4-5

            local iconPicShow = pic
            iconPicShow:setScale(0.7)
            iconPicShow:setTouchPriority(-(self.layerNum-1)*20-2)
            iconPicShow:setPosition(ccp(needWidth,needHeight))
            iconPicShow:setAnchorPoint(ccp(0.5,0.5))
            headBg:addChild(iconPicShow)

            if iconNum >1000 then
                iconNum =FormatNumber(iconNum)
            end
            local iconLabel = GetTTFLabel("x"..iconNum,25)
            iconLabel:setAnchorPoint(ccp(1,0))
            iconLabel:setPosition(ccp(iconPicShow:getContentSize().width-4,4))
            iconPicShow:addChild(iconLabel,2)

        end
----按钮点击事件不完整
        local recevBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",click,i+10,getlocal("daily_scene_get"),24,i+33)
        recevBtn:setAnchorPoint(ccp(1,0.5))
        recevBtn:setScale(0.7)
        local recevMenu=CCMenu:createWithItem(recevBtn)
        recevMenu:setPosition(ccp(headBg:getContentSize().width-15,headBg:getContentSize().height*0.3))
        recevMenu:setTouchPriority(-(self.layerNum-1)*20-2)
        headBg:addChild(recevMenu)
        recevBtn:setVisible(false)

        local goBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",click,i,getlocal("activity_heartOfIron_goto"),24)
        goBtn:setAnchorPoint(ccp(1,0.5))
        goBtn:setScale(0.7)
        local goMenu=CCMenu:createWithItem(goBtn)
        goMenu:setPosition(ccp(headBg:getContentSize().width-15,headBg:getContentSize().height*0.3))
        goMenu:setTouchPriority(-(self.layerNum-1)*20-2)
        headBg:addChild(goMenu)

        if tonumber(factorValue) <= tonumber(taskedNum) or isOver ==true then
            taskedNum =factorValue
            isRec=1
        end
        if isRec==1 then
            taskNumsStr:setColor(G_ColorGreen)
            recevBtn:setVisible(true)
            goBtn:setVisible(false)
            if isOver ==true then
                -- local hadRec = tolua.cast(recevBtn:getChildByTag(i+33),"CCLabelTTF")
                -- hadRec:setString(getlocal("activity_hadReward"))
                recevBtn:setTag(0)
                recevMenu:setTag(0)

                recevBtn:setVisible(false)
                taskNumsStr:setString(getlocal("activity_hadReward"))
                -- rechargeNumsStr:setColor(G_ColorGreen)
                taskNumsStr:setPosition(ccp(headBg:getContentSize().width-20,headBg:getContentSize().height*0.5))
            end
        end
    end

-----------------------------------充值
    -- local adaH = 0
    -- if G_getIphoneType() == G_iphoneX then
    --     adaH = 165
    -- end
    local adaH1 = 0
    if G_getIphoneType() == G_iphoneX then
        adaH1 = 10
    end
    local taskTitle2 = GetTTFLabelWrap(getlocal("activity_vipAction_tab1"),30,CCSizeMake(bgDia:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    taskTitle2:setPosition(ccp(bgDia:getContentSize().width*0.5,bgDia:getContentSize().height*0.5-10+adaH1))
    taskTitle2:setColor(G_ColorYellowPro)
    bgDia:addChild(taskTitle2)

    local rechargedGold = acThanksGivingVoApi:getRechargedGold( )--已充值的金币数
    local rechargeAwardPicTb = acThanksGivingVoApi:getRechargeAwardTb( )--已充值并且领过奖的记录--确定图标使用
    local sureIdTb = acThanksGivingVoApi:getSureAward()--同上
    -- print("rechargedGold---->",rechargedGold)
    for i=1,3 do
        local function onClickChest()
            local rechargeedTb = acThanksGivingVoApi:getRechargedLogTb( )
            if rechargeedTb and rechargeedTb[i] ==1 then
            else
                local sd=acThanksGivingSmallDialog:new(self.layerNum + 1,i)
                local dialog= sd:init(callbackSure,lotsAwardTb)
            end
        end
        local headBg2=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(65,25,1,1),function () do return end end)
        headBg2:setContentSize(CCSizeMake(bgDia:getContentSize().width,SizeBgHeight))
        headBg2:setAnchorPoint(ccp(0.5,1))
        headBg2:setPosition(ccp(bgDia:getContentSize().width*0.5,taskTitle2:getPositionY()-20-(i-1)*SizeBgHeight))
        bgDia:addChild(headBg2) 

        local taskAward2 = GetTTFLabelWrap(getlocal("award"),awardSize2,CCSizeMake(115,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
        taskAward2:setPosition(ccp(headBg2:getContentSize().width*0.08+15,headBg2:getContentSize().height*0.35))
        headBg2:addChild(taskAward2)

        local needRecharge = acThanksGivingVoApi:getNeedRechargeNum(i)
        local taskStr2 = GetTTFLabelWrap(getlocal("activity_ganenjiehuikui_rechargeStr",{needRecharge}),25,CCSizeMake(bgDia:getContentSize().width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        taskStr2:setAnchorPoint(ccp(0,0.5))
        taskStr2:setPosition(ccp(headBg2:getContentSize().width*0.08,headBg2:getContentSize().height-25))
        headBg2:addChild(taskStr2)

        local rechargeShow = rechargedGold
        if tonumber(rechargedGold)>tonumber(needRecharge) then
            rechargeShow = needRecharge
        end
        local rechargeNumsStr = GetTTFLabelWrap(rechargeShow.."/"..needRecharge,25,CCSizeMake(bgDia:getContentSize().width-100,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
        rechargeNumsStr:setAnchorPoint(ccp(1,0.5))
        rechargeNumsStr:setPosition(ccp(headBg2:getContentSize().width-20,headBg2:getContentSize().height-30))
        headBg2:addChild(rechargeNumsStr)

        
        for j=1,3 do
            local needPicData = nil
            local ii=nil
            local pic=nil
            local iconPicShow=nil
            local iconNum = nil
            local freshIcon = nil
            local freshIconPos = nil
            local needWidth = headBg2:getContentSize().width*0.15+headBg2:getContentSize().width*0.12*j+headBg2:getContentSize().width*0.04*(j-1)
            local needHeight = headBg2:getContentSize().height*0.4-5
            if j==1 then
                if (sureIdTb and sureIdTb[i] )or (rechargeAwardPicTb and type(rechargeAwardPicTb[i]) =="number")then-------------------------------------------
                    local picIdx = sureIdTb[i] or rechargeAwardPicTb[i]
                    -- print("picIdx------->",picIdx,rechargeAwardPicTb[i],i)
                    needPicData =lotsAwardTb[i][picIdx]
                    -- pic=needPicData.pic
                    pic =G_getItemIcon(needPicData,80,false,self.layerNum,onClickChest,self.tv,nil)
                    -- pic:setTag(i+50)
                    -- print("pic-------->",pic)
                    if freshIcon then
                        freshIcon:removeFromParentAndCleanup(true)
                    end
                    freshIcon = CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
                    freshIconPos =4

                    iconPicShow = pic
                    iconPicShow:setScale(0.75)
                    iconPicShow:setTag(i+50)
                    iconPicShow:setTouchPriority(-(self.layerNum-1)*20-2)
                    iconPicShow:setPosition(ccp(needWidth,needHeight))
                    iconPicShow:setAnchorPoint(ccp(0.5,0.5))
                    headBg2:addChild(iconPicShow)
                else
                    pic ="unKnowIcon.png"
                    freshIcon = CCSprite:createWithSpriteFrameName("freshIcon.png")
                    freshIconPos =-4

                    iconPicShow = GetButtonItem(pic,pic,pic,onClickChest,i+50,nil,nil)
                    iconPicShow:setScale(0.7)
                    iconPicShow:setAnchorPoint(ccp(0.5,0.5))
                    local iconPicShowMenu2=CCMenu:createWithItem(iconPicShow)
                    iconPicShowMenu2:setPosition(ccp(needWidth,needHeight))
                    iconPicShowMenu2:setTouchPriority(-(self.layerNum-1)*20-2)
                    headBg2:addChild(iconPicShowMenu2)
                end
                



                freshIcon:setAnchorPoint(ccp(1,0))
                freshIcon:setScale(0.8)
                freshIcon:setPosition(ccp(iconPicShow:getContentSize().width+freshIconPos,4))
                iconPicShow:addChild(freshIcon)
            else
                ii = j-1
                needPicData =singleSwardTb[i][ii]
                pic = G_getItemIcon(needPicData,80,true,self.layerNum,nil,self.tv,nil)
                iconPicShow=pic
                iconNum = needPicData.num
            end
             
            if iconPicShow then
                if j ==1 then 

                else
                    iconPicShow:setScale(0.75)
                    iconPicShow:setTouchPriority(-(self.layerNum-1)*20-2)
                    iconPicShow:setPosition(ccp(needWidth,needHeight))
                    iconPicShow:setAnchorPoint(ccp(0.5,0.5))
                    headBg2:addChild(iconPicShow)

                    local iconLabel = GetTTFLabel("x"..iconNum,25)
                    iconLabel:setAnchorPoint(ccp(1,0))
                    iconLabel:setPosition(ccp(iconPicShow:getContentSize().width-4,4))
                    iconPicShow:addChild(iconLabel,2)
                end
            end
        end
        ----按钮点击事件不完整
        local recevBtn2=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",click,i+20,getlocal("daily_scene_get"),24)
        recevBtn2:setAnchorPoint(ccp(1,0.5))
        recevBtn2:setScale(0.7)
        recevBtn2:setVisible(false)
        local recevMenu2=CCMenu:createWithItem(recevBtn2)
        recevMenu2:setPosition(ccp(headBg2:getContentSize().width-15,headBg2:getContentSize().height*0.3))
        recevMenu2:setTouchPriority(-(self.layerNum-1)*20-2)
        headBg2:addChild(recevMenu2)
        -- recevBtn2:setVisible(false)
        local sjNum= acThanksGivingVoApi:getRechargedInAwardSS()
        local rechargeAwardTb = acThanksGivingVoApi:getRechargedLogTb()
        -- print("i <=largeNum",i,sjNum,rechargeAwardTb[i])

        if tonumber(rechargedGold)>=tonumber(needRecharge) and rechargeAwardTb[i]~=1  then
            recevBtn2:setVisible(true)
        elseif tonumber(rechargedGold)>=tonumber(needRecharge) and rechargeAwardTb[i]==1 then
            recevBtn2:setVisible(false)
            rechargeNumsStr:setString(getlocal("activity_hadReward"))
            rechargeNumsStr:setColor(G_ColorGreen)
            rechargeNumsStr:setPosition(ccp(headBg2:getContentSize().width-20,headBg2:getContentSize().height*0.5))
        end
    end

    local rewardBtn =GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",click,30,getlocal("recharge"),25)
    local rewardMenu=CCMenu:createWithItem(rewardBtn)
    local adaH = 25
    if G_getIphoneType() == G_iphoneX then
        rewardMenu:setAnchorPoint(ccp(0.5,0))
        rewardMenu:setScale(0.9)
    end
    rewardMenu:setPosition(ccp(bgDia:getContentSize().width*0.5-adaH,40))
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-2)
    bgDia:addChild(rewardMenu)  

end

function acThanksGivingTab2:getRechargeAward(tag)
    local sureIdTb = acThanksGivingVoApi:getSureAward()
    local awardPid = sureIdTb[tag]
    if awardPid then
        local function rewardCallBack(fn,data )
            local ret,sData = base:checkServerData(data)
            if ret==true then
                -- print("yes~~rechargeAward receive~~~")
                if sData.data.ganenjiehuikui and sData.data.ganenjiehuikui.f2 then
                    acThanksGivingVoApi:setRechargedLogTb( sData.data.ganenjiehuikui.f2 )
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("receivereward_received_success"),30) --飘板
                    local recordPoint = self.tv:getRecordPoint()
                    self.tv:reloadData()
                    self.tv:recoverToRecordPoint(recordPoint)
                end
            end
        end
        socketHelper:thanksGivingYou(rewardCallBack,"4",awardPid,tag)
    else
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_ganenjiehuikui_awardNoChoose"),30) 
    end
end


function acThanksGivingTab2:goTask(tag)
    activityAndNoteDialog:closeAllDialog()
    if tag <3 then 
        worldScene:setShow()
    else
        storyScene:setShow()
    end
end
function acThanksGivingTab2:recAwardWithTask(tag)
    local idx = tag-10
    local whiKey = nil
    local taskedNum = nil

    if idx ==1 then
         whiKey = "jg"
         taskedNum = math.floor(acThanksGivingVoApi:getMerit( ))
    elseif idx ==2 then
         whiKey = "res"
         taskedNum = math.floor(acThanksGivingVoApi:getCargo( ))
    elseif idx ==3 then
         whiKey = "challenge"
         taskedNum = math.floor(acThanksGivingVoApi:getGameLevel( ))
    end
    local needIdxInAward = acThanksGivingVoApi:getNeedIdxInAward(idx) --
    local awardList,factorValue= acThanksGivingVoApi:getUpDiaAward(needIdxInAward,whiKey)
    local function rewardCallBack(fn,data )
        local ret,sData = base:checkServerData(data)
        if ret==true then
            -- print("yes~~taskAward receive~~~")
            if sData.data.ganenjiehuikui and sData.data.ganenjiehuikui.f then
                acThanksGivingVoApi:setRecAwardTb(sData.data.ganenjiehuikui.f )
                acThanksGivingVoApi:zeroRushInTask(whiKey,needIdxInAward)
                G_showRewardTip(awardList)
                local recordPoint = self.tv:getRecordPoint()
                self.tv:reloadData()
                self.tv:recoverToRecordPoint(recordPoint)
            end
        end
    end
    socketHelper:thanksGivingYou(rewardCallBack,"2",needIdxInAward,whiKey)--callback,action,tid,type
end

function acThanksGivingTab2:openInfo( )
    local td=smallDialog:new()
    local tabStr = nil 
    tabStr ={"\n",getlocal("activity_ganenjiehuikui_tip3"),"\n",getlocal("activity_ganenjiehuikui_tip2"),"\n",getlocal("activity_ganenjiehuikui_tip1"),"\n"}
    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,nil)
    sceneGame:addChild(dialog,self.layerNum+1)
end

function acThanksGivingTab2:tick( )
      local istoday = acThanksGivingVoApi:isToday()
      -- print("isToday------self.isToday",istoday,self.isToday, acThanksGivingVoApi:getUpLastTime())
      if istoday ~= self.isToday then
        -- print("here?????")
        self.isToday = istoday
        acThanksGivingVoApi:updateLastTime()
        acThanksGivingVoApi:setAllDataRefresh_0( )
        local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
      end
end