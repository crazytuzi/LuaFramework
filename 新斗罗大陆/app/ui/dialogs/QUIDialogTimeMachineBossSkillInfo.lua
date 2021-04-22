-- by Kumo
-- 活动副本Boss技能介绍界面

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTimeMachineBossSkillInfo = class("QUIDialogTimeMachineBossSkillInfo", QUIDialog)

local QUIWidgetTimeMachineBossSkillInfo = import("..widgets.QUIWidgetTimeMachineBossSkillInfo")
local QListView = import("...views.QListView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogTimeMachineBossSkillInfo:ctor(options)
    local ccbFile = "ccb/Dialog_Timemachine_skill.ccbi"
	local callBacks = {
            {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogTimeMachineBossSkillInfo._onTriggerClose)},
        }
    QUIDialogTimeMachineBossSkillInfo.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    self._instanceId = options.instanceId
    self._ccbOwner.frame_tf_title:setString("魂技信息")
    self:_init()
end

function QUIDialogTimeMachineBossSkillInfo:viewDidAppear()
    QUIDialogTimeMachineBossSkillInfo.super.viewDidAppear(self)
end

function QUIDialogTimeMachineBossSkillInfo:viewWillDisappear() 
    QUIDialogTimeMachineBossSkillInfo.super.viewWillDisappear(self)
end

function QUIDialogTimeMachineBossSkillInfo:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogTimeMachineBossSkillInfo:_onTriggerClose(e)
    if e ~= nil then
        app.sound:playSound("common_close")
    end
    self:playEffectOut()
end

function QUIDialogTimeMachineBossSkillInfo:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogTimeMachineBossSkillInfo:_init()
    local mapConfig = remote.activityInstance:getInstanceListById(self._instanceId)
    -- QPrintTable(mapConfig)
    self._skillIds = string.split(mapConfig[1].show_skill or "", ";")
    -- QPrintTable(self._skillIds)
    self:_initPageSwipe()
end

function QUIDialogTimeMachineBossSkillInfo:_initPageSwipe()
    if not self._contentListView then
        local cfg = {
            renderItemCallBack = handler(self,self._reandFunHandler),
            ignoreCanDrag = true,
            isVertical = true,
            enableShadow = false,
            totalNumber = #self._skillIds,
        }  
        self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        -- self._contentListView:reload({totalNumber = #self._itemList})
        self._contentListView:refreshData()
    end
end

function QUIDialogTimeMachineBossSkillInfo:_reandFunHandler( list, index, info )
    local isCacheNode = true
    local skillId = self._skillIds[index]
    local item = list:getItemFromCache()
    if not item then
        item = QUIWidgetTimeMachineBossSkillInfo.new()
        isCacheNode = false
    end
    item:init( skillId ) 
    info.item = item
    info.size = item:getContentSize()

    return isCacheNode
end

return QUIDialogTimeMachineBossSkillInfo



