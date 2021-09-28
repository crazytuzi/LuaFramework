local RechargeLayer = class("RechargeLayer",UFCCSModelLayer)
require("app.cfg.recharge_info")
require("app.cfg.month_card_info")
require("app.cfg.vip_level_info")

local ComSdkUtils = require("upgrade.ComSdkUtils")

function RechargeLayer.show(...)

	if G_Setting:get("open_recharge") == "0" then
		G_MovingTip:showMovingTip("充值功能暂未开放")
	else
		local layer = RechargeLayer.create(...)
		uf_sceneManager:getCurScene():addChild(layer)  
		--解决某些界面本身是添加在modelnode上(如角色信息->设置头像框)，再弹出充值框界面层级显示错误的问题
		-- uf_notifyLayer:getModelNode():addChild(layer)   
	end
end
function RechargeLayer.create(...)
	local opId = require("upgrade.ComSdkUtils").getOpId()
	require("app.platform.comSdk.ComSdkProxyConfig").setSpecialRechargeList(opId)
	return RechargeLayer.new("ui_layout/shop_ShopRechargeLayer.json",Colors.modelColor,...)
end

function RechargeLayer:ctor(...)
	self._listView = nil
	self._listData = {}
	self.super.ctor(self,...)
	self:showAtCenter(true)

	-- self._vipLevelImg = self:getImageViewByName("Image_level")
	self._levelImg = self:getImageViewByName("Image_level")
	-- self._vipImg = self:getImageViewByName("Image_vip")

	self:_initListData()
	self:_initListView()
	self:_initEvents()
	self:_setWidgets()
	self:_createRichText()
	self:_updateMonthLabel()
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_USE_MONTHCARD_INFO, self._useMonthCard, self) 
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_GET_RECHARGE_INFO, self._getRechargeInfo, self) 
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECHARGE_SUCCESS, self._rechargeSuccess, self) 
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TIME_PRIVILEGE_MAIN_SCENE_SHOW_ICON, self._getRechargeInfo, self) 
	
	G_HandlersManager.shopHandler:sendRechargeInfo()
	-- self:playAnimation("AnimationScale",function() 
	-- end)
end

