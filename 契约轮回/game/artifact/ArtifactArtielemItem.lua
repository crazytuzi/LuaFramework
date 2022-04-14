---
--- Created by  Administrator
--- DateTime: 2020/6/22 16:43
---
ArtifactArtielemItem = ArtifactArtielemItem or class("ArtifactArtielemItem", BaseCloneItem)
local this = ArtifactArtielemItem

function ArtifactArtielemItem:ctor(obj, parent_node, parent_panel)
    self.model = ArtifactModel:GetInstance()
    self.events = {}
    ArtifactArtielemItem.super.Load(self)


end

function ArtifactArtielemItem:dctor()
   -- GlobalEvent:RemoveTabListener(self.events)
    if self.effect then
        self.effect:destroy()
    end
    if self.red then
        self.red:destroy()
        self.red = nil
    end
end

function ArtifactArtielemItem:LoadCallBack()
    self.nodes = {
        "img_1","t_1","select","effParent"
    }
    self:GetChildren(self.nodes)
    self.img_1 = GetImage(self.img_1)
    self.t_1 = GetText(self.t_1)
    self:InitUI()
    self:AddEvent()
    self.effect = UIEffect(self.effParent,46001,false, self.layer)
    self.effect:SetConfig({useStencil = true,scale = 4})
   -- SetVisible(self.effect, false)
end

function ArtifactArtielemItem:InitUI()

end

function ArtifactArtielemItem:AddEvent()
    local function call_back()
        self.model:Brocast(ArtifactEvent.ArtielemItemClick,self.data,self.isMax);
    end
    AddClickEvent(self.img_1.gameObject,call_back)
end

function ArtifactArtielemItem:SetData(data,artifactType)
    self.data = data
    self.artifactType = artifactType
    lua_resMgr:SetImageTexture(self,self.img_1, 'artifact_image', 'artifact_e_'..self.data,true)
    self:UpdateInfo(self.data,self.artifactType)

end

function ArtifactArtielemItem:UpdateInfo(id,type)
    local info = self.model:GetArtielemInfo(type,id)

    if not info then
        self.t_1.text = "Lv.0"
        SetVisible(self.effParent,false)
    else
        self.t_1.text = "Lv."..info.level
        local key = type.."@"..id.."@"..info.level + 1
        local cfg = Config.db_artifact_element[key]
        if not cfg then
            SetVisible(self.effParent,false)
            self.isMax = true
        else
            self.isMax = false
            if table.isempty(String2Table(cfg.cost)) then
                SetVisible(self.effParent,true)
            else
                SetVisible(self.effParent,false)
            end
        end

    end
    if not  self.red then
        self.red = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
        self.red:SetPosition(-28, 173)
    end
    self.red:SetRedDotParam(self.model.typeRedPoints[type][id])
    --self.model.typeRedPoints
end

function ArtifactArtielemItem:SetSelect(isShow)
    SetVisible(self.select,isShow)
end
--function ArtifactArtielemItem:SetEff(isShow)
--    SetVisible(self.effParent,isShow)
--end