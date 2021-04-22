--
-- Author: wkwang
-- 魂兽森林邀请协助界面
--
local QUIDialog = import(".QUIDialog")
local QUIDialogSilverMineAssist = class("QUIDialogSilverMineAssist", QUIDialog)
local QListView = import("...views.QListView")
local QUIWidgetSilverMineAssist = import("..widgets.QUIWidgetSilverMineAssist")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")

function QUIDialogSilverMineAssist:ctor(options)
	local ccbFile = "ccb/Dialog_SilverMine_Yaoqingxiezhu.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerFinish", callback = handler(self, QUIDialogSilverMineAssist._onTriggerFinish)},
		{ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSilverMineAssist._onTriggerClose)},	
		{ccbCallbackName = "onTriggerGo", callback = handler(self, QUIDialogSilverMineAssist._onTriggerGo)},		
	}

	QUIDialogSilverMineAssist.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	self._ccbOwner.frame_tf_title:setString("邀请协助")

	self.fighters = options.fighters or {}
	local cfg = {}
	cfg.renderItemCallBack = handler(self, self.renderItemCallBack)
	cfg.spaceY = 6
	cfg.enableShadow = false
	cfg.totalNumber = #self.fighters
	self._contentListView = QListView.new(self._ccbOwner.sheet_layout,cfg)

	local myConsortiaId = remote.silverMine:getMyConsortiaId() 
	self._ccbOwner.sp_join_uion:setVisible(false)
	self._ccbOwner.sp_go_uion:setVisible(false)	
	if myConsortiaId == nil or myConsortiaId == "" then
		self._ccbOwner.node_no:setVisible(true)
		self._ccbOwner.tf_tips:setString("快去加入宗门，邀请小伙伴来协助你～")
		self._ccbOwner.sp_join_uion:setVisible(true)
	elseif #self.fighters == 0 then
		self._ccbOwner.node_no:setVisible(true)
		self._ccbOwner.tf_tips:setString("快去邀请小伙伴加入你的宗门吧～")
		self._ccbOwner.sp_go_uion:setVisible(true)
	else
		self._ccbOwner.node_no:setVisible(false)
	end
	self.invitedCount = 0
	local myOccupy = remote.silverMine:getMyOccupy()
	self.invitedCount = (myOccupy.inviteAssistCount or 0)
	if self.invitedCount < 0 then self.invitedCount = 0 end
	self._ccbOwner.tf_invite_count:setString(self.invitedCount.."人")
end

function QUIDialogSilverMineAssist:renderItemCallBack( list, index, info)
	local isCacheNode = true
	local data = self.fighters[index]
	local item = list:getItemFromCache()
	if not item then
		item = QUIWidgetSilverMineAssist.new()
		isCacheNode = false
	end
	item:setInfo(data)
	info.item = item
	info.size = item:getContentSize()
	info.size.height = info.size.height + 8
    list:registerBtnHandler(index, "btn_select2",function ()
		app.sound:playSound("common_small")
		if data.assistantCount == 0 then
			app.tip:floatTip("该宗门成员协助次数用完了~")
			return
		end
    	if data._assistSelect ~= true then
	    	local users = self:getSelectUserId()
	    	if self.invitedCount > #users then
	    		item:onSelect()
	    	else
	    		-- app.tip:floatTip("最多只能邀请"..self.invitedCount.."人~")
	    		app.tip:floatTip("每次狩猎最多发起5次协助邀请")
	    	end
	    else
    		item:onSelect()
	    end
    end)
    list:registerBtnHandler(index, "btn_head", function ()
		app.sound:playSound("common_small")

		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSocietyUnionHeadpromptNew", 
	        options = {info = data}}, {isPopCurrentDialog = false})
    end)
	return isCacheNode
end

--获取选中的用户ID
function QUIDialogSilverMineAssist:getSelectUserId()
	local users = {}
	for _,fighter in ipairs(self.fighters) do
		if fighter._assistSelect == true then
			table.insert(users, fighter.userId)
		end
	end
	return users
end

function QUIDialogSilverMineAssist:_onTriggerFinish(e)
	if q.buttonEventShadow(e, self._ccbOwner.btn_finish) == false then return end
	app.sound:playSound("common_small")
	local users = self:getSelectUserId()
	if #users > 0 then
		remote.silverMine:silverMineInviteAssistRequest(users, function ()
			local  msg = "亲爱的宗门小伙伴，我正在魂兽森林中狩猎，快来协助我吧~"

			local myOccupy = remote.silverMine:getMyOccupy()
			for _,fighter in ipairs(self.fighters) do
				if fighter._assistSelect == true then
					fighter.assistStatus = 1
					fighter._assistSelect = false
					-- fighter.assistantCount = fighter.assistantCount - 1
					self.invitedCount = self.invitedCount - 1
					-- app:getServerChatData():sendMessage(msg, 3, fighter.userId, fighter.name, fighter.avatar, {assist=myOccupy.oriOccupyId})
				end
			end
			-- app.tip:floatTip("协助邀请链接已发送至宗门成员的私聊窗口~")
			app.tip:floatTip("魂师大人，邀请协助发送成功~")
			-- self:_onTriggerClose()
			self._contentListView:refreshData()
			self._ccbOwner.tf_invite_count:setString(self.invitedCount.."人")
		end)
	else
		app.tip:floatTip("请先选择要邀请的宗门成员~")
	end
end

--点击链接
function QUIDialogSilverMineAssist:_onTriggerGo()
	local myConsortiaId = remote.silverMine:getMyConsortiaId() 
	if myConsortiaId == nil or myConsortiaId == "" then
		QQuickWay:openUnion()
	elseif #self.fighters == 0 then
		QQuickWay:openManageBuilding()
	end
end

function QUIDialogSilverMineAssist:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogSilverMineAssist:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogSilverMineAssist