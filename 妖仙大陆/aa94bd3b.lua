

local Helper = require 'Zeus.Logic.Helper'
local Util   = require 'Zeus.Logic.Util'
local Arena  = require 'Zeus.Model.Arena'
local ServerTime = require 'Zeus.Logic.ServerTime'
local _M = {}
_M.__index = _M

local hud_left
local hud_topRight
local lb_time
local defaultTimeArena

local Text = {
  
}

local maxPlayer = 20
local function InitComponent(self,tag)
	
  maxPlayer = GlobalHooks.DB.Find("GameMap", 70002).AllowedPlayers
	local top_right = XmdsUISystem.CreateFromFile("xmds_ui/arena/jjc_topright.gui.xml")
  HudManagerU.Instance:AddHudUI(top_right,'Arena.Hud.TopRight')
  local lb_fightpoint = top_right:FindChildByEditName('lb_fightpoint',true)
  lb_fightpoint.Text = 0
  local btn_tuichu = top_right:FindChildByEditName('btn_5v5leaveout',true)
  lb_time = top_right:FindChildByEditName('lb_time',true)
  defaultTimeArena = tostring(lb_time.Text)

  btn_tuichu.TouchClick = function (sender)
    local fightingEnd = false
        if not fightingEnd then
            local txt = Util.GetText(TextConfig.Type.FUBEN, 'outjjc')
            local backBattle = Util.GetText(TextConfig.Type.FUBEN, 'backBattle')
            local quit = Util.GetText(TextConfig.Type.FUBEN, 'quit')
            local title = Util.GetText(TextConfig.Type.FUBEN, 'title')
            GameAlertManager.Instance:ShowAlertDialog(
            AlertDialog.PRIORITY_NORMAL,
            txt,quit,backBattle,title,nil,
            function()
                Arena.RequestLeaveArenaArea( function()
                  lb_time.Text = defaultTimeArena
                    if DataMgr.Instance.TeamData.HasTeam and DataMgr.Instance.TeamData:IsLeader() then
                        
                        if DataMgr.Instance.QuestManager.autoControl.IsAuto then
                            EventManager.Fire("Event.Quest.CancelAuto", {});
                        end
                    end
                end )
            end,
            function() end
            )
        else
            Arena.RequestLeaveArenaArea( function()
              lb_time.Text = defaultTimeArena
            end )
        end
  end
end

local function UpdateBattleInfo()
  local data = Arena.battleData
  

  
  if not data or not data.s2c_index or not hud_left or not hud_left.Visible then 
    return 
  end
  
  
  for i=1,3 do
    local cvs_playername = hud_left:FindChildByEditName('cvs_playername'..i,true)
    if data.s2c_scores and #data.s2c_scores >= i then
      cvs_playername.Visible = true
      local item = data.s2c_scores[i]
      local lb_name = cvs_playername:FindChildByEditName('lb_name',false)
      local lb_num = cvs_playername:FindChildByEditName('lb_num',false)
      lb_name.Text = item.name
      
      lb_num.Text = item.score
    else
      cvs_playername.Visible = false
    end
  end
  
  for i=1,3 do
    local cvs_playername = hud_left:FindChildByEditName('cvs_playername'..(i+3),true)
    if data.s2c_killCountList and #data.s2c_killCountList >= i then
      cvs_playername.Visible = true
      local item = data.s2c_killCountList[i]
      local lb_name = cvs_playername:FindChildByEditName('lb_name',false)
      local lb_num = cvs_playername:FindChildByEditName('lb_num',false)
      lb_name.Text = item.name
      
      lb_num.Text = item.score
    else
      cvs_playername.Visible = false
    end
  end
  
  
  
  

  
  local lb_win = hud_topRight:FindChildByEditName('lb_win',true)
  
  local lb_fightpoint = hud_topRight:FindChildByEditName('lb_fightpoint',true)
  local lb_people = hud_topRight:FindChildByEditName('lb_people',true)
  lb_win.Text = data.s2c_killCount
  lb_people.Text =  tostring(data.s2c_playerCount) .. "/" .. maxPlayer

  

  
  
  local justScore = tonumber(lb_fightpoint.Text)
  
  if justScore ~= data.s2c_score then
    lb_fightpoint.Text = data.s2c_score 
    if data.s2c_score > justScore then
      GameAlertManager.Instance:ShowFloatingTipsMinor("h+"..(data.s2c_score - justScore));
    end
  end
end

local function onEnvironmentChange(eventname,params)
    local key = params.key
    if key == "TimeCounter" then
      lb_time.Text = GameUtil.GetMiniteTimeToString(params.value)
    end
end

local function OnShowHud(...)
  local left = HudManagerU.Instance:GetHudUI('Arena.Hud.Left')
  local top_right = HudManagerU.Instance:GetHudUI('Arena.Hud.TopRight')
  if not left then
    left = XmdsUISystem.CreateFromFile("xmds_ui/arena/jjc_left.gui.xml")
    local tbt_open = left:FindChildByEditName('tbt_open',true)
    local cvs_frame = left:FindChildByEditName('cvs_frame',true)
    tbt_open.IsChecked = false
    tbt_open.TouchClick = function (sender)
      if sender.IsChecked then
        cvs_frame.X = cvs_frame.X - cvs_frame.Width + tbt_open.Width
      else
        cvs_frame.X = 0
      end
    end
    HudManagerU.Instance:AddHudUI(left,'Arena.Hud.Left')
  end

  if not top_right then
    InitComponent()
    top_right = HudManagerU.Instance:GetHudUI('Arena.Hud.TopRight')
  end
  left.Visible = true
  top_right.Visible = true
  hud_left = left
  hud_topRight = top_right
  lb_time = hud_topRight:FindChildByEditName('lb_time',true)
  if defaultTimeArena then
    lb_time.Text = defaultTimeArena
  end
  EventManager.Subscribe("Event.EnvironmentVarChange", onEnvironmentChange)
  UpdateBattleInfo()
end

local function OnCloseHud(...)
  local left = HudManagerU.Instance:GetHudUI('Arena.Hud.Left')
  local top_right = HudManagerU.Instance:GetHudUI('Arena.Hud.TopRight')
  if left then
    left.Visible = false
  end
  if top_right then
    top_right.Visible = false
  end 
  hud_left = nil
  hud_topRight = nil
end


local function initial(...)
  EventManager.Subscribe("Event.Arena.ShowHud", OnShowHud)
  EventManager.Subscribe("Event.Arena.CloseShowHud", OnCloseHud)
  EventManager.Subscribe("Event.Arena.UpdateBattleInfo", UpdateBattleInfo)

  
  
  
  
  
  
  
  
  
  
end

local function fin()
  EventManager.Unsubscribe("Event.Arena.ShowHud", OnShowHud)
  EventManager.Unsubscribe("Event.Arena.CloseShowHud", OnCloseHud)
  EventManager.Unsubscribe("Event.Arena.UpdateBattleInfo", UpdateBattleInfo)
  
end
_M.initial = initial
_M.fin = fin
return _M
