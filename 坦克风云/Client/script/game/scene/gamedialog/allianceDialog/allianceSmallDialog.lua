allianceSmallDialog={}

function allianceSmallDialog:new()
    local nc={
      bgLayer=nil,             --背景sprite
      dialogLayer,         --对话框层
      bgSize,
      isTouch,
      isUseAmi,
      refreshData={},			--需要刷新的数据
      editBox=nil,
      textValue=nil,
      layerNum=nil,
      stateOfGarrsion=base.stateOfGarrsion, --拿到驻防状态信息
      personalRewardLabel=nil,
      allianceRewardLabel=nil,
      gemPersonalRewardLabel=nil,
      gemAllianceRewardLabel=nil,
      backSprie1=nil,
      backSprie2=nil,
    }
    setmetatable(nc,self)
    self.__index=self
    return nc
end
function allianceSmallDialog:showMember(title,isuseami,memberVo,layerNum,parentDlg,memberTb)
      local sd=allianceSmallDialog:new()
      G_AllianceDialogTb[2]=sd
      sd:initMember(title,isuseami,memberVo,layerNum,parentDlg,memberTb)
end

function allianceSmallDialog:showOKDialog(callBack,text,layerNum)
      local sd=allianceSmallDialog:new()
      sd:initOKDialog(callBack,text,layerNum)
end
function allianceSmallDialog:initOKDialog(callBack,text,layerNum)
    local function touchHandler()

    end

    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end

    local size = CCSizeMake(550,450)
    local dialogBg = G_getNewDialogBg(size, getlocal("dialog_title_prompt"), 28, nil, layerNum, true, close)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

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
    
    local function tthandler()
    
    end
    local okStr=nil
    local function callBackUserNameHandler(fn,eB,str,type)
       if str~=nil then
           okStr=str
        end
    end
    
    local accountBox=LuaCCScale9Sprite:createWithSpriteFrameName("LegionInputBg.png",CCRect(10,10,1,1),tthandler)
    accountBox:setContentSize(CCSize(200,60))
    accountBox:setPosition(ccp(size.width/2,size.height/2-20))
    self.bgLayer:addChild(accountBox)

    local lbSize=25
    
    local targetBoxLabel=GetTTFLabel("",lbSize)
    targetBoxLabel:setAnchorPoint(ccp(0,0.5))
    targetBoxLabel:setPosition(ccp(10,accountBox:getContentSize().height/2))
    local customEditAccountBox=customEditBox:new()
    local length=30
    customEditAccountBox:init(accountBox,targetBoxLabel,"inputNameBg.png",nil,-(layerNum-1)*20-4,length,callBackUserNameHandler,nil,nil)
    
    local textLbHeight = 200
    local tipsStr
    if type(text) == "table" then
        tipsStr = text[2]
        text = text[1]
        textLbHeight = 0
    end
    local textLb=GetTTFLabelWrap(text,25,CCSize(self.bgLayer:getContentSize().width-100,textLbHeight),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    textLb:setPosition(ccp(size.width/2,300))
    self.bgLayer:addChild(textLb)
    textLb:setColor(G_ColorYellow)
    if tipsStr then
        textLb:setPositionY(textLb:getPositionY() + 20)
        local tipsLb = GetTTFLabelWrap(tipsStr, 22, CCSize(self.bgLayer:getContentSize().width - 100, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        tipsLb:setPosition(textLb:getPositionX(), textLb:getPositionY() - textLb:getContentSize().height / 2 - tipsLb:getContentSize().height / 2)
        self.bgLayer:addChild(tipsLb)
        tipsLb:setColor(G_ColorYellowPro)
    end

    local pushOKLb=GetTTFLabel(getlocal("alliance_pushOK"),25)
    pushOKLb:setPosition(ccp(size.width/2,145))
    self.bgLayer:addChild(pushOKLb)
    
    local function pusuOK()
        if tostring(okStr)~=nil and okStr~=nil then
            if string.lower(okStr)=="ok" then
                callBack();
                self:close()
            else
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_pushNOOK"),28)
                -- self:close()
            end
        else
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_pushNOOK"),28)
            -- self:close()
        end
    end

    local sureItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",pusuOK,nil,getlocal("buyQueueOK"),24/0.7)
    sureItem:setScale(0.7)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(size.width/2,80))
    sureMenu:setTouchPriority(-(layerNum-1)*20-4);
    self.bgLayer:addChild(sureMenu)
end


function allianceSmallDialog:addTextField(member,isTouch,layerNum,bgheight)
		local maxLength=50
		local lastStr
--输入框--------------------------------
        local function touch2(hd,fn,idx)
            PlayEffect(audioCfg.mouseClick)
            if self.editBox then
                self.editBox:setVisible(isTouch)
                self.editBox:setText(textValue)
            end
		end
        local imgName="newAlliance_desc1.png"
        local rect1=CCRect(198,24, 2, 2)
        -- if isTouch==false then
        --     imgName="NoticeLine.png"
        --     rect1=CCRect(15,15,1,1)
        -- end

        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName(imgName,rect1,touch2)
	    backSprie:setContentSize(CCSizeMake(500, 210))
	    backSprie:ignoreAnchorPointForPosition(false)
	    --backSprie:setAnchorPoint(ccp(0,0))
	    backSprie:setIsSallow(false)
	    backSprie:setTouchPriority(-(layerNum-1)*20-3)
		backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2, bgheight-backSprie:getContentSize().height/2+65))
	    self.bgLayer:addChild(backSprie,2)

		local textLabel=GetTTFLabelWrap(member.signature,25,CCSizeMake(backSprie:getContentSize().width-20,backSprie:getContentSize().height-20),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		textLabel:setAnchorPoint(ccp(0,1))
		textLabel:setPosition(ccp(20,backSprie:getContentSize().height-15))
		backSprie:addChild(textLabel,2)

		self.textValue=textLabel:getString()
		if self.textValue==nil then
			self.textValue=""
		end
		local function tthandler()
	
	    end
	    local function callBackHandler(fn,eB,str,type)
			--if type==0 then  --开始输入
				--eB:setText(textValue)
			if type==1 then  --检测文本内容变化
				if str==nil then
					self.textValue=""
				else
					self.textValue=str
					if changeCallback then
						local txt=changeCallback(fn,eB,str,type)
						if txt then
							self.textValue=txt
							eB:setText(self.textValue)
						end
					end
				end
				if G_utfstrlen(str or "")>maxLength then
					
				else
					lastStr=str
				end
	            textLabel:setString(self.textValue)
			elseif type==2 then --检测文本输入结束
				eB:setVisible(false)
				if G_utfstrlen(self.textValue or "")>maxLength or G_utfstrlen(str or "")>maxLength then
					self.textValue=lastStr or ""
					eB:setText(self.textValue)
					textLabel:setString(self.textValue)
				end
			end
	    end
		
	    local winSize=CCEGLView:sharedOpenGLView():getFrameSize()
	    local xScale=winSize.width/640
	    local yScale=winSize.height/960
		local size=CCSizeMake(self.bgLayer:getContentSize().width,50)

		local xBox=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),tthandler)
	    self.editBox=CCEditBox:createForLua(size,xBox,nil,nil,callBackHandler)
		self.editBox:setFont(textLabel.getFontName(textLabel),yScale*textLabel.getFontSize(textLabel)/2)
		self.editBox:setMaxLength(maxLength)
		self.editBox:setText(self.textValue)
		self.editBox:setAnchorPoint(ccp(0,0))
		self.editBox:setPosition(ccp(0,170))

		--self.editBox:setInputFlag(CCEditBox.kEditBoxInputFlagInitialCapsAllCharacters)
        self.editBox:setInputFlag(CCEditBox.kEditBoxInputFlagInitialCapsSentence)
		self.editBox:setInputMode(CCEditBox.kEditBoxInputModeSingleLine)

	    self.editBox:setVisible(false)
	    self.bgLayer:addChild(self.editBox,4)
		----------------------------------
end

function allianceSmallDialog:initMember(title,isuseami,memberVo,layerNum,parentDlg,memberTb)
    self.isUseAmi=isuseami
    --layerNum=layerNum
    local function touchHandler()
    
    end

    local function closeCallBack()
        PlayEffect(audioCfg.mouseClick)    
        return self:close()
    end

    local androidH = 0
    if G_isIOS() == false then
        androidH = 100
    end
    
    local function closeCallBack()
        PlayEffect(audioCfg.mouseClick)    
        return self:close()
    end
    local size=CCSizeMake(550,850+androidH)
    local dialogBg = G_getNewDialogBg(size,title,30,nil,layerNum,true,closeCallBack)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()

    base:addNeedRefresh(self)
    
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
    
    


    
    local addX=50
    local addY=42
    local lbSize=25
    local namalabel = {"alliance_info_name","alliance_info_level","alliance_info_power","alliance_contributionLb","alliance_settings_post","alliance_settings_login"}
        local loginStr=nil
    local timeLog=tonumber(base.serverTime)-memberVo.logined_at
    if  timeLog<=24*60*60 then
        local hour=math.floor(timeLog/(3600))
        if hour<1 then
            hour=1;
        end
        loginStr=getlocal("alliance_loginTime1",{hour})
    else
        local day=math.floor(timeLog/(3600*24))
        loginStr=getlocal("alliance_loginTime2",{day})
    end
    local namevaluelable = {memberVo.name,memberVo.level,memberVo.fight,memberVo.donate-memberVo.useDonate,getlocal("alliance_role"..memberVo.role),loginStr}
    local lbhight = self.bgLayer:getContentSize().height -100
    for k,v in pairs(namalabel) do
            local temphight
            local nameLable = GetTTFLabelWrap(getlocal(v),lbSize,CCSizeMake(lbSize*8,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
            nameLable:setAnchorPoint(ccp(0,1))
            nameLable:setPosition(ccp(addX,lbhight))
            self.bgLayer:addChild(nameLable,1)
            temphight = nameLable:getContentSize().height

            local nameValueLable = GetTTFLabelWrap(namevaluelable[k],lbSize,CCSizeMake(lbSize*10-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                nameValueLable:setAnchorPoint(ccp(0,1))
                nameValueLable:setPosition(ccp(self.bgLayer:getContentSize().width/2,lbhight))
            if temphight<nameValueLable:getContentSize().height then
              temphight = nameValueLable:getContentSize().height
            end
            self.bgLayer:addChild(nameValueLable,1)
            lbhight = lbhight - temphight 

            if k ~= #namalabel then
            local LineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
            LineSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,2))
            LineSp:setAnchorPoint(ccp(0.5,1))
            self.bgLayer:addChild(LineSp)
            LineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,lbhight-5))

            lbhight = lbhight - 10
        end

    end
    --[[local memberLb=GetTTFLabelWrap(getlocal("alliance_info_name"),lbSize);
    memberLb:setAnchorPoint(ccp(0,0.5))
    memberLb:setPosition(ccp(addX,size.height-80-addY))
    self.bgLayer:addChild(memberLb)
    
    local memberLb1=GetTTFLabel(memberVo.name,lbSize);
    memberLb1:setAnchorPoint(ccp(0,0.5))
    memberLb1:setPosition(ccp(memberLb:getContentSize().width,memberLb:getContentSize().height/2))
    memberLb:addChild(memberLb1)
    memberLb1:setColor(G_ColorYellow)

    
    local levelLb=GetTTFLabel(getlocal("alliance_info_level"),lbSize);
    levelLb:setAnchorPoint(ccp(0,0.5))
    levelLb:setPosition(ccp(addX,size.height-120-addY))
    self.bgLayer:addChild(levelLb)
    
    local levelLb1=GetTTFLabel(memberVo.level,lbSize);
    levelLb1:setAnchorPoint(ccp(0,0.5))
    levelLb1:setPosition(ccp(levelLb:getContentSize().width,levelLb:getContentSize().height/2))
    levelLb:addChild(levelLb1)
    levelLb1:setColor(G_ColorYellow)
    
    local powerLb=GetTTFLabel(getlocal("alliance_info_power"),lbSize);
    powerLb:setAnchorPoint(ccp(0,0.5))
    powerLb:setPosition(ccp(addX,size.height-160-addY))
    self.bgLayer:addChild(powerLb)
    
    local powerLb1=GetTTFLabel(memberVo.fight,lbSize);
    powerLb1:setAnchorPoint(ccp(0,0.5))
    powerLb1:setPosition(ccp(powerLb:getContentSize().width,powerLb:getContentSize().height/2))
    powerLb:addChild(powerLb1)
    powerLb1:setColor(G_ColorYellow)
    
    local contributionLb=GetTTFLabel(getlocal("alliance_contributionLb"),lbSize);
    contributionLb:setAnchorPoint(ccp(0,0.5))
    contributionLb:setPosition(ccp(addX+280,size.height-80-addY))
    self.bgLayer:addChild(contributionLb)
    
    local contributionLb1=GetTTFLabel(memberVo.donate-memberVo.useDonate,lbSize);
    contributionLb1:setAnchorPoint(ccp(0,0.5))
    contributionLb1:setPosition(ccp(contributionLb:getContentSize().width,contributionLb:getContentSize().height/2))
    contributionLb1:setColor(G_ColorYellow)
    contributionLb:addChild(contributionLb1)
    
    local postLb=GetTTFLabel(getlocal("alliance_settings_post"),lbSize);
    postLb:setAnchorPoint(ccp(0,0.5))
    postLb:setPosition(ccp(addX+280,size.height-120-addY))
    self.bgLayer:addChild(postLb)

    local roleMember="alliance_role"..memberVo.role
    local postLb1=GetTTFLabel(getlocal(roleMember),lbSize);
    postLb1:setAnchorPoint(ccp(0,0.5))
    postLb1:setPosition(ccp(postLb:getContentSize().width,postLb:getContentSize().height/2))
    postLb:addChild(postLb1)
    postLb1:setColor(G_ColorYellow)

    local loginLb=GetTTFLabel(getlocal("alliance_settings_login"),lbSize);
    loginLb:setAnchorPoint(ccp(0,0.5))
    loginLb:setPosition(ccp(addX+280,size.height-160-addY))
    self.bgLayer:addChild(loginLb)

    local loginStr=nil
    local timeLog=tonumber(base.serverTime)-memberVo.logined_at
    if  timeLog<=24*60*60 then
        local hour=math.floor(timeLog/(3600))
        if hour<1 then
            hour=1;
        end
        loginStr=getlocal("alliance_loginTime1",{hour})
    else
        local day=math.floor(timeLog/(3600*24))
        loginStr=getlocal("alliance_loginTime2",{day})
    end
    
    local loginLb1=GetTTFLabelWrap(loginStr,lbSize,CCSizeMake(lbSize*5,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop);
    loginLb1:setAnchorPoint(ccp(0,0.5))
    loginLb1:setPosition(ccp(loginLb:getContentSize().width,loginLb:getContentSize().height/2))
    loginLb:addChild(loginLb1)
    loginLb1:setColor(G_ColorYellow)
    --]]
    local signLb=GetTTFLabelWrap(getlocal("newAllianceSign"),lbSize,CCSizeMake(lbSize*8,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold");
    signLb:setColor(G_ColorYellowPro2)
    signLb:setAnchorPoint(ccp(0.5,1))
    --signLb:setPosition(ccp(addX,size.height-200-addY))
    signLb:setPosition(ccp(self.bgLayer:getContentSize().width/2-20,lbhight-17))
    self.bgLayer:addChild(signLb)
    lbhight = lbhight - signLb:getContentSize().height-65

    local contactLb=GetTTFLabel(getlocal("alliance_info_contact"),lbSize,CCSizeMake(lbSize*10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop);
    signLb:setAnchorPoint(ccp(0,1))
    contactLb:setAnchorPoint(ccp(0,1))
    contactLb:setPosition(ccp(addX,lbhight-160))
    self.bgLayer:addChild(contactLb)
    
    local operationLb=GetTTFLabelWrap(getlocal("alliance_info_legionOperation"),lbSize,CCSizeMake(lbSize*5,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter);
    operationLb:setAnchorPoint(ccp(0,1))
    operationLb:setPosition(ccp(addX,lbhight-160-120-20))
    self.bgLayer:addChild(operationLb)
    

    local function sendEmail()
		PlayEffect(audioCfg.mouseClick)
        emailVoApi:showWriteEmailDialog(layerNum+1,getlocal("alliance_member_write_email"),memberVo.name,nil,nil,nil,nil,memberVo.uid)
    end
    local contactItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",sendEmail,nil,getlocal("alliance_member_write_email"),25/0.7)
    contactItem:setScale(0.7)
    local contactMenu=CCMenu:createWithItem(contactItem);
    contactMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,contactLb:getPositionY()-25))
    contactMenu:setTouchPriority(-(layerNum-1)*20-4);
    self.bgLayer:addChild(contactMenu)
    
    local function chat()
        chatVoApi:showChatDialog(layerNum+1,nil,memberVo.uid,memberVo.name,true)
    end
    local chatItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",chat,nil,getlocal("player_message_info_whisper"),25/0.7)
    chatItem:setScale(0.7)
    local chatMenu=CCMenu:createWithItem(chatItem);
    chatMenu:setPosition(ccp(430,contactLb:getPositionY()-25))
    chatMenu:setTouchPriority(-(layerNum-1)*20-4);
    self.bgLayer:addChild(chatMenu)

    if tonumber(memberVo.uid) ~= tonumber(playerVoApi:getUid()) then
    -- 屏蔽玩家
    local function shieldCallback( ... )
        local function confirmHandler( ... )
            local blackList=G_getBlackList()
              for k,v in pairs(blackList) do
                if tonumber(v[1]) == tonumber(memberVo.uid) then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shieldSuccess",{content[1][1]}),28)
                end
             end
            if SizeOfTable(G_getBlackList())>=G_blackListNum then
              smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("blackListMax"),28)
              do return end
            end
            local function saveBlackCallback()
               smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shieldSuccess",{memberVo.name}),28)
            end
            local toBlackTb={uid=memberVo.uid,name=memberVo.name}
            G_saveNameAndUidInBlackList(toBlackTb,saveBlackCallback)
        end
        G_showSecondConfirm(layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("friend_newSys_shieldConfirm"),false,confirmHandler)
    end
    local pos = ccp(430,contactLb:getPositionY()-85)

    local shieldButton = G_createBotton(self.bgLayer,pos,{getlocal("friend_newSys_shield"),25},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",shieldCallback,0.7,-(layerNum-1)*20-4)
    self.shieldButton = shieldButton
  
    local function friendCallback( ... )
        if self.realStr == "delFriend" then
          local function confirmHandler( ... )
          local function callback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then
                  smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_newSys_fr_del"),28)
                  friendInfoVoApi:removeFriend(tonumber(memberVo.uid))
                  friendInfoVo.friendChanegFlag = 1
                  friendInfoVo.friendGiftFlag = 1
                  self:close()
              end   
          end
            socketHelper:friendsDel(memberVo.uid,memberVo.name,callback)
        end
        G_showSecondConfirm(layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("friend_newSys_delConfirm"),false,confirmHandler)
        else   
          if memberVo.uid then
            local function callback(fn,data)
            local ret,sData=base:checkServerData(data)
              if ret==true then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("addMailListSuccess",{memberVo.name}),28) 
                self:close()
              end   
             end
            socketHelper:sendfriendApply(memberVo.uid,callback)
          end
        end
    end
    local realStr = ""
    local pos1 = ccp(self.bgLayer:getContentSize().width/2,contactLb:getPositionY()-85)
    if friendInfoVoApi:juedgeIsMyfriend(tonumber(memberVo.uid)) == false then 
        realStr = "friend_newSys_fr_apply"
    else
        realStr = "delFriend"
    end   
    self.realStr = realStr
    local friendButton = G_createBotton(self.bgLayer,pos1,{getlocal(realStr),25},"creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",friendCallback,0.7,-(layerNum-1)*20-4)
    end
    local alliance=allianceVoApi:getSelfAlliance()
    local istouch=false
    if tonumber(memberVo.uid)== tonumber(playerVoApi:getUid()) then
        istouch=true
        chatItem:setEnabled(false)
        contactItem:setEnabled(false)
        local function save()
            
            local function signatureCallBack(fn,data)
                if base:checkServerData(data)==true then
                    if  platCfg.platCfgKeyWord[G_curPlatName()]~=nil  then --设置屏蔽字
                        if keyWordCfg:keyWordsJudge(self.textValue)==false then
                            do
                                return
                            end
                        end
                    end
                    allianceMemberVoApi:changeMemberSignByUid(memberVo.uid,self.textValue)
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_baocunqianmingTip"),30)
                    self:close()--关闭板子
                    memberTb:reloadData()

                end
            end
            socketHelper:allianceEditmember(allianceVoApi:getSelfAlliance().aid,self.textValue,memberVo.uid,nil,signatureCallBack)
    
        end
        local saveItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",save,nil,getlocal("alliance_info_save"),25/0.7)
        saveItem:setScale(0.7)
        local saveMenu=CCMenu:createWithItem(saveItem);
        saveMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,signLb:getPositionY()-185))
        saveMenu:setTouchPriority(-(layerNum-1)*20-4);
        self.bgLayer:addChild(saveMenu)

        local function leaveAlliance()
            local uid=playerVoApi:getUid()
            if allianceVoApi:checkCanQuitAlliance(uid,layerNum+1)==false then
              do return end
            end
            local params={}
            if(tonumber(allianceVoApi:getSelfAlliance().role)==2 and SizeOfTable(allianceMemberVoApi:getMemberTab())==1)then
                params["isDismiss"]=1
                params["name"]=allianceVoApi:getSelfAlliance().name
            else
                params["name"]=allianceVoApi:getSelfAlliance().name
                params["list"]={}
                for k,v in pairs(allianceMemberVoApi:getMemberTab()) do
                    if(v.uid~=playerVoApi:getUid())then
                        table.insert(params["list"],{v.uid,v.name})
                    end
                end
            end
            local function leaveAllianceCallBack(fn,data)
                if base:checkServerData(data)==true then
                    -- allianceVoApi:clearSelfAlliance()--清空自己军团信息
                    allianceVoApi:clear()
                    allianceMemberVoApi:clear()--清空成员列表
                    allianceApplicantVoApi:clear()--清空
                    playerVoApi:clearAllianceData()
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_tuichuTip"),30)

                    self:close()--关闭板子
                    if parentDlg then
                        parentDlg:close(true)
                    else
                        activityAndNoteDialog:closeAllDialog()
                    end
                    chatVoApi:sendUpdateMessage(5,params)
                    --socketHelper:chatServerLogout()
                    -- allianceVoApi:clearRankAndGoodList()--清空军团列表
                    worldScene:updateAllianceName()
                    --helpDefendVoApi:clear()--清空协防
                    --工会活动刷新数据
                    activityVoApi:updateAc("fbReward")
                    activityVoApi:updateAc("allianceLevel")
                    activityVoApi:updateAc("allianceFight")
                end
            end
            socketHelper:allianceQuit(allianceVoApi:getSelfAlliance().aid,nil,leaveAllianceCallBack)
        end
        
        local function leaveSureAndCancel()
            if base.localWarSwitch==1 then
                if localWarVoApi:canQuitAlliance(1)==false then
                    do return end
                end
            end
            if base.serverWarLocalSwitch==1 then
                if serverWarLocalVoApi:canQuitAlliance(1)==false then
                    do return end
                end
            end

            if tonumber(alliance.role)==2 and SizeOfTable(allianceMemberVoApi:getMemberTab())>1 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_wufatuichuTip"),30)

                do
                    return
                end
            elseif tonumber(alliance.role)==2 and SizeOfTable(allianceMemberVoApi:getMemberTab())==1 then
                
                    allianceSmallDialog:showOKDialog(leaveAlliance,getlocal("alliance_tuanzhangtuichuSureOK"),layerNum+1)


            else
                    allianceSmallDialog:showOKDialog(leaveAlliance,getlocal("alliance_tuichuok"),layerNum+1)

            end

        end
        local textSize = 25
        if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
            textSize = 18
        end
        textSize = textSize/0.7
        local leaveItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",leaveSureAndCancel,nil,getlocal("alliance_leave"),textSize)
        leaveItem:setScale(0.7)
        local leaveMenu=CCMenu:createWithItem(leaveItem);
        leaveMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,operationLb:getPositionY()-15))
        leaveMenu:setTouchPriority(-(layerNum-1)*20-4);
        self.bgLayer:addChild(leaveMenu)
        
        
        if tonumber(allianceVoApi:getSelfAlliance().role)==0 then
            
            local function promote()
                if allianceMemberVoApi:getLeaderNum()>=2 then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promotionFail1"),30)

                    do
                        return
                    end
                elseif allianceMemberVoApi:getDonate(memberVo.uid)-allianceMemberVoApi:getUseDonate(memberVo.uid)<100 then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promotionFail2"),30)

                    do
                        return
                    end
                end
                
                local function prom()
                    if allianceVoApi:isInAllianceWar() then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("inAllianceWar"),30)

                        do
                            return
                        end
                    end
                    local function promotionCallBack(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("promotionSuccess"),30)
                            self:close()--关闭板子
                            
                        end
                    end
                    socketHelper:alliancePromotion(1,allianceVoApi:getSelfAlliance().aid,promotionCallBack)
                end
                
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),prom,getlocal("dialog_title_prompt"),getlocal("promotionTip"),nil,layerNum+1)
            end

            local promotionItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",promote,nil,getlocal("promotion"),25/0.7)
            promotionItem:setScale(0.7)
            local promotionMenu=CCMenu:createWithItem(promotionItem);
            promotionMenu:setPosition(ccp(430,operationLb:getPositionY()-15))
            promotionMenu:setTouchPriority(-(layerNum-1)*20-4);
            self.bgLayer:addChild(promotionMenu)
        
        end

        
    else
        
        local function appoint1()
            if allianceVoApi:isInAllianceWar() then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("inAllianceWar"),30)

                do
                    return
                end
            end
            local function appoint1CallBack(fn,data)
                if base:checkServerData(data)==true then
                    self:close()--关闭板子
                    memberTb:reloadData()
                end
            end
            socketHelper:allianceSetrole(allianceVoApi:getSelfAlliance().aid,2,memberVo.uid,appoint1CallBack)
    
        end
        
        local function appiont1Sure()
            allianceSmallDialog:showOKDialog(appoint1,getlocal("alliance_zhuanrangSure",{memberVo.name}),layerNum+1)
        end
        local textSize = 25
        if platCfg.platCfgBMImage[G_curPlatName()]~=nil then
            textSize=20
        end
        textSize = textSize/0.7
        local appointItem1 = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",appiont1Sure,nil,getlocal("alliance_info_appoint1"),textSize)
        appointItem1:setScale(0.7)
        local appointMenu1=CCMenu:createWithItem(appointItem1);
        appointMenu1:setPosition(ccp(self.bgLayer:getContentSize().width/2,operationLb:getPositionY()-15))
        appointMenu1:setTouchPriority(-(layerNum-1)*20-4);
        self.bgLayer:addChild(appointMenu1)
        local appointStrName="alliance_info_appoint2"
        local appoint2Type=1
        
        if tonumber(memberVo.role)==1 and tonumber(allianceVoApi:getSelfAlliance().role)==2 then
            print("appointStrNameappointStrNameappointStrName")
            appointStrName="alliance_quitrole2"
            appoint2Type=0
        end
        local function appoint2()
            if allianceVoApi:isInAllianceWar() then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("inAllianceWar"),30)

                do
                    return
                end
            end
            local function appoint2CallBack(fn,data)
                if base:checkServerData(data)==true then

                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_successfulOperation"),30)
                    self:close()--关闭板子
                    memberTb:reloadData()
                end
            end

            socketHelper:allianceSetrole(allianceVoApi:getSelfAlliance().aid,appoint2Type,memberVo.uid,appoint2CallBack)
        
        end
        local function appiont2Sure()
            if appoint2Type==0 then
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),appoint2,getlocal("dialog_title_prompt"),getlocal("alliance_jiangzhiSure",{memberVo.name}),nil,layerNum+1)
            elseif appoint2Type==1 then
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),appoint2,getlocal("dialog_title_prompt"),getlocal("alliance_tibaSure",{memberVo.name}),nil,layerNum+1)
            end

        end
        local appointItem2 = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",appiont2Sure,nil,getlocal(appointStrName),25/0.7)
        appointItem2:setScale(0.7)
        local appointMenu2=CCMenu:createWithItem(appointItem2);
        appointMenu2:setPosition(ccp(430,operationLb:getPositionY()-80))
        appointMenu2:setTouchPriority(-(layerNum-1)*20-4);
        self.bgLayer:addChild(appointMenu2)
        
        local function kickOut2()
            if allianceVoApi:isInAllianceWar() then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("inAllianceWar"),30)

                do
                    return
                end
            end
            if allianceCityVoApi:ishasDefTroops(memberVo.uid)==true then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("canotQuitAllianceStr2"),30)
                do return end
            end
            local function kickOutCallBack(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_successfulOperation"),30)
                    local function allianceCallback()
                        local params={}
                        if sData.data.cPlace then
                            params.x=sData.data.cPlace[1]
                            params.y=sData.data.cPlace[2]
                            params.baseUid=sData.data.cPlace[3]
                        end
                        chatVoApi:sendUpdateMessage(6,params)
                        allianceMemberVoApi:deleteMemberByUid(memberVo.uid)
                        self:close()--关闭板子
                        memberTb:reloadData()
                    end
                    G_getAlliance(allianceCallback)
                end
            end
            socketHelper:allianceQuit(allianceVoApi:getSelfAlliance().aid,memberVo.uid,kickOutCallBack)

        end

        local function kickOut()
            if base.localWarSwitch==1 then
                if localWarVoApi:canQuitAlliance(2)==false then
                    do return end
                end
            end
            if base.serverWarLocalSwitch==1 then
                if serverWarLocalVoApi:canQuitAlliance(2)==false then
                    do return end
                end
            end
            allianceSmallDialog:showOKDialog(kickOut2,getlocal("alliance_tichuok",{memberVo.name}),layerNum+1)
        
        end

        local kickItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",kickOut,nil,getlocal("alliance_info_kickOut"),textSize)
        kickItem:setScale(0.7)
        local kickMenu=CCMenu:createWithItem(kickItem);
        kickMenu:setPosition(ccp(self.bgLayer:getContentSize().width/2,operationLb:getPositionY()-80))
        kickMenu:setTouchPriority(-(layerNum-1)*20-4);
        self.bgLayer:addChild(kickMenu)
        
        if tonumber(memberVo.role)>tonumber(alliance.role) then
            local function impeach()
                if tonumber(alliance.role)==0 and tonumber(memberVo.role)==2 then
                        smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("impeachDesc2"),nil,layerNum+1)
                        do
                            return
                        end
                end

                if tonumber(base.serverTime)-tonumber(memberVo.logined_at)<=24*60*60*7 then
                    smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("impeachDesc1"),nil,layerNum+1)

                    do
                        return
                    end
                
                else
                    
                    if allianceVoApi:isInAllianceWar() then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("inAllianceWar"),30)

                        do
                            return
                        end
                    end

                    local function impeachCallBack(fn,data)
                        local ret,sData=base:checkServerData(data)
                        if ret==true then
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("impeachSuccess"),30)
                            self:close()--关闭板子

                        end
                    end

                    socketHelper:allianceImpeach(memberVo.uid,alliance.aid,impeachCallBack)

                end
        
            end
            
            local impeachItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",impeach,nil,getlocal("impeach"),25/0.7)
            impeachItem:setScale(0.7)
            local impeachMenu=CCMenu:createWithItem(impeachItem);
            impeachMenu:setPosition(ccp(430,operationLb:getPositionY()-15))
            impeachMenu:setTouchPriority(-(layerNum-1)*20-4);
            self.bgLayer:addChild(impeachMenu)
        end



        if tonumber(allianceVoApi:getSelfAlliance().role)==0 then
            kickItem:setEnabled(false)
            appointItem2:setEnabled(false)
            appointItem1:setEnabled(false)
        elseif tonumber(allianceVoApi:getSelfAlliance().role)==1 then
            if tonumber(memberVo.role)==0 then
                kickItem:setEnabled(true)
            else
                kickItem:setEnabled(false)
            end
            appointItem1:setEnabled(false)
            appointItem2:setEnabled(false)
        elseif tonumber(allianceVoApi:getSelfAlliance().role)==2 then
            kickItem:setEnabled(true)
            appointItem2:setEnabled(true)
            appointItem1:setEnabled(true)
            if tonumber(allianceMemberVoApi:getLeaderNum())==2 and tonumber(memberVo.role)==0 then
                appointItem2:setEnabled(false)
            end
        end

    end

    local lineSp1=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
    lineSp1:setAnchorPoint(ccp(0.5,0));
    lineSp1:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,2))
    lineSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2,operationLb:getPositionY()+20));
    self.bgLayer:addChild(lineSp1,1)

    self:addTextField(memberVo,istouch,layerNum,lbhight)


