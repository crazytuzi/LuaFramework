BeautyLockSkillTip = BeautyLockSkillTip or BaseClass(BaseView)

function BeautyLockSkillTip:__init()
	self.ui_config = {"uis/views/beauty","BeautyLockSkillTip"}
	self:SetMaskBg()

	self.skill_type = nil
	self.skill_index = nil
end

function BeautyLockSkillTip:LoadCallBack()
	self.consume_str = self:FindVariable("ConsumeStr")
	self.add_str = self:FindVariable("AddStr")

	self.consume_item = ItemCell.New()
	self.consume_item:SetInstanceParent(self:FindObj("ConsumeItem"))

	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickLock", BindTool.Bind(self.OnClickLock, self))
end

function BeautyLockSkillTip:ReleaseCallBack()
	if self.consume_item ~= nil then
		self.consume_item:DeleteMe()
		self.consume_item = nil
	end

	self.skill_type = nil
	self.skill_index = nil
	self.call_back = nil
	self.is_auto_buy = false

	self.consume_str = nil
	self.add_str = nil
end

function BeautyLockSkillTip:CloseCallBack()
	self.skill_type = nil
	self.skill_index = nil
	self.call_back = nil	
end

function BeautyLockSkillTip:ShowIndexCallBack()
	self:Flush()
end

function BeautyLockSkillTip:OnClickClose()
	self:Close()
end

function BeautyLockSkillTip:OnClickLock()
	if self.call_back == nil then
		return
	end	

	if self.skill_type == nil or self.skill_index == nil then
		return
	end

	local data = BeautyData.Instance:GetSkillLockInfo(self.skill_type, self.skill_index)
	if data == nil or next(data) == nil then
		return
	end
	local lock_cfg = BeautyData.Instance:GetSkillLockCfg(data.lock_num + 1)
	local has_num = ItemData.Instance:GetItemNumInBagById(lock_cfg.consume_item_id)
	local need_num = lock_cfg.consume_item_num

	if has_num < need_num and not self.is_auto_buy then
		-- 物品不足，弹出TIP框
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[lock_cfg.consume_item_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(lock_cfg.consume_item_id)
			return
		end

		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.is_auto_buy = is_buy_quick
			end

			self:Flush()
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, lock_cfg.consume_item_id, nil, need_num - has_num)
		return
	end

	self.call_back(self.is_auto_buy and 1 or 0)
	self:Close()
end

function BeautyLockSkillTip:SetData(skill_type, skill_index, call)
	self.skill_type = skill_type
	self.skill_index = skill_index
	self.call_back = call
	self:Open()
end

function BeautyLockSkillTip:OnFlush()
	if self.skill_type == nil or self.skill_index == nil then
		return
	end

	local data = BeautyData.Instance:GetSkillLockInfo(self.skill_type, self.skill_index)
	if data == nil or next(data) == nil then
		return
	end

	local lock_cfg = BeautyData.Instance:GetSkillLockCfg(data.lock_num + 1)
	if lock_cfg ~= nil and next(lock_cfg) ~= nil then
		if self.consume_item ~= nil then
			self.consume_item:SetData({item_id = lock_cfg.consume_item_id})
		end

		if self.consume_str ~= nil then
			local color = COLOR.RED
			local has_num = ItemData.Instance:GetItemNumInBagById(lock_cfg.consume_item_id)
			local need_num = lock_cfg.consume_item_num
			if has_num >= need_num then
				color = COLOR.GREEN
			end
			self.consume_str:SetValue(ToColorStr(has_num, color) .. "/" .. need_num)
		end

		if self.add_str ~= nil then
			local str = string.format(Language.Beaut.LockSkillTip, data.add_value)
			self.add_str:SetValue(str)
		end
	end
end