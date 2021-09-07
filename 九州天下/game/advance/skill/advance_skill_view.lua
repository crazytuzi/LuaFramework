AdvanceSkillView = AdvanceSkillView or BaseClass(BaseView)

local BAG_MAX_GRID_NUM = 50
local BAG_ROW = 2
local BAG_COLUMN = 5

local SKILL_MAX_GRID_NUM = 10
local SKILL_ROW = 2
local SKILL_COLUMN = 5

local STORAGDE_MAX_GRID_NUM = 50
local STORAGDE_ROW = 2
local STORAGDE_COLUMN = 5

local EFFECT_CD = 1

AdvanceSkillView.ViewType = {
	SKILL = 1,
	STORAGE = 2,
}

function AdvanceSkillView:__init()
	self.ui_config = {"uis/views/advanceview","AdvanceSkillView"}
	self.play_audio = true
	self:SetMaskBg()

	self.show_type = ADVANCE_SKILL_TYPE.MOUNT
	self.view_type = AdvanceSkillView.ViewType.SKILL
	self.bag_cells = {}
	self.skill_cells = {}
	self.storage_cells = {}
	self.show_model = {}
	self.is_learn = true
end

function AdvanceSkillView:__delete()
end

function AdvanceSkillView:ReleaseCallBack()
	self.show_type = ADVANCE_SKILL_TYPE.MOUNT
	self.view_type = AdvanceSkillView.ViewType.SKILL

	if self.bag_cells ~= nil then
		for k,v in pairs(self.bag_cells) do
			if v ~= nil then
				v:DeleteMe()
			end
		end

		self.bag_cells = {}
	end

	if self.skill_cells ~= nil then
		for k,v in pairs(self.skill_cells) do
			if v ~= nil then
				v:DeleteMe()
			end
		end

		self.skill_cells = {}
	end

	if self.storage_cells ~= nil then
		for k,v in pairs(self.storage_cells) do
			if v ~= nil then
				v:DeleteMe()
			end
		end

		self.storage_cells = {}
	end

	if self.show_model ~= nil then
		if self.show_model.model ~= nil then
			self.show_model.model:DeleteMe()
		end
		self.show_model = {}
	end	

	if self.player_data_event ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.player_data_event)
		self.player_data_event = nil
	end

	self.is_learn = true

	self.name_str = nil
	self.level_value = nil
	self.bag_name = nil
	self.cap_str = nil
	self.is_show_foot = nil
	self.is_show_learn = nil
	self.foot_dis = nil

	self.display = nil
	for i = 1, 3 do
		self["foot_dis_" .. i] = nil
	end	

	self.tab_list = {}
	self.tab_red_list = {}

	self.bag_list_view = nil
	self.skill_list_view = nil
	self.storage_list_view = nil
	self.bag_page_buttons = nil
	self.storage_page_buttons = nil
	self.grade_str = nil
	self.name_path = nil
	self.get_skill_redpoint = nil
	self.get_item_redpoint = nil
	self.get_skill_tuoyin_redpoint = nil
	self.get_skill_learn_redpoint = nil

	self.tab_str_list = {}
	self.tab_lock_list = {}
end

function AdvanceSkillView:LoadCallBack()
	self.name_str = self:FindVariable("text_sprite_name")
	self.level_value = self:FindVariable("text_sprite_level")
	self.bag_name = self:FindVariable("text_cur_bag_name")
	self.cap_str = self:FindVariable("total_zhanli")
	self.is_show_foot = self:FindVariable("IsShowFoot")
	self.is_show_learn = self:FindVariable("IsLearn")
	self.grade_str = self:FindVariable("GradeStr")
	self.name_path = self:FindVariable("NamePath")
	self.get_skill_redpoint = self:FindVariable("GetSkillRedPoint")
	self.get_skill_learn_redpoint = self:FindVariable("GetSkillLearnRedPoint")
	self.get_skill_tuoyin_redpoint = self:FindVariable("GetSkillRubbingRedPoint")

	self.tab_list = {}
	self.tab_list[ADVANCE_SKILL_TYPE.MOUNT] = self:FindObj("TabMount")
	self.tab_list[ADVANCE_SKILL_TYPE.WING] = self:FindObj("TabWing")
	self.tab_list[ADVANCE_SKILL_TYPE.HALO] = self:FindObj("TabHalo")
	self.tab_list[ADVANCE_SKILL_TYPE.FAZHEN] = self:FindObj("TabFaZhen")
	self.tab_list[ADVANCE_SKILL_TYPE.BEAUTY_HALO] = self:FindObj("TabBeautyHalo")
	self.tab_list[ADVANCE_SKILL_TYPE.HALIDOM] = self:FindObj("TabHalidom")
	self.tab_list[ADVANCE_SKILL_TYPE.FOOT] = self:FindObj("TabFootMark")
	self.tab_list[ADVANCE_SKILL_TYPE.MANTLE] = self:FindObj("TabMantle")

	self.tab_red_list = {}
	for k,v in pairs(ADVANCE_SKILL_TYPE) do
		self.tab_red_list[v] = self:FindVariable("ShowTabRed" .. v)
	end

	self.tab_str_list = {}
	for k,v in pairs(ADVANCE_SKILL_TYPE) do
		self.tab_str_list[v] = self:FindVariable("TabStr" .. v)
	end	

	self.tab_lock_list = {}
	for k,v in pairs(ADVANCE_SKILL_TYPE) do
		self.tab_lock_list[v] = self:FindVariable("TabLock" .. v)
	end	

	self.bag_page_buttons = self:FindObj("BagPageButtons")
	self.storage_page_buttons = self:FindObj("StoragePageButtons")

	self.display = self:FindObj("Display")
	self.foot_dis = self:FindObj("FootDis")
	self.get_item_redpoint = self:FindVariable("Getitem_RedPoint")
	for i = 1, 3 do
		self["foot_dis_" .. i] = self:FindObj("Foot" .. i)
	end

	local ui_foot = self:FindObj("UI_Foot")
	local foot_camera = self:FindObj("FootCamera")
	local camera = foot_camera:GetComponent(typeof(UnityEngine.Camera))
	local random_num = math.random(100, 9999)
	if not IsNil(camera) then
		--self.left_display.ui3d_display:Display(ui_foot.gameObject, camera)
		self.foot_dis.ui3d_display:DisplayPerspectiveWithOffset(ui_foot.gameObject, Vector3(random_num, random_num, random_num), Vector3(-1, 14, 2.2), Vector3(90, 0, 0))
	end

	self.bag_list_view = self:FindObj("SkillBagListView")
	local list_delegate = self.bag_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	self.book_item_list = AdvanceSkillData.Instance:GetBagSkillBookItem()
	self.skill_list_view = self:FindObj("SkillBookListView")
	list_delegate = self.skill_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.SkillGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.SkillRefreshCell, self)

	self.skill_storage_list = AdvanceSkillData.Instance:GetSkillStorageList()
	self.storage_list_view = self:FindObj("SkillStorageListView")
	list_delegate = self.storage_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.StorageGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.StorageRefreshCell, self)	

	self:ListenEvent("OnClickSkillPokedex", BindTool.Bind(self.OnClickSkillPokedex, self))
	self:ListenEvent("OnClickSkillGet", BindTool.Bind(self.OnClickSkillGet, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))

	self:ListenEvent("OnClickMount", BindTool.Bind(self.OnClickShowType, self, ADVANCE_SKILL_TYPE.MOUNT))
	self:ListenEvent("OnClickWing", BindTool.Bind(self.OnClickShowType, self, ADVANCE_SKILL_TYPE.WING))
	self:ListenEvent("OnClickHalo", BindTool.Bind(self.OnClickShowType, self, ADVANCE_SKILL_TYPE.HALO))
	self:ListenEvent("OnClickFaZhen", BindTool.Bind(self.OnClickShowType, self, ADVANCE_SKILL_TYPE.FAZHEN))
	self:ListenEvent("OnClickBeautyHalo", BindTool.Bind(self.OnClickShowType, self, ADVANCE_SKILL_TYPE.BEAUTY_HALO))
	self:ListenEvent("OnClickHalidom", BindTool.Bind(self.OnClickShowType, self, ADVANCE_SKILL_TYPE.HALIDOM))
	self:ListenEvent("OnClickFoot", BindTool.Bind(self.OnClickShowType, self, ADVANCE_SKILL_TYPE.FOOT))
	self:ListenEvent("OnClickMantle", BindTool.Bind(self.OnClickShowType, self, ADVANCE_SKILL_TYPE.MANTLE))

	self:ListenEvent("OnClickLearn", BindTool.Bind(self.OnClickLearn, self, true))
	self:ListenEvent("OnClickCopy", BindTool.Bind(self.OnClickCopy, self, false))
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))

	self:CheckTab()
	self:CheckTabRed()
end

function AdvanceSkillView:CheckTab()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local check_flag = false
	if self.tab_list ~= nil then
		for k,v in pairs(self.tab_list) do
			if v ~= nil then
				--local is_show = OpenFunData.Instance:CheckIsHide(ADVANCE_TAB_ACTIVE[k])
				--v:SetActive(is_show)
				local cfg = AdvanceSkillData.Instance:GetImageOpenCfg(k)
				local tab_str = Language.Advance.PercentAttrNameListNew[k]
				local is_lock = false
				if cfg ~= nil and next(cfg) ~= nil then
					if level < cfg.open_level then
						if not check_flag then
							tab_str = string.format(Language.Advance.AdvanceSkillTabLabel, cfg.open_level)
						else
							tab_str = Language.Advance.AdvanceSkillTabNoLabel
						end

						if not check_flag then
							check_flag = true
						end

						is_lock = true
					end
				end

				if self.tab_str_list[k] ~= nil then
					self.tab_str_list[k]:SetValue(tab_str)
				end

				if self.tab_lock_list[k] ~= nil then
					self.tab_lock_list[k]:SetValue(is_lock)
				end
			end
		end
	end
end

function AdvanceSkillView:CheckTabRed()
	if self.tab_red_list ~= nil then
		for k,v in pairs(self.tab_red_list) do
			if v ~= nil then
				local check_flag = AdvanceSkillData.Instance:SkillLearnRedPoint(k) or AdvanceSkillData.Instance:SkillTuoYinRedPoint(k) or AdvanceSkillData.Instance:GetItemShowRedPoint()
				v:SetValue(AdvanceSkillData.Instance:CheckIsCanOpen(k) and check_flag)
			end
		end
	end
end

function AdvanceSkillView:OpenCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	if self.player_data_event == nil then
		self.player_data_event = BindTool.Bind1(self.PlayerDataChange, self)
		PlayerData.Instance:ListenerAttrChange(self.player_data_event)
	end
end

function AdvanceSkillView:PlayerDataChange(attr_name, value, old_value)
	if attr_name == "level" then
		self:CheckTab()
	end
end

function AdvanceSkillView:CloseCallBack()
	if self.items ~= nil then
		for k,v in pairs(self.items) do
			if v ~= nil and v.cell ~= nil then
				v.cell:SetData({})
				v.cell:SetHighLight(false)
			end
		end
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.player_data_event ~= nil then
		PlayerData.Instance:UnlistenerAttrChange(self.player_data_event)
		self.player_data_event = nil
	end
end

function AdvanceSkillView:ShowIndexCallBack()
	self:Flush()
end

function AdvanceSkillView:OnClickClose()
	self:Close()
end

function AdvanceSkillView:GetShowType()
	return self.show_type
end

function AdvanceSkillView:OnClickSkillPokedex()
	AdvanceSkillCtrl.Instance:SetBookShowType(self.show_type)
	ViewManager.Instance:Open(ViewName.AdvanceSkillBookView)
end

function AdvanceSkillView:OnClickSkillGet()
	ViewManager.Instance:Open(ViewName.AdvanceSkillGetView)
end

function AdvanceSkillView:OnClickShowType(show_type)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local cfg = AdvanceSkillData.Instance:GetImageOpenCfg(show_type)
	if cfg ~= nil and next(cfg) ~= nil then
		if level < cfg.open_level then
			SysMsgCtrl.Instance:ErrorRemind(cfg.tips)

			if self.tab_list ~= nil and self.tab_list[self.show_type] then
				self.tab_list[self.show_type].toggle.isOn = true
			end
			return
		end
	end	

	self.show_type = show_type
	self:Flush()
end

function AdvanceSkillView:SetShowType(show_type)
	local level = GameVoManager.Instance:GetMainRoleVo().level
	local cfg = AdvanceSkillData.Instance:GetImageOpenCfg(show_type)
	if cfg ~= nil and next(cfg) ~= nil then
		if level < cfg.open_level then
			self.show_type = ADVANCE_SKILL_TYPE.MOUNT
			return
		end
	end	

	self.show_type = show_type
end

function AdvanceSkillView:OnClickLearn(value)
	self.is_learn = value
	if self.is_show_learn ~= nil then
		self.is_show_learn:SetValue(self.is_learn)
	end
	AdvanceSkillData.Instance:SetTableIndex(1)
	self.view_type = AdvanceSkillView.ViewType.SKILL
	self:Flush()
end

function AdvanceSkillView:OnClickCopy(value)
	self.is_learn = value
	if self.is_show_learn ~= nil then
		self.is_show_learn:SetValue(self.is_learn)
	end
	AdvanceSkillData.Instance:SetTableIndex(2)
	self.view_type = AdvanceSkillView.ViewType.STORAGE
	self:Flush()
end

function AdvanceSkillView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(42)
end

--点击格子事件
function AdvanceSkillView:HandleBagOnClick(data, group, group_index, data_index)
	if nil == data or nil == data.item_id then
		return
	end

	if nil == self.cur_data then
		SysMsgCtrl.Instance:ErrorRemind(Language.Advance.PleaseEquipJingLing)
		return
	end
	AdvanceSkillData.Instance:SetSpiritSkillViewCellData(data)
	AdvanceSkillCtrl.Instance:OpenSkillInfoView(AdvanceSkillInfoView.FromView.SpriteSkillBookBagView)
end

function AdvanceSkillView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM / BAG_ROW
end

function AdvanceSkillView:BagRefreshCell(cell, data_index)
	local group = self.bag_cells[cell]
	if group == nil  then
		group = AdvanceSkillBagGroup.New(cell.gameObject)
		self.bag_cells[cell] = group
	end
	group:SetToggleGroup(self.bag_list_view.toggle_group)
	local page = math.floor(data_index / BAG_COLUMN)
	local column = data_index - page * BAG_COLUMN
	local grid_count = BAG_COLUMN * BAG_ROW
	for i = 1, BAG_ROW do
		local index = (i - 1) * BAG_COLUMN + column + (page * grid_count)
		local data = nil
		data = self.book_item_list[index + 1] or {}
		group:SetData(i, data)
		group:ShowHighLight(i, false)
		group:ListenClick(i, BindTool.Bind(self.HandleBagOnClick, self, data, group, i, index))
	end
end

function AdvanceSkillView:SkillGetNumberOfCells()
	return SKILL_MAX_GRID_NUM / SKILL_ROW
end

