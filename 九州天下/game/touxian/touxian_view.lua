-- print_log("Shadow = ", self.test_obj, self.test_obj.gameObject:GetComponent(typeof(UnityEngine.UI.Shadow)))
-- print_log("UIGradient = ", self.test_obj, self.test_obj.gameObject:GetComponent(typeof(UIGradient)))
TouXianView = TouXianView or BaseClass(BaseView)
local MAX_ATTR_NUM = 3
local SHOW_ATTR = {
	"max_hp",
	"ming_zhong",
	"jian_ren",
}

function TouXianView:__init()
	self.ui_config = {"uis/views/touxianview", "TouXianView"}
	self:SetMaskBg()
	self.select_index = 1
	self.cell_list = {}
	self.attr_label_list = {}
	self.item_change_callback = BindTool.Bind(self.FlushItemNum, self)
end

function TouXianView:ReleaseCallBack()
	self.title_name = nil
	self.role_name = nil
	self.cur_capability = nil
	self.touxian_desc = nil
	self.skill_desc = nil
	self.item_num = nil
	self.list_view = nil
	self.guild_name = nil
	self.title_obj = nil
	-- self.auto_toggle = nil
	self.can_up = nil
	self.attr_label_list = {}

	self.skill_1 = nil
	self.skill_2 = nil
	self.skill_3 = nil
	self.show_skill_info = nil
	self.info_icon = nil
	self.skill_name = nil
	self.show_skill_desc = nil
	self.need_capability = nil
	self.show_red = nil
	self.up_btn = nil
	self.close_btn = nil

	if self.money_bar then 
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell= nil
	end

	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function TouXianView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickUp", BindTool.Bind(self.OnClickUp, self))
	self:ListenEvent("OnClickSkill1", BindTool.Bind(self.OnClickSkill, self, 1))
	self:ListenEvent("OnClickSkill2", BindTool.Bind(self.OnClickSkill, self, 2))
	self:ListenEvent("OnClickSkill3", BindTool.Bind(self.OnClickSkill, self, 3))
	self:ListenEvent("CloseSkillInfo", BindTool.Bind(self.CloseSkillInfo, self))

	self.title_name = self:FindVariable("TitleName")
	self.role_name = self:FindVariable("RoleName")
	self.guild_name = self:FindVariable("GuildName")
	self.title_obj = self:FindObj("TitleObj")
	self.cur_capability = self:FindVariable("Capability")
	self.touxian_desc = self:FindVariable("TouXianDesc")
	self.need_capability = self:FindVariable("NeedCapability")
	self.can_up = self:FindVariable("CanUp")
	self.show_red = self:FindVariable("ShowRed")

	-- 引导用
	self.up_btn = self:FindObj("UpBtn")
	self.close_btn = self:FindObj("BtnClose")

	for i = 1, MAX_ATTR_NUM do
		self.attr_label_list[SHOW_ATTR[i]] = self:FindVariable("label_" .. i)
	end
	self.skill_desc = self:FindVariable("SkillDesc")
	self.item_num = self:FindVariable("ItemNum")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))

	local display = self:FindObj("RoleDisplay")
	self.role_model = RoleModel.New("military_view")
	self.role_model:SetDisplay(display.ui3d_display)

	-- self.auto_toggle = self:FindObj("AutoToggle")
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.list_view.scroller:ReloadData(0)

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.role_model:SetModelResInfo(main_role_vo, false, true, true, false, true, false, true)

	-- 技能详情界面
	self.skill_1 = self:FindVariable("Skill1")
	self.skill_2 = self:FindVariable("Skill2")
	self.skill_3 = self:FindVariable("Skill3")
	self.show_skill_info = self:FindVariable("ShowSkillInfo")
	self.info_icon = self:FindVariable("InfoIcon")
	self.skill_name = self:FindVariable("SkillName")
	self.show_skill_desc = self:FindVariable("SkillInfoDesc")

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
end

