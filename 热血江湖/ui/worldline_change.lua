-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
 
wnd_worldLine_change = i3k_class("wnd_worldLine_change", ui.wnd_base)

local FightColor	= "FF911d02"	--争夺分线文字颜色（发红）
local CurColor		= "FF029133"	--当前所在分线文字颜色（发绿）
local NormalColor	= "FF634624" 	--普通分线文字颜色（棕色）

function wnd_worldLine_change:ctor()
end

function wnd_worldLine_change:configure()
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

function wnd_worldLine_change:refresh(curLine, count)	
	self._layout.vars.scroll:removeAllChildren()
	for i=1, count do
		self:updateSelectedListItem(i, curLine)
	end
	local fieldPKType = i3k_game_get_field_map_pk_type()
	if fieldPKType and fieldPKType == g_FIELD_NORMAL then
		self:updateSelectedListItem(g_WORLD_KILL_LINE, curLine, count) 
	end
	local index = curLine ~= g_WORLD_KILL_LINE and curLine or count + 1 
	self._layout.vars.scroll:jumpToChildWithIndex(index)
end

function wnd_worldLine_change:updateSelectedListItem(index, curLine, count)
	local lineWidgets = require("ui/widgets/huanxiant")()
	self._layout.vars.scroll:addItem(lineWidgets)
	local widget = lineWidgets.vars
	local color = ""
	if index == g_WORLD_KILL_LINE then
		widget.text:setText("乱斗")
		widget.desc:setText("争夺分线")
		color = FightColor
	else
		local mapId = g_i3k_game_context:GetWorldMapID()
		if mapId == i3k_db_marry_rules.marryMapID then
			widget.text:setText(i3k_get_string(i3k_db_marry_line[index].lineTipsId))
		else
			widget.text:setText(index.."线")
		end
		widget.desc:setText("普通分线")
		color = NormalColor
	end
	color = index == curLine and CurColor or color
	widget.text:setTextColor(color)
	widget.desc:setTextColor(color)
	widget.normalBg:setVisible(index ~= g_WORLD_KILL_LINE)
	widget.fightBg:setVisible(index == g_WORLD_KILL_LINE)
	widget.showselect:setVisible(index == curLine)
	if index == curLine then
		widget.select_btn:stateToPressedAndDisable()
	else
		widget.select_btn:stateToNormal()
	end
	widget.select_btn:onClick(self, self.onClickChange, index)
end

function wnd_worldLine_change:onClickChange(sender, line)
	if not g_i3k_game_context:IsInFightTime() then --战斗状态下不能换线
		local function func()
			local function callBackFunc()
				i3k_sbean.change_worldline(line)
			end
			g_i3k_logic:OpenWorldLineProcessBarUI(callBackFunc)
		end
		if line == g_WORLD_KILL_LINE then
			local function fun(isOk)
				if isOk then
					g_i3k_game_context:CheckMulHorse(func, true)
				end
			end
			g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(849), fun)
		else
			g_i3k_game_context:CheckMulHorse(func, true)
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(537))
	end	
end

function wnd_create(layout)
	local wnd = wnd_worldLine_change.new();
	wnd:create(layout);
	return wnd;
end
