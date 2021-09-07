--作者:hzf
--02/28/2017 19:31:39
--功能:珍宝迷城事件

TreasureMazeEventPanel = TreasureMazeEventPanel or BaseClass(BasePanel)
function TreasureMazeEventPanel:__init(model)
	self.model = model
    self.Mgr = TreasureMazeManager.Instance
	self.resList = {
        {file = AssetConfig.mazeeventpanel, type = AssetType.Main}
		,{file = "textures/ui/bigbg/stonebg.unity3d", type = AssetType.Main}
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
    self.slotlist = {}
end

function TreasureMazeEventPanel:__delete()
    for k,v in pairs(self.slotlist) do
        v:DeleteMe()
    end
    self.slotlist = {}
	if self.previewCom ~= nil then
		self.previewCom:DeleteMe()
		self.previewCom = nil
	end
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function TreasureMazeEventPanel:OnHide()

end

function TreasureMazeEventPanel:OnOpen()

end

function TreasureMazeEventPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.mazeeventpanel))
	self.gameObject.name = "TreasureMazeEventPanel"
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.transform = self.gameObject.transform
    self.transform:SetAsFirstSibling()

	self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function()
        self.model:CloseEventPanel()
    end)
	self.MainCon = self.transform:Find("MainCon")
	self.bg = self.transform:Find("MainCon/bg")
	self.Title = self.transform:Find("MainCon/Title")
	self.TitleText = self.transform:Find("MainCon/Title/Text"):GetComponent(Text)
    self.CancelButton = self.transform:Find("MainCon/CancelButton"):GetComponent(Button)
    self.CancelButton.gameObject:SetActive(false)
	self.CancelButton.onClick:AddListener(function()
        self:OnCancel()
    end)
	self.CancelButtonText = self.transform:Find("MainCon/CancelButton/Text"):GetComponent(Text)
    self.OkButton = self.transform:Find("MainCon/OkButton"):GetComponent(Button)
    self.OkButton.gameObject:SetActive(false)
	self.OkButton.onClick:AddListener(function()
        self:OnOk()
    end)
    self.OkButtonText = self.transform:Find("MainCon/OkButton/Text"):GetComponent(Text)
    self.ConfirmButton = self.transform:Find("MainCon/ConfirmButton"):GetComponent(Button)
    self.ConfirmButton.gameObject:SetActive(false)
    self.ConfirmButton.onClick:AddListener(function()
        self:OnConfirm()
    end)
	self.ConfirmButtonText = self.transform:Find("MainCon/ConfirmButton/Text"):GetComponent(Text)
	self.TopText = self.transform:Find("MainCon/Text"):GetComponent(Text)
    self.TopEXT = MsgItemExt.New(self.TopText, 352, 18, 29)
    self.DescText = self.transform:Find("MainCon/DescText"):GetComponent(Text)
    self.DescText.alignment = TextAnchor.MiddleCenter
    -- self.DescEXT = MsgItemExt.New(self.DescText, 377, 18, 29)
    self.transform:Find("MainCon/Slotbg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite("textures/ui/bigbg/stonebg.unity3d", "StoneBg")
    self.Slot = self.transform:Find("MainCon/Slotbg/Slot")
	self.NameText = self.transform:Find("MainCon/Slotbg/NameText"):GetComponent(Text)
	self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function()
        self.model:CloseEventPanel()
    end)

    self.data = self.openArgs
    self:LoadData()
end

function TreasureMazeEventPanel:OnConfirm()
    if self.data.id ~= nil then
        if self.data.id == 8 then
            if self.data.special_id ~= 0 then
                self.Mgr:Send18814(self.data.x, self.data.y)
            end
        end
    else
        if self.data.e_id == 12 then
            if not self.data.isfirst then
                self.Mgr:Send18814(self.data.e_x, self.data.e_y)
            end
        end
    end
    self.model:CloseEventPanel()
end

