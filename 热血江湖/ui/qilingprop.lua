module(..., package.seeall)

local require = require;
local ui = require("ui/base")

-------------------------------------------------------
wnd_qilingProp = i3k_class("wnd_qilingProp", ui.wnd_base)

function wnd_qilingProp:ctor()
	--self.fenghuang = nil
end

function wnd_qilingProp:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self,self.onCloseUI)
	widgets.backBtn:onClick(self, self.onBackBtn)
	widgets.propBtn:onClick(self, self.onProp)
	widgets.tipsBtn:onClick(self, self.onTips)
	widgets.item_icon4:onClick(self, self.onSkill)
end

function wnd_qilingProp:refresh(weaponId, cardID)
	local widgets = self._layout.vars
	self._weaponID = weaponId
	self._selectCardID = cardID -- 器灵的id
	self:initNodes()
end

-- InvokeUIFunction
function wnd_qilingProp:initNodes()
	local widgets = self._layout.vars
	local widgetName = i3k_db_qiling_type[self._selectCardID].widgetName
	local uiName = "ui/widgets/"..widgetName
	local id = self._selectCardID
	self:addQilingNodes(uiName)
	local iconID = i3k_db_qiling_type[id].skillIcon
	widgets.skillIcon:setImage(g_i3k_db.i3k_db_get_icon_path(iconID))
	self:updateSkillMax()
	self:updateSkillRedPoint()
	self:updatePromoteRedPoint()
end

function wnd_qilingProp:updateSkillMax()
	local id = self._selectCardID
	local widgets = self._layout.vars
	local data = g_i3k_game_context:getQilingData()
	local skillLevel = data[id].skillLevel
	local cfg = i3k_db_qiling_type[id]
	local maxRank = cfg.transUpLevel
	local isMax = skillLevel >= i3k_db_qiling_trans[id][maxRank].skillUpLevel
	widgets.maxIcon1:setVisible(isMax)
	widgets.maxIcon2:setVisible(isMax)
end
function wnd_qilingProp:addQilingNodes(uiName)
	local info = g_i3k_game_context:getQilingData()
	local rank = info[self._selectCardID].rank
	local cfg = i3k_db_qiling_nodes[self._selectCardID][rank] -- 配置表中的一组
	local node = require(uiName)()
	local flay=true
	local isAllActive = true
	for i = 1, #cfg do
		local active = info[self._selectCardID].activitePoints[cfg[i].id]
		local data = { active = active, cfg = cfg[i], cardID = self._selectCardID}
		node.vars["btn"..i]:onClick(self, self.onPropBtn, data)
		node.vars["wei"..i]:setVisible(not data.active)
		node.vars["wan"..i]:setVisible(data.active)
		
		if node.vars["xian"..i] and data.active then
			node.vars["xian"..i]:setImage(g_i3k_db.i3k_db_get_icon_path(4567))
		end
		if not data.active and isAllActive then
			isAllActive = false
		end
		--标记当前需要激活的按钮
		if not data.active and self:checkForwardActive(cfg[i].forward) then		
			local point=node.vars["posit"..i]:getPositionPercent()
			node.vars.curqiling:setPositionPercent(point.x,point.y)
			node.vars.curqiling:setAnchorPoint(0.5,0.5)
			node.vars.curqiling:show()
		end
	    if #cfg <= table.nums(info[self._selectCardID].activitePoints) then
		    node.vars.curqiling:hide()
	    end
		node.vars["zhong"..i]:setVisible(not data.active and self:checkConsume(cfg[i].consume) and self:checkForwardActive(cfg[i].forward) ) -- 可激活
	end
	node.vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_qiling_trans[self._selectCardID][rank].bgImgID))
	node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_qiling_trans[self._selectCardID][rank].iconID))
	self.fenghuang = node.anis.c_bao1
	local widgets = self._layout.vars
	local children = widgets.parent:getAddChild()
	for k, v in ipairs(children) do
		widgets.parent:removeChild(v)
	end
	widgets.parent:addChild(node)
	widgets.rankLabel:setText(i3k_get_string(1095, rank))

	widgets.propBtn:setVisible(rank < i3k_db_qiling_type[self._selectCardID].transUpLevel)
	local isMax = isAllActive and not widgets.propBtn:isVisible()
	-- widgets.max:setVisible(isMax)--满级
