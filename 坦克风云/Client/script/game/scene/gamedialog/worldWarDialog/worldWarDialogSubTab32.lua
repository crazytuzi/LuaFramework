worldWarDialogSubTab32={}

function worldWarDialogSubTab32:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
	self.parent=nil

	self.cellHeght=230

	if G_getIphoneType() ==	G_iphoneX then
		self.cellHeght = 180
	end
	
	self.hSpace=50
	self.maskSp=nil
	self.descLb=nil
	
    return nc
end

function worldWarDialogSubTab32:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
	self.parent=parent
	self:initDesc()
	self:initTableView()
    return self.bgLayer
end

function worldWarDialogSubTab32:initDesc()
	local str=getlocal("world_war_shop_desc2")
	local descLb=GetTTFLabelWrap(str,25,CCSizeMake(G_VisibleSizeWidth-150,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	descLb:setAnchorPoint(ccp(0,0.5))
	descLb:setPosition(ccp(30,G_VisibleSizeHeight-225-self.hSpace-20))
	descLb:setColor(G_ColorYellowPro)
	self.bgLayer:addChild(descLb)

	local function showInfo()
		if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
		local tabStr={"\n",getlocal("world_war_shop_tip_4"),"\n",getlocal("world_war_shop_tip_3",{worldWarCfg.shoppingtime}),"\n",getlocal("world_war_shop_tip_2"),"\n",getlocal("world_war_shop_tip_1"),"\n"};
		local tabColor={nil,G_ColorRed,nil,G_ColorYellow,nil,G_ColorYellow,nil,G_ColorYellow,nil}
		PlayEffect(audioCfg.mouseClick)
		local td=smallDialog:new()
		local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,tabColor)
		sceneGame:addChild(dialog,self.layerNum+1)
	end
	local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
	local infoBtn = CCMenu:createWithItem(infoItem);
	infoBtn:setPosition(ccp(G_VisibleSizeWidth-80,G_VisibleSizeHeight-210-self.hSpace-30))
	infoBtn:setTouchPriority(-(self.layerNum-1)*20-3)
	self.bgLayer:addChild(infoBtn)	

	local function tmpFunc()
    end
    self.maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),tmpFunc)
    self.maskSp:setOpacity(255)
    local size=CCSizeMake(G_VisibleSizeWidth-50,self.bgLayer:getContentSize().height-290-self.hSpace-25)
    self.maskSp:setContentSize(size)
    self.maskSp:setAnchorPoint(ccp(0,0))
    self.maskSp:setPosition(ccp(25,25))
    self.maskSp:setIsSallow(true)
    self.maskSp:setTouchPriority(-(self.layerNum-1)*20-5)
    self.bgLayer:addChild(self.maskSp,3)

	self.descLb=GetTTFLabelWrap(getlocal("serverwar_cannot_reward_rare"),30,CCSizeMake(self.maskSp:getContentSize().width-60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.descLb:setAnchorPoint(ccp(0.5,0.5))
	self.descLb:setPosition(getCenterPoint(self.maskSp))
	self.descLb:setColor(G_ColorRed)
	self.maskSp:addChild(self.descLb,1)

	
	-- local status=worldWarVoApi:checkStatus()
	-- if status and status<40 then
	local status=worldWarVoApi:getShopShowStatus()
	if status<=0 then
		self.maskSp:setPosition(ccp(25,25))
		self.descLb:setString(getlocal("world_war_shop_open_1"))
	else
		-- local buyStatus=worldWarVoApi:getBuyStatus()
		-- if buyStatus==2 then
		if status==2 then
			self.maskSp:setPosition(ccp(10000,0))
		else
			self.maskSp:setPosition(ccp(25,25))
			self.descLb:setString(getlocal("world_war_shop_open_2"))
		end
	end
end

function worldWarDialogSubTab32:initTableView()
	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,self.bgLayer:getContentSize().height-290-self.hSpace-35),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(30,30))
	self.tv:setMaxDisToBottomOrTop(120)
	self.bgLayer:addChild(self.tv)
end

