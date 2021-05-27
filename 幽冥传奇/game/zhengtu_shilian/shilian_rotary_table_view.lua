--------------------------------------------------------
-- 试炼转盘  配置 TrialWheelCfg TrialMapCfg
--------------------------------------------------------

ShiLianRotaryTableView = ShiLianRotaryTableView or BaseClass(BaseView)

function ShiLianRotaryTableView:__init()
	self.texture_path_list[1] = 'res/xui/zhengtu_shilian.png'
	self:SetModal(true)
	self:SetIsAnyClickClose(true)
	self.config_tab = {
		{"zhengtu_shilian_ui_cfg", 3, {0}}
	}

	self.data = nil
	self.item_daley_timer = nil
	self.item_cell_list = {}
end

function ShiLianRotaryTableView:__delete()
end

--释放回调
function ShiLianRotaryTableView:ReleaseCallBack()
	ZhengtuShilianData.Instance.skip_animation_status = self.skip_animation.status
	self.item_cell_list = {}
	if self.skip_animation then
		self.skip_animation = nil
	end

	if self.gate_num then
		self.gate_num:DeleteMe()
		self.gate_num = nil
	end

	if self.times then
		self.times:DeleteMe()
		self.times = nil
	end

end

--加载回调
function ShiLianRotaryTableView:LoadCallBack(index, loaded_times)
	self.data = ZhengtuShilianData.Instance:GetRotaryTableData()
	self:CreateCellView()
	self:CreateNumerView()
	self:CreateCheckBox()

	self.node_t_list['img_pointer'].node:setAnchorPoint(cc.p(0.5, -0.56)) -- 设置指针的初始锚点,以偏移到指定的位置
	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["btn_lucky_draw"].node, BindTool.Bind(self.OnBtnLuckyDraw, self))

	-- 数据监听
	EventProxy.New(ZhengtuShilianData.Instance, self):AddEventListener(ZhengtuShilianData.ROTARY_TABLE_DATA_CHANGE, BindTool.Bind(self.OnRotaryTableDataChange, self))
end

function ShiLianRotaryTableView:CreateCheckBox()
	self.skip_animation = self.skip_animation or {}
	self.skip_animation.status = ZhengtuShilianData.Instance.skip_animation_status
	self.skip_animation.node = XUI.CreateImageView(20, 20, ResPath.GetCommon("bg_checkbox_hook"), true)
	self.skip_animation.node:setVisible(self.skip_animation.status)
	self.node_t_list.layout_skip_animation.node:addChild(self.skip_animation.node, 10)
	XUI.AddClickEventListener(self.node_t_list.layout_skip_animation.node, BindTool.Bind(self.OnClickSelectBoxHandler, self), true)
end

function ShiLianRotaryTableView:OnClickSelectBoxHandler()
	if self.skip_animation == nil then return end
	self.skip_animation.status = not self.skip_animation.status
	self.skip_animation.node:setVisible(self.skip_animation.status)
end

function ShiLianRotaryTableView:OpenCallBack()
	-- 请求转盘数据
	ZhengtuShilianCtrl.Instance.SendShiLianRotaryTableReq(1)
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ShiLianRotaryTableView:CloseCallBack(is_all)
	BagData.Instance:SetDaley(false)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function ShiLianRotaryTableView:ShowIndexCallBack(index)
	self:FlushCellView()
	self:FlushTimes()

	self.gate_num:SetNumber(TrialMapConfig.nAddYuanBaoWheel)
	self.times:SetNumber(1)
end
----------视图函数----------

-- 创建'物品图标'视图
function ShiLianRotaryTableView:CreateCellView()
	for i = 1, 10 do
		ph = self.ph_list['ph_cell_' .. i]
		self.item_cell_list[i] = BaseCell.New()
		self.item_cell_list[i]:SetPosition(ph.x, ph.y)
		self.node_t_list['layout_rotary_table'].node:addChild(self.item_cell_list[i]:GetView(), 1)
	end
end

function ShiLianRotaryTableView:FlushTimes()
	local color = self.data.times > 0 and COLORSTR.GREEN or COLORSTR.RED
	local text = string.format("可抽{color;%s;%d}次", color, self.data.times)
	RichTextUtil.ParseRichText(self.node_t_list["rich_times"].node, text, 18, COLOR3B.ORANGE)
	XUI.RichTextSetCenter(self.node_t_list["rich_times"].node)		
end

