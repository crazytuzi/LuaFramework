-- ---------------------------
-- 引导描述 -- 换新资源版本
-- 20160911
-- hosr
-- ---------------------------
GuideTipsNew = GuideTipsNew or BaseClass(BaseTips)

function GuideTipsNew:__init(model)
    self.model = model
    self.mgr = TipsManager.Instance
    self.path = "prefabs/ui/tips/guidetipsnew.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = AssetConfig.guideres, type = AssetType.Dep},
        {file = AssetConfig.guidesprite, type = AssetType.Dep},
    }

    self.updateCall = function() self:UnRealUpdate() end
    self.OnHideEvent:Add(function() self:RemoveTime() end)
end

function GuideTipsNew:__delete()
    self:RemoveTime()
end

function GuideTipsNew:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "GuideTipsNew"
    self.transform = self.gameObject.transform
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.lefttext = self.transform:Find("LeftText"):GetComponent(Text)
    self.righttext = self.transform:Find("RightText"):GetComponent(Text)
    self.lefttextRect = self.lefttext.gameObject:GetComponent(RectTransform)
    self.righttextRect = self.righttext.gameObject:GetComponent(RectTransform)
    self.transform:SetParent(self.model.tipsCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.upArrow = self.transform:Find("Up").gameObject
    self.downArrow = self.transform:Find("Down").gameObject
    self.leftArrow = self.transform:Find("Left").gameObject
    self.rightArrow = self.transform:Find("Right").gameObject
    self.leftGril = self.transform:Find("LeftGril").gameObject
    self.rightGril = self.transform:Find("RightGril").gameObject
    self.leftGril:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guidesprite, "GuideSprite")
    self.rightGril:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guidesprite, "GuideSprite")

    self.gameObject:SetActive(false)
end

function GuideTipsNew:UpdateInfo(str)
    self.lefttext.text = str
    self.righttext.text = str
    self.lefttextRect.sizeDelta = Vector2(self.lefttext.preferredWidth, self.lefttext.preferredHeight)
    self.righttextRect.sizeDelta = Vector2(self.righttext.preferredWidth, self.righttext.preferredHeight)
    self.width = self.lefttext.preferredWidth + 90
    self.height = 82
    self.rect.sizeDelta = Vector2(self.width, self.height)
    self.mgr.updateCall = self.updateCall
end

function GuideTipsNew:RemoveTime()
    self.mgr.updateCall = nil
end

function GuideTipsNew:UnRealUpdate()
    if Input.touchCount > 0 and Input.GetTouch(0).phase == TouchPhase.Began then
        local v2 = Input.GetTouch(0).position
        if self.model:Checkvalidregion(v2.x, v2.y) == false then
            self.model:Closetips()
        end
    end

    if Input.GetMouseButtonDown(0) then
        local v2 = Input.mousePosition
        if self.model:Checkvalidregion(v2.x, v2.y) == false then
            self.model:Closetips()
        end
    end
end

function GuideTipsNew:ShowLeft()
    self.leftArrow:SetActive(false)
    self.rightArrow:SetActive(true)
    self.downArrow:SetActive(false)
    self.upArrow:SetActive(false)
    self.leftGril:SetActive(true)
    self.rightGril:SetActive(false)
    self.lefttext.gameObject:SetActive(true)
    self.righttext.gameObject:SetActive(false)
end

function GuideTipsNew:ShowRight()
    self.leftArrow:SetActive(true)
    self.rightArrow:SetActive(false)
    self.downArrow:SetActive(false)
    self.upArrow:SetActive(false)
    self.leftGril:SetActive(false)
    self.rightGril:SetActive(true)
    self.lefttext.gameObject:SetActive(false)
    self.righttext.gameObject:SetActive(true)
end

function GuideTipsNew:ShowUp()
    self.leftArrow:SetActive(false)
    self.rightArrow:SetActive(false)
    self.downArrow:SetActive(true)
    self.upArrow:SetActive(false)
    self.leftGril:SetActive(true)
    self.rightGril:SetActive(false)
    self.lefttext.gameObject:SetActive(true)
    self.righttext.gameObject:SetActive(false)
end

function GuideTipsNew:ShowDown()
    self.leftArrow:SetActive(false)
    self.rightArrow:SetActive(false)
    self.downArrow:SetActive(false)
    self.upArrow:SetActive(true)
    self.leftGril:SetActive(true)
    self.rightGril:SetActive(false)
    self.lefttext.gameObject:SetActive(true)
    self.righttext.gameObject:SetActive(false)
end