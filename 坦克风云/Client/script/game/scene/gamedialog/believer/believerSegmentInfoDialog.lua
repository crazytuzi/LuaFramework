local believerSegmentInfoDialog=commonDialog:new()

function believerSegmentInfoDialog:new(parent)
    local nc={
	    parent=parent,
	}
    setmetatable(nc,self)
    self.__index=self

    return nc
end

function believerSegmentInfoDialog:doUserHandler()
	local believerCfgVer=believerVoApi:getBelieverVerCfg()
	local segmentCfg=believerCfgVer.groupMsg
	self.tvNum=SizeOfTable(segmentCfg)
    self.tvWidth,self.tvHeight,self.normalHeight=G_VisibleSizeWidth-40,G_VisibleSizeHeight-260,150
	self.expandIdx={}
	self.expandHeightLow=self.normalHeight+240
	self.expandHeightHigh=3*100+240+self.normalHeight
end

--设置对话框里的tableView
function believerSegmentInfoDialog:initTableView()
	self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(true)
    self.panelTopLine:setPositionY(G_VisibleSizeHeight-82)

    local descBg=LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png",CCRect(15,15,2,2),function () end)
    descBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,150))
    descBg:setAnchorPoint(ccp(0.5,1))
    descBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-90)
    self.bgLayer:addChild(descBg)

	local fontSize=20
	local descLb=GetTTFLabelWrap(getlocal("believer_seg_info_desc"),fontSize,CCSizeMake(G_VisibleSizeWidth-180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	descLb:setAnchorPoint(ccp(0,0.5))
	descLb:setPosition(ccp(40,descBg:getContentSize().height/2))
	descLb:setColor(G_ColorWhite)
	descBg:addChild(descLb)

    local function infoHandler()
    	local tabStr={}
    	for i=1,6 do
    		table.insert(tabStr,getlocal("believer_seg_info_"..i))
    	end
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
    end
    G_addMenuInfo(descBg,self.layerNum,ccp(descBg:getContentSize().width-60,descBg:getContentSize().height/2),{},nil,nil,28,infoHandler,true)

    local function callBack(...)
		return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.tvWidth,self.tvHeight),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition((G_VisibleSizeWidth-self.tvWidth)/2,G_VisibleSizeHeight-240-self.tvHeight)
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)

    local grade,queue=believerVoApi:getMySegment() --自动展开当前段位的下一个段位信息，因为idx从0开始，故展开的idx应该为grade
    if grade<5 then
    	local expandIdx=grade
    	if expandIdx<self.tvNum then
	    	self:cellClick(expandIdx+1000)
	    end
	end
end

function believerSegmentInfoDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.tvNum
	elseif fn=="tableCellSizeForIndex" then
	    local tmpSize
	    if self.expandIdx["k"..idx]~=nil then
			tmpSize=CCSizeMake(self.tvWidth,self:getCellHeight(idx))
		else
			tmpSize=CCSizeMake(self.tvWidth,self.normalHeight)
		end
	    return tmpSize
	elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
		self:loadCCTableViewCell(cell,idx)

   		return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
		
    elseif fn=="ccScrollEnable" then
    end
end

