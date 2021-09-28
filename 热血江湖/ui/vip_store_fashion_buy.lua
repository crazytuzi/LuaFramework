-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/profile")
-------------------------------------------------------
local HUANXINGICON = 7855 --幻形
local FASHIONICON  = 7854 --时装
vip_store_fashion_buy = i3k_class("vip_store_fashion_buy",ui.wnd_profile)
local e_Type_vip_store_yuanbao = 1
local e_Type_vip_store_bangyuan = 0
local e_Type_vip_store_hongli = 3
local e_Type_vip_store_longhun = 4
local LAYER_ZBTIPST = "ui/widgets/szgmt"
local LAYER_ZBTIPST3 = "ui/widgets/zbtipst3"
local sexStr = {"男", "女"}
local currency_icon = {32, 3850, 5005}  --货币图标
local METAMORPHOSIS_TYPE = 1  --幻形
function vip_store_fashion_buy:ctor()
    self._dressType = nil
end

function vip_store_fashion_buy:refresh(sendcommond,item, typeState)
	local widget = self._layout.vars
	self._dressType = typeState
	self.sendcommond = sendcommond	--发送协议与参数
	self.item = item		--物品信息
	if  self._dressType ==  METAMORPHOSIS_TYPE  then
		widget.title:setImage(i3k_db.i3k_db_get_icon_path(HUANXINGICON))
		self:showInfoMetamorphosis()
		if self.ok_bt then self.ok_bt:onTouchEvent(self, self.okButton) end
	else
		widget.title:setImage(i3k_db.i3k_db_get_icon_path(FASHIONICON))
	self:showInfo();
		if self.ok_bt then self.ok_bt:onTouchEvent(self, self.okButton) end
	end
end

function vip_store_fashion_buy:configure(...)
	local screenSize = cc.Director:getInstance():getWinSize();
	local rootSize = self._layout.root:getContentSize();
	local widget = self._layout.vars
	self.close_btn = widget.close_btn
	self.item_bg = widget.item_bg
	self.item_icon = widget.item_icon
	self.item_icon_lock = widget.item_icon_lock
	self.item_name = widget.item_name
	self.item_level = widget.item_level
	self.is_free = widget.is_free
	self.item_type = widget.item_type
	self.scroll = widget.scroll
	self.power_value = widget.power_value
	self.item_price = widget.item_price
	self.item_price_icon = widget.item_price_icon
	self.item_price_lock_icon = widget.item_price_lock_icon
	self.revolve = widget.revolve
	self.revolve:onTouchEvent(self, self.onRotateBtn)
	self.cancel_bt = widget.cancel
	self.hero_module = widget.hero_module
	self.hero_module.isEffectFashion = true
	self.ok_bt = widget.ok
	if self.cancel_bt then self.cancel_bt:onTouchEvent(self, self.cancelButton) end
	--if self.close_btn then self.close_btn:onTouchEvent(self, self.onClose) end
	if self.ok_bt then self.ok_bt:onTouchEvent(self, self.okButton) end
	widget.liulan_btn:onClick(self,self.onShowBtn)
	self:initEffectEvent()
end

