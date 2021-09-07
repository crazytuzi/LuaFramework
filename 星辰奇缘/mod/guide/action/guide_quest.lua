-- -------------------------
-- 任务引导动作
-- hosr
-- -------------------------
GuideQuest = GuideQuest or BaseClass()

function GuideQuest:__init()
    -- 追踪面板主线任务对象
    self.questObj = nil
    self.effectStr = ""
    self.effect = nil
    self.effectTransform = nil

    self.listener = function() self:ClickQuest() end
end

function GuideQuest:__delete()
end

function GuideQuest:InitPanel()
    self.questObj = MainUIManager.Instance.mainuitracepanel.traceQuest.mainObj
    self:ShowEffect()
end

function GuideQuest:ShowEffect()
    if self.effect == nil then
        self.assetWrapper = AssetBatchWrapper.New()
        local func = function()
            self.effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.effectStr))
            self.effect.name = "GuideQuestEffect"
            self.effectTransform = self.effect.transform

            self.assetWrapper:DeleteMe()
            self.assetWrapper = nil

            self:LocateEffect()
        end
        self.assetWrapper:LoadAssetBundle({{file = self.effectStr, type = AssetType.Main}}, func)
    else
        self:LocateEffect()
    end
end

function GuideQuest:LocateEffect()
    self.effectTransform:SetParent(self.questObj.transform)
    self.effectTransform.localScale = Vector3.one
    self.effectTransform.localPosition = Vector3.zero
    self.effect:SetActive(true)
end

function GuideQuest:ClickQuest()
end
