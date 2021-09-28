module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_jinlanpu = i3k_class("wnd_jinlanpu", ui.wnd_base)

function wnd_jinlanpu:ctor()
end

function wnd_jinlanpu:configure()
	self.ui = self._layout.vars
	self.ui.close:onClick(self, self.onCloseUI)
end

function wnd_jinlanpu:refresh(cardInfos, isPreview, cardOwnerID)
	assert(cardInfos, "cardInfos can't be nil")
	local ids, names = self:sortIDorder(cardInfos)
	self:setTitle(cardInfos)
	self:setUI(cardInfos, isPreview)
	self:setPreview(cardInfos, ids, cardOwnerID)
	self:setShares(cardInfos, names)
end
	
function wnd_jinlanpu:setUI(cardInfos, isPreview)
	self.ui.msgbtn:setVisible(not isPreview)
	self.ui.like:setVisible(isPreview)
	self.ui.share:setVisible(not isPreview)
	self.ui.jinlanValue:setText(cardInfos.sworn.swornValue)
	self.ui.msg:setText(i3k_get_string(5521)..cardInfos.sworn.giftString)
	self.ui.likes:setText(cardInfos.sworn.signNum)
	self.ui.msgbtn:onClick(self, self.msgbtn, self)
end
function wnd_jinlanpu:updateText()
	self.ui.likes:setText(tonumber(self.ui.likes:getText()) + 1)
end
function wnd_jinlanpu:msgbtn()
	g_i3k_ui_mgr:OpenAndRefresh(eUIID_JinLanChangeMessage, self.ui.msg:getText())
end
function wnd_jinlanpu:changeMsg(msg)
	self.ui.msg:setText(msg and i3k_get_string(5521)..msg or "")
end
function wnd_jinlanpu:setTitle(cardInfos)
	local titleIndex = g_i3k_db.getTitleIndex(cardInfos.sworn.swornValue)
	if titleIndex == 0 then
		self.ui.chenghaobg:setVisible(false)
		self.ui.chmc:setVisible(false)
	else
		local titleId = i3k_db_sworn_value[titleIndex].titleId
		local bg = i3k_db_title_base[titleId].iconbackground
		local chmc = i3k_db_title_base[titleId].name
		self.ui.chenghaobg:setImage(g_i3k_db.i3k_db_get_icon_path(bg))
		self.ui.chmc:setImage(g_i3k_db.i3k_db_get_icon_path(chmc)) --Image(g_i3k_db.i3k_db_get_icon_path(chmc))
	end
end

function wnd_jinlanpu:setShares(cardInfos, names)
	self.ui.share:onClick(self, function() g_i3k_ui_mgr:OpenAndRefresh(eUIID_JinLanShare, cardInfos.sworn.id, names) end)
	self.ui.like:onClick(self, function() 
		g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(16907), function(ok) 
			if not ok then return end
			if g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_sworn_system.likeNeedItem) < 1 then
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16909))
				return
			end
			i3k_sbean.sworn_card_like(cardInfos.sworn.id)
		end)
	end)
end
function wnd_jinlanpu:setPreview(cardInfos, ids, cardOwnerID)
	local isBigger = 1
	for i = 1, 4 do
		local id = ids[i]
		if id then
			local info = cardInfos.sworn.roles[id]
			local isSelf = false
			if id == cardOwnerID then
				isBigger = 0
				isSelf = true
			end
			local f = (isSelf and i == 1) and 1 or isBigger
			local orderInfo = g_i3k_db.i3k_db_get_title_orderSeatId_bySelfIndex(i, info.role.gender, f)
			local player = require("ui/widgets/jinlanpcx")()
			self.ui["player"..i]:addItem(player)
			self.ui["player"..i]:stateToNoSlip()
			self:setPreviewModule(player.vars.player, cardInfos.roles[id])
			self.ui["zhuoci"..i]:setText(orderInfo.notes)
			self.ui["zcbg"..i]:setVisible(true)
			self.ui["ziye"..i]:setVisible(true)
			self.ui["ziye"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_general(info.role.type).classImg))
			self.ui["nickname"..i]:setText(cardInfos.sworn.prefix..info.suffix)
			self.ui["career"..i]:setText(info.role.name)		--g_i3k_db.i3k_db_get_job_name(info.role.type, info.role.tLvl, info.role.bwType)
		else
			self.ui["ziye"..i]:setVisible(false)
			self.ui["zhuoci"..i]:setText('')
			self.ui["zcbg"..i]:setVisible(false)
			self.ui["nickname"..i]:setVisible(false)
			self.ui["career"..i]:setVisible(false)
		end
	end
end

function wnd_jinlanpu:sortIDorder(cardInfos)
	local ids = {}
	local names = {}
	local roles = cardInfos.sworn.roles
	for k, v in pairs(roles) do
		table.insert(ids, k)
	end
	
	table.sort(ids, function(a, b)
		local result = g_i3k_db.i3k_db_rcsCompare({roles[a].birthday, a}, {roles[b].birthday, b}) < 0
		return result
	end)
	for _, v in ipairs(ids) do
		table.insert(names, cardInfos.sworn.roles[v].role.name)
	end
	
	--table.sort
	return ids, names
end

function wnd_jinlanpu:setPreviewModule(ui, info)
	local playerData = info.overview
	local equips = {}
	for k,v in pairs(info.wear.wearEquips) do
		equips[k] = v.equip.id
	end
	self:changeModel(ui, playerData.type, playerData.bwType, playerData.gender, info.wear.face, info.wear.hair, equips, info.wear.curFashions, info.wear.showFashionTypes, info.wear.wearParts, info.wear.armor, info.wear.weaponSoulShow, info.wear.soaringDisplay)
end

function wnd_jinlanpu:changeModel(ui, id, bwType, gender, face, hair, equips,fashions,isshow,equipparts,armor, weaponSoulShow, soaringDisplay)
	local cfg = i3k_db_fashion_dress[fashions[g_FashionType_Dress]]
	local modelTable = {}
	modelTable.node = ui
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

function wnd_create(layout)
	local wnd = wnd_jinlanpu.new()
	wnd:create(layout)
	return wnd
end

