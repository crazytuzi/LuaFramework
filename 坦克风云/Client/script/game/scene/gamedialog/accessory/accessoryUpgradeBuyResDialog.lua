--配件强化购买资源的面板
accessoryUpgradeBuyResDialog=smallDialog:new()

function accessoryUpgradeBuyResDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.dialogWidth=600
	nc.dialogHeight=610
	return nc
end

function accessoryUpgradeBuyResDialog:init(layerNum)
	self.isTouch=nil
	self.layerNum=layerNum

    self.bgSize=CCSizeMake(self.dialogWidth,self.dialogHeight)

	local function nilFunc()
	end
	local dialogBg = G_getNewDialogBg2(self.bgSize, layerNum, nilFunc)
	self.dialogLayer=CCLayer:create()
	self.bgLayer=dialogBg
	self:show()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	
	 -- 标题
    local titleTb={getlocal("accessory_upgrade_buy_res"), 28, G_ColorWhite}
    local titleLbSize=CCSizeMake(550,0)
    local titleBg,titleL,subHeight=G_createNewTitle(titleTb,titleLbSize,nil,true)
    titleBg:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-50))
    dialogBg:addChild(titleBg)

    local function cellClick(hd,fn,idx)
    end
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),cellClick)
	backSprie:setContentSize(CCSizeMake(self.dialogWidth-20,self.dialogHeight-200))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0,0))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
	backSprie:setPosition(ccp(10,110))
    dialogBg:addChild(backSprie)


	self.refTb={}
	self:exbgCellForId(25,dialogBg,self.dialogHeight-320+25)
	self:exbgCellForId(30,dialogBg,self.dialogHeight-520+25)


	local function sureHandler()
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:close()
    end
    local sureItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",sureHandler,2,getlocal("fight_close"),24/0.7)
    sureItem:setScale(0.7)
    local sureMenu=CCMenu:createWithItem(sureItem)
    sureMenu:setPosition(ccp(self.dialogWidth/2,60))
    sureMenu:setTouchPriority(-(layerNum-1)*20-5)
    self.bgLayer:addChild(sureMenu)


	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(ccp(0,0))
	self.dialogLayer:addChild(touchDialogBg)

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(getCenterPoint(sceneGame))
	return self.dialogLayer
end

