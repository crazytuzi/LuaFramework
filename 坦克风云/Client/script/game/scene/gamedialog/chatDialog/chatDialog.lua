--require "luascript/script/componet/commonDialog"
require "luascript/script/game/gamemodel/chat/chatVoApi"

chatDialog=commonDialog:new()

function chatDialog:new(chatType,_tabIndex,_reciverName,_reciverUid)
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	self.editMsgBox=nil
	self.messageBox=nil
	self.editBoxText=nil
	self.changeBtn=nil
	self.messageLabel=nil
	self.message=nil
	self.editReciverBox=nil
	self.reciverBox=nil
	self.reciverText=nil
	self.reciverLabel=nil
	self.reciver=nil
	self.reciverUid=nil
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
	self.chatType=chatType

	self.selectedTabIndex=_tabIndex or 0
	self.reciver=_reciverName
	self.reciverUid=_reciverUid
	self.prevTabIndex=nil

	spriteController:addPlist("serverWar/serverWar.plist")
	spriteController:addTexture("serverWar/serverWar.pvr.ccz")
	spriteController:addPlist("public/smbdPic.plist")
	spriteController:addPlist("public/chatVipNoLevel.plist")
    spriteController:addTexture("public/smbdPic.png")
    spriteController:addTexture("public/chatVipNoLevel.png")
    spriteController:addPlist("public/youhuaUI3.plist")
	spriteController:addTexture("public/youhuaUI3.png")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	spriteController:addPlist("public/chat_image.plist")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    -- spriteController:addPlist("public/chatImageNew.plist")
    spriteController:addPlist("public/chatVipNoLevel.plist")
    spriteController:addTexture("public/chatVipNoLevel.png")
    spriteController:addPlist("public/ltzdz/ltzdzSegImages2.plist")
    spriteController:addTexture("public/ltzdz/ltzdzSegImages2.png")
    chatVoApi:loadChatEmoji()
    return nc
end

--是否有军团页签
function chatDialog:isHasAllianceTab()
	if SizeOfTable(self.allTabs)==3 then
		return true
	else
		return false
	end
end
--设置或修改每个Tab页签
function chatDialog:resetTab()
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
		    if index==1 and base.firstAChatFlick==0 then
		    	if allianceVoApi:isHasAlliance() then
		    	else
			    	G_addRectFlicker(tabBtnItem,2.9,1,nil,0)
			    	base.firstAChatFlick=1
			    end
		    end

		    index=index+1
	    end
	end
	if self.chatType==nil then
		self.chatType=self.selectedTabIndex+1
	end
end

function chatDialog:resetForbidLayer()
    if self and self.selectedTabIndex and self.topforbidSp and self.bottomforbidSp then
    	if (self.selectedTabIndex==0) then
    		-- self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-320))
      --       self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 320))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 100))
        elseif (self.selectedTabIndex==1) then
            -- self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-280))
            -- self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 280))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 100))
        elseif (self.selectedTabIndex==2) then
            -- self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-280))
            -- self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 280))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 165))
        end
    end
end

function chatDialog:showLanguageList()
	if self.langBtnTab==nil then
		self.langBtnTab={}
	end
	if self.languageTab==nil then
		self.languageTab={}
	end
	if SizeOfTable(self.languageTab)==0 then
		local platLanCfg=platCfg.platCfgLanType[G_curPlatName()]
		if SizeOfTable(platLanCfg)>1 then
			for k,v in pairs(platLanCfg) do
				table.insert(self.languageTab,k)
			end
		end
	end
	local function selectLanguage(tag,object)
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
		if self then 
			local language
			if self.languageTab[tag] then
				language=self.languageTab[tag]
			else
				language="all"
			end
			chatVoApi:setSelectedLanguage(language)
			self:hideLanguageList()

			if self.languageLb then
				local languageStr=""
				if language=="all" then
					languageStr=getlocal("chat_all_language")
				elseif platCfg.platCfgLanDesc[language] then
					languageStr=platCfg.platCfgLanDesc[language]
				end
				self.languageLb:setString(languageStr)
			end

			if self and self.chatTab1 then
				self.chatTab1:refresh()
			end
		end
	end
	local iScale=1
	-- local platLanCfg=platCfg.platCfgLanType[G_curPlatName()]
	if SizeOfTable(self.langBtnTab)==0 then
		-- if SizeOfTable(platLanCfg)>1 then
			local index=1
			for k,v in pairs(self.languageTab) do
				local language=platCfg.platCfgLanDesc[v]

				local selectBtnItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",selectLanguage,k,language,25)
				selectBtnItem:setScale(iScale)         
				local selectBtnmenu = CCMenu:createWithItem(selectBtnItem)
				selectBtnmenu:setTouchPriority(-(self.layerNum-1)*20-4)
				selectBtnmenu:setPosition(selectBtnItem:getContentSize().width/2*iScale,selectBtnItem:getContentSize().height/2*iScale+15+(selectBtnItem:getContentSize().height/2*iScale)*index)
				self.bgLayer:addChild(selectBtnmenu,4)

				table.insert(self.langBtnTab,selectBtnItem)
				index=index+1
			end

			local language=getlocal("chat_all_language")
			local selectBtnItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",selectLanguage,index,language,25)
			selectBtnItem:setScale(iScale)         
			local selectBtnmenu = CCMenu:createWithItem(selectBtnItem)
			selectBtnmenu:setTouchPriority(-(self.layerNum-1)*20-4)
			selectBtnmenu:setPosition(selectBtnItem:getContentSize().width/2*iScale,selectBtnItem:getContentSize().height/2*iScale+15+(selectBtnItem:getContentSize().height/2*iScale)*index)
			self.bgLayer:addChild(selectBtnmenu,4)
			table.insert(self.langBtnTab,selectBtnItem)
			index=index+1
		-- end
	end
	for k,v in pairs(self.langBtnTab) do
		v:setVisible(true)
		v:setPosition(0,(v:getContentSize().height/2*iScale)*k)
		self.isShowList=true
	end

