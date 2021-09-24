alienTechFactoryDialogTab1={}

function alienTechFactoryDialogTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	
	self.tv=nil
	self.cellWidth=580
	self.normalHeight=100
    self.extendSpTag=113
	self.expandIdx={}
    self.expandHeight=936
    self.lineWidth=20
    self.noProduceLb=nil
    self.isShowAll=nil

	return nc
end

function alienTechFactoryDialogTab1:init(layerNum,parent)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.parent=parent
	self.maxRemakeNum=500
	if acTitaniumOfharvestVoApi and acTitaniumOfharvestVoApi:acIsActive()==true then
		self.isShowAll=true
	end

	self:initTableView()
	return self.bgLayer
end

--设置对话框里的tableView
function alienTechFactoryDialogTab1:initTableView()
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(30,30))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)


	self.noProduceLb=GetTTFLabelWrap(getlocal("alien_tech_empty_transform"),24,CCSizeMake(self.bgLayer:getContentSize().width-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.noProduceLb:setPosition(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2)
	self.noProduceLb:setAnchorPoint(ccp(0.5,0.5))
	self.bgLayer:addChild(self.noProduceLb,2)
	self.noProduceLb:setColor(G_ColorGray)

	local canTransformTb=alienTechVoApi:getCanTransformTb(1,self.isShowAll)
	if SizeOfTable(canTransformTb)>0 then
		self.noProduceLb:setVisible(false)
	else
		self.noProduceLb:setVisible(true)
	end
end

function alienTechFactoryDialogTab1:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local canTransformTb=alienTechVoApi:getCanTransformTb(1,self.isShowAll)
		return SizeOfTable(canTransformTb)
	elseif fn=="tableCellSizeForIndex" then
		if self.expandIdx and self.expandIdx["k"..idx]~=nil then
			tmpSize=CCSizeMake(self.cellWidth,self.expandHeight)
		else
			tmpSize=CCSizeMake(self.cellWidth,self.normalHeight)
		end
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local canTransformTb=alienTechVoApi:getCanTransformTb(1,self.isShowAll)
		local tid=canTransformTb[idx+1][1]
		local techId=canTransformTb[idx+1][2]
		local id=(tonumber(tid) or tonumber(RemoveFirstChar(tid)))
		

		local expanded=false
		if self.expandIdx and self.expandIdx["k"..idx]~=nil then
			expanded=true
		end
		if expanded then
			cell:setContentSize(CCSizeMake(self.cellWidth, self.expandHeight))
		else
			cell:setContentSize(CCSizeMake(self.cellWidth, self.normalHeight))
		end
		local rect = CCRect(0, 0, 50, 50);
		local capInSet = CCRect(20, 20, 10, 10);

		local function cellClick(hd,fn,idx)
			-- if self.tankResultLockTab[idx-1000+1]==0 then
			    return self:cellClick(idx)
			-- end
		end
		local headerSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
		headerSprie:setContentSize(CCSizeMake(self.cellWidth, self.normalHeight-4))
		headerSprie:ignoreAnchorPointForPosition(false);
		headerSprie:setAnchorPoint(ccp(0,0));
		headerSprie:setTag(1000+idx)
		headerSprie:setIsSallow(false)
		headerSprie:setTouchPriority(-(self.layerNum-1)*20-2)
		headerSprie:setPosition(ccp(0,cell:getContentSize().height-headerSprie:getContentSize().height));
		cell:addChild(headerSprie)


		if tankCfg[id].icon and tankCfg[id].icon~="" then
			local sprite = tankVoApi:getTankIconSp(id)
			sprite:setAnchorPoint(ccp(0,0.5));
			sprite:setPosition(20,headerSprie:getContentSize().height/2)
			sprite:setScale(0.5)
			headerSprie:addChild(sprite,2)
		end


		local str=getlocal(tankCfg[id].name)

		-- 钛矿丰收周活动是否开启
		if self.isShowAll==true then
			local tLevel=alienTechVoApi:getTechLevel(techId)
			if tLevel and tLevel>0 then
				str = str .. getlocal("activity_TitaniumOfharvest_tab3_sale")
			end
		end
		-- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
		local lbName=GetTTFLabelWrap(str,24,CCSizeMake(320,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
		lbName:setPosition(120,headerSprie:getContentSize().height/2+22)
		lbName:setAnchorPoint(ccp(0,0.5))
		headerSprie:addChild(lbName,2)
		lbName:setColor(G_ColorGreen)


		local minNum=0
		local tankId=canTransformTb[idx+1][1]
		local techId=canTransformTb[idx+1][2]
		local m_tankIndex=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))


        local sale=1
		if self.isShowAll==true then
			local tLevel=alienTechVoApi:getTechLevel(techId)
			if tLevel and tLevel>0 then
				sale=acTitaniumOfharvestVoApi:getValue()
			end
		end
		local costReR4=tankCfg[m_tankIndex].alienUraniumConsume*sale or 0
		local haveReR4=playerVoApi:getR4() or 0

		if haveReR4>0 and costReR4>0 then
			minNum=math.floor(haveReR4/costReR4)
		else
			minNum=0
		end
		if minNum>0 then
			local costTank=tankCfg[m_tankIndex].upgradeShipConsume
			local costTankId=0
			local costTankNum=0
			local haveTankNum=0
			if costTank and costTank~="" then
				local cArr=Split(costTank,",")
				if cArr and SizeOfTable(cArr)>0 then
					costTankId=tonumber(cArr[1]) or 0
					costTankNum=tonumber(cArr[2]) or 0
				end
			end
			if costTankId and costTankId>0 then
				haveTankNum=tankVoApi:getTankCountByItemId(costTankId) or 0
				haveTankNum=haveTankNum+(tankVoApi:getTankCountByItemId(costTankId+40000) or 0)
			end
			if haveTankNum>0 and costTankNum>0 then
				local maxNum=math.floor(haveTankNum/costTankNum)
				if minNum>maxNum then
					minNum=maxNum
				end
			else
				minNum=0
			end
			if minNum>0 then
				local upgradePropConsume=tankCfg[m_tankIndex].upgradePropConsume
				if upgradePropConsume~="" then
					for k,v in pairs(upgradePropConsume) do
						local pid=v[1]
						local num=v[2]
						local havePropNum=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid)))
						local needPropNum=tonumber(num)
						if havePropNum>0 and needPropNum>0 then
							local maxNum=math.floor(havePropNum/needPropNum)
							if minNum>maxNum then
								minNum=maxNum
							end
						else
							minNum=0
							break
						end
					end
				end
			end
		end

		local curNum=tankVoApi:getTankCountByItemId(id) or 0
		str=getlocal("can_smelt_num",{minNum})
		-- str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
		local lbPoint=GetTTFLabelWrap(str,20,CCSizeMake(260,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		lbPoint:setPosition(120,headerSprie:getContentSize().height/2-22)
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
		btn:setPosition(ccp(headerSprie:getContentSize().width-10-btn:getContentSize().width,headerSprie:getContentSize().height/2))
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


function alienTechFactoryDialogTab1:cellClick(idx)
    if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
        PlayEffect(audioCfg.mouseClick)

        if self.expandIdx==nil then
        	self.expandIdx={}
        end
        if self.expandIdx["k"..(idx-1000)]==nil then
                self.expandIdx["k"..(idx-1000)]=idx-1000
                self.tv:openByCellIndex(idx-1000,self.normalHeight)
        else
            self.expandIdx["k"..(idx-1000)]=nil
            self.tv:closeByCellIndex(idx-1000,self.expandHeight)
        end
    end
end

function alienTechFactoryDialogTab1:initExpand(idx,cell)
	if cell then
		local canTransformTb=alienTechVoApi:getCanTransformTb(1,self.isShowAll)
		local tankId=canTransformTb[idx+1][1]
		local techId=canTransformTb[idx+1][2]
		local m_tankIndex=(tonumber(tankId) or tonumber(RemoveFirstChar(tankId)))


		local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function touchHander()
  
        end
        local exBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touchHander)
        exBg:setAnchorPoint(ccp(0,0))
        exBg:setContentSize(CCSize(self.cellWidth,self.expandHeight-self.normalHeight-280-20+40))
        exBg:setPosition(ccp(0,180-40))
        exBg:setTag(2)
        cell:addChild(exBg)
        

        local spriteIcon = tankVoApi:getTankIconSp(m_tankIndex)
        spriteIcon:setAnchorPoint(ccp(0,0.5));
        spriteIcon:setScale(0.5)
        spriteIcon:setPosition(20,exBg:getContentSize().height+60)
        exBg:addChild(spriteIcon,2)

        local function touchInfo()
            PlayEffect(audioCfg.mouseClick)
            tankInfoDialog:create(exBg,m_tankIndex,self.layerNum+1)
        end

        local menuItemInfo = GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touchInfo,11,nil,nil)
        local menuInfo = CCMenu:createWithItem(menuItemInfo);
        menuInfo:setPosition(ccp(520,exBg:getContentSize().height+50));
        menuInfo:setTouchPriority(-(self.layerNum-1)*20-2);
        exBg:addChild(menuInfo,3);
        
        local lifeSp = CCSprite:createWithSpriteFrameName("pro_ship_life.png");
        local iconScale= 50/lifeSp:getContentSize().width
        lifeSp:setAnchorPoint(ccp(0,0.5));
        lifeSp:setPosition(120,exBg:getContentSize().height+90)
        exBg:addChild(lifeSp,2)
        lifeSp:setScale(iconScale)
        
        local attackSp = CCSprite:createWithSpriteFrameName("pro_ship_attack.png");
        attackSp:setAnchorPoint(ccp(0,0.5));
        attackSp:setPosition(280,exBg:getContentSize().height+90)
        exBg:addChild(attackSp,2)
        attackSp:setScale(iconScale)
        
        local typeStr = "pro_ship_attacktype_"..tankCfg[m_tankIndex].attackNum

        local attackTypeSp = CCSprite:createWithSpriteFrameName(typeStr..".png");
        attackTypeSp:setAnchorPoint(ccp(0,0.5));
        attackTypeSp:setPosition(120,exBg:getContentSize().height+35)
        exBg:addChild(attackTypeSp,2)
        attackTypeSp:setScale(iconScale)
        
        local lifeLb=GetTTFLabel(tankCfg[m_tankIndex].life,20)
        lifeLb:setAnchorPoint(ccp(0,0.5))
        lifeLb:setPosition(ccp(180,exBg:getContentSize().height+90))
        exBg:addChild(lifeLb)
        
        local attLb=GetTTFLabel(tankCfg[m_tankIndex].attack,20)
        attLb:setAnchorPoint(ccp(0,0.5))
        attLb:setPosition(ccp(340,exBg:getContentSize().height+90))
        exBg:addChild(attLb)
        
        local attTypeLb=GetTTFLabelWrap(getlocal(typeStr),20,CCSizeMake(24*10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        attTypeLb:setAnchorPoint(ccp(0,0.5))
        attTypeLb:setPosition(ccp(180,exBg:getContentSize().height+35))
        exBg:addChild(attTypeLb)
        
        
        local bgSp = CCSprite:createWithSpriteFrameName("TeamProduceTank_Bg.png");
        bgSp:setAnchorPoint(ccp(0,0.5));
        bgSp:setPosition(0,-30);
        exBg:addChild(bgSp,1);
        
        -- 钛矿丰收周活动是否开启
        local sale=1
		if self.isShowAll==true then
			local tLevel=alienTechVoApi:getTechLevel(techId)
			if tLevel and tLevel>0 then
				sale=acTitaniumOfharvestVoApi:getValue()
			end
		end

        local container=exBg
		local addH=11
		local costReR4=tankCfg[m_tankIndex].alienUraniumConsume*sale or 0
		local costTank=tankCfg[m_tankIndex].upgradeShipConsume
		local costTankId=0
		local costTankNum=0
		local haveTankNum=0
		local haveTankNum1=0
		local haveTankNum2=0
		if costTank and costTank~="" then
			local cArr=Split(costTank,",")
			if cArr and SizeOfTable(cArr)>0 then
				costTankId=tonumber(cArr[1]) or 0
				costTankNum=tonumber(cArr[2]) or 0
			end
		end
		if costTankId and costTankId>0 then
			haveTankNum1=tankVoApi:getTankCountByItemId(costTankId) or 0
			haveTankNum2=tankVoApi:getTankCountByItemId(costTankId+40000) or 0
			haveTankNum=haveTankNum1+haveTankNum2
		end

		local typeLb=GetTTFLabel(getlocal("resourceType"),20)
		typeLb:setAnchorPoint(ccp(0.5,0.5))
		typeLb:setPosition(ccp(150,container:getContentSize().height-40+addH))
		container:addChild(typeLb)

		local resourceLb=GetTTFLabel(getlocal("resourceRequire"),20)
		resourceLb:setAnchorPoint(ccp(0.5,0.5))
		resourceLb:setPosition(ccp(300,container:getContentSize().height-40+addH))
		container:addChild(resourceLb)

		local haveLb=GetTTFLabel(getlocal("resourceOwned"),20)
		haveLb:setAnchorPoint(ccp(0.5,0.5))
		haveLb:setPosition(ccp(450,container:getContentSize().height-40+addH))
		container:addChild(haveLb)



		local tb={
			{titleStr="uranium",spName="resourse_normal_uranium.png",needStr=FormatNumber(costReR4),haveStr=FormatNumber(playerVoApi:getR4()),num1=playerVoApi:getR4(),num2=tonumber(costReR4)},
		}

		local upgradePropConsume=tankCfg[m_tankIndex].upgradePropConsume
		if upgradePropConsume~="" then
			for k,v in pairs(upgradePropConsume) do
				local pid=v[1]
				local num=v[2]
				local name=propCfg[pid].name
				local ptb={titleStr=name,spName=propCfg[pid].icon,needStr=FormatNumber(num),haveStr=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid))),num1=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid))),num2=tonumber(num)}
				table.insert(tb,ptb)
			end
		end
		if costTankId and costTankId>0 and costTankNum>0 then
			local tankIconSp = tankVoApi:getTankIconSp(costTankId)--tankCfg[costTankId].icon
			local tb3={titleStr=tankCfg[costTankId].name,spName=tankIconSp,needStr=costTankNum,haveStr=FormatNumber(haveTankNum),num1=haveTankNum,num2=costTankNum}
			table.insert(tb,tb3)
		end

		addH=0
		local addy=70
		local spSize=50
		local countTb = {}
		for k,v in pairs(tb) do
			local resLb=GetTTFLabelWrap(getlocal(v.titleStr),20,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
			resLb:setAnchorPoint(ccp(0.5,0.5))
			resLb:setPosition(ccp(150,container:getContentSize().height-100+addH-(k-1)*addy))
			container:addChild(resLb)
			local resSp= type(v.spName) == "string" and CCSprite:createWithSpriteFrameName(v.spName) or v.spName
			resSp:setAnchorPoint(ccp(0.5,0.5))
			resSp:setPosition(ccp(40,container:getContentSize().height-100+addH-(k-1)*addy))
			container:addChild(resSp)
			resSp:setScale(spSize/resSp:getContentSize().width)

			local needResLb=GetTTFLabel(v.needStr,20)
			needResLb:setAnchorPoint(ccp(0.5,0.5))
			needResLb:setPosition(ccp(300,container:getContentSize().height-100+addH-(k-1)*addy))
			container:addChild(needResLb)

			local haveResLb=GetTTFLabel(v.haveStr,20)
			haveResLb:setAnchorPoint(ccp(0.5,0.5))
			haveResLb:setPosition(ccp(450,container:getContentSize().height-100+addH-(k-1)*addy))
			container:addChild(haveResLb)

			local checkSp;
			if v.num1>=v.num2 then
				checkSp=CCSprite:createWithSpriteFrameName("IconCheck.png")
			else
				checkSp=CCSprite:createWithSpriteFrameName("IconFault.png")
			end
			checkSp:setAnchorPoint(ccp(0.5,0.5))

			checkSp:setPosition(ccp(400,container:getContentSize().height-100+addH-(k-1)*addy))

			container:addChild(checkSp)
			countTb[k]=needResLb
		end


		local m_numLb=GetTTFLabel(" ",24)
		m_numLb:setPosition(70,-30);
		container:addChild(m_numLb,2);


		local function sliderTouch(handler,object)
			local count = math.floor(object:getValue())
			m_numLb:setString(count)
			if count>0 then
				-- lbTime:setString(GetTimeStr(timeConsume*count))
				for k,v in pairs(countTb) do
					v:setString(FormatNumber(tb[k].num2*count))
				end
			end
		end
		local spBg =CCSprite:createWithSpriteFrameName("ProduceTankSlideBg.png");
		local spPr =CCSprite:createWithSpriteFrameName("ProduceTankSlideBar.png");
		local spPr1 =CCSprite:createWithSpriteFrameName("ProduceTankIconSlide.png");
		local slider = LuaCCControlSlider:create(spBg,spPr,spPr1,sliderTouch);
		slider:setTouchPriority(-(self.layerNum-1)*20-2);
		slider:setIsSallow(true);

		slider:setMinimumValue(0.0);

		slider:setMaximumValue(self.maxRemakeNum);

		slider:setValue(0);
		slider:setPosition(ccp(355,-30))
		slider:setTag(99)
		container:addChild(slider,2)
		m_numLb:setString(math.floor(slider:getValue()))


		local function touchAdd()
			slider:setValue(slider:getValue()+1);
		end

		local function touchMinus()
			if slider:getValue()-1>0 then
		    	slider:setValue(slider:getValue()-1);
			end
		end

		local addSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconMore.png",touchAdd)
		addSp:setPosition(ccp(549,-30))
		container:addChild(addSp,1)
		addSp:setTouchPriority(-(self.layerNum-1)*20-3);

		local minusSp=LuaCCSprite:createWithSpriteFrameName("ProduceTankIconLess.png",touchMinus)
		minusSp:setPosition(ccp(157,-30))
		container:addChild(minusSp,1)
		minusSp:setTouchPriority(-(self.layerNum-1)*20-3);


		local function touch1()
		    PlayEffect(audioCfg.mouseClick)
		    local tid=tonumber(tankCfg[m_tankIndex].sid)
		    local nums=math.floor(tonumber(slider:getValue()))
		    if tid and nums and techId then
		    	local sale=1
				if self.isShowAll==true then
					local tLevel=alienTechVoApi:getTechLevel(techId)
					if tLevel and tLevel>0 then
						sale=acTitaniumOfharvestVoApi:getValue()
					end
				end
			    local result,flag=alienTechVoApi:getIsCanTransform(tid,nums,nil,sale)
			    if result==true then
			        local function alienAddtroopsCallback(fn,data)
						local ret,sData=base:checkServerData(data)
						if ret==true then
							if sData.data and sData.data.alien then
				            	self:setTechData(sData.data.alien)
				            end
				            self:refresh()

			            	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_smelt_success"),30)
						end
			        end
			        local enum=0
			        if flag>0 then
			        	enum=flag
		        	end
			        local function socketFunc()
			        	socketHelper:alienAddtroops(techId,nums,"a"..tid,alienAddtroopsCallback,enum)
			        end
			        if enum>0 then
			        	smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),socketFunc,getlocal("dialog_title_prompt"),getlocal("smelt_tip",{enum}),nil,self.layerNum+1)
			        else
			        	socketFunc()
			        end

			    else
		            smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),getlocal("resourcelimit"),nil,self.layerNum+1)
			    end  
			end
		end
		local menuItem1 = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touch1,11,getlocal("smelt"),24/0.8,101)
		menuItem1:setScale(0.8)
		local btnLb = menuItem1:getChildByTag(101)
		if btnLb then
			btnLb = tolua.cast(btnLb,"CCLabelTTF")
			btnLb:setFontName("Helvetica-bold")
		end
		local menu1 = CCMenu:createWithItem(menuItem1);
		menu1:setPosition(ccp(460,-93));
		menu1:setTouchPriority(-(self.layerNum-1)*20-2);
		container:addChild(menu1,3);

		local upgradePropConsume=tankCfg[m_tankIndex].upgradePropConsume
		if upgradePropConsume~="" then
			for k,v in pairs(upgradePropConsume) do
				local pid=v[1]
				local num=v[2]
				local name=propCfg[pid].name
				local ptb={titleStr=name,spName=propCfg[pid].icon,needStr=FormatNumber(num),haveStr=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid))),num1=bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid))),num2=tonumber(num)}
				table.insert(tb,ptb)
			end
		end


		local isTankEnough=true
		if costTankId and costTankId>0 and costTankNum>0 then
			if haveTankNum and haveTankNum<costTankNum then
				isTankEnough=false
			end
		end
		if upgradePropConsume~="" then
		    local isPropEnough=true
		    for k,v in pairs(upgradePropConsume) do
				local pid=v[1]
				local num=v[2]
				local hasPropNum = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid)))
				if hasPropNum<num then
					isPropEnough=false
				end
			end

			if playerVoApi:getR4()>=tonumber(costReR4) and
			  	isTankEnough==true and isPropEnough==true then
		    
			    local tnum4=playerVoApi:getR4()/tonumber(costReR4)
			    local num4 = math.floor(tnum4)
			    
			    local num5 = haveTankNum
			    
			    local numTab = {num4,num5}

			    for k,v in pairs(upgradePropConsume) do
					local pid=v[1]
					local num=v[2]
					local hasPropNum = bagVoApi:getItemNumId(tonumber(RemoveFirstChar(pid)))
					table.insert(numTab,hasPropNum)
				end

			    table.sort(numTab,function(a,b) return a<b end)
			    if numTab[1]>self.maxRemakeNum then

			       slider:setMaximumValue(self.maxRemakeNum);
			       
			    else

			       slider:setMaximumValue(numTab[1]);
			       
			    end
			    
			    if numTab[1]==1 then
			        slider:setMinimumValue(1.0);
			        slider:setMaximumValue(1.0);
			    else
			        slider:setMinimumValue(1.0);
			    end
			    if haveTankNum1>0 and haveTankNum1<numTab[1] then
		          slider:setValue(haveTankNum1)
		        else
		          slider:setValue(numTab[1]);
		        end
			    menuItem1:setEnabled(true)
			else
			    slider:setMaximumValue(0);
			    menuItem1:setEnabled(false)
			    menu1:setTag(199)

			end

		else
			if playerVoApi:getR4()>=tonumber(costReR4) and isTankEnough==true then
			    
			    local tnum4=playerVoApi:getR4()/tonumber(costReR4)
			    local num4 = math.floor(tnum4)
			    
			    local num5 = haveTankNum
			    
			    local numTab = {num4,num5}

			    table.sort(numTab,function(a,b) return a<b end)
			    if numTab[1]>self.maxRemakeNum then

			       slider:setMaximumValue(self.maxRemakeNum);
			       
			    else

			       slider:setMaximumValue(numTab[1]);
			       
			    end
			    
			    if numTab[1]==1 then
			        slider:setMinimumValue(1.0);
			        slider:setMaximumValue(1.0);
			    else
			        slider:setMinimumValue(1.0);
			    end
			    
			    if haveTankNum1>0 and haveTankNum1<numTab[1] then
		          slider:setValue(haveTankNum1)
		        else
		          slider:setValue(numTab[1]);
		        end
			    menuItem1:setEnabled(true)
			else
			    slider:setMaximumValue(0);
			    menuItem1:setEnabled(false)
			    menu1:setTag(199)

			end

		end

	end
