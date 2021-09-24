-- @Author hj
-- @Description 名将支援活动小板子
-- @Date 2018-06-11

acMjzySmallDialog=smallDialog:new()

function acMjzySmallDialog:new()
	local nc={
		rewardChose = nil,
        heroChose = acMjzyVoApi:getHeroSet(),
		selectedSp = nil,
		rewardTb = {},
        flag = acMjzyVoApi:getHeroReward(),
        -- heroFlag = acMjzyVoApi:getHeroSet(),
        layerNum = nil
	}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

function acMjzySmallDialog:showHeroSettingSmallDialog(size,titleStr,titleSize,titleColor,layerNum,parent)
	self.layerNum = layerNum
    local sd = acMjzySmallDialog:new()
	sd:initHeroSettingSmallDialog(size,titleStr,titleSize,titleColor,layerNum,parent)
end

function acMjzySmallDialog:initHeroSettingSmallDialog(size,titleStr,titleSize,titleColor,layerNum,parent)
	

    self.isUseAmi = false
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    sceneGame:addChild(self.dialogLayer,layerNum)
    self.dialogLayer:setPosition(ccp(0,0)) 

    local function closeCallBack( ... )
    	self:close()
    end

    --采用新式小板子
	local dialogBg = G_getNewDialogBg(size,titleStr,titleSize,nil,layerNum,true,closeCallBack,titleColor)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(size)
  	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

    local function eventHandler(handler,fn,idx,cel)
        if fn=="numberOfCellsInTableView" then
            return 2
        elseif fn=="tableCellSizeForIndex" then
            return CCSizeMake(self.bgLayer:getContentSize().width,580)
        elseif fn=="tableCellAtIndex" then
            local cell=CCTableViewCell:new()
            cell:autorelease()
            if self.flag then
                if idx == 0 then
                    self:initHeroSet(cell,parent)
                else
                    self:initReward(cell)
                end
            else
                if idx == 0 then
                    self:initReward(cell)
                else
                    self:initHeroSet(cell,parent)
                end
            end
            return cell
        elseif fn=="ccTouchBegan" then
            return true
        elseif fn=="ccTouchMoved" then
        elseif fn=="ccTouchEnded"  then
        end
    end

    local tvWidth = self.bgLayer:getContentSize().width
    local tvHeight = self.bgLayer:getContentSize().height-66-15-10
    local hd=LuaEventHandler:createHandler(eventHandler)
    local displayTv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
    displayTv:setTableViewTouchPriority(-(layerNum-1)*20-2)
    displayTv:setPosition(0,15)
    displayTv:setMaxDisToBottomOrTop(80)
    self.displayTv = displayTv
    self.bgLayer:addChild(displayTv,2)
     
    --设置tableview的遮罩
    local stencilBgUp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
    stencilBgUp:setContentSize(CCSizeMake(tvWidth,(G_VisibleSizeHeight/2-self.bgLayer:getContentSize().height/2)+66+5))
    stencilBgUp:setAnchorPoint(ccp(0.5,1))
    stencilBgUp:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight))
    stencilBgUp:setTouchPriority(-(layerNum-1)*20-3)
    stencilBgUp:setVisible(false)
    stencilBgUp:setIsSallow(true)
    self.dialogLayer:addChild(stencilBgUp,10)
    local stencilBgDown=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function ()end)
    stencilBgDown:setContentSize(CCSizeMake(tvWidth,15+(G_VisibleSizeHeight/2-self.bgLayer:getContentSize().height/2)))
    stencilBgDown:setAnchorPoint(ccp(0.5,0))
    stencilBgDown:setPosition(ccp(G_VisibleSizeWidth/2,0))
    stencilBgDown:setTouchPriority(-(layerNum-1)*20-3)
    stencilBgDown:setVisible(false)
    stencilBgDown:setIsSallow(true)
    self.dialogLayer:addChild(stencilBgDown,10)
 
    --黑色遮挡层
    local function touchLuaSpr()
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(220)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

end