function vip_store_fashion_buy:showInfo()
	local cfg = g_i3k_db.i3k_db_get_other_item_cfg(self.item.iid)
	local propertyTb = g_i3k_db.i3k_db_get_fashion_property(cfg.args1)
	local power = g_i3k_db.i3k_db_get_battle_power(propertyTb,true)
	self.power_value:setText(power)
	local itemname = "";
	itemname = i3k_db.i3k_db_get_common_item_name(self.item.iid)
	self.sendcommond.itemname = itemname;
	if self.item.icount > 1 then
		itemname = itemname.."*"..self.item.icount
	end
	local fashionCfg = g_i3k_db.i3k_db_get_fashion_cfg(cfg.args1)
	self.showingFashionId = cfg.args1
	self.item_level:setText(sexStr[fashionCfg.sex])
	self.item_level:setTextColor(g_i3k_get_cond_color(fashionCfg.sex == g_i3k_game_context:GetRoleGender()))
	self.item_name:setText(itemname)
	--self.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(self.item.iid)))
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self.item.iid))
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self.item.iid,i3k_game_context:IsFemaleRole()))
	self._layout.vars.descTitle:setText(i3k_get_string(1576))
	self._layout.vars.szTips:setText(fashionCfg.tips)
	if fashionCfg.LoGoID == 0 then
		self._layout.vars.LoGoImage:setVisible(false)
	else
		self._layout.vars.LoGoImage:setImage(fashionCfg.LoGoID)
	end
	if self.item.iid > 0  then
		self.item_icon_lock:setVisible(true)
		self.is_free:setText("绑定")
	else
		self.item_icon_lock:setVisible(false)
		self.is_free:setText("非绑定")
	end
	if fashionCfg.sex == g_i3k_game_context:GetRoleGender() then
		g_i3k_game_context:SetTestFashionData(cfg.args1)
		ui_set_hero_model(self._layout.vars.hero_module, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips())
	else
		local Gender = g_i3k_game_context:GetRoleGender()
		local Type = g_i3k_game_context:GetRoleType()
		local id = Gender == 2 and Type*2 or Type*2-1
		local cfgF = i3k_db_general_fashion[id]
		self.hero = {_guid = 11111,
					 _armor = {id = 0},
					_gender = fashionCfg.sex == 0 and Gender or fashionCfg.sex,
					_face = cfgF.faceSkin[1],
					_hair = cfgF.hairSkin[1],
					_id = Type,
					_fashion = cfgF,
					_Usefashion = {},
					_cacheFashionData = { valid =  false },
					_TestfashionID = {[fashionCfg.fashionType] = cfg.args1},
					_equips = {},
					_soaringDisplay = {weaponDisplay = 0, footEffect = 0},
					}
		ui_set_hero_model(self._layout.vars.hero_module,self.hero)--)
	end
	if self.sendcommond.free == e_Type_vip_store_yuanbao then
		self.item_price_lock_icon:hide()
		self.item_price_icon:setImage(i3k_db.i3k_db_get_icon_path(currency_icon[1]))  --元宝图标
	elseif self.sendcommond.free == e_Type_vip_store_bangyuan then
		self.item_price_lock_icon:show()
		self.item_price_icon:setImage(i3k_db.i3k_db_get_icon_path(currency_icon[1]))  --元宝图标
	elseif self.sendcommond.free == e_Type_vip_store_hongli then
		self.item_price_lock_icon:hide()
		self.item_price_icon:setImage(i3k_db.i3k_db_get_icon_path(currency_icon[2]))  --红利图标
	elseif self.sendcommond.free == e_Type_vip_store_longhun then
		self.item_price_lock_icon:hide()
		self.item_price_icon:setImage(i3k_db.i3k_db_get_icon_path(currency_icon[3]))  --龙魂币图标
	end
	self.item_price:setText(self.item.finalprice);
	--local des = require(LAYER_ZBTIPST3)()
	--des.vars.desc:setText(string.format("基础属性"))
	--self.scroll:addItem(des)


	for k, v in pairs(propertyTb) do
		local des = require(LAYER_ZBTIPST)()
		local _t = i3k_db_prop_id[k]
		local _desc = _t.desc
		_desc = _desc.." :"
		des.vars.desc:setText(_desc)
		--des.vars.desc:setTextColor(_t.textColor)
		des.vars.value:setText(i3k_get_prop_show(k,v))
		--des.vars.value:setTextColor(_t.valuColor)
		self.scroll:addItem(des)
	end

	self:setDynamicEffect(cfg.args1)
	self._layout.vars.liulan_btn:onClick(self,self.onShowBtn,cfg.args1)
	self.scroll:stateToNoSlip()
	self:onShowBtn(self)
end

function vip_store_fashion_buy:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_VIP_STROE_FASHION_BUY)
	end
end

function vip_store_fashion_buy:cancelButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if l_fCancelCallBack then
			l_fCancelCallBack()
		end
		g_i3k_ui_mgr:CloseUI(eUIID_VIP_STROE_FASHION_BUY)
	end
end

