-- 福利界面的签到panel
SignFuliPanel = BaseClass(LuaUI)

function SignFuliPanel:__init( ... )
	self.URL = "ui://of7roaz1mg8m10"
	self:__property(...)
	self:Config()
	self:Layout()
	self:InitEvent()
	self:RefreshUI()
end

function SignFuliPanel:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Sign","SignPanel");
	
	self.role = self.ui:GetChild("role")
	self.bar_jindu = self.ui:GetChild("bar_jindu")
	self.panel_grid = self.ui:GetChild("panel_grid")
	self.lb_reward_days = self.ui:GetChild("n12")
	self.btn_lingqu = self.ui:GetChild("n8")
	self.com_buqian = self.btn_lingqu:GetChild("n12")
	self.com_buqian.visible = false
	self.icon_cost = self.com_buqian:GetChild("n1")
	self.lb_cost = self.com_buqian:GetChild("n2")
	self.btn_libao = {}
	self.effects = {}
	for i = 1, SignConst.NUM_REWARD do
		self.effects[i] = {flag = 0}
		self.btn_libao[i] = self.ui:GetChild("btn_libao" .. i)
	end
	self.img_role = self.ui:GetChild("n31")
	self.img_role.visible = false

	self.bgBottom = self.ui:GetChild("bgBottom")
	self.bgBottom.visible = true
	self.bgDikuang = self.ui:GetChild("bgDikuang")
	self.bgDikuang.visible = true
	self.lineFenge = self.ui:GetChild("n45")
	self.lineFenge.visible = true
end

function SignFuliPanel.Create(ui, ...)
	return SignFuliPanel.New(ui, "#", {...})
end

function SignFuliPanel:SetProperty(...)
	
end

function SignFuliPanel:InitEvent()
	for i = 1, SignConst.NUM_REWARD do
		self.btn_libao[i].onClick:Add( function ()
			self:OnRewardClick(i)
		end)
	end
	
	self.btn_lingqu.onClick:Add( self.OnLingquClick, self )
	self.btn_lingqu.onTouchBegin:Add( self.OnBtnDown, self )
	self.btn_lingqu.onTouchEnd:Add( self.OnBtnUp, self )
	
	local function OnMsgChange()
		self:RefreshUI()
	end
	self._hMsgChange = self.model:AddEventListener(SignConst.SignMsgChange, OnMsgChange)

	local function OnRewardGot(signNum)
		self:RefreshBar()
		self:RefreshRewards()
		self:RefreshLingquBtn()
	end
	self._hConSignGot = self.model:AddEventListener(SignConst.ConSignGotOne, OnRewardGot)
end

function SignFuliPanel:OnBtnUp()
	self.isLongTouchChecking = false
	self.isLongTouch = false
	self.longTriggered = false
	RenderMgr.Remove(self.longTouchFrame)
end

function SignFuliPanel:OnBtnDown()
	self.isLongTouchChecking = true
	self.touchDownTime = Time.time
	RenderMgr.Add(function() self:LongTouchFrame() end, self.longTouchFrame)
end

-- 长按显示当前奖励
function SignFuliPanel:LongTouchFrame()
	if self.isLongTouchChecking and Time.time - self.touchDownTime > 1 and (not self.longTriggered) then 
		-- wq("long click ++++++++")
		self.longTriggered = true
		local idx = self.model:GetQiandaoDay() + 1
		if idx <= SignConst.NUM_DAYS then
			self.gridList[idx]:ShowTips()
		end
	end
end

-- 礼包点击
function SignFuliPanel:OnRewardClick(idx)
	local state = self.model:GetGiftState(idx)
	if state == SignConst.STATE_REWARD.CAN_LINGQU then
		SignController:GetInstance():C_GetConSignReward(idx)
	else
		local k = self.model:GetRewardIdx(idx)
		self:ShowRewardTip(idx)
	end
end

function SignFuliPanel:OnLingquClick()
	-- local day = self.model:GetQiandaoDay() + 1
	-- wq("lingqu ++++++ " .. day)

	local cost = self.model:GetBuqianCost() or 0
	local state = self.model:GetBtnState()
	if state == SignConst.STATE_GRID.CAN_BUQIAN then
		UIMgr.Win_Confirm("补签确认", StringFormat("花费{0}元宝补签？", cost), "确定", "取消", 
			function ()
				SignController:GetInstance():C_Sign()
			end,
			nil)
	else
		SignController:GetInstance():C_Sign()
	end
end

function SignFuliPanel:ShowRewardTip(idx)
	local vo = GoodsVo.New()
	-- vo:SetCfg(3, self.model:GetGiftId(idx), 1, false)
	local rewardTab = self.model:GetRewardTab(idx)
	vo:SetCfg(rewardTab[1], rewardTab[2], rewardTab[3], rewardTab[4])
	CustomTipLayer.Show(vo, false)
end

