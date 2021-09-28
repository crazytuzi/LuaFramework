if device.platform == "mac" then
  function CreateEditBoxForMac(editParam, ccsTextFieldIns, uiNode)
    local pos = ccsTextFieldIns:convertToWorldSpace(ccp(0, 0))
    local s = ccsTextFieldIns:getContentSize()
    editParam.size = editParam.size or CCSize(s.width, s.height)
    editParam.x = editParam.x or pos.x
    editParam.y = editParam.y or pos.y
    editParam.image = editParam.image or "views/pic/pic_bginput.png"
    editParam.listener = editParam.listener or function()
    end
    local c = ccsTextFieldIns:getColor()
    local editbox = ui.newEditBox(editParam)
    editbox:setPlaceHolder(ccsTextFieldIns:getPlaceHolder())
    editbox:setFontColor(ccc3(c.r, c.g, c.b))
    editbox:setFontSize(ccsTextFieldIns:getFontSize())
    editbox:setMaxLength(ccsTextFieldIns:getMaxLength())
    uiNode:addNode(editbox, ccsTextFieldIns:getZOrder())
    if ccsTextFieldIns:isPasswordEnabled() then
      editbox:setInputMode(kEditBoxInputFlagPassword)
    end
    ccsTextFieldIns:setTouchEnabled(false)
    ccsTextFieldIns:setVisible(false)
    ccsTextFieldIns:setEnabled(false)
    function editbox:getStringValue()
      return editbox:getText()
    end
    function editbox:SetFieldText(txt)
      editbox:setText(txt)
    end
    function editbox:GetFieldText()
      return editbox:getText()
    end
    function editbox:CloseTheKeyBoard()
    end
    function editbox:ClearTextFieldExtend()
    end
    function editbox:SetnablePassWord()
    end
    function editbox:SetMaxInputLength()
    end
    return editbox
  end
end
