------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require("ui/base")
------------------------------------------------------
wnd_house_furniture = i3k_class("wnd_house_furniture",ui.wnd_base)

local JJBFWIDGET = "ui/widgets/jiayuanjjbft1"
local JIAJUWIDGET = "ui/widgets/jiayuanjjbft2"

function wnd_house_furniture:ctor()
	self._isPlace = false
	self._index = 1
	self._furnitures = {}
	self._furnitureType = nil
end

function wnd_house_furniture:configure()
	self._layout.vars.place_btn:onClick(self, self.onPlaceBtn)
	self._layout.vars.cancel_btn:onClick(self, self.onCancelBtn)
	self._layout.vars.leave_btn:onClick(self, self.onLeaveBtn)
	self._layout.vars.hide_btn:onClick(self, self.onCloseUI)  
	self._layout.vars.addtionbt:onClick(self, self.onaddtionBtn)  
end

function wnd_house_furniture:refresh()
	self._layout.vars.furniture_root:hide()
	self._layout.vars.scroll_root:show()
	self._layout.vars.place_btn:disableWithChildren()
	self._layout.vars.cancel_btn:disableWithChildren()
	self:setFurnitureInfo()
	self:updateFurnitureType()
end

function wnd_house_furniture:setFurnitureInfo()
	self._furnitures = {}
	for k, v in pairs(g_i3k_db.i3k_db_get_all_furniture()) do
		for i, j in pairs(v) do
			if j.type ~= 999 then
				if not self._furnitures[j.type] then
					self._furnitures[j.type] = {}
				end
				table.insert(self._furnitures[j.type], {placeType = k, id = i, itemId = j.itemId})
			end
		end
	end
end

function wnd_house_furniture:updateFurnitureType()
	self._layout.vars.title_scroll:removeAllChildren()
	self._layout.vars.title_scroll:setAlignMode(g_UIScrollList_HORZ_ALIGN_LEFT)
	local title_sort = {}
	for k, _ in pairs(self._furnitures) do
		table.insert(title_sort, {sortId = k})
	end
	table.sort(title_sort, function(a, b)
		return a.sortId < b.sortId
	end)
	for _, v in ipairs(title_sort) do
		local node = require(JJBFWIDGET)()
		node.vars.type_btn:stateToNormal(true)
		node.vars.name:setTextColor("ffebc6b4")
		node.vars.name:enableOutline("ff91634a")
		if not self._furnitureType then
			self._furnitureType = v.sortId
			node.vars.type_btn:stateToPressed()
			node.vars.name:setTextColor("ff8d5328")
			node.vars.name:enableOutline("ffefdbbf")
		end
		node.vars.type_btn:onClick(self, self.onChangeType, v.sortId)
		node.vars.type_btn:setTag(v.sortId)
		node.vars.name:setText(i3k_db_home_land_produce_name[v.sortId])
		self._layout.vars.title_scroll:addItem(node)
	end
	self:updateFurnitureScroll()
end

function wnd_house_furniture:onChangeType(sender, furnitureType)
	if self._furnitureType ~= furnitureType then
		self._furnitureType = furnitureType
		local children = self._layout.vars.title_scroll:getAllChildren()
		for k, v in ipairs(children) do
			if v.vars.type_btn:getTag() == furnitureType then
				v.vars.type_btn:stateToPressed(true)
				v.vars.name:setTextColor("ff8d5328")
				v.vars.name:enableOutline("ffefdbbf")
			else
				v.vars.type_btn:stateToNormal(true)
				v.vars.name:setTextColor("ffebc6b4")
				v.vars.name:enableOutline("ff91634a")
			end
		end
		self:updateFurnitureScroll()
	end
end

