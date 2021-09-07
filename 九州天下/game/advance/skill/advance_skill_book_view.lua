AdvanceSkillBookView = AdvanceSkillBookView or BaseClass(BaseView)

-- local SKILL_MAX_GRID_NUM = 10
-- local SKILL_ROW = 2
-- local SKILL_COLUMN = 5

local PER_ATTR = {
	["maxhp"] = "maxhp_per",
	["gongji"] = "gongji_per",
	["fangyu"] = "fangyu_per",
}

function AdvanceSkillBookView:__init()
	self.ui_config = {"uis/views/advanceview", "AdvanceSkillBookView"}
	self.play_audio = true
	self:SetMaskBg()

	self.show_type = 0
end

function AdvanceSkillBookView:__delete()

end

function AdvanceSkillBookView:CloseCallBack()
end

function AdvanceSkillBookView:ReleaseCallBack()
	if self.skill_cells ~= nil then
		for k,v in pairs(self.skill_cells) do
			if v ~= nil then
				v:DeleteMe()
			end
		end
		self.skill_cells = {}
	end

	self.skill_list_view = nil
end

function AdvanceSkillBookView:LoadCallBack()
	self.skill_cells = {}
	self.skill_book_cfg = AdvanceSkillData.Instance:GetSpiritSkillBookCfg()

	self.skill_list_view = self:FindObj("BookListView")
	list_delegate = self.skill_list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self:ListenEvent("Close", BindTool.Bind(self.Close, self))
end

function AdvanceSkillBookView:SetShowType(show_type)
	self.show_type = show_type
end

function AdvanceSkillBookView:ShowIndexCallBack(index)
	self:Flush()
end

function AdvanceSkillBookView:OnFlush(param_list)
	if self.skill_list_view ~= nil then
		self.skill_list_view.scroller:RefreshActiveCellViews()
	end
end

function AdvanceSkillBookView:GetNumberOfCells()
	return AdvanceSkillData.Instance:GetSkillBookCfgMaxType()
end

function AdvanceSkillBookView:RefreshCell(cell, data_index)
	local group = self.skill_cells[cell]
	if group == nil  then
		group = AdvanceSkillBookRender.New(cell.gameObject)
		self.skill_cells[cell] = group
	end
	-- group:SetToggleGroup(self.skill_list_view.toggle_group)

	local data = self.skill_book_cfg[data_index + 1]
	local real_data = TableCopy(data)
	real_data.show_type = self.show_type or 0
	group:SetData(real_data)
end

-- 精灵技能图鉴Render
AdvanceSkillBookRender = AdvanceSkillBookRender or BaseClass(BaseRender)

function AdvanceSkillBookRender:__init(instance)
	self.item_list = {}
	self.item_name_list = {}
	self.capacity_list = {}
	self.show_capacity_list = {}

	for i = 1, 5 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item" .. i))
		item:SetData(nil)
		self.item_list[i] = item
		self.item_name_list[i] = self:FindVariable("text_item_name" .. i)
		self.capacity_list[i] = self:FindVariable("text_capacity".. i)
		self.show_capacity_list[i] = self:FindVariable("show_capacity".. i)
	end

	self.text_type_name = self:FindVariable("text_type_name")
	self.text_skill_desc = self:FindVariable("text_skill_desc")
end

function AdvanceSkillBookRender:__delete()
	if self.item_list ~= nil then
		for k,v in pairs(self.item_list) do
			if v ~= nil then
				v:DeleteMe()
			end
		end

		self.item_list = {}
	end
end

function AdvanceSkillBookRender:SetData(data)
	if data == nil or next(data) == nil then
		return
	end

	for i = 1, 5 do
		local item = self.item_list[i]
		local item_name = self.item_name_list[i]
		local text_capacity = self.capacity_list[i]
		local show_capacity = self.show_capacity_list[i]

		local item_id = data["item_id_" .. i]
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		local color = ADVANCE_SKILL_LEVEL_COLOR[item_cfg.color]
		local item_cfg_name = ToColorStr(item_cfg.name, color)
		
		if item_name ~= nil then
			item_name:SetValue(item_cfg_name or "")
		end
		
		if item ~= nil then
			item:SetData({["item_id"] = item_id})
		end
		
		-- local one_skill_cfg = AdvanceSkillData.Instance:GetOneSkillCfgByItemId(item_id)
		-- local grade_cfg = AdvanceSkillData:GetGradeCfgByType(data.show_type)
		-- if one_skill_cfg ~= nil and grade_cfg ~= nil and next(grade_cfg) ~= nil then
		-- 	local attr = CommonDataManager.GetAttributteNoUnderline(one_skill_cfg)
		-- 	for k,v in pairs(PER_ATTR) do
		-- 		if attr[k] ~= nil and one_skill_cfg[v] ~= nil and grade_cfg[k] ~= nil then
		-- 			attr[k] = attr[k] + math.ceil(0.0001 * one_skill_cfg[v] * grade_cfg[k]) 
		-- 		end
		-- 	end
		local cap = AdvanceSkillData.Instance:SetSkillListInfo(data.type - 1,item_id)
		local str = Language.SkillAttr[data.type]
			--local cap = CommonDataManager.GetCapability(attr)

		if text_capacity ~= nil then
			text_capacity:SetValue(str .. cap or 0)
			if  data.type >= 11 then
				local num = cap * 0.01 .. "%"
				text_capacity:SetValue(str .. num or 0)
			end
		end

		if show_capacity ~= nil then
			show_capacity:SetValue(cap >= 0)
		end

		--end
	end

	self.text_type_name:SetValue(data.type_name or "")
	self.text_skill_desc:SetValue(data.des)
end
