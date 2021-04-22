local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBlackRockInvite = class("QUIDialogBlackRockInvite", QUIDialog)
local QListView = import("...views.QListView")
local QUIWidgetBlackRockInvite = import("..widgets.blackrock.QUIWidgetBlackRockInvite")

function QUIDialogBlackRockInvite:ctor(options)
	local ccbFile = "ccb/Dialog_SilverMine_Yaoqingxiezhu.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerFinish", callback = handler(self, self._onTriggerFinish)},
	}
	QUIDialogBlackRockInvite.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true
	
	self._ccbOwner.frame_tf_title:setString("邀请队员")
	self._ccbOwner.tf_tips:setString("魂师大人，当前还没有可以邀请的队员哦~")
	self._ccbOwner.tf_yaoqing_des:setString("每位好友(活跃+3%)，每位宗门成员(活跃+3%，宗门+3%)")
	self._ccbOwner.tf_yaoqing_des:setFontSize(18)
	self._ccbOwner.node_no:setVisible(false)
	self._ccbOwner.btn_go:setVisible(false)
	self._ccbOwner.sp_go_uion:setVisible(false)
	self._ccbOwner.sp_join_uion:setVisible(false)

	self._callBack = options.callBack
	self._chapterId = options.chapterId
	self._teamId = options.teamId
	self._members = options.members
	self._inviteCount = 0
	-- self._members = {}
	-- self:initListView()
	-- if remote.user.userConsortia ~= nil then
	-- 	remote.blackrock:blackRockGetOnlineConsortiaMemberListRequest(self._chapterId, function (data)
	-- 		if data.blackRockGetOnlineConsortiaMemberListResponse ~= nil then
	-- 			self._members = data.blackRockGetOnlineConsortiaMemberListResponse.onlineMemebers or {}
	self:initListView()
		-- 	end
		-- end)
	-- end
end

function QUIDialogBlackRockInvite:initListView( ... )
	-- body
	if not self._listViewLayout then
		local cfg = {
			renderItemCallBack = handler(self, self.renderItemHandler),
	        enableShadow = false,
	      	ignoreCanDrag = true,
	        totalNumber = #self._members,
	        spaceY = 10,
	        curOriginOffset = 10,
	        curOffset = 10,
		}
		self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else

		self._listViewLayout:reload({#self._members})
	end
	self._ccbOwner.node_no:setVisible(#self._members == 0)
end

function QUIDialogBlackRockInvite:renderItemHandler(list, index, info )
    local isCacheNode = true
    local itemData = self._members[index]

    local item = list:getItemFromCache()
    if not item then
    	item = QUIWidgetBlackRockInvite.new()
        isCacheNode = false
    end

    item:setInfo(itemData)
    info.item = item
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_select2", handler(self, self._onTriggerSelect))

    return isCacheNode
end

function QUIDialogBlackRockInvite:_onTriggerSelect(x, y, touchNode, listView )
	app.sound:playSound("common_switch")
    local touchIndex = listView:getCurTouchIndex()
    if self._members[touchIndex].selected == false and self._inviteCount >= 5 then
    	app.tip:floatTip("最多一次邀请5人~")
    	return 
    end
    local item = listView:getItemByIndex(touchIndex)
    item:_onTriggerSelect()
    self:inviteCountHandler()
end

function QUIDialogBlackRockInvite:inviteCountHandler()
	self._inviteCount = 0
	for _,info in ipairs(self._members) do
		if info.selected == true then
			self._inviteCount = self._inviteCount + 1
		end
	end
	self._ccbOwner.tf_invite_count:setString(5-self._inviteCount.."人")
end

function QUIDialogBlackRockInvite:_onTriggerFinish(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_finish) == false then return end
	if self._inviteCount == 0 then
		app.tip:floatTip("至少选择一个队员~")
		return
	end
	local consortiaMemberId = {}
	for _,info in ipairs(self._members) do
		if info.selected == true then
			table.insert(consortiaMemberId, info.userId)
		end
	end
	remote.blackrock:blackRockInviteConsortiaMemberJoinTeamRequest(consortiaMemberId, self._chapterId, self._teamId, function ()
		if self:safeCheck() then
			app.tip:floatTip("邀请成功~")
			self:_onTriggerClose()
		end
	end)
end

function QUIDialogBlackRockInvite:_onTriggerClose()
    app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogBlackRockInvite:_backClickHandler()
    app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogBlackRockInvite:viewAnimationOutHandler()
	local callBack = self._callBack
	self:popSelf()
	if callBack ~= nil then 
		callBack()
	end
end

return QUIDialogBlackRockInvite