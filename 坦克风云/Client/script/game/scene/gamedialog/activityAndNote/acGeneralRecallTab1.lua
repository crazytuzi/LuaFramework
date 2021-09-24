acGeneralRecallTab1 ={}
function acGeneralRecallTab1:new(layerNum)
        local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.bgLayer=nil
    self.layerNum=layerNum
    self.tv = nil
    self.backSprie =nil
    self.showType=nil
    self.showRewardTb ={}
    self.codeBox=nil
    self.codeBox1=nil
    self.codeBox2=nil
    self.codeLabel=nil
    self.handselNumStr=nil
    self.sureIconTb={}
    self.iconPicSpTb = {}
    self.moreBtnTb={}
    self.forkBtnTb={}
    self.btnLbTb={}
    self.giftSp=nil
    self.noRewardLb=nil
    self.touchBgAtCodeBox =nil
    self.boxSpTb=nil
    self.oldHandselNum =0
    self.friendLbTb={}
    return nc;

end
function acGeneralRecallTab1:dispose( )
    self.bgLayer=nil
    self.layerNum=nil
    self.tv = nil
    self.backSprie =nil
    self.showType=nil
    self.showRewardTb =nil
    self.codeBox=nil
    self.codeBox1=nil
    self.codeBox2=nil
    self.codeLabel=nil
    self.handselNumStr =nil
    self.sureIconTb =nil
    self.iconPicSpTb = nil
    self.moreBtnTb=nil
    self.forkBtnTb=nil
    self.btnLbTb=nil
    self.giftSp=nil
    self.noRewardLb=nil
    self.touchBgAtCodeBox =nil
    self.boxSpTb=nil
    self.oldHandselNum =nil
    self.friendLbTb=nil
end

function acGeneralRecallTab1:init(layerNum)
    self.showType = acGeneralRecallVoApi:getPlayerType( )
    self.showRewardTb =acGeneralRecallVoApi:getShowReward( )
    self.isToday = true
    self.bgLayer=CCLayer:create()
    self.layerNum = layerNum

    local count=math.floor((G_VisibleSizeHeight-160)/80)
    for i=1,count do
        local bgSp=CCSprite:createWithSpriteFrameName("threeyear_bg.png")
        bgSp:setAnchorPoint(ccp(0.5,1))
        bgSp:setScaleX((G_VisibleSizeWidth-50)/bgSp:getContentSize().width)
        bgSp:setScaleY(80/bgSp:getContentSize().height)
        bgSp:setPosition(G_VisibleSizeWidth/2,(G_VisibleSizeHeight-160)-(i-1)*bgSp:getContentSize().height)
        self.bgLayer:addChild(bgSp)
        if G_isIphone5()==false and i==count then
            bgSp:setPosition(ccp(bgSp:getPositionX(),bgSp:getPositionY()+20))
        end
    end

    local function noData(hd,fn,index) end
    local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("wsjdzz_di3.png",CCRect(48, 48, 2, 2),noData)
    backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-44, G_VisibleSizeHeight-185))
    backSprie:setAnchorPoint(ccp(0.5,0))
    backSprie:setOpacity(0)
    backSprie:setPosition(ccp(G_VisibleSizeWidth*0.5,25))
    self.bgLayer:addChild(backSprie)
    self.backSprie =backSprie
    local fullWidth = backSprie:getContentSize().width
    local fullHeight = backSprie:getContentSize().height

    local posy=G_VisibleSizeHeight-175
    -- 活动时间
    local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),28)
    acLabel:setAnchorPoint(ccp(0.5,1))
    acLabel:setPosition(ccp(G_VisibleSizeWidth/2,posy))
    self.bgLayer:addChild(acLabel,5)
    acLabel:setColor(G_ColorYellowPro)

    posy=posy-acLabel:getContentSize().height-5
    local acVo = acGeneralRecallVoApi:getAcVo()
    local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.et)
    local timeLabel=GetTTFLabel(timeStr,25)
    timeLabel:setAnchorPoint(ccp(0.5,1))
    timeLabel:setPosition(ccp(G_VisibleSizeWidth/2,posy))
    self.bgLayer:addChild(timeLabel,5)

    local function touch33(...)
        self:openInfo()
    end
    local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch33,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(0.85)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-4)
    menuDesc:setPosition(ccp(G_VisibleSizeWidth-40,G_VisibleSizeHeight-170))
    self.bgLayer:addChild(menuDesc)

    self:activePlayerOrlossPlayerDialog(fullWidth,fullHeight)

    return self.bgLayer
 end
 function acGeneralRecallTab1:openInfo( )

      local td=smallDialog:new()

      local tabStr ={"\n",getlocal("activity_generalRecall_info_5"),"\n",getlocal("activity_generalRecall_info_4"),"\n",getlocal("activity_generalRecall_info_3"),"\n",getlocal("activity_generalRecall_info_2"),"\n",getlocal("activity_generalRecall_info_1",{acGeneralRecallVoApi:getLimitDay()}),"\n"}
      local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,nil)
      sceneGame:addChild(dialog,self.layerNum+1)
 end



