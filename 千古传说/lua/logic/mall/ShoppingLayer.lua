-- ShoppingLayer
-- Author: david.dai
-- Date: 2014-06-16 11:14:56
--

local ShoppingLayer = class("ShoppingLayer", BaseLayer)

CREATE_PANEL_FUN(ShoppingLayer)


function ShoppingLayer:ctor(id)
    self.super.ctor(self,id)
    self.id = id
    self:init("lua.uiconfig_mango_new.shop.ShoppingLayer")
end

function ShoppingLayer:initUI(ui)
	self.super.initUI(self,ui)

	--操作按钮
	self.btn_close				= TFDirector:getChildByPath(ui, 'btn_close')
	self.btn_add				= TFDirector:getChildByPath(ui, 'btn_add')
	self.btn_reduce				= TFDirector:getChildByPath(ui, 'btn_reduce')
	self.txt_num 				= TFDirector:getChildByPath(ui, 'txt_numnow')
	self.btn_buy 				= TFDirector:getChildByPath(ui, 'btn_buy')

	--动态信息控件
	self.txt_name				= TFDirector:getChildByPath(ui, 'txt_name')
	self.img_quality			= TFDirector:getChildByPath(ui, 'img_quality_bg')
	self.img_icon				= TFDirector:getChildByPath(ui, 'img_icon')
	
	self.txt_desc				= TFDirector:getChildByPath(ui, 'txt_desc')
	self.panel_gift				= TFDirector:getChildByPath(ui, 'panel_giftDesc')

	self.old_price_bg 			= TFDirector:getChildByPath(ui, 'img_price_bg')
	self.hengxian 				= TFDirector:getChildByPath(self.old_price_bg, 'hengxian')
	self.old_img_res_icon 			= TFDirector:getChildByPath(self.old_price_bg, 'img_res_icon')
	self.old_txt_price				= TFDirector:getChildByPath(self.old_price_bg, 'txt_price')

	self.now_price_bg 			= TFDirector:getChildByPath(ui, 'img_newprice_bg')
	self.now_img_res_icon 			= TFDirector:getChildByPath(self.now_price_bg, 'img_res_icon')
	self.now_txt_price				= TFDirector:getChildByPath(self.now_price_bg, 'txt_price')


	self.txt_numnow				= TFDirector:getChildByPath(self.ui, 'txt_num')
	self.slider_shop				= TFDirector:getChildByPath(self.ui, 'slider_shop')
	self.bg_jindushuzhi				= TFDirector:getChildByPath(self.ui, 'bg_jindushuzhi')
	self.txt_own_num				= TFDirector:getChildByPath(self.ui, 'txt_own_num')



	self.txt_buy_limit_tips 	= TFDirector:getChildByPath(ui, 'txt_buy_limit_tips')
	self.txt_buy_limit_tips:setVisible(false)

	--剩余购买个数信息
	self.lbl_remaining_title 	= TFDirector:getChildByPath(ui, 'lbl_remaining_title')
	self.txt_remaining_num 		= TFDirector:getChildByPath(ui, 'txt_remaining_num')
	

	self.img_zhekou 		= TFDirector:getChildByPath(ui, 'img_zhekou')
	self.bg_time 			= TFDirector:getChildByPath(ui, 'bg_time')
	self.txt_time 			= TFDirector:getChildByPath(ui, 'LabelBMFont_ShopItemCell_1')

	self.img_zhekou:setVisible(false)
	self.bg_time:setVisible(false)

	--为按钮绑定处理逻辑属性，指向self
	self.btn_close.logic = self
	self.btn_add.logic = self
	self.btn_reduce.logic = self
	self.slider_shop.logic = self
	self.btn_buy.logic = self
	self.txt_num:setText(1)
	self.max_num = 99
	self.bg_jindushuzhi:setVisible(false)

end

function ShoppingLayer:removeUI()
	--操作按钮
	self.btn_close				= nil
	self.old_img_res_icon 		= nil
	self.now_img_res_icon 		= nil
	self.btn_add				= nil
	self.btn_reduce				= nil
	self.txt_num 				= nil
	self.old_txt_price 			= nil
	self.now_txt_price 			= nil
	self.btn_buy 				= nil

	--动态信息控件
	self.txt_name				= nil
	self.img_quality			= nil
	self.img_icon				= nil
	
	self.txt_desc				= nil

	self.txt_buy_limit_tips 	= nil

	--剩余购买个数信息
	self.lbl_remaining_title 	= nil
	self.txt_remaining_num 		= nil

	self.img_zhekou		= nil
	self.bg_time		= nil
	self.txt_time		= nil

	--调用父类方法
	self.super.removeUI(self)
