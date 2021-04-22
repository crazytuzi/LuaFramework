local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogTeamHelperAddInfo = class("QUIDialogTeamHelperAddInfo", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")
local QColorLabel = import("...utils.QColorLabel")
local QListView = import("...views.QListView")
local QUIWidgetTeamHelperAddInfo = import("..widgets.QUIWidgetTeamHelperAddInfo")

function QUIDialogTeamHelperAddInfo:ctor(options)
	local ccbFile = "ccb/Dialog_metal_add_buff.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogTeamHelperAddInfo.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true
    self._ccbOwner.node_right_center:setVisible(false)

    self:setInfo(options)
    self._ccbOwner.frame_tf_title:setString("援助加成")
    if options.isInherit then
        self._ccbOwner.frame_tf_title:setString("传承加成")
    end
    if options.isEquilibrium then
        self._isEquilibrium = true
        self._ccbOwner.frame_tf_title:setString("均衡加成")
    end
end

function QUIDialogTeamHelperAddInfo:_backClickHandler()
	self:_onTriggerClose()
end




function QUIDialogTeamHelperAddInfo:setInfo(options)

    if not self._propListView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                -- body
                local isCacheNode = true
                local item = list:getItemFromCache()
                if not item then
                    item = QUIWidgetTeamHelperAddInfo.new()
                    isCacheNode = false
                end
                item:setInfo(self._options)
                info.item = item
                info.size = item:getContentSize()
                return isCacheNode
            end,
            ignoreCanDrag = true,
            enableShadow = false,
            isVertical = true,
            totalNumber = 1,
            contentOffsetX = 0 ,
        }  
        self._propListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._propListView:reload({totalNumber = 1})
    end
end

function QUIDialogTeamHelperAddInfo:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
    if event ~= nil then
        app.sound:playSound("common_cancel")
    end
	self:playEffectOut()
end

function QUIDialogTeamHelperAddInfo:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogTeamHelperAddInfo