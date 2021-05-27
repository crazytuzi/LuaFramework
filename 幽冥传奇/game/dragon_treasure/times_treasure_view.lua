--------------------------------------------------------
-- 次数奖品视图  配置 MeridiansCfg
--------------------------------------------------------

TimesTreasureView = TimesTreasureView or BaseClass(XuiBaseView)

function TimesTreasureView:__init()
	self.texture_path_list[1] = 'res/xui/dragon_treasure.png'
	self:SetIsAnyClickClose(true)
	self.config_tab = {
		{"dragon_treasure_ui_cfg", 3, {0}}
	}

	self.award_cell_list = nil
end

function TimesTreasureView:__delete()
end

--释放回调
function TimesTreasureView:ReleaseCallBack()
	if nil ~= self.times_award_view then
		self.times_award_view:DeleteMe()
		self.times_award_view = nil
	end

	if self.award_cell_list then 
		for k, v in pairs(self.award_cell_list) do
			v:DeleteMe()
		end
		self.award_cell_list = nil
	end
end

--加载回调
function TimesTreasureView:LoadCallBack(index, loaded_times)
	self:CreateAwardScroll()

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_get"].node, BindTool.Bind(self.OnGet, self))
end

function TimesTreasureView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function TimesTreasureView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()

	-- 关闭面板时,隐藏所有Cell
	if type(self.award_cell_list) == "table" then
		for i,v in ipairs(self.award_cell_list) do
			v:GetView():setVisible(false)
		end
	end
end

--显示指数回调
function TimesTreasureView:ShowIndexCallBack(index)
	self:Flush()
end

function TimesTreasureView:OnFlush()
	self.index = DragonTreasureData.Instance:GetTimesTreasureIndex()
	self.buy_times = ActivityBrilliantData.Instance:GetDragonTreasureData().buy_times
	self.cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.LZMB).config.timesAward[self.index]

	self.node_t_list["btn_get"].node:setEnabled(self.buy_times >= self.cfg.times)
	self:FlushAwardList()
end
----------视图函数----------

-- 创建"次数奖励"视图
function TimesTreasureView:CreateAwardScroll()
	self.reward_items = {}
	self.reward_list_view = self.node_t_list["scroll_award_view"].node
	self.reward_list_view:setScorllDirection(ScrollDir.Horizontal)
end

function TimesTreasureView:FlushAwardList()
	self.award_cell_list = self.award_cell_list or {}
	local x, y = 0, 0
	local x_interval = 85
	for k, v in pairs(self.cfg.award) do
		if nil == self.award_cell_list[k] then
			local item
			item = BaseCell.New()
			item:SetAnchorPoint(0, 0)
			self.reward_list_view:addChild(item:GetView(), 99)
			item:SetPosition(x, y)
			self.award_cell_list[k] = item
		else
			self.award_cell_list[k]:GetView():setVisible(true)
		end
		self.award_cell_list[k]:SetData(ItemData.InitItemDataByCfg(v))
		x = x + x_interval
	end
	self.reward_list_view:setInnerContainerSize(cc.size(x, 80))

	x = 346 - x / 2 + x_interval / 2
	self.reward_list_view:setPositionX(x)
end

----------end----------
function TimesTreasureView:OnGet()
	ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.LZMB, 2, self.index)
	self:Close()
end

--------------------