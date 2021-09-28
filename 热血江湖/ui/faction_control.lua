-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_control = i3k_class("wnd_faction_control", ui.wnd_base)

local LAYER_AN4 = "ui/widgets/an4"
local LAYER_AN5 = "ui/widgets/an5"
local LAYER_AN6 = "ui/widgets/an6"

local LAYER_BPSZT = "ui/widgets/bpszt"

function wnd_faction_control:ctor()
	self._type = nil
	self._id = nil
	self._pos = nil
	self._name = nil 
end


function wnd_faction_control:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.item_scroll = self._layout.vars.scroll
	self.rootView = self._layout.vars.rootView 
end

function wnd_faction_control:onShow()
	
end

function wnd_faction_control:refresh(_type,roleId,pos,name)
	self._type = _type
	self._id = roleId
	self._pos = pos
	self._name = name
	if self._type == 1 then
		self:setBaZhuData()
	else
		self:setFuBaZhuData()
	end
end 

function wnd_faction_control:setBaZhuData()
	self.item_scroll:removeAllChildren()
	for i= 1 ,5 do
			local _layer = require(LAYER_BPSZT)()
			local btnName = _layer.vars.btnName 
			local btn = _layer.vars.btn 
			local is_add = true 
			if i == 1 then
				btnName:setText("转让帮主")
				btn:onTouchEvent(self,self.onGiveBangZhu)
			elseif i == 2 then
				btnName:setText("任命副帮主")
				btn:onTouchEvent(self,self.onGiveFuBangZhu)
				if self._pos == eFactionSencondOwner then
					btn:disableWithChildren()
					is_add = false
				end
			elseif  i == 3 then
				btnName:setText("任命长老")
				btn:onTouchEvent(self,self.onGiveZhangLao)
				if self._pos == eFactionElder then
					btn:disableWithChildren()
					is_add = false
				end 
			elseif  i== 4 then
				btnName:setText("降为成员")
				btn:onTouchEvent(self,self.onGiveChengYuan)
				if self._pos == eFactionPeple then
					btn:disableWithChildren()
					is_add = false
				end
			elseif  i == 5 then
				btnName:setText("踢出帮派")
				btn:onTouchEvent(self,self.onKickOut)
			end
		if is_add then
			self.item_scroll:addItem(_layer)
		end 
	end
	
end

function wnd_faction_control:setFuBaZhuData()
	self.item_scroll:removeAllChildren()
	for i= 3 ,5 do
		local _layer = require(LAYER_BPSZT)()
		local btnName = _layer.vars.btnName 
		local btn = _layer.vars.btn 
		local is_add = true 
		if  i == 3 then
			btnName:setText("任命长老")
			btn:onTouchEvent(self,self.onGiveZhangLao)
			if self._pos == eFactionElder then
				btn:disableWithChildren()
				is_add = false
			end
		elseif  i== 4 then
			btnName:setText("降为成员")
			btn:onTouchEvent(self,self.onGiveChengYuan)
			if self._pos == eFactionPeple then
				btn:disableWithChildren()
				is_add = false
			end
		elseif  i == 5 then
			btnName:setText("踢出帮派")
			btn:onTouchEvent(self,self.onKickOut)
		end
		if is_add then
			self.item_scroll:addItem(_layer)
		end 
	end	
end

function wnd_faction_control:onGiveBangZhu(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		
		local role_id = self._id
		local fun = (function(ok) 
			if ok then
				local data = i3k_sbean.sect_appoint_req .new()
				data.roleId = role_id
				data.position = 1
				i3k_game_send_str_cmd(data,i3k_sbean.sect_appoint_res.getName())
			end 
		end)
		local desc = i3k_get_string(10079,self._name)
		g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
		
		g_i3k_ui_mgr:CloseUI(eUIID_FactionControl)
	end
end

function wnd_faction_control:onGiveFuBangZhu(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local data = i3k_sbean.sect_appoint_req .new()
		data.roleId = self._id
		data.position = 2
		i3k_game_send_str_cmd(data,i3k_sbean.sect_appoint_res.getName())
		g_i3k_ui_mgr:CloseUI(eUIID_FactionControl)
	end
end

function wnd_faction_control:onGiveZhangLao(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local data = i3k_sbean.sect_appoint_req .new()
		data.roleId = self._id
		data.position = 3
		i3k_game_send_str_cmd(data,i3k_sbean.sect_appoint_res.getName())
		g_i3k_ui_mgr:CloseUI(eUIID_FactionControl)
	end
end

function wnd_faction_control:onGiveChengYuan(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local data = i3k_sbean.sect_appoint_req .new()
		data.roleId = self._id
		data.position = 4
		i3k_game_send_str_cmd(data,i3k_sbean.sect_appoint_res.getName())
		g_i3k_ui_mgr:CloseUI(eUIID_FactionControl)
	end
end

function wnd_faction_control:onKickOut(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local role_id = self._id
		if g_i3k_game_context:judgeInFactionFight() and g_i3k_game_context:isInFactionFightGroup(role_id) then
			g_i3k_ui_mgr:PopupTipMessage("当前处于帮派战阶段,操作失败")
		else
			local fun = (function(ok) 
				if ok then
					local data = i3k_sbean.sect_kick_req.new()
					data.roleId = role_id
					i3k_game_send_str_cmd(data,i3k_sbean.sect_kick_res.getName())
				end 
			end)
			local desc = i3k_get_string(10075,self._name)
			g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
			
			g_i3k_ui_mgr:CloseUI(eUIID_FactionControl)
		end
	end
end

--[[function wnd_faction_control:onClose(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_FactionControl)
	end
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_faction_control.new();
		wnd:create(layout, ...);

	return wnd;
end

