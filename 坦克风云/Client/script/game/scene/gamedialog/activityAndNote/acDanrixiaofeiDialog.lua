acDanrixiaofeiDialog = commonDialog:new()

function acDanrixiaofeiDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.height = 130
	self.dangci = nil
	self.adaH = 0
	if G_getIphoneType() == G_iphoneX then
		self.adaH = 1250 - 1136
	end
	return nc
end

function acDanrixiaofeiDialog:resetTab()
	self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 395-self.adaH))
	self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2, 100+ self.adaH))  
end

function acDanrixiaofeiDialog:initTableView()
	self.cost = acDanrixiaofeiVoApi:getCostLevel()
	self.numberCell = SizeOfTable(self.cost)
	if(G_isIphone5()) and self.numberCell==4 then
		self.height=160
	end
	local function callBack( ... )
		return self:eventHandler(...)
	end 
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 20,G_VisibleSizeHeight - 460 -self.adaH),nil)
	self.bgLayer:addChild(self.tv)
	self.tv:setPosition(ccp(10,110 + self.adaH))
	self.tv:setAnchorPoint(ccp(0,0))
	self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setMaxDisToBottomOrTop(120)
	self:tabClick(0,false)


	local function rechargeCallback(tag,object)
    	PlayEffect(audioCfg.mouseClick)
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        -- print("+++++++",self.dangci)
        local selectReward = acDanrixiaofeiVoApi:getR1()
        local selectNum = SizeOfTable(selectReward[self.dangci] or {})
        -- selectNum=0
        if selectNum~=0 and self["selectSp" .. self.dangci]==nil then
        	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("awardNoChoose"),28)
        	return
        end
        local ChooseFlagList= acDanrixiaofeiVoApi:getChooseFlagList()
        local dijige = ChooseFlagList[self.dangci]
        -- print("++++++++self.dangci,dijige",self.dangci,dijige)
        local function linagqujiangli(fn,data)
        	local ret,sData = base:checkServerData(data)
        	if ret == true then
        		if sData and sData.data and sData.data.aname then
        			-- print("++++++++++++111")
        			acDanrixiaofeiVoApi:updataData(sData.data.aname)
        		end

        		if sData and sData.data and sData.data.accessory then
        			accessoryVoApi:onRefreshData(sData.data.accessory)
        		end
        			
        		local reward = selectReward[self.dangci]
				local item = FormatItem(reward[dijige])

				-- if item[1].type=="h" then
		  --           heroVoApi:addSoul(item[1].key,item[1].num)
		  --       end

        		self.dangci=nil
        		local recordPoint = self.tv:getRecordPoint()
        		self.tv:reloadData()
				self.tv:recoverToRecordPoint(recordPoint)
				self:refreshBtn()
        	end
        end

        local function callback()
        	socketHelper:acDanrixiaofei(self.dangci,dijige,linagqujiangli)
        end
        if dijige==nil then
        	callback()
        else
        	local sd=acXiaofeisongliSmallDialog2:new(self.layerNum + 1)
			local dialog= sd:init(callback,self.dangci,dijige,2)
        end

	
        
    end
    local rewardBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",rechargeCallback,nil,getlocal("daily_scene_get"),25,11)
    rewardBtn:setAnchorPoint(ccp(0.5,0))
    local btLocate = 20
    if G_getIphoneType()  == G_iphoneX then
    	btLocate = 60
    end
    local rewardMenu=CCMenu:createWithItem(rewardBtn)
    rewardMenu:setPosition(ccp(G_VisibleSizeWidth/2,btLocate))
    rewardMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(rewardMenu,1)

    self.rewardBtn=rewardBtn

    if self.dangci==nil then
    	rewardBtn:setEnabled(false)
    end

	local recordPoint = self.tv:getRecordPoint()
	recordPoint.y = 0
	self.tv:recoverToRecordPoint(recordPoint)
end

