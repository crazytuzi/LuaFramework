
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_evaluation_pet_weapon = i3k_class("wnd_evaluation_pet_weapon",ui.wnd_base)

local Theme_Pet = 1
local Theme_Weapon = 2
local Theme_HideWeapon = 3
function wnd_evaluation_pet_weapon:ctor()
	self._themeInfo = nil
	self._lastLookBtn = nil
	self._scrollPercent = 0
	self._isEndPage = true
end

function wnd_evaluation_pet_weapon:configure()
	local vars = self._layout.vars
	vars.closeBtn:onClick(self, self.onCloseUI)
	vars.nextPage:onClick(self, self.updateNextPage)
	vars.lastPage:onClick(self, self.updateLastPage)
	vars.editBox:setMaxLength(i3k_db_common.evaluation.maxNum)
	vars.editBox:setPlaceHolder(string.format("请写下你想说的话(至少%s个字)",i3k_db_common.evaluation.minNum))
	vars.noteBtn:onClick(self, self.sendEvaluation)
	vars.praiseBtn:onClick(self, self.onLookEvaluation,2)
	vars.disdainBtn:onClick(self, self.onLookEvaluation,3)
	vars.all_btn:onClick(self, self.onLookEvaluation,1)
	vars.tipsBtn:onClick(self, self.onTip)
end
--[[
self.themeType = themeType
	self.themeId = themeId
	self.tag = tag
	self.pageNo = pageNo
	self.len = len
]]
function wnd_evaluation_pet_weapon:refresh(themeInfo)
	if not self._themeInfo then
		local id = themeInfo.themeId
		local vars = self._layout.vars
		self._lastLookBtn = vars.all_btn
		self._lastLookBtn:stateToPressed()
		if themeInfo.themeType == Theme_Pet then
			vars.name:setText(i3k_db_mercenaries[id].name)
			vars.tipsBtn:setVisible(not g_i3k_game_context:IsHavePet(id))
		elseif themeInfo.themeType == Theme_Weapon then
			vars.name:setText(i3k_db_shen_bing[id].name)
			vars.tipsBtn:setVisible(not g_i3k_game_context:IsHaveShenbing(id))
		elseif themeInfo.themeType == Theme_HideWeapon then
			vars.name:setText(i3k_db_anqi_base[id].name)
			vars.tipsBtn:setVisible(not g_i3k_game_context:getHideWeaponByID(id))
		end
	end
	self._themeInfo = themeInfo
	-- self:updateEvaluationContent(themeInfo, comments)
	self._layout.vars.pageNum:setText(string.format("第%d页", themeInfo.pageNo))
end

function wnd_evaluation_pet_weapon:updateEvaluationContent(comments)
	local scroll = self._layout.vars.scroll
	self._isEndPage = #comments == 0
	scroll:removeAllChildren()
	for i,v in ipairs(comments) do
		local node = require("ui/widgets/pjjmt")()
		node.vars.name_label:setText(v.roleName)
		node.vars.nodeTxt:setText(v.comment)
		node.vars.flowerNum:setText(v.liked)
		node.vars.brickNum:setText(v.disliked)
		node.vars.brickBtn:onClick(self, self.onBrick, v)
		node.vars.flowerBtn:onClick(self, self.onFlower, v)
		scroll:addItem(node)
	end
	scroll:jumpToListPercent(self._scrollPercent)
end

function wnd_evaluation_pet_weapon:onFlower(sender, info)
	self:setScrollPercent()
	i3k_sbean.socialmsg_likeReq(info.serverId, info.serverName, self._themeInfo.themeType, self._themeInfo.themeId, info.commentId)
end

function wnd_evaluation_pet_weapon:onBrick(sender, info)
	self:setScrollPercent()
	i3k_sbean.socialmsg_dislikeReq(info.serverId, info.serverName, self._themeInfo.themeType, self._themeInfo.themeId, info.commentId)
end

function wnd_evaluation_pet_weapon:sendEvaluation(sender)
	local serverid = i3k_game_get_server_id()
	local info = self._themeInfo
	local comment = self._layout.vars.editBox:getText()
	local textcount = i3k_get_utf8_len(comment)

	if textcount > i3k_db_common.evaluation.maxNum or textcount < i3k_db_common.evaluation.minNum then
		return g_i3k_ui_mgr:PopupTipMessage(string.format("至少%s个字", i3k_db_common.evaluation.minNum))
	end
	self:setScrollPercent(0)
	comment = string.gsub(comment, " ", "")
	i3k_sbean.socialmsg_sendReq(serverid, i3k_game_get_server_name(serverid), info.themeType, info.themeId, comment)
end

function wnd_evaluation_pet_weapon:onTip(sender)
	if self._themeInfo.themeType == Theme_Pet then
		g_i3k_ui_mgr:PopupTipMessage("拥有该宠物后方可评价")
	elseif self._themeInfo.themeType == Theme_Weapon then
		g_i3k_ui_mgr:PopupTipMessage("拥有该神兵后方可评价")
	elseif self._themeInfo.themeType == Theme_HideWeapon then
		g_i3k_ui_mgr:PopupTipMessage("拥有该暗器后方可评价")
	end
end

function wnd_evaluation_pet_weapon:updateNextPage(sender)
	if self:isEndPage(self._isEndPage) then
		return
	end
	self:setScrollPercent(0)
	
	local info = self._themeInfo
	i3k_sbean.socialmsg_pageinfoReq(info.themeType, info.themeId, info.tag, info.pageNo + 1, info.len, true)
end

function wnd_evaluation_pet_weapon:updateLastPage(sender)
	self:setScrollPercent(0)
	
	local info = self._themeInfo
	local pageNo = info.pageNo - 1
	pageNo = pageNo <= 0 and 1 or pageNo
	i3k_sbean.socialmsg_pageinfoReq(info.themeType, info.themeId, info.tag, pageNo, info.len)
end

function wnd_evaluation_pet_weapon:onLookEvaluation(sender, tag)
	if self._lastLookBtn ~= sender then
		sender:stateToPressed()
		self._lastLookBtn:stateToNormal(true)
		self._lastLookBtn = sender
	end
	self:setScrollPercent(0)
	local info = self._themeInfo
	i3k_sbean.socialmsg_pageinfoReq(info.themeType, info.themeId, tag, 1, info.len)
end

function wnd_evaluation_pet_weapon:updateCurrPage()
	self:setScrollPercent()
	local info = self._themeInfo
	i3k_sbean.socialmsg_pageinfoReq(info.themeType, info.themeId, info.tag, info.pageNo, info.len)
end

function wnd_evaluation_pet_weapon:clearEditbox()
	self._layout.vars.editBox:setText("")
end

function wnd_evaluation_pet_weapon:clearScroll( )
	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren()
end

function wnd_evaluation_pet_weapon:setScrollPercent(percent)
	self._scrollPercent = percent or self._layout.vars.scroll:getListPercent()
end

function wnd_evaluation_pet_weapon:isEndPage(isEndPage)
	self._isEndPage = isEndPage
	if self._isEndPage then
		g_i3k_ui_mgr:PopupTipMessage("已经是最后一页了")
	end
	return self._isEndPage
end

function wnd_evaluation_pet_weapon:wnd_evaluation_pet_weapon()
	self._themeInfo = nil
end

function wnd_create(layout, ...)
	local wnd = wnd_evaluation_pet_weapon.new()
	wnd:create(layout, ...)
	return wnd;
end