function TreasureMazeEventPanel:OnOk()
    if self.data.id ~= nil then
       -- if self.data.id == 7 then
       --      self.Mgr:Send18814(self.data.x, self.data.y)
       --  elseif self.data.id == 10 then
       --      self.Mgr:Send18814(self.data.x, self.data.y)
       --  end
    else
        if self.data.e_id == 12 then

        end
    end
    self.model:CloseEventPanel()
end

function TreasureMazeEventPanel:OnCancel()
    if self.data.id ~= nil then
       if self.data.id == 7 then
            self.Mgr:Send18814(self.data.x, self.data.y)
        elseif self.data.id == 10 then
            self.Mgr:Send18814(self.data.x, self.data.y)
        end
    end
    self.model:CloseEventPanel()
end

function TreasureMazeEventPanel:LoadData()
    BaseUtils.dump(self.data, "数据")
    if self.data.id ~= nil then
        if self.data.id == 8 then
            if self.data.special_id == 0 then
                self.TitleText.text = TI18N("龙猫回家")
                self.TopEXT:SetData(TI18N("龙猫君：我..我..迷路了{face_1, 21}"))
                self.DescText.text = TI18N("找到龙猫君的小窝，可获得丰厚奖励")
                self.ConfirmButtonText.text = TI18N("确定")
            else
                self.TitleText.text = TI18N("龙猫回家")
                self.TopEXT:SetData(TI18N("龙猫君：找到家了{face_1, 21}"))
                self.DescText.text = TI18N("找到龙猫君的小窝，可获得丰厚奖励")
                self.ConfirmButtonText.text = TI18N("收下")
            end
            if self.data.reward[1] ~= nil then
                local data = {id = self.data.reward[1].base_id, num = self.data.reward[1].num}
                self:CreatSlot(data, self.Slot)
            else
                self:CreatSlot({id = 21715, num = 1}, self.Slot)
            end
            self.ConfirmButton.gameObject:SetActive(true)
            self:LoadPreview(73061)
        elseif self.data.id == 7 then
            self.TitleText.text = TI18N("浣熊献宝")
            local itemdata = DataItem.data_get[self.data.reward[1].base_id]
            self.TopEXT:SetData(TI18N("浣熊君：给你这个！{face_1, 36}"))
            self.DescText.text = TI18N("每次开启石板，浣熊君会尝试更换礼物，遇到好东西就收下吧")
            self.CancelButtonText.text = TI18N("接受礼物")
            self.CancelButton.gameObject:SetActive(true)
            self.OkButtonText.text = TI18N("暂时不理")
            self.OkButton.gameObject:SetActive(true)
            local data = {id = self.data.reward[1].base_id, num = self.data.reward[1].num}
            self:CreatSlot(data, self.Slot)
            self:LoadPreview(73060)
        elseif self.data.id == 9 then
            self.TitleText.text = TI18N("解救")
            local itemdata = DataItem.data_get[self.data.reward[1].base_id]
            self.TopEXT:SetData(TI18N("浣熊君：给你这个！{face_1, 36}"))
            self.DescText.text = TI18N("每次开启石板，浣熊君会尝试更换礼物，遇到好东西就收下吧")
            self.CancelButtonText.text = TI18N("暂时不理")
            self.CancelButton.gameObject:SetActive(true)
            self.OkButtonText.text = TI18N("接受礼物")
            self.OkButton.gameObject:SetActive(true)
            self:LoadPreview(73060)
        elseif self.data.id == 10 then
            self.TitleText.text = TI18N("点石成金")
            local itemdata = DataItem.data_get[self.data.reward[1].base_id]
            self.TopEXT:SetData(TI18N("金钱狐：我可以点石成金。敲碎那些石板，我可以帮你炼成金币！"))
            self.DescText.text = TI18N("奖励将在解锁终点后发放")
            -- self.CancelButtonText.text = TI18N("领取")
            -- self.CancelButton.gameObject:SetActive(true)
            -- self.OkButtonText.text = TI18N("确定")
            -- self.OkButton.gameObject:SetActive(true)
            self.ConfirmButtonText.text = TI18N("确定")
            self.ConfirmButton.gameObject:SetActive(true)
            local data = {id = self.data.reward[1].base_id, num = self.data.reward[1].num}
            self:CreatSlot(data, self.Slot)
            self:LoadPreview(73062)
        end
    else
        print("到这里来了")
        if self.data.e_id == 12 then
            self.TitleText.text = TI18N("抓住顽皮猴")
            if self.data.isfirst then
                self.TopEXT:SetData(TI18N("顽皮猴：来抓我呀~来抓我呀{face_1, 22}"))
            else
                self.TopEXT:SetData(TI18N("顽皮猴：没地方跑了，这些给你，别揍我{face_1, 11}"))
            end
            self.DescText.text = TI18N("抓住了猴子领取奖励")
            self.ConfirmButton.gameObject:SetActive(true)
            if self.data.isfirst then
                -- self:CreatSlot({id = 21715, num = 1}, self.Slot)
                local data = {id = self.data.e_reward[1].e_base_id, num = self.data.e_reward[1].e_num}
                self:CreatSlot(data, self.Slot)
                self.ConfirmButtonText.text = TI18N("确定")
            else
                local data = {id = self.data.e_reward[1].e_base_id, num = self.data.e_reward[1].e_num}
                self:CreatSlot(data, self.Slot)
                self.ConfirmButtonText.text = TI18N("领取")
            end
            self:LoadPreview(73063)
        end
    end
