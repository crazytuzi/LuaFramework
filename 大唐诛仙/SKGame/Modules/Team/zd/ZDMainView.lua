-- 总面板
ZDMainView = BaseClass(CommonBackGround)
function ZDMainView:__init()
	self.model = ZDModel:GetInstance()
	resMgr:AddUIAB("team")
	self:Config()
	self:InitEvent()
end

-- 配置
function ZDMainView:Config()
	self.id = "ZDMainView"
	self.showBtnClose = true
	self.openTopUI = true
	self.openResources = {1, 2}
	self.tabBar = {
		{label="", res0="zddt01", res1="zddt00", id="0", red=false}, 
		{label="", res0="wddw01", res1="wddw00", id="1", red=false},
	}
	self.defaultTabIndex = 0
	self.selectPanel = nil
	self.tabBarSelectCallback = function(idx, id)
		local cur = nil
		if id == "0" then
			self:SetTitle("队伍大厅")
			if not self.zdHallPanel then
				self.zdHallPanel = ZDHallPanel.New(self.container)
			end
			cur = self.zdHallPanel
		elseif id == "1" then
			self:SetTitle("我的队伍")
			if not self.zdMinePanel then
				self.zdMinePanel = ZDMinePanel.New(self.container)
			end
			cur = self.zdMinePanel
		end
		if self.selectPanel ~= cur then
			if self.selectPanel then
				self.selectPanel:SetVisible(false)
			end
			self.selectPanel = cur
			if cur then
				cur:SetVisible(true)
				cur:Update() -- 更新当前面板数据（每个面板切换时更新）
			end
		end
		self:SetTabarTips(id, false)
	end
	
end
-- 事件监听
function ZDMainView:InitEvent()
	local role = nil
	self.openCallback = function () -- 打开回调
		if self.selectPanel then
			self.selectPanel:Update()
			self.selectPanel:SetVisible(true)
		end
		role = SceneModel:GetInstance():GetMainPlayer()
		if role then
			self.roleChange = role:AddEventListener(SceneConst.OBJ_UPDATE, function ( k, v, old )
				if not self.isInited then return end
				if k == "teamId" then self:Update() end -- 队伍变化时改变
			end)
		end
	end
	self.closeCallback = function () -- 关闭回调
		if role then
			role:RemoveEventListener(self.roleChange)
		end
		if self.zdMinePanel then
			self.zdMinePanel:Close()
		end
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end

	self.hallChangeHandler = self.model:AddEventListener(ZDConst.HALL_CHANGE, function ()
		if self.selectPanel then
			self.selectPanel:Update()
		end
		self:Update()
	end)
	self.mineChangeHandler = self.model:AddEventListener(ZDConst.MINE_CHANGE, function ()
		if self.selectPanel then
			self.selectPanel:Update()
		end
		self:Update()
	end)
	
end
-- 重构打开
function ZDMainView:Open()
	CommonBackGround.Open(self)
	self:Update()
end

function ZDMainView:Layout()

	-- 由于本主面板是以标签形式处理，所以这里留空，如果是单一面板可以这里实现（仅一次）
end

function ZDMainView:Update()
	if not self.model then return end
	if self.model.teamId ~= 0 then
		self:SetTabbarVisible( "0", false)
		self:SetTabbarVisible( "1", true)
		self:SetSelectTabbar(1)
	else
		self:SetTabbarVisible( "1", false)
		self:SetTabbarVisible( "0", true)
		self:SetSelectTabbar(0)
	end
end

function ZDMainView:__delete()
	local role = SceneModel:GetInstance():GetMainPlayer()
	if role then role:RemoveEventListener(self.roleChange) end
	if self.zdHallPanel then
		self.zdHallPanel:Destroy()
	end
	self.zdHallPanel = nil
	if self.model then
		self.model:RemoveEventListener(self.hallChangeHandler)
		self.model:RemoveEventListener(self.mineChangeHandler)
	end
	if self.zdMinePanel then
		self.zdMinePanel:Destroy()
	end
	self.zdMinePanel = nil
	self.selectPanel = nil
end