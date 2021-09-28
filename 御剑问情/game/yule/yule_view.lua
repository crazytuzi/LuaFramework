require("game/yule/fishing/fishing_view")
require("game/yule/go_pawn/go_pawn_content_view")

YuLeView = YuLeView or BaseClass(BaseView)

function YuLeView:__init()
    self.ui_config = {"uis/views/yuleview_prefab", "YuLeView"}
    self.remind_change = BindTool.Bind(self.RemindChangeCallBack, self)
end

function YuLeView:__delete()

end

function YuLeView:ReleaseCallBack()
	if self.fishing_view then
		self.fishing_view:DeleteMe()
		self.fishing_view = nil
	end

	if self.go_pawn_view then
		self.go_pawn_view:DeleteMe()
		self.go_pawn_view = nil
	end

	if RemindManager.Instance then
		RemindManager.Instance:UnBind(self.remind_change)
	end

	self.tab_fish = nil
	self.tab_go_pawn = nil
	self.red_point_list = nil
end

function YuLeView:LoadCallBack()
	--捕鱼
	local fish_content = self:FindObj("FishContent")
	fish_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.fishing_view = FishingView.New(obj)
		self.fishing_view:InitView()
	end)

	--走棋子
	local go_pawn_content = self:FindObj("GoPawnContent")
	go_pawn_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.go_pawn_view = GoPawnContentView.New(obj)
	end)

	--获取标签
	self.tab_fish = self:FindObj("TabFish")
	self.tab_go_pawn = self:FindObj("TabGoPawn")

	self.red_point_list = {
		[RemindName.YuLe_Fishing] = self:FindVariable("FishRemind"),
		[RemindName.HuanJing_XunBao] = self:FindVariable("GoPawnRemind"),
	}

	for k in pairs(self.red_point_list) do
		RemindManager.Instance:Bind(self.remind_change, k)
	end

	self:ListenEvent("ClickTabFish", BindTool.Bind(self.ClickTabFish, self))
	self:ListenEvent("ClickTabGoPawn", BindTool.Bind(self.ClickTabGoPawn, self))

	self:ListenEvent("Close", BindTool.Bind(self.CloseWindow, self))
end

function YuLeView:RemindChangeCallBack(remind_name, num)
	if nil ~= self.red_point_list[remind_name] then
		self.red_point_list[remind_name]:SetValue(num > 0)
	end
end

function YuLeView:CloseWindow()
	self:Close()
end

function YuLeView:ClickTabFish()
	if self.fishing_view and self.show_index ~= TabIndex.yule_fishing then
		self.fishing_view:InitView()
	end
end

function YuLeView:ClickTabGoPawn()
	if self.go_pawn_content_view and self.show_index ~= TabIndex.yule_go_pawn then
		local active_value = ZhiBaoData.Instance:GetActiveDegreeValue()
		if active_value > 200 then
			active_value = 200
		end
		local slider = active_value / 200
		self.go_pawn_content_view:SetActiveSlider(active_value, slider)
		self.go_pawn_content_view:SetRedPoint(GoPawnData.Instance:CheckRedPoint())
	end
end

function YuLeView:OpenCallBack()
	if self.tab_fish.toggle.isOn then
		self:ChangeToIndex(TabIndex.yule_fishing)
	elseif self.tab_go_pawn.toggle.isOn then
		self:ChangeToIndex(TabIndex.yule_go_pawn)
	end
end

function YuLeView:CloseCallBack()
	if self.fishing_view then
		self.fishing_view:CloseCallBack()
	end
end

function YuLeView:ShowIndexCallBack(index)
	if index == TabIndex.yule_fishing then
		self.tab_fish.toggle.isOn = true
		if self.fishing_view then
			self.fishing_view:InitView()
		end
	elseif index == TabIndex.yule_go_pawn then
		self.tab_go_pawn.toggle.isOn = true
		self:ClickTabGoPawn()
	end
end

function YuLeView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "fish" and self.tab_fish.toggle.isOn then
			if self.fishing_view then
				self.fishing_view:FlushFish()
			end
		elseif k == "info" and self.tab_fish.toggle.isOn then
			if self.fishing_view then
				self.fishing_view:FlushInfo()
			end
		elseif k == "fish_num_change" and self.tab_fish.toggle.isOn then
			if self.fishing_view then
				self.fishing_view:FishNumChange(v[1])
			end
		elseif k == "enter_other" and self.tab_fish.toggle.isOn then
			if self.fishing_view then
				self.fishing_view:RefreshView(v[1])
			end
		elseif k == "fish_reward" and self.tab_fish.toggle.isOn then
			if self.fishing_view then
				self.fishing_view:PlayRewardEffect()
			end
		end
	end
end