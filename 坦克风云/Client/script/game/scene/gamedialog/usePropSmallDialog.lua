usePropSmallDialog=smallDialog:new()

function usePropSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.reward={}
	self.dialogHeight=700
	self.dialogWidth=550
	-- self.pageCellNum=10
	self.cellHeight=120
	self.isKP=false
	return nc
end

function usePropSmallDialog:init(layerNum,reward,pid,useNum)
	self.layerNum=layerNum
	self.reward=reward
	self.pid=pid
	self.useNum=useNum or 0

	local function nilFunc()
	end
	local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),nilFunc)
	self.dialogLayer=CCLayer:create()
	
	local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(size)
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true);

	-- local function close()
	-- 	PlayEffect(audioCfg.mouseClick)
	-- 	return self:close()
	-- end
	-- local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	-- closeBtnItem:setPosition(0,0)
	-- closeBtnItem:setAnchorPoint(CCPointMake(0,0))
		 
	-- self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	-- self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
	-- self.closeBtn:setPosition(ccp(size.width-closeBtnItem:getContentSize().width,size.height-closeBtnItem:getContentSize().height))
	-- dialogBg:addChild(self.closeBtn)
	local lbSize2 = 30
	if G_getCurChoseLanguage() =="ko" then
		lbSize2 =25
	end
	if propCfg[self.pid] then
		local nameStr=getlocal(propCfg[self.pid].name)
		local titleLb=GetTTFLabelWrap(getlocal("use_prop_desc",{self.useNum,nameStr}),lbSize2,CCSizeMake(self.dialogWidth-20,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		titleLb:setAnchorPoint(ccp(0.5,0.5))
		titleLb:setPosition(ccp(size.width/2,size.height-titleLb:getContentSize().height/2-25))
		dialogBg:addChild(titleLb)
	end


	--确定
    local function sureHandler()
        PlayEffect(audioCfg.mouseClick)

        -- AI部队随机箱子的处理 start
        local tipStr = nil
        for k, v in pairs(self.reward) do
            local num = tonumber(v.num)
            if v.type == "at" and v.eType == "a" then --AI部队
                if AITroopsVoApi:isExist(v.key) == true or num > 1 then
                	if tipStr == nil then
                		tipStr = ""
                	end
                    local aiFragmentNum = AITroopsVoApi:getModelCfg().fragmentExchangeNum * (num > 1 and (num - 1) or num)
                    local aiName = AITroopsVoApi:getAITroopsNameStr(v.key)
                    tipStr = tipStr .. getlocal("alreadyHasAITroopsTipDesc", { aiName, aiName, aiFragmentNum})
                end
                G_addPlayerAward(v.type, v.key, v.id, 1, nil, true)
            end
        end
        if tipStr then
        	smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tipStr, 30)
        end
        -- AI部队随机箱子的处理 end

        self:close()
    end
    local sureItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",sureHandler,2,getlocal("ok"),25)
    local sureMenu=CCMenu:createWithItem(sureItem)
    sureMenu:setPosition(ccp(self.dialogWidth/2,60))
    sureMenu:setTouchPriority(-(layerNum-1)*20-2)
    dialogBg:addChild(sureMenu)

	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1);

	self:initTableView()

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
end

function usePropSmallDialog:initTableView()
	self.tvHeight=self.dialogHeight-170
    local function callBack(...)
    	return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth-40,self.dialogHeight-210),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,105))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(self.cellHeight)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function usePropSmallDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local num=SizeOfTable(self.reward)
		return num
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		tmpSize=CCSizeMake(self.dialogWidth-40,self.cellHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
    	local cell=CCTableViewCell:new()
    	cell:autorelease()

    	local cellWidth=self.dialogWidth-40

    	local picSize=100
    	local item=self.reward[idx+1]
    	if item then
    		local propIcon
    		if item.type=="p" then
    			local pid=item.key
    			propIcon=bagVoApi:getItemIcon(pid)
    		else
				propIcon=G_getItemIcon(item,picSize)
    		end
    		if propIcon then
    			propIcon:setPosition(ccp(70,self.cellHeight/2))
    			cell:addChild(propIcon,1)
    		end
    		local name=item.name or ""
    		-- name="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    		local nameLb=GetTTFLabelWrap(name,25,CCSizeMake(cellWidth-160,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    		nameLb:setAnchorPoint(ccp(0,1))
    		nameLb:setPosition(ccp(140,self.cellHeight-15))
    		cell:addChild(nameLb,1)
    		local num=item.num or 0
    		local numLb=GetTTFLabel(getlocal("propInfoNum",{num}),25)
    		numLb:setAnchorPoint(ccp(0,0))
    		numLb:setPosition(ccp(140,15))
    		cell:addChild(numLb,1)
    		-- if self.pid =="p880" and self.isKP ==false then
    		-- 	if item.key =="gems" and item.type=='u' and tonumber(item.num) >=100 then
    		-- 		local message={key="getGemsAiring",param={playerVoApi:getPlayerName(),getlocal("sample_prop_name_880"),item.num}}
      --     			chatVoApi:sendSystemMessage(message)
      --     			self.isKP =true
    		-- 	end
    		-- end
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
