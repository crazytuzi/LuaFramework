local MAX_ATTR_NUM = 3

--引导用格子
local ITEM_SELECT = {
	COL = 1,			--列
}

GeneralRenderView = GeneralRenderView or BaseClass(BaseRender)
function GeneralRenderView:__init()
	self.role_cell_list = {}
	self.normal_cell_list = {}
	self.cur_attr_list = {}
	self.next_attr_list = {}
	self.select_role_index = 1
	self.cur_select_index = 1
	self.cur_role_index = nil
	self.click_skill = 1
end

function GeneralRenderView:__delete()
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	for k,v in pairs(self.role_cell_list) do
		v:DeleteMe()
	end
	self.role_cell_list = {}

	for k,v in pairs(self.normal_cell_list) do
		v:DeleteMe()
	end
	self.normal_cell_list = {}

	if self.each_passive_skill then 
		self.each_passive_skill:DeleteMe()
		self.each_passive_skill = nil
	end

	if self.spe_passive_skill then 
		self.spe_passive_skill:DeleteMe()
		self.spe_passive_skill = nil
	end

	self.var_gongji = nil
	self.var_fangyu = nil
	self.var_shengming = nil
	self.pro_gongji = nil
	self.pro_fangyu = nil
	self.pro_shengming = nil
end

function GeneralRenderView:LoadCallBack()
	self.name = self:FindVariable("Name")
	self.introduce = self:FindVariable("IntroduceText")
	self.skill_name = self:FindVariable("SkillName")
	self.skill_desc = self:FindVariable("SkillDesc")
	self.is_max_level = self:FindVariable("IsMaxLevel")
	self.show_skill = self:FindVariable("ShowSkill")
	self.var_gongji = self:FindVariable("var_gongji")
	self.var_fangyu = self:FindVariable("var_fangyu")
	self.var_shengming = self:FindVariable("var_shengming")
	self.pro_gongji = self:FindVariable("pro_gongji")
	self.pro_fangyu = self:FindVariable("pro_fangyu")
	self.pro_shengming = self:FindVariable("pro_shengming")
	self.get_way = self:FindVariable("GetWay")

	for i = 1, MAX_ATTR_NUM do
		self.cur_attr_list[FamousGeneralData.SHOW_ATTR[i]] = self:FindVariable("CurAttr" .. i)
		self.next_attr_list[FamousGeneralData.SHOW_ATTR[i]] = self:FindVariable("NextAttr" .. i)
	end

	local display = self:FindObj("Display")
	self.role_model = RoleModel.New("famous_general_panel")
	self.role_model:SetDisplay(display.ui3d_display)

	self.role_list = self:FindObj("RoleList")
	local list_delegate = self.role_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRoleNum, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRoleCell, self)

	self.normal_skill = self:FindObj("NormalSkill")
	local list_delegate = self.normal_skill.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNormalSkillNum, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshNormalSkillCell, self)

	self:ListenEvent("OnClickLeft", BindTool.Bind(self.OnClickArrow, self, -1))
	self:ListenEvent("OnClickRight", BindTool.Bind(self.OnClickArrow, self, 1))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickOpenAttr", BindTool.Bind(self.OnClickOpenAttr, self))
	self:ListenEvent("OnClickGetWay", BindTool.Bind(self.OnClickGetWay, self))

	self.each_passive_skill = GeneralSkillRender.New(self:FindObj("SingleSkill"))
	self.each_passive_skill:ListenClick(BindTool.Bind(self.OnClickSingleSkillInfo, self))
	self.each_passive_skill:SetParent(self)
	self.each_passive_skill:SetIndex(0)

	self.spe_passive_skill = GeneralSkillRender.New(self:FindObj("SpeSkill"))
	self.spe_passive_skill:ListenClick(BindTool.Bind(self.OnClickSpeSkillInfo, self))
	self.spe_passive_skill:SetParent(self)
	self.spe_passive_skill:SetIndex(100)

	self.cur_select_index = FamousGeneralData.Instance:GetSelectIndex()
	self.select_role_index = FamousGeneralData.Instance:AfterSortList()[self.cur_select_index].seq + 1
end

function GeneralRenderView:OpenCallBack()
	self.role_list.scroller:ReloadData(0)
end

function GeneralRenderView:GetRoleNum()
	return #FamousGeneralData.Instance:AfterSortList()
end

function GeneralRenderView:RefreshRoleCell(cell, cell_index)
	cell_index = cell_index + 1
	local item_cell = self.role_cell_list[cell]
	local data_list = FamousGeneralData.Instance:AfterSortList()
	if not item_cell then
		item_cell = GeneralHeadRender.New(cell.gameObject)
		self.role_cell_list[cell] = item_cell
	end
	if FunctionGuide.Instance:GetIsGuide() then
		if cell_index == ITEM_SELECT.COL then
			self.item_btn_active = nil
			self.item_btn_active = item_cell:GetBtnActive()
		end
	end
	item_cell:SetParent(self)
	item_cell:SetIndex(cell_index)
	item_cell:SetData(data_list[cell_index])
	item_cell:ListenClick(BindTool.Bind(self.OnClickRoleListCell, self, cell_index, data_list[cell_index], item_cell))
	item_cell:CurSelectTab(1)
