--[[
******角色详情*******
    -- by king
    -- 2015/4/17
]]

local RoleInfoLayer_sx = class("RoleInfoLayer_sx", BaseLayer)

local guild_practice_order = require("lua.table.t_s_guild_practice_order")

function RoleInfoLayer_sx:ctor(data)
    self.super.ctor(self,data)
    self.fightType = EnumFightStrategyType.StrategyType_PVE
    self:init("lua.uiconfig_mango_new.role_new.RoleInfoLayer_sx")
end


function RoleInfoLayer_sx:onShow()
    self.super.onShow(self)
      
    self:refreshBaseUI();
    self:refreshUI();

    if self.ScrollView_sx then
        self.ScrollView_sx:scrollToTop()
    end
end


function RoleInfoLayer_sx:refreshBaseUI()

end

function RoleInfoLayer_sx:refreshUI()

    if self.roleGmid and self.type == "self" then
        self.cardRole  = CardRoleManager:getRoleByGmid(self.roleGmid)
    end

    self.txt_des:setText(self.cardRole.describe1)
    -- self.type = "self"
    --角色属性
    for index,txt_arr in pairs(self.txt_arr_base) do
        local arrStr = 0;
        if self.type == "self" then
            arrStr = self.cardRole:getTotalAttributeByFightType(self.fightType,index)
        else
            arrStr = self.cardRole.totalAttribute[index]
        end
        txt_arr:setText(arrStr)
    end

    for index,txt_arr in pairs(self.txt_arr_add) do
        txt_arr:setVisible(false)
    end

    self.txt_percent = {}
    self.txt_arr = {}

    for i=EnumAttributeType.Crit, EnumAttributeType.Miss do
        local node = TFDirector:getChildByPath(self, "panel_shuxing" .. i)
        if  node then

            self.txt_arr[i]     = TFDirector:getChildByPath(node, "txt_shuxingzhi")
            self.txt_percent[i] = TFDirector:getChildByPath(node, "txt_percent")

        end
    end

    --角色属性
    for index,txt_a in pairs(self.txt_arr) do
        -- local arrStr = self.cardRole:getTotalAttributeByFightType(self.fightType,index)
        if self.type == "self" then
            arrStr = self.cardRole:getTotalAttributeByFightType(self.fightType,index)
        else
            arrStr = self.cardRole.totalAttribute[index]
        end

        if txt_a then
            txt_a:setText(covertToDisplayValue(index,arrStr))
        end
    end

    for index,txt_b in pairs(self.txt_percent) do
        local newIndex = index
        if index == EnumAttributeType.Crit then
            newIndex = index + 4
        elseif index == EnumAttributeType.Preciseness then
            newIndex = index + 3
        end

        -- local arrStr = self.cardRole:getTotalAttributeByFightType(self.fightType,newIndex)
        if self.type == "self" then
            arrStr = self.cardRole:getTotalAttributeByFightType(self.fightType,newIndex)
        else
            arrStr = self.cardRole.totalAttribute[newIndex]
        end

        if txt_b then
            local percent = arrStr or 0

            txt_b:setVisible(false)
            if percent > 0 then
                txt_b:setVisible(true)
                -- covertToDisplayValue(newIndex, percent)
                local percentValue = string.format("%.2f", percent / 100) .. '%'
                txt_b:setText("+"..percentValue)
            end
        end
    end

    local count = 1
    for i=16, 23 do

        local node       = TFDirector:getChildByPath(self, "panel_shuxing" .. i)
        local guildAttar = guild_practice_order:getObjectAt(count)
        if count > 6 then
            guildAttar = nil
        end
        if  node and guildAttar then
            local index = i
            local inheritanceType = guildAttar.type
            local inheritanceName = guildAttar.title

            local attrName  = TFDirector:getChildByPath(node, "txt_name")
            local attrValue = TFDirector:getChildByPath(node, "txt_percent")


            -- local inheritanceLevel = self.cardRole:getFactionPracticeLevelByType(inheritanceType)
            -- local PracticeData = GuildPracticeData:getPracticeInfoByTypeAndLevel( inheritanceType, inheritanceLevel )

            -- attrName:setText(inheritanceName)
            -- if PracticeData ~= nil then
            --     PracticeData = PracticeData:getAttributeValue()
            --     if  PracticeData.percent == true then
            --         local percentValue = math.floor(PracticeData.value / 100)
            --         percentValue = math.abs(percentValue)

            --         attrValue:setText(percentValue.."%")
            --     else
            --         local percentValue = math.abs(PracticeData.value)
            --         attrValue:setText(percentValue)
            --     end
            -- else
            --     attrValue:setText(0)
            -- end

            attrName:setText(inheritanceName)

            if self.type == "self" then
                local inheritanceLevel = self.cardRole:getFactionPracticeLevelByType(inheritanceType)
                local PracticeData = GuildPracticeData:getPracticeInfoByTypeAndLevel( inheritanceType, inheritanceLevel,self.cardRole.outline )

                attrName:setText(inheritanceName)
                if PracticeData ~= nil then
                    PracticeData = PracticeData:getAttributeValue()
                    if  PracticeData.percent == true then
                        local percentValue = math.floor(PracticeData.value / 100)
                        percentValue = math.abs(percentValue)

                        attrValue:setText(percentValue.."%")
                    else
                        local percentValue = math.abs(PracticeData.value)
                        attrValue:setText(percentValue)
                    end
                else
                    attrValue:setText(0)
                end

            else
                local newIndex = count + 40 - 1
                local attrValueExt = 0
                if self.cardRole.effectActive then 
                    attrValueExt = self.cardRole.effectActive[newIndex]
                end

                if count > 3 then
                    newIndex = newIndex - 3
                    -- attrValueExt = self.cardRole.effectPassive[newIndex]
                    if self.cardRole.effectPassive then 
                        attrValueExt = self.cardRole.effectPassive[newIndex]
                    end
                end

                attrValueExt = math.abs(attrValueExt)
                local percentValue = math.floor(attrValueExt / 100)
                attrValue:setText(percentValue.."%")
            end


        end

        if  node and guildAttar == nil then
            node:setVisible(false)
        end

        count = count + 1 
    end
