-- @Author: liaoxianbo
-- @Date:   2019-12-26 11:43:49
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2019-12-26 15:48:54
local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDailogCollegeTrainRule = class("QUIDailogCollegeTrainRule", QUIDialogBaseHelp)
local QListView = import("...views.QListView")
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QNavigationController = import("...controllers.QNavigationController")

function QUIDailogCollegeTrainRule:ctor(options)
    QUIDailogCollegeTrainRule.super.ctor(self, ccbFile, callBacks, options)
end

function QUIDailogCollegeTrainRule:viewDidAppear()
	QUIDailogCollegeTrainRule.super.viewDidAppear(self)

	self:addBackEvent(true)
end

function QUIDailogCollegeTrainRule:viewWillDisappear()
  	QUIDailogCollegeTrainRule.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDailogCollegeTrainRule:initData( options )
    options = options or {}

    local data = {}
    self._data = data
    table.insert(self._data,{oType = "describe", info = {helpType = "college_train"}})
    table.insert(self._data,{oType = "rankInfo"})

    if not self._listViewLayout then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local itemData = self._data[index]
                local item = list:getItemFromCache(itemData.oType)
                if not item then
                    if itemData.oType == "describe" then
                        item = QUIWidgetHelpDescribe.new()
                    elseif itemData.oType == "rankInfo" then
                        item = self:getRankInfo()
                    end    
                    isCacheNode = false
                end
                if itemData.oType == "describe" then
                    item:setInfo(itemData.info, itemData.title)
                end

                info.item = item
                info.size = item:getContentSize()
                return isCacheNode
            end,
            curOriginOffset = 15,
            enableShadow = false,
            ignoreCanDrag = true,
            totalNumber = #self._data,
        }
        self._listViewLayout = QListView.new(self._ccbOwner.sheet_layout,cfg)
    else
        self._listViewLayout:reload({#self._data})
    end
end

function QUIDailogCollegeTrainRule:getRankInfo()
    local node = CCNode:create()
    local titleNode = QUIWidget.new("ccb/Widget_Base_Help_mingrentang.ccbi")
    titleNode:setPositionY(-10)
    titleNode._ccbOwner.node_line_1:setVisible(false)
    titleNode._ccbOwner.node_line_2:setVisible(false)
    titleNode._ccbOwner.tf_ttitle_2:setVisible(false)
    titleNode._ccbOwner.tf_ttitle_4:setVisible(false)
    titleNode._ccbOwner.tf_ttitle_3:setString("竞速积分")
    node:addChild(titleNode)

    local height = 60
    for index=1,10 do
    	local jifen = db:getFamousPersonValueByRank("college_train", index) or 0
        local rankNode = QUIWidget.new("ccb/Widget_Base_Help_mingrentangrank.ccbi")
        rankNode._ccbOwner.tf_rank:setString("第"..index.."名")
        rankNode._ccbOwner.tf_num1:setVisible(false)
        rankNode._ccbOwner.tf_num3:setVisible(false)
        rankNode._ccbOwner.tf_num2:setString(jifen)
        rankNode._ccbOwner.node_bg:setVisible( (index%2==0) ) 
        rankNode:setPositionY(-height)
        node:addChild(rankNode)

        height = height + 40
    end
    node:setContentSize(CCSize(100, height))

    return node
end

function QUIDailogCollegeTrainRule:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDailogCollegeTrainRule
