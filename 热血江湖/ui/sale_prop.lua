-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/add_sub");

-------------------------------------------------------
wnd_sale_prop = i3k_class("wnd_sale_prop", ui.wnd_add_sub)


function wnd_sale_prop:ctor()
	self.index = 0
	self.PropMinCount = -i3k_db_common.aboutAuction.MinCount
	self.PropMaxCount = i3k_db_common.aboutAuction.MaxCount
	self.ChangeProportion =  i3k_db_common.aboutAuction.ChangeProportion
end

function wnd_sale_prop:configure()
	local widgets = self._layout.vars
	self._layout.vars.cancel:onClick(self, self.onCloseUI)

	self.add_btn = self._layout.vars.addBtn
	self.sub_btn = self._layout.vars.reduceBtn
	self.max_btn = self._layout.vars.maxBtn
	self._count_label = self._layout.vars.countLabel

	self.add_btn:onTouchEvent(self, self.onAdd, true)
	self.sub_btn:onTouchEvent(self,self.onSub, true)
	self.max_btn:onTouchEvent(self,self.onMax, true)

	-----------------------------------
	--add by jxw 加价格调控新需求
	self.price =widgets.countLabel2 --价格（会变化）
	self.reduceBtn =widgets.reduceBtn2 --减号
	self.reduceBtn:onClick(self, self.onReduceBtn)
	self.addBtn =widgets.addBtn2 --加号
	self.addBtn:onClick(self, self.onAddBtn)
	self.maxBtn =widgets.maxBtn2 --最大
	self.maxBtn:onClick(self, self.onMaxBtn)
	self.RecPriceLabel = self._layout.vars.RecPriceLabel --推荐价格的百分比
	------------------------------------

	self._otherPlayerWidgets = {}
	for i=1, 5 do
		local node = {}
		node.root = self._layout.vars[string.format("root%d", i)]
		node.root:hide()
		node.btn = self._layout.vars[string.format("btn%d", i)]
		node.gradeIcon = self._layout.vars[string.format("gradeIcon%d", i)]
		node.icon = self._layout.vars[string.format("icon%d", i)]
		node.nameLabel = self._layout.vars[string.format("nameLabel%d", i)]
		node.priceLabel = self._layout.vars[string.format("priceLabel%d", i)]
		self._otherPlayerWidgets[i] = node
	end
end

function wnd_sale_prop:setSaleMoneyCount(count1,count2)
	local tmp_str = string.format("%s/%s",count1,count2)
	self._count_label:setText(tmp_str)
end

function wnd_sale_prop:refresh(item, logs)
	local id = item.id
	self.id = id
	local count = item.count
	local maxSaleCount = i3k_db_common.aboutAuction.maxSaleCount
	if count > maxSaleCount then
		count = maxSaleCount
	end

	self.current_add_num = count

	self._fun = function ()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_SaleProp,"setSaleMoneyCount",self.current_num,self.current_add_num)
		self:calcTotalPrice()
	end

	local typeId = g_i3k_db.i3k_db_get_auction_item_type(id)
	local itemType = i3k_db_auction_type[typeId]

	local itemCfg = g_i3k_db.i3k_db_get_common_item_cfg(id)
	if itemCfg.levelReq then
		self._layout.vars.levelLabel:setText(string.format("%d级", itemCfg.levelReq ))
	else
		self._layout.vars.levelLabel:hide()
	end

	self._layout.vars.typeLabel:setText(itemType and itemType.name or i3k_db_auction_type[100].name)
	self._layout.vars.nameLabel:setText(g_i3k_db.i3k_db_get_common_item_name(id))
	local rank = g_i3k_db.i3k_db_get_common_item_rank(id)
	self._layout.vars.nameLabel:setTextColor(g_i3k_db.g_i3k_get_color_by_rank(rank))
	self._layout.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	self._layout.vars.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	self._layout.vars.countLabel:setText("1/"..count)
	self._layout.vars.totalPriceLabel:setText("0")
	self._layout.vars.descLabel:setText(g_i3k_db.i3k_db_get_common_item_desc(id))
	self._layout.vars.putOnBtn:onClick(self, self.putOn, id)
	self.priceAddNum =g_i3k_db.i3k_db_get_auction_recommend_price(id)
	self.price:setText(self.priceAddNum)
	self.RecPriceLabel:setText("推荐售价:+0%")
	self:calcTotalPrice()


	for i,v in ipairs(logs) do
		local node = self._otherPlayerWidgets[i]
		local id = v.id
		node.nameLabel:setText(g_i3k_db.i3k_db_get_common_item_name(id))
		local rank = g_i3k_db.i3k_db_get_common_item_rank(id)
		node.nameLabel:setTextColor(g_i3k_get_color_by_rank(rank))
		node.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		node.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
		node.priceLabel:setText(v.price/v.count)
		node.btn:onClick(self, self.checkItemInfo, id)
		node.root:show()
	end
