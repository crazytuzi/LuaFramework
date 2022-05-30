local data_mail_mail = require("data.data_mail_mail")
local data_item_item = require("data.data_item_item")
require("data.data_error_error")
local SHOWTYPE = {BATTLE = 1, SYSTEM = 3}

local BaseScene = require("game.BaseScene")
local MailScene = class("MailScene", BaseScene)
--[[
local MailScene = class("MailScene", function()
	return require("game.BaseScene").new({
	contentFile = "mail/mail_bg.ccbi",
	topFile = "mail/mail_up_tab.ccbi",
	adjustSize = cc.size(0, -60)
	})
end)
]]
function MailScene:reqMailData(viewType, bGetMore, curMailId)
	RequestHelper.Mail.getMailList({
	type = viewType,
	mailId = curMailId,
	callback = function(data)
		dump(data)
		if data.err and data.err ~= "" then
			dump(data.err)
		else
			if bGetMore == false then
				self._mailTotalNum = data.mailCnt
			end
			local lastPosIndex = 0
			if bGetMore == true then
				lastPosIndex = #self._itemDatas - 1
			end
			self:initMailData(data.mailList)
			self:reloadListView(viewType, lastPosIndex)
			if viewType == SHOWTYPE.BATTLE then
				self._rootnode.mail_battle_notice:setVisible(false)
				game.player:resetMailBattle()
			elseif viewType == SHOWTYPE.SYSTEM then
				self._rootnode.mail_system_notice:setVisible(false)
				game.player:resetMailSystem()
			end
		end
	end
	})
end

function MailScene:ctor()
	MailScene.super.ctor(self, {
	contentFile = "mail/mail_bg.ccbi",
	topFile = "mail/mail_up_tab.ccbi",
	adjustSize = cc.size(0, -60)
	})
	
	ResMgr.removeBefLayer()
	game.runningScene = self
	self._viewType = 0
	self._curMailId = 0
	self._mailTotalNum = 0
	self._itemDatas = {}
	local _bg = display.newSprite("ui_common/common_bg.png")
	local _bgW = display.width
	local _bgH = display.height - self._rootnode.bottomMenuNode:getContentSize().height - self._rootnode.topFrameNode:getContentSize().height
	_bg:setPosition(_bgW / 2, _bgH / 2 + self._rootnode.bottomMenuNode:getContentSize().height)
	_bg:setScaleX(_bgW / _bg:getContentSize().width)
	_bg:setScaleY(_bgH / _bg:getContentSize().height)
	self:addChild(_bg, 0)
	
	local function onTabBtn(tag)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_yeqian))
		if tag == 2 then
			tag = 3
		end
		if self._viewType ~= tag then
			self._curMailId = 0
			self._itemDatas = {}
			self._viewType = tag
			self:reqMailData(self._viewType, false, self._curMailId)
		end
	end
	CtrlBtnGroupAsMenu({
	self._rootnode.tab1,
	self._rootnode.tab2
	}, onTabBtn)
	onTabBtn(SHOWTYPE.BATTLE)
	if 0 < game.player:getMailBattle() then
		self._rootnode.mail_battle_notice:setVisible(true)
		self._rootnode.mail_battle_notice:setZOrder(11)
	else
		self._rootnode.mail_battle_notice:setVisible(false)
		game.player:resetMailBattle()
	end
	if 0 < game.player:getMailSystem() then
		self._rootnode.mail_system_notice:setVisible(true)
		self._rootnode.mail_system_notice:setZOrder(11)
	else
		self._rootnode.mail_system_notice:setVisible(false)
		game.player:resetMailSystem()
	end
end

function MailScene:onEnter()
	game.runningScene = self
	--self:regNotice()
	MailScene.super.onEnter(self)
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
end
function MailScene:onExit()
	--self:unregNotice()
	MailScene.super.onExit(self)
end

function MailScene:getDataByTypeAndId(mailType, mailId)
	local mailData
	for i, v in ipairs(data_mail_mail) do
		if v.type == mailType and v.id == mailId then
			mailData = v
			break
		end
	end
	return mailData
end

function MailScene:getStrColorAndFont(item, mailId)
	local color = "#5c2601"
	local name = ""
	local str = ""
	if item ~= nil then
		if item.paraType == 1 then
			local iconType = ResMgr.getResType(item.item_type)
			local infoData
			if iconType == ResMgr.ITEM or iconType == ResMgr.EQUIP then
				if item.item_type == 7 and item.item_id <= 50 then
					color = "#4eff00"
				else
					color = ResMgr.getItemNameColorHex(item.item_id)
				end
				infoData = data_item_item[item.item_id]
			elseif iconType == ResMgr.HERO then
				color = ResMgr.getHeroNameColorHexByClass(item.item_id, 1)
				infoData = ResMgr.getCardData(item.item_id)
			end
			if mailId == 5 then
				name = tostring(infoData.name)
			else
				name = tostring(infoData.name) .. tostring(item.item_num)
			end
		elseif item.paraType == 2 then
			color = ResMgr.getHeroNameColorHexByClass(1, item.cls)
			name = item.str
		elseif item.paraType == 3 then
			name = item.str
		end
		if item.paraType == 1 or item.paraType == 2 then
			str = "<font size=\"22\" font=\"fonts/FZCuYuan-M03.ttf\" color=\"" .. tostring(color) .. "\">" .. tostring(name) .. "</font>"
		elseif item.paraType == 3 then
			str = name
		end
	end
	return str
