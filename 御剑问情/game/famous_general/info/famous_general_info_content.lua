FamousGeneralInfoContent = FamousGeneralInfoContent or BaseClass(BaseRender)

local ATTR_LIST_NUM = 3
local SKILL_NUM = 4
local VIEW_STATE =
{
	NO_ACTIVE = 1,
	ACTIVE = 2,
	FIGHTOUT = 3,
	FIGHTOUTED = 4,
}
function FamousGeneralInfoContent:__init()
	self.cur_select_index = 1
	self.init_scorller_num = 0
	self.role_cell_list = {}
	self.view_flag = self:FindVariable("view_flag")
	self.name = self:FindVariable("Name")
	self.introduce = self:FindVariable("IntroduceText")
	self.level = self:FindVariable("level")
	self.show_effect = self:FindVariable("show_effect")

	self.attr_list = {}
	for i=1, ATTR_LIST_NUM do
		self.attr_list[i] = {}
		self.attr_list[i].text = self:FindVariable("text" .. i)
		self.attr_list[i].cur_attr = self:FindVariable("cur_attr" .. i)
		self.attr_list[i].next_attr = self:FindVariable("next_attr" .. i)
	end

	self.skill_list = {}
	for i=1, SKILL_NUM do
		self.skill_list[i] = {}
		self:ListenEvent("OnClickSkill" .. i, BindTool.Bind(self.OnClickSkill, self, i))
		self.skill_list[i].icon = self:FindVariable("skill_icon" .. i)
		self.skill_list[i].skill_name = self:FindVariable("skill_name" .. i)
		self.skill_list[i].skill_hl = self:FindVariable("skill_hl" .. i)
	end
	self.skill_introduce = self:FindVariable("skill_introduce")
	self.cur_skill = self:FindVariable("cur_skill")
	self.show_guangwu_red = self:FindVariable("show_guangwu_red")
	self.show_fazhen_red = self:FindVariable("show_fazhen_red")
	self.fight_power = self:FindVariable("fight_power")

	self.get_way_desc = self:FindVariable("get_way_desc")
	self.show_get_way = self:FindVariable("show_get_way")

	--特殊天神相关 大目标相关            
	self.special_tian_shen_is_active = self:FindVariable("SpecialTianShenIsActive")
	self.show_special_tian_shen_effect = self:FindVariable("ShowSpecialTianShenEffect")
	self.special_tian_shen_add_per = self:FindVariable("SpecialTianShenAddPer")
	self.special_tian_shen_is_free = self:FindVariable("SpecialTianShenIsFree")
	self.special_tian_shen_free_time = self:FindVariable("SpecialTianShenFreeTime")
	self.special_tian_shen_image = self:FindVariable("SpecialTianShenImage")
	--小目标相关
	self.is_show_big_target = self:FindVariable("IsShowBigTarget")
	self.small_target_title_image = self:FindVariable("SmallTargetTitleImage")
	self.is_can_free_get_small_target = self:FindVariable("IsCanFreeGetSmallTarget")
	self.small_target_power = self:FindVariable("SmallTargetPower")
	self.small_target_free_time = self:FindVariable("SmallTargetFreeTime")
	self.small_target_is_free = self:FindVariable("FreeGetSmallTargetIsEnd")
	
	local display = self:FindObj("Display")
	self.role_model = RoleModel.New()
	self.role_model:SetDisplay(display.ui3d_display)

	self.role_list = self:FindObj("RoleList")
	local list_delegate = self.role_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRoleNum, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRoleCell, self)

	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickFight", BindTool.Bind(self.OnClickFight, self))
	self:ListenEvent("OnClickGuangWu", BindTool.Bind(self.OnClickGuangWu, self))
	self:ListenEvent("OnClickFaZhen", BindTool.Bind(self.OnClickFaZhen, self))
	self:ListenEvent("OnClickAllAttr", BindTool.Bind(self.OnClickAllAttr, self))
	self:ListenEvent("OnClickGo", BindTool.Bind(self.OnClickGo, self))
	self:ListenEvent("OnClickSpecialTianShen", BindTool.Bind(self.OnClickSpecialTianShen, self))
	self:ListenEvent("OnClickOpenSmallTarget", BindTool.Bind(self.OnClickOpenSmallTarget, self))
	
	self:InitData()
