WeddingByView = WeddingByView or BaseClass(BaseView)

function WeddingByView:__init()
	self.ui_config = {"uis/views/marriageview", "WeddingByView"}
	self:SetMaskBg()
	self.view_layer = UiLayer.Pop
end

function WeddingByView:__delete()

end

function WeddingByView:LoadCallBack()
	self.from_name = self:FindVariable("FromName")
	self.sex_str = self:FindVariable("SexStr")
	self.wedding_str = self:FindVariable("WeddingStr")

	self.item_cell = {}
	for i = 1, 4 do
		self.item_cell[i] = {}
		self.item_cell[i].obj= self:FindObj("ItemReward" .. i)
		self.item_cell[i].cell = ItemCell.New()
		self.item_cell[i].cell:SetInstanceParent(self.item_cell[i].obj)
		self.item_cell[i].cell:SetData(nil)
	end

	self:ListenEvent("ClickAgree",BindTool.Bind(self.ClickBtn, self, 1))
	self:ListenEvent("ClickDisAgree",BindTool.Bind(self.ClickBtn, self, 0))
end

function WeddingByView:ReleaseCallBack()
	self.from_name = nil
	self.sex_str = nil
	self.wedding_str = nil
	self.item_cell1_obj = nil
	self.item_cell2_obj = nil

	for k, v in pairs(self.item_cell) do
		if v.cell then
			v.cell:DeleteMe()
		end
	end
	self.item_cell = {}

	self.equip_item_obj = nil
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

	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local hunli_info = MarriageData.Instance:GetHunliInfoByType(info.marry_type)
	if not next(hunli_info) then
		return
	end

	local reward_item = hunli_info.reward_item
	for i = 1, 3 do
		if reward_item[i - 1] then
			self.item_cell[i].cell:SetData(reward_item[i - 1])
			self.item_cell[i].obj:SetActive(true)
		else
			self.item_cell[i].obj:SetActive(false)
		end
	end

	local equip_reward_data = MarriageData.Instance:GetHunliEquipReward()
	local equip_data = {}
	equip_data.item_id = equip_reward_data.item_id
	self.item_cell[4].cell:SetData(equip_data, true)
end