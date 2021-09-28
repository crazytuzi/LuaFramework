ClanMainPanel = BaseClass(CommonBackGround)

function ClanMainPanel:__init(ctrl)
	self.ctrl = ctrl
	self.model = ClanModel:GetInstance()
	self:Config()
	self:InitEvent()
end

-- 配置
function ClanMainPanel:Config()
	self.cjPanel=nil
	self.sqPanel=nil
	self.xxPanel=nil
	self.cyPanel=nil
	self.hdPanel=nil
	self.jnPanel=nil

	self.id = "ClanMainPanel"
	self.showBtnClose = true
	self.openTopUI = true
	self.openResources = {1, 2}
	self.tabBar = {
		{label="", res0="cj0", res1="cj1", id=ClanConst.paneType.cj, red=false}, 
		{label="", res0="sq0", res1="sq1", id=ClanConst.paneType.sq, red=false},
		{label="", res0="xx01", res1="xx00", id=ClanConst.paneType.xx, red=false},
		{label="", res0="cy01", res1="cy00", id=ClanConst.paneType.cy, red=false},
		{label="", res0="hd0", res1="hd1", id=ClanConst.paneType.hd, red=false},
		{label="", res0="jn0", res1="jn1", id=ClanConst.paneType.jn, red=false},
	}
	self.defaultTabIndex = 0
	self.selectPanel = nil
	-- self.isfirst=true
	self.tabBarSelectCallback = function(idx, id)
		local cur = nil
		if id == "0" then
			self:SetTitle("创建")
			if not self.cjPanel then
				self.cjPanel = ClanCJPanel.New(self.container)
			end
			cur = self.cjPanel
		elseif id == "1" then
			self:SetTitle("申请")
			if not self.sqPanel then
				self.sqPanel = ClanSQPanel.New(self.container)
			end
			cur = self.sqPanel
		elseif id == "2" then
			self:SetTitle("信息")
			if not self.xxPanel then
				self.xxPanel = ClanXXPanel.New(self.container)
			end
			cur = self.xxPanel
		elseif id == "3" then
			self:SetTitle("成员")
			if not self.cyPanel then
				self.cyPanel = ClanCYPanel.New(self.container)
			end
			cur = self.cyPanel
		elseif id == "4" then
			self:SetTitle("活动")
			if not self.hdPanel then
				self.hdPanel = ClanHDPanel.New(self.container)
			end
			cur = self.hdPanel
			-- UIMgr.Win_FloatTip("功能待开发中。。")
		elseif id == "5" then
			self:SetTitle("技能")
			if not self.jnPanel then
				self.jnPanel = ClanJNPanel.New(self.container)
			end
			cur = self.jnPanel
			-- UIMgr.Win_FloatTip("功能待开发中。。")
		end
		if self.selectPanel ~= cur then
			if self.selectPanel then
				self.selectPanel:SetVisible(false)
			end
			if cur then
				cur:SetVisible(true, self.isfirst)
				self.isfirst=false
				self.selectPanel = cur
			end
		end
		self.model.openType = id
		self:SetTabarTips(id, false)
	end
end

-- 事件监听
function ClanMainPanel:InitEvent()
	self.openCallback = function () -- 打开回调
		if self.model.openType then
			self:SetSelectTabbar( self.model.openType )
			self.model.openType = nil
		end
	end
	
	self.closeCallback = function ()
		
	end -- 关闭回调

end

-- 重构打开
function ClanMainPanel:Open(tabIndex)
	if tabIndex then
		CommonBackGround.Open(self)
		self:SetSelectTabbar(tabIndex)
	elseif self:IsOpen() then -- 已经打开，就切换指定标签
		
	else
		CommonBackGround.Open(self)
		local model = self.model
		local paneType = ClanConst.paneType
		self.isfirst = true
		if model.clanId == 0 then
			self:SetSelectTabbar(paneType.sq, self.first)
		else
			self:SetSelectTabbar(paneType.xx, self.first)
		end
	end
end

-- 由于本主面板是以标签形式处理，所以这里留空，如果是单一面板可以这里实现（仅一次）
function ClanMainPanel:Layout()
	local paneType = ClanConst.paneType
	self:SetTabbarVisible({paneType.xx,paneType.cy,paneType.hd,paneType.jn}, false)
end

-- 更新界面
function ClanMainPanel:Update()
	local model = self.model
	local paneType = ClanConst.paneType

	if model.clanId == 0 then
		self:SetTabbarVisible({paneType.cj, paneType.sq}, true)
		self:SetTabbarVisible({paneType.xx, paneType.cy, paneType.hd, paneType.jn}, false)
	else
		self:SetTabbarVisible({paneType.cj, paneType.sq}, false)
		self:SetTabbarVisible({paneType.xx, paneType.cy, paneType.hd, paneType.jn}, true)
	end
	if model.justJoinClan then
		self:SetSelectTabbar(paneType.xx)
		model.justJoinClan=false
		if model.job == 0 then
			local s = StringFormat("您已经成为 {0} 都护府的 {1} ,2天内累计贡献未达到 {2} 会被请离都护府,累计贡献达到 {2} 会自动转正为 {3} 。", 
				model.clanInfo.guildName, 
				ClanConst.clanJob[1], 
				GetCfgData("constant"):Get(63).value,
				ClanConst.clanJob[2]
				)
			UIMgr.Win_Alter(ClanConst.clanJob[1], s, "确定", function () end)
		end
	end
	if model.justExitClan then
		self:SetSelectTabbar(paneType.sq)
		model.justExitClan=false
	end
	if self.selectPanel then
		self.selectPanel:Update()
	end
end

function ClanMainPanel:__delete()
	self.selectPanel = nil
	if self.cjPanel then
		self.cjPanel:Destroy()
		self.cjPanel=nil
	end
	if self.sqPanel then
		self.sqPanel:Destroy()
		self.sqPanel=nil
	end
	if self.xxPanel then
		self.xxPanel:Destroy()
		self.xxPanel=nil
	end
	if self.cyPanel then
		self.cyPanel:Destroy()
		self.cyPanel=nil
	end
	if self.hdPanel then
		self.hdPanel:Destroy()
		self.hdPanel=nil
	end
	if self.jnPanel then
		self.jnPanel:Destroy()
		self.jnPanel=nil
	end
end