end
 
function FamousGeneralInfoContent:InitData()
	for i=1, ATTR_LIST_NUM do
		self.attr_list[i].text:SetValue(Language.NormalAttr[i])
	end
end

function FamousGeneralInfoContent:__delete()
	if self.role_model then
		self.role_model:DeleteMe()
		self.role_model = nil
	end

	if RemindManager.Instance and self.remind_change then
		RemindManager.Instance:UnBind(self.remind_change)
		self.remind_change = nil
	end
end

function FamousGeneralInfoContent:GetRoleNum()
	return FamousGeneralData.Instance:GetListNum()
end

function FamousGeneralInfoContent:RefreshRoleCell(cell, cell_index)
	cell_index = cell_index + 1
	local item_cell = self.role_cell_list[cell]
	local data_list = FamousGeneralData.Instance:GetSortGeneralList()
	if not item_cell then
		item_cell = GeneralHeadRender.New(cell.gameObject)
		self.role_cell_list[cell] = item_cell
		item_cell.parent_view = self
	end
	item_cell:SetIndex(cell_index)
	if data_list[cell_index] then
		item_cell:SetTabIndex(TabIndex.famous_general_info)
		item_cell:SetData(data_list[cell_index])
		item_cell:SetClickCallBAck(function (data)
			self:OnClickRole(data)
		end)
	end
	item_cell:FlushHL(self.cur_select_index)
end

function FamousGeneralInfoContent:ShowGetWayDesc(is_on)
	self.show_get_way:SetValue(is_on)
end

function FamousGeneralInfoContent:FlushGetWay()
	local data_list = FamousGeneralData.Instance:GetSortGeneralList()

	local cfg =  data_list[self.cur_select_index]
	if nil == cfg then
		return
	end

	if cfg.get_msg then
		self.show_get_way:SetValue(true)
		self.get_way_desc:SetValue(cfg.get_msg)
	end
end

function FamousGeneralInfoContent:OnFlush(param_list)
	self:ConstructData()
	self:SetFlag()
	for k,v in pairs(param_list) do
		if k == "active" then

		elseif k == "flush_model" then
			self:ModelFlush()
		elseif k == "open" then
			self:Jump()
			self:OnClickSkill(1)
		elseif k == "change_index" then
			self:OnClickSkill(self.cur_skill_index)
		end
	end
	self:FlushGetWay()
	self:SetModel()
	self:SetInfo()
	self:SetSkill()
	ViewManager.Instance:FlushView(ViewName.FamousGeneralFaZhenView)
	ViewManager.Instance:FlushView(ViewName.FamousGeneralGuangWuView)
	self.role_list.scroller:RefreshActiveCellViews()
	self:SpecialGeneralDataInfo()
	-- local num = FamousGeneralData.Instance:GetListNum()
	-- self.role_list.scroll_rect.horizontalNormalizedPosition = (self.cur_select_index - 1) / num
end

