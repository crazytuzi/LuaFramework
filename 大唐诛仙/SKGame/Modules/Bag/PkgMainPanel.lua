-- 主面板:背包
PkgMainPanel = BaseClass(CommonBackGround)

function PkgMainPanel:__init()
	self.pkgModel = PkgModel:GetInstance()
	resMgr:AddUIAB("Pkg")
	resMgr:AddUIAB("Decomposition")
	self:Config()
	self:InitEvent()
end

-- 配置
function PkgMainPanel:Config()
	self.id = "PkgMainPanel"
	self.showBtnClose = true
	-- self.destroy = true
	-- self.titleName = "背包" -- self.titleNameRes = "Icon/Title/a1"
	self.openTopUI = true
	self.openResources = {1, 2}
	self.tabBar = {
		{label="", res0="bb00", res1="bb01", id="0", red=false}, 
		{label="", res0="ys00", res1="ys01", id="1", red=false},
		{label="", res0="hc00", res1="hc01", id="3", red=false},
		{label="", res0="fj00", res1="fj01", id="4", red=false},
		{label="", res0="tl00", res1="tl01", id="5", red=false},
	}
	self.defaultTabIndex = 0
	self.selectPanel = nil
	local update = true
	self.tabBarSelectCallback = function(idx, id)
		
		local cur = nil
		if id == "0" then
			self:SetTitle("背  包")
			if not self.pkgPanel then
				self.pkgPanel = PkgPanel.New(self.container)
			end
			cur = self.pkgPanel
			cur.tabCtrl.selectedIndex = 0 -- 每次打开重置为第一标签
		elseif id == "1" then
			self:SetTitle("药  剂")
			if not self.medicinePanel then
				self.medicinePanel = MedicinePanel.New(self.container)
			end
			cur = self.medicinePanel
			GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
		elseif id == "3" then
			self:SetTitle("合  成")
			if TableIsEmpty(self.compositionUI) then
				self.compositionUI = CompositionUI.New()
				self.compositionUI:SetXY(134, 102)
				self.container:AddChild(self.compositionUI.ui)
			end
			cur = self.compositionUI
			GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
		elseif id == "4" then
			self:SetTitle("分  解")
			if TableIsEmpty(self.decompositionUI) then
				self.decompositionUI = DecompositionUI.New()
				self.decompositionUI:SetXY(152, 108)
				self.container:AddChild(self.decompositionUI.ui)
			end
			cur = self.decompositionUI
		elseif id == "5" then
			self:SetTitle("提  炼")
			if TableIsEmpty(self.refinedPanel) then
				self.refinedPanel = RefinedPanel.New()
				self.refinedPanel:SetXY(152, 108)
				self.container:AddChild(self.refinedPanel.ui)
			end
			cur = self.refinedPanel
		end
		if self.selectPanel ~= cur then
			if self.selectPanel then
				self.selectPanel:SetVisible(false)
			end
			self.selectPanel = cur
			if cur then
				
				cur:SetVisible(true)
				if self.isFinishLayout and update then -- 在布局完成才调用（不要让打开回调与这里一起回调）
					cur:Update() -- 更新当前面板数据（每个面板切换时更新）
				end
			end
		end
		self:SetTabarTips(id, false)
	end
end

-- 事件监听
function PkgMainPanel:InitEvent()
	self.openCallback = function () -- 打开回调
		if self.pkgModel.openType then
			self:SetSelectTabbar( self.pkgModel.openType )
			self.pkgModel.openType = nil
		end
		if self.selectPanel then
			self.selectPanel:Update()
		end
	end
	self.closeCallback = function () 
		if self.selectPanel == self.decompositionUI then
			self.decompositionUI:HandleClose()
		end
		if self.selectPanel == self.refinedPanel then
			self.refinedPanel:HandleClose()
		end
		self.pkgModel:CleanSelectGoodsBid()
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end -- 关闭回调

	-- 装备变化
	-- self.equipInofChangeHandler = GlobalDispatcher:AddEventListener(EventName.EQUIPINFO_CHANGE, function() end) ---> 装备处理这里不作处理
	-- 物品变化
	self.bagChangeHandler = GlobalDispatcher:AddEventListener(EventName.BAG_CHANGE, function ( data )
		self:OnBagChange(data)
	end)
end

-- 重构打开
function PkgMainPanel:Open(tabIndex, param1)
	if tabIndex then
		CommonBackGround.Open(self)
		self:SetSelectTabbar(tabIndex)
	elseif self:IsOpen() then -- 已经打开，就切换指定标签
		if self.pkgModel.openType then
			self:SetSelectTabbar( self.pkgModel.openType )
			self.pkgModel.openType = nil
		end
	else
		CommonBackGround.Open(self)
	end
end

-- 物品变化
function PkgMainPanel:OnBagChange(data)
	-- local changes = data or {} -- print("参数这里没用到，别的地方提示用到 [bid]=num", next(changes))
	if self.pkgPanel and self.selectPanel == self.pkgPanel then
		self.pkgPanel:Update()
	end
end

-- 各个面板这里布局
function PkgMainPanel:Layout()
	-- 由于本主面板是以标签形式处理，所以这里留空，如果是单一面板可以这里实现（仅一次）
end

function PkgMainPanel:__delete()
	-- GlobalDispatcher:RemoveEventListener(self.equipInofChangeHandler)
	GlobalDispatcher:RemoveEventListener(self.bagChangeHandler)

	if self.pkgPanel then
		self.pkgPanel:Destroy()
	end
	if self.medicinePanel then
		self.medicinePanel:Destroy()
	end
	if self.refinedPanel then
		self.refinedPanel:Destroy()
	end

	if self.decompositionUI then
		self.decompositionUI:Destroy()
	end

	if self.compositionUI then
		self.compositionUI:Destroy()
	end

	self.medicinePanel = nil
	self.refinedPanel= nil
	self.pkgPanel = nil
	self.selectPanel = nil
	self.decompositionUI = nil
	self.compositionUI = nil
end