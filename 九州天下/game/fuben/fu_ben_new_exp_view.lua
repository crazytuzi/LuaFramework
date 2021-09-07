FuBenNewExpView = FuBenNewExpView or BaseClass(BaseRender)

function FuBenNewExpView:__init(instance)
	self.day_num = self:FindVariable("Day_Num")
	self.item_num = self:FindVariable("Item_Num")
	self.item_name = self:FindVariable("Item_Name")
	self.show_red_point = self:FindVariable("ShowRedPoint")

	for i=1,3 do
		self["towerdes"..i] = self:FindVariable("TowerDes" .. i)
		self["towerdes"..i]:SetValue(Language.Dungeon.TowerDes[i])
	end

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ReItemCell"))
	self.item_cell:SetData({item_id = 90050}, {num = 0}, {is_bind = 1})

	self:ListenEvent("OnClickContinue", BindTool.Bind(self.OnClickContinue, self))

	--引导用按钮
	self.get_ui_callback = BindTool.Bind(self.GetUiCallBack, self)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FuBen, self.get_ui_callback)

	self:Flush()
end

function FuBenNewExpView:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUiByFun(ViewName.FuBen, self.get_ui_callback)
	end
end

function FuBenNewExpView:OnClickContinue()
	FuBenCtrl.Instance:SendEnterFBReq(1)
end

-- 显示经验FB每日次数
function FuBenNewExpView:OnFlush()
	local day_num = FuBenData.Instance:GetExpDayCount()
	local exp_daily_fb = FuBenData.Instance:GetExpDailyFb()
	if exp_daily_fb[0].enter_item_id then
		local item_count = ItemData.Instance:GetItemNumInBagById(exp_daily_fb[0].enter_item_id)
		local item_info = ItemData.Instance:GetItemConfig(exp_daily_fb[0].enter_item_id)
		local str = string.format(Language.FB.ItemNum,item_count)
		if day_num >= exp_daily_fb[0].enter_day_times then
			day_num = exp_daily_fb[0].enter_day_times
		end
		self.day_num:SetValue(exp_daily_fb[0].enter_day_times - day_num)
		self.item_name:SetValue(item_info.name)
		self.item_num:SetValue(str)
		self.show_red_point:SetValue(exp_daily_fb[0].enter_day_times - day_num > 0 or item_count > 0)
	end
end

function FuBenNewExpView:GetUiCallBack(ui_name, ui_param)
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end