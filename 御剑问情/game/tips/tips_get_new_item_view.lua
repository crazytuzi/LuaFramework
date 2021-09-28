TipsGetNewitemView = TipsGetNewitemView or BaseClass(BaseView)

function TipsGetNewitemView:__init()
	self.ui_config = {"uis/views/tips/getnewitemtips_prefab", "GetNewItemTips"}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.index = -1
end

function TipsGetNewitemView:__delete()
end

-- 这里重写Open方法，延迟打开面板
-- 因为商城购买物品时可以要服务器帮忙使用，服务器会把道具先发到背包，然后立刻移除背包，体验很不好
function TipsGetNewitemView:Open(...)
	if not self.delay_time then
		self.delay_time = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.DelayOpen, self, ...), 0.5)
	end
end

function TipsGetNewitemView:Close(...)
	self:CancelDelayTime()
	BaseView.Close(self, ...)
end

function TipsGetNewitemView:DelayOpen(...)
	self:CancelDelayTime()
	BaseView.Open(self, ...)
end

function TipsGetNewitemView:CancelDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function TipsGetNewitemView:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("ReduceClick", BindTool.Bind(self.ChangeNumber, self, -1))
	self:ListenEvent("AddClick", BindTool.Bind(self.ChangeNumber, self, 1))
	self:ListenEvent("UseClick", BindTool.Bind(self.UseClick, self))

	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self:FindObj('ItemCell'))
	self.item_num = self:FindVariable('ItemNumber')
	self.item_name = self:FindVariable('ItemName')
end

function TipsGetNewitemView:ReleaseCallBack()
	if self.scene_load_enter ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self:CancelDelayTime()

	-- 清理变量和对象
	self.item_num = nil
	self.item_name = nil
end

function TipsGetNewitemView:OpenView(item_id, index)
	self.item_data = {}
	self.item_data.item_id = item_id
	self.index = index

	self.id_value = item_id
	local item_cfg = ItemData.Instance:GetItem(item_id)
	self.number_value = item_cfg and item_cfg.num or 0
	self.max_number = self.number_value
	self:Open()
end

function TipsGetNewitemView:OpenCallBack()
	self.scene_load_enter = GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER,
		BindTool.Bind(self.OnChangeScene, self))

	self.item_cfg = ItemData.Instance:GetItemConfig(self.id_value)
	self.item_name:SetValue(self.item_cfg.name)
	self.item_cell:SetData(self.item_data)
	self.item_num:SetValue(self.number_value)
end

function TipsGetNewitemView:CloseCallBack()
	if self.scene_load_enter ~= nil then
		GlobalEventSystem:UnBind(self.scene_load_enter)
		self.scene_load_enter = nil
	end
	self.index = -1
end

function TipsGetNewitemView:GetIndex()
	return self.index
end

function TipsGetNewitemView:OnChangeScene()
	if self:IsOpen() then
		self:Close()
	end
end

function TipsGetNewitemView:UseClick()
	local bag_data = ItemData.Instance:GetItem(self.id_value)
	if bag_data then
		PackageCtrl.Instance:SendUseItem(bag_data.index, self.number_value, bag_data.sub_type, self.item_cfg.need_gold)
	end
	self:Close()
end

function TipsGetNewitemView:ChangeNumber(number)
	local try_number = self.number_value
	try_number = try_number + number
	if try_number > 0 and try_number <= self.max_number then
		self.number_value = try_number
		self.item_num:SetValue(self.number_value)
	end
end

function TipsGetNewitemView:CloseView()
	self:Close()
end