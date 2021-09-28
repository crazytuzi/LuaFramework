local decompose = class("decompose",function() return cc.Layer:create() end)

function decompose:ctor(  )
	-- print("decompose")

	local msgids = {ITEM_SC_EMBLAZONRY_RET}
	require("src/MsgHandler").new(self,msgids)

	local gNum = 12
	self.decomposeNum = 0
	self.gNum = gNum
	self:showArrow()
	self:judgeScroll(gNum)
	-- self:createScroll(cc.size(285,360),cc.size(285,90*math.ceil(gNum/3)),cc.p(219,130))
	self.now_item = {}
	self.showProp = {}
	-- local posx,posy = 45,90*math.ceil(gNum/3)
	-- for i = 1, gNum do			
	-- 	local spr = createSprite(self.base_node,"res/common/bg/itemBg.png",cc.p(posx,posy-45))
	-- 	spr:setTag(i)
	-- 	posx = posx + 95
	-- 	if i%3 == 0 then
	-- 		posx = 45
	-- 		posy = posy - 90
	-- 	end
	-- end
	-- self.scrollView:setContentOffset(cc.p(0,360-90*math.ceil(gNum/3)))
	self.medalBtn = createTouchItem(self,"res/common/bg/itemBg.png",cc.p(687,315),function() self:input() end)
	local jia = createSprite(self.medalBtn,"res/layers/equipment/jia.png",cc.p(40,40))
	jia:setTag(10)
	self.decomposeLab = createLabel(self,string.format(game.getStrByKey("getTexture"),0),cc.p(687,150),nil,20,true,nil,nil,MColor.yellow)
	self.decomposeLab:setVisible(false)
	self.actBtn = createMenuItem(self,"res/component/button/1.png",cc.p(687,90),function() self:dp() end)
	createLabel(self.actBtn,game.getStrByKey("discompose"),cc.p(69,29),nil,20,true,nil,nil,MColor.lable_yellow)
	self.actBtn:setVisible(false)
	createLabel(self,game.getStrByKey("decompose_prop"),cc.p(356,87),nil,20,true,nil,nil,MColor.lable_black)
end

function decompose:judgeScroll(girdNum)
	if self.scrollView then
		removeFromParent(self.scrollView)
		self.scrollView = nil
	end
	self.gNum = girdNum
	self:createScroll(cc.size(285,360),cc.size(285,90*math.ceil(self.gNum/3)),cc.p(219,130))
	local posx,posy = 45,90*math.ceil(self.gNum/3)
	for i = 1, self.gNum do			
		local spr = createSprite(self.base_node,"res/common/bg/itemBg.png",cc.p(posx,posy-45))
		spr:setTag(i)
		posx = posx + 95
		if i%3 == 0 then
			posx = 45
			posy = posy - 90
		end
	end
	self.scrollView:setContentOffset(cc.p(0,360-90*math.ceil(self.gNum/3)))
end

function decompose:showArrow()
	local downFlag = Effects:create(false)
	downFlag:playActionData2("ActivePage",200,-1,0)
	downFlag:setPosition(cc.p(358,120))
	addEffectWithMode( downFlag , 1 )
	downFlag:setRotation(0)
	self.downFlag = downFlag

	local upFlag = Effects:create(false)
    upFlag:playActionData2("ActivePage", 200 , -1 , 0 )
    upFlag:setPosition(cc.p(358,500))
    addEffectWithMode( upFlag , 1 )
    upFlag:setRotation(180)
    self.upFlag = upFlag

    self:addChild(downFlag,10)
    self:addChild(upFlag,10)
    local delayFun = function()
    	if self.gNum > 12 then
    		upFlag:setVisible(false)
    	else
    		upFlag:setVisible(false)
    		downFlag:setVisible(false)
    	end
    end
    performWithDelay( upFlag , delayFun , 0.0 )
end

