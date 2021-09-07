ComposeContentView = ComposeContentView or BaseClass(BaseRender)
local EFFECT_CD = 1
function ComposeContentView:__init(instance)
	ComposeContentView.Instance = self
	-- self:ListenEvent("max_click",BindTool.Bind(self.MaxBtnOnClick, self))
	self:ListenEvent("input_click",BindTool.Bind(self.OnInputClick, self))
	self:ListenEvent("compose_click",BindTool.Bind(self.ComposeBtnClick, self))
	self.select_toggle = self:FindObj("select_toggle")
	self.turn_circle = self:FindObj("turn_circle")
	self.effect_root = self:FindObj("effect_root")
	self.select_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnSelectShowClick, self))
	self.the_item_list = {}
	for i=1,4 do
		local handler = function()
			local close_call_back = function()
				self.the_item_list[i].item_cell:ShowHighLight(false)
			end
			local data = self.the_item_list[i].item_cell:GetData()
			if data.item_id ~= 0 then
				self.the_item_list[i].item_cell:ShowHighLight(true)
				TipsCtrl.Instance:OpenItem(data, nil, nil, close_call_back)
			end
		end
		self.the_item_list[i] = {}
		self.the_item_list[i].item_cell = ItemCell.New()
		self.the_item_list[i].item_cell:SetInstanceParent(self:FindObj("item_cell_" .. i))
		self.the_item_list[i].item_cell:ListenClick(handler)
		self.the_item_list[i].count_text = self:FindVariable("count_text_" .. i)
		self.the_item_list[i].show_count = self:FindVariable("show_count_" .. i)
	end

	-- self.mat_item1 = self:FindVariable("mat_item1")
	-- self.mat_item2 = self:FindVariable("mat_item2")
	self.input_text = self:FindVariable("input_text")
	-- self.item1_count = self:FindVariable("item1_count")
	-- self.item1_upgrade_count = self:FindVariable("item1_upgrade_count")
	self.leftBarList = {}
	for i = 1, 7 do
		self.leftBarList[i] = {}
		self.leftBarList[i].select_btn = self:FindObj("select_btn_" .. i)
		self.leftBarList[i].list = self:FindObj("list_" .. i)
		self.leftBarList[i].btn_text = self:FindVariable("btn_text_" .. i)
		self.leftBarList[i].red_state = self:FindVariable("show_red_" .. i)
		self:ListenEvent("select_btn_" .. i ,BindTool.Bind(self.OnClickSelect, self, i))
	end

	self.show_item_list = {}
	for i = 1, 3 do
		self.show_item_list[i] = self:FindVariable("show_item_" .. i)
	end

	self.current_type = -1
	self.buy_num = -1
	self.list_index = 1
	self.item_list = {}
	self.item_cell_list = {}
	self.current_item_id = 0
	self.current_seq = 0
	self.item_data_event = nil
	self.is_select = false
	self.effect_cd = 0
	self.is_buy_quick = false
end

function ComposeContentView:__delete()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self.effect_cd = nil

	for k, v in pairs(self.the_item_list) do
		if v.item_cell then
			v.item_cell:DeleteMe()
		end
	end
	self.the_item_list = {}
end