function worldWarDialogSubTab32:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		local rareList=worldWarVoApi:getRareList()
		local num=SizeOfTable(rareList)
		return num
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize = CCSizeMake(G_VisibleSizeWidth-60,self.cellHeght)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20,20,10,10),function () end)
		backSprie:setContentSize(CCSizeMake(G_VisibleSizeWidth-65,self.cellHeght))
		backSprie:setPosition(ccp((G_VisibleSizeWidth-60)/2,self.cellHeght/2))
		backSprie:setTouchPriority(-(self.layerNum-1)*20-1)

		local showList=worldWarVoApi:getRareList()
		local shopVo=showList[idx+1]
		local id=shopVo.id
		local num=shopVo.num or 0

		local rareItems=worldWarVoApi:getShopRareItems()
		local cfg=rareItems[id]
		local rewardTb=FormatItem(cfg.reward)
		local price=cfg.price
		local maxNum=cfg.buynum

		local nameStrTb={}
		for k,v in pairs(rewardTb) do
			table.insert(nameStrTb,v.name.." x"..FormatNumber(v.num))
		end
		local nameLb=GetTTFLabel(table.concat(nameStrTb, ", "),25)
		nameLb:setAnchorPoint(ccp(0,0.5))
		nameLb:setColor(G_ColorGreen)
		nameLb:setPosition(ccp(10,(self.cellHeght/2+50+self.cellHeght)/2))
		backSprie:addChild(nameLb)

		local limitLb=GetTTFLabel("("..num.."/"..maxNum..")",25)
		limitLb:setAnchorPoint(ccp(0,0.5))
		limitLb:setPosition(ccp(10+nameLb:getContentSize().width+5,(self.cellHeght/2+50+self.cellHeght)/2))
		backSprie:addChild(limitLb)

		local award=rewardTb[1]
		local iconSize=100
		local icon=G_getItemIcon(award,iconSize,false,self.layerNum)
		if icon then
			icon:setAnchorPoint(ccp(0,0.5))
			icon:setPosition(ccp(10,self.cellHeght/2-10))
			backSprie:addChild(icon)
		end

		local descLb=GetTTFLabelWrap(getlocal(rewardTb[1].desc),22,CCSizeMake(G_VisibleSizeWidth-335,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
		descLb:setAnchorPoint(ccp(0,1))
		descLb:setPosition(ccp(130,self.cellHeght/2+40))
		backSprie:addChild(descLb)

		local priceDescLb=GetTTFLabel(getlocal("serverwar_point"),25)
		priceDescLb:setPosition(ccp(G_VisibleSizeWidth-135,self.cellHeght*3/4))
		backSprie:addChild(priceDescLb)

		local priceLb=GetTTFLabel(price,25)
		priceLb:setPosition(ccp(G_VisibleSizeWidth-135,self.cellHeght/2+10))
		if(worldWarVoApi:getPoint()<price)then
			priceLb:setColor(G_ColorRed)
		else
			priceLb:setColor(G_ColorYellowPro)
		end
		backSprie:addChild(priceLb)

		local function onClick(tag,object)
			if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				if G_checkClickEnable()==false then
		            do
		                return
		            end
		        else
		            base.setWaitTime=G_getCurDeviceMillTime()
		        end
				local showList=worldWarVoApi:getRareList()
				local shopVo=showList[idx+1]
				local id=shopVo.id
				local num=shopVo.num or 0
				if(num>=maxNum)then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwar_buy_num_full"),30)
					do return end
				end
				if(worldWarVoApi:getPoint()<price)then
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("serverwar_point_not_enough"),30)
					do return end
				end
				-- -- if(tag)then
				-- 	self:buyItem(shopVo)
				-- -- end
				local saveLocalKey = "keyWorldWar2"
                local function onSureBuyItem()
                    self:buyItem(shopVo)
                end
                local function secondTipFunc(sbFlag)
                    local sValue=base.serverTime .. "_" .. sbFlag
                    G_changePopFlag(saveLocalKey,sValue)
                end
                if G_isPopBoard(saveLocalKey) then
                    G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des2",{price}),true,onSureBuyItem,secondTipFunc)
                else
                    onSureBuyItem()
                end
			end
		end
		local buyItem = GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall.png",onClick,nil,getlocal("code_gift"),25)
		buyItem:setTag(idx+1)
		buyItem:setScale(0.8)
		if(num>=maxNum)then
			buyItem:setEnabled(false)
		end
		local buyBtn = CCMenu:createWithItem(buyItem)
		buyBtn:setPosition(ccp(G_VisibleSizeWidth-135,self.cellHeght/4))
		buyBtn:setTouchPriority(-(self.layerNum-1)*20-2)
		backSprie:addChild(buyBtn)

		cell:addChild(backSprie,1)
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then
	end
end

function worldWarDialogSubTab32:buyItem(shopVo)
	local id=shopVo.id
	local num=shopVo.num
	local rareItems=worldWarVoApi:getShopRareItems()
	local cfg=rareItems[id]
	local rewardTb=FormatItem(cfg.reward)
	local price=cfg.price
	local maxNum=cfg.buynum

	if (num<maxNum) and (worldWarVoApi:getPoint()>=price) then
		local function callback()
			-- local function onGetData(data)
			-- 	self:initWithData(data)
				local recordPoint = self.tv:getRecordPoint()
				self.tv:reloadData()
				self.tv:recoverToRecordPoint(recordPoint)
				if self.parent and self.parent.doUserHandler then
					self.parent:doUserHandler()
				end
			-- end
			-- allianceShopVoApi:getAShopData(onGetData)
		end
		worldWarVoApi:buyItem(2,id,callback)
	end
end

function worldWarDialogSubTab32:doUserHandler()

end

function worldWarDialogSubTab32:tick()
	if self and self.maskSp and self.descLb then
		-- local status=worldWarVoApi:checkStatus()	
		-- if status and status<40 then
		local status=worldWarVoApi:getShopShowStatus()
		if status<=0 then
			self.maskSp:setPosition(ccp(25,25))
			self.descLb:setString(getlocal("world_war_shop_open_1"))
		else
			-- local buyStatus=worldWarVoApi:getBuyStatus()
			-- if buyStatus==2 then
			if status==2 then
				self.maskSp:setPosition(ccp(10000,0))
			else
				self.maskSp:setPosition(ccp(25,25))
				self.descLb:setString(getlocal("world_war_shop_open_2"))
			end
		end
	end
end

function worldWarDialogSubTab32:refresh()

end

function worldWarDialogSubTab32:dispose()
    self.tv=nil
    self.bgLayer=nil
    self.layerNum=nil
    self.cellHeght=nil
	self.hSpace=nil
	self.maskSp=nil
	self.descLb=nil
end






