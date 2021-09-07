--2016/10/22
--zzl
--万圣节，驱除邪灵
NewYearDescPanel = NewYearDescPanel or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color

function NewYearDescPanel:__init(model, parent)
    self.parent = parent
    self.model = model
    self.name = "NewYearDescPanel"
    self.resList = {
        {file = AssetConfig.halloweenKillEvil, type = AssetType.Main}
        , {file = AssetConfig.new_year_fight_bg, type = AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false
    self.slotlist = {}
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function NewYearDescPanel:__delete()
    self:OnHide()
    for k,v in pairs(self.slotlist) do
        v:DeleteMe()
    end
    self.slotlist = {}
    if self.gameObject ~= nil then
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function NewYearDescPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.halloweenKillEvil))
    self.gameObject.name = "NewYearDescPanel"
    UIUtils.AddUIChild(self.parent.rightContainer.transform, self.gameObject)

    self.transform = self.gameObject.transform
    UIUtils.AddBigbg(self.transform:Find("HalloweenBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.new_year_fight_bg)))

    local cfgData = DataCampaign.data_list[389]
    self.txtTime = self.transform:Find("TxtTime"):GetComponent(Text)
    self.txtTime.text = string.format(TI18N("%s年%s月%s日-%s月%s日"), cfgData.cli_start_time[1][1], cfgData.cli_start_time[1][2], cfgData.cli_start_time[1][3], cfgData.cli_end_time[1][2], cfgData.cli_end_time[1][3])

    self.descTxt = self.transform:Find("Mask"):Find("Text"):GetComponent(Text)
    local msgTxt = MsgItemExt.New(self.descTxt, 500, 16, 21)
    msgTxt:SetData(cfgData.cond_desc)

    -- 按钮功能绑定
    local btn = self.transform:FindChild("OkButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:OnOkButton() end)

    -- 创建物品solt
    self.container = self.transform:FindChild("RewardPanel/Mask/Container").gameObject
    local itemObject = self.container.transform:FindChild("Item").gameObject
    itemObject:SetActive(false)
    for i=1, #cfgData.rewardgift do
        local item = GameObject.Instantiate(itemObject)
        UIUtils.AddUIChild(self.container, item.gameObject)
        local slot = ItemSlot.New()
        UIUtils.AddUIChild(item, slot.gameObject)
        table.insert(self.slotlist, slot)
        local itembase = BackpackManager.Instance:GetItemBase(cfgData.rewardgift[i][1])
        local itemData = ItemData.New()
        itemData:SetBase(itembase)
        slot:SetAll(itemData)
    end
    -----------------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function NewYearDescPanel:OnShow()

end

function NewYearDescPanel:OnHide()
end

function NewYearDescPanel:update()

end

function NewYearDescPanel:OnOkButton()
    MatchManager.Instance:Require18301(1000)
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.newyearwindow)
end