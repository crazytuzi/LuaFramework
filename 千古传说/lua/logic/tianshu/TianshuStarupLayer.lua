--[[
    天书突破结果
]]

local TianshuStarupLayer = class("TianshuStarupLayer", BaseLayer)

local CardSkyBook = require("lua.gamedata.base.CardSkyBook")

function TianshuStarupLayer:ctor(data)
    self.super.ctor(self, data)
    self:init("lua.uiconfig_mango_new.tianshu.TianShuStarUp")
    play_xiuliandengjitisheng()
end


function TianshuStarupLayer:initUI(ui)
	self.super.initUI(self,ui)

    self.btn_ok             = TFDirector:getChildByPath(ui, 'btn_ok')
    self.panel_effect       = TFDirector:getChildByPath(ui, 'Panel_TianShuStarUp')
    self.panel_close        = self.ui

    self.img_role           = TFDirector:getChildByPath(ui, 'img_tianshu')
    self.txt_power          = TFDirector:getChildByPath(ui, 'txt_power')

    self.panel_star         = TFDirector:getChildByPath(ui, 'panel_xingxing')
    self.panel_star:setZOrder(100)

    self.img_star           = {}
    self.img_star_h           = {}
    for i=1, SkyBookManager.kMaxStarLevel do
        self.img_star[i]  = TFDirector:getChildByPath(self.panel_star, "img_xing" .. i .. "_1")
        self.img_star_h[i]  = TFDirector:getChildByPath(self.panel_star, "img_xing" .. i .. "_2")
    end

    self.txt_att           = {}
    self.img_att           = {}
    self.txt_att_old       = {}
    self.txt_att_new       = {}
    self.img_arrow         = {}
    for i = 1, SkyBookManager.kMaxAttributeSize do
        local attr_Node = TFDirector:getChildByPath(ui, "img_attr_" .. i)
        self.img_att[i] = attr_Node
        self.txt_att[i] = TFDirector:getChildByPath(attr_Node, "txt_name")
        self.txt_att_old[i] = TFDirector:getChildByPath(attr_Node, "txt_old_attr")
        self.txt_att_new[i] = TFDirector:getChildByPath(attr_Node, "txt_new_attr")
        self.img_arrow[i] = TFDirector:getChildByPath(attr_Node, "img_arrow")
        self.img_att[i]:setVisible(false)
    end

    self.img_attr         = TFDirector:getChildByPath(ui, 'img_attr')
    self.img_title       = TFDirector:getChildByPath(ui, 'img_title')
    self.fightBgImg       = TFDirector:getChildByPath(ui, 'fightBgImg')

    self.panel_close:setTouchEnabled(false)
    self.img_attr:setVisible(false)
    self.btn_ok:setVisible(false) 
end

function TianshuStarupLayer:loadData(instanceId,oldarr,oldpower,oldFactor)
    self.instanceId = instanceId;
    self.oldarr = oldarr;
    self.oldpower = oldpower;
    self.oldFactor = oldFactor
end

function TianshuStarupLayer:setOldValue(quality, starlevel)
    self.old_quality    = quality
    self.old_starlevel  = starlevel
end

function TianshuStarupLayer:onShow()
    self.super.onShow(self)
    self:refreshBaseUI();
    self:refreshUI();
end

function TianshuStarupLayer:refreshBaseUI()

end