end
function allianceSmallDialog:showSureAndCancle(bgSrc,size,fullRect,inRect,callBack,title,content,isuseami,layerNum,align,valign,cancleCallBack)
      local sd=allianceSmallDialog:new()
      sd:initSureAndCancle(bgSrc,size,fullRect,inRect,callBack,title,content,isuseami,layerNum,align,valign,cancleCallBack)
end

function allianceSmallDialog:showSure(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,lbColor,callBackHandler)
      local sd=allianceSmallDialog:new()
      sd:initSure(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,lbColor,callBackHandler)
end

function allianceSmallDialog:showNormal(bgSrc,size,fullRect,inRect,tmpFunc,istouch,isuseami,layerNum,textTab,textSize,textColorTab)
      local sd=allianceSmallDialog:new()
      sd:init(bgSrc,size,fullRect,inRect,tmpFunc,istouch,isuseami,layerNum,textTab,textSize,textColorTab)
end

-- bgSrc:9宫格背景图片 size:对话框大小 callBack:确定回调函数 title:标题 content:内容 isuseami:是否有动画效果 layerNum:层次
function allianceSmallDialog:initSureAndCancle(bgSrc,size,fullRect,inRect,callBack,title,content,isuseami,layerNum,align,valign,cancleCallBack)
    self.isTouch=istouch
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
    
    local titleLb=GetTTFLabel(title,40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)
    local realalign,realValign=kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter
    if align~=nil then
        realalign=align
    end
    if valign~=nil then
        realValign=valign
    end
    local contentLb=GetTTFLabelWrap(content,25,CCSize(size.width-100,200),realalign,realValign)
   contentLb:setAnchorPoint(ccp(0.5,0.5))
    contentLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height-contentLb:getContentSize().height/2-50))
    dialogBg:addChild(contentLb)
    
    --取消
    local function cancleHandler()
         PlayEffect(audioCfg.mouseClick)
         if cancleCallBack~=nil then
            cancleCallBack()
         end
         self:close()
    end
    local cancleItem=GetButtonItem("BtnGraySmall.png","BtnGraySmall_Down.png","BtnGraySmall_Down.png",cancleHandler,2,getlocal("cancel"),25)
    local cancleMenu=CCMenu:createWithItem(cancleItem);
    cancleMenu:setPosition(ccp(size.width-120,80))
    cancleMenu:setTouchPriority(-(layerNum-1)*20-2);
    dialogBg:addChild(cancleMenu)
    --确定
    local function sureHandler()
        PlayEffect(audioCfg.mouseClick)
        callBack()
        self:close()
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("ok"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(120,80))
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
end




function allianceSmallDialog:initSure(bgSrc,size,fullRect,inRect,title,content,isuseami,layerNum,lbColor,callBackHandler)
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
    
    local contentLb=GetTTFLabelWrap(content,28,CCSize(size.width-100,100),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
   contentLb:setAnchorPoint(ccp(0.5,0.5))
    contentLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height-contentLb:getContentSize().height/2-70))
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

    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png",cancleHandler,2,getlocal("ok"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(size.width/2,80))
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
end

function allianceSmallDialog:initAllianceInforDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,allianceVo,callBackHandler)
      local sd=allianceSmallDialog:new()
      local dialog=sd:allianceInforDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,allianceVo,callBackHandler)
      return sd
