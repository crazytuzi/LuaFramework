local _M = {}
_M.__index = _M
local Util = require 'Zeus.Logic.Util'

function _M.GetAttrScoreByBaseAttr(attrs)
    local score = 0
    local maxScore = 0
    for i = 1, #(attrs) do
        local attr = attrs[i]
        local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)
        if attrdata ~= nil  then
            score = math.ceil (score + attr.value*attrdata.ScoreRatio)
            maxScore = maxScore + attr.maxValue*attrdata.ScoreRatio
        end 
    end
    return score,maxScore
end

 function _M.GetAttrQualityByScore(score,maxScore)
    local precent = Mathf.Round(score*100/maxScore)
    if precent > 95 then
        return 4
    elseif precent > 85 and precent <= 95 then
        return 3
    elseif precent > 70 and precent <= 85 then
        return 2    
    elseif precent > 30 and precent <= 70 then
        return 1 
    else
        return 0
    end
    return 5 
end


return _M
