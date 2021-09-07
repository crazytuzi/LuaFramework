MiJiComposeView = MiJiComposeView or BaseClass(BaseView)

local MAX_COMPOSE_NUM = 1

function MiJiComposeView:__init()
	self.ui_config = {"uis/views/shengeview", "MiJiComposeView"}
	self.play_audio = true
end

function MiJiComposeView:__delete()
	-- body
end

function MiJiComposeView:ReleaseCallBack()
	for _, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
	if self.item_cost then
		self.item_cost:DeleteMe()
		self.item_cost = nil
	end

	if nil ~= MiJiComposeData.Instance then
		MiJiComposeData.Instance:UnNotifyDataChangeCallBack(self.data_change_event)
		self.data_change_event = nil
	end

	-- 清理变量
	self.show_plus_list = nil
end

function MiJiComposeView:LoadCallBack()
	self.fight_info_view = true
	self.click_index = -1
	self.had_set_data_list = {list = {}, count = 0}
	self.had_set_data_count = 0
	self.item_list = {}
	self.show_plus_list = {}

	self:ListenEvent("OnClickYes",BindTool.Bind(self.OnClickYes, self))
	self:ListenEvent("OnClickNo",BindTool.Bind(self.OnClickNo, self))
	self:ListenEvent("OnClickClose",BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickHelp",BindTool.Bind(self.OnClickHelp, self))

	self.item_cost = ItemCell.New()
	self.item_cost:SetInstanceParent(self:FindObj("ItemDe"))
	self.item_cost:SetIsShowTips(false)
	self.item_cost:ShowHighLight(false)

	for i = 1, 3 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item"..i))
		item:SetClearListenValue(false)
		item:SetInteractable(true)
		item:ListenClick(BindTool.Bind(self.OnClickItem, self, i))
		self.item_list[i] = item
		self.show_plus_list[i] = self:FindVariable("ShowPlus"..i)
	end

	self.data_change_event = BindTool.Bind(self.OnDataChange, self)
	MiJiComposeData.Instance:NotifyDataChangeCallBack(self.data_change_event)
end

function MiJiComposeView:OpenCallBack()
	self:ClearItemData()
end

function MiJiComposeView:CloseCallBack()
end

function MiJiComposeView:OnClickYes()
	if self.had_set_data_count < MAX_COMPOSE_NUM then
		TipsCtrl.Instance:ShowSystemMsg(Language.ShengXiao.MaterialNoEnough)
		return
	end
	if(self.had_set_data_list.list[1] ~= nil) then
		ShengXiaoCtrl.Instance:SendHechengRequst(self.had_set_data_list.list[1].bag_info.index)
	end
	self:ClearItemData()
end

function MiJiComposeView:OnClickNo()
	self:ClearItemData()
end

function MiJiComposeView:OnClickClose()
	self:Close()
end

function MiJiComposeView:OnClickHelp()
	local tips_id = 179
 	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function MiJiComposeView:OnClickItem(index)
	local call_back = function(data)
		self.item_list[index]:SetHighLight(false)
		if nil ~= data then
			if nil == self.item_list[index]:GetData().item_id then
				self.had_set_data_count = self.had_set_data_count + 1
			end
			self.item_list[index]:SetData({item_id = data.item_id, num = 1, is_bind = data.bag_info.is_bind})
			self.show_plus_list[index]:SetValue(false)
			self.had_set_data_list.list[index] = data

			if index == 1 then
				self.item_cost:SetData({item_id = 65534, num = ShengXiaoData.Instance:GetCostByMijiLevel(data.level)})
			end
			--更新背包item数目

			-- 第一次选择，自动填充同样的神格
			-- if self.click_index <= 0 then
			-- 	local list = ShenGeData.Instance:GetBagSameQualityAndTypesItemDataList(data.shen_ge_data.type, data.shen_ge_data.quality, data.shen_ge_data.index)
			-- 	for k, v in pairs(self.item_list) do
			-- 		if nil == v:GetData().item_id and nil ~= list[1] then
			-- 			self.had_set_data_count = self.had_set_data_count + 1
			-- 			v:SetData(list[1])
			-- 			self.show_plus_list[k]:SetValue(false)
			-- 			self.had_set_data_list[k] = list[1]
			-- 			table.remove(list, 1)
			-- 		end
			-- 	end
			-- end
			self.click_index = index
		end
	end
	self.had_set_data_list.count = self.had_set_data_count
	MiJiComposeCtrl.Instance:ShowSelectView(call_back, self.had_set_data_list, "from_compose")
end

function MiJiComposeView:OnDataChange(info_type, param1, param2, param3)

	if info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_COMPOSE_SHENGE_INFO then
	
	end
end

function MiJiComposeView:ClearItemData()
	for k, v in pairs(self.item_list) do
		v:SetData()
		self.show_plus_list[k]:SetValue(true)
	end
	self.had_set_data_list = {list = {}, count = 0}
	self.click_index = -1
	self.had_set_data_count = 0
	self.item_cost:SetData({item_id = 65534})
end