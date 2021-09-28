
require("app.cfg.dead_battle_info")
local KnightPic = require("app.scenes.common.KnightPic")
local EffectNode = require "app.common.effects.EffectNode"

local WushFastAward = class("WushFastAward", function (  )
    return CCSItemCellBase:create("ui_layout/wush_fastAward.json")
end)

function WushFastAward:ctor()
    self._title = self:getLabelByName("Label_title") 
    self._title:createStroke(Colors.strokeBrown, 1)
    self._descLabel = self:getLabelByName("Label_desc") 
    self._awardPanel = self:getPanelByName("Panel_award")

    self._descLabel:setVisible(false)
    self._awardPanel:setVisible(false)
end

function WushFastAward:updateView(floorId)
    local ceng = math.floor((floorId)/3) - 1
    local floorStar = G_Me.wushData:calcCurStar(ceng*3+1,ceng*3+3)
    local str = G_lang:get("LANG_WUSH_FIGHTAWARDEND",{floormin=(ceng*3+1),floormax=(ceng*3+3),star=floorStar})
    self._descLabel:setText(str)
    local award = {}
    local info = dead_battle_info.get(ceng*3+3)
    local found = false
    for k = 1,3 do 
        local i = 4 - k
        local starNeed = info["type_star_"..i]
        if floorStar >= starNeed and not found then
            found = true
            -- local awardData = dead_battle_award_info.get(info["type_award_"..i])

            -- for j = 1,3 do 
            --     if awardData["type_"..j] ~= 0 then
            --         local awardCell = {type=awardData["type_"..j],value=awardData["value_"..j],size=awardData["size_"..j]}
            --         table.insert(award,#award+1,awardCell) 
            --     end
            -- end
            award = G_Me.wushData:getAwardById(info["type_award_"..i])
        end
    end
    GlobalFunc.createIconInPanel({panel=self._awardPanel,award=award,click=true})
end

function WushFastAward:start(callback)
    local time = 0.01
    local widget = self
    local delay1 = CCDelayTime:create(time)
    local delay2 = CCDelayTime:create(time)
    local func1 = CCCallFunc:create(function()
                    self._descLabel:setVisible(true)
                    self._awardPanel:setVisible(true)
            end)
    local func2 = CCCallFunc:create(function()
                    callback()
            end)
    local arr = CCArray:create()
    arr:addObject(delay1)
    arr:addObject(func1)
    arr:addObject(delay2)
    arr:addObject(func2)
    widget:runAction(CCSequence:create(arr))
end


return WushFastAward