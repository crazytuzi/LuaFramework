local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBlackRockPassLost = class("QUIDialogBlackRockPassLost", QUIDialog)
local QRichText = import("...utils.QRichText") 

function QUIDialogBlackRockPassLost:ctor(options)
	local ccbFile = "ccb/Dialog_Black_mountain_zdsb_xnn.ccbi"
	local callBacks = {
        -- {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogBlackRockPassLost.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._award = options.award
	self._callBack = options.callback
    self._endScore = self._award.awardScore or 0

	local rt = QRichText.new(nil, 380)
    rt:setAnchorPoint(ccp(0,1))
    local time = q.date("*t", self._award.happenAt/1000)
    local timeStr = string.format("%.2d-%.2d %.2d:%.2d", time.month, time.day, time.hour, time.min)
    local starStr = "未获得星级"
    local tfTbl = {}
    local chapterName = remote.blackrock:getChapterById(self._award.chapterId)[1].name
    table.insert(tfTbl, {oType = "font", content = "魂师大人，您在", size = 24, color = COLORS.a})
    table.insert(tfTbl, {oType = "font", content = timeStr..chapterName, size = 24, color = COLORS.M})
    table.insert(tfTbl, {oType = "font", content = "的组队战中", size = 24, color = COLORS.a})
    table.insert(tfTbl, {oType = "font", content = starStr, size = 24, color = COLORS.M})
    -- table.insert(tfTbl, {oType = "font", content = "，以下为您的奖励~", size = 24, color = ccc3(57,21,0)})
    rt:setString(tfTbl)
    self._ccbOwner.node_text:addChild(rt)
    if self._award.getAward == false then
    	--像后端请求
    	remote.blackrock:blackRockGetTeamAwardRequest(self._award.awardId,false)
    end
end

function QUIDialogBlackRockPassLost:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogBlackRockPassLost:_onTriggerClose()
	self:playEffectOut()
end

function QUIDialogBlackRockPassLost:viewAnimationOutHandler()
	local callBack = self._callBack
	self:popSelf()
	if callBack ~= nil then
		callBack()
	end
end

return QUIDialogBlackRockPassLost