end
function allianceSmallDialog:allianceInforDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,allianceVo,callBackHandler)
    self.isTouch=false
    self.isUseAmi=isuseami
    G_AllianceDialogTb[2]=self
    local function touchHandler()
    
    end

    local function closeCallBack()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end

    local dialogBg = G_getNewDialogBg(size,getlocal("alliance_list_check_info"),30,nil,layerNum,true,closeCallBack)
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
	

	
	local txtSize = 25
	local widthSpace=110
	local heightSpace=90
	local wSpace=60
	local hSpace=40
    local alliance=allianceVo or {}
    --[[
	local conditionStr=""
    if alliance.level_limit and alliance.level_limit>0 then
        conditionStr=conditionStr..getlocal("fightLevel",{alliance.level_limit})
    end
    if alliance.fight_limit and alliance.fight_limit>0 then
        if conditionStr=="" then
            conditionStr=conditionStr..getlocal("alliance_join_condition_value",{FormatNumber(alliance.fight_limit)})
        else
            conditionStr=conditionStr..getlocal("alliance_join_condition_and")..getlocal("alliance_join_condition_value",{FormatNumber(alliance.fight_limit)})
        end
    end
    if conditionStr=="" then
        conditionStr=getlocal("alliance_info_content")
    end
    ]]
	local nameTab={"alliance_scene_button_info_name","alliance_scene_leader_name","alliance_scene_rank","alliance_scene_level","alliance_scene_member_num","alliance_join_type","alliance_join_condition"}
	local valueTab={alliance.name,alliance.leaderName,alliance.rank,alliance.level,getlocal("scheduleChapter",{alliance.num,alliance.maxnum}),getlocal("alliance_apply"..alliance.type)}
    local lbhight = self.bgSize.height-heightSpace
	for i=1,SizeOfTable(nameTab) do

        local temphight
		local nameLable = GetTTFLabelWrap(getlocal(nameTab[i]),txtSize,CCSizeMake(txtSize*7,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
	    nameLable:setAnchorPoint(ccp(0,1))
	    nameLable:setPosition(ccp(48,lbhight))
		self.bgLayer:addChild(nameLable,1)
	    temphight = nameLable:getContentSize().height

        if nameTab[i]=="alliance_join_condition" then
            local levelLable=GetTTFLabelWrap(getlocal("fightLevel",{alliance.level_limit}),txtSize,CCSizeMake(txtSize*12,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            levelLable:setAnchorPoint(ccp(0,1))
            -- levelLable:setColor(G_ColorYellow)

            local fightLable=GetTTFLabel(getlocal("alliance_join_condition_value",{FormatNumber(alliance.fight_limit)}),txtSize,CCSizeMake(txtSize*12,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            fightLable:setAnchorPoint(ccp(0,1))
            -- fightLable:setColor(G_ColorYellow)

            local andLabel=GetTTFLabel(getlocal("alliance_join_condition_and"),txtSize,CCSizeMake(txtSize*12,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            andLabel:setAnchorPoint(ccp(0,1))
            -- andLabel:setColor(G_ColorYellow)

            local noLabel=GetTTFLabel(getlocal("alliance_info_content"),txtSize,CCSizeMake(txtSize*12,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
            noLabel:setAnchorPoint(ccp(0,1))
            -- noLabel:setColor(G_ColorYellow)

            local limitStr = ""
            

            if alliance.level_limit and alliance.level_limit>0 then
                levelLable:setPosition(ccp(self.bgSize.width/2-widthSpace+wSpace,lbhight))
                self.bgLayer:addChild(levelLable,1)
                if temphight< levelLable:getContentSize().height then
                temphight = levelLable:getContentSize().height
                end
                --[[if alliance.fight_limit and alliance.fight_limit>0 then
                    fightLable:setPosition(ccp(self.bgSize.width/2-widthSpace+wSpace,levelLable:getPositionY()+levelLable:getContentSize().height))
                    self.bgLayer:addChild(andLabel,1)
                    temphight = temphight+fightLable:getContentSize().height
                end]]
                if allianceVoApi:isHasAlliance()==false and playerVoApi:getPlayerLevel()<alliance.level_limit then
                    levelLable:setColor(G_ColorRed)
                    andLabel:setColor(G_ColorRed)
                end
            end
            

            if alliance.fight_limit and alliance.fight_limit>0 then
                if alliance.level_limit and alliance.level_limit>0 then 
                    fightLable:setPosition(ccp(self.bgSize.width/2-widthSpace+wSpace,levelLable:getPositionY()-levelLable:getContentSize().height))
                    temphight = temphight +fightLable:getContentSize().height
                else
                    fightLable:setPosition(ccp(self.bgSize.width/2-widthSpace+wSpace,lbhight))
                    if temphight< fightLable:getContentSize().height then
                         temphight = fightLable:getContentSize().height
                     end
                end
                self.bgLayer:addChild(fightLable,1)
                if allianceVoApi:isHasAlliance()==false and playerVoApi:getPlayerPower()<alliance.fight_limit then
                    fightLable:setColor(G_ColorRed)
                end
            end
            if (alliance.level_limit and alliance.level_limit>0) or (alliance.fight_limit and alliance.fight_limit>0) then
                --[[if alliance.level_limit and alliance.level_limit>0 then
                    limitStr = limitStr..getlocal("fightLevel",{alliance.level_limit})
                end
                if alliance.fight_limit and alliance.fight_limit>0 then
                    limitStr = limitStr..getlocal("alliance_join_condition_value",{FormatNumber(alliance.fight_limit)})
                end
               local limitLb = GetTTFLabelWrap(limitStr,txtSize,CCSizeMake(txtSize*12,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
                limitLb:setAnchorPoint(ccp(0,1))
                limitLb:setColor(G_ColorYellow)
                limitLb:setPosition(ccp(self.bgSize.width/2-widthSpace+wSpace,lbhight))
                self.bgLayer:addChild(limitLb,1)
                if temphight<limitLb:getContentSize().height then
                    temphight = limitLb:getContentSize().height
                end--]]

            else
                noLabel:setPosition(ccp(self.bgSize.width/2-widthSpace+wSpace,lbhight))
                if G_getCurChoseLanguage()=="ar" then
                    local nolabelxSize=noLabel:getContentSize().width
                    noLabel:setPositionX(self.bgSize.width-nolabelxSize-15)
                end
                self.bgLayer:addChild(noLabel,1)

               
                if temphight<noLabel:getContentSize().height then
                    temphight = noLabel:getContentSize().height
                end
            end
        else
    		local nameValueLable = GetTTFLabelWrap(valueTab[i],txtSize,CCSizeMake(self.bgSize.width/2+40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    	    nameValueLable:setAnchorPoint(ccp(0,1))
    	    nameValueLable:setPosition(ccp(self.bgSize.width/2-widthSpace+wSpace,lbhight))
    		self.bgLayer:addChild(nameValueLable,1)
            -- nameValueLable:setColor(G_ColorYellow)
            if temphight<nameValueLable:getContentSize().height then
                temphight = nameValueLable:getContentSize().height
            end
        end

        lbhight = lbhight - temphight - 5

        local lineWidth = self.bgLayer:getContentSize().width-50

        if i ~= #nameTab then
            if i<= 4 then
                lineWidth = lineWidth - 160
            end
            local LineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
            LineSp:setContentSize(CCSizeMake(lineWidth,2))
            LineSp:setAnchorPoint(ccp(0,1))
            self.bgLayer:addChild(LineSp)
            LineSp:setPosition(ccp(25,lbhight-5))
        end
        lbhight = lbhight - 15
	end
	
    lbhight = lbhight

	
	local capInSet = CCRect(20, 20, 10, 10)
	local function touch()
	end
    local imgName="newAlliance_desc1.png"
    local rect1=CCRect(198,24, 2, 2)
    local noticeBg =LuaCCScale9Sprite:createWithSpriteFrameName(imgName,rect1,touch)
	noticeBg:setContentSize(CCSizeMake(self.bgSize.width-100,300))
	noticeBg:ignoreAnchorPointForPosition(false)
	noticeBg:setAnchorPoint(ccp(0.5,1))
	noticeBg:setPosition(ccp(self.bgSize.width/2,lbhight))
	noticeBg:setIsSallow(false)
	noticeBg:setTouchPriority(-(layerNum-1)*20-2)
	self.bgLayer:addChild(noticeBg,1)

    local noticeLable = GetTTFLabel(getlocal("newAllianceSlogan"),txtSize,"Helvetica-bold")
    noticeLable:setColor(G_ColorYellowPro2)
    noticeLable:setAnchorPoint(ccp(0.5,0))
    noticeLable:setPosition(ccp(noticeBg:getContentSize().width/2,noticeBg:getContentSize().height-18))
    noticeBg:addChild(noticeLable,1)

    local noticeValueLable=GetTTFLabelWrap(alliance.desc,25,CCSize(self.bgSize.width-110,470),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    noticeValueLable:setAnchorPoint(ccp(0,1))
    noticeValueLable:setPosition(ccp(15,noticeBg:getContentSize().height-25))
    noticeBg:addChild(noticeValueLable,1)

    if base.isAf == 1 then
        -- 军团旗帜
        local defaultSelect = allianceVoApi:getFlagIconTab(alliance.banner)
        local flagIcon = allianceVoApi:createShowFlag(defaultSelect[1], defaultSelect[2], defaultSelect[3], 0.5)
        flagIcon:setPosition(self.bgSize.width - 90, self.bgSize.height - heightSpace - 120)
        self.bgLayer:addChild(flagIcon)
    end
	
    if allianceVoApi:isHasAlliance()==false then
        local hasApply=allianceVoApi:isHasApplyAlliance(alliance)
        local canClick=true
        if hasApply==false then
            local function applyHandler()
                PlayEffect(audioCfg.mouseClick)

                if alliance.aid then
                    local function applyCallback(fn,data)
                        if base:checkServerData(data)==true then
                            if alliance.type==1 then    --1 是需要审批，0 是直接加入
                                if allianceVoApi:requestsIsFull() then
                                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_apply_num_max"),30)
                                else
                                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_shenqingTip",{alliance.name}),30)
                                    allianceVoApi:addApply(alliance.aid)
                                    self:close()
                                    if callBackHandler then
                                        callBackHandler(1)
                                    end
                                end
                                canClick=true
                            else
                                worldScene:updateAllianceName()
                                --[[
smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_jiaruTip",{alliance.name}),30)

                                local function getAlliacenCallback(fn1,data1)

                                        local params = {allianceName=alliance.name}
                                        chatVoApi:sendUpdateMessage(7,params)
                                        allianceVoApi:removeApply()
                                        if callBackHandler then
                                            callBackHandler(1)
                                        end
                                        self:close()
                                        canClick=true
                                end
                                print("方法名",getAlliacenCallback)
                                G_getAlliance(getAlliacenCallback)
                                ]]
                            end
                        else
                            self:close()
                        end
                    end
                    if canClick then
                        socketHelper:allianceJoin(alliance.aid,applyCallback)
                        canClick=false
                    end
                end
            end
            local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",applyHandler,2,getlocal("alliance_info_apply"),25)
            sureItem:setScale(0.7)
            local sureMenu=CCMenu:createWithItem(sureItem);
            sureMenu:setPosition(ccp(size.width/2,40))
            sureMenu:setTouchPriority(-(layerNum-1)*20-2);
            dialogBg:addChild(sureMenu)
            if allianceVoApi:isCanApply(alliance)==false then
                sureItem:setEnabled(false)
            end
        else
            local function cancelApplyHandler()
                PlayEffect(audioCfg.mouseClick)

                if alliance.aid then
                    local function cancelApplyCallback(fn,data)
                        if base:checkServerData(data)==true then
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_quxiaoshenqingTip",{alliance.name}),30)
                            --if alliance.type==1 then
                                allianceVoApi:removeApply(alliance.aid)
                            --end
                            self:close()
                            if callBackHandler then
                                callBackHandler(2)
                            end
                        end
                    end
                    --socketHelper:allianceJoin(alliance.aid,applyCallback)
                    socketHelper:allianceCanceljoin(alliance.aid,playerVoApi:getUid(),cancelApplyCallback)
                end
            end
            local sureItem1=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",cancelApplyHandler,2,getlocal("alliance_info_cancel_apply"),25)
            local sureMenu1=CCMenu:createWithItem(sureItem1);
            sureItem1:setScale(0.7)
            sureMenu1:setPosition(ccp(size.width/2,40))
            sureMenu1:setTouchPriority(-(layerNum-1)*20-2);
            dialogBg:addChild(sureMenu1)
        end
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

-- isaddBacklist 1：添加屏蔽  2：添加好友
function allianceSmallDialog:allianceSearchDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callBackHandler,type,isaddBacklist,searchName)
      local sd=allianceSmallDialog:new()
      local dialog=sd:initAllianceSearchDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callBackHandler,type,isaddBacklist,searchName)
      return sd
end
function allianceSmallDialog:initAllianceSearchDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callBackHandler,type,isaddBacklist,searchName)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function touchHandler()
    
    end

    local titleStr = getlocal("alliance_list_scene_searchs")
    if isaddBacklist and isaddBacklist==1 then
        titleStr = getlocal("addForbid_title")
    elseif isaddBacklist and isaddBacklist==2 then
        titleStr = getlocal("addFriends_title")
    end

    local function closeCallBack()
        PlayEffect(audioCfg.mouseClick)    
        return self:close()
    end
    local dialogBg = G_getNewDialogBg(size,titleStr,30,nil,layerNum,true,closeCallBack)
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)
    self:show()
    self.dialogLayer=CCLayer:create()


    local function touchDialog()
      
    end
	
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()
	
     		
     local searchNameStr = getlocal("alliance_search_by_name")
    if isaddBacklist and isaddBacklist==1 then
        searchNameStr = getlocal("addForbid_des")
    elseif isaddBacklist and isaddBacklist==2 then
        searchNameStr = getlocal("addFriends_des")
    end
	local searchLable = GetTTFLabelWrap(searchNameStr,22,CCSizeMake(25*6,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter,"Helvetica-bold")
    searchLable:setAnchorPoint(ccp(0,0.5))
    searchLable:setPosition(ccp(50,self.bgSize.height-155))
	self.bgLayer:addChild(searchLable,1)
	
	-- local searchStr=""
    local function callBackTargetHandler(fn,eB,str)
		-- if str==nil then
		-- 	searchStr=""
		-- 	do return end
		-- end
	 -- 	searchStr=str
    end
	local function tthandler()
	end
    local editTargetBox=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),tthandler)
	editTargetBox:setContentSize(CCSizeMake(self.bgSize.width-230,50))
    editTargetBox:setIsSallow(false)
    editTargetBox:setTouchPriority(-(layerNum-1)*20-4)
	editTargetBox:setPosition(ccp(360,self.bgSize.height-155))
    if not searchName then
        searchName=""
    end
    local targetBoxLabel=GetTTFLabel(searchName,22)
	targetBoxLabel:setAnchorPoint(ccp(0,0.5))
    targetBoxLabel:setPosition(ccp(10,editTargetBox:getContentSize().height/2))
	local customEditBox=customEditBox:new()
	local length=12
	customEditBox:init(editTargetBox,targetBoxLabel,"rankKuang.png",nil,-(layerNum-1)*20-4,length,callBackTargetHandler,nil,nil)
    self.bgLayer:addChild(editTargetBox,2)
    local decStr = getlocal("alliance_search_desc")
    if type then
        decStr=getlocal("friend_search_desc")
    end


    local searchDescLable=GetTTFLabelWrap(decStr,22,CCSize(self.bgSize.width-100,500),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
    searchDescLable:setAnchorPoint(ccp(0,1))
    searchDescLable:setPosition(ccp(50,self.bgSize.height-225))
    self.bgLayer:addChild(searchDescLable,1)
    searchDescLable:setColor(G_ColorYellowPro2)

    if isaddBacklist and isaddBacklist==1 then
        searchDescLable:setVisible(false)
        local desLb = GetTTFLabelWrap(getlocal("addForbid_shieldDesc"),22,CCSize(self.bgSize.width-100,200),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
        desLb:setPosition(ccp(self.bgSize.width/2,150))
        self.bgLayer:addChild(desLb,1)
        desLb:setColor(G_ColorYellowPro2)
    elseif isaddBacklist and isaddBacklist==2 then
         searchDescLable:setVisible(false)
    end
	
    local function searchHandler()
        PlayEffect(audioCfg.mouseClick)
        local searchStr=targetBoxLabel:getString()
        if searchStr==nil or searchStr=="" then
            if callBackHandler~=nil then
                callBackHandler()
            end
            self:close()
        else
            local searchNum=G_utfstrlen(searchStr,true)
            if searchNum and searchNum>12 then
                if callBackHandler~=nil then
                    callBackHandler(searchStr,true)
                end
                self:close()   
            else
                local function searchCallback(fn,data)
                    if base:checkServerData(data)==true then
                        if callBackHandler~=nil then
                            callBackHandler(searchStr)
                        end
                        self:close()
                    end
                end

                local function addBlackList(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if sData and sData.data and sData.data.flag and sData.data.flag==0 then
                             smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_searchNo"),28)
                         end

                        if sData and sData.data and sData.data.tid then
                            local uid=sData.data.tid
                            local name= searchStr
                            local isHas=false
                            for k,v in pairs(G_blackList) do
                                if v and v[1] and uid and tonumber(v[1])==tonumber(uid) then
                                    isHas=true
                                end
                            end
                            if isHas==false then
                                local tempList=G_clone(G_blackList)
                                G_blackList={{tonumber(uid),name}}
                                for k,v in pairs(tempList) do
                                    table.insert(G_blackList,v)
                                end
                                if callBackHandler~=nil then
                                    callBackHandler(searchStr,true)
                                end
                            end
                        end

                        self:close()
                    end
                end

                local function addFriendList(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        if sData and sData.data and SizeOfTable(sData.data)==0 then
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_searchNo"),28)
                            self:close()
                            return
                        end
                        local function callback(fn,data)
                            local ret,sData=base:checkServerData(data)
                            if ret==true then
                 --             local toBlackTb={uid=uid,name=name}
                                -- local isSuccess=G_saveNameAndUidInMailList(toBlackTb)
                                -- if isSuccess==true then
                                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("addMailListSuccess",{searchStr}),28)
                                -- end
                                local function callbackList(fn,data)
                                local ret,sData=base:checkServerData(data)
                                    if ret==true then
                                        if callBackHandler~=nil then
                                            callBackHandler(searchStr,true)
                                        end
                                        self:close()
                                    end
                                end
                                socketHelper:friendsList(callbackList)
                            elseif sData.ret==-12001 then
                 --             local toBlackTb={uid=uid,name=name}
                                -- local isSuccess=G_saveNameAndUidInMailList(toBlackTb)
                                local function callbackList(fn,data)
                                local ret,sData=base:checkServerData(data)
                                    if ret==true then
                                        if callBackHandler~=nil then
                                            callBackHandler(searchStr,true)
                                        end
                                        self:close()
                                    end
                                end
                                socketHelper:friendsList(callbackList)
                            end

                        end
                        socketHelper:friendsAdd(searchStr,callback)  
                    end
                end
                if isaddBacklist and isaddBacklist==1 then
                    local name= searchStr
                    local blackList=G_getBlackList()
                    if blackList and SizeOfTable(blackList)>0 then
                        for k,v in pairs(blackList) do
                            if tostring(name)==tostring(v.name) then
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("shieldSuccess",{name}),28)
                                self:close()
                                do return end
                            end
                        end
                    end
                    if SizeOfTable(G_getBlackList())>=G_blackListNum then
                         smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("blackListMax"),28)
                         self:close()
                        do return end
                    end
                    if name==playerVoApi:getPlayerName() then
                         smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("addForbid_tip"),28)
                         self:close()
                        do return end
                    end
                    local isGM = false
                    for k,v in pairs(GM_Name) do
                        if v == name then
                            isGM = true
                            do break end
                        end
                    end
                    if isGM then
                        self:close()
                        do return end
                    else
                        socketHelper:mailAddblack(nil,nil,addBlackList,name)
                    end
                elseif isaddBacklist and isaddBacklist==2 then
                    local name= searchStr
                    local mailListTb=G_getMailList()

                     if SizeOfTable(mailListTb)>=G_mailListNum then
                         smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("mailListMax"),28)
                         self:close()
                        do return end
                    end

                     if name==playerVoApi:getPlayerName() then
                         smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("addFriends_tip"),28)
                         self:close()
                        do return end
                    end

                    local flag=false
                    for k,v in pairs(mailListTb) do
                        if v.name==name then
                            flag=true
                            break
                        end
                    end
                    if flag==true then
                        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alreadyFriend"),28)
                    else
                        local isGM = false
                        for k,v in pairs(GM_Name) do
                            if v == name then
                                isGM = true
                                do break end
                            end
                        end
                        if isGM then
                            self:close()
                            do return end
                        else
                            socketHelper:friendsSearch(name,addFriendList)
                        end
                    end
                    
                else
                    allianceVoApi:clearSearchList()
                    socketHelper:allianceFind(searchStr,searchCallback)
                end
               
            end
        end
    end
    local btnStr=getlocal("alliance_list_scene_searchs")
    if isaddBacklist then
        btnStr=getlocal("addMailList")
    end
    local sureItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",searchHandler,2,btnStr,24,11)
    local lb=tolua.cast(sureItem:getChildByTag(11),"CCLabelTTF")
    lb:setFontName("Helvetica-bold")
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(size.width/2,70))
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

function allianceSmallDialog:allianceSettingsDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,saveCallBack,allianceVo,refreshLabel)
      local sd=allianceSmallDialog:new()
      local dialog=sd:initAllianceSettingsDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,saveCallBack,allianceVo,refreshLabel)
      return sd
end
function allianceSmallDialog:initAllianceSettingsDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,saveCallBack,allianceVo,refreshLabel)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function touchHandler()
    
    end

    local function closeCallBack()
        PlayEffect(audioCfg.mouseClick)
        local alliance = allianceVoApi:getSelfAlliance()
        if refreshLabel and tolua.cast(refreshLabel,"CCLabelTTF") then
            tolua.cast(refreshLabel,"CCLabelTTF"):setString(alliance.notice)
        end
        return self:close()
    end

    local dialogBg = G_getNewDialogBg(size,getlocal("alliance_scene_setting"),30,nil,layerNum,true,closeCallBack)
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
	
    local leftPos=25

    local joinType=allianceVo.type or 0
    local isNeedLevel=false
    local isNeedFight=false
    local needLevel=0
    local needFight=0
    --if allianceVo.joinCondition then
        needLevel=tonumber(allianceVo.level_limit) or 0
        needFight=tonumber(allianceVo.fight_limit) or 0
    --end
    if needLevel>0 then
        isNeedLevel=true
    end
    if needFight>0 then
        isNeedFight=true
    end
    local internalNotice=allianceVo.notice or ""
    local foreignNotice=allianceVo.desc or ""
	local labelPosWidth =leftPos
    if G_getCurChoseLanguage() =="ar" then
        labelPosWidth =leftPos+200
    end

    local titleSpire = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),function ( ... ) end)
    titleSpire:setContentSize(CCSizeMake(500,32))
    titleSpire:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(titleSpire)
    titleSpire:setPosition(ccp(labelPosWidth,self.bgSize.height-110))

	local settingsApplyLable = GetTTFLabel(getlocal("alliance_settings_apply_type"),25,true)
    settingsApplyLable:setAnchorPoint(ccp(0,0.5))
    settingsApplyLable:setPosition(ccp(15,titleSpire:getContentSize().height/2))
    titleSpire:addChild(settingsApplyLable,1)

	local wSpace=leftPos
    local applyTypeSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
    local joinTypeSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
    applyTypeSp:setAnchorPoint(ccp(0,0.5))
    self.bgLayer:addChild(applyTypeSp,3)

    if joinType==0 then
        applyTypeSp:setPosition(wSpace,self.bgSize.height-160)
    else
        applyTypeSp:setPosition(wSpace,self.bgSize.height-230)
    end
	
	local function touch1(object,name,tag)
        if tag==1 then
            applyTypeSp:setPosition(wSpace,self.bgSize.height-160)
            joinType=0
        else
            applyTypeSp:setPosition(wSpace,self.bgSize.height-230)
            joinType=1
        end
    end
    local typeSp1=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",touch1)
    typeSp1:setAnchorPoint(ccp(0,0.5))
    typeSp1:setTag(1)
    typeSp1:setTouchPriority(-(layerNum-1)*20-4)
    typeSp1:setPosition(wSpace,self.bgSize.height-160)
    self.bgLayer:addChild(typeSp1,2)

    local typeSp2=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",touch1)
    typeSp2:setAnchorPoint(ccp(0,0.5))
    typeSp2:setTag(2)
    typeSp2:setTouchPriority(-(layerNum-1)*20-4)
    typeSp2:setPosition(wSpace,self.bgSize.height-230)
    self.bgLayer:addChild(typeSp2,2)
	
	local applyTypeLable1 = GetTTFLabelWrap(getlocal("alliance_apply0"),25,CCSizeMake(25*18,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
    applyTypeLable1:setAnchorPoint(ccp(0,0.5))
    applyTypeLable1:setPosition(ccp(wSpace+typeSp1:getContentSize().width+10,self.bgSize.height-160))
	self.bgLayer:addChild(applyTypeLable1,2)
	
	local applyTypeLable2 = GetTTFLabelWrap(getlocal("alliance_apply1"),25,CCSizeMake(25*18,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
    applyTypeLable2:setAnchorPoint(ccp(0,0.5))
    applyTypeLable2:setPosition(ccp(wSpace+typeSp2:getContentSize().width+10,self.bgSize.height-230))
	self.bgLayer:addChild(applyTypeLable2,2)
	
	

    local joinTypeSp1=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
    joinTypeSp1:setAnchorPoint(ccp(0,0.5))
    joinTypeSp1:setPosition(wSpace,self.bgSize.height-340)
    self.bgLayer:addChild(joinTypeSp1,3)
    if needLevel and needLevel>0 then
    else
        joinTypeSp1:setVisible(false)
    end

    local joinTypeSp2=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
    joinTypeSp2:setAnchorPoint(ccp(0,0.5))
    joinTypeSp2:setPosition(wSpace,self.bgSize.height-410)
    self.bgLayer:addChild(joinTypeSp2,3)
    if needFight and needFight>0 then
    else
        joinTypeSp2:setVisible(false)
    end
	
	local settingsJoinLable = GetTTFLabelWrap(getlocal("alliance_settings_join_condition"),25,CCSizeMake(self.bgLayer:getContentSize().width-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    settingsJoinLable:setColor(G_ColorYellowPro2)
    settingsJoinLable:setAnchorPoint(ccp(0,0.5))
    local settingPosWidht = leftPos
    if G_getCurChoseLanguage() =="ar" then
        settingPosWidht =leftPos-200
    end
    settingsJoinLable:setPosition(ccp(settingPosWidht,self.bgSize.height-285))
	self.bgLayer:addChild(settingsJoinLable,1)
	--[[
    local function touch2(object,name,tag)
        if joinTypeSp1:isVisible()==true then
            joinTypeSp1:setVisible(false)
            isNeedLevel=false
        else
            joinTypeSp1:setVisible(true)
            isNeedLevel=true
        end
        --joinTypeSp1:setPosition(wSpace,self.bgSize.height-340)
    end
    local needSp1=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",touch2)
    needSp1:setAnchorPoint(ccp(0,0.5))
    needSp1:setTag(3)
    needSp1:setTouchPriority(-(layerNum-1)*20-4)
    needSp1:setPosition(wSpace,self.bgSize.height-340)
    self.bgLayer:addChild(needSp1,2)

    local function touch3(object,name,tag)
        if joinTypeSp2:isVisible()==true then
            joinTypeSp2:setVisible(false)
            isNeedFight=false
        else
            joinTypeSp2:setVisible(true)
            isNeedFight=true
        end
        --joinTypeSp1:setPosition(wSpace,self.bgSize.height-410)
    end
    local needSp2=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",touch3)
    needSp2:setAnchorPoint(ccp(0,0.5))
    needSp2:setTag(4)
    needSp2:setTouchPriority(-(layerNum-1)*20-4)
    needSp2:setPosition(wSpace,self.bgSize.height-410)
    self.bgLayer:addChild(needSp2,2)
    ]]
    local strSize = 25
    if G_isAsia() == false then
        strSize = 22
    end
	local joinTypeLable1 = GetTTFLabelWrap(getlocal("alliance_settings_level"),strSize,CCSizeMake(125,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    joinTypeLable1:setAnchorPoint(ccp(0,0.5))
    joinTypeLable1:setPosition(ccp(wSpace+50+10,self.bgSize.height-340))
	self.bgLayer:addChild(joinTypeLable1,2)

	--local levelStr=""
    local function callBackLevelHandler(fn,eB,str)
		if str==nil then
			--levelStr=""
            needLevel=""
			do return end
		end
	 	--levelStr=str
        needLevel=str
        if tonumber(needLevel) and tonumber(needLevel)>60 then
            needLevel="60"
            return needLevel
        end
    end
	local function nilFunc()
	end
    local editLevelBox=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilFunc)
	editLevelBox:setContentSize(CCSizeMake(self.bgSize.width-280,50))
    editLevelBox:setIsSallow(false)
    editLevelBox:setTouchPriority(-(layerNum-1)*20-4)
	editLevelBox:setPosition(ccp(wSpace+50+joinTypeLable1:getContentSize().width+editLevelBox:getContentSize().width/2+25,self.bgSize.height-340))
    local levelBoxLabel=GetTTFLabel(needLevel,25)
	levelBoxLabel:setAnchorPoint(ccp(0,0.5))
    levelBoxLabel:setPosition(ccp(10,editLevelBox:getContentSize().height/2))
	local customEditBox=customEditBox:new()
	local length1=12
    local function clickCallback()
        if isNeedLevel==false then
            return true
        else
            return false
        end
    end
	customEditBox:init(editLevelBox,levelBoxLabel,"rankKuang.png",nil,-(layerNum-1)*20-4,length1,callBackLevelHandler,nil,CCEditBox.kEditBoxInputModeNumeric,nil,clickCallback)
    self.bgLayer:addChild(editLevelBox,2)

	local joinTypeLable2 = GetTTFLabelWrap(getlocal("alliance_settings_power"),strSize,CCSizeMake(125,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    joinTypeLable2:setAnchorPoint(ccp(0,0.5))
    joinTypeLable2:setPosition(ccp(wSpace+50+10,self.bgSize.height-410))
	self.bgLayer:addChild(joinTypeLable2,2)
	
	--local powerStr=""
    local function callBackPowerHandler(fn,eB,str)
		if str==nil then
			--powerStr=""
            needFight=""
			do return end
		end
	 	--powerStr=str
        needFight=str
    end
    local editPowerBox=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),nilFunc)
	editPowerBox:setContentSize(CCSizeMake(self.bgSize.width-280,50))
    editPowerBox:setIsSallow(false)
    editPowerBox:setTouchPriority(-(layerNum-1)*20-4)
	editPowerBox:setPosition(ccp(wSpace+50+joinTypeLable2:getContentSize().width+editPowerBox:getContentSize().width/2+25,self.bgSize.height-410))
    local powerBoxLabel=GetTTFLabel(needFight,25)
	powerBoxLabel:setAnchorPoint(ccp(0,0.5))
    powerBoxLabel:setPosition(ccp(10,editPowerBox:getContentSize().height/2))
	local customEditBox=customEditBox:new()
	local length2=12
    local function clickCallback1()
        if isNeedFight==false then
            return true
        else
            return false
        end
    end
	customEditBox:init(editPowerBox,powerBoxLabel,"rankKuang.png",nil,-(layerNum-1)*20-4,length2,callBackPowerHandler,nil,CCEditBox.kEditBoxInputModeNumeric,nil,clickCallback1)
    self.bgLayer:addChild(editPowerBox,2)
	
	

    local function touch2(object,name,tag)
        if joinTypeSp1:isVisible()==true then
            joinTypeSp1:setVisible(false)
            isNeedLevel=false
            needLevel=0
            levelBoxLabel:setString(0)
        else
            joinTypeSp1:setVisible(true)
            isNeedLevel=true
        end
        --joinTypeSp1:setPosition(wSpace,self.bgSize.height-340)
    end
    local needSp1=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",touch2)
    needSp1:setAnchorPoint(ccp(0,0.5))
    needSp1:setTag(3)
    needSp1:setTouchPriority(-(layerNum-1)*20-4)
    needSp1:setPosition(wSpace,self.bgSize.height-340)
    self.bgLayer:addChild(needSp1,2)

    local function touch3(object,name,tag)
        if joinTypeSp2:isVisible()==true then
            joinTypeSp2:setVisible(false)
            isNeedFight=false
            needFight=0
            powerBoxLabel:setString(0)
        else
            joinTypeSp2:setVisible(true)
            isNeedFight=true
        end
        --joinTypeSp1:setPosition(wSpace,self.bgSize.height-410)
    end
    local needSp2=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",touch3)
    needSp2:setAnchorPoint(ccp(0,0.5))
    needSp2:setTag(4)
    needSp2:setTouchPriority(-(layerNum-1)*20-4)
    needSp2:setPosition(wSpace,self.bgSize.height-410)
    self.bgLayer:addChild(needSp2,2)


    local coolingTime = allianceVoApi:getEditAllianceDescCoolingTime()
    local editBgHeight,offh = 165,0
    if coolingTime > 0 then
        editBgHeight,offh = 140,10
    end
	local noticeLable = GetTTFLabel(getlocal("newAllianceNotice"),strSize,true)
    noticeLable:setAnchorPoint(ccp(0.5,0))
    noticeLable:setPosition(ccp(self.bgLayer:getContentSize().width/2,425))
    noticeLable:setColor(G_ColorYellowPro2)
	self.bgLayer:addChild(noticeLable,1)
	
	--输入框--------------------------------
	local capInSet = CCRect(198,24, 2, 2)
	local function touch1(hd,fn,idx)
		--if self.isMoved==false then
			PlayEffect(audioCfg.mouseClick)
			if self.noticeEditBox then
		        self.noticeEditBox:setVisible(true)
				--self.noticeEditBox:setText(textValue)
			end
			--end
	end
	local noticeBg =LuaCCScale9Sprite:createWithSpriteFrameName("newAlliance_desc1.png",capInSet,touch1)
	noticeBg:setContentSize(CCSizeMake(500,editBgHeight))
	noticeBg:ignoreAnchorPointForPosition(false)
	noticeBg:setAnchorPoint(ccp(0.5,0.5))
	noticeBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,360 + offh))
	noticeBg:setIsSallow(false)
	noticeBg:setTouchPriority(-(layerNum-1)*20-2)
	self.bgLayer:addChild(noticeBg,1)
	
	local textLabel1=GetTTFLabelWrap(internalNotice,25,CCSizeMake(noticeBg:getContentSize().width-30,noticeBg:getContentSize().height-5),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	textLabel1:setAnchorPoint(ccp(0,1))
	textLabel1:setPosition(ccp(20,noticeBg:getContentSize().height-20))
	noticeBg:addChild(textLabel1,2)
	
	local maxLength=75
	local noticeStr=textLabel1:getString()
	local function tthandler()

    end
	local lastStr1
    local function callBackHandler(fn,eB,str,type)
		--if type==0 then  --开始输入
			--eB:setText(noticeStr)
		if type==1 then  --检测文本内容变化
			if str==nil then
				noticeStr=""
			else
				noticeStr=str
				--[[
				if changeCallback then
					local txt=changeCallback(fn,eB,str,type)
					if txt then
						noticeStr=txt
						eB:setText(noticeStr)
					end
				end
				]]
			end
			if G_utfstrlen(str or "")>maxLength then
				
			else
				lastStr1=str
			end
            textLabel1:setString(noticeStr)
		elseif type==2 then --检测文本输入结束
			eB:setVisible(false)
			if G_utfstrlen(noticeStr or "")>maxLength or G_utfstrlen(str or "")>maxLength then
				noticeStr=lastStr1 or ""
				eB:setText(noticeStr)
				textLabel1:setString(noticeStr)
			end
		end
    end

    local winSize=CCEGLView:sharedOpenGLView():getFrameSize()
    local xScale=winSize.width/640
    local yScale=winSize.height/960
	local size=CCSizeMake(self.bgLayer:getContentSize().width,50)
	local xBox=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),tthandler)
    self.noticeEditBox=CCEditBox:createForLua(size,xBox,nil,nil,callBackHandler)
	self.noticeEditBox:setFont(textLabel1.getFontName(textLabel1),yScale*textLabel1.getFontSize(textLabel1)/2)
	self.noticeEditBox:setMaxLength(maxLength)
	self.noticeEditBox:setText(noticeStr)
	self.noticeEditBox:setAnchorPoint(ccp(0,0))
	self.noticeEditBox:setPosition(ccp(0,200))

	--self.noticeEditBox:setInputFlag(CCEditBox.kEditBoxInputFlagInitialCapsAllCharacters)
    self.noticeEditBox:setInputFlag(CCEditBox.kEditBoxInputFlagInitialCapsSentence)
	self.noticeEditBox:setInputMode(CCEditBox.kEditBoxInputModeSingleLine)

    self.noticeEditBox:setVisible(false)
    self.bgLayer:addChild(self.noticeEditBox,3)
	----------------------------------
	local decPosWidth = leftPos
    if G_getCurChoseLanguage() =="ar" then
        decPosWidth = leftPos-20
    end
	local declarationLable = GetTTFLabel(getlocal("newAllianceSlogan"),strSize,true)
    declarationLable:setAnchorPoint(ccp(0.5,0))
    declarationLable:setPosition(ccp(self.bgLayer:getContentSize().width/2,250))
    declarationLable:setColor(G_ColorYellowPro2)
	self.bgLayer:addChild(declarationLable,1)
	
	--输入框--------------------------------
	local function touch2(hd,fn,idx)
		--if self.isMoved==false then
			PlayEffect(audioCfg.mouseClick)
			if self.declarationEditBox then
		        self.declarationEditBox:setVisible(true)
				--self.noticeEditBox:setText(textValue)
			end
			--end
	end
	local declarationBg =LuaCCScale9Sprite:createWithSpriteFrameName("newAlliance_desc1.png",capInSet,touch2)
	declarationBg:setContentSize(CCSizeMake(500,editBgHeight))
	declarationBg:ignoreAnchorPointForPosition(false)
	declarationBg:setAnchorPoint(ccp(0.5,0.5))
	declarationBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,185+offh))
	declarationBg:setIsSallow(false)
	declarationBg:setTouchPriority(-(layerNum-1)*20-2)
	self.bgLayer:addChild(declarationBg,1)

	
	local textLabel2=GetTTFLabelWrap(foreignNotice,25,CCSizeMake(declarationBg:getContentSize().width-30,declarationBg:getContentSize().height),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	textLabel2:setAnchorPoint(ccp(0,1))
	textLabel2:setPosition(ccp(20,declarationBg:getContentSize().height-20))
	declarationBg:addChild(textLabel2,2)

	local declarationStr=textLabel2:getString()
	local lastStr2
    local function callBackHandler1(fn,eB,str,type)
		--if type==0 then  --开始输入
			--eB:setText(noticeStr)
		if type==1 then  --检测文本内容变化
			if str==nil then
				declarationStr=""
			else
				declarationStr=str
				--[[
				if changeCallback then
					local txt=changeCallback(fn,eB,str,type)
					if txt then
						declarationStr=txt
						eB:setText(declarationStr)
					end
				end
				]]
			end
			if G_utfstrlen(str or "")>maxLength then
				
			else
				lastStr2=str
			end
            textLabel2:setString(declarationStr)
		elseif type==2 then --检测文本输入结束
			eB:setVisible(false)
			if G_utfstrlen(declarationStr or "")>maxLength or G_utfstrlen(str or "")>maxLength then
				declarationStr=lastStr2 or ""
				eB:setText(declarationStr)
				textLabel2:setString(declarationStr)
			end
		end
    end

    local winSize1=CCEGLView:sharedOpenGLView():getFrameSize()
    local xScale1=winSize1.width/640
    local yScale1=winSize1.height/960
	local size1=CCSizeMake(self.bgLayer:getContentSize().width,50)
	local xBox1=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),tthandler)
    self.declarationEditBox=CCEditBox:createForLua(size1,xBox1,nil,nil,callBackHandler1)
	self.declarationEditBox:setFont(textLabel2.getFontName(textLabel2),yScale1*textLabel2.getFontSize(textLabel2)/2)
	self.declarationEditBox:setMaxLength(maxLength)
	self.declarationEditBox:setText(declarationStr)
	self.declarationEditBox:setAnchorPoint(ccp(0,0))
	self.declarationEditBox:setPosition(ccp(0,30))

	--self.declarationEditBox:setInputFlag(CCEditBox.kEditBoxInputFlagInitialCapsAllCharacters)
    self.noticeEditBox:setInputFlag(CCEditBox.kEditBoxInputFlagInitialCapsSentence)
	self.declarationEditBox:setInputMode(CCEditBox.kEditBoxInputModeSingleLine)

    self.declarationEditBox:setVisible(false)
    self.bgLayer:addChild(self.declarationEditBox,3)
	----------------------------------

    local function saveHandler()
        PlayEffect(audioCfg.mouseClick)
        local joinNeedLv=0
        local joinNeedFc=0
        
        if  platCfg.platCfgKeyWord[G_curPlatName()]~=nil  then --设置屏蔽字
            if keyWordCfg:keyWordsJudge(noticeStr)==false or keyWordCfg:keyWordsJudge(declarationStr)==false  then
                do
                    return
                end
            end
        end

        if isNeedLevel==true and needLevel~=nil and needLevel~="" then
            if tonumber(needLevel)==nil then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_input_error"),28)
                do return end
            elseif tonumber(needLevel)>0 then
                joinNeedLv=tonumber(needLevel)
            end
        end
        if isNeedFight==true and needFight~=nil and needFight~="" then
            if tonumber(needFight)==nil then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_input_error"),28)
                do return end
            elseif tonumber(needFight)>0 then
                joinNeedFc=tonumber(needFight)
            end
        end
        internalNotice=noticeStr
        foreignNotice=declarationStr
        local function saveCallback(fn,data)
            if base:checkServerData(data)==true then
                if saveCallBack~=nil then
                    saveCallBack(allianceVo.aid,internalNotice,foreignNotice,joinNeedLv,joinNeedFc,joinType)
                end
                self:close()
                local params = {aid=allianceVo.aid,type=joinType,level_limit=joinNeedLv,fight_limit=joinNeedFc,desc=foreignNotice}
                chatVoApi:sendUpdateMessage(8,params)
            end
        end
        local needCallback=false
        if tostring(internalNotice)==tostring(allianceVo.notice) then
            internalNotice=nil
        else
            needCallback=true
        end
        if tostring(foreignNotice)==tostring(allianceVo.desc) then
            foreignNotice=nil
        else
            needCallback=true
        end
        if tostring(joinNeedLv)==tostring(allianceVo.level_limit) then
            joinNeedLv=nil
        else
            needCallback=true
        end
        if tostring(joinNeedFc)==tostring(allianceVo.fight_limit) then
            joinNeedFc=nil
        else
            needCallback=true
        end
        if tostring(joinType)==tostring(allianceVo.type) then
            joinType=nil
        else
            needCallback=true
        end
        if needCallback==true then
            local function trim(str) --去掉空格
               return (string.gsub(str, "^%s*(.-)%s*$", "%1"))
            end
            if foreignNotice and tostring(foreignNotice) ~= "" and trim(tostring(foreignNotice)) ~= "" then
                local coolingTime = allianceVoApi:getEditAllianceDescCoolingTime()
                if coolingTime > 0 then
                    G_showTipsDialog(getlocal("edit_alliancedesc_timetip",{GetTimeStr(coolingTime)}))
                    do return end
                end
            end
            socketHelper:allianceEdit(allianceVo.aid,internalNotice,foreignNotice,joinNeedLv,joinNeedFc,joinType,saveCallback)
        else
            self:close()
        end
    end
    local saveItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",saveHandler,2,getlocal("collect_border_save"),25/0.7)
    local saveMenu=CCMenu:createWithItem(saveItem);
    saveItem:setScale(0.8)
    saveMenu:setPosition(ccp(size.width/2,55))
    saveMenu:setTouchPriority(-(layerNum-1)*20-2);
    dialogBg:addChild(saveMenu)

    if coolingTime > 0 then
        local editDescTimeLb = GetTTFLabelWrap(getlocal("edit_alliancedesc_timetip",{GetTimeStr(coolingTime)}),22,CCSizeMake(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
        editDescTimeLb:setAnchorPoint(ccp(0.5,0))
        editDescTimeLb:setPosition(G_VisibleSizeWidth/2,90)
        editDescTimeLb:setColor(G_ColorRed)
        self.bgLayer:addChild(editDescTimeLb,2)
        self.editDescTimeLb = editDescTimeLb
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

function allianceSmallDialog:selectChannelDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callBackHandler,isNewUI)
      local sd=allianceSmallDialog:new()
      local dialog=sd:initSelectChannelDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callBackHandler,isNewUI)
      return sd
end
function allianceSmallDialog:initSelectChannelDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callBackHandler,isNewUI)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local function touchHandler()
    
    end
    self.bgSize=size
    local dialogBg
    self.dialogLayer=CCLayer:create()
    if isNewUI and isNewUI==true then
        dialogBg=G_getNewDialogBg(self.bgSize,getlocal("alliance_send_report"),32,nil,layerNum,true,close)
    else
        dialogBg=LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    end
    
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(size)
    self:show()

    local function touchDialog()
      
    end
	
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()
	
    if isNewUI==nil or isNewUI==false then
        local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
        closeBtnItem:setPosition(ccp(0,0))
        closeBtnItem:setAnchorPoint(CCPointMake(0,0))
         
        self.closeBtn = CCMenu:createWithItem(closeBtnItem)
        self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
        self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
        self.bgLayer:addChild(self.closeBtn,2)
        
        local titleLb=GetTTFLabel(getlocal("alliance_send_report"),40)
        titleLb:setAnchorPoint(ccp(0.5,0.5))
        titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-25))
        dialogBg:addChild(titleLb)
    end
	
    local btnPic,btnDownPic="BtnRecharge.png","BtnRecharge_Down.png"
    if isNewUI and isNewUI==true then
        btnPic,btnDownPic="creatRoleBtn.png","creatRoleBtn_Down.png"
    end
    local function sendReportHandler(tag,object)
         PlayEffect(audioCfg.mouseClick)
         if callBackHandler~=nil then
            callBackHandler(tag,object)
         end
         self:close()
    end
    local worldItem=GetButtonItem(btnPic,btnDownPic,btnPic,sendReportHandler,1,getlocal("alliance_send_channel_1"),25)
    local worldMenu=CCMenu:createWithItem(worldItem);
    worldMenu:setPosition(ccp(size.width/2,190))
    worldMenu:setTouchPriority(-(layerNum-1)*20-2);
    dialogBg:addChild(worldMenu)
    --[[
    local function sendToAllianceHandler(tag,object)
         PlayEffect(audioCfg.mouseClick)
         if callBackHandler~=nil then
            callBackHandler(tag)
         end
         self:close()
    end
    ]]
    local allianceItem=GetButtonItem(btnPic,btnDownPic,btnPic,sendReportHandler,3,getlocal("alliance_send_channel_2"),25)
    local allianceMenu=CCMenu:createWithItem(allianceItem);
    allianceMenu:setPosition(ccp(size.width/2,90))
    allianceMenu:setTouchPriority(-(layerNum-1)*20-2);
    dialogBg:addChild(allianceMenu)

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

