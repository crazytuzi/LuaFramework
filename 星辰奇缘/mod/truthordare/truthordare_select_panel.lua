
--  选择真心话或者大冒险界面

TruthordareSelectPanel = TruthordareSelectPanel or BaseClass(BaseView)

function TruthordareSelectPanel:__init(parent)
	self.parent = parent
    self.resList = {
        {file = AssetConfig.truthordareselectpanel, type = AssetType.Main}
        , {file = AssetConfig.TruthordareSelected, type = AssetType.Dep}
        , {file = AssetConfig.TruthordareTI18NChoose1, type = AssetType.Dep}
        , {file = AssetConfig.TruthordareTI18NChoose2, type = AssetType.Dep}
        , {file = string.format(AssetConfig.effect, 20516), type = AssetType.Main}
    }
    self.selectType = 1  --1 真心话  2 大冒险
    self.time = 30

    self._Update = function() self:Update() end

    self:LoadAssetBundleBatch()
end

function TruthordareSelectPanel:__delete()
    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
        self.timer = nil
    end

    TruthordareManager.Instance.OnUpdate:Remove(self._Update)

    if self.miniTweenId ~= nil then
        Tween.Instance:Cancel(self.miniTweenId)
        self.miniTweenId = nil
    end
 
    if self.leftImg ~= nil then
        BaseUtils.ReleaseImage(self.leftImg)
    end
    if self.rightImg ~= nil then
        BaseUtils.ReleaseImage(self.rightImg)
    end
    if self.leftImgSelect ~= nil then
        BaseUtils.ReleaseImage(self.leftImgSelect)
    end
    if self.rightImgSelect ~= nil then
        BaseUtils.ReleaseImage(self.rightImgSelect)
    end

    if self.headSlot ~= nil then
        self.headSlot:DeleteMe()
        self.headSlot = nil
    end
end

function TruthordareSelectPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.truthordareselectpanel))
    self.gameObject.name = "TruthordareSelectPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.transform:GetComponent(RectTransform).anchoredPosition = Vector2(355, 15)

    self.transform:Find("ExitButton"):GetComponent(Button).onClick:AddListener(function() self.parent:MiniPanel() end)
    self.transform:Find("MiniButton"):GetComponent(Button).onClick:AddListener(function() self.parent:MiniPanel(true) end)

    self.roundText = self.transform:Find("RoundText"):GetComponent(Text)
    self.upDesc = self.transform:Find("Text"):GetComponent(Text)

    self.transform:Find("Button1"):GetComponent(Button).onClick:AddListener(function() self:OnRuleButton() end)
    self.transform:Find("Button2"):GetComponent(Button).onClick:AddListener(function() self:OnEditorButton() end)

    self.leftArea = self.transform:Find("LeftArea")
    self.leftImg = self.leftArea:GetComponent(Image)
    self.leftImg.sprite = self.assetWrapper:GetSprite(AssetConfig.TruthordareTI18NChoose2, "TruthordareTI18NChoose2")
    self.leftImgSelect = self.transform:Find("LeftArea/Select"):GetComponent(Image)
    self.leftImgSelect.sprite = self.assetWrapper:GetSprite(AssetConfig.TruthordareSelected, "TruthordareChooseSelected")
    self.leftImgSelect.gameObject:SetActive(false)
    self.leftArea = self.transform:Find("LeftArea"):GetComponent(Button)
    --self.leftArea.onClick:AddListener(function() self:OnSelect(0) end)
    self.rightArea = self.transform:Find("RightArea")
    self.rightImg = self.rightArea:GetComponent(Image)
    self.rightImg.sprite = self.assetWrapper:GetSprite(AssetConfig.TruthordareTI18NChoose1, "TruthordareTI18NChoose1")
    self.rightImgSelect = self.transform:Find("RightArea/Select"):GetComponent(Image)
    self.rightImgSelect.sprite = self.assetWrapper:GetSprite(AssetConfig.TruthordareSelected, "TruthordareChooseSelected")
    self.rightImgSelect.gameObject:SetActive(false)
    self.rightArea = self.transform:Find("RightArea"):GetComponent(Button)
    --self.rightArea.onClick:AddListener(function() self:OnSelect(1) end)

    self.myself = self.transform:Find("Self")
    self.sureBtn = self.transform:Find("Self/SureButton"):GetComponent(Button)
    self.sureBtn.onClick:AddListener(function() self:OnSureBtn() end)
    self.clockText = self.transform:Find("Self/Clock/Text"):GetComponent(Text)
    
    self.other = self.transform:Find("Other")
    local LuckyMan = self.transform:Find("Other/BoomMan")
    self.headSlot = HeadSlot.New()
    self.headSlot:SetRectParent(LuckyMan:Find("RoleImage"))
    self.sexImage = LuckyMan:Find("Sex"):GetComponent(Image)
    self.nameText = LuckyMan:Find("NameText"):GetComponent(Text)
    self.talkText = self.transform:Find("Other/Talk/Text"):GetComponent(Text)

    self.effect20516 = GameObject.Instantiate(self:GetPrefab(string.format(AssetConfig.effect, 20516)))
    self.effect20516.transform:SetParent(self.transform)
    self.effect20516.transform.localScale = Vector3.one
    self.effect20516.transform.localPosition = Vector3(200, -160, -300)

    self:SetData()
    self:ClearMainAsset()
end

