-- @author hze
-- @date #19/08/19#
-- @战令购买等级面板

WarOrderLevPanel = WarOrderLevPanel or BaseClass(BasePanel)

function WarOrderLevPanel:__init(model, parent)
    self.resList = {
        {file = AssetConfig.war_order_lev_panel, type = AssetType.Main},
        {file = AssetConfig.warordertextures, type = AssetType.Dep},
    }
    self.model = model
    self.parent = parent
    self.mgr = CampaignProtoManager.Instance


    self.itemList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self._update_load_listener = function() self:ReloadData() end
end

function WarOrderLevPanel:__delete()
    self.OnHideEvent:Fire()

    if self.itemList ~= nil then
        for i, item in ipairs(self.itemList) do
             if item.msgTxt ~= nil then 
                item.msgTxt:DeleteMe()
             end    
        end
    end

    self:AssetClearAll()
end

function WarOrderLevPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.war_order_lev_panel))
    self.gameObject.name = "WarOrderLevPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    local container = self.transform:Find("ScrollRect/Container")
    for i = 1, 4 do
        local tab = {}
        tab.transform = container:GetChild(i - 1)
        tab.levTxt = tab.transform:Find("LevText"):GetComponent(Text)
        tab.descTxt = tab.transform:Find("DescText"):GetComponent(Text)
        tab.btn = tab.transform:Find("Button"):GetComponent(Button)
        tab.btnTxt = tab.transform:Find("Button/Text"):GetComponent(Text)
        tab.msgTxt = MsgItemExt.New(tab.btnTxt, 101, 17, 28)
        tab.tagObj = tab.transform:Find("Tag").gameObject
        tab.tagTxt = tab.transform:Find("Tag/Text"):GetComponent(Text)
        self.itemList[i] = tab
    end
end

function WarOrderLevPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WarOrderLevPanel:OnOpen()
    self:RemoveListeners()
    self:AddListeners()

    if not self.openArgs then
        return
    end
    self.campId = self.openArgs
    -- print(self.campId)

    -- self:DealExtraEffect()
    self:ReloadData()
end

function WarOrderLevPanel:OnHide()
    self:RemoveListeners()
end

function WarOrderLevPanel:AddListeners()
    self.mgr.updateWarOrderEvent:AddListener(self._update_load_listener)
end

function WarOrderLevPanel:RemoveListeners()
    self.mgr.updateWarOrderEvent:RemoveListener(self._update_load_listener)
end

--更新界面数据
function WarOrderLevPanel:ReloadData()
    -- BaseUtils.dump(data,"WarOrderLevData---------------------------1111111111")
    local data = DataCampWarOrder.data_lev
    for i, v in ipairs(data) do
        local item = self.itemList[i]
        item.levTxt.text = v.up_lev .. TI18N("级")
        item.descTxt.text = string.format(TI18N("可升至%s级"), self.model.warOrderData.lev + v.up_lev)
        item.btn.onClick:RemoveAllListeners()
        item.btn.onClick:AddListener(function() self:OnClick(v.up_lev) end)
        item.msgTxt:SetData(string.format("%s{assets_2,%s}", v.cost[1][2], v.cost[1][1]))
        local c = v.discount / 10
        item.tagObj:SetActive(c ~= 10)
        item.tagTxt.text = c .. TI18N("折")
    end
end

--购买等级
function WarOrderLevPanel:OnClick(id)
    self.mgr:Send20488(id)
end




