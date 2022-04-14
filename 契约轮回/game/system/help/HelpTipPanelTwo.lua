-- @Author: lwj
-- @Date:   2019-06-10 17:27:02
-- @Last Modified time: 2019-06-10 17:27:05
--

HelpTipPanelTwo = HelpTipPanelTwo or class("HelpTipPanelTwo", BasePanel)
local HelpTipPanelTwo = HelpTipPanelTwo

function HelpTipPanelTwo:ctor()
    self.abName = "help"
    self.assetName = "HelpTipPanelTwo"
    self.layer = "Top"

    --HelpTipPanelTwo.super.Load(self)
end

function HelpTipPanelTwo:dctor()
end

function HelpTipPanelTwo:LoadCallBack()
    self.nodes = {
        "ps", "btn_close", "scroll/Viewport/Content/con",
    }
    self:GetChildren(self.nodes)
    self.ps = GetText(self.ps)
    self.con = GetText(self.con)

    self:AddEvent()

    self.con.text = self.info
    self.ps.text = self.ps_text
end

function HelpTipPanelTwo:AddEvent()
    AddButtonEvent(self.btn_close.gameObject, handler(self, self.Close))
end

function HelpTipPanelTwo:Open(info, ps)
    self.info = info
    self.ps_text = ps
    HelpTipPanelTwo.super.Open(self)
end

function HelpTipPanelTwo:OpenCallBack()
    SetVisible(self.con, true)
end

function HelpTipPanelTwo:CloseCallBack()
end
