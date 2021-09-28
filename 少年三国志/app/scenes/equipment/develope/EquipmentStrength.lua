--由于在developerLayer里要同时显示 强化/精炼 equip/treasure等4个页面,所以分开来写逻辑比较清楚

local EquipmentStrength = class("EquipmentStrength")
local EffectNode = require "app.common.effects.EffectNode"
local EquipmentInfo = require("app.scenes.equipment.EquipmentInfo")

function EquipmentStrength:ctor(container)
    self._container = container

    self._levelBeforeStrength = 0
    self._wantStengthTimes = 0

end

--初始化
function EquipmentStrength:onLayerLoad( )
    local container = self._container



    container:getLabelByName("Label_strength_next_level"):setText(G_lang:get("LANG_NEXT_LEVEL"))

    container:getLabelByName("Label_strength_current_level"):setText(G_lang:get("LANG_CURRENT_STRENGTH"))


    container:attachImageTextForBtn("Button_strength","ImageView_222")
    container:attachImageTextForBtn("Button_autoStrength","ImageView_autoStrength")

    --事件相关
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_EQUIPMENT_STRENGTHEN, self._onStrengthResult, self)
    container:registerBtnClickEvent("Button_strength", function()
        self:_wantStength(1)


    end)
    container:registerBtnClickEvent("Button_autoStrength", function()
        if self:_canStrength5() then
            self:_wantStength(5)
        else
            -- local record = self:_getFunctionRecord()
            -- G_MovingTip:showMovingTip(record.comment)

        end
        
    
    end)

    self:_updateButtonState()
end

--更新强化面板上的显示, 默认以装备当前等级的数据来显示, 但是由于自动强化过程中需要逐步显示每个level变化的过程, 所以这里可以传一个level进来
function EquipmentStrength:updateView(level)
    local container = self._container
    local equipment = container:getEquipment()

    if level == nil then
        level = equipment.level
    end

    self:updateAttrView(level)
    self:updateMoney(level)
 
end



--更新强化面板上的显示, 默认以装备当前等级的数据来显示, 但是由于自动强化过程中需要逐步显示每个level变化的过程, 所以这里可以传一个level进来
function EquipmentStrength:updateAttrView(level)
    local container = self._container
    local equipment = container:getEquipment()

    if level == nil then
        level = equipment.level
    end

    local nextLevel = level + 1
    local maxLevel = equipment:getMaxStrengthLevel()

     --颜色设置
    if maxLevel <= level then
         --字体设置红色

         container:getLabelByName("Label_nextLevel"):setColor(Colors.lightColors.TIPS_01)
     else
         --字体设置绿色
         container:getLabelByName("Label_nextLevel"):setColor(Colors.lightColors.ATTRIBUTE)
     end
     
    -- 强化等级    
    container:getLabelByName("Label_currentLevel"):setText(level .. "/" .. maxLevel)
    container:getLabelByName("Label_nextLevel"):setText( nextLevel .. "/" .. maxLevel)

    --当前强化属性
    local attrs = equipment:getStrengthAttrs(level)
    EquipmentInfo.setAttrLabels(container,attrs,  {"Label_current_attr1_title", "Label_current_attr1_value", "Label_current_attr2_title", "Label_current_attr2_value"} )


    --下个等级属性
    local next_attrs = equipment:getStrengthAttrs(nextLevel)
    EquipmentInfo.setAttrLabels(container, next_attrs,  {"Label_next_attr1_title", "Label_next_attr1_value", "Label_next_attr2_title", "Label_next_attr2_value"} )

end

function EquipmentStrength:updateMoney(level)
    local container = self._container
    local equipment = container:getEquipment()

    --银两
    local money = equipment:getStrengthEquipmentMoney(level)

    if money > G_Me.userData.money then
        --字体设置红色

        container:getLabelByName("Label_cost"):setColor(Colors.lightColors.TIPS_01)
    else
        --字体设置白色

        container:getLabelByName("Label_cost"):setColor(Colors.lightColors.DESCRIPTION)
    end

    container:getLabelByName("Label_cost"):setText(money)
end

