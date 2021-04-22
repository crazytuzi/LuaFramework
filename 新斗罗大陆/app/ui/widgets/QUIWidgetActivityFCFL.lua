--
-- Author: Kumo
-- Date: 2015-07-15 11:39:38
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetActivityFCFL = class("QUIWidgetActivityFCFL", QUIWidget)

local QUIWidgetActivityFCFLItem = import("..widgets.QUIWidgetActivityFCFLItem")
local QScrollContain = import("..QScrollContain")
local QQuickWay = import("...utils.QQuickWay")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIViewController = import("..QUIViewController")
local QListView = import("...views.QListView")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIWidgetActivityFCFL:ctor(options)
	local ccbFile = "ccb/Widget_activivt_fcfl.ccbi"
  	local callBacks = {}
	QUIWidgetActivityFCFL.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetActivityFCFL:setInfo( info )
    self._info = info

    local yuan = info.rechargeFeedback.rechargeAmount or 0
    local token = yuan * 20
    local vipExp = yuan * 10
    local introduceStr = "您在《新斗罗大陆》两次删档计费测试中累计充值"..yuan.."元，本次不删档测试用同一账号登录将得到"..token.."钻石，"..vipExp.."VIP经验的返还；感谢您一直以来对《新斗罗大陆》的支持！"
    self._ccbOwner.tf_info:setString(introduceStr)

    self._selectInfo = info.targets
    for _, value in ipairs(self._selectInfo) do
    	value.rechargeAmount = info.rechargeFeedback.rechargeAmount
    	value.loginDaysCount = info.loginDaysCount
    	value.isComplete = false
    	for _, id in pairs(info.rechargeFeedback.gotRewardIds or {}) do
    		if id == value.id then
    			value.isComplete = true
    		end
    	end
    end

    table.sort(self._selectInfo, function(a, b)
    		if a.isComplete and not b.isComplete then
    			return false
			elseif not a.isComplete and not b.isComplete then
    			return a.id < b.id
			elseif not a.isComplete and b.isComplete then
				return true
			else
				return a.id < b.id
			end
    	end)
    if not self._infoListView then
		self:initListView()
	else
		self._infoListView:reload({totalNumber = #self._selectInfo})
	end
end

function QUIWidgetActivityFCFL:initListView()
    if type(self._selectInfo) ~= "table" then
        self._selectInfo = {}
    end

    local cfg = {
        renderItemCallBack = function( list, index, info )
            local isCacheNode = true
            local item = list:getItemFromCache()
            local data = self._selectInfo[index]
            if not item then
                item = QUIWidgetActivityFCFLItem.new()
                isCacheNode = false
            end
            item:setInfo(data)
            info.item = item
            info.size = item:getContentSize()

            list:registerBtnHandler(index, "btn_ok", handler(self, self.onTriggerConfirm), nil, true)
            item:registerItemBoxPrompt(index,list)
            return isCacheNode
        end,
        spaceY = 2,
        enableShadow = false,
        totalNumber = #self._selectInfo,
    }  
    self._infoListView = QListView.new(self._ccbOwner.menu_sheet_layout,cfg)
end


function QUIWidgetActivityFCFL:onTriggerConfirm( x, y, touchNode, listView )
	app.sound:playSound("common_confirm")
    local touchIndex = listView:getCurTouchIndex()
    local item = listView:getItemByIndex(touchIndex)
    local state = item:getState()
    local id = item:getId()
    local info = item:getInfo()
    if state and id and info then
        if state == 1 then
			app:getClient():getRechargeFeedbackGetRewardRequest(id, function(data)
                    remote.activity:updateFCFL(data)
					self:getRewards(info)
				end)
		elseif state == 0 then
			app.tip:floatTip("条件不足")
		else
			return
		end	
    end
end

function QUIWidgetActivityFCFL:getRewards(info)
	app.sound:playSound("common_confirm")
	local awards = {}
	local yuan = info.rechargeAmount
    local token = yuan * info.token_feed_back
    table.insert(awards, {id = nil, type = ITEM_TYPE.TOKEN_MONEY, count = token})
    local vipExp = yuan * info.vip_exp_feed_back
    table.insert(awards, {id = nil, type = ITEM_TYPE.VIP, count = vipExp})

	local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
		options = {awards = awards, callBack = handler(self, self.refreshData)}},{isPopCurrentDialog = false} )
	dialog:setTitle("恭喜您获得封测返利")
end

function QUIWidgetActivityFCFL:refreshData()
    self:setInfo(self._info)
	-- app:getClient():getRechargeFeedbackInfo(function( data )
	--         -- QPrintTable(data)
	--         data.title = "封测返利"
	--         local config = QStaticDatabase.sharedDatabase():getRechargeFeedback()
	--         data.targets = {}
	--         for _, value in pairs(config) do
	--             table.insert(data.targets, value)
	--         end
	--         data.activityId = "kfjj"
	--         data.type = remote.activity.TYPE_FENG_CE_FAN_LI
	--         self:setInfo(data)
	--     end)
end

function QUIWidgetActivityFCFL:onEnter()
end

function QUIWidgetActivityFCFL:onExit()
end

return QUIWidgetActivityFCFL