-- 
-- Kumo.Wang
-- 小助手：宗門祭祀
-- 
local QBaseSecretary = import(".QBaseSecretary")
local QSocietySacrificeSecretary = class("QSocietySacrificeSecretary", QBaseSecretary)

local QUIWidgetSecretarySettingTitle = import("..ui.widgets.QUIWidgetSecretarySettingTitle")
local QUIWidgetSecretarySettingII = import("..ui.widgets.QUIWidgetSecretarySettingII")

function QSocietySacrificeSecretary:ctor(options)
	QSocietySacrificeSecretary.super.ctor(self, options)

    local data = {}
    table.insert(data, {desc = "神赐建设", index = 1, type = 3})
    table.insert(data, {desc = "高级建设", index = 2, type = 2})
    table.insert(data, {desc = "普通建设", index = 3, type = 1})
    self._data = data
end

function QSocietySacrificeSecretary:checkSecretaryIsNotActive()
    if remote.union:checkHaveUnion() == false then
        return true, "尚未加入宗门"
    end
    
    return false
end

function QSocietySacrificeSecretary:getNameStr(taskId, idCount, logNum)
    local nameStr = ""

    local config = db:getSocietyFete(idCount)
    if config then
        nameStr = config.fete_name
    else
        nameStr = idCount
    end

    return nameStr
end

function QSocietySacrificeSecretary:convertSecretaryAwards(itemLog, logNum,info)
    QSocietySacrificeSecretary.super:convertSecretaryAwards(itemLog, logNum,info)
    local countTbl = string.split(itemLog.param, ";")

    if self._config.showResource ~= nil then
        local idCount = tonumber(countTbl[1]) or 0
        local config = db:getSocietyFete(idCount)
        if config and config.gold_consumption and config.gold_consumption ~= 0 then
            info.token = 0
            info.money = tonumber(countTbl[2]) or 0
        elseif config then
            info.token = tonumber(countTbl[2]) or 0
            info.money = 0
        end
    end
    return info
end

function QSocietySacrificeSecretary:executeSecretary()
    if remote.union:checkHaveUnion() == false or (remote.user.userConsortia.daily_sacrifice_type and remote.user.userConsortia.daily_sacrifice_type ~= 0) then
        -- 當前沒有宗門 or 當日已經祭拜

        --检测是否有建设礼包可以领取
        local award_ids = self:checkFeteReward()
        if #award_ids > 0 then
            self:openFeteReward(award_ids)
            return 
        end

        remote.secretary:nextTaskRunning()
    else
        local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
        local index = curSetting.chooseNum or 3
        local data = self._data[index]
        local sacrificeType = data and data.type or 1

        local config = db:getSocietyFete(sacrificeType)
        if config then
            if config.gold_consumption and config.gold_consumption > 0 then
                if remote.user.money < config.gold_consumption then
                    -- QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.MONEY)
                    app.tip:floatTip("宗门建设金币不足")
                    remote.secretary:nextTaskRunning()
                    return
                end
            elseif config.token_consumption and config.token_consumption > 0 then
                local superCost = config.token_consumption
                if sacrificeType == 3 and remote.activity:checkMonthCardActive(1) then
                    superCost = 188
                end
                if remote.user.token < superCost then
                    -- QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
                    app.tip:floatTip("宗门建设钻石不足")
                    remote.secretary:nextTaskRunning()
                    return
                end
            end
        end

        remote.union:unionFeteRequest(sacrificeType, true, function(data)
                remote.mark:cleanMark(remote.mark.MARK_CONSORTIA_SACRIFICE)
                remote.user.userConsortia.sacrificeCount = remote.user.userConsortia.sacrificeCount + 1
                
                if data.secretaryItemsLogResponse then
                    local countTbl = string.split(data.secretaryItemsLogResponse.secretaryLog.param, ";")
                    local sacrificeType = tonumber(countTbl[1]) or 1
                    remote.user.userConsortia.daily_sacrifice_type = sacrificeType
                    remote.union.unionActive:updateActiveTaskProgress(20001, sacrificeType, true)
                    local cost = tonumber(countTbl[2]) or 0

                end
                remote.secretary:updateSecretaryLog(data) 
                --检测是否有建设礼包可以领取
                local award_ids = self:checkFeteReward()
                if #award_ids > 0 then
                    self:openFeteReward(award_ids)
                    return 
                end
                remote.secretary:nextTaskRunning()
            end, function()
                remote.secretary:nextTaskRunning()
            end)
    end
end

function QSocietySacrificeSecretary:openFeteReward(reward_idx)

    local callback = function(data)
        if data.secretaryItemsLogResponse then
            remote.secretary:updateSecretaryLog(data, 2)
        end
        remote.secretary:nextTaskRunning()
    end
    remote.union:unionFeteRewardRequest(reward_idx, true, callback)
end


