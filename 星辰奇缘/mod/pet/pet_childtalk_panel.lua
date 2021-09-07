PetChildTalkPanel = PetChildTalkPanel or BaseClass(BasePanel)

function PetChildTalkPanel:__init(model)
    self.model = model
    self.name = "PetChildTalkPanel"

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
end


function PetChildTalkPanel:OnInitCompleted()

end

function PetChildTalkPanel:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
end

function PetChildTalkPanel:InitPanel()
    self.talk_data = {}
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pet_talk_panel))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.gameObject.name = "PetChildTalkPanel"
    self.transform = self.gameObject.transform
    self.maincon = self.transform:Find("Main/Con")
    self.transform:Find("Main").anchoredPosition = Vector2.zero
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:CloseChildTalkPanel() end)
    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:CloseChildTalkPanel() end)
    self:InitInputField()
    self.infoBtn = self.transform:Find("Main/Info")
    self.infoBtn = self.infoBtn:GetComponent(Button) or self.infoBtn.gameObject:AddComponent(Button)
    self.infoBtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.infoBtn.gameObject, itemData = {
            TI18N("1.出场(召唤/闪现)：战斗中召唤孩子或孩子闪现时，100%播放闲聊"),
            TI18N("2.孩子攻击、挨打、死亡、家长倒地、使用药品时，20%几率播放闲聊"),
            TI18N("3.每场战斗每条闲聊最多会播放一次"),
            }})
        end)
    self.maincon:Find("masterdead/DescText"):GetComponent(Text).text = TI18N("家长倒地")
end

function PetChildTalkPanel:Refresh()
    -- body
end

function PetChildTalkPanel:InitInputField()
    for i=0, 6 do
        local baseData = DataChild.data_child_talk[PetManager.Instance.model.currChild.base_id]
        local child = self.maincon:GetChild(i)
        local ipf = child:Find("InputField"):GetComponent(InputField)
        local textcom = ipf.gameObject.transform:Find("Text"):GetComponent(Text)
        local placeholder = ipf.gameObject.transform:Find("Placeholder"):GetComponent(Text)
        ipf.textComponent = textcom
        ipf.placeholder = placeholder
        ipf.interactable = false
        ipf.text = self:ConvetrTo(baseData[self.talk_Key[i]])
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
                PetManager.Instance:Send18634(PetManager.Instance.model.currChild.child_id, PetManager.Instance.model.currChild.platform, PetManager.Instance.model.currChild.zone_id, i+1, data1)
                -- PetManager.Instance:Send10536(PetManager.Instance.model.currChild.id, i+1, data1)
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
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("请先保存修改"))
            end
        end
        btn:GetComponent(Button).onClick:AddListener(editcallback)
        morebtn:GetComponent(Button).onClick:AddListener(function()
            if self.currInputField == ipf and (self.singleface == nil or self.singleface.gameObject == nil) then
                self.singleface = SingleFacePanel.New(ipf, self)
                self.transform:Find("Main").anchoredPosition = Vector2(0,-60+i*50)
            elseif self.currInputField == ipf then
                self.singleface:SetInputField(ipf)
                self.transform:Find("Main").anchoredPosition = Vector2(0,-60+i*50)
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

function PetChildTalkPanel:InitTalkSetting()
    self.talk_data = self.model.childtalk_data.combat_talk
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

function PetChildTalkPanel:ConvetrTo(msg)
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

function PetChildTalkPanel:ConvertToTag_Face2(msg)
    local overface = false
    local faces = {}
    local msgTemp = string.gsub(msg, "<.->", "")
    for faceId in string.gmatch(msgTemp, "#(%d+)") do
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

function PetChildTalkPanel:ResetPos()
    self.transform:Find("Main").anchoredPosition = Vector2.zero
end