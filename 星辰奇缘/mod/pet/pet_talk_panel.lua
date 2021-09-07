PetTalkPanel = PetTalkPanel or BaseClass(BasePanel)

function PetTalkPanel:__init(model)
    self.model = model
    self.name = "PetTalkPanel"

    self.resList = {
        {file = AssetConfig.pet_talk_panel, type = AssetType.Main}
        -- ,{file  =  AssetConfig.dropicon, type  =  AssetType.Dep}
    }
    self.currInputField = nil
    self.talk_Key={
        [0] = "show",
        [1] = "atk",
        [2] = "dfd",
        [3] = "dead",
        [4] = "master_dead",
        [5] = "use",
        [6] = "escape",
    }
    self.appendTab = {}
end


function PetTalkPanel:OnInitCompleted()

end

function PetTalkPanel:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
end

function PetTalkPanel:InitPanel()
    self.talk_data = {}
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_talk_panel))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.gameObject.name = "PetTalkPanel"
    self.transform = self.gameObject.transform
    self.maincon = self.transform:Find("Main/Con")
    self.transform:Find("Main").anchoredPosition = Vector2.zero
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:ClosePetTalkPanel() end)
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:ClosePetTalkPanel() end)
    self:InitInputField()
    self.infoBtn = self.transform:Find("Main/Info")
    self.infoBtn = self.infoBtn:GetComponent(Button) or self.infoBtn.gameObject:AddComponent(Button)
    self.infoBtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.infoBtn.gameObject, itemData = {
            TI18N("1.出场(召唤/闪现)：战斗中召唤宠物或宠物闪现时，100%播放闲聊"),
            TI18N("2.宠物攻击、挨打、死亡、主人倒地、使用药品时，20%几率播放闲聊"),
            TI18N("3.每场战斗每条闲聊最多会播放一次"),
            }})
        end)
end

function PetTalkPanel:Refresh()
    -- body
end

function PetTalkPanel:InitInputField()
    for i=0, 6 do
        local baseData = DataPet.data_pet_talk[self.model.cur_petdata.base_id]
        local child = self.maincon:GetChild(i)
        local ipf = child:Find("InputField"):GetComponent(InputField)
        local textcom = ipf.gameObject.transform:Find("Text"):GetComponent(Text)
        local placeholder = ipf.gameObject.transform:Find("Placeholder"):GetComponent(Text)
        ipf.textComponent = textcom
        ipf.placeholder = placeholder
        ipf.interactable = false
        -- PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton11")
        local btn = child:Find("SaveLoad")
        local morebtn = child:Find("Face")
        local ipfbtn = child:Find("ipfbtn")
        local resetbtn = child:Find("Reset")
        morebtn.gameObject:SetActive(false)
        resetbtn.gameObject:SetActive(false)
        local editcallback = function()
            if self.currInputField == ipf then
                local data1, data2 = self:ConvertToTag_Face2(self.currInputField.text)
                if data2 then
                    NoticeManager.Instance:FloatTipsByString(TI18N("表情数量超出1个，无法进行保存"))
                    return
                end
                btn:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
                btn:Find("Text"):GetComponent(Text).text = TI18N("编辑")
                self.talk_data[i+1] = data1
                print("表情：")
                print(data1)
                PetManager.Instance:Send10536(self.model.cur_petdata.id, i+1, data1)
                ipf.interactable = false
                self.currInputField = nil
                ipfbtn.gameObject:SetActive(true)
                morebtn.gameObject:SetActive(false)
                resetbtn.gameObject:SetActive(false)
            elseif self.currInputField == nil then
                btn:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
                btn:Find("Text"):GetComponent(Text).text = TI18N("保存")
                ipf.interactable = true
                self.currInputField = ipf
                ipfbtn.gameObject:SetActive(false)
                morebtn.gameObject:SetActive(true)
                resetbtn.gameObject:SetActive(true)

                -- self.ApplySaveButton()
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("请先保存修改"))
            end
        end
        btn:GetComponent(Button).onClick:AddListener(editcallback)
        morebtn:GetComponent(Button).onClick:AddListener(function()
            if self.currInputField == ipf and (self.singleface == nil or self.singleface.gameObject == nil) then
                if self.singleface == nil then
                        self.singleface = ChatExtMainPanel.New(self,MsgEumn.ExtPanelType.Other, {parent = self},nil,false)
                end
                self.singleface:Show()
            elseif self.singleface ~= nil then
                self.singleface:DeleteMe()
                self.singleface = nil
            end
        end)
        ipfbtn:GetComponent(Button).onClick:AddListener(editcallback)
        resetbtn:GetComponent(Button).onClick:AddListener(function()
            ipf.text = self:ConvetrTo(baseData[self.talk_Key[i]])
        end)
    end
    self:InitTalkSetting()