function wnd_house_furniture:updateFurnitureScroll()
	self._layout.vars.furniture_root:hide()
	self:cancelChooseFurniture()
	local logic = i3k_game_get_logic()
	if logic then
		local world = logic:GetWorld()
		world:RemoveChooseFurniture()
	end
	self._layout.vars.furniture_scroll:removeAllChildren()
	self._layout.vars.furniture_scroll:setAlignMode(g_UIScrollList_HORZ_ALIGN_LEFT)
	for k, v in ipairs(self._furnitures[self._furnitureType]) do
		v.sortId = g_i3k_db.i3k_db_get_common_item_rank(v.itemId) * 1000 - v.id
		if g_i3k_game_context:isHaveFurnitureById(v.placeType, v.id) > 0 then
			v.sortId = 10000 + g_i3k_db.i3k_db_get_common_item_rank(v.itemId) * 1000 - v.id
		end
	end
	table.sort(self._furnitures[self._furnitureType], function(a, b)
		return a.sortId > b.sortId
	end)
	for k, v in ipairs(self._furnitures[self._furnitureType]) do
		local node = require(JIAJUWIDGET)()
		node.vars.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.itemId))
		node.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.itemId, g_i3k_game_context:IsFemaleRole()))
		node.vars.choose_icon:hide()
		node.vars.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(v.itemId))
		node.vars.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(v.itemId)))
		node.vars.item_count:setText(string.format("x%d", g_i3k_game_context:isHaveFurnitureById(v.placeType, v.id) or 0))
		node.vars.item_btn:onClick(self, self.onChooseFurniture, k)
		self._layout.vars.furniture_scroll:addItem(node)
	end
end

function wnd_house_furniture:onChooseFurniture(sender, index)
	local logic = i3k_game_get_logic()
	if logic then
		local world = logic:GetWorld()
		world._curMoveFurniture = nil
		world:RemoveChooseFurniture()
	end
	local children = self._layout.vars.furniture_scroll:getAllChildren()
	for k, v in ipairs(children) do
		if k == index then
			v.vars.choose_icon:show()
		else
			v.vars.choose_icon:hide()
		end
	end
	self._index = index
	self._isPlace = false
	self._layout.vars.place_text:setText("提取")
	self._layout.vars.cancel_text:setText("摆放")
	self:showFurniturePlace(self._furnitures[self._furnitureType][self._index].itemId)
end

