-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_master_card = i3k_class("wnd_master_card", ui.wnd_base)

local STATE_MASTER = 1 --师父打开的
local STATE_APPRTC = 2 --徒弟打开的
local STATE_OTHER = 3 --其他人打开的

function wnd_master_card:ctor()
	self.masterId = 0
	self.state = STATE_OTHER
end

function wnd_master_card:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.editBtn:onClick(self, self.onEditClick)
	widgets.shareBtn:onClick(self, self.onShareClick)
	widgets.likeBtn:onClick(self, self.onLikeClick)
	widgets.desc:setText(i3k_get_string(5519))
end

function wnd_master_card:refresh(overview, fromShare)
	self.overview = overview
	if not pcall(function()self:checkState()end) then
		g_i3k_ui_mgr:PopupTipMessage("该桃李证已失效")
		self:onCloseUI()
		return
	else
		if self.state == STATE_OTHER and not fromShare then--不是从分享里打开的 但是是其他人 说明已经解除了关系
			g_i3k_ui_mgr:PopupTipMessage("该桃李证已失效")
			self:onCloseUI()
			return	
		end
	end
	local widgets = self._layout.vars
	widgets.txt:setText(overview.declaration)
	widgets.likeNum:setText(overview.praise)
	widgets.likeBtn:setVisible(fromShare)
	widgets.shareBtn:setVisible(not fromShare)
	widgets.editBtn:setVisible(not fromShare and self.state == STATE_MASTER)
	for i = 1, 4 do
		local scroll = self._layout.vars["scroll"..i]
		scroll:removeAllChildren()
		scroll:stateToNoSlip()
		local widget = require("ui/widgets/jinlanpcx")()
		if i == 1 then
			self:setRoleInfo(i, overview.master, scroll, widget)
		else
			if overview.apprentices[i - 1] then
				widget.vars.player:show()
				widgets['node'..i]:show()
				self:setRoleInfo(i, overview.apprentices[i - 1], scroll, widget)			
			else
				widget.vars.player:hide()
				widgets['node'..i]:hide()
			end
		end
	end
	self.curTxt = self.overview.declaration
end

function wnd_master_card:setRoleInfo(index, roleInfo, scroll, widget)
	local widgets = self._layout.vars
	widgets['name'..index]:setText(roleInfo.overview.name)
	widgets['pos'..index]:setText(i3k_get_string(index == 1 and 5515 or 5516))
	self:createModule(roleInfo, widget.vars.player)
	scroll:addItem(widget)
end

function wnd_master_card:checkState()--判断是谁打开的
	local overview = self.overview
	local roleId = g_i3k_game_context:GetRoleId()
	self.state = STATE_OTHER
	self.masterId = overview.master.overview.id
	if self.masterId == roleId then
		self.state = STATE_MASTER
	end
	for i,v in ipairs(overview.apprentices) do
		if v.overview.id == roleId then
			self.state = STATE_APPRTC
		end
	end
end

function wnd_master_card:setDeclaration(str)
	self.curTxt = str
	self._layout.vars.txt:setText(str)
end

function wnd_master_card:shareMasterCardBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_MasterCardShare)
	g_i3k_ui_mgr:RefreshUI(eUIID_MasterCardShare, self.masterId)
end


function wnd_master_card:createModule(Data, widget)
	local playerData = Data.overview
	local data = {}
	for k,v in pairs(Data.wear.wearEquips) do
		data[k] = v.equip.id
	end
	self:changeModel(widget, playerData.type, playerData.bwType, playerData.gender, Data.wear.face, Data.wear.hair, data, Data.wear.curFashions, Data.wear.showFashionTypes, Data.wear.wearParts, Data.wear.armor, Data.wear.weaponSoulShow, Data.wear.soaringDisplay)
	self:playAction(Data, widget)
end

function wnd_master_card:changeModel(widget, id, bwType, gender, face, hair, equips,fashions,isshow,equipparts,armor, weaponSoulShow, soaringDisplay)
	local cfg = i3k_db_fashion_dress[fashions[g_FashionType_Dress]]
	local modelTable = {}
	modelTable.node = widget
	modelTable.id = id
	modelTable.bwType = bwType
	modelTable.gender = gender
	modelTable.face = face
	modelTable.hair = hair
	modelTable.equips = equips
	modelTable.fashions = fashions
	modelTable.isshow = isshow
	modelTable.equipparts = equipparts
	modelTable.armor = armor
	modelTable.weaponSoulShow = weaponSoulShow
	modelTable.isEffectFashion = cfg and cfg.withEffect == 1
	modelTable.soaringDisplay = soaringDisplay
	self:createModelWithCfg(modelTable)
end

function wnd_master_card:playAction(Data, widget)--如果是动态披风 会播放动作 模型会停止旋转
	local fashions = Data.wear.curFashions
	local curFashion = fashions[g_FashionType_Dress]
	local cfg = i3k_db_fashion_dress[curFashion]
	local isEffectFashion = cfg and cfg.withEffect == 1 and Data.wear.soaringDisplay.skinDisplay == g_WEAR_FASHION_SHOW_TYPE
	if isEffectFashion then
		local showAct = cfg and cfg.showAction
		if showAct then
			for i, v in ipairs(showAct) do
			widget:pushActionList(v, i == #showAct and -1 or 1)
			end
			widget:playActionList()
		end
	end
end

function wnd_master_card:onEditClick(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_MasterCardEdit)
	g_i3k_ui_mgr:RefreshUI(eUIID_MasterCardEdit, self.curTxt)
end

function wnd_master_card:onShareClick(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_MasterCardShare)
	g_i3k_ui_mgr:RefreshUI(eUIID_MasterCardShare, self.masterId)
end

function wnd_master_card:onLikeClick(sender)
	local func = function(bValue)
		if bValue then
			local consume = i3k_db_master_cfg.cfg.likeConsume
			if g_i3k_game_context:GetCommonItemCanUseCount(consume.id) >= consume.count then
				i3k_sbean.master_card_sign(self.masterId)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16909))
			end
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(16907), func)
end
----------------------------------------------
function wnd_create(layout)
	local wnd = wnd_master_card.new()
	wnd:create(layout)
	return wnd
end
