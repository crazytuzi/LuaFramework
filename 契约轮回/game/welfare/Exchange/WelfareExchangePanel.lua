---
--- Created by  R2D2
--- DateTime: 2019/1/16 20:45
---
WelfareExchangePanel = WelfareExchangePanel or class("WelfareExchangePanel", BaseItem)
local this = WelfareExchangePanel

function WelfareExchangePanel:ctor(parent_node, parent_panel)
    self.abName = "welfare"
    self.assetName = "WelfareExchangePanel"
    self.layer = "UI"
    self.parentPanel = parent_panel

    self.events = {}
    WelfareExchangePanel.super.Load(self)
end

function WelfareExchangePanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function WelfareExchangePanel:LoadCallBack()
    self.nodes = { "Input/InputField", "Input/Button" }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
end

function WelfareExchangePanel:InitUI()
    self.inputFiled = GetInputField(self.InputField)
end

function WelfareExchangePanel:AddEvent()
    local function OnGetButton()
        local str = self.inputFiled.text

        if str == "" then
            Notify.ShowText("Please enter the correct Gift Code")
            return
        end

        local new_str = ""
        string.gsub(str, "([%z\33-\126]+)", function(s)
            new_str = new_str .. s
        end)

        if #str > #new_str then
            Notify.ShowText("Illegal character contained in the gift code")
            return
        end

        WelfareController:GetInstance():ReqeustGiftCode(str)

    end
    AddButtonEvent(self.Button.gameObject, OnGetButton)

    local function Call_Back()
        Notify.ShowText("Claimed")
        self.inputFiled.text = ""
    end
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(WelfareEvent.Welfare_GiftCodeSuccessEvent, Call_Back)
end