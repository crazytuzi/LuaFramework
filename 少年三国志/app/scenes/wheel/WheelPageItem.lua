--WheelPageItem.lua
require("app.cfg.wheel_info")
local EffectNode = require "app.common.effects.EffectNode"

local WheelPageItem = class ("WheelPageItem", function (  )
	return CCSPageCellBase:create("ui_layout/wheel_MyWheel.json")
end)

function WheelPageItem:initPageItem( index , parentLayer )
	self._index = index
	if  not self._inited then
		self._inited = 1
		self._wheelImg = self:getImageViewByName("Image_wheel")
		self._wheelPanel = self:getPanelByName("Panel_wheel")
		self._wheelItemList = {}
		for i = 1, 8 do 
			self._wheelItemList[i] = self:getImageViewByName("Image_item"..i)
		end
		local info = wheel_info.get(index)
		if index == 1 then
			self:getImageViewByName("Image_wheel"):loadTexture("ui/wheel/lunpan_putong.png")
			self:getImageViewByName("Image_middi"):loadTexture("ui/wheel/middle_lan.png")
			self:getImageViewByName("Image_arrow"):loadTexture("ui/wheel/zhizhen_putong.png")
			self:getButtonByName("Button_mid"):loadTextureNormal("ui/wheel/middle_putong.png")
			self:getImageViewByName("Image_item5"):loadTexture("ui/wheel/icon_bg_haohua.png")
		else
			self:getImageViewByName("Image_wheel"):loadTexture("ui/wheel/lunpan_haohua.png")
			self:getImageViewByName("Image_middi"):loadTexture("ui/wheel/middle_hong.png")
			self:getImageViewByName("Image_arrow"):loadTexture("ui/wheel/zhizhen_haohua.png")
			self:getButtonByName("Button_mid"):loadTextureNormal("ui/wheel/middle_haohua.png")
			self:getImageViewByName("Image_item5"):loadTexture("ui/wheel/icon_bg_haohua.png")
		end

		for i = 1, 7 do 
			local g = G_Goods.convert(info["type_"..i], info["value_"..i])
			local index = info["position_"..i]
			self:getImageViewByName("Image_icon"..index):loadTexture(g.icon)
			self:getImageViewByName("Image_ball"..index):loadTexture(G_Path.getEquipIconBack(g.quality))
			self:getLabelByName("Label_num"..index):setText("x"..GlobalFunc.ConvertNumToCharacter3(info["size_"..i]))
			self:getLabelByName("Label_num"..index):createStroke(Colors.strokeBrown, 1)
			self:getLabelByName("Label_num"..index):setScale(1/0.8)
			self:getButtonByName("Button_border"..index):loadTextureNormal(G_Path.getEquipColorImage(g.quality))
			self:regisgerWidgetTouchEvent("Button_border"..index, function ( widget, param )
			    if param == TOUCH_EVENT_ENDED then -- 点击事件
			        require("app.scenes.common.dropinfo.DropInfo").show(info["type_"..i], info["value_"..i])  
			    end
			end)
		end

		self:getLabelByName("Label_pool"):createStroke(Colors.strokeBrown, 1)
		local g = G_Goods.convert(G_Goods.TYPE_GOLD, 0)
		self:getImageViewByName("Image_icon"..5):loadTexture(g.icon)
		self:getImageViewByName("Image_ball"..5):loadTexture(G_Path.getEquipIconBack(g.quality))
		self:getLabelByName("Label_num"..5):setText("x".."50%")
		self:getLabelByName("Label_num"..5):createStroke(Colors.strokeBrown, 1)
		self:getLabelByName("Label_num"..5):setScale(1/0.8)
		self:getButtonByName("Button_border"..5):loadTextureNormal(G_Path.getEquipColorImage(g.quality))
		self:regisgerWidgetTouchEvent("Button_border"..5, function ( widget, param )
		    if param == TOUCH_EVENT_ENDED then -- 点击事件
		        -- require("app.scenes.common.dropinfo.DropInfo").show(G_Goods.TYPE_GOLD, 0)  
		        local gold = require("app.scenes.wheel.WheelGold").create(index)
		        uf_sceneManager:getCurScene():addChild(gold)
		    end
		end)

		self._img1 = self:getImageViewByName("Image_price1")
		self._img2 = self:getImageViewByName("Image_price2")
		self._title1 = self:getLabelByName("Label_title1")
		self._title2 = self:getLabelByName("Label_title2")
		self._title1:createStroke(Colors.strokeBrown, 1)
		self._title2:createStroke(Colors.strokeBrown, 1)
		self._count1 = self:getLabelByName("Label_count1")
		self._count2 = self:getLabelByName("Label_count2")
		self._count1:createStroke(Colors.strokeBrown, 1)
		self._count2:createStroke(Colors.strokeBrown, 1)
		self._free1 = self:getLabelByName("Label_free1")
		self._free2 = self:getLabelByName("Label_free2")
		self._free1:createStroke(Colors.strokeBrown, 1)
		self._free2:createStroke(Colors.strokeBrown, 1)
		self._free1:setText(G_lang:get("LANG_WHEEL_FREE"))
		self._free2:setText(G_lang:get("LANG_WHEEL_FREE"))
		self._gold = self:getLabelByName("Label_gold")
		self._gold:createStroke(Colors.strokeBrown, 1)
		self:getLabelByName("Label_goldTit"):createStroke(Colors.strokeBrown, 1)
		-- self:updateView()
		local button1 = self:getButtonByName("Button_buyone")
		local button2 = self:getButtonByName("Button_buyten")
		button1:setName("Button_buyone"..self._index)
		button2:setName("Button_buyten"..self._index)
		self:getImageViewByName("Image_buyone"):setName("Image_buyone"..self._index)
		self:getImageViewByName("Image_buyten"):setName("Image_buyten"..self._index)
		self:getButtonByName("Button_mid"):setName("Button_mid"..self._index)

		parentLayer:registerBtnClickEvent("Button_buyone"..self._index, function()
			local cost = G_Me.wheelData:getPrice(1,self._index)
			if G_Me.userData.gold >= cost then
        				self:play(1)
        			else
        				-- require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_ITEM, 54,
        				--  GlobalFunc.sceneToPack("app.scenes.wheel.WheelScene"))
				-- require("app.scenes.common.PurchaseScoreDialog").show(24)
				require("app.scenes.shop.GoldNotEnoughDialog").show()
        			end
    		end)
		parentLayer:registerBtnClickEvent("Button_buyten"..self._index, function()
			local cost = G_Me.wheelData:getPrice(10,self._index)
			if G_Me.userData.gold >= cost then
        				self:play(10)
        			else
        				-- require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_ITEM, 54,
        				--  GlobalFunc.sceneToPack("app.scenes.wheel.WheelScene"))
				-- require("app.scenes.common.PurchaseScoreDialog").show(24)
				require("app.scenes.shop.GoldNotEnoughDialog").show()
        			end
    		end)
		parentLayer:registerBtnClickEvent("Button_mid"..self._index, function()
			local gold = require("app.scenes.wheel.WheelGold").create(index)
			uf_sceneManager:getCurScene():addChild(gold)
    		end)

		self:attachImageTextForBtn("Button_buyone"..self._index,"Image_buyone"..self._index)
		self:attachImageTextForBtn("Button_buyten"..self._index,"Image_buyten"..self._index)

		if self._yuanbaoEffect == nil then
			self._yuanbaoEffect = EffectNode.new("effect_lp_zhuan_a")     
			self._yuanbaoEffect:setPosition(ccp(0,-145))
			self._yuanbaoEffect:play()
			self:getImageViewByName("Image_wheel"):addNode(self._yuanbaoEffect,5)
		end
	end
