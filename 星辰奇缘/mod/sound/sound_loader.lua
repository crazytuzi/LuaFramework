-- 背景音乐加载
-- @author huangyq
SoundLoader = SoundLoader or BaseClass()

function SoundLoader:__init(soundId, callback)
    self.soundId = soundId
    self.callback = callback

    self.soundPath = string.format("prefabs/sound/bgm/%s.unity3d", self.soundId)
    local resources = {
        {file = self.soundPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    }
    local loadCompleted = function()
        self:loadCompleted()
    end
    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle(resources, loadCompleted)
end

function SoundLoader:__delete()
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
end

function SoundLoader:loadCompleted()
    if self.callback ~= nil then
        local clip = self.assetWrapper:GetMainAsset(self.soundPath)
        self.callback(self.soundId, clip)
    end
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
end
