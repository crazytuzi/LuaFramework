TipsQuickCompletionView = TipsQuickCompletionView or BaseClass(BaseView)
function TipsQuickCompletionView:__init()
	self.ui_config = {"uis/views/tips/quickcompletiontip_prefab", "QuickCompletionTip"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self.pinzhi = -1
end

function TipsQuickCompletionView:LoadCallBack()
	self:ListenEvent("CloseWindow",	
		BindTool.Bind(self.CloseWindow, self))

	self:ListenEvent("ClickOk",
		BindTool.Bind(self.ClickOk, self))

	self.des = self:FindVariable("des")
	self.show_pinzhi = self:FindVariable("show_pinzhi")
	self.xingzuo_show = self:FindVariable("xingzuo_show")
	self.ok_des = self:FindVariable("OkDes")
	self.canel_des = self:FindVariable("CanelDes")
	self.title_name = self:FindVariable("title_name")
	self.is_show_ok = self:FindVariable("is_show_ok")
	self.show_des = self:FindVariable("show_des")

	self.dropdown = self:FindObj("dropdown").dropdown
	self.dropdown_2 = self:FindObj("dropdown_2").dropdown

	self:ListenEvent("auto_pick_value_change", BindTool.Bind(self.AutoPickValueChange,self))
end

function TipsQuickCompletionView:ReleaseCallBack()
	-- 清理变量和对象
	self.des = nil
	self.show_pinzhi = nil
	self.ok_des = nil
	self.canel_des = nil
	self.title_name = nil
	self.pinzhi = nil
	self.is_show_ok = nil
	self.show_des = nil
	self.dropdown = nil
	self.dropdown_2 = nil
	self.xingzuo_show = nil
end

function TipsQuickCompletionView:OpenCallBack()
	self.dropdown.value = 0
	self.dropdown_2.value = 1
	self:Flush()
end

function TipsQuickCompletionView:CloseCallBack()
	self.ok_callback = nil
	self.canel_callback = nil
end

function TipsQuickCompletionView:CloseWindow()
	self.is_auto = false
	if self.canel_callback then
		self.canel_callback()
	end
	self:Close()
end

function TipsQuickCompletionView:SetTitle(title_name)
	self.title_str = title_name ~= "" and title_name or Language.Common.Remind
end

function TipsQuickCompletionView:SetDesShow(value)
	self.show_des_value = value
end

function TipsQuickCompletionView:SetDes(des)
	self.des_str = des
end

function TipsQuickCompletionView:SetOkCallBack(callback)
	self.ok_callback = callback
end

function TipsQuickCompletionView:SetCanelCallBack(callback)
	self.canel_callback = callback
end

function TipsQuickCompletionView:ShowPinZhi(value)
	self.show_pinzhi_str = value
end

function TipsQuickCompletionView:ShowMoLong(value)
	self.show_mo_long_str = value
end

function TipsQuickCompletionView:SetIsShowOk(value)
	self.is_show_ok_str = value
end

function TipsQuickCompletionView:SetType(value)
	if value == nil then
		self.show_pinzhi_str = false
		self.show_mo_long_str = false
		return
	end
	self.type = value
	-- if self.type == SKIP_TYPE.SKIP_TYPE_XINGZUOYIJI then
	-- 	self:ShowMoLong(true)
	-- else
	self:ShowPinZhi(true)
	--end
	if self.type == SKIP_TYPE.SKIP_TYPE_XINGZUOYIJI then
		self:GetMoLong(0)
	elseif self.type == SKIP_TYPE.SKIP_TYPE_SAILING then
		self:GetMiningSea(0)
	elseif self.type == SKIP_TYPE.SKIP_TYPE_MINE then
		self:GetMiningMine(0)
	elseif self.type == SKIP_TYPE.SKIP_TYPE_FISH then
		self:GetFishing(0)
	end
end

function TipsQuickCompletionView:SetBtnDes(ok_des, canel_des)
	self.ok_str = ok_des or Language.Common.Confirm
	self.canel_str = canel_des or Language.Common.Cancel
end

function TipsQuickCompletionView:ClickOk()
	if self.ok_callback then
		self.ok_callback()
	end
	self:Close()
end

function TipsQuickCompletionView:OnFlush()
	self.title_name:SetValue(self.title_str)
	self.show_des:SetValue(self.show_des_value)
	self.des:SetValue(self.des_str)
	self.ok_des:SetValue(self.ok_str)
	self.canel_des:SetValue(self.canel_str)
	if self.is_show_ok_str ~= nil then
		self.is_show_ok:SetValue(self.is_show_ok_str)
	end

	if self.show_mo_long_str ~= nil then
		self.xingzuo_show:SetValue(self.show_mo_long_str)
	end

	if self.show_pinzhi_str ~= nil then
		self.show_pinzhi:SetValue(self.show_pinzhi_str)
	end
end

function TipsQuickCompletionView:AutoPickValueChange(value)
	--if value > 0 then
		if self.type == SKIP_TYPE.SKIP_TYPE_XINGZUOYIJI then
			self:GetMoLong(value)
		elseif self.type == SKIP_TYPE.SKIP_TYPE_SAILING then
			self:GetMiningSea(value)
		elseif self.type == SKIP_TYPE.SKIP_TYPE_MINE then
			self:GetMiningMine(value)
		elseif self.type == SKIP_TYPE.SKIP_TYPE_FISH then
			self:GetFishing(value)
		end
	--end
	self:Flush()
end

function TipsQuickCompletionView:SetInitText()
	local str = string.format(Language.QuickCompletion[self.type], 0, 0, 0)
	self:SetDesShow(true)
	self:SetDes(str)
end

----------------------------特殊处理函数------------------------------
-- -- 星座遗迹
-- function TipsQuickCompletionView:GetMoLong(value)
-- 	local gahter_count = RelicData.Instance:GetNowGatherNormalBoxNum()
-- 	local cfg = RelicData.Instance:GetRelicCfg().other[1]
-- 	local num = cfg.common_box_gather_limit - gahter_count
-- 	local consume = RelicData.Instance:GetConsume(value)

-- 	local gold = num * consume
-- 	local str = string.format(Language.QuickCompletion[SKIP_TYPE.SKIP_TYPE_XINGZUOYIJI], gold,num)

-- 	self:SetDesShow(true)
-- 	self:SetDes(str)
-- 	-- self.show_mo_long_str = false
-- 	self.is_show_ok_str = true
-- 	local ok_callback = function ()
-- 		MarriageCtrl.Instance:SendCSSkipReq(SKIP_TYPE.SKIP_TYPE_XINGZUOYIJI, value)
-- 	end
-- 	self:SetOkCallBack(ok_callback)
-- end

-- 航海
function TipsQuickCompletionView:GetMiningSea(value)
	local sea_day_times = MiningData.Instance:GetMiningSeaDayTimes()
	local sea_rob_times = MiningData.Instance:GetMiningSeaRobTimes()
	local consume = MiningData.Instance:GetConsume(value, 0)
	local consume2 = MiningData.Instance:GetConsume(-1, 4)
	local gold = (sea_day_times * consume) + (sea_rob_times * consume2)

	local str = string.format(Language.QuickCompletion[SKIP_TYPE.SKIP_TYPE_SAILING], gold,sea_day_times, sea_rob_times)

	self:SetDesShow(true)
	self:SetDes(str)
	-- self.show_pinzhi_str = false
	self.is_show_ok_str = true
	local ok_callback = function ()
		MarriageCtrl.Instance:SendCSSkipReq(SKIP_TYPE.SKIP_TYPE_SAILING, value)
	end
	self:SetOkCallBack(ok_callback)
end

-- 挖矿
function TipsQuickCompletionView:GetMiningMine(value)
	local mine_day_times = MiningData.Instance:GetMiningMineDayTimes()
	local mine_rob_times = MiningData.Instance:GetMiningMineRobTimes()
	local consume = MiningData.Instance:GetConsume(value, 0)
	local consume2 = MiningData.Instance:GetConsume(-1, 3)
	local gold = (mine_day_times * consume) + (mine_rob_times * consume2)


	local str = string.format(Language.QuickCompletion[SKIP_TYPE.SKIP_TYPE_MINE], gold,mine_day_times,mine_rob_times)

	self:SetDesShow(true)
	self:SetDes(str)
	-- self.show_pinzhi_str = false
	self.is_show_ok_str = true
	local ok_callback = function ()
		MarriageCtrl.Instance:SendCSSkipReq(SKIP_TYPE.SKIP_TYPE_MINE, value)
	end
	self:SetOkCallBack(ok_callback)
end

-- 捕鱼
function TipsQuickCompletionView:GetFishing(value)
	local farm_fish_times = FishingData.Instance:GetFarmFishTimes()
	local bullet_num = FishingData.Instance:GetLeftBulletNum()
	local consume = FishingData.Instance:GetSkipCfgByType(value).consume
	local consume2 = FishingData.Instance:GetSkipCfgByType(-1).consume
	local gold = (farm_fish_times * consume) + (bullet_num * consume2)

	local str = string.format(Language.QuickCompletion[SKIP_TYPE.SKIP_TYPE_FISH], gold,farm_fish_times,bullet_num)

	self:SetDesShow(true)
	self:SetDes(str)
	-- self.show_pinzhi_str = false
	self.is_show_ok_str = true
	local ok_callback = function ()
		MarriageCtrl.Instance:SendCSSkipReq(SKIP_TYPE.SKIP_TYPE_FISH, value)
	end
	self:SetOkCallBack(ok_callback)
end
