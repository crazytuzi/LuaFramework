-- --------------------------
-- 点播放特效
-- hosr
-- --------------------------
DramaAnimationPoint = DramaAnimationPoint or BaseClass()

function DramaAnimationPoint:__init()
    self.effectList = {}

    self.callback = nil
end

function DramaAnimationPoint:__delete()
    for i,v in ipairs(self.effectList) do
        GameObject.DestroyImmediate(v)
    end
    self.effectList = nil
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
end

function DramaAnimationPoint:Show(action)
    local x = action.x
    local y = action.y
    local path = string.format("prefabs/effect/%s.unity3d", action.res_id)

    self.assetWrapper = AssetBatchWrapper.New()
    local func = function()
        if self.assetWrapper == nil then
            -- bugly #29785070 hosr 20160722
            return
        end
        local effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(path))
        effect.transform.localRotation = Quaternion.identity
        local p = SceneManager.Instance.sceneModel:transport_small_pos(x , y)
        effect.transform.localPosition = Vector3(p.x, p.y, p.y)
        effect.transform:Rotate(Vector3(25, 0, 0))
        effect:SetActive(true)
        table.insert(self.effectList, effect)

        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil

        LuaTimer.Add(1000, function() self:TimeOut() end)
    end

    self.resList = {
        {file = path, type = AssetType.Main}
    }
    self.assetWrapper:LoadAssetBundle(self.resList, func)
end

function DramaAnimationPoint:Hiden()
end

function DramaAnimationPoint:TimeOut()
    if self.callback ~= nil then
        self.callback()
    end
end

function DramaAnimationPoint:OnJump()
end
