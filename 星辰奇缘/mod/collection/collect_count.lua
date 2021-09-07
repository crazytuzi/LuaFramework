-- ---------------------------------------
-- 进度条(支持倒计时)
-- 注意区别
-- hosr
-- ---------------------------------------

CollectCountPanel = CollectCountPanel or BaseClass(BasePanel)

function CollectCountPanel:__init()

    self.path = ""
    self.resList = {
        {file = "prefabs/ui/collection/collection.unity3d", type = AssetType.Main}
    }
end

function CollectCountPanel:__delete()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
end

function CollectCountPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local rect = self.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2.one
    rect.anchorMin = Vector2.zero
    rect.offsetMin = Vector2.zero
    rect.offsetMax = Vector2.zero
    self.gameObject:SetActive(false)

    self.mainObj = self.transform:Find("Main").gameObject
    self.slider = transform:Find("Main/Slider"):GetComponent(Slider)
    self.icon = transform:Find("Main/Slider/Icon"):GetComponent(Image)
    self.txt = transform:Find("Main/Text"):GetComponent(Text)
    self.slider.value = 1

    self:StartUp()
end

function CollectCountPanel:StartUp(lastTime, needTime, callback)
    self.needTime = needTime
    self.callback = callback
    self.time = needTime - (ctx.TimerManager.BASE_TIME - lastTime)
    self.timeId = LuaTimer.Add(0, 10, function() self:Run() end)
end

function CollectCountPanel:Run()
    if self.transform == nil or self.transform:Equals(NULL) then
        self.transform = nil
        self.mainObj = nil
        return
    end

    if self.time <= 0 then
        self:TimeOut()
        return
    end

    self.time = self.time - 1
    local t = ""
    if self.time >= 60 * 60 then
       t = tostring(os.date(TI18N("%H时%M分%S秒"), self.time))
    elseif self.time >= 60 then
       t = tostring(os.date(TI18N("%M分%S秒"), self.time))
    else
       t = tostring(os.date(TI18N("%S秒"), self.time))
    end
    self.txt.text = t
    self.slider.value = self.time / self.needTime
end

function CollectCountPanel:TimeOut()
    LuaTimer.Delete(self.timeId)
    if self.callback ~= nil then
        self.callback()
    end
end

function CollectCountPanel:UpdatePosition(v2)
    if self.transform == nil then
        return
    end
    if self.mainObj ~= nil then
        self.mainObj:GetComponent(RectTransform).anchoredPosition = v2
    end
end