end
function chatDialog:hideLanguageList()
	if self.langBtnTab==nil then
		self.langBtnTab={}
	end
	for k,v in pairs(self.langBtnTab) do
		if v then
			v:setVisible(false)
			v:setPosition(ccp(0,9999))
			self.isShowList=false
		end
	end
end

--设置对话框里的tableView
function chatDialog:initTableView()
	-- print("当前时间：",G_chatTime(base.serverTime,true))
	if self:isHasAllianceTab() == false then
		if self.selectedTabIndex == 2 then
			self.selectedTabIndex = 1
		end
	end
	self.panelLineBg:setVisible(false)
	self.panelTopLine:setVisible(true)
 	local lineSp=CCSprite:createWithSpriteFrameName("LineEntity.png")
    lineSp:ignoreAnchorPointForPosition(false)
    lineSp:setAnchorPoint(ccp(0.5,0))
    lineSp:setPosition(G_VisibleSizeWidth/2,90)
    lineSp:setScale((G_VisibleSizeWidth-40)/lineSp:getContentSize().width)
    self.bgLayer:addChild(lineSp)

	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	local function touchLuaSpr()
        if self and self.bgLayer then
            self:hideLanguageList()
        end
    end
    self.touchSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr)
    self.touchSp:setTouchPriority(-(self.layerNum-1)*20-4)
    self.touchSp:setIsSallow(false)
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchSp:setContentSize(rect)
    self.touchSp:setOpacity(180)
    self.touchSp:setPosition(getCenterPoint(self.bgLayer))
    self.bgLayer:addChild(self.touchSp)
    self.touchSp:setVisible(False)

    
    
    
    local function showBlackList()
        -- require "luascript/script/game/scene/gamedialog/chatDialog/blacklistDialog"
        -- local vrd=blacklistDialog:new()
        -- local vd = vrd:init(self.layerNum+1)
        require "luascript/script/game/scene/gamedialog/friendInfo/friendInfoSmallDialog"
		friendInfoSmallDialog:showMassageManagerDialog("newSmallPanelBg",CCSizeMake(550,600),CCRect(170,80,22,10),nil,getlocal("friend_newSys_inform_manager"),30,self.layerNum+1)
    end
    local menuItemDesc=GetButtonItem("cin_chatNoBtn.png","cin_chatNoBtn_Down.png","cin_chatNoBtn_Down.png",showBlackList,nil,nil,0)
    menuItemDesc:setAnchorPoint(ccp(0,0))
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(20,self.bgLayer:getContentSize().height-menuItemDesc:getContentSize().height-10))
    self.bgLayer:addChild(menuDesc,1)

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-15,self.bgLayer:getContentSize().height-270),nil)
    
    --self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,100))
    --self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)
	-- self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	-- self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-240))
	
	base.commonDialogOpened_WeakTb["chatDialog"]=self
    -- G_AllianceDialogTb["chatDialog"]=self

    local function tthandler()
    end
	local function sendHandler(obj, tag)
		if base.shutChatSwitch == 1 then
			G_showTipsDialog(getlocal("chat_sys_notopen"))
			do return end
		end
		local layerNum = self.layerNum
		local isSendGifEmoji, emojiId = false
		if type(obj) == "table" and type(obj.close) == "function" and type(tag) == "string" and string.sub(tag, 1, 1) == "f" then
			isSendGifEmoji = true
			emojiId = tag
			if type(obj.layerNum) == "number" then
				layerNum = obj.layerNum
			end
		else
			PlayEffect(audioCfg.mouseClick)
		end

		--检测是否被禁言
		if chatVoApi:canChat(layerNum)==false then
			do return end
		end

		local msgStr=""
		if isSendGifEmoji == true then
			local diffTime = base.serverTime - (base.lastSendEmojiTime or 0)
			if diffTime < chatVoApi:getChatEmojiCfg().sendEmojiCD then
				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("time_limit_prompt",{chatVoApi:getChatEmojiCfg().sendEmojiCD-diffTime}),true,layerNum+1)
				do return end
			end
			msgStr = getlocal("chatEmoji_showTips")
		else
			local playerLv=playerVoApi:getPlayerLevel()
	        local timeInterval=playerCfg.chatLimitCfg[playerLv] or 0
			local diffTime=0
			if base.lastSendTime then
				diffTime=base.serverTime-base.lastSendTime
			end
			if diffTime>0 and diffTime<timeInterval and GM_UidCfg[playerVoApi:getUid()] == nil then
				--smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("time_limit_prompt",{timeInterval-diffTime}),30)
				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("time_limit_prompt",{timeInterval-diffTime}),true,layerNum+1)
				do return end
			end
			--local msgStr=self.editMsgBox:getText()
			--[[
			if self.messageLabel then
				msgStr=self.messageLabel:getString()
			end
			]]
			if self.message then
				msgStr=self.message
			end
	        --[[
			if msgStr~=nil and msgStr~="" then
				msgStr=G_stringGsub(msgStr,"\n","")
				msgStr=G_stringGsub(msgStr,"\r","")
			end
	        ]]
			if msgStr==nil or msgStr=="" or string.find(msgStr,"%S")==nil then
				--smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("null_message_prompt"),30)
				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("null_message_prompt"),true,layerNum+1)
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
	    end
		
		--local type=self.selectedTabIndex+1
        local type=self:getChatTabType()+1
		local content=msgStr
		local reciverName=self.reciver
		local subType=1
		local sender=playerVoApi:getUid()

		if type==2 then
			if reciverName==nil or reciverName=="" then
				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("whisper_message_prompt"),true,layerNum+1)
				do return end
			end
			if tonumber(self.reciverUid)==tonumber(playerVoApi:getUid()) then
				smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("message_scene_whiper_prompt"),true,layerNum+1)
				do return end
			end
			subType=2
		else
			reciverName=""
			if type==3 then
				subType=3
			end
		end

		local senderName=tostring(playerVoApi:getPlayerName())
		local level=playerVoApi:getPlayerLevel()
		local rank=playerVoApi:getRank()
		local power=playerVoApi:getPlayerPower()
		
		--[[
		if type==1 then
			if (reciverName~=nil and reciverName~="") then
				type=2
				subType=2
			end
		end
		]]
		local contentType=1
        local allianceName
        local allianceRole
        if allianceVoApi:isHasAlliance() then
            local allianceVo=allianceVoApi:getSelfAlliance()
            allianceName=allianceVo.name
            allianceRole=allianceVo.role
        end
        local language=G_getCurChoseLanguage()
        local params={subType=subType,contentType=contentType,message=content,level=level,rank=rank,power=power,uid=playerVoApi:getUid(),name=tostring(playerVoApi:getPlayerName()),pic=playerVoApi:getPic(),ts=base.serverTime,allianceName=allianceName,allianceRole=allianceRole,vip=playerVoApi:getVipLevel(),language=language,wr=playerVoApi:getServerWarRank(),st=playerVoApi:getServerWarRankStartTime(),title=playerVoApi:getTitle(),bnum=base.clancrossinfoBnum,rpoint=base.clancrossinfoRpoint,hfid=playerVoApi:getHfid(),cfid=playerVoApi:getCfid(),emojiId=emojiId}
		--chatVoApi:addChat(type,sender,senderName,0,reciverName,params)
		if type==2 then
			local reciver=chatVoApi:getReciverIdByName(reciverName)
			if chatVoApi:isChat2_0() then
				if reciver==0 and self.reciverUid then
					reciver=self.reciverUid
				end
			end
			-- 取消在线提示所需要的假数据
			G_privateDataTip = {}
	        G_privateDataTip.sender = sender
	        G_privateDataTip.senderName = senderName
	        G_privateDataTip.reciver = reciver
	        G_privateDataTip.reciverName = reciverName
	        G_privateDataTip.content = params
	        G_privateDataTip.ts = base.serverTime
        	chatVoApi:sendChatMessage(0,sender,senderName,reciver,reciverName,params)
			-- chatVoApi:addChat(0,sender,senderName,reciver,reciverName,params)
			self:tick()
		elseif type==3 then
			local alliance=allianceVoApi:getSelfAlliance()
			if alliance and alliance.aid then
				chatVoApi:sendChatMessage(alliance.aid+1,sender,senderName,0,reciverName,params)
			end
		else
			if self.chatType and self.chatType>3 then
				chatVoApi:sendChatMessage(self.chatType,sender,senderName,0,reciverName,params)
			else
				chatVoApi:sendChatMessage(type,sender,senderName,0,reciverName,params)
			end
		end

		if isSendGifEmoji == true then
			base.lastSendEmojiTime = base.serverTime
			obj:close()
		else
			base.lastSendTime=base.serverTime
		
			self.editMsgBox:setText("")
			self.messageLabel:setString("")
			self.editBoxText=""
			self.message=""
		end
		
		--self:tick()
		
		--mainUI:setLastChat()
	end
	self.sendBtn=GetButtonItem("cin_mainBtnChat.png","cin_mainBtnChat_Down.png","cin_mainBtnChat_Down.png",sendHandler,nil,nil,nil)
	self.sendBtn:setAnchorPoint(ccp(1,0))
	local sendSpriteMenu=CCMenu:createWithItem(self.sendBtn)
	if G_checkUseAuditUI()==true then
		sendSpriteMenu:setPosition(ccp(G_VisibleSizeWidth-10,27))
	else
		sendSpriteMenu:setPosition(ccp(G_VisibleSizeWidth-10,20))
	end

	sendSpriteMenu:setTouchPriority(-(self.layerNum-1)*20-5)
	self.bgLayer:addChild(sendSpriteMenu,2)

	if chatVoApi:isChat2_0() and base.moji==1 then
		local function onClickGifBtn()
			if G_checkClickEnable() == false then
	            do return end
	        else
	            base.setWaitTime = G_getCurDeviceMillTime()
	        end
	        PlayEffect(audioCfg.mouseClick)
	        chatVoApi:showChatEmojiSmallDialog(self.layerNum + 1, sendHandler)
		end
		self.gifBtn = GetButtonItem("newFrChat.png", "newFrChat_down.png", "newFrChat.png", onClickGifBtn)
		local gifMenu = CCMenu:createWithItem(self.gifBtn)
		gifMenu:setPosition(sendSpriteMenu:getPositionX() - self.sendBtn:getContentSize().width - self.gifBtn:getContentSize().width * self.gifBtn:getScale() / 2, sendSpriteMenu:getPositionY() + self.sendBtn:getContentSize().height / 2)
		gifMenu:setTouchPriority(-(self.layerNum-1)*20-5)
		self.bgLayer:addChild(gifMenu,2)
		local gifBtnSp = CCSprite:createWithSpriteFrameName("chatEmoji_btnIcon.png")
		gifBtnSp:setPosition(self.gifBtn:getContentSize().width / 2, self.gifBtn:getContentSize().height / 2)
		self.gifBtn:addChild(gifBtnSp)
	end
	
	local function changeHandler()
		local platLanCfg=platCfg.platCfgLanType[G_curPlatName()]
		if platCfg.platCfgChatMultiLan[G_curPlatName()] and SizeOfTable(platLanCfg)>1 then
			if self.changeBtn then
				self.changeBtn:setSelectedIndex(self.selectedTabIndex)
			end
			if self.selectedTabIndex==0 then
				if self.isShowList==true then
					self:hideLanguageList()
				else
					self:showLanguageList()
				end
			end
		else
			local index=self.changeBtn:getSelectedIndex()
			self:tabClick(index)
		end
	end
    local tabBtn=CCMenu:create()
    local selectSp1,selectSp2,selectSp3,selectSp4,selectSp5,selectSp6
    if G_checkUseAuditUI() == true or G_getGameUIVer()==1 then
		selectSp1 = CCSprite:createWithSpriteFrameName("cin_chatBtnWorld.png")
    	selectSp2 = CCSprite:createWithSpriteFrameName("cin_chatBtnWorld.png")
    	selectSp3 = CCSprite:createWithSpriteFrameName("cin_chatBtnAlliance.png")
		selectSp4 = CCSprite:createWithSpriteFrameName("cin_chatBtnAlliance.png")
		selectSp5 = CCSprite:createWithSpriteFrameName("cin_chatBtnFriend.png")
		selectSp6 = CCSprite:createWithSpriteFrameName("cin_chatBtnFriend.png")
	else
		selectSp1 = CCSprite:createWithSpriteFrameName("cin_chatBtnWorld1.png")
    	selectSp2 = CCSprite:createWithSpriteFrameName("cin_chatBtnWorld1.png")
    	selectSp3 = CCSprite:createWithSpriteFrameName("cin_chatBtnAlliance1.png")
		selectSp4 = CCSprite:createWithSpriteFrameName("cin_chatBtnAlliance1.png")
		selectSp5 = CCSprite:createWithSpriteFrameName("cin_chatBtnFriend1.png")
		selectSp6 = CCSprite:createWithSpriteFrameName("cin_chatBtnFriend1.png")
	end
    local menuItemSp1 = CCMenuItemSprite:create(selectSp1,selectSp2)
	
	local menuItemSp2 = CCMenuItemSprite:create(selectSp3,selectSp4)
	
	local menuItemSp3 = CCMenuItemSprite:create(selectSp5,selectSp6)
    self.changeBtn = CCMenuItemToggle:create(menuItemSp1)
	if SizeOfTable(self.allTabs)==3 then
		self.changeBtn:addSubItem(menuItemSp2)
	end
	self.changeBtn:addSubItem(menuItemSp3)
    self.changeBtn:setAnchorPoint(CCPointMake(0,0))
    if G_checkUseAuditUI()==true then
    	self.changeBtn:setPosition(10,25)
    else
    	self.changeBtn:setPosition(10,18)
    end
    if self:isHasAllianceTab() == false then
		if self.selectedTabIndex == 2 then
			self.selectedTabIndex = 1
		end
	end
    self.changeBtn:registerScriptTapHandler(changeHandler)
	self.changeBtn:setSelectedIndex(self.selectedTabIndex)
    tabBtn:addChild(self.changeBtn)
	tabBtn:setPosition(ccp(0,5))
	tabBtn:setTouchPriority(-(self.layerNum-1)*20-5)
	self.bgLayer:addChild(tabBtn,2)


	local language=chatVoApi:getSelectedLanguage()
	local languageStr=""
	if language=="all" then
		languageStr=getlocal("chat_all_language")
	elseif platCfg.platCfgLanDesc[language] then
		languageStr=platCfg.platCfgLanDesc[language]
	end
	self.languageLb=GetTTFLabelWrap(languageStr,20,CCSizeMake(menuItemSp1:getContentSize().width+6,200),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.languageLb:setAnchorPoint(ccp(0.5,0.5))
    self.languageLb:setPosition(ccp(42,selectSp1:getContentSize().height/2+10))
    self.bgLayer:addChild(self.languageLb,5)
    self.languageLb:setColor(G_ColorRed)

    local idxType=self.selectedTabIndex+1
    if self.chatType and self.chatType>3 then
    	idxType=self.chatType
    end
    if chatVoApi:isMultiLanguage(idxType) then
    	self.languageLb:setVisible(true)
    else
    	self.languageLb:setVisible(false)
    end

    self:initMsgEditBox()
	
	if self.tv then
		local recordPoint = self.tv:getRecordPoint()
		if recordPoint.y<0 then
			recordPoint.y=0
			self.tv:recoverToRecordPoint(recordPoint)
		end
	end

	if self.reciver and self.reciverUid then
		self:changeReciver(self.reciver,nil,self.reciverUid,true)
	else
		self:tabClick(self.selectedTabIndex)
	end

	local idxType=self.selectedTabIndex+1
    if self.chatType and self.chatType>3 then
    	idxType=self.chatType
    end
	local selectedLanguage=chatVoApi:getSelectedLanguage()
	chatVoApi:setNoNewData(idxType,selectedLanguage)



	-- local lastTabIndex=chatVoApi:getLastTabIndex()
	-- self:setChatTabByType(lastTabIndex)
	-- if self.selectedTabIndex~=0 then
	-- 	self:tabClick(self.selectedTabIndex,nil,false)
	-- 	self.changeBtn:setSelectedIndex(self.selectedTabIndex)
	-- end
end

function chatDialog:initMsgEditBox()
	self:clearMsgEditBox()
	local function tthandler()
    end
	local function callBackMsgHandler(fn,eB,str,type)
		-- 正在输入...
		if str==nil then
			str=""
		end
		self.message=str
		--[[
		local messageLabel=GetTTFLabel(self.message,30)
		if messageLabel:getContentSize().width>self.messageBox:getContentSize().width then
			local strLength=string.len(self.message)
			local message1=""
			for i=1,strLength do
				if i>30 then
					message1=string.sub(self.message,1,i).."..."
					print("message1:",message1)
					messageLabel:setString(message1)
					if messageLabel:getContentSize().width<=self.messageBox:getContentSize().width then
						return message1
					end
				end
			end
		end
		]]
    end

    self.messageBox=LuaCCScale9Sprite:createWithSpriteFrameName("cin_mainChatBgSmall.png",CCRect(4,25,2,4),tthandler)
    local gitBtnWidth = self.gifBtn and (self.gifBtn:getContentSize().width*self.gifBtn:getScale()+10) or 0
	self.messageBox:setContentSize(CCSizeMake(G_VisibleSizeWidth-self.changeBtn:getContentSize().width-self.sendBtn:getContentSize().width-gitBtnWidth-13,self.messageBox:getContentSize().height))
    self.messageBox:setIsSallow(false)
    self.messageBox:setTouchPriority(-(self.layerNum-1)*20-4)
    self.messageBox:setAnchorPoint(ccp(0,0))
	self.messageBox:setPosition(ccp(self.changeBtn:getPositionX()+self.changeBtn:getContentSize().width,23))
	
	local _messageStr=""
	if chatVoApi:isChat2_0() then
	    local _ctype = self.selectedTabIndex
		if self:isHasAllianceTab()==false and _ctype==1 then
			_ctype = 2
		end
		_messageStr = chatVoApi:getChatUnSendMsg(_ctype,self.reciverUid)
		-- self:setEditBoxString(_messageStr)
	end

    if G_isIOS() then
        self.messageLabel=GetTTFLabel(_messageStr,30)
    else
        self.messageLabel=GetTTFLabelWrap(_messageStr,30,CCSizeMake(self.messageBox:getContentSize().width,35),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    end
	self.messageLabel:setAnchorPoint(ccp(0,0.5))
    self.messageLabel:setPosition(ccp(10,self.messageBox:getContentSize().height/2))

	local editBox=customEditBox:new()
	local length=100
	local inputMode=CCEditBox.kEditBoxInputModeSingleLine
	local inputFlag=CCEditBox.kEditBoxInputFlagInitialCapsSentence
	local showLength=self.messageBox:getContentSize().width-60
	self.editMsgBox,self.editBoxText=editBox:init(self.messageBox,self.messageLabel,"cin_mainChatBgSmall.png",CCSizeMake(self.messageBox:getContentSize().width,self.messageBox:getContentSize().height),-(self.layerNum-1)*20-4,length,callBackMsgHandler,inputFlag,inputMode,true,nil,G_isIOS() and showLength or nil)
    self.bgLayer:addChild(self.messageBox,2)

    if chatVoApi:isChat2_0() then
	 --    local _ctype = self.selectedTabIndex
		-- if self:isHasAllianceTab()==false and _ctype==1 then
		-- 	_ctype = 2
		-- end
		-- self:setEditBoxString(chatVoApi:getChatUnSendMsg(_ctype,self.reciverUid))
		self:setEditBoxString(_messageStr)
		if showLength and self.messageLabel then
			if self.messageLabel:getContentSize().width>showLength then
				local textStr=self.messageLabel:getString()
				local strLength=string.len(textStr)
				for i=15,strLength do
					showStr=string.sub(textStr,1,i).."..."
					self.messageLabel:setString(showStr)
					if self.messageLabel:getContentSize().width>showLength then
						break
					end
				end
			end
		end
	end
end

function chatDialog:clearMsgEditBox()
	if self.messageLabel then
		self.messageLabel:removeFromParentAndCleanup(true)
		self.messageLabel=nil
	end
	if self.editMsgBox then
		self.editMsgBox:removeFromParentAndCleanup(true)
		self.editMsgBox=nil
	end
	if self.messageBox then
		self.messageBox:removeFromParentAndCleanup(true)
		self.messageBox=nil
	end
end

function chatDialog:setMsgBoxVisible(_visible)
	if _visible==true then
		self:initMsgEditBox()
	else
		self:clearMsgEditBox()
	end

	-- if self.messageBox then
	-- 	self.messageBox:setPositionX(_visible==true and self.changeBtn:getContentSize().width or 99999)
	-- 	self.messageBox:setVisible(_visible)
	-- end
	-- if self.editMsgBox then
	-- 	self.editMsgBox:setPositionX(_visible==true and tonumber(0) or 99999)
	-- end
	if self.sendBtn then
		self.sendBtn:setVisible(_visible)
	end
	if self.gifBtn then
		self.gifBtn:setVisible(_visible)
	end
end

function chatDialog:clearReciver()
	if chatVoApi:isChat2_0() then
		if self.priavteTitleLb then
			self.priavteTitleLb:removeFromParentAndCleanup(true)
			self.priavteTitleLb=nil
		end

		do return end
	end

	-------------------------------------------------------------

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
function chatDialog:initReciver()
	if chatVoApi:isChat2_0() then
		self:clearReciver()
		self.priavteTitleLb=GetTTFLabel("",25,true)
		self.priavteTitleLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight - 185)
		self.bgLayer:addChild(self.priavteTitleLb,1)

		do return end
	end

	-------------------------------------------------------------

	self:clearReciver()
    local function callBackReciverHandler(fn,eB,str,type)
		if str==nil then
			str=""
		end
		self.reciver=str
    end
	local function tthandler()
	end
    self.reciverBox=LuaCCScale9Sprite:createWithSpriteFrameName("mainChatBgTo.png",CCRect(10,10,5,5),tthandler)
	--self.reciverBox:setContentSize(CCSizeMake(G_VisibleSizeWidth-self.changeBtn:getContentSize().width-self.sendBtn:getContentSize().width/2-3,self.messageBox:getContentSize().height))
    self.reciverBox:setContentSize(CCSizeMake(G_VisibleSizeWidth-self.changeBtn:getContentSize().width-40,self.messageBox:getContentSize().height))
	self.reciverBox:setIsSallow(false)
    self.reciverBox:setTouchPriority(-(self.layerNum-1)*20-4)
    self.reciverBox:setAnchorPoint(ccp(0,0))
	self.reciverBox:setPosition(ccp(self.changeBtn:getContentSize().width + 25,30+self.sendBtn:getContentSize().height))
	
    self.reciverLabel=GetTTFLabel("",30)
	self.reciverLabel:setAnchorPoint(ccp(0,0.5))
    self.reciverLabel:setPosition(ccp(10,self.reciverBox:getContentSize().height/2))
	self.reciverLabel:setColor(G_ColorPurple)
	if self.reciver~=nil then
		self.reciverLabel:setString(self.reciver)
	end
	
	local editBox1=customEditBox:new()
	local length1=20
	local inputMode1=CCEditBox.kEditBoxInputModeSingleLine
	local inputFlag1=CCEditBox.kEditBoxInputFlagInitialCapsSentence
	self.editReciverBox,self.reciverText=editBox1:init(self.reciverBox,self.reciverLabel,"mainChatBgTo.png",nil,-(self.layerNum-1)*20-4,length1,callBackReciverHandler,inputFlag1,inputMode1)
    self.bgLayer:addChild(self.reciverBox,2)
	self.editReciverBox:setFontColor(G_ColorPurple)
	
	if self.toLabel==nil then
        local function showMailList()
			require "luascript/script/game/scene/gamedialog/chatDialog/mailListDialog"
            local vrd=mailListDialog:new()
            local vd = vrd:init(1,self,self.layerNum+1)
		end
		local okItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",showMailList,nil,"",25)
		self.okBtn=CCMenu:createWithItem(okItem)
		self.okBtn:setTouchPriority(-(self.layerNum-1)*20-4)
		self.okBtn:setPosition(ccp(self.changeBtn:getContentSize().width/2+15,self.changeBtn:getContentSize().height+38+self.reciverBox:getContentSize().height/2))
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
function chatDialog:changeReciver(reciverName,isCheckForbid,reciverUid,_isFlag)
	if isCheckForbid and isCheckForbid==true then
		if chatVoApi:canChat(self.layerNum+1)==false then
			do return end
		end
	end
	if reciverName then
		self.reciver=reciverName
	end
	if reciverUid then
		self.reciverUid=reciverUid
	end
    local privateType=self:getChatTabType()
	if _isFlag==true or privateType~=1 then
        -- local hasAlliance=allianceVoApi:isHasAlliance()
        local hasAllianceTab=self:isHasAllianceTab()
        local _params = {uid=self.reciverUid,name=self.reciver}
        -- if hasAllianceTab and self.chatTab1 then
        if hasAllianceTab then
            self:tabClick(2,false,nil,_params)
        else
            self:tabClick(1,false,nil,_params)
        end
	end
	if self.editReciverBox and self.reciverLabel then
		self.editReciverBox:setText(reciverName)
		self.reciverLabel:setString(reciverName)
		self.reciverText=reciverName
	end
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function chatDialog:eventHandler(handler,fn,idx,cel)
	do return end
end

--点击tab页签 idx:索引
function chatDialog:tabClick(idx,isShowJoinDialog,isEffect,reciverParams)
	if isEffect==false then
	else
    	PlayEffect(audioCfg.mouseClick)
    end

    if isShowJoinDialog==nil then
    	isShowJoinDialog=true
    end
	if base.isAllianceSwitch==1 and isShowJoinDialog==true then
		if self:isHasAllianceTab() and idx==1 then
			if allianceVoApi:isHasAlliance() then
			else
				local sd=allianceJoinSmallDialog:new()
                sd:showJoinAllianceDialog("panelBg.png",CCSizeMake(525,440),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,getlocal("alliance_list_scene_name"),true)
	            -- smallDialog:showJoinAllianceDialog("panelBg.png",CCSizeMake(580,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),true,self.layerNum+1,getlocal("alliance_list_scene_name"),false,self)
	        	for k,v in pairs(self.allTabs) do
			        if self.oldSelectedTabIndex and v:getTag()==self.oldSelectedTabIndex then
			            v:setEnabled(false)
			        else
			            v:setEnabled(true)
			        end
			    end
			    self.selectedTabIndex=self.oldSelectedTabIndex
	        	do return end
	        end
	    end
    end

    self:tabClickColor(idx)
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
			self:doUserHandler()

			local isRemove=false
			if self:isHasAllianceTab()==true and v:getTag()==2 then
				isRemove=true
		    elseif self:isHasAllianceTab()==false and v:getTag()==1 then
		    	isRemove=true
		    end
		    if isRemove==true then
		    	G_removeFlicker(v)
		    	chatVoApi:setIsNewPrivateMsg(1)
		    	self.isAddFlick=false
		    end
        else
            v:setEnabled(true)
        end
    end

    if self.chatTab1==nil then
        self.chatTab1=chatDialogTab1:new()
        self.layerTab1=self.chatTab1:init(self.layerNum,0,self,self.chatType)
        self.bgLayer:addChild(self.layerTab1)
    end
	if self.chatTab2==nil then
        self.chatTab2=chatDialogTab2:new(self)
        self.layerTab2=self.chatTab2:init(self.layerNum,1,self)
        self.bgLayer:addChild(self.layerTab2)
    end
    if self.chatTab3==nil then
        self.chatTab3=chatDialogTab3:new()
        self.layerTab3=self.chatTab3:init(self.layerNum,2,self)
        self.bgLayer:addChild(self.layerTab3)
    end

    if chatVoApi:isChat2_0() then
	    if self.prevTabIndex and self.prevTabIndex~=idx then
			local _ctype = self.prevTabIndex
			if self:isHasAllianceTab()==false and _ctype==1 then
				_ctype = 2
			end
			if _ctype==2 then
				if self.chatTab2 and self.chatTab2:getCurShowIndex()==2 then
					chatVoApi:setChatUnSendMsg(_ctype,self.message,self.reciverUid)
				end
			else
				chatVoApi:setChatUnSendMsg(_ctype,self.message,self.reciverUid)
			end
		end
		-- local _ctype = idx
		-- if self:isHasAllianceTab()==false and _ctype==1 then
		-- 	_ctype = 2
		-- end
		-- self:setEditBoxString(chatVoApi:getChatUnSendMsg(_ctype,self.reciverUid))
		self.prevTabIndex=idx
	end

	if self:getChatTabType()==1 then
		local hSpace=65
		-- self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35+hSpace/2))
		-- self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-240-hSpace))
		self:initReciver()
		if chatVoApi:isChat2_0() then
			self:setMsgBoxVisible(false)
			if reciverParams then
				self.chatTab2:initUI(2,reciverParams)
			else
				self.chatTab2:initUI()
			end
			self.chatTab2:setVisibleOfFindEditBox(true)
		end
		
        self.layerTab1:setPosition(ccp(999333,0))
        self.layerTab1:setVisible(false)
        self.layerTab2:setPosition(ccp(0,0))
        self.layerTab2:setVisible(true)
        self.layerTab3:setPosition(ccp(999333,0))
        self.layerTab3:setVisible(false)
        if not chatVoApi:isChat2_0() then
			self.chatTab2:resetTvPos()
		end
	else
		if self:getChatTabType()==0 then
	        self.layerTab1:setPosition(ccp(0,0))
	        self.layerTab1:setVisible(true)
	        self.layerTab2:setPosition(ccp(999333,0))
	        self.layerTab2:setVisible(false)
	        self.layerTab3:setPosition(ccp(999333,0))
	        self.layerTab3:setVisible(false)
			self.chatTab1:resetTvPos()
		elseif self:getChatTabType()==2 then
	        self.layerTab1:setPosition(ccp(999333,0))
	        self.layerTab1:setVisible(false)
	        self.layerTab2:setPosition(ccp(999333,0))
	        self.layerTab2:setVisible(false)
	        self.layerTab3:setPosition(ccp(0,0))
	        self.layerTab3:setVisible(true)
			self.chatTab3:resetTvPos()
		end
		-- self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
		-- self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-240))
		self:clearReciver()
		if chatVoApi:isChat2_0() then
			self.chatTab2:setVisibleOfFindEditBox(false)
			self:setMsgBoxVisible(true)
		end
		if self.changeBtn and self.changeBtn:isVisible()==false then
			self.changeBtn:setEnabled(true)
			self.changeBtn:setVisible(true)
		end
	end
	if self.changeBtn then
		self.changeBtn:setSelectedIndex(idx)
	end
	--self:resetData()
	
	if self.editMsgBox and self.messageLabel then
		local color=G_ColorWhite
		if self:getChatTabType()==2 then
			color=G_ColorBlue
		elseif self:getChatTabType()==1 then
			color=G_ColorPurple
		end
		self.editMsgBox:setFontColor(color)
		self.messageLabel:setColor(color)
	end

	if self and self.languageLb then
		local idxType=self.selectedTabIndex+1
	    if self.chatType and self.chatType>3 then
	    	idxType=self.chatType
	    end
		if chatVoApi:isMultiLanguage(idxType) then
	    	self.languageLb:setVisible(true)
	    else
	    	self.languageLb:setVisible(false)
	    end
	end

	self:resetForbidLayer()
	if chatVoApi:isChat2_0() then
		self:refreshTabRedPoint()
	end
