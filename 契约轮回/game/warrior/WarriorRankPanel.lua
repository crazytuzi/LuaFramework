WarriorRankPanel = WarriorRankPanel or class("WarriorRankPanel", BaseItem)
local this = WarriorRankPanel

function WarriorRankPanel:ctor(parent_node, parent_panel)
	
	self.abName = "warrior";
	self.image_ab = "warrior_image";
	self.assetName = "WarriorRankPanel"
	self.layer = "UI"
	self.rightItems = {}
	self.gevents = {}
	self.events = {}
	self.model = WarriorModel:GetInstance()
	WarriorRankPanel.super.Load(self)
end

function WarriorRankPanel:dctor()
	self.model:RemoveTabListener(self.events)
	GlobalEvent:RemoveTabListener(self.gevents)
	for k, v in pairs(self.rightItems) do
		v:destroy()
	end
	self.rightItems = {}
	
	if self.roleMode  then
		self.roleMode:destroy()
	end
	
	--if self.red1 then
		--self.red1:destroy()
		--self.red1 = nil
	--end
end

function WarriorRankPanel:LoadCallBack()
	self.nodes = {
		"WarriorRankItem","ScrollView/Viewport/Content",
	}
	self:GetChildren(self.nodes)
	self:InitUI()
	self:AddEvent()

end

function WarriorRankPanel:InitUI()
	local cfg = Config.db_warrior_reward
	for i = 1, #cfg do
		local item = self.rightItems[i]
		if not item then
			item = WarriorRankItem(self.WarriorRankItem.gameObject,self.Content,"UI")
			self.rightItems[i] = item
		end
		item:SetData(cfg[i])
	end
end


function WarriorRankPanel:AddEvent()
end