function AdvanceSkillView:SkillRefreshCell(cell, data_index)
	local group = self.skill_cells[cell]
	if group == nil  then
		group = AdvanceSkillRenderGroup.New(cell.gameObject)
		self.skill_cells[cell] = group
	end
	group:SetToggleGroup(self.skill_list_view.toggle_group)

	local cur_sprite_skill_list = self.cur_data or {}
	local page = math.floor(data_index / SKILL_COLUMN)
	local column = data_index - page * SKILL_COLUMN
	local grid_count = SKILL_COLUMN * SKILL_ROW
	for i = 1, SKILL_ROW do
		local index = (i - 1) * SKILL_COLUMN + column + (page * grid_count)
		local data = nil
		data = cur_sprite_skill_list[index + 1]
		data = data or {}
		data.locked = false
		if data.index == nil then
			data.index = index
		end
		group:SetData(i, data)
	end
end

function AdvanceSkillView:StorageGetNumberOfCells()
	return STORAGDE_MAX_GRID_NUM / STORAGDE_ROW
end

function AdvanceSkillView:StorageRefreshCell(cell, data_index)
	local group = self.storage_cells[cell]
	if group == nil  then
		group = AdvanceSkillStorageGroup.New(cell.gameObject)
		self.storage_cells[cell] = group
	end

	local page = math.floor(data_index / STORAGDE_COLUMN)
	local column = data_index - page * STORAGDE_COLUMN
	local grid_count = STORAGDE_COLUMN * STORAGDE_ROW
	for i = 1, STORAGDE_ROW do
		local index = (i - 1) * STORAGDE_COLUMN + column + (page * grid_count)
		local data = {}
		data = self.skill_storage_list[index + 1]
		group:SetData(i, data)
	end
end

function AdvanceSkillView:FlsuhSkillView()
	self.book_item_list = AdvanceSkillData.Instance:GetBagSkillBookItem()
	if self.bag_list_view ~= nil then
		self.bag_list_view.scroller:RefreshActiveCellViews()
	end
end

function AdvanceSkillView:FlsuhStorageView()
	self.skill_storage_list = AdvanceSkillData.Instance:GetSkillStorageList()
	if self.storage_list_view ~= nil then
		self.storage_list_view.scroller:RefreshActiveCellViews()
	end
end

function AdvanceSkillView:ItemDataChangeCallback()
	--self:FlushView()
	self:Flush("flush_view")
end

function AdvanceSkillView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if "all" == k then
			self:CheckTab()
			self:CheckTabRed()
			self:FlushModel()
			if self.is_show_learn ~= nil then
				self.is_show_learn:SetValue(self.is_learn)
			end
			self:FlushView()
		elseif "flush_view" == k then
			self:FlushView()
		elseif "check_tab" == k then
			self:CheckTab()
			self:CheckTabRed()
		end
	end
end

function AdvanceSkillView:FlushView()
	self.cur_data = nil
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local advance_info = AdvanceSkillData.Instance:GetAdvanceSkillInfo()
	local image_list = advance_info.image_skills or {}

	if image_list[self.show_type] then
		self.cur_data = image_list[self.show_type]
	end

	if self.tab_list[self.show_type] ~= nil then
		self.tab_list[self.show_type].toggle.isOn = true
	end

	for k,v in pairs(self.tab_list) do
		if v ~= nil then
			if k == self.show_type then
				v.toggle.isOn = true
			else
				v.toggle.isOn = false
			end
		end
	end

	self.temp_spirit_list = image_list
	self.is_first = false

	local cur_advance_type = self.show_type
	AdvanceSkillData.Instance:SetCurAdvanceType(cur_advance_type)

	if self.view_type == AdvanceSkillView.ViewType.SKILL then
		self:FlsuhSkillView()
	else
		self:FlsuhStorageView()
	end

	self.bag_name:SetValue(Language.Advance.BagNameList[self.view_type])

	self.get_skill_redpoint:SetValue(AdvanceSkillData.Instance:ShowSkillRedPoint())
	self.get_item_redpoint:SetValue(AdvanceSkillData.Instance:GetItemShowRedPoint())
	self.get_skill_learn_redpoint:SetValue(AdvanceSkillData.Instance:SkillLearnRedPoint())
	self.get_skill_tuoyin_redpoint:SetValue(AdvanceSkillData.Instance:SkillTuoYinRedPoint())

	self.bag_list_view:SetActive(self.view_type == AdvanceSkillView.ViewType.SKILL)
	self.bag_page_buttons:SetActive(self.view_type == AdvanceSkillView.ViewType.SKILL)
	self.storage_list_view:SetActive(self.view_type == AdvanceSkillView.ViewType.STORAGE)
	self.storage_page_buttons:SetActive(self.view_type == AdvanceSkillView.ViewType.STORAGE)

	self.skill_list_view.scroller:RefreshActiveCellViews()	
	if nil == self.cur_data then
	    self.name_str:SetValue("")
	    self.level_value:SetValue("")
		return
	end

    local zhanli = 0
    for k,v in pairs(self.cur_data) do
   		local one_skill_cfg = nil
    	one_skill_cfg = AdvanceSkillData.Instance:GetOneSkillCfgBySkillId(v.skill_id)
    	if one_skill_cfg then
   			zhanli = zhanli + one_skill_cfg.zhandouli
		end
   	end
    self.cap_str:SetValue(zhanli)

    self:CheckTabRed()
end

