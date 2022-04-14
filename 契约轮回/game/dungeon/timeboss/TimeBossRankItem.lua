TimeBossRankItem = TimeBossRankItem or class("TimeBossRankItem",BaseCloneItem)
local TimeBossRankItem = TimeBossRankItem

function TimeBossRankItem:ctor(obj,parent_node,layer)
	TimeBossRankItem.super.Load(self)
end

function TimeBossRankItem:dctor()
end

function TimeBossRankItem:LoadCallBack()
	self.nodes = {
		"rank", "name","damage","click"
	}
	self:GetChildren(self.nodes)
	self.rank = GetText(self.rank)
	self.name = GetText(self.name)
	self.damage = GetText(self.damage)
	self:AddEvent()
end

function TimeBossRankItem:AddEvent()
	local function call_back()
		local panel = lua_panelMgr:GetPanelOrCreate(RoleMenuPanel, self.name)
		panel:Open(nil,self.data.captain)
	end
	AddClickEvent(self.click.gameObject,call_back)
end

function TimeBossRankItem:SetData(data)
	self.data = data
	self:UpdateView()
end

function TimeBossRankItem:UpdateView()

	local  sName = self.data.name
	if string.len(self.data.name) > 6 then
		sName = 	string.sub(self.data.name,1,6)
	end

	self.rank.text = self.data.rank
	self.name.text = sName.."s team"
	if self.data.damage/100 < 10 then
		self.damage.text = string.format("%0.2f", self.data.damage/100) .. "%"
	else
		self.damage.text = string.format("%0.1f", self.data.damage/100) .. "%"
	end
end