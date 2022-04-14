--
-- @Author: chk
-- @Date:   2018-11-29 17:17:38
--
RankTreeMenu = RankTreeMenu or class("RankTreeMenu", BaseTreeMenu)
local RankTreeMenu = RankTreeMenu

function RankTreeMenu:ctor(parent_node, layer, parent_cls, oneLvMenuCls, twoLvMenuCls, isStickItemWhenClick)
    self.abName = "system"
    self.assetName = "RankTreeMenu"
    self.layer = layer
    --self.parent_cls_name = parent_cls and parent_cls.__cname or ""
    self.oneLvMenuCls = RankOneMenu
    if isStickItemWhenClick == true or isStickItemWhenClick == nil then
        self.isStickItemWhenClick = true
    else
        self.isStickItemWhenClick = false
    end

    -- self.model = 2222222222222end:GetInstance()
    RankTreeMenu.super.Load(self)
end

function RankTreeMenu:dctor()

end

function RankTreeMenu:UpdateView()
    RankTreeMenu.super.UpdateView(self)
    local rectTra = self.transform:GetComponent('RectTransform')
    rectTra.anchoredPosition = Vector2(0, 0)
end

