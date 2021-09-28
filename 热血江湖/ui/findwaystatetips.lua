-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_findwayStateTips = i3k_class("wnd_findwayStateTips", ui.wnd_base)

function wnd_findwayStateTips:ctor()
end

function wnd_findwayStateTips:configure()
	local widget = self._layout.vars
	local flyBtn = widget.flybtn
	flyBtn:onClick(self,self.transfer)
end

function wnd_findwayStateTips:refresh()
	self._layout.vars.flybtn:hide()
	local needId = i3k_db_common.activity.transNeedItemId
	-- local itemCount = g_i3k_game_context:GetBagMiscellaneousCanUseCount(needId)
	-- if itemCount>0 then
	if g_i3k_game_context:CheckCanTrans(needId, 1) then
		local data = g_i3k_game_context:GetFindPathData()
		if data and data.transferData then
			self._layout.vars.flybtn:show()
		end
	end
end

function wnd_findwayStateTips:TransferBtnIsShow(isShow)
	self._layout.vars.flybtn:setVisible(isShow)
end

--传送
function wnd_findwayStateTips:transfer(sender)
	local data = g_i3k_game_context:GetFindPathData()
	if data and data.transferData then
		self:transferToPoint(data.transferData)
	end
end

function wnd_findwayStateTips:transferToPoint(needValue)
	local hero = i3k_game_get_player_hero()
	if hero then
		local isFight = hero:IsInFightTime()
		local isEscort = g_i3k_game_context:GetTransportState()
		if isFight and isEscort == 1 then
			g_i3k_ui_mgr:PopupTipMessage("运镖且战斗状态下不能传送")
			return;
		end
	end
	if i3k_game_get_map_type() == g_HOME_LAND and g_i3k_game_context:IsOnHugMode() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17744))
		return
	end
	local mapId = needValue.mapId
	local areaId = needValue.areaId
	local needId = i3k_db_common.activity.transNeedItemId
	local needName = g_i3k_db.i3k_db_get_common_item_name(needId)
	local descText = i3k_get_string(1491,needName, 1)
	if g_i3k_game_context:IsTransNeedItem() then
		local function callback(isOk)
			if isOk then
				g_i3k_game_context:TransportCallBack(mapId,areaId,needValue.flage)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(descText, callback)
	else
		g_i3k_game_context:TransportCallBack(mapId,areaId,needValue.flage)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_findwayStateTips.new()
	wnd:create(layout, ...)
	return wnd;
end
