WakeMenuItem = WakeMenuItem or class("WakeMenuItem",BaseItem)
local WakeMenuItem = WakeMenuItem

function WakeMenuItem:ctor(parent_node,layer)
	self.abName = "wake"
	self.assetName = "WakeMenuItem"
	self.layer = layer

	self.model = WakeModel:GetInstance()
	WakeMenuItem.super.Load(self)
end

function WakeMenuItem:dctor()
end

function WakeMenuItem:LoadCallBack()
	self.nodes = {
		"icon", "icon_select/title_select", "icon_select","icon/title",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
	self.title = GetText(self.title)
	self.title_select = GetText(self.title_select)
	self.icon = GetImage(self.icon)
	self.icon_select_img = GetImage(self.icon_select)
	self:UpdateView()
end

function WakeMenuItem:AddEvent()

	local function call_back(target,x,y)
		local wake_times = RoleInfoModel:GetInstance():GetRoleValue("wake")
		local arr = string.split(self.data.id, "@")
		if tonumber(arr[2]) > wake_times + 2 then
			return Notify.ShowText(ConfigLanguage.Wake.WakeNotOpen)
		end
		self.model:Brocast(WakeEvent.SelectWakeTimes, self.data.id)
	end
	AddClickEvent(self.icon.gameObject, call_back)
end

function WakeMenuItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function WakeMenuItem:UpdateView()
	self.title.text = self.data.title
	self.title_select.text = self.data.title
	lua_resMgr:SetImageTexture(self,self.icon,"wake_image", self.data.menu)
	if self.data.id == self.select_key then
		lua_resMgr:SetImageTexture(self,self.icon_select_img, 'wake_image', self.data.menu_select)
	end
end

function WakeMenuItem:Select(select_key)
	self.select_key = select_key
	SetVisible(self.icon_select, select_key==self.data.id)
	if self.is_loaded then
		if self.data.id == self.select_key then
			lua_resMgr:SetImageTexture(self,self.icon_select_img, 'wake_image', self.data.menu_select)
		end
	end
end