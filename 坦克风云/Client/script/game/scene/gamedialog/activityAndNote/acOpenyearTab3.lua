acOpenyearTab3 ={}
function acOpenyearTab3:new(layerNum)
        local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=layerNum
    return nc
end

function acOpenyearTab3:init()
	self.bgLayer=CCLayer:create()

	local lbH=self.bgLayer:getContentSize().height-210
	if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage()=="ja" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then

		local desLb=GetTTFLabelWrap(getlocal("activity_openyear_des3"),25,CCSize(460,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	    desLb:setAnchorPoint(ccp(0,0.5))
	    desLb:setPosition(50,lbH)
	    self.bgLayer:addChild(desLb)
	   
	else
		-- lbH=lbH-50-30
		if G_isIphone5() then
			desTv, desLabel = G_LabelTableView(CCSizeMake(460, 100),getlocal("activity_openyear_des3"),25,kCCTextAlignmentLeft)
		else
			desTv, desLabel=G_LabelTableView(CCSizeMake(460, 100),getlocal("activity_openyear_des3"),25,kCCTextAlignmentLeft)
		end
		desTv:setAnchorPoint(ccp(0,1))
	    desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	    desTv:setPosition(ccp(50,lbH-50))
	    desTv:setMaxDisToBottomOrTop(80)
	    self.bgLayer:addChild(desTv)
	end
	 lbH=lbH-50-30
    -- local function nilFunc()
    -- end
    -- local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("wsjdzz_di3.png",CCRect(48, 48, 2, 2),nilFunc)
    -- backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width
    -- 	-80,lbH))
    -- backSprie:ignoreAnchorPointForPosition(false)
    -- backSprie:setAnchorPoint(ccp(0.5,0))
    -- backSprie:setIsSallow(false)
    -- backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
    -- backSprie:setPosition(ccp(G_VisibleSizeWidth/2,30))
    -- self.bgLayer:addChild(backSprie)

    self.tvH=lbH-10
    self:addTV()

	return self.bgLayer
end

