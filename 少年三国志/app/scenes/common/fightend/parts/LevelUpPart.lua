
local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"


local LevelUpPart = class ("LevelUpPart", function() return display.newNode() end)
local Colors = require("app.setting.Colors")
require("app.cfg.knight_info")

require("app.cfg.role_info")
require("app.cfg.function_level_info")

local KnightPic = require("app.scenes.common.KnightPic")

function LevelUpPart:ctor( oldLevel, newLevel, endCallback)
    self._oldLevel = oldLevel
    self._newLevel = newLevel
    self._endCallback =  endCallback
    self:setNodeEventEnabled(true)
end







function LevelUpPart:play(   )
  


    local oldLevelRecord = role_info.get(self._oldLevel)
    local newLevelRecord = role_info.get(self._newLevel)


    --是否有新功能开放
    local newFunctionRecord = nil
    for i=1,function_level_info.getLength() do
        local record = function_level_info.indexOf(i)
        --if true then newFunctionRecord=record; break end
        if record.level == self._newLevel then
            newFunctionRecord = record
            break
        end
    end

    
    self._node = EffectMovingNode.new("moving_fightend1_levelup", function(key)
            if key == "levelup" then
                return CCSprite:create(G_Path.getTextPath("shengjile.png"))
            -- elseif key == "old_level" then
            --     local label = GlobalFunc.createGameLabel( self._oldLevel, 24, Colors.uiColors.WHITE, Colors.strokeBrown)
            --     return label
            elseif  key == "arrow3"  or key == "arrow2" then
                return CCSprite:create(G_Path.getFightEndDir() .. "shengji_arrow.png")
            -- elseif key == "new_level"  then
            --     G_SoundManager:playSound(require("app.const.SoundConst").GameSound.KNIGHT_UPGRADE)

            --     local label = GlobalFunc.createGameLabel( self._newLevel, 24, Colors.uiColors.GREEN, Colors.strokeBrown )
            --     return label
            elseif key == "level_txt"  then
                
                local layer = UFCCSNormalLayer.new("ui_layout/fightend_FightEndGongxiLevelup.json")
                layer:getLabelByName("Label_pre"):setText(G_lang:get("LANG_FIGHTEND_GONGXI_PRE"))
                layer:getLabelByName("Label_after"):setText(G_lang:get("LANG_FIGHTEND_GONGXI_AFTER"))
                layer:getLabelByName("Label_level"):setText(self._newLevel)

                layer:getLabelByName("Label_level"):createStroke(Colors.strokeBrown, 1)
                layer:setClickSwallow(true)
                
                ---self:getLabelByName("Label_awardTag"):createStroke(Colors.strokeBrown,1)

                return layer                

                -- local label = GlobalFunc.createGameLabel( self._newLevel, 24, Colors.uiColors.GREEN, Colors.strokeBrown )

                -- return label

            elseif key == "light"  then
                return CCSprite:create(G_Path.getFightEndDir() .. "shengji_guang.png")
            elseif key == "bg"  then
                return CCSprite:create(G_Path.getFightEndDir() .. "shengji_paper.png")
            -- elseif key == "level_bg0"  then
            --     return CCSprite:create(G_Path.getFightEndDir() .. "level_bg.png")
            elseif key == "level_bg1"  then
                return CCSprite:create(G_Path.getFightEndDir() .. "level_bg.png")
            elseif key == "level_bg2"  then
                return CCSprite:create(G_Path.getFightEndDir() .. "level_bg.png")
            -- elseif key == "level_title"  then
            --     local label = GlobalFunc.createGameLabel(  G_lang:get("LANG_FIGHTEND_CURRENT_LEVEL"), 24, Colors.uiColors.LYELLOW , Colors.strokeBrown)
            --     return label
            elseif key == "current_tili_title"  then
                local label = GlobalFunc.createGameLabel(  G_lang:get("LANG_FIGHTEND_CURRENT_TILI"), 24, Colors.darkColors.TITLE_02 , Colors.strokeBrown)
                return label
            elseif key == "current_jingli_title"  then
                local label = GlobalFunc.createGameLabel(  G_lang:get("LANG_FIGHTEND_CURRENT_JINGLI"), 24, Colors.darkColors.TITLE_02, Colors.strokeBrown )
                return label
            elseif key == "current_jingli"  then
                local label = GlobalFunc.createGameLabel(  G_Me.userData.spirit - oldLevelRecord.energy_recover, 24, Colors.darkColors.DESCRIPTION, Colors.strokeBrown )
                return label
            elseif key == "current_tili"  then
                local label = GlobalFunc.createGameLabel( G_Me.userData.vit - oldLevelRecord.power_recover, 24, Colors.darkColors.DESCRIPTION, Colors.strokeBrown )
                return label
            elseif key == "new_tili"  then
                local label = GlobalFunc.createGameLabel( G_Me.userData.vit, 24, Colors.darkColors.ATTRIBUTE, Colors.strokeBrown )
                return label
            elseif key == "new_jingli"  then
                local label = GlobalFunc.createGameLabel( G_Me.userData.spirit, 24, Colors.darkColors.ATTRIBUTE , Colors.strokeBrown)
                return label
            end
        end,



        function (event) 
            if event=="finish" and self._endCallback ~= nil then
                if newFunctionRecord ~=  nil then
                    local layer = UFCCSNormalLayer.new("ui_layout/fightend_FightEndNewFunction.json")
                    local size = layer:getRootWidget():getContentSize()
                    layer:setPosition(ccp(-size.width/2, -300))
                    self:addChild(layer)
                    layer:getPanelByName("Panel_content"):setVisible(false)
                    layer:setTouchEnabled(false)
                    layer:setClickSwallow(true)
                    local EffectNode = require "app.common.effects.EffectNode"
                    local effect 
                    effect = EffectNode.new("effect_kaiqi", 
                            function(event, frameIndex)
                                if event == "finish" then
                                    effect:stop()
                                    layer:getPanelByName("Panel_content"):setVisible(true)
                                    layer:getLabelByName("Label_title"):setText(newFunctionRecord.name)
                                    layer:getLabelByName("Label_desc"):setText(newFunctionRecord.directions)
                                    layer:getImageViewByName("Image_icon"):loadTexture( G_Path.getBasicIconById(newFunctionRecord.icon))
                                    layer:getLabelByName("Label_title"):createStroke(Colors.strokeBrown,1)

                                    self._endCallback()
                                    self._endCallback  = nil
                                end
                            end,
                            nil,
                            nil, 
                            function (sprite, png, key) 
                                local sp = CCSprite:create(G_Path.getTextPath("shengji_open.png"))
                                return true, sp
                            end
                        )



                    layer:getPanelByName("Panel_effect"):addNode(effect)
                    effect:play()

                else 
                    local layer = UFCCSNormalLayer.new("ui_layout/fightend_FightEndNoNewFunction.json")

                    if  G_Me.userData.level > 20 then
                        layer:getLabelByName("Label_txt"):setText(G_lang:get("LANG_FIGHTEND_GONGXI_SHENGJI"))

                    else
                        layer:getLabelByName("Label_txt"):setText(G_lang:get("LANG_FIGHTEND_GONGJI_LV_" .. tostring(G_Me.userData.level )))

                    end

                    


                    layer:setPosition(ccp(0, -180))
                    layer:setClickSwallow(true)
                    
                    self:addChild(layer)
                    
                    self._endCallback()
                    self._endCallback  = nil
                end
               
                
            end
        end
    )
    --self._node:setDouble(0.1)
    
    self:addChild(self._node)
    self._node:play()
end


function LevelUpPart:onExit()
    self:setNodeEventEnabled(false)
    if self._node then
        self._node:stop()
    end
    
end




return LevelUpPart