-- ---------------------------
-- 聊天语音提示
-- hosr
-- ---------------------------
ChatVoiceTips = ChatVoiceTips or BaseClass(BasePanel)

function ChatVoiceTips:__init(model)
    self.model = model
    self.path = "prefabs/ui/chat/chatvoicetips.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main}
    }
    self.OnOpenEvent:Add(function() self:ShowSend() end)
    self.timeId = 0

    self.isInited = false
    self.isShow = true
end

function ChatVoiceTips:__delete()
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
        self.timeId = 0
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ChatVoiceTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "ChatVoiceTips"
    self.transform = self.gameObject.transform
    -- self.transform:SetParent(self.model.chatCanvas.transform)
    self.transform:SetParent(TipsManager.Instance.model.tipsCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.send = self.transform:Find("Send").gameObject
    self.vol1 = self.transform:Find("Send/Volumn1").gameObject
    self.vol2 = self.transform:Find("Send/Volumn2").gameObject
    self.vol1:SetActive(false)
    self.vol2:SetActive(false)
    self.send:SetActive(false)
    self.volList = {self.vol1, self.vol2}
    self.currentIndex = 0
    self.showVol = function() self:ShowVolumn() end
    self.timeId = 0

    self.cancel = self.transform:Find("Cancel").gameObject
    self.cancel:SetActive(false)

    self.isInited = true

    if self.isShow and self.model.voiceDown then
        self:ShowSend()
    else
        self:Hiden()
    end
end

function ChatVoiceTips:ShowSend()
    self.send:SetActive(true)
    self.cancel:SetActive(false)
    self:HideVolumn()
    self.timeId = LuaTimer.Add(0, 500, self.showVol)
end

function ChatVoiceTips:ShowVolumn()
    self.isShow = true
    if self.currentIndex == 2 then
        self.currentIndex = 0
        self.vol1:SetActive(false)
        self.vol2:SetActive(false)
    else
        self.currentIndex = self.currentIndex + 1
        for i = 1, self.currentIndex do
            self.volList[i]:SetActive(true)
        end
    end
end

function ChatVoiceTips:HideVolumn()
    if self.timeId ~= 0 then
        LuaTimer.Delete(self.timeId)
        self.timeId = 0
    end
    self.vol1:SetActive(false)
    self.vol2:SetActive(false)
end

function ChatVoiceTips:ShowCancel()
    if not self.isInited then
        return
    end
    self:HideVolumn()
    self.send:SetActive(false)
    self.cancel:SetActive(true)
end

function ChatVoiceTips:Hiden()
    self.isShow = false
    if self.gameObject ~= nil then
        self:HideVolumn()
        self.gameObject:SetActive(false)
    end
end