function TouXianView:OpenCallBack()
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
	self:CheckJumpIndex()
	self:Flush()
end

function TouXianView:CloseCallBack()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
end

function TouXianView:GetNumberOfCells()
	return #TouXianData.Instance:GetLevelCfg()
end

function TouXianView:RefreshCell(cell, cell_index)
	local cur_cell = self.cell_list[cell]
	local data_list = TouXianData.Instance:GetLevelCfg()
	if cur_cell == nil then
		cur_cell = TouXianItem.New(cell.gameObject, self)
		self.cell_list[cell] = cur_cell
	end
	cell_index = cell_index + 1
	cur_cell:SetIndex(cell_index)
	cur_cell:SetData(data_list[cell_index])
end

function TouXianView:OnFlush(param_t)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local level_cfg = TouXianData.Instance:GetConfigByLevel(self.select_index)
	if not level_cfg or not next(level_cfg) then return end

	-- 显示配置表信息 guild_post guild_name
	local cam_set = ToColorStr(Language.Common.ScnenCampNameAbbr[main_role_vo.camp] .. "·", CAMP_COLOR[main_role_vo.camp])
	self.role_name:SetValue(cam_set .. main_role_vo.name)
	local guild_ser = ""
	if main_role_vo.guild_id > 0 then
		guild_ser = main_role_vo.guild_name .. Language.Convene.Post[2][main_role_vo.guild_post]
	end
	self.guild_name:SetValue(guild_ser)
	self.title_name:SetValue(level_cfg.title_name)
	self.touxian_desc:SetValue(level_cfg.title_descript)

	-- 渐变头衔
	TouXianView.SetGradientColor(level_cfg, self.title_obj.gameObject:GetComponent(typeof(UIGradient)))
	-- 显示属性
	local attr_list = CommonDataManager.GetAttributteByClass(level_cfg)
	for k,v in pairs(attr_list) do
		if self.attr_label_list[k] and v > 0 then
			local attr_str = string.format(Language.TouXian.ShowAttr, CommonDataManager.GetAttrName(k,true), v)
			self.attr_label_list[k]:SetValue(attr_str)
		end
	end
	local capability = CommonDataManager.GetCapability(attr_list)
	self.cur_capability:SetValue(capability)
	self.item_cell:SetData({item_id = level_cfg.stufff_id})
	self:FlushItemNum()
	self.list_view.scroller:RefreshActiveCellViews()

	local cur_level = TouXianData.Instance:GetCurLevel()
	local check_level = cur_level + 1
	cur_level = cur_level > 0 and cur_level or 1
	local cur_cfg = TouXianData.Instance:GetConfigByLevel(cur_level)
	if not next(cur_cfg) then
		self.skill_1:SetValue(false)
		self.skill_2:SetValue(false)
		-- self.skill_3:SetValue(false)
		return
	end

	self.skill_1:SetValue(cur_cfg.trigger_per_1 > 0)
	self.skill_2:SetValue(cur_cfg.trigger_per_2 > 0)
	-- 默认第三个技能永远亮着
	self.skill_3:SetValue(true)
	-- self.skill_3:SetValue(cur_cfg.trigger_per_3 > 0)
	self:FlushRightSkillInfo(cur_cfg)
	self.can_up:SetValue(self.select_index == check_level)
	self:CheckCanUp()
end

