--
-- @Author: chk
-- @Date:   2018-11-06 16:37:40
--
HelpTipPanel = HelpTipPanel or class("HelpTipPanel", BasePanel)
local HelpTipPanel = HelpTipPanel

function HelpTipPanel:ctor()
    self.abName = "help"
    self.assetName = "HelpTipPanel"
    self.layer = "Top"

    self.offset = 75
    self.min_txt_size = 158
    self.min_line = 10
    self.single_line_height = 32

    self.is_hide_other_panel = false
    --HelpTipPanel.super.Load(self)
end

function HelpTipPanel:dctor()
end

function HelpTipPanel:Open(info, width)
    self.info = info
    self.width = width
    HelpTipPanel.super.Open(self)
end

function HelpTipPanel:LoadCallBack()
    self.nodes = {
        "bg",
        "mask",
        "bg/Text",
        "bg/Title",
    }
    self:GetChildren(self.nodes)
    self.TextTxt = self.Text:GetComponent('Text')
    self.title_rect = GetRectTransform(self.Title)

    self:AddEvent()
    self.TextTxt.text = self.info

    self.text_rect = GetRectTransform(self.TextTxt)
    self.origin_text_width = self.text_rect.sizeDelta.x
    self.bg_rect = GetRectTransform(self.bg)
    self.text_offset = self.bg_rect.sizeDelta.x - self.origin_text_width

    local width = self.width or self.bg_rect.sizeDelta.x

    local final_width = width - self.text_offset
    SetSizeDelta(self.text_rect, final_width, self.text_rect.sizeDelta.y)

    local height = self.TextTxt.preferredHeight
    local line_count = height / self.single_line_height
    if line_count > self.min_line then
        SetSizeDelta(self.bg_rect, width, height + self.offset, 0)
    else
        SetSizeDeltaX(self.bg_rect, width)
    end
end

function HelpTipPanel:AddEvent()
    AddClickEvent(self.mask.gameObject, handler(self, self.Close))
end

function HelpTipPanel:OpenCallBack()
    SetVisible(self.Text, true)
end

function HelpTipPanel:CloseCallBack()
end