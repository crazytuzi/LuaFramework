
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_lucky_star = i3k_class("wnd_lucky_star",ui.wnd_base)

function wnd_lucky_star:ctor()

end

function wnd_lucky_star:configure()
	local widgets = self._layout.vars
	widgets.ok:onClick(self, self.onCloseUI)
end

function wnd_lucky_star:refresh()
	self:updateLuckyStarData()
end

function wnd_lucky_star:onTips(sender, eventType,id)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:ShowCommonItemInfo(id)
	end
end

function wnd_lucky_star:updateLuckyStarData()
	
	--self.titleImg:setImage(g_i3k_db.i3k_db_get_icon_path(1326))
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	scroll:removeAllChildren()
	scroll:setBounceEnabled(false)


	local lkData = g_i3k_game_context:GetLuckyStarData()
	local reward = g_i3k_game_context:GetLuckyStarDB()
	for i = 1 , 3 do
		local one = reward[i]
		if one.itemID ~= 0 then
			local node = require("ui/widgets/xingyunxingt")()
			scroll:addItem(node)
			node = node.vars
			node.bgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(one.itemID))
			node.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(one.itemID,i3k_game_context:IsFemaleRole()))
			node.bt:onTouchEvent(self,self.onTips,one.itemID)
			node.count:setText("x"..i3k_get_num_to_show(one.count))
			
		end
	end
	if lkData.dayRecvTimes > 0 then
		widgets.state:setText(i3k_get_string(3038))
		widgets.remainNum:setText(i3k_get_string(3039)..lkData.lastGiftTimes)
		
		if lkData.lastGiftTimes > 0 then
			widgets.desc:setText(i3k_get_string(914))
		else
			widgets.desc:setText(i3k_get_string(916))
		end
	else
		widgets.remainNum:setText(i3k_get_string(3040))
		widgets.state:setText(i3k_get_string(3041))
		widgets.desc:setText(i3k_get_string(915))
	end
	if lkData.dayRewardTimes > 0 then
		
	else
		
	end
end

function wnd_lucky_star:updateLuckStarRed()
	self._layout.vars.lucky_red:setVisible(g_i3k_game_context:IsUpdateLuckStart())
end

function wnd_create(layout, ...)
	local wnd = wnd_lucky_star.new()
	wnd:create(layout, ...)
	return wnd;
end

