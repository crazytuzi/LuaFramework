allianceDialogCreateTab={

}

function allianceDialogCreateTab:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    
    self.bgLayer=nil;
    self.layerNum=nil;
    self.createBtn=nil;
    self.applyType=0;
    self.needType=1;
    self.applyTypeSp=nil;
    self.needTypeSp=nil;
    self.allianceName="";
    self.allianceDeclaration=nil;
    self.editBox=nil;
    self.textValue=nil;
    self.parentDialog=nil;
    return nc;

end

function allianceDialogCreateTab:init(parentDialog,layerNum)

    self.parentDialog=parentDialog
    self.bgLayer=CCLayer:create();
    self.layerNum=layerNum;
    self:initTabLayer();

    return self.bgLayer
end

function allianceDialogCreateTab:addTextField()
		local maxLength=75
		local lastStr
--输入框--------------------------------
        local function touch2(hd,fn,idx)
            PlayEffect(audioCfg.mouseClick)
            if self.editBox then
                self.editBox:setVisible(true)
                self.editBox:setText(textValue)
            end
		end
        local descHeight = G_is5x(200,150)
        local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("newAlliance_desc1.png",CCRect(198,24, 2, 2),touch2)
        backSprie:setContentSize(CCSizeMake(500, descHeight))
	    backSprie:setAnchorPoint(ccp(0.5,1))
	    backSprie:setIsSallow(false)
	    backSprie:setTouchPriority(-(self.layerNum-1)*20-4)
		backSprie:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight-280))
	    self.bgLayer:addChild(backSprie,2)

        local noticeLable = GetTTFLabelWrap(getlocal("newAllianceSlogan"),25,CCSizeMake(25*5,0),kCCTextAlignmentLeft,kCCTextAlignmentCenter,"Helvetica-bold")
        noticeLable:setAnchorPoint(ccp(0.5,0))
        noticeLable:setPosition(ccp(backSprie:getContentSize().width/2+10,backSprie:getContentSize().height-18))
        noticeLable:setColor(G_ColorYellowPro2)
        backSprie:addChild(noticeLable,1)

		local textLabel=GetTTFLabelWrap("",25,CCSizeMake(backSprie:getContentSize().width-20,backSprie:getContentSize().height-20),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		textLabel:setAnchorPoint(ccp(0,1))
		textLabel:setPosition(ccp(20,backSprie:getContentSize().height-20))
		backSprie:addChild(textLabel,2)
        textLabel:setVisible(false)
        self.textLabel = textLabel

        --textLabel:setColor(G_ColorGreen)

        local editLabel=GetTTFLabelWrap(getlocal("newAlliancePrompt"),25,CCSizeMake(backSprie:getContentSize().width-50,backSprie:getContentSize().height-20),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        editLabel:setAnchorPoint(ccp(0,1))
        editLabel:setPosition(ccp(20,backSprie:getContentSize().height-20))
        backSprie:addChild(editLabel,2)
        editLabel:setColor(G_ColorGray)
        self.editLabel = editLabel


		self.textValue=textLabel:getString()
        --self.textValue=""
		if self.textValue==nil then
			self.textValue=""
		end
		local function tthandler()
	
	    end
	    local function callBackHandler(fn,eB,str,type)
			-- if type==0 then  --开始输入
			-- 	textLabel:setString(self.textValue)
   --              textLabel:setColor(G_ColorWhite)
			-- else
            if type==1 then  --检测文本内容变化
                editLabel:setVisible(false)
                textLabel:setVisible(true)
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
                if self.textValue == "" then
                    textLabel:setVisible(false)
                    editLabel:setVisible(true)
                end
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
		local size=CCSizeMake(640,50)
		local xBox=LuaCCScale9Sprite:createWithSpriteFrameName("worldInputBg.png",CCRect(10,10,5,5),tthandler)
	    self.editBox=CCEditBox:createForLua(size,xBox,nil,nil,callBackHandler)
		self.editBox:setFont(textLabel.getFontName(textLabel),yScale*textLabel.getFontSize(textLabel)/2)
		self.editBox:setMaxLength(maxLength)
		self.editBox:setText(self.textValue)
		self.editBox:setAnchorPoint(ccp(0,0))
		self.editBox:setPosition(ccp(0,220))

		--self.editBox:setInputFlag(CCEditBox.kEditBoxInputFlagInitialCapsAllCharacters)
        self.editBox:setInputFlag(CCEditBox.kEditBoxInputFlagInitialCapsSentence)
		self.editBox:setInputMode(CCEditBox.kEditBoxInputModeSingleLine)

	    self.editBox:setVisible(false)
	    self.bgLayer:addChild(self.editBox,4)
		----------------------------------
end
function allianceDialogCreateTab:initTabLayer()
    local offy = G_is5x(0,50)
    local isVipPrivilege=false
    local gemsNum=0
    --创建军团不花金币
    local vipPrivilegeSwitch=base.vipPrivilegeSwitch
    if vipPrivilegeSwitch and vipPrivilegeSwitch.vca==1 then
        local vipRelatedCfg=playerCfg.vipRelatedCfg or {}
        local createAllianceGems=vipRelatedCfg.createAllianceGems or {}
        if createAllianceGems and createAllianceGems[1] and createAllianceGems[2] then
            if playerVoApi:getVipLevel()>=createAllianceGems[1] then
                isVipPrivilege=true
                gemsNum=createAllianceGems[2]
            end
        end
    end
    
    self:addTextField()

    local function tthandler()
    
    end
    local function callBackUserNameHandler(fn,eB,str,type)
       if str~=nil then
           self.allianceName=str
           self.allianceName=G_stringGsub(self.allianceName," ","")
        end            
    end
    
    local accountBox=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),tthandler)
    accountBox:setContentSize(CCSize(445,60))
    accountBox:setPosition(ccp(365,G_VisibleSizeHeight-220))
    self.bgLayer:addChild(accountBox)

    local lbSize=25
    
    local targetBoxLabel=GetTTFLabel("",lbSize)
    targetBoxLabel:setAnchorPoint(ccp(0,0.5))
    targetBoxLabel:setPosition(ccp(10,accountBox:getContentSize().height/2))
    local customEditAccountBox=customEditBox:new()
    local length=12
    customEditAccountBox:init(accountBox,targetBoxLabel,"rankKuang.png",nil,-(self.layerNum-1)*20-4,length,callBackUserNameHandler,nil,nil)

    -- local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png");
    -- lineSp:setAnchorPoint(ccp(0.5,0));
    -- lineSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,G_VisibleSizeHeight-280));
    -- self.bgLayer:addChild(lineSp,2)

    local nameLabel=GetTTFLabel(getlocal("alliance_name"),lbSize,true)
    nameLabel:setPosition(80,G_VisibleSizeHeight-220)
    self.bgLayer:addChild(nameLabel,2)
    
    -- local declarationLabel=GetTTFLabel(getlocal("alliance_declaration"),lbSize)
    -- declarationLabel:setPosition(100,G_VisibleSizeHeight-400)
    -- self.bgLayer:addChild(declarationLabel,2)
    local function nilFunc( ... )
        -- body
    end

    local titleSpire = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),nilFunc)
    titleSpire:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-100,32))
    titleSpire:setAnchorPoint(ccp(0.5,1))
    self.bgLayer:addChild(titleSpire)
    titleSpire:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-490+offy))

    local typeLabel=GetTTFLabel(getlocal("newAllianceType"),lbSize,true)
    typeLabel:setColor(G_ColorYellowPro2)
    typeLabel:setAnchorPoint(ccp(0,0.5))
    typeLabel:setPosition(15,titleSpire:getContentSize().height/2)
    titleSpire:addChild(typeLabel,2)

    
    local titleSpire2 = LuaCCScale9Sprite:createWithSpriteFrameName("panelSubTitleBg.png",CCRect(105,0,1,32),nilFunc)
    titleSpire2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-100,32))
    titleSpire2:setAnchorPoint(ccp(0.5,1))
    self.bgLayer:addChild(titleSpire2)
    titleSpire2:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-670+offy))

    local needLabel=GetTTFLabel(getlocal("newAllianceNeed"),lbSize,true)
    needLabel:setColor(G_ColorYellowPro2)
    needLabel:setAnchorPoint(ccp(0,0.5))
    needLabel:setPosition(15,titleSpire2:getContentSize().height/2)
    titleSpire2:addChild(needLabel)

    local apply1Label=GetTTFLabelWrap(getlocal("alliance_apply0"),lbSize,CCSizeMake(lbSize*15,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    apply1Label:setAnchorPoint(ccp(0,0.5));
    apply1Label:setPosition(230,G_VisibleSizeHeight-560+offy)
    self.bgLayer:addChild(apply1Label,2)
    
    local apply2Label=GetTTFLabelWrap(getlocal("alliance_apply1"),lbSize,CCSizeMake(lbSize*15,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
    apply2Label:setAnchorPoint(ccp(0,0.5));
    apply2Label:setPosition(230,G_VisibleSizeHeight-620+offy)
    self.bgLayer:addChild(apply2Label,2)
    
    local resIcon1=CCSprite:createWithSpriteFrameName("IconCrystal-.png");
    resIcon1:setAnchorPoint(ccp(0,0.5));
    resIcon1:setPosition(ccp(230,G_VisibleSizeHeight-740+offy));
    self.bgLayer:addChild(resIcon1,2)
    
    local resStr
    if(G_isHexie())then
        resStr="50万"
    else
        resStr="500k"
    end
    local resLabel1=GetTTFLabel(resStr,lbSize)
    resLabel1:setAnchorPoint(ccp(0,0.5));
    resLabel1:setPosition(resIcon1:getContentSize().width,resIcon1:getContentSize().height/2)
    resIcon1:addChild(resLabel1,2)
    
    local resIcon2=CCSprite:createWithSpriteFrameName("IconCopper.png");
    resIcon2:setAnchorPoint(ccp(0,0.5));
    resIcon2:setPosition(ccp(320,G_VisibleSizeHeight-740+offy));
    self.bgLayer:addChild(resIcon2,2)
    
    local resLabel2=GetTTFLabel(resStr,lbSize)
    resLabel2:setAnchorPoint(ccp(0,0.5));
    resLabel2:setPosition(resIcon2:getContentSize().width,resIcon2:getContentSize().height/2)
    resIcon2:addChild(resLabel2,2)
    
    local resIcon3=CCSprite:createWithSpriteFrameName("IconOil.png");
    resIcon3:setAnchorPoint(ccp(0,0.5));
    resIcon3:setPosition(ccp(410,G_VisibleSizeHeight-740+offy));
    self.bgLayer:addChild(resIcon3,2)
    
    local resLabel3=GetTTFLabel(resStr,lbSize)
    resLabel3:setAnchorPoint(ccp(0,0.5));
    resLabel3:setPosition(resIcon3:getContentSize().width,resIcon3:getContentSize().height/2)
    resIcon3:addChild(resLabel3,2)
    
    local resIcon4=CCSprite:createWithSpriteFrameName("IconIron.png");
    resIcon4:setAnchorPoint(ccp(0,0.5));
    resIcon4:setPosition(ccp(500,G_VisibleSizeHeight-740+offy));
    self.bgLayer:addChild(resIcon4,2)
    
    local resLabel4=GetTTFLabel(resStr,lbSize)
    resLabel4:setAnchorPoint(ccp(0,0.5));
    resLabel4:setPosition(resIcon4:getContentSize().width,resIcon4:getContentSize().height/2)
    resIcon4:addChild(resLabel4,2)
    

    if playerVoApi:getGold()<500000 then
        resLabel1:setColor(G_ColorRed)
    end
    if playerVoApi:getR1()<500000 then
        resLabel2:setColor(G_ColorRed)
    end
    if playerVoApi:getR2()<500000 then
        resLabel3:setColor(G_ColorRed)
    end
    if playerVoApi:getR3()<500000 then
        resLabel4:setColor(G_ColorRed)
    end

    
    local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png");
    gemIcon:setAnchorPoint(ccp(0,0.5));
    gemIcon:setPosition(ccp(230,G_VisibleSizeHeight-800+offy));
    self.bgLayer:addChild(gemIcon,2)
    
    local gemLabel=GetTTFLabel("50",lbSize)
    gemLabel:setAnchorPoint(ccp(0,0.5));
    gemLabel:setPosition(gemIcon:getContentSize().width,gemIcon:getContentSize().height/2)
    gemIcon:addChild(gemLabel,2)
    if isVipPrivilege==true then
        gemLabel:setString(gemsNum)
    end
    
    local function touch1(object,name,tag)
        if tag==1 then
            self.applyTypeSp:setPosition(160,G_VisibleSizeHeight-560+offy)
            self.applyType=0;
        else
            self.applyTypeSp:setPosition(160,G_VisibleSizeHeight-620+offy)
            self.applyType=1;
        end
    end
    local typeSp1=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",touch1)
    typeSp1:setAnchorPoint(ccp(0,0.5));
    typeSp1:setTag(1)
    typeSp1:setTouchPriority(-(self.layerNum-1)*20-4);
    typeSp1:setPosition(160,G_VisibleSizeHeight-560+offy)
    self.bgLayer:addChild(typeSp1,2)
    
    local typeSp2=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",touch1)
    typeSp2:setAnchorPoint(ccp(0,0.5));
    typeSp2:setTag(2)
    typeSp2:setTouchPriority(-(self.layerNum-1)*20-4);
    typeSp2:setPosition(160,G_VisibleSizeHeight-620+offy)
    self.bgLayer:addChild(typeSp2,2)
    
    local function touch2(hd,fn,idx)

    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),touch2)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 200))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-4)
    backSprie:setPosition(ccp(self.bgLayer:getContentSize().width/2, G_VisibleSizeHeight-625+offy))
    backSprie:setOpacity(0)
    self.bgLayer:addChild(backSprie,1)
    
    local backSprie2 =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20,20,10,10),touch2)
    backSprie2:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60, 150))
    backSprie2:setIsSallow(false)
    backSprie2:setTouchPriority(-(self.layerNum-1)*20-4)
    backSprie2:setPosition(ccp(self.bgLayer:getContentSize().width/2, G_VisibleSizeHeight-810+offy))
    backSprie2:setOpacity(0)
    self.bgLayer:addChild(backSprie2,1)
    
    
    local function touch3(object,name,tag)
        if tag==3 then
            self.needTypeSp:setPosition(160,G_VisibleSizeHeight-740+offy)
            self.needType=1
        else
            self.needTypeSp:setPosition(160,G_VisibleSizeHeight-800+offy)
            self.needType=2
        end
    end
    local needSp1=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",touch3)
    needSp1:setAnchorPoint(ccp(0,0.5));
    needSp1:setTag(3)
    needSp1:setTouchPriority(-(self.layerNum-1)*20-4);
    needSp1:setPosition(160,G_VisibleSizeHeight-740+offy)
    self.bgLayer:addChild(needSp1,2)
    
    local needSp2=LuaCCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png",touch3)
    needSp2:setAnchorPoint(ccp(0,0.5));
    needSp2:setTag(4)
    needSp2:setTouchPriority(-(self.layerNum-1)*20-4);
    needSp2:setPosition(160,G_VisibleSizeHeight-800+offy)
    self.bgLayer:addChild(needSp2,2)
    
    self.applyTypeSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png");
    self.needTypeSp=CCSprite:createWithSpriteFrameName("LegionCheckBtn.png");
    self.applyTypeSp:setAnchorPoint(ccp(0,0.5));
    self.needTypeSp:setAnchorPoint(ccp(0,0.5));
    self.applyTypeSp:setPosition(160,G_VisibleSizeHeight-560+offy)
    self.needTypeSp:setPosition(160,G_VisibleSizeHeight-740+offy)

    self.bgLayer:addChild(self.applyTypeSp,3)
    self.bgLayer:addChild(self.needTypeSp,3)

    --创建公会的方法
    local function createAlliance()
        local coolingTime = playerVoApi:getCreateAllianceCoolingTime()
        if coolingTime > 0 then
            G_showTipsDialog(getlocal("create_alliance_timetip",{GetTimeStr(coolingTime)}))
            do return end
        end
        --前端先判断名称是否符合规则 字符数大于2 小于13 首字母不能为数字
        local nameCount=G_utfstrlen(self.allianceName,true)
        if G_match(self.allianceName)~=nil then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("alliance_illegalCharacters"),true,6,G_ColorRed)
            do 
                return
            end
        end
        --是否为空字符
        if self.allianceName=="" then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("alliance_nameNoNull"),true,6,G_ColorRed)
            do 
                return
            end
        end
        local hasEmjoy=G_checkEmjoy(self.allianceName)
        if hasEmjoy==false then
            do return end
        end
        --首字母是否为数字
        local strFisrt=G_stringGetAt(self.allianceName,0,1)
        if tonumber(strFisrt)~=nil then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("firstCharNoNum"),true,6,G_ColorRed)
            do 
                return
            end
        end
        if PlatformManage~=nil then
            if  platCfg.platCfgKeyWord[G_curPlatName()]~=nil  then --设置屏蔽字
                if keyWordCfg:keyWordsJudge(self.allianceName,false)==false then
                    G_showTipsDialog(getlocal("alliance_name_illegitmacy"))
                    do return end
                end
                if keyWordCfg:keyWordsJudge(self.textValue,false) == false then
                    G_showTipsDialog(getlocal("alliance_desc_illegitmacy"))
                    do return end
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
        
        local textCount=G_utfstrlen(self.textValue)
        if nameCount>100 then
            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("namelengthwrong"),true,6,G_ColorRed)
            do 
                return
            end
        end
        --判断资源是否足够
        if self.needType==2 then
            local isEnough=true
            if isVipPrivilege==true and gemsNum then
                if playerVoApi:getGems()>=gemsNum then
                    isEnough=true
                else
                    isEnough=false
                end
            elseif playerVoApi:getGems()<50 then
                isEnough=false
            end
            if isEnough==false then
                local function jumpGemDlg()
                    vipVoApi:showRechargeDialog(self.layerNum+1)
                    self.parentDialog:close()

                end
                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),jumpGemDlg,getlocal("dialog_title_prompt"),getlocal("alliance_createAllianceNoGem"),nil,self.layerNum+1)

                do
                    return
                end
            end
        elseif self.needType==1 then
            if playerVoApi:getGold()<500000 or playerVoApi:getR1()<500000 or playerVoApi:getR2()<500000 or playerVoApi:getR3()<500000 then
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("resourcelimit"),nil,self.layerNum+1)


                do
                    return
                end
                
            end
        end
        
        local function allianceCreateCallback(fn,data)
            if base:checkServerData(data)==true then
                self.parentDialog:close(true)
                local function createcCallbackHandler(fn,data)

                    local alliance=allianceVoApi:getSelfAlliance()
                    playerVoApi:setPlayerAid(alliance.aid)  --重置公会id
                    playerVoApi:setPlayerIsATag(0)
                    allianceVoApi:removeApply()
                    
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_chuangjianTip",{allianceVoApi:getSelfAlliance().name}),30)
                    if alliance and alliance.name then
                        local params = {allianceName=alliance.name}
                        chatVoApi:sendUpdateMessage(4,params)
                    end
                    allianceVoApi:clearRankAndGoodList()
                    worldScene:updateAllianceName()
                    worldScene:addAllianceSp()
                    --工会活动刷新数据
                    activityVoApi:updateAc("fbReward")
                    activityVoApi:updateAc("allianceLevel")
                    activityVoApi:updateAc("allianceFight")

                    --刷新军团资金招募活动数据
                    local vo = activityVoApi:getActivityVo("fundsRecruit")
                    if vo~=nil and activityVoApi:isStart(vo)==true then
                        local function updateCallback(fn,data)
                            local ret,sData=base:checkServerData(data)
                            if ret==true then
                                acFundsRecruitVoApi:updateData(sData.data)
                            end
                        end
                        socketHelper:activeFundsRecruit("updateTime",updateCallback)
                    end
                end
                base.allianceTime=nil
                G_getAlliance(createcCallbackHandler)

            end

        end
        socketHelper:allianceCreate(self.needType,self.textValue,self.allianceName,self.applyType,allianceCreateCallback)    
    end
    local btnoffy = G_is5x(0,-30)
    self.createBtn = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",createAlliance,nil,getlocal("createRole"),25)
    local createMenu=CCMenu:createWithItem(self.createBtn);
    createMenu:setPosition(ccp(G_VisibleSizeWidth/2,100+btnoffy))
    createMenu:setTouchPriority(-(self.layerNum-1)*20-4);
    self.bgLayer:addChild(createMenu)

    self:tick()
