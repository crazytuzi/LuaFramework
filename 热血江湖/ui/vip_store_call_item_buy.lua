
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/profile")
-------------------------------------------------------
wnd_vip_store_call_item_buy = i3k_class("wnd_vip_store_call_item_buy", ui.wnd_profile)

local e_Type_vip_store_yuanbao = 1
local e_Type_vip_store_bangyuan = 0
local e_Type_vip_store_hongli = 3
local e_Type_vip_store_longhun = 4
local currency_icon = {32, 3850, 5005}  --货币图标
local titleImg = {6599, 6600} --标题图片

function wnd_vip_store_call_item_buy:ctor()

end

function wnd_vip_store_call_item_buy:configure()
	local widget = self._layout.vars
	self.ui = widget

	widget.cancel:onClick(self, self.onCloseUI)
	widget.ok:onTouchEvent(self, self.okButton)

	self.revolve = widget.revolve
	self.revolve:onTouchEvent(self, self.onRotateBtn)
	self.hero_module = widget.hero_module
end

function wnd_vip_store_call_item_buy:refresh(sendcommond, item)
	self.sendcommond = sendcommond	--发送协议与参数
	self.item = item				--物品信息
	self:showInfo()
end

function wnd_vip_store_call_item_buy:showInfo()
	local cfg = g_i3k_db.i3k_db_get_other_item_cfg(self.item.iid)
	local titleText = ""
	local descText = ""
	local titleImgID = 0
	if cfg.args1 then  --坐骑或宠物的id
		if cfg.type == UseItemPet then
			local petCfg = g_i3k_db.i3k_db_get_pet_cfg(cfg.args1)
			titleText = "宠物介绍"
			descText = petCfg.storeDesc
			titleImgID = titleImg[2]

			self:setModel(petCfg.modelID)
			self.ui.hero_module:setRotation(2)
			if math.random() <= 0.5 then
				self.ui.hero_module:pushActionList("01attack01", 1)
			else
				self.ui.hero_module:pushActionList("02attack02", 1)
			end
			self.ui.hero_module:pushActionList("stand", -1)
			self.ui.hero_module:playActionList()
		elseif cfg.type == UseItemHorse then
			local steedCfg = i3k_db_steed_cfg[cfg.args1]
			local huanhuaCfg = i3k_db_steed_huanhua[steedCfg.huanhuaInitId]
			titleText = "坐骑介绍"
			descText = steedCfg.storeDesc
			titleImgID = titleImg[1]

			local mcfg = i3k_db_models[huanhuaCfg.modelId]
			self:setModel(huanhuaCfg.modelId, mcfg.uiscale * 1.2)
			if huanhuaCfg.modelRotation ~= 0 then
				self.ui.hero_module:setRotation(huanhuaCfg.modelRotation)
			end
			self.ui.hero_module:playAction("show")
		end
		self.ui.titleText:setText(titleText)
		self.ui.descText:setText(descText)
		self.ui.title:setImage(g_i3k_db.i3k_db_get_icon_path(titleImgID))
	end
	self:setItemInfo()
end

function wnd_vip_store_call_item_buy:setModel(modelID, uiscale)
	local mcfg = i3k_db_models[modelID]
	if mcfg then
		self.ui.hero_module:setSprite(mcfg.path)
		self.ui.hero_module:setSprSize(uiscale and uiscale or mcfg.uiscale)
	end
end

function wnd_vip_store_call_item_buy:setItemInfo()
	local itemname = ""
	itemname = g_i3k_db.i3k_db_get_common_item_name(self.item.iid)
	self.sendcommond.itemname = itemname
	if self.item.icount > 1 then
		itemname = itemname.."*"..self.item.icount
	end
	self.ui.item_name:setText(itemname)
	self.ui.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self.item.iid))
	self.ui.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self.item.iid, g_i3k_game_context:IsFemaleRole()))
	self.ui.item_icon_lock:setVisible(self.item.iid > 0)

	if self.sendcommond.free == e_Type_vip_store_yuanbao then
		self.ui.item_price_lock_icon:hide()
		self.ui.item_price_icon:setImage(i3k_db.i3k_db_get_icon_path(currency_icon[1]))  --元宝图标
	elseif self.sendcommond.free == e_Type_vip_store_bangyuan then
		self.ui.item_price_lock_icon:show()
		self.ui.item_price_icon:setImage(i3k_db.i3k_db_get_icon_path(currency_icon[1]))  --元宝图标
	elseif self.sendcommond.free == e_Type_vip_store_hongli then
		self.ui.item_price_lock_icon:hide()
		self.ui.item_price_icon:setImage(i3k_db.i3k_db_get_icon_path(currency_icon[2]))  --红利图标
	elseif self.sendcommond.free == e_Type_vip_store_longhun then
		self.ui.item_price_lock_icon:hide()
		self.ui.item_price_icon:setImage(i3k_db.i3k_db_get_icon_path(currency_icon[3]))  --龙魂币图标
	end
	self.ui.item_price:setText(self.item.finalprice)
end

