-- @Author: zhouxiaoshu
-- @Date:   2019-04-29 10:46:05
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-13 20:32:44
local QUIDialog = import("..Dialogs.QUIDialog")
local QUIDialogConsortiaWarHallSelect = class("QUIDialogConsortiaWarHallSelect", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetConsortiaWarHallSelect = import("..widgets.consortiaWar.QUIWidgetConsortiaWarHallSelect")
local QListView = import("...views.QListView")

function QUIDialogConsortiaWarHallSelect:ctor(options)
    local ccbFile = "ccb/Dialog_Unionwar_setting.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogConsortiaWarHallSelect._onTriggerClose)},
    }
    QUIDialogConsortiaWarHallSelect.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    self._callback = options.callback
    self._info = options.info
    self._data = {}
    self._isUpdate = false
    
    self:updateInfo()
    self:initListView()
end

function QUIDialogConsortiaWarHallSelect:updateInfo()
    local hallConfig = remote.consortiaWar:getHallConfigByHallId(self._info.hallId)
    local hallName = hallConfig.name or ""
    if self._info.isLeader then
        self._ccbOwner.frame_tf_title:setString(hallName.."堂主选择")
    else
        self._ccbOwner.frame_tf_title:setString(hallName.."成员选择")
    end
    local fighters = remote.consortiaWar:getConsortiaWarMemberList()
    for i, fighter in pairs(fighters) do
        local hallId = remote.consortiaWar:getFigherHallIdByUserId(fighter.userId)
        if hallId == 0 then
            table.insert(self._data, fighter)
        end
    end
    table.sort(self._data, function(a, b)
        return a.force > b.force
    end)
end

function QUIDialogConsortiaWarHallSelect:initListView()
	if not self._listView then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemFunc),
	        curOriginOffset = 0,
	        isVertical = true,
	        enableShadow = true,
	      	ignoreCanDrag = true,
	        totalNumber = #self._data,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_layout,cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIDialogConsortiaWarHallSelect:_renderItemFunc( list, index, info )
    -- body
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache(self._selectTab)
    if not item then
		item = QUIWidgetConsortiaWarHallSelect.new()
		item:addEventListener(QUIWidgetConsortiaWarHallSelect.EVENT_CLICK_UP, handler(self, self.headClickHandler))
    	isCacheNode = false
    end
    item:setInfo(itemData)
    item:initGLLayer()
    info.item = item
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_ok", "_onTriggerUp",nil,true)

    return isCacheNode
end

function QUIDialogConsortiaWarHallSelect:headClickHandler(event)
    if not event.name then
        return
    end
    local info = event.info
    local member = {}
    member.memberId = info.userId
    member.isLeader = self._info.isLeader
    member.memberFighter = info
    remote.consortiaWar:updateTempHall(true, self._info.hallId, member)
    self._isUpdate = true
    self:playEffectOut()
end

function QUIDialogConsortiaWarHallSelect:viewAnimationOutHandler()
    self:popSelf()
    if self._callback then
        self._callback(self._isUpdate)
    end
end

function QUIDialogConsortiaWarHallSelect:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogConsortiaWarHallSelect:_onTriggerClose()
	app.sound:playSound("common_cancel")
    self:playEffectOut()
end

return QUIDialogConsortiaWarHallSelect