alienTechDialogTab1={}

function alienTechDialogTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.tv1=nil
	self.tv2=nil
	self.iconBgTab={}
	self.selectIndex=1


	self.cellWidth=430
	self.normalHeight=100
    self.extendSpTag=113
	self.expandIdx={}
    -- self.expandHeight2=G_VisibleSize.height-156
    -- if G_isIphone5() then
    --    self.expandHeight=G_VisibleSize.height-156
    -- else
    --    self.expandHeight=1136-230
    -- end

    -- self.expandHeight=G_VisibleSize.height-300
    self.expandHeight=1136-300
    self.lineWidth=20
    self.expandIconBgTab={}

	return nc
end

function alienTechDialogTab1:init(layerNum,parent)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent

	local levelt=alienTechVoApi:getTechLevel("a10001")
	print("levelt",levelt)

	self:initBg()
	self:initTableView1()
	self:initTableView2()
	self:initTableView3()
	return self.bgLayer
end

function alienTechDialogTab1:initBg()
	local function click(hd,fn,idx)
	end
	for i=1,3 do
		-- if self.bgSprieTab[i] then
		-- 	self.bgSprieTab[i]:setVisible(true)
		-- else
			local bgSprie
			if i==1 then
				bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),click)
			    bgSprie:setContentSize(CCSizeMake(140, self.bgLayer:getContentSize().height-200))
			    bgSprie:setPosition(ccp(30,30))
			    self.bgSprie1=bgSprie
			    bgSprie:setTouchPriority(-(self.layerNum-1)*20-3)
			elseif i==2 then
				-- bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",CCRect(20, 20, 10, 10),click)
			    bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),click)
			    bgSprie:setContentSize(CCSizeMake(440, 80))
			    bgSprie:setPosition(ccp(170,self.bgLayer:getContentSize().height-250))
			    bgSprie:setTouchPriority(-(self.layerNum-1)*20-1)
			elseif i==3 then
				-- bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),click)
				bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),click)
			    bgSprie:setContentSize(CCSizeMake(440, self.bgLayer:getContentSize().height-280-110))
			    bgSprie:setPosition(ccp(170,30))
			    self.bgSprie3=bgSprie
			    bgSprie:setTouchPriority(-(self.layerNum-1)*20-1)
			end
			bgSprie:ignoreAnchorPointForPosition(false)
			bgSprie:setIsSallow(true)
			-- bgSprie:setTouchPriority(-(self.layerNum-1)*20-1)
		    bgSprie:setAnchorPoint(ccp(0,0))
		    self.bgLayer:addChild(bgSprie,1)

		    if i==1 then
		    	local iScale=1.3
		    	local upIcon=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
		    	upIcon:setAnchorPoint(ccp(0.5,0.5))
		    	upIcon:setPosition(ccp(bgSprie:getContentSize().width/2,bgSprie:getContentSize().height-upIcon:getContentSize().width))
		    	upIcon:setScale(iScale)
		    	upIcon:setRotation(90)
		    	bgSprie:addChild(upIcon,1)

		    	local downIcon=CCSprite:createWithSpriteFrameName("leftBtnGreen.png")
		    	downIcon:setAnchorPoint(ccp(0.5,0.5))
		    	downIcon:setPosition(ccp(bgSprie:getContentSize().width/2,downIcon:getContentSize().width))
		    	downIcon:setScale(iScale)
		    	downIcon:setRotation(-90)
		    	bgSprie:addChild(downIcon,2)
		    elseif i==2 then
				local treeCfg=alienTechVoApi:getTreeCfg()
				local cfg=treeCfg[self.selectIndex]
				local point=alienTechVoApi:getPointByType(self.selectIndex)

		    	local str=getlocal("alien_tech_class_point",{point,cfg.totalPoint})
		    	self.totalPointLb=GetTTFLabelWrap(str,24,CCSizeMake(420,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
			    self.totalPointLb:setAnchorPoint(ccp(0.5,0.5))
				-- self.totalPointLb:setColor(G_ColorYellowPro)
				self.totalPointLb:setPosition(getCenterPoint(bgSprie))
				bgSprie:addChild(self.totalPointLb,2)
		    end
			
		-- 	table.insert(self.bgSprieTab,i,bgSprie)
		-- end
	end

	
	local bgSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),click)
	bgSprie:setContentSize(CCSizeMake(440, 110))
	bgSprie:setPosition(ccp(170,self.bgLayer:getContentSize().height-250-110))
	bgSprie:ignoreAnchorPointForPosition(false)
	bgSprie:setIsSallow(true)
	bgSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    bgSprie:setAnchorPoint(ccp(0,0))
    self.bgLayer:addChild(bgSprie,1)
    self.bgSprie4=bgSprie
