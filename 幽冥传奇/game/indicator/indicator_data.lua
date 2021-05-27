IndicatorData = IndicatorData or BaseClass()

function IndicatorData:__init()
    if IndicatorData.Instance then
        ErrorLog("[IndicatorData]:Attempt to create singleton twice!")
    end
    IndicatorData.Instance = self
end

function IndicatorData:__delete()
    IndicatorData.Instance = nil

end

function IndicatorData.CanShowIndicatorBar(level)
    for i, v in ipairs(SystemOpenCfg.openList) do
        if level >= v.showLevel and level < v.openLevel then
            return true, v.openLevel - level
        end
    end
    return false
end

function IndicatorData.GetOpenCfgByLevel(level)
    for i, v in ipairs(SystemOpenCfg.openList) do
        if level >= v.showLevel and level < v.openLevel then
            return v
        end
    end
end

function IndicatorData.GetOpenCfgById(id)
    for i, v in ipairs(SystemOpenCfg.openList) do
        if v.id == id then
            return v
        end
    end
end

