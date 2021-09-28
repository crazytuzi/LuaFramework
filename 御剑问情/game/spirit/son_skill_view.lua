SonSkillView = SonSkillView or BaseClass(BaseRender)

local BAG_MAX_GRID_NUM = 40
local BAG_ROW = 2
local BAG_COLUMN = 4

local SKILL_MAX_GRID_NUM = 10
local SKILL_ROW = 2
local SKILL_COLUMN = 5

local STORAGDE_MAX_GRID_NUM = 50
local STORAGDE_ROW = 2
local STORAGDE_COLUMN = 5

local EFFECT_CD = 1

SonSkillView.ViewType = {
	["SkillView"] = 1,
	["StorageView"] = 2,
}

function SonSkillView:__init(instance)
	self.items = {}
	for i = 1, 4 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("Item"..i))
		item_cell:SetToggleGroup(self:FindObj("ItemToggleGroup").toggle_group)
		self.items[i] = {item = self:FindObj("Item"..i), cell = item_cell}
	end
	self.effect_root = self:FindObj("EffectRoot")
	self.bag_list_view = self:FindObj("SkillBagListView")

	local list_delegate = self.bag_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.BagGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.BagRefreshCell, self)

	self.skill_list_view = self:FindObj("SkillBookListView")
	list_delegate = self.skill_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.SkillGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.SkillRefreshCell, self)

	self.skill_storage_list = SpiritData.Instance:GetSkillStorageList()
	self.storage_list_view = self:FindObj("SkillStorageListView")
	list_delegate = self.storage_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.StorageGetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.StorageRefreshCell, self)

	self.bag_page_buttons = self:FindObj("BagPageButtons")
	self.storage_page_buttons = self:FindObj("StoragePageButtons")

	local model_display = self:FindObj("ModelDisplay")
	if model_display then
	    self.role_model = RoleModel.New("son_skill_panel")
	    self.role_model:SetDisplay(model_display.ui3d_display)
	end

	self.cur_click_index = 1
	self.is_first = true
	self.temp_spirit_list = {}
	self.res_id = 0
	self.fix_show_time = 8
	self.is_click_item = false
	self.bag_cells = {}
	self.skill_cells = {}
	self.storage_cells = {}
	self.cur_show_view = SonSkillView.ViewType.SkillView

	self:ListenEvent("OnClickSkillPokedex",BindTool.Bind(self.OnClickSkillPokedex, self))
	self:ListenEvent("OnClickSkillGet",BindTool.Bind(self.OnClickSkillGet, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickExchange", BindTool.Bind(self.OnClickExchange, self))
	self.text_sprite_name = self:FindVariable("text_sprite_name")
	self.text_sprite_level = self:FindVariable("text_sprite_level")
	self.text_cur_bag_name = self:FindVariable("text_cur_bag_name")
	self.is_show_red_point = self:FindVariable("is_show_red_point")
	self.total_zhanli = self:FindVariable("total_zhanli")

end

function SonSkillView:__delete()
	for k, v in pairs(self.items) do
		v.cell:DeleteMe()
	end
	self.items = nil
	self.is_first = nil
	self.temp_spirit_list = nil
	self.res_id = nil
	self.fix_show_time = nil
	self.bag_list_view = nil
	self.skill_list_view = nil
	self.storage_list_view = nil
	self.bag_page_buttons = nil
	self.storage_page_buttons = nil
	for k,v in pairs(self.bag_cells) do
		v:DeleteMe()
	end
	self.bag_cells = {}
	for k,v in pairs(self.skill_cells) do
		v:DeleteMe()
	end
	self.skill_cells = {}
	for k,v in pairs(self.storage_cells) do
		v:DeleteMe()
	end
	if self.role_model then
	    self.role_model:DeleteMe()
	    self.role_model = nil
	end
	self.storage_cells = {}
	self.skill_bag_toggle = nil
	self.skill_storage_toggle = nil
	self.is_show_red_point = nil
end

function SonSkillView:SetToggle(skill_bag_toggle, skill_storage_toggle)
	self.skill_bag_toggle = skill_bag_toggle
	self.skill_storage_toggle = skill_storage_toggle
end

function SonSkillView:OpenCallBack(skill_bag_toggle, skill_storage_toggle)
	self.is_first = true
	self.res_id = 0

	for k,v in pairs(self.items) do
		v.cell:SetData({})
		v.cell:SetHighLight(false)
	end
	self:Flush()
end

function SonSkillView:CloseCallBack()
	GlobalTimerQuest:CancelQuest(self.time_quest)
	self.time_quest = nil
	self.res_id = 0
	self.is_first = true
end

function SonSkillView:OnClickSkillPokedex()
	SpiritCtrl.Instance:OpenSkillBookView()
end

function SonSkillView:OnClickSkillGet()
	local cur_click_index = self.cur_click_index or 0
	SpiritData.Instance:GetSkillViewCurSpriteIndex(cur_click_index - 1)
	ViewManager.Instance:Open(ViewName.SpiritGetSkillView)
end

function SonSkillView:SkillGetNumberOfCells()
	return SKILL_MAX_GRID_NUM / SKILL_ROW
end

function SonSkillView:SkillRefreshCell(cell, data_index)
	local group = self.skill_cells[cell]
	if group == nil  then
		group = SpiritSkillRenderGroup.New(cell.gameObject)
		self.skill_cells[cell] = group
	end
	group:SetToggleGroup(self.skill_list_view.toggle_group)

	local cur_sprite_skill_list = self.cur_data and self.cur_data.param.jing_ling_skill_list or {}
	local page = math.floor(data_index / SKILL_COLUMN)
	local column = data_index - page * SKILL_COLUMN
	local grid_count = SKILL_COLUMN * SKILL_ROW
	for i = 1, SKILL_ROW do
		local index = (i - 1) * SKILL_COLUMN + column + (page * grid_count)
		local data = nil
		data = cur_sprite_skill_list[index]
		data = data or {}
		data.locked = false
		if data.index == nil then
			data.index = index
		end

		group:SetData(i, data)

	end
end

function SonSkillView:StorageGetNumberOfCells()
	return STORAGDE_MAX_GRID_NUM / STORAGDE_ROW
end

function SonSkillView:StorageRefreshCell(cell, data_index)
	local group = self.storage_cells[cell]
	if group == nil  then
		group = SpiritSkillStorageRenderGroup.New(cell.gameObject)
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

--点击格子事件
function SonSkillView:HandleSkillOnClick(data, group, group_index, data_index)
end

function SonSkillView:BagGetNumberOfCells()
	return BAG_MAX_GRID_NUM / BAG_ROW
end

function SonSkillView:BagRefreshCell(cell, data_index)
	local group = self.bag_cells[cell]
	if group == nil  then
		group = SpiritSkillBagGroup.New(cell.gameObject)
		self.bag_cells[cell] = group
	end
	group:SetToggleGroup(self.bag_list_view.toggle_group)
	local book_item_list = SpiritData.Instance:GetBagSkillBookItem()
	local page = math.floor(data_index / BAG_COLUMN)
	local column = data_index - page * BAG_COLUMN
	local grid_count = BAG_COLUMN * BAG_ROW
	for i = 1, BAG_ROW do
		local index = (i - 1) * BAG_COLUMN + column + (page * grid_count)
		local data = nil
		data = book_item_list[index + 1] or {}
		group:SetData(i, data)
		group:ShowHighLight(i, false)
		group:ListenClick(i, BindTool.Bind(self.HandleBagOnClick, self, data, group, i, index))
	end
end

--点击格子事件
function SonSkillView:HandleBagOnClick(data, group, group_index, data_index)
	if nil == data or nil == data.item_id then
		return
	end

	if nil == self.cur_data then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.PleaseEquipJingLing)
		return
	end
	SpiritData.Instance:SetSpiritSkillViewCellData(data)
	SpiritCtrl.Instance:OpenSkillInfoView(SpiritSkillInfo.FromView.SpriteSkillBookBagView)
end

function SonSkillView:OnFlush()
	self.cur_data = nil
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local spirit_list = spirit_info.jingling_list or {}

	for k, v in pairs(self.items) do
		if v.cell:GetData().item_id then
			if nil == spirit_list[k - 1] then
				if self.cur_click_index == k then
					if self.role_model then
					    self.role_model:ClearModel()
					end
					self.res_id = 0
				end
				v.cell:SetData({})
				v.cell:ClearItemEvent()
				v.cell:SetInteractable(false)
				v.cell:SetHighLight(false)
				self.cur_click_index = nil
			else
				if v.cell:GetData().param.strengthen_level < spirit_list[k - 1].param.strengthen_level then
					if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
						AudioService.Instance:PlayAdvancedAudio()
						EffectManager.Instance:PlayAtTransformCenter("effects2/prefab/ui_x/ui_sjcg_prefab",	"UI_sjcg", self.effect_root.transform, 2.0)
						self.effect_cd = Status.NowTime + EFFECT_CD
					end
				end
				v.cell:IsDestroyEffect(false)
				v.cell:SetData(spirit_list[k - 1])
				v.cell:SetHighLight(self.cur_click_index == k)
			end
		elseif spirit_list[k - 1] and nil == v.cell:GetData().item_id and self.is_first then
			if vo.used_sprite_id == spirit_list[k - 1].item_id then
				self.cur_click_index = k
			elseif (not self.cur_click_index and spirit_list[k - 1]) or (not self.temp_spirit_list[k - 1] and spirit_list[k - 1] and not self.is_first) then
				self.cur_click_index = k
			end
			v.cell:SetData(spirit_list[k - 1])
			v.cell:ListenClick(BindTool.Bind(self.OnClickItem, self, k, spirit_list[k - 1], v.cell))
			v.cell:SetInteractable(true)
			v.cell:SetHighLight(self.cur_click_index == k)
		else
			v.cell:SetData({})
			v.cell:SetInteractable(false)
		end
	end

	if self.cur_click_index and spirit_list[self.cur_click_index - 1] then
		self.cur_data = spirit_list[self.cur_click_index - 1]
	end

	self.temp_spirit_list = spirit_list
	self.is_first = false

	local cur_sprite_index = nil ~= self.cur_data and self.cur_data.index or 0
	SpiritData.Instance:SetSkillViewCurSpriteIndex(cur_sprite_index)

	if self.cur_show_view == SonSkillView.ViewType.SkillView then
		self:FlsuhSkillView()
	else
		self:FlsuhStorageView()
	end

	self.text_cur_bag_name:SetValue(Language.JingLing.BagNameList[self.cur_show_view])

	self.bag_list_view:SetActive(self.cur_show_view == SonSkillView.ViewType.SkillView)
	self.bag_page_buttons:SetActive(self.cur_show_view == SonSkillView.ViewType.SkillView)
	self.storage_list_view:SetActive(self.cur_show_view == SonSkillView.ViewType.StorageView)
	self.storage_page_buttons:SetActive(self.cur_show_view == SonSkillView.ViewType.StorageView)

	self.skill_list_view.scroller:RefreshActiveCellViews()
	 self.is_show_red_point:SetValue(SpiritData.Instance:ShowSkillRedPoint())
	if nil == self.cur_data then
	    self.text_sprite_name:SetValue("")
	    self.text_sprite_level:SetValue("")
    	self.total_zhanli:SetValue(0)
		return
	end

	local spirit_cfg = SpiritData.Instance:GetSpiritResIdByItemId(self.cur_data.item_id)
	if spirit_cfg and spirit_cfg.res_id and spirit_cfg.res_id > 0 then
        if self.res_id ~= spirit_cfg.res_id then
			local bundle, asset = ResPath.GetSpiritModel(spirit_cfg.res_id)
			local function call_back()
				-- local cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SPIRIT], spirit_cfg.res_id)
				-- if root then
				-- 	if cfg then
				-- 		root.transform.localPosition = cfg.position
				-- 		root.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
				-- 		root.transform.localScale = cfg.scale
				-- 	else
				-- 		root.transform.localPosition = Vector3(0, 0, 0)
				-- 		root.transform.localRotation = Quaternion.Euler(0, 0, 0)
				-- 		root.transform.localScale = Vector3(1, 1, 1)
				-- 	end
				-- end
				self:SetModleRestAni()
			end
			if self.role_model then
			    self.role_model:SetMainAsset(bundle, asset, call_back)
			end
			self.res_id = spirit_cfg.res_id
	    	self.role_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SPIRIT], self.res_id, DISPLAY_PANEL.ADVANCE_EQUIP)
        end
	end

	-- 精灵名字刷新
    local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.cur_data.item_id)
    local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color] .. ">"..item_cfg.name.."</color>"
    self.text_sprite_name:SetValue(name_str)
    self.text_sprite_level:SetValue(self.cur_data.param.strengthen_level)
    local zhanli = 0
    for k,v in pairs(self.cur_data.param.jing_ling_skill_list) do
   		local one_skill_cfg = nil
    	one_skill_cfg = SpiritData.Instance:GetOneSkillCfgBySkillId(v.skill_id)
    	if one_skill_cfg then
   			zhanli = zhanli + one_skill_cfg.zhandouli
		end
   	end
    self.total_zhanli:SetValue(zhanli)
