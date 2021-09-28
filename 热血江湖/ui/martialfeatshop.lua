-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_MFShop = i3k_class("wnd_MFShop", ui.wnd_base)

function wnd_MFShop:ctor()
	self._refreshTime = 0
	self._cfg = nil
	self._item = nil
	self._goods = nil
	self.shopId = -1
end

function wnd_MFShop:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
	self._layout.vars.refresh_btn:onClickWithChild(self, self.refreshData)
	--self._layout.vars.shopName:setImage(g_i3k_db.i3k_db_get_icon_path(498))
	self._layout.vars.tipTxtRoot:hide()
end

function wnd_MFShop:refresh(info, shopId)
	self.shopId = shopId
	self._cfg = i3k_db_martialFeat_Shop[shopId]
	if not self._cfg then
		self:onCloseUI()
		return
	end
	if self._cfg.bwtype == g_young_League then
		self._layout.vars.moneyRoot:hide()
		self._layout.vars.shopName:setImage(g_i3k_db.i3k_db_get_icon_path(3892))
		
	end
	g_i3k_ui_mgr:RefreshUI(eUIID_DB)
  	g_i3k_ui_mgr:RefreshUI(eUIID_DBF)
  	local totalFeats = g_i3k_game_context:getForceWarAddFeat()
  	self._layout.vars.featValue:setText(tostring(totalFeats))
	self:setData(info)
end

function wnd_MFShop:onItemTips(sender,eventType,args)
	self._layout.vars.tipTxtRoot:hide()
	if eventType == ccui.TouchEventType.began then
		local pos = sender:getPosition()
		pos = sender:getParent():convertToWorldSpace(pos)
		self._layout.vars.tipTxt:setText(args)
		self._layout.vars.tipTxtRoot:setPosition(pos)
		self._layout.vars.tipTxtRoot:show()
	elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
		self._layout.vars.tipTxtRoot:hide()
	end
end

function wnd_MFShop:setData(info)
	self._item = nil
	local timeNow = g_i3k_get_GMTtime(i3k_game_get_time())
	local hour = tonumber(os.date("%H", timeNow))
	local cfgRefresh = self._cfg.refreshTime
	local refreshHour = tonumber(string.sub(cfgRefresh, 1, 2))
	local nextRefreshTime
	if hour<refreshHour then
		nextRefreshTime = string.format("今日%d点", refreshHour)
		self._layout.vars.refreshTime:setText(nextRefreshTime)
	else
		nextRefreshTime = string.format("明日%d点", refreshHour)
		self._layout.vars.refreshTime:setText(nextRefreshTime)
	end
	
	self._refreshTime = info.refreshTimes
	self._goods = info.goods
	local scroll = self._layout.vars.item_scroll
	scroll:removeAllChildren()
	scroll:setBounceEnabled(false)

	local coinCnt = g_i3k_game_context:GetMoney(true)
	local totalFeats = g_i3k_game_context:getForceWarAddFeat()
	if scroll then
		local nodePath = "ui/widgets/wxsct"		
		for i,v in ipairs(info.goods) do
			local node = require(nodePath)()
			local cfg = self._cfg.shop[v.id]
			if v.buyTimes==0 then
				node.vars.out_icon:hide()
				node.vars.buyBtn:onClick(self, self.buyItem, {seq = i, cfg = cfg, item = node})
			else
				node.vars.out_icon:show()
				node.vars.buyBtn:setTouchEnabled(false)
			end
			node.vars.item_bg:onTouchEvent(self, self.onItemTips, cfg.tip)
			node.vars.item_bg:setImage(g_i3k_get_icon_frame_path_by_rank(cfg.rank))
			node.vars.item_name:setText(cfg.name)
			node.vars.item_name:setTextColor(g_i3k_get_color_by_rank(cfg.rank))
			if coinCnt < cfg.price then
				node.vars.money_count:setText("<c=hlred>"..cfg.price.."</c>")
			else
				node.vars.money_count:setText(cfg.price)
			end
			node.vars.item_icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.iconId))
			if totalFeats < cfg.limitValue then
				node.vars.descTxt:setText(string.format("%s<c=hlred>%s%d%s",cfg.desc,"\n武勋",cfg.limitValue,"可买</c>"))
			else
				if cfg.limitValue == 0 then
					node.vars.descTxt:setText(string.format("%s",cfg.desc))
				else
					node.vars.descTxt:setText(string.format("%s\n武勋%d%s",cfg.desc,cfg.limitValue,"可买"))
				end
			end
			scroll:addItem(node)
		end
	end
end

function wnd_MFShop:updateWordColor()
	local items = self._layout.vars.item_scroll:getAllChildren()
	local coinCnt = g_i3k_game_context:GetMoney(true)
	for k, v in ipairs(self._goods) do
		local cfg = self._cfg.shop[v.id]
		if coinCnt < cfg.price then
			items[k].vars.money_count:setText("<c=hlred>"..cfg.price.."</c>")
		else
			items[k].vars.money_count:setText(cfg.price)
		end	
	end
end

function wnd_MFShop:refreshData(sender)
	local count = #self._cfg.refreshCoin
	local needMoney = 0
	
	if self._refreshTime+1>count then
		needMoney = self._cfg.refreshCoin[count]
	else
		needMoney = self._cfg.refreshCoin[self._refreshTime+1]
	end
	
	local moneyCount = g_i3k_game_context:GetBaseItemCount(self._cfg.moneyType)
	if moneyCount>=needMoney then
		local refreshStrId = self.shopId > 2 and 15473 or 818
		local desc = i3k_get_string(refreshStrId, needMoney)
		local callback = function (isOk)
			if isOk then
				self._refreshTime = self._refreshTime+1
				local bean = i3k_sbean.feat_gambleshoprefresh_req.new()
				bean.times = self._refreshTime
				bean.shopId = self.shopId
				bean.callback = function( )
					g_i3k_game_context:UseDiamond(needMoney ,true,AT_USER_REFRESH_GAMBLE_SHOP)
				end
				i3k_game_send_str_cmd(bean, "feat_gambleshoprefresh_res")
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(548))
	end
end

function wnd_MFShop:buyItem(sender, args)
	local cfg = args.cfg
	local totalFeats = g_i3k_game_context:getForceWarAddFeat()
	if totalFeats < cfg.limitValue then
		return g_i3k_ui_mgr:PopupTipMessage("<c=hlred>武勋</c>未达到要求")
	elseif g_i3k_game_context:GetBaseItemCount(cfg.moneyType) < cfg.price then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(407))
	end
	local callback = function (isOk)
		if isOk then
			local bean = i3k_sbean.feat_gambleshopbuy_req.new()
			bean.seq = args.seq
			bean.shopId = self.shopId
			bean.callback = function( )
				self._item = args.seq
				g_i3k_game_context:UseBaseItem(cfg.moneyType, cfg.price, AT_BUY_GAMBLE_SHOP_GOOGS)
			end
			i3k_game_send_str_cmd(bean, "feat_gambleshopbuy_res")
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(817, cfg.price,cfg.name), callback)
end

function wnd_MFShop:ShowBoughtIcon()
	if self._item then
		local items = self._layout.vars.item_scroll:getAllChildren()
		local node = items[self._item]
		-- self._goods[self._item].buyTimes = 1
		node.vars.out_icon:show()
		node.vars.buyBtn:setTouchEnabled(false)
		self:updateWordColor()
		self._item = nil
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_MFShop.new();
		wnd:create(layout, ...);

	return wnd;
end
