-- @Author: lwj
-- @Date:   2019-11-28 19:10:53  
-- @Last Modified time: 2019-11-28 20:53:23

ChristmasConsumeView = ChristmasConsumeView or class("ChristmasConsumeView", BaseConsumeView)
local this = ChristmasConsumeView

function ChristmasConsumeView:ctor(parent_node, parent_panel, actID)
    self.abName = "nation"
    self.assetName = "ChristmasConsumeView"
    self.layer = "UI"
    self.stype = 3
    ChristmasConsumeView.super.Load(self)
end