end

function SonSkillView:OnClickItem(index, data, cell)
	cell:SetHighLight(true)
	if self.cur_click_index == index then
		return
	end
	self.cur_data = data
	self.cur_click_index = index
	self.is_click_item = true

	self:Flush()
end

function SonSkillView:SetModleRestAni()
	self.timer = self.fix_show_time
	if not self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			if self.timer == nil then return end
			self.timer = self.timer - UnityEngine.Time.deltaTime
			if self.timer <= 0 then
                if self.role_model then
                    self.role_model:SetTrigger("rest")
                end
				self.timer = self.fix_show_time
			end
		end, 0)
	end
end

function SonSkillView:OpenSkillView()
	self.cur_show_view = SonSkillView.ViewType.SkillView
	self:Flush()
end

function SonSkillView:OpenStorageView()
	self.cur_show_view = SonSkillView.ViewType.StorageView
	self:Flush()
end

function SonSkillView:FlsuhSkillView()
	if self.skill_bag_toggle then
		self.skill_bag_toggle.toggle.isOn = true
	end

	self.bag_list_view.scroller:RefreshActiveCellViews()
end

function SonSkillView:FlsuhStorageView()
	if self.skill_storage_toggle then
		self.skill_storage_toggle.toggle.isOn = true
	end

	self.skill_storage_list = SpiritData.Instance:GetSkillStorageList()
	self.storage_list_view.scroller:RefreshActiveCellViews()
