-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_list = i3k_class("wnd_faction_list", ui.wnd_base)

local LAYER_BPLBT = "ui/widgets/bplbt"

function wnd_faction_list:ctor()
	
end

function wnd_faction_list:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	local search_btn = self._layout.vars.search_btn 
	search_btn:onTouchEvent(self,self.onSearch)
	self.data_scroll = self._layout.vars.data_scroll 
	self.input_text = self._layout.vars.input_text 
	local refresh_btn = self._layout.vars.refresh_btn 
	refresh_btn:onTouchEvent(self,self.onRefresh)
end

function wnd_faction_list:onShow()
	
end

function wnd_faction_list:refresh()
	self:updateListData(g_i3k_game_context:GetFactionListData())
end 

function wnd_faction_list:updateListData(faction_data)
	if not faction_data then
		return 
	end 
	self._select = {}
	self.data_scroll:removeAllChildren()
	local count = 0
	for k,v in pairs(faction_data) do
		count = count + 1
		local _layer = require(LAYER_BPLBT)()
		local ID_label = _layer.vars.ID_label 
		ID_label:setText(v.sectId)
		local name_label = _layer.vars.name_label 
		name_label:setText(v.name)
		local faction_icon = _layer.vars.faction_icon 
		faction_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_faction_icons[v.icon].iconid))
		
		local master_label = _layer.vars.master_label 
		master_label:setText(v.chiefName)
		local level_label = _layer.vars.level_label 
		local tmp_str = string.format("%s级",v.level)
		level_label:setText(tmp_str)
		local count_lable = _layer.vars.count_lable 
		local maxCount = i3k_db_faction_uplvl[v.level].count
		local tmp_str = string.format("%s/%s",v.memberCount,maxCount)
		count_lable:setText(tmp_str)
		local creed = _layer.vars.creed 
		creed:setText(v.creed)
		local apply_btn = _layer.vars.apply_btn 
		apply_btn:hide()
		local btn_bg = _layer.vars.btn_bg 
		btn_bg:hide()
		local globel_btn = _layer.vars.globel_btn 
		globel_btn:setTag(v.sectId)
		globel_btn:onTouchEvent(self,self.onSelect)
		local add_lvl = _layer.vars.add_lvl 
		add_lvl:hide()
		self._select[v.sectId] = {}
		self._select[v.sectId].creed = v.creed
		self.data_scroll:addItem(_layer)
	end
end
function wnd_faction_list:onSearch(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local inputText = self.input_text:getText()
		if tonumber(inputText) then
			local data = i3k_sbean.sect_searchbyid_req.new()
			data.sectId = tonumber(inputText)
			i3k_game_send_str_cmd(data,i3k_sbean.sect_searchbyid_res.getName())
		else
			local data = i3k_sbean.sect_searchbyname_req.new()
			data.sectName = inputText
			i3k_game_send_str_cmd(data,i3k_sbean.sect_searchbyname_res.getName())
		end
	end
end


function wnd_faction_list:onRefresh(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		self.input_text:setText("")
		local data = i3k_sbean.sect_list_req.new()
		data.layer = 1
		i3k_game_send_str_cmd(data,i3k_sbean.sect_list_res.getName())
		
	end
end

--[[function wnd_faction_list:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionList)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_faction_list.new();
		wnd:create(layout, ...);

	return wnd;
end

