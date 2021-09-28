-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_rob_flag_award = i3k_class("wnd_faction_rob_flag_award", ui.wnd_base)

local tmp_info = {}

function wnd_faction_rob_flag_award:ctor()
	self._item_root = {}
end

function wnd_faction_rob_flag_award:configure(...)
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	
	self.faction_icon = self._layout.vars.faction_icon 
	self.faction_name = self._layout.vars.faction_name 
	
	self.occupyTime = self._layout.vars.occupyTime 
	self.awardTime = self._layout.vars.awardTime 
	for i=1,4 do
		local tmp_item_bg = string.format("itemBg%s",i)
		local itemBg = self._layout.vars[tmp_item_bg]
		local tmp_item_btn = string.format("itemBtn%s",i)
		local itemBtn = self._layout.vars[tmp_item_btn]
		local tmp_item_icon = string.format("itemIcon%s",i)
		local itemIcon = self._layout.vars[tmp_item_icon]
		self._item_root[i] = {itemBg = itemBg,itemBtn = itemBtn,itemIcon = itemIcon}
	end
end

function wnd_faction_rob_flag_award:onShow()
	
end

function wnd_faction_rob_flag_award:refresh(factionData,mapID)
	tmp_info = factionData
	self:updateBaseData(factionData,mapID)

end 

function wnd_faction_rob_flag_award:updateBaseData(factionData,mapID)
	
	self.faction_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_faction_icons[factionData.curSect.sectIcon].iconid))
	self.faction_name:setText(factionData.curSect.sectName)
	self:updateAwardItem(mapID)
	self:updateTimes()
	if not self._timer then
		self._timer = i3k_game_timer_rob_flag.new()
		self._timer:onTest()
	end 
end 

function wnd_faction_rob_flag_award:updateTimes()
	self.occupyTime:setText(self:getOccupyTime(tmp_info.occupyTime))
	self.awardTime:setText(self:getAwardTime(tmp_info.lastRoleRewardTime))
end 

function wnd_faction_rob_flag_award:getOccupyTime(lastTime)
	local serverTime = i3k_integer(i3k_game_get_time())
	local have_time = serverTime - lastTime
	
	if have_time >= 0 then
		local d = math.modf(have_time/(60*60*24))
		local h = math.modf((have_time - (d*(60*60*24)))/(60*60))
		local m = math.modf((have_time - d*60*60*24 - h*60*60)/60)
		return string.format("%s天%s小时%s分钟",d,h,m)
	else
		tmp_info.occupyTime = serverTime
	end
end 

function wnd_faction_rob_flag_award:getAwardTime(lastTime)
	local serverTime = i3k_integer(i3k_game_get_time())
	local have_time = serverTime - lastTime
	have_time = i3k_db_faction_rob_flag.faction_rob_flag.faction_award_time - have_time
	if have_time >= 0 then
		local d = math.modf(have_time/(60*60*24))
		local h = math.modf((have_time - (d*(60*60*24)))/(60*60))
		local m = math.modf((have_time - d*60*60*24 - h*60*60)/60)
		local s = have_time - d*60*60*24 - h*60*60 - 60*m
		return string.format("%s小时%s分钟%s秒",h,m,s)
	else
		tmp_info.lastRoleRewardTime = tmp_info.lastRoleRewardTime + i3k_db_faction_rob_flag.faction_rob_flag.faction_award_time
	end
end 

function wnd_faction_rob_flag_award:updateAwardItem(mapID)
	local tmp_item = {}
	local serverTime = i3k_integer(i3k_game_get_time())
	if g_i3k_get_day_time(i3k_db_faction_rob_flag.faction_rob_flag.rob_start_time) <= serverTime and
	serverTime < g_i3k_get_day_time(i3k_db_faction_rob_flag.faction_rob_flag.rob_end_time) then
		tmp_item = i3k_db_faction_map_flag[mapID].robItems
	else
		tmp_item = i3k_db_faction_map_flag[mapID].normalItems
	end
	
	for i=1,4 do
		if tmp_item[i] and tmp_item[i][1] ~= 0 and tmp_item[i][2] ~= 0 then
			self._item_root[i].itemBg:show()
			self._item_root[i].itemBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(tmp_item[i][1]))
			self._item_root[i].itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(tmp_item[i][1],i3k_game_context:IsFemaleRole()))
			self._item_root[i].itemBtn:onClick(self,self.onItemTips,tmp_item[i][1])
		else
			self._item_root[i].itemBg:hide()
		end
	end
end 

function wnd_faction_rob_flag_award:onItemTips(sender,id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end 

function wnd_faction_rob_flag_award:onHide()
	if self._timer then
		self._timer:CancelTimer()
		self._timer = nil 
	end
end 


function wnd_create(layout, ...)
	local wnd = wnd_faction_rob_flag_award.new();
		wnd:create(layout, ...)

	return wnd;
end


local TIMER = require("i3k_timer");
i3k_game_timer_rob_flag = i3k_class("i3k_game_timer_rob_flag", TIMER.i3k_timer)

function i3k_game_timer_rob_flag:Do(args)
	
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionRobFlagAward,"updateTimes")
end

function i3k_game_timer_rob_flag:onTest()
	local logic = i3k_game_get_logic()
	if logic then
		self._timer = logic:RegisterTimer(i3k_game_timer_rob_flag.new(1000))
	end
end

function i3k_game_timer_rob_flag:CancelTimer()
	local logic = i3k_game_get_logic();
	if logic and self._timer then
		logic:UnregisterTimer(self._timer);
	end
end

