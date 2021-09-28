-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_wipe = i3k_class("wnd_wipe", ui.wnd_base)

--体力id
local TILIICON = 101
--扫荡券id
local wipe_itemid = i3k_db_common.wipe.itemid

function wnd_wipe:ctor()
	self._isSelect = false
	self._id = nil
	self._cfg = nil 
end

function wnd_wipe:configure()
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

function wnd_wipe:refresh(id)
	self._id = id
	self._cfg = i3k_db_new_dungeon[self._id] or i3k_db_activity_cfg[self._id]
	self:SetData()
	if self._cfg.groupId == 1 then--修炼之地特殊提示
		self._layout.vars.desc:setText(i3k_get_string(18547))
	end
end

function wnd_wipe:getConsumeVit()
	return self._cfg.needTili or self._cfg.consume
end 

function wnd_wipe:getLastEnterTimes()
	if i3k_db_new_dungeon[self._id] then
		local count =  g_i3k_game_context:getDungeonDayEnterTimes(self._id)
		local total_count = g_i3k_game_context:GetNormalMapEnterTotalTimes(self._id)
		return total_count - count
	elseif i3k_db_activity_cfg[self._id] then
		local actID = i3k_db_activity_cfg[self._id].groupId
		local count =  g_i3k_game_context:getActivityDayEnterTime(actID)
		local total_count = g_i3k_game_context:GetActivityDungeonNormalEnterTimes(actID)
		return total_count - count
	end
end 

function wnd_wipe:SetData()
	local pay_btn = self._layout.vars.pay_btn 
	local item1Root = self._layout.vars.item1Root 
	local item2Root = self._layout.vars.item2Root 
	local item3Root = self._layout.vars.item3Root 
	local bingGouIcon = self._layout.vars.bingGouIcon 
	
	local consume = self:getConsumeVit()
	
	local item1_icon = self._layout.vars.item1_icon 
	local item1_count = self._layout.vars.item1_count 
	local itemid = i3k_db_common.wipe.itemid
	
	
	item1_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid,i3k_game_context:IsFemaleRole()))
	
	if item1_count then
		item1_count:setText("×1")
	end
	
	local item2_icon = self._layout.vars.item2_icon 
	local item2_count = self._layout.vars.item2_count 
	if item2_icon then
		item2_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_VIT,i3k_game_context:IsFemaleRole()))
	end
	if item2_count then
		item2_count:setText("×"..consume)
	end
	
	if bingGouIcon then
		bingGouIcon:hide()
	end
	if item3Root then
		item3Root:hide()
	end
	if pay_btn then
		pay_btn:onTouchEvent(self,self.onSelectPay)
	end
	
	local continueWipe_btn = self._layout.vars.continueWipe_btn 
	local singleWipe_btn = self._layout.vars.singleWipe_btn 
	if continueWipe_btn then
		continueWipe_btn:onTouchEvent(self,self.onContinueWipe)
	end
	if singleWipe_btn then
		singleWipe_btn:onTouchEvent(self,self.onSingleWipe)
	end
end

function wnd_wipe:onContinueWipe(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		
		local times = self:getLastEnterTimes()
		if times <= 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(71))
			return 
		end 
		local consume = self:getConsumeVit()
		local vit = g_i3k_game_context:GetVit()		
		if vit < consume then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(63))
			return 
		end
				
		local maxTimes = math.floor(vit/consume)
		if maxTimes < times then
			times = maxTimes
		end
		
		local wipeCount = g_i3k_game_context:GetCommonItemCanUseCount(wipe_itemid)
		
		if wipeCount < times then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(64))
			return 
		end
		local fun = function (ok)
			if ok then
				if i3k_db_new_dungeon[self._id] then
					local data = i3k_sbean.privatemap_sweep_req.new()
					data.mapId = self._id
					data.times = times
					if self._isSelect then
						data.extraCard = 1
						local diamondCount = g_i3k_game_context:GetDiamondCanUse(false)
						local diamondNeed = i3k_db_common.wipe.ingot
						if diamondCount < diamondNeed then 
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(612))
							return 
						end 
					else
						data.extraCard = 0
					end
					i3k_game_send_str_cmd(data,i3k_sbean.privatemap_sweep_res.getName())
				elseif i3k_db_activity_cfg[self._id] then
					local extraCard = 0
					if self._isSelect then
						extraCard = 1
						local diamondCount = g_i3k_game_context:GetDiamondCanUse(false)
						local diamondNeed = i3k_db_common.wipe.ingot
						if diamondCount < diamondNeed then 
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(612))
							return 
						end 
					end
					i3k_sbean.activity_wipe(self._id,times,extraCard)
				end
				g_i3k_ui_mgr:CloseUI(eUIID_WIPE)
			end
		end
		g_i3k_game_context:CheckJudgeEmailIsFull(fun)
	end
end

function wnd_wipe:onSingleWipe(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		
		local times = self:getLastEnterTimes()
		if times <= 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(71))
			return 
		end 
		
		local wipeCount = g_i3k_game_context:GetCommonItemCanUseCount(wipe_itemid)
		
		if wipeCount < 1 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(64))
			return 
		end
		
		local vit = g_i3k_game_context:GetVit()
		
		local consume = self:getConsumeVit()
		
		local need_consume = consume 
		if vit < need_consume then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(63))
			return 
		end
		local fun = function (ok)
			if ok then
				if i3k_db_new_dungeon[self._id] then
					local data = i3k_sbean.privatemap_sweep_req.new()
					data.mapId = self._id
					data.times = 1
					if self._isSelect then
						data.extraCard = 1
						local diamondCount = g_i3k_game_context:GetDiamondCanUse(false)
						local diamondNeed = i3k_db_common.wipe.ingot
						if diamondCount < diamondNeed then 
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(612))
							return 
						end 
					else
						data.extraCard = 0
					end
					i3k_game_send_str_cmd(data,i3k_sbean.privatemap_sweep_res.getName())
				elseif i3k_db_activity_cfg[self._id] then
					local extraCard = 0
					if self._isSelect then
						extraCard = 1
						local diamondCount = g_i3k_game_context:GetDiamondCanUse(false)
						local diamondNeed = i3k_db_common.wipe.ingot
						if diamondCount < diamondNeed then 
							g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(612))
							return 
						end 
					end
					i3k_sbean.activity_wipe(self._id,1,extraCard)
				end
				g_i3k_ui_mgr:CloseUI(eUIID_WIPE)
			end
		end
		g_i3k_game_context:CheckJudgeEmailIsFull(fun)
	end
end

function wnd_wipe:onSelectPay(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if self._isSelect then
			self._isSelect = false 
		else
			self._isSelect = true 
		end
		if self._isSelect then
			local bingGouIcon = self._layout.vars.bingGouIcon 
			if bingGouIcon then
				bingGouIcon:show()
			end
			local item3Root = self._layout.vars.item3Root 
			if item3Root then
				item3Root:show()
			end
			local count= i3k_db_common.wipe.ingot
			local ingot = self._layout.vars.ingot 
			if ingot then
				ingot:setText("×"..count)
			end
		else
			local bingGouIcon = self._layout.vars.bingGouIcon 
			if bingGouIcon then
				bingGouIcon:hide()
			end
			local item3Root = self._layout.vars.item3Root 
			if item3Root then
				item3Root:hide()
			end
		end
	end
end


function wnd_create(layout, ...)
	local wnd = wnd_wipe.new();
		wnd:create(layout, ...);

	return wnd;
end

