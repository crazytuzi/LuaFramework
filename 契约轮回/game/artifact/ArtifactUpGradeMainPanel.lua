---
--- Created by  Administrator
--- DateTime: 2020/6/24 11:02
---
ArtifactUpGradeMainPanel = ArtifactUpGradeMainPanel or class("ArtifactUpGradeMainPanel", BaseItem)
local this = ArtifactUpGradeMainPanel

function ArtifactUpGradeMainPanel:ctor(parent_node, parent_panel)
    self.abName = "artifact"
    self.assetName = "ArtifactUpGradeMainPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.attrs = {}
    self.model = ArtifactModel:GetInstance()
    ArtifactUpGradeMainPanel.super.Load(self)
end

function ArtifactUpGradeMainPanel:dctor()
    self.model:RemoveTabListener(self.events)
    if self.monster then
        self.monster:destroy()
    end
    self.monster = nil
    if not table.isempty(self.attrs) then
        for i, v in pairs(self.attrs) do
            v:destroy()
        end
        self.attrs = nil
    end
    if self.red then
        self.red:destroy()
        self.red = nil
    end
end

function ArtifactUpGradeMainPanel:LoadCallBack()
    self.nodes = {
        "title/name","attrObj/upBtn","attrObj/attrItemParent","modelcon","attrObj/noUp","ArtifactAttrItem","attrObj"
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self:InitUI()
    if self.is_need_setData then
        self:SetData(self.curArtId,self.curType)
    end
    self:AddEvent()
    SetAlignType(self.attrObj.transform, bit.bor(AlignType.Right, AlignType.Null))
end

function ArtifactUpGradeMainPanel:InitUI()

end

function ArtifactUpGradeMainPanel:AddEvent()
    local function call_back()
        if not self.artInfo then
            Notify.ShowText("The current divine locked")
            return
        end
        lua_panelMgr:GetPanelOrCreate(ArtifactUpGradePanel):Open(self.curArtId)
    end
    AddButtonEvent(self.upBtn.gameObject,call_back)

    self.events[#self.events + 1] = self.model:AddListener(ArtifactEvent.ArtifactReinfInfo, handler(self, self.ArtifactReinfInfo))
    self.events[#self.events + 1] = self.model:AddListener(ArtifactEvent.UpdateRedPoint, handler(self, self.UpdateRedPoint))
end


function ArtifactUpGradeMainPanel:UpdateRedPoint()
    if not self.red then
        self.red = RedDot(self.upBtn.transform, nil, RedDot.RedDotType.Nor)
        self.red:SetPosition(27, 26)
    end
    if self.curType and self.curArtId then
        self.red:SetRedDotParam(self.model.upRedPoints[self.curType][self.curArtId] or false)
    end

end


function ArtifactUpGradeMainPanel:ArtifactReinfInfo(data)
    self:UpdateAttrInfo()
    local cfg = Config.db_artifact_unlock[self.curArtId]
    if not self.artInfo then
        self.name.text = cfg.name.."  ".."LV0"
    else
        self.name.text = cfg.name.." ".."LV"..self.artInfo.reinf_lv
    end
end

function ArtifactUpGradeMainPanel:HideAllItems()
    if not table.isempty(self.attrs) then
        for i = 1, #self.attrs do
            self.attrs[i]:SetVisible(false)
        end
    end
end

function ArtifactUpGradeMainPanel:UpdateAttrInfo()
    if not self.artInfo then
        self:HideAllItems()
        SetVisible(self.noUp,true)
    else
        if self.artInfo.reinf_lv > 0 then
            SetVisible(self.noUp,false)
            local key = self.curArtId .. "@"..self.artInfo.reinf_lv
            local cfg = Config.db_artifact_reinf[key]
            local attrTab = String2Table(cfg.attrs)
            for i = 1, #attrTab do
                local item = self.attrs[i]
                if not item  then
                    item = ArtifactAttrItem(self.ArtifactAttrItem.gameObject,self.attrItemParent,"UI")
                    self.attrs[i] = item
                else
                    item:SetVisible(true)
                end
                item:SetData(attrTab[i][1],attrTab[i][2])
            end
            for i = #attrTab + 1, #self.attrs do
                local item = self.attrs[i]
                item:SetVisible(false)
            end
        else
            self:HideAllItems()
            SetVisible(self.noUp,true)
        end
    end

end


function ArtifactUpGradeMainPanel:SetData(curArtId,curType)
    self.curArtId = curArtId
    self.curType = curType
    self.artInfo = self.model:GetArtiInfo(self.curArtId)
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    self:InitModel()
    self:UpdateAttrInfo()
    self:UpdateRedPoint()
end

function ArtifactUpGradeMainPanel:InitModel()
    local cfg = Config.db_artifact_unlock[self.curArtId]
    if not self.artInfo then
        self.name.text = cfg.name.."  ".."LV0"
    else
        self.name.text = cfg.name.." ".."LV"..self.artInfo.reinf_lv
    end

    local res = cfg.res
    local ratio = cfg.ratio
    if res == self.curRes then
        return
    end
    self.curRes = res

    -- self.curResName

    if self.monster then
        self.monster:destroy()
    end
    local cfg = {}
    cfg.pos = {x = -2001, y = -37, z = 550}
    cfg.scale = {x = 100,y = 100,z = 100}
    cfg.trans_x = 830
    cfg.trans_x = 830
    cfg.trans_offset = {y=100}
    cfg.carmera_size = 0.48

    self.monster = UIModelCommonCamera(self.modelcon, nil, "model_sacredware_"..self.curRes)
    self.monster:SetConfig(cfg)
end