-- @author hze
-- @date #2019/10/11#
-- @WeChat公众号

PublicNumberPanel = PublicNumberPanel or BaseClass(BasePanel)

function PublicNumberPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "PublicNumberPanel"

    self.weChatStr = "xcqy3kwan"

    self.resList = {
        {file = AssetConfig.public_number_panel, type = AssetType.Main},
        {file = AssetConfig.public_number_panel_bgi18n, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep}
    }

    self.itemList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function PublicNumberPanel:__delete()
    self.OnHideEvent:Fire()

    self:AssetClearAll()
end

function PublicNumberPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.public_number_panel))
    self.gameObject.name = "PublicNumberPanel"
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t
    UIUtils.AddBigbg(t:Find("Bigbg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.public_number_panel_bgi18n)))
    self.mainTrans = t:Find("Main")
    self.copyBtnTrans = t:Find("Main/CopyButton")

    self.mainTrans.offsetMax = Vector2(0, -26.33)
    self.copyBtnTrans.sizeDelta = Vector2(142.3, 46.8)
    self.copyBtnTrans.anchoredPosition = Vector2(0, -162.3)

    t:Find("Main/CopyButton"):GetComponent(Button).onClick:AddListener(function()
            Utils.CopyTextToClipboard(self.weChatStr)
            NoticeManager.Instance:FloatTipsByString(TI18N("已复制到粘贴板"))
        end
    )
    self.descTxt = t:Find("Main/Text"):GetComponent(Text)
    self.descTxt.transform.sizeDelta = Vector2(365,23)
    self.descTxt.transform.anchoredPosition = Vector2(0,-198)
    self.descTxt.text = TI18N("（公众号：xcqy3kwan，复制后打开微信搜索即可关注）")
end

function PublicNumberPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function PublicNumberPanel:OnOpen()
    self:AddListeners()
    self:CheckRedPoint()
end

function PublicNumberPanel:OnHide()
    self:RemoveListeners()
end

function PublicNumberPanel:AddListeners()
    self:RemoveListeners()
end

function PublicNumberPanel:RemoveListeners()
end

function PublicNumberPanel:CheckRedPoint()
    BibleManager.Instance.redPointDic[1][27] = false
    BibleManager.Instance.onUpdateRedPoint:Fire()
end 
