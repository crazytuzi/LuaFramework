BabyMenuItem = BabyMenuItem or class("BabyMenuItem",BaseTreeOneMenu)
local BabyMenuItem = BabyMenuItem

function BabyMenuItem:ctor(parent_node,layer,parent_cls_name,twoLvMenuCls)
    self.abName = "system"
    self.assetName = "BabyMenuItem"
    self.layer = layer
    --self.model = 2222222222222end:GetInstance()

    --self.twoLvMenuCls = BabyMenuSubItem
    --self.parent_cls_name = self.first_menu_item.parent_cls_name
    BabyMenuItem.super.Load(self)
end

function BabyMenuItem:dctor()
    if self.redPoint then
        self.redPoint:destroy()
    end
    self.redPoint = nil
end


function BabyMenuItem:LoadCallBack()
    self.nodes = {
        "redParent"
    }
    self:GetChildren(self.nodes)
    AchieveOneMenu.super.LoadCallBack(self)
    self.redPoint = RedDot(self.redParent, nil, RedDot.RedDotType.Nor)
    self.redPoint:SetPosition(0, 0)
end

function BabyMenuItem:SetRedPoint()
    local gender = self.data[1]
    local redPoints = BabyModel:GetInstance().babyOrderRedPoints
    local isRed = false
    for id, reds in pairs(redPoints) do
        local key = tostring(id).."@".."0"
        local cfg = Config.db_baby_order[key]
        if cfg.gender == gender and BabyModel:GetInstance().curType == cfg.type_id then
            for i, v in pairs(reds) do
                if v == true then
                    isRed = true
                    break
                end
            end
        end
    end
    self.redPoint:SetRedDotParam(isRed)
    --self.redPoint:SetRedDotParam()
end

--function BabyMenuItem:LoadChildMenu()
--    local typeId = self.data[1]
--    for _, menuitem in pairs(self.menuitem_list) do
--        menuitem:destroy()
--    end
--    self.menuitem_list = {}
--    local subtypes = self.sub_data
--    local count = #subtypes
--    self.menuHeight = 0
--    for i=1, count do
--        local item = subtypes[i]
--        local menuitem = self.twoLvMenuCls(self.Content,nil,self)
--        menuitem:SetData(typeId,item, self.select_sub_id, nil, nil, i)
--        table.insert(self.menuitem_list, menuitem)
--        self.menuHeight = self.menuHeight + menuitem:GetHeight()
--    end
--    self.oldMenuHeight = self.menuHeight
--    self:ReLayout()
--end

--function BabyMenuItem:dctor()
--    --if self.redPoint then
--    --    self.redPoint:destroy()
--    --    self.redPoint = nil
--    --end
--end
--
--function TreeOneMenu:LoadCallBack()
--	self.nodes = {
--		"",
--	}
--	self:GetChildren(self.nodes)
--	self:AddEvent()
--end
--
--function BabyMenuItem:AddEvent()
--
--    BabyMenuItem.super.AddEvent(self)
--end


