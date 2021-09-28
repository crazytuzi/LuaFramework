TipsGetNewEquipView = TipsGetNewEquipView or BaseClass(BaseView)

function TipsGetNewEquipView:__init()
	self.ui_config = {"uis/views/tips/getnewequiptips_prefab", "GetNewEquipTips"}
	self.move_speed = 75
	self.fade_speed = 1.5
	self.play_audio = true
	self.item_list = {}
	self.view_layer = UiLayer.Pop
end

function TipsGetNewEquipView:__delete()
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	self.move_icon = nil
	self.move_icon_bind = nil
end

--写在open中是因为需要解决打开界面时会有延迟,而导致停下任务也有延迟的问题。
function TipsGetNewEquipView:Open(index)
	BaseView.Open(self, index)
	TaskCtrl.Instance:SetAutoTalkState(false)
end

function TipsGetNewEquipView:LoadCallBack()
	for i = 0, 9 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("item_"..i))
		-- self.item_list[i]:ListenClick()
	end
	self.move_icon = self:FindObj("MoveIcon")
	self.move_icon_bind = self:FindVariable("move_image")
	self.return_pos = self.move_icon.rect.anchoredPosition3D
end

function TipsGetNewEquipView:CloseCallBack()
	TaskCtrl.Instance:SetAutoTalkState(true)
end

function TipsGetNewEquipView:ReleaseCallBack()
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function TipsGetNewEquipView:ShowView(equip_id, index)
	self.index = index
	self.id_value = equip_id

	local equip_cfg = ItemData.Instance:GetItemConfig(self.id_value)
	local equip_index = EquipData.Instance:GetEquipIndexByType(equip_cfg.sub_type)
	if equip_cfg == nil then
		return
	end
	if equip_cfg.limit_prof ~= GameVoManager.Instance:GetMainRoleVo().prof then
		return
	end
	if equip_cfg.sub_type - 100 > 10 then
		return
	end

	local equip_data = EquipData.Instance:GetDataList()
	if equip_data[equip_index] ~= nil then
		local id = equip_data[equip_index].item_id
		if id ~= nil and id ~= 0 then
			return
		end
	end

	self:Open()
end

local DefaultEquipIcon = {
	[0] = 100,
	[1] = 1100,
	[2] = 3100,
	[3] = 4100,
	[4] = 5100,
	[5] = 6100,
	[6] = 8100,
	[7] = 9100,
	[8] = 2100,
	[9] = 9100,
}

function TipsGetNewEquipView:OpenCallBack()
	local equip_cfg = ItemData.Instance:GetItemConfig(self.id_value)
	local target_equip_index = equip_cfg.sub_type - 100
	local equip_data = EquipData.Instance:GetDataList()


	local bag_data = ItemData.Instance:GetItem(self.id_value)
	local equip_index = EquipData.Instance:GetEquipIndexByType(equip_cfg.sub_type)
	PackageCtrl.Instance:SendUseItem(bag_data.index, 1, equip_index, equip_cfg.need_gold)

	if target_equip_index == 7 then
		target_equip_index = equip_index
	end
	for i=0,#self.item_list do
		local data = {}
		data.is_bind = 0
		if equip_data[i] ~= nil and target_equip_index ~= i then
			data.item_id = equip_data[i].item_id
			self.item_list[i]:SetData(data)
			self.item_list[i]:SetIconGrayScale(false)
		else
			data.item_id = DefaultEquipIcon[i]
			self.item_list[i]:SetData(data)
			self.item_list[i]:SetIconGrayScale(true)
			self.item_list[i].show_quality:SetValue(false)
		end
		self.item_list[i]:SetShowUpArrow(false)
	end

	local bundle, asset = ResPath.GetItemIcon(equip_cfg.icon_id)
	-- self.move_icon.image:LoadSprite(bundle, asset)
	self.move_icon_bind:SetAsset(bundle, asset)

	local color = self.move_icon.image.color
	Color.New(color.r, color.g, color.b, 0)
	self.move_icon.image.color = Color.New(color.r, color.g, color.b, 0)
	local color_count = 0

	local delay_time = 0.6

	self.move_icon.rect.anchoredPosition3D = self.return_pos
	self.move_icon:SetActive(true)

	self.timer_quest = GlobalTimerQuest:AddRunQuest(function()

		if color_count < 1 then
			color_count = color_count + self.fade_speed * UnityEngine.Time.deltaTime
			self.move_icon.image.color = Color.New(color.r, color.g, color.b, color_count)
			return
		end

		if delay_time > 0 then
			delay_time = delay_time - UnityEngine.Time.deltaTime
			return
		end

		local target_pos = self.item_list[target_equip_index].root_node.transform.position
		local move_icon_pos = self.move_icon.transform.position
		if Vector3.Distance(target_pos, move_icon_pos) > 2 then
			local dir = (target_pos - move_icon_pos).normalized
			self.move_icon.transform:Translate(dir*self.move_speed*UnityEngine.Time.deltaTime)
		else
			local data = {}
			data.is_bind = 0
			data.item_id = self.id_value
			self.item_list[target_equip_index]:SetData(data)
			self.item_list[target_equip_index]:SetIconGrayScale(false)
			self.move_icon:SetActive(false)
			self.item_list[target_equip_index]:SetShowUpArrow(false)
			GlobalTimerQuest:AddDelayTimer(BindTool.Bind1(self.CloseView,self),0.6)
		end
	end, 0)
end

function TipsGetNewEquipView:CloseView()
	GlobalTimerQuest:CancelQuest(self.timer_quest)
	self:Close()
end