--[[	
	文件名称：QUIWidgetSocietyUnionExamine.lua
	创建时间：2016-03-25 17:05:37
	作者：nieming
	描述：QUIWidgetSocietyUnionExamine --审核
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetSocietyUnionExamine = class("QUIWidgetSocietyUnionExamine", QUIWidget)
local QUIWidgetSocietyUnionExamineSheet = import("..widgets.QUIWidgetSocietyUnionExamineSheet")
local QListView = import("...views.QListView")
local QUIViewController = import("..QUIViewController")
local QUIDialogUnionAnnouncement = import("..dialogs.QUIDialogUnionAnnouncement")

--初始化
function QUIWidgetSocietyUnionExamine:ctor(options)
	local ccbFile = "Widget_society_union_examine.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerLimitSetting", callback = handler(self, QUIWidgetSocietyUnionExamine._onTriggerLimitSetting)},
		{ccbCallbackName = "onTraggerRecruit", callback = handler(self, QUIWidgetSocietyUnionExamine._onTraggerRecruit)},
	}
	QUIWidgetSocietyUnionExamine.super.ctor(self,ccbFile,callBacks,options)
	--代码
	self._applyList = {}
end

--describe：
function QUIWidgetSocietyUnionExamine:_onTriggerLimitSetting(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_setting) == false then return end
    app.sound:playSound("common_small")
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionSetting",
        options = {confirmCallback = function (  )
        	-- body
        	if self._isExit then
        		app.tip:floatTip("设置成功！") 
        		self:setLimitLabel()
        	end
        end}}, {isPopCurrentDialog = false})

end

--describe：
function QUIWidgetSocietyUnionExamine:_onTraggerRecruit(event)
    if q.buttonEventShadow(event, self._ccbOwner.btnRecruit) == false then return end
	--代码
	if self._coolTime then
		return
	end
    app.sound:playSound("common_small")
	if remote.union.consortia.authorize ~= 1 and remote.union.consortia.authorize ~= 2 then
		app.tip:floatTip("魂师大人，您设置了禁止加入的限制，无法发起招募成员哦~")
		return
	end

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionAnnouncement", 
        options = {type = QUIDialogUnionAnnouncement.TYPE_UNION_RECRUIT, confirmCallback = function (word)
        	local msg = ""
        	if #word > 0 then
        		-- msg = string.format("##y《%s》%s", remote.union.consortia.name or "", word)
        		print("dxwlay word = "..word)
        		msg = string.format("##g%s", word)
				if remote.union.consortia.applyTeamLevel then
					msg = msg..string.format("##r (要求等级：%d级)",remote.union.consortia.applyTeamLevel)
				end	
            else
				-- app.tip:floatTip("请输入内容！")
				-- msg = string.format("##y《%s》邀请玩家加入,一起共创美好未来！", remote.union.consortia.name or "")
				msg = string.format("##g%s", remote.union:getRecruit())
				if remote.union.consortia.applyTeamLevel then
					msg = msg..string.format("##r (要求等级：%d级)",remote.union.consortia.applyTeamLevel)
				end	
            end
            app:getServerChatData():sendMessage(msg, 1, nil, nil, nil, {conscribe=remote.union.consortia.sid, conscribeUnionName = remote.union.consortia.name or "", conscribeUnionLevelLimit = remote.union.consortia.applyTeamLevel, conscribeUnionNotice = remote.union.consortia.notice or ""},
				function( code )
					if code  and code == 0 then
						app.tip:floatTip("招募成员发布成功！")
						self:openScheduler(600)

					else
						self:updateData()
					end
				end
			)
        end}}, {isPopCurrentDialog = false})
end

function QUIWidgetSocietyUnionExamine:updateData(  )
	-- body
	 remote.union:unionApplyListRequest(function (data)
	 	if not self._isExit then
	 		return
	 	end
	 	local isChange = false
	 	if data.consortiaFighters then
	        table.sort(data.consortiaFighters, function (x, y)
	                return x.level > y.level 
	            end)
	        self._applyList =  data.consortiaFighters
	        isChange = true
	    end

	    if #self._applyList == 0 then
			self._ccbOwner.emptyApplyList:setVisible(true)
			remote.mark:cleanMark(remote.mark.MARK_CONSORTIA_APPLY)
		else
			self._ccbOwner.emptyApplyList:setVisible(false)
		end
		
	    if data.consortia or isChange then
	    	self:setInfo()
	    end
    end) 
end

--describe：onEnter 
function QUIWidgetSocietyUnionExamine:onEnter()
	--代码
	self._isExit = true
	self:updateData()
	self:setInfo()
end

--describe：onExit 
function QUIWidgetSocietyUnionExamine:onExit()
	--代码
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)
		self._scheduler = nil
	end
	self._isExit = false
end

function QUIWidgetSocietyUnionExamine:argeeApply( x, y, touchNodeNode, list )
	-- body
	app.sound:playSound("common_confirm")
	local index = list:getCurTouchIndex()
	local applyInfo = self._applyList[index]
	if applyInfo then
		remote.union:unionApproveRequest(applyInfo.userId, true, function (data)
			if self._isExit then
				table.remove(self._applyList, index)
				if #self._applyList == 0 then
					self._ccbOwner.emptyApplyList:setVisible(true)
					remote.mark:cleanMark(remote.mark.MARK_CONSORTIA_APPLY)
				else
					self._ccbOwner.emptyApplyList:setVisible(false)
				end

				self:initListView()
			end
		end)
	end
	