end

function wnd_qilingProp:checkConsume(consumes)
	for k, v in ipairs(consumes) do
		local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
		if canUseCount < v.count then
			return false
		end
	end
	return true
end
function wnd_qilingProp:checkForwardActive(forwardNode)
	local cardID = self._selectCardID
	local info = g_i3k_game_context:getQilingData()
	local activeNodes = info[cardID].activitePoints
	return forwardNode == 0 or activeNodes[forwardNode]
end


function wnd_qilingProp:onBackBtn(sender)
	g_i3k_logic:openQilingUI(self._weaponID)
	self:onCloseUI()
end

-- 进化按钮
function wnd_qilingProp:onProp(sender)
	local id = self._selectCardID
	local info = g_i3k_game_context:getQilingData()
	local rank = info[self._selectCardID].rank
	g_i3k_ui_mgr:OpenUI(eUIID_QilingPromote)
	g_i3k_ui_mgr:RefreshUI(eUIID_QilingPromote, id, rank)
end

-- 点击每个属性点
function wnd_qilingProp:onPropBtn(sender, data)
	if data.active then -- 是否已经激活
		g_i3k_ui_mgr:OpenUI(eUIID_QilingNode)
		g_i3k_ui_mgr:RefreshUI(eUIID_QilingNode, data.cfg)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_QilingActive)
		g_i3k_ui_mgr:RefreshUI(eUIID_QilingActive, data.cfg, data.cardID)
	end
end

function wnd_qilingProp:onSkill(sender)
	local info = g_i3k_game_context:getQilingData()
	local rank = info[self._selectCardID].rank
	local maxRank = i3k_db_qiling_type[self._selectCardID].transUpLevel
	if rank >= i3k_db_qiling_type[self._selectCardID].needLevel and info[self._selectCardID].skillLevel < i3k_db_qiling_trans[self._selectCardID][maxRank].skillUpLevel then
		g_i3k_ui_mgr:OpenUI(eUIID_QilingSkillUpdate)
		g_i3k_ui_mgr:RefreshUI(eUIID_QilingSkillUpdate, self._selectCardID)
	else
		g_i3k_ui_mgr:OpenUI(eUIID_QilingSkillDesc)
		g_i3k_ui_mgr:RefreshUI(eUIID_QilingSkillDesc, self._selectCardID)
	end
end

function wnd_qilingProp:onTips(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_QilingTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_QilingTips, self._selectCardID)
end

function wnd_qilingProp:updateSkillRedPoint()
	if g_i3k_game_context:upLevelRedPoint(self._selectCardID) then
		self._layout.anis.c_ss:play()
	else
		self._layout.anis.c_ss:stop()
	end
end

function wnd_qilingProp:updatePromoteRedPoint()
	local info = g_i3k_game_context:getQilingData()
	local rank = info[self._selectCardID].rank
	local cfg = i3k_db_qiling_trans[self._selectCardID][rank]
	local promote = true
	local condition =
	{
		[1] = {cond = g_i3k_game_context.checkQilingPromoteLevel},
		[2] = {cond = g_i3k_game_context.checkQilingPromotePower},
		[3] = {cond = g_i3k_game_context.checkQilingPromoteWeapon},
	}
	if table.nums(info[self._selectCardID].activitePoints) >= #i3k_db_qiling_nodes[self._selectCardID][rank] then
		if rank < i3k_db_qiling_type[self._selectCardID].transUpLevel then
			for k, v in ipairs(i3k_db_qiling_trans[self._selectCardID][rank].consume) do
				if g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count then
					promote = false
					break
				end
			end
			for k, v in ipairs(condition) do
				if not v.cond(g_i3k_game_context, cfg) then
					promote = false
					break
				end
			end
		else
			promote = false
		end
	else
		promote = false
	end
	if promote then
		self._layout.vars.promoteRed:show()
	else
		self._layout.vars.promoteRed:hide()
	end
end

function wnd_qilingProp:playPromoteAni()
	self.fenghuang.play()
end

function wnd_create(layout, ...)
	local wnd = wnd_qilingProp.new();
		wnd:create(layout, ...);
	return wnd;
end