function FamousGeneralInfoContent:ConstructData()
	self.construct = true
	local data_instance = FamousGeneralData.Instance
	self.name_value = data_instance:GetGeneralName(self.cur_select_index)
	self.introduce_value = data_instance:GetIntroduce(self.cur_select_index)
	self.level_value = data_instance:GetLevel(self.cur_select_index)
	self.seq = data_instance:GetDataSeq(self.cur_select_index)

	self.attr_list_values = {}
	for i=1, ATTR_LIST_NUM do
		self.attr_list_values[i] = {}
		self.attr_list_values[i].cur_attr = data_instance:GetAttr(self.cur_select_index, i)
		self.attr_list_values[i].next_attr = data_instance:GetNextAttr(self.cur_select_index, i)
	end

	self.skill_list_values = {}
	for i=1, SKILL_NUM do
		self.skill_list_values[i] = {}
		self.skill_list_values[i].icon = data_instance:GetSkillIcon(self.cur_select_index, i)
		self.skill_list_values[i].name = data_instance:GetSkillName(self.cur_select_index, i)
		self.skill_list_values[i].introduce = data_instance:GetSkillDesc(self.cur_select_index, i)
	end
	if self.role_res_id == data_instance:GetGeneralModel(self.cur_select_index) then
		self.set_model_flag = false
	else
		self.set_model_flag = true
		self.role_res_id = data_instance:GetGeneralModel(self.cur_select_index)
	end
	self.is_active = FamousGeneralData.Instance:IsActiveGeneral(self.cur_select_index)
	if self.is_active then
		local guangwu_num = FamousGeneralData.Instance:GetGuangwuItemNum()
		self.show_guangwu_red_value = guangwu_num > 0 and not FamousGeneralData.Instance:GetLookGuangwu()
		
		local fazhen_num = FamousGeneralData.Instance:GetFaZhenItemNum()
		self.show_fazhen_red_value = fazhen_num > 0 and not FamousGeneralData.Instance:GetLookFaZhen()
	end
	self.is_fight_out = GeneralSkillData.Instance:IsFightOut(self.seq)
	self.fight_power_value = FamousGeneralData.Instance:GetSingerGeneralPower(self.cur_select_index)
end

function FamousGeneralInfoContent:SetFlag()
	local flag = VIEW_STATE.NO_ACTIVE 
	if self.is_active and self.is_fight_out then
		self.view_flag:SetValue(VIEW_STATE.FIGHTOUTED)
	elseif self.is_active and not self.is_fight_out then
		self.view_flag:SetValue(VIEW_STATE.FIGHTOUT)
	elseif not self.is_active then
		self.view_flag:SetValue(VIEW_STATE.NO_ACTIVE)
	end
	
end

function FamousGeneralInfoContent:SetModel()
	if self.construct == nil or not self.set_model_flag then
		return
	end

	local bundle, asset = ResPath.GetGeneralRes(self.role_res_id)
	self.role_model:SetMainAsset(bundle, asset, function ()
		self:ModelFlush()
	end)
	self.role_model:SetTrigger("attack3")
end

function FamousGeneralInfoContent:ModelFlush()
	if self.role_model then
		local fazhen_objs = FindObjsByName(self.role_model.draw_obj:GetPart(SceneObjPart.Main).obj.transform, "fazhen_effect")
		local weapon_objs = FindObjsByName(self.role_model.draw_obj:GetPart(SceneObjPart.Main).obj.transform, "weapon_effect")
		for k,v in pairs(fazhen_objs) do
			v.gameObject:SetActive(FamousGeneralData.Instance:IsShowFaZhen(self.cur_select_index))
		end
		for k,v in pairs(weapon_objs) do
			v.gameObject:SetActive(FamousGeneralData.Instance:IsShowGuangWu(self.cur_select_index))
		end
	end
end

function FamousGeneralInfoContent:SetInfo()
	if self.construct == nil  then
		return
	end

	self.name:SetValue(self.name_value)
	self.introduce:SetValue(self.introduce_value)
	self.level:SetValue(self.level_value)
	self.fight_power:SetValue(self.fight_power_value)



	for i=1, ATTR_LIST_NUM do
		self.attr_list[i].cur_attr:SetValue(self.attr_list_values[i].cur_attr)
		self.attr_list[i].next_attr:SetValue(self.attr_list_values[i].next_attr)
	end
	if self.is_active then
		self.show_guangwu_red:SetValue(self.show_guangwu_red_value)
		self.show_fazhen_red:SetValue(self.show_fazhen_red_value)
	else
		if self.level_value == 0 then
			local data_instance = FamousGeneralData.Instance
			self.level:SetValue(1)
			local attr_list_values = {}
			for i=1, ATTR_LIST_NUM do
				attr_list_values[i] = {}
				local list = data_instance:GetSortGeneralList()
				if not list[self.cur_select_index] then
					return
				end
				local sort_index = list[self.cur_select_index].sort_index
				attr_list_values[i].cur_attr = data_instance:GetCfgData(sort_index, 1)[GameEnum.AttrList[i]]
				attr_list_values[i].next_attr = data_instance:GetCfgData(sort_index, 2)[GameEnum.AttrList[i]]
			end
			for i=1, ATTR_LIST_NUM do
				self.attr_list[i].cur_attr:SetValue(attr_list_values[i].cur_attr)
				self.attr_list[i].next_attr:SetValue(attr_list_values[i].next_attr)
			end
			local fight_power_value = FamousGeneralData.Instance:GetSingerGeneralPower(self.cur_select_index, true)
			self.fight_power:SetValue(fight_power_value)
		end
	end