function allianceSmallDialog:allianceDonateDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,callBackHandler,resType,sid)
    -- print("sid ======== ",sid)
    self.isTouch=false
    self.isUseAmi=isuseami

    local function close( ... )
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local dialogBg = G_getNewDialogBg(size,getlocal("donateBorderTitle"),32,nil,layerNum,true,close)
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
    
    base:addNeedRefresh(self)

    local function touchTip()
        local tabStr= {}
        for i=1,4 do
            table.insert(tabStr,getlocal("alliance_skillNotice"..i))
        end
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
    end
    G_addMenuInfo(self.bgLayer,layerNum,ccp(self.bgSize.width-50,self.bgSize.height-115),{},nil,nil,28,touchTip,true)

    --科技id
    local skillId=tonumber(sid) or 0
    --哪一种资源
    local resIndex=1
    if resType==1 then
        resIndex=5
    else
        resIndex=resType-1
    end
    --第几次捐献
    local key=resIndex
    if resIndex==5 then
        key="gold"
    else
        key="r"..resIndex
    end
    local donateNum=allianceVoApi:getDonateCount(key)
    local donateMaxNum=allianceVoApi:getDonateMaxNum()
    local donateIndex=donateNum+1
    if donateIndex>donateMaxNum then
        donateIndex=donateMaxNum
    end
    local rewardCfg=playerCfg.allianceDonate[donateIndex]
    if skillId==SizeOfTable(allianceSkillCfg) then
        rewardCfg=playerCfg.zijinDonate[donateIndex]
    end
    --local rewardCfg=playerCfg.allianceDonate[donateIndex]
    local donateRes=playerCfg.allianceDonateResources[donateIndex]
    local donateGems=playerCfg.allianceDonateGold[donateIndex]

    if self.refreshData==nil then
        self.refreshData={}
    end
    self.refreshData.sid=skillId
    --self.refreshData.donateNum=donateNum

    local resName,resPic=getItem(key,"u")

    local donateNumLable=GetTTFLabelWrap(getlocal("alliance_donateCount",{resName,donateNum,donateMaxNum}),28,CCSizeMake(28*15,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    donateNumLable:setAnchorPoint(ccp(0.5,0.5))
    donateNumLable:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-115))
    self.bgLayer:addChild(donateNumLable,1)
    self.refreshData.donateNumLable=donateNumLable
    donateNumLable:setColor(G_ColorYellowPro2)
    --[[
    local skillNoticeLable1=GetTTFLabel(getlocal("alliance_skillNotice1"),22)
    -- local skillNoticeLable1=GetTTFLabelWrap(getlocal("alliance_skillNotice"),25,CCSize(self.bgSize.width-80,200),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    skillNoticeLable1:setAnchorPoint(ccp(0.5,1))
    skillNoticeLable1:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-128))
    self.bgLayer:addChild(skillNoticeLable1,1)
    self.refreshData.skillNoticeLable1=skillNoticeLable1

    local skillNoticeLable2=GetTTFLabel(getlocal("alliance_skillNotice2"),22)
    -- local skillNoticeLable2=GetTTFLabelWrap(getlocal("alliance_skillNotice"),25,CCSize(self.bgSize.width-80,200),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    skillNoticeLable2:setAnchorPoint(ccp(0.5,1))
    skillNoticeLable2:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-153))
    self.bgLayer:addChild(skillNoticeLable2,1)
    self.refreshData.skillNoticeLable2=skillNoticeLable2
    ]]
    local rect = CCRect(0, 0, 50, 50)
    local capInSet = CCRect(15, 15, 2, 2)
    local function touch(hd,fn,idx)

    end
    --资源捐献
    local backSprie1 =LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",capInSet,touch)
    backSprie1:setContentSize(CCSizeMake(self.bgSize.width-40, 300))
    backSprie1:ignoreAnchorPointForPosition(false)
    backSprie1:setAnchorPoint(ccp(0.5,0))
    backSprie1:setIsSallow(false)
    backSprie1:setTouchPriority(-(layerNum-1)*20-1)
    self.bgLayer:addChild(backSprie1,1)
    backSprie1:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-backSprie1:getContentSize().height-135-10))
    self.backSprie1=backSprie1


    local resIcon = CCSprite:createWithSpriteFrameName(resPic)
    resIcon:setPosition(ccp(resIcon:getContentSize().width/2+10,backSprie1:getContentSize().height-resIcon:getContentSize().height/2-20))
    backSprie1:addChild(resIcon,1)

    
    
    local needRes=donateRes
    local requestLable=GetTTFLabel(getlocal("donateRequest")..FormatNumber(needRes),28,true)
    requestLable:setAnchorPoint(ccp(0,1))
    requestLable:setPosition(ccp(resIcon:getContentSize().width+20,backSprie1:getContentSize().height-20))
    backSprie1:addChild(requestLable,1)
    self.refreshData.requestLable=requestLable

    local hasRes=0
    if playerVo[key] and tonumber(playerVo[key]) then
        hasRes=tonumber(playerVo[key])
    end
    local hasResLable=GetTTFLabel(getlocal("nowOwned")..FormatNumber(hasRes),28,true)
    hasResLable:setAnchorPoint(ccp(0,1))
    hasResLable:setPosition(ccp(resIcon:getContentSize().width+20,backSprie1:getContentSize().height-85))
    backSprie1:addChild(hasResLable,1)
    if hasRes-needRes<0 then
        hasResLable:setColor(G_ColorRed)
    end
    self.refreshData.resType=key
    self.refreshData.hasResLable=hasResLable

    local lineSprite = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
    lineSprite:setContentSize(CCSizeMake(backSprie1:getContentSize().width-10, 2))
    lineSprite:setAnchorPoint(ccp(0.5,0.5))
    lineSprite:setPosition(ccp(backSprie1:getContentSize().width/2,175))
    backSprie1:addChild(lineSprite,1)
    -- lineSprite:setScaleX(0.8)
    self:refreshDonateRewardsView(1,rewardCfg)

    local function donateHandler(tag,object)
        PlayEffect(audioCfg.mouseClick)
        -- if allianceVoApi:isJoinFirstDay()==true then
        --     smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("todaynotallow"),true,layerNum+1)
        --     do return end
        -- end
        if allianceVoApi:isCanDonate()==false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage8058"),30)
            do return end
        end

        if not allianceVoApi:isOverstep24Hours( ) then
            G_showTipsDialog(getlocal("joinTimeNotEnough"))
            do return end
        end
        
        if playerVo[key] and tonumber(playerVo[key]) then
            -- local donateNum=self.refreshData.donateNum
            local donateNum=allianceVoApi:getDonateCount(key)
            local donateMaxNum=allianceVoApi:getDonateMaxNum()
            local donateIndex=donateNum+1

            if donateIndex>donateMaxNum then
                donateIndex=donateMaxNum
            end
            local donateRes=playerCfg.allianceDonateResources[donateIndex]
            local diffRes=tonumber(playerVo[key])-donateRes
            if diffRes>=0 then
                local aid=playerVoApi:getPlayerAid()
                local sid=skillId
                local count=donateIndex
                local consumeType=1
                local rname=key
                local lastSkillLv=0
                if allianceSkillCfg[sid] and allianceSkillCfg[sid].sid=="22" then
                    lastSkillLv=allianceSkillVoApi:getSkillLevel(allianceSkillCfg[sid].sid)
                elseif allianceSkillCfg[sid] and allianceSkillCfg[sid].sid == "24" then
                    lastSkillLv = allianceSkillVoApi:getSkillLevel(allianceSkillCfg[sid].sid)
                elseif sid == 0 then
                    local selfAlliance = allianceVoApi:getSelfAlliance()
                    if selfAlliance then
                        lastSkillLv = selfAlliance.level
                    end
                end
                local function allianceDonateCallback(fn,data)
                    local ret,sData=base:checkServerData(data)
                    if ret==true then
                        local alliance=allianceVoApi:getSelfAlliance()
                        local lastDonateTime=alliance.lastDonateTime

                        local point=sData.data.point
                        local donateTime=sData.data.raising_at
                        local totalDonate=sData.data.raising
                        local weekDonate=sData.data.weekraising
                        local skill={}
                        local level=0
                        local exp=0
                        if sData.data.alliance then
                            if sData.data.alliance.skills then
                                skill=sData.data.alliance.skills
                                for m,n in pairs(skill) do
                                    sid=tonumber(m) or tonumber(RemoveFirstChar(m))
                                    level=tonumber(n[1]) or 0
                                    exp=tonumber(n[2]) or 0
                                end
                            else
                                skill=sData.data.alliance
                                level=tonumber(skill.level) or 0
                                exp=tonumber(skill.level_point) or 0
                            end
                        end

                        local oldLevel
                        local selfAlliance=allianceVoApi:getSelfAlliance()
                        local oldMaxnum=selfAlliance.maxnum
                        if sid==0 then 
                            oldLevel=selfAlliance.level
                        else
                            oldLevel=allianceSkillVoApi:getSkillLevel(sid)
                        end
                        playerVoApi:setValue(key,diffRes)
                        local rewardCfg=playerCfg.allianceDonate[donateIndex]
                        if skillId==SizeOfTable(allianceSkillCfg) then
                            rewardCfg=playerCfg.zijinDonate[donateIndex]
                        end
                        local rewardStr=""
                        local params={}
                        local uid=playerVoApi:getUid()
                        params[1]=uid

                        local playerHonors =playerVoApi:getHonors() --用户当前的总声望值
                        local maxLevel =playerVoApi:getMaxLvByKey("roleMaxLevel") --当前服 最大等级
                        local honTb =Split(playerCfg.honors,",")
                        local maxHonors =honTb[maxLevel] --当前服 最大声望值

                        for k,v in pairs(rewardCfg) do
                            local name=""
                            if k==1 then        --科技
                                name=getlocal("alliance_skill")
                                for m,n in pairs(skill) do
                                    -- local sid=tonumber(m) or tonumber(RemoveFirstChar(m))
                                    -- local level=0
                                    -- local exp=0
                                    if sid==0 then
                                        -- level=tonumber(n.level) or 0
                                        -- exp=tonumber(n.level_point) or 0
                                        allianceVoApi:setAllianceLevel(level)
                                        allianceVoApi:setAllianceExp(exp)
                                    else
                                        -- level=tonumber(n[1]) or 0
                                        -- exp=tonumber(n[2]) or 0
                                        allianceSkillVoApi:setSkillLevel(sid,level)
                                        allianceSkillVoApi:setSkillExp(sid,exp)
                                    end
                                    params[4]=sid
                                    params[5]=level
                                    params[6]=exp
                                end
                            elseif k==2 then    --贡献
                                -- allianceMemberVoApi:addDonate(uid,v)
                                -- params[2]=allianceMemberVoApi:getDonate(uid)
                                -- params[3]=allianceMemberVoApi:getWeekDonate(uid)
                                allianceMemberVoApi:setDonate(uid,totalDonate)
                                allianceMemberVoApi:setWeekDonate(uid,donateTime,weekDonate)
                                params[2]=totalDonate
                                params[3]=weekDonate
                                params[7]=donateTime
                                name=getlocal("alliance_contribution")
                            elseif k==3 then    --声望
                                    if base.isConvertGems==1 and tonumber(playerHonors) >=tonumber(maxHonors) then
                                        name = getlocal("money")
                                        playerVoApi:setValue("gold",playerVoApi:getGold()+playerVoApi:convertGems(2,tonumber(v)))
                                    else
                                        playerVoApi:setValue("honors",playerVoApi:getHonors()+v)
                                        name=getItem("honors","u")
                                    end
                            elseif k==4 then    --荣誉勋章
                                if v and v>0 then
                                    bagVoApi:addBag(19,v)
                                end
                                name=getItem("p19","p")
                            elseif k==5 then    --军功
                                name=getlocal("alliance_medals")
                            elseif k==6 then    --军团资金
                                name=getlocal("alliance_funds")
                            end
                            local num = v
                            if base.isConvertGems==1 and tonumber(playerHonors) >=tonumber(maxHonors) and k== 3 then
                                num =playerVoApi:convertGems(2,tonumber(v))
                            end
                            
                            if (lastDonateTime and G_isToday(lastDonateTime)==false) and (donateTime and G_isToday(donateTime)==true) and (k==1 or k==2 or k==6) and alliance.alevel and allianceActiveCfg.ActiveDonateCount[alliance.alevel]>1 then
                                num=num*allianceActiveCfg.ActiveDonateCount[alliance.alevel]
                            end
                            

                            if v>0 then
                                if rewardStr=="" then
                                    rewardStr=getlocal("daily_lotto_tip_10")..name.." x"..num
                                else
                                    rewardStr=rewardStr..","..name.." x"..num
                                end
                            end
                        end
                        if point then
                            params[8]=point
                            local updateData={point=point}
                            allianceVoApi:formatSelfAllianceData(updateData)
                        end
                        --self.refreshData.donateNum=donateNum+1
                        -- allianceVoApi:setLastDonateTime(donateTime)
                        -- allianceVoApi:setDonateCount(key)
                        allianceVoApi:donateRefreshData(donateTime,key)
                        allianceVoApi:apointRefreshData(1,sData.data)
                        chatVoApi:sendUpdateMessage(9,params,aid+1)

                        self:refreshDonateDialog()
                        G_isRefreshAllianceMemberTb=true
                        local function showTip1()
                            if rewardStr~="" then
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),rewardStr,28)
                            end
                        end
                        local function showTip2()
                            if level>oldLevel then
                                if sid==0 then
                                    local newAlliance=allianceVoApi:getSelfAlliance()
                                    local newMaxnum=newAlliance.maxnum
                                    local isUnlockSkill=false
                                    for k,v in pairs(allianceSkillCfg) do
                                        if tostring(v.allianceUnlockLevel)==tostring(level) then
                                            isUnlockSkill=true
                                        end
                                    end
                                    local tipStr=""
                                    tipStr=getlocal("alliance_levelup",{level})
                                    if newMaxnum>oldMaxnum then
                                        tipStr=tipStr..","..getlocal("alliance_levelup_unlock_maxnum")
                                        -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_levelup_unlock_maxnum",{level}),28)
                                    end
                                    if isUnlockSkill then
                                        tipStr=tipStr..","..getlocal("alliance_levelup_unlock_newskill")
                                        -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_levelup_unlock_newskill",{level}),28)
                                    end
                                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,28)
                                else
                                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_levelup_skill",{getlocal(allianceSkillCfg[sid].name),level}),28)
                                end
                            end
                        end
                        local callFunc1=CCCallFuncN:create(showTip1)
                        local delay=CCDelayTime:create(0.5)
                        local callFunc2=CCCallFuncN:create(showTip2)
                        local acArr=CCArray:create()
                        acArr:addObject(callFunc1)
                        acArr:addObject(delay)
                        acArr:addObject(callFunc2)
                        local seq=CCSequence:create(acArr)
                        self.bgLayer:runAction(seq)
                        local vo = activityVoApi:getActivityVo("fundsRecruit")
                        if vo~=nil and activityVoApi:isStart(vo)==true then
                            acFundsRecruitVoApi:updateAllianceDonateCount(1)
                        end
                        if allianceSkillCfg[sid] and allianceSkillCfg[sid].sid=="22" then --如果是“城市等级”的科技，则通知刷新世界地图军团城市等级
                            local curlv=allianceSkillVoApi:getSkillLevel(allianceSkillCfg[sid].sid)
                            if curlv>lastSkillLv then --等级发生变化
                                allianceCityVoApi:refreshWorldMapCity(curlv)
                            end
                        elseif allianceSkillCfg[sid] and allianceSkillCfg[sid].sid == "24" then -- 军旗品质等级变化并解锁旗帜通知军团
                            local curlv = allianceSkillVoApi:getSkillLevel(allianceSkillCfg[sid].sid)
                            allianceVoApi:checkUnlockState(3, lastSkillLv, curlv)
                        elseif sid == 0 then -- 军团等级变化并解锁旗帜通知军团
                            local curlv = 0
                            local selfAlliance = allianceVoApi:getSelfAlliance()
                            if selfAlliance then
                                curlv = selfAlliance.level
                            end
                            allianceVoApi:checkUnlockState(1, lastSkillLv, curlv)
                        end
                    end
                end
                local ssid
                if sid==0 then
                    ssid="alliance"
                else
                    if tonumber(sid)==SizeOfTable(allianceSkillCfg) then
                        ssid="s99"
                    else
                        ssid="s"..sid
                    end
                end
                -- print("ssid ========= ",ssid)
                socketHelper:allianceDonate(aid,ssid,count,consumeType,rname,allianceDonateCallback)
            end
        end
        -- if callBackHandler~=nil then
        --     callBackHandler(tag,object)
        -- end
    end
    local donateItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",donateHandler,1,getlocal("donateBorderTitle"),30)
    donateItem:setScale(0.8)
    local donateMenu=CCMenu:createWithItem(donateItem)
    donateMenu:setPosition(ccp(backSprie1:getContentSize().width-donateItem:getContentSize().width/2-10,backSprie1:getContentSize().height-60))
    donateMenu:setTouchPriority(-(layerNum-1)*20-2)
    backSprie1:addChild(donateMenu)

    if hasRes-needRes<0 or donateNum>=donateMaxNum then
        donateItem:setEnabled(false)
    end
    local selfAlliance=allianceVoApi:getSelfAlliance()
    if selfAlliance then
        if sid==0 then
            if selfAlliance.level>=allianceVoApi:getMaxLevel() and selfAlliance.exp>=allianceVoApi:getMaxExp() then
                donateItem:setEnabled(false)
            end
        else
            if allianceSkillVoApi:getSkillLevel(sid)>=allianceSkillVoApi:getSkillMaxLevel(sid) and allianceSkillVoApi:getSkillExp(sid)>=allianceSkillVoApi:getSkillMaxExp(sid) then
                donateItem:setEnabled(false)
            end
        end
    else
        donateItem:setEnabled(false)
    end
    self.refreshData.donateItem=donateItem

    --金币捐献
    local backSprie2 = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",capInSet,touch)
    backSprie2:setContentSize(CCSizeMake(self.bgSize.width-40, 300))
    backSprie2:ignoreAnchorPointForPosition(false)
    backSprie2:setAnchorPoint(ccp(0.5,0))
    backSprie2:setIsSallow(false)
    backSprie2:setTouchPriority(-(layerNum-1)*20-1)
    self.bgLayer:addChild(backSprie2,1)
    backSprie2:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-backSprie1:getContentSize().height-backSprie2:getContentSize().height-150-10))
    self.backSprie2=backSprie2

    local gemName,gemPic=getItem("gem","u")
    local gemIcon = CCSprite:createWithSpriteFrameName(gemPic)
    gemIcon:setPosition(ccp(gemIcon:getContentSize().width/2+10,backSprie2:getContentSize().height-gemIcon:getContentSize().height/2-20))
    backSprie2:addChild(gemIcon,1)

    local needGems=donateGems
    local requestGemsLable=GetTTFLabel(getlocal("donateRequest")..FormatNumber(needGems),28,true)
    requestGemsLable:setAnchorPoint(ccp(0,1))
    requestGemsLable:setPosition(ccp(gemIcon:getContentSize().width+20,backSprie2:getContentSize().height-20))
    backSprie2:addChild(requestGemsLable,1)
    self.refreshData.requestGemsLable=requestGemsLable

    local hasGems=playerVoApi:getGems()
    local hasGemsLable=GetTTFLabel(getlocal("nowOwned")..FormatNumber(hasGems),28,true)
    hasGemsLable:setAnchorPoint(ccp(0,1))
    hasGemsLable:setPosition(ccp(gemIcon:getContentSize().width+20,backSprie2:getContentSize().height-85))
    backSprie2:addChild(hasGemsLable,1)
    if hasGems-needGems<0 then
        hasGemsLable:setColor(G_ColorRed)
    end
    if self.refreshData==nil then
        self.refreshData={}
    end
    self.refreshData.hasGemsLable=hasGemsLable

    local lineSprite2 = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine5.png", CCRect(4, 0, 2, 2), function ()end)
    lineSprite2:setContentSize(CCSizeMake(backSprie2:getContentSize().width-10,2))
    lineSprite2:setAnchorPoint(ccp(0.5,0.5))
    lineSprite2:setPosition(ccp(backSprie2:getContentSize().width/2,175))
    backSprie2:addChild(lineSprite2,1)

    --刷新金币捐献页面
    self:refreshDonateRewardsView(2,rewardCfg)

    local function donateGemHandler(tag,object)
        PlayEffect(audioCfg.mouseClick)
        -- if allianceVoApi:isJoinFirstDay()==true then
        --     smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("todaynotallow"),true,layerNum+1)
        --     do return end
        -- end
        if allianceVoApi:isCanDonate()==false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage8058"),30)
            do return end
        end
        local vipRelatedCfg=playerCfg.vipRelatedCfg or {}
        local createAllianceGems=vipRelatedCfg.createAllianceGems or {}
        local vipNeed = createAllianceGems[1] or 1
        if playerVoApi:getVipLevel() < vipNeed then
            local function togoRecharge()
                vipVoApi:showRechargeDialog(layerNum+1)
            end
            smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),togoRecharge,getlocal("dialog_title_prompt"),getlocal("donate_need_vip",{vipNeed}),true,layerNum+1,nil,nil,nil,getlocal("buy"))
            do return end
        end

        if not allianceVoApi:isOverstep24Hours( ) then
            G_showTipsDialog(getlocal("joinTimeNotEnough"))
            do return end
        end

        local donateNum=allianceVoApi:getDonateCount(key)
        local donateMaxNum=allianceVoApi:getDonateMaxNum()
        local donateIndex=donateNum+1
        if donateIndex>donateMaxNum then
            donateIndex=donateMaxNum
        end
        local donateGems=playerCfg.allianceDonateGold[donateIndex]
        local diffGems=playerVoApi:getGems()-donateGems
        if diffGems>=0 then
            local aid=playerVoApi:getPlayerAid()
            local sid=skillId
            local count=donateIndex
            local consumeType=2
            local rname=key
            local lastSkillLv=0
            if allianceSkillCfg[sid] and allianceSkillCfg[sid].sid=="22" then
                lastSkillLv=allianceSkillVoApi:getSkillLevel(allianceSkillCfg[sid].sid)
            elseif allianceSkillCfg[sid] and allianceSkillCfg[sid].sid == "24" then
                lastSkillLv = allianceSkillVoApi:getSkillLevel(allianceSkillCfg[sid].sid)
            elseif sid == 0 then
                local selfAlliance = allianceVoApi:getSelfAlliance()
                if selfAlliance then
                    lastSkillLv = selfAlliance.level
                end
            end
            local function allianceGemsDonateCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    local alliance=allianceVoApi:getSelfAlliance()
                    local lastDonateTime=alliance.lastDonateTime

                    local point=sData.data.point
                    local donateTime=sData.data.raising_at
                    local totalDonate=sData.data.raising
                    local weekDonate=sData.data.weekraising
                    local skill={}
                    local level=0
                    local exp=0
                    if sData.data.alliance then
                        if sData.data.alliance.skills then
                            skill=sData.data.alliance.skills
                            for m,n in pairs(skill) do
                                sid=tonumber(m) or tonumber(RemoveFirstChar(m))
                                level=tonumber(n[1]) or 0
                                exp=tonumber(n[2]) or 0
                            end
                        else
                            skill=sData.data.alliance
                            level=tonumber(skill.level) or 0
                            exp=tonumber(skill.level_point) or 0
                        end
                    end

                    local oldLevel
                    local selfAlliance=allianceVoApi:getSelfAlliance()
                    local oldMaxnum=selfAlliance.maxnum
                    if sid==0 then 
                        oldLevel=selfAlliance.level
                    else
                        oldLevel=allianceSkillVoApi:getSkillLevel(sid)
                    end
                    --playerVoApi:useResource(0,0,0,0,0,needGems)
                    playerVoApi:setValue("gems",diffGems)
                    local rewardCfg=playerCfg.allianceDonate[donateIndex]
                    if skillId==SizeOfTable(allianceSkillCfg) then
                        rewardCfg=playerCfg.zijinDonate[donateIndex]
                    end
                    local rewardStr=""
                    local params={}
                    local uid=playerVoApi:getUid()
                    params[1]=uid

                    local playerHonors =playerVoApi:getHonors() --用户当前的总声望值
                    local maxLevel =playerVoApi:getMaxLvByKey("roleMaxLevel") --当前服 最大等级
                    local honTb =Split(playerCfg.honors,",")
                    local maxHonors =honTb[maxLevel] --当前服 最大声望值     
                                   
                    for k,v in pairs(rewardCfg) do
                        local name=""
                        local num=0
                        if k==1 then        --科技
                            name=getlocal("alliance_skill")
                            num=v*2
                            if(activityVoApi:checkActivityEffective("allianceDonate"))then
                                num=num*(1+activityCfg.allianceDonate.serverreward.percent)
                            end
                            for m,n in pairs(skill) do
                                -- local sid=tonumber(m) or tonumber(RemoveFirstChar(m))
                                -- local level=0
                                -- local exp=0
                                if sid==0 then
                                    -- level=tonumber(n.level) or 0
                                    -- exp=tonumber(n.level_point) or 0
                                    allianceVoApi:setAllianceLevel(level)
                                    allianceVoApi:setAllianceExp(exp)
                                else
                                    -- level=tonumber(n[1]) or 0
                                    -- exp=tonumber(n[2]) or 0
                                    allianceSkillVoApi:setSkillLevel(sid,level)
                                    allianceSkillVoApi:setSkillExp(sid,exp)
                                end
                                params[4]=sid
                                params[5]=level
                                params[6]=exp
                            end
                        elseif k==2 then    --贡献
                            name=getlocal("alliance_contribution")
                            num=v*2
                            if(activityVoApi:checkActivityEffective("allianceDonate"))then
                                num=num*(1+activityCfg.allianceDonate.serverreward.percent)
                            end
                            -- allianceMemberVoApi:addDonate(uid,num)
                            -- params[2]=allianceMemberVoApi:getDonate(uid)
                            -- params[3]=allianceMemberVoApi:getWeekDonate(uid)
                            allianceMemberVoApi:setDonate(uid,totalDonate)
                            allianceMemberVoApi:setWeekDonate(uid,donateTime,weekDonate)
                            params[2]=totalDonate
                            params[3]=weekDonate
                            params[7]=donateTime
                        elseif k==3 then    --声望
                            if base.isConvertGems==1 and tonumber(playerHonors) >=tonumber(maxHonors) then
                                name = getlocal("money")
                                num =playerVoApi:convertGems(2,tonumber(v))
                                playerVoApi:setValue("gold",playerVoApi:getGold()+num)
                            else
                                name=getItem("honors","u")
                                num=v
                                playerVoApi:setValue("honors",playerVoApi:getHonors()+num)
                            end
                        elseif k==4 then    --荣誉勋章
                            name=getItem("p19","p")
                            num=v
                            if num and num>0 then
                                bagVoApi:addBag(19,v)
                            end
                        elseif k==5 then    --军功
                            name=getlocal("alliance_medals")
                            num=v*2
                        elseif k==6 then
                            name=getlocal("alliance_funds")
                            num=v*2
                            if(activityVoApi:checkActivityEffective("allianceDonate"))then
                                num=num*(1+activityCfg.allianceDonate.serverreward.percent)
                            end
                        end

                        if (lastDonateTime and G_isToday(lastDonateTime)==false) and (donateTime and G_isToday(donateTime)==true) and (k==1 or k==2 or k==6) and alliance.alevel and allianceActiveCfg.ActiveDonateCount[alliance.alevel]>1 then
                            num=num*allianceActiveCfg.ActiveDonateCount[alliance.alevel]
                        end
                        if num>0 then
                            if rewardStr=="" then
                                rewardStr=getlocal("daily_lotto_tip_10")..name.." x"..num
                            else
                                rewardStr=rewardStr..","..name.." x"..num
                            end
                        end
                    end
                    if point then
                        params[8]=point
                        local updateData={point=point}
                        allianceVoApi:formatSelfAllianceData(updateData)
                    end
                    --self.refreshData.donateNum=self.refreshData.donateNum+1
                    -- allianceVoApi:setLastDonateTime(donateTime)
                    -- allianceVoApi:setDonateCount(key)
                    allianceVoApi:donateRefreshData(donateTime,key)
                    allianceVoApi:apointRefreshData(1,sData.data)
                    chatVoApi:sendUpdateMessage(9,params,aid+1)

                    self:refreshDonateDialog()
                    G_isRefreshAllianceMemberTb=true
                    local function showTip1()
                        if rewardStr~="" then
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),rewardStr,28)
                        end
                    end
                    local function showTip2()
                        if level>oldLevel then
                            if sid==0 then
                                local newAlliance=allianceVoApi:getSelfAlliance()
                                local newMaxnum=newAlliance.maxnum
                                local isUnlockSkill=false
                                for k,v in pairs(allianceSkillCfg) do
                                    if tostring(v.allianceUnlockLevel)==tostring(level) then
                                        isUnlockSkill=true
                                    end
                                end
                                local tipStr=""
                                tipStr=getlocal("alliance_levelup",{level})
                                if newMaxnum>oldMaxnum then
                                    tipStr=tipStr..","..getlocal("alliance_levelup_unlock_maxnum")
                                    -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_levelup_unlock_maxnum",{level}),28)
                                end
                                if isUnlockSkill then
                                    tipStr=tipStr..","..getlocal("alliance_levelup_unlock_newskill")
                                    -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_levelup_unlock_newskill",{level}),28)
                                end
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tipStr,28)
                            else
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_levelup_skill",{getlocal(allianceSkillCfg[sid].name),level}),28)
                            end
                        end
                    end
                    local callFunc1=CCCallFuncN:create(showTip1)
                    local delay=CCDelayTime:create(0.5)
                    local callFunc2=CCCallFuncN:create(showTip2)
                    local acArr=CCArray:create()
                    acArr:addObject(callFunc1)
                    acArr:addObject(delay)
                    acArr:addObject(callFunc2)
                    local seq=CCSequence:create(acArr)
                    self.bgLayer:runAction(seq)
                    
                     local vo = activityVoApi:getActivityVo("fundsRecruit")
                    if vo~=nil and activityVoApi:isStart(vo)==true then
                        acFundsRecruitVoApi:updateAllianceDonateCount(1)
                        acFundsRecruitVoApi:updateGoldDonateCount(1)
                    end
                    if allianceSkillCfg[sid] and allianceSkillCfg[sid].sid=="22" then --如果是“城市等级”的科技，则通知刷新世界地图军团城市等级
                        local curlv=allianceSkillVoApi:getSkillLevel(allianceSkillCfg[sid].sid)
                        if curlv>lastSkillLv then --等级发生变化
                            allianceCityVoApi:refreshWorldMapCity(curlv)
                        end
                    elseif allianceSkillCfg[sid] and allianceSkillCfg[sid].sid == "24" then -- 军旗品质等级变化并解锁旗帜通知军团
                        local curlv = allianceSkillVoApi:getSkillLevel(allianceSkillCfg[sid].sid)
                        allianceVoApi:checkUnlockState(3, lastSkillLv, curlv)
                    elseif sid == 0 then -- 军团等级变化并解锁旗帜通知军团
                        local curlv = 0
                        local selfAlliance = allianceVoApi:getSelfAlliance()
                        if selfAlliance then
                            curlv = selfAlliance.level
                        end
                        allianceVoApi:checkUnlockState(1, lastSkillLv, curlv)
                    end
                end
            end
            local ssid
            if sid==0 then
                ssid="alliance"
            else
                if tonumber(sid)==SizeOfTable(allianceSkillCfg) then
                    ssid="s99"
                else
                    ssid="s"..sid
                end                
            end
            socketHelper:allianceDonate(aid,ssid,count,consumeType,rname,allianceGemsDonateCallback)
        else
            GemsNotEnoughDialog(nil,nil,0-diffGems,layerNum+1,donateGems)
        end
        -- if callBackHandler~=nil then
        --    callBackHandler(tag,object)
        -- end
    end
    local donateGemItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",donateGemHandler,1,getlocal("donateBorderTitle"),30)
    donateGemItem:setScale(0.8)
    local donateGemMenu=CCMenu:createWithItem(donateGemItem)
    donateGemMenu:setPosition(ccp(backSprie2:getContentSize().width-donateItem:getContentSize().width/2-10,backSprie2:getContentSize().height-60))
    donateGemMenu:setTouchPriority(-(layerNum-1)*20-2)
    backSprie2:addChild(donateGemMenu)
    if donateNum>=donateMaxNum then
        donateGemItem:setEnabled(false)
    end
    if selfAlliance then
        if sid==0 then
            if selfAlliance.level>=allianceVoApi:getMaxLevel() and selfAlliance.exp>=allianceVoApi:getMaxExp() then
                donateGemItem:setEnabled(false)
            end
        else
            if allianceSkillVoApi:getSkillLevel(sid)>=allianceSkillVoApi:getSkillMaxLevel(sid) and allianceSkillVoApi:getSkillExp(sid)>=allianceSkillVoApi:getSkillMaxExp(sid) then
                donateGemItem:setEnabled(false)
            end
        end
    else
        donateGemItem:setEnabled(false)
    end
    self.refreshData.donateGemItem=donateGemItem


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

