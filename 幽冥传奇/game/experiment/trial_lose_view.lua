--------------------------------------------------------
-- 试炼挑战失败  配置
--------------------------------------------------------

TrialLoseView = TrialLoseView or BaseClass(BaseView)

function TrialLoseView:__init()
	self.texture_path_list[1] = 'res/xui/experiment.png'
	self.texture_path_list[2] = 'res/xui/mainui.png'
	self:SetModal(true)
	self.config_tab = {
		{"trial_ui_cfg", 6, {0}},
	}
end

function TrialLoseView:__delete()
end

--释放回调
function TrialLoseView:ReleaseCallBack()
	-- if nil ~= self.tabbar then
	-- 	self.tabbar:DeleteMe()
	-- 	self.tabbar = nil
	-- end
	self:CancelTimer()
end

--加载回调
function TrialLoseView:LoadCallBack(index, loaded_times)
	self:CreateList()

	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["layout_exit"].node, BindTool.Bind(self.OnExit, self), true)


	-- 数据监听
	-- EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.OnRoleAttrChange, self))
end

function TrialLoseView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function TrialLoseView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self:CancelTimer()
end

--显示指数回调
function TrialLoseView:ShowIndexCallBack(index)
	self:CreateTimer()
	self:Flush()
end
----------视图函数----------

function TrialLoseView:OnFlush()
	self:FlushList()
end

function TrialLoseView:CreateTimer()
	self.time = 3
	local callback = function()
		self.time = self.time - 1
		if self:IsOpen() then
			self.node_t_list["lbl_time"].node:setString(string.format("(%d)", self.time))
		end

		if self.time <= 0 then
			self:CancelTimer()
			self:OnExit()
		end
	end

	self:CancelTimer()
	self.node_t_list["lbl_time"].node:setString(string.format("(%d)", self.time))
	self.timer = GlobalTimerQuest:AddTimesTimer(callback, 1, self.time)
end

function TrialLoseView:CancelTimer()
	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function TrialLoseView:CreateList()
	local ph = self.ph_list["ph_list"]
	local ph_item = self.ph_list["ph_item"]
	local parent = self.node_t_list["layout_trial_lose"].node
	local callback = BindTool.Bind(self.ListSelect, self)
	local grid_scroll = GridScroll.New()
	grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, ph_item.h, self.item, ScrollDir.Vertical, false, ph_item)
	grid_scroll:SetSelectCallBack(callback)
	parent:addChild(grid_scroll:GetView(), 99)
	self.list = grid_scroll
	self:AddObj("list")
end

function TrialLoseView:ListSelect(item)
	local data = item:GetData()
	ViewManager.Instance:OpenViewByStr(data.view_link)
end

function TrialLoseView:FlushList()
	local data_list = {
		{name = "首充", path = ResPath.GetMainui("icon_23_img"), view_link = "ChargeFirst"},
		{name = "热血神装",  path = ResPath.GetMainui("icon_12_img"), view_link = "Role#RoleInfoList#NewReXueEquip"},
		{name = "我要变强",  path = ResPath.GetExperiment("btn_bestrong"), view_link = "Help"},
		{name = "寻宝",  path = ResPath.GetMainui("icon_02_img"), view_link = "Explore"},
		{name = "激战BOSS",  path = ResPath.GetMainui("icon_01_img"), view_link = "Boss"}
	}
	if ChargeRewardData.Instance:GetFirstChargeIsAllGet() then
		table.remove(data_list, 1)
	end
	self.list:SetDataList(data_list)
	self.list:JumpToTop()
end

----------end----------

function TrialLoseView:OnExit()
	ViewManager.Instance:CloseViewByDef(ViewDef.TrialLose)
end

--------------------

----------------------------------------
-- 项目渲染命名
----------------------------------------
TrialLoseView.item = BaseClass(BaseRender)
local item = TrialLoseView.item
function item:__init()
	--self.item_cell = nil
end

function item:__delete()
	-- if self.item_cell then
	-- 	self.item_cell:DeleteMe()
	-- 	self.item_cell = nil
	-- end
end

function item:CreateChild()
	BaseRender.CreateChild(self)
end

function item:OnFlush()
	if nil == self.data then return end
	self.node_tree["img_icon"].node:loadTexture(self.data.path)
	self.node_tree["lbl_name"].node:setString(self.data.name)
	if self.data.name == "激战BOSS" then
		self.node_tree["img_icon"].node:setScale(0.5)
	else
		self.node_tree["img_icon"].node:setScale(1)
	end
end

function item:CreateSelectEffect()
	return
end