--------------------------------------------------------
-- 运营活动 44 每日特惠
--------------------------------------------------------

TeHuiLBView = TeHuiLBView or BaseClass(ActBaseView)

function TeHuiLBView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function TeHuiLBView:__delete()
	if self.th_grid then
		self.th_grid:DeleteMe()
		self.th_grid = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

-- 初始化视图
function TeHuiLBView:InitView()
	self.act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.THLB)
	XUI.AddClickEventListener(self.node_t_list.layout_tehui_giftbag.btn_left.node, BindTool.Bind(self.OnClickTHlibaoLeftBackHandler, self), true)
	XUI.AddClickEventListener(self.node_t_list.layout_tehui_giftbag.btn_right.node, BindTool.Bind(self.OnClickTHlibaoRightBackHandler, self), true)
	if nil == self.act_cfg then 
		return
	end
	self:CreateTHGridScroll()
end

-- 视图关闭回调
function TeHuiLBView:CloseCallback() 
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

-- 选中当前视图回调
function TeHuiLBView:ShowIndexView()
end

-- 切换当前视图回调
function TeHuiLBView:SwitchIndexView()
end


function TeHuiLBView:RefreshView(param_list)
	self.th_grid:SetDataList(ActivityBrilliantData.Instance:GetTHlibaoItemList())


	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.TimerCallback, self), 1)
end

function TeHuiLBView:TimerCallback()
	if self.th_grid then
		local now_time = os.time()
		local end_time = TimeUtil.NowDayTimeEnd(now_time)
		local left_time = end_time - now_time
		local time = TimeUtil.FormatSecond(left_time, 3)
		local items = self.th_grid:GetAllCell()
		for i,v in pairs(items) do
			v:SetLeftTime(time)
		end
	else
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
	end
end

function TeHuiLBView:CreateTHGridScroll()
	if nil == self.act_cfg then return end
	local ph_shouhun = self.ph_list.ph_tehui_list
	local cell_num = #self.act_cfg.config
	if nil == self.th_grid  then
		self.th_grid = BaseGrid.New() 
		local grid_node = self.th_grid:CreateCells({w = ph_shouhun.w, h = ph_shouhun.h, itemRender = THlibaoItemRender, ui_config = self.ph_list.ph_tehui_item, cell_count = cell_num, col = 3, row = 1})
		self.node_t_list.layout_tehui_giftbag.node:addChild(grid_node, 10)
		self.th_grid:GetView():setPosition(ph_shouhun.x, ph_shouhun.y)
	end
end

function TeHuiLBView:OnClickTHlibaoRightBackHandler()
	local index = self.th_grid:GetCurPageIndex() or 0
	if index < self.th_grid:GetPageCount() then
		self.th_grid:ChangeToPage(index + 1)
	end

end

function TeHuiLBView:OnClickTHlibaoLeftBackHandler()
	local index = self.th_grid:GetCurPageIndex() or 0
	if index > 1 then
		self.th_grid:ChangeToPage(index - 1)
	end
end

function TeHuiLBView:ItemConfigCallback()
	self:RefreshView()
end