function EquipmentStrength:_checkStength()
    if self._effect  then
        return false
    end


    local container = self._container
    local equipment = container:getEquipment()
    
    --是否已经到达上限

    local level = equipment.level
    local maxLevel = equipment:getMaxStrengthLevel()
    if level >= maxLevel then
        G_MovingTip:showMovingTip(G_lang:get("LANG_STRENGTH_LEVEL_LIMIT"))
        return false
    end

    --银两
    local money = equipment:getStrengthEquipmentMoney(level)
    if money > G_Me.userData.money then
        --require("app.scenes.common.NoMoneyLayer").show()
        
        require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_MONEY, 0,
         GlobalFunc.sceneToPack("app.scenes.equipment.EquipmentDevelopeScene", {equipment,1}))
        return false
    end
    return true
end

function EquipmentStrength:_wantStength(times)


    if not self:_checkStength() then
        return 
    end

    local container = self._container
    local equipment = container:getEquipment()


    -- 开始强化
    self._wantStengthTimes = times
    self._levelBeforeStrength = equipment.level

    G_HandlersManager.equipmentStrengthenHandler:sendEquipmentStrengthen(equipment.id, times)

end



function EquipmentStrength:_stopEffect()

    if self._effect  ~= nil then

        self._effect:stop()
        self._container:getEffectNode():removeChild(self._effect)
        self._effect = nil    
    end

end


function EquipmentStrength:_stopBaojiEffect()

    if self._baojiEffect  ~= nil then

        self._baojiEffect:stop()
        self._container:getEffectNode():removeChild(self._baojiEffect)
        self._baojiEffect = nil    
    end



end

function EquipmentStrength:_getFunctionRecord()
   -- require("app.cfg.function_level_info")
   -- local record = function_level_info.get(31)
   -- local FunctionLevelConst = require("app.const.FunctionLevelConst")
   -- local _level = G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.STRENGTH_FIVE_TIMES)
   -- return _level
end
function EquipmentStrength:_canStrength5()
    local FunctionLevelConst = require("app.const.FunctionLevelConst")
    return G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.STRENGTH_FIVE_TIMES)
    
    -- local record = self:_getFunctionRecord()
    -- if record.level <=  G_Me.userData.level then
    --     return true
    -- else
    --     return false
    -- end 
end


function EquipmentStrength:onUncheck()
    self:_stopEffect()
    self:_stopBaojiEffect()
    -- self._attrPlaying = false
    -- self._attrPlayList = {}
    self:_updateButtonState() 
end

function EquipmentStrength:onLayerUnload()
    --todo stop all playing
    self:onUncheck()
    uf_eventManager:removeListenerWithTarget(self)

end

function EquipmentStrength:_updateButtonState()

       
    self._container:getImageViewByName("ImageView_autoStrength"):setVisible(true)
    self._container:getImageViewByName("ImageView_stop"):setVisible(false)

    if self._effect ~= nil then
        --正在播放特效
        self._container:getButtonByName("Button_strength"):setTouchEnabled(false)
        self._container:getButtonByName("Button_autoStrength"):setTouchEnabled(false)
    else

        self._container:getButtonByName("Button_strength"):setTouchEnabled(true)
        self._container:getButtonByName("Button_autoStrength"):setTouchEnabled(true)
    end

  

end



function EquipmentStrength:_attrPlayNext(levelInfo)
   
   local container = self._container
   local equipment = container:getEquipment()

   local levelDelta = levelInfo[1]
   local oldLevel = levelInfo[2]
   local nextLevel = levelInfo[3]
   
   local attrs = equipment:getStrengthAttrs(oldLevel)
   local attrsNext = equipment:getStrengthAttrs(nextLevel)

   --属性变化:
   for i=1,#attrsNext do
       attrsNext[i].delta = attrsNext[i].value - attrs[i].value
   end


   G_SoundManager:playSound(require("app.const.SoundConst").GameSound.ARENA_SCROLL)

   
   
   --装备强化只有一条属性变化
   local attrInfo = attrsNext[1]

   G_flyAttribute.addAttriChange(attrInfo.typeString, attrInfo.delta, self._container:getLabelByName("Label_current_attr1_value"))


  

end

----------------------------------网络接收---------------------


