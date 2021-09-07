SetFightRenderView = SetFightRenderView or BaseClass(BaseRender)
function SetFightRenderView:__init()
	self.general_list = {}
	self.general_flush = {}
end

function SetFightRenderView:__delete()
	for k,v in pairs(self.general_list) do
		if v.display then 
			v.display:DeleteMe()
		end
	end
	self.general_list = {}
	self.general_flush = {}
end

function SetFightRenderView:LoadCallBack()
	for i = 0, COMMON_CONSTS.GREATE_SOLDIER_SLOT_MAX_COUNT - 1 do
		local info = {}
		info.name = self:FindVariable("Name_" .. i)
		info.slot_name = self:FindVariable("slot_name_" .. i)
		info.fight_text = self:FindVariable("FightText_" .. i)
		info.level = self:FindVariable("Level_" .. i)
		info.active = self:FindVariable("IsActive_" .. i)
		info.red_point = self:FindVariable("Red_" .. i)
		info.role_red_point = self:FindVariable("Role_Red_" .. i)
		info.display = RoleModel.New("famous_general_panel")
		info.display:SetDisplay(self:FindObj("Display_" .. i).ui3d_display)
		self.general_list[i] = info
		self.general_flush[i] = 999999
		self:ListenEvent("Change_" .. i, BindTool.Bind(self.OnClickChange, self, i))
		self:ListenEvent("UpLevel_" .. i, BindTool.Bind(self.OnClickUpLevel, self, i))
	end
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self.btn_change_first = self:FindObj("Btn_Change_First")
	self.get_way = self:FindVariable("GetWay")
	self:ListenEvent("OnClickGetWay", BindTool.Bind(self.OnClickGetWay, self))
	self:Flush()
end

function SetFightRenderView:OnFlush()
	local slot_info = FamousGeneralData.Instance:GetslotInfo()
	if not slot_info then return end
	for k,v in pairs(slot_info) do
		if self.general_list[v.place] then
			self.general_list[v.place].level:SetValue("Lv." .. v.level)

			local slot_name, need_level = FamousGeneralData.Instance:GetSlotName(v.place)
			self.general_list[v.place].slot_name:SetValue(slot_name)
			self.general_list[v.place].fight_text:SetValue(string.format(Language.FamousGeneral.NeedLevel, need_level))
			if v.item_seq ~= -1 then
				local general_cfg = FamousGeneralData.Instance:GetSingleDataBySeq(v.item_seq)
				self.general_list[v.place].name:SetValue(general_cfg.name)
				local res_id = FamousGeneralData.Instance:GetResIdBySeq(v.item_seq)
				self.general_list[v.place].display:SetModelScale(v.place == 0 and Vector3(0.9, 0.9, 0.9) or Vector3(0.68, 0.68, 0.68))
				--显示点将模型
				if self.general_flush[v.place] ~= v.item_seq then
					local bundle, asset = ResPath.GetMingJiangRes(res_id)
					self.general_list[v.place].display:SetMainAsset(bundle, asset)
					self.general_list[v.place].active:SetValue(true)
				end
				self.general_flush[v.place] = v.item_seq
			else
				self.general_list[v.place].active:SetValue(false)
			end
			local solt_cfg = FamousGeneralData.Instance:GetSlotLevelCfg(v.level, v.place) or {}
			self.general_list[v.place].red_point:SetValue(ItemData.Instance:GetItemNumIsEnough(solt_cfg.item_id, 1))
			local has_general = FamousGeneralData.Instance:CheckGeneralPoolHasActive()
			local level = GameVoManager.Instance:GetMainRoleVo().level
			local level_reach = level >= need_level
			self.general_list[v.place].role_red_point:SetValue(has_general and level_reach)
			local other_info = FamousGeneralData.Instance:GetOtherCfg()
			self.get_way:SetValue(other_info.slot_get_msg)
		end
	end
end

function SetFightRenderView:OnClickChange(index)
	-- ViewName.GeneralSelectView
	-- ViewManager.Instance:Open(ViewName.GeneralSelectView)
	-- FamousGeneralCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_PUTON, index, index, param_3)

	local slot_name, need_level = FamousGeneralData.Instance:GetSlotName(index)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	if level < need_level then
		SysMsgCtrl.Instance:ErrorRemind(Language.CrossTeam.Levellimit)
		return
	end

	FamousGeneralCtrl.Instance:OpenSelectView(index)
end

function SetFightRenderView:OnClickUpLevel(index)
	FamousGeneralCtrl.Instance:OpenSlotUpView(index)
end

function SetFightRenderView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(200)
end

--引导用
function SetFightRenderView:GetBtnChangeFirst()
	if not self.btn_change_first then return end
	return self.btn_change_first
end

function SetFightRenderView:GetBtnChangeFirstOnClick()
	return BindTool.Bind(self.OnClickChange, self, 0)
end

function SetFightRenderView:OnClickGetWay()
	local other_info = FamousGeneralData.Instance:GetOtherCfg()
	if not other_info then return end
	ViewManager.Instance:OpenByCfg(other_info.slot_open_panel)
end