end

function chatDialog:setEditBoxString(_msgStr)
	_msgStr=_msgStr or ""
	if self.editMsgBox then
		self.editMsgBox:setText(_msgStr)
	end
	if self.messageLabel then
		self.messageLabel:setString(_msgStr)
	end
	self.editBoxText=_msgStr
	self.message=_msgStr
	-- if string.len(_msgStr)>0 and self.editMsgBox then
		-- self.editMsgBox:setVisible(true)
		-- self.messageLabel:setVisible(false)
	-- end
end

--判断是哪个频道 0为世界 1为私聊 2为军团
function chatDialog:getChatTabType()
	local hasAllianceTab=self:isHasAllianceTab()
    if (hasAllianceTab==false and self.selectedTabIndex==1) or (hasAllianceTab==true and self.selectedTabIndex==2) then
        return 1
    elseif hasAllianceTab==true and self.selectedTabIndex==1 then
        return 2
    end
    return 0
end

--根据频道设置页签
--type：0为世界 1为私聊 2为军团
function chatDialog:setChatTabByType(type)
	if type==nil then
		type=0
	end
	local hasAllianceTab=self:isHasAllianceTab()
	if type==0 then
		self.selectedTabIndex=0
	elseif type==1 then
		if hasAllianceTab==true then
			self.selectedTabIndex=2
		else
			self.selectedTabIndex=1
		end
	elseif type==2 then
		if hasAllianceTab==true and allianceVoApi:isHasAlliance()==true then
			self.selectedTabIndex=1
		else
			self.selectedTabIndex=0
		end
	end
