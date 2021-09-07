-- 下载窗口
-- @ljh 2016.06.12
DownLoadView = DownLoadView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function DownLoadView:__init(model)
    self.model = model
    self.name = "DownLoadView"
    self.windowId = WindowConfig.WinID.download_win
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.effectPath = "prefabs/effect/20118.unity3d"
    self.resList = {
        {file = AssetConfig.download_win, type = AssetType.Main}
        , {file = self.effectPath, type = AssetType.Main}
        , {file = AssetConfig.agenda_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil


	------------------------------------------------
    self.soltLIst = {}

    self.downLoad_Total = 1
    self.downLoad_Now = 1
	------------------------------------------------
    ------------------------------------------------
    self._update_progress = function(total, remain) self:update_progress(total, remain) end
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function DownLoadView:__delete()
    self:Release()
end

function DownLoadView:Release()
    self:OnHide()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function DownLoadView:InitPanel()
    if not self.model:IsSubpackage() then
        self:Release()
        return
    end

	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.download_win))
    self.gameObject.name = "DownLoadView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:FindChild("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

	self.slider = self.transform:FindChild("Main/Panel/Slider"):GetComponent(Slider)
    self.sliderText = self.transform:FindChild("Main/Panel/SliderText"):GetComponent(Text)

    self.soltPanel = self.transform:FindChild("Main/Panel/ItemPanel/SoltPanel").gameObject

    self.pauseButton = self.transform:FindChild("Main/Panel/PauseButton"):GetComponent(Button)
    self.pauseButton.onClick:AddListener(function() self:onClickPauseButton() end)

    self.rewardButton = self.transform:FindChild("Main/Panel/RewardButton"):GetComponent(Button)
    self.rewardButton.onClick:AddListener(function() self:onClickRewardButton() end)

    self.finishMark = self.transform:FindChild("Main/Panel/FinishMark").gameObject

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effect.transform:SetParent(self.rewardButton.transform)
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(-50, 27, -500)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect:SetActive(false)

    ----------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function DownLoadView:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function DownLoadView:OnShow()
    self:update_downLoad()
	self:update_item()
    self:update_slider()
    self:update_button()

    self.model.OnUpdate:Add(self._update_progress)
end

function DownLoadView:OnHide()
    self.model.OnUpdate:Remove(self._update_progress)
end

function DownLoadView:update_progress(total, remain)
    self.downLoad_Total = total
    self.downLoad_Now = total - remain
    self:update_slider()
    if self.downLoad_Now == self.downLoad_Total then
        self:update_button()
    end
end

function DownLoadView:update_downLoad()
    if CSSubpackageManager then
        self.downLoad_Total = CSSubpackageManager.GetInstance():GetTotal()
        self.downLoad_Now = self.downLoad_Total - CSSubpackageManager.GetInstance():GetRemain()
    end
end

function DownLoadView:update_button()
    if self.model.hasReward then
        self.rewardButton.gameObject.transform:FindChild("Text"):GetComponent(Text).text = TI18N("已领取")
        self.rewardButton.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.effect:SetActive(false)
        
        if self.downLoad_Total == self.downLoad_Now then
            self.pauseButton.gameObject:SetActive(false)
            self.finishMark:SetActive(true)
        else
            if self.model:IsDowning() then
                self.pauseButton.gameObject.transform:FindChild("Text"):GetComponent(Text).text = TI18N("暂  停")
            else
                self.pauseButton.gameObject.transform:FindChild("Text"):GetComponent(Text).text = TI18N("继  续")
            end

            self.rewardButton.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.finishMark:SetActive(false)
        end
    else
        if self.downLoad_Total == self.downLoad_Now then
            self.pauseButton.gameObject:SetActive(false)
            self.finishMark:SetActive(true)
            self.effect:SetActive(true)
            self.rewardButton.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
        else
            if self.model:IsDowning() then
                self.pauseButton.gameObject.transform:FindChild("Text"):GetComponent(Text).text = TI18N("暂  停")
            else
                self.pauseButton.gameObject.transform:FindChild("Text"):GetComponent(Text).text = TI18N("继  续")
            end

            self.rewardButton.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.effect:SetActive(false)
            self.finishMark:SetActive(false)
        end
    end
end

function DownLoadView:update_item()
    local itemList = DataDownloadReward.data_data[1].download_gain
    for i,gain in ipairs(itemList) do
        local itemSlot = self.soltLIst[i]
        if itemSlot == nil then
            itemSlot = ItemSlot.New()
            UIUtils.AddUIChild(self.soltPanel, itemSlot.gameObject)
            table.insert(self.soltLIst, itemSlot)
        end
        local itembase = BackpackManager.Instance:GetItemBase(gain.key)
        local itemData = ItemData.New()
        itemData:SetBase(itembase)
        itemData.quantity = gain.val
        itemSlot:SetAll(itemData)
    end
end

function DownLoadView:update_slider()
    if self.downLoad_Total == 0 or self.downLoad_Total == self.downLoad_Now then
        self.slider.value = 1
        self.sliderText.text = TI18N("下载已完成，请领取奖励")
    else
        self.slider.value = self.downLoad_Now / self.downLoad_Total 
        self.sliderText.text = string.format(TI18N("下载完成可以领取以下奖励，正在加载%.1f%%"), self.downLoad_Now / self.downLoad_Total * 100)
    end
end

function DownLoadView:onClickPauseButton()
    if self.model:IsDowning() then
        self.model:PauseDownload()
    else
        self.model:StartDownload()
    end
    self:update_button()
end

function DownLoadView:onClickRewardButton()
    if self.downLoad_Now ~= self.downLoad_Total then
        NoticeManager.Instance:FloatTipsByString(TI18N("下载完成才可以领奖哦"))
    else
        DownLoadManager.Instance:Send9930(1)
        self:OnClickClose()
    end
end
