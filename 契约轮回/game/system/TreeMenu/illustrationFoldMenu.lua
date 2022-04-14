illustrationFoldMenu = illustrationFoldMenu or class("illustrationFoldMenu", BaseTreeMenu)
local this = illustrationFoldMenu

function illustrationFoldMenu:ctor(parent_node, layer, parent_cls, oneLvMenuCls, twoLvMenuCl, isStickItemWhenClick)
    self.abName = "system"
    self.assetName = "illustrationFoldMenu"
    
    self.oneLvMenuCls = illustrationOneMenu
    self.isStickItemWhenClick = isStickItemWhenClick or true
    
    illustrationFoldMenu.super.Load(self)
end


function illustrationFoldMenu:SetDefaultSelected(first, second)

    --需要先设置为false 否则会出问题
    self.leftmenu_list[first].selected = false

    illustrationFoldMenu.super.SetDefaultSelected(self,first,second)
end

--红点检查
function illustrationFoldMenu:CheckReddot()

    for i = 1, #self.sub_data do
     
        for j = 1, #self.sub_data[i] do
            local isRed = illustrationModel.GetInstance():CheckReddotBySecondMenu(i,j)

            self.leftmenu_list[i].sub_data[j].isRed = isRed

            if self.leftmenu_list[i].menuitem_list[j] and table.nums(self.leftmenu_list[i].menuitem_list[j]) > 0 then
                self.leftmenu_list[i].menuitem_list[j]:SetRedDot(isRed)
            end
            
        end

        local isRed = illustrationModel.GetInstance():CheckReddotByFirstMenu(i)
        self.leftmenu_list[i]:SetRedDot(isRed)
    end

end

