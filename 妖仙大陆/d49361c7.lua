local _M = {}
_M.__index = _M


function _M.EquationDmg(DmgRate, DmgRatePerLvl, level)
    
    return (DmgRate + (level - 1) * DmgRatePerLvl) / 10000
end

function _M.EquationExdDmg(ExdDmgSet, level)
    
    local retArray = split(ExdDmgSet, ";")
    if #retArray >= level then
        return split(retArray[level], ":")[2]
    end
    return 0
end

function _M.EquationChance(Chance)
    
    return Chance / 100
end

function _M.EquationBuffTime(BuffTime, level)
    
    local retArray = split(BuffTime, ";")
    if #retArray >= level then
        return split(retArray[level], ":")[2] / 1000
    end
    return 0
end

function _M.EquationValueSet(ValueAttribute, ValueSet, level)
    
    local retArray = split(ValueSet, ";")
    if #retArray >= level then
        if ValueAttribute == 1 then
            return split(retArray[level], ":")[2] / 100
        else
            return split(retArray[level], ":")[2]
        end
    end
    return 0
end

function _M.EquationUpReqLevel(UpReqLevel, level)
    
    local retArray = split(UpReqLevel, ";")
    if #retArray >= level then
        return retArray[level]
    end
    return 0
end

function _M.EquationCostMan(CostManaSet, level)
    
    local retArray = split(CostManaSet, ";")
    if #retArray >= level then
        return split(retArray[level], ":")[2]
    end
    return 0
end

function _M.EquationType(skilldata, needtype, level)
    
    if needtype == 1 then
        return _M.EquationDmg(skilldata.DmgRate, skilldata.DmgRatePerLvl, level)
    elseif needtype == 2 then
        return _M.EquationExdDmg(skilldata.ExdDmgSet, level)
    elseif needtype == 3 then
        return _M.EquationChance(skilldata.Chance, level)
    elseif needtype == 4 then
        return _M.EquationBuffTime(skilldata.BuffTime, level)
    elseif needtype == 5 then
        return _M.EquationValueSet(skilldata.ValueAttribute1, skilldata.ValueSet, level)
    elseif needtype == 6 then
        return _M.EquationValueSet(skilldata.ValueAttribute2, skilldata.ValueSet2, level)
    elseif needtype == 7 then
        return _M.EquationValueSet(skilldata.ValueAttribute3, skilldata.ValueSet3, level)
    end
end

function _M.EquationBookCost(Qcolor, level)
    
    local search_t = {SkillLv = level}
    local ret = GlobalHooks.DB.Find('BookCost',search_t)
    if ret ~= nil and #ret > 0 then
        if Qcolor == 2 then
            return ret[1].Blue
        elseif Qcolor == 3 then
            return ret[1].Purple
        elseif Qcolor == 4 then
            return ret[1].Orange
        elseif Qcolor == 5 then
            return ret[1].Red
        end
    end
    return 0
end

function _M.EquationLockCost(num)
    
    local search_t = {Slot = num}
    local ret = GlobalHooks.DB.Find('LockCost',search_t)
    if ret ~= nil and #ret > 0 then
        return ret[1].Cost
    end
    return 0
end

function _M.PetConfigValue(key)
    
    local search_t = {ParamName = key}
    local ret = GlobalHooks.DB.Find('PetConfig',search_t)
    if ret ~= nil and #ret > 0 then
        if ret[1].ParamType == "NUMBER" then
            return tonumber(ret[1].ParamValue)
        else
            return ret[1].ParamValue
        end
    end
    return 0
end

return _M