function TouXianView:FlushRightSkillInfo(cur_cfg)
	-- 技能1激活状态
	local desc = ""
	local other_cfg = TouXianData.Instance:GetOtherConfig()
	local name_1 = TouXianData:SkillActiveName(1)
	local name_2 = TouXianData:SkillActiveName(1)
	if cur_cfg.trigger_per_1 > 0 then
		local skill_info = string.format(other_cfg.skill_describe_1, cur_cfg.trigger_per_1, cur_cfg.skill_effect_1)
		desc = string.format(Language.TouXian.SkillActive, other_cfg.skill_name_1, skill_info)
	else
		desc = string.format(Language.TouXian.NotActive, name_1, other_cfg.skill_name_1)
	end

	-- 技能2激活状态
	if cur_cfg.trigger_per_2 > 0 then
		local skill_info = string.format(other_cfg.skill_describe_2, cur_cfg.skill_effect_2, cur_cfg.effect_times)
		desc = desc .. "\n" .. string.format(Language.TouXian.SkillActive, other_cfg.skill_name_2, skill_info)
	else
		desc = desc .. "\n" .. string.format(Language.TouXian.NotActive, name_2, other_cfg.skill_name_2)
	end
	-- 重新排版取消描述的显示
	-- self.skill_desc:SetValue(desc)
	if self.skill_desc then
		self.skill_desc:SetValue(" ")
	end

end

function TouXianView:SetSelectIndex(index)
	self.select_index = index
	self:Flush()
end

function TouXianView:GetSelectIndex()
	return self.select_index
end

function TouXianView:OnClickHelp()
	local tips_id = 241
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function TouXianView:OnClickUp()
	-- local is_auto = self.auto_toggle.toggle.isOn and 1 or 0
	-- if not is_auto then
	-- 	local cur_level = TouXianData.Instance:GetCurLevel() + 1
	-- 	local max_level = #TouXianData.Instance:GetLevelCfg()
	-- 	cur_level = cur_level >= max_level and max_level or cur_level
	-- 	local cur_cfg = TouXianData.Instance:GetConfigByLevel(cur_level)
	-- 	TipsCommonBuyView.AUTO_LIST[cur_cfg.stufff_id] = nil
	-- end
	TouXianCtrl.Instance:SendReq(TOUXIAN_OPERA_REQ_TYPE.REQ_UPGRADE_TITLE, is_auto)
end

function TouXianView:FlushAllHl()
	for k,v in pairs(self.cell_list) do
		v:FlushHl()
	end
end

function TouXianView:OnClickSkill(skill_index)
	self:FlushSkillInfo(skill_index)
	self.show_skill_info:SetValue(true)
end

function TouXianView.SetGradientColor(color_cfg, gradient)
	if not color_cfg or not next(color_cfg) or not gradient then return end
	local color1_list = Split(color_cfg.color1, "|")
	local color2_list = Split(color_cfg.color2, "|")
	gradient.Color1 = Color(color1_list[1], color1_list[2], color1_list[3], color1_list[4])
	gradient.Color2 = Color(color2_list[1], color2_list[2], color2_list[3], color2_list[4])
end

function TouXianView:FlushItemNum()
	if self.item_num then
		local level_cfg = TouXianData.Instance:GetConfigByLevel(self.select_index)
		local str = "0/0"
		if level_cfg then
			local need_num = level_cfg.stuff_num
			local own_num = ItemData.Instance:GetItemNumInBagById(level_cfg.stufff_id)
			local color = own_num >= need_num and COLOR.GREEN or COLOR.RED
			str = ToColorStr(own_num, color) .. "/" .. need_num
		end
		self.item_num:SetValue(str)
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local color = main_role_vo.capability >= level_cfg.upgrade_need_capa and COLOR.GREEN or COLOR.RED
		self.need_capability:SetValue(string.format(Language.TouXian.NextLevelCap, ToColorStr(level_cfg.upgrade_need_capa, color)))
	end
end

function TouXianView:CloseSkillInfo()
	self.show_skill_info:SetValue(false)
end

