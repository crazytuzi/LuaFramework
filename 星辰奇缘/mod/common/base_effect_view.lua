-- ----------------------------------------------------------
-- 播放特效
-- data = { effectId, time, callback }
-- ----------------------------------------------------------
BaseEffectView = BaseEffectView or BaseClass(BaseView)

function BaseEffectView:__init(data)
    self.viewType = ViewType.BaseView
    -- 根节点
    self.gameObject = nil
    self.assetWrapper = nil
    self.show = true

    self.effectId = data.effectId
    self.time = data.time
	self.callback = data.callback

    self.name = string.format("effect_%s", data.effectId)
    self.effectPath = string.format("prefabs/effect/%s.unity3d", data.effectId)
    self.resList = {{file = self.effectPath, type = AssetType.Main}}
    self:LoadAssetBundleBatch()
end

function BaseEffectView:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
end

function BaseEffectView:InitPanel()
    if self.assetWrapper == nil then return end

	self.gameObject = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform

    if self.show == false then
        self.gameObject:SetActive(self.show)
    end

    -- 只能先干掉webstreaming了，这个类很少跑develeMe，对象泄漏了
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    self.callback(self)

    if self.time ~= nil then
    	LuaTimer.Add(self.time, 0, function(id) LuaTimer.Delete(id) self:DeleteMe() end)
    end
end

function BaseEffectView:SetActive(show)
    self.show = show
    if BaseUtils.is_null(self.gameObject) then
        -- Debug.Log("在BaseEffectView的gameObject已经被删除，不应该调用BaseEffectView:SetActive")
    else
        if self.gameObject.activeSelf ~= self.show then 
            self.gameObject:SetActive(show)
        end
    end
end