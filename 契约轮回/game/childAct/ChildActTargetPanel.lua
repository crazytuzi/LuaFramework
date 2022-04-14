--- Created by Admin.
--- DateTime: 2019/12/18 20:00

ChildActTargetPanel = ChildActTargetPanel or class("ChildActTargetPanel", SevenDayPetTargetPanel)
local ChildActTargetPanel = ChildActTargetPanel


function ChildActTargetPanel:ctor(parent_node, parent_panel,actID, assetName)

end



function ChildActTargetPanel:UpdateRewards(tab)
	ChildActTargetPanel.super.UpdateRewards(self, tab)
	GlobalEvent:Brocast(ChildActEvent.UpdateMainRed)
end

function ChildActTargetPanel:SetEffect()

   --[[if not self.effect then
        self.effect = UIEffect(self.leftbg, 10311, false)
        --self.effect:SetOrderIndex(101)
        local cfg = {}
        cfg.scale = 1.25
        cfg.pos = {x= 0, y=-100,z=0}
        self.effect:SetConfig(cfg)
    end
    local img = GetChild(self.leftbg.transform,"img")
    local action = cc.MoveTo(1, 0, 90)
    action = cc.Sequence(action, cc.MoveTo(1, 0, 75))
    action = cc.Repeat(action, 4)
    action = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action, img.transform)
	--]]
end