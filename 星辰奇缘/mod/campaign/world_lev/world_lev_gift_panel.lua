-- 作者:jia
-- 6/2/2017 3:19:42 PM
-- 功能:世界等级活动礼包界面

WorldLevGiftPanel = WorldLevGiftPanel or BaseClass(BasePanel)
function WorldLevGiftPanel:__init(parent,campaignType)
    self.parent = parent
    self.campaignType = campaignType
    self.resList = {
        { file = AssetConfig.worldlevgiftpanel, type = AssetType.Main }
        ,{ file = AssetConfig.may_textures, type = AssetType.Dep }
        ,{ file = AssetConfig.dailyicon, type = AssetType.Dep }
        ,{ file = AssetConfig.worldlevgiftbg, type = AssetType.Dep }
        ,{ file = AssetConfig.textures_campaign, type = AssetType.Dep }
        ,{ file = string.format(AssetConfig.effect, 20389), type = AssetType.Main }
        , {file = AssetConfig.worldlevgiftitem1, type = AssetType.Dep}
        , {file = AssetConfig.worldlevgiftitem2, type = AssetType.Dep}
        , {file = AssetConfig.worldlevgiftitem3, type = AssetType.Dep}
        , {file = AssetConfig.worldlevitembg1, type = AssetType.Dep}
        , {file = AssetConfig.worldlevitembg2, type = AssetType.Dep}
        , {file = AssetConfig.worldlevitembg3, type = AssetType.Dep}
    }
    self.OnOpenEvent:Add( function() self:OnOpen() end)
    self.OnHideEvent:Add( function() self:OnHide() end)
    self.hasInit = false
    self.campaignData = nil
    self.tmpData = nil
    self.updateListner =
    function()
        self:UpdateData()
    end
    self.itemList = { }
end

function WorldLevGiftPanel:__delete()
    self.OnHideEvent:Fire()
    if self.refreshTimer ~= nil then
        LuaTimer.Delete(self.refreshTimer)
        self.refreshTimer = nil
    end
    if self.itemList ~= nil then
        for _, item in pairs(self.itemList) do
            item:DeleteMe()
            item = nil
        end
        self.itemList = nil
    end
    self:AssetClearAll()
end

function WorldLevGiftPanel:OnHide()
    self:RemoveHandler()
end

function WorldLevGiftPanel:OnOpen()
    self:InitHandler()
    self:UpdateData()
end

function WorldLevGiftPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end


function WorldLevGiftPanel:InitHandler()
    EventMgr.Instance:AddListener(event_name.campaign_change, self.updateListner)
end

function WorldLevGiftPanel:RemoveHandler()
    EventMgr.Instance:RemoveListener(event_name.campaign_change, self.updateListner)
end

function WorldLevGiftPanel:UpdateData()
    self.campaignData = CampaignManager.Instance.campaignTree[CampaignEumn.Type.WorldLev][self.campaignType]
    if self.campaignData ~= nil then
        local showIndex = 0;
        local index = 1;
        for _, subData in ipairs(self.campaignData.sub) do
            local base_id = subData.id;
            local base_data = DataCampaign.data_list[base_id]
            if subData.status ~= CampaignEumn.Status.Accepted
                or(subData.status == CampaignEumn.Status.Accepted and tonumber(base_data.conds) == 3)
            then
                self.tmpData = base_data
                local item = self.itemList[base_data.group_index];
                if item == nil then
                    item = WorldLevGiftItem.New(self.Cloner, base_data.group_index)
                    self.itemList[base_data.group_index] = item
                end
                item:SetData(base_data,subData.status)
                item.ImgBg.sprite = self.assetWrapper:GetSprite(AssetConfig["worldlevitembg" .. base_data.effect_id], "worldlevitembg" .. base_data.effect_id)
                item.ImgLignt.sprite = self.assetWrapper:GetSprite(AssetConfig["worldlevgiftitem"..base_data.effect_id], "worldlevitemlight" .. base_data.effect_id) --self.assetWrapper:GetSprite(AssetConfig.textures_campaign, "worldlevitemlight" .. base_data.effect_id)
                item.ImgIcon1.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[base_data.loss_items[1][1]])
                item.ImgIcon2.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[base_data.loss_items[1][1]])
                if WorldLevManager.Instance.GiftRefreshIndex == base_data.group_index and subData.status ~= CampaignEumn.Status.Accepted then
                    showIndex = base_data.group_index
                end
                index = index + 1
            end
        end
        if showIndex > 0 then
            local showItem = self.itemList[showIndex];
            if self.effect20389 == nil then
                self.effect20389 = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20389)))
            end
            self.effect20389.transform:SetParent(showItem.transform)
            self.effect20389.transform.localRotation = Quaternion.identity
            Utils.ChangeLayersRecursively(self.effect20389.transform, "UI")
            self.effect20389.transform.localScale = Vector3(1, 1, 1)
            self.effect20389.transform.localPosition = Vector3(75, 65, -400)
            self.effect20389.gameObject:SetActive(true)
            self.refreshTimer = LuaTimer.Add(1000, function()
                if self.refreshTimer ~= nil then
                    LuaTimer.Delete(self.refreshTimer)
                    self.refreshTimer = nil
                end
                self.effect20389.gameObject:SetActive(false)
            end )
        end
         WorldLevManager.Instance.GiftRefreshIndex = 0
        self.Container.sizeDelta = Vector2(170 * index - 179, 0)
        self:UpdateTime()
    end
end


function WorldLevGiftPanel:UpdateTime()
    if self.tmpData == nil then
        return
    end
    local openTime = CampaignManager.Instance.open_srv_time;
    local openDay = self.tmpData.cli_start_time[1][2]
    local openSce = self.tmpData.cli_start_time[1][3]

    local endDay = self.tmpData.cli_end_time[1][2]
    local endSce = self.tmpData.cli_end_time[1][3]

    local beginTime = openDay * 24 * 60 * 60 + openSce + openTime
    local endTime = endDay * 24 * 60 * 60 + endSce + openTime

    local year1 = os.date("%Y", beginTime)
    local month1 = os.date("%m", beginTime)
    local day1 = os.date("%d", beginTime)

    local year2 = os.date("%Y", endTime)
    local month2 = os.date("%m", endTime)
    local day2 = os.date("%d", endTime)
    self.TxtTime.text = string.format(TI18N("活动时间：%s年%s月%s日~%s年%s月%s日"), year1, month1, day1, year2, month2, day2)
end

function WorldLevGiftPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldlevgiftpanel))
    self.gameObject.name = "WorldLevGiftPanel"

    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.BigBg = self.transform:Find("BigBg/BigBg")
    local bigbg = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldlevgiftbg));
    UIUtils.AddBigbg(self.BigBg, bigbg)
    self.ImgTitle = self.transform:Find("TitleArea/Title/Icon"):GetComponent(Image)
    self.TxtTitle = self.transform:Find("TitleArea/Title/Text"):GetComponent(Text)

    self.TxtTime = self.transform:Find("TitleArea/Time"):GetComponent(Text)
    self.TxtDesc = self.transform:Find("TitleArea/Desc"):GetComponent(Text)

    self.Container = self.transform:Find("ItemArea/ScrollLayer/Container")
    self.Cloner = self.transform:Find("ItemArea/ScrollLayer/Container/Cloner").gameObject
    self.Cloner:SetActive(false)
    self.TxtTime = self.transform:Find("TitleArea/Time"):GetComponent(Text)
end