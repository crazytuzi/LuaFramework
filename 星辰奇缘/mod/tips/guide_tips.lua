-- ---------------------------
-- 引导描述
-- hosr
-- ---------------------------
GuideTips = GuideTips or BaseClass(BaseTips)

function GuideTips:__init(model)
    self.model = model
    self.mgr = TipsManager.Instance
    self.path = "prefabs/ui/tips/guidetips.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = AssetConfig.guideres, type = AssetType.Dep},
    }

    self.updateCall = function() self:UnRealUpdate() end
    self.OnHideEvent:Add(function() self:RemoveTime() end)
end

function GuideTips:__delete()
    self:RemoveTime()
end

function GuideTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "GuideTips"
    self.transform = self.gameObject.transform
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.text = self.transform:Find("Text"):GetComponent(Text)
    self.textRect = self.text.gameObject:GetComponent(RectTransform)
    self.transform:SetParent(self.model.tipsCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.gameObject:SetActive(false)
end

function GuideTips:UpdateInfo(str)
    self.text.text = str
    self.textRect.sizeDelta = Vector2(self.text.preferredWidth, self.text.preferredHeight)
    self.width = self.text.preferredWidth + 70
    self.height = 82
    self.rect.sizeDelta = Vector2(self.width, self.height)
    self.mgr.updateCall = self.updateCall
end

function GuideTips:RemoveTime()
    self.mgr.updateCall = nil
end

function GuideTips:UnRealUpdate()
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