function ComposeContentView:UpdateList(type)
	-- if self.is_load == false then return end
	local compose_data = ComposeData.Instance
	local compose_item_list = compose_data:GetTypeOfAllItem(type)
	local can_compose_id = compose_data:CheckBagMat(compose_item_list)
	local to_product_id = compose_data:GetToProductId()
	if to_product_id then
		local product_item = compose_data:GetComposeItem(to_product_id)
		if product_item ~= nil then
			self.current_item_id = product_item.product_id
			self.current_seq = product_item.producd_seq
		end
	else
		if can_compose_id ~= 0 then
			self.current_item_id = can_compose_id
		else
			self.current_item_id = compose_data:GetShowId(self.current_type)
		end
	end


	self:SetIcon()
	--宝石 其他 
	self.current_type = type

	if self.leftBarList == nil or self.leftBarList[self.list_index] == nil then
		return
	end 

	self.leftBarList[self.list_index].select_btn.accordion_element.isOn = false
	self.leftBarList[self.list_index].list:SetActive(false)
	local count = compose_data:GetComposeTypeOfCount(type)
	local name_list = compose_data:GetComposeTypeOfNameList(type)
	local sub_type_list = compose_data:GetSubTypeList(type)
	local item_repoint_state = ComposeData.Instance:GetIsClickItemState()
	self.item_list = {}
	self.item_cell_list = {}
	self.is_load = true

	for i=1,count do
		local State = ComposeData.Instance:GetIsClickRedPointState(type, sub_type_list[i])		--是否点击过
		local sub_list = compose_data:GetComposeItemList(sub_type_list[i])
		local compose_id = compose_data:CheckBagMat(sub_list)
		--self.leftBarList[i].red_state:SetValue(compose_id > 0 and State)

		if State and compose_id then
			self.leftBarList[i].red_state:SetValue(true)
		else
			self.leftBarList[i].red_state:SetValue(compose_id > 0 and ComposeData.Instance:GetNumIsChange(self.current_type, sub_type_list[i]))
		end
		
		self.leftBarList[i].select_btn:SetActive(true)
		self.leftBarList[i].btn_text:SetValue(name_list[i])
		self:LoadCell(i,sub_type_list[i])
	end
	if count == 7 then
		return
	end
	for i=count + 1, 7 do
		self.leftBarList[i].select_btn:SetActive(false)
	end
end

-- function ComposeContentView:MaxBtnOnClick() --重复
-- 	self.buy_num = ComposeData:GetCanByNum(self.current_item_id)
-- 	if self.buy_num == 0 then
-- 		self.buy_num = 1
-- 	elseif tonumber(self.buy_num) >= 999 then
-- 		self.buy_num = 999
-- 	end
-- 	self.input_text:SetValue(self.buy_num)
-- end

function ComposeContentView:OnSelectShowClick(is_click)
	if is_click then
		self.is_select = true
	else
		self.is_select = false
	end
	self:CheckIsSelect()
end

function ComposeContentView:CheckIsSelect()
	if self.is_select then
		self:OnFlushItem()
	else
		self:OnSetItemActive()
	end
	if self.leftBarList[self.list_index] and self.leftBarList[self.list_index].select_btn.accordion_element 
		and self.leftBarList[self.list_index].select_btn.accordion_element.isOn then --刷新
		self.leftBarList[self.list_index].select_btn.accordion_element.isOn = false
		self.leftBarList[self.list_index].select_btn.accordion_element.isOn = true
	end

	if self.is_select then --根据背包是否拥有来判断是否关闭按钮
		local compose_data = ComposeData.Instance
		local sub_type_list = compose_data:GetSubTypeList(self.current_type)
		local compose_item_list = compose_data:GetComposeItemList(sub_type_list[self.list_index])
		for k,v in pairs(compose_item_list) do
			if compose_data:JudgeMatRich(v.product_id) then
				self.leftBarList[self.list_index].select_btn.accordion_element.isOn = true
				return
			end
		end
		self.leftBarList[self.list_index].select_btn.accordion_element.isOn = false
	end
end

