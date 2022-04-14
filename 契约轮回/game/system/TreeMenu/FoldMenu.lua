FoldMenu = FoldMenu or class("FoldMenu", BaseTreeMenu)
local this = FoldMenu

function FoldMenu:ctor(parent_node, layer, parent_cls, oneLvMenuCls, twoLvMenuCl, isStickItemWhenClick)
    self.abName = "system"
    self.assetName = "FoldMenu"
    --self.layer = layer
    --self.parent_cls_name = parent_cls and parent_cls.__cname or ""
    self.oneLvMenuCls = FirstMenuItem
    self.isStickItemWhenClick = isStickItemWhenClick or true
    
    FoldMenu.super.Load(self)
end

function FoldMenu:dctor()

end