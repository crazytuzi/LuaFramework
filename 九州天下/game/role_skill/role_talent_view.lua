RoleTalentView = RoleTalentView or BaseClass(BaseRender)

function RoleTalentView:__init(instance)
	self.cur_page = 1
	self.buy_num1 = 0
	self.buy_num2 = 0
	self.buy_num3 = 0
	self.cur_force_add = 0
	self.cur_command_add = 0
	self.cur_wisdom_add = 0
	self.cur_talent_index = 2
	self.cur_operate = 1
end

function RoleTalentView:__delete()
	if self.attr_tips then
		self.attr_tips:DeleteMe()
		self.attr_tips = nil
	end

	if self.talent_tips then
		self.talent_tips:DeleteMe()
		self.talent_tips = nil
	end

	if nil ~= self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	self.allocation_point = nil

	self.cur_page = nil
	self.buy_num1 = 0
	self.buy_num2 = 0
	self.buy_num3 = 0
	self.cur_force_add = 0
	self.cur_command_add = 0
	self.cur_wisdom_add = 0
	self.cur_talent_index = 0
	self.cur_force = nil
	self.cur_command = nil
	self.cur_wisdom = nil
	self.cur_talent_type = nil
	self.cur_talent_desc = nil
	self.cur_operate = nil

	for i=1,3 do
		self["show_dec_" .. i] = nil
		self["show_add_" .. i] = nil
		self["talent_" .. i] = nil
	end
end

function RoleTalentView:LoadCallBack(instance)
	--总属性Tips面板
	self.attr_tips = TalentAttrTips.New(self:FindObj("attr_tip"))
	self.attr_tips:SetActive(false)
	--兑换天赋点面板
	self.talent_tips = TalentTips.New(self:FindObj("talent_tip"))
	self.talent_tips:SetActive(false)

	self.display = self:FindObj("Display")

	self:ListenEvent("reset", BindTool.Bind2(self.DoTalentSystemOperate, self, 0))
	self:ListenEvent("save", BindTool.Bind2(self.DoTalentSystemOperate, self, 1))
	self:ListenEvent("click_force", BindTool.Bind2(self.SelectCurTalentType, self, 0))
	self:ListenEvent("click_command", BindTool.Bind2(self.SelectCurTalentType, self, 1))
	self:ListenEvent("click_wisdom", BindTool.Bind2(self.SelectCurTalentType, self, 2))
	self:ListenEvent("open_attr_tip", BindTool.Bind(self.ShowAttrTips, self))
	self:ListenEvent("close_attr_tip", BindTool.Bind(self.CloseAttrTips, self))
	self:ListenEvent("open_talent_tip", BindTool.Bind(self.ShowTalentTips, self))
	self:ListenEvent("close_talent_tip", BindTool.Bind(self.CloseTalentTips, self))
	self:ListenEvent("click_help", BindTool.Bind(self.OnClickHelp, self))

	for i=1,3 do
		self:ListenEvent("add_point" .. i, BindTool.Bind3(self.DistributeRoleTalentPoint, self, 1, i))
		self:ListenEvent("dec_point" .. i, BindTool.Bind3(self.DistributeRoleTalentPoint, self, 0, i))
		self["show_dec_" .. i] = self:FindVariable("show_dec_" .. i)
		self["show_add_" .. i] = self:FindVariable("show_add_" .. i)
	end

	self.allocation_point = self:FindVariable("allocation_point")
	self.cur_force = self:FindVariable("cur_force")
	self.cur_command = self:FindVariable("cur_command")
	self.cur_wisdom = self:FindVariable("cur_wisdom")
	self.cur_talent_type = self:FindVariable("cur_talent_type")
	self.cur_talent_desc = self:FindVariable("cur_talent_desc")
	self.show_power = self:FindVariable("show_power")

	self["talent_1"] = self:FindObj("Force")
	self["talent_2"] = self:FindObj("Command")
	self["talent_3"] = self:FindObj("Wisdom")

	self:FlushModel()
end

function RoleTalentView:OnFlush()
	local talent_data = RoleSkillData.Instance:GetRoleTalentData()
	local attr_list = talent_data.talent_attr_list
	self.allocation_point:SetValue(talent_data.remain_talent_points - self.buy_num1 - self.buy_num2 - self.buy_num3)
	self.cur_force:SetValue(self:ParseAddPointString(attr_list[1], self.cur_force_add))
	self.cur_command:SetValue(self:ParseAddPointString(attr_list[2], self.cur_command_add))
	self.cur_wisdom:SetValue(self:ParseAddPointString(attr_list[3], self.cur_wisdom_add))
	self.cur_talent_type:SetValue(Language.Common.TalentType[self.cur_talent_index + 1])
	self.cur_talent_desc:SetValue(Language.Common.TalentDesc[self.cur_talent_index + 1])

	local data = RoleSkillData.Instance:GetExchangeData()
	self.talent_tips:SetData(data)

	for i=1,3 do
		self:FlushSmallBtnState(i)
		if self["talent_" .. i] ~= nil then
			self["talent_" .. i].toggle.isOn = self.cur_talent_index + 1 == i
		end
	end
	self:ShowPower()
