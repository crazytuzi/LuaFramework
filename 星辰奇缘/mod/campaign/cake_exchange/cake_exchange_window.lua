-- 作者:jia
-- 5/4/2017 2:35:48 PM
-- 功能:周年庆兑换活动窗口

CakeExchangeWindow = CakeExchangeWindow or BaseClass(BaseWindow)
function CakeExchangeWindow:__init(model)
    self.model = model
    self.resList = {
        { file = AssetConfig.cakeexchangewindow, type = AssetType.Main }
         ,{file = AssetConfig.playkillbgcycle, type = AssetType.Dep}
    }
    self.windowId = WindowConfig.WinID.cakeexchangwindow
    -- self.OnOpenEvent:Add(function() self:OnOpen() end)
    -- self.OnHideEvent:Add(function() self:OnHide() end)
    self.RewardItemList = { }
    self.hasInit = false
    self.dataUpdateFun =
    function()
        self:UpdateData()
    end
    self.pointUpdateFun =
    function()
        self:UpdatPoint()
    end
    self:InitHandler()
end

function CakeExchangeWindow:__delete()
    self:RemoveHandler()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
    if self.RewardItemList ~= nil then
        for _, item in pairs(self.RewardItemList) do
            item:DeleteMe()
        end
        self.RewardItemList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function CakeExchangeWindow:OnHide()

end

function CakeExchangeWindow:OnOpen()

end

function CakeExchangeWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.cakeexchangewindow))
    self.gameObject.name = "CakeExchangeWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform
    self.Panel = self.transform:Find("Panel")
    self.Main = self.transform:Find("Main")
    local btn_close = self.transform:Find("Main/Close"):GetComponent(Button)
    btn_close.onClick:AddListener( function()
        self.model:CloseWindow()
    end )
    self.TxtCurPoint = self.transform:Find("Main/Top/ImgCurPoint/TxtCurPoint"):GetComponent(Text)
    self.transform:Find("Main/Top/ImgCurPoint/TxtCurPoint"):GetComponent(RectTransform).sizeDelta = Vector2(63,30)
    self.transform:Find("Main/Top/ImgCurPoint/TxtCurPoint"):GetComponent(RectTransform).localPosition = Vector2(12,-34)

    self.BtnGetPoint = self.transform:Find("Main/Top/BtnGetPoint"):GetComponent(Button)
    self.BtnGetPoint.onClick:AddListener(
    function()
        self:GetMorePoint()
    end )

    local sysid = ValentineManager.Instance.menuId.CakeExchange
    local beginTimeData = DataCampaign.data_list[sysid].cli_start_time[1]
    local endTimeData = DataCampaign.data_list[sysid].cli_end_time[1]
    local timeStr = string.format(TI18N("%s年%s月%s日"), beginTimeData[1], beginTimeData[2], beginTimeData[3])
    timeStr = timeStr .. "~" .. string.format(TI18N("%s年%s月%s日"), endTimeData[1], endTimeData[2], endTimeData[3])

    self.TxtDesc = self.transform:Find("Main/Top/TxtDesc"):GetComponent(Text)
    self.MsgTalk = MsgItemExt.New(self.TxtDesc, 340)
    self.MsgTalk:SetData(string.format(TI18N("1、{assets_2,%s}可在周年庆活动中获得\n2、前面道具兑换后，将开启下一神秘道具\n<color='#df3435'>注：兑换时间为5月11日~5月18日</color>"), 90039))
    self.ItemMaskCon = self.transform:Find("Main/Bottom/ItemMaskCon")
    self.ScrollLayer = self.transform:Find("Main/Bottom/ItemMaskCon/ScrollLayer")
    self.ItemCon = self.transform:Find("Main/Bottom/ItemMaskCon/ScrollLayer/ItemCon")
    self.BaseItem = self.transform:Find("Main/Bottom/ItemMaskCon/ScrollLayer/ItemCon/RewardItem").gameObject
    self.BaseItem.transform:Find("Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.playkillbgcycle, "PlayKillBgCycle")

    self.ScrollLayer:GetComponent(ScrollRect).onValueChanged:AddListener( function() self:OnValueChanged() end)
    self.ImgPointIcon = self.transform:Find("Main/Top/ImgCurPoint/ImgPoint"):GetComponent(Image)

    self.imgLoader = SingleIconLoader.New(self.ImgPointIcon.gameObject)
    self.imgLoader:SetSprite(SingleIconType.Item, KvData.assets.cake_exchange)

    self.hasInit = true
    self:UpdateData()
end

function CakeExchangeWindow:GetMorePoint()
    local base_data = DataItem.data_get[KvData.assets.cake_exchange]
    local info = { itemData = base_data, gameObject = self.BtnGetPoint.gameObject }
    TipsManager.Instance:ShowItem(info)
end

function CakeExchangeWindow:UpdateData()
    if not self.hasInit then
        return
    end
    local tmpList2 = DataCampExchange.data_camp_exchange_reward
    local tmpList = { }
    for _, tmp in pairs(tmpList2) do
        if self:CheckItemsByCondition(tmp) then
            tmpList[tmp.id] = tmp
        end
    end
    local index = 1;
    for id, tmp in pairs(tmpList) do
        local item = self.RewardItemList[index]
        if item == nil then
            item = CakeExchangeRewardItem.New(self.BaseItem, index)
            table.insert(self.RewardItemList, item)
        end
        item:SetData(tmp)
        item.gameObject:SetActive(true)
        if not CakeExchangeManager.Instance:CheckExchangeIsOpen(tmp) then
            break
        end
        index = index + 1
    end
    local newW = 215 * index - 9
    local rect = self.ItemCon.transform:GetComponent(RectTransform)
    rect.sizeDelta = Vector2(newW, 0)
    self:UpdatPoint()
    self:OnValueChanged()
end

function CakeExchangeWindow:UpdatPoint()
    self.TxtCurPoint.text = RoleManager.Instance.RoleData:GetMyAssetById(KvData.assets.cake_exchange)
end

function CakeExchangeWindow:InitHandler()
    EventMgr.Instance:AddListener(event_name.cake_exchange_data_update, self.dataUpdateFun)
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.pointUpdateFun)
end

function CakeExchangeWindow:RemoveHandler()
    EventMgr.Instance:RemoveListener(event_name.cake_exchange_data_update, self.dataUpdateFun)
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.pointUpdateFun)
end

function CakeExchangeWindow:CheckItemsByCondition(tmpdata)
    local roleData = RoleManager.Instance.RoleData
    if (tmpdata.sex == roleData.sex or tmpdata.sex == 2)
        and(tmpdata.classes == roleData.classes or tmpdata.classes == 0)
        and(tmpdata.min_lev <= roleData.lev or tmpdata.min_lev == 0)
        and(tmpdata.max_lev >= roleData.lev or tmpdata.min_maxv == 0)
        and(tmpdata.min_lev_break <= roleData.lev_break_times or tmpdata.min_lev_break == 0)
        and(tmpdata.max_lev_break >= roleData.lev_break_times or tmpdata.max_lev_break == 0) then
        return true
    end
    return false
end

function CakeExchangeWindow:OnValueChanged()
    local containerX = self.ItemCon.anchoredPosition.x
    for index, item in ipairs(self.RewardItemList) do
        local bool = false
        local itemX = item.transform.anchoredPosition.x
        bool = containerX + itemX >= -74 and containerX + itemX <= 584
        item:ShowEffect(bool)
    end
end