end

function GeneralRenderView:OnClickRoleListCell(cell_index, cell_data, item_cell)
	if self.cur_select_index == cell_index then return end
	FamousGeneralData.Instance:SetSelectIndex(cell_index)
	local last_select_data = FamousGeneralData.Instance:GetSingleDataBySeq(self.select_role_index - 1)
	local last_general_info = FamousGeneralData.Instance:GetGeneralSingleInfoBySeq(last_select_data.seq)

	self.select_role_index = cell_data.seq + 1
	self.cur_select_index = cell_index
	self:FlushAllHl()
	self:Flush()
	-- self:FlushSkillItem()

	local select_data = FamousGeneralData.Instance:GetSingleDataBySeq(self.select_role_index - 1)
	local general_info = FamousGeneralData.Instance:GetGeneralSingleInfoBySeq(select_data.seq)

	if general_info.active_skill_type == 0 and last_general_info.active_skill_type ~= 0 then
		if self.normal_cell_list ~= nil then
			for k,v in pairs(self.normal_cell_list) do
				if v ~= nil and v.index ~= nil and v.index == 1 and v.data ~= nil then
					self:OnClickSkill(v.index, v.data)
				end
			end
		end
	else
		if self.click_skill == 100 then
			self:OnClickSpeSkillInfo()
		end

		if self.click_skill == 0 then
			self:OnClickSingleSkillInfo()
		end
	end

	-- if self.click_skill == 0 then
	-- 	self:OnClickSingleSkillInfo()
	-- end
end

function GeneralRenderView:GetSelectIndex()
	return self.cur_select_index
end

function GeneralRenderView:GetSelectSeq()
	return self.select_role_index
end

function GeneralRenderView:GetNormalSkillNum()
	return #FamousGeneralData.Instance:GetSkillCfg()
end

function GeneralRenderView:RefreshNormalSkillCell(cell, cell_index)
	cell_index = cell_index + 1
	local item_cell = self.normal_cell_list[cell]
	local data_list = FamousGeneralData.Instance:GetSkillCfg()
	if not item_cell then
		item_cell = GeneralSkillRender.New(cell.gameObject)
		self.normal_cell_list[cell] = item_cell
	end
	item_cell:SetIndex(cell_index)
	item_cell:SetParent(self)
	item_cell:ListenClick(BindTool.Bind(self.OnClickSkill, self, cell_index, data_list[cell_index], item_cell))
	item_cell:SetData(data_list[cell_index])
	item_cell:FlushHL()
end

function GeneralRenderView:GetSelectSkillIndex()
	return self.click_skill
end

function GeneralRenderView:OnClickSkill(cell_index, cell_data, item_cell)
	self.click_skill = cell_index
	self:FlushSkillAllHl()
	self:FlushSkillInfo(cell_data)
end

function GeneralRenderView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "list_data" then
			-- self.cur_select_index = FamousGeneralData.Instance:GetIndexBySeq(self.select_role_index - 1)
			self.role_list.scroller:RefreshAndReloadActiveCellViews(true)
			-- self.role_list.scroller:JumpToDataIndexForce(self.cur_select_index - 1)
		elseif k == "change_index" then
			-- self.cur_select_index = FamousGeneralData.Instance:GetSelectIndex()
			-- self.select_role_index = FamousGeneralData.Instance:AfterSortList()[self.cur_select_index].seq + 1
			self.role_list.scroller:RefreshAndReloadActiveCellViews(true)
			-- self.role_list.scroller:JumpToDataIndexForce(self.cur_select_index - 1)
		end
	end
	local select_data = FamousGeneralData.Instance:GetSingleDataBySeq(self.select_role_index - 1)
	local general_info = FamousGeneralData.Instance:GetGeneralSingleInfoBySeq(select_data.seq)
	local other_cfg = FamousGeneralData.Instance:GetOtherCfg()
	if not select_data or not general_info or not other_cfg then return end
	for k,v in pairs(select_data) do
		if self.cur_attr_list[k] then
			self.cur_attr_list[k]:SetValue(string.format(Language.FamousGeneral.InfoAttr, CommonDataManager.GetAttrName(k), v * general_info.level))
			self.next_attr_list[k]:SetValue(string.format(Language.FamousGeneral.InfoAttr, CommonDataManager.GetAttrName(k), v * (general_info.level + 1)))
		end
	end
	local name_str = ToColorStr(select_data.name, ITEM_COLOR[select_data.color])
	self.name:SetValue(string.format(Language.FamousGeneral.Name, name_str, general_info.level))
	if self.cur_role_index ~= self.select_role_index then
		self.role_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.GENERAL], select_data.image_id)
		local bundle, asset = ResPath.GetMingJiangRes(select_data.image_id)
		self.role_model:SetMainAsset(bundle, asset)
		self.role_model:SetTrigger("attack10")
		self.cur_role_index = self.select_role_index
	end

	local passive_cfg = FamousGeneralData.Instance:GetsinglePassive(self.select_role_index - 1)
	self.each_passive_skill:SetData(passive_cfg)
	self.introduce:SetValue(select_data.synopsis)

	local spe_skill_info = FamousGeneralData.Instance:GetSpePassive(self.select_role_index - 1)
	self.spe_passive_skill:SetData(spe_skill_info)

	self.is_max_level:SetValue(general_info.level >= other_cfg.max_level)
	self:FlushSkillItem()

	if self.show_skill ~= nil then
		self.show_skill:SetValue(general_info.active_skill_type ~= 0)
	end
	self.get_way:SetValue(select_data.get_msg)

	self:FlushSkillInfo()
