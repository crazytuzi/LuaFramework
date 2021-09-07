-- @author ###
-- @date 2018年4月17日,星期二

ShouhuTransferListPanel = ShouhuTransferListPanel or BaseClass(BasePanel)

function ShouhuTransferListPanel:__init(model, parentWin, parent)
    self.model = model
    self.parentWin = parentWin
    self.parent = parent
    self.win = parentWin
    self.name = "ShouhuTransferListPanel"

    self.resList = {
        {file = AssetConfig.shouhu_transferlist_panel, type = AssetType.Main}
        ,{file = AssetConfig.shouhu_texture, type = AssetType.Dep}
        ,{file = AssetConfig.guard_head, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.ItemList = { }

    self.anotherShouhu = nil


end

function ShouhuTransferListPanel:__delete()
    self.OnHideEvent:Fire()

    self.ItemList = nil
    self.anotherShouhu = nil

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ShouhuTransferListPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shouhu_transferlist_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parentWin, self.gameObject)
    self.transform = t

    self.MainCon = self.transform:FindChild("MainCon")
    self.CloseBtn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    --self.parent:CloseShouhuList()
    self.CloseBtn.onClick:AddListener(function() self:Hiden() end)
    self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
    self.Container = self.MainCon:Find("FashionScrollRect/FashionContainer")
    self.item = self.Container:Find("Item")
    self.item.gameObject:SetActive(false)

    self.sureBtn = self.MainCon:Find("SureBtn"):GetComponent(Button)
    self.sureBtn.onClick:AddListener(function() self:ClickSureBtn() end)
    self.LuaBox = LuaBoxLayout.New(self.Container,{axis = BoxLayoutAxis.Y, cspacing = 0, border = 1})

end

function ShouhuTransferListPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ShouhuTransferListPanel:OnOpen()
    self:RemoveListeners()
    self.LuaBox:ReSet()
    local EnabledShouhuData = self.parent.has_recruit_enabled_list
    if EnabledShouhuData ~= nil then
        for i,v in pairs (EnabledShouhuData) do
            if self.ItemList[i] == nil then
                local tab = {}
                tab.item = ShouhuTransferItem.New(self, self.item.gameObject, i)
                self.ItemList[i] = tab
            end
            self.LuaBox:AddCell(self.ItemList[i].item.gameObject)
        end
    end
    self:SetData()
end

function ShouhuTransferListPanel:OnHide()
    self:RemoveListeners()
    if self.ItemList ~= nil then
        for i,v in pairs(self.ItemList) do
            if self.ItemList[i] ~= nil then
                GameObject.DestroyImmediate(self.ItemList[i].item.gameObject)
                self.ItemList[i] = nil
            end
        end
        self.ItemList = {}
    end
    self.anotherShouhu = nil

end

function ShouhuTransferListPanel:RemoveListeners()

end

function ShouhuTransferListPanel:SetData()
    local EnabledShouhuData = self.parent.has_recruit_enabled_list
    for i, v in pairs(EnabledShouhuData) do
        if v ~= nil and self.ItemList[i] ~= nil then
            self.ItemList[i].item:SetData(v)
        end
    end
end

function ShouhuTransferListPanel:ClickItem(index)
    local EnabledShouhuData = self.parent.has_recruit_enabled_list
    if self.ItemList ~= nil and EnabledShouhuData ~= nil then
        for i,v in pairs(EnabledShouhuData) do
            if i == index then
                self.anotherShouhu = v
                self.ItemList[i].item:ClickcallBack(true)
            else
                self.ItemList[i].item:ClickcallBack(false)
            end
        end
    end
end

function ShouhuTransferListPanel:ClickSureBtn()
    if self.anotherShouhu ~= nil then
        if self.parent.model:CheckIsPurpleShouhu(self.anotherShouhu) then
            if self.parent.model:CheckAllGemsBiggerOne(self.anotherShouhu) then
                --符合要求的守护
                local last_id = self.parent.currentShouhu.base_id
                self.parent.model.selectedTransferAnotherSH[last_id] = nil
                self.parent.model.selectedTransferAnotherSH[last_id] = self.anotherShouhu
                ShouhuManager.Instance:Send10922(last_id, self.anotherShouhu.base_id)
                self:Hiden()
                self.parent:SetAnotherData()
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("转换的守护<color='#ffff00'>宝石等级必须≥1级</color>{face_1,2}"))
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("<color='#ffff00'>紫色品阶</color>的守护才能转换哟{face_1,2}"))
        end
    else
        NoticeManager.Instance:FloatTipsByString("请选择需要转换的守护")
        return
    end
end


