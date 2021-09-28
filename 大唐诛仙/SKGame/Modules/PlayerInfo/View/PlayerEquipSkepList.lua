PlayerEquipSkepList =BaseClass(LuaUI)

function PlayerEquipSkepList:__init( ... )
	self.URL = "ui://0oudtuxpfqe0t";
	self:__property(...)
	self:Config()
end

function PlayerEquipSkepList:SetProperty( parent )
	self.parent = parent 
end

function PlayerEquipSkepList:Config()
	self.list = {}
end

function PlayerEquipSkepList:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("PlayerInfo","PlayerEquipSkepList")

	self.bg = self.ui:GetChild("bg")
	self.line1 = self.ui:GetChild("line1")
	self.title = self.ui:GetChild("title")
	self.line2 = self.ui:GetChild("line2")
	self.equipList = self.ui:GetChild("equipList")
	self.closeBtn = self.ui:GetChild("closeBtn")
end

function PlayerEquipSkepList.Create( ui, ...)
	return PlayerEquipSkepList.New(ui, "#", {...})
end

--刷新
function PlayerEquipSkepList:Refresh(list, isChange)
	self:ClearList()
	if list then
		self.list = {}
		for i = 1, #list do
			local item = PlayerEquipSkepListItem.New(list[i], isChange)
			item:AddTo(self.equipList)
			item:Init()
			table.insert(self.list, item)
		end
	end
	self.equipList.scrollPane:ScrollTop(true)
end

function PlayerEquipSkepList:ClearList()
	if self.list then
		for i, v in ipairs(self.list) do
			v:Destroy()
		end
	end
end

function PlayerEquipSkepList:Show(list, isChange)
	self:Refresh(list, isChange)
end

function PlayerEquipSkepList:Hide()
	
end

--关闭标签
function PlayerEquipSkepList:OnCloseBtn()
	UIMgr.HidePopup()
end

function PlayerEquipSkepList:__delete()
	self:ClearList()
	self.list = nil
end