end

function allianceDialogCreateTab:tick()
    local coolingTime = playerVoApi:getCreateAllianceCoolingTime()
    if coolingTime > 0 then
        if self.createTimeLb == nil or tolua.cast(self.createTimeLb,"CCLabelTTF") == nil then
            local offy = G_is5x(0,-30)
            local createTimeLb = GetTTFLabelWrap(getlocal("create_alliance_timetip"),22,CCSizeMake(G_VisibleSizeWidth-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
            createTimeLb:setAnchorPoint(ccp(0.5,0))
            createTimeLb:setPosition(G_VisibleSizeWidth/2,150+offy)
            createTimeLb:setColor(G_ColorRed)
            self.bgLayer:addChild(createTimeLb,2)
            self.createTimeLb = createTimeLb
        end
        self.createTimeLb:setString(getlocal("create_alliance_timetip",{GetTimeStr(coolingTime)}))
    else
        if self.createTimeLb and tolua.cast(self.createTimeLb,"CCLabelTTF") then
            self.createTimeLb:removeFromParentAndCleanup(true)
            self.createTimeLb = nil
        end
    end
end

--用户处理特殊需求,没有可以不写此方法
function allianceDialogCreateTab:doUserHandler()

end

function allianceDialogCreateTab:dispose()
    
    self.bgLayer:removeFromParentAndCleanup(true)
    self.bgLayer=nil;
    self.layerNum=nil;
    self.createBtn=nil;
    self.applyType=nil;
    self.needType=nil;
    self.applyTypeSp=nil;
    self.needTypeSp=nil;
    self.allianceName=nil;
    self.allianceDeclaration=nil;
    self.editBox=nil;
    self.textValue=nil;
    self.createTimeLb = nil    
end
