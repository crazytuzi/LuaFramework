acLmqrjSmallDialog=smallDialog:new()

function acLmqrjSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.layerNum = nil
	nc.bgSize = nil
	return nc
end

function acLmqrjSmallDialog:showGiving(layerNum,titleStr,curShowBoxIndex,btnCallback)
	local sd = acLmqrjSmallDialog:new()
	sd:initGivingUI(layerNum,titleStr,curShowBoxIndex,btnCallback)
	return sd
end

function acLmqrjSmallDialog:initGivingUI(layerNum,titleStr,curShowBoxIndex,btnCallback)
	self.layerNum = layerNum
	self.bgSize=CCSizeMake(560,800)

	local fontSize = 32
    local function close()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local dialogBg,titleBg,titleLb,closeBtnItem,closeBtn=G_getNewDialogBg(self.bgSize,titleStr,fontSize,nil,layerNum,true,close,nil)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    self.dialogLayer:addChild(self.bgLayer,2)

    -- 点击阴影区域关闭面板
    local function touchBackSpFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        -- return self:close()
    end
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchBackSpFunc)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    -- touchDialogBg:setOpacity(50)
    touchDialogBg:setAnchorPoint(ccp(0.5,0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    self.dialogLayer:addChild(touchDialogBg,1)

    local friendListBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
    friendListBg:setContentSize(CCSizeMake(self.bgSize.width-30,self.bgSize.height-430))
    friendListBg:setAnchorPoint(ccp(0.5,1))
    friendListBg:setPosition(self.bgSize.width/2,self.bgSize.height-75)
    self.bgLayer:addChild(friendListBg)

    local nameLb=GetTTFLabel(getlocal("alliance_scene_button_info_name"),20)
    local lvLb=GetTTFLabel(getlocal("RankScene_level"),20)
    local stateLb=GetTTFLabel(getlocal("state"),20)
    nameLb:setColor(G_ColorYellowPro)
    lvLb:setColor(G_ColorYellowPro)
    stateLb:setColor(G_ColorYellowPro)
    nameLb:setPosition(friendListBg:getContentSize().width/4-30,friendListBg:getContentSize().height-20)
    lvLb:setPosition(friendListBg:getContentSize().width/2,friendListBg:getContentSize().height-20)
    stateLb:setPosition(friendListBg:getContentSize().width/4*3+30,friendListBg:getContentSize().height-20)
    friendListBg:addChild(nameLb)
    friendListBg:addChild(lvLb)
    friendListBg:addChild(stateLb)

    local function createCheckBox(touchPriority,pos,callback)
    	local function operateHandler(...)
    		if callback then
    			callback(...)
    		end
	    end
	    local menu=CCMenu:create()
	    local switchSp1 = CCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
	    local switchSp2 = CCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
	    local menuItemSp1 = CCMenuItemSprite:create(switchSp1,switchSp2)
	    local switchSp3 = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
	    local switchSp4 = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
	    local menuItemSp2 = CCMenuItemSprite:create(switchSp3,switchSp4)
	    local checkBox = CCMenuItemToggle:create(menuItemSp1)
	    checkBox:addSubItem(menuItemSp2)
	    checkBox:setAnchorPoint(CCPointMake(0.5,0.5))
	    checkBox:registerScriptTapHandler(operateHandler)
	    menu:addChild(checkBox)
	    menu:setPosition(pos)
	    menu:setTouchPriority(touchPriority)
	    return checkBox,menu
    end

    local friendsTb=G_getMailList()
    local function sortFriendsTb()
        local _tb1={}
        local _tb2={}
        for k,v in pairs(friendsTb) do
            if acLmqrjVoApi:isGiving(v.uid,curShowBoxIndex) then
                table.insert(_tb2,v)
            else
                table.insert(_tb1,v)
            end
        end
        table.sort(_tb1, function(a,b) return tonumber(a.level)>tonumber(b.level) end)
        table.sort(_tb2, function(a,b) return tonumber(a.level)>tonumber(b.level) end)
        friendsTb=nil
        friendsTb={}
        for k,v in pairs(_tb1) do table.insert(friendsTb,v) end
        for k,v in pairs(_tb2) do table.insert(friendsTb,v) end
    end
    sortFriendsTb()
    if SizeOfTable(friendsTb)==0 then
        local noLabel=GetTTFLabel(getlocal("noFriends"),24)
        noLabel:setPosition(friendListBg:getContentSize().width/2,friendListBg:getContentSize().height/2)
        noLabel:setColor(G_ColorGray)
        friendListBg:addChild(noLabel)
    end

    local checkBoxTb={}
    local _curSelectedUid
    local tvSize=CCSizeMake(friendListBg:getContentSize().width,lvLb:getPositionY()-20)
    local function tvCallBack(handler,fn,index,cel)
        if fn=="numberOfCellsInTableView" then
            return SizeOfTable(friendsTb)
        elseif fn=="tableCellSizeForIndex" then
            return  CCSizeMake(tvSize.width,65)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            local cellW,cellH=tvSize.width,65

            local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
	        lineSp:setContentSize(CCSizeMake(cellW-18, 3))
	        lineSp:ignoreAnchorPointForPosition(false)
	        lineSp:setAnchorPoint(ccp(0.5,1))
	        lineSp:setPosition(cellW/2,cellH)
	        cell:addChild(lineSp)

	        local nameStr=friendsTb[index+1].name
	        local levelStr=friendsTb[index+1].level
	        local uid=friendsTb[index+1].uid

	    	local nameLabel = GetTTFLabel(nameStr,20)
	        nameLabel:setPosition(nameLb:getPositionX(),cellH/2)
	        cell:addChild(nameLabel)

	        local levelLabel = GetTTFLabel(tostring(levelStr),20)
	        levelLabel:setPosition(lvLb:getPositionX(),cellH/2)
	        cell:addChild(levelLabel)

            if acLmqrjVoApi:isGiving(uid,curShowBoxIndex) then
                local lb = GetTTFLabel(getlocal("alien_tech_alreadySend"),20)
                lb:setPosition(stateLb:getPositionX(),cellH/2)
                lb:setColor(G_ColorGray)
                cell:addChild(lb)
            else
                local checkBox, menu
    		    local function onClickCheckBox()
                    for k,v in pairs(checkBoxTb) do
                        if checkBox~=v then
                            v:setSelectedIndex(0)
                        end
                    end
                    if checkBox:getSelectedIndex()==0 then
                        _curSelectedUid=nil
                    else
                        _curSelectedUid=uid
                    end
    		    end
                checkBox, menu=createCheckBox(-(self.layerNum-1)*20-4,ccp(stateLb:getPositionX(),cellH/2),onClickCheckBox)
    		    cell:addChild(menu)
                table.insert(checkBoxTb,checkBox)
            end

            if (index+1)==SizeOfTable(friendsTb) then
                local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
                lineSp:setContentSize(CCSizeMake(cellW-18, 3))
                lineSp:ignoreAnchorPointForPosition(false)
                lineSp:setAnchorPoint(ccp(0.5,0))
                lineSp:setPosition(cellW/2,0)
                cell:addChild(lineSp)
            end

	    	return cell
        elseif fn=="ccTouchBegan" then
            -- isMoved=false
            return true
        elseif fn=="ccTouchMoved" then
            -- isMoved=true
        elseif fn=="ccTouchEnded"  then
        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    local tv=LuaCCTableView:createWithEventHandler(hd,tvSize,nil)
    tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    tv:setMaxDisToBottomOrTop(100)
    friendListBg:addChild(tv)

    local boxInfoBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
    boxInfoBg:setContentSize(CCSizeMake(self.bgSize.width-30,150))
    boxInfoBg:setAnchorPoint(ccp(0.5,1))
    boxInfoBg:setPosition(self.bgSize.width/2,friendListBg:getPositionY()-friendListBg:getContentSize().height-5)
    self.bgLayer:addChild(boxInfoBg)

    local boxData=acLmqrjVoApi:getBoxTb(curShowBoxIndex)
    local boxSp=CCSprite:createWithSpriteFrameName(boxData[1])
    boxSp:setAnchorPoint(ccp(0,0.5))
    boxSp:setPosition(20,boxInfoBg:getContentSize().height/2-10)
    boxSp:setScale(0.8)
    boxInfoBg:addChild(boxSp)
    local boxLidSp=CCSprite:createWithSpriteFrameName(boxData[2])
    if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
       boxLidSp:setPosition(boxSp:getContentSize().width/2+7,boxSp:getContentSize().height-7)
    else
	   boxLidSp:setPosition(boxSp:getContentSize().width/2,boxSp:getContentSize().height/2+30)
    end
	boxSp:addChild(boxLidSp)

	local ownedLb=GetTTFLabel(getlocal("propOwned"),22)
	ownedLb:setAnchorPoint(ccp(0,0.5))
	ownedLb:setPositionX(boxSp:getPositionX()+boxSp:getContentSize().width+30)
	boxInfoBg:addChild(ownedLb)
	local buyLb=GetTTFLabel(getlocal("buy")..":",22)
	buyLb:setAnchorPoint(ccp(0,0.5))
	buyLb:setPositionX(boxSp:getPositionX()+boxSp:getContentSize().width+30)
	boxInfoBg:addChild(buyLb)

    local _curBoxNum=acLmqrjVoApi:getBoxNum(curShowBoxIndex)
    local _boxPrice=acLmqrjVoApi:getOneCost(curShowBoxIndex)
    local _sendCost=acLmqrjVoApi:getSendCost(curShowBoxIndex)
    local _totalPrice=0
    local ownedCheckBox, ownedMenu
    local buyCheckBox, buyMenu
    local totalPriceLb
    local function onClickCheckBox(tag,obj)
        if obj==ownedCheckBox and ownedCheckBox:getSelectedIndex()==1 then
            if _curBoxNum<=0 then
                ownedCheckBox:setSelectedIndex(0)
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_lmqrj_givingFriendsTips2"),30)
                do return end
            end
            buyCheckBox:setSelectedIndex(0)
        end
        _totalPrice=0
        if obj==buyCheckBox and buyCheckBox:getSelectedIndex()==1 then
            ownedCheckBox:setSelectedIndex(0)
            _totalPrice=_totalPrice+_boxPrice
        end
        _totalPrice=_totalPrice+_sendCost
        totalPriceLb:setString(getlocal("activity_lmqrj_totalPrice",{_totalPrice}))
    end
    ownedCheckBox, ownedMenu=createCheckBox(-(self.layerNum-1)*20-4,ccp(stateLb:getPositionX(),boxInfoBg:getContentSize().height/2+30),onClickCheckBox)
    boxInfoBg:addChild(ownedMenu)

    buyCheckBox, buyMenu=createCheckBox(-(self.layerNum-1)*20-4,ccp(stateLb:getPositionX(),boxInfoBg:getContentSize().height/2-30),onClickCheckBox)
    boxInfoBg:addChild(buyMenu)

    ownedLb:setPositionY(ownedMenu:getPositionY())
    buyLb:setPositionY(buyMenu:getPositionY())
    local ownedNumLb=GetTTFLabel(tostring(_curBoxNum),22)
    ownedNumLb:setAnchorPoint(ccp(1,0.5))
    ownedNumLb:setPosition(ownedMenu:getPositionX()-55,ownedMenu:getPositionY())
    boxInfoBg:addChild(ownedNumLb)
    local goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
    local goldLb=GetTTFLabel(tostring(_boxPrice),22)
    goldSp:setAnchorPoint(ccp(1,0.5))
    goldLb:setAnchorPoint(ccp(1,0.5))
    goldSp:setPosition(buyMenu:getPositionX()-35,buyMenu:getPositionY())
    goldLb:setPosition(goldSp:getPositionX()-goldSp:getContentSize().width,goldSp:getPositionY())
    boxInfoBg:addChild(goldSp)
    boxInfoBg:addChild(goldLb)

    if _curBoxNum>0 then
        ownedCheckBox:setSelectedIndex(1)
    else
        buyCheckBox:setSelectedIndex(1)
        _totalPrice=_totalPrice+_boxPrice
    end

    local sendPriceLb=GetTTFLabel(getlocal("activity_lmqrj_sendPrice"),22)
    sendPriceLb:setAnchorPoint(ccp(0,0.5))
    sendPriceLb:setPosition(50,boxInfoBg:getPositionY()-boxInfoBg:getContentSize().height-sendPriceLb:getContentSize().height)
    self.bgLayer:addChild(sendPriceLb)
    local sendPriceGold=CCSprite:createWithSpriteFrameName("IconGold.png")
    sendPriceGold:setAnchorPoint(ccp(0,0.5))
    sendPriceGold:setPosition(self.bgSize.width-75,sendPriceLb:getPositionY())
    self.bgLayer:addChild(sendPriceGold)
    _totalPrice=_totalPrice+_sendCost
    local sendPrice=GetTTFLabel(tostring(_sendCost),22)
    sendPrice:setAnchorPoint(ccp(1,0.5))
    sendPrice:setPosition(sendPriceGold:getPosition())
    self.bgLayer:addChild(sendPrice)

	local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
    lineSp:setContentSize(CCSizeMake(self.bgSize.width-60, 2))
    lineSp:setAnchorPoint(ccp(0.5,1))
    lineSp:setPosition(self.bgSize.width/2,sendPriceLb:getPositionY()-sendPriceLb:getContentSize().height)
    self.bgLayer:addChild(lineSp)

    local _descLbKey="activity_lmqrj_givingDesc"
    if acLmqrjVoApi and acLmqrjVoApi:getVersion()==2 then
        _descLbKey="activity_lmqrj_givingDesc_v2"
    end
    local descLb=GetTTFLabel(getlocal(_descLbKey,{acLmqrjVoApi:getSendGiftScore(curShowBoxIndex)}),22)
    descLb:setPosition(self.bgSize.width/2,lineSp:getPositionY()-descLb:getContentSize().height)
    descLb:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(descLb)

    local totalPriceGold=CCSprite:createWithSpriteFrameName("IconGold.png")
    totalPriceLb=GetTTFLabel(getlocal("activity_lmqrj_totalPrice",{_totalPrice}),22)
    local _startPosX=(self.bgSize.width-(totalPriceLb:getContentSize().width+totalPriceGold:getContentSize().width))/2
    totalPriceLb:setAnchorPoint(ccp(1,0.5))
    totalPriceLb:setPosition(_startPosX+totalPriceLb:getContentSize().width,descLb:getPositionY()-descLb:getContentSize().height-5)
    totalPriceGold:setAnchorPoint(ccp(0,0.5))
    totalPriceGold:setPosition(totalPriceLb:getPosition())
    self.bgLayer:addChild(totalPriceLb)
    self.bgLayer:addChild(totalPriceGold)

    local function giveUpHandler(tag,obj)
    	if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        
        if playerVoApi:getPlayerLevel() < acLmqrjVoApi:getGiveLevelLimit() then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_fyss_givingLimitTip",{acLmqrjVoApi:getGiveLevelLimit()}),30)
            do return end
        end
        if _curSelectedUid==nil then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_lmqrj_givingFriendsTips"),30)
            do return end
        end
        if ownedCheckBox:getSelectedIndex()==0 and buyCheckBox:getSelectedIndex()==0 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_lmqrj_givingFriendsTips1"),30)
            do return end
        end
        local _giveType=2 --1:数量  2:金币
        if ownedCheckBox:getSelectedIndex()==1 then
            if _curBoxNum<=0 then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_lmqrj_givingFriendsTips2"),30)
                do return end
            end
            _giveType=1
        end
        if playerVoApi:getGems()<_totalPrice then
            GemsNotEnoughDialog(nil,nil,_totalPrice-playerVoApi:getGems(),self.layerNum+1,_totalPrice)
            do return end
        end

        local function onSureLogic()
            socketHelper:activeLmqrjGive({_curSelectedUid,curShowBoxIndex,_giveType},function(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    playerVoApi:setGems(playerVoApi:getGems()-_totalPrice)
                    if sData and sData.data then
                        acLmqrjVoApi:updateData(sData.data)
                    end
                    --赠送成功
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("friend_send_success"),30)
                    acLmqrjVoApi:updateGivingTab(_curSelectedUid,curShowBoxIndex)
                    sortFriendsTb()
                    if tv then
                        checkBoxTb=nil
                        checkBoxTb={}
                        tv:reloadData()
                        _curSelectedUid=nil
                    end
                    if _giveType==1 then
                        _curBoxNum=acLmqrjVoApi:getBoxNum(curShowBoxIndex)
                        ownedNumLb:setString(tostring(_curBoxNum))
                        if _curBoxNum<=0 then
                            ownedCheckBox:setSelectedIndex(0)
                        end
                    end
                    if btnCallback then
                        btnCallback()
                    end
                end
            end)
        end
        local function secondTipFunc(sbFlag)
            local sValue=base.serverTime .. "_" .. sbFlag
            G_changePopFlag("acLmqrjGiveDialog",sValue)
        end
        if G_isPopBoard("acLmqrjGiveDialog") then
            G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{_totalPrice}),true,onSureLogic,secondTipFunc)
        else
            onSureLogic()
        end

    end
    local btnScale=0.8
    local giveUpBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",giveUpHandler,11,getlocal("rechargeGifts_giveLabel"),24/btnScale)
    giveUpBtn:setScale(btnScale)
    giveUpBtn:setAnchorPoint(ccp(0.5,1))
    local menu=CCMenu:createWithItem(giveUpBtn)
    menu:setTouchPriority(-(self.layerNum-1)*20-4)
    menu:setPosition(ccp(self.bgSize.width/2,totalPriceGold:getPositionY()-totalPriceGold:getContentSize().height/2-5))
    self.bgLayer:addChild(menu)

    sceneGame:addChild(self.dialogLayer,self.layerNum)
