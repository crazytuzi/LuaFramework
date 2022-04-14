ArtifactFoldMenu = ArtifactFoldMenu or class("ArtifactFoldMenu", BaseTreeMenu)
local this = ArtifactFoldMenu

function ArtifactFoldMenu:ctor(parent_node, layer, parent_cls, oneLvMenuCls, twoLvMenuCl, isStickItemWhenClick)
    self.abName = "system"
    self.assetName = "ArtifactFoldMenu"
    self.layer = layer
    --self.parent_cls_name = parent_cls and parent_cls.__cname or ""
    self.oneLvMenuCls = ArtifactMenuItem
    self.isStickItemWhenClick = isStickItemWhenClick or true
    ArtifactFoldMenu.super.Load(self)
end

function ArtifactFoldMenu:dctor()

end

function ArtifactFoldMenu:UpdateRedPoint()
    for i = 1, #self.leftmenu_list do
        self.leftmenu_list[i]:SetRedPoint()
        for j = 1, #self.leftmenu_list[i].menuitem_list do
            self.leftmenu_list[i].menuitem_list[j]:SetRedPoint()
        end
    end
end

function ArtifactFoldMenu:RelayoutLeftMenu()
    self.LeftContent.sizeDelta = Vector2(self.LeftContent.sizeDelta.x, self.leftHeight + 5)
end

function ArtifactFoldMenu:UpdateArtInfo()
    for i = 1, #self.leftmenu_list do
        self.leftmenu_list[i]:UpdateArtInfo()
    end
end



--IsArtiLock



