StigmataCompoundFoldMenu = StigmataCompoundFoldMenu or class("StigmataCompoundFoldMenu", BaseTreeMenu)
local this = StigmataCompoundFoldMenu

function StigmataCompoundFoldMenu:ctor(parent_node, layer, parent_cls, oneLvMenuCls, twoLvMenuCl, isStickItemWhenClick)
    self.abName = "system"
    self.assetName = "StigmataCompoundFoldMenu"
    
    self.oneLvMenuCls = StigmataCompoundOneMenu
    self.isStickItemWhenClick = isStickItemWhenClick or true
    
    StigmataCompoundFoldMenu.super.Load(self)
end


function StigmataCompoundFoldMenu:SetDefaultSelected(first, second)

    --需要先设置为false 否则会出问题
    self.leftmenu_list[first].selected = false

    StigmataCompoundFoldMenu.super.SetDefaultSelected(self,first,second)
end