function vip_store_fashion_buy:okButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local fashion = g_i3k_db.i3k_db_get_other_item_cfg(self.item.iid)
		if g_i3k_game_context:GetCommonItemCanUseCount(self.item.iid) > 0 or g_i3k_db.i3k_db_get_fashion_is_have(fashion.args1) then
			local callback = (function(isOk)
				if isOk then
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_VIP_STROE_FASHION_BUY, "buyFashion")
				end
			end)
			g_i3k_ui_mgr:ShowCustomMessageBox2("确定", "取消", "您已拥有此时装，是否继续购买？", callback)
			return
		end
		self:buyFashion()
	end
end

function vip_store_fashion_buy:buyFashion()
	if self:canAfford(self.item.finalprice) then
		if self:canBuyVIP(self.item) then
			if self.limitTimes == 0 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(214))
			else
				local test = {}
				test[self.item.iid] = self.item.icount
				if g_i3k_game_context:IsBagEnough(test) then
					self.sendcommond.count = 1
					-- self.sendcommond.price = self.item.finalprice
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
								i3k_sbean.mall_buy(effectiveTime,id,gid,count,currencyType,price,itemname,finalcount, self.item.iid)
							end
						end

						local msg = ""
						if have == 0 then
							msg = i3k_get_string(217,self.sendcommond.price)
						else
							msg = i3k_get_string(299,have,(self.sendcommond.price-have))
						end
						g_i3k_ui_mgr:ShowCustomMessageBox2("购买", "取消", msg, callfunction)
					else
						local free = self.sendcommond.free
						local currencyType = self:toCurrencyType(free)
						i3k_sbean.mall_buy(self.sendcommond.effectiveTime,self.sendcommond.id,self.sendcommond.gid,self.sendcommond.count,currencyType,self.sendcommond.price,self.sendcommond.itemname,self.item.icount, self.item.iid)
					end
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(215))
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_VipStore, "isNeedRefreshLog")
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_VipStore, "setStoreList",false)
				end
			end
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(213,self.item.vipReq))
		end
	else
		--g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(216))
		local fun =(function(ok)
				if(ok)then
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
	--g_i3k_ui_mgr:CloseUI(eUIID_VIP_STROE_FASHION_BUY)
end

function vip_store_fashion_buy:canAfford(price)
	if self.sendcommond.free == e_Type_vip_store_yuanbao then
		local have = g_i3k_game_context:GetBaseItemCount(-g_BASE_ITEM_DIAMOND)
		if have >= price then
			return true
		end
	elseif self.sendcommond.free == e_Type_vip_store_bangyuan then
		local have = g_i3k_game_context:GetBaseItemCount(g_BASE_ITEM_DIAMOND)
		local fhave = g_i3k_game_context:GetBaseItemCount(-g_BASE_ITEM_DIAMOND)
		if have+fhave >= price then
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
	return false;
end

function vip_store_fashion_buy:canBuyVIP(Item)
	if Item.vipReq then
		local viplvl = g_i3k_game_context:GetVipLevel()
		if viplvl < Item.vipReq then
			return false;
		end
	end
	return true;
end

function vip_store_fashion_buy:toCurrencyType(free)
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

function vip_store_fashion_buy:onShowBtn(sender)
	local cfg = i3k_db_fashion_dress[self.showingFashionId and self.showingFashionId or 0]
	local showAct = cfg and cfg.showAction
	if not showAct then return; end
	ui_set_hero_model(self.hero_module, self.hero, g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion(),g_i3k_game_context:getIsShowArmor())
	for i, v in ipairs(showAct) do
		self.hero_module:pushActionList(v)
	end
	self.hero_module:playActionList()
end

------------------幻形------------------------
function vip_store_fashion_buy:showInfoMetamorphosis()
	local cfg = g_i3k_db.i3k_db_get_other_item_cfg(self.item.iid)
	local propertyTb = g_i3k_db.i3k_db_get_metamorphosis_property(cfg.args1)
	local power = g_i3k_db.i3k_db_get_battle_power(propertyTb,true)
	self.power_value:setText(power)
	local itemname = "";
	itemname = i3k_db.i3k_db_get_common_item_name(self.item.iid)
	self.sendcommond.itemname = itemname;
	if self.item.icount > 1 then
		itemname = itemname.."*"..self.item.icount
	end
	local fashionCfg = g_i3k_db.i3k_db_get_metamorphosis_cfg(cfg.args1)
	self.showingFashionId = cfg.args1
	self.item_level:setVisible(false)
	self.item_name:setText(itemname)
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self.item.iid))
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self.item.iid,i3k_game_context:IsFemaleRole()))
	self._layout.vars.descTitle:setText(i3k_get_string(1574))
	self._layout.vars.szTips:setText(fashionCfg.desc)
	self._layout.vars.LoGoImage:setVisible(false)
	if self.item.iid > 0  then
		self.item_icon_lock:setVisible(true)
		self.is_free:setText("绑定")
	else
		self.item_icon_lock:setVisible(false)
		self.is_free:setText("非绑定")
	end

	local changeID = fashionCfg.changeID
	local modelID = i3k_db_missionmode_cfg[changeID].modelId
	ui_set_hero_model(self._layout.vars.hero_module,modelID)
	if self.sendcommond.free == e_Type_vip_store_yuanbao then
		self.item_price_lock_icon:hide()
		self.item_price_icon:setImage(i3k_db.i3k_db_get_icon_path(currency_icon[1]))  --元宝图标
	elseif self.sendcommond.free == e_Type_vip_store_bangyuan then
		self.item_price_lock_icon:show()
		self.item_price_icon:setImage(i3k_db.i3k_db_get_icon_path(currency_icon[1]))  --元宝图标
	elseif self.sendcommond.free == e_Type_vip_store_hongli then
		self.item_price_lock_icon:hide()
		self.item_price_icon:setImage(i3k_db.i3k_db_get_icon_path(currency_icon[2]))  --红利图标
	elseif self.sendcommond.free == e_Type_vip_store_longhun then
		self.item_price_lock_icon:hide()
		self.item_price_icon:setImage(i3k_db.i3k_db_get_icon_path(currency_icon[3]))  --龙魂币图标
	end
	self.item_price:setText(self.item.finalprice);
	for k, v in pairs(propertyTb) do
		local des = require(LAYER_ZBTIPST)()
		local _t = i3k_db_prop_id[k]
		local _desc = _t.desc
		_desc = _desc.." :"
		des.vars.desc:setText(_desc)
		--des.vars.desc:setTextColor(_t.textColor)
		des.vars.value:setText(i3k_get_prop_show(k,v))
		--des.vars.value:setTextColor(_t.valuColor)
		self.scroll:addItem(des)
	end

	self:setDynamicEffect(cfg.args1, METAMORPHOSIS_TYPE)
	self._layout.vars.liulan_btn:onClick(self,self.onShowMetamorphosisBtn,cfg.args1)
	self.scroll:stateToNoSlip()
	self:onShowMetamorphosisBtn(self)
