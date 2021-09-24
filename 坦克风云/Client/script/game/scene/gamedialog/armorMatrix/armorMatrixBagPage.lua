armorMatrixBagPage={}

function armorMatrixBagPage:new(callback)
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.btnScale1=140/205
	self.pageRefreshFunc=callback
	return nc
end

function armorMatrixBagPage:init(layerNum,pageId,tvHeight,tvPosH,everyCellNum,midH)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.pageId=pageId
    self.tvHeight=tvHeight
    self.midH=midH-10
    self.tvPosH=tvPosH
    self.everyCellNum=everyCellNum

    -- self:initTableView()
    return self.bgLayer
end

function armorMatrixBagPage:initTableView(baglist,bagNum)
	self.normalHeight=130
	self.baglist=baglist
	self.bagNum=bagNum
	self.cellNum=self.bagNum-(self.pageId-1)*self.everyCellNum
	if self.cellNum>self.everyCellNum then
		self.cellNum=self.everyCellNum
	end

	local tvHeight=self.tvHeight
	if self.bagNum<=self.everyCellNum then
		tvHeight=self.tvHeight+self.midH
	end

	local function callBack(...)
        return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,self.tvPosH))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(80)

    -- self.tv:setViewSize(CCSizeMake(G_VisibleSizeWidth-30,self.tvHeight+30))
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function armorMatrixBagPage:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local num=self.cellNum
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-60,self.normalHeight)
        return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local cellHeight=self.normalHeight-5
        local function cellClick(hd,fn,idx)
		end
        local capInSet=CCRect(20, 20, 10, 10)
        local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
		backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-60, cellHeight))
		backSprie:ignoreAnchorPointForPosition(false);
		backSprie:setAnchorPoint(ccp(0,0));
		backSprie:setIsSallow(false)
		backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
		cell:addChild(backSprie,1)

		local bsSize=backSprie:getContentSize()

		local index=(self.pageId-1)*self.everyCellNum+idx+1
		local id=self.baglist[index]
		local mid,level=armorMatrixVoApi:getMidAndLevelById(id)

		local cfg=armorMatrixVoApi:getCfgByMid(mid)
		local nameStr=getlocal(cfg.name)

		
		local nameColor=armorMatrixVoApi:getColorByQuality(cfg.quality)

		local attrStr,value=armorMatrixVoApi:getAttrAndValue(mid,level)
		

		local function showInfoFunc()
			if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
			    if G_checkClickEnable()==false then
			        do
			            return
			        end
			    else
			        base.setWaitTime=G_getCurDeviceMillTime()
			    end

			    armorMatrixVoApi:showInfoSmallDialog(id,self.layerNum+1)
			end
		end
		local iconSp=armorMatrixVoApi:getArmorMatrixIcon(mid,90,100,showInfoFunc,level)
		-- LuaCCSprite:createWithSpriteFrameName("equipBg_purple.png",showInfoFunc)
		backSprie:addChild(iconSp)
		iconSp:setAnchorPoint(ccp(0,0.5))
		iconSp:setPosition(10,bsSize.height/2)
		iconSp:setTouchPriority(-(self.layerNum-1)*20-2)
		armorMatrixVoApi:addLightEffect(iconSp, mid)

		local nameX=140
		local nameLb=GetTTFLabelWrap(nameStr,24,CCSizeMake(bsSize.width-nameX-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentBottom,"Helvetica-bold")
		backSprie:addChild(nameLb)
		nameLb:setAnchorPoint(ccp(0,0.5))
		nameLb:setPosition(nameX,bsSize.height/2+20)
		nameLb:setColor(nameColor)

		-- local skillLb=GetTTFLabel(getlocal("bindText"),25)
		local skillLb=GetTTFLabel(attrStr,20)
		backSprie:addChild(skillLb)
		skillLb:setAnchorPoint(ccp(0,0.5))
		skillLb:setPosition(nameX,bsSize.height/2-20)

		local valueLb=GetTTFLabel("+" .. value .. "%",20)
		backSprie:addChild(valueLb)
		valueLb:setAnchorPoint(ccp(0,0.5))
		valueLb:setPosition(nameX+skillLb:getContentSize().width+5,bsSize.height/2-20)
		valueLb:setColor(G_ColorGreen)

		local exp=armorMatrixVoApi:getDecomposeExp(mid,level)

		local function severanceFunc()
	        if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
			    if G_checkClickEnable()==false then
			        do
			            return
			        end
			    else
			        base.setWaitTime=G_getCurDeviceMillTime()
			    end

			    
			    local dataInfo={}
			    local reward={am={exp=exp}}
			    local rewardItem=FormatItem(reward)
			    dataInfo.reward=rewardItem
			    dataInfo.sellNum=1
			    dataInfo.num4=0
			    dataInfo.num5=0
			    local quality=cfg.quality
			    if quality==4 then
			    	dataInfo.num4=1
		    	elseif quality==5 then
		    		dataInfo.num5=1
			    end

			    local function decomposeFunc()
			    	local function refreshCalback()
				    	table.remove(self.baglist,index)
				    	G_showRewardTip(rewardItem,true)
				    	 if self.pageRefreshFunc then
				        	self.pageRefreshFunc()
				        end
				    end
				    armorMatrixVoApi:armorResolve(id,nil,refreshCalback)
			    end
			    local titleStr=getlocal("armorMatrix_severance")
			    local desStr=getlocal("armorMatrix_decompose_des1",{1})
			    armorMatrixVoApi:showSellRewardDialog(self.layerNum+1,decomposeFunc,titleStr,desStr,dataInfo)
		       
			end
	    end
	    local lbStr2=getlocal("armorMatrix_severance")

	    local scale=self.btnScale1
	    local strSize2,strSize3 = 18,24
	    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
	        strSize2,strSize3 =24,31
	    end
	    local severanceItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",severanceFunc,nil,lbStr2,strSize3,11)
	    severanceItem:setScale(scale)
	    local btnLb = severanceItem:getChildByTag(11)
	    if btnLb then
	    	btnLb = tolua.cast(btnLb,"CCLabelTTF")
	    	btnLb:setFontName("Helvetica-bold")
	    end

	    local severanceBtn=CCMenu:createWithItem(severanceItem);
	    severanceBtn:setTouchPriority(-(self.layerNum-1)*20-2);
	    severanceBtn:setPosition(ccp(bsSize.width-90,bsSize.height/2-20))
	    backSprie:addChild(severanceBtn)

	    local childH=severanceItem:getContentSize().height+30
	    local expIcon1=CCSprite:createWithSpriteFrameName("armorMatrixExp.png")
	    severanceItem:addChild(expIcon1)
	    expIcon1:setPositionY(childH)
	    expIcon1:setAnchorPoint(ccp(0.5,0.5))
	    expIcon1:setScale(1/scale*0.5)

	    local iconLb1=GetTTFLabel(exp,25)
	    severanceItem:addChild(iconLb1)
	    iconLb1:setPositionY(childH)
	    iconLb1:setAnchorPoint(ccp(0.5,0.5))
	    iconLb1:setScale(1/scale)

	    G_setchildPosX(severanceItem,expIcon1,iconLb1)

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then

    end
end

function armorMatrixBagPage:refresh(bagNum,baglist)
	if self.tv then
		self.bagNum=bagNum
		self.baglist=baglist
		if self.bagNum<=self.everyCellNum then
			self.tv:setViewSize(CCSizeMake(G_VisibleSizeWidth-30,self.tvHeight+self.midH))
		end

		self.cellNum=self.bagNum-(self.pageId-1)*self.everyCellNum
		if self.cellNum>self.everyCellNum then
			self.cellNum=self.everyCellNum
		end

		local recordPoint=self.tv:getRecordPoint()
		self.tv:reloadData()
	end
end

function armorMatrixBagPage:dispose()
	self.bgLayer:removeFromParentAndCleanup(true)
	self.bgLayer=nil
    self.layerNum=nil
    self.pageId=nil
    self.tvHeight=nil
    self.tvPosH=nil
    self.tv=nil
    self.normalHeight=nil
	self.baglist=nil
	self.bagNum=nil
	self.cellNum=nil
end
