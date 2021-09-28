--[[
	28天签到主界面
]]

SignPanel = BaseClass(CommonBackGround)

function SignPanel:__init( ... )
	resMgr:AddUIAB("Sign")
	self.ui = UIPackage.CreateObject("Sign", "SignPanel")
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
	self.showAlphaBg = true
	--self.bgUrl = "bg_big1"
	self.bgUrl = "ui://of7roaz1j9fy1x"
	self.id = "SignPanel"
	self:SetTitle(string.format(SignConst.STR_TITLE, self:GetTitleStr()), nil, 603, 115, 28, newColorByString("852603"))
	self.showBtnClose = true
	self.openTopUI = true
	self.openResources = {1, 2}
	self.isOnOtherClose = false

	self.bgBottom = self.ui:GetChild("bgBottom")
	self.bgBottom.visible = false
	self.bgDikuang = self.ui:GetChild("bgDikuang")
	self.bgDikuang.visible = false
	self.lineFenge = self.ui:GetChild("n45")
	self.lineFenge.visible = false

	self:Config()
	self:Layout()
	self:InitEvent()
end

function SignPanel:SetTitle(titleName, titleNameRes, x, y, size, color, font)
	CommonBackGround.SetTitle(self, titleName, titleNameRes, x, y)
	if self._title then
		setTxtFontOrSize(self._title, font, size, color)
	end
end

function SignPanel:GetTitleStr()
	local mon = os.date("%m")
	local cnMon = numToCN(mon)
	--numToCN将12转成一十二,截掉第一个字符
	cnMon = string.sub(cnMon, 4)
	return cnMon
end

function SignPanel:InitEvent()
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

function SignPanel:OnBtnUp()
	self.isLongTouchChecking = false
	self.isLongTouch = false
	self.longTriggered = false
	RenderMgr.Remove(self.longTouchFrame)
end

function SignPanel:OnBtnDown()
	self.isLongTouchChecking = true
	self.touchDownTime = Time.time
	RenderMgr.Add(function() self:LongTouchFrame() end, self.longTouchFrame)
end

-- 长按显示当前奖励
function SignPanel:LongTouchFrame()
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
function SignPanel:OnRewardClick(idx)
	local state = self.model:GetGiftState(idx)
	if state == SignConst.STATE_REWARD.CAN_LINGQU then
		SignController:GetInstance():C_GetConSignReward(idx)
	else
		local k = self.model:GetRewardIdx(idx)
		self:ShowRewardTip(idx)
	end
end

function SignPanel:OnLingquClick()
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

function SignPanel:ShowRewardTip(idx)
	local vo = GoodsVo.New()
	-- vo:SetCfg(3, self.model:GetGiftId(idx), 1, false)
	local rewardTab = self.model:GetRewardTab(idx)
	vo:SetCfg(rewardTab[1], rewardTab[2], rewardTab[3], rewardTab[4])
	CustomTipLayer.Show(vo, false)
end

-- 布局UI
function SignPanel:Layout()
	self.container:AddChild(self.ui) -- 不改动，注意自行设置self.ui位置
	-- 以下开始UI布局
	self._bg:SetPosition( self._bg.position.x + 40, self._bg.position.y, self._bg.position.z )
	--self.ui:SetPosition(65, 50, 0)
	self.ui:SetPosition(80, 90, 0)
	self:SetBtnClose(true, 1117, 100)

	self.gridList = {}
	local idx = 1
	-- local startX = -170
	-- local startY = -95
	local startX = -121
	local startY = -88
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

function SignPanel:DestoryGrids()
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

-- Dispose use SignPanel obj:Destroy()
function SignPanel:__delete()
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
	GlobalDispatcher:DispatchEvent(EventName.PopCheckStateChange, {id = MainUIConst.PopModule.Sign, show = false, isClose = true})
end

function SignPanel:Open()
	CommonBackGround.Open(self)
	self:RefreshUI()
end

function SignPanel:Config()
	self.model = SignModel:GetInstance()
end

function SignPanel:Close()
	self:DestoryGrids()
	CommonBackGround.Close(self)
end

function SignPanel:RefreshUI()
	self:RefreshGrids()
	self:RefreshBar()
	self:RefreshRewards()
	self:RefreshLingquBtn()
end

-- 连续签到进度条和天数显示
function SignPanel:RefreshBar()
	local num = self.model:GetRewardDays()
	self.lb_reward_days.text = string.format( "%02d", num )
	self.bar_jindu.value = num
	self.bar_jindu.max = self.model:GetRewardMaxDay()
end

-- 连续签到区域
function SignPanel:RefreshRewards()
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
function SignPanel:CleanEffect()
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
function SignPanel:RefreshLingquBtn()
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

function SignPanel:RefreshGrids()
	for i = 1, #self.gridList do
		local icon = self.gridList[i]
		local mask = icon.sign_mask
		local state = self.model:GetGridState(i)
		mask:RefreshUI(state)
	end
end