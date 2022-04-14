--
-- @Author: chk
-- @Date:   2018-11-29 17:20:25
--
TreeTwoMenu = TreeTwoMenu or class("TreeTwoMenu",BaseTreeTwoMenu)
local TreenTwoMenu = TreeTwoMenu

function TreenTwoMenu:ctor(parent_node,layer,first_menu_item)
	self.abName = "system"
	self.assetName = "TreeTwoMenu"
	--self.layer = layer

	--self.layer = layer
	--self.first_menu_item = first_menu_item
	--self.parent_cls_name = self.first_menu_item.parent_cls_name
	--self.model = 2222222222222end:GetInstance()
	TreeTwoMenu.super.Load(self)
end

function TreeTwoMenu:dctor()
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