function AdvanceSkillView:FlushModel()
	if self.is_show_foot ~= nil then
		self.is_show_foot:SetValue(self.show_type == ADVANCE_SKILL_TYPE.FOOT)
	end

	if self.show_type ~= ADVANCE_SKILL_TYPE.FOOT then
		if self.show_model.model == nil then
			self.show_model.model = RoleModel.New()
			self.show_model.model:SetDisplay(self.display.ui3d_display)
		end

		if self.show_type == ADVANCE_SKILL_TYPE.FAZHEN then
			self.show_model.model:SetModelScale(Vector3(0.5, 0.5, 0.5))
			self.display.transform.localPosition = Vector3(68, 20, 0)
		else
			self.show_model.model:SetModelScale(Vector3(0.8, 0.8, 0.8))
			self.display.transform.localPosition = Vector3(100, 77, 0)
		end
	end

	local name_str = ""
	local g_str = ""

	if self.show_model.show_type == nil or self.show_model.show_type ~= self.show_type then
		self.show_model.show_type = self.show_type
		local image_cfg = nil
		local show_grade = nil
		if self.show_type == ADVANCE_SKILL_TYPE.MOUNT then
			local mount_info = MountData.Instance:GetMountInfo()
			show_grade = mount_info.show_grade
			local grade_cfg = MountData.Instance:GetMountShowGradeCfg(mount_info.show_grade)
			local used_imageid = grade_cfg and grade_cfg.image_id or 0
			image_cfg = MountData.Instance:GetMountImageCfg(used_imageid)
			if image_cfg == nil then return end
			self.show_model.model:ClearModel()
			self.show_model.model:SetDisplayPositionAndRotation("advance_skill_mount_panel")
			self.show_model.model:SetMainAsset(ResPath.GetMountModel(image_cfg.res_id))
			local cfg = self.show_model.model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.MOUNT], image_cfg.res_id)
			self.show_model.model:SetTransform(cfg)
			name_str = "mount_name_" .. (image_cfg.title_res or 1) 
			g_str = grade_cfg.gradename


		elseif self.show_type == ADVANCE_SKILL_TYPE.WING then
			local wing_info = WingData.Instance:GetWingInfo()
			show_grade = wing_info.show_grade
			local wing_grade_cfg = WingData.Instance:GetWingShowGradeCfg(wing_info.show_grade)
			local used_imageid = wing_grade_cfg and wing_grade_cfg.image_id or 0
			image_cfg = WingData.Instance:GetWingImageCfg(used_imageid)
			if image_cfg == nil then return end
			self.show_model.model:ClearModel()
			self.show_model.model:SetDisplayPositionAndRotation("advance_skill_wing_panel")
			local bundle, asset = ResPath.GetWingModel(image_cfg.res_id)	
			self.show_model.model:SetMainAsset(bundle, asset, function ()
			end)
			local cfg = self.show_model.model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.WING], image_cfg.res_id, DISPLAY_PANEL.FULL_PANEL)
			self.show_model.model:SetTransform(cfg)
			self.show_model.model:SetLayer(1, 1.0)
			name_str = "wing_name_" .. (image_cfg.title_res or 1) 
			g_str = wing_grade_cfg.gradename

		elseif self.show_type == ADVANCE_SKILL_TYPE.HALO then
			local halo_info = HaloData.Instance:GetHaloInfo()
			show_grade = halo_info.show_grade
			local grade_cfg = HaloData.Instance:GetHaloShowGradeCfg(halo_info.show_grade)
			local used_imageid = grade_cfg and grade_cfg.image_id or 0
			image_cfg = HaloData.Instance:GetHaloImageCfg(used_imageid)
			if image_cfg == nil then return end
			self.show_model.model:ClearModel()
			self.show_model.model:SetDisplayPositionAndRotation("advance_skill_panel")
			local cfg = self.show_model.model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.HALO], image_cfg.res_id)
			self.show_model.model:SetTransform(cfg)
			local main_role = Scene.Instance:GetMainRole()
			self.show_model.model:SetRoleResid(main_role:GetRoleResId())
			self.show_model.model:SetHaloResid(image_cfg.res_id)
			name_str = "halo_name_" .. (image_cfg.title_res or 1) 
			g_str = grade_cfg.gradename
		
		elseif self.show_type == ADVANCE_SKILL_TYPE.FAZHEN then
			local fazhen_info = FaZhenData.Instance:GetFightMountInfo()
			show_grade = fazhen_info.show_grade
			local grade_cfg = FaZhenData.Instance:GetMountShowGradeCfg(fazhen_info.show_grade)
			local used_imageid = grade_cfg and grade_cfg.image_id or 0
			image_cfg = FaZhenData.Instance:GetMountImageCfg(used_imageid)
			if image_cfg == nil then return end
			self.show_model.model:ClearModel()
			self.show_model.model:SetDisplayPositionAndRotation("advance_fazhen_panel")
			self.show_model.model:SetMainAsset(ResPath.GetFaZhenModel(image_cfg.res_id))
			name_str = "fazhen_name_" .. (image_cfg.title_res or 1) 
			g_str = grade_cfg.gradename
	
		elseif self.show_type == ADVANCE_SKILL_TYPE.BEAUTY_HALO then
			local beauty_halo_info = BeautyHaloData.Instance:GetBeautyHaloInfo()
			show_grade = beauty_halo_info.show_grade
			local grade_cfg = BeautyHaloData.Instance:GetShowBeautyHaloGradeCfg(beauty_halo_info.show_grade)
			local used_imageid = grade_cfg and grade_cfg.image_id or 0
			image_cfg = BeautyHaloData.Instance:GetImageListInfo(used_imageid)
			if image_cfg == nil then return end
			self.show_model.model:ClearModel()
			self.show_model.model:SetDisplayPositionAndRotation("advance_skill_panel")
			local cfg = self.show_model.model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SPIRIT_HALO], image_cfg.res_id,DISPLAY_PANEL.FULL_PANEL)
			self.show_model.model:SetTransform(cfg)
			local beauty_seq= BeautyData.Instance:GetCurBattleBeauty()
			local beautt_cfg = BeautyData.Instance:GetBeautyActiveInfo(beauty_seq) or {}
			local res_id = beautt_cfg.model or 11101
			local bundle, asset = ResPath.GetGoddessNotLModel(res_id)
			self.show_model.model:SetMainAsset(bundle, asset)
			self.show_model.model:SetHaloResid(image_cfg.res_id, true)
			name_str = "beauty_halo_" .. (image_cfg.title_res or 1) 
			g_str = grade_cfg.gradename
		
		elseif self.show_type == ADVANCE_SKILL_TYPE.HALIDOM then	
			local halidom_info = HalidomData.Instance:GetHalidomInfo()
			show_grade = halidom_info.show_grade
			local grade_cfg = HalidomData.Instance:GetShowHalidomGradeCfg(halidom_info.show_grade)
			local used_imageid = grade_cfg and grade_cfg.image_id or 0
			image_cfg = HalidomData.Instance:GetImageCfg(used_imageid)
			if image_cfg == nil then return end
			self.show_model.model:ClearModel()
			self.show_model.model:SetDisplayPositionAndRotation("advance_skill_halidom_panel")
			self.show_model.model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.ZHIBAO], image_cfg.res_id)
			self.show_model.model:SetMainAsset(ResPath.GetBaoJuModel(image_cfg.res_id))
			self.show_model.model:SetLayer(1, 1.0)
			name_str = "halidom_name_" .. (image_cfg.title_res or 1) 
			g_str = grade_cfg.gradename
		
		elseif self.show_type == ADVANCE_SKILL_TYPE.FOOT then
			local foot_info = ShengongData.Instance:GetShengongInfo()
			show_grade = foot_info.show_grade
			local grade_cfg = ShengongData.Instance:GetShengongShowGradeCfg(foot_info.show_grade)
			local used_imageid = grade_cfg and grade_cfg.image_id or 0
			image_cfg = ShengongData.Instance:GetImageListInfo(used_imageid)
			if image_cfg == nil then return end
			for i = 1, 3 do
				local bundle, asset = ResPath.GetFootEffec("Foot_" .. image_cfg.res_id)
				PrefabPool.Instance:Load(AssetID(bundle, asset), function (prefab)
					if nil == prefab then
						return
					end
					if self["foot_dis_" .. i] then
						local parent_transform = self["foot_dis_" .. i].transform
						for j = 0, parent_transform.childCount - 1 do
							GameObject.Destroy(parent_transform:GetChild(j).gameObject)
						end
						local obj = GameObject.Instantiate(prefab)
						local obj_transform = obj.transform
						obj_transform:SetParent(parent_transform, false)
						PrefabPool.Instance:Free(prefab)
					end
				end)
			end
			name_str = "foot_name_" .. (image_cfg.title_res or 1) 
			g_str = grade_cfg.gradename
		
		elseif self.show_type == ADVANCE_SKILL_TYPE.MANTLE then
			local mantle_info = ShenyiData.Instance:GetShenyiInfo()
			show_grade = mantle_info.show_grade
			local grade_cfg = ShenyiData.Instance:GetShenyiShowGradeCfg(mantle_info.show_grade)
			local used_imageid = grade_cfg and grade_cfg.image_id or 0
			image_cfg = ShenyiData.Instance:GetImageListInfo(used_imageid)
			if image_cfg == nil then return end
			self.show_model.model:ClearModel()
			self.show_model.model:SetDisplayPositionAndRotation("advance_skill_panel")
			local cfg = self.show_model.model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.MANTLE], image_cfg.res_id, DISPLAY_PANEL.FULL_PANEL)
			self.show_model.model:SetTransform(cfg)
			local main_role = Scene.Instance:GetMainRole()
			self.show_model.model:SetRoleResid(main_role:GetRoleResId())
			self.show_model.model:SetMantleResid(image_cfg.res_id)
			name_str = "mantle_name_" .. (image_cfg.title_res or 1) 
			g_str = grade_cfg.gradename
		end
	
		if image_cfg ~= nil and show_grade ~= nil then
		    --local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color] .. ">".. image_cfg.image_name .."</color>"
		   -- self.name_str:SetValue(image_cfg.image_name)
		   -- self.level_value:SetValue(show_grade)
		   if self.grade_str ~= nil and g_str ~= "" then
		   	  self.grade_str:SetValue(g_str)
		   end

		   if name_str ~= "" then
		   	  local bundle, asset = ResPath.GetAdvanceEquipIcon(name_str)
		   	  self.name_path:SetAsset(bundle, asset)
				-- if self.name_obj ~= nil then
				-- 	self.name_obj:GetComponent(typeof(UnityEngine.UI.Image)):LoadSprite(bundle, asset, function()
				-- 		self.name_obj:GetComponent(typeof(UnityEngine.UI.Image)):SetNativeSize()
				-- 	end)
				-- end
		   end
		end
	end
