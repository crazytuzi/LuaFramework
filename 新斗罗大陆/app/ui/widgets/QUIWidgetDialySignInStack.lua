local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetDialySignInStack = class("QUIWidgetDialySignInStack", QUIWidget)

local QUIWidgetDailySignInBox = import("..widgets.QUIWidgetDailySignInBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")

QUIWidgetDialySignInStack.RECEIVE_SUCCEED = "RECEIVE_SUCCEED"

function QUIWidgetDialySignInStack:ctor(options)
	local ccbFile = "ccb/Widget_DailySignIn_leiji.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTirrgerClickReceive", callback = handler(self, QUIWidgetDialySignInStack._onTirrgerClickReceive)}
	}
	QUIWidgetDialySignInStack.super.ctor(self, ccbFile, callBacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    
	self.itemBox = {}

	self._ccbOwner.stack_sign_num_all:setString("")
	self._ccbOwner.stack_sign_num:setString("")

	self:setSignNum()
end

function QUIWidgetDialySignInStack:onEnter()

end

function QUIWidgetDialySignInStack:onExit()
	
end

function QUIWidgetDialySignInStack:setSignNum()
	local signNum, signAward = remote.daily:getAddUpSignIn()
	self.award = QStaticDatabase:sharedDatabase():getAddUpSignInItmeByMonth(signNum, signAward)
	self.nowNum = signNum
	self.maxNum = self.award.times
	if self.award.times == self.nowNum then
		self._ccbOwner.stack_sign_num_all:setString("（"..signNum.."/"..self.award.times.."）")
		self._ccbOwner.stack_sign_num:setString("")
		--self._ccbOwner.stack_sign_num:setColor(ccc3(255, 263, 168))
	else
		self._ccbOwner.stack_sign_num_all:setString("（"..signNum.."/"..self.award.times.."）")
		self._ccbOwner.stack_sign_num:setString("")
		--self._ccbOwner.stack_sign_num:setColor(UNITY_COLOR.red)
	end
	-- UNITY_COLOR.red
	self:setItem()
end

function QUIWidgetDialySignInStack:setItem()
	for i = 1, 3, 1 do
		if self.itemBox[i] == nil then
			self.itemBox[i] = QUIWidgetDailySignInBox.new({type = "ADD_UP"})
			self.itemBox[i]:addEventListener(QUIWidgetDailySignInBox.ADD_EVENT_CLICK, handler(self, self._onTirrgerClickReceive))

			local contentSzie = self.itemBox[i]:getContentSize()
			self.itemBox[i]:setPosition(ccp(- contentSzie.width/2+5, contentSzie.height/2 + 8))
			self._ccbOwner["node"..i]:addChild(self.itemBox[i])
    		self.itemBox[i]:ininGLLayer()
		end

		local state = QUIWidgetDailySignInBox.IS_WAITING
		if self.nowNum >= self.maxNum then
			state = QUIWidgetDailySignInBox.IS_READY
		end

		self.itemBox[i]:setItemBoxInfo(self.award["type_"..i], self.award["id_"..i], self.award["num_"..i], self.maxNum, state,nil,true)
	end
end


function QUIWidgetDialySignInStack:_onTirrgerClickReceive(data)
    app.sound:playSound("common_common")
	if data.items[1].typeName ~= nil then
		if self.nowNum >= self.maxNum then
			app:getClient():addUpSignIn(self.award.times, function(data)
                    if self.class ~= nil then
                        self:showRewords(self.award)
                        self:dispatchEvent({name = QUIWidgetDialySignInStack.RECEIVE_SUCCEED})
                    end
				end)
		else
			local typeName = remote.items:getItemType(data.items[1].typeName)
			if typeName == ITEM_TYPE.MONEY or typeName == ITEM_TYPE.TOKEN_MONEY then
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDailySignInCurrencyPrompt" , options = {type = data.items[1].typeName, index = data.index,  isStack = true}},
					{isPopCurrentDialog = false})
			else
				local itemInfo = QStaticDatabase.sharedDatabase():getItemByID(data.items[1].id)
				if itemInfo.type == 3 then
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDailySignInChipPrompt" , options = {itemInfo = itemInfo, id = data.items[1].id, index = data.index, isStack = true}},
						{isPopCurrentDialog = false})
				elseif itemInfo ~= nil then
					app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogDailySignInItemPrompt" , options = {itemInfo = itemInfo, id = data.items[1].id, index = data.index, isStack = true}},
						{isPopCurrentDialog = false})
				end
			end
		end
	end
end

function QUIWidgetDialySignInStack:showRewords(data)
    local awards = {}
    for i = 1, 3, 1 do
        table.insert(awards, {id = data["id_"..i], typeName = data["type_"..i], count = data["num_"..i]})
    end
    local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
            options = {awards = awards}},{isPopCurrentDialog = false} )
    dialog:setTitle("恭喜您获得累积签到奖励")
end

return QUIWidgetDialySignInStack