end

function alienTechDialogTab1:initTableView1()
	local function callBack1(...)
		return self:eventHandler1(...)
    end
    local hd= LuaEventHandler:createHandler(callBack1)
 	self.tv1=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(130,self.bgLayer:getContentSize().height-230-160),nil)
    self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
    self.tv1:setPosition(ccp(35,50+80))
    self.bgLayer:addChild(self.tv1,5)
    self.tv1:setMaxDisToBottomOrTop(120)

end

function alienTechDialogTab1:initTableView2()
    local function callBack2(...)
       return self:eventHandler2(...)
    end
    local hd= LuaEventHandler:createHandler(callBack2)
	self.tv2=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(430,self.bgLayer:getContentSize().height-300-110),nil)
    self.tv2:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv2:setPosition(ccp(175,40))
    self.bgLayer:addChild(self.tv2,2)
    self.tv2:setMaxDisToBottomOrTop(120)

end

function alienTechDialogTab1:initTableView3()
	local function callBack3(...)
       return self:eventHandler3(...)
    end
    local hd= LuaEventHandler:createHandler(callBack3)
	self.tv3=LuaCCTableView:createHorizontalWithEventHandler(hd,CCSizeMake(430,100),nil)
    self.tv3:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv3:setPosition(ccp(5,5))
    self.bgSprie4:addChild(self.tv3,2)
    self.tv3:setMaxDisToBottomOrTop(80)
end


