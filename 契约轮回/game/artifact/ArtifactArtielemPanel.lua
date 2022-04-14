---
--- Created by  Administrator
--- DateTime: 2020/6/22 15:11
---
ArtifactArtielemPanel = ArtifactArtielemPanel or class("ArtifactArtielemPanel", BaseItem)
local this = ArtifactArtielemPanel

function ArtifactArtielemPanel:ctor(parent_node, parent_panel)
    self.abName = "artifact"
    self.assetName = "ArtifactArtielemPanel"
    self.layer = "UI"
    self.model = ArtifactModel:GetInstance()
    self.parentPanel = parent_panel
    self.events = {}
    self.artielems = {}
    self.attrs = {}
    --self.pageItems = {}
    ArtifactArtielemPanel.super.Load(self)
end

function ArtifactArtielemPanel:dctor()
    self.model:RemoveTabListener(self.events)
    --if not table.isempty(self.pageItems) then
    --    for i, v in pairs(self.pageItems) do
    --        v:destroy()
    --    end
    --    self.pageItems = nil
    --end

    if not table.isempty(self.artielems) then
        for i, v in pairs(self.artielems) do
            v:destroy()
        end
        self.artielems = {}
    end

    if not table.isempty(self.attrs) then
        for i, v in pairs(self.attrs) do
            v:destroy()
        end
        self.attrs = {}
    end
    if self.red then
        self.red:destroy()
        self.red = nil
    end
end

function ArtifactArtielemPanel:LoadCallBack()
    self.nodes = {
        "artielemParent/a_5","artielemParent/a_4","ArtifactArtielemItem","ArtifactAttrItem","artielemParent/a_3",
        "attrObj/iconParent","artielemParent/a_1","attrObj/attrItemParent","attrObj/iconDes","attrObj/upLvBtn",
        "attrObj/iconName","attrObj/upLvBtn/upLvBtnText","attrObj/iconNums","artielemParent/a_2","ArtifactPageItem",
        "leftObj/ScrollView/Viewport/Content","attrObj/iconImg","attrObj","textObj/stText","attrObj/max",
    }
    self:GetChildren(self.nodes)
    self.iconDes = GetText(self.iconDes)
    self.iconName = GetText(self.iconName)
    self.upLvBtnText = GetText(self.upLvBtnText)
    self.iconNums = GetText(self.iconNums)
    self.iconImg = GetImage(self.iconImg)
    self.stText = GetText(self.stText)
    self:InitUI()
    self:AddEvent()
    self:InitArtielem();
    SetAlignType(self.attrObj.transform, bit.bor(AlignType.Right, AlignType.Null))
    if self.is_need_setData then
        self:SetData(self.selectType)
    end
    --self.effect = UIEffect(self["a_"..1],46001,false, self.layer)
    ----self.effect:SetConfig({useStencil = true,scale = 0.8,stencilId = self.stencil_id, stencilType = 3})
    --SetVisible(self.effect, false)
end

function ArtifactArtielemPanel:SetData(selectType)
    self.selectType = selectType
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    self.stText.text = string.format("All elements reach lv.%s to unlock the corresponding divine",ChineseNumber(self.model:GetLockLv(self.selectType)))
    --self:UpdateRedPoint()
    --self:ArtielemItemClick(1)
end


function ArtifactArtielemPanel:InitUI()
    --self:InitPageItems()

end

