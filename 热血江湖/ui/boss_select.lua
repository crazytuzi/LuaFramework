module(..., package.seeall)

local require = require;

local ui = require("ui/base");


wnd_boss_select = i3k_class("wnd_boss_select", ui.wnd_base)

local f_lockDiamondIconId = 33
local f_posName = {"座标一", "座标二", "座标三", "座标四", "座标五"}

local f_colorTable = {pressedTextColor = "FFFFFA7B", pressedOutLineColor = "FF9B6C12", normalTextColor = "FFFFFFFF", normalOutLineColor = "FF276C61"}

function wnd_boss_select:ctor()
	self._pos = nil
	self._bossId = nil
end

function wnd_boss_select:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)

	local posRoot1 = self._layout.vars.posRoot1
	local posBtn1 = self._layout.vars.posBtn1
	local posName1 = self._layout.vars.posName1
	local select1 = self._layout.vars.select1
	local pos1 = {root = posRoot1, btn = posBtn1, name = posName1, selectImg = select1}

	local posRoot2 = self._layout.vars.posRoot2
	local posBtn2 = self._layout.vars.posBtn2
	local posName2 = self._layout.vars.posName2
	local select2 = self._layout.vars.select2
	local pos2 = {root = posRoot2, btn = posBtn2, name = posName2, selectImg = select2}

	local posRoot3 = self._layout.vars.posRoot3
	local posBtn3 = self._layout.vars.posBtn3
	local posName3 = self._layout.vars.posName3
	local select3 = self._layout.vars.select3
	local pos3 = {root = posRoot3, btn = posBtn3, name = posName3, selectImg = select3}

	local posRoot4 = self._layout.vars.posRoot4
	local posBtn4 = self._layout.vars.posBtn4
	local posName4 = self._layout.vars.posName4
	local select4 = self._layout.vars.select4
	local pos4 = {root = posRoot4, btn = posBtn4, name = posName4, selectImg = select4}

	local posRoot5 = self._layout.vars.posRoot5
	local posBtn5 = self._layout.vars.posBtn5
	local posName5 = self._layout.vars.posName5
	local select5 = self._layout.vars.select5
	local pos5 = {root = posRoot5, btn = posBtn5, name = posName5, selectImg = select5}

	self._posBtnTable = {pos1, pos2, pos3, pos4, pos5}
end

function wnd_boss_select:refresh(bossId)
	self._bossId = bossId
	self._layout.vars.walkToPos:setTag(bossId)
	self._layout.vars.walkToPos:onClick(self, self.walkToBossPos)
	self._layout.vars.transToPos:setTag(bossId)
	self._layout.vars.transToPos:onClick(self, self.transToBossPos)

	local userCfg = g_i3k_game_context:GetUserCfg()
	local thatCoolTime = userCfg:GetActTransCoolTime()
	local timeNow = math.floor(g_i3k_get_GMTtime(i3k_game_get_time()))
	local timee = i3k_db_common.activity.transCoolTime
	if timeNow-thatCoolTime.thatTime>thatCoolTime.cool then
		self._layout.vars.coolTimeLabel:hide()
		self._layout.vars.needItemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(i3k_db_common.activity.transNeedItemId,i3k_game_context:IsFemaleRole()))
		self._layout.vars.needDiamond:setText("x1")
	else
		g_i3k_game_context:StartTransCoolTime(thatCoolTime.cool - (timeNow - thatCoolTime.thatTime))
	end

	self:setData(bossId)
end

function wnd_boss_select:onShow()

end

function wnd_boss_select:setData(bossId)
	local activityCfg = i3k_db_world_boss[bossId]
	self._mapId = activityCfg.mapId
	local fightPosTable = {}
	for i=1,5 do
		local posStr = "pos"..i
		if activityCfg[posStr] then
			table.insert(fightPosTable, activityCfg[posStr])
		end
	end
	local tempPosTable = {}
	for i,v in ipairs(self._posBtnTable) do
		if fightPosTable[i] then
			v.root:show()
			v.name:setText(f_posName[i])
			v.btn:setTag(i+1000)
			v.btn:onClick(self, self.selectPos, fightPosTable[i])
			table.insert(tempPosTable, v)
		else
			v.root:hide()
		end
	end
	self._posBtnTable = tempPosTable
	self:selectPos(self._posBtnTable[1].btn, fightPosTable[1])
end

function wnd_boss_select:selectPos(sender, pos)
	for i,v in pairs(self._posBtnTable) do
		if v.btn:getTag()==sender:getTag() then
			v.selectImg:show()
			v.btn:stateToPressed()
			v.name:stateToPressed(f_colorTable.pressedTextColor, f_colorTable.pressedOutLineColor)
			self._seq = i
		else
			v.selectImg:hide()
			v.btn:stateToNormal()
			v.name:stateToNormal(f_colorTable.normalTextColor, f_colorTable.normalOutLineColor)
		end
		self._pos = pos
	end
end

function wnd_boss_select:walkToBossPos(sender)
	if self._mapId and self._pos then
		local walkToBoss = i3k_sbean.walktoboss_req.new()
		walkToBoss.bossID = sender:getTag()
		walkToBoss.mapId = self._mapId
		walkToBoss.pos = self._pos
		i3k_game_send_str_cmd(walkToBoss, "walktoboss_res")
	end
end

function wnd_boss_select:transToBossPos(sender)
	if self._seq then
		local bossId = sender:getTag()
		local bossInfo = i3k_db_world_boss[bossId]

		local itemCount = g_i3k_game_context:GetBagMiscellaneousCanUseCount(i3k_db_common.activity.transNeedItemId)
		if not g_i3k_game_context:CheckCanTrans(i3k_db_common.activity.transNeedItemId, 1) then
			local tips = string.format("%s", "所需物品数量不足,请步行前往")
			g_i3k_ui_mgr:PopupTipMessage(tips)
		else
			local func = function ()
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BossSelect, "transToBossCB", bossId, bossInfo)
			end
			g_i3k_game_context:CheckMulHorse(func, true)
		end
	end
end

function wnd_boss_select:transToBossCB(bossId, bossInfo)
	if i3k_check_resources_downloaded(bossInfo.mapId) then
		local toBoss = i3k_sbean.transtoboss_req.new()
		toBoss.bossID = bossId
		toBoss.needDiamond = 1
		toBoss.seq = self._seq
		toBoss.needCount = 1
		local world = i3k_game_get_logic():GetWorld()
		local mapID = bossInfo.mapId
		toBoss.newWorld = world._cfg.mapID ~= mapID
		i3k_game_send_str_cmd(toBoss, "transtoboss_res")
	end
end

function wnd_boss_select:resetCoolTime(sender)
	if g_i3k_game_context:GetDiamondCanUse(false) < i3k_db_common.activity.resetCoolDiamond then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(327))
	else
		local resetReq = i3k_sbean.reset_transtime_req.new()
		i3k_game_send_str_cmd(resetReq, "reset_transtime_res")
	end
end

function wnd_boss_select:resetData()
	g_i3k_game_context:UseDiamond(i3k_db_common.activity.resetCoolDiamond, false,AT_RESET_TRANS_TIME)
	g_i3k_game_context:StartTransCoolTime(0)
end

--[[function wnd_boss_select:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_BossSelect)
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_boss_select.new();
	wnd:create(layout, ...);

	return wnd;
end
