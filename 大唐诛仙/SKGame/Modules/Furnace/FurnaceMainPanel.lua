FurnaceMainPanel = BaseClass(CommonBackGround)

function FurnaceMainPanel:__init()
	self.model = FurnaceModel:GetInstance()
	resMgr:AddUIAB("furnace")
	self:Config()
	self:InitEvent()
end

-- 配置
function FurnaceMainPanel:Config()
	self.tgjqPanel=nil--天干剑气
	self.dzxfPanel=nil--地支血符
	self.tjdzPanel=nil--太极盾阵
	self.dtgyPanel=nil--大唐官印
	self.bglhPanel=nil--八卦龙魂

	self.id = "FurnaceMainPanel"

	self.showBtnClose = true
	-- self.destroy = true
	-- self.titleName = "熔炉" -- self.titleNameRes = "Icon/Title/a1"
	self.openTopUI = true
	self.openResources = {1, 2}
	self.tabBar = {
		{label="", res0="tjdz0", res1="tjdz1", id=FurnaceConst.paneType.tjdz, red=false}, 
		{label="", res0="dzxf0", res1="dzxf1", id=FurnaceConst.paneType.dzxf, red=false},
		{label="", res0="tgjq0", res1="tgjq1", id=FurnaceConst.paneType.tgjq, red=false},
		{label="", res0="bglh0", res1="bglh1", id=FurnaceConst.paneType.bglh, red=false},
		{label="", res0="dtgy0", res1="dtgy1", id=FurnaceConst.paneType.dtgy, red=false},
	}
	self.defaultTabIndex = 0
	self.selectPanel = nil
	local update = true
	self.tabBarSelectCallback = function(idx, id)
		local cur = nil
		if id == "0" then
			self:SetTitle("太极盾阵")
			if not self.tgjqPanel then
				self.tgjqPanel = FurnacePanel.New(self.container, FurnaceConst.paneType.tjdz)
			end
			cur = self.tgjqPanel
		elseif id == "1" then
			self:SetTitle("地支血符")
			if not self.dzxfPanel then
				self.dzxfPanel = FurnacePanel.New(self.container, FurnaceConst.paneType.dzxf)
			end
			cur = self.dzxfPanel
		elseif id == "2" then
			self:SetTitle("天干剑气")
			if not self.tjdzPanel then
				self.tjdzPanel = FurnacePanel.New(self.container, FurnaceConst.paneType.tgjq)
			end
			cur = self.tjdzPanel
		elseif id == "3" then
			self:SetTitle("八卦龙魂")
			if not self.dtgyPanel then
				self.dtgyPanel = FurnacePanel.New(self.container, FurnaceConst.paneType.bglh)
			end
			cur = self.dtgyPanel
		elseif id == "4" then
			self:SetTitle("大唐官印")
			if not self.bglhPanel then
				self.bglhPanel = FurnacePanel.New(self.container, FurnaceConst.paneType.dtgy)
			end
			cur = self.bglhPanel
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
	FurnaceCtrl:GetInstance():C_GetPlayerFurnaceList()
end

-- 事件监听
function FurnaceMainPanel:InitEvent()
	self.openCallback = function () -- 打开回调
		if self.model.openType then
			self:SetSelectTabbar( self.model.openType )
			self.model.openType = nil
		end
		if self.selectPanel then
			self.selectPanel:Update()
		end
	end
	
	self.closeCallback = function ()
		
	end -- 关闭回调

end

-- 重构打开
function FurnaceMainPanel:Open(tabIndex)
	if tabIndex then
		CommonBackGround.Open(self)
		self:SetSelectTabbar(tabIndex)
	elseif self:IsOpen() then -- 已经打开，就切换指定标签
		
	else
		CommonBackGround.Open(self)
	end
end

-- 各个面板这里布局
function FurnaceMainPanel:Layout()
	-- 由于本主面板是以标签形式处理，所以这里留空，如果是单一面板可以这里实现（仅一次）
end

function FurnaceMainPanel:__delete()
	self.selectPanel = nil
	if self.tgjqPanel then
		self.tgjqPanel:Destroy()
		self.tgjqPanel=nil
	end
	if self.dzxfPanel then
		self.dzxfPanel:Destroy()
		self.dzxfPanel=nil
	end
	if self.tjdzPanel then
		self.tjdzPanel:Destroy()
		self.tjdzPanel=nil
	end
	if self.dtgyPanel then
		self.dtgyPanel:Destroy()
		self.dtgyPanel=nil
	end
	if self.bglhPanel then
		self.bglhPanel:Destroy()
		self.bglhPanel=nil
	end
end