end

function FamousGeneralInfoContent:SetSkill()
	if self.construct == nil then
		return
	end

	for i=1, SKILL_NUM do
		local bundle, asset = ResPath.GetRoleChangeSkillIcon(self.skill_list_values[i].icon)
		self.skill_list[i].icon:SetAsset(bundle, asset)
		self.skill_list[i].skill_name:SetValue(self.skill_list_values[i].name)
	end
end

function FamousGeneralInfoContent:OnClickRole(index)
	self.cur_select_index = index
	for k,v in pairs(self.role_cell_list) do
		v:FlushHL(self.cur_select_index)
	end
	self:Flush("change_index")
end

function FamousGeneralInfoContent:OnClickSkill(skill_index)
	if self.skill_list_values[skill_index] == nil then
		return
	end

	self.cur_skill_index = skill_index
	self.cur_skill:SetValue(self.skill_list_values[skill_index].name)
	self.skill_introduce:SetValue(self.skill_list_values[skill_index].introduce)
	self:SetSkillHL(skill_index)
end

function FamousGeneralInfoContent:SetSkillHL(skill_index)
	for i, v in ipairs(self.skill_list) do
		if i == skill_index then
  			self.skill_list[i].skill_hl:SetValue(true)
		else
  			self.skill_list[i].skill_hl:SetValue(false)
		end
	end
end

function FamousGeneralInfoContent:OnClickHelp()
	
end

function FamousGeneralInfoContent:OnClickFight()
	if self.construct == nil then
		return
	end
	
	FamousGeneralCtrl.Instance:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_MAIN_SLOT, self.seq)
end

function FamousGeneralInfoContent:OnClickGuangWu()
	ViewManager.Instance:Open(ViewName.FamousGeneralGuangWuView, 0, "set_index", {index = self.cur_select_index})
end

function FamousGeneralInfoContent:OnClickFaZhen()
	ViewManager.Instance:Open(ViewName.FamousGeneralFaZhenView, 0, "set_index", {index = self.cur_select_index})
end

function FamousGeneralInfoContent:OnClickAllAttr()
	local _, attr = FamousGeneralData.Instance:GetTotalGeneralPower()
	TipsCtrl.Instance:ShowAttrView(attr)
end

function FamousGeneralInfoContent:OnClickGo()
	local data_list = FamousGeneralData.Instance:GetSortGeneralList()
	local cfg =  data_list[self.cur_select_index]
	if nil == cfg then
		return
	end

	local str = Split(cfg.open_panel, "#")
	--Vip面板特殊处理
	if str[1] == ViewName.VipView then
		VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.VIP)
		VipData.Instance:SetOpenParam(tonumber(str[3]))
	end
	ViewManager.Instance:OpenByCfg(cfg.open_panel)
end

function FamousGeneralInfoContent:SetAnim()
	if self.role_model then
		self.role_model:SetTrigger("attack3")
	end
end

function FamousGeneralInfoContent:Jump()
	if self.construct then
		local list = FamousGeneralData.Instance:GetSortGeneralList()
		local num = FamousGeneralData.Instance:GetListNum()
		local index = GeneralSkillData.Instance:GetMainSlot()
		if index ~= -1 then
			for k,v in ipairs(list) do
				if v.seq == index then
					self:OnClickRole(k)
					if self.jump_panel then
						self[self.jump_panel](self)
						self.jump_panel = nil
					end
					break
				end
			end
		end
	end
