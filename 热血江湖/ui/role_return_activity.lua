-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_role_return_activity = i3k_class("wnd_role_return_activity", ui.wnd_base)


local LAYERTITLE = "ui/widgets/czhdt"
local LAYERLOGIN = "ui/widgets/huiguidenglu"
local LAYERLIBAO = "ui/widgets/huiguilibao"
local LAYERDENGLU = "ui/widgets/lianxudenglut"
local LAYERZHEKOU = "ui/widgets/xianshilibaot"


local dayText = 
{
	[1] = "第一天", [2] = "第二天", [3] = "第三天", [4] = "第四天", [5] = "第五天", [6] = "第六天", [7] = "第七天",
}

function wnd_role_return_activity:ctor()
	self._state = 1
	self.needDiamond = 0
	self._timeCounter = 0
	self.activity =
	{
		[1] = {title = "七日登陆", clickFunc = self.onSevenLogin},
		[2] = {title = "折扣礼包", clickFunc = self.onDiscount},
	}
end

function wnd_role_return_activity:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseBtn)
end

function wnd_role_return_activity:refresh()
	self:updateLeftList()--更新左侧列表
	if self._state == 1 then
		self:onSevenLogin(nil, self._state)
	elseif self._state == 2 then
		self:onDiscount(nil, self._state)
	end
end

function wnd_role_return_activity:changeContentSize(control)
	local size = self._layout.vars.RightView:getContentSize()
	control.rootVar:setContentSize(size.width, size.height)
end

function wnd_role_return_activity:updateRightView(control)
	local AddChild = self._layout.vars.RightView:getAddChild()
	for i,v in ipairs (AddChild) do
		self._layout.vars.RightView:removeChild(v)
	end
	self._layout.vars.RightView:addChild(control)
end

function wnd_role_return_activity:updateLeftList()
	local day = self:judgeDay()
	local scroll = self._layout.vars.ActivitiesList
	scroll:removeAllChildren()
	for k, v in ipairs(self.activity) do
		if k == 2 then
			for i, j in pairs(i3k_db_role_return.consume) do
				if i == day then
					local _layer = require(LAYERTITLE)()
					scroll:addItem(_layer)
					_layer.vars.TitleName:setText(v.title)
					_layer.vars.bt:onClick(self, v.clickFunc, k)
				end
			end
		else
			local _layer = require(LAYERTITLE)()
			scroll:addItem(_layer)
			_layer.vars.TitleName:setText(v.title)
			_layer.vars.bt:onClick(self, v.clickFunc, k)
		end
	end
	self.scroll = scroll
	self:updateBtn()
end

function wnd_role_return_activity:updateBtn()
	local layer = self.scroll:getAllChildren()
	for k, v in ipairs(layer) do
		if self._state == k then
			v.vars.bt:stateToPressed()
		else
			v.vars.bt:stateToNormal()
		end
	end
	self:updateTime()
end

function wnd_role_return_activity:onSevenLogin(sender, state)
	self._state = state
	local info = g_i3k_game_context:getRoleReturnInfo()
	local control = require(LAYERLOGIN)()
	self:updateRightView(control)
	self:changeContentSize(control)
	self._widget = control
	local scroll = control.vars.ExchangeGiftList
	scroll:removeAllChildren()
	for k, v in ipairs(i3k_db_role_return.login_reward) do
		local day = self:judgeDay()
		local layer = require(LAYERDENGLU)()
		layer.vars.GoalContent:setText(dayText[k])
		if k == day then
			layer.vars.GetBtn:show()
			layer.vars.GetBtnText:setText("领取")
			layer.vars.GetBtn:onClick(self, self.onGetBtn, day)
			layer.vars.GetImage:hide()
		else
			layer.vars.GetBtn:show()
			layer.vars.GetBtnText:setText("未达标")
			layer.vars.GetBtn:disableWithChildren()
			layer.vars.GetImage:hide()
		end
		if info.loginGift then
			for i, j in pairs(info.loginGift) do
				if i == k then
					layer.vars.GetImage:show()
					layer.vars.GetBtn:hide()
					break
				end
			end
		end
		self:addReturnItem(layer, v.items)
		scroll:addItem(layer)
	end
	self:updateBtn()
end

function wnd_role_return_activity:addReturnItem(layer, gifts)
	local items =
	{
		[1] = {icon = layer.vars.item_icon, suo = layer.vars.item_suo, count = layer.vars.item_count, iconBg = layer.vars.item_bg, bianKuang = layer.vars.alreadyGet1},
		[2] = {icon = layer.vars.item_icon2, suo = layer.vars.item_suo2, count = layer.vars.item_count2, iconBg = layer.vars.item_bg2, bianKuang = layer.vars.alreadyGet2},
		[3] = {icon = layer.vars.item_icon3, suo = layer.vars.item_suo3, count = layer.vars.item_count3, iconBg = layer.vars.item_bg3, bianKuang = layer.vars.alreadyGet3},
	}
	for k, v in ipairs(gifts) do
		items[k].iconBg:show()
		items[k].iconBg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		items[k].icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id))
		if v.id == 2 then
			local count = v.count/10000
			items[k].count:setText(count.."万")
		else
			items[k].count:setText(v.count)
		end
		if v.id > 0 then
			items[k].suo:show()
		else
			items[k].suo:hide()
		end
		items[k].icon:onClick(self, self.onItem, v.id)
	end
