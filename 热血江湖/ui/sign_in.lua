-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_sign_in = i3k_class("wnd_sign_in",ui.wnd_base)
--月份
local monthNumber = {454,455,456,457,458,459,460,461,462,463,464,465,}
--Vip
local vipNumber = {466,467,468,469,470,471,472,473,474,475,476,477,478,479,480,}
local VIPDOUBLE = 2
local LAYER_QDT = "ui/widgets/qdt"
local RowitemCount = 6

function wnd_sign_in:ctor()
	
end
function wnd_sign_in:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	
	self.scroll = widgets.scroll
	self.month = widgets.month
	self.descLabel = widgets.desc_lab
end
function wnd_sign_in:refMonthNum(monthCfg)--刷新几月份签到
	local cfgMonth = tonumber(string.sub(monthCfg.startDay,6,7))
	self.month:setImage(g_i3k_db.i3k_db_get_icon_path(monthNumber[cfgMonth]))
end
function wnd_sign_in:getdays(checkinId)--获取当月天数
	local days = 0
	for i=1,31 do
		local day = string.format("day%s",i+1)
		if i3k_db_sign[checkinId][day] == nil or i3k_db_sign[checkinId][day].itemId == nil then
			days = i
			break
		end
	end
	return days
end
function wnd_sign_in:getItemdata(num,monthCfg)--每一个签到物品的信息
	local day = string.format("day%s",num)
	self.itemId = monthCfg[day].itemId
	self.itemCount = monthCfg[day].itemCount
	self.needVipLvl = monthCfg[day].needVipLvl
	return day
end
function wnd_sign_in:ItemInit(k,items,canCheckIn,finishedDays, id)---初始化每一个Item
		local item_btn = items.item_btn
		items.suo:setVisible(id>0)
		items.lizi:hide()
		if self.needVipLvl ~= 0 then
			items.vip_double:setImage(g_i3k_db.i3k_db_get_icon_path(vipNumber[self.needVipLvl]))
		else
			items.vip_double:hide()
		end
		if k <= finishedDays then
			items.is_sign:show()
			item_btn:disable()
			items.vip_double:setColorState(UI_COLOR_STATE_DARK)
		end
		if canCheckIn == 1 then
			if k == finishedDays+1 then
				items.lizi:show()
			end
		end
end
function wnd_sign_in:scrollinit(canCheckIn,checkinId,finishedDays,monthCfg)--初始化scroll界面
	local ary ={canCheckIn,finishedDays,monthCfg}
	local days = self:getdays(checkinId)
	local all_layer = self.scroll:addChildWithCount(LAYER_QDT,RowitemCount,days)
	local count = 0
	for k,v in ipairs(all_layer) do
		count = count + 1
		self:getItemdata(k,monthCfg)
		local day = string.format("day%s", k)
		local id = monthCfg[day].itemId
		local _layer = v
		local items = _layer.vars
		local grade = g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self.itemId)
		items.item_bg:setImage(grade)
		items.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self.itemId,i3k_game_context:IsFemaleRole()))
		items.item_count:setText(string.format("x%s", self.itemCount))
		items.item_btn:setTag(count)
		items.item_btn:onClick(self,self.onSureSign,ary)
		self:ItemInit(k,items,canCheckIn,finishedDays, id)
	end
end
function wnd_sign_in:refresh(finishedDays,checkinId,monthCfg,canCheckIn)
		self:refMonthNum(monthCfg)
		self:updateDesc(finishedDays)
		self:scrollinit(canCheckIn,checkinId,finishedDays,monthCfg)
end
function wnd_sign_in:updateDesc(num)
	local str = string.format("本月已累积签到%s次",num)
	self.descLabel:setText(str)
end
function wnd_sign_in:getAward(finishedDays,vars,awardarry)
	local callfunc = function()
		g_i3k_ui_mgr:OpenUI(eUIID_SignInAward)
		g_i3k_ui_mgr:RefreshUI(eUIID_SignInAward,awardarry)
	end
	local data = i3k_sbean.checkin_take_req.new()
	data.times = finishedDays + 1
	data.__callback = callfunc
	i3k_game_send_str_cmd(data,"checkin_take_res")	
	vars.is_sign:show()
	vars.item_btn:disable()
	vars.lizi:hide()
	if vars.vip_double then
		vars.vip_double:setColorState(UI_COLOR_STATE_DARK)
	end
end

function wnd_sign_in:isEnough(finishedDays,vars,tmp,awardarry)--判断背包是否满，并做相应修改
	local is_enough = g_i3k_game_context:IsBagEnough(tmp)
	if is_enough then 
		self:getAward(finishedDays,vars,awardarry)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(288))
	end
end
function wnd_sign_in:onSureSign(sender,ary)--点击签到相应事件
	local canCheckIn = ary[1]
	local finishedDays = ary[2]
	local monthCfg = ary[3]
	local tag = sender:getTag()
	local all_layer = self.scroll:getAllChildren()
	local vars = all_layer[tag].vars
	local vipLvl = g_i3k_game_context:GetVipLevel()
	local dayAward = self:getItemdata(tag,monthCfg)
	local awardarry = monthCfg[dayAward]
	local tmp = {}
	local count = tmp[self.itemId]
	if vipLvl >= awardarry.needVipLvl then
		self.itemCount = self.itemCount * VIPDOUBLE
	end
	count = count and count+self.itemCount or self.itemCount
	tmp[self.itemId] = count
	if  canCheckIn  == 1 then-- 1: 可以签到
		if tag ~= finishedDays+1 then
			g_i3k_ui_mgr:ShowCommonItemInfo(self.itemId)
		else
			self:isEnough(finishedDays,vars,tmp,awardarry)
		end
	else
		if tag >= finishedDays then
			g_i3k_ui_mgr:ShowCommonItemInfo(self.itemId)
		end
	end
end
--[[function wnd_sign_in:closeBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_SignIn)
end--]]
function wnd_create(layout)
	local wnd = wnd_sign_in.new()
	wnd:create(layout)
	return wnd
end
