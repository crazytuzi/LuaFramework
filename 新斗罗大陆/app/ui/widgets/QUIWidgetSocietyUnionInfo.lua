--[[	
	文件名称：QUIWidgetSocietyUnionInfo.lua
	创建时间：2016-03-23 18:03:45
	作者：nieming
	描述：QUIWidgetSocietyUnionInfo 宗门信息
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetSocietyUnionInfo = class("QUIWidgetSocietyUnionInfo", QUIWidget)
local QListView = import("...views.QListView")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetSocietyUnionInfoSheet = import(".QUIWidgetSocietyUnionInfoSheet")
local QUnionAvatar = import("...utils.QUnionAvatar")
local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QUIDialogUnionAnnouncement = import("..dialogs.QUIDialogUnionAnnouncement")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIWidgetSocietyUnionInfo:ctor(options)
	local ccbFile = "Widget_society_union_info.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerDisbanded", callback = handler(self, QUIWidgetSocietyUnionInfo._onTriggerDisbanded)},
		{ccbCallbackName = "onTriggerChangeIcon", callback = handler(self, QUIWidgetSocietyUnionInfo._onTriggerChangeIcon)},
		{ccbCallbackName = "onTriggerChangUnionName", callback = handler(self, QUIWidgetSocietyUnionInfo._onTriggerChangUnionName)},
		{ccbCallbackName = "onTriggerSendMail", callback = handler(self, QUIWidgetSocietyUnionInfo._onTriggerSendMail)},
		{ccbCallbackName = "onTriggerRule", callback = handler(self, QUIWidgetSocietyUnionInfo._onTriggerRule)},
	}
	QUIWidgetSocietyUnionInfo.super.ctor(self,ccbFile,callBacks,options)

	self._memberList = {}
	self._myOfficialPosition = remote.user.userConsortia.rank or SOCIETY_OFFICIAL_POSITION.MEMBER
	self._moveIndex = 0

	if not remote.union:checkUnionRight() then
		self._ccbOwner.node_btn_send_mail:setVisible(false)
		self._ccbOwner.node_btn_disbanded:setPositionX(322)
		self._ccbOwner.node_btn_disbanded:setPositionY(92)
	end
end

function QUIWidgetSocietyUnionInfo:_onTriggerDisbanded(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_dsbanded) == false then return end
    app.sound:playSound("common_small")
	if self._disbandedCallBack then
		self._disbandedCallBack()
	end
end

function QUIWidgetSocietyUnionInfo:_onTriggerChangeIcon()
    app.sound:playSound("common_small")
	if self._myOfficialPosition ~= SOCIETY_OFFICIAL_POSITION.BOSS then
		return
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionHead", 
		options = {type = 1, newAvatarSelected = function (icon)
			remote.union:unionUpdateSettingRequest(remote.union.consortia.applyTeamLevel, remote.union.consortia.authorize, remote.union.consortia.name, icon,
				(remote.union.consortia.applyPowerLimit or 0),function ( )
				if self._isExit then
					local unionAvatar = QUnionAvatar.new(icon, false, false)
					unionAvatar:setConsortiaWarFloor(remote.union.consortia.consortiaWarFloor)
					self._ccbOwner.iconNode:removeAllChildren()
			   	 	self._ccbOwner.iconNode:addChild(unionAvatar)
			   	 	app.tip:floatTip("修改宗门图标成功") 
			   	end
			end)
		end}}, {isPopCurrentDialog = false})
end

function QUIWidgetSocietyUnionInfo:_onTriggerChangUnionName(event)
    if q.buttonEventShadow(event, self._ccbOwner.btnChangUnionName) == false then return end
    app.sound:playSound("common_small")
	if self._myOfficialPosition ~= SOCIETY_OFFICIAL_POSITION.BOSS then
		return
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSocietyGaiming", 
        options = {confirmCallback = function (newName)
        	if newName and remote.union.consortia.name and newName == remote.union.consortia.name then
        		app.tip:floatTip("新的宗门名不能与旧的宗门名相同！") 
        		return 
        	end
        	remote.union:unionUpdateSettingRequest(remote.union.consortia.applyTeamLevel, remote.union.consortia.authorize, newName, remote.union.consortia.icon,
        		(remote.union.consortia.applyPowerLimit or 0),function ( )
				if self._isExit then
					remote.user.userConsortia.consortiaName = newName
					self._ccbOwner.unionName:setString( newName )
			   		app.tip:floatTip("修改宗门宗门名称成功") 
			   		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.UNION_WIDGET_NAME_UPDATE})
			   	end
			end)
        end}}, {isPopCurrentDialog = false})