function ComposeContentView:ComposeBtnClick()
	local bags_grid_num = ItemData.Instance:GetEmptyNum()
	if self.buy_num <= 0 or bags_grid_num < 1 then
		local remind_str = ""
		if self.buy_num <= 0 then
			remind_str = Language.Compose.NotEnoughStuff
		else
			remind_str = Language.Common.NotBagRoom
		end
		TipsCtrl.Instance:ShowSystemMsg(remind_str)
		return
	end
	local compose_data = ComposeData.Instance
	local compose_item = compose_data:GetComposeItem(self.current_item_id)
	-- local stuff_id_1 = compose_item.stuff_id_1
	-- local stuff_id_count = ItemData.Instance:GetItemNumInBagById(stuff_id_1)
	-- local stuff_need_count = compose_item.stuff_count_1
	-- if self.buy_num > 1 then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Compose.InputMaxTips)
	-- 	return
	-- end
	if self.buy_num + 0 <= compose_data:GetCanByNum(self.current_item_id) then
		ComposeCtrl.Instance:SendItemCompose(compose_item.producd_seq, self.buy_num, 0) --0合成类型
		self:ControllRotate()
		self:PlayUpStarEffect()
	else
		local is_shop_have = compose_data:GetIsHaveItemOfShop(self.current_item_id)
		if is_shop_have then
			for i=1,3 do
				local is_rich = compose_data:GetSingleMatRich(self.current_item_id, i)
				if not is_rich then
					local is_shop_exist = compose_data:GetIsHaveSingleItemOfShop(self.current_item_id, i)
					if is_shop_exist then
						self:OpenShopBuyTips(i)
					else
						TipsCtrl.Instance:ShowItemGetWayView(compose_item["stuff_id_"..i])
					end
				end
			end
		else
			TipsCtrl.Instance:ShowItemGetWayView(compose_item.stuff_id_1)
		end
	end
end

function ComposeContentView:OpenShopBuyTips(stuff_index)
	local compose_item = ComposeData.Instance:GetComposeItem(self.current_item_id)
	local bag_num = ItemData.Instance:GetItemNumInBagById(compose_item["stuff_id_"..stuff_index])
	local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
		self.is_buy_quick = is_buy_quick
		MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
	end
	if not self.is_buy_quick then
		TipsCtrl.Instance:ShowCommonBuyView(func, compose_item["stuff_id_"..stuff_index], nil, compose_item["stuff_count_"..stuff_index] - bag_num)
	else
		MarketCtrl.Instance:SendShopBuy(compose_item["stuff_id_"..stuff_index], compose_item["stuff_count_"..stuff_index] - bag_num, 0, 0)
	end

end

function ComposeContentView:OnInputClick()
	if self.list_index > 3 and self.current_type == 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Compose.InputMaxTips)
		return
	end
	local open_func = function(buy_num)
		self.buy_num = buy_num + 0
		if self.buy_num == 0 then
			self.buy_num = 1
		end
		self.input_text:SetValue(self.buy_num)
	end
	local close_func = function()
		if self.buy_num ~= -1 then
			return
		end
		self:FlushBuyNum()
	end
	local max_num = ComposeData.Instance:GetCanByNum(self.current_item_id)
	if max_num == 0 then
		max_num = 1
	end

	TipsCtrl.Instance:OpenCommonInputView(0,open_func,close_func,max_num)
end

