illustrationTwoMenu = illustrationTwoMenu or class("illustrationTwoMenu",BaseTreeTwoMenu)
local illustrationTwoMenu = illustrationTwoMenu

function illustrationTwoMenu:ctor(parent_node,layer,first_menu_item)
    self.abName = "system"
    self.assetName = "illustrationTwoMenu"

    self.index = 1

    self.red_dot = nil

    illustrationTwoMenu.super.Load(self)
end

function illustrationTwoMenu:dctor()
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

function illustrationTwoMenu:LoadCallBack()
    self.nodes = {

    }
    self:GetChildren(self.nodes)
    illustrationTwoMenu.super.LoadCallBack(self)

end



function illustrationTwoMenu:SetData(first_menu_id,data, select_sub_id,menuSpan, index)
    illustrationTwoMenu.super.SetData(self,first_menu_id,data, select_sub_id,menuSpan)
    self.group = first_menu_id
    self.page = data[1]
    self.index = index
    
    if self.data.isRed ~= nil then
        self:SetRedDot(self.data.isRed)
    end
end

--重写父类show panel 进行红点显示
function illustrationTwoMenu:ShowPanel( )
    illustrationTwoMenu.super.ShowPanel(self)
    if self.data and self.data.isRed ~= nil then
        self:SetRedDot(self.data.isRed)
    end
end

function illustrationTwoMenu:SetRedDot(is_show)
    if not is_show and not self.red_dot then
        return
    end

    self.red_dot = self.red_dot or RedDot(self.transform)
    self.red_dot:SetRedDotParam(is_show)
    SetLocalPositionZ(self.red_dot.transform,0)
    SetAnchoredPosition(self.red_dot.transform,105,21)
end



