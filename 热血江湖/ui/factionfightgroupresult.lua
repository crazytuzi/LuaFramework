-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

local item = require("ui/widgets/bpzzjt")
-------------------------------------------------------
wnd_factionFightGroupResult = i3k_class("wnd_factionFightGroupResult", ui.wnd_base)

function wnd_factionFightGroupResult:ctor()
	self.myData = {}
	self.defData = {}
end

function wnd_factionFightGroupResult:configure()
	self._layout.vars.get_score:setText(i3k_get_string(3120))
	self._layout.vars.myInfobtn:onClick(self,function ()
		self:showMy()
	end)
	self._layout.vars.defInfoBtn:onClick(self,function ()
		self:showDef()
	end)
	self._layout.vars.close_btn:onClick(self,self.onClose)
end

function wnd_factionFightGroupResult:refresh(myData, defData, myGroupData, defGroupData, winForceType)
	self.myData = myData
	self.defData = defData
	
	local vars = self._layout.vars
	vars.myFactionName:setText(myGroupData.sectName)
	vars.myGroupName:setText(myGroupData.groupName)
	
	vars.defFactionName:setText(defGroupData.sectName)
	vars.defGroupName:setText(defGroupData.groupName)
	
	local fightScore = g_i3k_game_context:getFactionFightScore()
	local forceType = g_i3k_game_context:GetForceType()
	local myScore = forceType == 1 and fightScore.whiteScore or fightScore.blackScore
	local defScore = forceType == 1 and fightScore.blackScore or fightScore.whiteScore
	
	vars.myScore:setText(myScore)
	vars.defScore:setText(defScore)
	
	local imgIcon = {
		my = 4092,
		def = 4092
	}
	if winForceType == -1 then
		imgIcon.my = 4094
		imgIcon.def = 4093
	elseif winForceType == 0 then
		--默认
	else
		if forceType == winForceType then
			imgIcon.my = 4091
		else
			imgIcon.def = 4091
		end
	end
	vars.myIcon:setImage(g_i3k_db.i3k_db_get_icon_path(imgIcon.my))
	vars.defIcon:setImage(g_i3k_db.i3k_db_get_icon_path(imgIcon.def))
	self:showMy()
end

function wnd_factionFightGroupResult:showMy()
	self._layout.vars.myInfobtn:stateToPressed()
	self._layout.vars.defInfoBtn:stateToNormal()
	self:showData(self.myData)
end

function wnd_factionFightGroupResult:showDef()
	self._layout.vars.defInfoBtn:stateToPressed()
	self._layout.vars.myInfobtn:stateToNormal()
	self:showData(self.defData)
end

function wnd_factionFightGroupResult:showData(data)
	local scroll = self._layout.vars.data_scroll
	scroll:removeAllChildren()
	
	table.sort(data, function (a, b)
		return a.score > b.score
	end)
	
	for k,_data in ipairs(data) do
		local _item = item()
		local vars = _item.vars
		if _data.rid == g_i3k_game_context:GetRoleId() then
			local orangeColor = "FFEE723B"
			vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(8023))
			vars.rank_label:setTextColor(orangeColor)
			vars.name_label:setTextColor(orangeColor)
			vars.lvl_label:setTextColor(orangeColor)
			vars.score_label:setTextColor(orangeColor)
		else
			vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(6204))
		end
		vars.rank_label:setText(k)
		vars.name_label:setText(_data.name)
		vars.lvl_label:setText(_data.level)
		vars.kill_label:setText(_data.kills)
		vars.assist_lable:setText(_data.assist)
		vars.mineral_label:setText(_data.mineralScore)
		vars.score_label:setText(_data.score)
		scroll:addItem(_item)
	end
end

function wnd_factionFightGroupResult:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_FactionFightGroupResult)
end

function wnd_create(layout, ...)
	local wnd = wnd_factionFightGroupResult.new()
		wnd:create(layout, ...)
	return wnd
end
