--------------------------------------------------------
-- 首充返利  配置 
--------------------------------------------------------

FirstChargeView = FirstChargeView or BaseClass(BaseView)

function FirstChargeView:__init()
	self.texture_path_list[1] = 'res/xui/first_charge.png'
	self:SetModal(true)
	self.config_tab = {
		{"first_charge_ui_cfg", 1, {0}}
	}
end

function FirstChargeView:__delete()
end

--释放回调
function FirstChargeView:ReleaseCallBack()
	if nil ~= self.discount_num then
		self.discount_num:DeleteMe()
		self.discount_num = nil
	end
end

--加载回调
function FirstChargeView:LoadCallBack(index, loaded_times)
	self:CreateDiscountNumber()
	self.cfg = ActivityBrilliantData.Instance:GetOperActCfg(ACT_ID.SCFL)
	-- 按钮监听
	XUI.AddClickEventListener(self.node_t_list["layout_charge_btn"].node, BindTool.Bind(self.OnCharge, self), true)
	XUI.AddClickEventListener(self.node_t_list["btn_close"].node, BindTool.Bind(self.OnClose, self), true)
end

function FirstChargeView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function FirstChargeView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	self:CancelTimerQuest()
end

--显示指数回调
function FirstChargeView:ShowIndexCallBack(index)
	if self.cfg == nil then return end
	local discount = self.cfg.config.BackProcent * 100
	self.discount_num:SetNumber(discount)
	self:CheckTimer()
end
----------视图函数----------

function FirstChargeView:CreateDiscountNumber()
	local ph = self.ph_list["ph_num"]
	self.discount_num = NumberBar.New()
	self.discount_num:SetRootPath(ResPath.GetCommon("num_1_"))
	self.discount_num:SetPosition(ph.x, ph.y)
	self.discount_num:SetGravity(NumberBarGravity.Left)
	self.node_t_list["layout_first_charge"].node:addChild(self.discount_num:GetView(), 300, 300)
end

--检查计时器任务
function FirstChargeView:CheckTimer()
	if self.cfg == nil then return end
	local left_time = math.max(self.cfg.end_time - os.time())
	if left_time > 0 then
		self:FlushLeftTime()
		if nil == self.timer then
			self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SecTime, self), 1)
		end
	else
		self:CancelTimerQuest()
	end
end

--取消计时器任务
function FirstChargeView:CancelTimerQuest()
	GlobalTimerQuest:CancelQuest(self.timer)
	self.timer = nil
end

--倒计时每秒回调
function FirstChargeView:SecTime()
	if self.cfg == nil then return end
	local left_time = math.max(self.cfg.end_time - os.time())
	self:FlushLeftTime()
	if left_time == 0 then
		self:CheckTimer()
	end
end

--刷新剩余时间
function FirstChargeView:FlushLeftTime()
	if self.cfg == nil then return end
	local left_time = math.max(self.cfg.end_time - os.time())
	self.node_t_list["lbl_left_time"].node:setString(TimeUtil.FormatSecond2Str(left_time))
end

----------end----------

function FirstChargeView:OnCharge()
	ViewManager.Instance:Open(ViewName.Recharge)
end


function FirstChargeView:OnClose()
	self:Close()
end


--------------------
