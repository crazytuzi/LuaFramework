-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_fightTeamResult = i3k_class("wnd_fightTeamResult", ui.wnd_base)

function wnd_fightTeamResult:ctor()
	self.myData = nil
	self.defData = nil
end

function wnd_fightTeamResult:configure(...)
	self.ui = self._layout.vars
	self.ui.close_btn:onClick(self,self.onCloseUI)
end

function wnd_fightTeamResult:refresh(data)
	local result = data.result
	--[[local result = {
		winTeam = {
			teamID = g_i3k_game_context:getFightTeamID(),
			teamName = "1",
			score = 100,
			alives = 5,
			memberLifes = 5,
			members = {
				{
					overview = {
						name = "1",
						level = 20
					},
					kills = 1,
					assist = 2,
					dead = 3,
					honor = 100
				},
				{
					overview = {
						name = "2",
						level = 30
					},
					kills = 2,
					assist = 3,
					dead = 4,
					honor = 200
				}
			}
		},
		loseTeam = {
		    teamID = 0, 
			teamName = "2",
			score = 200,
			alives = 5,
			memberLifes = 5,
			members = {
				{
					overview = {
						name = "3",
						level = 20
					},
					kills = 1,
					assist = 2,
					dead = 3,
					honor = 100
				},
				{
					overview = {
						name = "4",
						level = 30
					},
					kills = 2,
					assist = 3,
					dead = 4,
					honor = 200
				}
			
			}			
		}
	}--]]
	local winTeam = result.winTeam
	local loseTeam = result.loseTeam
	
	self.ui.winTeamName:setText(winTeam.teamName)
	
	local isHaiXuan = false
	local worldMapID = g_i3k_game_context:GetWorldMapID()
	local fightTeamFb = i3k_db_fight_team_fb[worldMapID]
	if fightTeamFb and fightTeamFb.mapType == 1 then
		isHaiXuan = true
	end
	if isHaiXuan then
		self.ui.winTeamInfo:setText("积分+" .. winTeam.score)
	else
		self.ui.winTeamInfo:setText("存活:" .. winTeam.alives)
	end
	
	self.ui.loseTeamName:setText(loseTeam.teamName)
	if isHaiXuan then
		self.ui.loseTeamInfo:setText("积分+" .. loseTeam.score)
	else
		self.ui.loseTeamInfo:setText("存活:" .. loseTeam.alives)
	end
	
	if winTeam.alives == loseTeam.alives and winTeam.memberLifes == loseTeam.memberLifes then
		self.ui.info:setText("战况胶着，根据队员剩余气血百分比总和决定胜负")
	end
	
	local myTeamId = g_i3k_game_context:getFightTeamID()
	if myTeamId == winTeam.teamID then
		self.myData = winTeam.members
		self.defData = loseTeam.members
	else
		self.defData = winTeam.members
		self.myData = loseTeam.members
	end
	self.ui.myBtn:onClick(self,self.showMy)
	self.ui.defBtn:onClick(self,self.showDef)
	self:showMy()
end

function wnd_fightTeamResult:showMy()
	self.ui.scroll:removeAllChildren()
	self.ui.myBtn:stateToPressed()
	self.ui.defBtn:stateToNormal()
	self:show(self.myData)
end

function wnd_fightTeamResult:showDef()
	self.ui.scroll:removeAllChildren()
	self.ui.defBtn:stateToPressed()
	self.ui.myBtn:stateToNormal()
	self:show(self.defData)
end

function wnd_fightTeamResult:show(data)
	self.ui.scroll:removeAllChildren()
	for k,v in ipairs(data) do
		local item = require("ui/widgets/wudaohuijgt")()
		item.vars.name_label:setText(v.overview.name)
		item.vars.lvl_label:setText(v.overview.level)
		item.vars.kill_label:setText(v.kills)
		item.vars.assist_lable:setText(v.assist)
		item.vars.dead_label:setText(v.dead)
		item.vars.honor_label:setText(v.honor)
		if v.overview.id == g_i3k_game_context:GetRoleId() then
			local orangeColor = "FFEE723B"
			item.vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(8023))
			item.vars.name_label:setTextColor(orangeColor)
			item.vars.lvl_label:setTextColor(orangeColor)
		else
			item.vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(6204))
		end
		self.ui.scroll:addItem(item)
	end
end


function wnd_create(layout, ...)
	local wnd = wnd_fightTeamResult.new();
		wnd:create(layout, ...);
	return wnd;
end