function allianceSmallDialog:refreshDonateRewardsView(donateType,donateRewardCfg)
    
    local function hasAllianceDonateReward(rewardCfg)
        for i=1,6 do
            if i==1 or i==5 or i==6 then
                if rewardCfg[i]>0 then
                    return true
                end
            end
        end
        return false
    end
    local function hasPersonalDonateReward(rewardCfg)
        for i=1,6 do
            if i==2 or i==3 or i==4 then
                if rewardCfg[i]>0 then
                    return true
                end
            end
        end
        return false
    end
    local parent
    local personalLabelTab
    local allianceLabelTab
    if donateType==1 then
        parent=self.backSprie1
        if self.refreshData.resRewardTable==nil then
            self.refreshData.resRewardTable={}
            self.refreshData.resRewardTable.personalTab={}
            self.refreshData.resRewardTable.allianceTab={}
        end
        personalLabelTab=self.refreshData.resRewardTable.personalTab
        allianceLabelTab=self.refreshData.resRewardTable.allianceTab
    elseif donateType==2 then
        parent=self.backSprie2
       if self.refreshData.gemsRewardTable==nil then
            self.refreshData.gemsRewardTable={}
            self.refreshData.gemsRewardTable.personalTab={}
            self.refreshData.gemsRewardTable.allianceTab={}
        end
        personalLabelTab=self.refreshData.gemsRewardTable.personalTab
        allianceLabelTab=self.refreshData.gemsRewardTable.allianceTab
    end
    local curHeight=165
    local hasAllianceReward=hasAllianceDonateReward(donateRewardCfg)
    if hasAllianceReward==true then
        local rewardLabel
        if donateType==1 then
            if self.allianceRewardLabel==nil then
                self.allianceRewardLabel=GetTTFLabel(getlocal("alliance_reward_title2"),25,true)
                self.allianceRewardLabel:setAnchorPoint(ccp(0,1))
                self.allianceRewardLabel:setPosition(ccp(10,curHeight))
                self.allianceRewardLabel:setColor(G_ColorYellowPro2)
                parent:addChild(self.allianceRewardLabel,1)
            end
        elseif donateType==2 then
            if self.gemAllianceRewardLabel==nil then
                self.gemAllianceRewardLabel=GetTTFLabel(getlocal("alliance_reward_title2"),25,true)
                self.gemAllianceRewardLabel:setAnchorPoint(ccp(0,1))
                self.gemAllianceRewardLabel:setPosition(ccp(10,curHeight))
                self.gemAllianceRewardLabel:setColor(G_ColorYellowPro2)
                parent:addChild(self.gemAllianceRewardLabel,1)
            end
        end
        curHeight=curHeight-40
        local idx=0
        for k=1,6 do
            if k==1 or k==5 or k==6 then
                local name
                local v=donateRewardCfg[k]
                local num=v
                if k==1 then
                    name=getlocal("alliance_skill")
                    if donateType==2 then
                        num=v*2
                        if(activityVoApi:checkActivityEffective("allianceDonate"))then
                            num=num*(1+activityCfg.allianceDonate.serverreward.percent)
                        end
                    end
                elseif k==5 then
                    name=getlocal("alliance_medals")
                    if donateType==2 then
                        num=v*2
                    end
                elseif k==6 then
                    name=getlocal("alliance_funds")
                    if donateType==2 then
                        num=v*2
                        if(activityVoApi:checkActivityEffective("allianceDonate"))then
                            num=num*(1+activityCfg.allianceDonate.serverreward.percent)
                        end
                    end
                end
                if name and name~="" and v~=0 then
                    idx=idx+1
                    local width = 30+((idx-1)%3)*175  
                    local height = curHeight-(math.floor((idx-1)/3))*40
                    curHeight=height
                    if allianceLabelTab==nil then
                        allianceLabelTab={}
                    end
                    if allianceLabelTab[k]==nil then
                        local txtLabel = GetTTFLabel(name.."+"..num,25,true)
                        txtLabel:setAnchorPoint(ccp(0.5,1))
                        txtLabel:setPosition(ccp(width+txtLabel:getContentSize().width/2,height))
                        parent:addChild(txtLabel,1)
                        table.insert(allianceLabelTab,k,txtLabel)
                    else
                        allianceLabelTab[k]:setString(name.."+"..num)
                        allianceLabelTab[k]:setPosition(ccp(width+allianceLabelTab[k]:getContentSize().width/2,height))
                    end
                end
                if allianceLabelTab[k] then
                    if num<=0 then
                        allianceLabelTab[k]:setVisible(false)
                    end
                end
            end
        end
    end
    local hasPersonalReward=hasPersonalDonateReward(donateRewardCfg)
    if hasPersonalReward==true then
        curHeight=curHeight-40
        if donateType==1 then
            if self.personalRewardLabel==nil then
                self.personalRewardLabel=GetTTFLabel(getlocal("alliance_reward_title1"),25,true)
                self.personalRewardLabel:setAnchorPoint(ccp(0,1))
                self.personalRewardLabel:setPosition(ccp(10,curHeight))
                self.personalRewardLabel:setColor(G_ColorYellowPro2)
                parent:addChild(self.personalRewardLabel,1)
            end
        elseif donateType==2 then
            if self.gemPersonalRewardLabel==nil then
                self.gemPersonalRewardLabel=GetTTFLabel(getlocal("alliance_reward_title1"),25,true)
                self.gemPersonalRewardLabel:setAnchorPoint(ccp(0,1))
                self.gemPersonalRewardLabel:setPosition(ccp(10,curHeight))
                self.gemPersonalRewardLabel:setColor(G_ColorYellowPro2)
                parent:addChild(self.gemPersonalRewardLabel,1)
            end
        end
        curHeight=curHeight-40
        local idx=0
        for k=1,6 do
            if k==2 or k==3 or k==4 then
                local name
                local v=donateRewardCfg[k]
                local num=v
                if k==2 then
                    name=getlocal("alliance_contribution")
                    if donateType==2 then
                        num=v*2
                        if(activityVoApi:checkActivityEffective("allianceDonate"))then
                            num=num*(1+activityCfg.allianceDonate.serverreward.percent)
                        end
                    end
                elseif k==3 then
                    name=getItem("honors","u")
                elseif k==4 then
                    name=getItem("p19","p")
                end
                if name and name~="" and v~=0 then
                    idx=idx+1
                    local width = 30+((idx-1)%3)*175  
                    local height = curHeight-(math.floor((idx-1)/3))*40
                    curHeight=height
                    if personalLabelTab==nil then
                        personalLabelTab={}
                    end
                    if personalLabelTab[k]==nil then
                        local txtLabel = GetTTFLabel(name.."+"..num,25,true)
                        txtLabel:setAnchorPoint(ccp(0.5,1))
                        txtLabel:setPosition(ccp(width+txtLabel:getContentSize().width/2,height))
                        parent:addChild(txtLabel,1)
                        table.insert(personalLabelTab,k,txtLabel)
                    else
                        personalLabelTab[k]:setString(name.."+"..num)
                        personalLabelTab[k]:setPosition(ccp(width+personalLabelTab[k]:getContentSize().width/2,height))
                    end
                end
                if personalLabelTab[k] then
                    if num<=0 then
                        personalLabelTab[k]:setVisible(false)
                    end
                end
            end
        end
    end
