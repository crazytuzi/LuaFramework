--
-- @Author: chk
-- @Date:   2018-11-29 17:19:31
--
TreeOneMenu = TreeOneMenu or class("TreeOneMenu", BaseTreeOneMenu)
local TreeOneMenu = TreeOneMenu

function TreeOneMenu:ctor(parent_node, layer, parent_cls_name, twoLvMenuCls)
    self.abName = "system"
    self.assetName = "TreeOneMenu"
    self.layer = layer


    --self.model = 2222222222222end:GetInstance()
    TreeOneMenu.super.Load(self)
end

--function TreeOneMenu:dctor()
--end

function TreeOneMenu:LoadChildMenu()
    local typeId = self.data[1]
    for _, menuitem in pairs(self.menuitem_list) do
        menuitem:destroy()
    end
    self.menuitem_list = {}
    local subtypes = self.sub_data
    local count = #subtypes
    self.menuHeight = 0
    for i = 1, count do
        local item = subtypes[i]
        local menuitem = self.twoLvMenuCls(self.Content, nil, self)
        menuitem:SetData(typeId, item, self.select_sub_id)
        table.insert(self.menuitem_list, menuitem)
        self.menuHeight = self.menuHeight + menuitem:GetHeight()
    end
    self.oldMenuHeight = self.menuHeight
    self:ReLayout()
end

function TreeOneMenu:dctor()
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
--function TreeOneMenu:SetData(data)
--
--end