end

function SonSkillView:OnClickHelp()
    local tip_id = 43
    TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

function SonSkillView:OnClickExchange()
 	SpiritCtrl.Instance.spirit_exchange:Open()
end

function SonSkillView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self:Flush()
end

-- 精灵技能格子
SpiritSkillBagGroup = SpiritSkillBagGroup or BaseClass(BaseRender)
function SpiritSkillBagGroup:__init(instance)
	self.cells = {}
	for i = 1, SKILL_ROW do
		self.cells[i] = ItemCell.New()
		self.cells[i]:SetInstanceParent(self:FindObj("Item"..i))
	end
end

function SpiritSkillBagGroup:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}
end

function SpiritSkillBagGroup:SetData(i, data)
	self.cells[i]:SetData(data)
end

function SpiritSkillBagGroup:ListenClick(i, handler)
	self.cells[i]:ListenClick(handler)
end

function SpiritSkillBagGroup:SetToggleGroup(toggle_group)
	for k, v in ipairs(self.cells) do
		v:SetToggleGroup(toggle_group)
	end
end

function SpiritSkillBagGroup:SetHighLight(i, enable)
	self.cells[i]:SetHighLight(enable)
end

function SpiritSkillBagGroup:ShowHighLight(i, enable)
	self.cells[i]:ShowHighLight(enable)
