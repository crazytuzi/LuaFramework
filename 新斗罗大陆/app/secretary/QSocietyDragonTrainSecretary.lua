-- 
-- Kumo.Wang
-- 小助手：宗門武魂養成
-- 
local QBaseSecretary = import(".QBaseSecretary")
local QSocietyDragonTrainSecretary = class("QSocietyDragonTrainSecretary", QBaseSecretary)

local QUIWidgetSecretarySettingTitle = import("..ui.widgets.QUIWidgetSecretarySettingTitle")
local QUIWidgetSecretarySettingII = import("..ui.widgets.QUIWidgetSecretarySettingII")

function QSocietyDragonTrainSecretary:ctor(options)
	QSocietyDragonTrainSecretary.super.ctor(self, options)


    local str = db:getConfigurationValue("sociaty_dragon_multiple")
    local tbl = string.split(str, ";")
    local consume = 0
    for _, value in ipairs(tbl) do
        local tmpTbl = string.split(value, ",")
        if tonumber(tmpTbl[2]) == 2 then
            consume = tonumber(tmpTbl[3])
        end
    end

    local data = {}
    table.insert(data, {desc = "双倍领奖", index = 1, resourceName = TOP_BAR_TYPE.TOKEN_MONEY, cost = consume, multiple = 2})
    table.insert(data, {desc = "正常领奖", index = 2, multiple = 1})
    self._data = data
end

function QSocietyDragonTrainSecretary:checkSecretaryIsNotActive()
    if remote.union:checkHaveUnion() == false then
        return true, "尚未加入宗门"
    end
    if app.unlock:checkLock("SOCIATY_DRAGON") == false then
        local config = db:getUnlock()
        local level = config["SOCIATY_DRAGON"].sociaty_level or 5
        return true, "宗门等级"..level.."级开启"
    end
    
    return false
end

function QSocietyDragonTrainSecretary:getNameStr(taskId, idCount, logNum)
    local nameStr = ""

    if idCount == 1 then
        nameStr = "普通领取"
    elseif idCount == 2 then
        nameStr = "双倍领取"
    elseif idCount == 3 then
        nameStr = "三倍领取"
    else
        nameStr = idCount
    end

    return nameStr
end

function QSocietyDragonTrainSecretary:convertSecretaryAwards(itemLog, logNum,info)
    QSocietyDragonTrainSecretary.super:convertSecretaryAwards(itemLog, logNum,info)
    local countTbl = string.split(itemLog.param, ";")

    if self._config.showResource ~= nil then
        info.money = 0   
        info.token = 0   
    end
    return info
end

function QSocietyDragonTrainSecretary:executeSecretary()
    if remote.union:checkHaveUnion() == false or app.unlock:checkLock("SOCIATY_DRAGON") == false then
        local box_ids = self:chechConsortiaDragonGetBoxPrize()
        if #box_ids > 0 then
            self:openConsortiaDragonGetBoxPrize(box_ids)
            return 
        end
        remote.secretary:nextTaskRunning()
    else
        remote.dragon:consortiaGetDragonInfoRequest(function()
                local dragonInfo = remote.dragon:getDragonInfo()
                if dragonInfo and dragonInfo.dragonId == 0 then
                    -- 當前宗門未設置宗門武魂
                    app.tip:floatTip("宗门未幻化武魂")
                    remote.secretary:nextTaskRunning()
                else
                    if remote.dragon:getTaskEndState() then
                        -- 當前宗門武魂養成任務已完結（完成並領獎）
                        local box_ids = self:chechConsortiaDragonGetBoxPrize()
                        if #box_ids > 0 then
                            self:openConsortiaDragonGetBoxPrize(box_ids)
                            return 
                        end
                        remote.secretary:nextTaskRunning()
                    else
                        local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
                        local index = curSetting.chooseNum or 2
                        local curData = self._data[index]
                        if curData then
                            if curData.cost and remote.user.token < curData.cost then
                                -- QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
                                app.tip:floatTip("双倍领奖钻石不足")
                                remote.secretary:nextTaskRunning()
                            else
                                local multiple = curData.multiple or 1
                                remote.dragon:consortiaDragonGetTaskProgressRequest(multiple, true, function(data)
                                        remote.secretary:updateSecretaryLog(data)
                                        local box_ids = self:chechConsortiaDragonGetBoxPrize()
                                        if #box_ids > 0 then
                                            self:openConsortiaDragonGetBoxPrize(box_ids)
                                            return 
                                        end 
                                        remote.secretary:nextTaskRunning()
                                    end, function()
                                        remote.secretary:nextTaskRunning()
                                    end)
                            end
                        else
                            remote.secretary:nextTaskRunning()
                        end
                    end    
                end
            end)
    end
end


function QSocietyDragonTrainSecretary:openConsortiaDragonGetBoxPrize(box_idx)

    local callback = function(data)
        if data.secretaryItemsLogResponse then
            remote.secretary:updateSecretaryLog(data, 2)
        end
        remote.secretary:nextTaskRunning()
    end
    remote.dragon:consortiaDragonGetBoxPrizeRequest(box_idx, true, callback)
end


