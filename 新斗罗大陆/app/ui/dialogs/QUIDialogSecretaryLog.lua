--
-- zxs
-- 小秘书日志查看
-- 

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSecretaryLog = class("QUIDialogSecretaryLog", QUIDialog)

local QListView = import("...views.QListView") 
local QUIWidgetSecretaryLog = import("..widgets.QUIWidgetSecretaryLog")

function QUIDialogSecretaryLog:ctor(options)
	local ccbFile = "ccb/Dialog_Secretary_log.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSecretaryLog._onTriggerClose)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, QUIDialogSecretaryLog._onTriggerOK)},
	}
	QUIDialogSecretaryLog.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    q.setButtonEnableShadow(self._ccbOwner.btn_action)
    q.setButtonEnableShadow(self._ccbOwner.btn_close)
    self._ccbOwner.frame_tf_title:setString("助手日志")

    self._totalHeight = 0 
    self._logInfos = options.logInfo or {}

    self._ccbOwner.node_no:setVisible(false)
    self._ccbOwner.btn_ok:setVisible(false)
    self._ccbOwner.btn_close:setVisible(false)

    if options.isShowAll then
        self:updateSecretaryLogs()
    end
    self:initListView()

    for i, logInfo in pairs(self._logInfos) do
        if logInfo.isFinish then
            self._ccbOwner.btn_ok:setVisible(true)
            self._ccbOwner.btn_close:setVisible(true)
            break
        end
    end
end

function QUIDialogSecretaryLog:viewDidAppear()
	QUIDialogSecretaryLog.super.viewDidAppear(self)

    self._secretaryEventProxy = cc.EventProxy.new(remote.secretary)
    self._secretaryEventProxy:addEventListener(remote.secretary.SECRETARY_LOG_INFO, handler(self, self._addLogInfo))    
    self._secretaryEventProxy:addEventListener(remote.secretary.SECRETARY_FINISH, handler(self, self._finish))   
end

function QUIDialogSecretaryLog:viewWillDisappear()
	QUIDialogSecretaryLog.super.viewWillDisappear(self)

    self._secretaryEventProxy:removeAllEventListeners()
end

function QUIDialogSecretaryLog:initListView()
    local totalNumber = #self._logInfos

    if not self._listView then
        local cfg = {
            renderItemCallBack = handler(self, self._renderItemCallBack),
            enableShadow = false,
            ignoreCanDrag = true,
            curOriginOffset = 5,
            totalNumber = totalNumber,
            tailIndex = totalNumber,
            spaceY = -30,
        }
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = totalNumber, tailIndex = totalNumber})
    end
end

function QUIDialogSecretaryLog:_renderItemCallBack(list, index, info)
    local isCacheNode = true
    local itemData = self._logInfos[index]

    local item = list:getItemFromCache()
    if not item then
        item = QUIWidgetSecretaryLog.new()
        isCacheNode = false
    end

    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()
    
    --注册事件
    item:registerItemBoxPrompt(index,list)

    return isCacheNode
end

-- 获得单个奖励
function QUIDialogSecretaryLog:_addLogInfo(event)
    local info = event.info
    table.insert(self._logInfos, info)
    self:getOptions().logInfo = self._logInfos
    self:initListView()
end

-- 汇总奖励
function QUIDialogSecretaryLog:_finish(event)
    local info = event.info
    table.insert(self._logInfos, info)

    self._ccbOwner.btn_ok:setVisible(true)
    self._ccbOwner.btn_close:setVisible(true)

    self:initListView()
end

-- 查看日志时获取所有奖励
function QUIDialogSecretaryLog:updateSecretaryLogs()
    local secretaryLogs = remote.secretary:getSecretaryAllLog()
    
    for i, log in pairs(secretaryLogs) do
        table.insert(self._logInfos, log)
    end
    self._ccbOwner.node_no:setVisible(#self._logInfos == 0)
end

function QUIDialogSecretaryLog:_onTriggerOK()
    app.sound:playSound("common_switch")
    self:playEffectOut()
end

function QUIDialogSecretaryLog:_onTriggerClose()
    app.sound:playSound("common_switch")
    self:playEffectOut()
end

return QUIDialogSecretaryLog