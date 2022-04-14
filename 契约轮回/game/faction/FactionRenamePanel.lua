---
--- Created by  Administrator
--- DateTime: 2019/7/4 15:08
---
FactionRenamePanel = FactionRenamePanel or class("FactionRenamePanel", WindowPanel)
local this = FactionRenamePanel

function FactionRenamePanel:ctor(parent_node, parent_panel)
    self.abName = "faction"
    self.assetName = "FactionRenamePanel"
    self.layer = "UI"
    self.use_background = true
    self.change_scene_close = true
    self.panel_type = 4
    self.events = {}
    self.model = FactionModel:GetInstance()
end

function FactionRenamePanel:dctor()
    self.model:RemoveTabListener(self.events)
end

function FactionRenamePanel:Open( )
    FactionCreatePanel.super.Open(self)
end


function FactionRenamePanel:LoadCallBack()
    self.nodes = {
        "okBtn","qxBtn","curName","CreateName/InputField",
        "CreateName/nameDefault"
    }
    self:GetChildren(self.nodes)
    self.curName = GetText(self.curName)
    self.InputIpt = self.InputField:GetComponent('InputField')
    self:SetTileTextImage("faction_image", "faction_title_text1");
    self:InitUI()
    self:AddEvent()
end

function FactionRenamePanel:InitUI()
    self.curName.text = "Current guild name:"..self.model.selfFactionInfo.name
end

function FactionRenamePanel:AddEvent()

    local function call_back()  --确定改名
        local oneLen = string.len("Me")
        local limitLen = oneLen * 6
        local name1 = string.gsub(self.InputIpt.text, "^%s*(.-)%s*$", "%1")
        local len1 = string.len(name1)
        local name2 = string.filterSpeChars(name1)
        local len2 = string.len(name2)
        if len1 ~= len2 then
            Notify.ShowText("Improper contents found in your guild name")
            return
        end

        if len1 > limitLen then
            Notify.ShowText(ConfigLanguage.Faction.NameLength)
            return
        end

        if len1 < oneLen then
            Notify.ShowText(ConfigLanguage.Faction.NameLength2)
            return
        end

        --if string.find(self.InputIpt.text," ") then
        --	Notify.ShowText(ConfigLanguage.Mix.FeiFaZiFu)
        --	return
        --end
        if name1 == "" then
            Notify.ShowText(ConfigLanguage.Faction.NameCantAllEasp)
        else
            if self.InputIpt.text == "" then
                Notify.ShowText(ConfigLanguage.Faction.InputFactionName)
            else
                if FilterWords:GetInstance():isSafe(name2) then
                    FactionController.GetInstance():RequestGuildRename(name2)
                else
                    Notify.ShowText("Improper contents found in your guild name")
                end
            end
        end
    end
    AddClickEvent(self.okBtn.gameObject,call_back)

    local function call_back()  --确定改名
        self:Close()
    end
    AddClickEvent(self.qxBtn.gameObject,call_back)


    local function call_back(str)
        if str ~= "" then
            SetVisible(self.nameDefault.gameObject,false)

        end
    end
    self.InputIpt.onValueChanged:AddListener(call_back)

    local function call_back(str)
        if str == "" then
            SetVisible(self.nameDefault.gameObject,true)
        end
    end
    self.InputIpt.onEndEdit:AddListener(call_back)

    self.events[#self.events + 1] =  self.model:AddListener(FactionEvent.FactionRename,handler(self,self.FactionRename))

end

function FactionRenamePanel:FactionRename()
    self:Close()
    Notify.ShowText("Guild name changed")
end