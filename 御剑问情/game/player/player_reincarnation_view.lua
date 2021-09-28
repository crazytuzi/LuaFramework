ReincarnationView = ReincarnationView or BaseClass(BaseRender)


function ReincarnationView:__init()
	self.atk = self:FindVariable("atk")
	self.add_atk = self:FindVariable("add_atk")

	self.def = self:FindVariable("def")
	self.add_def = self:FindVariable("add_def")

	self.hp = self:FindVariable("hp")
	self.add_hp = self:FindVariable("add_hp")

	self.cur_level = self:FindVariable("cur_level")
	self.next_level = self:FindVariable("next_level")
	self.need_level = self:FindVariable("need_level")
	self.item_num_text = self:FindVariable("number")
	self.is_maxlevel = self:FindVariable("is_maxlevel")

	self:ListenEvent("Closen",BindTool.Bind(self.OnClosen,self))
	self:ListenEvent("ZsClick",BindTool.Bind(self.ZsClick,self))

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item"))
	self.item_cell:ShowHighLight(false)

	-- 获取控件
	self.role_display = self:FindObj("RoleDisplay")
	-- self.role_model = RoleModel.New()

	--引导用按钮
	self.zs_button = self:FindObj("ZsButton")

	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
end

function ReincarnationView:__delete()
	if self.item_data_event ~= nil and ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

end


function ReincarnationView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:Flush()
end

function ReincarnationView:SetRoleData()
	local main_role = Scene.Instance:GetMainRole()
	self.role_model:SetDisplay(self.role_display.ui3d_display)
	self.role_model:SetRoleResid(main_role:GetRoleResId())
	self.role_model:SetWeaponResid(main_role:GetWeaponResId())
	self.role_model:SetWeapon2Resid(main_role:GetWeapon2ResId())
	self.role_model:SetWingResid(main_role:GetWingResId())
	--self.role_model:SetHaloResid(main_role:GetHaloResId())
end

function ReincarnationView:OpenCallBack()
	-- self:SetRoleData()
	self:Flush()
end

function ReincarnationView:OnClosen()
	self:Close()
end

function ReincarnationView:ZsClick()
	ReincarnationCtrl.Instance:SendRoleZhuanShengReq()
end

function ReincarnationView:GetZsButton()
	return self.zs_button
end

function ReincarnationView:OnFlush()
	local level = ReincarnationData.Instance:GetZsLevel()
	local data = ReincarnationData.Instance:GetZsDataByLevel(level)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level

	if level > 8 then
		self.cur_level:SetValue(data.name)
		self.atk:SetValue(data.gongji)
		self.def:SetValue(data.fangyu)
		self.hp:SetValue(data.maxhp)
		-- self.hit:SetValue(data.mingzhong)
		-- self.flash:SetValue(data.shanbi)
		self.is_maxlevel:SetValue(true)
		return
	end

	local next_data = ReincarnationData.Instance:GetZsDataByLevel(level + 1)
	if level > 0 then
		self.cur_level:SetValue(data.name)
		self.atk:SetValue(data.gongji)
		self.def:SetValue(data.fangyu)
		self.hp:SetValue(data.maxhp)
		-- self.hit:SetValue(data.mingzhong)
		-- self.flash:SetValue(data.shanbi)

		self.next_level:SetValue(next_data.name)
		local next_role_level = (level + 1) * 100
		-- if role_level >= next_role_level then
		-- 	self.need_level:SetValue(string.format(Language.Common.GreenZhuanLevel, 100, ToColorStr(data.name, TEXT_COLOR.BLUE_4)))
		-- else
		-- 	self.need_level:SetValue(string.format(Language.Common.RedZhuanLevel, 100, ToColorStr(data.name, TEXT_COLOR.BLUE_4)))
		-- end

		self.add_atk:SetValue(next_data.gongji - data.gongji)
		self.add_def:SetValue(next_data.fangyu - data.fangyu)
		self.add_hp:SetValue(next_data.maxhp - data.maxhp)
		-- self.add_hit:SetValue(next_data.mingzhong - data.mingzhong)
		-- self.add_flash:SetValue(next_data.shanbi - data.shanbi)
	else
		-- if role_level >= 100 then
		-- 	self.need_level:SetValue(string.format(Language.Common.GreenLevel, 100))
		-- else
		-- 	self.need_level:SetValue(string.format(Language.Common.RedLevel, 100))
		-- end
		self.cur_level:SetValue("0"..Language.Common.Zhuan)
		self.next_level:SetValue(next_data.name)
		self.atk:SetValue(0)
		self.def:SetValue(0)
		self.hp:SetValue(0)
		-- self.hit:SetValue(0)
		-- self.flash:SetValue(0)

		self.add_atk:SetValue(next_data.gongji)
		self.add_def:SetValue(next_data.fangyu)
		self.add_hp:SetValue(next_data.maxhp)
		-- self.add_hit:SetValue(next_data.mingzhong)
		-- self.add_flash:SetValue(next_data.shanbi)
	end

	local have_num = ItemData.Instance:GetItemNumInBagById(next_data.consume_item.item_id)
	local item_num = next_data.consume_item.num

	if have_num < item_num then
		self.item_num_text:SetValue(string.format("%s / %s", ToColorStr(have_num, TEXT_COLOR.RED), item_num))
	else
		self.item_num_text:SetValue(string.format("%s / %s", ToColorStr(have_num, TEXT_COLOR.BLUE1), item_num))
	end

	local item_data = {item_id = next_data.consume_item.item_id, is_bind = next_data.consume_item.is_bind}
	self.item_cell:SetData(item_data)
end

function ReincarnationView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end