function wnd_house_furniture:showFurniturePlace(itemId)
	local itemCfg = i3k_db_new_item[itemId]
	local info = g_i3k_db.i3k_db_get_all_furniture()
	local level = info[itemCfg.args1][itemCfg.args2].level
	local count = info[itemCfg.args1][itemCfg.args2].limitCount
	local build = info[itemCfg.args1][itemCfg.args2].builtPoint
	self._layout.vars.furniture_root:show()
	self._layout.vars.furniture_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
	self._layout.vars.furniture_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId, g_i3k_game_context:IsFemaleRole()))
	self._layout.vars.furniture_desc:setText(i3k_get_string(17425, level, count, build))
	self._layout.vars.furniture_name:setText(g_i3k_db.i3k_db_get_common_item_name(itemId))
	self._layout.vars.furniture_name:setTextColor(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
	self._layout.vars.place_btn:enableWithChildren()
	self._layout.vars.cancel_btn:enableWithChildren()
	self._layout.vars.addtionbt:disableWithChildren()
end

function wnd_house_furniture:onPlaceBtn(sender)
	if self._isPlace then
		--移除
		local logic = i3k_game_get_logic()
		if logic then
			local world = logic:GetWorld()
			world:RemovePlacedFurniture(self._chooseFurniture.guid, self._chooseFurniture.furnitureType)
		end
	else
		--提取
		local furniture = self._furnitures[self._furnitureType][self._index]
		if g_i3k_game_context:isHaveFurnitureById(furniture.placeType, furniture.id) > 0 then
			i3k_sbean.furniture_bag_get(furniture.id, 1, furniture.placeType)
		else
			g_i3k_ui_mgr:PopupTipMessage("该物品不足")
		end
	end
end

function wnd_house_furniture:onCancelBtn(sender)
	if self._isPlace then
		--调整
		if self._chooseFurniture.furnitureType == g_HOUSE_FLOOR_FURNITURE then
			local furnitureId = self._chooseFurniture.furnitureId
			local furniture = {placeType = g_HOUSE_FLOOR_FURNITURE, id = furnitureId, itemId = i3k_db_home_land_floor_furniture[furnitureId].itemId}
			g_i3k_ui_mgr:OpenUI(eUIID_HouseFurnitureSet)
			g_i3k_ui_mgr:RefreshUI(eUIID_HouseFurnitureSet, furniture)
			self._layout.vars.furniture_root:hide()
			self._layout.vars.scroll_root:hide()
			local logic = i3k_game_get_logic()
			if logic then
				local world = logic:GetWorld()
				world:MovePlacedFurniture(i3k_clone(self._chooseFurniture))
			end
		elseif self._chooseFurniture.furnitureType == g_HOUSE_WALL_FURNITURE then
			local furnitureId = self._chooseFurniture.id
			local furniture = {placeType = g_HOUSE_WALL_FURNITURE, id = furnitureId, itemId = i3k_db_home_land_wall_furniture[furnitureId].itemId}
			g_i3k_ui_mgr:OpenUI(eUIID_HouseFurnitureSet)
			g_i3k_ui_mgr:RefreshUI(eUIID_HouseFurnitureSet, furniture)
			self._layout.vars.furniture_root:hide()
			self._layout.vars.scroll_root:hide()
			local logic = i3k_game_get_logic()
			if logic then
				local world = logic:GetWorld()
				world:MovePlacedFurniture(i3k_clone(self._chooseFurniture))
			end
		elseif self._chooseFurniture.furnitureType == g_HOUSE_CARPET_FURNITURE then
			local furnitureId = self._chooseFurniture.furnitureId
			local furniture = {placeType = g_HOUSE_CARPET_FURNITURE, id = furnitureId, itemId = i3k_db_home_land_carpet_furniture[furnitureId].itemId}
			g_i3k_ui_mgr:OpenUI(eUIID_HouseFurnitureSet)
			g_i3k_ui_mgr:RefreshUI(eUIID_HouseFurnitureSet, furniture)
			self._layout.vars.furniture_root:hide()
			self._layout.vars.scroll_root:hide()
			local logic = i3k_game_get_logic()
			if logic then
				local world = logic:GetWorld()
				world:MovePlacedFurniture(i3k_clone(self._chooseFurniture))
			end
		else
			g_i3k_ui_mgr:PopupTipMessage("该家俱不支持移动")
		end
	else
		--摆放
		local furniture = self._furnitures[self._furnitureType][self._index]
		if g_i3k_game_context:isHaveFurnitureById(furniture.placeType, furniture.id) > 0 then
			local logic = i3k_game_get_logic()
			if logic then
				local world = logic:GetWorld()
				if world then
					if world:isPlacedMaxCount(furniture.placeType, furniture.id) then
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17431))
						return
					end
					if furniture.placeType == g_HOUSE_FLOOR_FURNITURE then
						if i3k_db_home_land_house[g_i3k_game_context:getCurHouseLevel()].furnitureMaxLvl >= i3k_db_home_land_floor_furniture[furniture.id].level then
							world:CreateFloorFurnitureSpace(furniture.id, g_HOUSE_FLOOR_FURNITURE)
							g_i3k_ui_mgr:OpenUI(eUIID_HouseFurnitureSet)
							g_i3k_ui_mgr:RefreshUI(eUIID_HouseFurnitureSet, furniture)
							self._layout.vars.furniture_root:hide()
							self._layout.vars.scroll_root:hide()
						else
							g_i3k_ui_mgr:PopupTipMessage("房屋等级过低")
						end
					elseif furniture.placeType == g_HOUSE_WALL_FURNITURE then
						if i3k_db_home_land_house[g_i3k_game_context:getCurHouseLevel()].furnitureMaxLvl >= i3k_db_home_land_wall_furniture[furniture.id].level then
							if world:CreateWallFurnitureSpace(furniture.id, furniture) then
								self._layout.vars.furniture_root:hide()
								self._layout.vars.scroll_root:hide()
							end
						else
							g_i3k_ui_mgr:PopupTipMessage("房屋等级过低")
						end
					elseif furniture.placeType == g_HOUSE_CARPET_FURNITURE then
						if i3k_db_home_land_house[g_i3k_game_context:getCurHouseLevel()].furnitureMaxLvl >= i3k_db_home_land_carpet_furniture[furniture.id].level then
							world:CreateFloorFurnitureSpace(furniture.id, g_HOUSE_CARPET_FURNITURE)
							g_i3k_ui_mgr:OpenUI(eUIID_HouseFurnitureSet)
							g_i3k_ui_mgr:RefreshUI(eUIID_HouseFurnitureSet, furniture)
							self._layout.vars.furniture_root:hide()
							self._layout.vars.scroll_root:hide()
						else
							g_i3k_ui_mgr:PopupTipMessage("房屋等级过低")
						end
					else
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5348))
					end
				end
			end
		else
			g_i3k_ui_mgr:PopupTipMessage("没有此种家俱")
		end
	end
