ClanCYPanel = BaseClass(LuaUI)
function ClanCYPanel:__init( container )
	self.parent = container
	self.ui = GComponent.New()
	self:Layout()
end
function ClanCYPanel:Layout()
	self:AddTo(self.parent)
	self:SetXY(162, 196)
	local panel = self.ui
	-- 标签
	local res0 = UIPackage.GetItemURL("Common" , "btnBg_001")
	local res1 = UIPackage.GetItemURL("Common" , "btnBg_002")
	local tabDatas = {
		{label="成员列表", res0=res0, res1=res1, id="0", red=false}, 
		{label="申请列表", res0=res0, res1=res1, id="1", red=false},
		-- {label="事件", res0=res0, res1=res1, id="2", red=false},
	}
	self.memberPane = nil
	self.shenqingPane = nil
	self.eventPane = nil
	self.selectPanel = nil
	local function tabClickCallback( idx, id )
		local cur = nil
		if id == "0" then
			if not self.memberPane then
				self.memberPane = ClanCYMemberPane.New(panel)
			end
			cur = self.memberPane
		elseif id == "1" then
			if not self.shenqingPane then
				self.shenqingPane = ClanCYMemberSQPane.New(panel)
			end
			cur = self.shenqingPane
		elseif id == "2" then
			if not self.eventPane then
				self.eventPane = ClanCYEventPane.New(panel)
			end
			cur = self.eventPane
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
	local offX=0
	local offY=0
	local ctrl, tabs = CreateTabbar(panel, 1, tabClickCallback, tabDatas, offX, offY-50, 0, 138, 133, 46)

	self.tabCtrl = ctrl
	self.tabs = tabs
end

function ClanCYPanel:SetVisible(v,first)
	LuaUI.SetVisible(self, v)
	if v and not first then
		local cur = self.selectPanel
		if self.memberPane ==cur then
			ClanCtrl:GetInstance():C_GetGuildPlayerList()
		elseif self.shenqingPane ==cur then
			ClanCtrl:GetInstance():C_GetApplyList()
		elseif self.eventPane ==cur then
			print("事件面板没有协议开发？？")
		end
	end
end

function ClanCYPanel:Update()
	if self.selectPanel then
		self.selectPanel:Update()
	end
end

function ClanCYPanel:__delete()
	self.selectPanel = nil
	if self.memberPane then
		self.memberPane:Destroy()
		self.memberPane=nil
	end
	if self.shenqingPane then
		self.shenqingPane:Destroy()
		self.shenqingPane=nil
	end
	if self.eventPane then
		self.eventPane:Destroy()
		self.eventPane=nil
	end
end