end

--------------------------------------------------------------------
-- 精灵技能格子
AdvanceSkillBagGroup = AdvanceSkillBagGroup or BaseClass(BaseRender)
function AdvanceSkillBagGroup:__init(instance)
	self.cells = {}
	for i = 1, SKILL_ROW do
		self.cells[i] = ItemCell.New(self:FindObj("Item"..i))
		self.cells[i]:SetIconScale(Vector3(0.95, 0.95, 0.95))
		--self.cells[i]:SetInstanceParent(self:FindObj("Item"..i))
	end
end

function AdvanceSkillBagGroup:__delete()
	if self.cells ~= nil then
		for k, v in pairs(self.cells) do
			if v ~= nil then
				v:DeleteMe()
			end
		end

		self.cells = {}
	end
end

function AdvanceSkillBagGroup:SetData(i, data)
	if self.cells[i] ~= nil then
		self.cells[i]:SetData(data)
	end
end

function AdvanceSkillBagGroup:ListenClick(i, handler)
	if self.cells[i] ~= nil then
		self.cells[i]:ListenClick(handler)
	end
end

function AdvanceSkillBagGroup:SetToggleGroup(toggle_group)
	for k, v in ipairs(self.cells) do
		if v ~= nil then
			v:SetToggleGroup(toggle_group)
		end
	end
