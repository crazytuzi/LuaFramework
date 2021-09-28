-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_escort_rob_store = i3k_class("wnd_faction_escort_rob_store", ui.wnd_base)


function wnd_faction_escort_rob_store:ctor()

end

function wnd_faction_escort_rob_store:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
	self.rob_escort_btn = self._layout.vars.rob_escort_btn
	self.rob_escort_btn:onClick(self,self.onRobEscort) 
	self.rob_escort_label = self._layout.vars.rob_escort_label 
	self.rob_escort_label:setText("我要劫镖")
	local robState = g_i3k_game_context:GetEscortRobState()
	if robState == 1 then
		self.rob_escort_label:setText("放弃劫镖")
		self.rob_escort_btn:onClick(self,self.onCancelRobEscort) 
	end
	
	self.escort_store = self._layout.vars.escort_store 
	self.escort_store:onClick(self,self.onEscortStore)
	
	self.rob_count = self._layout.vars.rob_count 
	local have_times = g_i3k_game_context:GetFactionEscortRobTimes()
	local str = string.format("剩余次数：%s/%s",i3k_db_escort.escort_args.rob_count - have_times,i3k_db_escort.escort_args.rob_count)
	self.rob_count:setText(str)
	
	self._layout.vars.desc:setText(i3k_get_string(5497)) 
end

function wnd_faction_escort_rob_store:refresh()
	
end


function wnd_faction_escort_rob_store:onRobEscort(sender)
	
	local taskId = g_i3k_game_context:GetFactionEscortTaskId()
	if taskId ~= 0 then
		local tmp_str = i3k_get_string(552)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
		return 
	end 
	
	
	local coutn = i3k_db_escort.escort_args.rob_count
	
	local have_count = g_i3k_game_context:GetFactionEscortRobTimes()
	
	if have_count >= coutn then
		local tmp_str = i3k_get_string(544)
		g_i3k_ui_mgr:PopupTipMessage(tmp_str)
		return 
	end
	
	local fun = (function(ok)
		if ok then
			i3k_sbean.rob_escort()
		end
	end)
	local desc = i3k_get_string(534)
	g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
	
end 

function wnd_faction_escort_rob_store:onCancelRobEscort(sender)
	local fun = (function(ok)
		if ok then
			i3k_sbean.cancel_rob_escort()
		end
	end)
	local desc = i3k_get_string(535)
	g_i3k_ui_mgr:ShowMessageBox2(desc,fun)
end 

function wnd_faction_escort_rob_store:updateRobBtn()
	self.rob_escort_label:setText("我要劫镖")
	self.rob_escort_btn:onClick(self,self.onRobEscort)
end 

function wnd_faction_escort_rob_store:updateCancelRobBtn()
	self.rob_escort_label:setText("放弃劫镖")
	self.rob_escort_btn:onClick(self,self.onCancelRobEscort)
end 

function wnd_faction_escort_rob_store:onEscortStore(sender)
	i3k_sbean.sect_escort_store_sync()
end 

function wnd_faction_escort_rob_store:updateRobTimes()
	local have_times = g_i3k_game_context:GetFactionEscortRobTimes()
	local str = string.format("剩余次数：%s/%s",i3k_db_escort.escort_args.rob_count - have_times,i3k_db_escort.escort_args.rob_count)
	self.rob_count:setText(str)
	--self._layout.vars.desc:setText(i3k_get_string(5497))
end 
-------------------------------------
function wnd_create(layout)
	local wnd = wnd_faction_escort_rob_store.new();
		wnd:create(layout);
	return wnd;
end
