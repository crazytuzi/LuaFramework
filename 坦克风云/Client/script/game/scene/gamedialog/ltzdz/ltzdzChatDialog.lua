ltzdzChatDialog=commonDialog:new()

function ltzdzChatDialog:new( layerNum )
    local nc = {}
    setmetatable(nc,self)
    self.__index =self
    nc.acTab1=nil
    nc.acTab2=nil

    nc.layerTab1=nil
    nc.layerTab2=nil
    nc.layerNum=layerNum

    local function addPlist()
    end
    G_addResource8888(addPlist)
    spriteController:addPlist("public/chat_image.plist")
    spriteController:addTexture("public/chat_image.png")

    return nc
end

function ltzdzChatDialog:resetTab( )

    local index=0
    local tabHeight=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v
         if index==0 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==1 then
         tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)
         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80-tabHeight)

         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
end

function ltzdzChatDialog:tabClick(idx,isEffect)
	if isEffect==nil then
		isEffect=true
	end
    if(isEffect)then
        PlayEffect(audioCfg.mouseClick)
    end
    self:tabClickColor(idx)
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
        else
            v:setEnabled(true)
        end
    end
    self:getDataByType(idx + 1)
end
function ltzdzChatDialog:getDataByType(type)
    if(type==nil)then
      return
    end 
    if type==1 then
        if self.layerTab1 ==nil then
            self.acTab1=ltzdzChatTab1:new(self.layerNum)
            self.layerTab1=self.acTab1:init()
            self.bgLayer:addChild(self.layerTab1,1)
        end
        self.layerTab1:setVisible(true)
        self.layerTab1:setPosition(ccp(0,0))

        self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
        self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-240))
        
        if self.layerTab2 then
            self.layerTab2:setVisible(false)
            self.layerTab2:setPosition(ccp(99930,0))
        end
        self:clearReciver()
    elseif type==2 then

        if self.layerTab2 ==nil then
            self.acTab2=ltzdzChatTab2:new(self.layerNum,self)
            self.layerTab2=self.acTab2:init()
            self.bgLayer:addChild(self.layerTab2,1);
        end
        self.layerTab2:setVisible(true)
        self.layerTab2:setPosition(ccp(0,0))

        local hSpace=65
        self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35+hSpace/2))
        self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-240-hSpace))

        if self.layerTab1 then
            self.layerTab1:setVisible(false)
            self.layerTab1:setPosition(ccp(10000,0))
        end
        self:initReciver()
    end
    self:resetForbidLayer()
    if self.changeBtn then
        self.changeBtn:setSelectedIndex(self.selectedTabIndex)
    end

    if self.editMsgBox and self.messageLabel then
        local color=ltzdzChatVoApi:getTypeInfo(type)
        self.editMsgBox:setFontColor(color)
        self.messageLabel:setColor(color)
    end
end



