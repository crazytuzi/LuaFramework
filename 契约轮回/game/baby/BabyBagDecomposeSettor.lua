---
--- Created by  Administrator
--- DateTime: 2019/11/14 14:53
---
BabyBagDecomposeSettor = BabyBagDecomposeSettor or class("BabyBagDecomposeSettor", BaseBagIconSettor)
local this = BabyBagDecomposeSettor

function BabyBagDecomposeSettor:ctor(parent_node, layer)
    self.abName = "system"
    self.assetName = "BagItem"
    self.layer = layer
    BabyBagDecomposeSettor.super.Load(self)
end

function BabyBagDecomposeSettor:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end



function BabyBagDecomposeSettor:InitUI()

end


function BabyBagDecomposeSettor:AddEvent()
    BabyBagDecomposeSettor.super.AddEvent(self)
    AddClickEvent(self.touch.gameObject,handler(self,self.ClickEvent))
end