---
--- Created by  Administrator
--- DateTime: 2020/6/28 17:54
---
ArtifactEnchantPanel = ArtifactEnchantPanel or class("ArtifactEnchantPanel", BaseItem)
local this = ArtifactEnchantPanel

function ArtifactEnchantPanel:ctor(parent_node, parent_panel)
    self.abName = "artifact"
    self.assetName = "ArtifactEnchantPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.attrs = {}
    self.attrs1 = {}
    self.model = ArtifactModel:GetInstance()
    ArtifactEnchantPanel.super.Load(self)
end

function ArtifactEnchantPanel:dctor()
    self.model:RemoveTabListener(self.events)
    if not table.isempty(self.attrs) then
        for i, v in pairs(self.attrs) do
            v:destroy()
        end
        self.attrs = {}
    end

    if not table.isempty(self.attrs1) then
        for i, v in pairs(self.attrs1) do
            v:destroy()
        end
        self.attrs1 = {}
    end
    if self.monster then
        self.monster:destroy()
    end
    self.monster = nil
    if self.itemicon then
        self.itemicon:destroy()
    end
    self.itemicon = nil
end

function ArtifactEnchantPanel:LoadCallBack()
    self.nodes = {
        "title/name","modelcon","attrObj/fulingBtn","attrObj/attrItemParent",
        "attrObj/iconParent",
        "attrObj/attrItemParent2","attrObj/nums","ArtifactAttrItem",
        "noLocK","noLocK/lockTex","attrObj","noUp","bg",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.lockTex = GetText(self.lockTex)
    self.nums = GetText(self.nums)
    self:InitUI()
    if self.is_need_setData then
        self:SetData(self.curArtId,self.curType)
    end
    self:AddEvent()
    SetAlignType(self.attrObj.transform, bit.bor(AlignType.Right, AlignType.Null))
    SetAlignType(self.noUp.transform, bit.bor(AlignType.Right, AlignType.Null))
    SetAlignType(self.noLocK.transform, bit.bor(AlignType.Right, AlignType.Null))
    SetAlignType(self.bg.transform, bit.bor(AlignType.Right, AlignType.Null))

end

function ArtifactEnchantPanel:InitUI()

end

function ArtifactEnchantPanel:AddEvent()
    local function call_back()
        if not self.model:IsLockEnchant(self.curArtId,1) then
            Notify.ShowText("Please equip the right gear to unlock the enchantment")
            return
        end
        ArtifactController:GetInstance():RequstArtifactEnchantInfo(self.curArtId)
    end
    AddButtonEvent(self.fulingBtn.gameObject,call_back)

    self.events[#self.events + 1] = self.model:AddListener(ArtifactEvent.ArtifactEnchantInfo, handler(self, self.ArtifactEnchantInfo))
end
function ArtifactEnchantPanel:SetData(curArtId,curType)
    self.curArtId = curArtId
    self.curType = curType
    self.artInfo = self.model:GetArtiInfo(self.curArtId)
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    self:InitModel()
    self:UpdateAttrInfo()
    self:CreateIcon()
end

function ArtifactEnchantPanel:HideAllItems()
    if not table.isempty(self.attrs) then
        for i = 1, #self.attrs do
            self.attrs[i]:SetVisible(false)
        end
    end
end

function ArtifactEnchantPanel:ArtifactEnchantInfo()
    self.artInfo = self.model:GetArtiInfo(self.curArtId)
    --self:UpdateAttrInfo()
    self:UpdateEnchantAttr()
    self:CreateIcon()
end



function ArtifactEnchantPanel:CreateIcon()
    local cfg = Config.db_artifact_enchant[self.curArtId.."@"..1]
    local constTab = String2Table(cfg.cost)
    local param = {}
    param["item_id"] = constTab[1][1]
    param["num"] = constTab[1][2]
    param["model"] = BagModel
    param["can_click"] = true
    param["show_num"] = true
    if self.itemicon == nil then
        self.itemicon = GoodsIconSettorTwo(self.iconParent)
    end
    self.itemicon:SetIcon(param)

    local mNum = self.model:GetItemNumByItemID(constTab[1][1]);
    local color = "00FCFF"
    if mNum < constTab[1][2] then
        color = "FF1C00"
    end
    self.nums.text = string.format("<color=#%s>%s/%s</color>",color,mNum,constTab[1][2])
end

function ArtifactEnchantPanel:UpdateAttrInfo()
    if not self.artInfo then
        self.lockTex.text = "The current divine locked"
        SetVisible(self.noLocK,true)
        SetVisible(self.attrObj,false)
        SetVisible(self.noUp,false)
    else
        --基础属性
         SetVisible(self.attrObj,true)
        SetVisible(self.noLocK,false)
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
        self:UpdateEnchantAttr()

        logError(self.model:IsMaxEnchant(self.curArtId))
    end
    
end

function ArtifactEnchantPanel:UpdateEnchantAttr()
    for i = 1, 4 do
        local key = self.curArtId.."@"..i
        local cfg = Config.db_artifact_enchant[key]
        local attrId = cfg.attr_code
        local attrValue = cfg.attr_base
        if self.artInfo.enchant[attrId] then
            attrValue = self.artInfo.enchant[attrId]
        end
        local item = self.attrs1[i]
        if not item  then
            item = ArtifactAttrItem(self.ArtifactAttrItem.gameObject,self.attrItemParent2,"UI")
            self.attrs1[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(attrId,attrValue,i,self.curArtId)
        --item:SetColor(255,0,42)
    end
end



function ArtifactEnchantPanel:InitModel()
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