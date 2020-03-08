local pb_helper = require("PB.pb_helper")
local on_level_score = function(sender, msg)
  if msg.score >= 0 then
    local ECMausoleumMan = require("Social.ECMausoleumMan")
    local MausoleumMan = ECMausoleumMan.Instance()
    MausoleumMan.m_AddScore = msg.score - MausoleumMan.m_AllScore
    MausoleumMan.m_AllScore = msg.score
    if MausoleumMan.m_AddScore > 1 then
      HUDMan.ShowReciveScore(MausoleumMan.m_AddScore)
    end
    local ECPanelMausoleumScore = require("GUI.ECPanelMausoleumScore")
    ECPanelMausoleumScore.Instance():UpdataScore()
  end
end
pb_helper.AddHandler("gp_level_score", on_level_score)