end

function FamousGeneralInfoContent:SetJump(name)
	self.jump_panel = name
end

function FamousGeneralInfoContent:ShowEffect()
	if self.in_effect then
		return
	end
	self.in_effect = true
	self.show_effect:SetValue(true)
	GlobalTimerQuest:AddDelayTimer(function ()
		if self.show_effect then
			self.show_effect:SetValue(false)
			self.in_effect = false
		end
	end, 1)
end

-------------------------------------------------------------------------------------
--特殊天神相关
function FamousGeneralInfoContent:SpecialGeneralDataInfo()
	local is_show_small_target = SpecialGeneralData.Instance:IsShowSmallTarget()
	local speical_img_id = SpecialGeneralData.Instance:GetSpecialGeneraImgId()
	self.is_show_big_target:SetValue(not is_show_small_target)
	if is_show_small_target then --小目标
		self:SmallTargetConstantData()
		self:SmallTargetNotConstantData(speical_img_id, GENERAL_TARGET_TYPE.SMALL_TARGET)
	else -- 大目标
		self:BigTargetConstantData()
		self:BigTargetNotConstantData(speical_img_id, GENERAL_TARGET_TYPE.BIG_TARGET)
	end
end

--大目标 变动显示
function FamousGeneralInfoContent:BigTargetNotConstantData(speical_img_id, target_type)
	local is_active = SpecialGeneralData.Instance:SpecialImageIsActive(speical_img_id)
	local is_have_active_item = SpecialGeneralData.Instance:BagIsHaveActiveNeedItem(speical_img_id)
	local active_is_end = SpecialGeneralData.Instance:GetFreeActiveIsEnd(speical_img_id)

	self.show_special_tian_shen_effect:SetValue(not is_active)
	self.special_tian_shen_is_active:SetValue(is_active)
	self.special_tian_shen_is_free:SetValue(not active_is_end)
	self:RemoveCountDown()

	if active_is_end then
		self:ClearSpecialGeneraFreeData(target_type)
		return
	end

	local end_time = SpecialGeneralData.Instance:GetActiveFreeEndTimestamp(speical_img_id)
	self:FulshSpecialGeneralFreeTime(end_time, target_type)
end

--小目标 变动显示
function FamousGeneralInfoContent:SmallTargetNotConstantData(speical_img_id, target_type)
	local is_free_end = SpecialGeneralData.Instance:FreeActiveTimeIsEnd(GENERAL_TARGET_TYPE.SMALL_TARGET)
	local is_can_free = SpecialGeneralData.Instance:SmallTargetIsCanFreeGet()
	self.is_can_free_get_small_target:SetValue(is_can_free)
	self.small_target_is_free:SetValue(not is_free_end)
	self:RemoveCountDown()

	if is_free_end then
		self:ClearSpecialGeneraFreeData(target_type)
		return
	end

	local end_time = SpecialGeneralData.Instance:GetActiveFreeEndTimestamp(speical_img_id, target_type)
	self:FulshSpecialGeneralFreeTime(end_time, target_type)
end

--小目标固定显示
function FamousGeneralInfoContent:SmallTargetConstantData()
	if self.set_small_target then
		return 
	end

	self.set_small_target = true
	local small_target_title_image = SpecialGeneralData.Instance:GetSmallTargetShowTitleId()
	local bundle, asset = ResPath.GetTitleIcon(small_target_title_image)
	self.small_target_title_image:SetAsset(bundle, asset)

	local power = SpecialGeneralData.Instance:SmallTargetFightPower()
	self.small_target_power:SetValue(power)
end

