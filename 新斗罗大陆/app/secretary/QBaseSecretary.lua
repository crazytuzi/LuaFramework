-- @Author: xurui
-- @Date:   2019-08-07 12:31:24
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-06-24 11:26:48
local QBaseSecretary = class("QBaseSecretary")
local QUIWidgetSecretary = import("..ui.widgets.QUIWidgetSecretary")

local QUIViewController = import("..ui.QUIViewController")
local QQuickWay = import("..utils.QQuickWay")

function QBaseSecretary:ctor(options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._widget = nil
	self._secretaryId = options.id or 100
	self._config = options.config or {}
end

------------------------- 逻辑 相关 ---------------------------

--检查当前类型是否完成
function QBaseSecretary:checkSecretaryIsComplete( ... )
	return false
end

--检查当前类型是否激活
function QBaseSecretary:checkSecretaryIsNotActive( ... )
    return false
end

--执行小舞助手
function QBaseSecretary:executeSecretary( ... )

end

function QBaseSecretary:getNameStr(taskId, idCount, logNum)
    return idCount
end

function QBaseSecretary:convertSecretaryAwards(itemLog, logNum,info)

	if info == nil then info = {} end
    local taskId = itemLog.taskType
    local dataProxy = remote.secretary:getSecretaryDataProxyById(itemLog.taskType)

    local secrataryConfig = remote.secretary:getSecretaryConfigById(taskId)

    local describe = nil
    -- 是否有多条日志
    if logNum and secrataryConfig.describe_split then
        local describeSplit = string.split(secrataryConfig.describe_split, ";")
        describe = describeSplit[logNum]
    end
    if not describe then
        describe = secrataryConfig.describe
    end

    local contents = string.split(describe, "#")
    local countTbl = string.split(itemLog.param, ";")
    local num = 1
    local title2 = ""
    for i, v in pairs(contents) do
        local str = v
        if str == "name" then
            local idCount = tonumber(countTbl[num]) or 0
            if dataProxy then
        		str = dataProxy:getNameStr(taskId, idCount, logNum)
        	else
        		str = idCount
    		end
            num = num + 1
        end
        if str == "replace" then
            title2 = title2..(countTbl[num] or "")
            num = num + 1
        elseif str then
            title2 = title2..str
        end
    end

    local configByType = remote.secretary:getMySecretaryConfigById(itemLog.taskType)
    if configByType and configByType.showResource ~= nil then
        info.token = tonumber(countTbl[2]) or 0
        info.money = tonumber(countTbl[3]) or 0    	
    end

    local awards = {}
    local rewards = string.split(itemLog.gotItems, ";")
    for i, v in pairs(rewards) do
        if v ~= "" then
            local reward = string.split(v, ",")
            local itemType = remote.items:getItemType(reward[3])
            local count = tonumber(reward[2])
            if count and count > 0 then
                local award = {id = reward[1], typeName = itemType, count = count }
                table.insert(awards, award)
            end
        end
    end

    info.taskId = taskId
    info.title1 = secrataryConfig.name or ""
    info.title2 = title2

    info.awards = awards
    info.isShow = secrataryConfig.is_show

	return info
end
------------------------- 小舞助手主界面widget 相关 ---------------------------

--获取小舞助手widget
function QBaseSecretary:createSecretaryWidget()
	return QUIWidgetSecretary.new()
end

--刷新widget数据
function QBaseSecretary:refreshWidgetData(widget, itemData, index)
	if widget then
		widget:setInfo(itemData)
		local isNotActive, desc = self:checkSecretaryIsNotActive()
		if isNotActive then
			widget:setSecretaryActive(isNotActive, desc)
		else
			local isComplete = self:checkSecretaryIsComplete()
			widget:setSecretaryComplete(isComplete)

			local curSetting = remote.secretary:getSettingBySecretaryId(self._secretaryId)
			local isOpen = curSetting.isOpen or false
			widget:setSecretaryOpen(isOpen)

			-- 购买次数
			if curSetting.buyCount then
				widget:setDescStr("购买"..curSetting.buyCount.."次")
			end
		end
	end
end

--注册widget按钮事件
function QBaseSecretary:registerBtnHandler(list, index)
	if list then
		list:registerBtnHandler(index, "btn_select", handler(self, self._onTriggerSelect))
		list:registerBtnHandler(index, "btn_set", handler(self, self._onTriggerSet))
		list:registerBtnHandler(index, "btn_go", handler(self, self._onTriggerGo))
	end
end

function QBaseSecretary:_onTriggerSelect()
	local curSetting = remote.secretary:getSettingBySecretaryId(self._secretaryId)
	local isOpen = curSetting.isOpen or false
	local setting = {}
	setting.isOpen = not isOpen
	remote.secretary:updateSecretarySetting(self._secretaryId, setting)
end

function QBaseSecretary:_onTriggerSet()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSecretarySetting", 
		options = {setId = self._secretaryId}}, {isPopCurrentDialog = false})
end

function QBaseSecretary:_onTriggerGo()
	local curConfig = remote.secretary:getSecretaryConfigById(self._secretaryId)
	if curConfig.shortcut_approach_new then
		local shortcut = db:getShortcutByID(curConfig.shortcut_approach_new)
    	QQuickWay:clickGoto(shortcut)
    end
end

------------------------- 小舞助手设置 相关 ---------------------------

--返回设置界面的widget列表
function QBaseSecretary:getSettingWidgets()
	return {}
end

--保存设置
function QBaseSecretary:saveSecretarySetting( ... )
	-- body
end

--tips
function QBaseSecretary:getSettingTips()
	return false, ""
end

return QBaseSecretary