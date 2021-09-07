-- ----------------------------------------------------------
-- UI - 真心话大冒险
-- ----------------------------------------------------------
TruthordareVoteDetailsPanel = TruthordareVoteDetailsPanel or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function TruthordareVoteDetailsPanel:__init(model)
    self.model = model
    self.name = "TruthordareVoteDetailsPanel"

    self.resList = {
        {file = AssetConfig.truthordarevotedetailspanel, type = AssetType.Main}
        , {file = AssetConfig.truthordare_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	self.mainTransform = nil

	------------------------------------------------

    self.headList1 = {}
    self.headList2 = {}
    self.headList3 = {}
	------------------------------------------------

    self._Update = function() 
        self:Update() 
    end

    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function TruthordareVoteDetailsPanel:__delete()
    self:OnHide()

    if self.chatExtPanel ~= nil then
        self.chatExtPanel:DeleteMe()
        self.chatExtPanel = nil
    end

    self:AssetClearAll()
end

function TruthordareVoteDetailsPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.truthordarevotedetailspanel))
    self.gameObject.name = "TruthordareVoteDetailsPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")
    self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClickClose() end)

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.itemCloner = self.mainTransform:FindChild("Item").gameObject
    self.itemCloner:SetActive(false)

    self.panel1 = self.mainTransform:FindChild("Panel1")
    self.panel1:Find("Bg"):GetComponent(Image).color = Color(215/255, 201/255, 160/255, 1)
    self.panel1_text = self.panel1:FindChild("Text"):GetComponent(Text)
    self.panel1_text2 = self.panel1:FindChild("Text2"):GetComponent(Text)
    self.panel1_barText2 = self.panel1:FindChild("BarBg/Text2"):GetComponent(Text)
    self.panel1_bar = self.panel1:FindChild("BarBg/Bar")
    self.panel1_container = self.panel1:FindChild("Mask/Container")

    local votebar1Rect = self.panel1_bar:GetComponent(RectTransform)
    votebar1Rect.anchorMax = Vector2(0, 0.5)
    votebar1Rect.anchorMin = Vector2(0, 0.5)
    votebar1Rect.anchoredPosition = Vector3(2, 1.5, 0)
    votebar1Rect.sizeDelta = Vector2(195,27)
    votebar1Rect.pivot = Vector2(0,0.5)



    self.panel2 = self.mainTransform:FindChild("Panel2")
    self.panel2:Find("Bg"):GetComponent(Image).color = Color(215/255, 201/255, 160/255, 1)
    self.panel2_text = self.panel2:FindChild("Text"):GetComponent(Text)
    self.panel2_text2 = self.panel2:FindChild("Text2"):GetComponent(Text)
    local barpanel2 = self.panel2:FindChild("BarBg"):GetComponent(Image)
    barpanel2.sprite = self.assetWrapper:GetSprite(AssetConfig.truthordare_textures, "BarBg2")
    barpanel2.type = Image.Type.Sliced
    self.panel2_barText2 = self.panel2:FindChild("BarBg/Text2"):GetComponent(Text)
    self.panel2_bar = self.panel2:FindChild("BarBg/Bar")
    self.panel2_container = self.panel2:FindChild("Mask/Container")

    local votebar2Rect = self.panel2_bar:GetComponent(RectTransform)
    votebar2Rect.anchorMax = Vector2(0, 0.5)
    votebar2Rect.anchorMin = Vector2(0, 0.5)
    votebar2Rect.anchoredPosition = Vector3(2, 1.5, 0)
    votebar2Rect.sizeDelta = Vector2(196,27)
    votebar2Rect = Vector2(0,0.5)

    self.panel3 = self.mainTransform:FindChild("Panel3")
    self.panel3:Find("Bg"):GetComponent(Image).color = Color(215/255, 201/255, 160/255, 1)
    self.panel3_text = self.panel3:FindChild("Text"):GetComponent(Text)
    self.panel3_text2 = self.panel3:FindChild("Text2"):GetComponent(Text)
    self.panel3_barText2 = self.panel3:FindChild("BarBg/Text2"):GetComponent(Text)
    self.panel3_container = self.panel3:FindChild("Mask/Container")

    self.panel1_text.text = TI18N("没有通过票，你们都是坏人~")
    self.panel1_text2.text = TI18N("好评撒花")

    self.panel2_text.text = TI18N("我的表演厉害吧，一个鸡蛋都没有！")
    self.panel2_text2.text = TI18N("差评扔蛋")

    self.panel3_text2.text = TI18N("吃瓜围观")
    self.panel3_text.text = TI18N("山顶的朋友，快举起你的手来！")

    self.OnHideEvent:AddListener(function() self.previewComposite:Hide() end)
    self.OnOpenEvent:AddListener(function() self.previewComposite:Show() end)
    ----------------------------

    self:OnShow()
    self:ClearMainAsset()
end

function TruthordareVoteDetailsPanel:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function TruthordareVoteDetailsPanel:OnShow()
    self:Update()

    TruthordareManager.Instance.OnQuestionInfoUpdate:Remove(self._Update)
    TruthordareManager.Instance.OnQuestionInfoUpdate:Add(self._Update)
