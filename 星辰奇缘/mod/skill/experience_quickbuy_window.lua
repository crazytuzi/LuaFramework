-- @author zyh
ExerciseQuickBuyWindow = ExerciseQuickBuyWindow or BaseClass(BaseWindow)

function ExerciseQuickBuyWindow:__init(model)
    self.model = model
    self.name = "ExerciseQuickBuyWindow"

    self.windowId = WindowConfig.WinID.exercisequickbuywindow
    self.resList = {
        {file = AssetConfig.exercise_quickbuy_window, type = AssetType.Main}
        ,{file = AssetConfig.exercise_textures, type = AssetType.Dep}
        --,{file  =  AssetConfig.FashionBg, type  =  AssetType.Dep}
        --, {file = AssetConfig.pet_textures, type = AssetType.Dep}
    }
    self.OnOpenEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:OnShow()
    end)
    self.itemListSlot = {}
    self._UpdateWindow = function() self:UpdateWindow() end
end

function ExerciseQuickBuyWindow:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:OnShow()
end

function ExerciseQuickBuyWindow:OnShow()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._UpdateWindow)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self._UpdateWindow)

    SkillManager.Instance.OnUpdateDoublePoint:RemoveListener(self._UpdateWindow)
    SkillManager.Instance.OnUpdateDoublePoint:AddListener(self._UpdateWindow)
    self:UpdateTime()

end

function ExerciseQuickBuyWindow:UpdateTime()
    local time = SkillManager.Instance.sq_double - BaseUtils.BASE_TIME
    local str = nil
    if time < 3600 and time > 0 then
        str = string.format(TI18N("剩余%s分钟"), tostring(math.ceil(time/60)))
    elseif time < 3600 * 10 and time > 0 then
        str = string.format(TI18N("剩余%s小时%s分钟"), tostring(math.floor(time/3600)),tostring(math.floor(time%3600/60)))
    elseif time < 3600 * 24 and time > 0 then
        str = string.format(TI18N("剩余%s小时"), tostring(math.floor(time/3600)))
    elseif time < 0 then
        str = "未开启加成"
    else
        str = string.format(TI18N("剩余%s天"), tostring(math.floor(time/3600/24)))
    end
    self.timeText.text = str
end

function ExerciseQuickBuyWindow:__delete()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self._UpdateWindow)
    SkillManager.Instance.OnUpdateDoublePoint:RemoveListener(self._UpdateWindow)
    for i,v in ipairs(self.itemListSlot) do
        if v ~= nil then
            v:DeleteMe()
        end
    end
    self.itemListSlot = nil

    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end

    if self.itemSlot ~= nil then
        self.itemSlot:DeleteMe()
        self.itemSlot = nil
    end


    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
end

function ExerciseQuickBuyWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.exercise_quickbuy_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function()
                WindowManager.Instance:CloseWindow(self)
            end)

    self.content = self.transform:Find("Main/Content")
    local icon = self.content:Find("DescImage/Icon").gameObject
    self.imgLoader = SingleIconLoader.New(icon)
    self.imgLoader:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.exercise_textures,"exercise"))

    self.descText1 = self.content:Find("DescText1"):GetComponent(Text)
    self.descText1.text = TI18N("获得妖精的祝福，参与各类活动可额外获得<color='#ffff00'>30%</color>的历练值")

    self.timeText = self.content:Find("DescImage/TimeText"):GetComponent(Text)

    self.imgItem = self.content:Find("ItemSlot").gameObject
    self.itemSlot = ItemSlot.New(self.imgItem)
    local itemData = ItemData.New()
    self.baseData = DataItem.data_get[23838]
    itemData:SetBase(self.baseData)
    self.itemSlot:SetAll(itemData)
    self.buttonImage = self.content:Find("Button/Image").gameObject

    self.btn = self.content:Find("Button"):GetComponent(Button)
    self.btn.onClick:AddListener(function()
                self:OnClickGetExerciseQuickBuyWindow()
            end)
    self.btnText = self.content:Find("Button/Text"):GetComponent(Text)
    self.btnText.text = 20

    self.remindText = self.content:Find("Text"):GetComponent(Text)
    self:DoClickPanel()
end

function ExerciseQuickBuyWindow:DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                    WindowManager.Instance:CloseWindow(self)
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end

function ExerciseQuickBuyWindow:OnClickGetExerciseQuickBuyWindow()


                      local num = BackpackManager.Instance:GetItemCount(23838)
                      if num > 0 then
                          local item_data = BackpackManager.Instance:GetItemByBaseid(23838)
                           BackpackManager.Instance:Use(item_data[1].id, 1,23838)
                      else
                          BuyManager.Instance:ShowQuickBuy({[23838] = {need = 1}})
                      end

end


function ExerciseQuickBuyWindow:OnClickClose()
    self.model:CloseMain()
end

function ExerciseQuickBuyWindow:UpdateWindow()
    local num = BackpackManager.Instance:GetItemCount(23838)
    if num > 0 then
            self.btnText.text = "补充"
            self.btnText.transform.anchoredPosition = Vector2(0,-1)
            self.buttonImage.gameObject:SetActive(false)
    else
            self.btnText.text = 20
            self.btnText.transform.anchoredPosition = Vector2(-13,-1)
            self.buttonImage.gameObject:SetActive(true)
    end
    self:UpdateTime()
end