function TianshuStarupLayer:refreshUI()
    if not self.isShow then
        return;
    end
    self.item = SkyBookManager:getItemByInstanceId(self.instanceId)

    self:drawLeftArea()

    --local trainItem_old= BibleBreachData:getBreachInfo(self.old_quality, self.old_starlevel)
    --local trainItem_new = BibleBreachData:getBreachInfo(self.item.quality, self.item.tupoLevel)

    --local newitemData = RoleData:objectByID(self.item.id)

    --local level_up        = newitemData:GetAttrLevelUp()

    self.img_role:setTexture(self.item:GetTextrue())
    self.txt_power:setText(self.oldpower)

    --self.oldarr = {}
    self.newarr = {}
    local count = 0

    local newItem = CardSkyBook:new(self.item.id)
    newItem:setLevel(self.item.level)
    newItem:setTupoLevel(self.item.tupoLevel)

    if self.item.sbStoneId then  
        for k, v in pairs(self.item.sbStoneId) do
            newItem:setStonePos(k, v)
        end           
    end
    newItem:updatePower()
    self.newarr = newItem:getTotalAttr()

    local newFac = newItem.breachConfig.factor

    -- print("+++++++++++++++ role star up begin +++++++++++++++++++++")
    -- print("=============== old attribute start =====================")
    -- print("old level --------->", self.old_starlevel)
    -- for k, v in pairs(self.oldarr) do
    --     print(k, v)
    -- end
    -- print("=============== old attribute end =====================")

    -- print("=============== new attribute start =====================")
    -- print("new level ---------->", self.item.tupoLevel)
    -- for k, v in pairs(self.newarr) do
    --     print(k, v)
    -- end
    -- print("=============== new attribute end =====================")
    -- print("+++++++++++++++ role star up end +++++++++++++++++++++")
    local count = 0
    for i = 1, EnumAttributeType.Max - 1 do       
        if self.newarr[i] and self.newarr[i] ~= 0 and count < SkyBookManager.kMaxAttributeSize then
            count = count + 1
            self.img_att[count]:setVisible(true)
            --self.txt_att[count]:setText(AttributeTypeStr[i] .. "成长")
            self.txt_att[count]:setText(stringUtils.format(localizable.trainLayer_chengzhang,AttributeTypeStr[i]))
            
            --self.txt_att_old[count]:setText(self.oldarr[i])
            --self.txt_att_new[count]:setText(self.newarr[i])
            self.txt_att_old[count]:setText("  " .. self.oldFactor)
            self.txt_att_new[count]:setText(newFac)
        end
    end


    local changeArrTemp = {}
    local changeLength = 0;
    count = 0
    for i=1,count do
        local offset = self.newarr[i] - self.oldarr[i];
        if offset ~= 0 then
            changeLength = changeLength + 1;
            changeArrTemp[changeLength] = {i,offset};
        end
    end

    self.changeLength = changeLength;
    self.changeArrTemp = changeArrTemp;

    for i=1,5 do
        self.img_star[i]:setVisible(true)
        self.img_star_h[i]:setVisible(false)
    end
    for i=1,self.old_starlevel do
        
        -- local starIdx = i
        -- local starTextrue = 'ui_new/tianshu/img_xing1.png'

        -- self.img_star[starIdx]:setTexture(starTextrue)        
        self.img_star_h[i]:setVisible(true)
    end 
    -- for i=self.old_starlevel+1,5 do

    --     local starIdx = i
    --     local starTextrue = 'ui_new/tianshu/img_xing2.png'

    --     self.img_star[starIdx]:setTexture(starTextrue)        
    --     self.img_star[starIdx]:setVisible(true)
    -- end 
end


function TianshuStarupLayer:removeUI()
    self.super.removeUI(self)
end

function TianshuStarupLayer:registerEvents()
    self.super.registerEvents(self)
    self.panel_close.logic = self 
    self.panel_close:addMEListener(TFWIDGET_CLICK, audioClickfun(self.closeLayer),1)
end


function TianshuStarupLayer:removeEvents()
    self.super.removeEvents(self)
    self.panel_close:removeMEListener(TFWIDGET_CLICK)
    if self.powerTimerID then
        TFDirector:removeTimer(self.powerTimerID)
        self.powerTimerID = nil
    end
end

function TianshuStarupLayer:drawLeftArea()
    self:ShowLeftAreaAction()
end

function TianshuStarupLayer:openRightArea()
    self.ui:runAnimation("Action0",1);
    self.ui:setAnimationCallBack("Action0", TFANIMATION_END, function()
        self:showTotalPowerAction()
    end)

    self.img_attr:setVisible(true)
end

function TianshuStarupLayer:ShowLeftAreaAction()
    self.img_role:setScale(1.3)
    self:drawStarAction()

    -- local layer = self.img_role

    -- TFDirector:setFPS(GameConfig.FPS * 2)


    -- layer:setOpacity(0);

    -- local toastTween = {
    --     target = layer,
    --     {
    --         delay = 1 / 60,
    --         onComplete = function() 
    --             layer:setScale(1.3);
    --         end
    --     },
    --     {
    --         duration = 0.3,
    --         alpha = 1,
    --         scale = 1.8,
    --     },
    --     {
    --         duration = 0.06,
    --         scale = 1.3,
    --     },
    --     {
    --         duration = 0,
    --         onComplete = function() 
    --             TFDirector:setFPS(GameConfig.FPS)
    --             self:drawStarAction()
    --         end
    --     }
    -- }

    -- TFDirector:toTween(toastTween);
end

