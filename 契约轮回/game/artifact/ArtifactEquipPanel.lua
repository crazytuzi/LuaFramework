---
--- Created by  Administrator
--- DateTime: 2020/6/22 15:13
---
ArtifactEquipPanel = ArtifactEquipPanel or class("ArtifactEquipPanel", BaseItem)
local this = ArtifactEquipPanel

function ArtifactEquipPanel:ctor(parent_node, parent_panel)
    self.abName = "artifact"
    self.assetName = "ArtifactEquipPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.gevents = {}
    self.bagItems = {}
    self.model = ArtifactModel:GetInstance()
    self.attrs = {}
    self.attrs1 = {}
    self.attrs2 = {}
    self.attrs3 = {}
    self.attrs4 = {}
    ArtifactEquipPanel.super.Load(self)
end

function ArtifactEquipPanel:dctor()
    self.model:RemoveTabListener(self.events)
    GlobalEvent:RemoveTabListener(self.gevents)
    if not table.isempty(self.bagItems) then
        for i, v in pairs(self.bagItems) do
            v:destroy()
        end
        self.bagItems = {}
    end

    if not table.isempty(self.attrs1) then
        for i, v in pairs(self.attrs1) do
            v:destroy()
        end
        self.attrs1 = {}
    end
    if not table.isempty(self.attrs2) then
        for i, v in pairs(self.attrs2) do
            v:destroy()
        end
        self.attrs2 = {}
    end
    if not table.isempty(self.attrs3) then
        for i, v in pairs(self.attrs3) do
            v:destroy()
        end
        self.attrs3 = {}
    end
    if not table.isempty(self.attrs4) then
        for i, v in pairs(self.attrs4) do
            v:destroy()
        end
        self.attrs4 = {}
    end
end

