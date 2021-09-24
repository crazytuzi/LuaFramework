acYrjTabTwo = {}

function acYrjTabTwo:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv       = nil
    self.bgLayer  = nil
    self.layerNum = nil

    return nc
end
function acYrjTabTwo:dispose( )
    if self.bgLayer then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil
    end
end
function acYrjTabTwo:init(layerNum)
    self.layerNum=layerNum
    self.bgLayer=CCLayer:create()

    self.cellWidth = self.bgLayer:getContentSize().width-40
    self.cellHeight= G_isAsia and 120 or 150

    self.shopTb,self.cellNum = acYrjVoApi:getFormatExTb( )

    self:initTableView()
    return self.bgLayer
end

function acYrjTabTwo:initTableView()
    local h=G_VisibleSizeHeight-160
    local w=G_VisibleSizeWidth-40 --背景框的宽度
    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(60,24,8,2),function () end)
    backSprie:setContentSize(CCSizeMake(w,120))
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setPosition(ccp(G_VisibleSizeWidth * 0.5,h))
    self.bgLayer:addChild(backSprie,10)
    backSprie:setOpacity(0)

    local scoreItem = acYrjVoApi:getScoreItem(75,65)
    local useHeight = backSprie:getContentSize().height
    local function showNewPropInfo()
        G_showNewPropInfo(self.layerNum+1,true,true,nil,acYrjVoApi:getScoreItem(90,90),nil,nil,nil,nil,true)
        return false
    end
    local scoreIcon = G_universalAcGetItemIcon(scoreItem,showNewPropInfo)
    scoreIcon:setTouchPriority(-(self.layerNum-1)*20-5)
    scoreIcon:setPosition(ccp(15 + scoreItem.bgSize * 0.5,useHeight - 10 - scoreItem.bgSize * 0.5))
    backSprie:addChild(scoreIcon)

    local scoreName = GetTTFLabel(scoreItem.name,24,"Helvetica-bold")
    scoreName:setAnchorPoint(ccp(0,0.5))
    scoreName:setPosition(ccp(15 + scoreItem.bgSize + 10,useHeight - 10 - scoreItem.bgSize * 0.5))
    backSprie:addChild(scoreName)
    scoreName:setColor(G_ColorYellowPro)
    local scoreNum = GetTTFLabel(": "..scoreItem.num,24,"Helvetica-bold")
    scoreNum:setAnchorPoint(ccp(0,0.5))
    scoreNum:setPosition(ccp(5 + scoreName:getPositionX() + scoreName:getContentSize().width,useHeight - 10 - scoreItem.bgSize * 0.5))
    backSprie:addChild(scoreNum)
    scoreNum:setColor(G_ColorYellowPro)
    self.scoreNum = scoreNum

    local scoreDesc = GetTTFLabel(getlocal(scoreItem.desc),22,"Helvetica-bold")
    scoreDesc:setAnchorPoint(ccp(0,0))
    scoreDesc:setPosition(ccp(15,15))
    backSprie:addChild(scoreDesc)
    if scoreDesc:getContentSize().width > w then
        scoreDesc:setScale(w/scoreDesc:getContentSize().width)
    end


    local function touchInfo()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        local tabStr = {}
        table.insert(tabStr,getlocal("activity_yrj_tab2_tip1",{acYrjVoApi:getSpecialProp()}))
        table.insert(tabStr,getlocal("activity_yrj_tab2_tip2",{acYrjVoApi:getSpecialProp()}))
        local titleStr = getlocal("activity_baseLeveling_ruleTitle")
        local textSize = 25
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,titleStr,tabStr,nil,textSize)
    end
    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,0.5))
    menuItemDesc:setScale(1)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-4)
    menuDesc:setPosition(ccp(w - 25,useHeight * 0.5))
    backSprie:addChild(menuDesc,2)

    self.tvHeight = h - useHeight

    local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
    tvBg:setContentSize(CCSizeMake(self.cellWidth,self.tvHeight))
    tvBg:setAnchorPoint(ccp(0,0))
    tvBg:setPosition(20,10)
    self.bgLayer:addChild(tvBg)
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.cellWidth,self.tvHeight-4),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,10))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acYrjTabTwo:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(self.cellWidth,self.cellHeight)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local shopAllInfoTb = self.shopTb[idx + 1]
        local propTb = FormatItem(shopAllInfoTb.reward)[1]

        local lbNameFontSize,nameSubPosY,desSize2,strPosx = 22,30,18,95
        if G_isAsia() == false then
            lbNameFontSize,nameSubPosY,desSize2= 20,16,16
        end

        local nameLb=GetTTFLabel(propTb.name,lbNameFontSize)
        nameLb:setAnchorPoint(ccp(0,0.5))
        nameLb:setColor(G_ColorGreen)
        nameLb:setPosition(ccp(strPosx,self.cellHeight-nameSubPosY))
        cell:addChild(nameLb)

        local limitLb=GetTTFLabel("("..shopAllInfoTb.exchangedNum.."/"..shopAllInfoTb.maxLimit..")",lbNameFontSize)
        limitLb:setAnchorPoint(ccp(0,0.5))
        limitLb:setPosition(ccp(2+nameLb:getContentSize().width+5 + nameLb:getPositionX(),nameLb:getPositionY()))
        cell:addChild(limitLb)

        local function showNewPropInfo()
            G_showNewPropInfo(self.layerNum+1,true,true,nil,propTb,nil,nil,nil,nil,true)
            return false
        end
        local icon,scale=G_getItemIcon(propTb,100,true,self.layerNum+1,showNewPropInfo)
        icon:setAnchorPoint(ccp(0,0.5))
        icon:setTouchPriority(-(self.layerNum-1)*20-3)
        icon:setPosition(ccp(10,self.cellHeight*0.5))
        cell:addChild(icon)
        icon:setScale(80/icon:getContentSize().width)

        local  descStr = getlocal(propTb.desc)
        if propTb.type == "pl" then
            descStr = propTb.desc
        end
        local descLb=GetTTFLabelWrap(descStr,desSize2,CCSizeMake(self.cellWidth - 230,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        descLb:setAnchorPoint(ccp(0,0.5))
        descLb:setPosition(ccp(strPosx,(self.cellHeight-25)*0.5))
        cell:addChild(descLb)

        local itemW=icon:getContentSize().width*scale
        local numLb=GetTTFLabel("x"..propTb.num,25)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setPosition(ccp(itemW-5,5))
        numLb:setScale(1/icon:getScale())
        icon:addChild(numLb,1)

        if shopAllInfoTb.oldNum < 5 then
            numLb:setPosition(ccp(numLb:getPositionX() + 10 ,numLb:getPositionY() - 27))
        end

        local gemIcon=CCSprite:createWithSpriteFrameName(acYrjVoApi:getSpecialPropPic());
        gemIcon:setScale(0.4)
        cell:addChild(gemIcon,2)
        local costNum = shopAllInfoTb.price[acYrjVoApi:getSpecialPropId()]
        local lbPrice=GetTTFLabel(costNum,24)
        
        lbPrice:setAnchorPoint(ccp(0,0.5));
        cell:addChild(lbPrice,2)

        local function touch1(tag,object)
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            self:exchangeFun(tonumber(tag),shopAllInfoTb,propTb)
        end
        local menuItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn_Down.png",touch1,idx + 1,getlocal("activity_loversDay_tab2"),35,100)
        menuItem:setScale(0.6)
        menuItem:setEnabled(true);
        local menu3=CCMenu:createWithItem(menuItem);
        menu3:setPosition(ccp(self.cellWidth - menuItem:getContentSize().width*0.5*0.65 - 5,35))
        menu3:setTouchPriority(-(self.layerNum-1)*20-3);
        cell:addChild(menu3,6)

        if shopAllInfoTb.state == 2 then
            menuItem:setEnabled(false)
            menu3:setEnabled(false)
        elseif shopAllInfoTb.state == 1 then
            lbPrice:setColor(G_ColorRed)
        end
        gemIcon:setPosition(ccp(menu3:getPositionX() -20,self.cellHeight*0.65))
        lbPrice:setPosition(ccp(menu3:getPositionX() + 5,self.cellHeight*0.65))

        local line =LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)
        line:setContentSize(CCSizeMake(self.cellWidth - 80,line:getContentSize().height))
        line:setPosition(ccp(self.cellWidth * 0.5,0))
        cell:addChild(line,99)
        return cell
    end
end

function acYrjTabTwo:exchangeFun(tag,shopAllInfoTb,propTb)
    
    PlayEffect(audioCfg.mouseClick)
    if shopAllInfoTb.state == 1 then
        smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_yrj_clownNotEnough",{acYrjVoApi:getSpecialProp()}),28)
            do return end 
    end
    local function requestHandler(fn,data)
        local ret,sData=base:checkServerData(data)
        if ret==true then
            if sData.data then
                if sData.data.yrj then
                    acYrjVoApi:updateSpecialData(sData.data.yrj)
                    self:refresh()
                    local rewardlist = {}
                    table.insert(rewardlist,propTb)
                    G_addPlayerAward(propTb.type,propTb.key,propTb.id,propTb.num,nil,true)
                    if shopAllInfoTb.oldNum < 5 then
                        self:chatMessage(propTb,shopAllInfoTb.oldNum)
                    end
                    G_showRewardTip(rewardlist,true)
                end
            end
        end
    end
    -- print("exchange num======>>>>>",shopAllInfoTb.oldNum)
    local params = {tid=shopAllInfoTb.oldNum}
    socketHelper:acYrjRequest("exchange",params,requestHandler)
end

function acYrjTabTwo:chatMessage(propTb)
    local paramTab={}
    paramTab.functionStr="yrj"
    paramTab.addStr="take_part"
    local chatKey = "activity_yrj_chat"
    local message={key=chatKey,param={playerVoApi:getPlayerName(),propTb.name.." x"..propTb.num,acYrjVoApi:getSpecialProp()}}
    chatVoApi:sendSystemMessage(message,paramTab)
end

function acYrjTabTwo:refresh( )
    self.scoreNum:setString(": "..acYrjVoApi:getScoreItem().num)
    self.shopTb = acYrjVoApi:getFormatExTb( )
    if self.tv then
        local recordPoint = self.tv:getRecordPoint()
        self.tv:reloadData()
        self.tv:recoverToRecordPoint(recordPoint)
    end
end