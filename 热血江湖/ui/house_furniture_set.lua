------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require("ui/base")
------------------------------------------------------
wnd_house_furniture_set = i3k_class("wnd_house_furniture_set",ui.wnd_base)

function wnd_house_furniture_set:ctor()
	self._placeType = 0
end

function wnd_house_furniture_set:configure()
	local widget = self._layout.vars
	widget.leave_btn:onClick(self, self.onLeaveBtn)
	widget.cancel_btn:onClick(self, self.onCancelBtn)
	widget.save_btn:onClick(self, self.onSaveBtn)
	widget.turn_left_btn:onClick(self, self.onTurnBtn, 1)
	widget.turn_right_btn:onClick(self, self.onTurnBtn, 2)
	widget.right_btn:onClick(self, self.onMoveBtn, 2)
	widget.left_btn:onClick(self, self.onMoveBtn, 1)
	widget.down_btn:onClick(self, self.onMoveBtn, 4)
	widget.up_btn:onClick(self, self.onMoveBtn, 3)
end

function wnd_house_furniture_set:refresh(furniture)
	self._placeType = furniture.placeType
end

function wnd_house_furniture_set:onLeaveBtn(sender)
	local logic = i3k_game_get_logic()
	if logic then
		local world = logic:GetWorld()
		if world then
			world._curMoveFurniture = nil
			world:ChangeCurMoveFloor(true)
			world:RemoveChooseFurniture()
		end
	end
	g_i3k_ui_mgr:CloseUI(eUIID_HouseFurniture)
	g_i3k_ui_mgr:CloseUI(eUIID_HouseFurnitureSet)
end

function wnd_house_furniture_set:onCancelBtn(sender)
	local logic = i3k_game_get_logic()
	if logic then
		local world = logic:GetWorld()
		if world then
			world:ChangeCurMoveFloor(true)
			world:RemoveChooseFurniture()
		end
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_HouseFurniture, "showScroll")
	g_i3k_ui_mgr:CloseUI(eUIID_HouseFurnitureSet)
end

function wnd_house_furniture_set:onSaveBtn(sender)
	local logic = i3k_game_get_logic()
	if logic then
		local world = logic:GetWorld()
		if world then
			world:TryToPlaceFurniture()
		end
	end
end

--转向，1向左2向右
function wnd_house_furniture_set:onTurnBtn(sender, direction)
	local logic = i3k_game_get_logic()
	if logic then
		local world = logic:GetWorld()
		world:turnFloorFurniture(direction, self._placeType)
	end
end

--移动，1左2右3上4下
function wnd_house_furniture_set:onMoveBtn(sender, direction)
	local logic = i3k_game_get_logic()
	if logic then
		local world = logic:GetWorld()
		world:moveFloorFurniture(direction, self._placeType)
	end
end

-------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_house_furniture_set.new()
	wnd:create(layout,...)
	return wnd
end
