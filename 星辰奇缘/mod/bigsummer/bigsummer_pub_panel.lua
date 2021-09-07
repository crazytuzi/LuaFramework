-- @author zyh
-- @date 2017年7月18日
BigSummerPubPanel = BigSummerPubPanel or BaseClass(BasePanel)

function BigSummerPubPanel:__init(model, parent, mainWindow)
    self.model = model
    self.parent = parent
    self.name = "BigSummerPubPanel"

    self.resList = {
        {file = AssetConfig.bigsummer_pub_panel, type = AssetType.Main},
        {file = AssetConfig.bigsummer_pub_bigbg, type = AssetType.Main},
        {file = AssetConfig.newmoon_textures, type = AssetType.Dep}
      }


    self.OnOpenEvent:AddListener(function()
      self:OnOpen()
    end)

    self.OnHideEvent:AddListener(function()
        self:OnHide()
    end)

    self.isOpen = false
    self.effTimerId = nil
end


function BigSummerPubPanel:__delete()
    self:OnHide()

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function BigSummerPubPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bigsummer_pub_panel))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.rechargeButton = self.transform:Find("Button"):GetComponent(Button)
    self.rechargeButton.onClick:AddListener(function()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop,{3})
    end

    )

    self.bigBg = self.transform:Find("Bigbg")
    local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.bigsummer_pub_bigbg))
    UIUtils.AddBigbg(self.bigBg,bigObj)

    self.noticeBtn = self.transform:Find("Notice"):GetComponent(Button)

    if self.campId == nil then
        self.campId = 959
    end

    local tipsText = {DataCampaign.data_list[self.campId].content}
    self.noticeBtn.onClick:AddListener(function()
         TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = tipsText})
    end)

    -- self.noticeBtn.transform.anchoredPosition = Vector2(-55,-400)

    self:OnOpen()
end

function BigSummerPubPanel:OnOpen()
    if self.effTimerId == nil then
        self.effTimerId = LuaTimer.Add(1000, 3000, function()
                   self.rechargeButton.gameObject.transform.localScale = Vector3(1.1,1.1,1)
                   Tween.Instance:Scale(self.rechargeButton.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
                end)
    end
end

function BigSummerPubPanel:OnHide()
    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end

end





