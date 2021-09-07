-- --------------------------
-- 单位播放特效
-- hosr
-- --------------------------
DramaAnimationUnit = DramaAnimationUnit or BaseClass()

function DramaAnimationUnit:__init()
    self.assetWrapper = nil
    self.effectList = {}

    self.callback = nil
end

function DramaAnimationUnit:__delete()
    for i,v in ipairs(self.effectList) do
        GameObject.DestroyImmediate(v)
    end
    self.effectList = nil
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
end

function DramaAnimationUnit:Show(action)
    self.assetWrapper = AssetBatchWrapper.New()

    local battle_id = action.battle_id
    local unit_id = action.unit_id
    local path = string.format("prefabs/effect/%s.unity3d", action.res_id)

    local func = function()
        local effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(path))
        if unit_id == 0 then
            if SceneManager.Instance.sceneElementsModel.self_view ~= nil and not BaseUtils.isnull(SceneManager.Instance.sceneElementsModel.self_view.gameObject) then
                effect.transform:SetParent(SceneManager.Instance.sceneElementsModel.self_view.gameObject.transform)
            end
        else
            local uniquenpcid = BaseUtils.get_unique_npcid(unit_id, battle_id)
            local npcView = SceneManager.Instance.sceneElementsModel.NpcView_List[uniquenpcid]
            if npcView ~= nil then
                effect.transform:SetParent(npcView.gameObject.transform)
            end
        end
        effect.transform.localPosition = Vector3.zero
        effect.transform.localScale = Vector3.one
        effect.transform:Rotate(Vector3(25, 0, 0))
        effect:SetActive(true)
        table.insert(self.effectList, effect)

        LuaTimer.Add(1000, function() self:TimeOut() end)

        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    self.resList = {
        {file = path, type = AssetType.Main}
    }
    self.assetWrapper:LoadAssetBundle(self.resList, func)
end

function DramaAnimationUnit:Hiden()
end

function DramaAnimationUnit:TimeOut()
    if self.callback ~= nil then
        self.callback()
    end
end

function DramaAnimationUnit:OnJump()
end
