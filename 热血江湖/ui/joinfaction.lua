-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_joinFaction = i3k_class("wnd_joinFaction", ui.wnd_base)

local LAYER_BPLBT = "ui/widgets/bplbt"


function wnd_joinFaction:ctor()
	self._select = {}

	self._id = nil
end

function wnd_joinFaction:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	local search_btn = self._layout.vars.search_btn
	search_btn:onTouchEvent(self,self.onSearch)
	local refresh_btn = self._layout.vars.refresh_btn
	refresh_btn:onTouchEvent(self,self.onRefresh)
	self.select_label = self._layout.vars.select_label
	self.data_scroll = self._layout.vars.data_scroll
end

function wnd_joinFaction:onShow()

end

function wnd_joinFaction:refresh()
	self:SetData()
end

function wnd_joinFaction:SetData()

	local faction_data = g_i3k_game_context:GetFactionListData()
	local have_select = g_i3k_game_context:GetFactionSelectData()
	self._select = {}
	self.data_scroll:removeAllChildren()
	local count = 0
	local illegalCfg = i3k_db_illegal_char
	for k,v in ipairs(faction_data) do
		count = count + 1
		local _layer = require(LAYER_BPLBT)()
		_layer.vars.ID_label:setText(v.sectId)
		_layer.vars.name_label:setText(v.name)
		_layer.vars.master_label:setText(v.chiefName)
		_layer.vars.faction_icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_faction_icons[v.icon].iconid))
		_layer.vars.level_label:setText(string.format("%s级",v.level))
		local maxCount = i3k_db_faction_uplvl[v.level].count
		_layer.vars.count_lable:setText(string.format("%s/%s", v.memberCount, maxCount))
		_layer.vars.apply_btn:setTag(v.sectId)
		_layer.vars.apply_btn:onTouchEvent(self,self.onApplJoin)
		_layer.vars.creed:setText(i3k_get_replace_invalid_string(v.creed, illegalCfg))
		local btn_text = _layer.vars.btn_text
		if have_select[v.sectId] then
			btn_text:setText("已申请")
			_layer.vars.apply_btn:disableWithChildren()
		else
			btn_text:setText("申请")
		end
		_layer.vars.add_lvl:setText(string.format("申请等级%s",v.joinLvlReq))

		self._select[v.sectId] = {is_apply = 0,creed = v.creed,btn_text = btn_text,joinLvl = v.joinLvlReq}
		self.data_scroll:addItem(_layer)
	end

end

function wnd_joinFaction:onRefresh(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		self.select_label:setText("")
		local data = i3k_sbean.sect_list_req.new()
		i3k_game_send_str_cmd(data,i3k_sbean.sect_list_res.getName())
	end
end

function wnd_joinFaction:onApplJoin(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local id = sender:getTag()
		local hero_lvl = g_i3k_game_context:GetLevel()
		if hero_lvl < i3k_db_common.faction.addLevel then
			local desc = "等级不足%s级，不可加入帮派"
			desc = string.format(desc,i3k_db_common.faction.addLevel)
			g_i3k_ui_mgr:PopupTipMessage(desc)
			return
		end
		local serverTime = i3k_game_get_time()
		serverTime = i3k_integer(serverTime)
		local _data = g_i3k_game_context:GetFactionMyData()
		if not _data then
			g_i3k_ui_mgr:PopupTipMessage("获取资讯失败")
			return
		end
		local leaveTimes = _data.leaveTimes or 0
		local isByKick = _data.isByKick or 1

		if leaveTimes > 1 then
			if _data.lastLeaveTime + g_i3k_db.i3k_db_get_faction_kick_punish_time(leaveTimes) > serverTime then
				local have_time =  _data.lastLeaveTime + g_i3k_db.i3k_db_get_faction_kick_punish_time(leaveTimes) - serverTime
				local tmp_str
				local tmp_str1
				local h = math.floor(have_time/(60*60))

				if h ~= 0 then
					local tmp = string.format("%s小时",h)
					tmp_str = i3k_get_string(10046,tmp)
					tmp_str1 = i3k_get_string(570,tmp)
				else
					local s = math.floor(have_time/60)
					if s == 0 then
						s = 1
					end
					local tmp = string.format("%s分钟",s)
					tmp_str = i3k_get_string(10046,tmp)
					tmp_str1 = i3k_get_string(570,tmp)

				end
				if isByKick == 1 then
					g_i3k_ui_mgr:PopupTipMessage(tmp_str1)
				elseif isByKick == 0 then
					g_i3k_ui_mgr:PopupTipMessage(tmp_str)
				end

				return
			end
		end


		local joinLvl = self._select[id].joinLvl
		if hero_lvl < joinLvl then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(10067,joinLvl))
			return
		end
		--TODO此处发送申请协议
		local myData = g_i3k_game_context:GetRoleInfo()
		local myID = myData.curChar._id
		local data = i3k_sbean.sect_apply_req.new()
		data.sectId = id

		i3k_game_send_str_cmd(data,i3k_sbean.sect_apply_res.getName())
	end
end

function wnd_joinFaction:onSearch(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local inputText = self.select_label:getText()
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


function wnd_joinFaction:onHide()

end

--[[function wnd_joinFaction:onCloseLayer(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_JoinFaction)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_joinFaction.new()
		wnd:create(layout, ...)

	return wnd
end