end

function chatDialog:refreshTabRedPoint()
	for k,v in pairs(self.allTabs) do
    	local _ctype = v:getTag()
        if self:isHasAllianceTab()==false and _ctype==1 then
        	_ctype = 2
        end
        if v:getTag()==self.selectedTabIndex then
        	local numBg = tolua.cast(v:getChildByTag(10),"CCSprite")
		    local numLb = tolua.cast(numBg:getChildByTag(11),"CCLabelTTF")
		    numBg:setVisible(false)
		    numLb:setString("0")
		    numLb:setPositionX(numBg:getContentSize().width*numBg:getScale()/2)
		    chatVoApi:setUnReadCount(_ctype)
        else
        	local _unReadCount = chatVoApi:getUnReadCount(_ctype)
            local numBg = tolua.cast(v:getChildByTag(10),"CCSprite")
		    local numLb = tolua.cast(numBg:getChildByTag(11),"CCLabelTTF")
		    if _unReadCount>0 then
		    	if self.chatType~=10000 then
		    		numBg:setVisible(true)
		    	end
		    else
		    	numBg:setVisible(false)
		    end
		    numLb:setString(tostring(_unReadCount))
		    numLb:setPositionX(numBg:getContentSize().width*numBg:getScale()/2)
        end
    end
end

