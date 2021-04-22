--
-- 觉醒重生数据类

local QBaseModel = import("...models.QBaseModel")
local QAwakeningRebirth = class("QAwakeningRebirth", QBaseModel)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

local QTextFiledScrollUtils = import("...utils.QTextFiledScrollUtils")

-- 顶部数字滚动变化的时间
QAwakeningRebirth.NUMBER_TIME = 0.5

function QAwakeningRebirth:ctor()
    QAwakeningRebirth.super.ctor(self)
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

-- 重置觉醒重生数据
function QAwakeningRebirth:initData(tfNodeProxy)
    self._decomposeList = {}            -- 计算用的列表，记录每种返还道具数量，tf的callback和文本滚动更新对象
    self._consumeItems = {}             -- 选中列表，给协议用的
    self._compensations = {}            -- 返还列表，给提示对话框用的
    self._data = {}                     -- 数据列表，包含可重生道具id，数量，选中数量，量表中配置的返还信息
    self._dataCount = 0
    self._tfNodeProxy = tfNodeProxy     -- 用来获取tf节点的代理

    self._data = remote.items:getAllAwakeningRebirth()
    self._dataCount = #self._data
end

-- 得到所有可以觉醒饰品重生的物品
function QAwakeningRebirth:getData()
    return self._data
end

-- 获取数据数量
function QAwakeningRebirth:getDataCount()
    return self._dataCount
end

-- 根据index获取数据
function QAwakeningRebirth:getDataByIndex(index)
    return self._data[index]
end

-- 更新选中数值
function QAwakeningRebirth:updataSelected(index, proxy)
    proxy = proxy or function(v) return v + 1 end

    local data = self._data[index]
    if data then
        local tSelectCount = proxy(data.selectedCount)
        if tSelectCount >= 0 and tSelectCount <= data.count then
            data.selectedCount = tSelectCount
            self:_updataItemsInfo()
            return true
        end
    end
    return false
end

-- 获取选中物品的返还列表
function QAwakeningRebirth:getCompensations()
    if q.isEmpty(self._compensations) then
        return self:_calcCompensations()
    end
    return self._compensations or {}
end

-- 获取选中物品的列表
function QAwakeningRebirth:getConsumeItems()
    if q.isEmpty(self._consumeItems) then
        return self:_calcConsumeItems()
    end
    return self._consumeItems or {}
end

-- 检查是否有选中物品
function QAwakeningRebirth:checkIsSelected()
    return not q.isEmpty(self:getConsumeItems())
end

-- 返还列表停止所有更新
function QAwakeningRebirth:stopUpdata()
    if not q.isEmpty(self._decomposeList) then
        for _, target in pairs(self._decomposeList) do
            if target then
                target.textFiledScroll:stopUpdate()
                target = nil
            end
        end
    end
end

-- 觉醒重生
function QAwakeningRebirth:onAwakeningRebirth(dialogTitle, dialogTip, onDoCallback)

    local callFunc = function()
        app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
        self:_onAwakeningRebirthRequest(self:getConsumeItems())
        
        if onDoCallback then
            onDoCallback()
        end

        self._consumeItems = {}
        self._compensations = {}
    end

    app:getNavigationManager():pushViewController(app.middleLayer, {
        uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogHeroRebornCompensation", 
        options = {
            compensations = self:getCompensations(), 
            callFunc = callFunc, 
            title = dialogTitle, 
            tips = dialogTip
        }
    })
end





-------------------------
-- 以下为私有内容

-- 统计选择信息
function QAwakeningRebirth:_statisticsSelect()
    for key, _ in pairs(self._decomposeList) do
        self._decomposeList[key].count = 0
    end

    for _, data in ipairs(self._data) do
        for id, decInfo in pairs(data.decompose) do
            local decItemId = decInfo.id
            local tfNode = self._tfNodeProxy(decItemId)
            if tfNode then
                if q.isEmpty(self._decomposeList[decItemId]) then
                    local tfUpdataCallback = function(value)
                        tfNode:setString(tostring(math.ceil(value)))
                    end
                    self._decomposeList[decItemId] = {
                        count = 0,
                        tfNode = tfNode,
                        textFiledScroll = QTextFiledScrollUtils.new(),
                        tfUpdataCallback = tfUpdataCallback
                    }
                end
                self._decomposeList[decItemId].count = self._decomposeList[decItemId].count + decInfo.count * data.selectedCount
            end
        end
    end
end

-- tf节点的更新
function QAwakeningRebirth:_updateTfNodeNumber(tf, forceUpdate, updateCallBack, startNum, endNum)
    if endNum > startNum or not forceUpdate or not updateCallBack then
        self:_nodeEffect(tf)
    -- else
    --     updateCallBack(endNum)
    --     return
    end
    forceUpdate:addUpdate(startNum, endNum, updateCallBack, QAwakeningRebirth.NUMBER_TIME)
end

-- tf节点的缩放动画
function QAwakeningRebirth:_nodeEffect(node)
    if node ~= nil then
        local actionArrayIn = CCArray:create()
        actionArrayIn:addObject(CCScaleTo:create(0.23, 2))
        actionArrayIn:addObject(CCScaleTo:create(0.23, 1))
        local ccsequence = CCSequence:create(actionArrayIn)
        node:runAction(ccsequence)
    end
end

-- 更新选中信息
function QAwakeningRebirth:_updataItemsInfo()
    self:_statisticsSelect()
    for key, decInfo in pairs(self._decomposeList) do
        local tfNode = decInfo.tfNode
        local startNum = tonumber(tfNode:getString())
        local endNum = decInfo.count
        self:_updateTfNodeNumber(tfNode, decInfo.textFiledScroll, decInfo.tfUpdataCallback, startNum, endNum)
    end
end

-- 计算选中物品的返还列表
function QAwakeningRebirth:_calcCompensations()
    self._compensations = {}
    for id, info in pairs(self._decomposeList) do
        if info.count > 0 then
            table.insert(self._compensations, { id = id, value = info.count })
        end
    end
    return self._compensations
end

-- 计算选中物品的列表
function QAwakeningRebirth:_calcConsumeItems()
    self._consumeItems = {}
    for _, info in ipairs(self._data) do
        if info.selectedCount > 0 then
            table.insert(self._consumeItems, { type = tonumber(info.id), count = tonumber(info.selectedCount) })
        end
    end
    return self._consumeItems
end

-- 觉醒重生request
function QAwakeningRebirth:_onAwakeningRebirthRequest(consumeItems)
    local request = {api = "ITEM_RETURN", itemReturnRequest = { consumeItems = consumeItems } }
    app:getClient():requestPackageHandler("ITEM_RETURN", request, function(response)
        if response.items then 
            remote.items:setItems(response.items) 
        end
    end)
end


return QAwakeningRebirth