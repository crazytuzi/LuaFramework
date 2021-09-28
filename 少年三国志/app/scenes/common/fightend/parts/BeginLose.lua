
local EffectMovingNode = require "app.common.effects.EffectMovingNode"

local BeginLose = class ("BeginLose", function() return display.newNode() end)

local EffectNode = require "app.common.effects.EffectNode"


function BeginLose:ctor(data, result, endCallback)
    self._data = data
    self._result = result
    self._endCallback =  endCallback
    self:setNodeEventEnabled(true)
end


function BeginLose:play(   )


    self._node = EffectMovingNode.new("moving_lose", function(key)
          if key == "effect_lose" then
                self._effect = EffectNode.new("effect_lose", nil,nil,nil, function (sprite, png, key) 
                    if key == "title_1"  then
                        if sprite == nil then
                            -- local sp = CCSprite:create(G_Path.getTextPath("zd_shibai.png"))
                            local title = nil
                            if not self._result then
                                title = "zd_shibai.png"
                            else
                                title = G_Path.getBattleResultImage(self._result)
                            end
                            local sp = CCSprite:create(G_Path.getTextPath(title))
                            return true, sp
                        else
                            return true, sprite     
                        end
                       
                    end
                    return false
                end)
                self._effect:play()
                return self._effect                
            elseif key == "tips" then
                --闯关里会有这个胜利条件描述

               

                if self._data.lose_desc ~= nil  then
                    --闯关里会有这个胜利条件描述
                    local layer = UFCCSNormalLayer.new("ui_layout/fightend_FightEndTowerDesc.json")
                    layer:getLabelByName("Label_desc"):setColor(Colors.darkColors.DESCRIPTION)
                    layer:getLabelByName("Label_desc"):setText(self._data.lose_desc )
                    layer:getLabelByName("Label_desc"):createStroke(Colors.strokeBrown,1)
                    layer:setClickSwallow(true)
                    return layer  
                elseif self._data.revenge_failed then
                    -- 争粮战复仇失败需要显示说明文字
                    local layer = UFCCSNormalLayer.new("ui_layout/fightend_RobRevenge.json")
                    
                    layer:setClickSwallow(true)
                    return layer     
                elseif self._data.daily_pvp_mvp then
                     -- 激战虎牢关
                    local layer = UFCCSNormalLayer.new("ui_layout/fightend_FightEndTowerDesc.json")
                    if self._result  == "vip_result" then
                        --战斗评价
                        layer:getImageViewByName("Image_title"):loadTexture(G_Path.getTextPath("title_zhandoupingjia.png"))
                    end

                    local imgTitle = layer:getImageViewByName("Image_title")
                    if imgTitle then
                        imgTitle:loadTexture("ui/text/txt/title_benchangmvp.png")
                    end
                
                    local szMVPName1 = self._data.daily_pvp_mvp["mvp_name_1"]
                    local szMVPName2 = self._data.daily_pvp_mvp["mvp_name_2"]

                    if szMVPName1 and szMVPName1 ~= "" then
                        label = layer:getLabelByName("Label_desc")
                        if label then
                            label:setText(szMVPName1)
                            label:setColor(Colors.qualityColors[self._data.daily_pvp_mvp["mvp_quality_1"]])
                            label:createStroke(Colors.strokeBrown, 1)
                        end
                    end
                    if szMVPName2 and szMVPName2 ~= "" then
                        local label2 = GlobalFunc.createGameLabel(szMVPName2, 24, Colors.qualityColors[self._data.daily_pvp_mvp["mvp_quality_2"]])
                        if label then
                            label2:createStroke(Colors.strokeBrown, 1)
                            label:addChild(label2)
                            label2:setPositionY(-26)
                        end
                    end

                    layer:setClickSwallow(true)

                    return layer  
                else
                    return display.newNode()
                end

            end
        end,
        function (event) 
            if event=="finish" and self._endCallback ~= nil then

                self._endCallback()
                self._endCallback  = nil
                
            end
        end
    )

    
    self:addChild(self._node)
    self._node:play()



end


function BeginLose:onExit()
    self:setNodeEventEnabled(false)
    if self._node then
        self._node:stop()
    end
    
end

return BeginLose