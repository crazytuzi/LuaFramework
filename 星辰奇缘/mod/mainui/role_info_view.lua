-- 主界面 人物头像
RoleInfoView = RoleInfoView or BaseClass(BaseView)

local Vector3 = UnityEngine.Vector3
function RoleInfoView:__init()
    self.model = model
	self.resList = {
        {file = AssetConfig.roleinfoarea, type = AssetType.Main}
        , {file = AssetConfig.heads, type = AssetType.Dep}
        , {file = AssetConfig.normalbufficon, type = AssetType.Dep}
    }

    self.name = "RoleInfoView"

    self.originPos = Vector3.zero
    self.isShow = true

    self.gameObject = nil
    self.transform = nil

    ------------------------------------
	self.roleHeadImage = nil
	-- self.roleNameText = nil
	self.roleLevelText = nil
	-- self.rolePowerText = nil

	self.hpBar = nil
	self.mpBar = nil
    self.expBar = nil
	self.worldLev = nil
    self.showLevBreak = false

    ------------------------------------
    self._update = function()
    	self:update()
	end

    self.adaptListener = function() self:AdaptIPhoneX() end

	self:LoadAssetBundleBatch()
    self.isShowWorldLev = true
end

function RoleInfoView:ShowCanvas(bool)
    if self.gameObject == nil then
        return
    end
    if bool then
        self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    else
        self.gameObject.transform.localPosition = Vector3(0, -2000, 0)
    end
end

function RoleInfoView:__delete()
    EventMgr.Instance:RemoveListener(event_name.adapt_iphonex, self.adaptListener)

    if self.headSlot ~= nil then
        self.headSlot:DeleteMe()
        self.headSlot = nil
    end
    BaseUtils.CancelIPhoneXTween(self.transform)
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function RoleInfoView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.roleinfoarea))
    self.gameObject.name = "RoleInfoView"
    self.gameObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    local rect = self.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2(1, 1)
    rect.anchorMin = Vector2(0, 0)
    rect.localPosition = Vector3(0, 0, 1)
    rect.offsetMin = Vector2(0, 0)
    rect.offsetMax = Vector2(0, 0)
    rect.localScale = Vector3.one

    self.mainRect = rect
    self.transform = self.gameObject.transform

    self.gameObject.transform:SetAsFirstSibling()

	-----------------------------
	-- self.roleNameText = self.transform:FindChild ("Main/NameText"):GetComponent(Text)
    self.roleLevelText = self.transform:FindChild ("Main/LevelText"):GetComponent(Text)
    -- self.rolePowerText = self.transform:FindChild ("Main/PowerText"):GetComponent(Text)
    self.roleHeadImage = self.transform:FindChild ("Main/RoleHeadContainer/RoleImage"):GetComponent(Image)

    self.hpBar = self.transform:FindChild("Main/HPBar").gameObject
    self.mpBar = self.transform:FindChild("Main/MPBar").gameObject
    self.expBar = self.transform:FindChild("Main/ExpBar").gameObject

    self.transform:FindChild("Main"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.backpack, {1, 2}) end)

    self.buffPanel = self.transform:FindChild("BuffsArea").gameObject
    self.buffPanel:GetComponent(Button).onClick:AddListener(function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.buffpanel)
    end)
    self.buffIcon1 = self.buffPanel.transform:FindChild("buff1").gameObject
    self.buffIcon2 = self.buffPanel.transform:FindChild("buff2").gameObject
    self.buffIcon3 = self.buffPanel.transform:FindChild("buff3").gameObject
    self.buffIconImage1 = self.buffIcon1.transform:FindChild("Image"):GetComponent(Image)
    self.buffIconImage2 = self.buffIcon2.transform:FindChild("Image"):GetComponent(Image)
    self.buffIconImage3 = self.buffIcon3.transform:FindChild("Image"):GetComponent(Image)
    self.buffArrow = self.buffPanel.transform:FindChild("arrow").gameObject

    self.headSlot = HeadSlot.New()
    self.roleHeadImage.transform.anchoredPosition = Vector2(22.5, 5)
    self.roleHeadImage.transform.sizeDelta = Vector2(59, 59)
    self.headSlot:SetRectParent(self.roleHeadImage.transform)

    self.worldLev = self.transform:FindChild("WorldLev"):GetComponent(Image)
    self.worldLev.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnWorldLevClick() end)


    -----------------------------
    self:update()
    self:AdaptIPhoneX()

    EventMgr.Instance:AddListener(event_name.world_lev_change, function() self:update_world_lev() end)
    EventMgr.Instance:AddListener(event_name.role_level_change, function() self:update_info() self:update_world_lev() self:update_buff() end)
    EventMgr.Instance:AddListener(event_name.role_attr_change, function() self:update_info() end)
    EventMgr.Instance:AddListener(event_name.role_exp_change, function() self:update_info() end)
    EventMgr.Instance:AddListener(event_name.role_asset_change, function() self:update_buff() end)
    EventMgr.Instance:AddListener(event_name.buff_update, function() self:update_buff() end)
    EventMgr.Instance:AddListener(event_name.adapt_iphonex, self.adaptListener)

    -- 转职了
    EventMgr.Instance:AddListener(event_name.change_classes, function() self:update_head() end)

    -- self:AssetClearAll()
    self:ClearMainAsset()

    if BaseUtils.IsVerify then
        self.gameObject:SetActive(false)
    end
