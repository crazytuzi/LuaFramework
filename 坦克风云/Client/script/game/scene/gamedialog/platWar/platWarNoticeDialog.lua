
platWarNoticeDialog=commonDialog:new()

function platWarNoticeDialog:new(parent)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	self.editMsgBox=nil
	self.messageBox=nil
	self.messageBox2=nil
	self.editBoxText=nil
	self.changeBtn=nil
	self.messageLabel=nil
	self.messageLabel2=nil
	self.message=nil
	self.keyStr=nil
	self.editReciverBox=nil
	self.reciverBox=nil
	self.reciverText=nil
	self.reciverLabel=nil
	self.reciver=nil
	self.toLabel=nil
	
	
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.chatTab1=nil
    self.chatTab2=nil
    self.chatTab3=nil

    self.langBtnTab={}
    self.touchSp=nil
    self.isShowList=false
    self.languageLb=nil
	self.isAddFlick=false
	self.parent=parent
    return nc
end

--是否是只能选择20句话
function platWarNoticeDialog:isSelectMsg()
	if base.pwNoticeSwitch==2 and self.selectedTabIndex~=2 then
		return true
	end
	return false
end

--设置或修改每个Tab页签
function platWarNoticeDialog:resetTab()
    local index=0
    if SizeOfTable(self.allTabs)==2 then
	    for k,v in pairs(self.allTabs) do
			local  tabBtnItem=v
			if index==0 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
			elseif index==1 then
			tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
			end
		    if index==self.selectedTabIndex then
		        tabBtnItem:setEnabled(false)
		    end
		    index=index+1
	    end
    elseif SizeOfTable(self.allTabs)==3 then
	    for k,v in pairs(self.allTabs) do
			local  tabBtnItem=v
			if index==0 then
			tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
			elseif index==1 then
			tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
			elseif index==2 then
			tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
			end
		    if index==self.selectedTabIndex then
		        tabBtnItem:setEnabled(false)
		    end
		    index=index+1
	    end
	end
	self:tabClick(0)
end

function platWarNoticeDialog:resetForbidLayer()
    if self and self.selectedTabIndex and self.topforbidSp and self.bottomforbidSp then
    	if (self.selectedTabIndex==0) then
    		self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 100))
        elseif (self.selectedTabIndex==1) then
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 100))
        elseif (self.selectedTabIndex==2) then
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 100))
        end
    end
end

--设置对话框里的tableView
function platWarNoticeDialog:initTableView()
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-15,self.bgLayer:getContentSize().height-270),nil)
    
    self.tv:setPosition(ccp(30,100))
    self.tv:setMaxDisToBottomOrTop(120)
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-240))

	local function sendHandler()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
		PlayEffect(audioCfg.mouseClick)

		local noticeCost=platWarCfg.noticeCost
		local donateLevel=80
		if playerVoApi:getPlayerLevel()<donateLevel then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("plat_war_notice_tip",{donateLevel,noticeCost}),30)
			do return end
		end
		if self.selectedTabIndex==2 then
		else
			if(noticeCost>playerVoApi:getGems())then
				GemsNotEnoughDialog(nil,nil,noticeCost - playerVoApi:getGems(),self.layerNum+1,noticeCost)
				do return end
			end
		end

		local msgStr=""
		if self.message then
			msgStr=self.message
		end
		if msgStr==nil or msgStr=="" or string.find(msgStr,"%S")==nil then
			--smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("null_message_prompt"),30)
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
        		if self.selectedTabIndex==2 then
        		else
					local costGems=platWarCfg.noticeCost
					playerVoApi:setGems(playerVoApi:getGems()-costGems)
				end
				-- if self and self["chatTab"..self.selectedTabIndex+1] and self["chatTab"..self.selectedTabIndex+1].refresh then
				-- 	self["chatTab"..self.selectedTabIndex+1]:refresh()
				-- end
				if self and self["chatTab"..self.selectedTabIndex+1] and self["chatTab"..self.selectedTabIndex+1].checkUpdate then
					self["chatTab"..self.selectedTabIndex+1]:checkUpdate()
				end
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
				if self.parent then
					self.parent:setLastNotice(1)
				end
			end
			local contentType=1
			-- if self:isSelectMsg()==true then
			-- 	contentType=2
			-- 	msgStr=self.keyStr
			-- end
			local content={msg=msgStr,uid=playerVoApi:getUid(),name=playerVoApi:getPlayerName(),level=playerVoApi:getPlayerLevel(),power=playerVoApi:getPlayerPower(),rank=playerVoApi:getRank(),ts=base.serverTime,vip=playerVoApi:getVipLevel(),contentType=contentType}
			local selfAlliance=allianceVoApi:getSelfAlliance()
			if selfAlliance then
				content.allianceName=selfAlliance.name
			end
			platWarVoApi:sendPlatMsg(self.selectedTabIndex,content,sendPlatMsgCallback)
        end 
        if self.selectedTabIndex==2 then
        	sendPlatMsg()
        else
			local function onConfirm()
				sendPlatMsg()
			end
			smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("plat_war_notice_sure",{noticeCost}),nil,self.layerNum+1)
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
	local selectSp3 = CCSprite:createWithSpriteFrameName("chatBtnAlliance.png")
	local selectSp4 = CCSprite:createWithSpriteFrameName("chatBtnAlliance_Down.png")
	local menuItemSp2 = CCMenuItemSprite:create(selectSp3,selectSp4)
	local selectSp5 = CCSprite:createWithSpriteFrameName("chatBtnFriend.png")
	local selectSp6 = CCSprite:createWithSpriteFrameName("chatBtnFriend_Down.png")
	local menuItemSp3 = CCMenuItemSprite:create(selectSp5,selectSp6)
    self.changeBtn = CCMenuItemToggle:create(menuItemSp1)
	self.changeBtn:addSubItem(menuItemSp2)
	if SizeOfTable(self.allTabs)==3 then
		self.changeBtn:addSubItem(menuItemSp3)
	end
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

	if self.selectedTabIndex~=0 then
		self:tabClick(self.selectedTabIndex,nil,false)
		self.changeBtn:setSelectedIndex(self.selectedTabIndex)
	end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function platWarNoticeDialog:eventHandler(handler,fn,idx,cel)
	do return end