end


--减号 jxw
function wnd_sale_prop:onReduceBtn(sender)
	if self.index <= self.PropMinCount then
		g_i3k_ui_mgr:PopupTipMessage("已经是最小价格了")
		return
	end
	self.index = self.index - 1
	local str = "+"
	if self.index <0 then
		str = "-"
	end
	local num = self.index*self.ChangeProportion
	--从装备表中取出售卖推荐价格
	local price =g_i3k_db.i3k_db_get_auction_recommend_price(self.id)
	self.priceAddNum = math.floor(price + price*num/100) > 0 and math.floor(price + price*num/100) or 1
	self.price:setText(self.priceAddNum)
	local showNum = num>=0 and num or -num
	self.RecPriceLabel:setText("推荐售价:"..str..showNum.."%")
	self:calcTotalPrice()
end

--加号 jxw
function wnd_sale_prop:onAddBtn(sender)
	if self.index >= self.PropMaxCount then
		g_i3k_ui_mgr:PopupTipMessage("已经是最大价格了")
		return
	end
	self.index = self.index + 1
	local str = "+"
	if self.index <0 then
		str = "-"
	end
	local num = self.index*self.ChangeProportion
	--从装备表中取出售卖推荐价格
	local price =g_i3k_db.i3k_db_get_auction_recommend_price(self.id)
	self.priceAddNum = math.floor(price + price*num/100) > 0 and math.floor(price + price*num/100) or 1
	self.price:setText(self.priceAddNum)
	local showNum = num>=0 and num or -num
	self.RecPriceLabel:setText("推荐售价:"..str..showNum.."%")
	self:calcTotalPrice()
end

--最大 jxw
function wnd_sale_prop:onMaxBtn(sender)
	self.index = self.PropMaxCount
	local str = "+"
	local num = self.index*self.ChangeProportion
	--从装备表中取出售卖推荐价格
	local price =g_i3k_db.i3k_db_get_auction_recommend_price(self.id)
	self.priceAddNum =math.floor(price + price*num/100) > 0 and math.floor(price + price*num/100) or 1
	self.price:setText(self.priceAddNum)
	local showNum = num>=0 and num or -num
	self.RecPriceLabel:setText("推荐售价:"..str..showNum.."%")
	self:calcTotalPrice()
end

function wnd_sale_prop:putOn(sender, id)
	local saleCount, totalCount = self:getSaleAndTotalCount()
	local price = self.priceAddNum
	if price and price>0 then
		--上架协议操作
		i3k_sbean.putOnItem(id, saleCount, price*saleCount)
	else
		--提示信息，写上价格
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(394))
	end
end

function wnd_sale_prop:checkItemInfo(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_sale_prop:calcTotalPrice()
	local saleCount, totalCount = self:getSaleAndTotalCount()
	local price = self.priceAddNum
	if price then
		local totalPrice = tonumber(math.floor(saleCount*price))
		self._layout.vars.totalPriceLabel:setText(totalPrice)
	end
end

function wnd_sale_prop:getSaleAndTotalCount()
	local str = self._layout.vars.countLabel:getText()
	local number = string.split(str, "/")
	return tonumber(number[1]), tonumber(number[2])
end

function wnd_create(layout, ...)
	local wnd = wnd_sale_prop.new()
	wnd:create(layout, ...)
	return wnd;
end
