-- @Author: liaoxianbo
-- @Date:   2020-09-14 16:08:04
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-14 16:52:14
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogCreateUnion = class("QUIDialogCreateUnion", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUnionAvatar = import("...utils.QUnionAvatar")
local QQuickWay = import("...utils.QQuickWay")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QMaskWords = import("...utils.QMaskWords")
local QVIPUtil = import("...utils.QVIPUtil")

QUIDialogCreateUnion.NO_INPUT_ERROR = "宗门名称不能为空"
QUIDialogCreateUnion.INVALID_INPUT_ERROR = "无效的名字"
QUIDialogCreateUnion.DEFAULT_PROMPT = "请输入宗门名称"
QUIDialogCreateUnion.CANNOT_ALL_NUMBER = "宗门名不能全部由数字构成"
local cost = 500

function QUIDialogCreateUnion:ctor(options)
	local ccbFile = "ccb/Dialog_union_creat_new.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
      	{ccbCallbackName = "onTriggerIcon", callback = handler(self, self._onTriggerIcon)},
      	{ccbCallbackName = "onTriggerFound", callback = handler(self, self._onTriggerFound)},		
    }
    QUIDialogCreateUnion.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
    self._ccbOwner.name:setString("")

    q.setButtonEnableShadow(self._ccbOwner.btn_creat)
    self._ccbOwner.frame_tf_title:setString("创建宗门")

	-- add input box
    self._unionName = ui.newEditBox({image = "ui/none.png", listener = self.onEdit, size = CCSize(310, 36)})
    self._unionName:setFont(global.font_default, 22)
    self._unionName:setMaxLength(7) 
    -- self._unionName:setAnchorPoint(ccp(0, 0.5))
    self._unionName:setPlaceHolder(QUIDialogCreateUnion.DEFAULT_PROMPT)
    self._ccbOwner.name:addChild(self._unionName)
    self._ccbOwner.token:setString(cost)

    local unionAvatar = QUnionAvatar.new(db:getDefaultUnionIcon(), false, false)
    unionAvatar:setConsortiaWarFloor(remote.union.consortia.consortiaWarFloor)
    self._ccbOwner.node_item:removeAllChildren()
    self._ccbOwner.node_item:addChild(unionAvatar)
end

function QUIDialogCreateUnion:viewDidAppear()
	QUIDialogCreateUnion.super.viewDidAppear(self)

	self:addBackEvent(false)
end

function QUIDialogCreateUnion:viewWillDisappear()
  	QUIDialogCreateUnion.super.viewWillDisappear(self)

	self:removeBackEvent()
end


function QUIDialogCreateUnion:onEdit(event, editbox)
    if event == "began" then

    elseif event == "changed" then

    elseif event == "ended" then
        -- 输入结束
    elseif event == "return" then
        -- 从输入框返回
    end
end

function QUIDialogCreateUnion:_onTriggerIcon()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionHead", 
		options = {type = 1, newAvatarSelected = function (icon)
            local unionAvatar = QUnionAvatar.new(icon, false, false)
            unionAvatar:setConsortiaWarFloor(remote.union.consortia.consortiaWarFloor)
		    self._ccbOwner.node_item:removeAllChildren()
		    self._ccbOwner.node_item:addChild(unionAvatar)
			self._unionIcon = icon
		end}}, {isPopCurrentDialog = false})
end

function QUIDialogCreateUnion:_onTriggerFound(event)
    if event ~= nil then
        app.sound:playSound("common_common")
    end


	local newName = self._unionName:getText()
	if self:_invalidNames(newName) then
		return
	end

	if remote.user.token < cost then
        QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil, nil, function ()
			app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
        end)
        return
	end

    local nowTime = q.serverTime()
    local realOpenServerTime = (remote.user.realOpenServerTime or 0) / 1000
    local offsetTime = (nowTime - realOpenServerTime) / MIN
    local limtMin = db:getConfigurationValue("CREATE_CONSORTIA_AFTER_USER_MAKE_TEAM_AT")
    if offsetTime < limtMin then 
        local minStr = math.floor(limtMin - offsetTime) 
        app.tip:floatTip(minStr.."分钟后可创建宗门")
        return
    end


    if remote.user.userConsortia and remote.user.userConsortia.last_create_at and remote.user.userConsortia.last_create_at ~= FOUNDER_TIME then
        local curTime = q.serverTime() * 1000
        local cdEndTime = remote.user.userConsortia.last_create_at + DAY * 1000
        if curTime <= cdEndTime then
            app.tip:floatTip("二十四小时内只能创建一次宗门，请稍后再试")
            return 
        end
    end

    if app.unlock:checkLock("UNLOCK_UNION_1", false) == false then
        local unlockInfo = app.unlock:getConfigByKey("UNLOCK_UNION_1")
        local battleForce = remote.user:getTopNForce()
        if unlockInfo.force > battleForce then
            local force, word = q.convertLargerNumber(unlockInfo.force)
            app.tip:floatTip(string.format("魂师大人，您的战力还未达到创建要求（%s%s战力），请加油哦~", force, word))
        elseif unlockInfo.need_vip > QVIPUtil:VIPLevel() then
            local text = "VIP达到"..unlockInfo.need_vip.."级可创建，是否前往充值提升VIP等级？"
            app:vipAlert({content=text}, false)
        end
        return
    end

    local callback = function (state)
        if state == ALERT_TYPE.CONFIRM then
            remote.union:unionFoundRequest(newName, self._unionIcon or QStaticDatabase:sharedDatabase():getDefaultUnion().id, function(data)
                remote.union:unionOpenRequest(function (data)
                        if next(data.consortia) then
                            app.tip:floatTip("恭喜您，创建宗门成功！")
                            remote.union:resetSocietyDungeonData()
                            app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
                            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyUnionMain", options = {info = data.consortia}})
                        end
                    end)
                end)
        end
    end

    app:alert({content = "是否要创建宗门", callback = callback}, false)
end

function QUIDialogCreateUnion:_invalidNames(newName)
    if newName == "" then
        app.tip:floatTip(QUIDialogCreateUnion.NO_INPUT_ERROR)
        return true
    elseif tonumber(newName) then
        app.tip:floatTip(QUIDialogCreateUnion.CANNOT_ALL_NUMBER)
        return true
    elseif QMaskWords:isFind(newName) then
        app.tip:floatTip(QUIDialogCreateUnion.INVALID_INPUT_ERROR)
        return true

    else
        return false
    end
end

function QUIDialogCreateUnion:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogCreateUnion:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogCreateUnion:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogCreateUnion
