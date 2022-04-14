illustrationOneMenu = illustrationOneMenu or class("illustrationOneMenu",BaseTreeOneMenu)
local illustrationOneMenu = illustrationOneMenu

function illustrationOneMenu:ctor(parent_node,layer,parent_cls_name,twoLvMenuCls)
    self.abName = "system"
    self.assetName = "illustrationOneMenu"
    self.layer = layer

    self.red_dot = nil

    illustrationOneMenu.super.Load(self)
end


function illustrationOneMenu:dctor()
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function illustrationOneMenu:LoadCallBack()

    self.nodes = {
    }
    self:GetChildren(self.nodes)
    illustrationOneMenu.super.LoadCallBack(self)

end

function illustrationOneMenu:LoadChildMenu()
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


function illustrationOneMenu:SetData(data, index, sub_data, select_sub_id, oneLvMenuSpan, twoLvMenuSpan)
    illustrationOneMenu.super.SetData(self,data, index, sub_data, select_sub_id, oneLvMenuSpan, twoLvMenuSpan)
    if table.isempty(sub_data) then
        SetVisible(self.arror,false)
    end
end

function illustrationOneMenu:SelectedItem(index)
    
    illustrationOneMenu.super.SelectedItem(self,index)

    --派发点击二级菜单事件
    GlobalEvent:Brocast(CombineEvent.LeftSecondMenuClick .. illustrationPanel.__cname,self.index,index)

end

function illustrationOneMenu:SetRedDot(is_show)
    if not is_show and not self.red_dot then
        return
    end

    self.red_dot = self.red_dot or RedDot(self.transform)
    self.red_dot:SetRedDotParam(is_show)
    SetLocalPositionZ(self.red_dot.transform,0)
    SetAnchoredPosition(self.red_dot.transform,105,21)
end