end

function RoleInfoView:SetWorldLevVisible(bo)
    if self.worldLev ~= nil then
        self.worldLev.gameObject:SetActive(bo)
    end
end

function RoleInfoView:OnWorldLevClick()
    if self.showLevBreak then
        local itemDataTemp = {}
        itemDataTemp.textList = RoleManager.Instance:WorldlevTips()
        itemDataTemp.btnText = TI18N("突破")
        itemDataTemp.callback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.levelbreakwindow) end
        TipsManager.Instance:ShowTextBtn({gameObject = self.worldLev.gameObject, itemData = itemDataTemp})
    else
        TipsManager.Instance:ShowText({gameObject = self.worldLev.gameObject, itemData = RoleManager.Instance:WorldlevTips()})
    end
end

function RoleInfoView:update()
    self:update_world_lev()
	self:update_info()
	self:update_head()
    self:update_buff()
end

function RoleInfoView:refresh()
    if self.gameObject ~= nil then
        self:update()
    end
end

function RoleInfoView:update_head()
    local data = RoleManager.Instance.RoleData
	-- self.roleHeadImage.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", data.classes, data.sex))
    self.roleHeadImage.enabled = false
    self.headSlot:HideSlotBg(true, 0)
    self.headSlot:SetAll(data, {isSmall = true, clickCallback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.backpack, {1, 2}) end})
    -- self.roleHeadImage:SetNativeSize()
    -- self.roleHeadImage.rectTransform.sizeDelta = Vector2(80, 80)
end

function RoleInfoView:update_info()
    local data = RoleManager.Instance.RoleData

    -- self.roleNameText.text = data.name
    self.roleLevelText.text = tostring(data.lev)
    -- self.rolePowerText.text = tostring(data.fc)

    local hpX = data.hp / data.hp_max
    if hpX > 1 then
        hpX = 1
    elseif hpX < 0 then
        hpX = 0
    end
    self.hpBar.transform.localScale = Vector3 (hpX, 1, 1)
    local mpX = data.mp / data.mp_max
    if mpX > 1 then
        mpX = 1
    elseif mpX < 0 then
        mpX = 0
    end
    self.mpBar.transform.localScale = Vector3 (mpX, 1, 1)
    local levup_data = DataLevup.data_levup[data.lev]
    if levup_data ~= nil then
        local exp_max = levup_data.exp
        local expX = data.exp / exp_max
        if expX > 1 then
            expX = 1
        elseif expX < 0 then
            expX = 0
        end
        self.expBar.transform.localScale = Vector3 (expX, 1, 1)
    else
        self.expBar.transform.localScale = Vector3 (1, 1, 1)
    end
end

function RoleInfoView:update_world_lev()
    RoleManager.Instance:WorldlevRatio()
    if RoleManager.Instance.RoleData.lev > 35 then
        if RoleManager.Instance.RoleData.lev >= 95 and RoleManager.Instance.world_lev >= 95 and RoleManager.Instance.RoleData.lev_break_times == 0 then
            self.worldLev.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "I18NWorldLev_Break")
            self.showLevBreak = true
        elseif RoleManager.Instance.exp_ratio_real > 1000 then
            self.worldLev.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "I18NWorldLev_Up")
        elseif RoleManager.Instance.exp_ratio_real == 1000 then
            self.worldLev.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "I18NWorldLev_Normal")
        elseif RoleManager.Instance.exp_ratio_real < 1000 then
            self.worldLev.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "I18NWorldLev_Down")
        end

        if self.isShowWorldLev then
            self.worldLev.gameObject:SetActive(true)
        else
            self.worldLev.gameObject:SetActive(false)
        end
    else
        self.worldLev.gameObject:SetActive(false)
    end
end