end

function QUIWidgetSocietyUnionExamine:refuseApply( x, y, touchNodeNode, list )
	-- body
	app.sound:playSound("common_cancel")
	local index = list:getCurTouchIndex()
	local applyInfo = self._applyList[index]
	if applyInfo then
		remote.union:unionApproveRequest(applyInfo.userId, false, function (data)
			if self._isExit then
				table.remove(self._applyList, index)
				if #self._applyList == 0 then
					self._ccbOwner.emptyApplyList:setVisible(true)
					remote.mark:cleanMark(remote.mark.MARK_CONSORTIA_APPLY)
				else
					self._ccbOwner.emptyApplyList:setVisible(false)
				end
				self:initListView()
			end
		end)
	end

end

function QUIWidgetSocietyUnionExamine:showInfo( x, y, touchNodeNode, list )
	-- body
	app.sound:playSound("common_cancel")
	local index = list:getCurTouchIndex()
	local applyInfo = self._applyList[index]
	if applyInfo then
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogFriendInfo", 
	    	options = {info = {vipLevel = applyInfo.vip, teamLevel = applyInfo.level, avatar = applyInfo.avatar, nickname = applyInfo.name,force = applyInfo.force,user_id = applyInfo.userId}}}, {isPopCurrentDialog = false})
	end

end

function QUIWidgetSocietyUnionExamine:setLimitLabel(  )
	-- body
	local str1 = ""
	local str2 = remote.union.consortia.applyTeamLevel or ""
	if remote.union.consortia.authorize then
		if remote.union.consortia.authorize == 1 then
			str1 = "  (需申请)"
		elseif remote.union.consortia.authorize == 2 then
			str1 = "  (自由加入)"
		else
			str1 = "  (禁止加入)"
		end
	end
	self._ccbOwner.limitLabel:setString(str2..str1)
end

function QUIWidgetSocietyUnionExamine:initListView()

	if not self._listView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            -- body
	            local isCacheNode = true
	            local item = list:getItemFromCache()
	            local data = self._applyList[index]
	            if not item then
	                item = QUIWidgetSocietyUnionExamineSheet.new()
	                isCacheNode = false
	            end
	            item:setInfo(data)
	            info.item = item
	            info.size = item:getContentSize()

	            list:registerBtnHandler(index, "btn_agree", handler(self,QUIWidgetSocietyUnionExamine.argeeApply), nil, true)
	            list:registerBtnHandler(index, "btn_refuse", handler(self,QUIWidgetSocietyUnionExamine.refuseApply), nil, true)
	           	list:registerBtnHandler(index, "clickHead", handler(self,QUIWidgetSocietyUnionExamine.showInfo))

	            return isCacheNode
	        end,
	        spaceY = 0,
	   		enableShadow = true,
	        totalNumber = #self._applyList,
	        curOffset = 5, 
	        curOriginOffset = -4,
    	} 
    	self._listView = QListView.new(self._ccbOwner.listView,cfg)

    else
    	self._listView:reload({totalNumber = #self._applyList}) 
	end
end

function QUIWidgetSocietyUnionExamine:openScheduler( time )
	-- body
	self._coolTime = time
	if self._scheduler then
		scheduler.unscheduleGlobal(self._scheduler)	
	end
	self._scheduler = scheduler.scheduleGlobal(handler(self, self._onScheduler), 1)
	self._ccbOwner.btnRecruit:setEnabled(false)
	makeNodeFromNormalToGray(self._ccbOwner.btnRecruit)
	self._ccbOwner.recruitLabel:setString(q.timeToHourMinuteSecond(self._coolTime,true))
end
--describe：setInfo 
function QUIWidgetSocietyUnionExamine:setInfo(info)
	--代码


	self:setLimitLabel()
	self:initListView()

	if remote.union.consortia.consortiaCommandTime  then
		local time = math.floor(remote.union.consortia.consortiaCommandTime/1000) + 600 - q.serverTime()
		if time > 0 then
			self:openScheduler( time)
		end
	end
end

function QUIWidgetSocietyUnionExamine:_onScheduler(  )
	-- body
	if self._isExit and self._coolTime then
		self._coolTime = self._coolTime -1
		if self._coolTime  <=0 then
			if self._scheduler then
				scheduler.unscheduleGlobal(self._scheduler)	
				self._scheduler = nil
			end
			self._coolTime = nil
			self._ccbOwner.btnRecruit:setEnabled(true)
			makeNodeFromGrayToNormal(self._ccbOwner.btnRecruit)
			self._ccbOwner.recruitLabel:setString("招募成员")

		else
			self._ccbOwner.recruitLabel:setString(q.timeToHourMinuteSecond(self._coolTime,true))
		end
	end
end

--describe：getContentSize 
--function QUIWidgetSocietyUnionExamine:getContentSize()
	----代码
--end

return QUIWidgetSocietyUnionExamine