end

function platWarNoticeDialog:getDataByType1( typpe )
	if typpe == nil then
		typpe = 0
	end
	local chatTabType=typpe
	if chatTabType==0 then
		if self.chatTab1==nil then
			-- local list=platWarVoApi:getNoticeListByType(chatTabType+1)
			-- if SizeOfTable(list)>0 then
			-- 	self.chatTab1=platWarNoticeDialogTab1:new()
		 --        self.layerTab1=self.chatTab1:init(self.layerNum,0,self)
		 --        self.bgLayer:addChild(self.layerTab1)
			-- else
				-- local isSuccess=platWarVoApi:initNoticeList(chatTabType)
		  --       if isSuccess==true then
			        self.chatTab1=platWarNoticeDialogTab1:new()
			        self.layerTab1=self.chatTab1:init(self.layerNum,0,self)
			        self.bgLayer:addChild(self.layerTab1)
			    -- end
			-- end
	    end
	    if self.layerTab1 then
	        self.layerTab1:setPosition(ccp(0,0))
	        self.layerTab1:setVisible(true)
	        self.chatTab1:resetTvPos()
	    end
        if self.layerTab2 then
	        self.layerTab2:setPosition(ccp(999333,0))
	        self.layerTab2:setVisible(false)
	    end
	    if self.layerTab3 then
	        self.layerTab3:setPosition(ccp(999333,0))
	        self.layerTab3:setVisible(false)
	    end
	 --    if self.changeBtn then
		-- 	self.changeBtn:setSelectedIndex(idx)
		-- end
		-- self:resetForbidLayer()
	elseif chatTabType==1 then
		if self.chatTab2==nil then
			-- local isSuccess=platWarVoApi:initNoticeList(chatTabType)
			-- if isSuccess==true then
		        self.chatTab2=platWarNoticeDialogTab2:new(self)
		        self.layerTab2=self.chatTab2:init(self.layerNum,1,self)
		        self.bgLayer:addChild(self.layerTab2)
		    -- end
	    end
	    if self.layerTab2 then
	        self.layerTab2:setPosition(ccp(0,0))
	        self.layerTab2:setVisible(true)
	        self.chatTab2:resetTvPos()
	    end
        if self.layerTab1 then
	        self.layerTab1:setPosition(ccp(999333,0))
	        self.layerTab1:setVisible(false)
	    end
        if self.layerTab3 then
	        self.layerTab3:setPosition(ccp(999333,0))
	        self.layerTab3:setVisible(false)
	    end
  --       if self.changeBtn then
		-- 	self.changeBtn:setSelectedIndex(idx)
		-- end
		-- self:resetForbidLayer()
	elseif chatTabType==2 then
		if self.chatTab3==nil then
			-- local isSuccess=platWarVoApi:initNoticeList(chatTabType)
			-- if isSuccess==true then
		        self.chatTab3=platWarNoticeDialogTab3:new(self)
		        self.layerTab3=self.chatTab3:init(self.layerNum,2,self)
		        self.bgLayer:addChild(self.layerTab3)
		    -- end
	    end
	    if self.layerTab3 then
	        self.layerTab3:setPosition(ccp(0,0))
	        self.layerTab3:setVisible(true)
	        self.chatTab3:resetTvPos()
	    end
        if self.layerTab1 then
	        self.layerTab1:setPosition(ccp(999333,0))
	        self.layerTab1:setVisible(false)
	    end
	    if self.layerTab2 then
	        self.layerTab2:setPosition(ccp(999333,0))
	        self.layerTab2:setVisible(false)
	    end
  --       if self.changeBtn then
		-- 	self.changeBtn:setSelectedIndex(idx)
		-- end
		-- self:resetForbidLayer()
	end
