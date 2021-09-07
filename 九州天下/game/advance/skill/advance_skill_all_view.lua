AdvanceSkillAllView = AdvanceSkillAllView or BaseClass(BaseView)

local BAG_MAX_GRID_NUM = 10
local BAG_ROW = 2
local BAG_COLUMN = 5

function AdvanceSkillAllView:__init()
	self.ui_config = {"uis/views/advanceview", "FlsuhSkillBigView"}
	self.play_audio = true
	self:SetMaskBg()
	self.skill_cells = {}
end

function AdvanceSkillAllView:__delete()

end

function AdvanceSkillAllView:OpenCallBack()
	--self:InitData()
end

function AdvanceSkillAllView:CloseCallBack()

end

function AdvanceSkillAllView:ReleaseCallBack()
	if self.skill_cells ~= nil then
		for k,v in pairs(self.skill_cells) do
			if v ~= nil then
				v:DeleteMe()
			end
		end
		self.skill_cells = {}
	end
	
	self.image_star_list = {}

	self.skill_list_view = nil
	self.text_stage_desc = nil
	self.text_flsuh_cost = nil
	self.cur_cell_info = nil
	self.cost_img = nil
end

function AdvanceSkillAllView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("FlsuhSkill", BindTool.Bind(self.FlsuhSkill, self))

	self.skill_list_view = self:FindObj("SkillList")
	self.text_stage_desc = self:FindVariable("text_stage_desc")
	self.text_flsuh_cost = self:FindVariable("text_flsuh_cost")
	self.cost_img = self:FindVariable("cost_img")
	self.image_star_list = {}
	for i = 1, 8 do
		self.image_star_list[i] = self:FindObj("star" .. i)
	end

	self:InitData()
	local list_delegate = self.skill_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function AdvanceSkillAllView:InitData()
	local advance_info = AdvanceSkillData.Instance:GetAdvanceSkillInfo()
	-- 根据格子找技能的，不理解的问光展(其实格子相当于一个宝箱)
	local cur_cell_index = AdvanceSkillData.Instance:GetSkillViewCurCellIndex()

	if advance_info == nil or advance_info.skill_refresh_item_list == nil or cur_cell_index == nil then
		return
	end

	local cell_info = advance_info.skill_refresh_item_list[cur_cell_index + 1]
	if cell_info == nil then
		return
	end
	self.cur_cell_info = cell_info
end

function AdvanceSkillAllView:GetNumberOfCells()
	return BAG_MAX_GRID_NUM / BAG_ROW
end

function AdvanceSkillAllView:RefreshCell(cell, data_index)
	local group = self.skill_cells[cell]
	if group == nil  then
		group = AdvanceFlushSkillGroup.New(cell.gameObject)
		self.skill_cells[cell] = group
	end
	group:SetToggleGroup(self.skill_list_view.toggle_group)
	-- local advance_info = AdvanceSkillData.Instance:GetAdvanceSkillInfo()
	-- local cur_cell_index = AdvanceSkillData.Instance:GetSkillViewCurCellIndex()
	-- local cell_info = advance_info.skill_refresh_item_list[cur_cell_index]
	-- local skill_list = cell_info.skill_list
	local page = math.floor(data_index / BAG_COLUMN)
	local column = data_index - page * BAG_COLUMN
	local grid_count = BAG_COLUMN * BAG_ROW
	for i = 1, BAG_ROW do
		local index = (i - 1) * BAG_COLUMN + column + (page * grid_count) + 1
		local data = {}
		if self.cur_cell_info ~= nil then
			data.skill_id = self.cur_cell_info.skill_list[index]
		end
		-- data.skill_id = skill_list[index] 
		if data.index == nil then
			data.index = index
		end
		group:SetData(i, data)
		group:ListenClick(i, BindTool.Bind(self.HandleBagOnClick, self, data, group, i, index))
	end
end

function AdvanceSkillAllView:ShowIndexCallBack()
	self:Flush()
end

