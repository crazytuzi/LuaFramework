local FactionShopLayer = class("FactionShopLayer", function() return cc.Layer:create() end)

function FactionShopLayer:ctor(factionData)
	local msgids = {FACTION_SC_GETSHOPDATARET}
	require("src/MsgHandler").new(self,msgids)

	self.factionData = factionData
	self.shopLv = self.factionData.shopLv

	-- local MGoodsView = require("src/layers/shop/GoodsView")
	-- local layer = MGoodsView.new({storeId = 4 + factionData.shopLv})
	-- self:addChild(layer)
	-- layer:setPosition(cc.p(0, 5))
	-- self.shopLayer = layer

	createScale9Frame(
        self,
        "res/common/scalable/panel_outer_base_1.png",
        "res/common/scalable/panel_outer_frame_scale9_1.png",
        cc.p(0, 0),
        cc.size(710, 500),
        5
    )

	local infoBg = createSprite(self, "res/faction/9.jpg", cc.p(0, 1), cc.p(0, 0))--createScale9Sprite(self, "res/common/scalable/3.png", cc.p(568, 2), cc.size(140, 496), cc.p(0, 0))
	
	--if self.factionData.shopLv then
		--self.levelLabel = createLabel(infoBg, game.getStrByKey("num_"..self.factionData.shopLv)..game.getStrByKey("faction_tip_shop_level"), cc.p(infoBg:getContentSize().width/2, 450), cc.p(0.5, 0.5), 20, true, nil,nil,MColor.yellow)
	    --createLabel(infoBg, game.getStrByKey("faction_baibaoge"), cc.p(infoBg:getContentSize().width/2, 425), cc.p(0.5, 0.5), 20, true, nil,nil,MColor.yellow)
    --end
	createLabel(infoBg, game.getStrByKey("my_devote"), cc.p(75, 60), cc.p(0.5, 0.5), 20, true, nil, nil, MColor.lable_yellow)
	self.moneyLabel = createLabel(infoBg, factionData.myMoney, cc.p(75, 30), cc.p(0.5, 0.5), 22, true, nil, nil, MColor.yellow)
	-- local function levelUpBtnFunc()
	-- 	local layer = require("src/layers/faction/FactionUpdateLayer").new(self.factionData, 2)
	-- 	Manimation:transit(
	-- 	{
	-- 		ref = self,
	-- 		node = layer,
	-- 		curve = "-",
	-- 		sp = self:convertToNodeSpace(cc.p(display.cx, display.cy)),
	-- 		ep = self:convertToNodeSpace(cc.p(display.cx, display.cy)),
	-- 		swallow = true,
	-- 		zOrder = 100,
	-- 	})
	-- end
	-- local levelUpBtn = createMenuItem(infoBg, "res/component/button/48.png", cc.p(infoBg:getContentSize().width/2, 50), levelUpBtnFunc)
	-- levelUpBtn:setScale(0.9)
	-- createLabel(levelUpBtn, game.getStrByKey("faction_btn_level_up"), getCenterPos(levelUpBtn), cc.p(0.5, 0.5), 22, true)
	
	g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_GETSHOPDATA, "GetMyFactionData", {factionID=require("src/layers/role/RoleStruct"):getAttr(PLAYER_FACTIONID)})
    addNetLoading(FACTION_CS_GETSHOPDATA, FACTION_SC_GETSHOPDATARET)
end

function FactionShopLayer:updateFactionInfo()
	self:updatUI()
end

function FactionShopLayer:updateData()    
	self:updatUI()
end

function FactionShopLayer:updatUI()
	--self.levelLabel:setString(game.getStrByKey("num_"..self.factionData.shopLv)..game.getStrByKey("faction_tip_shop_level"))
	self.moneyLabel:setString(self.factionData.myMoney)

	if self.shopLayer then
		removeFromParent(self.shopLayer)
		self.shopLayer = nil
	end
	
	local tMap = {[1]=5, [2]=6, [3]=7, [4]=8, [5]=9, [6]=15, [7]=16, [8]=17, [9]=18}
	local storeId = tMap[self.factionData.shopLv]

	if self.shopLv and self.shopLv == self.factionData.shopLv then
		if self.shopLayer == nil then
			local MGoodsView = require("src/layers/shop/GoodsView")
			local layer = MGoodsView.new({storeId = storeId,vSizeH=492})
			self:addChild(layer)
			layer:setPosition(cc.p(140, 5))
			self.shopLayer = layer 
		end
	else
		local MGoodsView = require("src/layers/shop/GoodsView")
		local layer = MGoodsView.new({storeId = storeId})
		self:addChild(layer)
		layer:setPosition(cc.p(0, 5))
		self.shopLayer = layer 
	end

    if self.shopLayer then
        require("src/layers/shop/CommData").hanghuiGongXianValue = self.factionData.myMoney
    end 
end

function FactionShopLayer:networkHander(buff, msgid)
	local switch = {
		[FACTION_SC_GETSHOPDATARET] = function()    
			local t = g_msgHandlerInst:convertBufferToTable("GetMyFactionDataRet", buff)
            
            self.factionData.shopLv = t.storeLv
			self.factionData.myMoney = t.contribution
            
			self:updateData()
		end,
	}

 	if switch[msgid] then 
 		switch[msgid]()
 	end
end

return FactionShopLayer