end

function AdvanceSkillBagGroup:SetHighLight(i, enable)
	if self.cells[i] ~= nil then
		self.cells[i]:SetHighLight(enable)
	end
end

function AdvanceSkillBagGroup:ShowHighLight(i, enable)
	if self.cells[i] ~= nil then
		self.cells[i]:ShowHighLight(enable)
	end
end

function AdvanceSkillBagGroup:SetInteractable(i, enable)
	if self.cells[i] ~= nil then
		self.cells[i]:SetInteractable(enable)
	end
end


-- 形象技能格子
AdvanceSkillRenderGroup = AdvanceSkillRenderGroup or BaseClass(BaseRender)

function AdvanceSkillRenderGroup:__init(instance)
	self.skills = {}
	for i = 1, SKILL_ROW do
		self.skills[i] = self:FindObj("Item"..i)
		self.skills[i].obj = self:FindObj("Item"..i)
		self.skills[i].variable_table = self.skills[i].obj:GetComponent(typeof(UIVariableTable))
	end

	self:ListenEvent("OnClickItem1",BindTool.Bind(self.OnClickSkillItem, self, 1))
	self:ListenEvent("OnClickItem2",BindTool.Bind(self.OnClickSkillItem, self, 2))
end

function AdvanceSkillRenderGroup:__delete()
	self.skills = {}
end

function AdvanceSkillRenderGroup:OnClickSkillItem(index)
	if self.skills[index] == nil or nil == self.skills[index].data then
		return
	end

	local cur_select_sprite_index = AdvanceSkillData.Instance:GetCurAdvanceType()
	if cur_select_sprite_index == nil then
		return
	end
	--是否开启格子
	local open_cell_num = AdvanceSkillData.Instance:GetSkillOpenNum(cur_select_sprite_index)
	local data = self.skills[index].data
	if data.index > open_cell_num - 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Advance.SkillCellNotOpen)
		return
	end

	if data.skill_id == 0 then
		return
	end

	AdvanceSkillData.Instance:SetSpiritSkillViewCellData(self.skills[index].data)
	AdvanceSkillCtrl.Instance:OpenSkillInfoView(AdvanceSkillInfoView.FromView.SpriteSkillView)
end

