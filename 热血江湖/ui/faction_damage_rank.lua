-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_damage_rank = i3k_class("wnd_faction_damage_rank", ui.wnd_base)

local LAYER_BFPHT = "ui/widgets/bfpht"

local rank_icons = {236,237,238,239}


function wnd_faction_damage_rank:ctor()
	self._data = {}
end


function wnd_faction_damage_rank:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.single_btn = self._layout.vars.single_btn 
	self.single_btn:onTouchEvent(self,self.onSingleRank)
	self.all_btn = self._layout.vars.all_btn 
	self.all_btn:onTouchEvent(self,self.onAllRank)
	self.single_btn:stateToPressed()
	self.all_btn:stateToNormal()
	self.item_scroll = self._layout.vars.item_scroll 
end

function wnd_faction_damage_rank:onShow()
	
end

function wnd_faction_damage_rank:refresh()
	local data = g_i3k_game_context:GetFactionDungeonDamage()
	self._data = data.maxDamage
	self:setData()
end 

function wnd_faction_damage_rank:setData()
	local data = g_i3k_game_context:GetFactionDungeonDamage()
	local tmp_data = {}
	for k,v in pairs(self._data) do
		if v ~= 0 then
			local tmp = {} 
			tmp.id = k 
			tmp.value = v 
			table.insert(tmp_data,tmp)
		end 
	end
	table.sort(tmp_data,function (a,b)
		return a.value > b.value
	end)
	self.item_scroll:removeAllChildren()
	for k,v in ipairs(tmp_data) do
		local id = v.id 
		local value = v.value 
		local _data = data.members[id]
		if _data then
			local _layer = require(LAYER_BFPHT)()
			local rank_label = _layer.vars.rank_label 
			rank_label:setText(k)
			local rank_icon = _layer.vars.rank_icon 
			rank_icon:setImage(i3k_db_icons[rank_icons[4]].path)
			if k == 1 then
				rank_label:hide()
				rank_icon:setImage(i3k_db_icons[rank_icons[1]].path)
			elseif k == 2 then
				rank_label:hide()
				rank_icon:setImage(i3k_db_icons[rank_icons[2]].path)
			elseif k == 3 then
				rank_label:hide()
				rank_icon:setImage(i3k_db_icons[rank_icons[3]].path)
			end
			local headimg = _layer.vars.headimg
			local hicon = g_i3k_db.i3k_db_get_head_icon_ex(_data.headIcon,g_i3k_db.eHeadShapeCircie)
			if hicon and hicon > 0 then
				headimg:setImage(g_i3k_db.i3k_db_get_icon_path(hicon))
			end 
			local level = _layer.vars.level 
			local tmp_str = string.format("%s级",_data.level)
			level:setText(tmp_str)
			local name = _layer.vars.name 
			name:setText(_data.name)
			local damage = _layer.vars.damage 
			damage:setText(value)
			
			local roleHeadBg = _layer.vars.roleHeadBg 
			roleHeadBg:setImage(g_i3k_get_head_bg_path(_data.bwType, _data.headBorder))
			self.item_scroll:addItem(_layer)
		end
	end
end

function wnd_faction_damage_rank:onSingleRank(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		self.single_btn:stateToPressed()
		self.all_btn:stateToNormal()
		local data = g_i3k_game_context:GetFactionDungeonDamage()
		self._data = data.maxDamage
		self:setData()
	end
end

function wnd_faction_damage_rank:onAllRank(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		self.single_btn:stateToNormal()
		self.all_btn:stateToPressed()
		local data = g_i3k_game_context:GetFactionDungeonDamage()
		self._data = data.accDamage
		self:setData()
	end
end

--[[function wnd_faction_damage_rank:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionDamageRank)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_faction_damage_rank.new()
	wnd:create(layout, ...)
	return wnd
end