-- 技能详情界面数据刷新
function TouXianView:FlushSkillInfo(skill_index)
	local other_cfg = TouXianData.Instance:GetOtherConfig()
	if not other_cfg then return end
	local level_cfg = TouXianData.Instance:GetConfigByLevel(self.select_index)
	local name_skr = TouXianData.Instance:GetSkillNameByIndex(skill_index) or " "
	if not next(level_cfg) then return end
	local name_str = "skill_name_" .. skill_index
	local desc_str = "skill_describe_" .. skill_index
	local percent = skill_index == 1 and "trigger_per_1" or "skill_effect_2"
	local effect = skill_index == 1 and "skill_effect_1" or "effect_times"
	if skill_index == 3 then
		percent = "injure_maxhp_per"
		self.show_skill_desc:SetValue(string.format(other_cfg[desc_str], level_cfg[percent]))
	else
		self.show_skill_desc:SetValue(string.format(other_cfg[desc_str], level_cfg[percent], level_cfg[effect]))
	end
	self.info_icon:SetAsset(ResPath.GetTouXianImage("skill_" .. skill_index))
	self.skill_name:SetValue(name_skr)
end

function TouXianView:CheckJumpIndex()
	local cur_level = TouXianData.Instance:GetCurLevel()
	if cur_level == 0 then return end
	local max_level = #TouXianData.Instance:GetLevelCfg()
	self.select_index = cur_level + 1
	if self.select_index > max_level then
		self.select_index = max_level
	end
	if cur_level < max_level then
		self.list_view.scroller:JumpToDataIndexForce(self.select_index - 1)
	end
end

function TouXianView:CheckCanUp()
	local cur_level = TouXianData.Instance:GetCurLevel()
	local can_up_level = false
	local cur_cfg = TouXianData.Instance:GetConfigByLevel(self.select_index)
	if next(cur_cfg) then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_role_vo.capability >= cur_cfg.upgrade_need_capa and 
			ItemData.Instance:GetItemNumIsEnough(cur_cfg.stufff_id, cur_cfg.stuff_num) and 
			self.select_index - cur_level == 1 then
			can_up_level = true
		end
	end
	self.show_red:SetValue(can_up_level)
end

function TouXianView:GetUpBtn()
	return self.up_btn
end

function TouXianView:GetCloseBtn()
	return self.close_btn
end
-----------------------------ItemRender--------------------------------
TouXianItem = TouXianItem or BaseClass(BaseCell)
function TouXianItem:__init(instance, parent)
	self.parent = parent

	self.name_obj = self:FindObj("Name")
	self.name_str = self:FindVariable("name")
	self.show_hl = self:FindVariable("show_hl")
	self.cur_level = self:FindVariable("CurLevel")
	self.is_active = self:FindVariable("IsActive")
	self.can_up = self:FindVariable("CanUp")
	self:ListenEvent("OnClick", BindTool.Bind1(self.OnClickCell, self))
end

function TouXianItem:__delete()
	self.parent = nil
end

function TouXianItem:OnFlush()
	if self.data == nil or not next(self.data) then 
		return 
	end
	self.name_str:SetValue(self.data.title_name)
	if self.name_obj and not IsNil(self.name_obj.gameObject) and UIGradient ~= nil then
		TouXianView.SetGradientColor(self.data, self.name_obj.gameObject:GetComponent(typeof(UIGradient)))
	end
	
	self.parent:FlushAllHl()
	local cur_level = TouXianData.Instance:GetCurLevel()
	self.is_active:SetValue(cur_level >= self.index)

	local can_up_level = false
	local cur_level = TouXianData.Instance:GetCurLevel()
	local cur_cfg = TouXianData.Instance:GetConfigByLevel(self.data.titile_level)
	if next(cur_cfg) then
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		if main_role_vo.capability >= cur_cfg.upgrade_need_capa and
			ItemData.Instance:GetItemNumIsEnough(cur_cfg.stufff_id, cur_cfg.stuff_num) and
			self.data.titile_level - cur_level == 1  then
			can_up_level = true
		end
	end
	self.can_up:SetValue(can_up_level)
end

function TouXianItem:OnClickCell()
	self.parent:SetSelectIndex(self.index)
	self.parent:FlushAllHl()
end

function TouXianItem:FlushHl()
	local cur_index = self.parent:GetSelectIndex()
	self.show_hl:SetValue(cur_index == self.index)
end