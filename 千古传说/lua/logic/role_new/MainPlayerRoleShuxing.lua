--[[
******角色详情*******
    -- by king
    -- 2015/4/17
]]

local ClimbRoleShuxing = class("ClimbRoleShuxing", BaseLayer)

local guild_practice_order = require("lua.table.t_s_guild_practice_order")

function ClimbRoleShuxing:ctor(data)
    self.super.ctor(self,data)

    self:init("lua.uiconfig_mango_new.climb.qimendunxiangxi")
end


function ClimbRoleShuxing:onShow()
    self.super.onShow(self)
      
    self:refreshBaseUI();
    self:refreshUI();

end


function ClimbRoleShuxing:refreshBaseUI()

end

function ClimbRoleShuxing:refreshUI()

    if self.roleGmid and self.type == "self" then
        self.cardRole  = CardRoleManager:getRoleByGmid(self.roleGmid)
    end

    print("self.txt_arr_base = ", self.txt_arr_base)
    print("self.txt_arr_add = ", self.txt_arr_add)

    print(":getQimenAttrDetail() = ", self.cardRole:getQimenAttrDetail())
    
    -- getQimenAttrDetail()

    -- self.txt_des:setText(self.cardRole.describe1)
    -- self.type = "self"
    --角色属性
    for index,txt_arr in pairs(self.txt_arr_base) do
        local arrStr = 0;
        if self.type == "self" then
            arrStr = self.cardRole:getQimengetTotalAttribute(index)
        else
            arrStr = self.cardRole.totalAttribute[index]
        end

        arrStr = arrStr or 0

        txt_arr:setText(arrStr)
    end

    -- for index,txt_arr in pairs(self.txt_arr_add) do
    --     txt_arr:setVisible(false)
    -- end

    self.txt_percent = {}
    self.txt_arr = {}
    local panel = TFDirector:getChildByPath(self.ui, "panel_xiangxi2")
    for i=EnumAttributeType.Crit, EnumAttributeType.Miss do
        local node = TFDirector:getChildByPath(panel, "panel_shuxing" .. i)
        if  node then
            self.txt_arr[i]     = TFDirector:getChildByPath(node, "txt_base")
            -- self.txt_percent[i] = TFDirector:getChildByPath(node, "txt_percent")

            local txt_name = TFDirector:getChildByPath(node, "txt_name")
            if txt_name then
                txt_name:setText(AttributeTypeStr[i])
            end
        end
    end

    --角色属性
    for index,txt_a in pairs(self.txt_arr) do
        local arrStr = self.cardRole:getQimengetTotalAttribute(index)
        if txt_a then
            arrStr = arrStr or 0
            txt_a:setText(covertToDisplayValue(index,arrStr))
        end
    end

    -- for index,txt_b in pairs(self.txt_percent) do
    --     local newIndex = index
    --     if index == EnumAttributeType.Crit then
    --         newIndex = index + 4
    --     elseif index == EnumAttributeType.Preciseness then
    --         newIndex = index + 3
    --     end

    --     local arrStr = self.cardRole:getQimengetTotalAttribute(newIndex)
    --     if txt_b then
    --         local percent = arrStr or 0

    --         txt_b:setVisible(false)
    --         if percent > 0 then
    --             txt_b:setVisible(true)
    --             -- covertToDisplayValue(newIndex, percent)
    --             local percentValue = string.format("%.2f", percent / 100) .. '%'
    --             txt_b:setText("+"..percentValue)
    --         end
    --     end
    -- end
    self.txt_arr = {}
    local panel = TFDirector:getChildByPath(self.ui, "panel_tdsx")
    local attributeList = {1,2,3,4,5,14}
    for k,v in ipairs(attributeList) do
        local node = TFDirector:getChildByPath(panel, "panel_shuxing" .. v)
        if  node then
            self.txt_arr[v]     = TFDirector:getChildByPath(node, "txt_base")
            -- self.txt_percent[i] = TFDirector:getChildByPath(node, "txt_percent")
            local txt_name = TFDirector:getChildByPath(node, "txt_name")
            if txt_name then
                txt_name:setText(AttributeTypeStr[v])
            end
        end
    end

    --角色属性
    for index,txt_a in pairs(self.txt_arr) do
        local arrStr = self.cardRole:getQimenTeamgetTotalAttribute(index)
        if txt_a then
            arrStr = arrStr or 0
            txt_a:setText(covertToDisplayValue(index,arrStr))
        end
    end
end

function ClimbRoleShuxing:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_close  = TFDirector:getChildByPath(ui, 'btn_close')
    self.panel_content  = TFDirector:getChildByPath(ui, 'pan_content')
    self.txt_des     = TFDirector:getChildByPath(ui, 'txt_wenben')

    -- 基本属性
    local panel_arr = TFDirector:getChildByPath(ui, "panel_xiangxi")
    self.txt_arr_base = {}
    self.txt_arr_base[EnumAttributeType.Blood]   =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_qixue"),"txt_base")
    self.txt_arr_base[EnumAttributeType.Force]   =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_wuli"),"txt_base")
    self.txt_arr_base[EnumAttributeType.Defence] =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_fangyu"),"txt_base")
    self.txt_arr_base[EnumAttributeType.Magic]   =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_neili"),"txt_base")
    self.txt_arr_base[EnumAttributeType.Agility] =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_shenfa"),"txt_base")


    -- self.txt_arr_base[EnumAttributeType.Agility]:enableShadow(CCSizeMake(10, 10),0,0);

    -- local panel_arr = TFDirector:getChildByPath(ui, "panel_xiangxi2")
    -- self.txt_arr_add = {}
    -- self.txt_arr_add[EnumAttributeType.Blood]   =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_qixue"),"txt_base")
    -- self.txt_arr_add[EnumAttributeType.Force]   =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_wuli"),"txt_base")
    -- self.txt_arr_add[EnumAttributeType.Defence] =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_fangyu"),"txt_base")
    -- self.txt_arr_add[EnumAttributeType.Magic]   =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_neili"),"txt_base")
    -- self.txt_arr_add[EnumAttributeType.Agility] =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_shenfa"),"txt_base")


    -- for i=EnumAttributeType.Crit, EnumAttributeType.Miss do
    --     local node = TFDirector:getChildByPath(ui, "panel_shuxing" .. i)
    --     if  node then
    --         local percentNode = TFDirector:getChildByPath(node, "txt_percent")
    --         print("percentNode = ", percentNode)
    --         if percentNode then
    --             local posX = percentNode:getPositionX()

    --             percentNode:setPositionX(posX + 20)
    --         end
    --     end
    -- end
end



function ClimbRoleShuxing:registerEvents(ui)
    self.super.registerEvents(self)

    self.btn_close:addMEListener(TFWIDGET_CLICK,function()
        AlertManager:close()
    end)
end


function ClimbRoleShuxing:removeEvents()
    self.super.removeEvents(self);
end




function ClimbRoleShuxing.BtnClickHandle(sender)
    local self  = sender.logic

end

function ClimbRoleShuxing:setCardRole(cardRole)
    self.cardRole = cardRole

    if cardRole then
        self.roleGmid = cardRole.gmId
    end

    self.type = "self"
end

return ClimbRoleShuxing