function accessoryUpgradeBuyResDialog:exbgCellForId(id,parent,m_height)
	local pid="p"..id;
	if self.refTb[pid]==nil then
		self.refTb[pid]={}
	end

	local spacex=10
	local lbName=GetTTFLabelWrap(getlocal(propCfg[pid].name),26,CCSizeMake(26*12,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	lbName:setPosition(150+spacex,150+m_height)
	lbName:setAnchorPoint(ccp(0,0.5));
	parent:addChild(lbName,2)

	local lbNum=GetTTFLabel(getlocal("propHave")..bagVoApi:getItemNumId(id),22)
	lbNum:setPosition(490,23+m_height+10)
	lbNum:setAnchorPoint(ccp(0.5,0.5));
	parent:addChild(lbNum,2)
	self.refTb[pid].lbNum=lbNum

	local sprite = CCSprite:createWithSpriteFrameName(propCfg[pid].icon);
	sprite:setAnchorPoint(ccp(0,0.5));
	sprite:setPosition(20+spacex,120+m_height)
	parent:addChild(sprite,2)

	local labelSize = CCSize(270, 100);
	local lbDescription=GetTTFLabelWrap(getlocal(propCfg[pid].description),22,labelSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	lbDescription:setPosition(130+spacex,75+m_height)
	lbDescription:setAnchorPoint(ccp(0,0.5));
	parent:addChild(lbDescription,2)

	local gemIcon=CCSprite:createWithSpriteFrameName("IconGold.png");
	gemIcon:setPosition(ccp(470,50+m_height+110));
	parent:addChild(gemIcon,2)

	local lbPrice=GetTTFLabel(propCfg[pid].gemCost,24)
	lbPrice:setPosition(gemIcon:getPositionX()+30,gemIcon:getPositionY())
	lbPrice:setAnchorPoint(ccp(0,0.5));
	parent:addChild(lbPrice,2)

	if id==30 then
	else
		local lineSprite=LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,0,1,2),function()end)
		lineSprite:setContentSize(CCSizeMake(554,2))
		lineSprite:setPosition(self.bgSize.width/2,m_height)
		parent:addChild(lineSprite,2)
	end

	
	local function touch1()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

		-- PlayEffect(audioCfg.mouseClick)
		-- if self:useBuffItem(id)>0 then
		-- 	do
		-- 		return
		-- 	end
		-- end
		-- if id==10 then
		-- end
		-- if newGuidMgr:isNewGuiding() then  --新手引导
		-- 	if id==21 then
		-- 		newGuidMgr:toNextStep()
		-- 		self:close();
		-- 	end
		-- end

		local function callbackHandler(num)
			local function callbackUseProc(fn,data)
				--local retTb=OBJDEF:decode(data)
				if base:checkServerData(data)==true then
					--统计使用物品
					statisticsHelper:useItem(pid,num)
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("use_prop_success",{getlocal(propCfg[pid].name)}),28)
					-- self:reloadAndRemenber()
					self:refreshUI(id)
					eventDispatcher:dispatchEvent("accessory.dialog.upgradeBuyRes")
				end
			end
			socketHelper:useProc(id,nil,callbackUseProc,nil,nil,num)
		end
		bagVoApi:showBatchUsePropSmallDialog(pid,self.layerNum+1,callbackHandler)
	end
	local menuItem1 = GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",touch1,11,getlocal("use"),24/0.7)
	menuItem1:setScale(0.7)
	local menu1 = CCMenu:createWithItem(menuItem1);
	menu1:setPosition(ccp(490,40+m_height+60));
	menu1:setTouchPriority(-(self.layerNum-1)*20-2);
	parent:addChild(menu1,3);
	self.refTb[pid].menuItem1=menuItem1

	local  function touch2()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

		
		local  function touchBuy(num2)
			local function callbackUseProc(fn,data)
			--local retTb=OBJDEF:decode(data)
				if base:checkServerData(data)==true then
					--统计购买物品
					statisticsHelper:buyItem(pid,propCfg[pid].gemCost,num2,propCfg[pid].gemCost)
					--统计使用物品
					statisticsHelper:useItem(pid,num2)

					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("use_prop_success",{getlocal(propCfg[pid].name)}),28)
					-- self:reloadAndRemenber()
					--self.tv:reloadData()
					self:refreshUI(id)
					eventDispatcher:dispatchEvent("accessory.dialog.upgradeBuyRes")
				end
			end
			socketHelper:useProc(id,1,callbackUseProc,nil,nil,num2)
		end

		local function buyGems()
			if G_checkClickEnable()==false then
				do
					return
				end
			end
			vipVoApi:showRechargeDialog(self.layerNum+1)
		end
		local pid="p"..id
		local gems=playerVoApi:getGems()
		print("pid,gems,propCfg[pid].gemCost",pid,gems,propCfg[pid].gemCost)
		if gems<tonumber(propCfg[pid].gemCost) then
			local num=tonumber(propCfg[pid].gemCost)-gems
			local smallD=smallDialog:new()
			smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),buyGems,getlocal("dialog_title_prompt"),getlocal("gemNotEnough",{tonumber(propCfg[pid].gemCost),gems,num}),nil,self.layerNum+1)
		else
			-- if self:useBuffItem(id)>0 then
			-- 	do
			-- 		return
			-- 	end
			-- end
			-- local smallD=smallDialog:new()
			-- smallD:initSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),touchBuy,getlocal("dialog_title_prompt"),getlocal("prop_buy_tip",{propCfg[pid].gemCost,getlocal(propCfg[pid].name)}),nil,self.layerNum+1)

			local function callbackHandler(num1)
				touchBuy(num1)
			end
			shopVoApi:showBatchBuyPropSmallDialog(pid,self.layerNum+1,callbackHandler,getlocal("buyAndUse"))
		end
	end
	local menuItem2 = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",touch2,11,getlocal("buyAndUse"),24/0.7)
	menuItem2:setScale(0.7)
	local menu2 = CCMenu:createWithItem(menuItem2);
	menu2:setPosition(ccp(490,40+m_height+60));
	menu2:setTouchPriority(-(self.layerNum-1)*20-2);
	parent:addChild(menu2,3);
	self.refTb[pid].menuItem2=menuItem2
	
	self:refreshUI(id)
end

function accessoryUpgradeBuyResDialog:refreshUI(id)
	local pid="p"..id;
	if self.refTb[pid]==nil then
		self.refTb[pid]={}
	end
	if self.refTb[pid].lbNum then
		local lbNum=tolua.cast(self.refTb[pid].lbNum,"CCLabelTTF")
		if lbNum then
			lbNum:setString(getlocal("propHave")..bagVoApi:getItemNumId(id))
		end
	end
	if bagVoApi:getItemNumId(id)>0 then
		if self.refTb[pid].menuItem1 and tolua.cast(self.refTb[pid].menuItem1,"CCMenuItemSprite") then
			local menuItem1=tolua.cast(self.refTb[pid].menuItem1,"CCMenuItemSprite")
			menuItem1:setVisible(true)
			menuItem1:setEnabled(true)
		end
		if self.refTb[pid].menuItem2 and tolua.cast(self.refTb[pid].menuItem2,"CCMenuItemSprite") then
			local menuItem2=tolua.cast(self.refTb[pid].menuItem2,"CCMenuItemSprite")
			menuItem2:setVisible(false)
			menuItem2:setEnabled(false)
		end
	else
		if self.refTb[pid].menuItem1 and tolua.cast(self.refTb[pid].menuItem1,"CCMenuItemSprite") then
			local menuItem1=tolua.cast(self.refTb[pid].menuItem1,"CCMenuItemSprite")
			menuItem1:setVisible(false)
			menuItem1:setEnabled(false)
		end
		if self.refTb[pid].menuItem2 and tolua.cast(self.refTb[pid].menuItem2,"CCMenuItemSprite") then
			local menuItem2=tolua.cast(self.refTb[pid].menuItem2,"CCMenuItemSprite")
			menuItem2:setVisible(true)
			menuItem2:setEnabled(true)
		end
	end
end

function accessoryUpgradeBuyResDialog:dispose()
	self.isNoticeSp=nil
end