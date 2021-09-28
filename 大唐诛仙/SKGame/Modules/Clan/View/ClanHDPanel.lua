ClanHDPanel = BaseClass(LuaUI)
function ClanHDPanel:__init( container )
	self.parent = container
	self.ui = GComponent.New()
	self:Layout()
end
function ClanHDPanel:Layout()
	self:AddTo(self.parent)
	self:SetXY(316, 120)
	local panel = self.ui
	-- 标签
	local res0 = UIPackage.GetItemURL("Common" , "btnBg_001")
	local res1 = UIPackage.GetItemURL("Common" , "btnBg_002")
	local tabDatas = {
		{label="都护府升级", res0=res0, res1=res1, id="0", red=false}, 
		{label="都护府捐献", res0=res0, res1=res1, id="1", red=false},
		{label="都护府宣战", res0=res0, res1=res1, id="2", red=false},
		-- {label="都护府城战", res0=res0, res1=res1, id="3", red=false},
	}
	self.upgradePane = nil
	self.contributePane = nil
	self.fightPane = nil
	self.selectPanel = nil
	local function tabClickCallback( idx, id )
		local cur = nil
		if id == "0" then
			if not self.upgradePane then
				self.upgradePane = ClanHDUpGradePane.New(panel)
			end
			cur = self.upgradePane
		elseif id == "1" then
			if not self.contributePane then
				self.contributePane = ClanHDContributePane.New(panel)
			end
			cur = self.contributePane
		elseif id == "2" then
			if not self.fightPane then
				self.fightPane = ClanHDFightPane.New(panel)
			end
			cur = self.fightPane
		-- elseif id == "3" then
		-- 	UIMgr.Win_FloatTip("您的成员未达到40人，不能开启城战！")
		-- 	return
		end
		if self.selectPanel ~= cur then
			if self.selectPanel then
				self.selectPanel:SetVisible(false)
			end
			if cur then
				cur:SetVisible(true, self.selectPanel==nil)
				self.selectPanel = cur
			end
		end
		SetTabRedTips(self.tabs, id, false ) -- 点击去掉红点
	end
	local offX=-140
	local offY=0
	local ctrl, tabs = CreateTabbar(panel, 0, tabClickCallback, tabDatas, offX, offY, 0, 52, 133, 46)

	self.tabCtrl = ctrl
	self.tabs = tabs
end
function ClanHDPanel:Update()
	if self.selectPanel then
		self.selectPanel:Update()
	end
end
function ClanHDPanel:SetVisible(v,first)
	LuaUI.SetVisible(self, v)
	if v and not first then
		local cur = self.selectPanel
		if self.fightPane ==cur then
			ClanCtrl:GetInstance():C_GetGuildWarList()
		elseif self.contributePane ==cur then
			ClanCtrl:GetInstance():C_GetDonateTimes()
		-- elseif self.upgradePane ==cur then
		end
	end
end
function ClanHDPanel:__delete()
	if self.fightPane then
		self.fightPane:Destroy()
		self.fightPane = nil
	elseif self.contributePane then
		self.contributePane:Destroy()
		self.contributePane = nil
	elseif self.upgradePane then
		self.upgradePane:Destroy()
		self.upgradePane = nil
	end
end