end

-- 群发邮件
function QUIWidgetSocietyUnionInfo:_onTriggerSendMail(event)
	--屏蔽群发邮件
	if true then
		return
	end
    if q.buttonEventShadow(event, self._ccbOwner.btn_sendMail) == false then return end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionAnnouncement", 
        options = {type = QUIDialogUnionAnnouncement.TYPE_UNION_MASS_MAIL, word = "", confirmCallback = function (word)
        	if #word > 0 then
        		remote.union:unionSendMassMailRequest(word, function()
        			-- self._announcement = word
        			-- self._ccbOwner.announcementStr:setString(string.format("　　%s",self._announcement))
        		end)
            end
        end}}, {isPopCurrentDialog = false})
end

function QUIWidgetSocietyUnionInfo:_onTriggerRule()
	app.sound:playSound("common_small")

	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSocietyManagerHelp"})
end

function QUIWidgetSocietyUnionInfo:onEnter()
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.UNION_CONSORTIA_KICKED_OTHER, self.kickedUnionMember, self)
	self._isExit = true

	if (remote.user.userConsortia.consortiaId == nil or remote.user.userConsortia.consortiaId == "") then
		return
	end
	
	self:updateData()
	self:setInfo()
end

function QUIWidgetSocietyUnionInfo:onExit()
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.UNION_CONSORTIA_KICKED_OTHER, self.kickedUnionMember, self)
	self._isExit = false
end

function QUIWidgetSocietyUnionInfo:updateData(  )
	 remote.union:unionMemberListRequest(function (data)
	 	if self._isExit then
	        self._memberList =  data.consortiaFighters
	        self:setInfo()
	    end
		
    end) 
end