function AdvanceSkillRenderGroup:SetData(i, data)	
	if self.skills[i] == nil then
		return
	end
	self.skills[i].data = data
	local skill_item = self.skills[i]
	local lock_obj = skill_item.obj:FindObj("lock")
	local text_open_limit = skill_item.variable_table:FindVariable("text_open_limit")
	local cur_advance_type = AdvanceSkillData.Instance:GetCurAdvanceType()
	if cur_advance_type == nil then
		return
	end
	local skill_id = data.skill_id or 0
	local one_skill_cfg = AdvanceSkillData.Instance:GetOneSkillCfgBySkillId(skill_id)
	-- 开启格子数
	local open_cell_num, next_open_grade = AdvanceSkillData.Instance:GetSkillOpenNum(cur_advance_type)
	local open_max_cell = AdvanceSkillData.Instance:GetMaxSkillCellNumByIndex(cur_advance_type)
	-- -- 剩余开启的悟性格子
	-- local left_wuxing_cell_num = max_wuxing_cell_num - cur_wuxing_cell_num
	-- -- 剩余开启的等级格子
	-- local left_level_cell_num = max_level_cell_num - cur_level_cell_num
	if data.index <= open_cell_num - 1 then
		lock_obj:SetActive(false)
		text_open_limit:SetValue("")
	else
		-- 格子上的文本提示
		local desc_limit = ""
		-- if left_level_cell_num > 0 and data.index <= open_cell_num then
		-- 	local next_level = AdvanceSkillData.Instance:GetSkillNumNextLevelById(cur_sprite_info.item_id or 0, cur_level_cell_num)
		-- 	desc_limit = string.format(Language.Advance..LevelOpenCellLimit, next_level)
		-- elseif left_wuxing_cell_num > 0 and left_level_cell_num > 0 and data.index <= open_cell_num + 1 then
		-- 	local next_level = AdvanceSkillData.Instance:GetNextWuXingBySkillNum(cur_wuxing_cell_num)
		-- 	desc_limit = string.format(Language.Advance.WuxingOpenCellLimit, next_level)
		-- elseif left_wuxing_cell_num > 0 and left_level_cell_num <= 0 and data.index <= open_cell_num then
		-- 	local next_level = AdvanceSkillData.Instance:GetNextWuXingBySkillNum(cur_wuxing_cell_num)
		-- 	desc_limit = string.format(Language.Advance.WuxingOpenCellLimit, next_level)
		-- end
		if data.index == open_cell_num then
			desc_limit = string.format(Language.Advance.SkillLimlitLabel, next_open_grade)
		end
		text_open_limit:SetValue(desc_limit)
		lock_obj:SetActive(desc_limit == "")
	end

	-- -- 图标显示
	-- -- 图标图片设置
	local image_skill_icon = skill_item.variable_table:FindVariable("image_skill_icon")
	local skill_icon_bundle, skill_icon_asset = "", ""
	if skill_id > 0 then
		skill_icon_bundle, skill_icon_asset = ResPath.GetAdvanceEquipIcon("skill_" .. skill_id)
	end
	image_skill_icon:SetAsset(skill_icon_bundle, skill_icon_asset)
	--显示红点
	local show_item_redpoint = skill_item.variable_table:FindVariable("show_item_redpoint")
	show_item_redpoint:SetValue(AdvanceSkillData.Instance:SkillItemRedPoint(data))
	---是否显示拓印标记
	local is_show_flag = skill_item.variable_table:FindVariable("is_show_flag")
	is_show_flag:SetValue(data.can_move == 1)
end

function AdvanceSkillRenderGroup:ListenClick(i, handler)
	-- self.cells[i]:ListenClick(handler)
end

function AdvanceSkillRenderGroup:SetToggleGroup(toggle_group)
	-- for k, v in ipairs(self.cells) do
	-- 	v:SetToggleGroup(toggle_group)
	-- end
end

function AdvanceSkillRenderGroup:SetHighLight(i, enable)
	-- self.cells[i]:SetHighLight(enable)
end

function AdvanceSkillRenderGroup:ShowHighLight(i, enable)
	-- self.cells[i]:ShowHighLight(enable)
end

function AdvanceSkillRenderGroup:SetInteractable(i, enable)
	-- self.cells[i]:SetInteractable(enable)
end

-- 技能仓库格子
AdvanceSkillStorageGroup = AdvanceSkillStorageGroup or BaseClass(BaseRender)

function AdvanceSkillStorageGroup:__init(instance)
	self.skills = {}
	for i = 1, BAG_ROW do
		self.skills[i] = {}
		self.skills[i].obj = self:FindObj("Item"..i)
		local lock_obj = self.skills[i].obj:FindObj("lock")
		lock_obj:SetActive(false)
		self.skills[i].variable_table = self.skills[i].obj:GetComponent(typeof(UIVariableTable))
	end

	self:ListenEvent("OnClickItem1",BindTool.Bind(self.OnClickSkillItem, self, 1))
	self:ListenEvent("OnClickItem2",BindTool.Bind(self.OnClickSkillItem, self, 2))
end

function AdvanceSkillStorageGroup:__delete()
	self.skills = {}
end

function AdvanceSkillStorageGroup:OnClickSkillItem(index)
	if nil == self.skills[index] or nil == self.skills[index].data or nil == self.skills[index].data.skill_id or self.skills[index].data.skill_id == 0 then
		return
	end
	-- local storage_cell_index = self.skills[index].data.index
	-- AdvanceSkillData.Instance:SetSkillStorageCellIndex(storage_cell_index)
	AdvanceSkillData.Instance:SetSpiritSkillViewCellData(self.skills[index].data)
	AdvanceSkillCtrl.Instance:OpenSkillInfoView(AdvanceSkillInfoView.FromView.SpriteSkillStorageView)
end

function AdvanceSkillStorageGroup:SetData(i, data)
	if self.skills[i] == nil or data == nil or next(data) == nil then
		return
	end

	self.skills[i].data = data
	local skill_item = self.skills[i]
	local skill_id = data.skill_id
	local one_skill_cfg = AdvanceSkillData.Instance:GetOneSkillCfgBySkillId(skill_id)
	-- 图标图片设置
	local image_skill_icon = skill_item.variable_table:FindVariable("image_skill_icon")
	local skill_icon_bundle, skill_icon_asset = "", ""
	if skill_id > 0 then
		skill_icon_bundle, skill_icon_asset = ResPath.GetAdvanceEquipIcon("skill_" .. skill_id)
	end
	image_skill_icon:SetAsset(skill_icon_bundle, skill_icon_asset)
end