end

function SpiritSkillBagGroup:SetInteractable(i, enable)
	self.cells[i]:SetInteractable(enable)
end


-- 精灵技能格子
SpiritSkillRenderGroup = SpiritSkillRenderGroup or BaseClass(BaseRender)

function SpiritSkillRenderGroup:__init(instance)
	self.skills = {}
	for i = 1, SKILL_ROW do
		self.skills[i] = self:FindObj("Item"..i)
		self.skills[i].obj = self:FindObj("Item"..i)
		self.skills[i].variable_table = self.skills[i].obj:GetComponent(typeof(UIVariableTable))
		self.skills[i].event_table = self.skills[i].obj:GetComponent(typeof(UIEventTable))
	end

	self:ListenEvent("OnClickItem1",BindTool.Bind(self.OnClickSkillItem, self, 1))
	self:ListenEvent("OnClickItem2",BindTool.Bind(self.OnClickSkillItem, self, 2))
end

function SpiritSkillRenderGroup:OnClickSkillItem(index)
	if nil == self.skills[index].data then
		return
	end

	local cur_select_sprite_index = SpiritData.Instance:GetSkillViewCurSpriteIndex()
	-- 是否开启格子
	local open_cell_num = SpiritData.Instance:GetSkillOpenNum(cur_select_sprite_index)
	local data = self.skills[index].data
	if data.index > open_cell_num - 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.SkillCellNotOpen)
		return
	end

	local data = self.skills[index].data
	if data.skill_id == 0 then
		return
	end

	SpiritData.Instance:SetSpiritSkillViewCellData(self.skills[index].data)
	SpiritCtrl.Instance:OpenSkillInfoView(SpiritSkillInfo.FromView.SpriteSkillView)
