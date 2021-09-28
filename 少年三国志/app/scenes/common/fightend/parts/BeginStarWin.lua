
local EffectMovingNode = require "app.common.effects.EffectMovingNode"
local EffectNode = require "app.common.effects.EffectNode"

local BeginStarWin = class ("BeginStarWin", function() return display.newNode() end)

local KnightPic = require("app.scenes.common.KnightPic")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

require("app.cfg.knight_info")

function BeginStarWin:ctor( data, result, endCallback)
   self._star = data.star
   self._result = result
   self._data = data
   self._endCallback =  endCallback
   self:setNodeEventEnabled(true)

   -- 过关斩将
   self._ex_star = data.ex_star
end



function BeginStarWin:play(   )

    self._node = EffectMovingNode.new("moving_win", function(key)
          if key == "stars" then
                if self._star ~= nil and self._star > 0 then
                    self._starsAnimation = EffectMovingNode.new( "moving_fightend1_begin_star_win_star3", 
                        function(key)
                            if key == "star1" or key == "star2" or key == "star3" then
                               return CCSprite:create(G_Path.getFightEndDir() .. "zd_star.png")
                            elseif key == "gstar1" or key == "gstar2" or key == "gstar3" then
                                return CCSprite:create(G_Path.getFightEndDir() .. "zd_star_gray.png")
                            end
                        end,
                        function (event) 
                            if event == "star1" and self._star == 1 then
                                --停止
                                self:_finishStars()
                            elseif event == "star2" and self._star == 2 then
                                self:_finishStars()
                            elseif event == "star3" or event == "finish"  then
                                self:_finishStars()
                            elseif event == "star1_ok" or event == "star2_ok"  or event == "star3_ok" then
                                if self._shaking ~= nil then
                                    self._shaking:resetPosition()
                                    self._shaking:stop()
                                end    
                                self._shaking = EffectSingleMoving.run(self, "smoving_shake_star")
                                G_SoundManager:playSound(require("app.const.SoundConst").GameSound.STAR_SOUND)

                            end 

                        end
                    )   
                    self._starsAnimation:play()
                    return self._starsAnimation
                elseif self._ex_star ~= nil and self._ex_star > 0 then
                    self._starsAnimation = EffectMovingNode.new( "moving_fightend1_begin_star_win_star3", 
                        function(key)
                            if key == "star1" or key == "star2" or key == "star3" then
                               return CCSprite:create(G_Path.getFightEndDir() .. "zd_star.png")
                            elseif key == "gstar1" or key == "gstar2" or key == "gstar3" then
                                return CCSprite:create(G_Path.getFightEndDir() .. "zd_star_gray.png")
                            end
                        end,
                        function (event) 
                            if event == "star1" and self._ex_star == 1 then
                                --停止
                                self:_finishStars()
                            elseif event == "star2" and self._ex_star == 2 then
                                self:_finishStars()
                            elseif event == "star3" or event == "finish"  then
                                self:_finishStars()
                            elseif event == "star1_ok" or event == "star2_ok"  or event == "star3_ok" then
                                if self._shaking ~= nil then
                                    self._shaking:resetPosition()
                                    self._shaking:stop()
                                end    
                                self._shaking = EffectSingleMoving.run(self, "smoving_shake_star")
                                G_SoundManager:playSound(require("app.const.SoundConst").GameSound.STAR_SOUND)

                            end 

                        end
                    )   
                    self._starsAnimation:play()
                    return self._starsAnimation
                else
                    return display.newNode()
                end
  
            
            elseif key == "effect_win" then
                self._effect = EffectNode.new("effect_win1", nil,nil,nil, function (sprite, png, key) 
                    if key == "title_2"  then
                        if sprite == nil then
                            local title = "zd_shengli.png"
                            if self._result  == "vip_result" or self._result == "moshen_result" or self._result == "juntuan_result" then
                               title = "vip_zhandoujieshu.png" 
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
               
                local PlotlineDungeonType = require("app.const.PlotlineDungeonType")
                if self._star ~= nil and self._star > 0 then
                    local starTxt = ""
                    if self._star == 1 then
                        if G_Me.userData:getPlotlineDungeonType() == PlotlineDungeonType.EASY then
                            starTxt = G_lang:get("LANG_FIGHTEND_STAR1")
                        else
                            starTxt = G_lang:get("LANG_FIGHTEND_HARD_STAR1")
                        end
                    elseif self._star ==2 then
                        if G_Me.userData:getPlotlineDungeonType() == PlotlineDungeonType.EASY then
                            starTxt = G_lang:get("LANG_FIGHTEND_STAR2")
                        else
                            starTxt = G_lang:get("LANG_FIGHTEND_HARD_STAR2")
                        end
                    elseif self._star ==3 then
                        if G_Me.userData:getPlotlineDungeonType() == PlotlineDungeonType.EASY then
                            starTxt = G_lang:get("LANG_FIGHTEND_STAR3")
                        else
                            starTxt = G_lang:get("LANG_FIGHTEND_HARD_STAR3")
                        end
                    end
                    local label = GlobalFunc.createGameLabel(starTxt , 20, Colors.uiColors.YELLOW )
                    return label


                   
                elseif self._data.win_desc ~= nil  then

                    --闯关/VIP里会有这个胜利条件描述
                    local layer = UFCCSNormalLayer.new("ui_layout/fightend_FightEndTowerDesc.json")
                    if self._result  == "vip_result" then
                        --战斗评价
                        layer:getImageViewByName("Image_title"):loadTexture(G_Path.getTextPath("title_zhandoupingjia.png"))
                    end
                    layer:getLabelByName("Label_desc"):setColor(Colors.darkColors.DESCRIPTION)
                    layer:getLabelByName("Label_desc"):setText(self._data.win_desc )
                    layer:getLabelByName("Label_desc"):createStroke(Colors.strokeBrown,1)
                    layer:setClickSwallow(true)
                    return layer  
                elseif self._data.riot_win_desc1 ~= nil and self._data.riot_win_desc2 then
               
                    -- 精英暴动
                    local layer = UFCCSNormalLayer.new("ui_layout/fightend_FightEndRiotDesc.json")
                    assert(layer)
                    local labelDesc = layer:getLabelByName("Label_desc")
                    local panel = layer:getPanelByName("Panel_3")
                    assert(labelDesc)
                    local nFontSize = labelDesc:getFontSize()

      
                    local richText1 = GlobalFunc.createGameRichtext(self._data.riot_win_desc1, nFontSize, nil, Colors.strokeBrown)
                    if richText1 then 
                        local textSize = richText1:getSize()
                        panel:addChild(richText1)
                        richText1:setPosition(ccp(0, textSize.height/2 + 10))
                    end 

                    local richText2 = GlobalFunc.createGameRichtext(self._data.riot_win_desc2, nFontSize, nil, Colors.strokeBrown)
                    if richText2 then 
                        local textSize = richText2:getSize()
                        panel:addChild(richText2)
                        richText2:setPosition(ccp(0, textSize.height/2 - 20))
                    end 
                    labelDesc:setVisible(false)

                    return layer  
                -- 叛军相关
                elseif self._data.gongxun then 
                    local layer = UFCCSNormalLayer.new("ui_layout/fightend_RankUp_moshen.json")
                    -- 居中显示
                    local widthPanelRank = layer:getLabelByName("Label_new_rank1"):getContentSize().width +
                         layer:getLabelByName("Label_new_rank1"):getPositionX() - 
                         layer:getLabelByName("Label_title1"):getPositionX() - 50
                    layer:getLabelByName("Label_new_rank1"):createStroke(Colors.strokeBrown,1)
                    layer:getLabelByName("Label_old_rank1"):createStroke(Colors.strokeBrown,1)
                    layer:getLabelByName("Label_title1"):createStroke(Colors.strokeBrown,1)
                    layer:getLabelByName("Label_new_rank1"):setColor(Colors.darkColors.TIPS_01)
                    -- 名次上升  并且当前名次上榜
                    if self._data.gongxunRank < self._data.lastGongxunRank and self._data.gongxunRank ~= 0 then 
                        layer:getLabelByName("Label_old_rank1"):setText(self._data.lastGongxunRank)
                        layer:getLabelByName("Label_new_rank1"):setText(self._data.gongxunRank)
                        layer:getPanelByName("Panel_Rank_Up"):setPositionX(-widthPanelRank / 2 )
                    -- 未上榜到上榜
                    elseif self._data.gongxunRank > 0 and self._data.lastGongxunRank == 0 then 
                        layer:getLabelByName("Label_old_rank1"):setText(G_lang:get("LANG_WHEEL_NORANK"))
                        layer:getLabelByName("Label_new_rank1"):setText(self._data.gongxunRank)
                        layer:getPanelByName("Panel_Rank_Up"):setPositionX(-widthPanelRank / 2 )
                    else
                        layer:getPanelByName("Panel_Rank_Up"):setVisible(false)
                    end

                    layer:getLabelByName("Label_new_rank2"):createStroke(Colors.strokeBrown,1)
                    layer:getLabelByName("Label_old_rank2"):createStroke(Colors.strokeBrown,1)
                    layer:getLabelByName("Label_title2"):createStroke(Colors.strokeBrown,1)
                    layer:getLabelByName("Label_new_rank2"):setColor(Colors.darkColors.TIPS_01)
                    if self._data.harmRank < self._data.lastHarmRank and self._data.harmRank ~= 0 then 
                        layer:getLabelByName("Label_old_rank2"):setText(self._data.lastHarmRank)
                        layer:getLabelByName("Label_new_rank2"):setText(self._data.harmRank)
                        layer:getPanelByName("Panel_Rank_Up_0"):setPositionX(-widthPanelRank / 2)
                    elseif self._data.harmRank > 0 and self._data.lastHarmRank == 0 then 
                        layer:getLabelByName("Label_old_rank2"):setText(G_lang:get("LANG_WHEEL_NORANK"))
                        layer:getLabelByName("Label_new_rank2"):setText(self._data.harmRank)
                        layer:getPanelByName("Panel_Rank_Up_0"):setPositionX(-widthPanelRank / 2)
                    else
                        layer:getPanelByName("Panel_Rank_Up_0"):setVisible(false)
                    end
                    

                    return layer
                elseif self._data.new_rank then
                    local layer = UFCCSNormalLayer.new("ui_layout/fightend_RankUp.json")
                    if self._data.new_rank < self._data.old_rank then
                        -- return display.newNode()

                        layer:getLabelByName("Label_new_rank"):createStroke(Colors.strokeBrown,1)
                        layer:getLabelByName("Label_old_rank"):createStroke(Colors.strokeBrown,1)
                        layer:getLabelByName("Label_title"):createStroke(Colors.strokeBrown,1)
                        layer:getLabelByName("Label_new_rank"):setColor(Colors.darkColors.TIPS_01)
                        layer:getLabelByName("Label_new_rank"):setText(self._data.new_rank)
                        if self._data.old_rank then
                            layer:getLabelByName("Label_old_rank"):setText(self._data.old_rank)
                        else
                            layer:getLabelByName("Label_old_rank"):setText(G_lang:get("LANG_LEGION_RANK_NUMBER_NULL"))
                        end

                        -- 居中显示
                        local widthPanelRank = layer:getLabelByName("Label_new_rank"):getContentSize().width +
                             layer:getLabelByName("Label_new_rank"):getPositionX() - 
                             layer:getLabelByName("Label_title"):getPositionX()

                        local rankUpPanel = layer:getPanelByName("Panel_Rank_Up")
                        -- local panelRankUpWidth = rankUpPanel:getContentSize().width
                        rankUpPanel:setPositionX(-widthPanelRank / 2)
                    else
                        layer:showWidgetByName("Panel_Rank_Up", false)
                    end

                    -- 竞技场显示战胜了某某玩家
                    require("app.cfg.knight_info")
                    local knightInfo = knight_info.get(self._data.opponent.base_id)       
                    local color = Colors.qualityColors[knightInfo.quality]
                    layer:getLabelByName("Label_Opponent_Name"):setColor(color)
                    layer:getLabelByName("Label_Opponent_Name"):setText(self._data.opponent.name)
                    layer:getLabelByName("Label_Opponent_Name"):createStroke(Colors.strokeBrown, 1)

                    layer:getLabelByName("Label_Win_Tag"):createStroke(Colors.strokeBrown, 1)
                    layer:getLabelByName("Label_Exclamation"):createStroke(Colors.strokeBrown, 1)

                    -- 居中显示
                    local opponentInfoPanel = layer:getPanelByName("Panel_Show_Loser_Name")
                    -- local panelOpponentInfoWidth = opponentInfoPanel:getContentSize().width
                    -- __Log("getContentSize width = %d", panelOpponentInfoWidth)
                    local widthPanelOpp = layer:getLabelByName("Label_Win_Tag"):getContentSize().width +
                         layer:getLabelByName("Label_Opponent_Name"):getContentSize().width + 
                         layer:getLabelByName("Label_Exclamation"):getContentSize().width/3
                    opponentInfoPanel:setPositionX(-widthPanelOpp / 2)


                    layer:setClickSwallow(true)
                    return layer
                elseif self._data.crosswar_curWinStreak then
                    -- 跨服演武战斗胜利需要显示当前连胜
                    local layer = UFCCSNormalLayer.new("ui_layout/fightend_WinStreak.json")
                    layer:enableLabelStroke("Label_Current", Colors.strokeBrown, 1)
                    layer:enableLabelStroke("Label_WinNum", Colors.strokeBrown, 1)
                    layer:showTextWithLabel("Label_WinNum", self._data.crosswar_curWinStreak .. G_lang:get("LANG_ACTIVITY_CAISHEN_TITLE5_2"))
                    layer:setClickSwallow(true)
                    return layer
                elseif self._data.crusade_beat_user ~= nil then
                    local layer = UFCCSNormalLayer.new("ui_layout/fightend_CrusadeWin.json")
                    -- 显示战胜了某某玩家
                    require("app.cfg.knight_info")
                    local knightInfo = knight_info.get(self._data.crusade_beat_user.main_role)       
                    local color = Colors.qualityColors[knightInfo.quality]
                    layer:getLabelByName("Label_Opponent_Name"):setColor(color)
                    layer:getLabelByName("Label_Opponent_Name"):setText(self._data.crusade_beat_user.name)
                    layer:getLabelByName("Label_Opponent_Name"):createStroke(Colors.strokeBrown, 1)
                    layer:getLabelByName("Label_Win_Tag"):createStroke(Colors.strokeBrown, 1)

                    -- 居中显示
                    local opponentInfoPanel = layer:getPanelByName("Panel_Show_Loser_Name")
                    local widthPanelOpp = layer:getLabelByName("Label_Win_Tag"):getContentSize().width +
                         layer:getLabelByName("Label_Opponent_Name"):getContentSize().width + 
                         layer:getLabelByName("Label_Exclamation"):getContentSize().width/3
                    opponentInfoPanel:setPositionX(-widthPanelOpp / 2)
                    opponentInfoPanel:setPositionY(opponentInfoPanel:getContentSize().height/2)
                    layer:setClickSwallow(true)

                    return layer

                elseif self._data.robrice_win then
                    -- 争粮战抢夺胜利需要显示说明文字
                    local layer = UFCCSNormalLayer.new("ui_layout/fightend_RobRice.json")

                    -- 竞技场显示战胜了某某玩家
                    require("app.cfg.knight_info")
                    local knightInfo = knight_info.get(self._data.opponent.baseId)       
                    local color = Colors.qualityColors[knightInfo.quality]
                    layer:getLabelByName("Label_Opponent_Name"):setColor(color)
                    layer:getLabelByName("Label_Opponent_Name"):setText(self._data.opponent.name)
                    layer:getLabelByName("Label_Opponent_Name"):createStroke(Colors.strokeBrown, 1)
                    layer:getLabelByName("Label_Rice"):setText(G_lang:get("LANG_ROB_RICE_ROB_INIT_RICE", {num = self._data.robrice_win}))
                    layer:getLabelByName("Label_Rice"):createStroke(Colors.strokeBrown, 1)
                    layer:getLabelByName("Label_Title"):createStroke(Colors.strokeBrown, 1)
                    layer:getLabelByName("Label_Win_Tag"):createStroke(Colors.strokeBrown, 1)

                    -- 居中显示
                    local opponentInfoPanel = layer:getPanelByName("Panel_Show_Loser_Name")
                    local widthPanelOpp = layer:getLabelByName("Label_Win_Tag"):getContentSize().width +
                         layer:getLabelByName("Label_Opponent_Name"):getContentSize().width + 
                         layer:getLabelByName("Label_Exclamation"):getContentSize().width/3
                    opponentInfoPanel:setPositionX(-widthPanelOpp / 2)

                    local riceInfoPanel = layer:getPanelByName("Panel_Rice_Info")
                    local widthPanelRice = layer:getLabelByName("Label_Title"):getContentSize().width +
                            layer:getLabelByName("Label_Rice"):getContentSize().width
                    riceInfoPanel:setPositionX(-widthPanelRice / 2)


                    layer:setClickSwallow(true)

                    return layer
                elseif self._data.crosspvp_win then
                    local layer = UFCCSNormalLayer.new("ui_layout/fightend_RankUp.json")

                    -- "恭喜少年战胜玩家XXXX"
                    local labelCongratulation = layer:getLabelByName("Label_Win_Tag")
                    if labelCongratulation then
                        labelCongratulation:createStroke(Colors.strokeBrown, 1)
                    end
                    local labelName = layer:getLabelByName("Label_Opponent_Name")
                    if labelName then
                        labelName:createStroke(Colors.strokeBrown, 1)
                        labelName:setText(self._data.enemyName)
                        labelName:setColor(self._data.enemyColor)
                    end
                    -- 成功占领, xx坑
                    local labelEngaged = layer:getLabelByName("Label_title")
                    if labelEngaged then
                        labelEngaged:createStroke(Colors.strokeBrown, 1)
                        labelEngaged:setText(G_lang:get("LANG_CROSS_PVP_ENGAGED_SUCC"))
                    end
                    local labelArena = layer:getLabelByName("Label_old_rank")
                    if labelArena then
                        labelArena:createStroke(Colors.strokeBrown, 1)
                        labelArena:setText(self._data.arenaName)
                        labelArena:setColor(self._data.arenaColor)
                    end

                    layer:showWidgetByName("Image_Arrow", false)
                    layer:showWidgetByName("Label_new_rank", false)

                    -- 设置位置
                    local nWidth = labelCongratulation:getSize().width + 
                                   labelName:getSize().width + 
                                   layer:getLabelByName("Label_Exclamation"):getSize().width       
                    local panel = layer:getPanelByName("Panel_Show_Loser_Name")
                    if panel then
                        panel:setPositionX(panel:getPositionX() - nWidth/2)
                    end
                    nWidth = labelEngaged:getSize().width + labelArena:getSize().width
                    panel = layer:getPanelByName("Panel_Rank_Up")
                    if panel then
                        panel:setPositionX(panel:getPositionX() - nWidth/2)
                    end

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
                            local labelParent = label:getParent()
                            labelParent:addChild(label2)
                            local x, y = label:getPosition()
                            label2:setPositionXY(x,y-26)
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
            if  event == "stars" then
                if self._star ~= nil and self._star > 0 then
                    self._effect:pause()
                    self._node:pause()
                end
                if self._ex_star ~= nil and self._ex_star > 0 then
                    self._effect:pause()
                    self._node:pause()
                end

            elseif event=="finish" and self._endCallback ~= nil then

                self._endCallback()
                self._endCallback  = nil
                
            end
        end
    )

    
    self:addChild(self._node)
    self._node:play()
end




function BeginStarWin:_finishStars()
    
    self._starsAnimation:stop()
    self._node:resume()
    self._effect:resume()
    
end
function BeginStarWin:onExit()
    self:setNodeEventEnabled(false)
    if self._node then
        self._node:stop()
    end
    
end




local sortKnightsFunc = function(a,b)
    local ka = G_Me.bagData.knightsData:getKnightByKnightId(a)
    local kb = G_Me.bagData.knightsData:getKnightByKnightId(b)

    return ka.level > kb.level
end

--取到最多3个上阵侠客ID, 第一个是主角, 其他2个挑等级最高的
function BeginStarWin.getFirst3Knights()
    local ids1 = G_Me.formationData:getFirstTeamKnightIds()

    if #ids1 < 3 then
        local ids2 = G_Me.formationData:getSecondTeamKnightIds()
        for i=1,#ids2 do
            if ids2[i] and ids2[i] > 0 then 
                table.insert(ids1, ids2[i])
            end
        end
    end 
    --第一个肯定是主角, 先排除
    local mainKnightId = table.remove(ids1, 1)
    --根据强化等级排序
    table.sort(ids1, sortKnightsFunc)
    table.insert(ids1, 1, mainKnightId)
    local knightResIds = {}
    for i=1,#ids1 do
        if #knightResIds < 3 then 
            local kight = G_Me.bagData.knightsData:getKnightByKnightId(ids1[i])
            local baseInfo = knight_info.get(kight.base_id)
            table.insert(knightResIds, baseInfo.res_id)
        else 
            break
        end
    end
    return knightResIds
end

return BeginStarWin