end

function PetTalkPanel:InitTalkSetting()
    self.talk_data = self.model.pettalk_data.combat_talk
    for k,v in pairs(self.talk_data) do
        if v.type == 1 then
            self.maincon:Find("show/InputField"):GetComponent(InputField).text = self:ConvetrTo(v.msg)
            -- self.maincon:Find("show/InputField"):GetComponent(InputField).text = MessageParser.Filter(v.msg) string.gsub(v.msg, "{face_%d, %d}", "#52910f")
        elseif v.type == 2 then
            self.maincon:Find("atk/InputField"):GetComponent(InputField).text = self:ConvetrTo(v.msg)
        elseif v.type == 3 then
            self.maincon:Find("dfd/InputField"):GetComponent(InputField).text = self:ConvetrTo(v.msg)
        elseif v.type == 4 then
            self.maincon:Find("dead/InputField"):GetComponent(InputField).text = self:ConvetrTo(v.msg)
        elseif v.type == 5 then
            self.maincon:Find("masterdead/InputField"):GetComponent(InputField).text = self:ConvetrTo(v.msg)
        elseif v.type == 6 then
            self.maincon:Find("use/InputField"):GetComponent(InputField).text = self:ConvetrTo(v.msg)
        elseif v.type == 7 then
            self.maincon:Find("escape/InputField"):GetComponent(InputField).text = self:ConvetrTo(v.msg)
        end
    end
end
    -- MessageParser.Filter(str)  ---->#
    -- MessageParser.ConvertToTag_Face(msg) --->{}

function PetTalkPanel:ConvetrTo(msg)
    local temp = msg
    for tag,val in string.gmatch(msg, "{(%l-_%d-),(.-)}") do
        local val_ = tonumber(val)
        -- local msg = MsgElement.New()
        -- msg.fatherStr = string.format("{%s,%s}", tag, val)
        temp = string.gsub(temp, string.format("{face_1, %s}",val_), string.format("#%s", val_))
        temp = string.gsub(temp, string.format("{face_1,%s}",val_), string.format("#%s", val_))
        -- msg.srcStr = string.format("{%s,%s}", msg.tag, msg.val)
        -- table.insert(tags, msg)
    end
    return temp
end

function PetTalkPanel:ConvertToTag_Face2(msg)
    local overface = false
    local faces = {}
    local msgTemp = string.gsub(msg, "<.->", "")
    for faceId in string.gmatch(msgTemp, "#(%d+)") do
        if MessageParser.CheckFaceHas(faceId) == true then
            if #faces < 5 and tonumber(faceId) <= 40 then
                table.insert(faces, faceId)
            elseif #faces < 5 and tonumber(faceId) >= 41 and tonumber(faceId)  <=48 then
                local _type = PrivilegeManager.Instance:GetValueByType(PrivilegeEumn.Type.specialFacePack)
                local cfg_data = DataChatFace.data_get_chat_face_privilege[tonumber(faceId)]
                if cfg_data.privilege <= _type then
                    table.insert(faces, faceId)
                end
            elseif #faces < 5 and tonumber(faceId) >= 49 and tonumber(faceId) <= 59 then
                table.insert(faces, faceId)
            else
                table.insert(faces, faceId)
            end
        end
    end

    for i,faceId in ipairs(faces) do
        if i <= 1 then
            local src = string.format("#%s", faceId)
            local rep = string.format("{face_1,%s}", faceId)
            msg = string.gsub(msg, src, rep, 1)
        else
            overface = true
        end
    end
    return msg, overface