function ArtifactArtielemPanel:AddEvent()
    local function call_back()
        if not self.selectId then
            Notify.ShowText(ArtifactModel.desTab.selectTex)
            return
        end
        --logError("type:",self.selectType," id:",self.selectId)

        ArtifactController:GetInstance():RequstArtielemUpGradeInfo(self.selectType,self.selectId)
    end
    AddClickEvent(self.upLvBtn.gameObject,call_back)
  --  self.events[#self.events + 1] = self.model:AddListener(ArtifactEvent.PageItemClick, handler(self, self.PageItemClick))
    self.events[#self.events + 1] = self.model:AddListener(ArtifactEvent.ArtielemItemClick, handler(self, self.ArtielemItemClick))
    self.events[#self.events + 1] = self.model:AddListener(ArtifactEvent.ArtielemListInfo, handler(self, self.ArtielemListInfo))
    self.events[#self.events + 1] = self.model:AddListener(ArtifactEvent.ArtielemUpGradeInfo, handler(self, self.ArtielemUpGradeInfo))
    self.events[#self.events + 1] = self.model:AddListener(ArtifactEvent.UpdateRedPoint, handler(self, self.UpdateRedPoint))
    self:ArtielemListInfo()
end

function ArtifactArtielemPanel:UpdateRedPoint()
    if not self.red then
        self.red = RedDot(self.upLvBtn.transform, nil, RedDot.RedDotType.Nor)
        self.red:SetPosition(63, 16)
    end
    if self.selectType and self.selectId then
        self.red:SetRedDotParam(self.model.typeRedPoints[self.selectType][self.selectId] or false)
    end
end



function ArtifactArtielemPanel:InitArtielem()
    for i = 1, 5 do
        local item = self.artielems[i]
        if not item then
            item = ArtifactArtielemItem(self.ArtifactArtielemItem.gameObject,self["a_"..i],"UI")
            self.artielems[i] = item;
        end
        item:SetData(i,self.selectType);
    end
    self:ArtielemItemClick(1)
end

function ArtifactArtielemPanel:ArtielemItemClick(data)
    for i, v in pairs(self.artielems) do
        if data == v.data then
            v:SetSelect(true)
            self.selectId = data
            self:UpdateIconInfo()
            self:UpdateRedPoint()
        else
            v:SetSelect(false)
        end
    end
end

function ArtifactArtielemPanel:UpdateRightInfo()
    local tab = self.model:GetArtielemTab(self.selectType)
    local cfg = Config.db_artifact_element
    local arrtTab = {}
    if table.isempty(tab) then
        for i = 1, 5 do
            local key = self.selectType.."@"..i.."@"..0
            local attrTab = String2Table(cfg[key].attrs)
            for i = 1, #attrTab do
                local attrId = attrTab[i][1]
                local attrValue = attrTab[i][2]
                if not arrtTab[attrId] then
                    arrtTab[attrId] = attrValue
                else
                    arrtTab[attrId] = arrtTab[attrId] + attrValue
                end
            end
        end
    else
        for i = 1, 5 do
            local info = self.model:GetArtielemInfo(self.selectType,i)
            local key = self.selectType.."@"..i.."@"..0
            if info then
                local level = info.level
                if level > 500  then
                    level = 500
                end
                key = self.selectType.."@"..i.."@"..level
               --logError(info.level)
            end

            local attrTab = String2Table(cfg[key].attrs)
            for i = 1, #attrTab do
                local attrId = attrTab[i][1]
                local attrValue = attrTab[i][2]
                if not arrtTab[attrId] then
                    arrtTab[attrId] = attrValue
                else
                    arrtTab[attrId] = arrtTab[attrId] + attrValue
                end
            end
          --  logError(Table2String(cfg[key].attrs))
        end
       -- logError(Table2String(arrtTab))
    end
   -- logError(Table2String(arrtTab))
    local index = 0
    for i, v in table.pairsByKey(arrtTab) do
        index = index + 1
        local item = self.attrs[index]
        if not item then
            item = ArtifactAttrItem(self.ArtifactAttrItem.gameObject,self.attrItemParent,"UI")
            self.attrs[index] = item

        else
            item:SetVisible(true)
        end
        item:SetData(i,v)
    end
    for i = #arrtTab + 1,#self.attrs do
        local buyItem = self.attrs[i]
        buyItem:SetVisible(false)
    end
    self:UpdateIconInfo()
end

function ArtifactArtielemPanel:UpdateIconInfo()
    local info = self.model:GetArtielemInfo(self.selectType,self.selectId)
    local key = self.selectType.."@"..self.selectId.."@"..1
    if info then
        key = self.selectType.."@"..self.selectId.."@"..info.level + 1
        local num = 10 - (info.level%10) - 1
        if num == 0 then
            self.iconDes.text = "<color=#00FCFF>Breakthrough</color>"
        else
            self.iconDes.text = string.format("Lv.<color=#00fcff>%s</color> can be breakthrough",num)
        end

    else
        self.iconDes.text = string.format("Lv.<color=#00fcff>%s</color> can be breakthrough",9)
    end
    local cfg = Config.db_artifact_element[key]
    if not cfg then
        SetVisible(self.iconParent,false)
        SetVisible(self.iconNums,false)
        SetVisible(self.iconImg,false)
        SetVisible(self.upLvBtn,false)
        SetVisible(self.max,true)
        return
    end
    SetVisible(self.upLvBtn,true)
    SetVisible(self.max,false)
    local costTab = String2Table(cfg.cost)
    if not table.isempty(costTab) then
        local id = costTab[1][1]
        local num = costTab[1][2]
        local itemCfg = Config.db_item[id]
        local mNum = BagModel:GetInstance():GetItemNumByItemID(id) or 0
        self.iconName.text = itemCfg.name
        local color = "00FCFF"
        if mNum < num then
            color = "FF1C00"
        end
        self.iconNums.text = string.format("<color=#%s>%s/%s</color>",color,mNum,num)
        self.upLvBtnText.text = "Upgrade"
        SetVisible(self.iconParent,true)
        SetVisible(self.iconNums,true)
        SetLocalPositionY(self.upLvBtn,-243)
        SetVisible(self.iconImg,true)
        GoodIconUtil:CreateIcon(self, self.iconImg, id, true)
    else
       -- SetVisible(self.iconName,false)
        SetVisible(self.iconParent,false)
        SetVisible(self.iconNums,false)
        SetVisible(self.iconImg,false)
        self.upLvBtnText.text = "Breakthrough"
        SetLocalPositionY(self.upLvBtn,-163)
    end


end


function ArtifactArtielemPanel:UpdateUpGradeInfo(type,id)
    for i, v in pairs(self.artielems) do
        if id == v.data then
            v:UpdateInfo(id,type)
        end
    end
    self:UpdateRightInfo()
end

function ArtifactArtielemPanel:ArtielemListInfo(data)

    self:InitArtielem();
    self:UpdateRightInfo()
end

function ArtifactArtielemPanel:ArtielemUpGradeInfo(data)
    self:UpdateUpGradeInfo(data.arti_type,data.elem_id)
   -- logError(self:CheckLock())
    if self:CheckLock() then
        Notify.ShowText("Divine unlocked")
    end
    
end

function ArtifactArtielemPanel:CheckLock()
    local cfg = Config.db_artifact_unlock
    for i, v in pairs(cfg) do
        if v.type == self.selectType then
            local tab = String2Table(v.unlock)
            local index = 0
            for i = 1, #tab do
                local id = tab[i][1]
                local lv = tab[i][2]
                if self.model:GetArtielemLv(v.type,id) == lv then
                    --return false
                    index = index + 1
                end
            end
            if index == #tab then
                return true
            end
            break
        end
    end
    return false

end

function ArtifactArtielemPanel:IsMax()
    
end