function acDanrixiaofeiDialog:doUserHandler()
	local function cellClick(hd,fn,index)
	end

	local w = G_VisibleSizeWidth - 20 -- 背景框的宽度
	local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),cellClick)
	backSprie:setContentSize(CCSizeMake(w, 200))
	backSprie:setAnchorPoint(ccp(0,0))
	backSprie:setPosition(ccp(10, G_VisibleSizeHeight - 290))
	self.bgLayer:addChild(backSprie)

	local function touch(tag,object)
		self:openInfo()
	end

	w = w - 10 -- 按钮的x坐标
	local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch,nil,nil,0)
	menuItemDesc:setAnchorPoint(ccp(1,0.5))
	local menuDesc=CCMenu:createWithItem(menuItemDesc)
	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
	menuDesc:setPosition(ccp(w, 50))
	backSprie:addChild(menuDesc)

	local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),28)
	acLabel:setAnchorPoint(ccp(0.5,1))
	acLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 190))
	backSprie:addChild(acLabel)

	local acVo = acDanrixiaofeiVoApi:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
	local messageLabel=GetTTFLabel(timeStr,28)
	messageLabel:setAnchorPoint(ccp(0.5,1))
	messageLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 150))
	backSprie:addChild(messageLabel)

	local desStr = getlocal("activity_danrixiaofei_des_" .. acDanrixiaofeiVoApi:getVersion())
	local desTv, desLabel= G_LabelTableView(CCSizeMake(backSprie:getContentSize().width*0.8, 60),desStr,25,kCCTextAlignmentLeft)
    desTv:setPosition(ccp(20,55))
    backSprie:addChild(desTv)
	desTv:setAnchorPoint(ccp(0,1))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(80)

	local rechargeLabel = GetTTFLabel(getlocal("activity_danrixiaofei_totalMoney_" .. acDanrixiaofeiVoApi:getVersion()),28)
	rechargeLabel:setAnchorPoint(ccp(0,0))
	rechargeLabel:setPosition(ccp(20, 10))
	backSprie:addChild(rechargeLabel)

	self.moneyX = 20 + rechargeLabel:getContentSize().width
	self.totalMoneyLabel = GetTTFLabel(tostring(acDanrixiaofeiVoApi:getAlreadyCost()), 30)
	self.totalMoneyLabel:setAnchorPoint(ccp(0,0))
	self.totalMoneyLabel:setPosition(ccp(self.moneyX, 10))
	self.totalMoneyLabel:setColor(G_ColorYellowPro)
	backSprie:addChild(self.totalMoneyLabel)

	self.goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
	self.goldIcon:setAnchorPoint(ccp(0,0))
	self.goldIcon:setPosition(ccp(self.moneyX + self.totalMoneyLabel:getContentSize().width + 20,10))
	backSprie:addChild(self.goldIcon)

	local totalW = G_VisibleSizeWidth - 20

	local backSprie2 = LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),cellClick)
	backSprie2:setContentSize(CCSizeMake(totalW, 40))
	backSprie2:setAnchorPoint(ccp(0.5,0.5))
	backSprie2:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight - 320))
	self.bgLayer:addChild(backSprie2)

	local goldLabel=GetTTFLabel(getlocal("gem"),28)
	goldLabel:setPosition(ccp(100 ,20))
	goldLabel:setColor(G_ColorGreen)
	backSprie2:addChild(goldLabel)

	local rewardLabel=GetTTFLabel(getlocal("award"),28)
	rewardLabel:setPosition(ccp(totalW - 180,20))
	rewardLabel:setColor(G_ColorGreen)
	backSprie2:addChild(rewardLabel) 

	

end