function ArtifactEquipPanel:LoadCallBack()
    self.nodes = {
        "LeftMenu","attrObj/bagIcon","ArtifactEquipSlotItem","equipObj/slot_2","equipObj/slot_3","equipObj/slot_1",
        "attrObj/noEquip","attrObj","ArtifactAttrItem","attrObj/attrItemParent","attrObj/comIcon",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
    if self.is_need_setData then
        self:SetData(self.curArtId,self.curType)
    end
    SetAlignType(self.attrObj.transform, bit.bor(AlignType.Right, AlignType.Null))
   -- ArtifactController:GetInstance():RequstArtifactListInfo()
end

function ArtifactEquipPanel:InitUI()

end

function ArtifactEquipPanel:SetData(curArtId,curType)
    self.curArtId = curArtId
    self.curType = curType
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
   -- if  table.isempty(self.bagItems) then
        self:InitEquipItems()
        self:UpdateAttrInfo()
   -- end
    --logError(self.curArtId)
end

function ArtifactEquipPanel:InitEquipItems()
    for i = 1, 3 do
        local item = self.bagItems[i]
        if not item then
            item = ArtifactEquipSlotItem(self.ArtifactEquipSlotItem.gameObject,self["slot_"..i],"UI")
            self.bagItems[i] = item
        end
        item:SetData(i,self.curArtId,self.curType);
    end
end

function ArtifactEquipPanel:UpdateAttrInfo()
    local tab = self.model:GetPutOnEquipIds(self.curArtId)
    --logError(Table2String(tab))
    local arrTab1 = {}
    local arrTab2 = {}
    local arrTab3 = {}
    local arrTab4 = {}
    if table.isempty(tab) then
        SetVisible(self.noEquip,true)
    else
        SetVisible(self.noEquip,false)

        for i = 1, #tab do
            local id = tab[i]
            local cfg = Config.db_equip[id]
            local baseTab = String2Table(cfg.base)
            local rare1Tab = String2Table(cfg.rare1)
            local rare2Tab = String2Table(cfg.rare2)
            local rare3Tab = String2Table(cfg.rare3)
            if not table.isempty(baseTab) then
                for i = 1, #baseTab do
                    local id = baseTab[i][1]
                    local value = baseTab[i][2]
                    if not arrTab1[id] then
                        arrTab1[id] = value
                    else
                        arrTab1[id] = arrTab1[id] + value
                    end
                end
            end

            if not table.isempty(rare1Tab) then
                for i = 1, #rare1Tab do
                    local id = rare1Tab[i][1]
                    local value = rare1Tab[i][2]
                    if not arrTab2[id] then
                        arrTab2[id] = value
                    else
                        arrTab2[id] = arrTab2[id] + value
                    end
                end
            end
            if not table.isempty(rare2Tab) then
                for i = 1, #rare2Tab do
                    local id = rare2Tab[i][1]
                    local value = rare2Tab[i][2]
                    if not arrTab2[id] then
                        arrTab3[id] = value
                    else
                        arrTab3[id] = arrTab3[id] + value
                    end
                end
            end
            if not table.isempty(rare3Tab) then
                for i = 1, #rare3Tab do
                    local id = rare3Tab[i][1]
                    local value = rare3Tab[i][2]
                    if not arrTab4[id] then
                        arrTab4[id] = value
                    else
                        arrTab4[id] = arrTab4[id] + value
                    end
                end
            end
            --logError(Table2String(arrTab1))
            --logError(Table2String(arrTab2))
            --logError(Table2String(arrTab3))
            --logError(Table2String(arrTab4))
        end
    end
    local index = 0
    for i, v in table.pairsByKey(arrTab1) do
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
    for i, v in table.pairsByKey(arrTab2) do
        index = index + 1
        local item = self.attrs[index]
        if not item then
            item = ArtifactAttrItem(self.ArtifactAttrItem.gameObject,self.attrItemParent,"UI")
            self.attrs[index] = item

        else
            item:SetVisible(true)
        end
        item:SetData(i,v)
        item:SetColor(44,193,255)
    end
    for i, v in table.pairsByKey(arrTab3) do
        index = index + 1
        local item = self.attrs[index]
        if not item then
            item = ArtifactAttrItem(self.ArtifactAttrItem.gameObject,self.attrItemParent,"UI")
            self.attrs[index] = item

        else
            item:SetVisible(true)
        end
        item:SetData(i,v)
        item:SetColor(204,66,255)
    end
    for i, v in table.pairsByKey(arrTab4) do
        index = index + 1
        local item = self.attrs[index]
        if not item then
            item = ArtifactAttrItem(self.ArtifactAttrItem.gameObject,self.attrItemParent,"UI")
            self.attrs[index] = item
        else
            item:SetVisible(true)
        end
        item:SetData(i,v)
        item:SetColor(228,99,40)
    end

    local len = table.nums(arrTab1) + table.nums(arrTab2) + table.nums(arrTab3) + table.nums(arrTab4)
    for i = len + 1,#self.attrs do
        local buyItem = self.attrs[i]
        buyItem:SetVisible(false)
    end


end

function ArtifactEquipPanel:AddEvent()
    local function call_back()
        if not self.model:GetArtiInfo(self.curArtId) then
            Notify.ShowText("The current divine locked")
            return
        end
        lua_panelMgr:GetPanelOrCreate(ArtifactBagPanel):Open(self.curArtId)
    end
    AddButtonEvent(self.bagIcon.gameObject,call_back)

    local function call_back()
        --lua_panelMgr:GetPanelOrCreate(ArtifactBagPanel):Open(self.curArtId)
        local opLv = Config.db_equip_combine_sec_type[401].open_level
        if RoleInfoModel:GetInstance():GetMainRoleLevel() >= opLv then
            OpenLink(170,1,4,401)
        else
            Notify.ShowText(string.format("Gear combine will be open at Lv.%s",opLv))
        end
    end
    AddButtonEvent(self.comIcon.gameObject,call_back)
    self.events[#self.events + 1] = self.model:AddListener(ArtifactEvent.ArtifactPutOnInfo, handler(self, self.ArtifactPutOnInfo))
    self.events[#self.events + 1] = self.model:AddListener(ArtifactEvent.ArtifactPutOffInfo, handler(self, self.ArtifactPutOnInfo))
end

function ArtifactEquipPanel:ArtifactPutOnInfo()
    self:UpdateAttrInfo()
end




