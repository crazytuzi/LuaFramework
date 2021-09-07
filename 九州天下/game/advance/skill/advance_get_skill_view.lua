AdvanceGetSkillView = AdvanceGetSkillView or BaseClass(BaseView)

function AdvanceGetSkillView:__init()
	self.ui_config = {"uis/views/advanceview", "AdvanceGetSkillView"}
	self.play_audio = true
	self:SetMaskBg()
end

function AdvanceGetSkillView:__delete()
end

function AdvanceGetSkillView:ReleaseCallBack()
	if self.items ~= nil then
		for k, v in pairs(self.items) do
			if v ~= nil and v.cell ~= nil then
				v.cell:DeleteMe()
			end
		end

		self.items = nil
	end
	
	self.bt_text_list = {}
	self.is_auto_buy = false

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	self.text_item_name_list = {}
	self.red_point_list = {}
end

function AdvanceGetSkillView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	for i = 1, GameEnum.JING_LING_SKILL_REFRESH_ITEM_MAX do
		-- i - 1 服务端索引从0开始
		self:ListenEvent("UseItem" .. i, BindTool.Bind2(self.UseItem, self, i - 1))
	end
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)

	self.items = {}
	self.bt_text_list = {}
	self.text_item_name_list = {}
	self.red_point_list = {}
	for i = 1, GameEnum.JING_LING_SKILL_REFRESH_ITEM_MAX do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("Item"..i))
		-- item_cell:SetToggleGroup(self:FindObj("ItemToggleGroup").toggle_group)
		self.items[i] = {item = self:FindObj("Item"..i), cell = item_cell}
		self.bt_text_list[i] = self:FindVariable("text_bt_" .. i)
		self.text_item_name_list[i] = self:FindVariable("text_item_name" .. i)
		self.red_point_list[i] = self:FindVariable("is_show_red_point" .. i)
	end
end

function AdvanceGetSkillView:ShowIndexCallBack(index)
	self:Flush()
end

function AdvanceGetSkillView:CloseAutoBuy()
	self.is_auto_buy = false
end

function AdvanceGetSkillView:UseItem(index)
	--local advance_info = AdvanceSkillData.Instance:GetAdvanceSkillInfo()
	-- local jingling_list = advance_info.jingling_list
	-- local jingling_count = advance_info.count

	-- if jingling_count <= 0 then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.Advance.PleaseEquipJingLing)
	-- 	return
	-- end
	local activate_item_id = AdvanceSkillData.Instance:GetActivateSkillItemId()
	local data = self.items[index + 1].cell:GetData()
	if data.item_id ~= nil and data.item_id > 0 then
		local advance_info = AdvanceSkillData.Instance:GetAdvanceSkillInfo()
		local skill_refresh_item_list = advance_info.skill_refresh_item_list
		if skill_refresh_item_list == nil or skill_refresh_item_list[index + 1] == nil then
			return
		end

		local is_cell_active = skill_refresh_item_list[index + 1].is_active
		if is_cell_active == 0 then
			-- 技能 刷新激活,param1 刷新索引
			AdvanceSkillCtrl.Instance:SendAdvanceSkillOpera(JINGLING_OPER_TYPE.JINGLING_OPER_REFRESH_ACTIVE, index)
		end
		 AdvanceSkillData.Instance:SetGetSkillViewCurCellIndex(index)
		 ViewManager.Instance:Open(ViewName.AdvanceSkillOneView)
		--AdvanceSkillCtrl.Instance:OpenFlsuhSkillLittleView()
	else
		local shop_item_cfg = ShopData.Instance:GetItemCfgById(activate_item_id)
		if shop_item_cfg == nil then
			return
		end

		local cost_bind_gold = shop_item_cfg.bind_gold
		local role_bind_gold = GameVoManager.Instance:GetMainRoleVo().bind_gold
		if role_bind_gold < cost_bind_gold and self.is_bind == 1 and self.is_auto_buy then
			self.is_auto_buy = false
		end
		
		if self.is_auto_buy then
			local is_bind = role_bind_gold < cost_bind_gold and 0 or 1
			MarketCtrl.Instance:SendShopBuy(activate_item_id, 1, is_bind, 0)
		else
		    --打开购买物品界面
			local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
				self.is_auto_buy = is_buy_quick
				self.is_bind = is_bind
			end
			local nofunc = function()
			end

		    TipsCtrl.Instance:ShowCommonBuyView(func, activate_item_id, nofunc, 1)
		end
	end

end

function AdvanceGetSkillView:OnFlush()
	local activate_item_id = AdvanceSkillData.Instance:GetActivateSkillItemId()
	local item_num = ItemData.Instance:GetItemNumInBagById(activate_item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(activate_item_id)
	local advance_info = AdvanceSkillData.Instance:GetAdvanceSkillInfo()
	local skill_refresh_item_list = advance_info.skill_refresh_item_list
	local free_refresh_times = AdvanceSkillData.Instance:GetFreeFlushLeftTimes()
	if skill_refresh_item_list == nil or next(skill_refresh_item_list) == nil then
		return
	end

	for i = 1, GameEnum.JING_LING_SKILL_REFRESH_ITEM_MAX do
		--如果激活了客户端这边相当于多了个物品，但服务端那边会把物品消耗掉
		local is_cell_active = skill_refresh_item_list[i].is_active
		if is_cell_active == 1 then
			if self.items[i] ~= nil then
				self.items[i].cell:SetData({item_id = activate_item_id, num = 1})
			end
			
			if self.bt_text_list[i] ~= nil then
				self.bt_text_list[i]:SetValue(Language.Advance.GetSkillBtText[1])
			end

			if self.text_item_name_list[i] ~= nil then
				self.text_item_name_list[i]:SetValue(item_cfg.name)
			end
			
			if self.red_point_list[i] ~= nil then
				self.red_point_list[i]:SetValue(free_refresh_times > 0)
			end
		-- 放一个减一个

		elseif item_num > 0 then
			if self.items[i] ~= nil then
				self.items[i].cell:SetData({item_id = activate_item_id, num = 1})
			end

			if self.bt_text_list[i] ~= nil then
				self.bt_text_list[i]:SetValue(Language.Advance.GetSkillBtText[1])
			end

			if self.text_item_name_list[i] ~= nil then
				self.text_item_name_list[i]:SetValue(item_cfg.name)
			end

			item_num = item_num - 1
			if self.red_point_list[i] ~= nil then
				self.red_point_list[i]:SetValue(true)
			end
		else
			if self.items[i] ~= nil then
				self.items[i].cell:Reset()
				self.items[i].cell:SetData(nil)
			end
			
			if self.bt_text_list[i] ~= nil then
				self.bt_text_list[i]:SetValue(Language.Advance.GetSkillBtText[2])
			end

			if self.text_item_name_list[i] ~= nil then
				self.text_item_name_list[i]:SetValue("")
			end
			
			if self.red_point_list[i] ~= nil then
				self.red_point_list[i]:SetValue(false)
			end
		end
	end
end

-- 物品不足，购买成功后刷新物品数量
function AdvanceGetSkillView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:Flush()
end