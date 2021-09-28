FlushSpiriBigSkillView = FlushSpiriBigSkillView or BaseClass(BaseView)

local BAG_MAX_GRID_NUM = 10
local BAG_ROW = 2
local BAG_COLUMN = 5

function FlushSpiriBigSkillView:__init()
	self.ui_config = {"uis/views/spiritview_prefab", "FlsuhSpriteSkillBigView"}
	self.play_audio = true
	self.skill_cells = {}
end

function FlushSpiriBigSkillView:__delete()

end

function FlushSpiriBigSkillView:OpenCallBack()

end

function FlushSpiriBigSkillView:CloseCallBack()

end

function FlushSpiriBigSkillView:ReleaseCallBack()
	self.skill_list_view = nil
	self.text_stage_desc = nil
	self.text_flsuh_cost = nil
	self.cur_cell_info = nil
	for k,v in pairs(self.skill_cells) do
		v:DeleteMe()
	end
	self.skill_cells = {}
	self.image_star_list = {}
end

function FlushSpiriBigSkillView:LoadCallBack()
	local sprite_info = SpiritData.Instance:GetSpiritInfo()
	-- 根据格子找技能的，不理解的问光展(其实格子相当于一个宝箱)
	local cur_cell_index = SpiritData.Instance:GetSkillViewCurCellIndex()
	local cell_info = sprite_info.skill_refresh_item_list[cur_cell_index]
	self.cur_cell_info = cell_info

	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
	self:ListenEvent("FlsuhSkill", BindTool.Bind(self.FlsuhSkill, self))

	self.skill_list_view = self:FindObj("SkillList")
	self.text_stage_desc = self:FindVariable("text_stage_desc")
	self.text_flsuh_cost = self:FindVariable("text_flsuh_cost")
	self.image_star_list = {}
	for i = 1, 8 do
		self.image_star_list[i] = self:FindObj("star" .. i)
	end

	local list_delegate = self.skill_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function FlushSpiriBigSkillView:GetNumberOfCells()
	return BAG_MAX_GRID_NUM / BAG_ROW
end

function FlushSpiriBigSkillView:RefreshCell(cell, data_index)
	local group = self.skill_cells[cell]
	if group == nil  then
		group = SpiritFlushSkillGroup.New(cell.gameObject)
		self.skill_cells[cell] = group
	end
	group:SetToggleGroup(self.skill_list_view.toggle_group)
	local sprite_info = SpiritData.Instance:GetSpiritInfo()
	local cur_cell_index = SpiritData.Instance:GetSkillViewCurCellIndex()
	local cell_info = sprite_info.skill_refresh_item_list[cur_cell_index]
	local skill_list = cell_info.skill_list
	local page = math.floor(data_index / BAG_COLUMN)
	local column = data_index - page * BAG_COLUMN
	local grid_count = BAG_COLUMN * BAG_ROW
	for i = 1, BAG_ROW do
		local index = (i - 1) * BAG_COLUMN + column + (page * grid_count) + 1
		local data = {}
		data.skill_id = skill_list[index]
		if data.index == nil then
			data.index = index
		end
		group:SetData(i, data)
		group:ListenClick(i, BindTool.Bind(self.HandleBagOnClick, self, data, group, i, index))
	end
end

function FlushSpiriBigSkillView:OpenCallBack(index)
	self:Flush()
end

function FlushSpiriBigSkillView:OnFlush()
	local sprite_info = SpiritData.Instance:GetSpiritInfo()
	-- 根据格子找技能的，不理解的问光展(其实格子相当于一个宝箱)
	local cur_cell_index = SpiritData.Instance:GetSkillViewCurCellIndex()
	local cell_info = sprite_info.skill_refresh_item_list[cur_cell_index]

	local refresh_count = cell_info.refresh_count
	local skill_refresh_cfg = SpiritData.Instance:GetSkliiFlsuhStageByTimes(refresh_count)
	-- 描述处理
	self.text_stage_desc:SetValue(skill_refresh_cfg.desc or "")

	-- 星星处理
	local stage = skill_refresh_cfg.stage or 0
	local show_star = stage + 1
	-- local activate_bundle, activate_asset = ResPath.GetImages("star18")
	-- local gray_bundle, gray_asset = ResPath.GetSpiritImage("star17")

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

	-- 刷新消耗显示
	self.text_flsuh_cost:SetValue(skill_refresh_cfg.ten_gold or "")
end

function FlushSpiriBigSkillView:FlsuhSkill()
	local cur_select_cell_index = SpiritData.Instance:GetSkillViewCurCellIndex()
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_REFRESH, cur_select_cell_index, 1)
end



--点击格子事件
function FlushSpiriBigSkillView:HandleBagOnClick(data, group, group_index, data_index)
end

-- 背包格子
SpiritFlushSkillGroup = SpiritFlushSkillGroup or BaseClass(BaseRender)

function SpiritFlushSkillGroup:__init(instance)
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

function SpiritFlushSkillGroup:__delete()
	self.skills = {}
end

function SpiritFlushSkillGroup:BuySkill(item_index)
	local data = self.skills[item_index].data
	if nil == data or data.skill_id <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.JingLing.PleaseFlushSkill)
		return
	end
	local cur_select_cell_index = SpiritData.Instance:GetSkillViewCurCellIndex()
	local skill_index = data.index
	-- 技能 获取,param1 刷新索引,param2 技能索引
	SpiritCtrl.Instance:SendJingLingInfoReq(JINGLING_OPER_TYPE.JINGLING_OPER_GET, cur_select_cell_index, skill_index)
	SpiritCtrl.Instance:CloseFlsuhSkillBigView()
end

function SpiritFlushSkillGroup:SetData(i, data)
	-- self.skills[1]:SetActive(false)
	self.skills[i].data = data

	local skill_item = self.skills[i]
	local item = self.skills[i].item
	local skill_id = data.skill_id
	local one_skill_cfg = SpiritData.Instance:GetOneSkillCfgBySkillId(skill_id)
	local text_skill_name = skill_item.variable_table:FindVariable("text_skill_name")
	-- local image_skill_icon = skill_item.variable_table:FindVariable("image_skill_icon")
	if nil == one_skill_cfg then
		text_skill_name:SetValue("")
		item:SetData(nil)
		return
	end
	-- 图标名字设置
	local item_color = SPRITE_SKILL_LEVEL_COLOR[one_skill_cfg.skill_level]
	if item_color == "#00ff06" then
		item_color = "#008427"
	end
	local item_name = ToColorStr(one_skill_cfg.skill_name, item_color)
    text_skill_name:SetValue(item_name)
    
	item:SetData({["item_id"] = one_skill_cfg.book_id})
end

function SpiritFlushSkillGroup:ListenClick(i, handler)
end

function SpiritFlushSkillGroup:SetToggleGroup(toggle_group)
end

function SpiritFlushSkillGroup:SetHighLight(i, enable)
end

function SpiritFlushSkillGroup:ShowHighLight(i, enable)
end

function SpiritFlushSkillGroup:SetInteractable(i, enable)
end