function acMjzySmallDialog:initReward(cell)

    cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,580))

    
    local descStr = getlocal("activity_mjzy_smallDesc1",{acMjzyVoApi:getUpRateCostNum()})
    local colorTb = {nil,G_ColorYellowPro,nil}
    local descLb,height = G_getRichTextLabel(descStr,colorTb,22,cell:getContentSize().width-20,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    descLb:setAnchorPoint(ccp(0,1))
    descLb:setPosition(ccp(10,cell:getContentSize().height-10))
    cell:addChild(descLb)

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    dialogBg:setContentSize(CCSizeMake(cell:getContentSize().width-20,430))
    dialogBg:setAnchorPoint(ccp(0.5,1))
    dialogBg:setPosition(ccp(cell:getContentSize().width/2,cell:getContentSize().height-height-20))
    cell:addChild(dialogBg)

    local bgH = dialogBg:getContentSize().height
    local heroList = FormatItem(acMjzyVoApi:getRewardExtra(),nil,true)
    for k,v in pairs(heroList) do
        local function heroCallback( ... )
            if self.selectedSp and self.rewardChose then
                if self.rewardChose ~= k then
                    self.selectedSp:removeFromParentAndCleanup(true)
                    self.selectedSp = nil
                    local selectedSp=LuaCCScale9Sprite:createWithSpriteFrameName("equipSelectedRect.png",CCRect(20,20,80,80),function()end)
                    self.selectedSp = selectedSp
                    selectedSp:setContentSize(CCSizeMake(170,200))
                    selectedSp:setAnchorPoint(ccp(0.5,0.5))
                    selectedSp:setPosition(ccp(30+70+(k%4-1+math.floor(k/4))*(25+140),bgH-5-90-(20+180)*math.floor(k/4)))
                    dialogBg:addChild(selectedSp)
                    self.rewardChose = k
                else
                    self.selectedSp:removeFromParentAndCleanup(true)
                    self.selectedSp = nil
                    self.rewardChose = nil
                end
            else
                local selectedSp=LuaCCScale9Sprite:createWithSpriteFrameName("equipSelectedRect.png",CCRect(20,20,80,80),function()end)
                self.selectedSp = selectedSp
                selectedSp:setContentSize(CCSizeMake(170,200))
                selectedSp:setAnchorPoint(ccp(0.5,0.5))
                selectedSp:setPosition(ccp(30+70+(k%4-1+math.floor(k/4))*(25+140),bgH-5-90-(30+180)*math.floor(k/4)))
                dialogBg:addChild(selectedSp)
                self.rewardChose = k
            end  
        end

        local heroBg = CCSprite:createWithSpriteFrameName("hero_display_base.png")
        heroBg:setAnchorPoint(ccp(0.5,0.5))
        heroBg:setPosition(ccp(30+70+(k%4-1+math.floor(k/4))*(25+140),bgH-5-90-(30+180)*math.floor(k/4)))
        dialogBg:addChild(heroBg)

        local numLb=GetTTFLabel(getlocal("alliance_challenge_prop_num",{FormatNumber(v.num)}),18,true)
        heroBg:addChild(numLb)
        numLb:setAnchorPoint(ccp(0.5,0))
        numLb:setPosition(ccp(75,15))

        local nameLb = GetTTFLabel(v.name,18,true)
        nameLb:setColor(G_ColorYellowPro)
        heroBg:addChild(nameLb)
        nameLb:setAnchorPoint(ccp(0.5,1))
        nameLb:setPosition(ccp(75,-3))

        local icon=G_getItemIcon(v,120,false,self.layerNum+1,heroCallback)
        if not self.flag then
            icon:setTouchPriority(-(self.layerNum-1)*20-2)
        else
            local blackBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(2,2,2,2),function()end)
            blackBg:setContentSize(CCSizeMake(150,150))
            blackBg:setAnchorPoint(ccp(0.5,0.5))
            blackBg:setPosition(getCenterPoint(icon))
            icon:addChild(blackBg,3)
            blackBg:setOpacity(100)
        end
        icon:setAnchorPoint(ccp(0.5,0.5))
        icon:setPosition(ccp(75,105))
        heroBg:addChild(icon)

        if self.flag and self.flag == v.key then
            -- 已领取过奖励显示选中状态
            local selectedSp=LuaCCScale9Sprite:createWithSpriteFrameName("equipSelectedRect.png",CCRect(20,20,80,80),function()end)
            selectedSp:setContentSize(CCSizeMake(170,200))
            selectedSp:setAnchorPoint(ccp(0.5,0.5))
            selectedSp:setPosition(ccp(30+70+(k%4-1+math.floor(k/4))*(25+140),bgH-5-90-(30+180)*math.floor(k/4)))
            dialogBg:addChild(selectedSp)
        end

    end

    local function getRewardCallback()
        if self.rewardChose then
            local function callback(fn,data)
                 local ret,sData = base:checkServerData(data)
                 if ret==true then
                     if sData.data and sData.data.mjzy then
                         acMjzyVoApi:updateSpecialData(sData.data.mjzy)
                         for k,v in pairs(heroList) do
                             if k == self.rewardChose then
                                if v.type == "h" then
                                    heroVoApi:addSoul(v.key,v.num)
                                 else
                                    G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                                 end
                                 local tempTb = {}
                                 table.insert(tempTb,v)
                                 G_showRewardTip(tempTb,true)
                             end
                        end
                        self.flag = acMjzyVoApi:getHeroReward()
                        self.displayTv:reloadData()
                     end     
                 end
            end
            socketHelper:acMjzyHeroSetting(acMjzyVoApi:getHeroId(self.rewardChose),1,callback)
        else
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_mjzy_smallPrompt"),30)
        end
    end

    local getBtn
    if self.flag then
        getBtn = G_createBotton(cell,ccp(cell:getContentSize().width/2,cell:getContentSize().height-height-410-80),{getlocal("activity_hadReward"),24},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",getRewardCallback,0.7,-(self.layerNum-1)*20-2)
        getBtn:setEnabled(false)
       
    else
        getBtn = G_createBotton(cell,ccp(cell:getContentSize().width/2,cell:getContentSize().height-height-410-80),{getlocal("daily_scene_get"),24},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",getRewardCallback,0.7,-(self.layerNum-1)*20-2)
    end
end

function acMjzySmallDialog:initHeroSet(cell,parent)

    cell:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width,580))
    local descStr = getlocal("activity_mjzy_smallDesc2",{acMjzyVoApi:getShowRate()})
    local colorTb = {nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil,G_ColorYellowPro,nil}
    local descLb,height = G_getRichTextLabel(descStr,colorTb,22,cell:getContentSize().width-20,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    descLb:setAnchorPoint(ccp(0,1))
    descLb:setPosition(ccp(10,cell:getContentSize().height-10))
    cell:addChild(descLb)

    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function() end)
    dialogBg:setContentSize(CCSizeMake(cell:getContentSize().width-20,430))
    dialogBg:setAnchorPoint(ccp(0.5,1))
    dialogBg:setPosition(ccp(cell:getContentSize().width/2,cell:getContentSize().height-height-20))
    cell:addChild(dialogBg)

    local bgH = dialogBg:getContentSize().height
    local heroList = acMjzyVoApi:getHerolist()
   
    -- 将领图标的添加
    for k,v in pairs(heroList) do

        local heroBg = CCSprite:createWithSpriteFrameName("hero_display_base.png")
        heroBg:setAnchorPoint(ccp(0.5,0.5))
        heroBg:setPosition(ccp(30+70+(k%4-1+math.floor(k/4))*(25+140),bgH-5-90-(30+180)*math.floor(k/4)))
        dialogBg:addChild(heroBg)
        --添加将领点击事件
        local function touchHeroIcon(...)
             if self.selectedSp1 and self.heroChose then
                if self.heroChose ~= v.name then
                    self.selectedSp1:removeFromParentAndCleanup(true)
                    self.selectedSp1 = nil
                    self.heroChose = ""
                    local selectedSp1=LuaCCScale9Sprite:createWithSpriteFrameName("equipSelectedRect.png",CCRect(20,20,80,80),function()end)
                    self.selectedSp1 = selectedSp1
                    selectedSp1:setContentSize(CCSizeMake(170,200))
                    selectedSp1:setAnchorPoint(ccp(0.5,0.5))
                    selectedSp1:setPosition(ccp(30+70+(k%4-1+math.floor(k/4))*(25+140),bgH-5-90-(30+180)*math.floor(k/4)))
                    dialogBg:addChild(selectedSp1)
                    self.heroChose = v.name
                else
                    self.selectedSp1:removeFromParentAndCleanup(true)
                    self.selectedSp1 = nil
                    self.heroChose = ""
                end
            else
                local selectedSp1 = LuaCCScale9Sprite:createWithSpriteFrameName("equipSelectedRect.png",CCRect(20,20,80,80),function()end)
                self.selectedSp1 = selectedSp1
                selectedSp1:setContentSize(CCSizeMake(170,200))
                selectedSp1:setAnchorPoint(ccp(0.5,0.5))
                selectedSp1:setPosition(ccp(30+70+(k%4-1+math.floor(k/4))*(25+140),bgH-5-90-(30+180)*math.floor(k/4)))
                dialogBg:addChild(selectedSp1)
                self.heroChose = v.name
            end 
        end   

        local heroInfo = heroVoApi:getHeroSpeInfo(v.name)

        if heroInfo.hid then
            -- 显示将领
            local heroIcon = heroVoApi:getHeroIcon(heroInfo.hid,heroInfo.productOrder,true,touchHeroIcon,nil,nil,true,{adjutants={}})
            heroIcon:setTouchPriority(-(self.layerNum-1)*20-2)
            heroIcon:setPosition(ccp(75,105))
            heroIcon:setAnchorPoint(ccp(0.5,0.5))
            heroIcon:setScale(120/heroIcon:getContentSize().width)
            heroBg:addChild(heroIcon)

            local heroNameStr = GetTTFLabel(heroVoApi:getHeroName(heroInfo.hid),18,true)
            local color=heroVoApi:getHeroColor(heroInfo.productOrder)
            heroNameStr:setColor(color)
            heroNameStr:setAnchorPoint(ccp(0.5,1))
            heroNameStr:setPosition(ccp(75,-3))
            heroBg:addChild(heroNameStr)
        else
            if heroInfo.sid then
                local hid =heroCfg.soul2hero[heroInfo.sid]
                local heroIcon = heroVoApi:getHeroIcon(hid,1,false,touchHeroIcon,true)
                heroIcon:setTouchPriority(-(self.layerNum-1)*20-2)
                heroIcon:setPosition(ccp(75,105))
                heroIcon:setAnchorPoint(ccp(0.5,0.5))
                heroIcon:setScale(120/heroIcon:getContentSize().width)
                heroBg:addChild(heroIcon)

                local heroNameStr = GetTTFLabel(getlocal(heroListCfg[hid].heroName),18,true)
                heroNameStr:setAnchorPoint(ccp(0.5,1))
                heroNameStr:setPosition(ccp(75,-3))
                heroBg:addChild(heroNameStr)

                local sid = heroInfo.sid
                local num = heroInfo.num
                local maxNum=heroListCfg[heroCfg.soul2hero[sid]].fusion.soul[sid]
                local str = num.."/"..maxNum

                AddProgramTimer(heroBg,ccp(75,30),10,12,str,"smallBarBg.png","smallYellowBar.png",11,130/106,20/23)
                local timerSprite = tolua.cast(heroBg:getChildByTag(10),"CCProgressTimer")
                timerSprite:setPercentage(num*100/maxNum)
                local proLb=tolua.cast(timerSprite:getChildByTag(12),"CCLabelTTF")
                proLb:setScaleX(0.7)
                proLb:setScaleY(0.8)
            end
        end

        local temp = "s"..RemoveFirstChar(v.name)
        if self.heroChose ~=  "" and self.heroChose == temp then
            -- 已经设置
            local selectedSp1=LuaCCScale9Sprite:createWithSpriteFrameName("equipSelectedRect.png",CCRect(20,20,80,80),function()end)
            selectedSp1:setContentSize(CCSizeMake(170,200))
            selectedSp1:setAnchorPoint(ccp(0.5,0.5))
            selectedSp1:setPosition(ccp(30+70+(k%4-1+math.floor(k/4))*(25+140),bgH-5-90-(30+180)*math.floor(k/4)))
            dialogBg:addChild(selectedSp1)
            self.selectedSp1 = selectedSp1
            self.heroChose = v.name
        end

    end

    local function confirmCallback( ... )

         local function callback(fn,data)
             local ret,sData = base:checkServerData(data)
             if ret==true then
                 if sData.data and sData.data.mjzy then
                     acMjzyVoApi:updateSpecialData(sData.data.mjzy)
                     if parent and parent.refreshRateSprite then
                        parent:refreshRateSprite()
                     end
                     self:close()
                 end     
             end
        end

        if self.heroChose ~= "" then
            local param = "s"..RemoveFirstChar(self.heroChose)
            socketHelper:acMjzyHeroSetting(param,2,callback)
        else
            socketHelper:acMjzyHeroSetting("",2,callback)
        end
    end

    local confirmBtn = G_createBotton(cell,ccp(cell:getContentSize().width/2,cell:getContentSize().height-410-height-80),{getlocal("activity_huoxianmingjiang_queren"),24},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",confirmCallback,0.7,-(self.layerNum-1)*20-2)

end


function acMjzySmallDialog:dispose( ... )
	self.rewardChose = nil
	self.rewardTb = {}
	self.selectedSp = nil
end
