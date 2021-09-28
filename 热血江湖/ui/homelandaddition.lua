------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require("ui/base")
------------------------------------------------------
wnd_homelandAddition = i3k_class("wnd_homelandAddition", ui.wnd_base)

function wnd_homelandAddition:ctor()
	self._curChooseFur = nil
	self._curFurnitureIndex = 0
	self._floorFurnitureId = 0
end

function wnd_homelandAddition:configure()
	local weight = self._layout.vars
	weight.cancel:onClick(self, self.onCloseUI) 
	weight.ok:onClick(self, self.onOKBt) 
end

function wnd_homelandAddition:refresh(index, furnitureId)
	self._curFurnitureIndex = index
	self._floorFurnitureId = furnitureId
	local weight = self._layout.vars
	weight.desc:setText(i3k_get_string(5349))
	self._layout.vars.itemScoll:removeAllChildren()
	local houseBag = g_i3k_game_context:getCurHouseBag()
	if houseBag then
		local children = self._layout.vars.itemScoll:addChildWithCount("ui/widgets/jiayuanjjgzt", 4, table.nums(houseBag.additionFurniture), true)
		local childIndex = 1
		for k, v in pairs(houseBag.additionFurniture) do
			local item = children[childIndex].vars
			local hangInfo = i3k_db_home_land_hang_furniture[k]
			item.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(hangInfo.itemId))
			item.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(hangInfo.itemId, g_i3k_game_context:IsFemaleRole()))
			item.choose_icon:hide()
			item.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(hangInfo.itemId))
			item.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(hangInfo.itemId)))
			item.item_count:setText(string.format("x%d", v))
			item.item_btn:onClick(self, self.onChooseFurBt, {node = item, id = k})
			childIndex = childIndex + 1
		end
	end
end

function wnd_homelandAddition:onChooseFurBt(sender, chooseItem)
	if self._curChooseFur and self._curChooseFur.node then
		self._curChooseFur.node.choose_icon:hide()
	end
	
	self._curChooseFur = chooseItem
	chooseItem.node.choose_icon:show()
end

function wnd_homelandAddition:onOKBt()
	if not self._curChooseFur then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5366))
		return
	end
	local isCanPut = false
	for _, v in ipairs(i3k_db_home_land_floor_furniture[self._floorFurnitureId].hangon) do
		if v == self._curChooseFur.id then
			isCanPut = true
			break
		end
	end
	if isCanPut then
		local fun = function(ok)
			if ok then
				i3k_sbean.addition_furniture_put(self._curChooseFur.id, self._curFurnitureIndex)
				self:onCloseUI()
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(5367), fun)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5348))
	end
end

-------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_homelandAddition.new()
	wnd:create(layout,...)
	return wnd
end