function QSocietySacrificeSecretary:checkFeteReward()

    if remote.union:checkHaveUnion() == false then
        return {}
    end


    local consortiaInfo = remote.secretary:getSecretaryInfo().consortiaSecretary or {}

    local cur_sacrifice_value = remote.union.consortia.sacrifice
    if consortiaInfo.consortiaSacrifice then
        cur_sacrifice_value = consortiaInfo.consortiaSacrifice
    end

    local ids ={}
    -- 去除获得过的礼包
    for i=1,4 do
        local not_got = not remote.user.userConsortia["draw" .. i]
        if not not_got and consortiaInfo.gotSacrificeId and #consortiaInfo.gotSacrificeId > 0 then
            for f,id in ipairs(consortiaInfo.gotSacrificeId) do
                if id == i  then
                    not_got = false
                    break
                end
            end
        end
        if not_got then table.insert(ids, i) end
    end

    local award_ids ={}

    for _,i in ipairs(ids) do
        if  cur_sacrifice_value >= db:getSocietyFeteReward(remote.union.consortia.level)[i].fete_schedule then
            table.insert(award_ids, i)
        end
    end

    return award_ids 
end


function QSocietySacrificeSecretary:getSettingWidgets()
    local widgets = {}

    local titleWidget = QUIWidgetSecretarySettingTitle.new()
    titleWidget:setInfo("建设方式")
    local titleHeight = titleWidget:getContentSize().height
    table.insert(widgets, titleWidget)

    self._chooseWidgetList = {}
    local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
    self._curChoose = curSetting.chooseNum or 3

    local totalHeight = titleHeight
    local height = 0
    for i, setInfo in pairs(self._data) do
        local chooseWidget = QUIWidgetSecretarySettingII.new()
        chooseWidget:addEventListener(QUIWidgetSecretarySettingII.EVENT_SELECT_CLICK, handler(self, self.chooseItemClickHandler))
        chooseWidget:setIndex(setInfo.index)
        self:setWidgetInfo(chooseWidget, setInfo)
        chooseWidget:setSelected(self._curChoose == setInfo.index)
        
        height = chooseWidget:getContentSize().height
        chooseWidget:setPositionX(100)
        chooseWidget:setPositionY(-totalHeight)
        totalHeight = totalHeight+height

        table.insert(widgets, chooseWidget)
        table.insert(self._chooseWidgetList, chooseWidget)
    end
    self:updateChooseInfo()

    return widgets
end

function QSocietySacrificeSecretary:setWidgetInfo(widget, info)
    if not widget or not info then return end

    local sacrificeType = info.type
    local config = db:getSocietyFete(sacrificeType)
    local cost = config and (config.gold_consumption ~= 0 and config.gold_consumption or config.token_consumption) or 0
    local resourceName = ""
    if config and config.gold_consumption and config.gold_consumption > 0 then
        -- 金幣
        resourceName = TOP_BAR_TYPE.MONEY
    elseif config and config.token_consumption and config.token_consumption > 0 then
        -- 鑽石
        resourceName = TOP_BAR_TYPE.TOKEN_MONEY
    end
    local resourceInfo = remote.items:getWalletByType(resourceName)
    if resourceInfo ~= nil and resourceInfo.alphaIcon ~= nil then
        local texture = CCTextureCache:sharedTextureCache():addImage(resourceInfo.alphaIcon)
        if texture then
            local size = texture:getContentSize()
            local rect = CCRectMake(0, 3, size.width, size.height)
            widget._ccbOwner.sp_resource:setTexture(texture)
            widget._ccbOwner.sp_resource:setTextureRect(rect)
        end
    end
    widget._ccbOwner.tf_name:setString(config and config.fete_name or "")
    widget._ccbOwner.tf_num1:setString(cost)
    if sacrificeType == 3 and remote.activity:checkMonthCardActive(1) then
        local preConfig = {}
        preConfig.point_x = widget._ccbOwner.tf_num1:getPositionX()
        preConfig.point_y = widget._ccbOwner.tf_num1:getPositionY()
        local config = {}
        config.point_x = preConfig.point_x + widget._ccbOwner.tf_num1:getContentSize().width
        config.point_y = preConfig.point_y
        self:_createLine(config, preConfig, widget._ccbOwner.tf_num1:getParent())

        widget._ccbOwner.tf_num2:setString(188)
        widget._ccbOwner.tf_num2:setVisible(true)
    else
        widget._ccbOwner.tf_num2:setVisible(false)
    end
end

function QSocietySacrificeSecretary:_createLine( config, preConfig, node )
    local line = CCDrawNode:create()
    line:drawLine({preConfig.point_x, preConfig.point_y}, {config.point_x, config.point_y}, 0.5, ccc4FFromccc4B(COLORS.X))
    node:addChild(line)
end

function QSocietySacrificeSecretary:refreshWidgetData(widget, itemData, index)
    QSocietySacrificeSecretary.super.refreshWidgetData(self, widget, itemData, index)
    if widget then
        local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
        local chooseNum = curSetting.chooseNum or 3
        local data = self._data[chooseNum]
        if data then
            local config = db:getSocietyFete(data.type)
            widget:setDescStr(config and config.fete_name or "")
        end
    end
end

function QSocietySacrificeSecretary:chooseItemClickHandler(event)
    if not event or not event.index then
        return
    end
    self._curChoose = event.index
    self:updateChooseInfo()
end

function QSocietySacrificeSecretary:updateChooseInfo()
    for i, widget in pairs(self._chooseWidgetList) do
        local index = widget:getIndex()
        widget:setSelected(self._curChoose == index)
    end
end

function QSocietySacrificeSecretary:saveSecretarySetting()
    local setting = {}
    setting.chooseNum = self._curChoose
    remote.secretary:updateSecretarySetting(self._config.id, setting)
end

return QSocietySacrificeSecretary