end

function GeneralRenderView:OnClickArrow(num)
	local max_num = self:GetRoleNum()
	self.select_role_index = self.select_role_index + num
	if self.select_role_index > max_num then
		self.select_role_index = max_num
		return
	elseif self.select_role_index < 1 then
		self.select_role_index = 1
		return 
	end
	self:FlushAllHl()  
	self.role_list.scroller:JumpToDataIndex(self.select_role_index - 1)
	self:Flush()
end

function GeneralRenderView:FlushAllHl()
	for k,v in pairs(self.role_cell_list) do
		v:FlushHL()
	end
end

function GeneralRenderView:FlushSkillAllHl()
	for k,v in pairs(self.normal_cell_list) do
		v:FlushHL()
	end
	self.each_passive_skill:FlushHL()
	self.spe_passive_skill:FlushHL()
end

function GeneralRenderView:FlushSkillInfo(data)
	data = data or FamousGeneralData.Instance:GetSkillCfg()[self.click_skill]
	if not data then return end
	if data.skill_id then
		local skill_cfg = ConfigManager.Instance:GetAutoConfig("roleskill_auto").normal_skill[data.skill_id]
		if not skill_cfg then return end

		desc = string.gsub(skill_cfg.skill_desc, "%b()%%" , function(str)
			return tonumber(skill_cfg[string.sub(str, 2, -3)]) / 1000
		end)
		desc = string.gsub(desc, "%b[]%%" , function(str)
			return tonumber(skill_cfg[string.sub(str, 2, -3)]) / 100 .. "%"
		end)
		desc = string.gsub(desc, "%[.-%]" , function(str)
			return skill_cfg[string.sub(str, 2, -2)]
		end)

		self.skill_name:SetValue(skill_cfg.skill_name)
		self.skill_desc:SetValue(desc)
	else
		self.skill_name:SetValue(data.skill_name)
		self.skill_desc:SetValue(data.skill_tips)
	end
end

function GeneralRenderView:OnClickSingleSkillInfo()
	local passive_cfg = FamousGeneralData.Instance:GetsinglePassive(self.select_role_index - 1)
	if not passive_cfg or not next(passive_cfg) then return end
	self.skill_name:SetValue(passive_cfg.skill_name or "")
	self.skill_desc:SetValue(passive_cfg.skill_tips or "")
	self.click_skill = 0
	self:FlushSkillAllHl()
end

function GeneralRenderView:OnClickSpeSkillInfo()
	local passive_cfg = FamousGeneralData.Instance:GetSpePassive(self.select_role_index - 1)
	if not passive_cfg or not next(passive_cfg) then return end
	self.skill_name:SetValue(passive_cfg.skill_name or "")
	self.skill_desc:SetValue(passive_cfg.skill_tips or "")
	self.click_skill = 100
	self:FlushSkillAllHl()
end

function GeneralRenderView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(198)
end

function GeneralRenderView:OnClickOpenAttr()
	--FamousGeneralCtrl.Instance:OpenAttrView()
	local cfg, cap = FamousGeneralData.Instance:GetFamousCapAndAttr()
	TipsCtrl.Instance:OpenGeneralView(cfg)
end

function GeneralRenderView:GetItemBtnActive()
	return self.item_btn_active
end

function GeneralRenderView:FlushSkillItem()
	for k,v in pairs(self.normal_cell_list) do
		v:Flush()
	end
end

function GeneralRenderView:OnClickGetWay()
	local select_cfg = FamousGeneralData.Instance:GetSingleDataBySeq(self.select_role_index - 1)
	if not select_cfg then return end
	ViewManager.Instance:OpenByCfg(select_cfg.open_panel)
end