--------------------------------------------------------
-- 试炼信息  配置 
--------------------------------------------------------

TrialAddAwardsView = TrialAddAwardsView or BaseClass(BaseView)

function TrialAddAwardsView:__init()
	self.is_any_click_close = true
	self:SetModal(true)
	self.config_tab = {
		{"trial_ui_cfg", 3, {0}},
	}
end

function TrialAddAwardsView:__delete()

end

--释放回调
function TrialAddAwardsView:ReleaseCallBack()
	-- if nil ~= self.tabbar then
	-- 	self.tabbar:DeleteMe()
	-- 	self.tabbar = nil
	-- end
	self.data = nil
end

--加载回调
function TrialAddAwardsView:LoadCallBack(index, loaded_times)
	self:CreateCellList()

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_1"].node, BindTool.Bind(self.OnBtn, self))


	-- 数据监听
	-- EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleAttrChange, self))
end

function TrialAddAwardsView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function TrialAddAwardsView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function TrialAddAwardsView:SetData(data)
	self.data = data
end

--显示指数回调
function TrialAddAwardsView:ShowIndexCallBack(index)
	self:Flush()
end
----------视图函数----------

function TrialAddAwardsView:OnFlush(param_list, index)
	self:FlushCellList()
end

function TrialAddAwardsView:CreateCellList()
	local ph = self.ph_list["ph_award_list"]
	local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE}
	local parent = self.node_t_list["layout_trial_add_awards"].node
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.w + 5, ActBaseCell, ScrollDir.Horizontal, false, ph_item)
	parent:addChild(grid_scroll:GetView(), 99)
	self.cell_list = grid_scroll
	self:AddObj("cell_list")
end

function TrialAddAwardsView:FlushCellList()
	local cfg = self.data.cfg or {}
	local addwards = cfg.addwards or {}
	local awards = cfg.awards or {}

	local show_list = {}
	for i,v in ipairs(addwards) do
		show_list[#show_list + 1] = ItemData.InitItemDataByCfg(v)
	end

	for i,v in ipairs(awards) do
		show_list[#show_list + 1] = ItemData.InitItemDataByCfg(v)
	end

	self.cell_list:SetDataList(show_list)

	-- 居中处理
	local view = self.cell_list:GetView()
	local inner = view:getInnerContainer()
	local size = view:getContentSize()
	local inner_width =(BaseCell.SIZE + 5) * (#show_list) - 5
	local view_width = math.min(self.ph_list["ph_award_list"].w, inner_width + 5)
	view:setContentSize(cc.size(view_width, size.height))
	view:setInnerContainerSize(cc.size(inner_width, size.height))
	view:jumpToTop()
end

----------end----------
function TrialAddAwardsView:OnBtn()
	self:Close()
end

--------------------