end



--点击tab页签 idx:索引
function platWarNoticeDialog:tabClick(idx,isShowJoinDialog,isEffect)
	if isEffect==false then
	else
    	PlayEffect(audioCfg.mouseClick)
    end

    self:tabClickColor(idx)
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            self:getDataByType1(idx)
			self:doUserHandler()
        else
            v:setEnabled(true)
        end
    end

	-- local chatTabType=self:getChatTabType()
	-- if chatTabType==0 then
	-- 	if self.chatTab1==nil then
	-- 		local list=platWarVoApi:getNoticeListByType(chatTabType+1)
	-- 		if SizeOfTable(list)>0 then
	-- 			self.chatTab1=platWarNoticeDialogTab1:new()
	-- 	        self.layerTab1=self.chatTab1:init(self.layerNum,0,self)
	-- 	        self.bgLayer:addChild(self.layerTab1)
	-- 		else
	-- 			local isSuccess=platWarVoApi:initNoticeList(chatTabType)
	-- 	        if isSuccess==true then
	-- 		        self.chatTab1=platWarNoticeDialogTab1:new()
	-- 		        self.layerTab1=self.chatTab1:init(self.layerNum,0,self)
	-- 		        self.bgLayer:addChild(self.layerTab1)
	-- 		    end
	-- 		end
	--     end
	--     if self.layerTab1 then
	--         self.layerTab1:setPosition(ccp(0,0))
	--         self.layerTab1:setVisible(true)
	--         self.chatTab1:resetTvPos()
	--     end
 --        if self.layerTab2 then
	--         self.layerTab2:setPosition(ccp(999333,0))
	--         self.layerTab2:setVisible(false)
	--     end
	--     if self.layerTab3 then
	--         self.layerTab3:setPosition(ccp(999333,0))
	--         self.layerTab3:setVisible(false)
	--     end
	--     if self.changeBtn then
	-- 		self.changeBtn:setSelectedIndex(idx)
	-- 	end
	-- 	self:resetForbidLayer()
	-- elseif chatTabType==1 then
	-- 	if self.chatTab2==nil then
	-- 		local isSuccess=platWarVoApi:initNoticeList(chatTabType)
	-- 		if isSuccess==true then
	-- 	        self.chatTab2=platWarNoticeDialogTab2:new(self)
	-- 	        self.layerTab2=self.chatTab2:init(self.layerNum,1,self)
	-- 	        self.bgLayer:addChild(self.layerTab2)
	-- 	    end
	--     end
	--     if self.layerTab2 then
	--         self.layerTab2:setPosition(ccp(0,0))
	--         self.layerTab2:setVisible(true)
	--         self.chatTab2:resetTvPos()
	--     end
 --        if self.layerTab1 then
	--         self.layerTab1:setPosition(ccp(999333,0))
	--         self.layerTab1:setVisible(false)
	--     end
 --        if self.layerTab3 then
	--         self.layerTab3:setPosition(ccp(999333,0))
	--         self.layerTab3:setVisible(false)
	--     end
 --        if self.changeBtn then
	-- 		self.changeBtn:setSelectedIndex(idx)
	-- 	end
	-- 	self:resetForbidLayer()
	-- elseif chatTabType==2 then
	-- 	if self.chatTab3==nil then
	-- 		local isSuccess=platWarVoApi:initNoticeList(chatTabType)
	-- 		if isSuccess==true then
	-- 	        self.chatTab3=platWarNoticeDialogTab3:new(self)
	-- 	        self.layerTab3=self.chatTab3:init(self.layerNum,2,self)
	-- 	        self.bgLayer:addChild(self.layerTab3)
	-- 	    end
	--     end
	--     if self.layerTab3 then
	--         self.layerTab3:setPosition(ccp(0,0))
	--         self.layerTab3:setVisible(true)
	--         self.chatTab3:resetTvPos()
	--     end
 --        if self.layerTab1 then
	--         self.layerTab1:setPosition(ccp(999333,0))
	--         self.layerTab1:setVisible(false)
	--     end
	--     if self.layerTab2 then
	--         self.layerTab2:setPosition(ccp(999333,0))
	--         self.layerTab2:setVisible(false)
	--     end
 --        if self.changeBtn then
	-- 		self.changeBtn:setSelectedIndex(idx)
	-- 	end
	-- 	self:resetForbidLayer()
	-- end

	if self.changeBtn then
		self.changeBtn:setSelectedIndex(idx)
	end
	self:resetForbidLayer()
	
	if self:isSelectMsg()==true then
	    if self.messageBox then
	    	self.messageBox:setPosition(ccp(999333,0))
	    end
	    if self.messageBox2 and self.changeBtn then
	    	self.messageBox2:setPosition(ccp(self.changeBtn:getContentSize().width,10))
	    end
    	if self.messageLabel2 then
			local color=G_ColorWhite
			if self:getChatTabType()>=1 then
				color=G_ColorBlue
			-- elseif self:getChatTabType()==1 then
			-- 	color=G_ColorPurple
			end
			self.messageLabel2:setColor(color)
			self.message=self.messageLabel2:getString()
		end
    else
	    if self.messageBox and self.changeBtn then
	    	self.messageBox:setPosition(ccp(self.changeBtn:getContentSize().width,10))
	    end
	    if self.editMsgBox and self.messageLabel then
			local color=G_ColorWhite
			if self:getChatTabType()>=1 then
				color=G_ColorBlue
			-- elseif self:getChatTabType()==1 then
			-- 	color=G_ColorPurple
			end
			self.editMsgBox:setFontColor(color)
			self.messageLabel:setColor(color)
			self.message=self.messageLabel:getString()
		end
		if self.messageBox2 then
	    	self.messageBox2:setPosition(ccp(999333,0))
	    end
	end