end

--在场景里选中家具调用
function wnd_house_furniture:setChooseFurniture(guid, furniture, furnitureType)
	local weight = self._layout.vars
	self._chooseFurniture = furniture
	self._chooseFurniture.guid = guid
	self._chooseFurniture.furnitureType = furnitureType
	self._isPlace = true
	weight.place_text:setText("移除")
	weight.cancel_text:setText("调整")
	if furnitureType == g_HOUSE_FLOOR_FURNITURE then
		self:showFurniturePlace(i3k_db_home_land_floor_furniture[furniture.furnitureId].itemId)
	elseif furnitureType == g_HOUSE_WALL_FURNITURE then
		self:showFurniturePlace(i3k_db_home_land_wall_furniture[furniture.id].itemId)
	elseif furnitureType == g_HOUSE_CARPET_FURNITURE then
		self:showFurniturePlace(i3k_db_home_land_carpet_furniture[furniture.furnitureId].itemId)
	end
	if g_i3k_game_context:isCanAdditionFurniture(furnitureType, furniture.furnitureId) then
		weight.addtionbt:enableWithChildren()
	else
		weight.addtionbt:disableWithChildren()
	end
end

function wnd_house_furniture:cancelChooseFurniture()
	self._chooseFurniture = {}
	self._isPlace = false
	self._layout.vars.place_text:setText("提取")
	self._layout.vars.cancel_text:setText("摆放")
end

function wnd_house_furniture:onLeaveBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_HouseBase)
	g_i3k_ui_mgr:RefreshUI(eUIID_HouseBase)
	self:onCloseUI()
end

function wnd_house_furniture:showScroll()
	self._layout.vars.scroll_root:show()
	self._layout.vars.furniture_root:show()
end

function wnd_house_furniture:updateFurnitureInfo()
	self:updateFurnitureScroll()
	self:onChooseFurniture(nil, self._index)
end

function wnd_house_furniture:onHide()
	local logic = i3k_game_get_logic()
	if logic then
		local world = logic:GetWorld()
		world:ChangeCurMoveFloor(true)
		world:RemoveChooseFurniture()
	end
	g_i3k_game_context:setIsInPlaceState(false)
end

function wnd_house_furniture:onaddtionBtn()
	local world = i3k_game_get_world()
	if world then
		local index = world:GetFurnitureIndex(self._chooseFurniture.guid, self._chooseFurniture.furnitureType)
		if index then
			local entity = world:GetEntity(eET_Furniture, world._furnitureList[g_HOUSE_FLOOR_FURNITURE][index])
			if entity and entity._curMountFurniture then
				g_i3k_ui_mgr:PopupTipMessage("已经挂载家俱了")
				return
			end
			local isHave = false
			for k, v in ipairs(i3k_db_home_land_hang_furniture) do
				local num = g_i3k_game_context:isHaveFurnitureById(g_HOUSE_HANG_FURNITURE, k)
				if num > 0 then
					isHave = true
				end
			end
			if not isHave then
				g_i3k_ui_mgr:PopupTipMessage("没有挂载家俱了")
				return
			end
			g_i3k_logic:OpenHomelandAdditionUI(index, self._chooseFurniture.furnitureId)
		end
	end
	self:onCloseUI()
end

-------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_house_furniture.new()
	wnd:create(layout,...)
	return wnd
end
