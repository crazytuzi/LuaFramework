--
-- @Author: chk
-- @Date:   2018-11-29 17:17:38
--
TreeMenu = TreeMenu or class("TreeMenu", BaseTreeMenu)
local TreeMenu = TreeMenu

--is_go_bottom              点击二级菜单的时候，是否沉底（默认关闭）
--isStickItemWhenClick      点击一级菜单的时候，是否置顶（默认开启）
--!!!以上两者，不可同时激活
function TreeMenu:ctor(parent_node, layer, parent_cls, oneLvMenuCls, twoLvMenuCls, isStickItemWhenClick, is_go_bottom)
    self.abName = "system"
    self.assetName = "TreeMenu"
    self.layer = layer
    --self.parent_cls_name = parent_cls and parent_cls.__cname or ""
    if isStickItemWhenClick == true or isStickItemWhenClick == nil then
        self.isStickItemWhenClick = true
    else
        self.isStickItemWhenClick = false
    end

    if is_go_bottom then
        self.is_go_bottom = true
    end

    -- self.model = 2222222222222end:GetInstance()
    TreeMenu.super.Load(self)
end

function TreeMenu:dctor()

end

function TreeMenu:UpdateView()
    TreeMenu.super.UpdateView(self)
    local rectTra = self.transform:GetComponent('RectTransform')
    rectTra.anchoredPosition = Vector2(0, 0)
end


--function TreeMenu:dctor()
--end
--
--function TreeMenu:LoadCallBack()
--	self.nodes = {
--		"",
--	}
--	self:GetChildren(self.nodes)
--	self:AddEvent()
--end
--
--function TreeMenu:AddEvent()
--end
--
--function TreeMenu:SetData(data)
--
--end