end

function allianceSmallDialog:showHelpDefendDialog(bgSrc,size,fullRect,inRect,istouch,isuseami,title,layerNum)
      local sd=allianceSmallDialog:new()
      local dialog=sd:initShowHelpDefendDialog(bgSrc,size,fullRect,inRect,istouch,isuseami,title,layerNum)
      return sd
end
function allianceSmallDialog:initShowHelpDefendDialog(bgSrc,size,fullRect,inRect,istouch,isuseami,title,layerNum)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function tmpFunc()

    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,tmpFunc)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgSize=size
    self.bgLayer:setContentSize(size)

    self:show()

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

    local titleLb=GetTTFLabel(title,40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)

    base:addNeedRefresh(self)
    if self.refreshData==nil then
        self.refreshData={}
    end

    local helpDefendAll=helpDefendVoApi:getHelpDefendAll()

    local defendCountLabel=GetTTFLabel(getlocal("coverCount",{SizeOfTable(helpDefendAll),helpDefendVoApi:getMaxNum()}),25)
    defendCountLabel:setAnchorPoint(ccp(0,0.5))
    defendCountLabel:setPosition(ccp(30,size.height-112))
    dialogBg:addChild(defendCountLabel,2)
    self.refreshData.defendCountLabel=defendCountLabel
    self.refreshData.countdownTab={}

    local function tipTouch()
        local sd=smallDialog:new()
        local dialogLayer=sd:init("TankInforPanel.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,layerNum+1,{" ",getlocal("help_defend_tip4")," ",getlocal("help_defend_tip3")," ",getlocal("help_defend_tip2")," ",getlocal("help_defend_tip1")," "},25,{nil,G_ColorYellow,nil,G_ColorYellow,nil,G_ColorYellow,nil,G_ColorYellow,nil})
        sceneGame:addChild(dialogLayer,layerNum+1)
        dialogLayer:setPosition(ccp(0,0))
    end
    local tipItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",tipTouch,11,nil,nil)
    tipItem:setScale(0.6)
    local tipMenu = CCMenu:createWithItem(tipItem)
    tipMenu:setPosition(ccp(self.bgSize.width-80,self.bgSize.height-112))
    tipMenu:setTouchPriority(-(layerNum-1)*20-3)
    self.bgLayer:addChild(tipMenu,1)

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            local num=helpDefendVoApi:getHelpDefendNum()
            return num
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

            local helpDefendAll=helpDefendVoApi:getHelpDefendAll()
            if helpDefendAll and helpDefendAll[idx+1]==nil then
                do return  end
            end
            local helpDefendVo=helpDefendAll[idx+1]
            if helpDefendVo==nil then
                do return  end
            end

            local function touch()
            end
            local bgName="panelItemBg.png"
            local capInSet = CCRect(20, 20, 10, 10)
            if helpDefendVo.status==2 then
                bgName="CorpsLevel.png"
                capInSet = CCRect(65, 25, 1, 1)
            end
            local bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName(bgName,capInSet,touch)
            bgSprie:setContentSize(CCSizeMake(cellWidth,cellHeight-5))
            bgSprie:setPosition(ccp(cellWidth/2,cellHeight/2))
            bgSprie:setIsSallow(false)
            bgSprie:setTouchPriority(-(layerNum-1)*20-2)
            cell:addChild(bgSprie,1)
        
            local icon=CCSprite:createWithSpriteFrameName("IconHelp.png")
            icon:setAnchorPoint(ccp(0,0.5))
            icon:setPosition(ccp(10,cellHeight/2-5))
            icon:setScaleX(0.75)
            icon:setScaleY(0.75)
            bgSprie:addChild(icon,2)
        
            local height=bgSprie:getContentSize().height-10
            local width=icon:getContentSize().width-10

            -- local nameStr=helpDefendVo.attackerName
            -- local nameLabel
            -- if helpDefendVo.islandType==6 then
            --     nameLabel=GetTTFLabel(getlocal("enemyComingPlayer",{nameStr}),28)
            -- else
            --     nameLabel=GetTTFLabel(getlocal("enemyComingIslands",{nameStr}),28)
            -- end
            local nameStr=helpDefendVo.name
            local nameLabel=GetTTFLabel(nameStr,28)
            nameLabel:setAnchorPoint(ccp(0,1))
            nameLabel:setPosition(ccp(width,height-10))
            bgSprie:addChild(nameLabel,2)
            nameLabel:setColor(G_ColorWhite)
            if self.refreshData.nameTab==nil then
                self.refreshData.nameTab={}
            end
            self.refreshData.nameTab[idx+1]={nameLabel=nameLabel}
            
            --[[
            -- local locationLabel=GetTTFLabel(getlocal("city_info_coordinate")..":"..getlocal("city_info_coordinate_style",{helpDefendVo.place[1],helpDefendVo.place[2]}),25)
            local locationLabel=GetTTFLabel(getlocal("city_info_coordinate")..":"..getlocal("city_info_coordinate_style",{playerVoApi:getMapX(),playerVoApi:getMapY()}),25)   
            locationLabel:setAnchorPoint(ccp(0,0.5))
            --locationLabel:setPosition(ccp(cellWidth-150,height))
            locationLabel:setPosition(ccp(width,height/2+5))
            bgSprie:addChild(locationLabel,2)
            ]]
        
            local time=0
            if helpDefendVo.time then
                time=helpDefendVo.time-base.serverTime
            end
            if time<0 then
                time=0
            end
            local countdownLabel
            if helpDefendVo.status==2 then
                countdownLabel=GetTTFLabel(getlocal("help_defending"),25)
                nameLabel:setColor(G_ColorGreen2)
                countdownLabel:setColor(G_ColorGreen2)
            else
                if helpDefendVo.status==1 or (helpDefendVo.status==0 and time<=0) then
                    countdownLabel=GetTTFLabel(getlocal("coverWaitting"),25)
                elseif (helpDefendVo.status==0 and time>0) then
                    local timeStr=GetTimeStr(time)
                    countdownLabel=GetTTFLabel(getlocal("coverArriving",{timeStr}),25)
                end
                countdownLabel:setColor(G_ColorWhite)
            end
            countdownLabel:setAnchorPoint(ccp(0,0))
            countdownLabel:setPosition(ccp(width,10+10))
            bgSprie:addChild(countdownLabel,2)
            --self.refreshData.countdownTab[idx+1]={time=time,label=countdownLabel}
            self.refreshData.countdownTab[idx+1]={label=countdownLabel}

            local function touchInfo(tag,object)
                if self.refreshData and self.refreshData.tableView and self.refreshData.tableView:getIsScrolled()==false then
                    PlayEffect(audioCfg.mouseClick)
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    local hdAll=helpDefendVoApi:getHelpDefendAll()
                    if hdAll and SizeOfTable(hdAll)>0 then
                        local cid="c"..tag
                        local hdVo=helpDefendVoApi:getHelpDefend(cid)
                        local isCallback=false
                        -- local hdVo=hdAll[tag]
                        -- print("SizeOfTable(tankInfoTab)",SizeOfTable(hdVo.tankInfoTab))
                        if hdVo and hdVo.tankInfoTab and SizeOfTable(hdVo.tankInfoTab)>0 then
                            if hdVo.lastTime==0 then
                                isCallback=true
                            else
                                require "luascript/script/game/scene/gamedialog/allianceDialog/helpDefenseInfoDialog"
                                local infoDialog = helpDefenseInfoDialog:new()
                                local infoBg = infoDialog:init(hdVo,layerNum+1,true) 
                            end                 
                        else
                            isCallback=true
                        end

                        if isCallback==true and hdVo and hdVo.id and hdVo.uid then
                            local function troopGetCallBack(fn,data)
                                local ret,sData=base:checkServerData(data)
                                if ret==true then
                                    if sData.data and sData.data.helpDefenseInfo then
                                        helpDefendVoApi:formatTankInfo(cid,sData.data.helpDefenseInfo)
                                        local hdefendVo=helpDefendVoApi:getHelpDefend(cid)
                                        if hdefendVo and hdefendVo.tankInfoTab and SizeOfTable(hdefendVo.tankInfoTab)>0 then
                                            require "luascript/script/game/scene/gamedialog/allianceDialog/helpDefenseInfoDialog"
                                            local infoDialog1 = helpDefenseInfoDialog:new()
                                            local infoBg1 = infoDialog1:init(hdefendVo,layerNum+1,true)
                                        end                
                                    end
                                end
                            end
                            socketHelper:troopGethelpdefense(hdVo.id,hdVo.uid,troopGetCallBack)
                        end
                    end
                end
            end
            local menuItemInfo = GetButtonItem("BtnSetUp.png","BtnSetUp_Down.png","BtnSetUp_Down.png",touchInfo,tonumber(RemoveFirstChar(helpDefendVo.id)),nil,nil)
            local menuInfo = CCMenu:createWithItem(menuItemInfo)
            menuInfo:setPosition(ccp(cellWidth-menuItemInfo:getContentSize().width/2-20,cellHeight/2))
            menuInfo:setTouchPriority(-(layerNum-1)*20-2)
            cell:addChild(menuInfo,3)
        
            return cell
        elseif fn=="ccTouchBegan" then
            return true
        elseif fn=="ccTouchMoved" then

        elseif fn=="ccTouchEnded"  then

        end
    end
    local cellWidth=self.bgLayer:getContentSize().width-40
    local hd= LuaEventHandler:createHandler(tvCallBack)
    self.refreshData.tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,self.bgLayer:getContentSize().height-170),nil)
    self.refreshData.tableView:setTableViewTouchPriority(-(layerNum-1)*20-3)
    self.refreshData.tableView:setPosition(ccp(20,35))
    self.bgLayer:addChild(self.refreshData.tableView,2)
    self.refreshData.tableView:setMaxDisToBottomOrTop(120)
    --[[
    local tableView=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(cellWidth,self.bgLayer:getContentSize().height-170),nil)
    tableView:setTableViewTouchPriority(-(layerNum-1)*20-3)
    tableView:setPosition(ccp(50,50))
    self.bgLayer:addChild(tableView,2)
    tableView:setMaxDisToBottomOrTop(120)
    ]]

    local function touchDialog()
        
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

