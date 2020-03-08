local Lplus = require("Lplus")
local ECGame = Lplus.ForwardDeclare("ECGame")
local pb_helper = require("PB.pb_helper")
local CLIMBTOWER_TID = 839
local function on_level_result(sender, msg)
  local curWorldTid = ECGame.Instance().m_curWorldTid
  local instQuitShow = dofile("Configs/instance_quit_show.lua")
  local scoreFlag = instQuitShow.Score[curWorldTid] or false
  if scoreFlag then
    local ECPanelMausoleumResult = require("GUI.ECPanelMausoleumResult")
    ECPanelMausoleumResult.Instance():Toggle()
    return
  end
  if curWorldTid == CLIMBTOWER_TID then
    if msg.result == 0 then
      local ECPanelPassFail = require("GUI.ECPanelPassFail")
      ECPanelPassFail.Instance():Toggle()
    else
      local ECPanelPassWin = require("GUI.ECPanelPassWin")
      ECPanelPassWin.Instance():Toggle()
    end
  elseif msg.result == 0 then
    local panel = require("GUI.ECPanelHeroFightFail")
    local flag = instQuitShow.Failed[curWorldTid] or false
    if flag then
      panel.Instance():Toggle()
    end
  else
    local panel = require("GUI.ECPanelInstanceEnd")
    local flag = instQuitShow.Winner[curWorldTid] or false
    if flag then
      panel.Popup()
    end
  end
end
pb_helper.AddHandler("gp_level_result", on_level_result)
