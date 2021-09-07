-- @author 黄耀聪
-- @date 2017年4月1日

TalismanAfter = TalismanAfter or BaseClass(BaseTips)

function TalismanAfter:__init(model)
    self.model = model
    self.name = "TalismanAfter"

    self.resList = {
        {file = AssetConfig.talisman_after, type = AssetType.Main},
        {file = AssetConfig.talisman_textures, type = AssetType.Dep},
    }

    self.attrDataList = {
        {key = "up_mask"},
        {key = "up_ring"},
        {key = "up_cloak"},
        {key = "up_blazon"},
    }
    self.updateCall = function() self:UnRealUpdate() end
    self.OnHideEvent:Add(function() self:RemoveTime() end)
end

function TalismanAfter:RemoveTime()
    TipsManager.Instance.updateCall = nil
end

function TalismanAfter:__delete()
    self:AssetClearAll()
end

function TalismanAfter:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.talisman_after))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.model.tipsCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    local main = self.transform
    self.confirmBtn = main:Find("Button"):GetComponent(Button)
    self.leftText = main:Find("Left/Text"):GetComponent(Text)
    self.rightText = main:Find("Right/Text"):GetComponent(Text)

    self.confirmBtn.onClick:AddListener(function() self.model:Closetips() end)
end

function TalismanAfter:OnInitCompleted()
    -- self.OnOpenEvent:Fire()
end

function TalismanAfter:UpdateInfo(attrOrigin, attrNow, extra)
    self.extra = extra or {}

    self.originAttr = attrOrigin
    self.currentAttr = attrNow

    self:ReloadAttr(self.originAttr, self.rightText)
    self:ReloadAttr(self.currentAttr, self.leftText)

    self:RePosition()
    TipsManager.Instance.updateCall = self.updateCall
end

function TalismanAfter:ReloadAttr(attrList, text)
    local textString = ""
    for index, attr in ipairs(attrList) do
        local lineString = ""
        local str = KvData.GetAttrName(attr.name, TalismanEumn.DecodeFlag(attr.flag, 3))
        if str == nil then
            lineString = TI18N("可洗炼")
        else
            if KvData.prop_percent[attr.name] == nil then
                lineString = string.format("%s+%s", str, attr.val)
            else
                lineString = string.format("%s+%s%%", str, attr.val / 10)
            end
        end
        if index == 1 then
            textString = string.format("%s%s", textString, lineString)
        else
            textString = string.format("%s\n%s", textString, lineString)
        end
    end
    text.text = textString
end

function TalismanAfter:RePosition()
    local size = self.transform.sizeDelta
    local width = 960
    local height = 960 * ctx.ScreenHeight / ctx.ScreenWidth

    self.transform.anchoredPosition = Vector2((width - size.x) / 2, (height - size.y) / 2)
    self.model.xregion = {["min"] = self.transform.anchoredPosition.x, ["max"] = self.transform.anchoredPosition.x + self.transform.sizeDelta.x}
    self.model.yregion = {["min"] = self.transform.anchoredPosition.y, ["max"] = self.transform.anchoredPosition.y + self.transform.sizeDelta.y}
end

function TalismanAfter:UnRealUpdate()
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