end

function alienTechFactoryDialogTab1:refresh(idx,cell)
	if self.tv then
		local recordPoint=self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)

		-- self:refreshCellExpand(idx,cell)

		if self.noProduceLb then
			local canTransformTb=alienTechVoApi:getCanTransformTb(1,self.isShowAll)
			if SizeOfTable(canTransformTb)>0 then
				self.noProduceLb:setVisible(false)
			else
				self.noProduceLb:setVisible(true)
			end
		end
	end	
end

function alienTechFactoryDialogTab1:tick()
	local isShowAll=true
	if acTitaniumOfharvestVoApi and acTitaniumOfharvestVoApi:acIsActive()==false then
		isShowAll=nil
	end
	if self.isShowAll and self.isShowAll ~= isShowAll then
		self.isShowAll=isShowAll
		local canTransformTb=alienTechVoApi:getCanTransformTb(1,self.isShowAll)
		if self.noProduceLb then
			if SizeOfTable(canTransformTb)>0 then
				self.noProduceLb:setVisible(false)
			else
				self.noProduceLb:setVisible(true)
			end
		end
		self.tv:reloadData()
	end

end

function alienTechFactoryDialogTab1:dispose()
	self.tv=nil
	self.expandIdx={}
    self.noProduceLb=nil
    self.isShowAll=nil
end