function chatDialog:resetData()
	--[[
	local msgNum=chatVoApi:getChatNum(self.selectedTabIndex+1)
	local viewHeight=0
	if msgNum>0 then
		for i=1,msgNum do
			local type,showMsg,width,height=self:getMessage(i,self.selectedTabIndex+1)
			viewHeight=viewHeight+height
		end
	end
	local recordPoint = self.tv:getRecordPoint()
	local needRecord=false
	--if recordPoint.y<=40 then
	if viewHeight>=self.bgLayer:getContentSize().height-270 then
		recordPoint.y=0
		needRecord=true
	end
	]]
	if self then
	    self:doUserHandler()
	    if self.tv then
	    	self.tv:reloadData()
			local recordPoint = self.tv:getRecordPoint()
			if recordPoint.y and recordPoint.y<0 then
				recordPoint.y=0
				self.tv:recoverToRecordPoint(recordPoint)
			end
		end
	end
end

function chatDialog:tick()
	if self.chatTab1 then
		self.chatTab1:tick()
	end
	if self.chatTab2 then
		self.chatTab2:tick()
	end
	if self.chatTab3 then
		self.chatTab3:tick()
	end

	if not chatVoApi:isChat2_0() then
		if self:getChatTabType()==1 then
			if chatVoApi:getIsNewPrivateMsg()~=1 then
				chatVoApi:setIsNewPrivateMsg(1)
			end
		elseif chatVoApi:getIsNewPrivateMsg()==-1 and chatDialog:getChatTabType()~=1 then
			local chatTabType=chatDialog:getChatTabType()
			for k,v in pairs(self.allTabs) do
				local isAdd=false
				local isHasAllianceTab=false
		        if self:isHasAllianceTab()==true and v:getTag()==2 then
		        	isAdd=true
		        	isHasAllianceTab=true
		        elseif self:isHasAllianceTab()==false and v:getTag()==1 then
					isAdd=true
		        end
		        if isAdd==true and self.isAddFlick==false then
		        	if isHasAllianceTab==true then
		        		G_addRectFlicker(v,2.9,1,nil,0)
		        	else
		        		G_addRectFlicker(v,4.2,1,nil,0)
		        	end
		        	self.isAddFlick=true
		        end
		    end
		end
	end

