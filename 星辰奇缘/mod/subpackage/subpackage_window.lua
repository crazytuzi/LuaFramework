-- 分包处理 窗口资源
-- @author huangyq
-- @date 2016-10-11
SubpackageWindowSetting = SubpackageWindowSetting or BaseClass()

function SubpackageWindowSetting:__init()
end

function SubpackageWindowSetting:__delete()
end

function SubpackageWindowSetting:Resources(resData)
end

function SubpackageWindowSetting:CheckFile(requestRes)
    if not SubpackageManager.Instance.IsSubPackage then
        return false 
    end
    local requestList = {}
    for _, data in ipairs(requestRes) do
        table.insert(requestList, data.file)
    end
    local needDownload = false
    if CSSubpackageManager.GetInstance():HaveSubpackageFile(requestList) then
        CSSubpackageManager.GetInstance():AddOptimalFile(requestList)
        needDownload = true
    else
        needDownload = false
    end
    return  needDownload
end
