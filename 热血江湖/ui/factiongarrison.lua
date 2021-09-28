-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_garrison = i3k_class("wnd_garrison",ui.wnd_base)

local CONDITIONICON = {4688, 4689} -- 对勾，叉叉

local ROLE_DESC = "ui/widgets/bpgzt"
function wnd_garrison:ctor()
	self._conditionWidgets = {}
	self._count = 0
	self._conditions = {}
end

function wnd_garrison:configure()
	local widgets = self._layout.vars
	
	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.donateBtn:onClick(self, self.onDonateBtn)
	
	self.scrollDesc = widgets.scroll
	for i=1, 3 do
		local condition = "condition"..i
		local conditionDesc = "conditionDesc"..i
		
		self._conditionWidgets[i] = {
			condition		= widgets[condition],
			conditionDesc	= widgets[conditionDesc],
		}
	end
	self.donateProgress = widgets.donateProgress
	self.donateProDesc = widgets.donateProDesc
	self.btnDesc = widgets.btnDesc
end

function wnd_garrison:refresh(donateCount, isOpen)
	self._count = donateCount
	self:updateData(donateCount)
	self:updateBtnState()
end

function wnd_garrison:updateData(donateCount)
	local openCfg = i3k_db_faction_garrison.openCondition
	self._conditions = {
		[1] = g_i3k_game_context:getSectFactionLevel() >= openCfg.needFactionLvl,
		[2]	= g_i3k_game_context:GetFactionVitality() >= openCfg.needActivity,
		[3]	= donateCount >= openCfg.donationItemCount,
	}
	
	local conditionTxt = {
		[1] = i3k_get_string(16601, g_i3k_game_context:getSectFactionLevel(), openCfg.needFactionLvl),
		[2]	= i3k_get_string(16602, g_i3k_game_context:GetFactionVitality(), openCfg.needActivity),
		[3]	= i3k_get_string(16603, donateCount, openCfg.donationItemCount),
	}
	
	for i, e in ipairs(self._conditionWidgets) do
		e.condition:setImage(g_i3k_db.i3k_db_get_icon_path(self._conditions[i] and CONDITIONICON[1] or CONDITIONICON[2]))
		e.conditionDesc:setText(conditionTxt[i])
	end
	local percent = donateCount / openCfg.donationItemCount * 100
	self.donateProgress:setPercent(donateCount / openCfg.donationItemCount * 100)
	self.donateProDesc:setText(i3k_get_string(16604, math.floor(percent)))
	self.scrollDesc:removeAllChildren()
	local roleDescTxt = {
		[1] = i3k_get_string(16600, openCfg.needFactionLvl, openCfg.needActivity, openCfg.needTime)
	}	
	for k, v in ipairs(roleDescTxt) do
		local node = require(ROLE_DESC)()
		node.vars.ruleDesc:setText(v)
		self.scrollDesc:addItem(node)
		g_i3k_ui_mgr:AddTask(self, {node}, function(ui)
				local textUI = node.vars.ruleDesc
				local size = node.rootVar:getContentSize()
				local height = textUI:getInnerSize().height
				local width = size.width
				height = size.height > height and size.height or height
				node.rootVar:changeSizeInScroll(ui.scrollDesc, width, height, true)
			end, 1)
	end
end

function wnd_garrison:onDonateBtn(sender)
	local openCfg = i3k_db_faction_garrison.openCondition
	if not self._conditions[3] then
		if i3k_game_get_time() - g_i3k_game_context:getlastjointime() >= openCfg.needTime * 3600 then
			local openCfg = i3k_db_faction_garrison.openCondition
			g_i3k_ui_mgr:OpenUI(eUIID_FactionGarrisonDonate)
			g_i3k_ui_mgr:RefreshUI(eUIID_FactionGarrisonDonate, openCfg.donationItemID, self._count, openCfg.getPower)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16605, openCfg.needTime))
		end
	else
		local pos = g_i3k_game_context:GetSectPosition()
		if i3k_db_faction_power[pos] and i3k_db_faction_power[pos].garrisonOpen == 1 then
			if not self:isCanOpenGarrison() then
				return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16609))
			end
			i3k_sbean.sect_zone_open()
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16610))
		end
	end
end

function wnd_garrison:isCanOpenGarrison()
	for i, e in ipairs(self._conditions) do
		if not e then
			return false
		end
	end
	return true
end

function wnd_garrison:updateBtnState()
	--捐献已满文字变为驻地解锁
	self.btnDesc:setText(not self._conditions[3] and i3k_get_string(16611) or i3k_get_string(16612))
end
	
function wnd_create(layout)
	local wnd = wnd_garrison.new()
	wnd:create(layout)
	return wnd
end