function TianshuStarupLayer:drawStarAction()
    --print("111111")
    --print(self.item)
    for i=1,SkyBookManager.kMaxStarLevel do
        --if i == (self.item:getTupoLevel() + 1) then
        if i == self.item:getTupoLevel() then
            local starIdx = i
            local starNode = self.img_star[starIdx]
            local pos = starNode:getPosition()
            local parent = starNode:getParent()

            local animJsonPath = "effect/skybook_tupo_1.xml"
            local animPath = "skybook_tupo_1_anim"

            TFResourceHelper:instance():addArmatureFromJsonFile(animJsonPath)
            local effect = TFArmature:create(animPath)
            if effect == nil then
                return
            end

            effect:addMEListener(TFARMATURE_COMPLETE,function()
                effect:removeMEListener(TFARMATURE_COMPLETE) 
                effect:removeFromParent()
                -- local starTextrue = 'ui_new/tianshu/img_xing1.png'
                -- starNode:setTexture(starTextrue)
                self.img_star_h[starIdx]:setVisible(true)


                TFResourceHelper:instance():addArmatureFromJsonFile("effect/skybook_tupo_2.xml")
                local effect_2 = TFArmature:create("skybook_tupo_2_anim")
                if effect_2 == nil then
                    return
                end
                local temp_index = 1
                effect_2:addMEListener(TFARMATURE_UPDATE,function()

                    if temp_index >= 13 then
                        effect_2:removeMEListener(TFARMATURE_UPDATE) 
                        TFResourceHelper:instance():addArmatureFromJsonFile("effect/skybook_tupo_3.xml")
                        local effect_3 = TFArmature:create("skybook_tupo_3_anim")
                        if effect_3 == nil then
                            return
                        end
                        effect_3:setAnimationFps(GameConfig.ANIM_FPS)
                        effect_3:playByIndex(0, -1, -1, 1)
                        effect_3:setPosition(ccp(55,55))
                        effect_3:setScale(1/1.3)
                        effect_3:setZOrder(1)
                        self.img_role:addChild(effect_3)
                    else
                        temp_index = temp_index + 1
                    end

                end)


                effect_2:setAnimationFps(GameConfig.ANIM_FPS)
                effect_2:playByIndex(0, -1, -1, 0)
                effect_2:setPosition(ccp(55,55))
                effect_2:setScale(1/1.3)
                effect_2:setZOrder(1)
                self.img_role:addChild(effect_2)

            end)

            effect:setAnimationFps(GameConfig.ANIM_FPS)
            effect:playByIndex(0, -1, -1, 0)
            effect:setPosition(ccp(pos.x, pos.y))
            effect:setZOrder(1)
            parent:addChild(effect)

            
            self.moveToRightTimer = TFDirector:addTimer(1400, 1, nil, 
                function()
                    self:openRightArea()
                    TFDirector:removeTimer(self.moveToRightTimer)
                    self.moveToRightTimer = nil
                    end)
           
            return
        end
    end
end



function TianshuStarupLayer:showTotalPowerAction()
    self.fightBgImg:setVisible(true)
    TFResourceHelper:instance():addArmatureFromJsonFile("effect/star_up_power_effect.xml")
    local effect = TFArmature:create("star_up_power_effect_anim")
    if effect == nil then
        return
    end

    effect:addMEListener(TFARMATURE_COMPLETE,function()
        effect:removeMEListener(TFARMATURE_COMPLETE) 
        effect:removeFromParent()
        self.btn_ok:setVisible(true)
        self.panel_close:setTouchEnabled(true)
        self.allEffectCompelte = true
    end)

    effect:setAnimationFps(GameConfig.ANIM_FPS)
    effect:playByIndex(0, -1, -1, 0)
    effect:setPosition(ccp(120, 20))
    self.fightBgImg:addChild(effect)


    self:textChange(self.oldpower,self.item.power)
end


function TianshuStarupLayer.closeLayer(sender)
    local self = sender.logic
    AlertManager:close()
end

function TianshuStarupLayer:textChange(oldValue,newValue)
    if not oldValue or not newValue then
        return;
    end
    
    self.txt_power:setText(oldValue);

    local changeSum = newValue - oldValue

    if self.power_effect == nil then
        -- local resPath = "effect/ui/power_change.xml"
        -- TFResourceHelper:instance():addArmatureFromJsonFile(resPath)
        -- effect = TFArmature:create("power_change_anim")

        -- self.txt_power:addChild(effect,2)
        local effect = Public:addEffect("power_change", self.txt_power, 0, -10, 0.5, 0)
        effect:setZOrder(2)    
        self.power_effect = effect
        self.power_effect:setVisible(false)
    end

    local frame = 1
    self.txt_power:setScale(1)

    self.powerTimerID = TFDirector:addTimer(1000/60, 40, nil, 
                function() 
                    if frame == 11 then
                        self.power_effect:setVisible(true)
                        -- self.power_effect:playByIndex(0, -1, -1, 0)
                        ModelManager:playWithNameAndIndex(self.power_effect, "", 0, 0, -1, -1)
                    end
                    if frame >= 11 and frame < 34 then
                         if newValue > oldValue then
                            play_shuzibiandong()
                        end
                        local tempValue = oldValue + (frame - 11) *(changeSum/23)
                        self.txt_power:setText(math.floor(tempValue));
                    end
                    if frame == 34 then
                        self.power_effect:removeFromParent()
                        self.power_effect = nil
                        self.txt_power:setText(newValue);
                        TFDirector:removeTimer(self.powerTimerID)
                        self.powerTimerID = nil
                    end
                    frame = frame + 1
                end)
end

return TianshuStarupLayer