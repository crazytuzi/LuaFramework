ClanJNPanel = BaseClass(LuaUI)
function ClanJNPanel:__init( container )
	self.parent = container
	self.ui = GComponent.New()
	self.model = ClanModel:GetInstance()
	self.model:ConfigSkill()
	self:Layout()
end
function ClanJNPanel:Layout()
	self:AddTo(self.parent)
	self:SetXY(155, 120)
	local panel = self.ui
	local res0 = UIPackage.GetItemURL("Common" , "btnBg_001")	-- 标签
	local res1 = UIPackage.GetItemURL("Common" , "btnBg_002")
	local tabDatas = {
		{label="学习", res0=res0, res1=res1, id=ClanJNPane.Learn, red=false}, 
		{label="研发", res0=res0, res1=res1, id=ClanJNPane.Dev, red=false}
	}
	self.learnPane = nil
	self.developPane = nil
	self.selectPanel = nil
	local function tabClickCallback( idx, id )
		local cur = nil
		if id == ClanJNPane.Learn then
			if not self.learnPane then
				self.learnPane = ClanJNPane.New(panel, id)
			end
			cur = self.learnPane
		elseif id == ClanJNPane.Dev then
			if not self.developPane then
				self.developPane = ClanJNPane.New(panel, id)
			end
			cur = self.developPane
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
	local offX= 587
	local offY= 0
	local ctrl, tabs = CreateTabbar(panel, 1, tabClickCallback, tabDatas, offX, offY, 0, 138, 133, 46)

	self.tabCtrl = ctrl
	self.tabs = tabs
	ShowTabbar(self.tabs, ClanJNPane.Dev, self.model.job>1)
end
function ClanJNPanel:Update()
	ShowTabbar(self.tabs, ClanJNPane.Dev, self.model.job>1)
	if self.selectPanel then
		self.selectPanel:Update()
	end
end
function ClanJNPanel:SetVisible(v,first)
	LuaUI.SetVisible(self, v)
	if v and not first then
		ClanCtrl:GetInstance():C_GetGuildSkills() -- 请求数据
	end
end
function ClanJNPanel:__delete()
	self.selectPanel = nil
	if self.learnPane then
		self.learnPane:Destroy()
		self.learnPane=nil
	end
	if self.developPane then
		self.developPane:Destroy()
		self.developPane=nil
	end
end