end

function wnd_role_return_activity:onItem(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_role_return_activity:onDiscount(sender, state)
	self._state = state
	local info = g_i3k_game_context:getRoleReturnInfo()
	local day = self:judgeDay()
	local control = require(LAYERLIBAO)()
	self:updateRightView(control)
	self:changeContentSize(control)
	self._widget = control
	for i, j in pairs(info.dailyDiscount) do
		if i == day then
			control.vars.buyBtn:disableWithChildren()
		end
	end
	local scroll = control.vars.GradeGiftList
	for k, v in pairs(i3k_db_role_return.consume) do
		if day == k then
			self:addConsume(scroll, v.consume_item)
			control.vars.needDiamond:setText("x"..v.need_diamond)
			self.needDiamond = v.need_diamond
			break
		end
	end
	control.vars.buyBtn:onClick(self, self.onBuyBtn, day)
	self:updateBtn()
end

function wnd_role_return_activity:onBuyBtn(sender, day)
	local diamond = g_i3k_game_context:GetDiamondCanUse(true)
	if diamond < self.needDiamond then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(4118))
	else
		local callback = function()
			i3k_sbean.sync_regression(function()
				local itemData = {}
				for k, v in ipairs(i3k_db_role_return.consume[day].consume_item) do
					table.insert(itemData, {id = v.id, count = v.count})
				end
				g_i3k_ui_mgr:OpenUI(eUIID_UseItemGainMoreItems)
				g_i3k_ui_mgr:RefreshUI(eUIID_UseItemGainMoreItems, itemData)
				g_i3k_game_context:UseDiamond(self.needDiamond, true, AT_FLASHSALE_GOODS)
				g_i3k_ui_mgr:RefreshUI(eUIID_RoleReturnActivity)
			end)
		end
		i3k_sbean.buy_regression_daily_discount(day, callback)
	end
end

function wnd_role_return_activity:addConsume(scroll, items)
	scroll:removeAllChildren()
	for k, v in ipairs(items) do
		local _layer = require(LAYERZHEKOU)()
		_layer.vars.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id,i3k_game_context:IsFemaleRole()))
		_layer.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		_layer.vars.item_count:setText("x"..v.count)
		_layer.vars.item_icon:onClick(self, self.onItem, v.id)
		if v.id > 0 then
			_layer.vars.suo:show()
		else
			_layer.vars.suo:hide()
		end
		scroll:addItem(_layer)
	end
end

function wnd_role_return_activity:onGetBtn(sender, day)
	i3k_sbean.take_regression_login_gift(day, function()
		i3k_sbean.sync_regression(function()
			local itemData = {}
			for k, v in ipairs(i3k_db_role_return.login_reward[day].items) do
				table.insert(itemData, {id = v.id, count = v.count})
			end
			g_i3k_ui_mgr:OpenUI(eUIID_UseItemGainMoreItems)
			g_i3k_ui_mgr:RefreshUI(eUIID_UseItemGainMoreItems, itemData)
			g_i3k_ui_mgr:RefreshUI(eUIID_RoleReturnActivity)
		end)
	end)
end

--判断今天是回归第几天
function wnd_role_return_activity:judgeDay()
	local timeState = i3k_game_get_time()
	local info = g_i3k_game_context:getRoleReturnInfo()
	local theDay = g_i3k_get_day(timeState) - g_i3k_get_day(info.regressionLogin) + 1
	return theDay
end

function wnd_role_return_activity:onCloseBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_RoleReturnActivity)
end

function wnd_role_return_activity:onUpdate(dTime)
	self._timeCounter = self._timeCounter + dTime
	if self._timeCounter > 60 then
		self:updateTime(dTime)
		self._timeCounter = 0
	end
end

function wnd_role_return_activity:updateTime(dTime)
	local maxTime = i3k_db_role_return.common.maxTime
	local info = g_i3k_game_context:getRoleReturnInfo()
	local timeState = i3k_game_get_time()
	local leftTime = maxTime + info.regressionLogin - timeState
	local day = math.floor(leftTime/86400)
	local hour = math.floor(leftTime/3600%24)
	local min = math.floor(leftTime/60%60)
	local text = day.."天"..hour.."小时"..min.."分钟"
	if self._widget then
		self._widget.vars.ActivitiesTime:setText(text)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_role_return_activity.new();
		wnd:create(layout, ...);
	return wnd;
end