function TruthordareSelectPanel:MiniPanel(andCloseChatPanel)
    if self.miniTweenId == nil then
        self.miniTweenId = Tween.Instance:Scale(self.gameObject, Vector3.zero, 0.2, 
            function() 
                self.miniMark = true 
                self:SetActive(false)
                self.miniTweenId = nil 
                if andCloseChatPanel then
                    if ChatManager.Instance.model.chatWindow ~= nil and not BaseUtils.isnull(ChatManager.Instance.model.chatWindow.transform) then
                        ChatManager.Instance.model.chatWindow:ClickShow()
                    end
                end
            end, LeanTweenType.easeOutQuart).id
    end
end

function TruthordareSelectPanel:SetData(data)
    self.data = data
    if BaseUtils.isnull(self.gameObject) then
        return
    end

    self:SetActive(true)
end

function TruthordareSelectPanel:SetActive(active)
    self.isActive = true
    if not BaseUtils.isnull(self.gameObject) then
        self.gameObject:SetActive(active)
        if self.timer ~= nil then
            LuaTimer.Delete(self.timer)
            self.timer = nil
        end
        if active then
            self.transform.localScale = Vector3.one
            self.time = TruthordareManager.Instance.model.time - BaseUtils.BASE_TIME

            TruthordareManager.Instance.OnUpdate:Remove(self._Update)
            TruthordareManager.Instance.OnUpdate:Add(self._Update)
            self:Update()
            self.effect20516:SetActive(false)
            self.effect20516:SetActive(true)
        else
            TruthordareManager.Instance.OnUpdate:Remove(self._Update)
        end
    end
end

function TruthordareSelectPanel:Update()
    local model = TruthordareManager.Instance.model
    self.roundText.text = string.format(TI18N("当前第%s轮 共%s轮"), model.now_round, model.max_round)

    local isLuckyMan = model:IsLuckyMan()
    if isLuckyMan then
        self.other.gameObject:SetActive(false)
        self.myself.gameObject:SetActive(true)
        self.leftImgSelect.gameObject:SetActive(true)
        self.leftArea.transform.localScale = Vector2(1.1,1.1)
        self.rightArea.transform.localScale = Vector2.one
        self.leftArea.onClick:RemoveAllListeners()
        self.rightArea.onClick:RemoveAllListeners()
        self.leftArea.onClick:AddListener(function() self:OnSelect(0) end)
        self.rightArea.onClick:AddListener(function() self:OnSelect(1) end)
    else
        self.other.gameObject:SetActive(true)
        self.myself.gameObject:SetActive(false)
        self.rightArea.onClick:RemoveAllListeners()
        self.leftArea.onClick:RemoveAllListeners()
        self:SetLuckyData()
    end

    if self.timer == nil then
        self.timer = LuaTimer.Add(1000, 1000, function() self:OnTimer() end)
    end
end

function TruthordareSelectPanel:SetLuckyData()
    
    local luckyData = TruthordareManager.Instance.model.luckyMan
    if luckyData == nil then
        return
    end
    self.upDesc.text = string.format(TI18N("%s正在艰难的选择中..."),luckyData.name)
    self.headSlot.gameObject:SetActive(true)
    self.headSlot:HideSlotBg(true, 0)
    luckyData.id = luckyData.rid
    self.headSlot:SetAll(luckyData, {isSmall = true})
    self.sexImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, (luckyData.sex == 0 and "IconSex0" or "IconSex1"))
    self.nameText.text = luckyData.name
    self.talkText.text = TI18N("怎么办,选什么好呢？")
end

function TruthordareSelectPanel:OnSelect(index)
    if index == 0 then
        self.leftArea.transform.localScale = Vector2(1.1,1.1)
        self.rightArea.transform.localScale = Vector2.one
        self.leftImgSelect.gameObject:SetActive(true)
        self.rightImgSelect.gameObject:SetActive(false)
        self.selectType = 1
    elseif index == 1 then
        self.leftArea.transform.localScale = Vector2.one
        self.rightArea.transform.localScale = Vector2(1.1,1.1)
        self.leftImgSelect.gameObject:SetActive(false)
        self.rightImgSelect.gameObject:SetActive(true)
        self.selectType = 2
    end
end

function TruthordareSelectPanel:OnSureBtn()
    print("发送协议15919".."type = "..self.selectType)
    TruthordareManager.Instance:Send19519(self.selectType)
end

function TruthordareSelectPanel:OnTimer()
    if self.time == 0 then
        self:OnSureBtn()
        if self.timer ~= nil then
            LuaTimer.Delete(self.timer)
            self.timer = nil
        end
    else
        self.time = self.time - 1
        self.clockText.text = self.time

        if not TruthordareManager.Instance.model:IsLuckyMan() then 
            local luckyData = TruthordareManager.Instance.model.luckyMan
            if luckyData == nil then
                return
            end
            local str = "..."
            if self.time % 3 == 1 then
                str = ".."
            elseif self.time % 3 == 2 then 
                str = "."
            end
            self.upDesc.text = string.format(TI18N("%s正在艰难的选择中%s"),luckyData.name,str)
        end
    end
end

function TruthordareSelectPanel:OnRuleButton()
    self.parent:OpenGuidePanelFun()
end

function TruthordareSelectPanel:OnEditorButton()
    TruthordareManager.Instance.model:OpenEditorWindow()
end
