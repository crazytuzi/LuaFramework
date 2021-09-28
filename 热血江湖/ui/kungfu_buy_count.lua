-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_kungfu_buy_count = i3k_class("wnd_kungfu_buy_count", ui.wnd_base)


local moneyID = 2

local BASE_COUNT = 1
local MAX_COUNT = 0
local HAVECOUNT = 0
local roleAllSkillData = nil

function wnd_kungfu_buy_count:ctor()
	BASE_COUNT = 1
	self.needMoney = nil
end

function wnd_kungfu_buy_count:configure()
	local widgets = self._layout.vars

	widgets.cancel_btn:onClick(self,self.onCancel)
	widgets.ok_btn:onClick(self,self.onOk)
	widgets.jian_btn:onClick(self,self.onJian)
	widgets.jia_btn:onClick(self,self.onJia)
	widgets.max_btn:onClick(self,self.onMax)
end

function wnd_kungfu_buy_count:refresh( data )
    roleAllSkillData = data
    self:setData()
end

function wnd_kungfu_buy_count:setData()

	local buy_count = roleAllSkillData.dayBuyCount -- 已经购买的次数
	local _viplvl =g_i3k_game_context:GetVipLevel()
	local desc1 = self._layout.vars.desc1
	local desc2 = self._layout.vars.desc2
	local total_count = i3k_db_kungfu_vip[_viplvl].count
	local next_total = 0

	local now_addCount = i3k_db_kungfu_vip[_viplvl ].count
	local tmp_vip = _viplvl
	local next_addCount = 0
	while i3k_db_kungfu_vip[tmp_vip + 1] do
		next_addCount = i3k_db_kungfu_vip[tmp_vip + 1].count
		tmp_vip = tmp_vip + 1
		if next_addCount > now_addCount then
			break
		end
	end

	if next_addCount ~= 0 and next_addCount > now_addCount  then
		if desc2 then
			desc2:show()
			desc2:setText(string.format("升级至贵族%d%s%d%s",tmp_vip,"：每日可购买",next_addCount,"次"))
		end
	else
		if desc2 then
			desc2:hide()
		end
	end
	MAX_COUNT = total_count
	local have_count  = total_count - buy_count
	HAVECOUNT = have_count
	desc1:setText(string.format("本日您还可以购买%d%s",have_count,"次"))
	local money_count = self._layout.vars.money_count
	self.needMoney = i3k_db_kungfu_vip[_viplvl].money[buy_count +1]
	money_count:setText(self.needMoney)
	local sale_count = self._layout.vars.sale_count
	sale_count:setText(BASE_COUNT.."/"..MAX_COUNT)
end

function wnd_kungfu_buy_count:onCancel(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_KungfuBuyCount)
end

function wnd_kungfu_buy_count:onOk(sender)
	if g_i3k_game_context:GetDiamondCanUse(false) >= self.needMoney then
		i3k_sbean.diyskill_buytimes(BASE_COUNT, self.needMoney)
	else
		g_i3k_ui_mgr:PopupTipMessage("元宝不足，够买失败")
	end
end

function wnd_kungfu_buy_count:onJian(sender)
	BASE_COUNT = BASE_COUNT -1
	if BASE_COUNT < 1 then
		BASE_COUNT = 1
	end

	self.needMoney = g_i3k_game_context:getBuyCreateKungfuNeedMoney(BASE_COUNT,roleAllSkillData)
	local sale_count = self._layout.vars.sale_count
	sale_count:setText(BASE_COUNT.."/"..MAX_COUNT)
	local money_count = self._layout.vars.money_count
	money_count:setText(self.needMoney)
end

function wnd_kungfu_buy_count:onJia(sender)
	BASE_COUNT = BASE_COUNT + 1
	if BASE_COUNT > HAVECOUNT then
		BASE_COUNT = HAVECOUNT
	end

	self.needMoney = g_i3k_game_context:getBuyCreateKungfuNeedMoney(BASE_COUNT,roleAllSkillData)
	local sale_count = self._layout.vars.sale_count
	sale_count:setText(BASE_COUNT.."/"..MAX_COUNT)
	local money_count = self._layout.vars.money_count
	money_count:setText(self.needMoney)
end

function wnd_kungfu_buy_count:onMax(sender)
	BASE_COUNT = HAVECOUNT
	self.needMoney = g_i3k_game_context:getBuyCreateKungfuNeedMoney(BASE_COUNT,roleAllSkillData)
	local sale_count = self._layout.vars.sale_count
	sale_count:setText(BASE_COUNT.."/"..MAX_COUNT)
	local money_count = self._layout.vars.money_count
	money_count:setText(self.needMoney)
end

function wnd_kungfu_buy_count:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_KungfuBuyCount)
end

function wnd_create(layout)
	local wnd = wnd_kungfu_buy_count.new();
		wnd:create(layout);
	return wnd;
end
