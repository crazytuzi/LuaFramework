local SanguozhiAttrItem = class("SanguozhiAttrItem",function()
    return CCSItemCellBase:create("ui_layout/sanguozhi_SanguozhiAttrItem.json")
end)


function SanguozhiAttrItem:ctor()
    self._label01 = self:getLabelByName("Label_01")           
    self._label02 = self:getLabelByName("Label_02")  
    self._label01Tag = self:getLabelByName("Label_01Tag") 
    self._label02Tag = self:getLabelByName("Label_02Tag")    
    -- self._label01:createStroke(Colors.strokeBrown,1)
    -- self._label02:createStroke(Colors.strokeBrown,1)  
    -- self._label01Tag:createStroke(Colors.strokeBrown,1)  
    -- self._label02Tag:createStroke(Colors.strokeBrown,1)       
end

function SanguozhiAttrItem:updateCell(text01,text02)
    self._label01:setVisible(text01 ~= nil)
    self._label01Tag:setVisible(text01 ~= nil)
    
    self._label02:setVisible(text02 ~= nil)
    self._label02Tag:setVisible(text02 ~= nil)
    if(text01) then
        self._label01Tag:setText(text01.text)
        self._label01:setText("+" .. text01.value)
    end
    if(text02) then
        self._label02:setText("+" .. text02.value)
        self._label02Tag:setText(text02.text)
    end
end

return SanguozhiAttrItem

