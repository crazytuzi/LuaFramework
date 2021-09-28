local SystemGoodsPopWindowsLayer = class("SystemGoodsPopWindowsLayer", UFCCSNormalLayer)

--[[
    holiday 圣诞活动
]]
function SystemGoodsPopWindowsLayer:ctor(json,_list, func, tips01,tips02,quality,holiday,...)
    self.super.ctor(self,...)
    self:adapterWithScreen()
    self:_initGoods(_list)
    self._tips01Label = self:getLabelByName("Label_title")
    self._tips02Label = self:getLabelByName("Label_name")
    if tips01 ~= nil then
        self._tips01Label:setText(tips01)
    else
        self._tips01Label:setText(G_lang:get("LANG_SYSTEM_GOODS"))
    end

    if tips02 ~= nil and type(quality) == "number" then
        self._tips02Label:setText(tips02)
        self._tips02Label:setColor(Colors.qualityColors[quality])
    end
    self:getImageViewByName("ImageView_762"):setPosition(ccp(display.cx, display.cy))
    local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

       EffectSingleMoving.run(self:getImageViewByName("ImageView_762"), "smoving_droptip", function(event) 
            if event == "finish" then 
                if func then
                    if type(func) == "function" then
                        func()
                    else
                        __Log("----------SystemGoodsPopWindowsLayer:ctor: func param not valid")
                    end
                end

                self:close()
            end 
        end)
    if holiday then
        --切换成holiday版助手
        self:getImageViewByName("Image_23"):loadTexture("ui/activity/xiaozhushou_shengdan.png")
    else
        GlobalFunc.replaceForAppVersion(self:getImageViewByName("Image_23"))
    -- elseif (G_Setting:get("appstore_version") == "1") then
    --     self:getImageViewByName("Image_23"):loadTexture("ui/arena/xiaozhushou_hexie.png")
    end
end

function SystemGoodsPopWindowsLayer:_initGoods(_list)
    local firstIndex = 1
    if _list ~= nil then
        if #_list == 1 or #_list == 2 then
            firstIndex = 2 
        end
    end
    for i=firstIndex,firstIndex+#_list do
        if _list[i-firstIndex+1] then
            local _data = G_Goods.convert(_list[i-firstIndex+1].type,_list[i-firstIndex+1].value)
            local _name = self:getLabelByName("bounsname" .. i)
            if _data and _name then
                _name:setText(_data.name)
                _name:setColor(Colors.getColor(_data.quality))
                _name:createStroke(Colors.strokeBrown,1)

                self:getImageViewByName("bouns" .. i):loadTexture(_data.icon)

                local _ico = self:getImageViewByName("ico" .. i)
                _ico:loadTexture(G_Path.getEquipColorImage(_data.quality,_data.type))

                 local _numLabel = self:getLabelByName("bounsnum" .. i)
                 _numLabel:setText("x" .. G_GlobalFunc.ConvertNumToCharacter3(_list[i-firstIndex+1].size))
                 _numLabel:createStroke(Colors.strokeBrown,1)
                 local bg = self:getImageViewByName("ImageView_bouns" .. i)
                 bg:loadTexture(G_Path.getEquipIconBack(_data.quality))
                 bg:setVisible(true)
           end
        end
    end
end


--[[
    tips01:恭喜主公xxx获得xxx
    tips02:xxx道具name
    tips02Color:道具品质颜色

]]
function SystemGoodsPopWindowsLayer.create(bounslist, func,tips01,tips02,quality,...)
    return SystemGoodsPopWindowsLayer.new("ui_layout/common_SystemGoodsPopWindowsLayer.json",bounslist, func,tips01,tips02,quality,...)
end

function SystemGoodsPopWindowsLayer.createForHoliday(bounslist, _,_,_,_,_,...)
    return SystemGoodsPopWindowsLayer.new("ui_layout/common_SystemGoodsPopWindowsLayer.json",bounslist, func,tips01,tips02,quality,true,...)
end

function SystemGoodsPopWindowsLayer:_closeWindow()
    self:close()
end

function SystemGoodsPopWindowsLayer:onLayerEnter(...)
    
    --panel:runAction(CCScaleTo:create(0.1,1))
    -- local appstoreVersion = (G_Setting:get("appstore_version") == "1")
    -- if appstoreVersion or IS_HEXIE_VERSION  then 
    --     local img = self:getImageViewByName("Image_23")
    --     if img then
    --         img:loadTexture("ui/arena/xiaozhushou_hexie.png")
    --     end
    -- end
    GlobalFunc.replaceForAppVersion(self:getImageViewByName("Image_23"))
end

return SystemGoodsPopWindowsLayer

