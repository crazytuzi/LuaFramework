TipsMarketRemindView = TipsMarketRemindView or BaseClass(BaseView)

function TipsMarketRemindView:__init()
	self.ui_config = {"uis/views/tips/markettips_prefab", "MarketRemindTips"}
	self.view_layer = UiLayer.MainUI
end

function TipsMarketRemindView:__delete()

end

-- 创建完调用
function TipsMarketRemindView:LoadCallBack()
	self.remind_toggle = self:FindObj("RemindToggle")
	self.remind_toggle.toggle.isOn = false		--今日提醒默认为false
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("Item"))
	self.fight_power_text = self:FindVariable("FightPowerText")

	self:ListenEvent("OnClickGo", BindTool.Bind(self.OnClickGoMarket, self))
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
end

function TipsMarketRemindView:ReleaseCallBack()
	self:ClearCountDown()

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self.remind_toggle = nil
	self.fight_power_text = nil
end

function TipsMarketRemindView:OpenCallBack()
	self:Flush()
end

function TipsMarketRemindView:CloseCallBack()
	if self.remind_toggle.toggle.isOn then
		local cur_day = TimeCtrl.Instance:GetCurOpenServerDay()
		local main_role_id = GameVoManager.Instance:GetMainRoleVo().role_id
		UnityEngine.PlayerPrefs.SetInt(main_role_id..RemindName.MarketTips, cur_day)
	end
end

function TipsMarketRemindView:OnClickClose()
	self:Close()
end

function TipsMarketRemindView:OnClickGoMarket()
	ViewManager.Instance:Open(ViewName.Market)
	self:Close()
end

function TipsMarketRemindView:OnFlush()
	local item_data = MarketData.Instance:GetMarketNoticeGoodItem()
	if nil ~= next(item_data) then
		self.item_cell:SetData({item_id = item_data.item_id})
		self.item_cell:SetShowStar(item_data.star)

		local item_cfg = ItemData.Instance:GetItemConfig(item_data.item_id)
		local fight_power = CommonDataManager.GetCapability(item_cfg) or 0
		self.fight_power_text:SetValue(fight_power)
	end

	self:ClearCountDown()
	self.close_count_down = CountDown.Instance:AddCountDown(20, 1, BindTool.Bind(self.CloseCountDown, self))	--自动关闭时间定为20秒
end

function TipsMarketRemindView:CloseCountDown(elapse_time, total_time)
	if elapse_time >= total_time then
		if self.close_count_down then
			CountDown.Instance:RemoveCountDown(self.close_count_down)
			self.close_count_down = nil
		end
		self:Close()
	end
end

function TipsMarketRemindView:ClearCountDown()
	if self.close_count_down then
		CountDown.Instance:RemoveCountDown(self.close_count_down)
		self.close_count_down = nil
	end
end