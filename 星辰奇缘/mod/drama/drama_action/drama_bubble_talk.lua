-- -----------------------------
-- 剧情泡泡对话
-- -----------------------------
DramaBubble = DramaBubble or BaseClass(BaseDramaPanel)

function DramaBubble:__init(model)
    self.model = model
    self.path = "prefabs/ui/drama/scenetalkbubble.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main}
    }
    self.callback = nil
end

function DramaBubble:__delete()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
end

function DramaBubble:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local rect = self.gameObject:GetComponent(RectTransform)
    rect.anchorMax = Vector2.one
    rect.anchorMin = Vector2.zero
    rect.offsetMin = Vector2.zero
    rect.offsetMax = Vector2.zero
    self.gameObject:SetActive(false)

    self.transform = self.gameObject.transform
    self.mainObj = self.transform:Find("Main").gameObject
    self.mainRect = self.mainObj:GetComponent(RectTransform)
    self.content = self.mainObj.transform:Find("Content"):GetComponent(Text)
    self.contentRect = self.content.gameObject:GetComponent(RectTransform)
    self.content.text = ""
end

function DramaBubble:OnInitCompleted()
    self:SetData(self.openArgs)
end

function DramaBubble:SetData(data)
    local battle_id = data.battle_id
    local unit_id = data.unit_id
    local msg = data.msg
    local delay = data.time

    self.content.text = msg
    local len = self.content.preferredWidth
    local hh = self.content.preferredHeight
    if len > 150 then
        len = 150
    end
    self.contentRect.sizeDelta = Vector2(len, hh)
    self.mainRect.sizeDelta = Vector2(len + 40, hh + 50)
    self.mainRect.anchoredPosition = Vector2(20, -20)

    local unitObj = nil
    if unit_id == 0 then
        unitObj = SceneManager.Instance.sceneElementsModel.self_view.gameObject
    else
        local uniquenpcid = BaseUtils.get_unique_npcid(unit_id, battle_id)
        local npcView = SceneManager.Instance.sceneElementsModel.NpcView_List[uniquenpcid]
        if npcView ~= nil then
            unitObj = npcView.gameObject
        end
    end

    local pos = CombatUtil.WorldToUIPoint(ctx.MainCamera, unitObj.transform.position)
    self.mainObj.transform.localPosition = Vector3(pos.x, pos.y + 110, 0)
    self.gameObject:SetActive(true)

    LuaTimer.Add(delay, function() self:TimeOut() end)
end

function DramaBubble:TimeOut()
    self.gameObject:SetActive(false)
    if self.callback ~= nil then
        self.callback()
    end
end

function DramaBubble:OnJump()
end