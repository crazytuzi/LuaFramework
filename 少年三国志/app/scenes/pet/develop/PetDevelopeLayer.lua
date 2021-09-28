
local PetDevelopeLayer = class("PetDevelopeLayer",UFCCSNormalLayer)
local EffectNode = require "app.common.effects.EffectNode"
local PetBagConst = require "app.const.PetBagConst"
local PetPic = require("app.scenes.common.PetPic")
local BagConst = require("app.const.BagConst")
require("app.cfg.pet_info")

function PetDevelopeLayer.create(...)
    return PetDevelopeLayer.new("ui_layout/petbag_DevelopMain.json", ...)
end

function PetDevelopeLayer:ctor(...)
    self.super.ctor(self,...)

    self._turnplateLayer = require("app.scenes.pet.develop.PetTurnplateLayer").new()
    local size = CCSizeMake(480,500)
    self._turnplateLayer:init(size,self)
    self._turnplateLayer:setPosition(ccp(80,0))
    self:getPanelByName("Panel_middle"):addNode(self._turnplateLayer)

    local bgImg = self:getImageViewByName("Image_bg")
    bgImg:setPosition(ccp(320,320))

    self._bottomPanel = self:getPanelByName("Panel_bottom")
    self._curLayer = nil
    self._layerHeight = self._bottomPanel:getContentSize().height
    self._fightLabel = self:getLabelByName("Label_fight")
    self._fightLabel:createStroke(Colors.strokeBrown, 2)

    self._lastFightValue = 0

    local effect = EffectNode.new("effect_shoulan_bg")
    bgImg:addNode(effect)
    effect:setScale(0.5)
    effect:play()

    self:registerBtnClickEvent("Button_back", function()
            self:onBack()

            -- local effect = EffectNode.new("effect_shoulan_shengji", function(event, frameIndex, _effect)
            --     if event == "finish" then
            --         _effect:removeFromParent()   
            --         if callback then
            --             callback("finish")
            --         end
            --     end
            -- end)
            -- self:getEffectNode():addNode(effect)
            -- effect:setPosition(ccp(15,178))
            -- effect:setScale(1.1)
            -- effect:play()
            -- self._starLayer:runEffect()
        end)
end

function PetDevelopeLayer:onLayerEnter( )
    uf_eventManager:addEventListener(G_EVENTMSGID.EVNET_BAG_HAS_CHANGED, self._onBagDataChanged, self)
end

function PetDevelopeLayer:_onBagDataChanged( changeType, buff )
   if BagConst.CHANGE_TYPE.PET == changeType then 
      self:updateFight()
   end
end

function PetDevelopeLayer:setPet(pet, developeType)
    self._petNode = display.newNode()
    self._turnplateLayer:setImg(self._petNode)

    self._pet = pet
    self:_updateCommonAttrs()

    developeType = developeType or PetBagConst.DevelopType.STRENGTH
    self:checkLayer(developeType)
    self._turnplateLayer:rollTo(developeType)
end

function PetDevelopeLayer:checkLayer(developeType)
    if developeType == PetBagConst.DevelopType.STRENGTH then
        self:onPetStrength()
    elseif developeType == PetBagConst.DevelopType.STAR then
        self:onPetStar()
    elseif developeType == PetBagConst.DevelopType.REFINE then  
        self:onPetRefine()
    end
end

function PetDevelopeLayer:onPetStrength(  )
    if not self._strengthLayer then
        self._strengthLayer = require("app.scenes.pet.develop.PetStrengthLayer"):create(self)
        self._strengthLayer:setContentSize(CCSize(640 ,self._layerHeight))
        if self._strengthLayer.adapterLayer then
            self._strengthLayer:adapterLayer()
        end
        self._bottomPanel:addNode(self._strengthLayer)
    end
    self:showLayer(self._strengthLayer)
end