end

function SpiritSkillRenderGroup:__delete()
	self.skills = {}
end

function SpiritSkillRenderGroup:SetData(i, data)
	self.skills[i].data = data
	local skill_item = self.skills[i]
	local lock_obj = skill_item.obj:FindObj("lock")
	local text_open_limit = skill_item.variable_table:FindVariable("text_open_limit")
	local cur_select_sprite_index = SpiritData.Instance:GetSkillViewCurSpriteIndex() or 0
	local spirit_info = SpiritData.Instance:GetSpiritInfo()
	local spirit_list = spirit_info.jingling_list or {}
	local cur_sprite_info = spirit_list[cur_select_sprite_index] or {}

	skill_item.event_table:ListenEvent("OnClickAdd",
		BindTool.Bind(self.OnClickAdd, self))

	local skill_id = data.skill_id or 0
	local one_skill_cfg = SpiritData.Instance:GetOneSkillCfgBySkillId(skill_id)
	-- 开启格子数
	local open_cell_num, cur_wuxing_cell_num, cur_level_cell_num = SpiritData.Instance:GetSkillOpenNum(cur_select_sprite_index)
	local open_max_cell, max_wuxing_cell_num, max_level_cell_num = SpiritData.Instance:GetMaxSkillCellNumByIndex(cur_select_sprite_index)

	-- 剩余开启的悟性格子
	local left_wuxing_cell_num = max_wuxing_cell_num - cur_wuxing_cell_num
	-- 剩余开启的等级格子
	local islock = false
	local left_level_cell_num = max_level_cell_num - cur_level_cell_num
	if data.index <= open_cell_num - 1 then
		lock_obj:SetActive(false)
		islock = false
		text_open_limit:SetValue("")
	else
		-- 格子上的文本提示
		local desc_limit = ""
		if left_level_cell_num > 0 and data.index <= open_cell_num then
			local next_level = SpiritData.Instance:GetSkillNumNextLevelById(cur_sprite_info.item_id or 0, cur_level_cell_num)
			desc_limit = string.format(Language.JingLing.LevelOpenCellLimit, next_level)
		elseif left_wuxing_cell_num > 0 and left_level_cell_num > 0 and data.index <= open_cell_num + 1 then
			local next_level = SpiritData.Instance:GetNextWuXingBySkillNum(cur_wuxing_cell_num)
			desc_limit = string.format(Language.JingLing.WuxingOpenCellLimit, next_level)
		elseif left_wuxing_cell_num > 0 and left_level_cell_num <= 0 and data.index <= open_cell_num then
			local next_level = SpiritData.Instance:GetNextWuXingBySkillNum(cur_wuxing_cell_num)
			desc_limit = string.format(Language.JingLing.WuxingOpenCellLimit, next_level)
		end

		text_open_limit:SetValue(desc_limit)
		lock_obj:SetActive(desc_limit == "")
		islock = (desc_limit == "")
	end

	-- 图标显示
	-- 图标图片设置
	local image_skill_icon = skill_item.variable_table:FindVariable("image_skill_icon")
	local skill_icon_bundle, skill_icon_asset = "", ""
	if skill_id > 0 then
		skill_icon_bundle, skill_icon_asset = ResPath.GetSpiritSkillIcon("skill_" .. skill_id)
	end
	image_skill_icon:SetAsset(skill_icon_bundle, skill_icon_asset)
	---是否显示拓印标记
	local is_show_flag = skill_item.variable_table:FindVariable("is_show_flag")
	is_show_flag:SetValue(data.can_move == 1)

	local is_showadd = skill_item.variable_table:FindVariable("is_Add")
	if "" == skill_icon_bundle and "" == skill_icon_asset and not islock then
		is_showadd:SetValue(true)
	else
		is_showadd:SetValue(false)
	end

