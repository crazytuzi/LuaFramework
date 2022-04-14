BabyFoldMenu = BabyFoldMenu or class("AchieveFoldMenu", BaseTreeMenu)
local this = BabyFoldMenu

function BabyFoldMenu:ctor(parent_node, layer, parent_cls, oneLvMenuCls, twoLvMenuCl, isStickItemWhenClick)
    self.abName = "system"
    self.assetName = "BabyFoldMenu"
    self.layer = layer
    --self.parent_cls_name = parent_cls and parent_cls.__cname or ""
    self.oneLvMenuCls = BabyMenuItem
    self.isStickItemWhenClick = isStickItemWhenClick or true
    --self.globalEvents = {}
    --self.leftmenu_list = {}
    --self.leftHeight = 0
    --self.select_sub_id = -1
    --self.model = 2222222222222end:GetInstance()
    self.model = BabyModel:GetInstance()
    BabyFoldMenu.super.Load(self)
end

function BabyFoldMenu:dctor()

end

function BabyFoldMenu:UpdateRedPoint()
    --for id, v in pairs(self.model.babyOrderRedPoints) do
    --    local key = tostring(id).."@".."0"
    --    local cfg = Config.db_baby_order[key]
    --    if cfg.gender ==  then
    --
    --    end
    --end
    --
    --
    --dump(self.leftmenu_list)
    for i = 1, #self.leftmenu_list do
        self.leftmenu_list[i]:SetRedPoint()
        for j = 1, #self.leftmenu_list[i].menuitem_list do
            self.leftmenu_list[i].menuitem_list[j]:SetRedPoint()
        end
    end
end

--function BabyFoldMenu:CheckAchieveRedPoint()
--
--    for i = 1, #self.sub_data do
--        --if i == 1 then
--        --    local isRed = AchieveModel:GetInstance():CheckRedPoint(1,i)
--        --    self.leftmenu_list[i]:SetRedDot(isRed)
--        --end
--        for j = 1, #self.sub_data[i] do
--            local isRed = AchieveModel:GetInstance():CheckRedPoint(i,j)
--            --self.leftmenu_list[i]:SetRedDot(isRed)
--            self.leftmenu_list[i].sub_data[j].isRed = isRed
--        end
--        local isRed = AchieveModel:GetInstance():CheckRedPointByGroup(i)
--        self.leftmenu_list[i]:SetRedDot(isRed)
--    end
--
--end