function RechargeLayer:_initListData()
	-- local appId = G_PlatformProxy:getOpId() -- ComSdkUtils.getAppId()
	local appId =  G_PlatformProxy:getAppId()
	appId = appId and appId or "1"
	local initDataWithAppId = function(appId)
		local list = {}
		-- local length = month_card_info.getLength()
		-- for i=1,length do
		-- 	local item = month_card_info.indexOf(i)
		-- 	--month card ignore the value of appid
		-- 	--if item.app_id == appId then
		-- 		table.insert(list,{data=item,type=1})
		-- 	--end
		-- end
		


		local length = recharge_info.getLength()
		--any record has appid?
		local finded= false
		for i=1,length do
			local item = recharge_info.indexOf(i)
			if tostring(item.app_id) == tostring(appId) then
				finded = true
				break
			end
		end

		if not finded then
			appId = "1"
		end
		for i=1,length do
			local item = recharge_info.indexOf(i)
			if tostring(item.app_id) == tostring(appId) then
				table.insert(list,{data=item,type=2})
			end
		end

		table.sort( list, function ( a , b )
			if G_Me.timePrivilegeData ~= nil and G_Me.timePrivilegeData.getRealRechargeId ~= nil then
				local rechageId = 0
				rechageId, _ = G_Me.timePrivilegeData:getRealRechargeId()
				if a.data.id == rechageId then
					return true
				end
				if b.data.id == rechageId then
					return false
				end
				return a.data.id < b.data.id
			end
			return a.data.id < b.data.id
		end )
		return list
	end

	self._listData = initDataWithAppId(appId)
	-- if appId ~= "1" and (self._listData == nil or #self._listData == 0) then
	-- 	--如果没有，默认取1
	-- 	self._listData = initDataWithAppId("1")
	-- end

end


function RechargeLayer:_initListView()
	local panel = self:getPanelByName("Panel_list")
	self._listView = CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_HORIZONTAL)
	self._listView:setCreateCellHandler(function(list,index)
		local item = require("app.scenes.shop.recharge.RechargeItem").new()
		return item
	end)
	
	self._listView:setUpdateCellHandler(function(list,index,cell)
		local data = self._listData[index+1]
		cell:update(data)
		cell:setRechargeFunc(function()
			local data = self._listData[index+1]
			local _id = data.data.id
			--充值
			local payExtra	= nil
			payExtra = json.encode({extratype=0,extraappid=toint(data.data.app_id)})
			self:_callRecharge(data.data.size,data.data.product_id,data.data.name, payExtra)
			-- if data.type == 1 then
			-- 	--购买月卡
			-- 	if G_Me.shopData:monthCardPurchasability(_id) then	
			-- 		--购买月卡
			-- 		local appId =  G_PlatformProxy:getAppId()
			-- 		local payExtra = json.encode({extratype=1,extraid=_id,extraappid=toint(appId)})
			-- 		self:_callRecharge(data.data.size,data.data.product_id,data.data.name,payExtra)
			-- 	elseif G_Me.shopData:useEnabled(_id) then
			-- 		--可领取
			-- 		G_HandlersManager.shopHandler:sendUseMonthCard(_id)
			-- 	else
			-- 		--已领取
			-- 	end
			-- else
			-- 	--充值
			-- 	local payExtra	= nil
			-- 	payExtra = json.encode({extratype=0,extraappid=toint(data.data.app_id)})
			-- 	self:_callRecharge(data.data.size,data.data.product_id,data.data.name, payExtra)
			-- end
			end)
	end)

	-- self._listView:setClickCellHandler(function ( list, index, cell )
	-- 	local data = self._listData[index+1]
	-- 	local _id = data.data.id
	-- 	if data.type == 1 then
	-- 		--购买月卡
	-- 		if G_Me.shopData:monthCardPurchasability(_id) then	
	-- 			--购买月卡
	-- 			local payExtra = json.encode({extratype=1,extraid=_id})
	-- 			self:_callRecharge(data.data.size,data.data.product_id,data.data.name,payExtra)
	-- 		elseif G_Me.shopData:useEnabled(_id) then
	-- 			--可领取
	-- 			G_HandlersManager.shopHandler:sendUseMonthCard(_id)
	-- 		else
	-- 			--已领取
	-- 		end
	-- 	else
	-- 		--充值
	-- 		self:_callRecharge(data.data.size,data.data.product_id,data.data.name)
	-- 	end

 -- 	    end)
	if self._listData ~= nil and #self._listData ~= 0 then
		self._listView:reloadWithLength(#self._listData,0)
	end
end




function RechargeLayer:_callRecharge(price,productId,productName,payExtra)
	local _t  = {}


	price = price and price or 0
	local is_1yuan = G_Setting:get("open_1yuan")
	if is_1yuan == "1" then
		price = 1
	end


	productId = productId and productId or ""
	productName = productName and productName or "元宝"
	local pointRate = pointRate and pointRate or 10
	local pointName = pointName and pointName or "元宝"
	local orderTitle = ""
	payExtra = payExtra and payExtra or ""
	local productDesc = productName

	table.insert(_t,{price=price})
	table.insert(_t,{productId=productId})
	table.insert(_t,{productName=productName})
	table.insert(_t,{productDesc=productDesc})
	table.insert(_t,{pointRate=pointRate})
	table.insert(_t,{pointName=pointName})
	table.insert(_t,{orderTitle=orderTitle})
	table.insert(_t,{payExtra=payExtra})

	ComSdkUtils.call("pay",_t)
end


function RechargeLayer:_initEvents()
	self:enableAudioEffectByName("Button_close", false)
	self:registerBtnClickEvent("Button_close",function()
		if G_Me.shopData:getVipEnter() == true then
		    local layer = require("app.scenes.vip.VipMainLayer").create()
		    --uf_sceneManager:getCurScene():addChild(layer) 
		    uf_notifyLayer:getModelNode():addChild(layer)
		end
		self:animationToClose()
		local soundConst = require("app.const.SoundConst")
	   	G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
		end)

	self:registerBtnClickEvent("Button_tequan",function()
		local layer = require("app.scenes.vip.VipMainLayer").create()
		--uf_sceneManager:getCurScene():addChild(layer) 
		uf_notifyLayer:getModelNode():addChild(layer)
		self:animationToClose()     
		end)
	self:registerBtnClickEvent("Button_yue25",function()
		self:_buyMonthCard(2)
		end)
	self:registerBtnClickEvent("Button_yue50",function()
		self:_buyMonthCard(1)
		end)
end

function RechargeLayer:_buyMonthCard(index)
	--购买月卡
	local data = month_card_info.indexOf(index)
	local _id = data.id
	if G_Me.shopData:monthCardPurchasability(_id) then	
		--购买月卡
		local appId =  G_PlatformProxy:getAppId()
		local payExtra = json.encode({extratype=1,extraid=_id,extraappid=toint(appId)})
		self:_callRecharge(data.size,data.product_id,data.name,payExtra)
	elseif G_Me.shopData:useEnabled(_id) then
		--可领取
		G_HandlersManager.shopHandler:sendUseMonthCard(_id)
	else
		--已领取
	end
end

function RechargeLayer:_setWidgets()
	-- self:getImageViewByName("Image_vip"):loadTexture(G_Path.getVipLevelImage(G_Me.userData.vip))
	self:updateLevel(G_Me.userData.vip)
	
	self:showWidgetByName("Label_vip_tip", G_Me.userData.vip >= 9)
	if G_Me.userData.vip >= 9 then 
		self:showTextWithLabel("Label_vip_tip", G_lang:get("LANG_VIP_TIP"))
		self:showTextWithLabel("Label_MaxVIP", G_lang:get("LANG_VIP_MAX"))
	end

	self:enableLabelStroke("Label_MaxVIP", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_vip_tip", Colors.strokeBrown, 1 )

	self:enableLabelStroke("Label_desc25_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_desc25_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_desc25_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_desc25_4", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_desc25_5", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_desc50_1", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_desc50_2", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_desc50_3", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_desc50_4", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_desc50_5", Colors.strokeBrown, 1 )
end

function RechargeLayer:_createRichText()
	local currentVipExpLabel = self:getLabelByName("Label_currentVipExp")
	currentVipExpLabel:createStroke(Colors.strokeBrown,1)
	local exp = G_Me.vipData:getExp()
	local progressBar = self:getLoadingBarByName("ProgressBar_vip")
	local label = self:getLabelByName("Label_tips")
	--VIP最高等级12
	if G_Me.userData.vip == 12 then
		self:showWidgetByName("Label_MaxVIP",true)
		self:showWidgetByName("Panel_richText",false)
		progressBar:setPercent(100)
		local expMax = vip_level_info.get(G_Me.userData.vip).low_value
		currentVipExpLabel:setText(exp .. "/" .. expMax)
		return
	end
	self:showWidgetByName("Label_MaxVIP",false)
	self:showWidgetByName("Panel_richText",true)
	local expMax = vip_level_info.get(G_Me.userData.vip+1).low_value
	currentVipExpLabel:setText(exp .. "/" .. expMax)
	progressBar:setPercent(exp/expMax * 100)

	--[[
		"<root><text value='再充值' color='16709336'/><text value='#money#' color='14791292'/><image path='icon_mini_yuanbao.png' type='1'/><text value='即可成为' color='16709336'/><text value='VIP#vip#' color='16771584'/></root>",
	]]
	if self._richText == nil then
		local label = self:getLabelByName("Label_vip_tip")
		local panel = self:getPanelByName("Panel_richText")
		local size = panel:getContentSize()
		self._richText = CCSRichText:create(size.width+150, size.height+30)
		self._richText:setFontSize(label:getFontSize())
		self._richText:setFontName(label:getFontName())
		self._richText:enableStroke(Colors.strokeBrown)
		panel:addChild(self._richText)
		self._richText:setPosition(ccp(175,50))
	end
	self._richText:clearRichElement()
	local text = G_lang:get("LANG_VIP_LEVEL_UP_TIPS",{money=(expMax-exp),vip=(G_Me.userData.vip + 1)})
	
	self._richText:appendXmlContent(text)
	self._richText:reloadData()
end

function RechargeLayer:_refreshRichText()
	
	
	
end

function RechargeLayer:_updateMonthLabel()
	for i = 1 , 2  do 
		local item = month_card_info.indexOf(3-i)
		local label1 = self:getLabelByName("Label_desc"..(i*25).."_1")
		local label2 = self:getLabelByName("Label_desc"..(i*25).."_2")
		local label3 = self:getLabelByName("Label_desc"..(i*25).."_5")
		local img = self:getImageViewByName("Image_get"..(i*25))
		if G_Me.shopData:monthCardPurchasability(item.id) then
			-- label1:setText(G_lang:get("LANG_RECHARGE_GIFT_MONTH_1")) 
			-- label2:setText(G_lang:get("LANG_RECHARGE_GIFT_MONTH_DAYS",{days=30}))
			label1:setVisible(false)
			label2:setVisible(false)
			label3:setVisible(true)
			img:setVisible(false)
		elseif G_Me.shopData:getMonthCardLeftDay(item.id) > 0 then
			label1:setVisible(true)
			label2:setVisible(true)
			label3:setVisible(false)
			img:setVisible(true)
			label1:setText(G_lang:get("LANG_RECHARGE_GIFT_MONTH_2"))
			label2:setText(G_lang:get("LANG_RECHARGE_GIFT_MONTH_DAYS",{days=G_Me.shopData:getMonthCardLeftDay(item.id)})) 
			local imgUrl = G_Me.shopData:useEnabled(item.id) and "ui/text/txt/cz_kelingqu.png" or "ui/text/txt/cz_yilingqu.png"
			img:loadTexture(imgUrl)
		end
	end
end

function RechargeLayer:_useMonthCard(data)
	if data.ret == 1 then
		self:_updateMonthLabel()
		self._listView:refreshAllCell()
	end
end

function RechargeLayer:_getRechargeInfo(data)
	self:_createRichText()
	-- self:getImageViewByName("Image_vip"):loadTexture(G_Path.getVipLevelImage(G_Me.userData.vip))
	self:updateLevel(G_Me.userData.vip)
	self._listView:refreshAllCell()
end

function RechargeLayer:_rechargeSuccess(data)
	
end

function RechargeLayer:updateLevel(vip)
	self._levelImg:loadTexture("ui/shop/vip_"..vip..".png")
	-- self._levelImg:loadTexture(G_Path.getVipLevelImage(vip))
	-- local totalWidth = self._vipLevelImg:getContentSize().width
	-- local levelWidth = self._levelImg:getContentSize().width
	-- local vipWidth = self._vipImg:getContentSize().width
	-- local center = (vipWidth-levelWidth)/2
	-- self._levelImg:setPositionXY(center+levelWidth/2,0)
	-- self._vipImg:setPositionXY(center-vipWidth/2,0)
end

function RechargeLayer:onLayerUnload()
	uf_eventManager:removeListenerWithTarget(self)
end

function RechargeLayer:onLayerEnter()
	self:closeAtReturn(true)
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end

return RechargeLayer