
local QUIDialogBaseHelp = import(".QUIDialogBaseHelp")
local QUIDialogHeroSsSparGradeRule = class("QUIDialogHeroSsSparGradeRule", QUIDialogBaseHelp)
local QRichText = import("...utils.QRichText")
local QListView = import("...views.QListView")
--初始化
function QUIDialogHeroSsSparGradeRule:ctor(options)
	QUIDialogHeroSsSparGradeRule.super.ctor(self,options)

	self._itemId = options.itemId
	self._ccbOwner.frame_tf_title:setString("升星碎片消耗")
	
	
end

function QUIDialogHeroSsSparGradeRule:initData()
	self._needInfo = { 50, 80, 110, 140, 180 }
	self._maxLevel = 5

	self._showInfo = {}
	for i=1, self._maxLevel do
		table.insert(self._showInfo, string.format("%s星升级到%s星需要碎片%s片", q.numToWord(i - 1), q.numToWord(i), tostring(self._needInfo[i])))
	end

	printTable(self._showInfo)
end

function QUIDialogHeroSsSparGradeRule:renderItemFunc(list, index, info)
	local isCacheNode = true
	local item = list:getItemFromCache()
	if not item then
		item = QRichText.new({
			{oType = "font", content = self._showInfo[index] ,size = 20, color = ccc3(134,85,55)}
		})
		isCacheNode = false
	end
	item:setAnchorPoint(0, 1)
	info.item = item
	info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogHeroSsSparGradeRule:initListView( ... )
	local cfg = {
		renderItemCallBack = handler(self, self.renderItemFunc),
		ignoreCanDrag = true,
		contentOffsetX = 30,
		contentOffsetY = -20,
		spaceY = 5,

		totalNumber = #self._showInfo
	}
	self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
end

return QUIDialogHeroSsSparGradeRule