end


function ShoppingLayer:onShow()
	self.super.onShow(self)
    self:refreshBaseUI()
    self:refreshUI()
end

function ShoppingLayer:refreshBaseUI()
end

function ShoppingLayer:setOldPrice( id , num )
	local shop = ShopData:objectByID(id)
	if shop == nil  then
		print("商城无此数据 id == " , id)
		return
	end
	if not shop.old_price or shop.old_price <= 0 then
		return
	end
	self.old_txt_price:setText(MallManager:getTotalOldPrice(id,num ))
	self.img_zhekou:setVisible(true)
end

function ShoppingLayer:refreshUI()
    local shop = ShopData:objectByID(self.id)
	if shop == nil  then
		print("商城无此数据 id == " , self.id)
		return
	end
	if shop.old_price and shop.old_price > 0 then
		self.now_price_bg:setVisible(true)
		self.hengxian:setVisible(true)
	else
		self.hengxian:setVisible(false)
		self.now_price_bg:setVisible(false)
	end

	local item = ItemData:objectByID(shop.res_id)
	if item == nil  then
		print("道具表无此数据 id == " , shop.res_id)
		return
	end

	self.txt_name:setText(item.name)
	self.txt_desc:setText(item.details)
	self.img_quality:setTexture(GetBackgroundForGoods(item))
	self.img_icon:setTexture(item:GetPath())
	self.old_img_res_icon:setTexture(GetResourceIcon(shop.consume_type))
	self.now_img_res_icon:setTexture(GetResourceIcon(shop.consume_type))

	Public:addPieceImg(self.img_icon,{type = EnumDropType.GOODS,itemid = shop.res_id});

	local  item_num = BagManager:getItemNumById( item.id )
	self.txt_own_num:setVisible(true)		
	if item.type == 7 then
		local roleData = RoleData:objectByID(item.usable)
		if roleData then
			self.txt_own_num:setText(item_num.."/"..roleData.merge_card_num)
		end
	elseif item.type == 8 then
		if item.kind < 6 then
			local equipmentTemplate = EquipmentTemplateData:findByPieceId(item.id)
			if equipmentTemplate ~= nil then
				local needNumber = equipmentTemplate.merge_num
				self.txt_own_num:setText(item_num.."/"..needNumber)
			end
		elseif item.kind == 10 then
			local martialTemplate,num = MartialData:findByMaterial(item.id)
			if martialTemplate ~= nil then
				local needNumber = num
				self.txt_own_num:setText(item_num.."/"..needNumber)
			end
		end
	elseif item.type == 1 then
		self.txt_own_num:setVisible(false)		
	else
		self.txt_own_num:setText(item_num)
	end


	if shop:isLimited() then
		self.txt_remaining_num:setVisible(true)
		self.lbl_remaining_title:setVisible(true)
		local max_num = shop:getMaxNum(MainPlayer:getVipLevel())
		local now_count = max_num - MallManager:getPurchasedCount(shop.id)
		self.max_num = math.min(now_count,99)
		if now_count <= 0 then
			now_count = 0
			self.txt_remaining_num:setColor(ccc3(255, 0, 0))
			self.lbl_remaining_title:setColor(ccc3(255, 0, 0))
		else
			self.txt_remaining_num:setColor(ccc3(0, 0, 0))
			self.lbl_remaining_title:setColor(ccc3(0, 0, 0))
		end
		self.txt_remaining_num:setText(now_count)
		self.now_txt_price:setText(MallManager:getNowPrice( self.id ))
		self.old_txt_price:setText(MallManager:getNowPrice( self.id ))
	else
		self.txt_remaining_num:setVisible(false)
		self.lbl_remaining_title:setVisible(false)
		self.now_txt_price:setText(shop.consume_number)
		self.old_txt_price:setText(shop.consume_number)
	end

	self:setOldPrice( self.id , 1 )

	local percent = math.ceil(1/self.max_num*100)
	local currentNumText = self.txt_num:getText()
	if currentNumText and currentNumText:len() > 0 then
		local currentNum = tonumber(currentNumText)
		if currentNum < 1 then
			self:setShopNum(1)
		else
			self:setShopNum(currentNum)
			percent = math.ceil(currentNum/self.max_num*100)
		end
	else
		self:setShopNum(1)
	end

	self.slider_shop:setPercent(percent)

	-- print("shop = ", shop)
	-- print("item = ", item)
	self.txt_desc:setVisible(true)
	-- 判断是非为礼包
	if item.type == EnumGameItemType.Box then
		-- 判断是非为礼包
		self.txt_desc:setVisible(false)
		local giftPackData = GiftPackData:objectByID(item.id)
		if giftPackData == nil  then
			print("无此数据 id == " , item.id)
			return
		end
		
		self.giftGoodsList = split(giftPackData.goods, "|")
		print("礼包里面的物品数量 = ", #self.giftGoodsList)
		print("礼包 = ", self.giftGoodsList)
		self:drawGiftItemList()
	end
end


function ShoppingLayer:setShopid( id )
	self.id = id
	self:refreshUI()
end

function ShoppingLayer.reduceButtonClickHandle(sender)
	local count = tonumber(sender.logic.txt_num:getText())
	count = count - 1
	if count > 0 then
		sender.logic:setShopNum(count)
	end

	local percent = math.ceil(count/sender.logic.max_num*100)
	sender.logic.slider_shop:setPercent(percent)
end

function ShoppingLayer.addButtonClickHandle(sender)
	local count = tonumber(sender.logic.txt_num:getText())
	count = count + 1
	sender.logic:setShopNum(count)

	local percent = math.ceil(count/sender.logic.max_num*100)
	sender.logic.slider_shop:setPercent(percent)
end


function ShoppingLayer.sliderTouchBeginHandle(sender)
	local self = sender.logic
	self.bg_jindushuzhi:setVisible(true)
	self:freshSliderNum()
end

function ShoppingLayer.sliderTouchMoveHandle(sender)
	local self = sender.logic
	self:freshSliderNum()
end

function ShoppingLayer.sliderTouchEndHandle(sender)
	local self = sender.logic
	self.bg_jindushuzhi:setVisible(false)


	local count = tonumber(sender.logic.txt_num:getText())
	local percent = math.ceil(count/sender.logic.max_num*100)
	sender.logic.slider_shop:setPercent(percent)
end


function ShoppingLayer:freshSliderNum()
	local percent = self.slider_shop:getPercent()/100
	local num = math.ceil(percent*self.max_num)
	num = math.max(num,1)
	self:setShopNum(num)
	local width = self.slider_shop:getSize().width
	local temp = math.ceil(width*percent)
	self.bg_jindushuzhi:setPositionX(temp - width/2)
end

--设置按钮状态
function ShoppingLayer:setButtonState(addEnabled,reduceEnabled,buyEnabled)
	self.btn_buy:setTouchEnabled(buyEnabled)
	self.btn_buy:setGrayEnabled(not buyEnabled)

	if buyEnabled then
		Public:addBtnWaterEffect(self.btn_buy, true,1)
	else
		Public:addBtnWaterEffect(self.btn_buy, false)
	end

	self.btn_reduce:setTouchEnabled(reduceEnabled)
	self.btn_reduce:setGrayEnabled(not reduceEnabled)


	self.btn_add:setTouchEnabled(addEnabled)
	self.btn_add:setGrayEnabled(not addEnabled)

end

function ShoppingLayer:toCanNotBuy()
	self:setButtonState(false,false,false)
	self.txt_num:setText(0)
	self.txt_numnow:setText(0)
	self.now_txt_price:setText(0)
	self.old_txt_price:setText(0)
	self.now_txt_price:setColor(ccc3(255, 0, 0))
	self.old_txt_price:setColor(ccc3(255, 0, 0))
end

function ShoppingLayer:setShopNum( num )
	local shop = ShopData:objectByID(self.id)
	if shop == nil then 
		print("无法找到该商品 id=="..self.id)
		return
	end

	local canAdd = true
	local canReduce = true
	local canBuy = true

	local remainging = self.max_num
	if shop:isLimited() then
		local now_count = MallManager:getPurchasedCount(self.id)
		local max_num = shop:getMaxNum(MainPlayer:getVipLevel())
		local remainging = max_num - now_count
	end
	if remainging < 1 then
		num = 0
		self:toCanNotBuy()
		return
	else
		if num > remainging then
			num = remainging
		end
	end
	if num == remainging then
		canAdd = false
	end
	-- else
	-- 	if num < 1 then
	-- 		num = 1
	-- 	end
	-- end

	if num < 2 then
		canReduce = false
	end



	self:setButtonState(canAdd,canReduce,canBuy)

	self.txt_num:setText(num)
	self.txt_numnow:setText(num)
	local currentResValue = MainPlayer:getResValueByType(shop.consume_type)
	local totalPrice = MallManager:getTotalPrice(self.id,num)
	self.now_txt_price:setText(totalPrice)
	self.old_txt_price:setText(totalPrice)
	self:setOldPrice( self.id , num )
	if totalPrice <= currentResValue then
		self.now_txt_price:setColor(ccc3(255, 255, 255))
		self.old_price_bg:setColor(ccc3(255, 255, 255))
	else
		self.old_price_bg:setColor(ccc3(255, 0, 0))
		self.now_txt_price:setColor(ccc3(255, 0, 0))
	end
end

--显示充值提示框
function ShoppingLayer:showRechargeDialog()
	CommonManager:showOperateSureLayer(
            function()
                PayManager:showPayLayer()
            end,
            nil,
            {
            --msg = "您没有足够的元宝购买物品，是否进入充值界面？"
            msg = localizable.common_pay_tips_1,
            }
    )
end

function ShoppingLayer.buyButtonClickHandle(sender)
	local self = sender.logic
	local num =  tonumber(self.txt_num:getText())
	local shop = ShopData:objectByID(self.id)
	if shop == nil then 
		print("无法找到该商品 id=="..self.id)
		return
	end

	if shop.need_vip_level > MainPlayer:getVipLevel() then
		--toastMessage("您的VIP等级需要达到[Lv"..shop.need_vip_level .. "]才能购买")
		toastMessage(stringUtils.format(localizable.common_todo_vip,shop.need_vip_level))
		return
	end

	if shop:isLimited() then
		local now_count = MallManager:getPurchasedCount(self.id)
		local max_num = shop:getMaxNum(MainPlayer:getVipLevel())
		if now_count + num > max_num then
			--toastMessage("超过购买上限")
			toastMessage(localizable.common_level_buzu)
			return
		end
	end

	local totalPrice = MallManager:getTotalPrice(self.id,num)
	local enough = MainPlayer:isEnough(shop.consume_type,totalPrice)
	--print("buy : ",totalPrice,enough,shop.consume_type)
	if enough then
		showLoading()
		MallManager:buyCommodityForFixedStore(shop.id,num)
		--AlertManager:close()
	end
	
	--local currentResValue = MainPlayer:getResValueByType(shop.consume_type)
	--if totalPrice > currentResValue then
	--	if shop.consume_type == EnumDropType.SYCEE then
	--		self:showRechargeDialog()
	--	else
	--		toastMessage("您没有足够的" .. GetResourceName(shop.consume_type) .. "资源，无法购买")
	--		return
    --    end
    --else
    --	AlertManager:close()
	--	MallManager:buyCommodityForFixedStore(shop.id,num)
	--end
	
end

--刷新回调
function ShoppingLayer:refreshCallback()
    self:refreshUI()
end

function ShoppingLayer:registerEvents()
	self.super.registerEvents(self)

	ADD_ALERT_CLOSE_LISTENER(self,self.btn_close)
	self.btn_close:setClickAreaLength(100);

	self.btn_add:addMEListener(TFWIDGET_CLICK, audioClickfun(self.addButtonClickHandle),1)
	self.btn_reduce:addMEListener(TFWIDGET_CLICK, audioClickfun(self.reduceButtonClickHandle),1)
	self.btn_buy:addMEListener(TFWIDGET_CLICK, audioClickfun(self.buyButtonClickHandle),1)



	--购买成功通知
     self.buySuccessCallback = function (event)
         --self:refreshCallback()
         hideLoading()
         AlertManager:close()
     end

	--逻辑事件
    TFDirector:addMEGlobalListener(MallManager.BuySuccessFromFixedStore, self.buySuccessCallback)

    --监听VIP等级更改
    self.vipLevelChangedCallback = function(event)
    	self:refreshUI()
	end
	TFDirector:addMEGlobalListener(MainPlayer.VipLevelChange, self.vipLevelChangedCallback)



	self.slider_shop:addMEListener(TFWIDGET_TOUCHBEGAN, audioClickfun(self.sliderTouchBeginHandle),1)
	self.slider_shop:addMEListener(TFWIDGET_TOUCHMOVED, audioClickfun(self.sliderTouchMoveHandle),1)
	self.slider_shop:addMEListener(TFWIDGET_TOUCHENDED, audioClickfun(self.sliderTouchEndHandle),1)

end

function ShoppingLayer:removeEvents()
    self.btn_add:removeMEListener(TFWIDGET_CLICK)
	self.btn_reduce:removeMEListener(TFWIDGET_CLICK)
	self.btn_buy:removeMEListener(TFWIDGET_CLICK)

	self.slider_shop:removeMEListener(TFWIDGET_TOUCHBEGAN)
	self.slider_shop:removeMEListener(TFWIDGET_TOUCHMOVED)
	self.slider_shop:removeMEListener(TFWIDGET_TOUCHENDED)

	--逻辑事件
    TFDirector:removeMEGlobalListener(MallManager.BuySuccessFromFixedStore, self.buySuccessCallback)
    TFDirector:removeMEGlobalListener(MainPlayer.VipLevelChange, self.vipLevelChangedCallback)
    self.super.removeEvents(self)
end

function ShoppingLayer:drawGiftItemList()
	if self.tableView == nil then
		local  tableView =  TFTableView:create()
	    tableView:setTableViewSize(self.panel_gift:getContentSize())
	    tableView:setDirection(TFTableView.TFSCROLLHORIZONTAL)
	    tableView:setVerticalFillOrder(TFTableView.TFTabViewFILLTOPDOWN)
	    -- tableView:setPosition(self.panel_gift:getPosition())
	    tableView:setPosition(ccp(0, 0))
	    self.tableView = tableView
	    self.tableView.logic = self

	    -- tableView:addMEListener(TFTABLEVIEW_TOUCHED, NewSignLayer.tableCellTouched)
	    tableView:addMEListener(TFTABLEVIEW_SIZEFORINDEX, ShoppingLayer.cellSizeForTable)
	    tableView:addMEListener(TFTABLEVIEW_SIZEATINDEX, ShoppingLayer.tableCellAtIndex)
	    tableView:addMEListener(TFTABLEVIEW_NUMOFCELLSINTABLEVIEW, ShoppingLayer.numberOfCellsInTableView)
	    tableView:reloadData()

	    -- self.panel_gift:getParent():addChild(self.tableView,1)
	    self.panel_gift:addChild(self.tableView,1)
	else
		self.tableView:reloadData()
	end

end

function ShoppingLayer.numberOfCellsInTableView(table)
	local self = table.logic

    return #self.giftGoodsList
end


function ShoppingLayer.cellSizeForTable(table,idx)
    -- return 160,130*7
    return 110,80
end

function ShoppingLayer.tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local self = table.logic

    local cell = table:dequeueCell()
    if nil == cell then
        cell = TFTableViewCell:create()
    else
        cell:removeAllChildren()
    end

    self:drawGiftCell(cell, idx)

    return cell
end

function ShoppingLayer.touchGiftItem(sender)

end


function ShoppingLayer:drawGiftCell(cell, cellIndex)
    local posX = 40
   	local giftData 		= self.giftGoodsList[cellIndex + 1]
   	local giftDataInfo 	= split(giftData, "_")
   	local itemType 		= tonumber(giftDataInfo[1])
   	local itemId_ 		= tonumber(giftDataInfo[2])
   	local itemNum 		= tonumber(giftDataInfo[3])
   	-- print("giftDataInfo = ", giftDataInfo)


   	local item = {type = itemType, number = itemNum, itemId = itemId_}
    local rewardInfo = BaseDataManager:getReward(item)
    -- print("item = ", item)
    print("rewardInfo = ", rewardInfo)
   	-- if true then
   	-- 	return
   	-- end
    local rewardItemBg = TFImage:create(GetColorIconByQuality(rewardInfo.quality))
    rewardItemBg:setPosition(ccp(posX, 60))
    rewardItemBg:setScale(0.5)
    cell:addChild(rewardItemBg)
    
    local rewardItemImage = TFImage:create(rewardInfo.path)
    rewardItemImage:setPosition(ccp(0, 0))
    rewardItemBg:addChild(rewardItemImage)
    rewardItemImage:setTouchEnabled(true)
    rewardItemImage:addMEListener(TFWIDGET_CLICK,
    audioClickfun(function()
        Public:ShowItemTipLayer(rewardInfo.itemid, rewardInfo.type)
    end))

    local rewardLabel = TFLabelBMFont:create()
    rewardLabel:setScale(0.65)
    rewardLabel:setFntFile("font/new/num_lv.fnt")
    rewardLabel:setPosition(ccp(posX, 17))
    rewardLabel:setText("X"..rewardInfo.number)
    cell:addChild(rewardLabel)
    posX = posX + 60

    -- Public:addPieceImg(rewardItemImage,rewardData)
end

return ShoppingLayer;