function QSocietyDragonTrainSecretary:chechConsortiaDragonGetBoxPrize()

    if remote.union:checkHaveUnion() == false then
        return {}
    end


    local configs_list = remote.dragon:getTaskBoxConfigList()

    local newconfigs = {}
    for _,v in pairs(configs_list) do
        v.isOpenBox = remote.dragon:isTaskBoxOpenedByBoxId(v.box_id)
        table.insert(newconfigs,v)
    end
    table.sort(newconfigs,function(a,b)
        if a.isOpenBox ~= b.isOpenBox then
            return b.isOpenBox == true
        else
            return tonumber(a.box_id) < tonumber(b.box_id)
        end
    end)

    configs_list = newconfigs


    local consortiaInfo = remote.secretary:getSecretaryInfo().consortiaSecretary or {}
    local cur_task_progress = remote.dragon:getTaskProgressStr()
    -- if consortiaInfo.consortiaSacrifice then
    --     cur_task_progress = consortiaInfo.consortiaTaskProgress
    -- end
    local taskProgressDic ={}
    if cur_task_progress ~= ""  then
        local tbl = string.split(cur_task_progress, ";")
        for _, value in ipairs(tbl) do
            local tmpTbl = string.split(value, ",")
            if tmpTbl and #tmpTbl > 1 then
                taskProgressDic[tonumber(tmpTbl[1])] = tonumber(tmpTbl[2])
            end
        end
    else
        return {}
    end
    local cur_task = 99999
    QPrintTable(taskProgressDic)

    for i=1,3 do
        if taskProgressDic[i] == nil then
            cur_task = 0
            break
        else
            cur_task = math.min(cur_task,taskProgressDic[i])
        end
    end

    print("cur_task  -----  "..cur_task)


    local ids ={}
    -- 去除获得过的礼包
    for i=1,#configs_list do
        local config = configs_list[i]
        if config then 
            local bos_id = config.box_id
            local not_got = not remote.dragon:isTaskBoxOpenedByBoxId(bos_id) 
            if not not_got and consortiaInfo.gotDragonBoxId and #consortiaInfo.gotDragonBoxId > 0 then
                for f,id in ipairs(consortiaInfo.gotDragonBoxId) do
                    if id == bos_id  then
                        not_got = false
                        break
                    end
                end
            end
            if not_got then table.insert(ids, i) end
        end
    end 
    local box_ids ={}

    for _,i in ipairs(ids) do
        local config = configs_list[i]
        local target_value = config.box_target or 999999
        if target_value and cur_task then
            if  tonumber(cur_task) >= tonumber(target_value) then
                local bos_id = config.box_id
                table.insert(box_ids, config.box_id)
            end
        end
    end

    return box_ids 
end



function QSocietyDragonTrainSecretary:getSettingWidgets()
    local widgets = {}

    local titleWidget = QUIWidgetSecretarySettingTitle.new()
    titleWidget:setInfo("领奖方式")
    local titleHeight = titleWidget:getContentSize().height
    table.insert(widgets, titleWidget)

    self._chooseWidgetList = {}
    local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
    self._curChoose = curSetting.chooseNum or 2

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

    -- local chooseWidget = QUIWidgetSecretarySettingII.new()
    -- self:setWidgetInfo(chooseWidget, {desc = "自动完成进度最低的任务"})
    -- chooseWidget:setSelected(true)
    
    -- height = chooseWidget:getContentSize().height
    -- chooseWidget:setPositionX(100)
    -- chooseWidget:setPositionY(-totalHeight)
    -- totalHeight = totalHeight+height

    table.insert(widgets, chooseWidget)
    self:updateChooseInfo()

    return widgets
end

function QSocietyDragonTrainSecretary:getSettingTips()
    return true, "小舞助手将自动完成进度最低的任务"
end

function QSocietyDragonTrainSecretary:setWidgetInfo(widget, info)
    if not widget or not info then return end

    widget._ccbOwner.tf_name:setString(info.desc or "")

    local resourceName = info.resourceName
    if resourceName then
        local cost = info.cost or 0
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
        widget._ccbOwner.tf_num1:setString(cost)
        widget._ccbOwner.tf_num2:setVisible(false)
    else
        widget._ccbOwner.sp_resource:setVisible(false)
        widget._ccbOwner.tf_num1:setVisible(false)
        widget._ccbOwner.tf_num2:setVisible(false)
    end
end

function QSocietyDragonTrainSecretary:refreshWidgetData(widget, itemData, index)
    QSocietyDragonTrainSecretary.super.refreshWidgetData(self, widget, itemData, index)
    if widget then
        local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
        local chooseNum = curSetting.chooseNum or 2
        local data = self._data[chooseNum]
        if data then
            widget:setDescStr(data.desc)
        end
    end
end

function QSocietyDragonTrainSecretary:chooseItemClickHandler(event)
    if not event or not event.index then
        return
    end
    self._curChoose = event.index
    self:updateChooseInfo()
end

function QSocietyDragonTrainSecretary:updateChooseInfo()
    for i, widget in pairs(self._chooseWidgetList) do
        local index = widget:getIndex()
        widget:setSelected(self._curChoose == index)
    end
end

function QSocietyDragonTrainSecretary:saveSecretarySetting()
    local setting = {}
    setting.chooseNum = self._curChoose
    remote.secretary:updateSecretarySetting(self._config.id, setting)
end

return QSocietyDragonTrainSecretary
