-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_lucky_wheel_buy_count = i3k_class("wnd_lucky_wheel_buy_count",ui.wnd_base)

local BASE_COUNT = 1
local MAX_COUNT = 0
local HAVECOUNT = 0
local roleAllSkillData = nil


function wnd_lucky_wheel_buy_count:ctor()
	self._money_count = 0
end

function wnd_lucky_wheel_buy_count:configure()
	
end

function wnd_lucky_wheel_buy_count:refresh( data )
	roleAllSkillData = data
	self:setData()
end

function wnd_lucky_wheel_buy_count:setData()
	
	BASE_COUNT = 1
	local widgets = self._layout.vars
	local buy_count = roleAllSkillData.dayBuyCount -- 已经购买的次数
	self._layout.vars.desc2:hide()
	local total_count = i3k_db_lucky_wheel.limitBuyTime
	
	MAX_COUNT = total_count
	local have_count  = g_i3k_game_context:GetLuckyWheelBuyTime()--剩余购买次数
	HAVECOUNT = have_count
	widgets.desc1:setText(string.format("本日您还可以购买%d%s",have_count,"次"))
	self._money_count = i3k_db_lucky_wheel.needGold[buy_count +1]
	widgets.money_count:setText(self._money_count )
	
	widgets.sale_count:setText(BASE_COUNT.."/"..HAVECOUNT)
	
	widgets.cancel_btn:onClick(self,self.onCancel)
	widgets.ok_btn:onClick(self,self.onOk)
	widgets.jian_btn:onClick(self,self.onJian)
	widgets.jia_btn:onClick(self,self.onJia)
	widgets.max_btn:onClick(self,self.onMax)
	
end

function wnd_lucky_wheel_buy_count:onCancel(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_LuckyWheel_buy_count)
end

function wnd_lucky_wheel_buy_count:onOk(sender)
	--判断元宝是否足够
	
	local haveDiamond_binding = g_i3k_game_context:GetDiamond(false)--绑定
	local haveDiamond = g_i3k_game_context:GetDiamond(true)--true非绑定
	if g_i3k_game_context:GetDiamondCanUse(false) >= self._money_count then--g_i3k_game_context:GetDiamondCanUse(false)绑定和非绑定总和
		
		if haveDiamond_binding >= self._money_count then--绑定元宝足够时
			i3k_sbean.activities_luckywheel_buy(BASE_COUNT, self._money_count)
		else--绑定元宝不够时
			local callfunction = function(ok)
				if ok then
					i3k_sbean.activities_luckywheel_buy(BASE_COUNT, self._money_count)
				end
			end
			
			local have = g_i3k_game_context:GetBaseItemCount(g_BASE_ITEM_DIAMOND)
			local msg = ""
			if have == 0 then
				msg = i3k_get_string(217,self._money_count)
			else
				msg = i3k_get_string(299,have,(self._money_count-have))
			end
			g_i3k_ui_mgr:ShowCustomMessageBox2("购买", "取消", msg, callfunction)
		end
	else
		local tips = string.format("%s", "您的元宝不足，购买失败")
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(359))
	end
end

function wnd_lucky_wheel_buy_count:onJian(sender)
	BASE_COUNT = BASE_COUNT -1
	if BASE_COUNT < 1 then
		BASE_COUNT = 1
	end
	
	self._money_count = g_i3k_game_context:getBuyLuckyWheelNeedMoney(BASE_COUNT,roleAllSkillData.dayBuyCount)
	self._layout.vars.sale_count:setText(BASE_COUNT.."/"..MAX_COUNT)
	self._layout.vars.money_count:setText(self._money_count)
end

function wnd_lucky_wheel_buy_count:onJia(sender)
	BASE_COUNT = BASE_COUNT + 1
	if BASE_COUNT > HAVECOUNT then
		BASE_COUNT = HAVECOUNT
	end
	
	self._money_count = g_i3k_game_context:getBuyLuckyWheelNeedMoney(BASE_COUNT,roleAllSkillData.dayBuyCount)
	self._layout.vars.sale_count:setText(BASE_COUNT.."/"..MAX_COUNT)
	self._layout.vars.money_count:setText(self._money_count)
end

function wnd_lucky_wheel_buy_count:onMax(sender)
	BASE_COUNT = HAVECOUNT
	self._money_count = g_i3k_game_context:getBuyLuckyWheelNeedMoney(BASE_COUNT,roleAllSkillData.dayBuyCount)
	
	self._layout.vars.sale_count:setText(BASE_COUNT.."/"..MAX_COUNT)
	self._layout.vars.money_count:setText(self._money_count)
end

function wnd_lucky_wheel_buy_count:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_LuckyWheel_buy_count)
end

function wnd_create(layout)
	local wnd = wnd_lucky_wheel_buy_count.new();
	wnd:create(layout);
	return wnd;
end
