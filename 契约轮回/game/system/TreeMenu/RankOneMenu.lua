RankOneMenu = RankOneMenu or class("RankOneMenu",BaseTreeOneMenu)
local RankOneMenu = RankOneMenu

function RankOneMenu:ctor(parent_node,layer,parent_cls_name,twoLvMenuCls)
    self.abName = "system"
    self.assetName = "RankOneMenu"
    self.layer = layer


    --self.model = 2222222222222end:GetInstance()
    RankOneMenu.super.Load(self)
end

--function TreeOneMenu:dctor()
--end

function RankOneMenu:LoadChildMenu()
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
        menuitem:SetData(typeId,item, self.select_sub_id)
        table.insert(self.menuitem_list, menuitem)
        self.menuHeight = self.menuHeight + menuitem:GetHeight()
    end
    self.oldMenuHeight = self.menuHeight
    self:ReLayout()
end

function RankOneMenu:dctor()
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
