PetEvaluationMessageItem = PetEvaluationMessageItem or BaseClass(MsgItemExt)

function PetEvaluationMessageItem:__init(text, maxWidth, fontSize, lineSpace, isSceneFace)
    self.specialIds = {}

end


function PetEvaluationMessageItem:SetData(data,specialIds)
    self.specialIds = specialIds
    self.data = data
    self.msgData = self:GetMsgData(data.content)
    self.data.msgData = self.msgData
    self.data = data
    -- self.data.leve = 80
    self.data.lev = 0
    if isDialog then
        self.msgData.showString = QuestEumn.FilterContent(self.msgData.showString)
    end
    -- self.contentTxt.text = self.msgData.showString
    self.contentTxt.text = self.msgData.pureString
    self:Layout()
end




function PetEvaluationMessageItem:ShowElements(elements)
    self:HideImg()
    local numb = 1
    for i,msg in ipairs(elements) do
        local func = function()
            local btn = self:GetButton()
            local rect = btn.gameObject:GetComponent(RectTransform)
            rect.sizeDelta = Vector2(msg.width, self.lineSpace)
            rect.anchoredPosition = Vector2(self.posxDic[i], self.posyDic[i])
            btn.onClick:RemoveAllListeners()
            btn.gameObject:SetActive(true)
            table.insert(self.btnTempTab, btn)
            return btn
        end

        --------------------------------------
        if msg.petId ~= 0 then
            local myId = nil
            local btn = func()

            if self.specialIds ~= nil then
                 msg.cacheId = self.specialIds[numb].id
                 numb = numb + 1
            else
                msg.cacheId = msg.cacheId
            end
            btn.onClick:AddListener(function() PetEvaluationManager.Instance:ShowCacheData(btn.gameObject, MsgEumn.CacheType.Pet,msg,self.data,msg.cacheId) end)
        elseif msg.guardId ~= 0 then
            local btn = func()
            if msg.cacheId ~= 0 then
                btn.onClick:AddListener(function() PetEvaluationManager.Instance:ShowCacheData(btn.gameObject, MsgEumn.CacheType.Guard, msg, self.data) end)
            end
        elseif msg.faceId ~= 0 and msg.faceId ~= nil then
            -- 表情处理
            local face = self:GetFaceItem()
            face:Show(msg.faceId, Vector2(self.posxDic[i], self.posyDic[i]), self.isSceneFace)
            if msg.faceId >= 1000 then
                if msg.noRoll then
                    face:JustShowResult(msg.randomVal)
                else
                    face:ShowRandom(msg.randomVal)
                end
                msg.noRoll = true
            end
            table.insert(self.faceTempTab, face)
        end
    end
end
