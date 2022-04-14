WakeSkillItem = WakeSkillItem or class("WakeSkillItem",BaseItem)
local WakeSkillItem = WakeSkillItem

function WakeSkillItem:ctor(parent_node,layer)
	self.abName = "wake"
	self.assetName = "WakeSkillItem"
	self.layer = layer

	self.model = WakeModel:GetInstance()
	WakeSkillItem.super.Load(self)
end

function WakeSkillItem:dctor()
end

function WakeSkillItem:LoadCallBack()
	self.nodes = {
		"icon", "title", "flag", "bg"
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
	self.title = GetText(self.title)
	self.icon = GetImage(self.icon)
	self.flag = GetImage(self.flag)

	self:UpdateView()
end

function WakeSkillItem:AddEvent()
	local function call_back(target,x,y)
		local tipsPanel = lua_panelMgr:GetPanelOrCreate(TipsSkillPanel)
		tipsPanel:Open()
		tipsPanel:SetId(self.data, self.bg)
		self.model:Brocast(WakeEvent.ClickSkill, self.data)
	end
	AddClickEvent(self.icon.gameObject,call_back)
end

function WakeSkillItem:SetData(data, flag)
	self.data = data
	self.flag_value = flag
	if self.is_loaded then
		self:UpdateView()
	end
end

function WakeSkillItem:UpdateView()
	local skill = Config.db_skill[tonumber(self.data)]
	self.title.text = skill.name
	lua_resMgr:SetImageTexture(self,self.icon,"iconasset/icon_skill",tostring(skill.icon), true)
	if not self.flag_value then
		SetVisible(self.flag, false)
	else
		lua_resMgr:SetImageTexture(self, self.flag, "wake_image", self.flag_value)
	end
end