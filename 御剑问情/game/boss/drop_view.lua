DropContentView = DropContentView or BaseClass(BaseRender)

function DropContentView:__init()
	self.list_data = {}
	self.cell_list = {}
	self.list_view = self:FindObj("list_view")
	list_simple_delegate = self.list_view.list_simple_delegate
	list_simple_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCell, self)
	list_simple_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function DropContentView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = nil
end

function DropContentView:GetNumberOfCell()
	return #self.list_data
end

function DropContentView:RefreshCell(cell, data_index)
	data_index = data_index + 1

	local drop_cell = self.cell_list[cell]
	if nil == drop_cell then
		drop_cell = DropCellItem.New(cell.gameObject)
		self.cell_list[cell] = drop_cell
	end

	drop_cell:SetData(self.list_data[data_index])
end

function DropContentView:FlushView()
	self.list_data = BossData.Instance:GetDropLog() or {}
	self.list_view.scroller:ReloadData(0)
end

DropCellItem = DropCellItem or BaseClass(BaseCell)
function DropCellItem:__init()
	self.rich_text = self:FindObj("rich_text")
end

function DropCellItem:__delete()
end

function DropCellItem:OnFlush()
	if nil == self.data then
		return
	end

	local time_str = os.date("%m/%d %X", self.data.timestamp)
	local name_str = self.data.role_name

	local scene_name = ""
	local scene_config = ConfigManager.Instance:GetSceneConfig(self.data.scene_id)
	if scene_config then
		scene_name = scene_config.name
	end

	local boss_name = ""
	local boss_cfg_info = BossData.Instance:GetMonsterInfo(self.data.monster_id)
	if boss_cfg_info then
		boss_name = boss_cfg_info.name
	end

	local str = string.format(Language.BossDrop[1], time_str, TEXT_COLOR.YELLOW, name_str, TEXT_COLOR.GREEN, scene_name, TEXT_COLOR.YELLOW, boss_name, self.data.item_id, self.data.item_num)
	RichTextUtil.ParseRichText(self.rich_text.rich_text, str)
end