--需要判断之前是否买过或拥有坐骑或宠物道具
function wnd_vip_store_call_item_buy:okButton(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(self.item.iid)
		local isHave = false
		local str = ""
		if cfg.type == UseItemPet then
			isHave = g_i3k_game_context:IsHavePet(cfg.args1)
			str = "宠物"
		elseif cfg.type == UseItemHorse then
			isHave = g_i3k_db.i3k_db_get_steed_is_have(cfg.args1)
			str = "坐骑"
		end

		if g_i3k_game_context:GetCommonItemCanUseCount(self.item.iid) > 0 or isHave then
			local callback = (function(ok)
				if ok then
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_VipStoreCallItemBuy, "buyItem")
				end
			end)
			g_i3k_ui_mgr:ShowMessageBox2(string.format("您已拥有此%s，是否继续购买？", str) , callback)
			return
		end
		self:buyItem()
	end
end

function wnd_vip_store_call_item_buy:buyItem()
	if self:canAfford(self.item.finalprice) then
		if self:canBuyVIP(self.item) then
			if self.limitTimes == 0 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(214))
			else
				local test = {}
				test[self.item.iid] = self.item.icount
				if g_i3k_game_context:IsBagEnough(test) then
					self.sendcommond.count = 1
					local have = g_i3k_game_context:GetBaseItemCount(g_BASE_ITEM_DIAMOND)
					if self.sendcommond.price > have and self.sendcommond.free == e_Type_vip_store_bangyuan then
						local effectiveTime = self.sendcommond.effectiveTime
						local id = self.sendcommond.id
						local gid = self.sendcommond.gid
						local count = self.sendcommond.count
						local free = self.sendcommond.free
						local price = self.sendcommond.price
						local itemname = self.sendcommond.itemname
						local finalcount = self.item.icount
						local currencyType = self:toCurrencyType(free)

						local callfunction = function(ok)
							if ok then
								i3k_sbean.mall_buy(effectiveTime, id, gid,count, currencyType, price, itemname, finalcount)
							end
						end

						local msg = ""
						if have == 0 then
							msg = i3k_get_string(217, self.sendcommond.price)
						else
							msg = i3k_get_string(299, have, (self.sendcommond.price - have))
						end
						g_i3k_ui_mgr:ShowCustomMessageBox2("购买", "取消", msg, callfunction)
					else
						local free = self.sendcommond.free
						local currencyType = self:toCurrencyType(free)
						i3k_sbean.mall_buy(self.sendcommond.effectiveTime, self.sendcommond.id, self.sendcommond.gid, self.sendcommond.count, currencyType, self.sendcommond.price, self.sendcommond.itemname, self.item.icount)
					end
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(215))
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_VipStore, "isNeedRefreshLog")
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_VipStore, "setStoreList", false)
				end
			end
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(213, self.item.vipReq))
		end
	else
		local fun =(function(ok)
			if ok then
				g_i3k_logic:OpenChannelPayUI()
			end
		end)
		if self.sendcommond.free == e_Type_vip_store_hongli then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(3079))
		elseif self.sendcommond.free == e_Type_vip_store_longhun then
			g_i3k_ui_mgr:ShowCustomMessageBox2("去储值", "以后再说", "你的龙魂币不够哦，需要充值吗", fun)
		else
			g_i3k_ui_mgr:ShowCustomMessageBox2("去储值", "以后再说", "你的元宝不够哦，需要储值吗", fun)
		end
	end
end

function wnd_vip_store_call_item_buy:canAfford(price)
	if self.sendcommond.free == e_Type_vip_store_yuanbao then
		local have = g_i3k_game_context:GetBaseItemCount(-g_BASE_ITEM_DIAMOND)
		if have >= price then
			return true
		end
	elseif self.sendcommond.free == e_Type_vip_store_bangyuan then
		local have = g_i3k_game_context:GetBaseItemCount(g_BASE_ITEM_DIAMOND)
		local fhave = g_i3k_game_context:GetBaseItemCount(-g_BASE_ITEM_DIAMOND)
		if have + fhave >= price then
			return true
		end
	elseif self.sendcommond.free == e_Type_vip_store_hongli then
		local have = g_i3k_game_context:GetBaseItemCount(g_BASE_ITEM_DIVIDEND)
		if have >= price then
			return true
		end
	elseif self.sendcommond.free == e_Type_vip_store_longhun then
		local have = g_i3k_game_context:GetBaseItemCount(g_BASE_ITEM_DRAGON_COIN)
		if have >= price then
			return true
		end
	end
	return false
end

function wnd_vip_store_call_item_buy:canBuyVIP(Item)
	if Item.vipReq then
		local viplvl = g_i3k_game_context:GetVipLevel()
		if viplvl < Item.vipReq then
			return false
		end
	end
	return true
end

function wnd_vip_store_call_item_buy:toCurrencyType(free)
	local currencyType = g_BASE_ITEM_DIAMOND
	if free == e_Type_vip_store_yuanbao then
		currencyType = -g_BASE_ITEM_DIAMOND
	elseif free == e_Type_vip_store_bangyuan then
		currencyType = g_BASE_ITEM_DIAMOND
	elseif free == e_Type_vip_store_hongli then
		currencyType = g_BASE_ITEM_DIVIDEND
	elseif free == e_Type_vip_store_longhun then
		currencyType = g_BASE_ITEM_DRAGON_COIN
	end
	return currencyType
end

function wnd_create(layout, ...)
	local wnd = wnd_vip_store_call_item_buy.new()
	wnd:create(layout, ...)
	return wnd;
end