function QUIWidgetSocietyUnionInfo:setInfo()
	if self._myOfficialPosition == SOCIETY_OFFICIAL_POSITION.BOSS then
		self._disbandedCallBack = function()
			app:alert({content = "是否要解散宗门", title = "宗门解散", redBtn = true, callback = function (state)
				if state == ALERT_TYPE.CONFIRM then
			        remote.union:unionDismissRequest(function ()
			            remote.user.userConsortia = {}
			            remote.union:resetUnionData()
			            app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
			            QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.UNION_SKILL_CHANGE})
			        end)
			    end
		    end}, false)
		end
	else
		self._ccbOwner.labelDisbanded:setString("退出宗门")
		self._disbandedCallBack = function()
			local quitUnionFunc = function()
		        remote.union:unionAutoLeaveRequest(function ()
		            remote.user.userConsortia = {}
		            remote.union:resetUnionData()
		            app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
		            QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.UNION_SKILL_CHANGE})
		        end)
			end

			local openServerTime = remote.activity:checkActivityIsInDays(0, 3, 5)
			local mergeServerTime = remote.activity:checkActivityIsInDays(0, 4, 0 , true)


			if openServerTime or mergeServerTime then
				quitUnionFunc()
			else
				local time = QStaticDatabase.sharedDatabase():getConfigurationValue("ENTER_SOCIETY") / 60 
				app:alert({content = "退出宗门后，需要等待"..time.."小时才能再次加入其它的宗门，是否退出？", title = "退出宗门", btns = {ALERT_BTN.BTN_OK_RED, ALERT_BTN.BTN_CANCEL}, 
					callback = function (state)
					if state == ALERT_TYPE.CONFIRM then
						quitUnionFunc()
				    end
		    	end}, false)
			end
		end
	end

	self._ccbOwner.btnChangeIcon:setVisible(self._myOfficialPosition == SOCIETY_OFFICIAL_POSITION.BOSS)
	self._ccbOwner.node_changeName:setVisible(self._myOfficialPosition == SOCIETY_OFFICIAL_POSITION.BOSS)

	-- 宗门头像
	local unionAvatar = QUnionAvatar.new(remote.union.consortia.icon, false, false)
    unionAvatar:setConsortiaWarFloor(remote.union.consortia.consortiaWarFloor)
	self._ccbOwner.iconNode:removeAllChildren()
	self._ccbOwner.iconNode:addChild(unionAvatar)

	-- 宗門名字
	self._ccbOwner.unionName:setString(remote.union.consortia.name or "")
	
	-- 宗門等級	
	local level = remote.union.consortia.level or 1
	self._ccbOwner.unionLevel:setString( "LV."..level )

	-- 宗門ID
	self._ccbOwner.id:setString((remote.union.consortia.id or ""))

	local societyConfig = QStaticDatabase:sharedDatabase():getSocietyLevel(level)
	if societyConfig then
		-- 宗門人數
		local memberLimit = societyConfig.sociaty_scale or 1
		local curMemberCount = remote.union.consortia.memberCount or 1
		self._ccbOwner.memberCount:setString(curMemberCount.."/"..memberLimit)

		local nodes = {}
		local curAdjutantCount = 0
		local curEliteCount = 0
		for _, fighter in ipairs(self._memberList) do
			if fighter.rank == SOCIETY_OFFICIAL_POSITION.ADJUTANT then
				-- 副官
				curAdjutantCount = curAdjutantCount + 1
			elseif fighter.rank == SOCIETY_OFFICIAL_POSITION.ELITE then
				-- 精英
				curEliteCount = curEliteCount + 1
			end
		end
		-- 宗門職位——副官
		local adjutantLimit = QStaticDatabase:sharedDatabase():getConfigurationValue("VICE_CHAIRMAN") or 0
		self._ccbOwner.tf_op_name_1:setString("副宗主：")
		self._ccbOwner.tf_op_count_1:setString(curAdjutantCount.."/"..adjutantLimit)
		table.insert(nodes, self._ccbOwner.tf_op_name_1)
		table.insert(nodes, self._ccbOwner.tf_op_count_1)
		q.autoLayerNode(nodes, "x", 5)
		-- 宗門職位——精英
		nodes = {}
		local eliteLimit = societyConfig.elite_num or 0
		self._ccbOwner.tf_op_name_2:setString("精英：")
		self._ccbOwner.tf_op_count_2:setString(curEliteCount.."/"..eliteLimit)
		table.insert(nodes, self._ccbOwner.tf_op_name_2)
		table.insert(nodes, self._ccbOwner.tf_op_count_2)
		q.autoLayerNode(nodes, "x", 5)
	end

	self._moveIndex = self._moveIndex > #self._memberList and #self._memberList or self._moveIndex
	if not self._listView then
		local cfg = {
	        renderItemCallBack = function( list, index, info )
	            local isCacheNode = true
	            local item = list:getItemFromCache()
	            local data = self._memberList[index]
	            if not item then
	                item = QUIWidgetSocietyUnionInfoSheet.new()
	                isCacheNode = false
	            end
	            item:setInfo(data, index)
	            info.item = item
	            info.size = item:getContentSize()

	         
	            list:registerClickHandler(index, "self", function ()
		            	return true
		            end, nil, "_onTriggerLook")

	            return isCacheNode
	        end,
	        spaceY = -3,
	        enableShadow = true,
	        totalNumber = #self._memberList,
	        curOriginOffset = -4,
	        curOffset = 5,
    	} 
    	self._listView = QListView.new(self._ccbOwner.listView, cfg)
    else
    	self._listView:reload({totalNumber = #self._memberList, isCleanUp = true}) 
    	if self._moveIndex > 3 then
    		self._listView:startScrollToIndex(self._moveIndex, true, 500)
    	end
	end
end

function QUIWidgetSocietyUnionInfo:_addMaskLayer(ccb, mask)
    local width = ccb:getContentSize().width
    local height = ccb:getContentSize().height
    local maskLayer = CCLayerColor:create(ccc4(0,0,0,150), width, height)
    maskLayer:setAnchorPoint(ccp(0, 0.5))
    maskLayer:setPosition(ccp(-width/2, -height/2))

    local ccclippingNode = CCClippingNode:create()
    ccclippingNode:setStencil(maskLayer)
    ccb:retain()
    ccb:removeFromParent()
    ccb:setPosition(ccp(-width/2, 0))
    ccclippingNode:addChild(ccb)
    ccb:release()

    mask:addChild(ccclippingNode)
    return maskLayer
end

function QUIWidgetSocietyUnionInfo:kickedUnionMember(event)
	if self.class then
		self._moveIndex = event.index or 0
		self:updateData()
	end
end

return QUIWidgetSocietyUnionInfo