function acOpenyearTab3:addTV()
	self.cellHeight=185
	self.taskTb=acOpenyearVoApi:getCurrentTaskState()
	self.cellNum=SizeOfTable(self.taskTb)
	local function callBack(...)
         return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,self.tvH),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,40))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function acOpenyearTab3:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then	 	
        return self.cellNum
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
		tmpSize=CCSizeMake(G_VisibleSizeWidth-40,self.cellHeight)
		return  tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()

        local function nilFunc()
	    end
	    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("wsjdzz_di3.png",CCRect(48, 48, 2, 2),nilFunc)
	    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width
	    	-40,self.cellHeight-5))
	    backSprie:ignoreAnchorPointForPosition(false)
	    backSprie:setAnchorPoint(ccp(0,0))
	    backSprie:setPosition(ccp(0,5))
	    cell:addChild(backSprie)

		local greenLineSp2=CCSprite:createWithSpriteFrameName("openyear_line.png")
		backSprie:addChild(greenLineSp2)
		greenLineSp2:setPosition(backSprie:getContentSize().width/2,4)

	    local valueTb=self.taskTb[idx+1].value

	    -- 任务类型
	    local typeStr=valueTb.key
	    local titleStr=getlocal("activity_chunjiepansheng_" .. typeStr .. "_title",{self.taskTb[idx+1].haveNum,valueTb.needNum})

	    -- 任务描述
	    local lbStarWidth=20
		local titleLb=GetTTFLabelWrap(titleStr,25,CCSizeMake(400,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	    titleLb:setAnchorPoint(ccp(0,1))
		titleLb:setColor(G_ColorYellowPro)
		titleLb:setPosition(ccp(lbStarWidth,backSprie:getContentSize().height-15))
		backSprie:addChild(titleLb,1)

		local bgdiSp = CCSprite:createWithSpriteFrameName("openyear_singleBg.png")
		backSprie:addChild(bgdiSp)
		bgdiSp:setScaleX(400/bgdiSp:getContentSize().width)
		bgdiSp:setAnchorPoint(ccp(0,1))
		bgdiSp:setOpacity(120)
		bgdiSp:setPosition(lbStarWidth-13,backSprie:getContentSize().height-5)

		-- 奖励描述
		local posx222 = G_getCurChoseLanguage() == "ar" and lbStarWidth - 10 or lbStarWidth
		local desH=(self.cellHeight - titleLb:getContentSize().height-30)/2
		local desLb=GetTTFLabelWrap(getlocal("activity_rechargeDouble_get"),22,CCSizeMake(100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		desLb:setAnchorPoint(ccp(0,0.5))
		-- desLb:setColor(G_ColorYellowPro)
		desLb:setPosition(ccp(posx222,desH))
		backSprie:addChild(desLb)

		-- 奖励展示
		local rewardItem=FormatItem(valueTb.reward,nil,true)
		local taskW=0
		for k,v in pairs(rewardItem) do
			local icon = G_getItemIcon(v,100,true,self.layerNum+1,nil,self.tv,nil,nil,nil)
			icon:setTouchPriority(-(self.layerNum-1)*20-2)
			backSprie:addChild(icon)
			icon:setAnchorPoint(ccp(0,0.5))
			icon:setPosition(k*100+20, desH)
			local scale=80/icon:getContentSize().width
			icon:setScale(scale)
			taskW=k*100


			local numLabel=GetTTFLabel("x"..FormatNumber(v.num),22)
			numLabel:setAnchorPoint(ccp(1,0))
			numLabel:setPosition(icon:getContentSize().width-5, 5)
			numLabel:setScale(1/scale)
			icon:addChild(numLabel,1)
		end

		local index=self.taskTb[idx+1].index
		if index>10000 then -- 已完成(已领取)
            local p1Sp=CCSprite:createWithSpriteFrameName("monthlysignFreeGetIcon.png")
            backSprie:addChild(p1Sp)
            p1Sp:setPosition(ccp(backSprie:getContentSize().width-90,backSprie:getContentSize().height/2))
            p1Sp:setScale(0.6)
		elseif index>1000 then -- 未完成
			local function goTiantang()
				if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				    if G_checkClickEnable()==false then
				        do
				            return
				        end
				    else
				        base.setWaitTime=G_getCurDeviceMillTime()
				    end

				    G_goToDialog2(valueTb.key,4,true)
				end

			end
			-- local goItemScale=1
			-- local goItemImage1,goItemImage2,goItemImage3="BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png"
			-- if acOpenyearVoApi:getAcShowType()==acOpenyearVoApi.acShowType.TYPE_2 then
				local goItemScale=0.8
				local goItemImage1,goItemImage2,goItemImage3="creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png"
			-- end
			local goItem=GetButtonItem(goItemImage1,goItemImage2,goItemImage3,goTiantang,nil,getlocal("activity_heartOfIron_goto"),24/goItemScale)
			goItem:setScale(goItemScale)
			local goBtn=CCMenu:createWithItem(goItem);
			goBtn:setTouchPriority(-(self.layerNum-1)*20-2);
			goBtn:setPosition(ccp(backSprie:getContentSize().width-90,backSprie:getContentSize().height/2))
			backSprie:addChild(goBtn)
		else -- 可领取
			local function rewardTiantang()
				if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				    if G_checkClickEnable()==false then
				        do
				            return
				        end
				    else
				        base.setWaitTime=G_getCurDeviceMillTime()
				    end

				    local action="taskreward"
					local tid=valueTb.index

					local function refreshFunc(rewardlist)
						self.taskTb=acOpenyearVoApi:getCurrentTaskState()
				    	local recordPoint=self.tv:getRecordPoint()
						self.tv:reloadData()
						self.tv:recoverToRecordPoint(recordPoint)

						-- 此处加弹板
						if rewardlist then
							acOpenyearVoApi:showRewardDialog(rewardlist,self.layerNum)
						end
				    end
					acOpenyearVoApi:socketOpenyear(action,refreshFunc,tid)

				end
			end
			-- local rewardItemScale=1
			-- local rewardItemImage1,rewardItemImage2,rewardItemImage3="BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png"
			-- if acOpenyearVoApi:getAcShowType()==acOpenyearVoApi.acShowType.TYPE_2 then
				local rewardItemScale=0.8
				local rewardItemImage1,rewardItemImage2,rewardItemImage3="newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png"
			-- end
			-- "BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall.png"
			local rewardItem=GetButtonItem(rewardItemImage1,rewardItemImage2,rewardItemImage3,rewardTiantang,nil,getlocal("daily_scene_get"),24/rewardItemScale)
			rewardItem:setScale(rewardItemScale)
			local rewardBtn=CCMenu:createWithItem(rewardItem);
			rewardBtn:setTouchPriority(-(self.layerNum-1)*20-2);
			rewardBtn:setPosition(ccp(backSprie:getContentSize().width-90,backSprie:getContentSize().height/2))
			backSprie:addChild(rewardBtn)
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

function acOpenyearTab3:refresh()
	if self.tv then
		self.taskTb=acOpenyearVoApi:getCurrentTaskState()
		local recordPoint=self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
	end
end

function acOpenyearTab3:tick()
end

function acOpenyearTab3:dispose( )
    self.layerNum=nil
end