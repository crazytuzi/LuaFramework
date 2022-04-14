GodFoldMenu = GodFoldMenu or class("GodFoldMenu", BaseTreeMenu)
local this = GodFoldMenu

function GodFoldMenu:ctor(parent_node, layer, parent_cls, oneLvMenuCls, twoLvMenuCl, isStickItemWhenClick)
    self.abName = "system"
    self.assetName = "GodFoldMenu"
    self.layer = layer
    --self.parent_cls_name = parent_cls and parent_cls.__cname or ""
    self.oneLvMenuCls = GodMenuItem
    self.isStickItemWhenClick = isStickItemWhenClick or true
    GodFoldMenu.super.Load(self)
end

function GodFoldMenu:dctor()

end

function GodFoldMenu:UpdateRedPoint()
    --for i = 1, #self.leftmenu_list do
    --    self.leftmenu_list[i]:SetRedPoint()
    --    for j = 1, #self.leftmenu_list[i].menuitem_list do
    --        self.leftmenu_list[i].menuitem_list[j]:SetRedPoint()
    --    end
    --end
    for i = 1, #self.leftmenu_list do
        self.leftmenu_list[i]:SetRedPoint()
        for j = 1, #self.leftmenu_list[i].menuitem_list do
            self.leftmenu_list[i].menuitem_list[j]:SetRedPoint()
        end
    end
end