end



function TreasureMazeEventPanel:LoadPreview(base_id)
    local unit_data = DataUnit.data_unit[base_id]
    local setting = {
        name = "TreasureMazeEventPanel"
        ,orthographicSize = 0.4
        ,width = 256
        ,height = 256
        ,offsetY = -0.4
    }
    if base_id == 73060 then
        setting = {
            name = "TreasureMazeEventPanel"
            ,orthographicSize = 0.65
            ,width = 256
            ,height = 256
            ,offsetY = -0.4
        }
    end
    local modelData = {type = PreViewType.Npc, skinId = unit_data.skin, modelId = unit_data.res, animationId = unit_data.animation_id, scale = 1}
    self.preview_loaded = function(com)
        self:PreviewLoaded(com)
    end
    if self.previewCom == nil then
        self.previewCom = PreviewComposite.New(self.preview_loaded, setting, modelData)

        -- 有缓存的窗口要写这个
        -- self.OnHideEvent:AddListener(function() self.previewCom:Hide() end)
        -- self.OnOpenEvent:AddListener(function() self.previewCom:Show() end)
    else
        if self.previewCom.modelData.modelId == modelData.modelId and self.previewCom.modelData.skinId == modelData.skinId then
            return
        else
            self.previewCom:Reload(modelData, self.preview_loaded)
        end
    end

end


function TreasureMazeEventPanel:PreviewLoaded(composite)
    local rawImage = composite.rawImage
    if rawImage ~= nil then
        self.rawImage = rawImage
        rawImage.transform:SetParent(self.transform)
        rawImage.transform.anchoredPosition = Vector3(-289, -121, 0)
        local canvasG = self.rawImage.transform:GetComponent(CanvasGroup) or self.rawImage.transform.gameObject:AddComponent(CanvasGroup)
        canvasG.blocksRaycasts = false
        rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform.localRotation = Quaternion.identity
        composite.tpose.transform:Rotate(Vector3(0, 315, 0))
        -- self.preview.texture = rawImage.texture
    end
end


function TreasureMazeEventPanel:CreatSlot(data, parent)
    local slot = ItemSlot.New()
    local info = ItemData.New()
    local base = DataItem.data_get[data.id]
    if base == nil then
        Log.Error("道具id配错():[baseid:" .. tostring(data.id) .. "]")
    end
    self.NameText.text = ColorHelper.color_item_name(base.quality, base.name)
    -- self.NameText.text = base.name
    info:SetBase(base)
    info.quantity = data.num
    local extra = {inbag = false, nobutton = true}
    slot:SetAll(info, extra)
    table.insert(self.slotlist, slot)
    UIUtils.AddUIChild(parent.gameObject,slot.gameObject)
end