end

function MailScene:getRichHtmlTextByItemData(item, mailData)
	local itemRichText
	local paras = item.paras
	local htmlText = mailData.content
	local paraList = {}
	for i, v in ipairs(paras) do
		local str = self:getStrColorAndFont(v, mailData.id)
		table.insert(paraList, str)
	end
	local paraNum = #paraList
	if paraNum == 1 then
		htmlText = string.format(htmlText, paraList[1])
	elseif paraNum == 2 then
		htmlText = string.format(htmlText, paraList[1], paraList[2])
	elseif paraNum == 3 then
		htmlText = string.format(htmlText, paraList[1], paraList[2], paraList[3])
	elseif paraNum == 4 then
		htmlText = string.format(htmlText, paraList[1], paraList[2], paraList[3], paraList[4])
	elseif paraNum == 5 then
		htmlText = string.format(htmlText, paraList[1], paraList[2], paraList[3], paraList[4], paraList[5])
	elseif paraNum == 6 then
		htmlText = string.format(htmlText, paraList[1], paraList[2], paraList[3], paraList[4], paraList[5], paraList[6])
	elseif paraNum == 7 then
		htmlText = string.format(htmlText, paraList[1], paraList[2], paraList[3], paraList[4], paraList[5], paraList[6], paraList[7])
	elseif paraNum == 8 then
		htmlText = string.format(htmlText, paraList[1], paraList[2], paraList[3], paraList[4], paraList[5], paraList[6], paraList[7], paraList[8])
	end
	return htmlText
end

function MailScene:initMailData(mails)
	for i, v in ipairs(mails) do
		local mailData = self:getDataByTypeAndId(v.type, v.strId)
		if mailData == nil then
			ResMgr.showAlert(mailData, common:getLanguageString("@ServerMailError") .. v.type .. ", id: " .. v.strId)
		else
			local dayTime = ""
			if v.disDay == 0 then
				dayTime = common:getLanguageString("@JinDay")
			elseif v.disDay > 0 then
				dayTime = common:getLanguageString("@XDay", v.disDay)
			end
			common:getLanguageString("@XDay")
			time = common:getLanguageString("@JinDay")
			local richHtmlText = self:getRichHtmlTextByItemData(v, mailData)
			table.insert(self._itemDatas, {
			title = mailData.title,
			battleType = mailData.battleType,
			disDay = dayTime,
			richHtmlText = richHtmlText
			})
			if i == #mails then
				self._curMailId = v.mailId
			end
		end
	end
end

function MailScene:reloadListView(viewType, lastPosIndex)
	
	if self._listViewTable ~= nil then
		self._listViewTable:removeSelf()
		self._listViewTable = nil
	end
	local isCanShowMoreBtn = false
	local tableNum = #self._itemDatas
	if #self._itemDatas < self._mailTotalNum then
		isCanShowMoreBtn = true
		tableNum = tableNum + 1
	end
	local viewSize = self._rootnode.listView:getContentSize()
	local function createFunc(index)
		local item
		if viewType == SHOWTYPE.BATTLE then
			item = require("game.Mail.MailBattleItem").new()
		elseif viewType == SHOWTYPE.SYSTEM then
			item = require("game.Mail.MailSystemItem").new()
		end
		local itemData
		if isCanShowMoreBtn == false or index + 1 <= #self._itemDatas then
			itemData = self._itemDatas[index + 1]
		end
		return item:create({
		id = index + 1,
		itemData = itemData,
		viewSize = viewSize,
		totalNum = self._mailTotalNum,
		curMailNum = tableNum,
		isCanShowMoreBtn = isCanShowMoreBtn
		})
	end
	local function refreshFunc(cell, index)
		local itemData
		if isCanShowMoreBtn == false or index + 1 <= #self._itemDatas then
			itemData = self._itemDatas[index + 1]
		end
		cell:refresh({
		id = index + 1,
		itemData = itemData
		})
	end
	local cellContentSize = require("game.Mail.MailBattleItem").new():getContentSize()
	self._listViewTable = require("utility.TableViewExt").new({
	size = viewSize,
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = tableNum,
	cellSize = cellContentSize,
	touchFunc = function(cell)
		local idx = cell:getIdx() + 1
		if isCanShowMoreBtn == true and idx == tableNum then
			if #self._itemDatas < self._mailTotalNum then
				self:reqMailData(viewType, true, self._curMailId)
			else
				show_tip_label(data_error_error[2600001].prompt)
			end
		end
	end
	})
	self._rootnode.listView:addChild(self._listViewTable)
	local pageCount = self._listViewTable:getViewSize().height / cellContentSize.height
	if pageCount < lastPosIndex + 1 then
		local maxMove = tableNum - pageCount
		if maxMove < 0 then
			maxMove = 0
		end
		if lastPosIndex > maxMove then
			lastPosIndex = maxMove
		end
		local curIndex = maxMove - lastPosIndex
		self._listViewTable:setContentOffset(cc.p(0, -(curIndex * cellContentSize.height)))
	end
end

return MailScene