------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require("ui/vip_store_buy_base")
------------------------------------------------------
wnd_vip_store_homeland = i3k_class("wnd_vip_store_homeland", ui.wnd_vip_store_buy_base)

local e_Type_vip_store_yuanbao = 1
local e_Type_vip_store_bangyuan = 0
local e_Type_vip_store_hongli = 3
local e_Type_vip_store_longhun = 4
local currency = 
{
	[e_Type_vip_store_yuanbao] = -g_BASE_ITEM_DIAMOND,
	[e_Type_vip_store_bangyuan] = g_BASE_ITEM_DIAMOND,
	[e_Type_vip_store_hongli] = g_BASE_ITEM_DIVIDEND,
	[e_Type_vip_store_longhun] = g_BASE_ITEM_DRAGON_COIN,
}

function wnd_vip_store_homeland:ctor()
	self.sendcommond = {}
	self.item = {}
end

function wnd_vip_store_homeland:configure()
	self._layout.vars.cancel:onClick(self, self.onCloseUI)
	self._layout.vars.ok:onClick(self, self.onBuyBtn)
end

function wnd_vip_store_homeland:refresh(buy, item)
	self.sendcommond = buy
	self.item = item
	local itemname = "";
	itemname = i3k_db.i3k_db_get_common_item_name(self.item.iid)
	self.sendcommond.itemname = itemname
	if self.item.icount > 1 then
		itemname = itemname.."*"..self.item.icount
	end
	self:setFurniture()
end

function wnd_vip_store_homeland:setFurniture()
	local itemId = self.item.iid
	local furniture = g_i3k_db.i3k_db_get_furniture_data(i3k_db_new_item[itemId].args1, i3k_db_new_item[itemId].args2)
	local widget = self._layout.vars
	--widget.furniture_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemId))
	widget.furniture_desc:setText(g_i3k_db.i3k_db_get_common_item_desc(itemId))
	widget.furniture_level:setText(string.format("家俱等级：%s", furniture.level))
	widget.limit_count:setText(string.format("摆放数量：%s", furniture.limitCount))
	widget.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemId))
	widget.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemId)))
	widget.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
	widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId))
	widget.item_icon_lock:setVisible(itemId > 0)
	widget.item_price_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(currency[self.sendcommond.free]))
	widget.item_price_lock_icon:setVisible(self.sendcommond.free == e_Type_vip_store_bangyuan)
	widget.item_price:setText(self.sendcommond.price)
	local pos = widget.hero_module:getPosition()
	widget.hero_module:setPosition(pos.x, furniture.storeHeight)
	ui_set_hero_model(widget.hero_module, furniture.models[1])
	widget.hero_module:setCameraAngle(furniture.angle.x, furniture.angle.y, furniture.angle.z)
end

function wnd_vip_store_homeland:onBuyBtn(sender)
	self:buyItem()
end

-------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_vip_store_homeland.new()
		wnd:create(layout,...)
	return wnd
end
