TipsKillBossDropView = TipsKillBossDropView or BaseClass(BaseView)

function TipsKillBossDropView:__init()
	self.ui_config = {"uis/views/tips/killbosstips", "KillBossDropTip"}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)
end

function TipsKillBossDropView:__delete()
end

function TipsKillBossDropView:ReleaseCallBack()
	if self.item_cell_list and next(self.item_cell_list) then
		for _,v in pairs(self.item_cell_list) do
			v:DeleteMe()
			v = nil
		end
		self.item_cell_list = {}
	end	

	self.view_data = nil
	self.scroller = nil
	self.is_show_remind = nil
end

function TipsKillBossDropView:OpenCallBack()
end

function TipsKillBossDropView:LoadCallBack()
	self.item_cell_list = {}

	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
	self.scroller = self:FindObj("Scroller")
	self.is_show_remind = self:FindVariable("Is_Show_Remind")
	local boss_list_view_delegate = self.scroller.list_simple_delegate
	boss_list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	boss_list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function TipsKillBossDropView:OnFlush()
	self.is_show_remind:SetValue(#self.view_data <= 0)
	self:FlushScroller()
end

function TipsKillBossDropView:SetData(data)
	self.view_data = data
	self:Flush()
end

function TipsKillBossDropView:OnCloseClick()
	self:Close()
end

function TipsKillBossDropView:GetNumberOfCells()
	if self.view_data then
		return #self.view_data
	end
	return 0
end

function TipsKillBossDropView:RefreshView(cell, data_index)
	data_index = data_index + 1

	local item_cell = self.item_cell_list[cell]
	if item_cell == nil then
		item_cell = BossDropItemCell.New(cell.gameObject)
		self.item_cell_list[cell] = item_cell
	end
	item_cell:SetIndex(data_index)
	item_cell:SetData(self.view_data[data_index])
end

function TipsKillBossDropView:FlushScroller()
	if self.scroller.scroller.isActiveAndEnabled then
		self.scroller.scroller:ReloadData(0)
	end
end


---------------- BossDropItemCell ----------------------------------
BossDropItemCell = BossDropItemCell or BaseClass(BaseCell)

function BossDropItemCell:__init()
	self.conent = self:FindVariable("Content")
	self.recode = self:FindVariable("Recode")
end

function BossDropItemCell:__delete()
end

function BossDropItemCell:OnFlush()
	if self.data then
		local time_str = os.date("%m-%d %X", self.data.drop_timestamp) or ""
		local name_str = self.data.name or ""
		local scene_str = MapData.Instance:GetMapConfig(self.data.scene_id).name or ""
		local boss_name_str = BossData.Instance:GetMonsterInfo(self.data.monster_id).name or ""
		self.conent:SetValue(string.format(Language.Boss.KillBossDropDes, time_str, name_str, scene_str, boss_name_str))

		local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
		local item_name = item_cfg.name or ""
		local item_color = item_cfg.color or GameEnum.ITEM_COLOR_WHITE
		self.recode:SetValue(ToColorStr(item_name, ITEM_COLOR[item_color]))
	end
end