function PetDevelopeLayer:onPetRefine(  )
    if not self._refineLayer then
        self._refineLayer = require("app.scenes.pet.develop.PetRefineLayer"):create(self)
        self._refineLayer:setContentSize(CCSize(640 ,self._layerHeight))
        if self._refineLayer.adapterLayer then
            self._refineLayer:adapterLayer()
        end
        self._bottomPanel:addNode(self._refineLayer)
    end
    self:showLayer(self._refineLayer)
end

function PetDevelopeLayer:onPetStar(  )
    if not self._starLayer then
        self._starLayer = require("app.scenes.pet.develop.PetStarLayer"):create(self)
        self._starLayer:setContentSize(CCSize(640 ,self._layerHeight))
        if self._starLayer.adapterLayer then
            self._starLayer:adapterLayer()
        end
        self._bottomPanel:addNode(self._starLayer)
    end
    self:showLayer(self._starLayer)
end

function PetDevelopeLayer:showLayer( layer )
    if self._curLayer then
        self._curLayer:setVisible(false)
    end
    layer:setVisible(true)
    self:_updateCommonAttrs()
    self._curLayer = layer
    if self._curLayer.enter then
        self._curLayer:enter()
    end
end

function PetDevelopeLayer:hideLayer()
    if self._curLayer then
        -- if self._curLayer.exit then
        --     local layer = self._curLayer
        --     layer:exit(function ( )
        --         layer:setVisible(false)
        --         if self._curLayer == layer then
        --             self._curLayer = nil
        --         end
        --     end)
        -- else
            if self._curLayer.exit then
                self._curLayer:exit()
            end
            --播你妹的特效
            self:getEffectNode():removeAllNodes()
            self._curLayer:setVisible(false)
            self._curLayer = nil
        -- end
    end
end

function PetDevelopeLayer:getPet()
    return self._pet  
end

function PetDevelopeLayer:onBack()
    if CCDirector:sharedDirector():getSceneCount() > 1 then 
                uf_sceneManager:popScene()
    else
        uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
    end
end

function PetDevelopeLayer:goList()
    uf_sceneManager:replaceScene(require("app.scenes.pet.bag.PetBagMainScene").new())
end

--播放特效的锚点容器
function PetDevelopeLayer:getEffectNode()
   return self:getPanelByName("Panel_effect")
end

function PetDevelopeLayer:addPetYing(state)
    local info = pet_info.get(self._pet.base_id)
    if state then
        if not self._petImg2 then
            local petPath2 = G_Path.getPetReadyGuangEffect(info.ready_id)
            self._petImg2 = EffectNode.new(petPath2)
            self._petImg2:setScale(0.65)
            self._petImg2:setPosition(ccp(0,25))
            self._petNode:addChild(self._petImg2)
            self._petImg2:play()
        end
   else
            self._petImg2:removeFromParentAndCleanup(true)
            self._petImg2 = nil
   end
end

-- 更新通用的属性, 名字啊, star啥的
function PetDevelopeLayer:_updateCommonAttrs()
    local info = pet_info.get(self._pet.base_id)
    -- --名字
    local nameLabel = self:getLabelByName("Label_name")
    nameLabel:setColor(Colors.getColor(info.quality))
    nameLabel:setText(info.name)
    nameLabel:createStroke(Colors.strokeBrown,2)
    
    --战宠形象
    if not self._petImg then
        -- local petPath2 = G_Path.getPetReadyGuangEffect(info.ready_id)
        -- self._petImg2 = EffectNode.new(petPath2)
        -- self._petImg2:setScale(0.65)
        -- self._petImg2:setPosition(ccp(0,25))
        -- self._petNode:addChild(self._petImg2)
        -- self._petImg2:play()
        local petPath = G_Path.getPetReadyEffect(info.ready_id)
        self._petImg = EffectNode.new(petPath)
        self._petNode:addChild(self._petImg,10)
        self._petImg:setPosition(ccp(0,25))
        self._petImg:setScale(0.85)
        self._petImg:play()
    end

    for index = 1 , 5 do 
        self:getImageViewByName("Image_star"..index):loadTexture(info.star >= index and "ui/yangcheng/star_juexing.png" or "ui/yangcheng/star_juexing_kong.png")
    end

    self:updateFight()
end

function PetDevelopeLayer:getPetImg()
    return self._petImg
end

function PetDevelopeLayer:updateStar()

    self:_updateCommonAttrs()
    self._effect = EffectNode.new("effect_juexing_c", 
        function(event)
            if event == "finish" then
                -- self:removeChild(effect,true)
                self._effect:removeFromParentAndCleanup(true)
                self._effect = nil
            end
        end
    )
    self:addChild(self._effect)
    self._effect:setPosition( self:getImageViewByName("Image_star" .. 
        tostring(pet_info.get(self._pet.base_id).star )):convertToWorldSpace(ccp(0, -100))  )
    self._effect:play()

end

function PetDevelopeLayer:adapterLayer()

    -- self:adapterWidgetHeight("Panel_content", "Panel_checkbox", "", 0, 0)
end

function PetDevelopeLayer:onLayerLoad( )
    --返回按钮事件
    -- self:registerBtnClickEvent("Button_back", function()
    --     -- uf_sceneManager:popScene()
    --     print("back")
    --     if CCDirector:sharedDirector():getSceneCount() > 1 then 
    --                 uf_sceneManager:popScene()
    --     else
    --         uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
    --     end
    -- end)

    -- self:registerWidgetClickEvent("ImageView_pic", function()
    --     -- uf_sceneManager:popScene()
    --     if CCDirector:sharedDirector():getSceneCount() > 1 then 
    --                 uf_sceneManager:popScene()
    --     else
    --         uf_sceneManager:replaceScene(require("app.scenes.equipment.EquipmentMainScene").new())
    --     end
    -- end)

end

function PetDevelopeLayer:onLayerUnload()

    uf_eventManager:removeListenerWithTarget(self)

end

function PetDevelopeLayer:updateFight()
    if self._lastFightValue > 0 and self._lastFightValue ~= self._pet.fight_value then
        --增加一个变化动画
        if self._fightValueChanger then
            self._fightValueChanger:stop()
            self._fightValueChanger = nil 
        end
        local NumberScaleChanger = require("app.scenes.common.NumberScaleChanger")
        self._fightValueChanger = NumberScaleChanger.new( self._fightLabel,  self._lastFightValue, self._pet.fight_value ,
            function(value) 
                if G_SceneObserver:getSceneName() ~= "PetDevelopeScene" then
                    return
                end
                self:updateFightLabel(value)
            end
        )
    else
        self:updateFightLabel(self._pet.fight_value)
    end
    self._lastFightValue = self._pet.fight_value
end

function PetDevelopeLayer:updateFightLabel(value)
    self._fightLabel:setText(GlobalFunc.ConvertNumToCharacter(value))
    local fightValueClr = Colors.qualityColors[1]
    -- if value < 10000 then
    --     fightValueClr = Colors.qualityColors[1]
    -- elseif value < 25000 then
    --     fightValueClr = Colors.qualityColors[2]
    -- elseif value < 50000 then
    --     fightValueClr = Colors.qualityColors[3]
    -- elseif value < 100000 then
    --     fightValueClr = Colors.qualityColors[4]
    -- elseif value < 200000 then
    --     fightValueClr = Colors.qualityColors[5]
    -- elseif value < 400000 then
    --     fightValueClr = Colors.qualityColors[6]
    -- else
    --     fightValueClr = Colors.qualityColors[7]
    -- end
    self._fightLabel:setColor(fightValueClr)
end

function PetDevelopeLayer:onLayerExit( )
    if self._fightValueChanger then
        self._fightValueChanger:stop()
        self._fightValueChanger = nil 
    end
end


return PetDevelopeLayer
