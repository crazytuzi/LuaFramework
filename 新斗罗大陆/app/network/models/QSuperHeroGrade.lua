--
-- SS魂师升星数据类
-- 此数据类只计算和提供数据，并不做远程交互，放到remote下只为获取

local QBaseModel = import("...models.QBaseModel")
local QSuperHeroGrade = class("QSuperHeroGrade", QBaseModel)

local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")

QSuperHeroGrade.SELECT_STATUS_ALL = "1"       -- 选中“添加所有”
QSuperHeroGrade.SELECT_STATUS_NOT_ALL = "2"   -- 选中“添加非收集中”

-- 记录到本地的键 记录选中状态
QSuperHeroGrade.USERDATA_SELECT_CONFIG = "QSuperHeroGrade_USERDATA_SELECT_CONFIG"

function QSuperHeroGrade:ctor()
    QSuperHeroGrade.super.ctor(self)
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end



----------------------------------------
---接口部分

-- 设置信息
function QSuperHeroGrade:setInfo(actorId, updateWidgetCallback)
    self._actorId = actorId
end


-- 页面退出时调用
function QSuperHeroGrade:onDialogClose()
    self._selectStatus = nil
    if self._isUpgrade then
        local addGrade = self:getAddGrade(true)
        if addGrade > 0 then
            QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.HERO_ADVANCE_SUCCESS, items = self._items, addGrade = addGrade})
        end
    end
end

-- 更新并重新获取data
function QSuperHeroGrade:updataAndGetData()
    local data = self:_getData()    -- 要先获取数据在做reset
    self:_reset()
    return data
end

-- 获取heroInfo
function QSuperHeroGrade:getHeroInfo()
    return self._heroInfo
end

-- 获取选取的总经验
function QSuperHeroGrade:getTotalExp()
    local exp = 0
	for i, item in pairs(self._data) do
    	if item.selectedCount > 0 then
    		exp = exp + item.selectedCount * (item.exp or 0)
    	end
    end
    return exp
end

-- 获取需要金币
function QSuperHeroGrade:getNeedMoney()
    return self._realNeedMoney
end

-- 获取需要等级
function QSuperHeroGrade:getNeedLevel()
    -- 此处给外部用下一级所需等级
    return self._limitLevel
end

-- 获取actorId
function QSuperHeroGrade:getActorId()
    return self._actorId
end

-- 获取欲增加星级, isReal=true时返回选中经验实际能升到的等级
function QSuperHeroGrade:getAddGrade(isReal)
    if isReal then
        if self._addGrade > 1 or self._curExpMax then
            local addGrade = self._addGrade
            if self._curExp + self._addExp < self._consumeExp then
                addGrade = addGrade - 1
            end
            
            return addGrade
        else
            return 0
        end
    end
    return self._addGrade
end

-- 获取增加的经验
function QSuperHeroGrade:getAddExp()
    return self._addExp
end

-- 获取所需经验
function QSuperHeroGrade:getConsumeExp()
    return self._consumeExp
end

-- 获取当前经验
function QSuperHeroGrade:getCurExp()
    return self._curExp
end

-- 是否缺钱
function QSuperHeroGrade:isMoneyNotEnough()
    return self._isMoneyNotEnough
end

-- 是否缺级
function QSuperHeroGrade:isLevelNotEnough()
    -- return self._isLevelNotEnough

    -- 允许外部红色情况下添加碎片，所以这里用的是下一级的等级需求
    return self._heroInfo.level < self._limitLevel
end

-- 添加的碎片是否足够升至少一级
function QSuperHeroGrade:isSelectedEnough()
    return (self._addGrade > 1 or self._curExpMax)
end

-- 是否满级
function QSuperHeroGrade:isMax()
    return self._isMax
end

-- 是否显示摘除按钮
function QSuperHeroGrade:isShowReset()
    if self._heroInfo then
        return (self._heroInfo.grade > 0 or self._curExp > 0)
    end
    return false
end

