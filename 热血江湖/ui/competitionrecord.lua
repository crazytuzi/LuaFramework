-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

local WIDGET = "ui/widgets/yyqcszjt"
-------------------------------------------------------
wnd_competitionRecord = i3k_class("wnd_competitionRecord", ui.wnd_base)

function wnd_competitionRecord:ctor()

end

function wnd_competitionRecord:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
end

function wnd_competitionRecord:refresh(info)
	local widgets = self._layout.vars
	widgets.viewNum:setText(i3k_get_string(18873, info.guardNumber))
	--widgets.redIcon:setImage()--2
	--widgets.blueIcon:setImage()--1
	local blueInfo = info.teams[g_COMPETITION_BLUE]
	local redInfo = info.teams[g_COMPETITION_RED]
	widgets.blue:setText(blueInfo.scoreTotal)
	widgets.red:setText(redInfo.scoreTotal)
	widgets.clan_scroll:removeAllChildren()
	local blueNum = #blueInfo.ranks
	local redNum = #redInfo.ranks
	local tem = blueNum > redNum and blueNum or redNum
	local jump = 1
	local index = 1;
	local roleID = g_i3k_game_context:GetRoleId()
	allList = widgets.clan_scroll:addChildWithCount(WIDGET , 2, tem * 2)

	for k, v in ipairs(allList) do
        local wid = v.vars
        local temInfo = nil 

        if index % 2 ~= 0 then
        	temInfo = table.remove(blueInfo.ranks, 1)
        else
        	temInfo = table.remove(redInfo.ranks, 1)
        end

        index = index + 1

        if temInfo then
        	wid.name1:setText(temInfo.name)
        	wid.lvl1:setText(temInfo.level)
        	wid.kill1:setText(temInfo.killTotal)
        	if roleID == temInfo.id then
        		jump = k
        		wid.light:setVisible(true)
        	end
        else
        	--[[wid.name1:setText("")
        	wid.lvl1:setText("")
        	wid.kill1:setText("")--]]
        	wid.bg:setVisible(false)
        end
	end

	--if not g_i3k_game_context:GetIsGuard() or not g_i3k_game_context:getCompetitionIsReallyGuard() then
	widgets.clan_scroll:jumpToChildWithIndex(jump)
	--end
	--self.id:		int32	
	--self.name:		string	
	--self.level:		int32	
	--self.score:		int32	
	--self.killTotal:		int32	
	--self.deadTotal:		int32
end

function wnd_create(layout)
	local wnd = wnd_competitionRecord.new()
	wnd:create(layout)
	return wnd
end