function decompose:createScroll(size,nodeSize,pos,isneedSlide)
	local scrollView = cc.ScrollView:create()

	local setFlagShow = function( value )  
		if self.downFlag and self.upFlag then
	    	if self.gNum > 12 then
	            self.upFlag:setVisible( value~=3 )
	            self.downFlag:setVisible( value~=1 )
	        else
	        	self.upFlag:setVisible( false )
	            self.downFlag:setVisible( false )
	        end
	    end
    end

	local function scrollViewDidScroll()
		if scrollView:getContentOffset().y >= scrollView:maxContainerOffset().y then
			setFlagShow(1)
		elseif scrollView:getContentOffset().y <= scrollView:minContainerOffset().y then
			setFlagShow(3)
		else
			setFlagShow(2)
		end
	end
	if scrollView then
		scrollView:setViewSize(size)
		scrollView:setPosition(pos)
		scrollView:setScale(1)
		scrollView:ignoreAnchorPointForPosition(true)
		local node = cc.Node:create()
		self.base_node = node
		node:setContentSize(nodeSize)
		scrollView:setContainer(node)
		scrollView:updateInset()
		if isneedSlide then
			scrollView:addSlider("res/common/slider.png")
		end
		scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
		scrollView:setClippingToBounds(true)
		scrollView:setBounceable(true)
		scrollView:setDelegate()
		scrollView:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
		self:addChild(scrollView)
		self.scrollView = scrollView
	end
end

function decompose:input()
	print(index,"放什么？")
	-- AudioEnginer.playTouchPointEffect()
			
	local Mreloading = require "src/layers/honour/medal_select"
	local Manimation = require "src/young/animation"
	Manimation:transit(
	{
		node = Mreloading.new(
		{
			now = self.now_item,		
			filtrate = function(packId,grid,now)
				-- local MequipOp = require "src/config/equipOp"
				local MpropOp = require "src/config/propOp"
				-- local Mconvertor = require "src/config/convertor"
				local protoId = MPackStruct.protoIdFromGird(grid)
				local isShiWen = MpropOp.shiwen(protoId)     --protoId >= 1601 and protoId <= 1609
				local shiWenPass = isShiWen and isShiWen < 4
				local gridId = MPackStruct.girdIdFromGird(grid)
				local now_gridId = MPackStruct.girdIdFromGird(now.grid)
				if packId == now.packId and gridId == now_gridId then 
					return false 
				else
					return shiWenPass
				end
			end,
			handler = function(item)				
				self.now_item = item
				-- dump(self.now_item,"33333333333333333333333333333333")
				-- self.tip:setVisible(false)
				self:reloadView(item)
			end,
			
			act_src = game.getStrByKey("equip_select_btn_title"),
			title_src = game.getStrByKey("medal_select_title"),
			way = 1,
		}),
		sp = g_scrCenter,
		ep = g_scrCenter,
		--trend = "-",
		zOrder = 200,
		curve = "-",
		swallow = true,
	})
end

function decompose:reloadView(item)
	if self.medalBtn then
		self.wenTab = {}
		if self.srcIcon then
			removeFromParent(self.srcIcon)
			self.srcIcon = nil
		end
		local Mprop = require "src/layers/bag/prop"
		-- local MpropOp = require "src/config/propOp"
		local packId = item.packId
		local grid = item.grid
		local gridId = MPackStruct.girdIdFromGird(grid)
		local protoId = MPackStruct.protoIdFromGird(grid)
		local btnSize = self.medalBtn:getContentSize()
		self.srcIcon = Mprop.new(
		{
			grid = grid,
			strengthLv = strengthLv,
		})
		-- MpropOp.createColorName(grid, self.medalBtn[index], cc.p(btnSize.width/2, btnSize.height/2), cc.p(0.5,0.5), 22)
		Mnode.addChild(
		{
			parent = self.medalBtn,
			child = self.srcIcon,
			pos = cc.p(btnSize.width/2,  btnSize.height/2),
		})
		if self.medalBtn:getChildByTag(10) then
			self.medalBtn:getChildByTag(10):setVisible(false)
		end		
		local MpropOp = require "src/config/propOp"
		local shiwenType = MpropOp.shiwen(protoId)
		local isActive = MPackStruct.active(grid)
		local gridId = MPackStruct.girdIdFromGird(grid)		
		table.insert(self.wenTab,{{protoId,isActive},shiwenType,gridId})
		-- print(self.wenTab,"44444444444444444444")
		self:reloadProp()
		self.actBtn:setVisible(true)
	end
end

