
-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_faction_escort_luck_draw = i3k_class("wnd_faction_escort_luck_draw", ui.wnd_base)

local STEP_ANGLE = 1000 --旋转速度
local CIRCLE_ROTATION = 1080 --三圈360*3
function wnd_faction_escort_luck_draw:ctor()

end

function wnd_faction_escort_luck_draw:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.startGame:onClick(self, self.okbtn)
	self._isStartGame = false
	self._endAngle = 0
	self.wheel_index = widgets.wheel_index
	self.startGame = widgets.startGame
end

function wnd_faction_escort_luck_draw:refresh()
	self:updataItems()
	self:updateRobTimes()
end


function wnd_faction_escort_luck_draw:okbtn(sender)
	local count = g_i3k_game_context:GetFactionEscortLuckTimes()
	if count == 0 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5499))
	end
	if g_i3k_game_context:GetBagIsFull() then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5500))
		return
	end
	self.startGame:stateToPressedAndDisable(false)
	local escortInfo =  g_i3k_game_context:GetFactionEscortLuckInfo()
	local cfg = i3k_db_escort_luck_draw[g_FACTION_ESCORT_LUAK_ONE].escortTimes
	for k, v in ipairs(cfg) do
		if v <= escortInfo.deliverTimes and not escortInfo.takedTimes[v] then
			i3k_sbean.escort_luck_draw(g_FACTION_ESCORT_LUAK_ONE, v)
			break
		end
	end
	--self:showResult({{id = 65790, count = 2 },})
end

function wnd_faction_escort_luck_draw:onUpdate(dTime)
	self:onLuckRotation(dTime)
end

function wnd_faction_escort_luck_draw:onLuckRotation(dTime)
	if self._isStartGame then
		if self._endAngle <= STEP_ANGLE * dTime then
			self.wheel_index:setRotation(self.wheel_index:getRotation() + self._endAngle)
			self._isStartGame = false
			self.startGame:stateToNormal()
			self._endAngle = 0
			g_i3k_ui_mgr:AddTask(self, {},function(ui)
				g_i3k_ui_mgr:ShowGainItemInfo(self.drops)
			end,
			1)
		else
			self.wheel_index:setRotation(self.wheel_index:getRotation() + STEP_ANGLE * dTime)
			self._endAngle =  self._endAngle - STEP_ANGLE * dTime
		end
	end
	
end


function wnd_faction_escort_luck_draw:updataItems()
	local widgets = self._layout.vars
    local cfg = i3k_db_escort_luck_draw[g_FACTION_ESCORT_LUAK_ONE].drops
	for k, v in ipairs(cfg) do
		local curCount = g_i3k_game_context:GetCommonItemCanUseCount(v.id)
		if widgets["item_bg"..k] then
			widgets["item_bg"..k]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
			widgets["item_icon"..k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id,g_i3k_game_context:IsFemaleRole()))
			widgets["cnt"..k]:setText(v.count)
			widgets["Btn"..k]:onClick(self,function(id) g_i3k_ui_mgr:ShowCommonItemInfo(v.id) end)
			widgets["suo"..k]:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(v.id))
		end
	end
end


function wnd_faction_escort_luck_draw:showResult(drops)
    self.startGame:stateToPressedAndDisable(true)
    self.drops = drops
	local addRotation = self:getRotation(drops[1])
	local starRotation = self.wheel_index:getRotation()
	if starRotation > CIRCLE_ROTATION then
		starRotation = starRotation %CIRCLE_ROTATION
		self.wheel_index:setRotation(starRotation)
	end
	self._endAngle = CIRCLE_ROTATION - starRotation + addRotation
	self._isStartGame = true
	self:updateRobTimes()
end


function wnd_faction_escort_luck_draw:getRotation(drop)
    local index = 1
	local cfg = i3k_db_escort_luck_draw[g_FACTION_ESCORT_LUAK_ONE].drops
	for k, v in ipairs(cfg) do
		if v.id == drop.id and v.count == drop.count then
			index = k
			break
		end
	end
	local oneRotation = 360/#cfg   --每份
	local rotation = oneRotation * index - oneRotation/2
	return rotation
end

function wnd_faction_escort_luck_draw:updateRobTimes()
	local have_times = g_i3k_game_context:GetFactionEscortLuckTimes()
	local cfg = i3k_db_escort_luck_draw[g_FACTION_ESCORT_LUAK_ONE].escortTimes
	local timesStr = nil
	for k, v in ipairs(cfg) do
		if timesStr then
			timesStr = timesStr.."/"..v
		else
			timesStr = v
		end
	end
	timesStr = i3k_get_string(5498, timesStr)
	local str = string.format("剩余次数：%s",have_times)
	
	self._layout.vars.desc:setText(str.."\n"..timesStr)
end 
-------------------------------------
function wnd_create(layout)
	local wnd = wnd_faction_escort_luck_draw.new();
		wnd:create(layout);
	return wnd;
end
