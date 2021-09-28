-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_mercenary_revive = i3k_class("wnd_mercenary_revive",ui.wnd_base)

function wnd_mercenary_revive:ctor()
end

function wnd_mercenary_revive:configure(...)
	local arg = { ... };

	local screenSize = cc.Director:getInstance():getWinSize();
	local rootSize = self._layout.root:getContentSize();
	local widget = self._layout.vars
	
	self._mercenary_revive_index = arg[1];
	local Mercenaryrevivepanel = widget.MercenaryrevivePanel
	--local LeftTime = widget.LeftTime
	local btn1 = widget.btn1
	local btn1_text = widget.btn1_text
	local btn2 = widget.btn2
	local btn2_text = widget.btn2_text
	local costpanel1 = widget.costpanel1
	local costicon1 = widget.costicon1
	local costtext1 = widget.costtext1
	local costpanel2 = widget.costpanel2
	local costicon2 = widget.costicon2
	local costtext2 = widget.costtext2
	
	
	--if btn1_text then btn1_text:setText("原地复活"); end
	--if btn2_text then btn2_text:setText("复活点复活"); end
	--if btn3_text then btn3_text:setText("退出副本"); end

	if btn1 then btn1:onTouchEvent(self,self.onbtn1) end
	if btn2 then btn2:onTouchEvent(self,self.onbtn2) end
	--if btn3 then btn3:onTouchEvent(self,self.onbtn3) end
	widget.exitbtn:onClick(self,self.onCloseUI)
	--此变量需传入，临时测试使用
	
end


function wnd_mercenary_revive:onbtn1(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local logic = i3k_game_get_logic();
		if logic then
			local world = logic:GetWorld();
			if world then
				local player = logic:GetPlayer();
				local Mercenary = player:GetMercenary(self._mercenary_revive_index);
				local guid = string.split(Mercenary._guid, "|")								
				local cfgID = tonumber(guid[2])
				--local bean = i3k_sbean.pet_revive_req.new();
				--bean.petId = cfgID; 
				--bean.useStone = 1;
				--i3k_game_send_str_cmd(bean, i3k_sbean.pet_revive_res.getName())
			end
		end
	end
end

function wnd_mercenary_revive:onbtn2(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		local logic = i3k_game_get_logic();
		if logic then
			local world = logic:GetWorld();
			if world then
				local player = logic:GetPlayer();
				local Mercenary = player:GetMercenary(self._mercenary_revive_index);
				local guid = string.split(Mercenary._guid, "|")								
				local cfgID = tonumber(guid[2])
				--local bean = i3k_sbean.pet_revive_req.new();
				--bean.petId = cfgID; 
				--bean.useStone = 0;
				--i3k_game_send_str_cmd(bean, i3k_sbean.pet_revive_res.getName())
			end
		end
	end
end	


function wnd_mercenary_revive:onShow()
	local logic = i3k_game_get_logic();
	local MercenaryrevivePanel = self._layout.vars.MercenaryrevivePanel
	local costpanel1 = self._layout.vars.costpanel1
	local costpanel2 = self._layout.vars.costpanel2
	local costtext1 = self._layout.vars.costtext1
	local costtext2 = self._layout.vars.costtext2
	local cfg = i3k_db_common.mercenaryrevive
	local Money = 0;
	local DMoney = 0;
	local starlvl = 0;
	local lvl = 0;
	local logic = i3k_game_get_logic();
	if logic then
		local world = logic:GetWorld();
		if world then
			local player = logic:GetPlayer();
			local Mercenary = player:GetMercenary(self._mercenary_revive_index);
			local guid = string.split(Mercenary._guid, "|")
			local allData,PlayData,OtherData = g_i3k_game_context:GetYongbingData()
			local Detail = allData[tonumber(guid[2])]
			starlvl = Detail.starlvl
			lvl = Detail.level
		end
	end
	DMoney = cfg.Money
	Money = (cfg.arg2+cfg.arg1*starlvl)*(cfg.arg3+lvl*cfg.arg4)
	costtext1:setText(DMoney)
	costtext2:setText(Money)
	MercenaryrevivePanel:show()
	costpanel1:show()
	costpanel2:show()
end

function wnd_mercenary_revive:onHide()
	local MercenaryrevivePanel = self._layout.vars.MercenaryrevivePanel
	MercenaryrevivePanel:hide()
end

function wnd_mercenary_revive:onUpdate(dTime)

end

--[[function wnd_mercenary_revive:onClose(sender,eventType)
	if eventType ==ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_MercenaryRevive)
	end
end--]]


function wnd_mercenary_revive:updateTimeElapse(time, color)
	local formatTime = function(time)
		local tm = time;

		local h = i3k_integer(tm / (60 * 60));
		tm = tm - h * 60 * 60;

		local m = i3k_integer(tm / 60);
		tm = tm - m * 60;

		local s = tm;

		return string.format("%02d:%02d:%02d", h, m, s);
	end

	local ui = self._layout.vars.LeftTime;
	if ui then
		ui:setText(formatTime(time));
		ui:setTextColor(color);
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_mercenary_revive.new()
		wnd:create(layout, ...)
	return wnd
end
