mergerServersChangeNameDialog=smallDialog:new()

function mergerServersChangeNameDialog:new()
	local nc={
		dialogWidth=500,
		dialogHeight=600,
	}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

--bg 背景 title:标题名称 content:描述 type:类型 1：改变玩家名称 2：改变军团名称
--isRenameCard 是否是使用改名卡功能
function mergerServersChangeNameDialog:create(layerNum,title,content,type,callback,isRenameCard)
    local sd=mergerServersChangeNameDialog:new()
    sd:init(layerNum,title,content,type,callback,isRenameCard)
    return sd

end

function mergerServersChangeNameDialog:init(layerNum,title,content,type,callback,isRenameCard)
	self.isTouch=nil
	self.layerNum=layerNum

    spriteController:addPlist("public/youhuaUI3.plist")
    spriteController:addTexture("public/youhuaUI3.png")

    local renameCardPropId = 4933
    local tipFontSize,nameFontSize = 25,30
    local editBoxWidth,editBoxHeight = self.dialogWidth-40, 60
    local contentBgW,contentBgH = self.dialogWidth-40,260
    local addH = 0
    local desLb
    if type==1 and isRenameCard==true then
    	editBoxWidth=self.dialogWidth-80
    	desLb = GetTTFLabelWrap(content,tipFontSize,CCSizeMake(contentBgW-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    	contentBgH=desLb:getContentSize().height+20+30+editBoxHeight+20
    	addH=80 --需要显示改名卡的消耗提示，所以高度增加
    else
		local desTv, desLabel = G_LabelTableView(CCSizeMake(contentBgW-20,contentBgH-20),content,25,kCCTextAlignmentLeft)
		desLb=desTv
		addH=100
    end
    self.dialogHeight=contentBgH+80+20+10+100+addH
    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)
   
    local function nilFunc()
	end
	local function close()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local dialogBg,titleBg,titleLb,closeBtnItem,closeBtn = G_getNewDialogBg(self.bgSize,title,30,nil,layerNum,true,close)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(self.bgSize)
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	
	if type==2 or (type==1 and isRenameCard==true) then
		closeBtn:setVisible(true)
		closeBtnItem:setEnabled(true)
	else
		closeBtn:setVisible(false)
		closeBtnItem:setEnabled(false)
	end

	local contentBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),nilFunc)
	contentBg:setContentSize(CCSizeMake(contentBgW,contentBgH))
	contentBg:ignoreAnchorPointForPosition(false)
	contentBg:setAnchorPoint(ccp(0.5,1))
	contentBg:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-100))
	contentBg:setIsSallow(false)
	contentBg:setTouchPriority(-(self.layerNum-1)*20-2)
	dialogBg:addChild(contentBg,1)

	if desLb then
		contentBg:addChild(desLb)	
		if type==1 and isRenameCard==true then
			desLb:setAnchorPoint(ccp(0,0.5))
			desLb:setPosition(10,contentBgH-desLb:getContentSize().height/2-20)
			desLb:setColor(G_ColorYellowPro)
		else
			desLb:setPosition(ccp(10,10))
			desLb:setAnchorPoint(ccp(0,0))
			desLb:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
			desLb:setMaxDisToBottomOrTop(100)
		end
	end
	
	local function touch1(hd,fn,idx)
		--if self.isMoved==false then
			PlayEffect(audioCfg.mouseClick)
			if self.nameEditBox then
		        self.nameEditBox:setVisible(true)
				--self.nameEditBox:setText(textValue)
			end
			--end
	end
	local nameBg =LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzDisplayBox.png",CCRect(7,7,1,1),touch1)
	nameBg:ignoreAnchorPointForPosition(false)
	nameBg:setAnchorPoint(ccp(0.5,0))
	nameBg:setIsSallow(false)
	nameBg:setTouchPriority(-(layerNum-1)*20-2)
	if type==1 and isRenameCard==true then
		nameBg:setContentSize(CCSizeMake(editBoxWidth,editBoxHeight))
		nameBg:setPosition(ccp(contentBgW/2,20))
		contentBg:addChild(nameBg,1)
	else
		nameBg:setContentSize(CCSizeMake(self.bgSize.width-40,80))
		nameBg:setPosition(ccp(self.bgSize.width/2,110))
		self.bgLayer:addChild(nameBg,1)
	end
	local internalname=""
	if type==2 then
		local alliance=allianceVoApi:getSelfAlliance()
		internalname=alliance.name or ""
	elseif type==1 then
		internalname=playerVoApi:getPlayerName() or ""
	end
	local textLabel1=GetTTFLabelWrap(internalname,nameFontSize,CCSizeMake(nameBg:getContentSize().width-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	textLabel1:setAnchorPoint(ccp(0.5,0.5))
	textLabel1:setPosition(ccp(nameBg:getContentSize().width/2,nameBg:getContentSize().height/2))
	nameBg:addChild(textLabel1,2)
	
	local maxLength=75
	if type==1 then
		maxLength=20
	    if G_curPlatName()=="9010001" then
	        maxLength=12
	    end
	elseif type==2 then
		local maxLength=12
	    if G_getCurChoseLanguage()=="ar" then
	        maxLength=24
	    end
    end
	local nameStr=textLabel1:getString()
	local function tthandler()

    end
	local lastStr1
    local function callBackHandler(fn,eB,str,type)
		--if type==0 then  --开始输入
			--eB:setText(nameStr)
			print("str----->>>",str)
		if type==1 then  --检测文本内容变化
			if str==nil then
				nameStr=""
			else
				nameStr=str
			end
			if G_utfstrlen(str or "")>maxLength then
				
			else
				lastStr1=str
			end
            textLabel1:setString(nameStr)
		elseif type==2 then --检测文本输入结束
			eB:setVisible(false)
			if G_utfstrlen(nameStr or "")>maxLength or G_utfstrlen(str or "")>maxLength then
				nameStr=lastStr1 or ""
				eB:setText(nameStr)
				textLabel1:setString(nameStr)
			end
		end
    end

    local winSize=CCEGLView:sharedOpenGLView():getFrameSize()
    local xScale=winSize.width/640
    local yScale=winSize.height/960
	local size=CCSizeMake(editBoxWidth,editBoxHeight)
	local xBox=LuaCCScale9Sprite:createWithSpriteFrameName("ltzdzDisplayBox.png",CCRect(7,7,1,1),tthandler)
    self.nameEditBox=CCEditBox:createForLua(size,xBox,nil,nil,callBackHandler)
	self.nameEditBox:setFont(textLabel1.getFontName(textLabel1),yScale*textLabel1.getFontSize(textLabel1)/2)
	self.nameEditBox:setMaxLength(maxLength)
	self.nameEditBox:setText(nameStr)
	self.nameEditBox:setAnchorPoint(ccp(0.5,0))	
	--self.nameEditBox:setInputFlag(CCEditBox.kEditBoxInputFlagInitialCapsAllCharacters)
    self.nameEditBox:setInputFlag(CCEditBox.kEditBoxInputFlagInitialCapsSentence)
	self.nameEditBox:setInputMode(CCEditBox.kEditBoxInputModeSingleLine)
	self.nameEditBox:setVisible(false)
    if type==1 and isRenameCard==true then
		self.nameEditBox:setPosition(ccp(contentBgW/2,20))
    	contentBg:addChild(self.nameEditBox,3)

    	local mLine = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png", CCRect(37, 1, 2, 21), function ()end)
        mLine:setPosition(self.dialogWidth/2,140)
        mLine:setContentSize(CCSizeMake(self.dialogWidth, mLine:getContentSize().height))
        self.bgLayer:addChild(mLine)

    	local fontSize = 20
    	local cost = 0
		local propNum = bagVoApi:getItemNumId(renameCardPropId)
    	if propNum==0 then --如果没有改名卡，则显示金币消耗
	   		cost = propCfg["p"..renameCardPropId].gemCost
            local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
            goldIcon:setAnchorPoint(ccp(0,0.5))
            self.bgLayer:addChild(goldIcon)
            
    		local costLb=GetTTFLabel(cost,fontSize)
			costLb:setAnchorPoint(ccp(0,0.5))
			self.bgLayer:addChild(costLb)

			local realW = goldIcon:getContentSize().width+costLb:getContentSize().width+10
			goldIcon:setPosition((self.dialogWidth-realW)/2,105)
			costLb:setPosition(goldIcon:getPositionX()+goldIcon:getContentSize().width+10,goldIcon:getPositionY())

			if playerVoApi:getGems() < cost then
				costLb:setColor(G_ColorRed)
			end
    	else
    		cost=1

    		local iconSize = 40
    		local tipStr = getlocal("changenameTip_need")
    		local tipLb=GetTTFLabelWrap(tipStr,fontSize,CCSizeMake(self.dialogWidth-120,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			tipLb:setAnchorPoint(ccp(0,0.5))
			tipLb:setColor(G_ColorRed)
			self.bgLayer:addChild(tipLb)
			local tmpTipLb=GetTTFLabel(tipStr,fontSize)
			local realW = tmpTipLb:getContentSize().width
			if realW>tipLb:getContentSize().width then
				realW=tipLb:getContentSize().width
			end
			local iconSp = CCSprite:createWithSpriteFrameName(propCfg["p"..renameCardPropId].icon)
			iconSp:setAnchorPoint(ccp(0,0.5))
			iconSp:setScale(iconSize/iconSp:getContentSize().width)
			self.bgLayer:addChild(iconSp)
			local costLb = GetTTFLabel("x"..cost,fontSize)
			costLb:setAnchorPoint(ccp(0,0.5))
			self.bgLayer:addChild(costLb)

			local tipWidth = realW +iconSize+costLb:getContentSize().width+20
			tipLb:setPosition((self.dialogWidth-tipWidth)/2,160)
			iconSp:setPosition(tipLb:getPositionX()+realW+10,tipLb:getPositionY())
			costLb:setPosition(iconSp:getPositionX()+iconSize+10,tipLb:getPositionY())

			local ownLb = GetTTFLabel(getlocal("resourceOwned")..": ",fontSize)
			ownLb:setAnchorPoint(ccp(0,0.5))
			self.bgLayer:addChild(ownLb)

			local ownSp = CCSprite:createWithSpriteFrameName(propCfg["p"..renameCardPropId].icon)
			ownSp:setAnchorPoint(ccp(0,0.5))
			ownSp:setScale(iconSize/ownSp:getContentSize().width)
			self.bgLayer:addChild(ownSp)

			local ownNumLb = GetTTFLabel("x"..propNum,fontSize)
			ownNumLb:setAnchorPoint(ccp(0,0.5))
			self.bgLayer:addChild(ownNumLb)

			tipWidth=ownLb:getContentSize().width+iconSize+ownNumLb:getContentSize().width+20
			ownLb:setPosition((self.dialogWidth-tipWidth)/2,108)
			ownSp:setPosition(ownLb:getPositionX()+ownLb:getContentSize().width+10,ownLb:getPositionY())
			ownNumLb:setPosition(ownSp:getPositionX()+iconSize+10,ownLb:getPositionY())
    	end
    else
		self.nameEditBox:setPosition(ccp(self.bgSize.width/2,200))
	    self.bgLayer:addChild(self.nameEditBox,3)
    end

    local function sureChange(nameStr,cost)
    	local hasEmjoy=G_checkEmjoy(nameStr)
        if hasEmjoy==false then
            do return end
        end
        local count=G_utfstrlen(nameStr,true)
        if  platCfg.platCfgKeyWord[G_curPlatName()]~=nil  then --设置屏蔽字
            if keyWordCfg:keyWordsJudge(nameStr)==false then
                do
                    return
                end
            end
        end
        if G_match(nameStr)~=nil then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("alliance_illegalCharacters"),true,20,G_ColorRed)
            do 
                return
            end
        end
        if string.find(nameStr, ' ')~=nil then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("blankCharacter"),true,20,G_ColorRed)
            do 
                return
            end
        end
        
        local strFisrt=G_stringGetAt(nameStr,0,1)
        if tonumber(strFisrt)~=nil then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("firstCharNoNum"),true,20,G_ColorRed)
            do 
                return
            end
        end

        if nameStr=="" then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("nameNullCharacter"),true,20,G_ColorRed)
            do 
                return
            end
        end
        if count>12 then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("namelengthwrong"),true,20,G_ColorRed)
        elseif count<3 then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("nameStrMinLen"),true,20,G_ColorRed)
		else
			local function changeCallback(fn,data)
				local ret,sData = base:checkServerData(data)
				if ret==true then
					G_cancleLoginLoading()
					local oldName = playerVoApi:getPlayerName()
					playerVoApi:setPlayerName(nameStr)
                    eventDispatcher:dispatchEvent("user.name.change")
                  	if isRenameCard == true then
	                    local message={key="changenameTip_chatMsg",param={oldName,nameStr}}
	                    chatVoApi:sendSystemMessage(message)

			            allianceVoApi:setNeedRefreshFlag(true) --需要重新拉军团数据
					end
					if cost > 0 then
						playerVoApi:setGems(playerVoApi:getGems()-cost)
					end
					if callback then
                    	callback()
                    end
                    worldScene:updateUserName()
					playerVoApi:setChangeNameCD(sData.data.cdtime)
					return self:close()
				else
                    smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("namehasbeenused"),true,6,G_ColorRed)
					G_cancleLoginLoading() --注册角色名失败 取消loading
				end
			end
			G_showLoginLoading() --加loading
			socketHelper:userRename(nameStr,playerVoApi:getPic(),changeCallback,isRenameCard)
		end
    end

    local function onConfirm()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		

		if type==2 then
			   --前端先判断名称是否符合规则 字符数大于2 小于13 首字母不能为数字
		        local nameCount=G_utfstrlen(nameStr,true)
		        if G_match(nameStr)~=nil then
		            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("alliance_illegalCharacters"),true,6,G_ColorRed)
		            do 
		                return
		            end
		        end
		        --是否为空字符
		        if nameStr=="" then
		            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("alliance_nameNoNull"),true,6,G_ColorRed)
		            do 
		                return
		            end
		        end
		        local hasEmjoy=G_checkEmjoy(nameStr)
		        if hasEmjoy==false then
		            do return end
		        end
		        --首字母是否为数字
		        local strFisrt=G_stringGetAt(nameStr,0,1)
		        if tonumber(strFisrt)~=nil then
		            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("firstCharNoNum"),true,6,G_ColorRed)
		            do 
		                return
		            end
		        end
		        if PlatformManage~=nil then
		            if  platCfg.platCfgKeyWord[G_curPlatName()]~=nil  then --设置屏蔽字
		                if keyWordCfg:keyWordsJudge(nameStr)==false then
		                    do
		                        return
		                    end
		                end
		            end
		        end
		        
		        if nameCount>12 then

		            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("namelengthwrong"),true,6,G_ColorRed)
		            do 
		                return
		            end
		        elseif nameCount<3 then
		            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("roleNameMinLen"),true,6,G_ColorRed)
		            do 
		                return
		            end

		        end
        
        -- local textCount=G_utfstrlen(self.textValue)
        -- if nameCount>100 then
        --     smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("namelengthwrong"),true,6,G_ColorRed)
        --     do 
        --         return
        --     end
        -- end
			local function changeCallback(fn,data)
				local ret,sData = base:checkServerData(data)
				if ret==true then
					local updateData={name=nameStr,setname_at=base.serverTime}
                    allianceVoApi:formatSelfAllianceData(updateData)
                    if callback then
                    	callback()
                    end
                    local params={}
                    local uid=playerVoApi:getUid()
                    params.uid=uid
                    params.aname=nameStr
                    params.settime=base.serverTime
                    local aid=playerVoApi:getPlayerAid()
                    chatVoApi:sendUpdateMessage(20,params,aid+1)

                    local params = {aid=allianceVo.aid,name=nameStr}
                	chatVoApi:sendUpdateMessage(8,params)

                	worldScene:updateAllianceName()
					return self:close()
				end
			end
			local alliance=allianceVoApi:getSelfAlliance()
			socketHelper:changeAllianceName(playerVoApi:getUid(),nameStr,changeCallback)
		elseif type==1 then
			local oldName = playerVoApi:getPlayerName()
			if oldName==nameStr then --昵称相同
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("changenameTip_sameName_tip"),30)
				do return end
			end
		    local cost = 0
			if isRenameCard == true and base.reNameSwitch == 1 then
				local propNum = bagVoApi:getItemNumId(renameCardPropId)
				if propNum == 0 then
			   		cost = propCfg["p"..renameCardPropId].gemCost
		    		if playerVoApi:getGems() < cost then
		    			GemsNotEnoughDialog(nil,nil,cost-playerVoApi:getGems(),self.layerNum+1,cost)
		    			do return end
		    		else
		    			local function sureHandler()
		    				sureChange(nameStr,cost)
		    			end
		    			local tipStr = getlocal("changenameTip_sureTip",{cost,math.ceil(propCfg["p"..renameCardPropId].useCDTime/86400)})
		    			G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),tipStr,false,sureHandler)
		    		    do return end
		    		end
			    end
			end
		    sureChange(nameStr,cost)
		end

		
	end 

	local btnScale = 0.7
	local confirmItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onConfirm,2,getlocal("collect_border_save"),25/btnScale)
	confirmItem:setScale(btnScale)
	local confirmBtn=CCMenu:createWithItem(confirmItem)
	confirmBtn:setPosition(ccp(self.dialogWidth/2,60))
	confirmBtn:setTouchPriority(-(layerNum-1)*20-4)
	self.bgLayer:addChild(confirmBtn)


	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end

function mergerServersChangeNameDialog:dispose()
    spriteController:removePlist("public/youhuaUI3.plist")
    spriteController:removeTexture("public/youhuaUI3.png")
    self.dialogWidth=nil
    self.dialogHeight=nil
end