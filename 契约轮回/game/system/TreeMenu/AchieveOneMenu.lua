AchieveOneMenu = AchieveOneMenu or class("AchieveOneMenu",BaseTreeOneMenu)
local AchieveOneMenu = AchieveOneMenu

function AchieveOneMenu:ctor(parent_node,layer,parent_cls_name,twoLvMenuCls)
    self.abName = "system"
    self.assetName = "AchieveOneMenu"
    self.layer = layer
    --self.model = 2222222222222end:GetInstance()
    AchieveOneMenu.super.Load(self)
end

--function TreeOneMenu:dctor()
--end
function AchieveOneMenu:LoadCallBack()

    self.nodes = {
        "arror","redParent"
    }
    self:GetChildren(self.nodes)
    AchieveOneMenu.super.LoadCallBack(self)
    self.redPoint = RedDot(self.redParent, nil, RedDot.RedDotType.Nor)
    self.redPoint:SetPosition(115, 22)
end

function AchieveOneMenu:LoadChildMenu()
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

function AchieveOneMenu:dctor()
    if self.redPoint then
        self.redPoint:destroy()
        self.redPoint = nil
    end
   -- AchieveOneMenu.super.dctor(self)
end
--
--function TreeOneMenu:LoadCallBack()
--	self.nodes = {
--		"",
--	}
--	self:GetChildren(self.nodes)
--	self:AddEvent()
--end
--
--function TreeOneMenu:AddEvent()
--end
--
function AchieveOneMenu:SetData(data, index, sub_data, select_sub_id, oneLvMenuSpan, twoLvMenuSpan)
    AchieveOneMenu.super.SetData(self,data, index, sub_data, select_sub_id, oneLvMenuSpan, twoLvMenuSpan)
    if table.isempty(sub_data) then
        SetVisible(self.arror,false)
    end
end

function AchieveOneMenu:SelectedItem(index)
    if self.index == 1 and self.selected then
        return
    end
    if self.selected then
        SetLocalRotation(self.arror,0,0,180)
    else
        SetLocalRotation(self.arror,0,0,0)
    end
    AchieveOneMenu.super.SelectedItem(self,index)
    --dump(self.menuitem_list)
    --print2(#self.menuitem_list)

end

function AchieveOneMenu:SetRedDot(isShow)
    self.redPoint:SetRedDotParam(isShow)
end

