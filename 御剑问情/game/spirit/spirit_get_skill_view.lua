SpiritGetSkillView = SpiritGetSkillView or BaseClass(BaseView)

function SpiritGetSkillView:__init()
	self.ui_config = {"uis/views/spiritview_prefab", "GetSpriteSkillView"}
	self.play_audio = true
end

function SpiritGetSkillView:__delete()
end

function SpiritGetSkillView:ReleaseCallBack()
	for k, v in pairs(self.items) do
		v.cell:DeleteMe()
	end
	self.items = nil
	self.bt_text_list = {}
	self.show_yellow_btn = {}
	self.is_auto_buy = false

	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	self.item_data_event = nil
	self.text_item_name_list = {}
	self.red_point_list = {}
end

function SpiritGetSkillView:LoadCallBack()
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
	self.show_yellow_btn = {}
	for i = 1, GameEnum.JING_LING_SKILL_REFRESH_ITEM_MAX do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("Item"..i))
		-- item_cell:SetToggleGroup(self:FindObj("ItemToggleGroup").toggle_group)
		self.items[i] = {item = self:FindObj("Item"..i), cell = item_cell}

		self.bt_text_list[i] = self:FindVariable("text_bt_" .. i)
		self.text_item_name_list[i] = self:FindVariable("text_item_name" .. i)
		self.red_point_list[i] = self:FindVariable("is_show_red_point" .. i)
		self.show_yellow_btn[i] = self:FindVariable("show_blue_button" .. i)
	end
end

function SpiritGetSkillView:ShowIndexCallBack(index)
	self:Flush()
end

function SpiritGetSkillView:CloseAutoBuy()
	self.is_auto_buy = false
end

function SpiritGetSkillView:UseItem(index)
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local jingling_list = spirit_info.jingling_list
	local jingling_count = spirit_info.count

	-- if jingling_count <= 0 then
	-- 	SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.PleaseEquipJingLing)
	-- 	return
	-- end
	local activate_item_id = SpiritData.Instance:GetActivateSkillItemId()
	local data = self.items[index + 1].cell:GetData()
	if data.item_id ~= nil and data.item_id > 0 then
		local spirit_info = SpiritData.Instance:GetSpiritInfo()
		local skill_refresh_item_list = spirit_info.skill_refresh_item_list
		local is_cell_active = skill_refresh_item_list[index].is_active
		if is_cell_active == 0 then
			-- 技能 刷新激活,param1 刷新索引
			SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_REFRESH_ACTIVE, index)
		end
		SpiritData.Instance:SetGetSkillViewCurCellIndex(index)
		SpiritCtrl.Instance:OpenFlsuhSkillLittleView()
	else
		if self.is_auto_buy then
			MarketCtrl.Instance:SendShopBuy(activate_item_id, 1, 0, 0)
		else
		    --打开购买物品界面
			local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
				self.is_auto_buy = is_buy_quick
			end
			local nofunc = function()
			end

		    TipsCtrl.Instance:ShowCommonBuyView(func, activate_item_id, nofunc, 1)
		end
	end

end

function SpiritGetSkillView:OnFlush()
	local activate_item_id = SpiritData.Instance:GetActivateSkillItemId()
	local item_num = ItemData.Instance:GetItemNumInBagById(activate_item_id)
	local item_cfg = ItemData.Instance:GetItemConfig(activate_item_id)
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local skill_refresh_item_list = spirit_info.skill_refresh_item_list
	local free_refresh_times = SpiritData.Instance:GetFreeFlushLeftTimes()
	for i = 1, GameEnum.JING_LING_SKILL_REFRESH_ITEM_MAX do
		--如果激活了客户端这边相当于多了个物品，但服务端那边会把物品消耗掉
		local is_cell_active = skill_refresh_item_list[i - 1].is_active
		if is_cell_active == 1 then
			self.items[i].cell:SetData({item_id = activate_item_id, num = 1})
			self.bt_text_list[i]:SetValue(Language.JingLing.GetSkillBtText[1])
			self.show_yellow_btn[i]:SetValue(true)
			self.text_item_name_list[i]:SetValue(item_cfg.name)

			self.red_point_list[i]:SetValue(free_refresh_times > 0)
		-- 放一个减一个
		elseif item_num > 0 then
			self.items[i].cell:SetData({item_id = activate_item_id, num = 1})
			self.bt_text_list[i]:SetValue(Language.JingLing.GetSkillBtText[1])
			self.show_yellow_btn[i]:SetValue(true)
			self.text_item_name_list[i]:SetValue(item_cfg.name)
			item_num = item_num - 1
			self.red_point_list[i]:SetValue(true)
		else
			self.items[i].cell:Reset()
			self.items[i].cell:SetData(nil)
			self.bt_text_list[i]:SetValue(Language.JingLing.GetSkillBtText[2])
			self.show_yellow_btn[i]:SetValue(false)
			self.text_item_name_list[i]:SetValue("")
			self.red_point_list[i]:SetValue(false)
		end
	end
end

-- 物品不足，购买成功后刷新物品数量
function SpiritGetSkillView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:Flush()
end