--2016/10/22
--zzl
--万圣节，驱除邪灵
HalloweenKillEvilPanel = HalloweenKillEvilPanel or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color

function HalloweenKillEvilPanel:__init(model,parent)
    self.parent = parent
    self.model = HalloweenManager.Instance.model
    self.name = "HalloweenKillEvilPanel"
    self.resList = {
        {file = AssetConfig.halloweenKillEvil, type = AssetType.Main}
        -- , {file = AssetConfig.halloweenKillEvilBg, type = AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false
    self.campId = nil

    self.slotList = {}
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function HalloweenKillEvilPanel:__delete()
    self:OnHide()
    for k,v in pairs(self.slotList) do
        v:DeleteMe()
    end
    self:AssetClearAll()
end

function HalloweenKillEvilPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.halloweenKillEvil))
    self.gameObject.name = "HalloweenKillEvilPanel"
    UIUtils.AddUIChild(self.parent,self.gameObject)
    self.transform = self.gameObject.transform
    UIUtils.AddBigbg(self.transform:Find("HalloweenBg"), GameObject.Instantiate(self:GetPrefab(self.bg)))

    local cfgData = DataCampaign.data_list[340]
    self.txtTime = self.transform:Find("TxtTime"):GetComponent(Text)
    self.txtTime.text = string.format(TI18N("%s月%s日-%s月%s日"), cfgData.cli_start_time[1][2], cfgData.cli_start_time[1][3], cfgData.cli_end_time[1][2], cfgData.cli_end_time[1][3])

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

        table.insert(self.slotList, slot)
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

function HalloweenKillEvilPanel:OnShow()

end

function HalloweenKillEvilPanel:OnHide()
end

function HalloweenKillEvilPanel:update()

end

function HalloweenKillEvilPanel:OnOkButton()
    local hour = tonumber(os.date("%H", BaseUtils.BASE_TIME))
    if hour >= 9 and hour < 23 then
        local key = BaseUtils.get_unique_npcid(74, 1)
        SceneManager.Instance.sceneElementsModel:Self_AutoPath(10001, key, nil, nil, true)
        self.model:CloseMainUI()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("活动开启时段为<color='#ffff00'>09:00-23:00</color>，请准时参加哦！{face_1,7}"))
        return
    end
end