end

function RoleInfoLayer_sx:initUI(ui)
	self.super.initUI(self,ui)

    self.panel_content  = TFDirector:getChildByPath(ui, 'pan_content')
    self.txt_des     = TFDirector:getChildByPath(ui, 'txt_wenben')

    -- 基本属性
    local panel_arr = TFDirector:getChildByPath(ui, "panel_jingmaixiangqing")
    self.txt_arr_base = {}
    self.txt_arr_base[EnumAttributeType.Blood]   =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_qixue"),"txt_base")
    self.txt_arr_base[EnumAttributeType.Force]   =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_wuli"),"txt_base")
    self.txt_arr_base[EnumAttributeType.Defence] =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_fangyu"),"txt_base")
    self.txt_arr_base[EnumAttributeType.Magic]   =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_neili"),"txt_base")
    self.txt_arr_base[EnumAttributeType.Agility] =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_shenfa"),"txt_base")


    -- self.txt_arr_base[EnumAttributeType.Agility]:enableShadow(CCSizeMake(10, 10),0,0);

    self.txt_arr_add = {}
    self.txt_arr_add[EnumAttributeType.Blood]   =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_qixue"),"txt_add")
    self.txt_arr_add[EnumAttributeType.Force]   =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_wuli"),"txt_add")
    self.txt_arr_add[EnumAttributeType.Defence] =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_fangyu"),"txt_add")
    self.txt_arr_add[EnumAttributeType.Magic]   =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_neili"),"txt_add")
    self.txt_arr_add[EnumAttributeType.Agility] =  TFDirector:getChildByPath(TFDirector:getChildByPath(panel_arr, "img_shenfa"),"txt_add")


    for i=EnumAttributeType.Crit, EnumAttributeType.Miss do
        local node = TFDirector:getChildByPath(ui, "panel_shuxing" .. i)
        if  node then
            local percentNode = TFDirector:getChildByPath(node, "txt_percent")
            print("percentNode = ", percentNode)
            if percentNode then
                local posX = percentNode:getPositionX()

                percentNode:setPositionX(posX + 20)
            end
        end
    end


    self.ScrollView_sx = TFDirector:getChildByPath(ui, "ScrollView_sx")
end



function RoleInfoLayer_sx:registerEvents(ui)
    self.super.registerEvents(self)


end


function RoleInfoLayer_sx:removeEvents()
    self.super.removeEvents(self);
end


function RoleInfoLayer_sx.onCloseClickHandle(sender)
    local self = sender.logic;

    if (self.img_select) then
        self:removeSelectIcon();
        self:closeEquipListLayer();
       return;
    end 
    AlertManager:close(AlertManager.TWEEN_1);
end


function RoleInfoLayer_sx.BtnClickHandle(sender)
    local self  = sender.logic

end

function RoleInfoLayer_sx:setCardRole(cardRole)
    self.cardRole = cardRole

    if cardRole then
        self.roleGmid = cardRole.gmId
    end
end

return RoleInfoLayer_sx