function allianceSmallDialog:utfstrlen(str)
    local len = #str;
    local left = len;
    local cnt = 0;
    local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc};
    while left ~= 0 do
        local tmp=string.byte(str,-left);
        local i=#arr;
        while arr[i] do
            if tmp>=arr[i] then 
                left=left-i;
                break;
            end
                i=i-1;
        end
		--[[
        if tmp>=192 then
            cnt=cnt+2;
        else
            cnt=cnt+1;
        end
		]]
        cnt=cnt+1;
    end
    return cnt;
end

function allianceSmallDialog:refreshDonateDialog()
    if self and self.refreshData then
        if self.refreshData.sid and self.refreshData.resType then
            local sid=self.refreshData.sid
            local resType=self.refreshData.resType
            local donateNum=allianceVoApi:getDonateCount(resType)
            local donateMaxNum=allianceVoApi:getDonateMaxNum()
            local donateIdx=donateNum+1
            if donateIdx>donateMaxNum then
                donateIdx=donateMaxNum
            end
            local needRes=playerCfg.allianceDonateResources[donateIdx]
            local needGems=playerCfg.allianceDonateGold[donateIdx]

            if self.refreshData.donateItem then
                self.refreshData.donateItem:setEnabled(true)
            end
            if self.refreshData.donateGemItem then
                self.refreshData.donateGemItem:setEnabled(true)
            end
            if self.refreshData.hasResLable and resType then
                local hasRes=0
                local key=resType
                if playerVo[key] and tonumber(playerVo[key]) then
                    hasRes=tonumber(playerVo[key])
                end
                self.refreshData.hasResLable:setString(getlocal("nowOwned")..FormatNumber(hasRes))
                self.refreshData.hasResLable:setColor(G_ColorWhite)

                if needRes then
                    if hasRes<needRes then
                        self.refreshData.hasResLable:setColor(G_ColorRed)
                        if self.refreshData.donateItem then
                            self.refreshData.donateItem:setEnabled(false)
                        end
                    end
                end
            end
            if self.refreshData.hasGemsLable then
                local hasGems=playerVoApi:getGems()
                self.refreshData.hasGemsLable:setString(getlocal("nowOwned")..FormatNumber(hasGems))
                self.refreshData.hasGemsLable:setColor(G_ColorWhite)
                if needGems then
                    if hasGems<needGems then
                        self.refreshData.hasGemsLable:setColor(G_ColorRed)
                    end
                end
            end
            local donateMaxNum=allianceVoApi:getDonateMaxNum()
            if donateNum then
                if donateNum>=donateMaxNum then
                    if self.refreshData.donateItem then
                        self.refreshData.donateItem:setEnabled(false)
                    end
                    if self.refreshData.donateGemItem then
                        self.refreshData.donateGemItem:setEnabled(false)
                    end
                end
            end
            local selfAlliance=allianceVoApi:getSelfAlliance()
            if selfAlliance then
                if sid==0 then
                    if selfAlliance.level>=allianceVoApi:getMaxLevel() and selfAlliance.exp>=allianceVoApi:getMaxExp() then
                        self.refreshData.donateItem:setEnabled(false)
                        self.refreshData.donateGemItem:setEnabled(false)
                    end
                else
                    if allianceSkillVoApi:getSkillLevel(sid)>=allianceSkillVoApi:getSkillMaxLevel(sid) and allianceSkillVoApi:getSkillExp(sid)>=allianceSkillVoApi:getSkillMaxExp(sid) then
                        self.refreshData.donateItem:setEnabled(false)
                        self.refreshData.donateGemItem:setEnabled(false)
                    end
                end
            else
                self.refreshData.donateItem:setEnabled(false)
                self.refreshData.donateGemItem:setEnabled(false)
            end

            if self.refreshData.donateNumLable then
                local resName=getItem(resType,"u")
                self.refreshData.donateNumLable:setString(getlocal("alliance_donateCount",{(resName or ""),donateNum,donateMaxNum}))
            end

            if self.refreshData.requestLable then
                self.refreshData.requestLable:setString(getlocal("donateRequest")..FormatNumber(needRes))
            end

            local rewardCfg=playerCfg.allianceDonate[donateIdx]
            if sid==SizeOfTable(allianceSkillCfg) then
                rewardCfg=playerCfg.zijinDonate[donateIdx]
            end
            --刷新资源捐献的页面
            self:refreshDonateRewardsView(1,rewardCfg)

            if self.refreshData.requestGemsLable then
                self.refreshData.requestGemsLable:setString(getlocal("donateRequest")..FormatNumber(needGems))
            end
            --刷新金币捐献的页面
            self:refreshDonateRewardsView(2,rewardCfg)
        end
    end
end

function allianceSmallDialog:refreshHelpDefend()
    if self and self.refreshData and self.refreshData.tableView then
        local helpDefendNum=helpDefendVoApi:getHelpDefendNum()
        if helpDefendNum==0 then
            self:close()
        elseif helpDefendVoApi:getFlag()==0 then
            if self.refreshData.defendCountLabel then
                self.refreshData.defendCountLabel:setString(getlocal("coverCount",{helpDefendNum,helpDefendVoApi:getMaxNum()}))
            end
            if self.refreshData.tableView~=nil then
                if self.refreshData.countdownTab~=nil then
                    for k,v in pairs(self.refreshData.countdownTab) do
                        self.refreshData.countdownTab[k]=nil
                    end
                end
                self.refreshData.countdownTab={}
                self.refreshData.tableView:reloadData()
            end
            helpDefendVoApi:setFlag(-1)
        else
            if self.refreshData.countdownTab~=nil then
                local helpDefendAll=helpDefendVoApi:getHelpDefendAll()
                for k,v in pairs(helpDefendAll) do
                    if v and v.time and self.refreshData.countdownTab[k] then
                        local time=0
                        if v.status==0 then
                            time=v.time-base.serverTime
                        end
                        if time<0 then
                            time=0
                        end
                        -- if self.refreshData.nameTab[k].nameLabel then
                        --     self.refreshData.nameTab[k].nameLabel:setColor(G_ColorWhite)
                        --     if time==0 and v.status==2 then
                        --         self.refreshData.nameTab[k].nameLabel:setColor(G_ColorGreen2)
                        --     end
                        -- end
                        if self.refreshData.countdownTab[k].label then
                            self.refreshData.countdownTab[k].label:setColor(G_ColorWhite)
                            if time==0 then
                                if v.status==2 then
                                    self.refreshData.countdownTab[k].label:setString(getlocal("help_defending"))
                                    self.refreshData.countdownTab[k].label:setColor(G_ColorGreen2)
                                else
                                    self.refreshData.countdownTab[k].label:setString(getlocal("coverWaitting"))
                                end
                            else
                                self.refreshData.countdownTab[k].label:setString(getlocal("coverArriving",{GetTimeStr(time)}))
                            end
                        end
                    end
                end
            end
        end
    end
end

function allianceSmallDialog:tick()
    self:refreshDonateDialog()
    self:refreshHelpDefend()
    --编辑军团宣言冷却时间刷新
    if self.editDescTimeLb and tolua.cast(self.editDescTimeLb,"CCLabelTTF") then
        local coolingTime = allianceVoApi:getEditAllianceDescCoolingTime()
        if coolingTime > 0 then
            self.editDescTimeLb:setString(getlocal("edit_alliancedesc_timetip",{GetTimeStr(coolingTime)}))
        else
            self.editDescTimeLb:removeFromParentAndCleanup(true)
            self.editDescTimeLb = nil
        end
    end
end

--设置dialogLayer触摸优先级
function allianceSmallDialog:setTouchPriority(p)
    self.dialogLayer:setTouchPriority(p)
end
--特殊处理
function allianceSmallDialog:userHandler()

end

