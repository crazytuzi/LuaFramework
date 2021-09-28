GuajiTaOfflineInfoView = GuajiTaOfflineInfoView or BaseClass(BaseView)

local DEFUALT_COLOR = "#B7D3F9FF"
local RED_COLOR = "#ff0000"

function GuajiTaOfflineInfoView:__init()
	self.ui_config = {"uis/views/guajitaview_prefab", "GuajiTaOfflineInfoView"}
end

function GuajiTaOfflineInfoView:LoadCallBack()
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickBuy", BindTool.Bind(self.OnClickBuy, self))

	self.used_hour = self:FindVariable("UseHour")
	self.used_min = self:FindVariable("UseMin")
	self.rest_hour = self:FindVariable("RestHour")
	self.rest_min = self:FindVariable("RestMin")
	self.old_level = self:FindVariable("OldLevel")
	self.new_level = self:FindVariable("NewLevel")
	self.role_exp = self:FindVariable("RoleExp")
	self.rune_exp = self:FindVariable("RuneExp")
	self.mojing_num = self:FindVariable("MojingNum")
	self.rest_time_color = self:FindVariable("RestTimeColor")
	self.show_arrow = self:FindVariable("ShowArrow")

	self.get_blue_num = self:FindVariable("GetBlueEquipNum")
	self.eat_blue_num = self:FindVariable("EatBlueEquipNum")
	self.get_purple_num = self:FindVariable("GetPurpleEquipNum")
	self.eat_purple_num = self:FindVariable("EatPurpleEquipNum")
	self.get_orange_num = self:FindVariable("GetOrangeEquipNum")
	self.eat_orange_num = self:FindVariable("EatOrangeEquipNum")
end

function GuajiTaOfflineInfoView:ReleaseCallBack()
	-- 清理变量和对象
	self.used_hour = nil
	self.used_min = nil
	self.rest_hour = nil
	self.rest_min = nil
	self.old_level = nil
	self.new_level = nil
	self.role_exp = nil
	self.rune_exp = nil
	self.mojing_num = nil
	self.rest_time_color = nil
	self.show_arrow = nil
	self.get_blue_num = nil
	self.eat_blue_num = nil
	self.get_purple_num = nil
	self.eat_purple_num = nil
	self.get_orange_num = nil
	self.eat_orange_num = nil
end

function GuajiTaOfflineInfoView:OpenCallBack()
	self:Flush()
end

function GuajiTaOfflineInfoView:CloseCallBack()
end

function GuajiTaOfflineInfoView:OnClickClose()
	self:Close()
end

function GuajiTaOfflineInfoView:OnClickBuy()
	local other_cfg = GuaJiTaData.Instance:GetRuneOtherCfg()
	local rune_info = GuaJiTaData.Instance:GetRuneTowerInfo()

	local can_use = true
	if next(other_cfg) and next(rune_info) and other_cfg.offline_time_max <= rune_info.offline_time then
		can_use = false
	end

	local callback = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
		local use_flag = can_use and 1 or 0
		if not can_use then
			TipsCtrl.Instance:ShowSystemMsg(Language.Rune.OfflineLimit)
		end
		MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, use_flag)
	end
	TipsCtrl.Instance:ShowCommonBuyView(callback, GUAJI_TA_TIME_CARD_ITEM_ID, nil, 1)
	self:Close()
end

function GuajiTaOfflineInfoView:OnFlush(param_list)
	local offline_info = GuaJiTaData.Instance:GetRuneTowerOfflineInfo()
	if next(offline_info) then
		local time =  offline_info.guaji_time
		local hour = math.floor(time / 3600)
		self.used_hour:SetValue(hour)
		local min = math.floor((time - hour * 3600) / 60)
		self.used_min:SetValue(min)

		local rest_hour = math.floor(offline_info.fb_offline_time / 3600)
		local rest_min = math.floor((offline_info.fb_offline_time - rest_hour * 3600) / 60)
		self.rest_hour:SetValue(rest_hour)
		self.rest_min:SetValue(rest_min)

		local color = offline_info.fb_offline_time >= 3600 * 2 and DEFUALT_COLOR or RED_COLOR
		self.rest_time_color:SetValue(color)

		self.show_arrow:SetValue(offline_info.fb_offline_time < 3600)

		self.old_level:SetValue(self:ChangeLevel(offline_info.old_level))
		self.new_level:SetValue(self:ChangeLevel(offline_info.new_level))
		self.role_exp:SetValue(self:ChangeNum(offline_info.add_exp))
		self.rune_exp:SetValue(self:ChangeNum(offline_info.add_jinghua))
		self.mojing_num:SetValue(self:ChangeNum(offline_info.add_mojing))

		self.get_blue_num:SetValue(offline_info.add_equip_blue)
		self.eat_blue_num:SetValue(offline_info.recycl_equip_blue)

		self.get_purple_num:SetValue(offline_info.add_equip_purple)
		self.eat_purple_num:SetValue(offline_info.recycl_equip_purple)

		self.get_orange_num:SetValue(offline_info.add_equip_orange)
		self.eat_orange_num:SetValue(offline_info.recycl_equip_orange)
	end
end

function GuajiTaOfflineInfoView:ChangeLevel(level)
	if not level then return "" end

	-- local level_befor = math.floor(level % 100) ~= 0 and math.floor(level % 100) or 100
	-- local level_behind = math.floor(level % 100) ~= 0 and math.floor(level / 100) or math.floor(level / 100) - 1

	return PlayerData.GetLevelString(level)
end

function GuajiTaOfflineInfoView:ChangeNum(count)
	local count = count or 0
	if count > 99999 and count <= 99999999 then
		count = count / 10000
		count = math.floor(count)
		count = count .. "万"
	elseif count > 99999999 then
		count = count / 100000000
		count = math.floor(count)
		count = count .. "亿"
	end
	return count
end