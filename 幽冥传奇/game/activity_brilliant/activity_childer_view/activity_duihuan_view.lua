DuiHuanView = DuiHuanView or BaseClass(ActBaseView)

function DuiHuanView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function DuiHuanView:__delete()
	if nil~=self.grid_duihuan_scroll_list then
		self.grid_duihuan_scroll_list:DeleteMe()
	end
	self.grid_duihuan_scroll_list = nil
end

function DuiHuanView:InitView()
	self:CreateDuihuanGridScroll()
end

function DuiHuanView:RefreshView(param_list)
	local data = ActivityBrilliantData.Instance
	local old_data_list = self.grid_duihuan_scroll_list:GetDataList()
	local data_list = data:GetDuihuanItemList()
	self.grid_duihuan_scroll_list:SetDataList(data_list)
	if nil == old_data_list or nil == next(old_data_list) then
		self.grid_duihuan_scroll_list:JumpToTop()
	end

	local mine_num = data.mine_num and data.mine_num[40] or 0
	local cfg = data:GetOperActCfg(self.act_id)
	local icon_id = cfg.config and cfg.config.icon_id or 1
	local item_icon = ResPath.GetItem(icon_id)
	local text = string.format(Language.ActivityBrilliant.Text35, item_icon, mine_num)
	local rich = self.node_t_list["rich_duihuan_tip"].node
	rich = RichTextUtil.ParseRichText(rich, text, 20, COLOR3B.WHITE)
	rich:refreshView()
end

function DuiHuanView:CreateDuihuanGridScroll()
	if nil == self.node_t_list.layout_duihuan then
		return
	end
	if nil == self.grid_duihuan_scroll_list then
		local ph = self.ph_list.ph_qmqg_list
		self.grid_duihuan_scroll_list = GridScroll.New()
		self.grid_duihuan_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 1, 118, DuihuanItemRender, ScrollDir.Vertical, false, self.ph_list.ph_duihuan_item)
		self.node_t_list.layout_duihuan.node:addChild(self.grid_duihuan_scroll_list:GetView(), 100)
	end
end