end

function WheelPageItem:_onHeroPageIndexClicked( posIndex, knightId )
	
end

function WheelPageItem:play( times )
	if G_Me.wheelData:isNeedRequestNewData() then
	    G_HandlersManager.wheelHandler:sendWheelInfo()
	end
	G_HandlersManager.wheelHandler:sendPlayWheel(self._index,times)
	-- self:roll(1)
end

function WheelPageItem:resetPos( )
	
end

function WheelPageItem:roll( dst ,_type,callback )
	if self._aroundEffect then
		self._aroundEffect:removeFromParentAndCleanup(true)
		self._aroundEffect = nil
	end
	if self._chooseEffect then
		self._chooseEffect:removeFromParentAndCleanup(true)
		self._chooseEffect = nil
	end
	local info = wheel_info.get(self._index)
	local index = 5
	if dst ~= 8 then
		index = info["position_"..dst]
	end
	local time = 1.5
	local rand = math.random(-15,15)
	-- local original = self._wheelImg:getRotation()
	rand = 0
	__Log("roll to "..index-1)
	local rot = 1080+(9-index)*45+rand

	if _type == 10 then
		time = 3.0
		rot = rot + 1080
	end
	-- local rollAction = CCRotateTo:create(time,-rot)
	self._rollEffect = EffectNode.new("effect_lp_light")     
	self._rollEffect:setPosition(ccp(214,211))
	self._rollEffect:play()
	self:getPanelByName("Panel_stop"):addNode(self._rollEffect,10)
	local rollAction = CCEaseExponentialOut:create(CCRotateTo:create(time,rot))
	self._wheelImg:runAction(CCSequence:createWithTwoActions(rollAction,CCCallFunc:create(function()
		self._rollEffect:stop()
		self._rollEffect:removeFromParentAndCleanup(true)
		self._aroundEffect = EffectNode.new("effect_around1")     
		self._aroundEffect:setScale(1.7) 
		self._aroundEffect:setPosition(ccp(5,-5))
		self._aroundEffect:play()
		local widget = self:getButtonByName("Button_border"..index)
		widget:addNode(self._aroundEffect,10)
		widget:runAction(CCEaseIn:create(CCFadeOut:create(5),5))
		self._chooseEffect = EffectNode.new("effect_lp_zhuan_b")     
		local posx = 5
		local posy = 140
		-- print(index.."   "..math.sin(math.pi/4*(index-1))*length.."   "..math.cos(math.pi/4*(index-1))*length)
		self._chooseEffect:setPosition(ccp(math.sin(math.pi/4*(index-1))*posy+math.cos(math.pi/4*(index-1))*posx,math.cos(math.pi/4*(index-1))*posy-math.sin(math.pi/4*(index-1))*posx))
		-- self._chooseEffect:setPosition(ccp(0,length))
		self._chooseEffect:setRotation(45*(index-1))
		self._chooseEffect:play()
		self:getImageViewByName("Image_wheel"):addNode(self._chooseEffect,2)
		self._chooseEffect:runAction(CCEaseIn:create(CCFadeOut:create(5),5))
		if callback then
			callback()
		end
	end)))

	for i = 1 , 8 do 
		local rollAction2 = CCEaseExponentialOut:create(CCRotateTo:create(time,-rot))
		-- local rollAction2 = CCRotateTo:create(time,rot)
		self._wheelItemList[i]:runAction(rollAction2)
	end
	-- self:getImageViewByName("Image_arrow"):runAction(rollAction)
