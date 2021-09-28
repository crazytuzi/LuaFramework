local DressBookCellTwo = class("DressBookCellTwo",function()
    return CCSItemCellBase:create("ui_layout/dress_BookCell2.json")
end)
require("app.cfg.knight_info")
require("app.cfg.dress_info")
local KnightPic = require("app.scenes.common.KnightPic")
local MergeEquipment = require("app.data.MergeEquipment")
local EffectNode = require "app.common.effects.EffectNode"

function DressBookCellTwo:ctor()

        self:setTouchEnabled(true)
     
         self:registerWidgetClickEvent("Image_heroClick1", function()
                self:click(1)
         end) 

        self:registerWidgetClickEvent("Image_heroClick2", function()
                self:click(2)
        end) 
        
        if require("app.scenes.mainscene.SettingLayer").showEffectEnable() then
            self._effect1 = EffectNode.new("effect_szkpgy", 
                function(event, frameIndex)
                    if event == "finish" then
                 
                    end
                end
            )
            self._effect1:setPosition(ccp(0,0))
            self._effect1:play()
            self:getImageViewByName("Image_heroClick1"):addNode(self._effect1) 

            self._effect2 = EffectNode.new("effect_szkpgy", 
                function(event, frameIndex)
                    if event == "finish" then
                 
                    end
                end
            )
            self._effect2:setPosition(ccp(0,0))
            self._effect2:play()
            self:getImageViewByName("Image_heroClick2"):addNode(self._effect2) 
        end
end

function DressBookCellTwo:click(index)
    if not self._data then
        return
    end
    local dressid  = self._data["dress_"..index]
    local dressinfo = dress_info.get(dressid)
    if dressinfo then
        require("app.scenes.dress.DressInfo").showInfo(dressinfo,self._container )
    end
end

function DressBookCellTwo:updateData(data)
        self._data = data
        local name = self:getLabelByName("Label_title")
        name:createStroke(Colors.strokeBrown, 1)
        if data then
            self:initKnight(1,data.dress_1)
            self:initKnight(2,data.dress_2)
            name:setText(data.name)
        else
            self:initKnight(1,0)
            self:initKnight(2,0)
            name:setText("???")
        end
        self:updateAttrs(data)
end

function DressBookCellTwo:initKnight(index,baseid)
      if baseid ~= 0 then
            local dressData = dress_info.get(baseid)
            self:getImageViewByName("Image_namebg"..index):setVisible(true)
            local nametxt = self:getLabelByName("Label_name"..index)
            nametxt:setText(dressData.name)
            nametxt:setColor(Colors.qualityColors[dressData.quality])
            nametxt:createStroke(Colors.strokeBrown, 1)
            local future = self:getLabelByName("Label_future"..index)
            future:setVisible(false)
            self:getImageViewByName("Image_default"..index):setVisible(false)
            if dressData.common_skill_id > 0 then
                self:getImageViewByName("Image_skill_"..index.."_1"):setVisible(true)
            else
                self:getImageViewByName("Image_skill_"..index.."_1"):setVisible(false)
            end
            if dressData.active_skill_id_1 > 0 then
                self:getImageViewByName("Image_skill_"..index.."_2"):setVisible(true)
            else
                self:getImageViewByName("Image_skill_"..index.."_2"):setVisible(false)
            end
            if dressData.unite_skill_id > 0 then
                self:getImageViewByName("Image_skill_"..index.."_3"):setVisible(true)
            else
                self:getImageViewByName("Image_skill_"..index.."_3"):setVisible(false)
            end
            if dressData.super_unite_skill_id > 0 then
                self:getImageViewByName("Image_skill_"..index.."_4"):setVisible(true)
            else
                self:getImageViewByName("Image_skill_"..index.."_4"):setVisible(false)
            end
            self:getPanelByName("Panel_hero"..index):removeAllChildrenWithCleanup(true)
            local sex = G_Me.dressData:getCurSex()
            local resid = sex==1 and dressData.man_res_id or dressData.woman_res_id
            local knight = KnightPic.createKnightPic( resid, self:getPanelByName("Panel_hero"..index), "knightImg"..index,true )
            knight:setScale(0.7)
            local grayColor = ccc3(0xae, 0xae, 0xae) 
            if G_Me.dressData:hasDressId(baseid) then
                knight:showAsGray(false)
            else
                knight:showAsGray(true)
            end
            self:getPanelByName("Panel_heroArea"..index):setVisible(true)
      else
            local future = self:getLabelByName("Label_future"..index)
            future:setVisible(true)
            future:createStroke(Colors.strokeBrown, 1)
            self:getImageViewByName("Image_namebg"..index):setVisible(false)
            local defaultImg = self:getImageViewByName("Image_default"..index)
            defaultImg:setVisible(true)
            local sex = G_Me.dressData:getCurSex()
            defaultImg:loadTexture(sex==1 and "ui/dress/tujian_nan.png" or "ui/dress/tujian_nv.png")
            self:getImageViewByName("Image_skill_"..index.."_1"):setVisible(false)
            self:getImageViewByName("Image_skill_"..index.."_2"):setVisible(false)
            self:getImageViewByName("Image_skill_"..index.."_3"):setVisible(false)
            self:getImageViewByName("Image_skill_"..index.."_4"):setVisible(false)
            -- self:getPanelByName("Panel_hero"..index):removeAllChildrenWithCleanup(true)
            self:getPanelByName("Panel_heroArea"..index):setVisible(false)
      end
end

function DressBookCellTwo:getWidth()
      local width = self:getContentSize().width
      return width
end

function DressBookCellTwo:updateAttrs(data )
    local allLabel = self:getLabelByName("Label_showAll")
    allLabel:setText(G_lang:get("LANG_DRESS_ALLACTIVE"))
    allLabel:createStroke(Colors.strokeBrown, 1)
    if data then
        local count = 0
        -- local offset = {150,93,40}
        local posy = 25
        for i = 1,4 do 
            if data["attribute_value_"..i] == 0 then
                self:getLabelByName("Label_attrtype"..i):setVisible(false)
                self:getLabelByName("Label_attrvalue"..i):setVisible(false)
            else
                local attrtype,attrvalue,strtype,strvalue = MergeEquipment.convertAttrTypeAndValue(data["attribute_type_"..i], data["attribute_value_"..i])
                local label1 = self:getLabelByName("Label_attrtype"..i)
                local label2 = self:getLabelByName("Label_attrvalue"..i)
                label1:setVisible(true)
                label2:setVisible(true)
                if G_Me.dressData:hasDressId(data.dress_1) and G_Me.dressData:hasDressId(data.dress_2) then
                    label1:setColor(Colors.darkColors.ATTRIBUTE)
                    label2:setColor(Colors.darkColors.ATTRIBUTE)
                else
                    label1:setColor(Colors.darkColors.TIPS_02)
                    label2:setColor(Colors.darkColors.TIPS_02)
                end
                label1:setText(strtype)
                label1:createStroke(Colors.strokeBrown, 1)
                label2:setText("+"..strvalue)
                label2:createStroke(Colors.strokeBrown, 1)
                count = count + 1
            end
        end
        -- self:getPanelByName("Panel_attr"):setPosition(ccp(offset[count],posy))
        if G_Me.dressData:hasDressId(data.dress_1) and G_Me.dressData:hasDressId(data.dress_2) then
            -- allLabel:setColor(Colors.darkColors.ATTRIBUTE)
            self:getImageViewByName("Image_arrow"):showAsGray(false)
        else
            -- allLabel:setColor(Colors.darkColors.TIPS_02)
            self:getImageViewByName("Image_arrow"):showAsGray(true)
        end
    else
        for i = 1,4 do 
            local label1 = self:getLabelByName("Label_attrtype"..i)
            label1:setColor(Colors.darkColors.TIPS_02)
            label1:setText("???")
            label1:createStroke(Colors.strokeBrown, 1)
            local label2 = self:getLabelByName("Label_attrvalue"..i)
            label2:setColor(Colors.darkColors.TIPS_02)
            label2:setText("???")
            label2:createStroke(Colors.strokeBrown, 1)
        end
        self:getImageViewByName("Image_arrow"):showAsGray(true)
        -- allLabel:setColor(Colors.darkColors.TIPS_02)
    end
end

function DressBookCellTwo:onLayerUnload()
    
    uf_eventManager:removeListenerWithTarget(self)

end

return DressBookCellTwo