function ltzdzChatDialog:initTableView()
    local function callback( ... )
    end
    local hd= LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-65-120),nil)

    local function sendHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        if base.serverTime<ltzdzChatVoApi.nextSendTime then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("time_limit_prompt",{ltzdzChatVoApi.nextSendTime-base.serverTime}),true,self.layerNum+1)
            do return end
        end

        local msgStr=""
        -- print("self.message",self.message)
        if self.message then
            msgStr=self.message
        end
        if msgStr==nil or msgStr=="" or string.find(msgStr,"%S")==nil then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("null_message_prompt"),true,self.layerNum+1)
            do return end
        end

        --检测并替换屏蔽字，阿拉伯需求
        msgStr=keyWordCfg:keyWordsReplace(msgStr)
        if  platCfg.platCfgKeyWord[G_curPlatName()]~=nil  then --设置屏蔽字
            if keyWordCfg:keyWordsJudge(msgStr)==false then
                do
                    return
                end
            end
        end

        local function sendPlatMsg()
            local function sendPlatMsgCallback()
               
                -- if self and self["chatTab"..self.selectedTabIndex+1] and self["chatTab"..self.selectedTabIndex+1].checkUpdate then
                --     self["chatTab"..self.selectedTabIndex+1]:checkUpdate()
                -- end
                
            end
          
        end 
        local function refreshFunc()
            self.messageLabel:setString("")
            self.messageLabel2:setString("")
            self.message=""
            self.keyStr=""
            if self.editMsgBox then
                self.editMsgBox:setText("")
            end
            if self.editBoxText then
                self.editBoxText=""
            end
        end
        if self.selectedTabIndex==0 then
            ltzdzChatVoApi:chatSocket(refreshFunc,1,msgStr,nil)
        else
            if self.reciver==nil or self.reciver==0 then
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("ltzdz_whisper_message_des1"),true,self.layerNum+1)
                do return end
            end
            ltzdzChatVoApi:chatSocket(refreshFunc,2,msgStr,self.reciver,self.nickName)
        end
    end
    self.sendBtn=GetButtonItem("mainBtnChat.png","mainBtnChat_Down.png","mainBtnChat_Down.png",sendHandler,nil,nil,nil)
    self.sendBtn:setAnchorPoint(ccp(1,0))
    local sendSpriteMenu=CCMenu:createWithItem(self.sendBtn)
    sendSpriteMenu:setPosition(ccp(G_VisibleSizeWidth,10))
    sendSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-5)
    self.bgLayer:addChild(sendSpriteMenu,2)

    local function changeHandler()
        local index=self.changeBtn:getSelectedIndex()
        self:tabClick(index)
    end
    local tabBtn=CCMenu:create()
    local selectSp1 = CCSprite:createWithSpriteFrameName("chatBtnWorld.png")
    local selectSp2 = CCSprite:createWithSpriteFrameName("chatBtnWorld_Down.png")
    local menuItemSp1 = CCMenuItemSprite:create(selectSp1,selectSp2)
    local selectSp5 = CCSprite:createWithSpriteFrameName("chatBtnFriend.png")
    local selectSp6 = CCSprite:createWithSpriteFrameName("chatBtnFriend_Down.png")
    local menuItemSp3 = CCMenuItemSprite:create(selectSp5,selectSp6)
    self.changeBtn = CCMenuItemToggle:create(menuItemSp1)
    -- self.changeBtn:addSubItem(menuItemSp2)
    -- if SizeOfTable(self.allTabs)==3 then
    self.changeBtn:addSubItem(menuItemSp3)
    -- end
    self.changeBtn:setAnchorPoint(CCPointMake(0,0))
    self.changeBtn:setPosition(0,0)
    self.changeBtn:registerScriptTapHandler(changeHandler)
    self.changeBtn:setSelectedIndex(self.selectedTabIndex)
    tabBtn:addChild(self.changeBtn)
    tabBtn:setPosition(ccp(0,5))
    tabBtn:setTouchPriority(-(self.layerNum-1)*20-5)
    self.bgLayer:addChild(tabBtn,2)

    local function callBackMsgHandler(fn,eB,str,type)
        if str==nil then
            str=""
        end
        self.message=str
    end
    self.messageBox=LuaCCScale9Sprite:createWithSpriteFrameName("mainChatBgSmall.png",CCRect(10,10,5,5),function ()end)
    self.messageBox:setContentSize(CCSizeMake(G_VisibleSizeWidth-self.changeBtn:getContentSize().width-self.sendBtn:getContentSize().width/2-3,self.messageBox:getContentSize().height))
    self.messageBox:setIsSallow(false)
    self.messageBox:setTouchPriority(-(self.layerNum-1)*20-4)
    self.messageBox:setAnchorPoint(ccp(0,0))
    self.messageBox:setPosition(ccp(self.changeBtn:getContentSize().width,10))
    
    if G_isIOS() then
        self.messageLabel=GetTTFLabel("",30)
    else
        self.messageLabel=GetTTFLabelWrap("",30,CCSizeMake(self.messageBox:getContentSize().width-40,35),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    end
    self.messageLabel:setAnchorPoint(ccp(0,0.5))
    self.messageLabel:setPosition(ccp(10,self.messageBox:getContentSize().height/2))

    local editBox=customEditBox:new()
    local length=100
    local inputMode=CCEditBox.kEditBoxInputModeSingleLine
    local inputFlag=CCEditBox.kEditBoxInputFlagInitialCapsSentence
    local showLength=self.messageBox:getContentSize().width-60
    self.editMsgBox,self.editBoxText=editBox:init(self.messageBox,self.messageLabel,"mainChatBgSmall.png",CCSizeMake(self.messageBox:getContentSize().width-50,self.messageBox:getContentSize().height),-(self.layerNum-1)*20-4,length,callBackMsgHandler,inputFlag,inputMode,true,nil,G_isIOS() and showLength or nil)

    local function tthandler()
        if self:isSelectMsg()==true then
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            
            local function noticeCallback(noticeStr,keyStr)
                if noticeStr then
                    -- self.messageLabel:setString(noticeStr)
                    self.messageLabel2:setString(noticeStr)
                    self.message=noticeStr
                    self.keyStr=keyStr
                end
            end
            require "luascript/script/game/scene/gamedialog/platWar/platWarNoticeSmallDialog"
            local noticeSmallDialog=platWarNoticeSmallDialog:new()
            noticeSmallDialog:init(self.layerNum+1,noticeCallback)
        end
    end
    self.messageBox2=LuaCCScale9Sprite:createWithSpriteFrameName("mainChatBgSmall.png",CCRect(10,10,5,5),tthandler)
    self.messageBox2:setContentSize(CCSizeMake(G_VisibleSizeWidth-self.changeBtn:getContentSize().width-self.sendBtn:getContentSize().width/2-3,self.messageBox2:getContentSize().height))
    self.messageBox2:setIsSallow(false)
    self.messageBox2:setTouchPriority(-(self.layerNum-1)*20-4)
    self.messageBox2:setAnchorPoint(ccp(0,0))
    self.messageBox2:setPosition(ccp(self.changeBtn:getContentSize().width,10))
    -- if G_isIOS() then
    --     self.messageLabel2=GetTTFLabel("",30)
    -- else
        self.messageLabel2=GetTTFLabelWrap("",30,CCSizeMake(self.messageBox2:getContentSize().width-40,35),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    -- end
    self.messageLabel2:setAnchorPoint(ccp(0,0.5))
    self.messageLabel2:setPosition(ccp(10,self.messageBox2:getContentSize().height/2))
    self.messageBox2:addChild(self.messageLabel2,2)

    if self:isSelectMsg()==true then
        self.messageBox2:setPosition(ccp(self.changeBtn:getContentSize().width,10))
        self.messageBox:setPosition(ccp(999333,0))
    else
        self.messageBox2:setPosition(ccp(999333,0))
        self.messageBox:setPosition(ccp(self.changeBtn:getContentSize().width,10))
    end
    self.bgLayer:addChild(self.messageBox,2)
    self.bgLayer:addChild(self.messageBox2,2)

end

function ltzdzChatDialog:isSelectMsg()
    -- if self.selectedTabIndex~=1 then
    --     return true
    -- end
    return false
end

function ltzdzChatDialog:resetForbidLayer()
    if self and self.selectedTabIndex and self.topforbidSp and self.bottomforbidSp then
        if (self.selectedTabIndex==0) then
            self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-160))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 160))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 100))
        elseif (self.selectedTabIndex==1) then
            self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-160))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 160))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 165))
        end
    end