end

function PetTalkPanel:ResetPos()
    self.transform:Find("Main").anchoredPosition = Vector2.zero
end

function PetTalkPanel:AppendInputElement(element)
    -- 其他：同类只有一个，如果是自己，则过滤掉
   local delIndex = 0
    local srcStr = ""
    if element.type ~= nil then
        for i,has in ipairs(self.appendTab) do
            if has.type == element.type and element.type ~= MsgEumn.AppendElementType.Face then
               if element.type == MsgEumn.AppendElementType.Pet and has.id ~= element.id then

               else
                 delIndex = i
                 srcStr = has.matchString
               end
            end
        end
    end

    local nowStr = self.currInputField.text
    if delIndex ~= 0 then
        table.remove(self.appendTab, delIndex)
        table.insert(self.appendTab, delIndex, element)
        if string.find(nowStr, srcStr) ~= nil then
            local repStr = element.matchString
            nowStr = string.gsub(nowStr, srcStr, repStr, 1)
        else
            nowStr = nowStr .. element.showString
        end
    else
        nowStr = nowStr .. element.showString
        table.insert(self.appendTab, element)
    end
    self.currInputField.text = nowStr
end

-- function PetTalkPanel:ApplySaveButton()
-- end

-- function PetEvaluationWindow:CheckElement()
--     self.specialIds = {}
--     if #self.appendTab == 0 then
--         return false
--     end
--     local role = RoleManager.Instance.RoleData
--     local str = self.currInputField.text
--     local numb = 1
--     for i,v in ipairs(self.appendTab) do
--         local newSendStr = v.sendString

--         if v.type == MsgEumn.AppendElementType.Pet then
--               newSendStr = string.format("{pet_1,%s,%s,%s,%s}", role.platform, role.zone_id,v.id,v.base_id)
--               self.specialIds[numb] = {}
--               self.specialIds[numb].id = v.id
--               numb = numb + 1

--         elseif v.cacheType == MsgEumn.CacheType.Guard then
--             -- local cacheId = ChatManager.Instance.guardCache[v.id]
--             -- if cacheId ~= nil then
--                 local myShData = ShouhuManager.Instance.model:get_my_shouhu_data_by_id(self.currentTargetData.id)
--                 BaseUtils.dump(myShData,"守护数据")
--                 newSendStr = string.format("{guard_1,%s,%s,%s,%s, %s}", role.platform, role.zone_id,self.currentTargetData.id, self.currentTargetData.id, myShData.quality)
--             -- end
--         end
--         str = string.gsub(str, v.matchString, newSendStr, 1)
--     end

--     if self.typeIndex == EvaluationTypeEumn.Type.ShouHu then
--         self.specialIds[1] = {}
--         self.specialIds[1].id = self.currentTargetData.id
--     end
--     -- ChatManager.Instance:AppendHistory(self.EvaluationInputField.text)
--     -- 去掉手动输入的控制符 如 \n
--     str = string.gsub(str, "%c+", "　")
--         -- self.myCurrentEvaluation = str
--         -- local data = { type = self.typeIndex,base_id = self.currentTargetData.id,content = msg}
--     local ok = PetEvaluationManager.Instance:SendMsg(self.typeIndex,self.currentTargetData.id,self.specialIds,str)
--         -- self.petEvaluationList:AddMyEvaluation(data)

--     if ok then
--         self.appendTab = {}
--     end
--     -- local ok = ChatManager.Instance:SendMsg(self.currentChannel.channel, str)
--     -- if ok then
--     --     self.EvaluationInputField.text = ""
--     --     self.appendTab = {}
--     -- end
--     return true
-- end