--大目标固定显示
function FamousGeneralInfoContent:BigTargetConstantData()
	if self.set_big_target then
		return 
	end

	self.set_big_target = true
	local speical_img_id = SpecialGeneralData.Instance:GetSpecialGeneraImgId()
	local cfg = SpecialGeneralData.Instance:GetSpecialImageCfgInfoByImageId(speical_img_id)
	local item_id = cfg.item_id or 0
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg and self.special_tian_shen_image then
		local item_bundle, item_asset = ResPath.GetItemIcon(item_cfg.icon_id)
		self.special_tian_shen_image:SetAsset(item_bundle, item_asset)
	end

	local per = cfg.add_other_soldier_attr_per or 0 			--万分比
	local per_text = per * 0.01
	self.special_tian_shen_add_per:SetValue(per_text)
end

--刷新免费时间
function FamousGeneralInfoContent:FulshSpecialGeneralFreeTime(end_time, target_type)
	if end_time == 0 then
		self:ClearSpecialGeneraFreeData(target_type)
		return
	end

	local now_time = TimeCtrl.Instance:GetServerTime()
	local rest_time = end_time - now_time
	self:SetJinJieFreeTime(rest_time, target_type)
	if rest_time >= 0 and nil == self.least_time_timer then
		self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetJinJieFreeTime(rest_time, target_type)
		end)
	else
		self:RemoveCountDown()
		self:ClearSpecialGeneraFreeData(target_type)
	end	
end

--移除免费倒计时
function FamousGeneralInfoContent:RemoveCountDown()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

--设置进阶时间
function FamousGeneralInfoContent:SetJinJieFreeTime(time, target_type)
	if time > 0 then
		local time_str = ""
		if time > 3600 * 24 then
			time_str = TimeUtil.FormatSecond(time, 7)
		else
			local time_list = TimeUtil.Format2TableDHMS(time)
			if time > 3600 then
				time_str = time_list.hour .. Language.Common.TimeList.h
			elseif time > 60 then
				time_str = time_list.min .. Language.Common.TimeList.min
			else
				time_str = time_list.s .. Language.Common.TimeList.s
			end
		end
		self:FreeTimeShow(time_str, target_type)
	else
		self:RemoveCountDown()
		self:ClearSpecialGeneraFreeData(target_type)
		self:SpecialGeneralDataInfo()
	end
end

--免费时间显示
function FamousGeneralInfoContent:FreeTimeShow(time, target_type)
	if target_type and target_type == GENERAL_TARGET_TYPE.SMALL_TARGET then --小目标
		self.small_target_free_time:SetValue(time)
	else    --大目标
		self.special_tian_shen_free_time:SetValue(time)
	end
end

--清除大目标/小目标免费数据 target_type 目标类型  不传默认大目标
function FamousGeneralInfoContent:ClearSpecialGeneraFreeData(target_type)
	if target_type and target_type == GENERAL_TARGET_TYPE.SMALL_TARGET then --小目标
		self.small_target_free_time:SetValue("")
		self.small_target_is_free:SetValue(false)
	else    --大目标
		self.special_tian_shen_free_time:SetValue("")
		self.special_tian_shen_is_free:SetValue(false)		
	end
end

--小目标点击事件
function FamousGeneralInfoContent:OnClickOpenSmallTarget()
	local function callback()
		local req_type = GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_SMALL_GOAL_BUY
		local is_can_free = SpecialGeneralData.Instance:SmallTargetIsCanFreeGet()
		
		if is_can_free then
			req_type = GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_SMALL_GOAL_FETCH
		end
		FamousGeneralCtrl.Instance:SendRequest(req_type)
	end

	local data = SpecialGeneralData.Instance:GetSmallTargetShowData(callback)
	TipsCtrl.Instance:ShowTimeLimitTitleView(data)
end

--大目标点击事件
function FamousGeneralInfoContent:OnClickSpecialTianShen()
	local special_img_id = SpecialGeneralData.Instance:GetSpecialGeneraImgId()
	FamousGeneralCtrl.Instance:OpenSpecialFamousTipView(special_img_id)
end

function FamousGeneralInfoContent:CloseCallBack()
	self:RemoveCountDown()
end