function ShiLianRotaryTableView:FlushCellView()
	if nil == next(self.item_cell_list) then return end
	local cfg = ZhengtuShilianData.Instance.GetRotaryTableItemData(self.data.pool_index)
	for i = 1, 10 do
		self.item_cell_list[i]:SetData(cfg[i])
	end
end

-- 创建'转盘动作'
function ShiLianRotaryTableView:FlushAction()
	if self.data.item_index == 0 then return end
	self.node_t_list["btn_lucky_draw"].node:setEnabled(false)
	local item_index = self.data.item_index
	self.node_t_list['img_pointer'].node:stopAllActions()
	self.node_t_list['img_pointer'].node:setAnchorPoint(cc.p(0.5, -0.56))
	local act_info = {{0.5, 0.5}, {0.3, 0.5}, {0.2, 0.5}, {1.5, 5}} -- 启动动作
	local act_info_item ={{0.18, 0.6}, {0.16, 0.4}, {0.2, 0.4}, {0.25, 0.4}, {0.15, 0.2}, {0.25, 0.25}, {0.4, 0.2}, {0.15, 0.05}} -- 停止前的缓冲动作

	local current_angle = self.node_t_list['img_pointer'].node:getRotation() -- 获取当前角度
	local item_Angle = (item_index * 360 / 10 - 18 - current_angle%360 + 360)%360 -- 算出需旋转的角度
	local ratio = (item_Angle  + 900) / 900 -- 算出缓冲动作需要改变的"比例"
	-- 根据"比例"改变缓冲动作每一步的时间和"角度比例"
	for k,v in pairs(act_info_item) do
		table.insert(act_info, {(v[1] * ratio), (v[2] * ratio)})
	end
	-- 创建动作
	local act_t = {}
	for i, v in pairs(act_info) do
		act_t[i] = cc.RotateBy:create(v[1], v[2] * 360)
	end

	local seq_act = cc.Sequence:create(unpack(act_t)) -- 合并动作
	local seq_act = cc.Sequence:create(seq_act, cc.CallFunc:create(BindTool.Bind(self.OnTableActionChange, self))) -- 绑定动作回调
	self.node_t_list['img_pointer'].node:runAction(seq_act) -- 运行操作
end


function ShiLianRotaryTableView:CreateNumerView()
	if nil == self.gate_num then
		local ph = self.ph_list.ph_gate_num
		self.gate_num = NumberBar.New()
		self.gate_num:SetRootPath(ResPath.GetZhengTuShiLian("num_1_"))
		self.gate_num:SetPosition(ph.x, ph.y)
		self.gate_num:SetGravity(NumberBarGravity.Center)
		-- self.gate_num:GetView():setScale(1)
		self.node_t_list["layout_rotary_table"].node:addChild(self.gate_num:GetView(), 10)	
	end

	if nil == self.times then
		local ph = self.ph_list.ph_times
		self.times = NumberBar.New()
		self.times:SetRootPath(ResPath.GetZhengTuShiLian("num_1_"))
		self.times:SetPosition(ph.x, ph.y)
		self.times:SetGravity(NumberBarGravity.Center)
		-- self.times:GetView():setScale(1)
		self.node_t_list["layout_rotary_table"].node:addChild(self.times:GetView(), 10)
	end
end

----------end----------

-- "开始抽奖"按钮点击回调
function ShiLianRotaryTableView:OnBtnLuckyDraw()
	if not self.skip_animation.status then
		BagData.Instance:SetDaley(true)
	end
	ZhengtuShilianCtrl.Instance.SendShiLianRotaryTableReq(2)
end

-- 转盘动作回调
function ShiLianRotaryTableView:OnTableActionChange()
	BagData.Instance:SetDaley(false)
	if nil ~= self.item_daley_timer then
		GlobalTimerQuest:CancelQuest(self.item_daley_timer)
		self.item_daley_timer = nil
	end
	if self:IsOpen() then
		self.node_t_list["btn_lucky_draw"].node:setEnabled(true)
	end
	self.item_daley_timer = GlobalTimerQuest:AddDelayTimer(function()
		if self:IsOpen() then
			self:FlushCellView()
		end
		GlobalTimerQuest:CancelQuest(self.item_daley_timer)
		self.item_daley_timer = nil
	end, 2)
end

-- 转盘次数改变回调
function ShiLianRotaryTableView:OnRotaryTableDataChange()
	if not self.skip_animation.status then
		self:FlushAction()
	else
		self:FlushCellView()
		self.node_t_list['img_pointer'].node:setRotation(0)
	end
	if self.data.item_index == 0 then self:FlushCellView() end
	self:FlushTimes()
end
--------------------

