--[[	
	文件名称：QUIWidgetSocietyXuanyan.lua
	创建时间：2016-04-28 14:34:52
	作者：nieming
	描述：QUIWidgetSocietyXuanyan
]]

local QUIWidget = import(".QUIWidget")
local QUIWidgetSocietyXuanyan = class("QUIWidgetSocietyXuanyan", QUIWidget)
local QUIViewController = import("..QUIViewController")
local QUIDialogUnionAnnouncement = import("..dialogs.QUIDialogUnionAnnouncement")
local QRichText = import("...utils.QRichText")
--初始化
function QUIWidgetSocietyXuanyan:ctor(options)
	local ccbFile = "Widget_society_xuanyan.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerChangeNotice", callback = handler(self, QUIWidgetSocietyXuanyan._onTriggerChangeNotice)},
	}
	QUIWidgetSocietyXuanyan.super.ctor(self,ccbFile,callBacks,options)

	local richText = QRichText.new(nil, 658, {defaultSize = 26, defaultColor = COLORS.k, lineSpacing = 10, fontName = global.font_name})
	self._richText = richText
	self._ccbOwner.noticeStr:addChild(richText)
	self._richText:setAnchorPoint(ccp(0, 0.5))
end

function QUIWidgetSocietyXuanyan:setInfo( info )
	if info and info ~= "" then
		self._notice = info
	else
		self._notice = string.format("尊敬的魂师大人，%s欢迎您的加入！~",remote.union.consortia.name or "")
	end

	self._richText:setString({{oType = "font", content = string.format("　　%s",self._notice)}})
	
	self._ccbOwner.presidentName:setString("宗主："..(remote.union.consortia.presidentName or ""))

	if remote.user.userConsortia.rank and remote.user.userConsortia.rank == SOCIETY_OFFICIAL_POSITION.BOSS then
		self._ccbOwner.node_btn_changeNotice:setVisible(true)
	else
		self._ccbOwner.node_btn_changeNotice:setVisible(false)
	end
end

function QUIWidgetSocietyXuanyan:_onTriggerChangeNotice(e)
	--屏蔽宣言
	if true then
		return
	end
	if q.buttonEventShadow(e, self._ccbOwner.btn_changeNotice) == false then return end
    app.sound:playSound("common_small")
	if not (remote.user.userConsortia.rank and remote.user.userConsortia.rank == SOCIETY_OFFICIAL_POSITION.BOSS) then
		return
	end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogUnionAnnouncement", 
        options = {type = QUIDialogUnionAnnouncement.TYPE_UNION_NOTICE, word = "", confirmCallback = function (word)
        	if #word > 0 then
        		remote.union:unionChangeNoticeRequest(word, function ( )
        			self._notice = word
        			self._richText:setString({{oType = "font", content = string.format("　　%s", self._notice)}})
        		end)
            end
        end}}, {isPopCurrentDialog = false})
end

return QUIWidgetSocietyXuanyan