end

function RoleTalentView:ParseAddPointString(cur_val, add_val)
	if 0 == add_val then
		return cur_val
	else
		local str = string.format(cur_val .. Language.Common.AddPointString, add_val)
		return str
	end
end

function RoleTalentView:FlushModel()
	if not self.role_model then
		self.role_model = RoleModel.New()
		self.role_model:SetDisplay(self.display.ui3d_display)
	end
	if self.role_model then
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		self.role_model:RemoveMount()
		self.role_model:ResetRotation()
		self.role_model:SetModelResInfo(role_vo, nil, nil, nil, nil, true)
	end
end

function RoleTalentView:DistributeRoleTalentPoint(upvalue, talent_type)
	if self.cur_page then
		if 0 == upvalue then
			self["buy_num" .. talent_type] = self["buy_num" .. talent_type] - 1
		else
			self["buy_num" .. talent_type] = self["buy_num" .. talent_type] + 1
		end

		local talent_data = RoleSkillData.Instance:GetRoleTalentData()
		local attr_list = talent_data.talent_attr_list
		local now_buy_num = self.buy_num1 + self.buy_num2 + self.buy_num3
		if self["buy_num" .. talent_type] < 0 then
			self["buy_num" .. talent_type] = 0
		elseif now_buy_num > talent_data.remain_talent_points then
			self["buy_num" .. talent_type] = self["buy_num" .. talent_type] - 1
			SysMsgCtrl.Instance:ErrorRemind(Language.Common.OverflowMsg)
			return
		end

		self.cur_force_add = self.buy_num1
		self.cur_command_add = self.buy_num2
		self.cur_wisdom_add = self.buy_num3
		self:Flush()
	end
end

function RoleTalentView:CloseAttrTips()
	self.attr_tips:SetActive(false)
end

--总属性面板
function RoleTalentView:ShowAttrTips()
	-- if self.attr_tips.root_node.gameObject.activeSelf then
	-- 	self.attr_tips:SetActive(false)
	-- else
	-- 	local data = RoleSkillData.Instance:GetRoleAttrList()
	-- 	self.attr_tips:SetData(data)
	-- 	self.attr_tips:SetActive(true)
	-- end
	local data = RoleSkillData.Instance:GetRoleAttrList()
	TipsCtrl.Instance:OpenGeneralView(data)
end

function RoleTalentView:ShowPower()
	local data = RoleSkillData.Instance:GetRoleAttrList()
	local attribute = CommonStruct.AttributeNoUnderline()
	if data ~= nil then
		for k,v in pairs(data) do
			if v ~= nil and attribute[k] ~= nil then
				attribute[k] = attribute[k] + v
			end
		end
	end
	
	local talent_data = RoleSkillData.Instance:GetRoleTalentData()
	local ext_power = RoleSkillData.Instance:GetCapabilityByLevel(talent_data.total_talent_points)
	self.show_power:SetValue(CommonDataManager.GetCapability(attribute) + ext_power)
end

function RoleTalentView:CloseTalentTips()
	self.talent_tips:SetActive(false)
end

--总属性面板
function RoleTalentView:ShowTalentTips()
	if self.talent_tips.root_node.gameObject.activeSelf then
		self.talent_tips:SetActive(false)
	else
		local data = RoleSkillData.Instance:GetExchangeData()
		self.talent_tips:SetData(data)
		self.talent_tips:SetActive(true)
	end
end

function RoleTalentView:OnClickHelp()
	local help_id = 210
	TipsCtrl.Instance:ShowHelpTipView(help_id)
end

function RoleTalentView:FlushBuyNum()
	local talent_data = RoleSkillData.Instance:GetRoleTalentData()
	local attr_list = talent_data.talent_attr_list

	for i=1,3 do
		self["buy_num" .. i] = 0
	end
	self.cur_force_add = 0
	self.cur_command_add = 0
	self.cur_wisdom_add = 0
end

function RoleTalentView:DoTalentSystemOperate(index)
	local talent_data = RoleSkillData.Instance:GetRoleTalentData()
	local attr_list = talent_data.talent_attr_list
	if 0 == index then
		local cost = RoleSkillData.Instance:GetRoleTalentCfg().other[1].reset_talent_price
		local str= string.format(Language.Common.ResetTalentPage, cost)
		TipsCtrl.Instance:ShowCommonTip(function() 
			RoleSkillCtrl.Instance:SendTalentSystemOperateReq(TALENT_SYSTEM_REQ_TYPE.TALENT_SYSTEM_REQ_TYPE_RESET, self.cur_page - 1) end, nil, str)
		self:FlushBuyNum()
	elseif 1 == index then
		local attr_list = {self.cur_force_add + attr_list[1], self.cur_command_add + attr_list[2], self.cur_wisdom_add + attr_list[3]}
		RoleSkillCtrl.Instance:SendTalentSystemOperateReq(TALENT_SYSTEM_REQ_TYPE.TALENT_SYSTEM_REQ_TYPE_SAVE_INFO, self.cur_page - 1, attr_list)
		self:FlushBuyNum()
	end
end

function RoleTalentView:SelectCurTalentType(index)
	self.cur_talent_index = index
	--self:FlushBuyNum()
	self:Flush()
end

function RoleTalentView:FlushSmallBtnState(index)
	local talent_data = RoleSkillData.Instance:GetRoleTalentData()
	if talent_data.remain_talent_points > 0 then
		self["show_add_" .. index]:SetValue(true)
	else
		self["show_add_" .. index]:SetValue(false)
	end

	self["show_dec_" .. index]:SetValue(false)
	if 0 ~= self.cur_force_add and 1 == index then 
		self["show_dec_" .. 1]:SetValue(true)
	elseif 0 ~= self.cur_command_add and 2 == index then
		self["show_dec_" .. 2]:SetValue(true)
	elseif 0 ~= self.cur_wisdom_add and 3 == index then
		self["show_dec_" .. 3]:SetValue(true)
	end
end

----------------------------------------------------------------------------
--TalentAttrTips   		总属性Tips面板
----------------------------------------------------------------------------
TalentAttrTips = TalentAttrTips or BaseClass(BaseCell)

function TalentAttrTips:__init()
	self.num_power = self:FindVariable("num_power")
	self.cur_gongji = self:FindVariable("cur_gongji")
	self.cur_fangyu = self:FindVariable("cur_fangyu")
	self.cur_shengmin = self:FindVariable("cur_shengmin")

	-- self.show_gongji = self:FindVariable("show_gongji")
	-- self.show_fangyu = self:FindVariable("show_fangyu")
	-- self.show_hp = self:FindVariable("show_hp")
	-- self.show_cap = self:FindVariable("show_cap")
end

function TalentAttrTips:__delete()

end

function TalentAttrTips:OnFlush()
	local talent_data = RoleSkillData.Instance:GetRoleTalentData()
	local capability_add = CommonDataManager.GetCapability(self.data)
	local cap = talent_data.total_talent_points * 300 + capability_add
	-- self.show_gongji:SetValue(self.data.gongji > 0)
	-- self.show_fangyu:SetValue(self.data.maxhp > 0)
	-- self.show_hp:SetValue(self.data.fangyu > 0)
	-- self.show_cap:SetValue(cap > 0)

	self.cur_gongji:SetValue(self.data.gongji or 0)
	self.cur_shengmin:SetValue(self.data.maxhp or 0)
	self.cur_fangyu:SetValue(self.data.fangyu or 0)
	self.num_power:SetValue(cap)
end

----------------------------------------------------------------------------
--TalentTips   		兑换点数Tips面板
----------------------------------------------------------------------------
TalentTips = TalentTips or BaseClass(BaseCell)

function TalentTips:__init()
	self.single_cost_exp = self:FindVariable("single_cost_exp")
	self.single_cost_gold = self:FindVariable("single_cost_gold")
	self.cur_exp = self:FindVariable("cur_exp")
	self.cur_gold = self:FindVariable("cur_gold")
	self.remain_times = self:FindVariable("remain_times")
	self.converted_point = self:FindVariable("converted_point")

	self:ListenEvent("ExchangePoint", BindTool.Bind(self.ExchangeTalentPoint, self))
end

function TalentTips:__delete()

end

function TalentTips:ExchangeTalentPoint()
	RoleSkillCtrl.Instance:SendTalentSystemOperateReq(TALENT_SYSTEM_REQ_TYPE.TALENT_SYSTEM_REQ_TYPE_EXCHANGE)
end

function TalentTips:OnFlush()
	self.single_cost_gold:SetValue(self.data.bind_gold)
	self.single_cost_exp:SetValue(tostring(self.data.need_exp))
	self.remain_times:SetValue(self.data.exchange_times)

	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local exp_str = ""
	local bind_gold_str = ""
	if self.data.is_can then
		if role_vo.exp < self.data.need_exp then
			exp_str = ToColorStr(role_vo.exp, TEXT_COLOR.RED)
		else
			exp_str = ToColorStr(role_vo.exp, "#84410A")
		end

		if role_vo.bind_gold < self.data.bind_gold then
			bind_gold_str = ToColorStr(role_vo.bind_gold, TEXT_COLOR.RED)
		else
			bind_gold_str = ToColorStr(role_vo.bind_gold, "#84410A")
		end
	else
		exp_str = tostring(role_vo.exp)
		bind_gold_str = tostring(role_vo.bind_gold)
	end

	self.cur_exp:SetValue(exp_str)
	self.cur_gold:SetValue(bind_gold_str)

	local talent_data = RoleSkillData.Instance:GetRoleTalentData()
	local attr_list = talent_data.talent_attr_list
	self.converted_point:SetValue(talent_data.total_talent_points)
end