end


function WheelPageItem:updateView( )
	-- local curQuan = G_Me.wheelData:getCurQuanNum()
	-- local info = wheel_info.get(self._index)
	local cost1 = G_Me.wheelData:getPrice(1,self._index)
	local cost2 = G_Me.wheelData:getPrice(10,self._index)
	self._count1:setText(cost1)
	self._count2:setText(cost2)
	self._count1:setColor(G_Me.userData.gold >= cost1 and Colors.darkColors.DESCRIPTION or Colors.darkColors.TIPS_01)
	self._count2:setColor(G_Me.userData.gold >= cost2 and Colors.darkColors.DESCRIPTION or Colors.darkColors.TIPS_01)
	self._gold:setText(self._index == 1 and G_Me.wheelData.pool or G_Me.wheelData.pool2)

	self._count1:setVisible(cost1>0)
	self._count2:setVisible(cost2>0)
	self._img1:setVisible(cost1>0)
	self._img2:setVisible(cost2>0)
	self._title1:setVisible(cost1>0)
	self._title2:setVisible(cost2>0)
	self._free1:setVisible(cost1==0)
	if cost1 == 0 then
	    self._free1:setText(G_lang:get("LANG_WHEEL_FREE2",{num=G_Me.wheelData:getFreeLeft(self._index)}))
	end
	self._free2:setVisible(cost2==0)
end

return WheelPageItem