function acGeneralRecallTab1:showActivePlayerData( )

    if self.backSprie then
        local acPlayer = acGeneralRecallVoApi:getOldPlayerBD( )
        -- print("acPlayer[4]--->",acPlayer[4])
        local friendData = {getlocal("takeYourFriendStr",{acPlayer[4]}),getlocal("yourFriendLevelStr",{acPlayer[5]}),getlocal("FriendVipStr",{acPlayer[3]})}
        for i=1,3 do
            friendLbStr=GetTTFLabel(friendData[i],26)
            friendLbStr:setAnchorPoint(ccp(0,0.5))
            friendLbStr:setPosition(ccp(30,self.backSprie:getContentSize().height*0.75-40*(i-1)))
            self.backSprie:addChild(friendLbStr,5)
            self.friendLbTb[i] = friendLbStr
        end
        

        local function sureItemCallBack( )
                local function confirmHandler()    
                    if #friendInfoVo.friendTb + 1 > friendInfoVoApi:getfriendCfg(2) then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_err_12003"),28)
                    else    
                        local function callback(fn,data)
                        local ret,sData=base:checkServerData(data)
                          if ret==true then
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("addMailListSuccess",{acPlayer[4]}),28) 
                                local function callbackList(fn,data)
                                    local ret,sData=base:checkServerData(data)
                                    if ret==true then
                                        
                                    end
                                end
                                local itemMenu = tolua.cast(self.backSprie:getChildByTag(321),"CCMenuItemSprite")
                                if itemMenu then
                                    itemMenu:setVisible(false)
                                end
                                for i=1,3 do
                                    self.friendLbTb[i]:setAnchorPoint(ccp(0.5,0.5))
                                    self.friendLbTb[i]:setPosition(ccp(self.backSprie:getContentSize().width*0.5,self.backSprie:getContentSize().height*0.75-40*(i-1)))
                                end
                            socketHelper:friendsList(callbackList)
                          end   
                         end
                        socketHelper:sendfriendApply(acPlayer[1],callback)
                    end
                end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),confirmHandler,getlocal("dialog_title_prompt"),getlocal("mailListDesc",{acPlayer[4]}),nil,self.layerNum+1)
        end
        local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureItemCallBack,321,getlocal("friend_newSys_fr_apply"),22)
        sureItem:setAnchorPoint(ccp(1,0))
        sureItem:setScale(0.8)
        local itemMenu=CCMenu:createWithItem(sureItem)
        itemMenu:setTouchPriority(-(self.layerNum-1)*20-5)
        itemMenu:setTag(321)
        itemMenu:setPosition(ccp(self.backSprie:getContentSize().width-20,self.backSprie:getContentSize().height*0.65))
        self.backSprie:addChild(itemMenu,2)
        -- print("acPlayer[1]",acPlayer[1])
        local function getFriendCallBack(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                if sData and sData.data and sData.data.friends then
                    self.friendTb = friendMailVoApi:getFriendTb()
                    for k,v in pairs(self.friendTb) do
                        if tonumber(v.uid) == tonumber(acPlayer[1]) then
                            itemMenu:setVisible(false)
                            for i=1,3 do
                                self.friendLbTb[i]:setAnchorPoint(ccp(0.5,0.5))
                                self.friendLbTb[i]:setPosition(ccp(self.backSprie:getContentSize().width*0.5,self.backSprie:getContentSize().height*0.75-40*(i-1)))
                            end
                        end
                    end
                end
            end
        end
        socketHelper:friendsList(getFriendCallBack)
    end
end

function acGeneralRecallTab1:activePlayerOrlossPlayerDialog(fullWidth,fullHeight)
    local strSize2 = 25
    local btnLbSubSize = 0
    local needPosX = 5
    local upTitle = getlocal("activity_generalRecall_tab1")
    if self.showType ==2 then
        upTitle = getlocal("invitePlayerStr")
    end
    local title1,title2=upTitle,getlocal("activity_generalRecall_bindingGift")
    local titleBgWidth,titleBgHeight=self.backSprie:getContentSize().width*0.46,50
    local titleBg1=CCSprite:createWithSpriteFrameName("groupSelf.png")
    local scalex,scaley=titleBgWidth/titleBg1:getContentSize().width,titleBgHeight/titleBg1:getContentSize().height
    titleBg1:setAnchorPoint(ccp(0.5,1))
    titleBg1:setPosition(ccp(fullWidth*0.5+needPosX,fullHeight*0.87))
    titleBg1:setScaleX(scalex)
    titleBg1:setScaleY(scaley)
    self.backSprie:addChild(titleBg1,1)
    local lineSp1=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp1:setScaleX(titleBgWidth/lineSp1:getContentSize().width)
    lineSp1:setScaleY(lineSp1:getContentSize().height/45)
    lineSp1:setPosition(ccp(titleBg1:getContentSize().width/2-needPosX,titleBg1:getContentSize().height))
    titleBg1:addChild(lineSp1)
    local lineSp2=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp2:setScaleX(titleBgWidth/lineSp2:getContentSize().width)
    lineSp2:setScaleY(lineSp2:getContentSize().height/45)
    lineSp2:setPosition(ccp(titleBg1:getContentSize().width/2-needPosX,0))
    titleBg1:addChild(lineSp2)

    local titleLb1=GetTTFLabelWrap(title1,30,CCSizeMake(titleBgWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb1:setAnchorPoint(ccp(0.5,0.5))
    titleLb1:setPosition(getCenterPoint(titleBg1))
    titleLb1:setPositionX(titleLb1:getPositionX()-needPosX)
    titleLb1:setScaleX(1/scalex)
    titleLb1:setScaleY(1/scaley)
    titleBg1:addChild(titleLb1)

    local blindWidth,blindHeight = fullWidth-10,fullHeight*0.2
    local function addBlueBg()
        local blueBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
        blueBg:setAnchorPoint(ccp(0.5,1))
        blueBg:setScaleX((blindWidth-4)/blueBg:getContentSize().width)
        blueBg:setScaleY((blindHeight-4)/blueBg:getContentSize().height)
        blueBg:setPosition(ccp(fullWidth*0.5,titleBg1:getPositionY()-55))
        -- blueBg:setOpacity(100)
        self.backSprie:addChild(blueBg)
    end
    G_addResource8888(addBlueBg)
    local bindBg=LuaCCScale9Sprite:createWithSpriteFrameName("wsjdzz_di3.png",CCRect(48, 48, 2, 2),function ( ... )end)
    bindBg:setContentSize(CCSizeMake(blindWidth,blindHeight))
    bindBg:setAnchorPoint(ccp(0.5,1))
    -- bindBg:setOpacity(150)
    bindBg:setPosition(ccp(fullWidth*0.5,titleBg1:getPositionY()-55))
    self.backSprie:addChild(bindBg)
    local bindBgMiddPosY = bindBg:getPositionY()-bindBg:getContentSize().height*0.5
    ---------------\\\\\绑定逻辑////////---------------

    local function recordHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:recordHandler()
    end
    local recordBtn=GetButtonItem("hero_infoBtn.png","hero_infoBtn.png","hero_infoBtn.png",recordHandler,11,nil,nil)
    recordBtn:setScale(0.8)
    local recordMenu=CCMenu:createWithItem(recordBtn)
    recordMenu:setAnchorPoint(ccp(0,1))
    recordMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    recordMenu:setPosition(ccp(G_VisibleSizeWidth-60,titleBg1:getPositionY()))
    self.bgLayer:addChild(recordMenu)
    if self.showType == 1 then
        recordMenu:setVisible(false)
    end
    local recordBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    recordBg:setAnchorPoint(ccp(0.5,1))
    recordBg:setContentSize(CCSizeMake(100,40))
    recordBg:setPosition(ccp(recordBtn:getContentSize().width/2,5))
    recordBg:setScale(1/recordBtn:getScale())
    recordBg:setOpacity(0)
    recordBtn:addChild(recordBg)
    local recordLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),22,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    recordLb:setPosition(recordBg:getContentSize().width/2,recordBg:getContentSize().height-10)
    recordLb:setColor(G_ColorYellowPro)
    recordBg:addChild(recordLb)

    if self.showType ==1 then
            local beBindTb = acGeneralRecallVoApi:getOldPlayerBD( )
            -- print("isbeBind----->",beBindTb)

            local function callBackCodeHandler(fn,eB,str,type)
                if type==0 then
                    self.codeBox1:setVisible(false)
                elseif type==1 then  --检测文本内容变化
                    if str=="" then
                        self.codeLabel:setString(getlocal("activity_generalRecall_input_invite_code"))
                        self.codeLabel:setColor(G_ColorGray)
                        self.inviteCode=""
                        do
                            return
                        end
                    end
                    self.inviteCode=str
                    self.codeLabel:setString(str)
                elseif type==2 then --检测文本输入结束
                    eB:setVisible(false)
                    if self.codeLabel and self.codeLabel:getString()==getlocal("activity_generalRecall_input_invite_code") then
                        self.codeLabel:setColor(G_ColorGray)
                    elseif self.codeLabel then
                        self.codeLabel:setColor(G_ColorWhite)
                    end
                    if self.codeBox1 then
                        self.codeBox1:setVisible(true)
                    end
                end
            end


            local function tthandler()
            end
            self.codeBox1=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarLocal_bg3.png",CCRect(19,19,1,1),tthandler)
            self.codeBox1:setContentSize(CCSizeMake(300,50))

            self.codeLabel=GetTTFLabel(getlocal("activity_generalRecall_input_invite_code"),strSize2)
            self.codeLabel:setAnchorPoint(ccp(0.5,0.5))
            self.codeLabel:setColor(G_ColorGray)
            self.codeBox1:addChild(self.codeLabel,2)
            self.backSprie:addChild(self.codeBox1,2)

            local inviteCode=acGeneralRecallVoApi:getReceiveInviteCode()
            if inviteCode then
                self.inviteCode=inviteCode
                self.codeLabel:setString(tostring(inviteCode))
                self.codeLabel:setColor(G_ColorWhite)
            end
            local codeBox2=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarLocal_bg3.png",CCRect(19,19,1,1),tthandler)
            self.codeBox=CCEditBox:createForLua(CCSize(300,50),codeBox2,nil,nil,callBackCodeHandler)
            self.codeBox:setInputMode(CCEditBox.kEditBoxInputModeSingleLine)
            self.codeBox:setVisible(false)
            self.codeBox:setMaxLength(15)
            self.codeBox:setFont(self.codeLabel.getFontName(self.codeLabel),self.codeLabel.getFontSize(self.codeLabel)/2+2)
            self.backSprie:addChild(self.codeBox,3)

            local function tthandler3()
                PlayEffect(audioCfg.mouseClick)
                self.codeBox:setVisible(true)
            end
            local touchBg=LuaCCScale9Sprite:createWithSpriteFrameName("olympic_collect.png",CCRect(10,10,10,10),tthandler3)
            touchBg:setContentSize(CCSize(300,50))
            touchBg:setTouchPriority(-(self.layerNum-1)*20-4)
            touchBg:setOpacity(0)
            self.touchBgAtCodeBox= touchBg
            self.backSprie:addChild(touchBg,1)

            self.codeBox1:setPosition(ccp(fullWidth*0.5,bindBgMiddPosY))
            self.codeLabel:setPosition(getCenterPoint(self.codeBox1))
            self.codeBox:setPosition(ccp(fullWidth*0.5,bindBgMiddPosY))
            touchBg:setPosition(ccp(fullWidth*0.5,bindBgMiddPosY))

            local function onBind()
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                -- print("self.inviteCode",self.inviteCode)
                if self.inviteCode and self.inviteCode~="" then
                    local function bindCallback(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            if sData.data and sData.data.djrecall then
                                acGeneralRecallVoApi:updateData(sData.data.djrecall)
                                self.bindItem:setEnabled(false)
                                self.bindItem:setVisible(false)
                                self.codeBox1:setVisible(false)
                                self.codeBox1:setPosition(ccp(self.codeBox1:getPositionX(),99999))
                                self.codeLabel:setVisible(false)
                                self.codeLabel:setPosition(ccp(self.codeLabel:getPositionX(),99999))
                                self.codeBox:setVisible(false)
                                self.codeBox:setPosition(ccp(self.codeBox:getPositionX(),99999))
                                self.touchBgAtCodeBox:setVisible(false)
                                self.touchBgAtCodeBox:setPosition(ccp(self.touchBgAtCodeBox:getPositionX(),99999))
                                self:showActivePlayerData()
                                if sData.data.djrecall.bd then
                                    acGeneralRecallVoApi:setBd(sData.data.djrecall.bd)
                                end
                                local lb=tolua.cast(self.bindItem:getChildByTag(101),"CCLabelTTF")
                                if lb then
                                    lb:setString(getlocal("activity_generalRecall_has_bind"))
                                end
                                if self.codeBox then
                                    self.codeBox:setVisible(false)
                                end
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_generalRecall_bind_success"),28)
                                self:refreshBoxState()
                            end
                        end
                    end
                    local inviteCode=self.inviteCode
                    local cmd = "active.djrecall.bind"
                    socketHelper:activeGeneralRecall(cmd,{inviteCode=inviteCode},bindCallback)
                else
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_generalRecall_input_invite_code"),28)
                end
            end
            local itemScale=0.6
            local lbSize=22*1/itemScale
            self.bindItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onBind,nil,getlocal("bindText"),lbSize-btnLbSubSize,101)
            self.bindItem:setScale(itemScale)
            local bindMenu=CCMenu:createWithItem(self.bindItem)
            bindMenu:setTouchPriority(-(self.layerNum-1)*20-4)
            bindMenu:setPosition(fullWidth*0.85,bindBgMiddPosY)
            self.bindMenu = bindMenu
            self.backSprie:addChild(bindMenu,2)

            if acGeneralRecallVoApi:getOldPlayerBD() then
                self.bindItem:setEnabled(false)
                self.bindItem:setVisible(false)
                self.codeBox1:setVisible(false)
                self.codeBox1:setPosition(ccp(self.codeBox1:getPositionX(),99999))
                self.codeLabel:setVisible(false)
                self.codeLabel:setPosition(ccp(self.codeLabel:getPositionX(),99999))
                self.codeBox:setVisible(false)
                self.codeBox:setPosition(ccp(self.codeBox:getPositionX(),99999))
                self.touchBgAtCodeBox:setVisible(false)
                self.touchBgAtCodeBox:setPosition(ccp(self.touchBgAtCodeBox:getPositionX(),99999))
                self:showActivePlayerData()
                local lb=tolua.cast(self.bindItem:getChildByTag(101),"CCLabelTTF")
                if lb then
                    lb:setString(getlocal("activity_generalRecall_has_bind"))
                end
            end

    elseif self.showType == 2 then
            
            local inviteCodeBg=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarLocal_bg3.png",CCRect(10,10,10,10),function ( ... )end)
            inviteCodeBg:setContentSize(CCSizeMake(180,50))
            inviteCodeBg:setAnchorPoint(ccp(0.5,0.5))
            inviteCodeBg:setPosition(ccp(fullWidth*0.5,bindBgMiddPosY))
            self.backSprie:addChild(inviteCodeBg,2)

            local codeNum = acGeneralRecallVoApi:getInviteCode()
            local codeLb=GetTTFLabel(codeNum,25)
            codeLb:setPosition(getCenterPoint(inviteCodeBg))
            inviteCodeBg:addChild(codeLb)
            local inviteCodeLb=GetTTFLabelWrap(getlocal("inviteCodeStr"),strSize2,CCSizeMake(inviteCodeBg:getPositionX()-inviteCodeBg:getContentSize().width/2-20,0),kCCTextAlignmentRight,kCCVerticalTextAlignmentCenter)
            inviteCodeLb:setAnchorPoint(ccp(1,0.5))
            inviteCodeLb:setPosition(ccp(inviteCodeBg:getPositionX()-inviteCodeBg:getContentSize().width*0.5-20,bindBgMiddPosY))
            self.backSprie:addChild(inviteCodeLb,2)

            local function onShare()
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)

                local lastTime=acGeneralRecallVoApi:getLastChatTime()
                if base.serverTime-lastTime>=60 then
                    local message=getlocal("activity_generalRecall_invite_chat",{codeNum})

                    --具体数据需要确定

                    -- if G_curPlatName()=="androidkunlun" or G_curPlatName()=="14" or G_curPlatName()=="androidkunlunz" or G_curPlatName()=="0" then
                    --     local function sendFeedHandler( ... )
                    --         smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_zhanyoujijie_share_success"),28)
                    --         acGeneralRecallVoApi:setLastChatTime(base.serverTime)
                    --     end
                    --     G_sendFeed(1,sendFeedHandler,message)
                    -- else
                        local channelType=1    
                        local sender=playerVoApi:getUid()
                        local senderName=playerVoApi:getPlayerName()
                        local level=playerVoApi:getPlayerLevel()
                        local rank=playerVoApi:getRank()
                        local allianceName
                        local allianceRole
                        if allianceVoApi:isHasAlliance() then
                            local allianceVo=allianceVoApi:getSelfAlliance()
                            allianceName=allianceVo.name
                            allianceRole=allianceVo.role
                        end

                        local params={subType=1,contentType=2,message=message,level=level,rank=rank,power=playerVoApi:getPlayerPower(),uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),pic=playerVoApi:getPic(),ts=base.serverTime,allianceName=allianceName,allianceRole=allianceRole,vip=playerVoApi:getVipLevel(),wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),title=playerVoApi:getTitle(),brType=15,activity={key="djrecall",inviteCode=codeNum}}
                        chatVoApi:sendChatMessage(channelType,sender,senderName,0,"",params)
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_zhanyoujijie_share_success"),28)
                        acGeneralRecallVoApi:setLastChatTime(base.serverTime)
                    -- end
                else
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_zhanyoujijie_share_fail1"),28)
                end
            end
            local shareItem=GetButtonItem("anniversarySend.png","anniversarySendDown.png","anniversarySendDown.png",onShare)
            local shareBtn=CCMenu:createWithItem(shareItem)
            shareBtn:setTouchPriority(-(self.layerNum-1)*20-4)
            shareBtn:setPosition(fullWidth*0.85,bindBgMiddPosY)
            self.backSprie:addChild(shareBtn,2)
    end
    ---------------////////绑定逻辑\\\\\\\---------------

    ----------------\\\\\豪礼逻辑////////---------------
    local titleBg2=CCSprite:createWithSpriteFrameName("groupSelf.png")
    local scalex,scaley=titleBgWidth/titleBg2:getContentSize().width,titleBgHeight/titleBg2:getContentSize().height
    titleBg2:setAnchorPoint(ccp(0.5,1))
    titleBg2:setPosition(ccp(fullWidth*0.5+needPosX,fullHeight*0.59))
    titleBg2:setScaleX(scalex)
    titleBg2:setScaleY(scaley)
    self.backSprie:addChild(titleBg2,1)
    local lineSp3=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp3:setScaleX(titleBgWidth/lineSp3:getContentSize().width)
    lineSp3:setScaleY(lineSp3:getContentSize().height/45)
    lineSp3:setPosition(ccp(titleBg2:getContentSize().width/2-needPosX,titleBg2:getContentSize().height))
    titleBg2:addChild(lineSp3)
    local lineSp4=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp4:setScaleX(titleBgWidth/lineSp4:getContentSize().width)
    lineSp4:setScaleY(lineSp4:getContentSize().height/45)
    lineSp4:setPosition(ccp(titleBg2:getContentSize().width/2-needPosX,0))
    titleBg2:addChild(lineSp4)

    local titleLb2=GetTTFLabelWrap(title2,30,CCSizeMake(titleBgWidth,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLb2:setAnchorPoint(ccp(0.5,0.5))
    titleLb2:setPosition(getCenterPoint(titleBg2))
    titleLb2:setPositionX(titleLb2:getPositionX()-needPosX)
    titleLb2:setScaleX(1/scalex)
    titleLb2:setScaleY(1/scaley)
    titleBg2:addChild(titleLb2)

    local function callBack(...)
        return self:eventHandler2(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(fullWidth,200),nil)
    self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv2:setPosition(ccp(0,5))
    self.backSprie:addChild(self.tv2)
    self.tv2:setMaxDisToBottomOrTop(0)

    local bindStr = self.showType == 1 and getlocal("curVipLevel",{""}) or getlocal("addRecallStr",{""})
    local bindOrIsbindTitle = GetTTFLabelWrap(bindStr,strSize2-2,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    bindOrIsbindTitle:setAnchorPoint(ccp(0,0))
    bindOrIsbindTitle:setColor(G_ColorYellowPro)
    bindOrIsbindTitle:setPosition(ccp(15,fullHeight*0.4+50))
    self.backSprie:addChild(bindOrIsbindTitle)

    local bindTip = GetTTFLabelWrap(getlocal("activity_generalRecall_bindedGetReward"),strSize2-2,CCSizeMake(380,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    bindTip:setAnchorPoint(ccp(0.5,1))
    bindTip:setColor(G_ColorRed)
    bindTip:setPosition(ccp(fullWidth*0.5,fullHeight*0.4-20))
    self.backSprie:addChild(bindTip)
     ---------------////////豪礼逻辑\\\\\\\---------------

     ----------------\\\\\好友赠送礼物////////---------------

    local blindWidth2,blindHeight2 = fullWidth-10,fullHeight*0.33
    local needPosX = 5
    local function addBlueBg2()
        local blueBg2=CCSprite:create("public/superWeapon/weaponBg.jpg")
        blueBg2:setAnchorPoint(ccp(0.5,0))
        blueBg2:setScaleX((blindWidth2-6)/blueBg2:getContentSize().width)
        blueBg2:setScaleY((blindHeight2-6)/blueBg2:getContentSize().height)
        blueBg2:setPosition(ccp(fullWidth*0.5,6))
        -- blueBg2:setOpacity(100)
        self.backSprie:addChild(blueBg2)
    end
    G_addResource8888(addBlueBg2)
    local bindBg2=LuaCCScale9Sprite:createWithSpriteFrameName("wsjdzz_di3.png",CCRect(48, 48, 2, 2),function ( ... )end)
    bindBg2:setContentSize(CCSizeMake(blindWidth2,blindHeight2))
    bindBg2:setAnchorPoint(ccp(0.5,0))
    -- bindBg2:setOpacity(150)
    bindBg2:setPosition(ccp(fullWidth*0.5,3))
    self.backSprie:addChild(bindBg2)

    local titleDownBg=CCSprite:createWithSpriteFrameName("groupSelf.png")
    local scalex,scaley=titleBgWidth/titleDownBg:getContentSize().width,(titleBgHeight*0.8)/titleDownBg:getContentSize().height
    titleDownBg:setAnchorPoint(ccp(0.5,1))
    titleDownBg:setPosition(ccp(fullWidth*0.5+needPosX,bindBg2:getContentSize().height-4))
    titleDownBg:setScaleX(scalex)
    titleDownBg:setScaleY(scaley)
    bindBg2:addChild(titleDownBg,1)
    local lineSpDown1=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSpDown1:setScaleX(titleBgWidth/lineSpDown1:getContentSize().width)
    lineSpDown1:setScaleY(lineSpDown1:getContentSize().height/45)
    lineSpDown1:setPosition(ccp(titleDownBg:getContentSize().width/2-needPosX,titleDownBg:getContentSize().height))
    titleDownBg:addChild(lineSpDown1)
    local lineSpDown2=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSpDown2:setScaleX(titleBgWidth/lineSpDown2:getContentSize().width)
    lineSpDown2:setScaleY(lineSpDown2:getContentSize().height/45)
    lineSpDown2:setPosition(ccp(titleDownBg:getContentSize().width/2-needPosX,0))
    titleDownBg:addChild(lineSpDown2)

    local bindtitleStr = self.showType ==1 and getlocal("activity_generalRecall_bindedSendStr2") or getlocal("activity_generalRecall_bindedSendStr1")
    local titleLbDown=GetTTFLabelWrap(bindtitleStr,strSize2-3,CCSizeMake(520,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    titleLbDown:setAnchorPoint(ccp(0.5,0.5))
    titleLbDown:setPosition(getCenterPoint(titleDownBg))
    titleLbDown:setPositionX(titleLbDown:getPositionX()-needPosX)
    titleLbDown:setScaleX(1/scalex)
    titleLbDown:setScaleY(1/scaley)
    titleDownBg:addChild(titleLbDown)

    if self.showType ==1 then
        self:initLossPlayerGetReward(strSize2,fullWidth,fullHeight,titleBgWidth,titleBgHeight)
    elseif self.showType ==2 then
        self:initActivePlayerGetReward(strSize2,fullWidth,fullHeight,titleBgWidth,titleBgHeight)
    end
    
     ---------------////////好友赠送礼物\\\\\\\---------------
 end

 --设置对话框里的tableView

function acGeneralRecallTab1:eventHandler2(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return 1
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.backSprie:getContentSize().width,200)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local barWidth=450
        local fullWidth=self.backSprie:getContentSize().width
        local fullHeight=self.backSprie:getContentSize().height
        local needVipOrPeople= self.showType == 1 and acGeneralRecallVoApi:getNeedVipTb( ) or acGeneralRecallVoApi:getNeedPeopleTb()
        local curVipOrPeople= self.showType ==1 and playerVoApi:getVipLevel() or acGeneralRecallVoApi:getAddRecallNum( )

        local percentStr=""
        local per=G_getPercentage(curVipOrPeople,needVipOrPeople)
        AddProgramTimer(self.backSprie,ccp(fullWidth*0.5-15,fullHeight*0.4),11,12,percentStr,"platWarProgressBg.png","taskBlueBar.png",13,1,1)
        local timerSpriteLv=self.backSprie:getChildByTag(11)
        timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
        timerSpriteLv:setPercentage(per)
        local timerSpriteBg=self.backSprie:getChildByTag(13)
        timerSpriteBg=tolua.cast(timerSpriteBg,"CCSprite")
        local scalex=barWidth/timerSpriteLv:getContentSize().width
        timerSpriteBg:setScaleX(scalex)
        timerSpriteLv:setScaleX(scalex)

        local totalWidth=timerSpriteBg:getContentSize().width
        local totalHeight=timerSpriteBg:getContentSize().height
        local everyWidth=totalWidth/5

        -- 当前值
        local acSp=CCSprite:createWithSpriteFrameName("taskActiveSp.png")
        acSp:setPosition(ccp(0,totalHeight/2))
        timerSpriteLv:addChild(acSp,2)

        
        local curVipOrPeopleLb=GetBMLabel(curVipOrPeople,G_GoldFontSrc,10)
        curVipOrPeopleLb:setPosition(ccp(acSp:getContentSize().width/2,acSp:getContentSize().height/2-2))
        acSp:addChild(curVipOrPeopleLb,2)
        curVipOrPeopleLb:setScale(0.4)
        self.boxSpTb={}
        -- 每一段进度值
        for k,v in pairs(needVipOrPeople) do
            local acSp1=CCSprite:createWithSpriteFrameName("taskActiveSp1.png")
            acSp1:setPosition(ccp(everyWidth*k,totalHeight/2))
            timerSpriteLv:addChild(acSp1,1)
            acSp1:setScale(1.2)
            local acSp2=CCSprite:createWithSpriteFrameName("taskActiveSp2.png")
            acSp2:setPosition(ccp(everyWidth*k,totalHeight/2))
            timerSpriteLv:addChild(acSp2,1)
            acSp2:setScale(1.2)
            if curVipOrPeople>=v then
                acSp2:setVisible(true)
            else
                acSp2:setVisible(false)
            end

            local numLb=GetBMLabel(v,G_GoldFontSrc,10)
            numLb:setPosition(ccp(everyWidth*k,totalHeight/2))
            timerSpriteLv:addChild(numLb,3)
            numLb:setScale(0.3)

            -- flag 1 未达成 2 可领取 3 已领取
            local flag=acGeneralRecallVoApi:getReceivedState(k)

            local function clickBoxHandler()
                
                
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    PlayEffect(audioCfg.mouseClick)

                    local titleStr=getlocal("activity_openyear_baoxiang" .. k)
                    if flag~=2 then
                        local reward={self.showRewardTb[k]}--
                        local titleColor
                        if k==1 then
                            titleColor=G_ColorWhite
                        elseif k==2 then
                            titleColor=G_ColorGreen
                        elseif k==3 then
                            titleColor=G_ColorBlue
                        elseif k==4 then
                            titleColor=G_ColorPurple
                        elseif k==5 then
                            titleColor=G_ColorOrange
                        end
                        local desStr=getlocal("activity_openyear_allreward_des")
                        acGeneralRecallVoApi:showRewardKu(titleStr,self.layerNum,reward,desStr,titleColor)
                        return
                    end

                    local function refreshFunc(rewardlist)--广播内容需要改！！！！！！！

                        if self.showType ==2 and (k==4 or k==5)then
                            local desStr
                            if k==4 then
                                desStr="activity_generalRecall_chatMessage1"
                            elseif k==5 then
                                desStr="activity_generalRecall_chatMessage2"
                            end
                            local paramTab={}
                            paramTab.functionStr="djrecall"
                            paramTab.addStr="i_also_want"
                            local count = SizeOfTable(acGeneralRecallVoApi:getBindList())
                            local message={key=desStr,param={playerVoApi:getPlayerName(),getlocal("activity_openyear_title"),v,count,titleStr}}
                            chatVoApi:sendSystemMessage(message,paramTab)
                        end

                        -- 此处加弹板
                        if rewardlist then
                            acGeneralRecallVoApi:showRewardDialog(rewardlist,self.layerNum)
                        end
                        local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
                        -- lbBg:setContentSize(CCSizeMake(150,40))
                        lbBg:setScaleX(150/lbBg:getContentSize().width)
                        lbBg:setPosition(everyWidth*k,totalHeight+45)
                        timerSpriteLv:addChild(lbBg,4)
                        lbBg:setScale(0.7)
                        local hasRewardLb=GetTTFLabel(getlocal("activity_hadReward"),22)
                        hasRewardLb:setPosition(everyWidth*k,totalHeight+45)
                        timerSpriteLv:addChild(hasRewardLb,5)
                        if self.boxSpTb and self.boxSpTb[k] then
                            self.boxSpTb[k]:stopAllActions()
                        end
                    end
                    local cmd=self.showType==1 and "active.djrecall.bindReward1" or "active.djrecall.bindReward2"
                    local rid=k
                    -- print("cmd,rid=====",cmd,rid)
                    local rewardlist=FormatItem(self.showRewardTb[k])
                    acGeneralRecallVoApi:socketGeneralRecall(cmd,{rid=rid},refreshFunc,rewardlist)

            end

            local boxScale=0.7
            local boxSp=LuaCCSprite:createWithSpriteFrameName("taskBox"..k..".png",clickBoxHandler)
            boxSp:setTouchPriority(-(self.layerNum-1)*20-2)
            boxSp:setPosition(everyWidth*k,totalHeight+45)
            timerSpriteLv:addChild(boxSp,3)
            boxSp:setScale(boxScale)
            boxSp:setTag(k)
            self.boxSpTb[k]=boxSp
            
            if flag==2 then
                local lightSp = CCSprite:createWithSpriteFrameName("AperturePhoto.png")
                lightSp:setPosition(everyWidth*k,totalHeight+45)
                timerSpriteLv:addChild(lightSp)
                lightSp:setScale(0.5)

                local time = 0.1--0.07
                local rotate1=CCRotateTo:create(time, 30)
                local rotate2=CCRotateTo:create(time, -30)
                local rotate3=CCRotateTo:create(time, 20)
                local rotate4=CCRotateTo:create(time, -20)
                local rotate5=CCRotateTo:create(time, 0)
                local delay=CCDelayTime:create(1)
                local acArr=CCArray:create()
                acArr:addObject(rotate1)
                acArr:addObject(rotate2)
                acArr:addObject(rotate3)
                acArr:addObject(rotate4)
                acArr:addObject(rotate5)
                acArr:addObject(delay)
                local seq=CCSequence:create(acArr)
                local repeatForever=CCRepeatForever:create(seq)
                boxSp:runAction(repeatForever)
            elseif flag==3 then
                boxSp:stopAllActions()
                local lbBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(20, 20, 10, 10),function ()end)
                -- lbBg:setContentSize(CCSizeMake(150,40))
                lbBg:setScaleX(150/lbBg:getContentSize().width)
                lbBg:setPosition(everyWidth*k,totalHeight+45)
                timerSpriteLv:addChild(lbBg,4)
                lbBg:setScale(0.7)
                local hasRewardLb=GetTTFLabel(getlocal("activity_hadReward"),22)
                hasRewardLb:setPosition(everyWidth*k,totalHeight+45)
                timerSpriteLv:addChild(hasRewardLb,5)
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
        if newGuidMgr:isNewGuiding()==true then
             return 0
        else
             return 1
        end
    end
end

function acGeneralRecallTab1:sureToCloseSmallDialog( )
    
end
function acGeneralRecallTab1:cancleToCloseSmallDalog( )
    
end

function acGeneralRecallTab1:cleanFistDialog( )
    acGeneralRecallVoApi:setFixGiftType()
    acGeneralRecallVoApi:setCurSid()
    acGeneralRecallVoApi:setCurGiftNum()
    acGeneralRecallVoApi:setIsNeedGem()
    acGeneralRecallVoApi:setNeedCurPayProp()
    acGeneralRecallVoApi:setSingleNum()
    acGeneralRecallVoApi:setCurPayGems()
end

function acGeneralRecallTab1:initActivePlayerGetReward(strSize2,fullWidth,fullHeight,titleBgWidth,titleBgHeight)
    local PosXSc = {0.18,0.5,0.82}
    local chooseDes = {getlocal("activity_chrisEve_chooseGift"),getlocal("chooseComrade"),getlocal("payToSure"),}
    local iconPicTb = { "unKnowIcon.png", "heroManage.png","resourse_normal_gem.png" }
    local lineBasePosY = {5,-5}
    local function chooseGiftFriendAndPay(hd,fn,index) 
        -- print("index---->",index)
        if acGeneralRecallVoApi:getHandselNum( ) >= acGeneralRecallVoApi:getHandselLimit( ) then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("todaySendingisLimit"),28)
            do return end
        end 
        if index == 311 then
            self:cleanFistDialog()--再次点击选择礼物，清楚上次选择的数据
            if acGeneralRecallVoApi:getMyFriend( ) then

            elseif self.btnLbTb[1] then
                self.btnLbTb[1]:setString(chooseDes[1])
                self.btnLbTb[1]:setColor(G_ColorWhite)
            end
            local errorStr
            local flag=acGeneralRecallVoApi:getDonateState()
            if flag==2 then
                errorStr=getlocal("todaySendingisLimit")
            elseif flag==3 then
                errorStr=getlocal("noBindFriendStr")
            elseif flag==4 then
                errorStr=getlocal("noFriendCanDonate")
            end
            if errorStr then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),errorStr,30)
                return
            end
        elseif (index ==312 or index ==313) and acGeneralRecallVoApi:getFixGiftType( ) == false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("pleaseStrpleaseStr",{getlocal("activity_chrisEve_chooseGift")}),28)
            do return end
        elseif index ==313 and acGeneralRecallVoApi:getMyFriend() ==0 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("pleaseStrpleaseStr",{getlocal("invitePlayerStr")}),28)  
            do return end
        elseif index ==312 then
             
            acGeneralRecallVoApi:setMyFriend()--再次点击选择好友，清除上次选择的数据
            if self.btnLbTb[2] then
                self.btnLbTb[2]:setString(chooseDes[2])
                self.btnLbTb[2]:setColor(G_ColorWhite)
            end
        end



        local function sureCallback()
            self:sureToCloseSmallDialog() 
            if index == 311 then
                local curSid = acGeneralRecallVoApi:getCurSid()
                local gData,gFormatTb = acGeneralRecallVoApi:getLast(curSid)
                if self.sureIconTb[1] then
                    self.sureIconTb[1]:removeFromParentAndCleanup(true)
                end
                if self.btnLbTb[1] then
                    self.btnLbTb[1]:setString(getlocal("changeGiftStr"))
                    self.btnLbTb[1]:setColor(G_ColorYellowPro)
                end
                local newIcon = G_getItemIcon(gFormatTb,100,false,self.layerNum,nil)
                local baseIcon = tolua.cast(self.iconPicSpTb[1],"CCSprite")
                newIcon:setPosition(getCenterPoint(baseIcon))
                baseIcon:addChild(newIcon)
                self.sureIconTb[1] = newIcon
                self.moreBtnTb[1]:setVisible(false)
                self.forkBtnTb[1]:setVisible(true)
            elseif index == 312 then
                self.moreBtnTb[2]:setVisible(false)
                self.forkBtnTb[2]:setVisible(true)
                self.iconPicSpTb[2]:setVisible(false)
                if self.btnLbTb[2] then
                    self.btnLbTb[2]:setString(getlocal("changeFriendStr"))
                    self.btnLbTb[2]:setColor(G_ColorYellowPro)
                end
            elseif index == 313 then
                for i=1,2 do
                    self.moreBtnTb[i]:setVisible(true)
                    self.forkBtnTb[i]:setVisible(false)
                    self.iconPicSpTb[i]:setVisible(true)

                    self.btnLbTb[i]:setString(chooseDes[i])
                    self.btnLbTb[i]:setColor(G_ColorWhite)    
                end
                if self.sureIconTb[1] then
                    self.sureIconTb[1]:removeFromParentAndCleanup(true)
                    self.sureIconTb[1] =nil
                end
            end
        end
        local function cancleCallback()
            self:cancleToCloseSmallDalog() 
            if index == 311 then
                self:cleanFistDialog()
                if self.sureIconTb[1] then
                    self.sureIconTb[1]:removeFromParentAndCleanup(true)
                    self.sureIconTb[1] =nil
                end
                self.moreBtnTb[1]:setVisible(true)
                self.forkBtnTb[1]:setVisible(false)
            elseif index ==312 then
                self.moreBtnTb[2]:setVisible(true)
                self.forkBtnTb[2]:setVisible(false)
                self.iconPicSpTb[2]:setVisible(true)
            elseif index == 313 then
                for i=1,2 do
                    self.moreBtnTb[i]:setVisible(false)
                    self.forkBtnTb[i]:setVisible(true)
                end
            end

        end
        if index==312 then
            acGeneralRecallVoApi:showSelectFriendDialog(self.layerNum+1,sureCallback,cancleCallback)
        else
            self.td=acGeneralRecallSmallDialog:new()
            self.td:init(index-310,sureCallback,cancleCallback,self.layerNum,chooseDes[index-310])
        end
    end
    for i=1,3 do
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("wsjdzz_di3.png",CCRect(48, 48, 2, 2),chooseGiftFriendAndPay)
        backSprie:setTag(310+i)
        backSprie:setContentSize(CCSizeMake(fullWidth*0.23,fullHeight*0.2))
        backSprie:setTouchPriority(-(self.layerNum-1)*20-4)
        backSprie:ignoreAnchorPointForPosition(false)
        backSprie:setAnchorPoint(ccp(0.5,0))
        backSprie:setPosition(ccp(fullWidth*PosXSc[i],50))
        self.backSprie:addChild(backSprie)

        for j=1,2 do
            local lineSp=CCSprite:createWithSpriteFrameName("openyear_line.png")
            lineSp:setAnchorPoint(ccp(0.5,0.5))
            lineSp:setPosition(ccp(backSprie:getContentSize().width*0.5,lineBasePosY[j]+(j-1)*backSprie:getContentSize().height))
            lineSp:setScaleX((backSprie:getContentSize().width*0.8)/lineSp:getContentSize().width)
            backSprie:addChild(lineSp)
        end

        if i == 2 then
            --recruitIcon.png
            local recruitIcon=CCSprite:createWithSpriteFrameName("recruitIcon.png")
            recruitIcon:setAnchorPoint(ccp(0.5,1))
            recruitIcon:setPosition(ccp(backSprie:getContentSize().width*0.5,backSprie:getContentSize().height-15))
            local iconScale =90/recruitIcon:getContentSize().width
            recruitIcon:setScale(iconScale)
            backSprie:addChild(recruitIcon)

        end

        local iconPic=CCSprite:createWithSpriteFrameName(iconPicTb[i])
        self.iconPicSpTb[i] = iconPic
        iconPic:setAnchorPoint(ccp(0.5,1))
        iconPic:setPosition(ccp(backSprie:getContentSize().width*0.5,backSprie:getContentSize().height-15))
        local iconScale =90/iconPic:getContentSize().width
        iconPic:setScale(iconScale)
        backSprie:addChild(iconPic)

        local chooseDesStr = GetTTFLabelWrap(chooseDes[i],strSize2-2,CCSizeMake(backSprie:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
        chooseDesStr:setAnchorPoint(ccp(0.5,1))
        backSprie:addChild(chooseDesStr)
        self.btnLbTb[i] = chooseDesStr
        chooseDesStr:setPosition(ccp(backSprie:getContentSize().width*0.5,iconPic:getPositionY()-iconPic:getContentSize().height*iconScale-10))

        local morePic = CCSprite:createWithSpriteFrameName("moreBtn.png")
        morePic:setAnchorPoint(ccp(0.5,0.5))
        morePic:setPosition(ccp(backSprie:getContentSize().width-5,backSprie:getContentSize().height-5))
        morePic:setScale(0.5)
        backSprie:addChild(morePic)
        self.moreBtnTb[i] =morePic

        local forkPic = CCSprite:createWithSpriteFrameName("IconFault.png")
        forkPic:setAnchorPoint(ccp(0.5,0.5))
        forkPic:setPosition(ccp(backSprie:getContentSize().width-5,backSprie:getContentSize().height-5))
        forkPic:setScale(0.7)
        backSprie:addChild(forkPic)
        forkPic:setVisible(false)
        self.forkBtnTb[i]=forkPic

        if i<3 then
            local pointPic=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
            pointPic:setPosition(ccp(backSprie:getContentSize().width*0.66+backSprie:getPositionX(),backSprie:getPositionY()+backSprie:getContentSize().height*0.5))
            pointPic:setAnchorPoint(ccp(0.5,0.5))
            pointPic:setFlipX(true)
            self.backSprie:addChild(pointPic)

        end
    end
    
    self.handselNumStr = GetTTFLabelWrap(getlocal("activity_xinchunhongbao_giveFirendsNum",{acGeneralRecallVoApi:getHandselNum( ),acGeneralRecallVoApi:getHandselLimit( )}),strSize2-2,CCSizeMake(fullWidth*0.8,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.handselNumStr:setAnchorPoint(ccp(0.5,0.5))
    self.handselNumStr:setPosition(ccp(fullWidth*0.5,30))
    -- self.handselNumStr:setColor(G_ColorRed)
    self.backSprie:addChild(self.handselNumStr)

 end
function acGeneralRecallTab1:initLossPlayerGetReward(strSize2,fullWidth,fullHeight,titleBgWidth,titleBgHeight)
    local giftList=acGeneralRecallVoApi:getGiftList()
    local giftCount=SizeOfTable(giftList)
    local noRewardLb=GetTTFLabelWrap(getlocal("noFriendGiftStr"),25,CCSizeMake(G_VisibleSizeWidth-44,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    self.backSprie:addChild(noRewardLb)
    noRewardLb:setPosition(ccp((G_VisibleSizeWidth-44)/2,130))
    noRewardLb:setColor(G_ColorGray)
    self.noRewardLb=noRewardLb
    local bagPosY=65
    if G_isIphone5() then
        bagPosY=90
    end
    local function nilFunc()
    end
    local rewardBg=LuaCCScale9Sprite:createWithSpriteFrameName("wsjdzz_di3.png",CCRect(48, 48, 2, 2),nilFunc)
    rewardBg:setContentSize(CCSizeMake(130,150))
    rewardBg:ignoreAnchorPointForPosition(false)
    rewardBg:setTouchPriority(-(self.layerNum-1)*20-4)
    rewardBg:setAnchorPoint(ccp(0.5,0))
    rewardBg:setPosition(ccp((G_VisibleSizeWidth-44)/2,bagPosY))
    self.backSprie:addChild(rewardBg)
    self.giftSp=rewardBg
    local bgSize=rewardBg:getContentSize()
    for j=1,2 do
        local lineSp=CCSprite:createWithSpriteFrameName("openyear_line.png")
        lineSp:setAnchorPoint(ccp(0.5,0.5))
        lineSp:setPosition(ccp(bgSize.width/2,bgSize.height-(j-1)*(bgSize.height-10)-5))
        lineSp:setScaleX((bgSize.width-10)/lineSp:getContentSize().width)
        rewardBg:addChild(lineSp)
    end
    local iconPic=CCSprite:createWithSpriteFrameName("unKnowIcon.png")
    iconPic:setAnchorPoint(ccp(0.5,1))
    iconPic:setPosition(ccp(bgSize.width*0.5,bgSize.height-15))
    local iconScale=90/iconPic:getContentSize().width
    iconPic:setScale(iconScale)
    rewardBg:addChild(iconPic)

    local rewardLb=GetTTFLabelWrap(getlocal("friendGiftStr"),25,CCSizeMake(bgSize.width+100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    rewardLb:setAnchorPoint(ccp(0.5,1))
    rewardBg:addChild(rewardLb)
    rewardLb:setPosition(ccp(bgSize.width*0.5,iconPic:getPositionY()-iconPic:getContentSize().height*iconScale-10))

    local function showGiftList()
        local function callback()
            self:refreshLossPlayerGiftLayer()
        end
        require "luascript/script/game/scene/gamedialog/activityAndNote/acGeneralRecallGiftSmallDialog"    
        local dialog=acGeneralRecallGiftSmallDialog:new()
        dialog:init(self.layerNum+1,callback)
    end
    local getItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",showGiftList,111,getlocal("daily_scene_get"),25,101)
    getItem:setAnchorPoint(ccp(0.5,0.5))
    local scaley=60/getItem:getContentSize().height
    getItem:setScaleY(scaley)
    local getMenu=CCMenu:createWithItem(getItem)
    getMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    getMenu:setPosition(ccp(bgSize.width/2,-getItem:getContentSize().height*scaley/2))
    rewardBg:addChild(getMenu)
    self.exchangeBtn=getItem
    local getLb=tolua.cast(getItem:getChildByTag(101),"CCLabelTTF")
    if getLb then
        getLb:setScaleY(1/scaley)
    end

    G_addNumTip(rewardBg,ccp(rewardBg:getContentSize().width+10,rewardBg:getContentSize().height-10),true,giftCount,0.8)

    self:refreshLossPlayerGiftLayer()
end

function acGeneralRecallTab1:recordHandler()
    local bindCount=0
    local list=acGeneralRecallVoApi:getBindList()
    bindCount=SizeOfTable(list)
    if bindCount==0 then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("noBindFriendStr"),30)
        do return end
    end
    acGeneralRecallVoApi:showBindListDialog(self.layerNum+1)    
    -- if rtype==1 then --绑定好友列表
    --     local function showBindList()
    --         -- acGeneralRecallVoApi:showSelectFriendDialog(self.layerNum+1)
    --     end
    --     acGeneralRecallVoApi:socketGeneralRecall("active.djrecall.bindList",nil,showBindList)
    -- elseif rtype==2 then --邀请好友列表

    -- end
end

function acGeneralRecallTab1:tick( )
    
    if acGeneralRecallVoApi:getHandselNum() ~= self.oldHandselNum and self.handselNumStr then
        self.oldHandselNum = acGeneralRecallVoApi:getHandselNum()
        self.handselNumStr:setString(getlocal("activity_xinchunhongbao_giveFirendsNum",{acGeneralRecallVoApi:getHandselNum( ),acGeneralRecallVoApi:getHandselLimit( )}))
    end

    if acGeneralRecallVoApi:isToday()==false and self.isToday==true then
        -- print("self.isToday---->")
        self.isToday=false
         acGeneralRecallVoApi:setHandselNum(0)
         acGeneralRecallVoApi:cleanDsu( )
         if self.handselNumStr then
            self.handselNumStr:setString(getlocal("activity_xinchunhongbao_giveFirendsNum",{0,acGeneralRecallVoApi:getHandselLimit( )}))
         end
    end
    local flag=acGeneralRecallVoApi:getRefreshFlag()
    if flag==true then
        self:refreshBoxState()
        acGeneralRecallVoApi:setRefreshFlag(false)
    end
end

function acGeneralRecallTab1:refreshBoxState()
    if self.tv2 then
        self.tv2:reloadData()
    end
end

function acGeneralRecallTab1:refreshLossPlayerGiftLayer()
    if self.giftSp and self.noRewardLb then
        local giftList=acGeneralRecallVoApi:getGiftList()
        local giftCount=SizeOfTable(giftList)
        if giftCount>0 then
            self.noRewardLb:setVisible(false)
            self.giftSp:setVisible(true)
            G_refreshNumTip(self.giftSp,true,giftCount)
        else
            self.giftSp:setVisible(false)
            self.noRewardLb:setVisible(true)
        end
    end
end


