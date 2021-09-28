-- modify by zhangbing 2018/07/18
-- [eUIID_HuoBanBonus]		       = {name = "huobanBonus", layout = "huobanyqxq", order = eUIO_TOP_MOST},
-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_huobanBonus = i3k_class("wnd_huobanBonus",ui.wnd_base)

function wnd_huobanBonus:ctor()

end

function wnd_huobanBonus:configure()
 	local widgets = self._layout.vars 
	self.scroll =  widgets.scroll
	self.desc   = widgets.desc
	widgets.close_btn:onClick(self, self.onCloseUI)	
end

function wnd_huobanBonus:refresh(info)
	self.info = info
	self.scroll:removeAllChildren()
	for k, v in pairs(info) do
		local node = require("ui/widgets/huobanyqxqt")()
		node.vars.name:setText(v.name)
		node.vars.level:setText(v.level) 
		node.vars.power:setText(v.maxFightPower) 
		node.vars.activity:setText(v.activity) 
		node.vars.dividend:setText(v.dividend)
		node.vars.state:setText(self:getStateDes(v.lastLoginTime))
		node.vars.unbind:onClick(self, self.onUnBindClick, {id = k, info = v})
		self.scroll:addItem(node)
	end		

	self.desc:setText(i3k_get_string(17360)) --描述
end
 
function wnd_huobanBonus:getStateDes(state)
	if state < 0 then
		return "线上"
	elseif state == 0 then
		return "久未上线"
	else
		local now = i3k_game_get_time()
		local time = now - state
		local day,hour = i3k_get_rest_date(time)
		if day > 7 then
			return "久未上线"
		elseif day > 0 then
			return  string.format("离线%s天", day)
		elseif hour > 0 then
			return string.format("离线%s小时", hour)
		else
			return "刚刚"
		end
	end
end
function wnd_huobanBonus:onUnBindSuccess(roleID)
	self.info[roleID] = nil
	self:refresh(self.info)
	i3k_sbean.sync_partner_info(3)
end
function wnd_huobanBonus:onUnBindClick(sender, data)
	local cd = i3k_db_partner_base.cfg.unbindCD
	local lastTime = g_i3k_game_context:GetPartnerUnBindTime()
	local now = i3k_game_get_time()
	local left = cd - (now - lastTime)
	if left <= 0 then
		local str = i3k_get_string(17891, data.info.name)
		g_i3k_ui_mgr:ShowMessageBox2(str, function(isOk)
			if isOk then
				i3k_sbean.unbind_partner(data.id)
			end
		end)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17890, i3k_get_show_rest_time(left)))
	end
end
function wnd_create(layout)
	local wnd = wnd_huobanBonus.new()
	wnd:create(layout)
	return wnd
end
