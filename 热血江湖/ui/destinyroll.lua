module(..., package.seeall)

local require = require;
local ui = require("ui/base")

-------------------------------------------------------
wnd_destinyRoll = i3k_class("wnd_destinyRoll", ui.wnd_base)

function wnd_destinyRoll:ctor()
	
end

function wnd_destinyRoll:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self,self.onCloseUI)
	widgets.resetBtn:onClick(self,self.onReset)
end

function wnd_destinyRoll:refresh()
	local widgets = self._layout.vars
	for i,v in ipairs(i3k_db_destiny_roll) do
		widgets["btn"..i]:onClick(self,self.onChoose, i)
		widgets["choose"..i]:hide()
		
		widgets["attr"..i.."_1"]:hide()
		widgets["attr"..i.."_1".."_value"]:hide()
		widgets["attr"..i.."_2"]:hide()
		widgets["attr"..i.."_2".."_value"]:hide()
	end
	
	widgets.resetBtn:hide()
	
	self:setRollCfg()
	self:setPlayerInfo()
end

function wnd_destinyRoll:setRollCfg()
	local widgets = self._layout.vars
	widgets.tips:setText(i3k_get_string(1384))
	for i,v in ipairs(i3k_db_destiny_roll) do
		widgets["icon"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(v.icon))
		for k,s in ipairs(v.props) do
			if s.id ~= 0 then
				widgets["attr"..i.."_"..k]:show()
				widgets["attr"..i.."_"..k.."_value"]:show()
				widgets["attr"..i.."_"..k]:setTextColor("FF9080A3")
				widgets["attr"..i.."_"..k.."_value"]:setTextColor("FF9080A3")
				widgets["attr"..i.."_"..k]:setText(i3k_db_prop_id[s.id].desc)
				widgets["attr"..i.."_"..k.."_value"]:setText("+"..i3k_get_prop_show(s.id, s.count))
			end
		end
	end
end

function wnd_destinyRoll:setPlayerInfo()
	local widgets = self._layout.vars
	local fiveTrans = g_i3k_game_context:getFiveTrans()
	local totalPoint = i3k_db_five_trans[fiveTrans.level].destinyCount
	local leftPoint = totalPoint - self:getChosenPoint()
	
	widgets.pointInfo:setText("当前可勾选："..leftPoint.."/"..totalPoint)
	
	for i, v in pairs(fiveTrans.liftWheel) do
		if v then
			widgets["choose"..i]:show()
			for k, s in ipairs(i3k_db_destiny_roll[i].props) do
				if s.id ~= 0 then
					widgets["attr"..i.."_"..k]:setTextColor("FF7DD6FF")
					widgets["attr"..i.."_"..k.."_value"]:setTextColor("FF7DD6FF")
				end
			end
			widgets.resetBtn:show()
		end
	end
end

function wnd_destinyRoll:onChoose(sender, id)
	local fiveTrans = g_i3k_game_context:getFiveTrans()
	local totalPoint = i3k_db_five_trans[fiveTrans.level].destinyCount
	local leftPoint = totalPoint - self:getChosenPoint()
	
	if fiveTrans.liftWheel[id] then
			
	elseif leftPoint <= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1379))
	else	
		i3k_sbean.fiveTransform_choose_attr(id)
	end
end

function wnd_destinyRoll:onReset(sender)
	local callback = function(ok)
			if ok then
				i3k_sbean.fiveTransform_reset_attr()
			end 
		end
	 g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(1380), callback)
end

function wnd_destinyRoll:afterChoose(id)
	g_i3k_game_context:SetPrePower()
	g_i3k_game_context:addDestinyRollPoint(id)
	local hero = i3k_game_get_player_hero()
	if hero then
		hero:UpdateDestinyRollProp()
	end
	self:refresh()
	g_i3k_game_context:ShowPowerChange()
end

function wnd_destinyRoll:afterReset()
	g_i3k_game_context:SetPrePower()
	g_i3k_game_context:resetDestinyRollPoint()
	local hero = i3k_game_get_player_hero()
	if hero then
		hero:UpdateDestinyRollProp()
	end
	self:refresh()
	g_i3k_game_context:ShowPowerChange()
end

function wnd_destinyRoll:getChosenPoint()
	local num = 0
	local fiveTrans = g_i3k_game_context:getFiveTrans()
	for i,v in pairs(fiveTrans.liftWheel) do
		if v then
			num = num + 1
		end
	end
	return num
end
	
function wnd_create(layout, ...)
	local wnd = wnd_destinyRoll.new();
		wnd:create(layout, ...);
	return wnd;
end