end

function chatDialog:refreshEveryTabRedBagIcon(redBagTag,isWhi)
	if isWhi ==1 then
		if self.chatTab1 and self.chatTab1.redBagTagAndIconTb then
			for k,v in pairs(self.chatTab1.redBagTagAndIconTb) do
				if v[1] == redBagTag and v[2] and v[3] then
					v[1] =nil
					v[2]:removeFromParentAndCleanup(true)
					v[3]:removeFromParentAndCleanup(true)
					self.chatTab1.redBagTagAndIconTb[k] =nil
				end
			end
		end
	elseif isWhi ==2 then
		if self.chatTab3 and self.chatTab3.redBagTagAndIconTb then
			for k,v in pairs(self.chatTab3.redBagTagAndIconTb) do
				if v[1] == redBagTag and v[2] and v[3] then
					v[1] =nil
					v[2]:removeFromParentAndCleanup(true)
					v[3]:removeFromParentAndCleanup(true)
					self.chatTab3.redBagTagAndIconTb[k] =nil
				end
			end
		end
	end
end

--用户处理特殊需求,没有可以不写此方法
function chatDialog:doUserHandler()
	local function callback(fn,data)
	  local ret,sData=base:checkServerData(data)
	  if ret==true then
	  	do return end
	  end
    end
    socketHelper:friendsList(callback)