function acDanrixiaofeiDialog:eventHandler( handler,fn,idx,cel )
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(G_VisibleSizeWidth - 20,self.height*self.numberCell+20)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local scale = 1
		if(G_isIphone5()) and self.numberCell==4 then
			scale = 1
		end
		local addW=110
		local height = self.height
		local totalW = G_VisibleSizeWidth - 20
		local totalH = self.height*self.numberCell+20

		local selectReward = acDanrixiaofeiVoApi:getR1()
		local gudinReward = acDanrixiaofeiVoApi:getR2()
		local ChooseFlagList = acDanrixiaofeiVoApi:getChooseFlagList()
		local isreward = acDanrixiaofeiVoApi:getIsreward()
		local alReadyCost = acDanrixiaofeiVoApi:getAlreadyCost()
		local flagList = acDanrixiaofeiVoApi:getFlaglist()
		local hadAwardList = acDanrixiaofeiVoApi:gethadAwardList()

		for i=1,self.numberCell do
			local selectNum = SizeOfTable(selectReward[i] or {})
			local spWidth=210
			local Flag = acDanrixiaofeiVoApi:getStateByid(i)

			-- 记录领取第几档
			if Flag==2 then
				if self.dangci==nil then
					self.dangci=i
				end
			end

			-- 是否可选
			if selectNum==0 then
				spWidth=210
			else
				local function touchSelect()
					if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
					    if G_checkClickEnable()==false then
					        do
					            return
					        end
					    else
					        base.setWaitTime=G_getCurDeviceMillTime()
					    end

					   local function addSelectSp(selectitem)
					   		if self["selectSp" .. i] then
					   			self["selectSp" .. i]:removeFromParentAndCleanup(true)
					   			self["selectSp" .. i]=nil
					   		end

					   		if selectitem.type=="h" then
					   			self["selectSp" .. i]=G_getItemIcon(selectitem)
					   		else
					   			self["selectSp" .. i]=CCSprite:createWithSpriteFrameName(selectitem.pic)
					   		end
					   		
					   		cell:addChild(self["selectSp" .. i],5)
					   		self["selectSp" .. i]:setPosition(210, self.height/2+(i-1)*height)
					   		self["selectSp" .. i]:setScale(scale*80/self["selectSp" .. i]:getContentSize().width)

					   		local numLabel=GetTTFLabel("x"..selectitem.num,21)
							numLabel:setAnchorPoint(ccp(1,0))
							numLabel:setPosition(self["selectSp" .. i]:getContentSize().width-5, 5)
							numLabel:setScale(self["selectSp" .. i]:getContentSize().width/80/scale)
							self["selectSp" .. i]:addChild(numLabel,1)

					   end
					  
					   local sd=acXiaofeisongliSmallDialog:new(self.layerNum + 1,i)
					   local dialog= sd:init(addSelectSp,2)
					end
				end

				-- 是否已领取
				local selectPic = "unKnowIcon.png"
				local selectCallback=touchSelect
				local heroItem=nil
				if Flag==3 then
					local item = FormatItem(selectReward[i][hadAwardList[i]])
					local function itemInfo()
						propInfoDialog:create(sceneGame,item[1],self.layerNum+1,nil, true,nil,nil)
					end
					selectCallback=itemInfo
					selectPic=item[1].pic
					if item[1].type=="h" then
						heroItem=item[1]
					end
				end

				local sp
				local heroScale=nil

				if heroItem then
					sp,heroScale =  G_getItemIcon(heroItem,nil,false,self.layerNum+1,selectCallback)
				else
					sp =  GetBgIcon(selectPic,selectCallback,nil,80,80)
				end

				sp:setTouchPriority(-(self.layerNum-1) * 20 - 2)
				cell:addChild(sp)
				sp:setPosition(spWidth, self.height/2+(i-1)*height)
				sp:setScale(scale*80/sp:getContentSize().width)

				if Flag==3 then
					local item = FormatItem(selectReward[i][hadAwardList[i]])
					local numLabel=GetTTFLabel("x"..item[1].num,21)
					numLabel:setAnchorPoint(ccp(1,0))
					numLabel:setPosition(sp:getContentSize().width-5, 5)
					numLabel:setScale(sp:getContentSize().width/80/scale)
					sp:addChild(numLabel,1)
				end

				if Flag~=3 then
					local freshIcon = CCSprite:createWithSpriteFrameName("freshIcon.png")
					cell:addChild(freshIcon,6)
					freshIcon:setScale(0.8)
					freshIcon:setPosition(spWidth+18, self.height/2+(i-1)*height+18)
				end
				
				if ChooseFlagList[i] and Flag~=3  then
					local Sreward = selectReward[i]
					local Sitem = FormatItem(Sreward[ChooseFlagList[i]])
					self["selectSp" .. i]=G_getItemIcon(Sitem[1])
			   		cell:addChild(self["selectSp" .. i],5)
			   		self["selectSp" .. i]:setPosition(210, self.height/2+(i-1)*height)
			   		self["selectSp" .. i]:setScale(scale*80/self["selectSp" .. i]:getContentSize().width)

			   		local numLabel=GetTTFLabel("x"..Sitem[1].num,21)
					numLabel:setAnchorPoint(ccp(1,0))
					numLabel:setPosition(self["selectSp" .. i]:getContentSize().width-5, 5)
					numLabel:setScale(self["selectSp" .. i]:getContentSize().width/80/scale)
					self["selectSp" .. i]:addChild(numLabel,1)
				end

				local isDajiang = false 
				if isreward and isreward[i] and isreward[i][1] and isreward[i][1]==1 then
					isDajiang=true
				end
				if isDajiang then
					-- G_addRectFlicker(sp,(1/scale)*1.1,(1/scale)*1.1)
					if heroScale then
						G_addRectFlicker(sp,(1/scale/heroScale)*1.36,(1/scale/heroScale)*1.36,nil,3)
					else
						G_addRectFlicker(sp,(1/scale)*1.15,(1/scale)*1.15,nil,3)
					end
					
				end

				spWidth=210+addW
			end
			

			local gudingNum = SizeOfTable(gudinReward[i]) or {}
			for j=1,gudingNum do
				local item = FormatItem(gudinReward[i][j])
				local icon,iconScale = G_getItemIcon(item[1],80,true,self.layerNum)
				-- local icon =  GetBgIcon(item[1].pic,nil,nil,80,80)
				icon:setTouchPriority(-(self.layerNum-1)*20-2)
				cell:addChild(icon)
				icon:setPosition(spWidth+(j-1)*addW, self.height/2+(i-1)*height)
				icon:setScale(scale*80/icon:getContentSize().width)

				local numLabel=GetTTFLabel("x"..item[1].num,21)
				numLabel:setAnchorPoint(ccp(1,0))
				numLabel:setPosition(icon:getContentSize().width-5, 5)
				numLabel:setScale(icon:getContentSize().width/scale/80)
				icon:addChild(numLabel,1)

				local isNum = 1
				if spWidth==210 then
					isNum=j
				else
					isNum=j+1
				end

				local isDajiang = false 
				if isreward and isreward[i] and isreward[i][isNum] and isreward[i][isNum]==1 then
					isDajiang=true
				end

				if isDajiang then
					-- G_addRectFlicker(sp,(1/scale)*1.1,(1/scale)*1.1)
					G_addRectFlicker(icon,(1/iconScale)*scale*1.15,(1/iconScale)*scale*1.15,nil,3)
				end

			end
			local strSize2 = 22
			local strWidth2 = 120
			if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
				strSize2 =25
				strWidth2 = 100
			end
			-- 判断 条件不足  可领取  已领取
			if Flag==1 then
				local noLabel = GetTTFLabelWrap(getlocal("activity_totalRecharge_no"),strSize2,CCSizeMake(strWidth2,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				noLabel:setPosition(ccp(540,self.height/2+(i-1)*height))
				cell:addChild(noLabel)
			elseif Flag==2 then
				local noLabel = GetTTFLabelWrap(getlocal("canReward"),25,CCSizeMake(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
				noLabel:setPosition(ccp(540,self.height/2+(i-1)*height))
				cell:addChild(noLabel)
				noLabel:setColor(G_ColorGreen)
			else
				local rightIcon=CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
				rightIcon:setAnchorPoint(ccp(0.5,0.5))
				rightIcon:setPosition(ccp(540,self.height/2+(i-1)*height))
				cell:addChild(rightIcon,1)
			end
			

			local lvCost = self.cost[i] or i*1000
			local needGolds = GetTTFLabel(tostring(lvCost),28)
			needGolds:setColor(G_ColorGreen)
            needGolds:setAnchorPoint(ccp(1,1))
            needGolds:setPosition(ccp(160,self.height+(i-1)*height))	
            cell:addChild(needGolds,2)

			local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
            lineSprite:setScaleX((totalW + 30)/lineSprite:getContentSize().width)
            lineSprite:setPosition(ccp((totalW + 30)/2 + 30,0+(i-1)*height))
            cell:addChild(lineSprite)

			if i == self.numberCell then
				local lineSprite2 = CCSprite:createWithSpriteFrameName("LineCross.png")
				lineSprite2:setScaleX((totalW + 30)/lineSprite:getContentSize().width)
				lineSprite2:setPosition(ccp((totalW + 30)/2 + 30,totalH-20))
				cell:addChild(lineSprite2,5)
			end
		end

		local verticalLine = CCSprite:createWithSpriteFrameName("LineCross.png")
		verticalLine:setScaleX(totalH/verticalLine:getContentSize().width)
		verticalLine:setRotation(90)
		verticalLine:setPosition(ccp(160 ,totalH/2))
		cell:addChild(verticalLine,2)

		local barWidth = totalH-20
		local function click(hd,fn,idx)
		end
		local barSprie = LuaCCScale9Sprite:createWithSpriteFrameName("HelpBgBottom.png", CCRect(20,20,1,1),click)
		barSprie:setContentSize(CCSizeMake(barWidth, 50))
		barSprie:setRotation(90)
		barSprie:setPosition(ccp(35,barWidth/2))
		cell:addChild(barSprie,1)

		AddProgramTimer(cell,ccp(35,barWidth/2),11,12,nil,"AllBarBg.png","AllXpBar.png",13,1,1)
		local per = acDanrixiaofeiVoApi:getPercentage()
		local timerSpriteLv = cell:getChildByTag(11)
		timerSpriteLv=tolua.cast(timerSpriteLv,"CCProgressTimer")
		timerSpriteLv:setPercentage(per)
		timerSpriteLv:setRotation(-90)
		timerSpriteLv:setScaleX(barWidth/timerSpriteLv:getContentSize().width)
		local bg = cell:getChildByTag(13)
		bg:setVisible(false)

		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function acDanrixiaofeiDialog:refreshBtn()
	if self.dangci==nil then
    	self.rewardBtn:setEnabled(false)
    else
    	self.rewardBtn:setEnabled(true)
    end
end


function acDanrixiaofeiDialog:openInfo()
	if G_checkClickEnable()==false then
		do
			return
		end
	else
		base.setWaitTime=G_getCurDeviceMillTime() -- 防止两个按钮同时被点击
	end
	PlayEffect(audioCfg.mouseClick)
	local version=1
	if acDanrixiaofeiVoApi:getVersion()==1 then
		version=1
	end
	local td=smallDialog:new()
	local tabStr = {getlocal("activity_xiaofeisongli_tip4_" .. version),getlocal("activity_danrixiaofei_tip3_" .. version), getlocal("activity_danrixiaofei_tip2_" .. version),getlocal("activity_danrixiaofei_tip1_" .. version),"\n"}
	local colorTb = {nil,G_ColorWhite,G_ColorWhite,G_ColorWhite,G_ColorWhite,G_ColorWhite,nil}

	local flag = false
	local selectRew = acDanrixiaofeiVoApi:getR1() -- 可选奖励
	for i=1,#selectRew do
		if selectRew[i] then
			local num = SizeOfTable(selectRew[i])
			if num > 0 then
				flag=true
				break
			end
		end
	end

	if flag then
		table.insert(tabStr,1,getlocal("activity_xiaofeisongli_tip5_" .. version))
		table.insert(tabStr,1,"\n")
		table.insert(colorTb,1,G_ColorRed)
		table.insert(colorTb,1,nil)
	else
		table.insert(tabStr,1,"\n")
		table.insert(colorTb,2,nil)
	end

	local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,colorTb)
	sceneGame:addChild(dialog,self.layerNum+1)
end

function acDanrixiaofeiDialog:refresh()
	self.totalMoneyLabel:setString(acDanrixiaofeiVoApi:getAlreadyCost())
	self.dangci=nil
	local recordPoint=self.tv:getRecordPoint()
	self.tv:reloadData()
	self.tv:recoverToRecordPoint(recordPoint)
	self:refreshBtn()
end

function acDanrixiaofeiDialog:tick()
    local vo=acDanrixiaofeiVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

    if acDanrixiaofeiVoApi:isToday()==false then
    	acDanrixiaofeiVoApi:refresh()
    	self:refresh()
    end
end

function acDanrixiaofeiDialog:dispose()
	self.dangci=nil
end