function RoleInfoView:update_buff()
    local list = {}
    local hasdiaowen = false
    for k,v in pairs(BuffPanelManager.Instance.model.buffDic) do
        if v.id < 90000 then table.insert(list, v) end
        local buffTplData = DataBuff.data_list[v.id]
        if buffTplData.icon_member == 10100 then
            hasdiaowen = true
        end
    end

    if SatiationManager:IsHunger() then
        self.buffIconImage1.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "hunger")
    else
        self.buffIconImage1.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "hungernot")
    end

    if not hasdiaowen then -- 没有雕文就显示个没有雕文的图标
        table.insert(list, 1, { special = 2 })
    end
    if ApocalypseLordManager.Instance.model.is_offer == 1 then -- 天启资格的图标
        table.insert(list, 1, { special = 4 })
    end
    if StarChallengeManager.Instance.model.is_offer == 1 then -- 龙王资格的图标
        table.insert(list, 1, { special = 3 })
    end
    if RoleManager.Instance.RoleData.lev >= 15 then --大于或等距15级时显示双倍
        table.insert(list, 1, { special = 1 })
    end

    self:SetBuffIcon(list[1], self.buffIcon2, self.buffIconImage2)
    self:SetBuffIcon(list[2], self.buffIcon3, self.buffIconImage3)


    -- if RoleManager.Instance.RoleData.lev < 15 then --小于15级时显示两个Buff
    --     self.buffArrow:SetActive(#list>2)

    --     if list[1] ~= nil then
    --         local buffinfo = DataBuff.data_list[list[1].id]
    --         self.buffIconImage2.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, tostring(buffinfo.icon))
    --         self.buffIcon2:SetActive(true)
    --     else
    --         self.buffIcon2:SetActive(false)
    --     end
    --     self.buffIconImage3.color = Color.white
    --     if list[2] ~= nil then
    --         local buffinfo = DataBuff.data_list[list[2].id]
    --         self.buffIconImage3.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, tostring(buffinfo.icon))
    --         self.buffIcon3:SetActive(true)
    --     else
    --         self.buffIcon3:SetActive(false)
    --     end
    -- elseif RoleManager.Instance.RoleData.lev < 30 or hasdiaowen then --大于等于15级时显示一个双倍点数一个Buff
    --     self.buffArrow:SetActive(#list>1)
    --     self.buffIconImage3.color = Color.white
    --     if AgendaManager.Instance.double_point == 0 then
    --         self.buffIconImage2.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "I18N_double_point_zero")
    --     else
    --         self.buffIconImage2.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "I18N_double_point")
    --     end
    --     self.buffIcon2:SetActive(true)

    --     if list[1] ~= nil then
    --         local buffinfo = DataBuff.data_list[list[1].id]
    --         self.buffIconImage3.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, tostring(buffinfo.icon))
    --         self.buffIcon3:SetActive(true)
    --     else
    --         self.buffIcon3:SetActive(false)
    --     end
    -- elseif RoleManager.Instance.RoleData.lev >= 30 then
    --     self.buffArrow:SetActive(#list>1)
    --     if AgendaManager.Instance.double_point == 0 then
    --         self.buffIconImage2.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "I18N_double_point_zero")
    --     else
    --         self.buffIconImage2.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "I18N_double_point")
    --     end
    --     self.buffIcon2:SetActive(true)
    --     self.buffIconImage3.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "12004")
    --     if hasdiaowen then
    --         self.buffIconImage3.color = Color.white
    --     else
    --         self.buffIconImage3.color = Color(0.4,0.4,0.4)
    --     end
    --     self.buffIcon3:SetActive(true)
    -- else
    -- end
end

function RoleInfoView:SetBuffIcon(data, iconObject, iconImage)
    if data ~= nil then
        if data.special == nil then
            iconImage.color = Color.white
            local buffinfo = DataBuff.data_list[data.id]
            iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, tostring(buffinfo.icon))
        elseif data.special == 1 then
            iconImage.color = Color.white
            if AgendaManager.Instance.double_point == 0 then
                iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "I18N_double_point_zero")
            else
                iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "I18N_double_point")
            end
        elseif data.special == 2 then
            iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "12004")
            if hasdiaowen then
                iconImage.color = Color.white
            else
                iconImage.color = Color(0.4,0.4,0.4)
            end
        elseif data.special == 3 then
            iconImage.color = Color.white
            iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "30001")
        elseif data.special == 4 then
            iconImage.color = Color.white
            iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.normalbufficon, "30003")
        end
        iconObject:SetActive(true)
    else
        iconObject:SetActive(false)
    end
end

function RoleInfoView:TweenHide()
    Tween.Instance:Move(self.mainRect, Vector3(self.originPos.x, 86, self.originPos.z), 0.2)
    self.isShow = false
end

function RoleInfoView:TweenShow()
    if BaseUtils.is_null(self.mainRect) then
        return
    end

    Tween.Instance:Move(self.mainRect, self.originPos, 0.2)
    self.isShow = true
end

function RoleInfoView:ShowWorldLev(bool)
    self.isShowWorldLev = bool
    if self.worldLev ~= nil then
        if RoleManager.Instance.RoleData.lev > 35 then
            self.worldLev.gameObject:SetActive(bool)
            if bool then
                self:update_world_lev()
            end
        else
            self.worldLev.gameObject:SetActive(false)
        end
    end
end

function RoleInfoView:AdaptIPhoneX()
    BaseUtils.AdaptIPhoneX(self.transform)
end
