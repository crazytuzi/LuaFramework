--[[
文件名:CacheFashion.lua
描述：绝学数据抽象类型
创建人：peiyaoqiang
创建时间：2017.09.09
--]]

-- 绝学数据说明
--[[
    服务器返回的绝学数据，每条格式格式为：
    {
        Id:        实体ID
        ModelId:   模型ID
        IsDressIn: 是否穿戴
        Step:      进阶信息
    },
--]]

local CacheFashion = class("CacheFashion", {})

--[[
--]]
function CacheFashion:ctor()
    self.myFashionList = {}
end

-- 清空管理对象中的数据
function CacheFashion:reset()
   self.myFashionList = {}
end

-- 获取玩家拥有的时装列表
function CacheFashion:getFashionList(callFunc)
    if (table.nums(self.myFashionList) > 0) then
        callFunc(clone(self.myFashionList))
        return
    end

    -- 如果还没有数据，就请求服务器
    HttpClient:request({
        moduleName = "Fashion",
        methodName = "GetFashionInfo",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.myFashionList = clone(response.Value.FashionInfo)
            if callFunc then
                callFunc(clone(self.myFashionList))
            end
        end,
    })
end

-- 刷新玩家拥有的时装列表（学习之后主动调用）
function CacheFashion:refreshFashionList(callFunc)
    self.myFashionList = {}
    self:getFashionList(callFunc)
end

-- 返回某个特定种类的时装
function CacheFashion:getGuidByModelId(modelId)
    if (modelId == nil) then
        return nil
    end

    -- 0表示不穿戴任何时装的主角
    if (modelId == 0) then
        return EMPTY_ENTITY_ID
    end

    -- 找到任意一个即可
    local retGuid = nil
    for _,v in pairs(self.myFashionList) do
        if (v.ModelId == modelId) then
            retGuid = v.Id
            break
        end
    end

    return retGuid
end

-- 返回特定种类的全部可用时装ID（保留进阶最高或已上阵）
function CacheFashion:getFashionGuidList(modelId)
    if (modelId == nil) then
        return nil
    end

    -- 0表示不穿戴任何时装的主角
    if (modelId == 0) then
        return {EMPTY_ENTITY_ID}
    end

    -- 查找该时装需保留的时装
    local fashionInfo = self:getStepFashionInfo(modelId)
    -- 返回全部的未上阵时装
    local retList = {}
    for _,v in pairs(self.myFashionList) do
        if (v.ModelId == modelId) and (fashionInfo.Id ~= v.Id) then
            table.insert(retList, v.Id)
        end
    end

    return retList
end

-- 判断某种时装是否已拥有
function CacheFashion:getOneItemOwned(modelId)
    if (modelId == nil) then
        return false
    end

    -- 0表示不穿戴任何时装的主角
    if (modelId == 0) then
        -- 永远已存在
        return true
    end

    -- 只要拥有任意一个即可
    local retOwned = false
    for _,v in pairs(self.myFashionList) do
        if (v.ModelId == modelId) then
            retOwned = true
            break
        end
    end

    return retOwned
end

-- 判断某种时装是否已穿戴
function CacheFashion:getOneItemDressIn(modelId)
    if (modelId == nil) then
        return false
    end

    -- 0表示不穿戴任何时装的主角
    if (modelId == 0) then
        -- 如果所有时装都未穿戴，则视为穿戴了主角
        local isMainHeroDress = true
        for _,v in pairs(self.myFashionList) do
            if (v.IsDressIn == true) then
                isMainHeroDress = false
                break
            end
        end
        return isMainHeroDress
    end

    -- 只要有任意一个上阵即可
    local retDressIn = false
    for _,v in pairs(self.myFashionList) do
        if (v.ModelId == modelId) and (v.IsDressIn == true) then
            retDressIn = true
            break
        end
    end

    return retDressIn
end

-- 设置某种时装已穿戴
function CacheFashion:setOneItemDressIn(fashionId)
    if (fashionId == nil) then
        return false
    end

    -- 标记上阵时装并把其他的穿戴标记清空
    for _,v in pairs(self.myFashionList) do
        if v.Id == fashionId then
            v.IsDressIn = true
        else
            v.IsDressIn = false
        end
    end
end

