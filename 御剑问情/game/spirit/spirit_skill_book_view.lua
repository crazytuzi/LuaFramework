SpiritSkillBookView = SpiritSkillBookView or BaseClass(BaseView)

-- local SKILL_MAX_GRID_NUM = 10
-- local SKILL_ROW = 2
-- local SKILL_COLUMN = 5

function SpiritSkillBookView:__init()
	self.ui_config = {"uis/views/spiritview_prefab", "SpriteSkillBookView"}
	self.play_audio = true
end

function SpiritSkillBookView:__delete()

end

function SpiritSkillBookView:CloseCallBack()
end

function SpiritSkillBookView:ReleaseCallBack()
	for k,v in pairs(self.skill_cells) do
		v:DeleteMe()
	end
	self.skill_cells = {}
	self.skill_list_view = nil
end

function SpiritSkillBookView:LoadCallBack()
	self.skill_cells = {}
	self.skill_book_cfg = SpiritData.Instance:GetSpiritSkillBookCfg()

	self.skill_list_view = self:FindObj("BookListView")
	list_delegate = self.skill_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
end

function SpiritSkillBookView:ShowIndexCallBack(index)
	self:Flush()
end

function SpiritSkillBookView:OnFlush(param_list)
	self.skill_list_view.scroller:RefreshActiveCellViews()
end

function SpiritSkillBookView:GetNumberOfCells()
	return SpiritData.Instance:GetSkillBookCfgMaxType()
end

function SpiritSkillBookView:RefreshCell(cell, data_index)
	local group = self.skill_cells[cell]
	if group == nil  then
		group = SpiritSkillBookRender.New(cell.gameObject)
		self.skill_cells[cell] = group
	end
	-- group:SetToggleGroup(self.skill_list_view.toggle_group)

	local data = self.skill_book_cfg[data_index + 1]
	group:SetData(data)
end

-- 精灵技能图鉴Render
SpiritSkillBookRender = SpiritSkillBookRender or BaseClass(BaseRender)

function SpiritSkillBookRender:__init(instance)
	self.item_list = {}
	self.item_name_list = {}
	self.capacity_list = {}
	self.is_show_list = {}
	for i = 1, 4 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item" .. i))
		item:SetData(nil)
		self.item_list[i] = item
		self.item_name_list[i] = self:FindVariable("text_item_name" .. i)
		self.capacity_list[i] = self:FindVariable("text_capacity".. i)
		self.is_show_list[i] = self:FindVariable("is_show_"..i)
	end

	self.text_type_name = self:FindVariable("text_type_name")
	self.text_skill_desc = self:FindVariable("text_skill_desc")
end

function SpiritSkillBookRender:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end

	self.item_list = {}
end

function SpiritSkillBookRender:SetData(data)
	for i = 1, 4 do
		local item = self.item_list[i]
		local item_name = self.item_name_list[i]
		local text_capacity = self.capacity_list[i]

		local item_id = data["item_id_" .. i]
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		local color = SOUL_NAME_COLOR[item_cfg.color]
		if color == "#00ff06" then
			color = "#00842c"
		end
		local item_cfg_name = ToColorStr(item_cfg.name, color)
		item_name:SetValue(item_cfg_name or "")
		item:SetData({["item_id"] = item_id})
		local one_skill_cfg = SpiritData.Instance:GetOneSkillCfgByItemId(item_id)
		self.is_show_list[i]:SetValue(tonumber(one_skill_cfg.zhandouli) ~= 0)
        text_capacity:SetValue(one_skill_cfg.zhandouli)
	end

	self.text_type_name:SetValue(data.type_name or "")
	self.text_skill_desc:SetValue(data.des)
end