function alienTechDialogTab1:eventHandler1(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local treeCfg=alienTechVoApi:getTreeCfg()
		return SizeOfTable(treeCfg)
	elseif fn=="tableCellSizeForIndex" then
		local treeCfg=alienTechVoApi:getTreeCfg()
		local tmpSize=CCSizeMake(130,120)
		if idx==0 or idx==4 then
			tmpSize=CCSizeMake(130,120+60)
		end
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		-- if idx==0 or idx==5 then
			local labelFontSize=24
			local tStr=""
			if idx==0 then
				tStr=getlocal("alien_tech_common_tank")
			elseif idx==4 then
				tStr=getlocal("alien_tech_special_tank")
			end
			if G_getCurChoseLanguage()=="cn" or G_getCurChoseLanguage()=="tw" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage()=="ko" then
				labelFontSize=24
			else
				labelFontSize=22
			end
			local tLabel=GetTTFLabelWrap(tStr,labelFontSize,CCSizeMake(120,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		    tLabel:setAnchorPoint(ccp(0.5,0.5))
			tLabel:setColor(G_ColorYellowPro)
			tLabel:setPosition(ccp(130/2,60/2+120))
			cell:addChild(tLabel,2)
		-- 	do return cell end
		-- end

		local treeCfg=alienTechVoApi:getTreeCfg()
		local cfg=treeCfg[idx+1]

		-- local rect = CCRect(0, 0, 50, 50);
		-- local capInSet = CCRect(20, 20, 10, 10);
		local function cellClick1()
			if self.tv1 and self.tv1:getScrollEnable()==true and self.tv1:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                
				self:cellClick1(idx)
			end
		end
		-- local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSet,cellClick)
		-- backSprie:setContentSize(CCSizeMake(130-40,115-40))
		-- backSprie:ignoreAnchorPointForPosition(false);
		-- backSprie:setAnchorPoint(ccp(0,0));
		-- backSprie:setTag(idx)
		-- backSprie:setIsSallow(false)
		-- backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		-- backSprie:setPosition(ccp(0+15,5+20));
		-- cell:addChild(backSprie,2)

		local tid=cfg.pic
		local id=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
		-- local iconStr=tankCfg[id].icon
		-- local iconStr=cfg.pic
		local tankSp=G_getTankPic(id,cellClick1)
		-- local tankSp=LuaCCSprite:createWithSpriteFrameName(iconStr,cellClick1)
		if tankSp then
			tankSp:setScale(0.6)
			tankSp:setTouchPriority(-(self.layerNum-1)*20-3)
			tankSp:setPosition(ccp(130/2,120/2))
			cell:addChild(tankSp,2)
		end


		local iconBg=CCSprite:createWithSpriteFrameName("LanguageSelectBtn.png")
	    iconBg:setPosition(ccp(65,60))
	   	cell:addChild(iconBg,1)
		table.insert(self.iconBgTab,idx+1,iconBg)
		iconBg:setVisible(false)

		if (idx+1)==self.selectIndex then
			iconBg:setVisible(true)
		end
		
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
   
	end
end

function alienTechDialogTab1:eventHandler2(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local treeCfg=alienTechVoApi:getTreeCfg()
		local cfg=treeCfg[self.selectIndex]
		return SizeOfTable(cfg.desc)
	elseif fn=="tableCellSizeForIndex" then
		if self.expandIdx[self.selectIndex] and self.expandIdx[self.selectIndex]["k"..idx]~=nil then
			tmpSize=CCSizeMake(self.cellWidth,self.expandHeight)
		else
			tmpSize=CCSizeMake(self.cellWidth,self.normalHeight)
		end
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		

		-- local rect = CCRect(0, 0, 50, 50);
		-- local capInSet = CCRect(20, 20, 10, 10);
		-- local function cellClick(hd,fn,idx)
		-- 	-- return self:cellClick(idx)
		-- end
		-- local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("ItemBtnMore.png",capInSet,cellClick)
		-- backSprie:setContentSize(CCSizeMake(430,115))
		-- backSprie:ignoreAnchorPointForPosition(false);
		-- backSprie:setAnchorPoint(ccp(0,0));
		-- backSprie:setTag(idx)
		-- backSprie:setIsSallow(false)
		-- backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		-- backSprie:setPosition(ccp(0,5));
		-- cell:addChild(backSprie,1)


		self.cellWidth=430

		local treeCfg=alienTechVoApi:getTreeCfg()
		local cfg=treeCfg[self.selectIndex]
		local tid=cfg.desc[idx+1]
		local id=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
		local point=0
		local pointTb=alienTechVoApi:getPointTb()
		if pointTb[self.selectIndex] and pointTb[self.selectIndex][idx+1] then
			point=pointTb[self.selectIndex][idx+1]
		end

		local expanded=false
		if self.expandIdx[self.selectIndex] and self.expandIdx[self.selectIndex]["k"..idx]~=nil then
			expanded=true
		end
		if expanded then
			cell:setContentSize(CCSizeMake(self.cellWidth, self.expandHeight))
		else
			cell:setContentSize(CCSizeMake(self.cellWidth, self.normalHeight))
		end
		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);

		local function cellClick2(hd,fn,idx)
			-- if self.tankResultLockTab[idx-1000+1]==0 then
			    return self:cellClick2(idx)
			-- end
		end
		local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick2)
		headerSprie:setContentSize(CCSizeMake(self.cellWidth, self.normalHeight-4))
		headerSprie:ignoreAnchorPointForPosition(false);
		headerSprie:setAnchorPoint(ccp(0,0));
		headerSprie:setTag(1000+idx)
		headerSprie:setIsSallow(false)
		headerSprie:setTouchPriority(-(self.layerNum-1)*20-1)
		headerSprie:setPosition(ccp(0,cell:getContentSize().height-headerSprie:getContentSize().height));
		cell:addChild(headerSprie)


		if tankCfg[id].icon and tankCfg[id].icon~="" then
			local sprite = tankVoApi:getTankIconSp(id)
			sprite:setAnchorPoint(ccp(0,0.5));
			sprite:setPosition(10,headerSprie:getContentSize().height/2)
			sprite:setScale(0.5)
			headerSprie:addChild(sprite,2)
		end


		local str=getlocal(tankCfg[id].name)
		-- local lbName=GetTTFLabel(str,20)
		-- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
		local isShowGai,tankGaiId=alienTechVoApi:getIsShowTankGai({tid})
		if isShowGai==true and tankGaiId then
            local tGaiId=(tonumber(tankGaiId) or tonumber(RemoveFirstChar(tankGaiId)))
            if tankCfg[tGaiId] then
                local tankGaiName=getlocal(tankCfg[tGaiId].name)
                str=str.."/"..tankGaiName
            end
        end
		local lbName=GetTTFLabelWrap(str,24,CCSizeMake(320,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		lbName:setPosition(90,headerSprie:getContentSize().height/2+22)
		lbName:setAnchorPoint(ccp(0,0.5))
		headerSprie:addChild(lbName,2)
		lbName:setColor(G_ColorGreen)

		
		str=getlocal("alien_tech_point",{point,cfg.pointTab[idx+1]})
		-- local lbPoint=GetTTFLabel(str,20)
		-- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
		local lbPoint=GetTTFLabelWrap(str,20,CCSizeMake(260,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		lbPoint:setPosition(90,headerSprie:getContentSize().height/2-22)
		lbPoint:setAnchorPoint(ccp(0,0.5));
		headerSprie:addChild(lbPoint,2)

		  

		--显示加减号
		local btn
		if expanded==false then
			btn=CCSprite:createWithSpriteFrameName("sYellowAddBtn.png")
		else
			btn=CCSprite:createWithSpriteFrameName("sYellowSubBtn.png")
		end
		btn:setScale(0.8)
		btn:setAnchorPoint(ccp(0,0.5))
		btn:setPosition(ccp(headerSprie:getContentSize().width-10-btn:getContentSize().width,headerSprie:getContentSize().height*0.5))
		headerSprie:addChild(btn)
		btn:setTag(self.extendSpTag)


		if expanded==true then
			self:initExpand(idx,cell)
		end

		
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
   
	end
end

function alienTechDialogTab1:eventHandler3(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		if self.selectIndex>4 then
			return 0
		end
		local treeCfg=alienTechVoApi:getTreeCfg()
		local cfg=treeCfg[self.selectIndex]
		return SizeOfTable(cfg.desc)
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize=CCSizeMake(100,100)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local treeCfg=alienTechVoApi:getTreeCfg()
		local cfg=treeCfg[self.selectIndex]
		local tid=cfg.desc[idx+1]
		local id=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
		local function showAlienBufferInfo()
			if self.tv3 and self.tv3:getScrollEnable()==true and self.tv3:getIsScrolled()==false then
                if G_checkClickEnable()==false then
                    do
                        return
                    end
                else
                    base.setWaitTime=G_getCurDeviceMillTime()
                end
                PlayEffect(audioCfg.mouseClick)
                alienTechVoApi:showBufferDialog(self.layerNum+1,true,true,"",self.selectIndex,tid)
            end
			
		end
		local icon=tankVoApi:getTankIconSp(id,nil,showAlienBufferInfo)
		icon:setAnchorPoint(ccp(0,0))
		icon:setScale(100/icon:getContentSize().width)
		cell:addChild(icon)
		icon:setPosition(0,0)
		icon:setTouchPriority(-(self.layerNum-1)*20-2)

		local bufferLv=alienTechVoApi:getBufferLv(tid,self.selectIndex)
		--alienTechBufFrameLv1.png
		local iconLvFrame = nil
		if bufferLv <= 0 then
			iconLvFrame =CCSprite:createWithSpriteFrameName("alienTechBufFrameLv1.png")
		elseif bufferLv > 3 then
			iconLvFrame =CCSprite:createWithSpriteFrameName("alienTechBufFrameLv3.png")
		else
			iconLvFrame =CCSprite:createWithSpriteFrameName("alienTechBufFrameLv"..bufferLv..".png")
		end
		iconLvFrame:setScale((icon:getContentSize().width-3)/iconLvFrame:getContentSize().width)
		iconLvFrame:setPosition(getCenterPoint(icon))
		icon:addChild(iconLvFrame)

		local clockAdornSp = CCSprite:createWithSpriteFrameName("clockIcon.png")
		clockAdornSp:setAnchorPoint(ccp(1,0))
		clockAdornSp:setScale(2)
		clockAdornSp:setPosition(ccp(icon:getContentSize().width-10,10))
		icon:addChild(clockAdornSp)

		local function tmpFunc()
        end
        local maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
        maskSp:setOpacity(255)
        local spSize=CCSizeMake(icon:getContentSize().width,icon:getContentSize().height)
        maskSp:setContentSize(spSize)
        maskSp:setPosition(getCenterPoint(icon))
        maskSp:setTag(11)
        icon:addChild(maskSp,2)
        if bufferLv==0 then
            maskSp:setVisible(true)
        else
            maskSp:setVisible(false)
        end

		
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
   
	end
end

function alienTechDialogTab1:getLine(lineType,color,rotation,anchorPoint)
	local picStr=""
	if lineType==1 then
		if color==1 then
			picStr="treeGray1.png"
		else
			picStr="treeYellow1.png"
		end
	else
		if color==1 then
			picStr="treeGray2.png"
		else
			picStr="treeYellow2.png"
		end
	end
	local line=CCSprite:createWithSpriteFrameName(picStr)
	-- local line=CCSprite:createWithSpriteFrameName("lineWhite.png")
	-- if color then
	-- 	line:setColor(color)
	-- end
	if anchorPoint then
		line:setAnchorPoint(anchorPoint)
	end
	-- if lineType==1 then
	-- 	local lineSize=line:getContentSize()
	-- 	-- line:setScaleX(self.lineWidth/lineSize.width)
	-- 	line:setScaleY(length/lineSize.height)
	-- end
	if rotation then
		line:setRotation(rotation)
	end
	return line
end


function alienTechDialogTab1:cellClick1(idx)
	for k,v in pairs(self.iconBgTab) do
		local iconBg=tolua.cast(v,"CCSprite")
		if k==(idx+1) then
			iconBg:setVisible(true)
		else
			iconBg:setVisible(false)
		end
	end

	self.selectIndex=idx+1
	if self.totalPointLb then
		local treeCfg=alienTechVoApi:getTreeCfg()
		local cfg=treeCfg[idx+1]
		local point=alienTechVoApi:getPointByType(self.selectIndex)
    	local str=getlocal("alien_tech_class_point",{point,cfg.totalPoint})
		self.totalPointLb:setString(str)
	end

	if idx<4 then
		self.tv2:setViewSize(CCSizeMake(430,self.bgLayer:getContentSize().height-300-110))
		self.bgSprie3:setContentSize(CCSizeMake(440, self.bgLayer:getContentSize().height-280-110))
	    
	    self.bgSprie4:setVisible(true)
	    self.bgSprie4:setContentSize(CCSizeMake(440, 110))
	else
		self.tv2:setViewSize(CCSizeMake(430,self.bgLayer:getContentSize().height-300))
		self.bgSprie3:setContentSize(CCSizeMake(440, self.bgLayer:getContentSize().height-280))
	    self.bgSprie4:setVisible(false)
	    self.bgSprie4:setContentSize(CCSizeMake(0,0))
	end

	if self.tv2 then
		self.tv2:reloadData()
	end
	if self.tv3 then
		self.tv3:reloadData()
	end
end

--点击了cell或cell上某个按钮
function alienTechDialogTab1:cellClick2(idx)
    if self.tv2:getScrollEnable()==true and self.tv2:getIsScrolled()==false then
        PlayEffect(audioCfg.mouseClick)

        if self.expandIdx[self.selectIndex]==nil then
        	self.expandIdx[self.selectIndex]={}
        end
        if self.expandIdx[self.selectIndex]["k"..(idx-1000)]==nil then
                self.expandIdx[self.selectIndex]["k"..(idx-1000)]=idx-1000
                self.tv2:openByCellIndex(idx-1000,self.normalHeight)
        else
            self.expandIdx[self.selectIndex]["k"..(idx-1000)]=nil
            self.tv2:closeByCellIndex(idx-1000,self.expandHeight)
            if self.expandIconBgTab[idx-1000+1] then
            	for k,v in pairs(self.expandIconBgTab[idx-1000+1]) do
            		if v and v.setVisible then
            			v:setVisible(false)
            		end
            	end
            end
        end
    end
end

function alienTechDialogTab1:initExpand(idx,cell)
	if cell then
		local treeCfg=alienTechVoApi:getTreeCfg()
		local cfg=treeCfg[self.selectIndex]

		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);
		local function touchHander()

		end
		local exBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touchHander)
		exBg:setAnchorPoint(ccp(0,0))
		exBg:setContentSize(CCSize(self.cellWidth,self.expandHeight-self.normalHeight-5))
		exBg:setPosition(ccp(0,5))
		exBg:setTag(2)
		cell:addChild(exBg)

		local bgWidth,bgHeight=exBg:getContentSize().width,exBg:getContentSize().height
		local fx=65+3
		local fy=80
		local wSpace=(bgWidth-fx*2)/3
		-- local hSpace=(bgHeight-fy*2)/3
		local lineHeight=50-2
		local heightSpace=4.5


		local num=8
		local tech=cfg.tech
		local bNum=idx*11+1
		local eNum=idx*11+11
		if tech[bNum+2]==0 then
			num=7
		end

		local lineTb={}
		for i=1,num do
			local lType=1
			if num==7 then
				lType=0
			end
			
			lineTb[i]={}
			local lineType=1
			local color=alienTechVoApi:getLineIsUnlock(i,lType,self.selectIndex,idx)
			local rotation=0
			local lineX,lineY
			local anchorPoint
			-- local addLength=self.lineWidth
			if i>=num-7 and i<=num-4 then
				lineType=1
				-- color=2
				rotation=0
				for k=1,3 do
					lineX,lineY=fx+(i-1)*wSpace,bgHeight-fy-lineHeight*k
					if num==7 and i==num-4 then
						lineX,lineY=fx+wSpace/2+wSpace*2,bgHeight-fy-lineHeight*k
					end
					table.insert(lineTb[i],{lineType,color,rotation,lineX,lineY})
				end
			elseif i>=num-3 and i<=num-2 then
				if idx+1==SizeOfTable(cfg.desc) and (tech[bNum+9]==nil or tech[bNum+9]==0) and (tech[bNum+10]==nil or tech[bNum+10]==0) and i==num-2 then
				else
					-- color=1
					local minNum=num-3
					for k=1,7 do
						local isInsert=true
						lineType=1
						if k==3 or k==4 then
							lineType=2
						end
						rotation=0
						if k==3 or k==5 then
							if num==7 and i==num-2 and k==5 then
							else
								rotation=90
							end
						end
						if k==1 or k==2 then
							if num==7 and i==num-2 then
								if k==1 then
									lineX,lineY=fx+wSpace*2.5,bgHeight-fy-lineHeight*4
								elseif k==2 then
									isInsert=false
								end
							else
								lineX,lineY=fx+(k-1)*wSpace+(i-minNum)*wSpace*2,bgHeight-fy-lineHeight*4
							end
						elseif k==3 or k==4 then
							if num==7 and i==num-2 then
								isInsert=false
							else
								lineX,lineY=fx+(k-3)*wSpace+(i-minNum)*wSpace*2,bgHeight-fy-lineHeight*5
							end
						elseif k==5 then
							lineX,lineY=fx+wSpace/2+(i-minNum)*wSpace*2,bgHeight-fy-lineHeight*5
						elseif k==6 then
							lineX,lineY=fx+wSpace/2+(i-minNum)*wSpace*2,bgHeight-fy-lineHeight*5.5-heightSpace
						elseif k==7 then
							lineX,lineY=fx+wSpace/2+(i-minNum)*wSpace*2,bgHeight-fy-lineHeight*6.5-heightSpace
						end
						if isInsert==true then
							table.insert(lineTb[i],{lineType,color,rotation,lineX,lineY})
						end
					end
				end
			elseif i==num-1 then
				if idx+1~=SizeOfTable(cfg.desc) then
					-- color=1
					for k=1,10 do
						lineType=1
						if k==3 or k==4 then
							lineType=2
						end
						rotation=0
						if k==3 or k==5 or k==6 or k==7 then
							rotation=90
						end
						if k==1 or k==2 then
							lineX,lineY=fx+wSpace/2+(k-1)*wSpace*2,bgHeight-fy-lineHeight*7.5-heightSpace
						elseif k==3 or k==4 then
							lineX,lineY=fx+wSpace/2+(k-3)*wSpace*2,bgHeight-fy-lineHeight*8.5-heightSpace
						elseif k==5 or k==6 or k==7 then
							lineX,lineY=bgWidth/2+(k-6)*wSpace/2,bgHeight-fy-lineHeight*8.5-heightSpace
						elseif k==8 or k==9 then
							lineX,lineY=bgWidth/2,bgHeight-fy-lineHeight*(k+1)-heightSpace*2
						end
						table.insert(lineTb[i],{lineType,color,rotation,lineX,lineY})
					end
				end
			elseif i==num then
				if idx+1~=SizeOfTable(cfg.desc) then
					-- color=1
					for k=1,3 do
						rotation=0
						lineX,lineY=bgWidth/2,bgHeight-fy-lineHeight*(k+10)-heightSpace*2
						table.insert(lineTb[i],{lineType,color,rotation,lineX,lineY})
					end
				end
			end
			for k,v in pairs(lineTb[i]) do
				local lineType,color,rotation,lineX,lineY,anchorPoint=v[1],v[2],v[3],v[4],v[5],v[6]
				-- local lineSp=self:getLine(length,color,isHorizontal,anchorPoint)
				local lineSp=self:getLine(lineType,color,rotation,anchorPoint)
				lineSp:setPosition(ccp(lineX,lineY))
				exBg:addChild(lineSp,1)
			end

		end

		self.expandIconBgTab[idx+1]={}
		for i=bNum,eNum do
			local techId=tech[i]
			local index=i-bNum

			if techId and techId~=0 then
				local tCfg=alienTechCfg.talent[techId]
				local icon=tCfg[alienTechCfg.keyCfg.icon][1]
                local subIcon=tCfg[alienTechCfg.keyCfg.icon][2]
				local maxLv=tCfg[alienTechCfg.keyCfg.maxLv]
				local isUnlock=alienTechVoApi:getTechIsUnlock(techId,self.selectIndex)

				local function clickIcon()
					if self and self.tv2 and self.tv2:getScrollEnable()==true and self.tv2:getIsScrolled()==false then
						if G_checkClickEnable()==false then
							do
								return
							end
						else
							base.setWaitTime=G_getCurDeviceMillTime()
						end
						PlayEffect(audioCfg.mouseClick)


						local function upgradeSkill()
							local tPoint=alienTechVoApi:getPointByTypeIndex(self.selectIndex,idx+1)
							alienTechVoApi:setPointByTypeIndex(self.selectIndex,idx+1,tPoint+1)

							self:refresh()
						end
						smallDialog:showAlienTechInfoDialog("TankInforPanel.png",CCSizeMake(550,820),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),true,self.layerNum+1,upgradeSkill,self.selectIndex,techId)

					end
				end

                local tSize=80
				local tIcon
				local tSubIcon
				if isUnlock==true then
					-- tIcon=LuaCCSprite:createWithSpriteFrameName(icon,clickIcon)
					-- tIcon:setTouchPriority(-(self.layerNum-1)*20-2)
					tIcon=CCSprite:createWithSpriteFrameName(icon)		
					if subIcon and subIcon~="" then
						tSubIcon=CCSprite:createWithSpriteFrameName(subIcon)
					end
				else
					tIcon=GraySprite:createWithSpriteFrameName(icon)
					if subIcon and subIcon~="" then
						tSubIcon=GraySprite:createWithSpriteFrameName(subIcon)
					end
				end
                local tScale=tSize/tIcon:getContentSize().width
				tIcon:setScale(tScale)
				if tSubIcon then
					tSubIcon:setPosition(ccp(tSubIcon:getContentSize().width/2+10,tIcon:getContentSize().height-tSubIcon:getContentSize().height/2-10))
					tIcon:addChild(tSubIcon,1)
				end

				local posX,posY
				if index>=0 and index<=3 then
					if num==7 and (index==2 or index==3) then
						posX,posY=fx+2.5*wSpace,bgHeight-fy
					else
						posX,posY=fx+index*wSpace,bgHeight-fy
					end
				elseif index>=4 and index<=7 then
					if num==7 and (index==6 or index==7) then
						posX,posY=fx+2.5*wSpace,bgHeight-fy-lineHeight*3.5
					else
						posX,posY=fx+(index-4)*wSpace,bgHeight-fy-lineHeight*3.5
					end
				elseif index>=8 and index<=9 then
					posX,posY=fx+((1/2)+(index-8)*2)*wSpace,bgHeight-fy-lineHeight*7
				else
					posX,posY=bgWidth/2,bgHeight-fy-lineHeight*11
				end
                local iconBg=LuaCCSprite:createWithSpriteFrameName("Icon_BG.png",clickIcon)
                iconBg:setTouchPriority(-(self.layerNum-1)*20-1)
                iconBg:setScale(tSize/iconBg:getContentSize().width)
                iconBg:setPosition(ccp(posX,posY))
				exBg:addChild(iconBg,3)
				tIcon:setPosition(getCenterPoint(iconBg))
				iconBg:addChild(tIcon,1)
				-- tIcon:setPosition(ccp(posX,posY))
				-- exBg:addChild(tIcon,4)
				table.insert(self.expandIconBgTab[idx+1],iconBg)

				local level=alienTechVoApi:getTechLevel(techId)
				local str=getlocal("scheduleChapter",{level,maxLv})
				local pNumLb=GetTTFLabel(str,20)
				pNumLb:setAnchorPoint(ccp(1,0))
				pNumLb:setPosition(ccp(tIcon:getContentSize().width-10,5))
				pNumLb:setScale(1/tScale)
				tIcon:addChild(pNumLb,1)
			end

		end

	end
end

function alienTechDialogTab1:refresh()
	if self.tv2 then
		local recordPoint=self.tv2:getRecordPoint()
		self.tv2:reloadData()
		self.tv2:recoverToRecordPoint(recordPoint)
	end
	if self.tv3 then
		local recordPoint=self.tv3:getRecordPoint()
		self.tv3:reloadData()
		self.tv3:recoverToRecordPoint(recordPoint)
	end

	if self.totalPointLb then
		local treeCfg=alienTechVoApi:getTreeCfg()
		local cfg=treeCfg[self.selectIndex]
		local point=alienTechVoApi:getPointByType(self.selectIndex)
		local str=getlocal("alien_tech_class_point",{point,cfg.totalPoint})
		self.totalPointLb:setString(str)
	end
		
end

function alienTechDialogTab1:tick()
	
end

function alienTechDialogTab1:dispose()
	self.tv1=nil
	self.tv2=nil
	self.iconBgTab={}
	self.selectIndex=1
	self.expandIdx={}
    self.expandIconBgTab={}
end