end

function TruthordareVoteDetailsPanel:OnHide()
    TruthordareManager.Instance.OnQuestionInfoUpdate:Remove(self._Update)
end

function TruthordareVoteDetailsPanel:Update()
    self.panel1_barText2.text = tostring(#self.model.flower_list)
    self.panel2_barText2.text = tostring(#self.model.egg_list)
    self.panel3_barText2.text = tostring(#self.model.call_list)
    if #self.model.flower_list + #self.model.egg_list == 0 then
        --self.panel1_bar.localScale = Vector3(0, 1, 1)
        --self.panel2_bar.localScale = Vector3(0, 1, 1)
        self.panel1_bar.sizeDelta = Vector2(25,27)
        self.panel2_bar.sizeDelta = Vector2(25,27)
    else
        self.panel1_bar.sizeDelta = Vector2(#self.model.flower_list / (#self.model.flower_list + #self.model.egg_list) * 195,27)
        self.panel2_bar.sizeDelta = Vector2(#self.model.egg_list / (#self.model.flower_list + #self.model.egg_list) * 195,27)

        --self.panel1_bar.localScale = Vector3(#self.model.flower_list / (#self.model.flower_list + #self.model.egg_list), 1, 1)
        --self.panel2_bar.localScale = Vector3(#self.model.egg_list / (#self.model.flower_list + #self.model.egg_list), 1, 1)
    end
    local list = self.model.flower_list 
    self.panel1_text.gameObject:SetActive(#list == 0)
    for i,v in ipairs(list) do
        local head = self.headList1[i]
        if head == nil then
            local item = GameObject.Instantiate(self.itemCloner).transform
            item:SetParent(self.panel1_container)
            item.localScale = Vector3.one
            item.localPosition = Vector3.zero

            local headSlot = HeadSlot.New()
            headSlot:SetRectParent(item:Find("RoleImage"))
            headSlot:HideSlotBg(true, 0)
            local sexImage = item:Find("Sex"):GetComponent(Image)
            local nameText = item:Find("NameText"):GetComponent(Text)
            head = { gameObject = item.gameObject, headSlot = headSlot, sexImage = sexImage, nameText = nameText }
            self.headList1[i] = head
        end

        head.gameObject:SetActive(true)
        head.headSlot:SetAll(v, {isSmall = true})
        head.nameText.text = v.role_name
        head.sexImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, (v.sex == 0 and "IconSex0" or "IconSex1"))
    end

    for i = #list + 1, #self.headList1 do
        local head = self.headList1[i]
        head.gameObject:SetActive(false)
    end

    list = self.model.egg_list 
    self.panel2_text.gameObject:SetActive(#list == 0)
    for i,v in ipairs(list) do
        local head = self.headList2[i]
        if head == nil then
            local item = GameObject.Instantiate(self.itemCloner).transform
            item:SetParent(self.panel2_container)
            item.localScale = Vector3.one
            item.localPosition = Vector3.zero

            local headSlot = HeadSlot.New()
            headSlot:SetRectParent(item:Find("RoleImage"))
            headSlot:HideSlotBg(true, 0)
            local sexImage = item:Find("Sex"):GetComponent(Image)
            local nameText = item:Find("NameText"):GetComponent(Text)
            head = { gameObject = item.gameObject, headSlot = headSlot, sexImage = sexImage, nameText = nameText }
            self.headList2[i] = head
        end

        head.gameObject:SetActive(true)
        head.headSlot:SetAll(v, {isSmall = true})
        head.nameText.text = v.role_name
        head.sexImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, (v.sex == 0 and "IconSex0" or "IconSex1"))
    end

    for i = #list + 1, #self.headList2 do
        local head = self.headList2[i]
        head.gameObject:SetActive(false)
    end

    list = self.model.call_list 
    self.panel3_text.gameObject:SetActive(#list == 0)
    for i,v in ipairs(list) do
        local head = self.headList3[i]
        if head == nil then
            local item = GameObject.Instantiate(self.itemCloner).transform
            item:SetParent(self.panel3_container)
            item.localScale = Vector3.one
            item.localPosition = Vector3.zero

            local headSlot = HeadSlot.New()
            headSlot:SetRectParent(item:Find("RoleImage"))
            headSlot:HideSlotBg(true, 0)
            local sexImage = item:Find("Sex"):GetComponent(Image)
            local nameText = item:Find("NameText"):GetComponent(Text)
            head = { gameObject = item.gameObject, headSlot = headSlot, sexImage = sexImage, nameText = nameText }
            self.headList3[i] = head
        end

        head.gameObject:SetActive(true)
        head.headSlot:SetAll(v, {isSmall = true})
        head.nameText.text = v.role_name
        head.sexImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, (v.sex == 0 and "IconSex0" or "IconSex1"))
    end

    for i = #list + 1, #self.headList3 do
        local head = self.headList3[i]
        head.gameObject:SetActive(false)
    end
    -- self.model.egg_list
    -- self.model.call_list
end
