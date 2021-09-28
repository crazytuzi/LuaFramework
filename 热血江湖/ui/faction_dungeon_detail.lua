-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_dungeon_detail = i3k_class("wnd_faction_dungeon_detail", ui.wnd_base)

local LAYER_BFSQT = "ui/widgets/bfsqt"

local _TIME_TEXT 

function wnd_faction_dungeon_detail:ctor()
	self._id = nil
	self._mapid = nil
	self._item_timer = nil
end



function wnd_faction_dungeon_detail:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.rank_desc = self._layout.vars.rank_desc 
	self.item_scroll = self._layout.vars.item_scroll 
	self.item_bg = self._layout.vars.item_bg 
	self.item_icon = self._layout.vars.item_icon 
	self.item_name = self._layout.vars.item_name 
	self.item_count = self._layout.vars.item_count 
	self.apply_btn = self._layout.vars.apply_btn 
	self.no_icon = self._layout.vars.no_icon 
	self.have_icon = self._layout.vars.have_icon 
	_TIME_TEXT = self._layout.vars.time_label 
	
end

function wnd_faction_dungeon_detail:onShow()
end

function wnd_faction_dungeon_detail:updateDItemData(apply_data,my_applyID,my_id)
	local data = {}
	if apply_data.rewards and apply_data.rewards[self._id] then
		data = apply_data.rewards[self._id].applicants
	end
	local my_rank = 1
	
	self.rank_desc:hide()
	self.item_scroll:removeAllChildren()
	for k,v in ipairs(data) do
		if apply_data.members[v] then
			local _layer = require(LAYER_BFSQT)()
			local rank = _layer.vars.rank 
			local icon = _layer.vars.icon 
			local level = _layer.vars.level 
			local name = _layer.vars.name 
			if my_id == v then
				my_rank = k 
				self.rank_desc:show()
				local tmp_str = string.format("当前排在第%s位",my_rank)
				self.rank_desc:setText(tmp_str)
			end
			local tmp_str = string.format("%s.",k)
			rank:setText(tmp_str)
			name:setText(apply_data.members[v].name)
			local tmp_str = string.format("%s级",apply_data.members[v].level)
			level:setText(tmp_str)
			local hicon = g_i3k_db.i3k_db_get_head_icon_ex(apply_data.members[v].headIcon,g_i3k_db.eHeadShapeCircie)
			if hicon and hicon > 0 then
				icon:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
			end
			local roleHeadBg = _layer.vars.roleHeadBg 
			roleHeadBg:setImage(g_i3k_get_head_bg_path(apply_data.members[v].bwType, apply_data.members[v].headBorder))
			self.item_scroll:addItem(_layer)
		end 
	end
	self.item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self._id))
	self.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self._id,i3k_game_context:IsFemaleRole()))
	self.item_name:setText(g_i3k_db.i3k_db_get_common_item_name(self._id))
	self.item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(self._id)))
	local count = 0
	if apply_data.rewards and apply_data.rewards[self._id] then
		local tmp_data = apply_data.rewards[self._id]
		count = tmp_data.count 
	end
	local tmp_str = string.format("待分配：%s个",count)
	self.item_count:setText(tmp_str)
	
	if my_applyID  == self._id then
		self.have_icon:show()
		self.no_icon:hide()
	else
		self.have_icon:hide()
		self.no_icon:show()
		self.apply_btn:onTouchEvent(self,self.onApply)
	end
	self:setUpTime()
	if not self._item_timer then
		self._item_timer = i3k_game_timer_dungeon_detail.new()
		self._item_timer:onTest()
	end
end

function wnd_faction_dungeon_detail:refresh(itemid,mapId)
	self._id = itemid
	self._mapid = mapId
	self:updateDItemData(g_i3k_game_context:getFactionDungeonAward(),g_i3k_game_context:getFactionDungeonApplyItemID(),g_i3k_game_context:GetRoleId())
end 

function wnd_faction_dungeon_detail:onApply(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local data = i3k_sbean.sectmap_apply_req.new()
		data.mapId = self._mapid
		data.rewardId = self._id 
		i3k_game_send_str_cmd(data,i3k_sbean.sectmap_apply_res.getName())
	end
end

--[[function wnd_faction_dungeon_detail:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionDungeonDetail)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_faction_dungeon_detail.new()
	wnd:create(layout, ...)
	return wnd
end

function wnd_faction_dungeon_detail:setUpTime()
	
	local serverTime = math.modf(i3k_game_get_time())
	
	local m =math.modf(os.date("%M",serverTime))
	
	local have_time = 0
	if m <= 30 then
		have_time = 30 - m 
	else
		have_time = 60 - m 
	end 
	local desc = string.format("%s分后自动分配",have_time)
	_TIME_TEXT:setText(desc)
end


function wnd_faction_dungeon_detail:onHide()
	if self._item_timer then
		self._item_timer:CancelTimer()
	end
end 


local TIMER = require("i3k_timer");
i3k_game_timer_dungeon_detail = i3k_class("i3k_game_timer_dungeon_detail", TIMER.i3k_timer);

function i3k_game_timer_dungeon_detail:Do(args)
	
	
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FactionDungeonDetail,"setUpTime")
end

function i3k_game_timer_dungeon_detail:onTest()
	local logic = i3k_game_get_logic()
	if logic then
		self._timer = logic:RegisterTimer(i3k_game_timer_dungeon_detail.new(1000));

	end
end

function i3k_game_timer_dungeon_detail:CancelTimer()
	local logic = i3k_game_get_logic();
	if logic and self._timer then
		logic:UnregisterTimer(self._timer);
	end
end

