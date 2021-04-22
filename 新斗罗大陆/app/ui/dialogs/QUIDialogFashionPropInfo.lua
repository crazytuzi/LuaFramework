--
-- Kumo.Wang
-- 時裝衣櫃属性展示
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogFashionPropInfo = class("QUIDialogFashionPropInfo", QUIDialog)

local QListView = import("...views.QListView")
local QUIWidgetFashionPropInfo = import("..widgets.QUIWidgetFashionPropInfo")

function QUIDialogFashionPropInfo:ctor(options)
	local ccbFile = "ccb/Dialog_Fashion_PropView.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogFashionPropInfo.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	if options then
		self._quality = options.quality
	end
	self._ccbOwner.frame_tf_title:setString(remote.fashion:getQualityCNameByQuality(self._quality).."宝录属性")

	self._data = {}

	if self._quality then
		local configs = db:getStaticByName("skins_wardrobe_prop")
	    for _, config in pairs(configs) do
	        if config.quality and tostring(config.quality) == tostring(self._quality) then
	            table.insert(self._data, config)
	        end
	    end
	    table.sort(self._data, function(a, b)
	    	return a.condition < b.condition
	    end)

	    QKumo(self._data)
		self:initListView()
	end
end

function QUIDialogFashionPropInfo:initListView()
	if not self._data then return end

    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        enableShadow = false,
	        totalNumber = #self._data,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:refreshData()
	end
end

function QUIDialogFashionPropInfo:renderFunHandler(list, index, info)
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetFashionPropInfo.new()
        isCacheNode = false
    end
    info.item = item
	item:setInfo(itemData)
    info.size = item:getContentSize()

	return isCacheNode
end

function QUIDialogFashionPropInfo:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_close")
	
	self:playEffectOut()
end

function QUIDialogFashionPropInfo:_backClickHandler()
	self:playEffectOut()
end

return QUIDialogFashionPropInfo