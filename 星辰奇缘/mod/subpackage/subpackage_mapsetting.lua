-- 分包处理 地图切片设置
-- @author ljh
-- @date 20160613
SubpackageMapSetting = SubpackageMapSetting or BaseClass()

function SubpackageMapSetting:__init()

end

function SubpackageMapSetting:__delete()
end

function SubpackageMapSetting:Resources(resData)
    -- 这里需要检查
    if not SubpackageManager.Instance.IsSubPackage then
        return resData
    else
        local usePack = false
        local newResData = {}
        local requestRes = {}
        for _, value in ipairs(resData) do
            if CSSubpackageManager.GetInstance():HaveSubpackageFileSingle(value.file) then
                table.insert(requestRes, value.file)
                usePack = true
            else
                table.insert(newResData, value)
            end
        end

        if not usePack then
            return resData
        else
            CSSubpackageManager.GetInstance():AddOptimalFile(requestRes)
            return newResData
        end
    end
end