end

function vip_store_fashion_buy:onShowMetamorphosisBtn(sender)
	local cfg = i3k_db_metamorphosis[self.showingFashionId]
	
	local showAct = cfg and cfg.showAction
	if not showAct then return; end
	local changeID = cfg.changeID
	local modelID = i3k_db_missionmode_cfg[changeID].modelId
	ui_set_hero_model(self.hero_module, self.hero, modelID)
	for i, v in ipairs(showAct) do
		self.hero_module:pushActionList(v)
	end
	self.hero_module:playActionList()
end

--okButton
function vip_store_fashion_buy:okMetamorphosisButton(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local fashion = g_i3k_db.i3k_db_get_other_item_cfg(self.item.iid)
		if g_i3k_game_context:GetCommonItemCanUseCount(self.item.iid) > 0 or g_i3k_db.i3k_db_get_metamorphosis_is_have(fashion.args1) then
			local callback = (function(isOk)
				if isOk then
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_VIP_STROE_FASHION_BUY, "buyFashion")
				end
			end)
			g_i3k_ui_mgr:ShowCustomMessageBox2("确定", "取消", "您已拥有此幻形，是否继续购买？", callback)
			return
		end
		self:buyFashion()
	end
end


-------------------幻形end--------------------
function vip_store_fashion_buy:onShow()

end

function vip_store_fashion_buy:onHide()

end

function wnd_create(layout, ...)
	local wnd = vip_store_fashion_buy.new()
	wnd:create(layout, ...)
	return wnd
end