end

function SpiritSkillRenderGroup:ListenClick(i, handler)
	-- self.cells[i]:ListenClick(handler)
end

function SpiritSkillRenderGroup:SetToggleGroup(toggle_group)
	-- for k, v in ipairs(self.cells) do
	-- 	v:SetToggleGroup(toggle_group)
	-- end
end

function SpiritSkillRenderGroup:OnClickAdd()
	TipsCtrl.Instance:ShowSpiritTips()
end

function SpiritSkillRenderGroup:SetHighLight(i, enable)
	-- self.cells[i]:SetHighLight(enable)
end

function SpiritSkillRenderGroup:ShowHighLight(i, enable)
	-- self.cells[i]:ShowHighLight(enable)
end

function SpiritSkillRenderGroup:SetInteractable(i, enable)
	-- self.cells[i]:SetInteractable(enable)
end

-- 技能仓库格子
SpiritSkillStorageRenderGroup = SpiritSkillStorageRenderGroup or BaseClass(BaseRender)

function SpiritSkillStorageRenderGroup:__init(instance)
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

function SpiritSkillStorageRenderGroup:__delete()
	self.skills = {}
end

function SpiritSkillStorageRenderGroup:OnClickSkillItem(index)
	if nil == self.skills[index] or nil == self.skills[index].data or nil == self.skills[index].data.skill_id or self.skills[index].data.skill_id == 0 then
		return
	end
	-- local storage_cell_index = self.skills[index].data.index
	-- SpiritData.Instance:SetSkillStorageCellIndex(storage_cell_index)
	SpiritData.Instance:SetSpiritSkillViewCellData(self.skills[index].data)
	SpiritCtrl.Instance:OpenSkillInfoView(SpiritSkillInfo.FromView.SpriteSkillStorageView)
end

function SpiritSkillStorageRenderGroup:SetData(i, data)
	self.skills[i].data = data
	local skill_item = self.skills[i]
	local skill_id = data.skill_id
	local one_skill_cfg = SpiritData.Instance:GetOneSkillCfgBySkillId(skill_id)
	-- 图标图片设置
	local image_skill_icon = skill_item.variable_table:FindVariable("image_skill_icon")
	local skill_icon_bundle, skill_icon_asset = "", ""
	if skill_id > 0 then
		skill_icon_bundle, skill_icon_asset = ResPath.GetSpiritSkillIcon("skill_" .. skill_id)
	end
	image_skill_icon:SetAsset(skill_icon_bundle, skill_icon_asset)
end