--创建或刷新CCTableViewCell
function believerSegmentInfoDialog:loadCCTableViewCell(cell,idx)
	local grade=idx+1
	local believerCfg=believerVoApi:getBelieverCfg()
	local believerCfgVer=believerVoApi:getBelieverVerCfg()
	local segmentCfg=believerCfgVer.groupMsg[grade]
    local expanded=false
    local cellMaxHeight=self.normalHeight
	if self.expandIdx["k"..idx]==nil then
	    expanded=false
	else
	    expanded=true
	end
	if expanded then
		cellMaxHeight=self:getCellHeight(idx)
	end
    cell:setContentSize(CCSizeMake(self.tvWidth,cellMaxHeight))

    local function cellClick(hd,fn,idx)
    	self:cellClick(idx)
    end
	local itemHeight=self.normalHeight-6
    local itemBg=LuaCCScale9Sprite:createWithSpriteFrameName("newUnReadBg.png",CCRect(5,23,1,1),cellClick)
    itemBg:setContentSize(CCSizeMake(self.tvWidth,itemHeight))
    itemBg:setPosition(self.tvWidth/2,cell:getContentSize().height-(self.normalHeight-itemHeight)/2-itemHeight/2)
    itemBg:setTag(1000+idx)
    itemBg:setTouchPriority(-(self.layerNum-1)*20-3)
    cell:addChild(itemBg)

    local iconBg=LuaCCScale9Sprite:createWithSpriteFrameName("newChat_head_shade.png",CCRect(16,16,2,2),function()end)
    iconBg:setContentSize(CCSizeMake(itemHeight-10,itemHeight-10))
    iconBg:setPosition(iconBg:getContentSize().width/2,itemHeight/2)
    itemBg:addChild(iconBg)

    local segIconSp=believerVoApi:getSegmentIcon(grade)
    if segIconSp then
        segIconSp:setScale(0.6)
        segIconSp:setPosition(iconBg:getContentSize().width/2,iconBg:getContentSize().height/2-5)
        iconBg:addChild(segIconSp,2)
    end
    local fontSize=22
    local segNameStr=believerVoApi:getSegmentName(grade)
    local segmentLb=GetTTFLabelWrap(segNameStr,fontSize,CCSizeMake(self.tvWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
    segmentLb:setAnchorPoint(ccp(0,0.5))
    segmentLb:setPosition(ccp(iconBg:getPositionX()+itemHeight/2+10,itemHeight-segmentLb:getContentSize().height/2-15))
    segmentLb:setColor(G_ColorHighGreen)
    itemBg:addChild(segmentLb)

	local limitNum=0 --段位人数总容量
	for k,v in pairs(segmentCfg) do
		if v.numLimit then
			limitNum=limitNum+v.numLimit
		end
	end
	if limitNum<0 then
		limitNum=getlocal("believer_seg_no_max")
	end
	local limitLb=GetTTFLabelWrap(getlocal("believer_seg_all_num",{limitNum}),fontSize-2,CCSizeMake(self.tvWidth/2,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	limitLb:setAnchorPoint(ccp(0,0.5))
	limitLb:setPosition(segmentLb:getPositionX(),limitLb:getContentSize().height/2+15)
	itemBg:addChild(limitLb)

	local btn
	if expanded==false then
		btn=CCSprite:createWithSpriteFrameName("sYellowAddBtn.png")
	else
		btn=CCSprite:createWithSpriteFrameName("sYellowSubBtn.png")
	end
	btn:setAnchorPoint(ccp(1,0))
	btn:setPosition(ccp(self.tvWidth-20,10))
	itemBg:addChild(btn)

	if expanded==true then
		local queueNum=SizeOfTable(segmentCfg)
		local iconSize=80
		local subItemHeight=iconSize+20
		local exBgWidth,exBgHeight=self.tvWidth-10,240
		if queueNum>1 then
			exBgHeight=queueNum*(subItemHeight)+240
		end
	    local function touchHander()
	    end
	    local exBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
	    exBg:setContentSize(CCSizeMake(exBgWidth,exBgHeight))
	    exBg:setAnchorPoint(ccp(0.5,1))
	   	exBg:setPosition(ccp(self.tvWidth/2,cellMaxHeight-self.normalHeight))
	    exBg:setTag(2)
	    cell:addChild(exBg)

		local levelTask=believerCfg.levelTask[grade]

		local segNameStr=believerVoApi:getSegmentName(grade)
		local titleTb={getlocal("believer_seg_info_reach",{segNameStr}),fontSize,G_ColorGreen}
		local titleLbSize=CCSizeMake(300,0)
		local titleBg,titleLb=G_createNewTitle(titleTb,titleLbSize,nil,nil,"Helvetica-bold")
		titleBg:setPosition(exBgWidth/2,exBgHeight-40)
		exBg:addChild(titleBg)
		
		local posY=titleBg:getPositionY()-10
		if levelTask==nil then
			local nullLb=GetTTFLabelWrap(getlocal("alliance_info_content"),fontSize-2,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
			nullLb:setAnchorPoint(ccp(0.5,1))
			nullLb:setPosition(ccp(exBgWidth/2,posY))
			exBg:addChild(nullLb)
			do return end
		else
			for k,v in pairs(levelTask.t) do
				local taskStr=""
				if k==3 then
					taskStr=k.."."..getlocal("believer_seg_task_desc_"..k,{believerVoApi:getSegmentName(grade-1),v})
				elseif k==2 then
					taskStr=k.."."..getlocal("believer_seg_task_desc_"..k,{v}).."%"
				else
					taskStr=k.."."..getlocal("believer_seg_task_desc_"..k,{v})
				end
				local taskLb=GetTTFLabelWrap(taskStr,fontSize-2,CCSizeMake(exBgWidth-240,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
				taskLb:setAnchorPoint(ccp(0,1))
				taskLb:setPosition(ccp(exBgWidth/2-140,posY))
				exBg:addChild(taskLb)

				posY=posY-taskLb:getContentSize().height-5
			end
		end
		posY=posY-10

		local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSp:setScaleX((self.tvWidth-60)/lineSp:getContentSize().width)
		lineSp:setPosition(exBgWidth/2,posY)
		exBg:addChild(lineSp,1)

	    posY=posY-10

	    local queueNum=SizeOfTable(segmentCfg)
	    if queueNum>1 then
	    	for k=queueNum,1,-1 do
			    posY=posY-10

	    		local cfg=segmentCfg[k]
				local iconWidth=80
			    local segIconSp,iconScale=believerVoApi:getSegmentIcon(grade,k,iconWidth)
			    segIconSp:setPosition(ccp(40+iconWidth/2,posY-iconWidth/2))
			    exBg:addChild(segIconSp)

				local pointLb=GetTTFLabelWrap(getlocal("serverwar_reward_desc2",{cfg.scoreRequire}),fontSize-2,CCSizeMake(160,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				pointLb:setAnchorPoint(ccp(0,0.5))
				pointLb:setPosition(ccp(segIconSp:getPositionX()+iconWidth/2+50,segIconSp:getPositionY()))
				exBg:addChild(pointLb)

				local haveNum=cfg.numLimit
				if haveNum<0 then
					haveNum=getlocal("believer_seg_no_max")
				end
				local haveNumLb=GetTTFLabelWrap(getlocal("alliance_list_scene_number").."："..haveNum,fontSize-2,CCSizeMake(160,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
				haveNumLb:setAnchorPoint(ccp(0,0.5))
				haveNumLb:setPosition(ccp(pointLb:getPositionX()+pointLb:getContentSize().width+40,pointLb:getPositionY()))
				exBg:addChild(haveNumLb)

				posY=posY-iconWidth-15

			    local mLine=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function () end)
		        mLine:setContentSize(CCSizeMake(exBgWidth-20,mLine:getContentSize().height))
		        mLine:setPosition(exBgWidth/2,posY)
		        exBg:addChild(mLine)
			end
	    end
	end
end

function believerSegmentInfoDialog:getCellHeight(idx)
	return self.tvHeight
	-- local expandHeight
	-- if idx==(self.tvNum-1) then
	-- 	expandHeight=self.tvHeight
	-- elseif idx==0 or idx==4 then
	-- 	expandHeight=self.expandHeightLow
	-- else
	-- 	expandHeight=self.expandHeightHigh
	-- end
    -- return expandHeight
end

function believerSegmentInfoDialog:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        PlayEffect(audioCfg.mouseClick)
        local index=idx-1000
        if self.expandIdx["k"..index]==nil then
            self.expandIdx["k"..index]=index
            self.tv:openByCellIndex(index,self.normalHeight)
        else
            self.expandIdx["k"..index]=nil
            self.tv:closeByCellIndex(index,self:getCellHeight(index))
        end
    end
end

function believerSegmentInfoDialog:dispose()
	self.expandIdx=nil
    self.normalHeight=nil
    self.expandHeightLow=nil
    self.expandHeightHigh=nil
    self.tvNum=nil
    self.parent=nil
    self.tvWidth=nil
    self.tvHeight=nil
    if self.parent and self.parent.backToMainDialogHandler then
        self.parent:backToMainDialogHandler()
        self.parent=nil
    end
end

return believerSegmentInfoDialog