-- 改变经验 返回false增加失败 返回true增加成功    isChangeToNext:若经验满足，则信息是否切换到下一等级的信息
function QSuperHeroGrade:changeExpData(offsetExp, isChangeToNext)
    local tempAddExp = self._addExp + offsetExp
    if tempAddExp < 0 then
        return false
    end
    self._addExp = tempAddExp
    self._curExpMax = false
    self._selectedMax = false
    while true do
        -- 经验满足
        if self._curExp + self._addExp >= self._consumeExp then
            -- 不切换到下一级
            if not isChangeToNext then
                self._curExpMax = true
                break
            end

            -- 满级检测
            local gradeConfig = db:getGradeByHeroActorLevel(self._actorId, self._heroInfo.grade + self._addGrade + 1)
            if not gradeConfig then 
                self._selectedMax = true
                break
            end
            self._lastLimitLevel = self._limitLevel
            self._limitLevel = gradeConfig.hero_level_limit
            self._lastMoney = self._needMoney
            self._needMoney = self._needMoney + gradeConfig.money
            self._lastConsumeExp = self._consumeExp
            self._consumeExp = self._consumeExp + gradeConfig.super_devour_consume or 1
            self._addGrade = self._addGrade + 1

        elseif self._curExp + self._addExp < self._lastConsumeExp and self._addGrade > 1 then
            -- 经验减少，grade等级下降
            self._addGrade = self._addGrade - 1
            self._limitLevel = self._lastLimitLevel 
            self._needMoney = self._lastMoney
            self._consumeExp = self._lastConsumeExp

            if self._addGrade > 1 then
                local gradeConfig = db:getGradeByHeroActorLevel(self._actorId, self._heroInfo.grade + self._addGrade)
                self._lastLimitLevel = gradeConfig.hero_level_limit
                self._lastMoney = self._lastMoney - gradeConfig.money
                self._lastConsumeExp = self._lastConsumeExp - gradeConfig.super_devour_consume or 1
            else
                self._lastMoney = 0
                self._lastConsumeExp = 0
            end
        else
            break
        end
    end


    -- 其中real是只针对存在星级提升时候的所需
    -- 非real是直接下一级所需
    self._isMoneyNotEnough = false
    self._isLevelNotEnough = false
    if self._addGrade > 1 or self._curExpMax then
        self._realNeedMoney = self._needMoney
        self._realLimitLevel = self._limitLevel
        if self._curExp + self._addExp < self._consumeExp then
            self._realNeedMoney = self._lastMoney
            self._realLimitLevel = self._lastLimitLevel
        end

        self._isMoneyNotEnough = remote.user.money < self._realNeedMoney
        self._isLevelNotEnough = self._heroInfo.level < self._realLimitLevel
    end

    return true
end

-- 设置选中状态
function QSuperHeroGrade:setSelectStatus(status)
    if status then
        self._selectStatus = status
        app:getUserData():setUserValueForKey(QSuperHeroGrade.USERDATA_SELECT_CONFIG, self._selectStatus)
    end
end

-- 获取选中状态
function QSuperHeroGrade:getSelectStatus()
    if not self._selectStatus then
        local status = app:getUserData():getUserValueForKey(QSuperHeroGrade.USERDATA_SELECT_CONFIG)
        self._selectStatus = status or QSuperHeroGrade.SELECT_STATUS_NOT_ALL
    end

    return self._selectStatus
end

-- 根据选中状态选择, 若status为空则按照配置来
function QSuperHeroGrade:autoSelect(status)
    if not status then
        status = self:getSelectStatus()
    end
    if status == QSuperHeroGrade.SELECT_STATUS_ALL then
        self:_onAutoSelectImpl(true)
    else
        self:_onAutoSelectImpl(false)
    end
end

-- 获取是否开启自动添加
function QSuperHeroGrade:isOpenAutoAdd()
    return app.unlock:checkLock("UNLOCK_HERO_STAR_ONE_KEY")
end



----------------------------------------
---按钮交互部分

-- 摘除
function QSuperHeroGrade:onReset(successCallback)
    if 30 > remote.user.token then
        QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
        return
    end

    app:alert({content = "##n花费##e30钻石##n，可以将当前##e魂师##n的星级重新重生到##e1星##n，并返还##e所消耗数量相同的SS升星碎片、金币、灵魂石和体技强化石##n，是否重生？", title = "系统提示", 
        callback = function(callType)
            if callType == ALERT_TYPE.CONFIRM then
                -- 点击后星级重置
                app:getClient():heroReturnGradeRequest(self._actorId, successCallback)
            end
        end, isAnimation = true, colorful = true}, true, true)
end

-- 帮助
function QSuperHeroGrade:onHelp()
    local aptitudeInfo = db:getActorSABC(self._actorId)
    local index = 1
    if aptitudeInfo.qc == "SS+" then
        index = 2
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSuperHeroGradeHelp", options = {index = index}}, {isPopCurrentDialog = false})
end

-- 设置
function QSuperHeroGrade:onSet()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSuperHeroGradeSetting"}, {isPopCurrentDialog = false})
end

-- 升星
function QSuperHeroGrade:onAdvance(addExpSucCallback)
    if self._isMax then
        app.tip:floatTip("魂师已满星，无法升星")
        return false
    end

    if self._addExp <= 0 then
        app.tip:floatTip("所选道具数量不能为空")
        return false
    end

    self._items = {}
    for i, item in pairs(self._data) do
        if item.selectedCount > 0 then
            table.insert(self._items, {type = item.id, count = item.selectedCount})
        end
    end

    -- 等级判断
    if self._isLevelNotEnough then
        QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.HERO_LEVEL)
        return false
    end

    -- 金币判断
    if self._isMoneyNotEnough then
        QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
        return false
    end

    if self._addExp > 0 and self._addGrade == 1 and not self._curExpMax then
        app:getClient():grade(self._actorId, self._items, function(data)
            if addExpSucCallback then
                addExpSucCallback()
            end
        end)
		return false
    end

    self._isUpgrade = true
    return true
