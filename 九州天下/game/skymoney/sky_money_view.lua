SkyMoneyView = SkyMoneyView or BaseClass(BaseView)

function SkyMoneyView:__init()
	self.ui_config = {"uis/views/skymoney", "SkyMoneyView"}
	self.play_audio = true
	self.item_cells = {}
end

function SkyMoneyView:__delete()
	for k, v in pairs(self.item_cells) do
		if v.item_cell then
			v.item_cell:DeleteMe()
		end
	end
	self.item_cells = {}
end

function SkyMoneyView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("Enter", BindTool.Bind(self.OnClickEnter, self))
	self:ListenEvent("Help", BindTool.Bind(self.OnClickHelp, self))

	self.level = self:FindVariable("Level")
	self.start_time = self:FindVariable("StartTime")
	self.end_time = self:FindVariable("EndTime")

	local item_cfg = ConfigManager.Instance:GetAutoConfig("activitytianjiangcaibao_auto").task_reward[1]

	for i = 1, 4 do
		local item_obj = self:FindObj("Item"..i)
		local item_cell = ItemCell.New(item_obj)
		local data = {item_id = item_cfg["reward_item"..i].item_id}
		item_cell:SetData(data)
		self.item_cells[i] = {item_obj = item_obj, item_cell = item_cell}
	end

	self:Flush()
end

function SkyMoneyView:ReleaseCallBack()
	for k, v in pairs(self.item_cells) do
		if v.item_cell then
			v.item_cell:DeleteMe()
		end
	end
	self.item_cells = {}

	-- 清理变量和对象
	self.level = nil
	self.start_time = nil
	self.end_time = nil
end

function SkyMoneyView:OnClickClose()
	self:Close()
end

function SkyMoneyView:OnClickEnter()
	ActivityCtrl.Instance:SendActivityEnterReq(ACTIVITY_TYPE.TIANJIANGCAIBAO, 0)
	self:Close()
end

function SkyMoneyView:OnClickHelp()

end

function SkyMoneyView:OnFlush(param_t)
	local cfg =  ActivityData.Instance:GetClockActivityByID(SkyMoneyDataId.Id)
	self.start_time:SetValue(cfg.open_time)
	self.end_time:SetValue(cfg.end_time)
	self.level:SetValue(cfg.min_level)
end