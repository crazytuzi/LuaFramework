-- ------------------
-- NoticeTips按钮
-- hze
-- ------------------
NoticeBtnTips = NoticeBtnTips or BaseClass()

function NoticeBtnTips:__init(parent,position,size,click)
    self.parent = parent
    self.gameObject = nil
    self.size = size or 32
    self.click = click 
    self.position = position or Vector2.zero
    self:Load()
end

function NoticeBtnTips:Load()
    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle({{file = AssetConfig.notice_tips, type = AssetType.Main}}, function() self:LoadEnd() end)
end

function NoticeBtnTips:LoadEnd()
    self.gameObject = GameObject.Instantiate(self.assetWrapper:GetMainAsset(AssetConfig.notice_tips))
    self.gameObject.name = "NoticeTipsBtn"
    UIUtils.AddBigbg(self.parent, self.gameObject)

    self.btn = self.gameObject.transform:GetComponent(Button)
    if self.click ~= nil then 
        self.btn.onClick:AddListener(function() self.click() end)
    end
    self.gameObject.transform.sizeDelta = Vector2(self.size, self.size)
    self.gameObject.transform.anchoredPosition = self.position
    self.gameObject:SetActive(true)
end

function NoticeBtnTips:__delete()
    if self.gameObject ~= nil then
        GameObject.Destroy(self.gameObject)
        self.gameObject = nil
    end
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
end