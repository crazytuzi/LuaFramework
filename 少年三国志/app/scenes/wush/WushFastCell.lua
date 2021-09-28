
require("app.cfg.dead_battle_info")
local KnightPic = require("app.scenes.common.KnightPic")
local EffectNode = require "app.common.effects.EffectNode"

local WushFastCell = class("WushFastCell", function (  )
    return CCSItemCellBase:create("ui_layout/wush_fastCell.json")
end)

function WushFastCell:ctor()

    self._title = self:getLabelByName("Label_title") 
    self._title:createStroke(Colors.strokeBrown, 1)

    self._type1 = self:getLabelByName("Label_type1") 
    self._type2 = self:getLabelByName("Label_type2") 
    self._icon1 = self:getImageViewByName("Image_icon1") 
    self._icon2 = self:getImageViewByName("Image_icon2") 
    self._value1 = self:getLabelByName("Label_value1") 
    self._value2 = self:getLabelByName("Label_value2") 
    self._baoji1 = self:getLabelByName("Label_baoji1") 
    self._baoji2 = self:getLabelByName("Label_baoji2") 
    self._fail1 = self:getLabelByName("Label_fail1") 
    self._fail2 = self:getLabelByName("Label_fail2") 
    self._panel = self:getPanelByName("Panel_all")
    self._loseImg = self:getImageViewByName("Image_lose")

    self._type1:setVisible(false)
    self._type2:setVisible(false)
    self._icon1:setVisible(false)
    self._icon2:setVisible(false)
    self._value1:setVisible(false)
    self._value2:setVisible(false)
    self._baoji1:setVisible(false)
    self._baoji2:setVisible(false)
    self._fail1:setVisible(false)
    self._fail2:setVisible(false)
    self._panel:setVisible(false)
    self._loseImg:setVisible(false)

end

function WushFastCell:updateView(floorId,data,win)
    self._title:setText(G_lang:get("LANG_WUSH_CENGSHU",{floor=floorId}))
    self._win = win
    if self._win then
        self:initWin(floorId,data)
    else
        self:initLose(floorId,data)
    end
end

function WushFastCell:initWin(floorId,data)
    local info = dead_battle_info.get(floorId)
    local index = data.index + 1
    local _tower_score = info["tower_score_"..index]
    local _tower_money = info["coins_"..index]
    if G_Me.activityData.custom:isWushActive() then   --威名翻倍
      _tower_score = _tower_score * 2
    end

    local award = data.award
    local score = 0
    local money = 0
    for k, v in pairs(award) do 
        if v.type == G_Goods.TYPE_MONEY then
            money = v.size
        elseif v.type == G_Goods.TYPE_CHUANGUAN then
            score = v.size
        end
    end

    local delta1 = score/_tower_score
    -- print("delta1  "..delta1.."    "..score.."/".._tower_score)
    if delta1 == 1 then
        self._baoji1:setColor(Colors.qualityColors[4])
        self._baoji1:setText(G_lang:get("LANG_FIGHTEND_BAO_JI"))
        self._baoji1:setVisible(true)
    elseif delta1 == 1.2 then
        self._baoji1:setText(G_lang:get("LANG_FIGHTEND_DA_BAO_JI"))
        self._baoji1:setColor(Colors.qualityColors[4])
        self._baoji1:setVisible(true)
    elseif delta1 == 1.6 then
        self._baoji1:setText(G_lang:get("LANG_FIGHTEND_XING_YUN_BAO_JI"))
        self._baoji1:setColor(Colors.qualityColors[5])
        self._baoji1:setVisible(true)
    end
    local delta2 = money/_tower_money
    -- print("delta2  "..delta2.."    "..money.."/".._tower_money)
    if delta2 == 1 then
        self._baoji2:setColor(Colors.qualityColors[4])
        self._baoji2:setText(G_lang:get("LANG_FIGHTEND_BAO_JI"))
        self._baoji2:setVisible(true)
    elseif delta2 == 1.2 then
        self._baoji2:setText(G_lang:get("LANG_FIGHTEND_DA_BAO_JI"))
        self._baoji2:setColor(Colors.qualityColors[4])
        self._baoji2:setVisible(true)
    elseif delta2 == 1.6 then
        self._baoji2:setText(G_lang:get("LANG_FIGHTEND_XING_YUN_BAO_JI"))
        self._baoji2:setColor(Colors.qualityColors[5])
        self._baoji2:setVisible(true)
    end

    self._type1:setText(G_lang:get("LANG_WUSH_FIGHTAWARD1"))
    self._type2:setText(G_lang:get("LANG_WUSH_FIGHTAWARD2"))
    self._value1:setText(score)
    self._value2:setText(money)
    self._type1:setVisible(true)
    self._type2:setVisible(true)
    self._value1:setVisible(true)
    self._value2:setVisible(true)
    self._icon1:setVisible(true)
    self._icon2:setVisible(true)