end

function platWarNoticeDialog:getChatTabType()
    return self.selectedTabIndex
end

function platWarNoticeDialog:resetData()

end

function platWarNoticeDialog:fastTick()
	if self and self["chatTab"..(self.selectedTabIndex+1)] and self["chatTab"..(self.selectedTabIndex+1)].fastTick then
		self["chatTab"..(self.selectedTabIndex+1)]:fastTick()
	end
end
function platWarNoticeDialog:tick()
	if self and self["chatTab"..(self.selectedTabIndex+1)] and self["chatTab"..(self.selectedTabIndex+1)].tick then
		self["chatTab"..(self.selectedTabIndex+1)]:tick()
	end
end

--用户处理特殊需求,没有可以不写此方法
function platWarNoticeDialog:doUserHandler()
	
end

function platWarNoticeDialog:dispose()
	-- chatVoApi:setLastTabIndex(self:getChatTabType())

    -- base.commonDialogOpened_WeakTb["platWarNoticeDialog"]=nil
    -- G_AllianceDialogTb["platWarNoticeDialog"]=nil

    if self.chatTab1~=nil then
        self.chatTab1:dispose()
    end
    if self.chatTab2~=nil then
        self.chatTab2:dispose()
    end
    if self.chatTab3~=nil then
        self.chatTab3:dispose()
    end
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.chatTab1=nil
    self.chatTab2=nil
    self.chatTab3=nil
	
	
	self.editMsgBox=nil
	self.messageBox=nil
	self.messageBox2=nil
	self.editBoxText=nil
	self.changeBtn=nil
	self.messageLabel=nil
	self.messageLabel2=nil
	self.message=nil
	self.editReciverBox=nil
	self.reciverBox=nil
	self.reciverText=nil
	self.reciverLabel=nil
	self.reciver=nil
	self.toLabel=nil
	self.langBtnTab=nil
	self.touchSp=nil
	self.isShowList=nil
	self.languageLb=nil
	self.isAddFlick=false
    self=nil
end






