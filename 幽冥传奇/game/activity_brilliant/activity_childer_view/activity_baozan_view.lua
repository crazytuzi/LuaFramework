BaoZanView = BaoZanView or BaseClass(ActBaseView)

function BaoZanView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function BaoZanView:__delete()
	if nil ~= self.gear_list then
		self.gear_list:DeleteMe()
		self.gear_list = nil
	end
end

function BaoZanView:InitView()
	self:CreateGearList()

end

function BaoZanView:RefreshView(param_list)
	local baozan_num = ActivityBrilliantData.Instance.baozan_num
	self.node_t_list["lbl_activity_tip"].node:setString(baozan_num)
	self:FlushGearList()
end

function BaoZanView:CreateGearList()
	local ph = self.ph_list["ph_gear_list"]
	local ph_item = self.ph_list["ph_gear_item"]
	local parent = self.node_t_list["layout_precious"].node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.h + 3, self.GearListRender, ScrollDir.Vertical, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 20)
	grid_scroll:JumpToTop() -- 跳至开头
	self.gear_list = grid_scroll
end

function BaoZanView:FlushGearList()
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(self.act_id) or {}
	local list = {}
	for i,v in ipairs(act_cfg.config or {}) do
		table.insert(list, {index = i, cfg = v})
	end
	list = ActivityBrilliantData.Instance:GetSignListByActId(list, self.act_id)
	table.sort(list, function(a, b)
		if a.sign ~= b.sign then
			return a.sign < b.sign
		else
			return a.index < b.index
		end
	end)

	self.gear_list:SetDataList(list)
	self.gear_list:JumpToTop()
end

----------------------------------------
-- 项目渲染命名
----------------------------------------
BaoZanView.GearListRender = BaseClass(BaseRender)
local GearListRender = BaoZanView.GearListRender
function GearListRender:__init()
	--self.item_cell = nil
end

function GearListRender:__delete()
	if self.xubao_times then
		self.xubao_times:DeleteMe()
		self.xubao_times = nil
	end

	if nil ~= self.award_list then
		self.award_list:DeleteMe()
		self.award_list = nil
	end

end

function GearListRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list["ph_xunbao_times"]
	local parent = self.view

	local path = ResPath.GetActivityBrilliant("act_15_num_")
	local number_bar = NumberBar.New()
	number_bar:Create(ph.x, ph.y, ph.w, ph.h, path)
	number_bar:SetSpace(-5)
	number_bar:SetGravity(NumberBarGravity.Center)
	parent:addChild(number_bar:GetView(), 99)
	self.xunbao_times = number_bar

	local ph  = self.ph_list["ph_award_list"]
	local awardi_list = ListView.New()
	awardi_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ActBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	awardi_list:SetItemsInterval(10)
	parent:addChild(awardi_list:GetView(), 10)
	self.award_list = awardi_list

	XUI.AddClickEventListener(self.node_tree["btn_receive"].node, BindTool.Bind(self.OnReceive, self), true)
end

function GearListRender:OnReceive()
	if self.data == nil then return end
	local act_id = ACT_ID.BZ
	if self.can_receive then
		local index = self.data.index or 0
		ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, index)
	else
		ViewManager.Instance:OpenViewByDef(ViewDef.Explore)
		ActivityBrilliantCtrl.Instance:CloseView(act_id)
	end
end

function GearListRender:OnFlush()
	if nil == self.data then return end
	local cfg = self.data.cfg or {}
	local award = cfg.award or {}
	local data_list = {}
	for i,v in ipairs(award or {}) do
		data_list[#data_list + 1] = ItemData.InitItemDataByCfg(v)
	end
	self.award_list:SetDataList(data_list)
	self.xunbao_times:SetNumber(cfg.times or 0)

	local baozan_num = ActivityBrilliantData.Instance.baozan_num
	self.can_receive = baozan_num >= (cfg.times or 0)
	local title_text = self.can_receive and Language.Common.LingQuJiangLi or "前往寻宝"
	self.node_tree["btn_receive"].node:setTitleText(title_text)
	self.node_tree["btn_receive"].node:setVisible(self.data.sign == 0)
	self.node_tree["img_stamp"].node:setVisible(self.data.sign ~= 0)
end

function GearListRender:CreateSelectEffect()
	return
end