--显示面板,加效果
function allianceSmallDialog:show()

    if self.isUseAmi~=nil then
       local moveTo=CCMoveTo:create(0.3,CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
       local function callBack()
           base:cancleWait()
       end
       local callFunc=CCCallFunc:create(callBack)
       
       local scaleTo1=CCScaleTo:create(0.1, 1.1);
       local scaleTo2=CCScaleTo:create(0.07, 1);

       local acArr=CCArray:create()
       acArr:addObject(scaleTo1)
       acArr:addObject(scaleTo2)
       acArr:addObject(callFunc)
        
       local seq=CCSequence:create(acArr)
       self.bgLayer:runAction(seq)
   end
   table.insert(G_SmallDialogDialogTb,self)
   
end

function allianceSmallDialog:close()
    if self.isUseAmi~=nil and self.bgLayer~=nil then
	    local function realClose()
	        return self:realClose()
	    end
	   local fc= CCCallFunc:create(realClose)
	   local scaleTo1=CCScaleTo:create(0.1, 1.1);
	   local scaleTo2=CCScaleTo:create(0.07, 0.8);

	   local acArr=CCArray:create()
	   acArr:addObject(scaleTo1)
	   acArr:addObject(scaleTo2)
	   acArr:addObject(fc)
    
	   local seq=CCSequence:create(acArr)
	   self.bgLayer:runAction(seq)
   else
        self:realClose()

   end
end
function allianceSmallDialog:realClose()
	base:removeFromNeedRefresh(self)
    G_AllianceDialogTb[2]=nil
	if self.dialogLayer~=nil then
	    self.dialogLayer:removeFromParentAndCleanup(true)
	end
    self.bgLayer=nil
    self.dialogLayer=nil
    self.bgSize=nil
	if self.refreshData~=nil then
		for k,v in pairs(self.refreshData) do
			self.refreshData[k]=nil
		end
	end
	self.refreshData=nil
    self.personalRewardLabel=nil
    self.allianceRewardLabel=nil
    self.gemPersonalRewardLabel=nil
    self.gemAllianceRewardLabel=nil
    self.backSprie1=nil
    self.backSprie2=nil
    for k,v in pairs(G_SmallDialogDialogTb) do
        if v==self then
            v=nil
            G_SmallDialogDialogTb[k]=nil
        end
    end
end


function allianceSmallDialog:showTurnTestDialog(callBack,text,layerNum)
      local sd=allianceSmallDialog:new()
      sd:initTurnTestDialog(callBack,text,layerNum)
end
function allianceSmallDialog:initTurnTestDialog(callBack,text,layerNum)

    local function touchHandler()
    
    end

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("PanelHeaderPopup.png",CCRect(168, 86, 10, 10),touchHandler)
    self.dialogLayer=CCLayer:create()
    local size=CCSizeMake(550,450)
    self.bgLayer=dialogBg
    self.bgSize=size
    dialogBg:setContentSize(size)
    
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);

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
    
    local function close()
        PlayEffect(audioCfg.mouseClick)    
        return self:close()
     end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
    closeBtnItem:setPosition(0, 0)
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    local closeBtn = CCMenu:createWithItem(closeBtnItem)
    closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(closeBtn)
    
    local function tthandler()
    
    end
    local okStr=nil
    local function callBackUserNameHandler(fn,eB,str,type)
       if str~=nil then
           okStr=str
        end
    end
    
    local accountBox=LuaCCScale9Sprite:createWithSpriteFrameName("LegionInputBg.png",CCRect(10,10,1,1),tthandler)
    accountBox:setContentSize(CCSize(200,60))
    accountBox:setPosition(ccp(size.width/2,size.height/2-20))
    self.bgLayer:addChild(accountBox)

    local lbSize=25
    
    local targetBoxLabel=GetTTFLabel("",lbSize)
    targetBoxLabel:setAnchorPoint(ccp(0,0.5))
    targetBoxLabel:setPosition(ccp(10,accountBox:getContentSize().height/2))
    local customEditAccountBox=customEditBox:new()
    local length=30
    customEditAccountBox:init(accountBox,targetBoxLabel,"inputNameBg.png",nil,-(layerNum-1)*20-4,length,callBackUserNameHandler,nil,nil)
    
    local titleLb=GetTTFLabel(getlocal("dialog_title_prompt"),40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-titleLb:getContentSize().height/2-25))
    self.bgLayer:addChild(titleLb)
    
    
    local textLb=GetTTFLabelWrap(text,25,CCSize(self.bgLayer:getContentSize().width-100,200),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    textLb:setPosition(ccp(size.width/2,300))
    self.bgLayer:addChild(textLb)
    textLb:setColor(G_ColorYellow)
    
    local function pusuOK()
        if tostring(okStr)~=nil and okStr~=nil then
            if okStr=="rayjoy888" then
                self:close()
                callBack(1);
            elseif okStr=="rayjoy999" then
                self:close()
                callBack(2);
            else
               self:close()
               smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_pushNOOK"),28)
               
            end
        else
           self:close()
           smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_pushNOOK"),28)
           
        end
    end

    local sureItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",pusuOK,nil,getlocal("buyQueueOK"),25)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(size.width/2,80))
    sureMenu:setTouchPriority(-(layerNum-1)*20-4);
    self.bgLayer:addChild(sureMenu)
    


end



function allianceSmallDialog:showWarResultDialog(bgSrc,size,fullRect,inRect,isVictory,callBack,isuseami,layerNum,params)
    local sd=allianceSmallDialog:new()
    sd:initWarResultDialog(bgSrc,size,fullRect,inRect,isVictory,callBack,isuseami,layerNum,params)
    return sd
end
function allianceSmallDialog:initWarResultDialog(bgSrc,size,fullRect,inRect,isVictory,callBack,isuseami,layerNum,params)
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


    local function detailHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if callBack then
            callBack(tag,object)
        end

        if G_AllianceWarDialogTb["warRecordDialog"] then
            -- G_AllianceWarDialogTb["warRecordDialog"]:tabClick(1)
        else
            
            if G_AllianceWarDialogTb["allianceWarDialog"]~=nil then
                G_AllianceWarDialogTb["allianceWarDialog"]:close()
            end

            local td=warRecordDialog:new()
            local tbArr={getlocal("alliance_war_record_title"),getlocal("alliance_war_stats")}
            local tbSubArr={}
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,tbSubArr,nil,getlocal("alliance_war_battle_stats"),true,layerNum)
            sceneGame:addChild(dialog,layerNum)
            

            -- td:tabClick(1)
        end

        self:close()
    end
    local detailBtnItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",detailHandler,2,getlocal("record_detail"),25)
    detailBtnItem:setPosition(0,0)
    detailBtnItem:setAnchorPoint(CCPointMake(0,0))
    local detailBtn = CCMenu:createWithItem(detailBtnItem)
    detailBtn:setTouchPriority(-(layerNum-1)*20-4)
    detailBtn:setPosition(ccp(80,20))
    self.bgLayer:addChild(detailBtn,2)

    local function closeHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        -- self.bgLayer:setVisible(false)
        if G_AllianceWarDialogTb["allianceWarDialog"]~=nil then
            G_AllianceWarDialogTb["allianceWarDialog"]:close()
            local td=allianceWarOverviewDialog:new(3)
            local tbArr={}
            local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_war"),false,3)
            sceneGame:addChild(dialog,3)
        end  
        self:close()



    end
    local closeBtnItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",closeHandler,1,getlocal("ok"),25)
    closeBtnItem:setPosition(0,0)
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(size.width/2-closeBtnItem:getContentSize().width/2,20))
    self.bgLayer:addChild(self.closeBtn,2)
    self.closeBtn:setPosition(ccp(size.width-detailBtnItem:getContentSize().width-80,20))


    local lbSize=22
    -- local str="啊啊啊啊啊啊"
    -- local redPointLb=GetTTFLabelWrap(str,lbSize,CCSize(self.bgLayer:getContentSize().width/2-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    -- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    -- local bluePointLb=GetTTFLabelWrap(str,lbSize,CCSize(self.bgLayer:getContentSize().width/2-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    -- local redDestroyLb=GetTTFLabelWrap(str,lbSize,CCSize(self.bgLayer:getContentSize().width/2-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    -- local blueDestroyLb=GetTTFLabelWrap(str,lbSize,CCSize(self.bgLayer:getContentSize().width/2-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    -- local contributionLb=GetTTFLabelWrap(str,lbSize,CCSize(self.bgLayer:getContentSize().width-25,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)

    local redPoint=allianceWarRecordVoApi.redPoint or 0
    local bluePoint=allianceWarRecordVoApi.bluePoint or 0
    local redDestroy=allianceWarRecordVoApi.redDestroy or 0
    local blueDestroy=allianceWarRecordVoApi.blueDestroy or 0
    local rewardContribution=allianceWarRecordVoApi.rewardContribution or 0

    local redPointLb=GetTTFLabelWrap(getlocal("alliance_war_red",{redPoint}),lbSize,CCSize(self.bgLayer:getContentSize().width/2-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    local bluePointLb=GetTTFLabelWrap(getlocal("alliance_war_blue",{bluePoint}),lbSize,CCSize(self.bgLayer:getContentSize().width/2-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    local redDestroyLb=GetTTFLabelWrap(getlocal("alliance_war_destroy_total",{redDestroy}),lbSize,CCSize(self.bgLayer:getContentSize().width/2-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    local blueDestroyLb=GetTTFLabelWrap(getlocal("alliance_war_destroy_total",{blueDestroy}),lbSize,CCSize(self.bgLayer:getContentSize().width/2-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop) 
    local contributionLb=GetTTFLabelWrap(getlocal("record_personal_contribution",{rewardContribution}),lbSize,CCSize(self.bgLayer:getContentSize().width-25,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)


    local lbHeight=0
    local lbheight1=0
    local lbheight2=0
    if redPointLb:getContentSize().height>bluePointLb:getContentSize().height then
        lbheight1=redPointLb:getContentSize().height
        lbHeight=lbHeight+redPointLb:getContentSize().height
    else
        lbheight1=bluePointLb:getContentSize().height
        lbHeight=lbHeight+bluePointLb:getContentSize().height
    end
    if redDestroyLb:getContentSize().height>blueDestroyLb:getContentSize().height then
        lbheight2=redDestroyLb:getContentSize().height
        lbHeight=lbHeight+redDestroyLb:getContentSize().height
    else
        lbheight2=blueDestroyLb:getContentSize().height
        lbHeight=lbHeight+blueDestroyLb:getContentSize().height
    end
    lbHeight=lbHeight+contributionLb:getContentSize().height


    local bgHeight=355+lbHeight
    local victoryBg = CCSprite:createWithSpriteFrameName("TeamHeaderBg.png")
    victoryBg:setAnchorPoint(ccp(0.5,1))
    victoryBg:setPosition(ccp(size.width/2,bgHeight-40))
    self.bgLayer:addChild(victoryBg)
    local isVictoryLabel
    if isVictory then
        isVictoryLabel=GetTTFLabel(getlocal("record_win"),30)
        isVictoryLabel:setAnchorPoint(ccp(0.5,0.5))
        isVictoryLabel:setPosition(getCenterPoint(victoryBg))
        victoryBg:addChild(isVictoryLabel,1)
        isVictoryLabel:setColor(G_ColorYellowPro)

        local victorySpBg = CCSprite:createWithSpriteFrameName("SuccessHeader.png")
        --victorySpBg:setAnchorPoint(ccp(0.5,1))
        victorySpBg:setPosition(ccp(size.width/2,bgHeight+48))
        self.bgLayer:addChild(victorySpBg,2)

        --星星动画
        -- battleScene:showStarAni(victorySpBg,3)
    else
        isVictoryLabel=GetTTFLabel(getlocal("record_fail"),30)
        isVictoryLabel:setAnchorPoint(ccp(0.5,0.5))
        isVictoryLabel:setPosition(getCenterPoint(victoryBg))
        victoryBg:addChild(isVictoryLabel,1)
        
        local loseSpBg = CCSprite:createWithSpriteFrameName("LoseHeader.png")
        --loseSpBg:setAnchorPoint(ccp(0.5,1))
        loseSpBg:setPosition(ccp(size.width/2,bgHeight+48))
        self.bgLayer:addChild(loseSpBg,2)

    end

    redPointLb:setAnchorPoint(ccp(0,1))
    redPointLb:setPosition(ccp(20,bgHeight-140))
    self.bgLayer:addChild(redPointLb,2)

    bluePointLb:setAnchorPoint(ccp(0,1))
    bluePointLb:setPosition(ccp(size.width/2+20,bgHeight-140))
    self.bgLayer:addChild(bluePointLb,2)

    redDestroyLb:setAnchorPoint(ccp(0,1))
    redDestroyLb:setPosition(ccp(20,bgHeight-140-lbheight1-15))

    self.bgLayer:addChild(redDestroyLb,2)

    blueDestroyLb:setAnchorPoint(ccp(0,1))
    blueDestroyLb:setPosition(ccp(size.width/2+20,bgHeight-140-lbheight1-15))
    self.bgLayer:addChild(blueDestroyLb,2)

    contributionLb:setAnchorPoint(ccp(0.5,1))
    contributionLb:setPosition(ccp(size.width/2,bgHeight-140-lbheight1-lbheight2-60))
    self.bgLayer:addChild(contributionLb,2)


    bgHeight=bgHeight+50

    local bgSize=CCSizeMake(size.width,bgHeight)
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




function allianceSmallDialog:showWar2ResultDialog(bgSrc,size,fullRect,inRect,isVictory,callBack,isuseami,layerNum,params)
    local sd=allianceSmallDialog:new()
    sd:initWar2ResultDialog(bgSrc,size,fullRect,inRect,isVictory,callBack,isuseami,layerNum,params)
    return sd
end
function allianceSmallDialog:initWar2ResultDialog(bgSrc,size,fullRect,inRect,isVictory,callBack,isuseami,layerNum,params)
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


    local function detailHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if callBack then
            callBack(tag,object)
        end

        if G_AllianceWarDialogTb["allianceWar2RecordDialog"] then
            -- G_AllianceWarDialogTb["allianceWar2RecordDialog"]:tabClick(1)
        else
            
            if G_AllianceWarDialogTb["allianceWar2Dialog"]~=nil then
                G_AllianceWarDialogTb["allianceWar2Dialog"]:close()
            end

            -- local td=allianceWar2RecordDialog:new()
            -- local tbArr={getlocal("alliance_war_record_title"),getlocal("alliance_war_stats")}
            -- local tbSubArr={}
            -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,tbSubArr,nil,getlocal("alliance_war_battle_stats"),true,layerNum)
            -- sceneGame:addChild(dialog,layerNum)
            
            allianceWar2VoApi:showRecordDialog(layerNum)

            -- td:tabClick(1)
        end

        self:close()
    end
    local detailBtnItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",detailHandler,2,getlocal("record_detail"),25)
    detailBtnItem:setPosition(0,0)
    detailBtnItem:setAnchorPoint(CCPointMake(0,0))
    local detailBtn = CCMenu:createWithItem(detailBtnItem)
    detailBtn:setTouchPriority(-(layerNum-1)*20-4)
    detailBtn:setPosition(ccp(80,20))
    self.bgLayer:addChild(detailBtn,2)

    local function closeHandler(tag,object)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        -- self.bgLayer:setVisible(false)
        if G_AllianceWarDialogTb["allianceWar2Dialog"]~=nil then
            G_AllianceWarDialogTb["allianceWar2Dialog"]:close()
            -- local td=allianceWar2OverviewDialog:new(3)
            -- local tbArr={}
            -- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_war"),false,3)
            -- sceneGame:addChild(dialog,3)
        end
        if G_AllianceWarDialogTb["allianceWar2OverviewDialog"] and G_AllianceWarDialogTb["allianceWar2OverviewDialog"].refreshCity then
            G_AllianceWarDialogTb["allianceWar2OverviewDialog"]:refreshCity()
        end
        self:close()
    end
    local closeBtnItem = GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",closeHandler,1,getlocal("ok"),25)
    closeBtnItem:setPosition(0,0)
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(size.width/2-closeBtnItem:getContentSize().width/2,20))
    self.bgLayer:addChild(self.closeBtn,2)
    self.closeBtn:setPosition(ccp(size.width-detailBtnItem:getContentSize().width-80,20))


    local lbSize=22
    -- local str="啊啊啊啊啊啊"
    -- local redPointLb=GetTTFLabelWrap(str,lbSize,CCSize(self.bgLayer:getContentSize().width/2-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    -- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    -- local bluePointLb=GetTTFLabelWrap(str,lbSize,CCSize(self.bgLayer:getContentSize().width/2-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    -- local redDestroyLb=GetTTFLabelWrap(str,lbSize,CCSize(self.bgLayer:getContentSize().width/2-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    -- local blueDestroyLb=GetTTFLabelWrap(str,lbSize,CCSize(self.bgLayer:getContentSize().width/2-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    -- local contributionLb=GetTTFLabelWrap(str,lbSize,CCSize(self.bgLayer:getContentSize().width-25,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)

    local redPoint=allianceWar2RecordVoApi.redPoint or 0
    local bluePoint=allianceWar2RecordVoApi.bluePoint or 0
    local redDestroy=allianceWar2RecordVoApi.redDestroy or 0
    local blueDestroy=allianceWar2RecordVoApi.blueDestroy or 0
    local rewardContribution=allianceWar2RecordVoApi.rewardContribution or 0

    -- local redPointLb=GetTTFLabelWrap(getlocal("alliance_war_red",{redPoint}),lbSize,CCSize(self.bgLayer:getContentSize().width/2-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    -- local bluePointLb=GetTTFLabelWrap(getlocal("alliance_war_blue",{bluePoint}),lbSize,CCSize(self.bgLayer:getContentSize().width/2-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    local redPointLb=GetTTFLabel(": "..redPoint,lbSize)
    local bluePointLb=GetTTFLabel(": "..bluePoint,lbSize)
    local redDestroyLb=GetTTFLabelWrap(getlocal("alliance_war_destroy_total",{redDestroy}),lbSize,CCSize(self.bgLayer:getContentSize().width/2-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    local blueDestroyLb=GetTTFLabelWrap(getlocal("alliance_war_destroy_total",{blueDestroy}),lbSize,CCSize(self.bgLayer:getContentSize().width/2-20,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop) 
    local contributionLb=GetTTFLabelWrap(getlocal("record_personal_contribution",{rewardContribution}),lbSize,CCSize(self.bgLayer:getContentSize().width-25,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)


    local lbHeight=0
    local lbheight1=0
    local lbheight2=0
    if redPointLb:getContentSize().height>bluePointLb:getContentSize().height then
        lbheight1=redPointLb:getContentSize().height
        lbHeight=lbHeight+redPointLb:getContentSize().height
    else
        lbheight1=bluePointLb:getContentSize().height
        lbHeight=lbHeight+bluePointLb:getContentSize().height
    end
    if redDestroyLb:getContentSize().height>blueDestroyLb:getContentSize().height then
        lbheight2=redDestroyLb:getContentSize().height
        lbHeight=lbHeight+redDestroyLb:getContentSize().height
    else
        lbheight2=blueDestroyLb:getContentSize().height
        lbHeight=lbHeight+blueDestroyLb:getContentSize().height
    end
    lbHeight=lbHeight+contributionLb:getContentSize().height


    local bgHeight=355+lbHeight
    local victoryBg = CCSprite:createWithSpriteFrameName("TeamHeaderBg.png")
    victoryBg:setAnchorPoint(ccp(0.5,1))
    victoryBg:setPosition(ccp(size.width/2,bgHeight-40))
    self.bgLayer:addChild(victoryBg)
    local isVictoryLabel
    if isVictory then
        isVictoryLabel=GetTTFLabel(getlocal("record_win"),30)
        isVictoryLabel:setAnchorPoint(ccp(0.5,0.5))
        isVictoryLabel:setPosition(getCenterPoint(victoryBg))
        victoryBg:addChild(isVictoryLabel,1)
        isVictoryLabel:setColor(G_ColorYellowPro)

        local victorySpBg = CCSprite:createWithSpriteFrameName("SuccessHeader.png")
        --victorySpBg:setAnchorPoint(ccp(0.5,1))
        victorySpBg:setPosition(ccp(size.width/2,bgHeight+48))
        self.bgLayer:addChild(victorySpBg,2)

        --星星动画
        -- battleScene:showStarAni(victorySpBg,3)
    else
        isVictoryLabel=GetTTFLabel(getlocal("record_fail"),30)
        isVictoryLabel:setAnchorPoint(ccp(0.5,0.5))
        isVictoryLabel:setPosition(getCenterPoint(victoryBg))
        victoryBg:addChild(isVictoryLabel,1)
        
        local loseSpBg = CCSprite:createWithSpriteFrameName("LoseHeader.png")
        --loseSpBg:setAnchorPoint(ccp(0.5,1))
        loseSpBg:setPosition(ccp(size.width/2,bgHeight+48))
        self.bgLayer:addChild(loseSpBg,2)

    end

    local redFlag=CCSprite:createWithSpriteFrameName("awRedFlag.png")
    redFlag:setAnchorPoint(ccp(0,0.5))
    redFlag:setPosition(ccp(30,bgHeight-152))
    self.bgLayer:addChild(redFlag,2)
    local blueFlag=CCSprite:createWithSpriteFrameName("awBlueFlag.png")
    blueFlag:setAnchorPoint(ccp(0,0.5))
    blueFlag:setPosition(ccp(size.width/2+30,bgHeight-152))
    self.bgLayer:addChild(blueFlag,2)

    redPointLb:setAnchorPoint(ccp(0,1))
    redPointLb:setPosition(ccp(20+redFlag:getContentSize().width+20,bgHeight-140))
    self.bgLayer:addChild(redPointLb,2)

    bluePointLb:setAnchorPoint(ccp(0,1))
    bluePointLb:setPosition(ccp(size.width/2+20+blueFlag:getContentSize().width+20,bgHeight-140))
    self.bgLayer:addChild(bluePointLb,2)

    redDestroyLb:setAnchorPoint(ccp(0,1))
    redDestroyLb:setPosition(ccp(20,bgHeight-140-lbheight1-15))

    self.bgLayer:addChild(redDestroyLb,2)

    blueDestroyLb:setAnchorPoint(ccp(0,1))
    blueDestroyLb:setPosition(ccp(size.width/2+20,bgHeight-140-lbheight1-15))
    self.bgLayer:addChild(blueDestroyLb,2)

    contributionLb:setAnchorPoint(ccp(0.5,1))
    contributionLb:setPosition(ccp(size.width/2,bgHeight-140-lbheight1-lbheight2-60))
    self.bgLayer:addChild(contributionLb,2)
    contributionLb:setColor(G_ColorYellowPro)


    bgHeight=bgHeight+50

    local bgSize=CCSizeMake(size.width,bgHeight)
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

    if G_AllianceWarDialogTb["allianceWar2cityDialog"] and G_AllianceWarDialogTb["allianceWar2cityDialog"].close then
        G_AllianceWarDialogTb["allianceWar2cityDialog"]:close()
    end
    return self.dialogLayer
end



function allianceSmallDialog:showCityDialog(bgSrc,size,fullRect,inRect,title,isuseami,layerNum,cityID,callBack)
    local sd=allianceSmallDialog:new()
    sd:initCityDialog(bgSrc,size,fullRect,inRect,title,isuseami,layerNum,cityID,callBack)
    return sd
end
function allianceSmallDialog:initCityDialog(bgSrc,size,fullRect,inRect,title,isuseami,layerNum,cityID,callBack)
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

    local titleLb=GetTTFLabel(title,40)
    titleLb:setAnchorPoint(ccp(0.5,0.5))
    titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
    dialogBg:addChild(titleLb)

    local function close()
        PlayEffect(audioCfg.mouseClick)  
        G_AllianceWarDialogTb["allianceWar2cityDialog"]=nil
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
    closeBtnItem:setPosition(0, 0)
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
    local closeBtn = CCMenu:createWithItem(closeBtnItem)
    closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(closeBtn)


    if cityID then
        -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
        local collectSpeed=allianceWar2Cfg.stronghold[cityID].winPoint
        local buffLv=0
        local collectBuff=0
        if allianceWar2VoApi:getBattlefieldUser() and allianceWar2VoApi:getBattlefieldUser().b3 then
            buffLv=tonumber(allianceWar2VoApi:getBattlefieldUser().b3)
            collectBuff=buffLv*allianceWar2Cfg.buffSkill.b3.per*100
        end

        local speedStr=getlocal("allianceWar2_collect_speed",{FormatNumber(collectSpeed*10*(collectBuff/100+1)).."/10s"})
        local buffStr=getlocal("allianceWar2_buff_effect",{collectBuff})
        if buffLv>=allianceWar2Cfg.buffSkill.b3.maxLv then
            buffStr=buffStr..getlocal("hero_honor_level_max")
        end
        local cdTimeStr=GetTimeStr(allianceWar2Cfg.cdTime)
        local regroupDesc=getlocal("allianceWar2_regroup_desc",{cdTimeStr})
        -- speedStr=str
        -- buffStr=str
        -- regroupDesc=str

        local spaceh=-10
        -- local speedLb=GetTTFLabelWrap(speedStr,25,CCSize(self.bgLayer:getContentSize().width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        -- speedLb:setPosition(ccp(size.width/2,420+spaceh))
        local speedLb=GetTTFLabelWrap(speedStr,25,CCSize(self.bgLayer:getContentSize().width-180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        speedLb:setAnchorPoint(ccp(0,0.5))
        speedLb:setPosition(ccp(120,320+spaceh))
        self.bgLayer:addChild(speedLb)
        -- local buffLb=GetTTFLabelWrap(buffStr,25,CCSize(self.bgLayer:getContentSize().width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        -- buffLb:setPosition(ccp(size.width/2,330+spaceh))
        local buffLb=GetTTFLabelWrap(buffStr,25,CCSize(self.bgLayer:getContentSize().width-180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        buffLb:setAnchorPoint(ccp(0,0.5))
        buffLb:setPosition(ccp(120,260+spaceh))
        self.bgLayer:addChild(buffLb)
        local descLb=GetTTFLabelWrap(regroupDesc,25,CCSize(self.bgLayer:getContentSize().width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        descLb:setPosition(ccp(size.width/2,180+spaceh))
        self.bgLayer:addChild(descLb)
        descLb:setColor(G_ColorYellow)
        
        --放弃据点
        local function giveupHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            
            local function regroupCallback(fn,data)
                local cresult,retTb=base:checkServerData(data)
                if cresult==true then
                    --smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceWar2_regroup_success"),30)
                    G_AllianceWarDialogTb["allianceWar2cityDialog"]=nil
                    self:close()
                    if callBack then
                        callBack()
                    end
                end
            end
            local selfOid=allianceWar2VoApi:getSelfOid()
            if selfOid and selfOid>0 then
                socketHelper:alliancewarnewRegroup(selfOid,allianceWar2VoApi:getTargetCity(),regroupCallback)
            end
        end
        local giveupItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",giveupHandler,1,getlocal("allianceWar2_giveup_stronghold"),25)
        local giveupMenu=CCMenu:createWithItem(giveupItem)
        giveupMenu:setPosition(ccp(size.width-120,60))
        giveupMenu:setTouchPriority(-(layerNum-1)*20-4)
        dialogBg:addChild(giveupMenu)
        
        --加速采集，跳转
        local function speedupHandler()
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            G_AllianceWarDialogTb["allianceWar2cityDialog"]=nil
            self:close()
            allianceWar2VoApi:showBufferDialog(layerNum+1)
        end
        local speedupItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",speedupHandler,2,getlocal("allianceWar2_speedup_collection"),25)
        local speedupMenu=CCMenu:createWithItem(speedupItem)
        speedupMenu:setPosition(ccp(120,60))
        speedupMenu:setTouchPriority(-(layerNum-1)*20-4)
        dialogBg:addChild(speedupMenu)
        if buffLv>=allianceWar2Cfg.buffSkill.b3.maxLv then
            speedupItem:setEnabled(false)
        end
    end


    self.bgLayer:setContentSize(self.bgSize)
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

    G_AllianceWarDialogTb["allianceWar2cityDialog"]=self

    return self.dialogLayer
end


