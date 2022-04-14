StigmataCompoundTwoMenu = StigmataCompoundTwoMenu or class("StigmataCompoundTwoMenu",BaseTreeTwoMenu)
local StigmataCompoundTwoMenu = StigmataCompoundTwoMenu

function StigmataCompoundTwoMenu:ctor(parent_node,layer,first_menu_item)
    self.abName = "system"
    self.assetName = "StigmataCompoundTwoMenu"

    self.index = 1
    StigmataCompoundTwoMenu.super.Load(self)
end

function StigmataCompoundTwoMenu:dctor()


end

function StigmataCompoundTwoMenu:LoadCallBack()
    self.nodes = {

    }
    self:GetChildren(self.nodes)
    StigmataCompoundTwoMenu.super.LoadCallBack(self)


end



function StigmataCompoundTwoMenu:SetData(first_menu_id,data, select_sub_id,menuSpan, index)
    StigmataCompoundTwoMenu.super.SetData(self,first_menu_id,data, select_sub_id,menuSpan)
    self.group = first_menu_id
    self.page = data[1]
    self.index = index
end





