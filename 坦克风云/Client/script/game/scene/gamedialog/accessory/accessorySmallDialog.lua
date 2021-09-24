--弹出配件信息小面板
accessorySmallDialog=smallDialog:new()

function accessorySmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	nc.dialogHeight=500
	nc.dialogWidth=550

	nc.parent=nil
	nc.data=nil
	nc.type=0		  --是配件还是碎片
	return nc
end

--param layerNum: 显示层次
--param type: 1是配件, 2是碎片, 3是道具
--param data: 数据
--param parent: 父UI
--param tankID: 坦克ID
--param partID: 部位ID
--param canSell: 是否可以出售
function accessorySmallDialog:init(layerNum,type,data,parent,tankID,partID,canSell)
	self.layerNum=layerNum
	self.parent=parent
	self.type=type
	self.data=data
	self.tankID=tankID
	self.partID=partID
	self.canSell=canSell

	local function nilFunc()
	end

	local titleStr
	if(self.type==3)then
		titleStr=getlocal(accessoryCfg.propCfg[self.data.id].name)
	else
		local quality=self.data:getConfigData("quality")
		if(self.type==1)then
			if(quality==1)then
				titleStr=getlocal("accessory_greenQuality")
			elseif(quality==2)then
				titleStr=getlocal("accessory_blueQuality")
			elseif(quality==3)then
				titleStr=getlocal("accessory_purpleQuality")
			elseif(quality==4)then
				titleStr=getlocal("accessory_orangeQuality")
            elseif(quality==5)then
                titleStr=getlocal("accessory_redQuality")
			else
				titleStr=getlocal("accessory")
			end
		else
			titleStr=getlocal("elite_challenge_fragment_"..quality,{""})
		end
	end

	local function close()
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end

	local size=CCSizeMake(self.dialogWidth,self.dialogHeight)

	self.dialogLayer=CCLayer:create()
	local dialogBg = G_getNewDialogBg(size, titleStr, 32, nil, layerNum, true, close)
	self.bgLayer=dialogBg
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true);

	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc);
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(640,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(180)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg,1);

	local icon
	local iconSize=100
	if(self.type==1)then
		icon=accessoryVoApi:getAccessoryIcon(self.data.type,80,iconSize,nil)
	elseif(self.type==2)then
		icon=accessoryVoApi:getFragmentIcon(self.data.id,80,iconSize,nil)
	elseif(self.type==3)then
		icon=CCSprite:createWithSpriteFrameName(accessoryCfg.propCfg[self.data.id].icon)
		icon:setScale(iconSize/icon:getContentSize().width)
	end
	icon:setAnchorPoint(ccp(0,0))
	icon:setPosition(50,self.dialogHeight-200)
	dialogBg:addChild(icon)

	local nameLb
	if(self.type==3)then
		nameLb=GetTTFLabelWrap(getlocal(accessoryCfg.propCfg[self.data.id].name),25,CCSizeMake(icon:getContentSize().width+75,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	else
		nameLb=GetTTFLabelWrap(getlocal(self.data:getConfigData("name")),25,CCSizeMake(icon:getContentSize().width+75,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	end
	nameLb:setAnchorPoint(ccp(0.5,1))
	local posX,posY=icon:getPosition()
	nameLb:setPosition(posX+iconSize/2,posY-5)
	dialogBg:addChild(nameLb)

	local leftMaxPos=posY-nameLb:getContentSize().height

	if(self.type==2)then
		local numLb
		if(self.data:getConfigData("quality")>=4)then
			numLb=GetTTFLabel(self.data.num,25)
		else
			numLb=GetTTFLabel(self.data.num.."/"..self.data:getConfigData("composeNum"),25)
		end
		numLb:setAnchorPoint(ccp(0.5,1))
		numLb:setPosition(posX+iconSize/2,posY-5-nameLb:getContentSize().height)
		dialogBg:addChild(numLb)
		leftMaxPos=leftMaxPos-numLb:getContentSize().height
	elseif(self.type==3)then
		local numLb
		if(self.data.id=="p11")then
			numLb=GetTTFLabel(self.data.num.."/"..accessoryCfg.change.use["p11"],25)
			if(self.data.num<accessoryCfg.change.use["p11"])then
				numLb:setColor(G_ColorRed)
			end
		else
			numLb=GetTTFLabel(self.data.num,25)
		end
		numLb:setAnchorPoint(ccp(0.5,1))
		numLb:setPosition(posX+iconSize/2,posY-5-nameLb:getContentSize().height)
		dialogBg:addChild(numLb)
		leftMaxPos=leftMaxPos-numLb:getContentSize().height
	end

	posX,posY=200,self.dialogHeight-140
	if(self.type==3)then
		local descLb=GetTTFLabelWrap(getlocal(accessoryCfg.propCfg[self.data.id].desc),25,CCSizeMake(self.dialogWidth - posX - 10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		descLb:setAnchorPoint(ccp(0,1))
		descLb:setPosition(posX,posY)
		dialogBg:addChild(descLb)

		posY = posY - descLb:getContentSize().height - 10
		local sourceStr=getlocal("accessory_sourceDesc")
		local sourceTb=accessoryCfg.propCfg[self.data.id].source
		for k,v in pairs(sourceTb) do
			sourceStr=sourceStr.." "..getlocal("accessory_sourceWay_"..v)..","
		end
		sourceStr=string.sub(sourceStr,1,string.len(sourceStr)-1)
		if(#sourceTb>0)then
			local sourceLb=GetTTFLabelWrap(sourceStr,25,CCSizeMake(self.dialogWidth - posX - 10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			sourceLb:setAnchorPoint(ccp(0,1))
			sourceLb:setPosition(ccp(posX,posY))
			dialogBg:addChild(sourceLb)
		end
	else
		local rank
		if(self.data.rank==nil)then
			rank=0
		else
			rank=self.data.rank
		end
		self.rankLb=GetTTFLabel(getlocal("accessory_rank",{rank}),25)
		self.rankLb:setAnchorPoint(ccp(0,0))
		self.rankLb:setPosition(posX,posY)
		dialogBg:addChild(self.rankLb)
	
		posY=posY-35
		local lv
		if(self.data.lv==nil)then
			lv=0
		else
			lv=self.data.lv
		end
		self.lvLb=GetTTFLabel(getlocal("accessory_lv",{lv}),25)
		self.lvLb:setAnchorPoint(ccp(0,0))
		self.lvLb:setPosition(posX,posY)
		dialogBg:addChild(self.lvLb)
	
		local tmpVo
		if(self.type==1)then
			tmpVo=data
		else
			tmpVo=accessoryVo:new()
			tmpVo:initWithData({self.data:getConfigData("output"),0,0})
		end
		local attTb=tmpVo:getAtt()
		local attTypeTb=tmpVo:getConfigData("attType")
		local attEffectTb=accessoryCfg.attEffect
		self.attLbs={}
		for k,v in pairs(attTypeTb) do
			posY=posY-35
			local effectStr
			if(attEffectTb[tonumber(v)]==1)then
				effectStr=string.format("%.2f",attTb[k]).."%%"
			else
				effectStr=attTb[k]
			end
			local attLb=GetTTFLabel(getlocal("accessory_attAdd_"..v,{effectStr}),25)
			attLb:setAnchorPoint(ccp(0,0))
			attLb:setPosition(posX,posY)
			dialogBg:addChild(attLb)
			self.attLbs[k]=attLb
		end
	end
	if(self.type==3)then
		local function onConfirm()
			if(self.data.id=="p11" and self.data.num>=accessoryCfg.change.use["p11"])then
				local function callback()
					smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_successfulOperation"),28)
					self:close()
				end
				accessoryVoApi:composeProp("p11",1,callback)
			else
				self:close()
			end			
		end
		local buttonStr
		if(self.data.id=="p11")then
			buttonStr=getlocal("compose")
		else
			buttonStr=getlocal("confirm")
		end
		local composeItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onConfirm,2,buttonStr,24/0.7,38)
		composeItem:setScale(0.7)
		if(self.data.id=="p11")then
			if(self.data.num<accessoryCfg.change.use["p11"])then
				composeItem:setEnabled(false)
			end
		end
		local composeBtn=CCMenu:createWithItem(composeItem)
		composeBtn:setPosition(self.dialogWidth/2,60)
		composeBtn:setTouchPriority(-(layerNum-1)*20-2)
		dialogBg:addChild(composeBtn)
		sceneGame:addChild(self.dialogLayer,layerNum)
		self.dialogLayer:setPosition(ccp(0,0))
		do return end
	end

	if(self.type==1)then
		posY=posY-12
		self.gsLb=GetTTFLabelWrap(getlocal("accessory_gsAdd",{self.data:getGS()}),28,CCSizeMake(dialogBg:getContentSize().width-200,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
		self.gsLb:setColor(G_ColorGreen)
		self.gsLb:setAnchorPoint(ccp(0,1))
		self.gsLb:setPosition(posX,posY)
		dialogBg:addChild(self.gsLb)
	end

	if(leftMaxPos<posY)then
		posY=leftMaxPos
	end

	local tankStr
	local tankID
	local btnHeight
	local localStr
	if(self.type==1)then
		tankID=self.data:getConfigData("tankID")
		btnHeight=175
		localStr="accessory_fit_part"
	elseif(self.type==2)then
		local output=self.data:getConfigData("output")
		if(output~="")then
			local aCfg=accessoryCfg.aCfg[output]
			if(aCfg~=nil)then
				tankID=aCfg.tankID
			else
				tankID=1
			end
		end
		btnHeight=120
		localStr="accessory_fragment_fit_part"
	end
	if(tankID==1)then
		tankStr=getlocal("tanke")
	elseif(tankID==2)then
		tankStr=getlocal("jianjiche")
	elseif(tankID==3)then
		tankStr=getlocal("zixinghuopao")
	elseif(tankID==4)then
		tankStr=getlocal("huojianche")
	end
	if(tankStr)then
		local tankLb=GetTTFLabelWrap(getlocal(localStr,{tankStr}),25,CCSizeMake(self.dialogWidth-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)		
		tankLb:setAnchorPoint(ccp(0.5,0.5))
	
		tankLb:setPosition(dialogBg:getContentSize().width/2,(posY-btnHeight)/2+btnHeight-30)
		dialogBg:addChild(tankLb)
	end

	-- 添加判断
	local topFlag = self:topIsCanDispose(self.canSell,self.data:getConfigData("quality"))

	local function onClickSell()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		local function callBack()
			self:sell()
		end
		if topFlag then
			local str = getlocal("accessory_depose_check",{getlocal(self.data:getConfigData("name"))})
			allianceSmallDialog:showOKDialog(callBack,str,layerNum+1)

		else
			callBack()
		end
	end

	local sellItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onClickSell,2,getlocal("decompose"),24/0.7,38)
	sellItem:setScale(0.7)
	local sellBtn=CCMenu:createWithItem(sellItem);
	sellBtn:setPosition(ccp(size.width-120,60))
	sellBtn:setTouchPriority(-(layerNum-1)*20-2);
	dialogBg:addChild(sellBtn)

	-- 添加判断
	if topFlag then
		-- local num=accessoryVoApi:checkAccesoryNum(self.data.type)
		local num=accessoryVoApi:checkHigherQualityNum(self.data.type)
		if num<2 then
			sellItem:setEnabled(false)
			sellItem:setVisible(false)
		end
	end

	if(self.canSell~=1)then
		sellItem:setEnabled(false)
		local function onClickMask()
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_onlybagcansell"),28)
		end
		

		local function onClickMask2()
			-- if self.canSell==2 then
			-- 	do return end
			-- end

			-- PlayEffect(audioCfg.mouseClick)
			-- self:close()
			-- activityAndNoteDialog:closeAllDialog()
			-- require "luascript/script/game/scene/gamedialog/purifying/purifyingDialog1"
			-- local td=purifyingDialog1:new()
			-- local tbArr={}
			-- local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("purifying"),true,self.layerNum+1)
			-- sceneGame:addChild(dialog,4)
		end
		local callback=onClickMask
		local sellStr=getlocal("decompose")
		if accessoryVoApi:succinctIsOpen() and self.data:getConfigData("quality")>2 then
			sellItem:setEnabled(true)
			sellStr = getlocal("purifying")
			callback=onClickMask2
			local lb = tolua.cast(sellItem:getChildByTag(38),"CCLabelTTF")
			lb:setString(getlocal("purifying"))


		end

		local sellMaskItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",callback,2,sellStr,24/0.7)
		sellMaskItem:setScale(0.7)
		sellMaskItem:setOpacity(0)
		local sellMaskBtn=CCMenu:createWithItem(sellMaskItem)
		sellMaskBtn:setPosition(sellBtn:getPosition())
		sellMaskBtn:setTouchPriority(-(layerNum-1)*20-3)
		dialogBg:addChild(sellMaskBtn)
		if self.canSell==2 then
			sellItem:setEnabled(false)

		end
	end

	local function onClickLeftBtn()
		if G_checkClickEnable()==false then
			do return end
		else
			base.setWaitTime=G_getCurDeviceMillTime()
		end
		PlayEffect(audioCfg.mouseClick)
		if(self.type==1)then
			self:ware()
		else
			self:compose()
		end
	end
	local btnStr
	local showBtnFlag=false
	if(self.type==1)then
		if(self.tankID~=nil)then
			btnStr=getlocal("accessory_unware")
		else
			btnStr=getlocal("accessory_ware")
		end
		local tankID="t"..self.data:getConfigData("tankID")
		local partID="p"..self.data:getConfigData("part")
		if(accessoryVoApi.equip[tankID]==nil or accessoryVoApi.equip[tankID][partID]==nil)then
			showBtnFlag=true
		end
	else
		local composeNum=tonumber(self.data:getConfigData("composeNum"))
		if(self.data.num>=composeNum)then
			showBtnFlag=true
			btnStr=getlocal("compose")
		else
			local multiNum=accessoryVoApi:getMultiFragmentNum()
			if(self.data.num+multiNum>=composeNum)then
				btnStr=getlocal("compose")
			else
				btnStr=getlocal("accessory_get")
			end
		end
	end
	local leftItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",onClickLeftBtn,2,btnStr,24/0.7)
	leftItem:setScale(0.7)
	if(showBtnFlag)then
		local capInSet1 = CCRect(17, 17, 1, 1)
		local function touchClick()
		end
		local wareIcon=LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
		wareIcon:setScale(0.5/0.7)
		wareIcon:setPosition(ccp(180,55))
		leftItem:addChild(wareIcon)
	end
	local leftBtn=CCMenu:createWithItem(leftItem);
	leftBtn:setPosition(ccp(120,60))
	leftBtn:setTouchPriority(-(layerNum-1)*20-2);
	dialogBg:addChild(leftBtn)

	-- 碎片，有配件，4 隐藏
	if self.type==2 and tonumber(self.data:getConfigData("quality"))>=4 then
		leftBtn:setVisible(false)
		sellBtn:setPosition(ccp(size.width/2,60))
		local output = self.data:getConfigData("output")
		-- local num = accessoryVoApi:checkAccesoryNum(output)
		local num=accessoryVoApi:checkHigherQualityNum(output)
		if num~=0 then
			sellItem:setEnabled(true)
		else
			sellItem:setEnabled(false)
		end
	end

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))

	local function onRefresh(event,data)
		for k,v in pairs(data.type) do
			if(v==1 or v==2)then
				self:refresh()
				break
			end
		end
	end
	self.refreshListener=onRefresh
	eventDispatcher:addEventListener("accessory.data.refresh",self.refreshListener)
end

function accessorySmallDialog:sell()
	accessoryVoApi:showDecomposeDialog(self.layerNum+1,self.type,self.data,self)
end

function accessorySmallDialog:ware()
	if(accessoryVoApi:checkCanWare(self.data)==false)then
		local unlockLv=accessoryCfg.partUnlockLv[tonumber(self.data:getConfigData("part"))]
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_part_unlock_desc",{unlockLv}),30)
		do return end 
	end
	local tankID=self.data:getConfigData("tankID")
	local partID=self.data:getConfigData("part")
	local equipData=accessoryVoApi:getAccessoryByPart(tankID,partID)
	if(equipData and equipData.bind==1)then
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_cantWare"),30)
		do return end
	end
	local function callback(data)
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_ware_success"),28)
		self:close()
		if(data.oldfc and data.newfc)then
			local oldpower=tonumber(data.oldfc)
			local newpower=tonumber(data.newfc)
			local function onShowPowerChange()
				smallDialog:showPowerChangeEffect(oldpower,newpower)
			end
			local callFunc=CCCallFunc:create(onShowPowerChange)
			local delay=CCDelayTime:create(0.5)
			local acArr=CCArray:create()
			acArr:addObject(delay)
			acArr:addObject(callFunc)
			local seq=CCSequence:create(acArr)
			sceneGame:runAction(seq)
		end
	end
	if(self.type==1 and self.data~=nil)then
		accessoryVoApi:ware(self.data.id,callback)
	end
end

function accessorySmallDialog:compose()
	local needNum=tonumber(self.data:getConfigData("composeNum"))
	local leftGrid=accessoryVoApi:getABagLeftGrid()
	local function callback()
		smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_successfulOperation"),30)
		self:close()
	end
	if(self.data.num<needNum)then
		local multiNum=accessoryVoApi:getMultiFragmentNum()
		if(self.data.num+multiNum<needNum)then
			self.parent.parent:tabClick(1)
			self:close()
			self.parent.parent:close()
			-- activityAndNoteDialog:closeAllDialog()
			accessoryVoApi:showSupplyDialog(4)
			do return end
		else
			if(leftGrid==nil or leftGrid<=0)then
				smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_bag_full"),30)
				do return end
			end
			local function onConfirm()
				accessoryVoApi:compose(self.data.id,true,callback)
			end
			smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),onConfirm,getlocal("dialog_title_prompt"),getlocal("accessory_use_multiFragment"),nil,self.layerNum+1)
		end
	else
		if(leftGrid==nil or leftGrid<=0)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("accessory_bag_full"),30)
			do return end
		end
		accessoryVoApi:compose(self.data.id,false,callback)
	end
end

function accessorySmallDialog:refresh()
	self.rankLb:setString(getlocal("accessory_rank",{self.data.rank}))
	self.lvLb:setString(getlocal("accessory_lv",{self.data.lv}))
	local tmpVo
	if(self.type==1)then
		tmpVo=self.data
	else
		tmpVo=accessoryVo:new()
		tmpVo:initWithData({self.data:getConfigData("output"),0,0})
	end
	local attTb=tmpVo:getAtt()
	local attTypeTb=tmpVo:getConfigData("attType")
	local attEffectTb=accessoryCfg.attEffect
	for k,v in pairs(attTypeTb) do
		local effectStr
		if(attEffectTb[tonumber(v)]==1)then
			effectStr=string.format("%.2f",attTb[k]).."%%"
		else
			effectStr=attTb[k]
		end
		self.attLbs[k]:setString(getlocal("accessory_attAdd_"..v,{effectStr}))
	end

	if(self.type==1)then
		self.gsLb:setString(getlocal("accessory_gsAdd",{self.data:getGS()}))
	end
end

-- 尖端配件分解条件
function accessorySmallDialog:topIsCanDispose(canSell,quality)
	if(canSell==1) and self.type==1 and quality>=4 then
		return true
	end
	return false
end

function accessorySmallDialog:dispose()
	eventDispatcher:removeEventListener("accessory.data.refresh",self.refreshListener)
end