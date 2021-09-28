local RoleAvatarFrameItem = class("RoleAvatarFrameItem",function()
    return CCSItemCellBase:create("ui_layout/common_RoleAvatarFrameItem.json")
end)

require("app.cfg.frame_info")

function RoleAvatarFrameItem:ctor()
    --复选框选中事件
    self._checkboxFunc = nil
    self._gotoGetFunc = nil

    self._frameType = 0
 
    self._nameLabel = self:getLabelByName("Label_name")
    self._nameLabel:setText("")

    self._itemFrame = self:getImageViewByName("Image_frame")

    self._descLabel = self:getLabelByName("Label_desc")
    self._descLabel:setText("")

    self._checkBox = self:getCheckBoxByName("CheckBox_selected")
    self._getButton = self:getButtonByName("Button_get")

    self._nameLabel:createStroke(Colors.strokeBrown,1)
    
    self:getPanelByName("Panel_root"):setVisible(false)
    
end

function RoleAvatarFrameItem:setCheckBoxState(state)
    if not state or type(state) ~= "boolean" then end

    self._checkBox:setSelectedState(state)

end

function RoleAvatarFrameItem:setSelectedHandler(widget, type, isCheck)
    local selected = self._checkBox:getSelectedState()
    if self._checkboxFunc then self._checkboxFunc(selected) end
end


function RoleAvatarFrameItem:updateItem(data, frameType)

    if not data or type(data) ~= "table" then return end

    self._frameType = frameType and 1

    self:getPanelByName("Panel_root"):setVisible(true)
  
    local frame = frame_info.get(data.id)

    if frame then
        self._itemFrame:loadTexture(G_Path.getAvatarFrame(frame.res_id))
        G_GlobalFunc.addHeadIcon(self._itemFrame,frame.vip_level)
    else
        self._itemFrame:setVisible(false)
    end

    self._nameLabel:setText(frame.name)
    self._descLabel:setText(frame.directions)

    self._checkBox:setSelectedState(data.id == G_Me.userData:getFrameId())
    self._checkBox:setVisible(G_Me.userData.vip >= frame.vip_level)
    self._getButton:setVisible(G_Me.userData.vip < frame.vip_level)

    self:registerCheckboxEvent("CheckBox_selected",handler(self, self.setSelectedHandler))

    self:registerWidgetClickEvent("ImageView_frame",function() 
        --TODO
        end)

    self:registerBtnClickEvent("Button_get",function() 
        --VIP
        if self._frameType == 1 then
            --先关掉PopRoleInfoLayer 和 RoleAvatarFrameListLayer
            if self._gotoGetFunc then self._gotoGetFunc() end

            require("app.scenes.shop.recharge.RechargeLayer").show()
        --特殊
        elseif self._frameType == 2 then
            --TODO
        end
    end)

end


function RoleAvatarFrameItem:setCheckBoxEvent(func)
    self._checkboxFunc = func
end

function RoleAvatarFrameItem:setGotoGetEvent(func)
    self._gotoGetFunc = func
end

return RoleAvatarFrameItem
