--
-- Kumo
-- Date: Sat Jun  4 10:57:28 2016
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionDragonTrainBox = class("QUIDialogUnionDragonTrainBox", QUIDialog)

local QListView = import("...views.QListView") 
local QUIWidgetUnionDragonTrainBox = import("..widgets.dragon.QUIWidgetUnionDragonTrainBox")

function QUIDialogUnionDragonTrainBox:ctor(options)
	local ccbFile = "ccb/Dialog_Society_Dragon_Task_Box.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogUnionDragonTrainBox.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true --是否动画显示
    self._ccbOwner.frame_tf_title:setString("武魂回馈")

	self:_init()
end

function QUIDialogUnionDragonTrainBox:viewDidAppear()
	QUIDialogUnionDragonTrainBox.super.viewDidAppear(self)
end

function QUIDialogUnionDragonTrainBox:viewWillDisappear()
  	QUIDialogUnionDragonTrainBox.super.viewWillDisappear(self)
end

function QUIDialogUnionDragonTrainBox:viewAnimationInHandler()
	QUIDialogUnionDragonTrainBox.super.viewAnimationInHandler(self)
	self:_initListView()
end

function QUIDialogUnionDragonTrainBox:_init()
	self._configs = remote.dragon:getTaskBoxConfigList()

    local newconfigs = {}
    for _,v in pairs(self._configs) do
        v.isOpenBox = remote.dragon:isTaskBoxOpenedByBoxId(v.box_id)
        table.insert(newconfigs,v)
    end
    table.sort(newconfigs,function(a,b)
        if a.isOpenBox ~= b.isOpenBox then
            return b.isOpenBox == true
        else
            return tonumber(a.box_id) < tonumber(b.box_id)
        end
    end)

    self._configs = newconfigs
end

function QUIDialogUnionDragonTrainBox:_initListView()
    if not self._listView then
	    local cfg = {
	        renderItemCallBack = handler(self, self.reandFunHandler),
	        spaceX = 0,
            spaceY = 0,
            isVertical = true,
            multiItems = 1,
            curOffset = 0,
            enableShadow = false,
	        totalNumber = #self._configs,
	    }  
	    self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._listView:reload({totalNumber = #self._configs})
	end
end

function QUIDialogUnionDragonTrainBox:reandFunHandler( list, index, info )
    local isCacheNode = true
    local config = self._configs[index]
    local item = list:getItemFromCache()

    local function showItemInfo(x, y, itemBox, listView)
        app.tip:itemTip(itemBox._itemType, itemBox._itemID, true)
    end

    if not item then
        item = QUIWidgetUnionDragonTrainBox.new()
        item:addEventListener(QUIWidgetUnionDragonTrainBox.EVENT_CLICK, handler(self, self.cellClickHandler))
        isCacheNode = false
    end

    item:setInfo(config, self)
    info.item = item
    info.size = item:getContentSize()

    list:registerBtnHandler(index, "btn_done", "_onTriggerClickAwards")
    for i, box in ipairs(item.boxList) do
        list:registerItemBoxPrompt(index, i, box, nil, showItemInfo)
    end

    return isCacheNode
end

function QUIDialogUnionDragonTrainBox:cellClickHandler(event)
    local boxId = event.boxId
    if not boxId then
        return
    end

    remote.dragon:consortiaDragonGetBoxPrizeRequest({boxId}, false,function(data)
            if self:safeCheck() then
                if data and data.error == "NO_ERROR" and data.prizes then
                    if data.consortiaGetDragonInfoResponse then
                        local dragonExp = data.consortiaGetDragonInfoResponse.dragonExp
                        if dragonExp and dragonExp ~= "" then
                            local tbl = string.split(dragonExp, "^")
                            table.insert(data.prizes, {id = remote.dragon.EXP_RESOURCE_ID, type = remote.dragon.EXP_RESOURCE_TYPE, count = tonumber(tbl[2])})
                        else
                            app.tip:floatTip("本周宗门武魂回馈经验领取次数已达上限")
                        end
                        -- local boxOpenParam = data.consortiaGetDragonInfoResponse.boxOpenParam or ""
                        -- local boxOpenList = string.split(boxOpenList, ";")
                        -- for i, boxInfo in ipairs(boxOpenList) do
                        --     local boxTbl = string.split(boxInfo, ",")
                        --     if tonumber(boxTbl[1]) == boxId then
                        --         local level = remote.union.consortia.level or 1
                        --         local memberLimit = db:getSocietyMemberLimitByLevel(level) or 1
                        --         if tonumber(boxTbl[2]) > memberLimit then
                        --             app.tip:floatTip("本周宗门武魂回馈经验已达上限")
                        --         end
                        --         break
                        --     end
                        -- end
                    end
                    self:_init()
                    self:_initListView()
                    remote.dragon:showRewardForDialog(data.prizes)
                end
            end
        end)
end


function QUIDialogUnionDragonTrainBox:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
    if app.sound ~= nil and e then
        app.sound:playSound("common_close")
    end
    self:playEffectOut()
end

function QUIDialogUnionDragonTrainBox:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogUnionDragonTrainBox:viewAnimationOutHandler()
    local options = self:getOptions()
    local callBack = options.callBack
    self:popSelf()

    if callBack ~= nil then
        callBack()
    end
end

return QUIDialogUnionDragonTrainBox