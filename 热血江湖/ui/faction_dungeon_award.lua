-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_dungeon_award = i3k_class("wnd_faction_dungeon_award", ui.wnd_base)

local LAYER_BFFPT = "ui/widgets/bffpt"

function wnd_faction_dungeon_award:ctor()
	self._id = nil
end
function wnd_faction_dungeon_award:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.item_scroll = self._layout.vars.item_scroll 
	
end

function wnd_faction_dungeon_award:onShow()
	
end

function wnd_faction_dungeon_award:updateDABaseData(apply_data,my_applyID)
	local id = self._id
	local data = {}
	for i=1,10 do
		local tmp_item = string.format("bossBlood%s",i)
		local bossBlood = i3k_db_faction_dungeon[id][tmp_item]
		if bossBlood[1] ~= -1 then
			local _index = #bossBlood
			for i=1,_index,2 do
				if data[bossBlood[i]] then
					data[bossBlood[i]] = data[bossBlood[i]] + bossBlood[i+1]
				else
					data[bossBlood[i]] =  bossBlood[i+1]
				end
			end
		end
	end
	self._layout.vars.left_times:setText(string.format("今日剩余自取次数：%s/%s", i3k_db_common.faction.get_times - g_i3k_game_context:GetFactionTakeRewardCnt(), i3k_db_common.faction.get_times))
	self.item_scroll:removeAllChildren()
	local curindex = 1
	local index = 0
	for k,v in pairs(data) do
		index = index + 1
		local _layer = require(LAYER_BFFPT)()
		local item_bg = _layer.vars.item_bg 
		local item_icon = _layer.vars.item_icon 
		local item_name = _layer.vars.item_name 
		local desc = _layer.vars.desc 
		local apply_desc = _layer.vars.apply_desc 
		item_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(k))
		item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(k,i3k_game_context:IsFemaleRole()))
		item_name:setText(g_i3k_db.i3k_db_get_common_item_name(k))
		item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(k)))
		local detail_btn = _layer.vars.detail_btn 
		detail_btn:setTag(k)
		detail_btn:onTouchEvent(self,self.onDetail)
		local no_icon = _layer.vars.no_icon 
		local have_icon = _layer.vars.have_icon 
		local apply_btn = _layer.vars.apply_btn 
		if my_applyID ~= k then
			apply_btn:setTag(k)
			apply_btn:onTouchEvent(self,self.onApply)
			have_icon:hide()
			no_icon:show()
		else
			have_icon:show()
			no_icon:hide()
			curindex = index
		end
		local tmp_data = 0
		local count = 0
		local nums = 0
		if apply_data.rewards and apply_data.rewards[k] then
			local tmp_data = apply_data.rewards[k]
			count = tmp_data.count 
			nums = #tmp_data.applicants
		end
		local tmp_str = string.format("剩余%s件",count)
		desc:setText(tmp_str)
		local tmp_str = string.format("已经%s人申请",nums)
		apply_desc:setText(tmp_str)
		if count - nums >= i3k_db_common.faction.need_sub then
			_layer.vars.get_byself:enableWithChildren()
		else
			_layer.vars.get_byself:disableWithChildren()
		end
		_layer.vars.get_byself:onClick(self, self.award_get_byself, {mapId = id, rewardId = k})
		self.item_scroll:addItem(_layer)
	end
	self.item_scroll:jumpToChildWithIndex(curindex)

end

function wnd_faction_dungeon_award:refresh(mapId)
	self._id = mapId
	self:updateDABaseData(g_i3k_game_context:getFactionDungeonAward(),g_i3k_game_context:getFactionDungeonApplyItemID())
end 

function wnd_faction_dungeon_award:onDetail(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local id = sender:getTag()
		g_i3k_ui_mgr:OpenUI(eUIID_FactionDungeonDetail)
		g_i3k_ui_mgr:RefreshUI(eUIID_FactionDungeonDetail,id,self._id)
	end
end

function wnd_faction_dungeon_award:onApply(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if g_i3k_game_context:getFactionDungeonApplyItemID() ~= 0 then
			local fun = (function(ok)
					if ok then
						local id = sender:getTag()
						local data = i3k_sbean.sectmap_apply_req.new()
						data.mapId = self._id
						data.rewardId = id 
						i3k_game_send_str_cmd(data,i3k_sbean.sectmap_apply_res.getName())
					end
				end)
				g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(592),fun)
		else
			local id = sender:getTag()
			local data = i3k_sbean.sectmap_apply_req.new()
			data.mapId = self._id
			data.rewardId = id 
			i3k_game_send_str_cmd(data,i3k_sbean.sectmap_apply_res.getName())
		end
		
	end
end

function wnd_faction_dungeon_award:onRecord(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:OpenUI(eUIID_FactionDungeonDetail)
	end
end

function wnd_faction_dungeon_award:award_get_byself(sender, award)
	if i3k_game_get_time() - g_i3k_game_context:getlastjointime() < i3k_db_common.faction.need_days * 86400 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17092, i3k_db_common.faction.need_days))
	elseif g_i3k_game_context:GetLevel() < i3k_db_common.faction.get_byself_lvl then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17093, i3k_db_common.faction.get_byself_lvl))
	elseif g_i3k_game_context:GetScheduleInfo().activity < i3k_db_common.faction.need_activity then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17094, i3k_db_common.faction.need_activity))
	elseif g_i3k_game_context:GetFactionTakeRewardCnt() >= i3k_db_common.faction.get_times then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17095))
	elseif g_i3k_game_context:GetBagIsFull() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
	else
		i3k_sbean.sectmap_reward_self_take(award.mapId, award.rewardId)
	end
end

--[[function wnd_faction_dungeon_award:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionDungeonAward)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_faction_dungeon_award.new();
		wnd:create(layout, ...);

	return wnd;
end