function EquipmentStrength:_onStrengthResult(data) 
    -- dump(data)
    if data.ret == NetMsg_ERROR.RET_OK then
        local times = data.times
        local crit_times = data.crit_times
        local afterLevel = data.level
        local delta = afterLevel - self._levelBeforeStrength
        -- optional uint32 times = 2; //强化次数
        -- optional uint32 crit_times = 3; //暴击次数
        -- optional uint32 break_reason = 4; //强化中断原因
        -- optional uint32 level = 5; //强化后等级

        local container = self._container
        local equipment = container:getEquipment()
        self:_stopEffect()
        G_flyAttribute._clearFlyAttributes(  )
        self:updateAttrView(self._levelBeforeStrength)

        self._effect = EffectNode.new("effect_tiecui", 
            function(event, frameIndex)
                if event == "finish" then
                    self:_stopEffect()
                    self:_updateButtonState()  
                    -- self:_flyAttr(data) 

                elseif event == "baoji" then

                    GlobalFunc.shakeAction(self._container:getImageViewByName("ImageView_pic"),0.3)

                    if (self._wantStengthTimes == 1 and delta > 1) or (self._wantStengthTimes > 1 and data.crit_times >= 1 ) then
                        self:_stopBaojiEffect()
                        self._baojiEffect = EffectNode.new("effect_baoji", 
                            function(event, frameIndex)
                                if event == "finish" then
                                    self:_stopBaojiEffect()
                                end
                            end,
                            nil,
                            nil,
                            function (sprite, png, key) 
                                
                                return true, CCSprite:create(G_Path.getTextPath("zbyc_baoji.png"))
                            end
                        )
                        self._baojiEffect:play()
                        container:getEffectNode():addNode(self._baojiEffect,3)
                        
                    end 
                 
                    self:_flyAttr(data) 
                    -- self:updateView()
                    -- if self:_canStrength5() then
                    --     self:_wantStength(5)
                    -- end

                end
            end
        )


        self._effect:setScale(1.2)
        self._effect:play()
        container:getEffectNode():addNode(self._effect, 1)
        
        self:_updateButtonState() 

        self:updateMoney(afterLevel)


        if self._container.onEquipStrength then 
            self._container:onEquipStrength()
        end

        


    end
end

function EquipmentStrength:_flyAttr(data) 

    if not self._container or not self._container.isRunning or not self._container:isRunning() then 
        return 
    end

    local times = data.times
    local crit_times = data.crit_times
    local afterLevel = data.level
    local delta = afterLevel - self._levelBeforeStrength

    G_flyAttribute._clearFlyAttributes()
    
    local levelTxt = ""
    if self._wantStengthTimes == 1 then
        --强化一次
        levelTxt = G_lang:get("LANG_QIANGHUA_DENGJI_DELTA", {delta=delta})

        G_flyAttribute.addNormalText(levelTxt,nil, self._container:getLabelByName("Label_currentLevel"), delta)
    else
        --强化5次
        if times >=  self._wantStengthTimes then
            levelTxt = G_lang:get("LANG_QIANGHUA_N_TIMES1", {delta=delta, times=times, baoji=crit_times})
        else
            if data.break_reason == 1 then
                --银两不足
                levelTxt = G_lang:get("LANG_QIANGHUA_N_TIMES3", {delta=delta, times=times, baoji=crit_times})
            elseif data.break_reason ==2 then
                levelTxt = G_lang:get("LANG_QIANGHUA_N_TIMES2", {delta=delta, times=times, baoji=crit_times})
            else
                --error
                --levelTxt = G_lang:get("LANG_QIANGHUA_DENGJI_DELTA", {delta=delta})
            end
    
        end


       G_flyAttribute.addNormalText(levelTxt,nil, self._container:getLabelByName("Label_currentLevel"), delta)

    end

    
    self:_attrPlayNext({delta, self._levelBeforeStrength, afterLevel})

-- __Log("G_flyAttribute:play(), container:%d, callback:%d", self._container and 1 or 0, 
--     self._container and (self._container.__EFFECT_FINISH_CALLBACK__ and 1 or 0) or 0)
    G_flyAttribute.play(function ( ... )
        if not self._container or not self._container.isRunning or not self._container:isRunning() then 
            return 
        end
        if self._container and self._container.__EFFECT_FINISH_CALLBACK__ then 
            self._container.__EFFECT_FINISH_CALLBACK__()
        end

        if G_SceneObserver:getSceneName() ~= "EquipmentDevelopeScene" then
            return
        end
            self:updateAttrView(nextLevel)

    end, 1.5)
end













return EquipmentStrength