-- 布局UI
function SignFuliPanel:Layout()
	self.btn_lingqu:SetPosition(860, 600, 0)
	self.bar_jindu:SetPosition(290, 613, 0)
	for i = 1, SignConst.NUM_REWARD do
		local pos = self.btn_libao[i].position
		pos = pos + Vector3.New(-100, 51, 0)
		self.btn_libao[i]:SetPosition(pos.x, pos.y, pos.z)
	end

	self.gridList = {}
	local idx = 1
	local startX = -122
	local startY = -87
	for i = 1, SignConst.NUM_LINE do
		for j = 1, SignConst.NUM_PER_LINE do
			local icon = PkgCell.New(self.panel_grid)
			--icon:SetScale(1.2, 1.2)
			icon:SetXY(startX + 126 * j, startY + 112 * i)
			icon:OpenTips(true)
			local data, isDouble = self.model:GetData(idx)
			icon:SetDataByCfg(data[1], data[2], data[3], data[4])
			icon.sign_mask = SignMask.New()
			icon.sign_mask:SetXY(0, 0)
			icon.ui:AddChild(icon.sign_mask.ui)
			self.gridList[idx] = icon
			if isDouble > 0 then
				icon.sign_mask:SetDouble(true)
			else
				icon.sign_mask:SetDouble(false)
			end
			-- icon.sign_mask:RefreshUI()
			idx = idx + 1
		end
	end
end

function SignFuliPanel:DestoryGrids()
	if not self.gridList then return end
	for i = 1, #self.gridList do
		if self.gridList[i] then
			if self.gridList[i].sign_mask then
				self.gridList[i].sign_mask:Destroy()
			end
			self.gridList[i]:Destroy() 
		end
	end
	self.gridList = nil
end

-- Dispose use SignFuliPanel obj:Destroy()
function SignFuliPanel:__delete()
	RenderMgr.Remove(self.longTouchFrame)
	self:DestoryGrids()
	self:CleanEffect()
	self.effects = nil
	self.btn_lingqu.onClick:Remove(self.OnLingquClick, self)
	self.btn_lingqu.onTouchBegin:Remove(self.OnBtnUp, self)
	self.btn_lingqu.onTouchEnd:Remove(self.OnBtnDown, self)

	if self.model then
		self.model:SetLock(false)
		self.model:RemoveEventListener(self._hMsgChange)
		self.model:RemoveEventListener(self._hConSignGot)
	end
end

function SignFuliPanel:Open()
	CommonBackGround.Open(self)
	self:RefreshUI()
end

function SignFuliPanel:Config()
	self.model = SignModel:GetInstance()
end

function SignFuliPanel:RefreshUI()
	self:RefreshGrids()
	self:RefreshBar()
	self:RefreshRewards()
	self:RefreshLingquBtn()
end

-- 连续签到进度条和天数显示
function SignFuliPanel:RefreshBar()
	local num = self.model:GetRewardDays()
	self.lb_reward_days.text = string.format( "%02d", num )
	self.bar_jindu.value = num
	self.bar_jindu.max = self.model:GetRewardMaxDay()
end

-- 连续签到区域
function SignFuliPanel:RefreshRewards()
	self:CleanEffect()
	for i = 1, SignConst.NUM_REWARD do
		local state = self.model:GetGiftState(i)
		if state == SignConst.STATE_REWARD.YILINGQU then
			self.btn_libao[i].grayed = true
			self.btn_libao[i].touchable = false
		elseif state == SignConst.STATE_REWARD.CAN_LINGQU then
			self.btn_libao[i].grayed = false
			self.btn_libao[i].touchable = true

			if self.effects[i].flag == 0 then
				self.effects[i].flag = 1
				AddEffectToUI( self.btn_libao[i], "ui_tbhuanrao_dc", 22, 25, Vector3.New( 0.6, 0.6, 0.6 ), self.effects[i], "flag", 2 )
			end
		else
			self.btn_libao[i].grayed = false
			self.btn_libao[i].touchable = true
		end
	end

	self:RefreshBar()
end

-- 清特效 ...
function SignFuliPanel:CleanEffect()
	if self.effects then
		for i = 1, SignConst.NUM_REWARD do
			if self.effects[i].flag == 2 and self.effects[i].eff and self.effects[i].conn then
				destroyImmediate(self.effects[i].eff)
				destroyUI( self.effects[i].conn )
				self.effects[i].flag = 0
			end
		end
	end
end

-- 领取按钮
function SignFuliPanel:RefreshLingquBtn()
	if not self.com_buqian then return end
	local state = self.model:GetBtnState()

	if state == SignConst.STATE_GRID.YILINGQU then
		self.com_buqian.visible = false
		self.btn_lingqu.text = SignConst.STR_YILINGQU
		self.btn_lingqu.enabled = false
	elseif state == SignConst.STATE_GRID.CAN_LINGQU then
		self.com_buqian.visible = false
		self.btn_lingqu.text = SignConst.STR_LINGQU
		self.btn_lingqu.enabled = true
	elseif state == SignConst.STATE_GRID.CAN_BUQIAN then
		self.btn_lingqu.enabled = true
		self.btn_lingqu.text = ""
		self.com_buqian.visible = true
		self.icon_cost.url = SignConst.URL_BUQIAN_COST
		self.lb_cost.text = self.model:GetBuqianCost() or 0
	end
end

function SignFuliPanel:RefreshGrids()
	if not self.gridList then return end
	for i = 1, #self.gridList do
		local icon = self.gridList[i]
		local mask = icon.sign_mask
		local state = self.model:GetGridState(i)
		mask:RefreshUI(state)
	end
end