function AdvanceSkillAllView:OnFlush()
	self:InitData()
	--local advance_info = AdvanceSkillData.Instance:GetAdvanceSkillInfo()
	-- 根据格子找技能的，不理解的问光展(其实格子相当于一个宝箱)
	--local cur_cell_index = AdvanceSkillData.Instance:GetSkillViewCurCellIndex()
	--local cell_info = advance_info.skill_refresh_item_list[cur_cell_index]

	if self.cur_cell_info == nil or next(self.cur_cell_info) == nil then
		return
	end

	local refresh_count = self.cur_cell_info.refresh_count
	local skill_refresh_cfg = AdvanceSkillData.Instance:GetSkliiFlsuhStageByTimes(refresh_count)
	-- 描述处理
	if self.text_stage_desc ~= nil then
		self.text_stage_desc:SetValue(skill_refresh_cfg.desc or "")
	end

	-- 星星处理
	local stage = skill_refresh_cfg.stage or 0
	local show_star = stage + 1
	local activate_bundle, activate_asset = ResPath.GetImages("star18")
	local gray_bundle, gray_asset = ResPath.GetImages("star17")

	local star_width = 41
	local star_height = 39
	local max_count = skill_refresh_cfg.max_count or 0
	local min_count = skill_refresh_cfg.min_count or 0
	local cur_star_full_times = max_count - min_count
	local cur_star_flush_times = refresh_count - min_count
	local star_percent = cur_star_flush_times / cur_star_full_times
	local cur_star_width = star_width * star_percent
	
	for i, v in ipairs(self.image_star_list) do
		if i <= show_star then
			v:SetActive(true)
			if i == show_star then
				-- 当前的星星要做遮罩显示处理
				v.rect.sizeDelta = Vector2(cur_star_width, star_height)
			else
				v.rect.sizeDelta = Vector2(star_width, star_height)
			end
		else
			v:SetActive(false)
		end
	end

	-- 网格刷新
	self.skill_list_view.scroller:RefreshActiveCellViews()
	local cost_str = skill_refresh_cfg.ten_gold or ""

	if self.cost_img ~= nil then
		local bundle, name = ResPath.GetImages("icon_bind_coin")
		local ten_item = skill_refresh_cfg.ten_items
		if ten_item ~= nil then
			local num = ItemData.Instance:GetItemNumInBagById(ten_item)
			if num ~= nil and num >= 1 then
				bundle, name = ResPath.GetImages("icon_lottery_" .. ten_item)
				cost_str = string.format(Language.Advance.CostStr, num, 1)
			end
		end

		self.cost_img:SetAsset(bundle, name)	
	end

	-- 刷新消耗显示
	self.text_flsuh_cost:SetValue(cost_str)
end

function AdvanceSkillAllView:FlsuhSkill()
	local cur_select_cell_index = AdvanceSkillData.Instance:GetSkillViewCurCellIndex()
	if cur_select_cell_index == nil then
		return
	end
	AdvanceSkillCtrl.Instance:SendAdvanceSkillOpera(JINGLING_OPER_TYPE.JINGLING_OPER_REFRESH, cur_select_cell_index, 1)
end

--点击格子事件
function AdvanceSkillAllView:HandleBagOnClick(data, group, group_index, data_index)
end

-- 背包格子
AdvanceFlushSkillGroup = AdvanceFlushSkillGroup or BaseClass(BaseRender)
function AdvanceFlushSkillGroup:__init(instance)
	self.skills = {}
	for i = 1, BAG_ROW do
		self.skills[i] = {}
		self.skills[i].obj = self:FindObj("Skill"..i)
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item" .. i))
		item:SetData(nil)
		self.skills[i].item = item

		self.skills[i].variable_table = self.skills[i].obj:GetComponent(typeof(UIVariableTable))
		self:ListenEvent("BuySkill" .. i, BindTool.Bind2(self.BuySkill, self, i))
	end
end

function AdvanceFlushSkillGroup:__delete()
	self.skills = {}
end

function AdvanceFlushSkillGroup:BuySkill(item_index)
	if self.skills == nil or item_index == nil or self.skills[item_index] == nil then
		return
	end

	local data = self.skills[item_index].data
	if nil == data or data.skill_id <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Advance.PleaseFlushSkill)
		return
	end

	local cur_select_cell_index = AdvanceSkillData.Instance:GetSkillViewCurCellIndex()
	local skill_index = data.index
	if cur_select_cell_index == nil or skill_index == nil then
		return
	end
	-- 技能 获取,param1 刷新索引,param2 技能索引
	AdvanceSkillCtrl.Instance:SendAdvanceSkillOpera(JINGLING_OPER_TYPE.JINGLING_OPER_GET, cur_select_cell_index, skill_index - 1)
	ViewManager.Instance:Close(ViewName.AdvanceSkillAllView)
	--AdvanceSkillCtrl.Instance:CloseFlsuhSkillBigView()
end

function AdvanceFlushSkillGroup:SetData(i, data)
	-- self.skills[1]:SetActive(false)
	if self.skills == nil or self.skills[i] == nil then
		return
	end

	self.skills[i].data = data
	local skill_item = self.skills[i]
	local item = self.skills[i].item
	local skill_id = data.skill_id
	local one_skill_cfg = AdvanceSkillData.Instance:GetOneSkillCfgBySkillId(skill_id)
	local text_skill_name = skill_item.variable_table:FindVariable("text_skill_name")
	-- local image_skill_icon = skill_item.variable_table:FindVariable("image_skill_icon")
	if nil == one_skill_cfg then
		text_skill_name:SetValue("")
		item:SetData(nil)
		return
	end
	-- 图标名字设置
	local item_color = ADVANCE_SKILL_LEVEL_COLOR[one_skill_cfg.skill_level]
	local item_name = ToColorStr(one_skill_cfg.skill_name, item_color)
    text_skill_name:SetValue(item_name)
    
	item:SetData({["item_id"] = one_skill_cfg.book_id})
end

function AdvanceFlushSkillGroup:ListenClick(i, handler)
end

function AdvanceFlushSkillGroup:SetToggleGroup(toggle_group)
end

function AdvanceFlushSkillGroup:SetHighLight(i, enable)
end

function AdvanceFlushSkillGroup:ShowHighLight(i, enable)
end

function AdvanceFlushSkillGroup:SetInteractable(i, enable)
end