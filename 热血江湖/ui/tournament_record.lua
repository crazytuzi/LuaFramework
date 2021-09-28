-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_tournament_record = i3k_class("wnd_tournament_record", ui.wnd_base)

local f_numberImgTable = {"jjc#jjc_0.png", "jjc#jjc_1.png", "jjc#jjc_2.png", "jjc#jjc_3.png", "jjc#jjc_4.png", "jjc#jjc_5.png", "jjc#jjc_6.png", "jjc#jjc_7.png", "jjc#jjc_8.png", "jjc#jjc_9.png"}

function wnd_tournament_record:ctor()
	
end

function wnd_tournament_record:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
end

function wnd_tournament_record:onShow()
	
end

function wnd_tournament_record:refresh(info)
	self:loadRankData(info.logs)
	local weekRank = info.weekRank
	
	local mbw = self._layout.vars.imgB
	local msw = self._layout.vars.imgS
	local mgw = self._layout.vars.imgG
	if weekRank==0 then
		self._layout.vars.activeRoot:hide()
		self._layout.vars.noActive:show()
	else
		self._layout.vars.activeRoot:show()
		self._layout.vars.noActive:hide()
		if weekRank<100 then
			mgw:hide()
			if weekRank<10 then
				msw:hide()
				mbw:setImage(f_numberImgTable[weekRank+1])
			else
				local sw = math.floor(weekRank/10)
				local gw = math.floor(weekRank%10)
				mbw:setImage(f_numberImgTable[sw+1])
				msw:setImage(f_numberImgTable[gw+1])
			end
		else
			local bw = math.floor(weekRank/100)
			local sw = math.floor(weekRank%100/10)
			local gw = math.floor(weekRank%10)
			mbw:setImage(f_numberImgTable[bw+1])
			msw:setImage(f_numberImgTable[sw+1])
			mgw:setImage(f_numberImgTable[gw+1])
		end
	end
end

function wnd_tournament_record:loadRankData(logs)
	local scroll = self._layout.vars.scroll
	local count = 0
	for i,v in pairs(logs) do
		local node = require("ui/widgets/4v4pht")()
		local activity = i3k_db_tournament[i]
		node.vars.nameLabel:setText(activity.name)
		node.vars.enterLabel:setText(v.enterTimes)
		local probaStr = string.format("%.1f", v.winTimes/v.enterTimes*100)
		node.vars.probaLabel:setText(probaStr.."%")
		-- node.vars.rankLabel:setText(v.bestRank)
		node.vars.rankLabel:setText(v.dayHonor)
		node.vars.btn:onClick(self, self.checkTypeRank, i)
		scroll:addItem(node)
		count = count + 1
	end
	if count>0 then
		self._layout.vars.checkBtn:enableWithChildren()
		self._layout.vars.checkBtn:onClick(self, self.checkRank)
	else
		self._layout.vars.checkBtn:disableWithChildren()
	end
end

function wnd_tournament_record:checkTypeRank(sender, rankType)
	i3k_log("rankType = "..rankType)
end

function wnd_tournament_record:checkRank(sender)
	--g_i3k_ui_mgr:PopupTipMessage("查看")
	g_i3k_logic:OpenSuperArenaWeekrankUI()
end

--[[function wnd_tournament_record:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_TournamentRecord)
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_tournament_record.new()
	wnd:create(layout, ...)
	return wnd;
end
