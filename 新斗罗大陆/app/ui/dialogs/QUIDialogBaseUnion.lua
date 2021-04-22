--[[	
	文件名称：QUIDialogSocietyUnionManage.lua
	创建时间：2016-03-23 17:51:09
	作者：nieming
	描述：QUIDialogSocietyUnionManage 宗门管理
]]

local QUIDialog = import(".QUIDialog")
local QUIDialogBaseUnion = class("QUIDialogBaseUnion", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetSocietyName = import("..widgets.QUIWidgetSocietyName")
local QUIWidgetDragonTrainBuffIcon = import("..widgets.QUIWidgetDragonTrainBuffIcon")

function QUIDialogBaseUnion:ctor( ccbFile,callBacks,options )
	-- body
	QUIDialogBaseUnion.super.ctor(self,ccbFile,callBacks,options)
	
	if (not remote.user.userConsortia.consortiaId or remote.user.userConsortia.consortiaId == "") then	
		app:alert({content = "您被移出宗门！", title = "系统提示", callback = function (state)
                app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
            end},false,true)
		return
	end

	local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page.setScalingVisible then page:setScalingVisible(false) end

	self:setSocietyTopBar(page)
    if self.__cname ~= "QUIDialogSocietyMap" then
    	self._societyNamewidget = QUIWidgetSocietyName.new()
	    self._societyNamewidget:setPosition(ccp(-display.ui_width/2 + 220,display.height/2))
	    self._view:addChild(self._societyNamewidget)


	    if remote.union:isDragonTrainBuff() then
	    	self._societyDragonTrainBuffIcon = QUIWidgetDragonTrainBuffIcon.new()
		    self._societyDragonTrainBuffIcon:setPosition(ccp(-display.ui_width/2 + 220 + 180, display.height/2 - 30))
		    self._view:addChild(self._societyDragonTrainBuffIcon)
		else
			if self._societyDragonTrainBuffIcon then
				self._societyDragonTrainBuffIcon:removeFromParent()
				self._societyDragonTrainBuffIcon = nil
			end
	    end
    end

    self._markProxy = cc.EventProxy.new(remote.mark)

	self:_init(options)
end

function QUIDialogBaseUnion:_init( options )
	-- body
end
function QUIDialogBaseUnion:jobChange( event )
	-- body
	if event and self._appear and not app.battle  then
		local str
		if event.oldRank < event.newRank then
			if event.newRank == SOCIETY_OFFICIAL_POSITION.ADJUTANT then
				str = "恭喜您！荣升为副宗主"
			elseif event.newRank == SOCIETY_OFFICIAL_POSITION.BOSS then
				str = "恭喜您！荣升为宗主"
			elseif event.newRank == SOCIETY_OFFICIAL_POSITION.ELITE then
				str = "恭喜您！荣升为精英"
			end
		else
			if event.newRank == SOCIETY_OFFICIAL_POSITION.ELITE then
				str = "您被降职为精英"
			else
				str = "您被降职为普通成员"
			end
			remote.mark:cleanMark(remote.mark.MARK_CONSORTIA_APPLY)
		end
		app.tip:floatTip(str)

		self:handleJobChange()
	end
end

function QUIDialogBaseUnion:kickedUnion(  )
	-- body
	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.UNION_SKILL_CHANGE})
	--战力发生变化 拉取战力变化
	app:getClient():refreshForce()

	remote.mark:cleanMark(remote.mark.MARK_CONSORTIA_APPLY)

	self:handleKickedUnion()
end

function QUIDialogBaseUnion:unionInfoUpdate(  )
	-- body

	self:handleUnionInfoUpdate()
end

function QUIDialogBaseUnion:redTipsChange( event )
	-- body
	--五点刷新宗门建设小红点
	if event.markTbl and event.markTbl[remote.mark.MARK_TIME_FIVE] then
		remote.mark:analysisMark(remote.mark.MARK_CONSORTIA_SACRIFICE)
		
	end

	if event.markTbl  and (event.markTbl[remote.mark.MARK_CONSORTIA_APPLY] or event.markTbl[remote.mark.MARK_CONSORTIA_SACRIFICE] ) then
		self:handleRedTipsUpdate()
	end
end

function QUIDialogBaseUnion:handleKickedUnion(  )
	-- body
	if self._appear and not app.battle then
		app:alert({content = "您被移出宗门！", title = "系统提示", callback = function (state)
            app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
        end},false,true)
	end
		
end

function QUIDialogBaseUnion:handleJobChange(  )
	-- body

end

function QUIDialogBaseUnion:handleUnionInfoUpdate(  )
	-- body

end


function QUIDialogBaseUnion:handleRedTipsUpdate(  )
	-- body
end

function QUIDialogBaseUnion:setSocietyNameVisible(visible)
	if self._societyNamewidget then
		self._societyNamewidget:setVisible(visible)
	end
	if self._societyDragonTrainBuffIcon then
		self._societyDragonTrainBuffIcon:setVisible(visible)
	end
end

function QUIDialogBaseUnion:setSocietyTopBar(page)
	if page and page.topBar then
	    if self.__cname == "QUIDialogSocietyUnionSkill" then
	    	page.topBar:showWithUnionSkill()
	    else
	    	page.topBar:showWithUnionNormal()
	    end
	end
end

--describe：viewDidAppear 
function QUIDialogBaseUnion:viewDidAppear()
	--代码
	QUIDialogBaseUnion.super.viewDidAppear(self)

	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.UNION_CONSORTIA_KICKED, QUIDialogBaseUnion.kickedUnion, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.UNION_JOB_CHANGE, QUIDialogBaseUnion.jobChange, self)
	QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.UNION_INFO_UPDATE, QUIDialogBaseUnion.unionInfoUpdate, self)
	
	local topPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if topPage then
		local isShow = false
		if self.__cname == "QUIDialogSocietyUnionMain" then
			if topPage.setChatButtonZOrder then
				self._chatZOrder = topPage:setChatButtonZOrder(9997)
		    end
		    topPage.inUnionPage = true
		    isShow = true
		end
		if topPage.setChatButton then
			topPage:setChatButton(isShow)
		end
		if topPage.setChatInUnion then
			topPage:setChatInUnion(true)
		end
		if topPage.setLevelGuidButton then
			topPage:setLevelGuidButton(isShow)
		end
	end

	if self._markProxy then
		self._markProxy:addEventListener(remote.mark.EVENT_UPDATE, handler(self, self.redTipsChange))
	end

	self:addBackEvent(false)
end


-- describe：viewWillDisappear 
function QUIDialogBaseUnion:viewWillDisappear()
	--代码
	QUIDialogBaseUnion.super.viewWillDisappear(self)
	
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.UNION_CONSORTIA_KICKED, QUIDialogBaseUnion.kickedUnion, self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.UNION_JOB_CHANGE, QUIDialogBaseUnion.jobChange, self)
	QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.UNION_INFO_UPDATE, QUIDialogBaseUnion.unionInfoUpdate, self)

	local topPage = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
	if topPage then
		if self.__cname == "QUIDialogSocietyUnionMain" then
			if topPage.setChatButton then
		    	topPage:setChatButtonZOrder(self._chatZOrder)
		    end
		    topPage.inUnionPage = false
		end
		if topPage.setChatInUnion then
			topPage:setChatInUnion(false)
		end		
	end
	self:removeBackEvent()

	if self._markProxy then
		self._markProxy:removeAllEventListeners()
		self._markProxy = nil
	end
end

function QUIDialogBaseUnion:onTriggerBackHandler(tag)
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end



return QUIDialogBaseUnion
