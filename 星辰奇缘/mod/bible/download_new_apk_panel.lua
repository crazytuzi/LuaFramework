-- @author ljh
-- @date 2018年06月28日

DownloadNewApkPanel = DownloadNewApkPanel or BaseClass(BasePanel)

function DownloadNewApkPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "DownloadNewApkPanel"

    self.resList = {
        {file = AssetConfig.downloadnewapkpanel, type = AssetType.Main},
        {file = AssetConfig.downloadnewapki18n, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }

    self.itemList = {}

    self.linkText = "http://transfer.kkk5.com/?ct=api&ac=link&app_id=347&from_id=%s"
    self.linkText_Platform = "http://download-pt.kkk5.com/yunying/xcqy/18070500/xcqy-tengx3k-%s.apk"
    self.linkText_OtherPlatform = "http://download-pt.kkk5.com/yunying/xcqy/18070500/xcqy_%s_%s.apk"
    self.linkText_IOS = "https://itunes.apple.com/cn/app/id1062524230?mt=8"
    
    self.hideEffect = function ()
        if DownLoadManager.Instance.model.hasReward_Type2 == 1 then
            self:HideEffect()
        end
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function DownloadNewApkPanel:__delete()
    self.OnHideEvent:Fire()

    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v.slot:DeleteMe()
                v.itemdata:DeleteMe()
            end
        end
        self.itemList = nil
    end

    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end

    if self.btnEffect == nil then
        self.btnEffect:DeleteMe()
        self.btnEffect = nil
    end

    self:AssetClearAll()
end

function DownloadNewApkPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.downloadnewapkpanel))
    self.gameObject.name = "DownloadNewApkPanel"
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t
    UIUtils.AddBigbg(t:Find("BigBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.downloadnewapki18n)))


    self.layout = LuaBoxLayout.New(t:Find("Reward/Scroll/Container"), {axis = BoxLayoutAxis.X, border = 10, cspacing = 10})

    local data = DataDownloadReward.data_data[1].guide_gain
    self.layout:ReSet()
    local weight = #data*(64+10)+10
    t:Find("Reward/Scroll"):GetComponent(RectTransform).sizeDelta = Vector2(weight,65)

    for i,v in ipairs(data) do
        local tab = self.itemList[i]
        if tab == nil then
            tab = {}
            tab.slot = ItemSlot.New()
            tab.itemdata = ItemData.New()
            self.itemList[i] = tab
        end
        tab.itemdata:SetBase(DataItem.data_get[v.key])
        tab.slot:SetAll(tab.itemdata)
        tab.slot:SetNum(v.val)
        self.layout:AddCell(tab.slot.gameObject)
    end

    self.jumpBtn = t:Find("JumpBtn"):GetComponent(Button)
    self.jumpBtn.onClick:AddListener(function()
        if self:NeedDownload() then
            Application.OpenURL(self:GetLinkText())
        else
            DownLoadManager.Instance:Send9930(2)
        end
    end)

    self.btnText = t:Find("JumpBtn/Text"):GetComponent(Text)

    if self.btnEffect == nil then
        self.btnEffect = BaseUtils.ShowEffect(20053, self.jumpBtn.transform, Vector3(1.9,0.75,1), Vector3(-60,-16,-1000))
    end

    if self:NeedDownload() then
        t:Find("Desc/Text"):GetComponent(Text).text = TI18N("·您所使用的客户端版本较旧，请于8月27日-9月4日内前往下载最新版本\n·若未能及时更新，9月4日后将会进行强制更新，具体日期请留意公告")
        self.btnText.text = TI18N("前往下载")

        t:Find("LinkText/Text"):GetComponent(Text).text = self:GetLinkText()
        t:Find("CopyBtn"):GetComponent(Button).onClick:AddListener(function()
            Utils.CopyTextToClipboard(self:GetLinkText())
            NoticeManager.Instance:FloatTipsByString(TI18N("链接已复制到粘贴板"))
        end)
    else
        t:Find("Desc/Text"):GetComponent(Text).text = TI18N("                恭喜您已下载最新版本客户端，可点击领取以下礼包！")
    
        self.btnText.text = TI18N("领取奖励")
        t:Find("JumpBtn").localPosition = Vector3(0, -193.2, 0)
        t:Find("LinkText").gameObject:SetActive(false)
        t:Find("CopyBtn").gameObject:SetActive(false)
    end
end

function DownloadNewApkPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function DownloadNewApkPanel:OnOpen()
    self:AddListeners()

end

function DownloadNewApkPanel:OnHide()
    self:RemoveListeners()
end

function DownloadNewApkPanel:AddListeners()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.download_reward, self.hideEffect)
end

function DownloadNewApkPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.download_reward, self.hideEffect)
end

function DownloadNewApkPanel:HideEffect()
    self.btnText.text = TI18N("已领取")
    self.btnEffect:SetActive(false)
    self.jumpBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    self.btnText.color =  ColorHelper.DefaultButton4
end

function DownloadNewApkPanel:OnReturn()
    self.btnText.text = TI18N("领取奖励")
end

function DownloadNewApkPanel:NeedDownload()
    if Application.platform == RuntimePlatform.Android and BaseUtils.CSVersionToNum() < 10700 then
        return true
    elseif Application.platform == RuntimePlatform.IPhonePlayer and BaseUtils.GetGameName() == "xcqy" and BaseUtils.CSVersionToNum() < 20900 then
        return true
    else
        return false
    end
end

function DownloadNewApkPanel:GetLinkText()
    if Application.platform == RuntimePlatform.Android then
        if ctx.PlatformChanleId == 0 then
            return string.format(self.linkText, ctx.KKKChanleId)
        elseif ctx.PlatformChanleId == 33 then
            return string.format(self.linkText_Platform, ctx.KKKChanleId)
        else
            return string.format(self.linkText_OtherPlatform, ctx.PlatformChanleId, ctx.KKKChanleId)
        end
    elseif Application.platform == RuntimePlatform.IPhonePlayer then
        return self.linkText_IOS
    end
end