function decompose:dp()
	if self.wenTab and self.wenTab[1] then
		local t = {}
		t.id = self.wenTab[1][1][1] 
		t.emblazonryType = self.wenTab[1][2]
		t.opType = 3
		t.posIndex = self.wenTab[1][3]
		g_msgHandlerInst:sendNetDataByTable(ITEM_CS_EMBLAZONRY, "EmblazonryProtocol", t)
	end
	-- if self.base_node then
	-- 		local num = 98
	-- 	if num > 0 then
	-- 		local Mprop = require( "src/layers/bag/prop" )
	-- 		local MpropOp = require "src/config/propOp"
	-- 		local maxNum = MpropOp.maxOverlay() or 1
	-- 		local gezi = num > maxNum and math.ceil(num/maxNum) or 1
	-- 		print(maxNum,gezi,"444444444444444444")
	-- 		if gezi > 12 then
	-- 			self:judgeScroll(gezi)
	-- 		end
			 
	-- 		for i=1 , gezi do
	-- 			local spr = tolua.cast(self.base_node:getChildByTag(i),"cc.Sprite")
	-- 			local sprSize = spr:getContentSize()
	-- 			if spr then
	-- 				self.showProp[i] = Mprop.new(
	-- 				{
	-- 					protoId = 1003,
	-- 					num = num > maxNum and ((i < gezi and maxNum) or (num%maxNum == 0) and maxNum or num%maxNum) or num , 
	-- 					cb = "tips", 
	-- 					swallow = false,
	-- 					--tag = G_DRUG_TAB[num][j][1],
	-- 				})
	-- 				self.showProp[i]:setPosition(cc.p(sprSize.width/2,sprSize.height/2))
	-- 				spr:addChild(self.showProp[i])
	-- 			end
	-- 		end
	-- 		if self.srcIcon then
	-- 			removeFromParent(self.srcIcon)
	-- 			self.srcIcon = nil
	-- 		end
	-- 		if self.medalBtn and self.medalBtn:getChildByTag(10) then
	-- 			self.medalBtn:getChildByTag(10):setVisible(true)
	-- 		end
	-- 		self.now_item = {}
	-- 	end
	-- end
end

function decompose:reloadProp()--q_decomposeNum	
	local honourData = require("src/layers/honour/honourData")
	local goodTab = {}
	-- dump(self.wenTab,"55555555555555555555555")
	goodTab = honourData:init(self.wenTab,3)	
	if goodTab and goodTab[1].q_decomposeNum then
		self.decomposeNum = goodTab[1].q_decomposeNum
		self.decomposeLab:setVisible(true)
		self.decomposeLab:setString(string.format(game.getStrByKey("getTexture"),goodTab[1].q_decomposeNum))
	end
end

function decompose:networkHander(buff,msgid)
	local switch = {
		[ITEM_SC_EMBLAZONRY_RET] = function()    
			local t = g_msgHandlerInst:convertBufferToTable("EmblazonryRetProtocol", buff)
			-- dump({t.optype,t.emblazonryType},"((((((((((((((")
			if t.optype == 3 then
				if self.base_node then
					local num = self.decomposeNum
					if num > 0 then
						local Mprop = require( "src/layers/bag/prop" )
						local MpropOp = require "src/config/propOp"
						local maxNum = MpropOp.maxOverlay() or 1
						local gezi = num > maxNum and math.ceil(num/maxNum) or 1
						-- print(maxNum,gezi,"444444444444444444")
						if gezi > 12 then
							self:judgeScroll(gezi)
						end
						 
						for i=1 , gezi do
							local spr = tolua.cast(self.base_node:getChildByTag(i),"cc.Sprite")
							local sprSize = spr:getContentSize()
							if spr then
								self.showProp[i] = Mprop.new(
								{
									protoId = 1003,
									num = num > maxNum and ((i < gezi and maxNum) or (num%maxNum == 0) and maxNum or num%maxNum) or num , 
									cb = "tips", 
									swallow = false,
									--tag = G_DRUG_TAB[num][j][1],
								})
								self.showProp[i]:setPosition(cc.p(sprSize.width/2,sprSize.height/2))
								spr:addChild(self.showProp[i])
							end
						end
						if self.srcIcon then
							removeFromParent(self.srcIcon)
							self.srcIcon = nil
						end
						if self.medalBtn and self.medalBtn:getChildByTag(10) then
							self.medalBtn:getChildByTag(10):setVisible(true)
						end
						self.now_item = {}
					end
				end
			end

		end
		,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end


return decompose