-- 判断某种时装的进阶
function CacheFashion:getOneItemStep(modelId)
    if (modelId == nil) then
        return 0
    end

    -- 0表示不穿戴任何时装的主角
    if (modelId == 0) then
        -- 不能进阶
        return 0
    end

    -- 找出最大的进阶
    local retStep = 0
    for _,v in pairs(self.myFashionList) do
        if (v.ModelId == modelId) and (v.Step > retStep) then
            retStep = v.Step
        end
    end

    return retStep
end

-- 设置某种时装的进阶
--[[
    参数:guid            时装实体id
        newStep         当前进阶
        BackUpUseSteps  使用参悟丹的阶数
]] 
function CacheFashion:setOneItemStep(guid, newStep, BackUpUseSteps)
    if (guid == nil) then
        return
    end

    -- 先把所有的穿戴标记清空
    for _,v in pairs(self.myFashionList) do
        if (v.Id == guid) then
            v.Step = newStep
            v.BackUpUseSteps = BackUpUseSteps
            break
        end
    end
end

-- 获取某个时装的拥有数量
--[[
    ignoreDressIn : 是否忽略已上阵的，默认为false
--]]
function CacheFashion:getFashionCount(modelId, ignoreDressIn)
    if (modelId == nil) then
        return 0
    end

    -- 默认的无时装形象，永远存在，且数量为1
    if (modelId == 0) then
        return 1
    end

    -- 遍历某个时装的数量
    local retNum = 0
    for _,v in pairs(self.myFashionList) do
        if (v.ModelId == modelId) then
            if (ignoreDressIn ~= nil) and (ignoreDressIn == true) and (v.IsDressIn == true) then
            else
                retNum = retNum + 1
            end
        end
    end

    return retNum
end

-- 获取某类时装有进阶最高的实体信息(如果该类时装已上阵则返回上阵时装)
function CacheFashion:getStepFashionInfo(modelId)
    if (modelId == nil) then
        return nil
    end

    -- 默认的无时装形象时阶数0
    if (modelId == 0) then
        return nil
    end

    -- 查找该时装
    local fashionInfo = nil
    local tempStep = 0

    for _,v in pairs(self.myFashionList) do
        if (v.ModelId == modelId) and v.IsDressIn then
            fashionInfo = clone(v)
            break
        elseif (v.ModelId == modelId) and tempStep <= v.Step then
            fashionInfo = clone(v)
            tempStep = v.Step
        end
    end

    return fashionInfo
end

-- 获取能分解的时装列表
function CacheFashion:getRefineFashionList()
    -- 时装分解列表
    local fashionRefineList = {}
    -- 时装计数列表
    local fashionCountList = {}
    -- 拷贝时装列表
    local tempFashionList = {}
    for _,v in pairs(self.myFashionList) do
        table.insert(tempFashionList, v)
    end
    -- 为了方便筛选进行排序
    table.sort(tempFashionList, function (fashion1, fashion2)
        -- 已上阵的在前面
        if fashion1.IsDressIn ~= fashion2.IsDressIn then
            return fashion1.IsDressIn
        end
        -- 进阶等级高的在前面
        if fashion1.Step ~= fashion2.Step then
            return fashion1.Step > fashion2.Step
        end

        return fashion1.ModelId < fashion2.ModelId
    end)

    for _,v in pairs(tempFashionList) do
        -- 计数(经过排序在前面有进阶等级或已上阵的时装会优先最为保底的最后一件)
        fashionCountList[v.ModelId] = fashionCountList[v.ModelId] or 0
        fashionCountList[v.ModelId] = fashionCountList[v.ModelId] + 1
        -- 没有进阶等级且没有被穿戴且不是保底的最后一件
        if v.Step <= 0 and v.IsDressIn == false and fashionCountList[v.ModelId] > 1 then
            table.insert(fashionRefineList, clone(v))
        end
    end

    return fashionRefineList
end

-- 删除某个指定的时装
function CacheFashion:delOneItem(guid)
    if (guid == nil) then
        return
    end

    for i,v in ipairs(self.myFashionList) do
        if (v.Id == guid) then
            table.remove(self.myFashionList, i)
            break
        end
    end
end

-- 更新时装列表
function CacheFashion:updateFashionList(fashionList)
    if (fashionList == nil) then
        return
    end

    self.myFashionList = fashionList
end

return CacheFashion