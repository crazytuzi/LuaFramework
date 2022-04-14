DungeonWorldBossDamageItem = DungeonWorldBossDamageItem or class("DungeonWorldBossDamageItem",BaseCloneItem)
local DungeonWorldBossDamageItem = DungeonWorldBossDamageItem

function DungeonWorldBossDamageItem:ctor(obj,parent_node,layer)
	DungeonWorldBossDamageItem.super.Load(self)
end

function DungeonWorldBossDamageItem:dctor()
end

function DungeonWorldBossDamageItem:LoadCallBack()
	self.nodes = {
		"damage", "name","click","belong"
	}
	self:GetChildren(self.nodes)
	self.name = GetText(self.name)
	self.damage = GetText(self.damage)
	self:AddEvent()
end

function DungeonWorldBossDamageItem:AddEvent()
	local function call_back()
		--logError(self.data.captain)
		local panel = lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.name)
		panel:Open(nil,self.data.captain)
	end
	AddClickEvent(self.click.gameObject,call_back)
end

function DungeonWorldBossDamageItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function DungeonWorldBossDamageItem:UpdateView()
	local  sName = self.data.name
	if string.len(self.data.name) > 6 then
		sName = 	string.sub(self.data.name,1,6)
	end
	self.name.text = sName.."s team"
	self.damage.text = GetShowNumber(self.data.damage)
	SetVisible(self.belong,self.data.rank == 1)

end