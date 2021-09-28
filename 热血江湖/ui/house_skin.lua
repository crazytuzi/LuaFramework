------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require("ui/base")
------------------------------------------------------
wnd_house_skin = i3k_class("wnd_house_skin", ui.wnd_base)

local SKINWIDGET = "ui/widgets/jiayuanzbt"

function wnd_house_skin:ctor()
	self._curViewSkin = 1
end

function wnd_house_skin:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
end

function wnd_house_skin:refresh()
	local houseInfo = g_i3k_game_context:getHomeLandHouseInfo()
	self._curViewSkin = houseInfo.homeland.curSkin
	self:setSkinScroll()
end

function wnd_house_skin:setSkinScroll()
	self._layout.vars.scroll:removeAllChildren()
	local houseInfo = g_i3k_game_context:getHomeLandHouseInfo()
	for k, v in pairs(i3k_db_home_land_house_skin) do
		local node = require(SKINWIDGET)()
		node.vars.bgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.itemId))
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.itemId))
		node.vars.usingIcon:setVisible(houseInfo.homeland.curSkin == k)
		node.vars.name:setText(g_i3k_db.i3k_db_get_common_item_name(v.itemId))
		node.vars.isOwned:setText(g_i3k_game_context:isHaveHouseSkin(k) and "已拥有" or "未拥有")
		node.vars.btn:onClick(self, self.onChangeSkin, k)
		self._layout.vars.scroll:addItem(node)
	end
end

function wnd_house_skin:onChangeSkin(sender, id)
	self._curViewSkin = id
	local houseInfo = g_i3k_game_context:getHomeLandHouseInfo()
	if id ~= houseInfo.homeland.curSkin then
		g_i3k_ui_mgr:ShowCommonItemInfo(i3k_db_home_land_house_skin[id].itemId)
	end
	local world = i3k_game_get_world()
	if world then
		world:ChangeHouseSkin(id)
	end
end

function wnd_house_skin:onHide()
	local houseInfo = g_i3k_game_context:getHomeLandHouseInfo()
	if houseInfo then
		if self._curViewSkin ~= houseInfo.homeland.curSkin then
			local world = i3k_game_get_world()
			if world then
				world:ChangeHouseSkin(houseInfo.homeland.curSkin)
			end
		end
	end
end

-------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_house_skin.new()
	wnd:create(layout,...)
	return wnd
end