end

function chatDialog:dispose()
	if chatVoApi:isChat2_0() then
		mainUI.chatTabShowIndex=self.selectedTabIndex
		if self:getChatTabType()==1 and self.chatTab2 and self.chatTab2:getCurShowIndex()==2 then
			mainUI.chatPrivateReciverName=self.reciver
			mainUI.chatPrivateReciverUid=self.reciverUid
		else
			mainUI.chatPrivateReciverName=nil
			mainUI.chatPrivateReciverUid=nil
		end

		if self.messageBox and self.messageBox:isVisible() then
			local _ctype = self.selectedTabIndex
			if self:isHasAllianceTab()==false and _ctype==1 then
				_ctype = 2
			end
			chatVoApi:setChatUnSendMsg(_ctype,self.message,self.reciverUid)
		end
	end

	-- chatVoApi:setLastTabIndex(self:getChatTabType())

    base.commonDialogOpened_WeakTb["chatDialog"]=nil
    -- G_AllianceDialogTb["chatDialog"]=nil

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
	self.editBoxText=nil
	self.changeBtn=nil
	self.messageLabel=nil
	self.message=nil
	self.editReciverBox=nil
	self.reciverBox=nil
	self.reciverText=nil
	self.reciverLabel=nil
	self.reciver=nil
	self.reciverUid=nil
	self.toLabel=nil
	self.langBtnTab=nil
	self.touchSp=nil
	self.isShowList=nil
	self.languageLb=nil
	self.isAddFlick=false
	self.chatType=nil
	self.prevTabIndex=nil
    self=nil
    spriteController:removePlist("public/chat_image.plist")
	spriteController:removeTexture("public/chat_image.png")
    spriteController:removePlist("public/chatVipNoLevel.plist")
	spriteController:removeTexture("public/chatVipNoLevel.png")
	spriteController:removePlist("public/smbdPic.plist")
	spriteController:removePlist("public/chatVipNoLevel.plist")
	spriteController:removeTexture("public/smbdPic.png")
	spriteController:removeTexture("public/chatVipNoLevel.png")
	spriteController:removePlist("public/youhuaUI3.plist")
	spriteController:removeTexture("public/youhuaUI3.png")
	-- spriteController:removePlist("public/chatImageNew.plist")
	-- spriteController:removeTexture("public/chatImageNew.png")
	spriteController:removePlist("serverWar/serverWar.plist")
	spriteController:removeTexture("serverWar/serverWar.pvr.ccz")
	spriteController:removePlist("public/ltzdz/ltzdzSegImages2.plist")
    spriteController:removeTexture("public/ltzdz/ltzdzSegImages2.png")
    chatVoApi:loadChatEmoji(true)
end






