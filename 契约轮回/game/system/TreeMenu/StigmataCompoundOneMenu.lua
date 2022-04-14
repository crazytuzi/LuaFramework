StigmataCompoundOneMenu = StigmataCompoundOneMenu or class("StigmataCompoundOneMenu",BaseTreeOneMenu)
local StigmataCompoundOneMenu = StigmataCompoundOneMenu

function StigmataCompoundOneMenu:ctor(parent_node,layer,parent_cls_name,twoLvMenuCls)
    self.abName = "system"
    self.assetName = "StigmataCompoundOneMenu"
    self.layer = layer

    StigmataCompoundOneMenu.super.Load(self)
end


function StigmataCompoundOneMenu:LoadCallBack()

    self.nodes = {
        "arror"
    }
    self:GetChildren(self.nodes)
    StigmataCompoundOneMenu.super.LoadCallBack(self)

end

function StigmataCompoundOneMenu:LoadChildMenu()
    local typeId = self.data[1]
    for _, menuitem in pairs(self.menuitem_list) do
        menuitem:destroy()
    end
    self.menuitem_list = {}
    local subtypes = self.sub_data
    local count = #subtypes
    self.menuHeight = 0
    for i=1, count do
        local item = subtypes[i]
        local menuitem = self.twoLvMenuCls(self.Content,nil,self)
        menuitem:SetData(typeId,item, self.select_sub_id, nil, nil, i)
        table.insert(self.menuitem_list, menuitem)
        self.menuHeight = self.menuHeight + menuitem:GetHeight()
    end
    self.oldMenuHeight = self.menuHeight
    self:ReLayout()
end

function StigmataCompoundOneMenu:dctor()

end

function StigmataCompoundOneMenu:SetData(data, index, sub_data, select_sub_id, oneLvMenuSpan, twoLvMenuSpan)
    StigmataCompoundOneMenu.super.SetData(self,data, index, sub_data, select_sub_id, oneLvMenuSpan, twoLvMenuSpan)
    if table.isempty(sub_data) then
        SetVisible(self.arror,false)
    end
end

function StigmataCompoundOneMenu:SelectedItem(index)
    
    StigmataCompoundOneMenu.super.SelectedItem(self,index)

    --派发点击二级菜单事件
    GlobalEvent:Brocast(CombineEvent.LeftSecondMenuClick .. StigmataCompoundPanel.__cname,self.index,index)

end

function StigmataCompoundOneMenu:Select(flag)

    StigmataCompoundOneMenu.super.Select(self,flag)

    if flag then
        SetLocalRotation(self.arror,0,0,0)
    else
        SetLocalRotation(self.arror,0,0,180)
    end
end