end

-- 添加碎片
function QSuperHeroGrade:onAddItem(event, callback)
    if self._isMax then
        app.tip:floatTip("魂师已满星，无法吞噬增加经验")
        return
    end

    if self._selectedMax then
        app.tip:floatTip("已达到星级上限，无法继续提升")
        return
    end

    local curItem = self:_getCurItem(event.itemID)
    if curItem == nil then return end
    if curItem.selectedCount >= curItem.count then
        app.tip:floatTip("所选道具数量已达上限")
        return
    end

    if not self:isOpenAutoAdd() and self._curExpMax then
        app.tip:floatTip("当前经验已可以升星")
        return
    end

    -- 更新到下一级
    if self._curExpMax then
        self:changeExpData(0, true)
        self._curExpMax = false

        -- 两次_selectedMax判断目的不一样，这里也要有
        if self._selectedMax then
            app.tip:floatTip("已达到星级上限，无法继续提升")
            return
        end
    end

    local count = self:_getNextGradeNeedNum(curItem.exp, curItem.count - curItem.selectedCount)
    if curItem.id == tonumber(ITEM_TYPE.POWERFUL_PIECE) then
        count = math.floor(count/5)*5
        if count == 0 then
            app.tip:floatTip("所选道具数量不足")
        end
    end
    if count == 0 then
        return
    end

    local exp = curItem.exp * count
    if self:changeExpData(exp) then
        curItem.selectedCount = curItem.selectedCount + count
        if curItem.selectedCount > curItem.count then
            curItem.selectedCount = curItem.count
        end
        if callback then
            callback()
        end
    end
end

-- 减少碎片
function QSuperHeroGrade:onMinusItem(event, callback)
    local curItem = self:_getCurItem(event.itemID)
    if curItem then
        local itemWidget = event.source
        if curItem.selectedCount > 0 then
            local count = 1
            if curItem.id == tonumber(ITEM_TYPE.POWERFUL_PIECE) then
                count = 5
            end
            local exp = curItem.exp * count
            if self:changeExpData(-exp) then
                curItem.selectedCount = curItem.selectedCount - count
            end
        end
        itemWidget:setGoodsInfo(event.itemID, ITEM_TYPE.ITEM, curItem.selectedCount.."/"..curItem.count, true)
        itemWidget:showMinusButton(curItem.selectedCount > 0)
        if callback then
            callback()
        end
    end
end





----------------------------------------
---私有部分

-- 获取到下一级所需的剩余数量
function QSuperHeroGrade:_getNextGradeNeedNum(itemExp, notSelectedCount)
    if self._isMax then
        return 0
    end

    local needExp = self._consumeExp - self._curExp - self._addExp
    local totalNeed = math.ceil(needExp / itemExp)
    if totalNeed >= notSelectedCount then
        return notSelectedCount
    end

    return totalNeed
end

-- 自动添加
function QSuperHeroGrade:_onAutoSelectImpl(isAll)
    -- 如果选择非收集中，则把收集中的碎片先全部取消掉
    if not isAll then
        local subExp = 0
        for _, item in ipairs(self._data) do
            --if item.order == 4 then
                subExp = subExp + item.exp * item.selectedCount
                item.selectedCount = 0
            --end
        end
        if subExp > 0 then
            self:changeExpData(-subExp)
        end
    end
    local exp = 0
    local curExp = self._curExp + self._addExp
    local needExp = self._consumeExp
    local needMoney = self._needMoney
    local addGrade = self._addGrade + 1

    -- 获取所有剩余碎片的经验
    for _, item in ipairs(self._data) do
        if isAll or (item.order ~= 4 and item.order ~= 2) then
            exp = exp + item.exp * (item.count - item.selectedCount)
        end
    end

    -- 获取剩余经验能提升到哪一级
    while true do
        local gradeConfig = db:getGradeByHeroActorLevel(self._actorId, self._heroInfo.grade + addGrade)
        if not gradeConfig then
            break
        end
        local isSatisfy = true
        local gradeExp = gradeConfig.super_devour_consume or 1
        local gradeMoney = gradeConfig.money or 0

        isSatisfy = isSatisfy and (needExp + gradeExp <= curExp + exp)                      -- 经验满足
        isSatisfy = isSatisfy and (needMoney + gradeMoney <= remote.user.money)             -- 金币满足
        isSatisfy = isSatisfy and (self._heroInfo.level >= gradeConfig.hero_level_limit)    -- 等级满足

        if isSatisfy then
            addGrade = addGrade + 1
            needExp = needExp + gradeExp
            needMoney = needMoney + gradeMoney
        else
            break
        end
    end

    -- 减去一级，因为这一级是剩余经验提不上去的
    addGrade = addGrade - 1
    if addGrade < self._addGrade then
        return
    end

    -- 等级有提升时允许自动添加
    local surplusCount = 0
    local surplusExp = 0
    for _, item in ipairs(self._data) do
        if isAll or (item.order ~= 4 and item.order ~= 2) then
            while self._addGrade <= addGrade do
                surplusCount = self:_getNextGradeNeedNum(item.exp, item.count - item.selectedCount)
                if item.id == tonumber(ITEM_TYPE.POWERFUL_PIECE) then
                    surplusCount = math.floor(surplusCount/5)*5
                    if surplusCount == 0 then
                        break
                    end
                end

                surplusExp = item.exp * surplusCount
                if self:changeExpData(surplusExp, self._addGrade < addGrade) then
                    item.selectedCount = item.selectedCount + surplusCount
                    if item.selectedCount >= item.count then
                        item.selectedCount = item.count
                        break
                    end
                    if self._addGrade == addGrade and self._curExpMax then
                        break
                    end
                else
                    break
                end
            end

            if self._addGrade == addGrade and self._curExpMax then
                break
            end
        end
    end
