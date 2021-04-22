local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBlackRockRecordDetail = class("QUIDialogBlackRockRecordDetail", QUIDialog)

-- local QNavigationController = import("...controllers.QNavigationController")
-- local QListView = import("...views.QListView")
-- local QUIWidgetBlackRock = import("..widgets.blackrock.QUIWidgetBlackRock")
-- local QUIViewController = import("..QUIViewController")
-- local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")

function QUIDialogBlackRockRecordDetail:ctor(options)
	local ccbFile = "ccb/Dialog_Black_mountain_record.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogBlackRockRecordDetail.super.ctor(self,ccbFile,callBacks,options)

    self.isAnimation = true
    q.setButtonEnableShadow(self._ccbOwner.btn_close)
    
    local data = options.data
    local list = options.list or {}

    self._ccbOwner.frame_tf_title:setString("对战记录")

    self:_initTitle(data)
    self:_init(list)
end

function QUIDialogBlackRockRecordDetail:_initTitle(data)
    local time = q.date("%m-%d %H:%M", data.happenedAt / 1000)
    self._ccbOwner.label_title:setString(time .. " " .. tostring(remote.blackrock:getChapterById(data.chapterId)[1].name))
end

function QUIDialogBlackRockRecordDetail:_init(data)
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, self._ccbOwner.sheet_layout:getContentSize(), {bufferMode = 1, sensitiveDistance = 10})
    self._scrollView:setVerticalBounce(true)

    for index = 1, 3 do
        local subData = data[index]
        if subData then
            local owner = {}
            local proxy = CCBProxy:create()
            local node = CCBuilderReaderLoad("ccb/Widget_Black_mountain_sanxing.ccbi", proxy, owner)
            node.getContentSize = function()
                return CCSizeMake(665, 130)
            end
            node:setPositionY(-index * 125 + 120)
            self._scrollView:addItemBox(node)
            self._scrollView:setRect(0, -index * 125 -10, 0, self._ccbOwner.sheet_layout:getContentSize().width)
            self:_initWidget(node, owner, subData)
        end
    end
end

function QUIDialogBlackRockRecordDetail:_initWidget(widget, owner, data)
    -- isCaptain
    owner.node_leader:setVisible(not not data.isLeader)
    owner.node_member:setVisible(not data.isLeader)
    -- head
    local head = QUIWidgetAvatar.new(data.icon)
    owner.node_headPicture:addChild(head)
    head:setScale(0.7)
    -- level
    owner.label_level:setString("LV."..tostring(data.teamLevel))
    -- name
    if data.isNpc ~= true then
        -- vip
        owner.label_vip:setString(tostring(data.vipLv))
        -- battle force
        local num,unit = q.convertLargerNumber(data.topnForce or 0)
        owner.label_force:setString(num..(unit or ""))
    else
        owner.node_vip:setVisible(false)
        owner.label_force:setString("【佣兵】")
    end
    owner.label_name:setString(tostring(data.memberName))
    if data.memberId == remote.user.userId then
        owner.label_name:setColor(UNITY_COLOR_LIGHT.orange)
    end
    -- success or fail
    owner.sp_pass:setVisible(not not data.isWin)
    owner.label_fail:setVisible(not data.isWin)
    owner.sprite_star_on:setVisible(not not data.isWin)
    owner.sprite_star_off:setVisible(not data.isWin)
end

function QUIDialogBlackRockRecordDetail:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogBlackRockRecordDetail:_close()
    self:playEffectOut()
end

function QUIDialogBlackRockRecordDetail:_onTriggerClose()
    app.sound:playSound("common_cancel")
    self:_close()
end

return QUIDialogBlackRockRecordDetail