end

function WushFastCell:initLose(floorId,data)
    local info = dead_battle_info.get(floorId)
    local _type = info.success_type
    self._fail1:setText(info.success_directions)
    self._fail2:setText(self:_fastChallenge(data,_type))
    self._type1:setText(G_lang:get("LANG_WUSH_FIGHTAWARD3"))
    self._type2:setText(G_lang:get("LANG_WUSH_FIGHT".._type))
    self._fail1:setVisible(true)
    self._fail2:setVisible(true)
    self._type1:setVisible(true)
    self._type2:setVisible(true)
end

function WushFastCell:_fastChallenge(data,_type )

    local report = data.battle_report
    local parser = require("app.scenes.battle.BattleReportParser").parse(report)
    -- print("getKnightUpAmount  "..parser:getKnightUpAmount(1))
    -- print("getLeftKnightUpAmount  "..parser:getLeftKnightUpAmount(1))
    -- print("getKnightTotalHP  "..parser:getKnightTotalHP(1))
    -- print("getLeftKnightHP  "..parser:getLeftKnightHP(1))
    -- print("getRound  "..parser:getRound())
    -- self._buff:updateRound(self._battleField:getRound())
    -- self._buff:updateSelfHp(string.format("%.1f", self._battleField:getKnightCurrentHP(1)/self._selfHp*100).."%")
    -- self._buff:updateEnemyHp(string.format("%.1f", self._battleField:getKnightCurrentHP(2)/self._enemyHp*100).."%")
    -- self._buff:updateSelfDead(self._battleField:getHeroKnightUpAmount() - self._battleField:getLeftHeroKnightAmount())
    if _type == 1 then
        return parser:getRound()
    elseif _type == 2 then
        return parser:getKnightUpAmount(1) - parser:getLeftKnightUpAmount(1)
    elseif _type == 3 then
        return string.format("%.1f", parser:getLeftKnightHP(1)/parser:getKnightTotalHP(1)*100).."%"
    elseif _type == 4 then
        return string.format("%.1f", parser:getLeftKnightHP(2)/parser:getKnightTotalHP(2)*100).."%"
    else
        return G_lang:get("LANG_WUSH_NO")
    end
end

function WushFastCell:start(callback)
    local time = 0.01
    local widget = self
    local delay1 = CCDelayTime:create(time)
    local delay2 = CCDelayTime:create(time)
    local func1 = CCCallFunc:create(function()
                    self._panel:setVisible(true)
            end)
    local func2 = CCCallFunc:create(function()
                    callback()
            end)
    local arr = CCArray:create()
    arr:addObject(delay1)
    arr:addObject(func1)
    if not self._win then
        self._loseImg:setVisible(true)
        self._loseImg:setScale(5.0)
        local scaleAction = CCScaleTo:create(0.3,1)
        arr:addObject(CCEaseBackOut:create(scaleAction))
        widget = self._loseImg
    end
    arr:addObject(delay2)
    arr:addObject(func2)
    widget:runAction(CCSequence:create(arr))
end


function WushFastCell:updateBuff(buffId)
    self._win = true
    local skill = passive_skill_info.get(buffId)
    local desc,value = G_Me.wushData.convertAttrTypeAndValue(skill.affect_type,skill.affect_value)
    self._fail1:setText(desc.."+"..value)
    self._fail2:setText(G_lang:get("LANG_WUSH_FIGHT_STAR",{star=G_Me.wushData:getBuffToChooseIndex()*3}))
    self._type1:setText(G_lang:get("LANG_WUSH_FIGHT_BUFF1"))
    self._type2:setText(G_lang:get("LANG_WUSH_FIGHT_BUFF2"))
    self._title:setText(G_lang:get("LANG_WUSH_BUFF_CHOOSE"))
    self._fail1:setVisible(true)
    self._fail2:setVisible(true)
    self._type1:setVisible(true)
    self._type2:setVisible(true)
end

return WushFastCell