end

-- 获取选中widgetItem
function QSuperHeroGrade:_getCurItem(itemId)
    for i, item in pairs(self._data) do
    	if item.id == itemId then
        	return item
    	end
    end
end

-- 获取itemData列表
function QSuperHeroGrade:_getData()
    self._data = {}
	local fragments = remote.items:getAllSuperGradeFragment()
	for k, v in pairs(fragments) do
		local itemInfo = db:getItemByID(v.type)
        local order = 3
        if remote.stores:checkItemIsNeed(v.type, 1) then
            order = 4
        end

        -- local actorId = db:getActorIdBySoulId(v.type)
        -- local isCollected = table.find(remote.user.collectedHeros, actorId)

        local value = {id = v.type, count = v.count, order = order, selectedCount = 0, color = itemInfo.colour, aptitude = 20, exp = itemInfo.devour_exp or 0}
        table.insert(self._data, value)
    end
    local expItem = db:getItemByID(ITEM_TYPE.SUPER_EXP) -- 魂师经验碎片
    local soulNum = remote.items:getItemsNumByID(expItem.id)
    if soulNum > 0 then
        local value = {id = expItem.id, count = soulNum, order = 1, selectedCount = 0, color = expItem.colour, aptitude = 20, exp = expItem.devour_exp or 0}
        table.insert(self._data, value)
    end
    local expItem = db:getItemByID(ITEM_TYPE.POWERFUL_PIECE) -- 万能碎片
    local soulNum = remote.items:getItemsNumByID(expItem.id)
    if soulNum > 0 then
        local value = {id = expItem.id, count = soulNum, order = 2, selectedCount = 0, color = expItem.colour, aptitude = 20, exp = expItem.devour_exp or 0}
        table.insert(self._data, value)
    end

    table.sort(self._data, function (x, y) 
        if x.order == y.order then
            return x.id < y.id
        else
            return x.order < y.order
        end
    end)
    return self._data
end

-- 初始化魂师等级数据
function QSuperHeroGrade:_reset()
    local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
	if heroInfo == nil then return end
    self._heroInfo = heroInfo                           -- 魂师信息
    self._addGrade = 1                                  -- 增加的星级，目标添加等级，>1时若经验不满足则需要-1才是实际增加等级
    self._addExp = self:getTotalExp()                   -- 选中的碎片增加的总经验
    self._curExp = self._heroInfo.superHeroExp or 0     -- 当前经验
    self._limitLevel = 0                                -- 限制等级
    self._lastLimitLevel = 0                            -- 上一星级的限制等级
    self._needMoney = 0                                 -- 需要金币
    self._lastMoney = 0                                 -- 上一星级的所需金币
    self._consumeExp = 0                                -- 需要经验
    self._lastConsumeExp = 0                            -- 上一星级的需要经验
    self._isMax = false                                 -- 是否满级
    self._isUpgrade = false                             -- 是否点击了升星按钮，并且成功触发升星
    self._selectedMax = false                           -- 选中数量是否达到满级

    local gradeConfig = db:getGradeByHeroActorLevel(self._actorId, self._heroInfo.grade + self._addGrade)
    if gradeConfig == nil then 
        self._isMax = true
        return
    end

    self._limitLevel = gradeConfig.hero_level_limit
    self._needMoney = gradeConfig.money
    self._consumeExp = gradeConfig.super_devour_consume or 1
    self._curExpMax = false
end


return QSuperHeroGrade