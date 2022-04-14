RankTwoMenu = RankTwoMenu or class("RankTwoMenu",BaseTreeTwoMenu)
local RankTwoMenu = RankTwoMenu

function RankTwoMenu:ctor(parent_node,layer,first_menu_item)
    self.abName = "system"
    self.assetName = "RankTwoMenu"
    --self.layer = layer

    --self.layer = layer
    --self.first_menu_item = first_menu_item
    --self.parent_cls_name = self.first_menu_item.parent_cls_name
    --self.model = 2222222222222end:GetInstance()
    RankTwoMenu.super.Load(self)
end

function RankTwoMenu:dctor()
end

--function TreeTwoMenu:LoadCallBack()
--	self.nodes = {
--		"",
--	}
--	self:GetChildren(self.nodes)
--	self:AddEvent()
--end
--
--function TreeTwoMenu:AddEvent()
--end
--
--function TreeTwoMenu:SetData(data)
--
--end
