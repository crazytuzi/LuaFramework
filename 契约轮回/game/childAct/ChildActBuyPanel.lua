--- Created by Admin.
--- DateTime: 2019/12/18 19:56

ChildActBuyPanel = ChildActBuyPanel or class("ChildActBuyPanel", SevenDayPetBuyPanel)
local ChildActBuyPanel = ChildActBuyPanel

function ChildActBuyPanel:ctor(parent_node, parent_panel,actID, assetName)

end

function ChildActBuyPanel:dctor()
    if self.effect then
		self.effect:destroy()
		self.effect = nil
	end
	if self.monster then
		self.monster:destroy()
		self.monster = nil
	end
	ChildActBuyPanel.super.dctor(self)
end

function ChildActBuyPanel:InitUI()
    self:SetEffect()
	ChildActBuyPanel.super.InitUI(self)
end

function ChildActBuyPanel:SetEffect()
    if not self.effect then
        self.effect = UIEffect(self.leftbg, 10311, false)
        --self.effect:SetOrderIndex(101)
        local cfg1 = {}
        cfg1.scale = 1.25
        cfg1.pos = {x= 0, y=-80,z=0}
        self.effect:SetConfig(cfg1)
    end
	
	local cfg = {}
	cfg.pos = {x = -2000, y = -60, z = 193}
	cfg.scale = {x=200, y=200, z=200}
	cfg.trans_offset = {y=60}
	local config = OperateModel:GetInstance():GetConfig(self.actID) 
	local resName = String2Table(config.reqs)[1][1]
	self.monster = UIModelCommonCamera(self.leftbg, nil, resName)
	self.monster:SetConfig(cfg)
end







