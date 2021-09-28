WeddingByView = WeddingByView or BaseClass(BaseView)

function WeddingByView:__init()
	self.ui_config = {"uis/views/marriageview_prefab", "WeddingByView"}
	self.view_layer = UiLayer.Pop
end

function WeddingByView:__delete()

end

function WeddingByView:LoadCallBack()
	self.from_name = self:FindVariable("FromName")
	self.sex_str = self:FindVariable("SexStr")
	self.wedding_str = self:FindVariable("WeddingStr")
	self.have_item = self:FindVariable("HaveItem")

	self.item_cell1 = ItemCell.New()
	self.item_cell1:SetInstanceParent(self:FindObj("ItemReward1"))
	self.item_cell1:SetData(nil)

	self.item_cell2 = ItemCell.New()
	self.item_cell2:SetInstanceParent(self:FindObj("ItemReward2"))
	self.item_cell2:SetData(nil)

	self.equip_item_obj = self:FindObj("ItemReward3")
	self.equip_cell = ItemCell.New()
	self.equip_cell:SetInstanceParent(self.equip_item_obj)
	self.equip_cell:SetData(nil)

	self:ListenEvent("ClickAgree",BindTool.Bind(self.ClickBtn, self, 1))
	self:ListenEvent("ClickDisAgree",BindTool.Bind(self.ClickBtn, self, 0))
end

function WeddingByView:ReleaseCallBack()
	if self.item_cell1 then
		self.item_cell1:DeleteMe()
		self.item_cell1 = nil
	end
	if self.item_cell2 then
		self.item_cell2:DeleteMe()
		self.item_cell2 = nil
	end

	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end

	self.from_name = nil
	self.sex_str = nil
	self.wedding_str = nil
	self.equip_item_obj = nil
	self.have_item = nil
end

function WeddingByView:OpenCallBack()
	self:Flush()
end

function WeddingByView:ClickBtn(is_accept)
	local info = MarriageData.Instance:GetReqWeddingInfo()
	if not next(info) then
		print_error("求婚信息为空！")
		return
	end

	if is_accept == 1 then
		--同意结婚打开摁指印界面
		ViewManager.Instance:Open(ViewName.WeddingHunShuView)
	end

	MarriageCtrl.Instance:SendMarryRet(info.marry_type, is_accept, info.req_uid)
	self:Close()
end

function WeddingByView:OnFlush()
	local info = MarriageData.Instance:GetReqWeddingInfo()
	if not next(info) then
		print_error("求婚信息为空！")
		return
	end
	local from_name = info.GameName
	self.from_name:SetValue(from_name)

	local friend_info = ScoietyData.Instance:GetFriendInfoByName(from_name)
	if next(friend_info) then
		local str = friend_info.sex == 1 and Language.Common.Person[3][1] or Language.Common.Person[3][2]
		self.sex_str:SetValue(str)
	end

	local hunli_name = Language.HunLiName[info.marry_type] or ""
	self.wedding_str:SetValue(hunli_name)

	local hunli_info = MarriageData.Instance:GetHunliInfoByType(info.marry_type)
	if not next(hunli_info) then
		return
	end

	-- 是否可以领取婚礼奖励
	local can_get_reward = MarriageData.Instance:IsCanGetHunliReward(info.marry_type + 1)
	if can_get_reward then
		self.have_item:SetValue(true)
		--设置第一个物品
		local reward_item = hunli_info.reward_type
		if nil ~= reward_item[0] then
			self.item_cell1:SetParentActive(true)
			self.item_cell1:SetData(reward_item[0])
		else
			self.item_cell1:SetParentActive(false)
		end

		--设置第二个物品（称号）
		if hunli_info.title_id > 0 then
			self.item_cell2:SetParentActive(true)
			self.item_cell2:SetData(hunli_info.reward_item[0])
		else
			self.item_cell2:SetParentActive(false)
		end

		if nil ~= reward_item[1] then
			self.equip_cell:SetParentActive(true)
			self.equip_cell:SetData(reward_item[1])
		else
			self.equip_cell:SetParentActive(false)
		end
	else
		self.have_item:SetValue(false)
	end
end