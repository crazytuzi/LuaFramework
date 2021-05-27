DengLuView = DengLuView or BaseClass(ActBaseView)

function DengLuView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function DengLuView:__delete()
	if nil~=self.grid_denglu_scroll_list then
		self.grid_denglu_scroll_list:DeleteMe()
	end
	self.grid_denglu_scroll_list = nil
end

function DengLuView:InitView()
	self:CreateDengluGridScroll()
	XUI.AddClickEventListener(self.node_t_list["btn_left"].node, BindTool.Bind(self.OnLeft, self))
	XUI.AddClickEventListener(self.node_t_list["btn_right"].node, BindTool.Bind(self.OnRight, self))
	XUI.AddClickEventListener(self.node_t_list["btn_get"].node, BindTool.Bind(self.OnClickGetRewardBtn, self))

	XUI.AddRemingTip(self.node_t_list["btn_get"].node)
	XUI.AddRemingTip(self.node_t_list["btn_right"].node)
	XUI.AddRemingTip(self.node_t_list["btn_left"].node)
end

function DengLuView:RefreshView(param_list)
	self.data_list = ActivityBrilliantData.Instance:GetDengluRewardList()
	self.max_page = #self.data_list
	self.grid_denglu_scroll_list:ExtendGrid(#self.data_list)
	local new_data_list = {}
	for i,v in ipairs(self.data_list) do
		new_data_list[i - 1] = v
	end
	self.grid_denglu_scroll_list:SetDataList(new_data_list)
	-- local w = (BaseCell.SIZE + 20) * #self.data_list - 20
	-- local h = BaseCell.SIZE + 5
	-- self.base_grid_item:setContentSize(cc.size(w, h))

	local cfg = ActivityBrilliantData.Instance:GetOperActCfg(ACT_ID.DL) or {}
	local beg_time = os.date("*t", cfg.beg_time or 0)
	--领取按钮显示 只与天数有关
	beg_time.hour = 0
	beg_time.sec = 0
	beg_time.min = 0
	beg_time = os.time(beg_time)
	local now_time = TimeCtrl.Instance:GetServerTime()
	local pass_time = now_time - beg_time
	self.activity_day = math.ceil(pass_time / 86400) 
	local page_index = self.activity_day >= self.max_page and self.max_page or self.activity_day
	self:OnPageChangeCallBack(nil, page_index)
end

--登陆奖励
function DengLuView:CreateDengluGridScroll()
	if nil == self.node_t_list.layout_denglujiangli then
		return
	end
	if nil == self.grid_denglu_scroll_list then
		local ph = self.ph_list.ph_denglu_list
		local parent = self.node_t_list["layout_denglujiangli"].node
		local base_grid = BaseGrid.New()
		base_grid:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))

		local table = {w = ph.w, h = ph.h, cell_count = 1, col = 1, row = 1, itemRender = DengluItemRender, ScrollDir.Vertical, ui_config = self.ph_list["ph_item"]}
		self.base_grid_item = base_grid:CreateCells(table)
		self.base_grid_item:setPosition(ph.x, ph.y)
		base_grid:GetView():setAnchorPoint(0.5, 0.5)
		parent:addChild(self.base_grid_item, 20)
		self.grid_denglu_scroll_list = base_grid
	end
end

function DengLuView:OnLeft()
	if self.grid_denglu_scroll_list:IsChangePage() then return end -- 正在翻面时跳出
	local page_index = self.page_index - 1
	self.grid_denglu_scroll_list:ChangeToPage(page_index)
end

function DengLuView:OnRight()
	if self.grid_denglu_scroll_list:IsChangePage() then return end -- 正在翻面时跳出
	local page_index = self.page_index + 1
	self.grid_denglu_scroll_list:ChangeToPage(page_index)
end

function DengLuView:OnPageChangeCallBack(grid_render, page_index, prve_page_index)
	self.select_data = self.data_list[page_index] or {}
	self.page_index = page_index or 1

	local is_lingqu = self.select_data.sign ~= 0
	local boor = self.activity_day >= page_index
	local can_get = self.activity_day == page_index
	local btn_title = is_lingqu and Language.Common.YiLingQu or Language.Common.LingQuJiangLi
	self.node_t_list["btn_get"].node:setVisible(boor)
	self.node_t_list["btn_get"].node:setEnabled(not is_lingqu and can_get)
	self.node_t_list["btn_get"].node:UpdateReimd(not is_lingqu and can_get)
	self.node_t_list["btn_get"].node:setTitleText(btn_title)

	local day = page_index > 0 and page_index or 1
	self.node_t_list["img_day"].node:loadTexture(ResPath.GetActivityBrilliant("act_2_day_" .. day))
	self.node_t_list["img_day2"].node:loadTexture(ResPath.GetActivityBrilliant("act_2_day2_" .. day))
	self.node_t_list["img_day2"].node:setVisible(not boor)
	self.node_t_list["text_2"].node:setVisible(not boor)

	self.node_t_list["btn_left"].node:setVisible(page_index ~= 1)
	self.node_t_list["btn_right"].node:setVisible(page_index ~= self.max_page)

	local can_lingqu = false
	for i = page_index + 1, self.max_page do
		local data = self.data_list[i] or {}
		local can_get = self.activity_day == i
		local is_lingqu = data.sign ~= 0
		can_lingqu = can_lingqu or (not is_lingqu and can_get)
	end
	self.node_t_list["btn_right"].node:UpdateReimd(can_lingqu)

	local can_lingqu = false
	for i = page_index - 1, 1, -1 do
		local data = self.data_list[i] or {}
		local can_get = self.activity_day == i
		local is_lingqu = data.sign ~= 0
		can_lingqu = can_lingqu or (not is_lingqu and can_get)
	end
	self.node_t_list["btn_left"].node:UpdateReimd(can_lingqu)

end

function DengLuView:OnClickGetRewardBtn()
	if self.select_data == nil then return end
	ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.DL, self.select_data.index)
end
