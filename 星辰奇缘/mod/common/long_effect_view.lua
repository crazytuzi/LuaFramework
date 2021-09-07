-- ------------------------------------------
-- 播放存放一段时间的特效
-- 需要播放时间和销毁时间
-- data = { effectId, time, timeDel, callback , delCallback}
-- ------------------------------------------
LongEffectView = LongEffectView or BaseClass(BaseView)

function LongEffectView:__init(data)
    self.gameObject = nil
    self.assetWrapper = nil
    self.show = true

    self.effectId = data.effectId
    self.time = data.time
    self.timeDel = data.timeDel
    self.callback = data.callback
    self.delCallback = data.delCallback

    self.timeId = 0
    self.timeDelId = 0

    self.name = string.format("effect_%s", data.effectId)
    self.effectPath = string.format("prefabs/effect/%s.unity3d", data.effectId)
    self.resList = {{file = self.effectPath, type = AssetType.Main}}
    self:LoadAssetBundleBatch()
end

function LongEffectView:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper= nil
    end
end

function LongEffectView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform

    if self.callback ~= nil then
        self.callback()
    end

    if self.show == false then
        self:SetActive(self.show)
    end

end

function LongEffectView:TimeOut()
    self:SetActive(false)
end

function LongEffectView:DelTimeOut()
    if self.delCallback ~= nil then
        self.delCallback()
    end
    self:DeleteMe()
end

function LongEffectView:SetActive(show)
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
    end

    if self.timeDelId ~= 0 then
        LuaTimer.Delete(self.timeDelId)
    end

    self.show = show
    if self.show then
        if self.time ~= nil then
            self.timeId = LuaTimer.Add(self.time, function() self:TimeOut() end)
        end

        if self.timeDel ~= nil then
            self.timeDelId = LuaTimer.Add(self.timeDel, function() self:DelTimeOut() end)
        end
    end
    if self.gameObject ~= nil then
        self.gameObject:SetActive(show)
    end
end