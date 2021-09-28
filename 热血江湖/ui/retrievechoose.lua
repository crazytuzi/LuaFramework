-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_retrieve_choose = i3k_class("wnd_retrieve_choose", ui.wnd_base)

function wnd_retrieve_choose:ctor()
	self.canSelect = true
end

function wnd_retrieve_choose:configure()
	self._layout.vars.closeBtn:onClick(self, self.closeUI)
	self._layout.vars.bzts_btn:onClick(self, self.selectNotShow)
	self._layout.vars.bzts_img:hide()
end

function wnd_retrieve_choose:refresh()
	
	local existRetrAct = g_i3k_game_context:GetRetrieveActData()
	local lastAct = existRetrAct.lastTimes
	local listUI = self._layout.vars.scrollList
	listUI:removeAllChildren()
	local count = 0
	for k,v in ipairs(i3k_db_activity) do
		if lastAct[k] and lastAct[k] > 0 then
			count = count + 1
		end
	end
	listUI:addChildWithCount("ui/widgets/hd1t", 2, count, true)
	local curIndex = 1
	for k,v in ipairs(i3k_db_activity) do
		if lastAct[k] and lastAct[k] > 0 then
			local node = listUI:getChildAtIndex(curIndex)
			curIndex = curIndex + 1
			node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.icon))--i3k_db_icons[v.icon].path)
			--node.vars.icon:setOpacity(255*0.6)
			node.vars.name:setText(v.name)
			node.vars.haveTimes:setTextColor("FF76d646")
			node.vars.haveTimes:enableOutline("FF516c31")
			node.vars.clickBtn:onClick(self, self.gotoChoose,k)
			node.vars.haveTimes:setText("剩余次数："..lastAct[k])
			node.vars.dropWord1:setText(v.dropDesc1)
			local dropStar1 = {node.vars.dropStar11, node.vars.dropStar12, node.vars.dropStar13}
			for i,t in ipairs(dropStar1) do
				if i<=v.dropStar1 then
					t:show()
				else
					t:hide()
				end
			end
			node.vars.dropWord2:setText(v.dropDesc2)
			node.vars.drop2:setVisible(v.dropStar2~=0)
			local dropStar2 = {node.vars.dropStar21, node.vars.dropStar22, node.vars.dropStar23}
			for i,t in ipairs(dropStar2) do
				if i<=v.dropStar2 then
					t:show()
				else
					t:hide()
				end
			end
		end
	end
end

function wnd_retrieve_choose:gotoChoose(sender, groupID)
	local cfg = i3k_db_activity[groupID]
	g_i3k_ui_mgr:OpenUI(eUIID_RetrieveActivity)
	g_i3k_ui_mgr:RefreshUI(eUIID_RetrieveActivity, groupID, cfg.name, cfg.icon)
	self:onCloseUI()
end

function wnd_retrieve_choose:closeUI(sender)
	if self._layout.vars.bzts_img:isVisible() then
		self:tipsBoard()
	else
		self:onCloseUI()
	end
end

function wnd_retrieve_choose:tipsBoard()
	local desc = i3k_get_string(15394)
	local callback = function (isOk)
		if isOk then
			local cfg = g_i3k_game_context:GetUserCfg()
			if cfg then
				cfg:SetNotShowDay(g_i3k_get_day(i3k_game_get_time()))
			end
			if g_i3k_ui_mgr:GetUI(eUIID_RetrieveActivityTip) then
				g_i3k_ui_mgr:CloseUI(eUIID_RetrieveActivityTip)
			end
			self:onCloseUI()
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
end

function wnd_retrieve_choose:selectNotShow(sender)
	if canSelect then
		self._layout.vars.bzts_img:show()
		canSelect = false
	else
		self._layout.vars.bzts_img:hide()
		canSelect = true
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_retrieve_choose.new()
	wnd:create(layout, ...)
	return wnd;
end