end

function acLmqrjSmallDialog:showLogDialog(layerNum,titleStr,isuseami,logList,zslogList)
    local sd = acLmqrjSmallDialog:new()
    sd:initLogDialog(layerNum,titleStr,isuseami,logList,zslogList)
    return sd
end

function acLmqrjSmallDialog:initLogDialog(layerNum,titleStr,isuseami,logList,zslogList)
    self.layerNum=layerNum
    self.isUseAmi=isuseami
    self.bgSize=CCSizeMake(560,750)

    local fontSize = 32
    local function close()
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local dialogBg,titleBg,titleLb,closeBtnItem,closeBtn=G_getNewDialogBg(self.bgSize,titleStr,fontSize,nil,layerNum,true,close,nil)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setAnchorPoint(ccp(0.5,0.5))
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    self.dialogLayer:addChild(self.bgLayer,2)

    -- 点击阴影区域关闭面板
    local function touchBackSpFunc()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        -- return self:close()
    end
    -- 非面板区域的阴影
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchBackSpFunc)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    -- touchDialogBg:setOpacity(50)
    touchDialogBg:setAnchorPoint(ccp(0.5,0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    self.dialogLayer:addChild(touchDialogBg,1)

    local title2=GetTTFLabelWrap(titleStr2,22,CCSize(self.bgSize.width-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    title2:setAnchorPoint(ccp(0,1))
    title2:setPosition(30,self.bgSize.height-80)
    self.bgLayer:addChild(title2)

    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
    tvBg:setContentSize(CCSizeMake(self.bgSize.width-40,self.bgSize.height-280))
    tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setPosition(self.bgSize.width/2,self.bgSize.height-125)
    self.bgLayer:addChild(tvBg)
    tvBg:setVisible(false)

    local noRecordLb=GetTTFLabel(getlocal("activity_tccx_no_record"),22)
    noRecordLb:setPosition(self.bgSize.width/2,tvBg:getPositionY()-tvBg:getContentSize().height/2)
    noRecordLb:setColor(G_ColorGray)
    self.bgLayer:addChild(noRecordLb,1)
    noRecordLb:setVisible(false)

    local logSize=SizeOfTable(logList)
    local zslogSize=SizeOfTable(zslogList)
    local tv
    local _curSelectedTabIndex=1
    local allTabBtn={}
    local function tabClick(idx)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        tvBg:setVisible(false)
        noRecordLb:setVisible(false)
        for k,v in pairs(allTabBtn) do
            if v:getTag()==idx then
                v:setEnabled(false)
                _curSelectedTabIndex=idx
            else
                v:setEnabled(true)
            end
        end
        if _curSelectedTabIndex==1 then
            if logSize==0 then
                noRecordLb:setVisible(true)
            end
        elseif _curSelectedTabIndex==2 then
            tvBg:setVisible(true)
            if zslogSize==0 then
                noRecordLb:setVisible(true)
            end
        end
        if tv then
            tv:reloadData()
        end
    end
    local tabBtn=CCMenu:create()
    for i=1,2 do
        local tabBtnItem = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
        tabBtnItem:setAnchorPoint(ccp(0,1))
        tabBtnItem:setPosition(20+(i-1)*(tabBtnItem:getContentSize().width+4),self.bgSize.height-75)
        tabBtn:addChild(tabBtnItem)
        tabBtnItem:setTag(i)

        local titleStr=getlocal("activity_lmqrj_smallDialogTabTitle"..i)
        local lb=GetTTFLabelWrap(titleStr,24,CCSizeMake(tabBtnItem:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
        lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
        tabBtnItem:addChild(lb,1)

        tabBtnItem:registerScriptTapHandler(tabClick)
        allTabBtn[i]=tabBtnItem
        if i==1 then
            tabBtnItem:setEnabled(false)
        end
    end
    tabBtn:setPosition(0,0)
    tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(tabBtn)
    if logSize==0 then
        noRecordLb:setVisible(true)
    end

    local rowNum=6 --每行最多显示6个
    local itemSize=70
    local spaceX,spaceY=10,10
    local tvSize=CCSizeMake(self.bgSize.width-40,tvBg:getContentSize().height)
    local logCellHeightTb={}
    local function initLogCellHeight()
        for k, v in pairs(logList) do
            local height=0
            local titleStr=v.titleStr or ""
            -- local color=v.titleColor or G_ColorWhite
            local tsize=v.titleSize or 22
            local timeLb=GetTTFLabel(G_getDataTimeStr(v.time),22)
            local titleW=tvSize.width-timeLb:getContentSize().width-40
            local titleLb=GetTTFLabelWrap(titleStr,tsize,CCSizeMake(titleW,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            height=height+(titleLb:getContentSize().height+20)
            height=height+10
            local content=v.content
            local count=SizeOfTable(content)
            if count%rowNum>0 then
                count=math.floor(count/rowNum)+1
            else
                count=math.floor(count/rowNum)
            end
            height=height+(count*itemSize+(count-1)*spaceY)
            height=height+10
            table.insert(logCellHeightTb,height+10)
        end
    end
    initLogCellHeight()
    local zslogCellHeight={}
    local function initZslogCellHeight()
        for k, v in pairs(zslogList) do
            local height=0
            local msgStr=v.msgStr or ""
            -- local msgColor=v.msgColor or G_ColorWhite
            local msgSize=v.msgSize or 22
            local timeLb=GetTTFLabel(G_getDataTimeStr(v.time),22)
            local msgW=tvSize.width-timeLb:getContentSize().width-30
            local msgLb=GetTTFLabelWrap(msgStr,msgSize,CCSizeMake(msgW,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
            height=height+(msgLb:getContentSize().height+8*2)
            table.insert(zslogCellHeight,height)
        end
    end
    initZslogCellHeight()

    local function tvCallBack(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            if _curSelectedTabIndex==1 then
                return logSize
            elseif _curSelectedTabIndex==2 then
                return zslogSize
            end
            return 0
        elseif fn=="tableCellSizeForIndex" then
            if _curSelectedTabIndex==1 then
                return CCSize(tvSize.width,logCellHeightTb[idx+1])
            elseif _curSelectedTabIndex==2 then
                return CCSizeMake(tvSize.width,zslogCellHeight[idx+1])
            end
            return CCSizeMake(0,0)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()

            if _curSelectedTabIndex==1 then
                local cellW=tvSize.width
                local cellH=logCellHeightTb[idx+1]

                local cellBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function()end)
                cellBg:setContentSize(CCSizeMake(cellW,cellH-10))
                cellBg:setAnchorPoint(ccp(0.5,1))
                cellBg:setPosition(ccp(cellW/2,cellH))
                cell:addChild(cellBg)
                local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
                pointSp1:setPosition(ccp(5,cellBg:getContentSize().height/2))
                cellBg:addChild(pointSp1)
                local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
                pointSp2:setPosition(ccp(cellBg:getContentSize().width-5,cellBg:getContentSize().height/2))
                cellBg:addChild(pointSp2)

                local log=logList[idx+1]
                local titleStr=log.titleStr or ""
                local color=log.titleColor or G_ColorWhite
                local tsize=log.titleSize or 22
                local timeLb=GetTTFLabel(G_getDataTimeStr(log.time),tsize)
                local titleW=tvSize.width-timeLb:getContentSize().width-40
                local titleLb=GetTTFLabelWrap(titleStr,tsize,CCSizeMake(titleW,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                titleLb:setAnchorPoint(ccp(0,1))
                titleLb:setPosition(10,cellBg:getContentSize().height-10)
                titleLb:setColor(color)
                cellBg:addChild(titleLb)
                timeLb:setAnchorPoint(ccp(1,0.5))
                timeLb:setPosition(cellBg:getContentSize().width-10,titleLb:getPositionY()-titleLb:getContentSize().height/2)
                timeLb:setColor(color)
                cellBg:addChild(timeLb)

                local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("new_cutline.png",CCRect(27,3,1,1),function ()end)
                lineSp:setContentSize(CCSizeMake(cellBg:getContentSize().width-20,lineSp:getContentSize().height))
                lineSp:setPosition(ccp(cellBg:getContentSize().width/2,titleLb:getPositionY()-titleLb:getContentSize().height-10))
                cellBg:addChild(lineSp)

                local firstPosX=(cellBg:getContentSize().width-(itemSize*rowNum+spaceX*(rowNum-1)))/2
                local firstPosY=lineSp:getPositionY()-10
                local content=log.content
                for k, reward in pairs(content) do
                    local function showNewPropInfo()
                        G_showNewPropInfo(self.layerNum+1,true,true,nil,reward)
                    end
                    local icon,scale=G_getItemIcon(reward,itemSize,false,self.layerNum,showNewPropInfo)
                    if icon then
                        icon:setAnchorPoint(ccp(0,1))
                        icon:setPosition(firstPosX+((k-1)%rowNum)*(itemSize+spaceX),firstPosY-math.floor(((k-1)/rowNum))*(itemSize+spaceY))
                        icon:setTouchPriority(-(self.layerNum-1)*20-3)
                        icon:setIsSallow(false)
                        cellBg:addChild(icon,1)
                        local numLb=GetTTFLabel(FormatNumber(reward.num),23)
                        numLb:setAnchorPoint(ccp(1,0))
                        numLb:setScale(1/scale)
                        numLb:setPosition(ccp(icon:getContentSize().width-5,0))
                        icon:addChild(numLb,4)
                        local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
                        numBg:setAnchorPoint(ccp(1,0))
                        numBg:setContentSize(CCSizeMake(numLb:getContentSize().width*numLb:getScale()+5,numLb:getContentSize().height*numLb:getScale()-5))
                        numBg:setPosition(ccp(icon:getContentSize().width-5,5))
                        numBg:setOpacity(150)
                        icon:addChild(numBg,3)
                    end
                end
            elseif _curSelectedTabIndex==2 then
                local cellW=tvSize.width
                local cellH=zslogCellHeight[idx+1]
                local zslog=zslogList[idx+1]
                local msgStr=zslog.msgStr or ""
                local msgColor=zslog.msgColor or G_ColorWhite
                local msgSize=zslog.msgSize or 22
                local timeLb=GetTTFLabel(G_getDataTimeStr(zslog.time),msgSize)
                local msgW=tvSize.width-timeLb:getContentSize().width-30
                local msgLb=GetTTFLabelWrap(msgStr,msgSize,CCSizeMake(msgW,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
                msgLb:setColor(msgColor)
                timeLb:setColor(msgColor)
                timeLb:setAnchorPoint(ccp(0,0.5))
                msgLb:setAnchorPoint(ccp(0,0.5))
                timeLb:setPosition(5,cellH/2)
                msgLb:setPosition(timeLb:getPositionX()+timeLb:getContentSize().width+20,cellH/2)
                cell:addChild(timeLb)
                cell:addChild(msgLb)

                local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
                lineSp:setContentSize(CCSizeMake(cellW-10, 3))
                lineSp:ignoreAnchorPointForPosition(false)
                lineSp:setAnchorPoint(ccp(0.5,0))
                lineSp:setPosition(cellW/2,0)
                cell:addChild(lineSp)
            end
            
            return cell
        elseif fn=="ccTouchBegan" then
            return true
        elseif fn=="ccTouchMoved" then
        elseif fn=="ccTouchEnded"  then

        end
    end
    local hd=LuaEventHandler:createHandler(tvCallBack)
    tv=LuaCCTableView:createWithEventHandler(hd,tvSize,nil)
    tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    tv:setPosition(ccp(20,tvBg:getPositionY()-tvBg:getContentSize().height))
    self.bgLayer:addChild(tv,2)
    tv:setMaxDisToBottomOrTop(120)

    local noticeLb=GetTTFLabelWrap(getlocal("activity_xinchunhongbao_repordMax",{10}),24,CCSizeMake(self.bgSize.width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    noticeLb:setAnchorPoint(ccp(0.5,0.5))
    noticeLb:setPosition(ccp(self.bgSize.width/2,123))
    noticeLb:setColor(G_ColorRed)
    self.bgLayer:addChild(noticeLb)

    local function buttonHandler(...)
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if btnCallback then
            btnCallback(...)
        end
        self:close()
    end
    local buttonScale=0.8
    local button=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",buttonHandler,11,getlocal("ok"),24/buttonScale)
    button:setScale(buttonScale)
    local menu=CCMenu:createWithItem(button)
    menu:setPosition(ccp(self.bgSize.width/2,60))
    menu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(menu)

    sceneGame:addChild(self.dialogLayer,self.layerNum)
end