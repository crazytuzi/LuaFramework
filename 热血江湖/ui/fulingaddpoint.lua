-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_fulingAddPoint = i3k_class("wnd_fulingAddPoint", ui.wnd_base)

function wnd_fulingAddPoint:ctor()

end

function wnd_fulingAddPoint:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)


end

function wnd_fulingAddPoint:refresh(id)
	self._id = id
	self:setItemUI(id)
	self:setScrollCurrent(id)
	-- self:setScrollNext(id)
end

-- InvokeUIFunction
function wnd_fulingAddPoint:refreshWithoutID()
	self:refresh(self._id)
end

function wnd_fulingAddPoint:setItemUI(id)
	local widgets = self._layout.vars
	-- local itemID = 1
	local points = g_i3k_game_context:getWuxingPoint(id)
	local curLevel = g_i3k_game_context:getFulingCurLevel()
	local upLimitPoints = g_i3k_db.i3k_db_get_fuling_upLimit_points(curLevel - 1)
	-- widgets.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemID))
	-- widgets.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemID))
	-- widgets.item_btn:onClick(self, self.onItemTips, itemID)
	local iconID = i3k_db_longyin_sprite_addPoint[id][1].icon
	widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(iconID))

	local name = i3k_db_longyin_sprite_addPoint[id][1].name
	widgets.name:setText(name)
	widgets.curPoints:setText("当前加点："..points.."/"..upLimitPoints)
	widgets.upLvlBtn:onClick(self, self.onAddPoint, id)


	local index = g_i3k_db.i3k_db_get_wuxing_pre_index(id)
	local data = self:getShowData(index)
	local whoBornWhoID = g_i3k_db.i3k_db_get_wuxing_index(index, #i3k_db_longyin_sprite_addPoint)
	local shengName = i3k_db_longyin_sprite_born[whoBornWhoID][1].name
	widgets.des:setText(shengName.."-"..data.cur)
end

-- id = 0,初始， id = #list 满级了
function wnd_fulingAddPoint:getShowData(id)
	local cfgID = g_i3k_db.i3k_db_get_wuxing_index(id, #i3k_db_longyin_sprite_addPoint)
	local cfg = i3k_db_longyin_sprite_born[cfgID]
	local points = g_i3k_game_context:getXiangshengPoint(cfgID)

	if points == 0 then
		return { cur = "无", next = cfg[points + 1].effectDesc, consumes = cfg[points + 1].consumes, forwardCount = cfg[points + 1].forwardCount}
	end
	if not cfg[points + 1] then
		return { cur = cfg[points].effectDesc, next = "无", consumes = {}, forwardCount = 0}
	end

	return {cur = cfg[points].effectDesc, next = cfg[points + 1].effectDesc, consumes = cfg[points + 1].consumes, forwardCount = cfg[points + 1].forwardCount}
end

function wnd_fulingAddPoint:setScrollCurrent(id)
	local widgets = self._layout.vars
	local scroll = widgets.scroll1
	scroll:removeAllChildren()
	local points = g_i3k_game_context:getWuxingPoint(id)
	local props = g_i3k_db.i3k_db_get_wuxing_props(id, points)
	local sortProps = g_i3k_db.i3k_db_sort_props(props)

	local nextPoints = g_i3k_game_context:getWuxingPoint(id)
	local nextProps = g_i3k_db.i3k_db_get_wuxing_next_level_props(id, nextPoints)

	for k, v in ipairs(sortProps) do
		local ui = require("ui/widgets/lyfljdt")()
		ui.vars.icon:setImage(g_i3k_db.i3k_db_get_property_icon_path(v.id)) -- 属性图标
		ui.vars.name:setText(i3k_db_prop_id[v.id].desc)
		ui.vars.attr:setText(i3k_get_prop_show(v.id ,v.value))
		if nextProps[v.id] then
			if nextProps[v.id] - v.value ~= 0 then
				ui.vars.count2:setText("+"..(nextProps[v.id] - v.value))
			else
				ui.vars.count2:hide()
			end
		else
			ui.vars.count2:hide()
		end
		scroll:addItem(ui)
	end

	local minProps = g_i3k_db.i3k_db_get_props_min(props, nextProps)
	local sortMinProps = g_i3k_db.i3k_db_sort_props(minProps)
	for k, v in ipairs(sortMinProps) do
		local ui = require("ui/widgets/lyfljdt")()
		ui.vars.icon:setImage(g_i3k_db.i3k_db_get_property_icon_path(v.id)) -- 属性图标
		ui.vars.name:setText(i3k_db_prop_id[v.id].desc)
		ui.vars.attr:setText("0")
		if v.value ~= 0 then
			ui.vars.count2:setText("+"..i3k_get_prop_show(v.id, v.value))
		else
			ui.vars.count2:hide()
		end
		scroll:addItem(ui)
	end

end

-- function wnd_fulingAddPoint:setScrollNext(id)
-- 	local widgets = self._layout.vars
-- 	local scroll = widgets.scroll2
-- 	scroll:removeAllChildren()
-- 	local points = g_i3k_game_context:getWuxingPoint(id)
-- 	local props = g_i3k_db.i3k_db_get_wuxing_next_level_props(id, points)
-- 	local sortProps = g_i3k_db.i3k_db_sort_props(props)
-- 	for k, v in ipairs(sortProps) do
-- 		local ui = require("ui/widgets/lyfljdt")()
-- 		ui.vars.icon:setImage(g_i3k_db.i3k_db_get_property_icon_path(v.id)) -- 属性图标
-- 		ui.vars.name:setText(i3k_db_prop_id[v.id].desc)
-- 		ui.vars.attr:setText(i3k_get_prop_show(v.id ,v.value))
-- 		scroll:addItem(ui)
-- 	end
-- end

-- 投入一点
function wnd_fulingAddPoint:onAddPoint(sender, id)
	local usedPoints = g_i3k_game_context:getWuxingUsedPoints()
	local allPoints = g_i3k_game_context:getWuxingAllCount()
	if allPoints - usedPoints <= 0 then
		g_i3k_ui_mgr:PopupTipMessage("剩余点数不足")
		return
	end
	local points = g_i3k_game_context:getWuxingPoint(id)
	local curLevel = g_i3k_game_context:getFulingCurLevel()
	local upLimitPoints = g_i3k_db.i3k_db_get_fuling_upLimit_points(curLevel - 1)
	local name = i3k_db_longyin_sprite_addPoint[id][1].name
	if points >= upLimitPoints then
		g_i3k_ui_mgr:PopupTipMessage(name.."已经到达加点上限")
		return
	end

	i3k_sbean.fulingAddPoint(id, 1)
end

function wnd_fulingAddPoint:onItemTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_create(layout, ...)
	local wnd = wnd_fulingAddPoint.new()
	wnd:create(layout, ...)
	return wnd;
end
