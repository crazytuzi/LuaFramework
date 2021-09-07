-- 主界面 系统
SystemView = SystemView or BaseClass(BaseView)

function SystemView:__init()
    self.model = model
	self.resList = {
        {file = AssetConfig.systemarea, type = AssetType.Main}
    }

    self.name = "SystemView"

    self.gameObject = nil
    self.transform = nil

    ------------------------------------
    self.timeText = nil
    self.power = nil
    self.wifi = nil
    self.signalText = nil

    self.count = 0

    ------------------------------------
    self._update = function()
    	self:update()
	end

	self:LoadAssetBundleBatch()
end

function SystemView:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function SystemView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.systemarea))
    self.gameObject.name = "SystemView"
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

    self.transform = self.gameObject.transform

    -----------------------------
    self.mainRect = self.transform:Find("Main"):GetComponent(RectTransform)
    self.timeText = self.transform:Find("Main/TimeText"):GetComponent(Text)
    self.power = self.transform:Find("Main/Power")
    self.wifi = self.transform:Find("Main/Wifi"):GetComponent(Image)
    self.signalText = self.transform:Find("Main/NetText"):GetComponent(Text)

    -----------------------------
    self:update()

    self:ClearMainAsset()
    -- self:AssetClearAll() --后面有用到 self.assetWrapper，所以注释掉这里了 soso
end

function SystemView:update()
    self:updateTime()
    self:updatePower()
    self:updateSignal()
end

function SystemView:updateTime()
    self.timeText.text = string.format("%s:%s", os.date("%H", BaseUtils.BASE_TIME), os.date("%M", BaseUtils.BASE_TIME))
end

function SystemView:updatePower()
    self.transform:Find("Main/PowerBG").gameObject:SetActive(false)
    self.power.gameObject:SetActive(false)
    -- self.power.localScale = Vector3 (0.5, 1, 1)
end

function SystemView:updateSignal()
    self.wifi.gameObject:SetActive(false)
    self.signalText.gameObject:SetActive(false)
    local flag = ctx:GetNetworkType()
    -- print(flag)
    if flag == "WIFI" or flag == "wifi" then
        self.wifi.gameObject:SetActive(true)
        self.wifi.sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "MainUIWifi")
    elseif flag == "2G" or flag == "3G" or flag == "4G" or flag == "2g" or flag == "3g" or flag == "4g" then
        self.wifi.gameObject:SetActive(true)
        self.wifi.sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "MainUIGGG")
    else
        self.wifi.gameObject:SetActive(true)
        self.wifi.sprite = PreloadManager.Instance:GetSprite(AssetConfig.mainui_textures, "MainUINone")
    end
end

function SystemView:OnTick()
    self.count = self.count + 1
    if self.count % 100 == 0 then
        self:updateTime()
        self:updateSignal()
    end
    -- if self.count % 500 == 0 then
    --     self:updatePower()
    -- end
end

function SystemView:TweenHide()
-- bugly #29751717 hosr 20160722
    if not BaseUtils.is_null(self.mainRect) then
        Tween.Instance:MoveY(self.mainRect, 100, 0.2)
    end
end

function SystemView:TweenShow()
-- bugly #29751717 hosr 20160722
    if not BaseUtils.is_null(self.mainRect) then
        Tween.Instance:MoveY(self.mainRect, -1, 0.2)
    end
end