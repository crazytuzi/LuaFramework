stewardTabOne={}

function stewardTabOne:init(layerNum,parent)
	self.layerNum = layerNum
	self.parent = parent
	self.bgSize = parent.bgSize

	self.bgLayer=CCLayer:create()

	self.tvData = stewardVoApi:getStewardData(self.layerNum,1)
	self:initUI()

	return self.bgLayer
end

function stewardTabOne:refreshList()
	self.tvData = stewardVoApi:getStewardData(self.layerNum,1)
	self.cellNum = SizeOfTable(self.tvData)
	self.extractBtn:setEnabled(false)
	local recordPoint = self.tv:getRecordPoint()
    self.tv:reloadData()
    self.tv:recoverToRecordPoint(recordPoint)
    if self.parent and self.parent.checkRedPoint then
    	self.parent:checkRedPoint(1)
    end
end

function stewardTabOne:initUI()
	self.cellNum = SizeOfTable(self.tvData)

	local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function()end)
    tvBg:setContentSize(CCSizeMake(self.bgSize.width-40,self.bgSize.height-210))
    tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setPosition(self.bgSize.width/2,self.bgSize.height-85)
    self.bgLayer:addChild(tvBg)

    local tipLabel = GetTTFLabelWrap(getlocal("steward_tabOne_tip"),20,CCSizeMake(tvBg:getContentSize().width,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    tipLabel:setAnchorPoint(ccp(0.5,1))
    tipLabel:setPosition(self.bgSize.width/2,tvBg:getPositionY()-tvBg:getContentSize().height-10)
    tipLabel:setColor(G_ColorYellowPro)
    self.bgLayer:addChild(tipLabel)

    local function extractHandler(tag,obj)
    	if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        stewardVoApi:lottery(self.tvData, function(sData)
        	if self.extractBtn then
        		self.extractBtn:setEnabled(false)
        	end
        	G_playBoomAction(self.bgLayer,ccp(self.bgSize.width/2,self.bgSize.height/2),function()
        		require "luascript/script/game/scene/gamedialog/stewardLotterySmallDialog"
	        	stewardLotterySmallDialog:showLotteryRewardDialog(self.layerNum+1, getlocal("award"), sData, self.parent)
	        	self:refreshList()
	        	stewardDialog:checkRedPoint(1)
        	end,0.6,3)
        end)
    end
    local btnScale = 0.8
    local extractBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",extractHandler,11,getlocal("steward_title_tabOne"),24/btnScale)
    extractBtn:setScale(btnScale)
    extractBtn:setAnchorPoint(ccp(0.5,1))
    local menu=CCMenu:createWithItem(extractBtn)
    menu:setTouchPriority(-(self.layerNum-1)*20-4)
    menu:setPosition(ccp(self.bgSize.width/2,tipLabel:getPositionY()-tipLabel:getContentSize().height-10))
    self.bgLayer:addChild(menu)
    extractBtn:setEnabled(false)
    self.extractBtn=extractBtn

    local function tvCallBack(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(tvCallBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgSize.width-40,tvBg:getContentSize().height-6),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(20,tvBg:getPositionY()-tvBg:getContentSize().height+3))
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(120)
end

function stewardTabOne:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.cellNum
	elseif fn=="tableCellSizeForIndex" then
		return CCSizeMake(self.bgSize.width-40,90)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellW, cellH = self.bgSize.width-40,90
		local data = self.tvData[idx+1]
		local _freeFlag = false

		local iconBg = CCSprite:createWithSpriteFrameName(data.icon or "icon_bg_gray.png")
		iconBg:setAnchorPoint(ccp(0,0.5))
		iconBg:setPosition(15,cellH/2)
		iconBg:setScale((cellH-18)/iconBg:getContentSize().height)
		cell:addChild(iconBg)

		local sizeWidth = cellW/2
		if G_getCurChoseLanguage() == "ar" then
			sizeWidth = cellW/3
		end
		local nameLb = GetTTFLabelWrap(data.name,22,CCSizeMake(sizeWidth,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop,"Helvetica-bold")
		nameLb:setAnchorPoint(ccp(0,1))
		nameLb:setPosition(iconBg:getPositionX()+iconBg:getContentSize().width*iconBg:getScale()+10,cellH-10)
		cell:addChild(nameLb)

		if data.descTb and data.freeTb and SizeOfTable(data.descTb)==SizeOfTable(data.freeTb) then
			local _posX = nameLb:getPositionX()
			for k, v in pairs(data.descTb) do
				local freeTb = data.freeTb[k]
				local _curFreeNum, _maxFreeNum = freeTb[1], freeTb[2]
				local strSize = 20
				if G_isAsia() == false then
					strSize = 16
				end
				local lb = GetTTFLabel(v.."："..getlocal("scheduleChapter",{_curFreeNum,_maxFreeNum}), strSize)
				lb:setAnchorPoint(ccp(0,0))
				lb:setPosition(_posX, 10)
				if _curFreeNum==0 then
					lb:setColor(G_ColorGray)
				else
					_freeFlag = true
					if data.isCheckBox == true and stewardVoApi:getCheckBoxState(data.key) ~= 1 then
						_freeFlag = false
					end
					if _freeFlag and self.extractBtn then
						self.extractBtn:setEnabled(true)
					end
				end
				cell:addChild(lb)
				if data.isCheckBox == true then
					local costNum = freeTb[3] or 0
					local function operateHandler(tag, obj)
						if tolua.cast(obj, "CCMenuItemToggle") then
							if obj:getSelectedIndex() == 1 then
								obj:setSelectedIndex(0)
								G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("steward_buyR5_tips"),nil,function()
									-- print("cjl ----->>>【确定勾选】", data.key, data.name)
									obj:setSelectedIndex(1)
									stewardVoApi:setCheckBoxState(data.key, 1)
									-- stewardDialog:checkRedPoint(1)
									self:refreshList()
								end)
							else
								-- print("cjl ----->>>【取消勾选】", data.key, data.name)
								stewardVoApi:setCheckBoxState(data.key, 0)
								-- stewardDialog:checkRedPoint(1)
								self:refreshList()
							end
						end
				    end
				    local cbMenu=CCMenu:create()
				    local switchSp1 = CCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
				    local switchSp2 = CCSprite:createWithSpriteFrameName("LegionCheckBtnUn.png")
				    local menuItemSp1 = CCMenuItemSprite:create(switchSp1,switchSp2)
				    local switchSp3 = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
				    local switchSp4 = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
				    local menuItemSp2 = CCMenuItemSprite:create(switchSp3,switchSp4)
				    local checkBox = CCMenuItemToggle:create(menuItemSp1)
				    checkBox:addSubItem(menuItemSp2)
				    checkBox:setScale(0.8)
				    checkBox:setAnchorPoint(CCPointMake(0.5,0.5))
				    checkBox:registerScriptTapHandler(operateHandler)
				    cbMenu:addChild(checkBox)
				    cbMenu:setPosition(_posX + checkBox:getContentSize().width * checkBox:getScale() / 2, checkBox:getContentSize().height * checkBox:getScale() / 2 + 10)
				    cbMenu:setTouchPriority(-(self.layerNum-1)*20-4)
				    cell:addChild(cbMenu)
				    checkBox:setSelectedIndex(stewardVoApi:getCheckBoxState(data.key) or 0)
				    lb:setPosition(cbMenu:getPositionX() + checkBox:getContentSize().width * checkBox:getScale() / 2 + 5, cbMenu:getPositionY())
				    local costLb = GetTTFLabel(getlocal("oneKeyDonateTitle2") .. FormatNumber(costNum), strSize)
				    if costNum == 0 then
				    	costLb:setColor(G_ColorGray)
				    else
				    	costLb:setColor(G_ColorYellowPro)
				    end
				    costLb:setAnchorPoint(ccp(0, 1))
				    costLb:setPosition(lb:getPosition())
				    cell:addChild(costLb)
				    local costIcon = CCSprite:createWithSpriteFrameName("IconCrystal-.png")
				    costIcon:setScale(costLb:getContentSize().height / costIcon:getContentSize().height)
				    costIcon:setPosition(costLb:getPositionX() + costLb:getContentSize().width + costIcon:getContentSize().width * costIcon:getScale() / 2 + 10, costLb:getPositionY() - costIcon:getContentSize().height * costIcon:getScale() / 2)
				    cell:addChild(costIcon)
				end
				_posX = lb:getPositionX()+lb:getContentSize().width+10
			end
		end

		local function onBtnHandler(tag,obj)
			if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            if type(data.jumpTo)=="function" then
            	if self.parent and self.parent.closeDialog then
            		self.parent:closeDialog()
            	end
            	data.jumpTo()
            end
		end
		local button=GetButtonItem("yh_nbSkillGoto.png","yh_nbSkillGoto_Down.png","yh_nbSkillGoto.png",onBtnHandler,idx+1)
        button:setScale(54/button:getContentSize().height)
        button:setAnchorPoint(ccp(0.5,0.5))
        local menu=CCMenu:createWithItem(button)
        menu:setTouchPriority(-(self.layerNum-1)*20-4)
        menu:setPosition(ccp(cellW-button:getContentSize().width*button:getScale()/2-15,cellH/2))
        cell:addChild(menu,11)

        if data.key=="s1" then
        	local function btnHandler(tag,obj)
        		if G_checkClickEnable()==false then
	                do return end
	            else
	                base.setWaitTime=G_getCurDeviceMillTime()
	            end
	            PlayEffect(audioCfg.mouseClick)
	            local function showCallback()
	            	if self.parent and self.parent.closeDialog then
	            		self.parent:closeDialog()
	            	end
                    armorMatrixVoApi:showArmorMatrixDialog(self.layerNum+1)
                    armorMatrixVoApi:showBagDialog(self.layerNum+2)
                end
                armorMatrixVoApi:armorGetData(showCallback)
        	end
        	local strSize = 24
        	if G_isAsia() == false then
        		strSize = 20
        	end
        	local btn=GetButtonItem("steward_green_midBtn.png","steward_green_midBtn_down.png","steward_green_midBtn.png",btnHandler,1,getlocal("hold_name3"),strSize)
        	btn:setScale(54/btn:getContentSize().height)
        	btn:setAnchorPoint(ccp(1,0.5))
        	local btnMenu=CCMenu:createWithItem(btn)
	        btnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	        btnMenu:setPosition(ccp(menu:getPositionX()-button:getContentSize().width*button:getScale()/2-15,cellH/2))
	        cell:addChild(btnMenu,11)
        end

        if _freeFlag==false then
        	iconBg:setColor(G_ColorGray)
        	nameLb:setColor(G_ColorGray)
	        local cellAlpha = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()end)
	        cellAlpha:setContentSize(CCSizeMake(cellW-4,cellH-3))
	        cellAlpha:setPosition(cellW/2,cellH/2)
	        cellAlpha:setOpacity(100)
	        cell:addChild(cellAlpha,10)
    	end

        local lineSp=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
        lineSp:setContentSize(CCSizeMake(cellW-18, 3))
        lineSp:ignoreAnchorPointForPosition(false)
        lineSp:setAnchorPoint(ccp(0.5,0.5))
        lineSp:setPosition(cellW/2,0)
        cell:addChild(lineSp)

		return cell
	elseif fn=="ccTouchBegan" then
		return true
	elseif fn=="ccTouchMoved" then
	elseif fn=="ccTouchEnded" then
	end
end

function stewardTabOne:tick()
	if self and self.tvData then
		local _isRefres=false
		local tvData = stewardVoApi:getStewardData(self.layerNum,1)
		for k, v in pairs(tvData) do
			if self.tvData[k] then
				local freeTb = v.freeTb
				local _freeTb = self.tvData[k].freeTb
				if type(freeTb)=="table" and type(_freeTb)=="table" then
					if SizeOfTable(freeTb)==SizeOfTable(_freeTb) then
						for m, n in pairs(freeTb) do
							if n[1]~=_freeTb[m][1] then
								_isRefres=true
								break
							end
						end
					else
						_isRefres=true
						break
					end
				end
			else
				_isRefres=true
				break
			end
			if _isRefres==true then
				break
			end
		end
		if _isRefres==true then
			self:refreshList()
		end
	end
end

function stewardTabOne:dispose()
	self.cellNum = nil
	self.tvData = nil
	self = nil
end

return stewardTabOne