function ComposeContentView:LoadCell(index,sub_type)
	local compose_item_list = ComposeData.Instance:GetComposeItemList(sub_type)
	PrefabPool.Instance:Load(AssetID("uis/views/composeview_prefab", "ItemType"), function (prefab)
		if nil == prefab then
			return
		end
		for i=1,#compose_item_list do
			local obj = GameObject.Instantiate(prefab)
			local obj_transform = obj.transform
			if self.leftBarList[index] then
				obj_transform:SetParent(self.leftBarList[index].list.transform, false)
				obj:GetComponent("Toggle").group = self.leftBarList[index].list.toggle_group
			end	
			local item_cell = ComposeItem.New(obj)
				item_cell:InitCell(compose_item_list[i].product_id)
				self.item_list[#self.item_list + 1] = obj_transform
				self.item_cell_list[#self.item_cell_list + 1] = item_cell
		end

		PrefabPool.Instance:Free(prefab)
		self:CheckIsSelect()
	end)
end

function ComposeContentView:OnClickSelect(index)
	self.list_index = index
	local count = ComposeData.Instance:GetComposeTypeOfCount(self.current_type)
	local sub_type_list = ComposeData.Instance:GetSubTypeList(self.current_type)
	--for i=1,count do
		ComposeData.Instance:SetIsClickRedPointState(self.current_type, sub_type_list[self.list_index])
		local State = ComposeData.Instance:GetIsClickRedPointState(self.current_type, sub_type_list[self.list_index])
		local sub_list = ComposeData.Instance:GetComposeItemList(sub_type_list[self.list_index])
		local compose_id = ComposeData.Instance:CheckBagMat(sub_list)

		if State then
			self.leftBarList[self.list_index].red_state:SetValue(true)
		else
			self.leftBarList[self.list_index].red_state:SetValue(compose_id > 0 and ComposeData.Instance:GetNumIsChange(self.current_type, sub_type_list[self.list_index]))
		end
		--self.leftBarList[self.list_index].red_state:SetValue(false)
	--end

	if self.current_type == ComposeData.Type.stone then
		RemindManager.Instance:Fire(RemindName.ComposeStone)
	elseif self.current_type == ComposeData.Type.jinjie then
		RemindManager.Instance:Fire(RemindName.ComposeJinjie)
	elseif self.current_type == ComposeData.Type.other then
		RemindManager.Instance:Fire(RemindName.ComposeOther)
	end
	self:OnFlushNum()
end

function ComposeContentView:OnBaoShi()
	self:DestoryGameObject()
	self.current_type = 1
	self:UpdateList(1)
	self:OpenFrame()
	self:SetIcon()
	ComposeData.Instance:SetToProductId(nil)
end

function ComposeContentView:OnQiTa()
	self:DestoryGameObject()
	self.current_type = 3
	self:UpdateList(3)
	self:OpenFrame()
	self:SetIcon()
	ComposeData.Instance:SetToProductId(nil)
end

function ComposeContentView:OnJinJie()
	self:DestoryGameObject()
	self.current_type = 2
	self:UpdateList(2)
	self:OpenFrame()
	self:SetIcon()
	ComposeData.Instance:SetToProductId(nil)
end

function ComposeContentView:OnShiZhuang()
	self:DestoryGameObject()
	self.current_type = 4
	self:UpdateList(4)
	self:OpenFrame()
	self:SetIcon()
	ComposeData.Instance:SetToProductId(nil)
end

function ComposeContentView:OpenFrame()
	local list_index = ComposeData.Instance:GetCurrentListIndex()
	self.list_index = list_index
	self.leftBarList[list_index].select_btn.accordion_element.isOn = true
end

function ComposeContentView:DestoryGameObject()
	if self.item_list == {} then
		return
	end
	self.is_load = false
	for k,v in pairs(self.item_list) do
		GameObject.Destroy(v.gameObject)
	end
	self.item_list = {}
	self.item_cell_list = {}
end

function ComposeContentView:SetIcon()
	local compose_cfg = ComposeData.Instance:GetComposeItem(self.current_item_id)
	if compose_cfg then
		local stuff_list = {}
		stuff_list = {[1] = compose_cfg.stuff_id_1, [2] = compose_cfg.stuff_id_2, [3] = compose_cfg.stuff_id_3 }
		for i=1,3 do
			if self.the_item_list[i] and self.the_item_list[i].item_cell then
				if stuff_list[i] ~= 0 then
					self.the_item_list[i].item_cell:SetCellLock(false)
					self.the_item_list[i].show_count:SetValue(true)
					self.the_item_list[i].item_cell:SetData({item_id = stuff_list[i]})
					local count_text_list = ComposeData.Instance:GetCountText(self.current_item_id)
					self.the_item_list[i].count_text:SetValue(count_text_list[i])
					if self.show_item_list[i] ~= nil then
						self.show_item_list[i]:SetValue(true)
					end
				else
					local data = {}
					data.item_id = 0
					self.the_item_list[i].item_cell:SetData(data)
					self.the_item_list[i].item_cell:SetCellLock(true)
					self.the_item_list[i].show_count:SetValue(false)
					if self.show_item_list[i] ~= nil then
						self.show_item_list[i]:SetValue(false)
					end
				end
			end
		end

		self.the_item_list[4].item_cell:SetData({item_id = self.current_item_id})
	end
end

function ComposeContentView:OnFlushItem()
	if self.item_cell_list ~= nil then
		for k,v in pairs(self.item_cell_list) do
			v:OnFlush()
		end
	end
end

function ComposeContentView:OnFlushNum()
	if self.item_cell_list ~= nil then
		for k,v in pairs(self.item_cell_list) do
			v:FlushNum()
		end
	end
end

function ComposeContentView:OnSetItemActive()
	if self.item_cell_list ~= nil then
		for k,v in pairs(self.item_cell_list) do
			v:SetItemActive(true)
		end
	end
end

function ComposeContentView:SetCurrentItemId(item_id)
	self.current_item_id = item_id
end

function ComposeContentView:GetCurrentItemId()
	return self.current_item_id
end

function ComposeContentView:GetCurrentType()
	return self.current_type
end

function ComposeContentView:FlushBuyNum()
	self.buy_num = ComposeData:GetCanByNum(self.current_item_id)
	if self.buy_num == 0 then
		self.buy_num = 1
	elseif tonumber(self.buy_num) >= 99 then
		self.buy_num = 99
	end
	if self.list_index > 3 and self.current_type == 1 then
		self.buy_num = 1
	end
	self.input_text:SetValue(self.buy_num)
end

function ComposeContentView:ItemDataChangeCallback(the_item_id)
	self:OnFlushNum()
	self:SetIcon()

	ComposeData.Instance:CalcStoreRedPoint()
	ComposeData.Instance:CalcOtherRedPoint()
	ComposeData.Instance:CalcJinjieRedPoint()
	
	local compose_data = ComposeData.Instance
	local count = compose_data:GetComposeTypeOfCount(self.current_type)
	local sub_type_list = compose_data:GetSubTypeList(self.current_type)
	for i=1,count do
		local sub_list = compose_data:GetComposeItemList(sub_type_list[i])
		local compose_id = compose_data:CheckBagMat(sub_list)
		--self.leftBarList[i].red_state:SetValue(compose_id > 0 and State)
		local State = ComposeData.Instance:GetIsClickRedPointState(self.current_type, sub_type_list[i])
		if State then
			self.leftBarList[i].red_state:SetValue(true)
		else
			self.leftBarList[i].red_state:SetValue(compose_id > 0 and ComposeData.Instance:GetNumIsChange(self.current_type, sub_type_list[i]))
		end
	end
	if the_item_id ~= self.current_item_id then
		if compose_data:GetEnoughMatEqualNeedCount(compose_data:GetProductIdByStuffId(the_item_id)) then
			self:OnFlushNum()
			self:FlushBuyNum()
			self:CheckOpenOrNot()
			self:CheckIsSelect()
			self:SetIcon()
		end
		return
	end
	self:FlushBuyNum()
	if self.is_select then
		self:IsSelect(the_item_id)
	else
		self:IsNotSelect()
	end
	if self.item_cell_list ~= nil then
		for k,v in pairs(self.item_cell_list) do
			if self.current_item_id == v:GetItemId() then
				v:SetHighLight()
			end
		end
	end
	self:SetIcon()
end

function ComposeContentView:IsNotSelect()
	local compose_data = ComposeData.Instance
	local enough_mat = compose_data:JudgeMatRich(self.current_item_id)
	if enough_mat then
		return
	end

	local is_have = compose_data:GetSubIsHaveCompose(compose_data:GetComposeItem(self.current_item_id).sub_type)
	local item_id = compose_data:GetShowItemId(self.current_type, compose_data:GetComposeItem(self.current_item_id).sub_type)
	if item_id ~= -1 then
		self.current_item_id = item_id
	else
		return
	end
	if compose_data:GetSubIsHaveCompose(compose_data:GetComposeItem(self.current_item_id).sub_type) == false then
		self:CheckOpenOrNot()
		self:CheckIsSelect()
	else
		if is_have == false then
			self:CheckOpenOrNot()
			self:CheckIsSelect()
		end
	end
end

function ComposeContentView:IsSelect(the_item_id)
	local compose_data = ComposeData.Instance
	local enough_need = compose_data:GetEnoughMatEqualNeedCount(compose_data:GetProductIdByStuffId(the_item_id))
	local enough_mat = compose_data:JudgeMatRich(the_item_id)
	if not enough_need and enough_mat then
		return
	end
	local item_id = -1
	if not enough_mat then
		item_id = compose_data:GetShowItemId(self.current_type, compose_data:GetComposeItem(self.current_item_id).sub_type)
	end

	if item_id ~= -1 then
		self.current_item_id = item_id
	else
		self:OnFlushItem()
	end
	self:CheckOpenOrNot()
	self:CheckIsSelect()
end

function ComposeContentView:CheckOpenOrNot()
	local list_index = ComposeData.Instance:GetCurrentListIndex()
	if self.list_index ~= list_index then
		self.list_index = list_index
		self.leftBarList[self.list_index].select_btn.accordion_element.isOn = true
	end
end

function ComposeContentView:ControllRotate()
	local transform = self.turn_circle.transform
	local position = transform.position
	-- local rotate_self = transform:DOLocalRotate(
	-- 	Vector3(0, 0, 1080), 1.5, DG.Tweening.RotateMode.FastBeyond360)
	-- local sequence = DG.Tweening.DOTween.Sequence()
	-- sequence:Append(rotate_self)
end

function ComposeContentView:PlayUpStarEffect()
	if self.effect_cd then
		EffectManager.Instance:PlayAtTransformCenter(
			"effects2/prefab/ui/ui_chenggong_kgh_prefab",
			"UI_chenggong_KGH",
			self.effect_root.transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end

------------------------------------------------
ComposeItem = ComposeItem or BaseClass(BaseCell)
function ComposeItem:__init(instance)
	self.name = self:FindVariable("Name")
	self.num = self:FindVariable("Num")
	self.item_id = 0
	self.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnItemClick, self))
	self.can_buy_num = 0
end

function ComposeItem:__delete()
	self.can_buy_num = nil
	self.item_id = nil
end

function ComposeItem:InitCell(item_id)
	self.item_id = item_id
	self.name:SetValue(ItemData.Instance:GetItemConfig(item_id).name)
	self:FlushNum()
end

function ComposeItem:OnFlush()
	local is_rich = ComposeData.Instance:JudgeMatRich(self.item_id)
	if is_rich then
		self.root_node:SetActive(true)
	else
		self.root_node:SetActive(false)
	end
end

function ComposeItem:FlushNum()
	local compose_item = ComposeData.Instance:GetComposeItem(self.item_id)
	self.can_buy_num = ComposeData.Instance:GetCanByNum(self.item_id)
	if self.can_buy_num > 0 then
		self.num:SetValue("("..self.can_buy_num..")")
	else
		self.num:SetValue("")
	end
	self:SetHighLight()
end

function ComposeItem:SetHighLight()
	if ComposeContentView.Instance:GetCurrentItemId() == self.item_id then
		self.root_node.toggle.isOn = true
	else
		self.root_node.toggle.isOn = false
	end
end

function ComposeItem:GetCanBuyNum()
	return self.can_buy_num
end

function ComposeItem:SetItemActive(is_active)
	self.root_node:SetActive(is_active)
end

function ComposeItem:OnItemClick(is_click)
	if is_click then
		ComposeContentView.Instance:SetCurrentItemId(self.item_id)
		ComposeContentView.Instance:SetIcon(self.item_id)
		ComposeContentView.Instance:FlushBuyNum()
	end
end

function ComposeItem:GetItemId()
	return self.item_id
end