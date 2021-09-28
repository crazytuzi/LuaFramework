-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_blood_pool = i3k_class("wnd_blood_pool", ui.wnd_base)

local XCTST_WIDGETS = "ui/widgets/xctst"

function wnd_blood_pool:ctor()

end

function wnd_blood_pool:configure()
	local widgets = self._layout.vars
	
	self.desc = widgets.desc
	self.scroll = widgets.scroll
	self.hpText1 = widgets.hpText1
	self.hpText2 = widgets.hpText2
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_blood_pool:refresh()
	self:loadScroll()
	local hpUpper = i3k_round(i3k_db_common.drug.viplimited/10000)
	local hero = i3k_game_get_player_hero()
	if hero then
		local HPIncrease = hero:GetPropertyValue(ePropID_MeridianHPIncrease)
		local HPUpper = hero:GetPropertyValue(ePropID_MeridianHPUpper)
		self.hpText1:hide()
		self.hpText2:hide()
		if HPIncrease > 0 then
			self.hpText1:show():setText(i3k_get_string(1162,i3k_round(HPIncrease*100)))
		end
		if HPUpper > 0 then
			local HPUpper = i3k_round(HPUpper/10000)
			hpUpper = hpUpper + HPUpper
			self.hpText2:show():setText(i3k_get_string(1163,HPUpper))
		end
	end
	self.desc:setText(i3k_get_string(211, g_i3k_game_context:GetVipBloodPool(), hpUpper))
end

function wnd_blood_pool:loadScroll()
	self.scroll:removeAllChildren()
	for _, v in ipairs(self:sortItems()) do
		local dbCfg = v.cfg
		local id = v.id
		local node = require(XCTST_WIDGETS)()
		local widget = node.vars
		local icon = g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole())
		local count = g_i3k_game_context:GetCommonItemCount(id)
		widget.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		widget.item_icon:setImage(icon)
		widget.item_count:setText("x"..count)
		widget.suo:setVisible(id > 0)
		widget.item_count:setTextColor(g_i3k_get_cond_color(count > 0))
		widget.item_value:setText(i3k_get_num_to_show(dbCfg.args1))
		widget.bt:onClick(self, self.onItemTips, {id = id, count = count})
		self.scroll:addItem(node)
	end
end

--排序
function wnd_blood_pool:sortItems()
	local db = {}
	local items = {}
	local _, bagItems = g_i3k_game_context:GetBagInfo()
	for k, v in pairs(bagItems) do --先排背包里有的血池类道具
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(k)
		if cfg and cfg.type == UseItemVipHp then
			items[k] = v
			local order = cfg.args1
			local count = g_i3k_game_context:GetCommonItemCount(k)
			if count > 0 then
				order = order + 10^8
			end
			table.insert(db, {id = k, cfg = cfg, order = order})
		end
	end
	for k, v in pairs(i3k_db_new_item) do
		if v.type == UseItemVipHp and not items[k] and not items[-k] then
			local order = v.args1
			table.insert(db, {id = k, cfg = g_i3k_db.i3k_db_get_other_item_cfg(k), order = order})
		end
	end
	table.sort(db, function (a,b)
		return a.order > b.order
	end)
	return db
end

function wnd_blood_pool:onItemTips(sender, data)
	if data.count > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_BagItemInfo)
		g_i3k_ui_mgr:RefreshUI(eUIID_BagItemInfo, data.id)
	elseif i3k_game_get_map_type() == g_FIELD then
		g_i3k_ui_mgr:ShowCommonItemInfo(data.id)
	end
end

function wnd_create(layout)
	local wnd = wnd_blood_pool.new()
	wnd:create(layout)
	return wnd
end
