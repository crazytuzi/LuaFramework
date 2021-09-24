ltzdzStratagemBagDialog=commonDialog:new()

function ltzdzStratagemBagDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    return nc
end

function ltzdzStratagemBagDialog:resetTab()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(620,G_VisibleSize.height-100))
    self.panelLineBg:setVisible(false)
end

function ltzdzStratagemBagDialog:getStratagemList()
    self.stratagemList={}
    local bag=ltzdzFightApi:getMyBag()
    for k,v in pairs(bag) do
        table.insert(self.stratagemList,{k,v})
    end
    self.cellNum=SizeOfTable(self.stratagemList)
end

function ltzdzStratagemBagDialog:isCanUse(tid,num)
    --只有补充代币和石油的道具可以在计策背包里面使用，其余的在相应的功能里面使用
    if (tostring(tid)=="t3" or tostring(tid)=="t4") and tonumber(num)>0 then
        return true
    end
    return false
end

function ltzdzStratagemBagDialog:initTableView()
    ltzdzVoApi:addOrRemoveOpenDialog(1,"ltzdzStratagemBagDialog",self)

    self:getStratagemList()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSize.width-30,G_VisibleSize.height-220),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setMaxDisToBottomOrTop(120)
    self.tv:setPosition(ccp(15,130))
    self.bgLayer:addChild(self.tv)


    local promptLb=GetTTFLabelWrap(getlocal("ltzdz_bag_promptStr"),25,CCSizeMake(G_VisibleSize.width-180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    promptLb:setAnchorPoint(ccp(0,0.5))
    promptLb:setColor(G_ColorRed)
    promptLb:setPosition(40,75)
    self.bgLayer:addChild(promptLb)

    local noStratagemLb=GetTTFLabelWrap(getlocal("ltzdz_bag_null"),25,CCSizeMake(G_VisibleSize.width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    noStratagemLb:setColor(G_ColorGray)
    noStratagemLb:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2)
    self.bgLayer:addChild(noStratagemLb)
    self.noStratagemLb=noStratagemLb
    if self.cellNum and self.cellNum>0 then
        self.noStratagemLb:setVisible(false)
    end

    local mLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)
    mLine:setPosition(ccp(G_VisibleSizeWidth/2,40))
    mLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,mLine:getContentSize().height))
    self.bgLayer:addChild(mLine)
end

function ltzdzStratagemBagDialog:eventHandler(handler,fn,idx,cel)
   	if fn=="numberOfCellsInTableView" then
   		return self.cellNum
   	elseif fn=="tableCellSizeForIndex" then
       	local tmpSize=CCSizeMake(G_VisibleSize.width-30,130)
       	return tmpSize
   	elseif fn=="tableCellAtIndex" then
   	    local cell=CCTableViewCell:new()
        cell:autorelease()

        local nameFontSize,descFontSize=20,18
        local cellWidth=G_VisibleSize.width-30
        local cellHeight=130
        local itemHeight=120
        local stratagem=self.stratagemList[idx+1]
        local tid=stratagem[1] --id
        local num=stratagem[2] --数量
        local nameStr,descStr,iconPic=ltzdzVoApi:getStratagemInfoById(tid)

        local function nilFunc()
        end
        local itemBg=G_getThreePointBg(CCSizeMake(cellWidth,itemHeight),nilFunc,ccp(0.5,0.5),ccp(cellWidth/2,cellHeight/2),cell)
        local function touchHandler()
        end
        local iconSp=LuaCCSprite:createWithSpriteFrameName(iconPic,touchHandler)
        iconSp:setAnchorPoint(ccp(0,0.5))
        iconSp:setPosition(ccp(15,itemBg:getContentSize().height/2))
        itemBg:addChild(iconSp)
        local iconWidth=iconSp:getContentSize().width*iconSp:getScaleX()
        local iconHeight=iconSp:getContentSize().height*iconSp:getScaleY()


        local nameLb=GetTTFLabelWrap(nameStr,nameFontSize,CCSizeMake(cellWidth-300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        nameLb:setPosition(15+iconWidth+10,itemHeight-nameLb:getContentSize().height/2-10)
        nameLb:setAnchorPoint(ccp(0,0.5))
        nameLb:setColor(G_ColorYellowPro)
        itemBg:addChild(nameLb)
                
        local descLb=GetTTFLabelWrap(descStr,descFontSize,CCSizeMake(cellWidth-300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        descLb:setPosition(15+iconWidth+10,nameLb:getPositionY()-nameLb:getContentSize().height/2-20)
        descLb:setAnchorPoint(ccp(0,1))
        itemBg:addChild(descLb)

        local function useHandler()
            if self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                local function useCallBack()
                    self:refresh(tid)
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("ltzdz_use_success",{nameStr}),30)
                end
                ltzdzFightApi:buyOrUsePropsRequest(2,tid,false,useCallBack)
			end
        end
        local priority=-(self.layerNum-1)*20-2
        local useItem,useBtn=G_createBotton(itemBg,ccp(cellWidth-80,itemHeight/2-20),{getlocal("use"),23},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",useHandler,0.7,priority)
        local useFlag=self:isCanUse(tid,num)
        if useFlag==false then
            useItem:setEnabled(false)
        end

        local ownLb=GetTTFLabel(getlocal("emblem_infoOwn",{num}),descFontSize)
        ownLb:setAnchorPoint(ccp(0.5,0))
        ownLb:setPosition(useBtn:getPositionX(),itemHeight/2+20)
        itemBg:addChild(ownLb)

		return cell
   	elseif fn=="ccTouchBegan" then
       	self.isMoved=false
       	return true
   	elseif fn=="ccTouchMoved" then
       	self.isMoved=true
   	elseif fn=="ccTouchEnded"  then
       
   	end
end

function ltzdzStratagemBagDialog:tick()

end

function ltzdzStratagemBagDialog:refresh(tid)
    if self.tv then
        self:getStratagemList()
        local bag=ltzdzFightApi:getMyBag()
        if bag and bag[tid] and tonumber(bag[tid])>0 then
            local recordPoint=self.tv:getRecordPoint()
            self.tv:reloadData()
            self.tv:recoverToRecordPoint(recordPoint)
        else
            self.tv:reloadData()
        end
        if self.cellNum and self.cellNum>0 then
            self.noStratagemLb:setVisible(false)
        else
            self.noStratagemLb:setVisible(true)
        end
    end
end

function ltzdzStratagemBagDialog:dispose()
    ltzdzVoApi:addOrRemoveOpenDialog(2,"ltzdzStratagemBagDialog",self)
end