end

function ltzdzChatDialog:clearReciver()
    if self.reciverLabel then
        self.reciverLabel:removeFromParentAndCleanup(true)
        self.reciverLabel=nil
    end
    if self.editReciverBox then
        self.editReciverBox:removeFromParentAndCleanup(true)
        self.editReciverBox=nil
    end
    if self.reciverBox then
        self.reciverBox:removeFromParentAndCleanup(true)
        self.reciverBox=nil
    end
    if self.toLabel~=nil then
        self.toLabel:setVisible(false)
        self.okBtn:setVisible(false)
    end
end
function ltzdzChatDialog:initReciver()
    self:clearReciver()
    local function callBackReciverHandler(fn,eB,str,type)
        if str==nil then
            str=""
        end
        self.reciver=str
    end
    local function tthandler()
        local function selectPerson(nickName,uid)
            self.nickName=nickName
            self.reciverLabel:setString(nickName)
            self.reciver=uid
        end
        local chatList,ally=ltzdzChatVoApi:getChatList()
        ltzdzChatVoApi:showChatList(self.layerNum+1,true,true,selectPerson,getlocal("ltzdz_power_list"),self,chatList,ally)
    end
    self.reciverBox=LuaCCScale9Sprite:createWithSpriteFrameName("mainChatBgTo.png",CCRect(10,10,5,5),tthandler)
    --self.reciverBox:setContentSize(CCSizeMake(G_VisibleSizeWidth-self.changeBtn:getContentSize().width-self.sendBtn:getContentSize().width/2-3,self.messageBox:getContentSize().height))
    self.reciverBox:setContentSize(CCSizeMake(G_VisibleSizeWidth-self.changeBtn:getContentSize().width-17,self.messageBox:getContentSize().height))
    self.reciverBox:setIsSallow(false)
    self.reciverBox:setTouchPriority(-(self.layerNum-1)*20-4)
    self.reciverBox:setAnchorPoint(ccp(0,0))
    self.reciverBox:setPosition(ccp(self.changeBtn:getContentSize().width,10+self.sendBtn:getContentSize().height))
    
    self.reciverLabel=GetTTFLabel("",30)
    self.reciverLabel:setAnchorPoint(ccp(0,0.5))
    self.reciverLabel:setPosition(ccp(10,self.reciverBox:getContentSize().height/2))
    self.reciverLabel:setColor(G_ColorPurple)
    if self.nickName~=nil then
        self.reciverLabel:setString(self.nickName)
    end
    
    local editBox1=customEditBox:new()
    local length1=20
    local inputMode1=CCEditBox.kEditBoxInputModeSingleLine
    local inputFlag1=CCEditBox.kEditBoxInputFlagInitialCapsSentence
    self.editReciverBox,self.reciverText=editBox1:init(self.reciverBox,self.reciverLabel,"mainChatBgTo.png",nil,-(self.layerNum-1)*20-1,length1,callBackReciverHandler,inputFlag1,inputMode1)
    self.bgLayer:addChild(self.reciverBox,2)
    self.editReciverBox:setFontColor(G_ColorPurple)
    
    if self.toLabel==nil then
        local function showMailList()
            local function selectPerson(nickName,uid)
                self.nickName=nickName
                self.reciverLabel:setString(nickName)
                self.reciver=uid
            end
            local chatList,ally=ltzdzChatVoApi:getChatList()
            ltzdzChatVoApi:showChatList(self.layerNum+1,true,true,selectPerson,getlocal("ltzdz_power_list"),self,chatList,ally)
        end
        local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",showMailList,nil,"",25)
        self.okBtn=CCMenu:createWithItem(okItem)
        self.okBtn:setTouchPriority(-(self.layerNum-1)*20-4)
        self.okBtn:setPosition(ccp(self.changeBtn:getContentSize().width/2,self.changeBtn:getContentSize().height+self.reciverBox:getContentSize().height/2))
        self.bgLayer:addChild(self.okBtn)
        okItem:setScale(0.5)


        self.toLabel=GetTTFLabel(getlocal("chatTo"),40)
        self.toLabel:setScale(1.2)
        self.toLabel:setAnchorPoint(ccp(0.5,0.5))
        self.toLabel:setPosition(getCenterPoint(okItem))
        okItem:addChild(self.toLabel,2)
        self.toLabel:setColor(G_ColorPurple)

    end
    self.toLabel:setVisible(true)
    self.okBtn:setVisible(true)
end

function ltzdzChatDialog:tick()
end

function ltzdzChatDialog:fastTick()
end

function ltzdzChatDialog:refresh()
end

function ltzdzChatDialog:update()

end

function ltzdzChatDialog:dispose()
    if self.layerTab1 then
        self.acTab1:dispose()
    end
    if self.layerTab2 then
        self.acTab2:dispose()
    end
    self.acTab1=nil
    self.acTab2=nil
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerNum=nil
    self.changeBtn=nil
    self.editMsgBox=nil
    self.messageLabel=nil

    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
    end
    self.bgLayer=nil
    spriteController:removePlist("public/chat_image.plist")
    spriteController:removeTexture("public/chat_image.png")
end