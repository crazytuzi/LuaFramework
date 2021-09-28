
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_queryRoleRuneLangAttr = i3k_class("wnd_queryRoleRuneLangAttr",ui.wnd_base)

local TITLE_ITEM = "ui/widgets/fwzytipst1"
function wnd_queryRoleRuneLangAttr:ctor()

end

function wnd_queryRoleRuneLangAttr:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
end

function wnd_queryRoleRuneLangAttr:refresh(index, lvl, langName, zhudingLv)
	local widg = self._layout.vars
	local attr = g_i3k_db.i3k_db_get_rune_lang_attr(index, lvl)

	widg.scroll:removeAllChildren()
	local header_1 = require(TITLE_ITEM)()
	header_1.vars.desc:setText(langName)
	widg.scroll:addItem(header_1)	
	local powerTab = {}
	for i =1 , #attr do
		local attrId = attr[i].id
		local attrValue = attr[i].value
		if attrId~=0 then
			local node = require("ui/widgets/fwzytipst")()
			local widget = node.vars
			widget.value:setText("+".. i3k_get_prop_show(attrId,attrValue))
			widget.desc:setText(i3k_db_prop_id[attrId].desc)
	        widget.icon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(attrId)))
			widg.scroll:addItem(node)
			powerTab[attrId] = attrValue
		end
	end
	if zhudingLv > 0 then
		local header_2 = require(TITLE_ITEM)()
		header_2.vars.desc:setText(i3k_get_string(18309, zhudingLv))
		widg.scroll:addItem(header_2)
		for i,v in ipairs(i3k_db_rune_zhuDing[index][zhudingLv].attribute) do
			local attrId = v.id
			local attrValue = v.value
			if attrId ~= 0 then
				local node = require("ui/widgets/fwzytipst")()
				local widget = node.vars
				widget.value:setText("+"..i3k_get_prop_show(attrId,attrValue))
				widget.desc:setText(i3k_db_prop_id[attrId].desc)
				widget.icon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(attrId)))
				widg.scroll:addItem(node)
				powerTab[attrId] = powerTab[attrId] and powerTab[attrId] + attrValue or attrValue
			end
		end
	end
	local power = g_i3k_db.i3k_db_get_battle_power(powerTab,true)
	widg.battle_power:setText(power)
end

function wnd_create(layout, ...)
	local wnd = wnd_queryRoleRuneLangAttr.new()
	wnd:create(layout, ...)
	return wnd;
end

