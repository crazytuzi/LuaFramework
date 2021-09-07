ExquisiteShelfShowWindow = ExquisiteShelfShowWindow or BaseClass(BaseWindow)

function ExquisiteShelfShowWindow:__init(model)
    self.model = model
    self.name = "ExquisiteShelfShowWindow"
    self.windowId = WindowConfig.WinID.exquisite_shelf_show_window

    self.resList = {
        {file = AssetConfig.exquisiteshelfshowwindow, type = AssetType.Main},
        {file = AssetConfig.exquisiteshelfshowbg, type = AssetType.Main},
        {file = AssetConfig.midAutumn_textures, type = AssetType.Dep}
    }


    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ExquisiteShelfShowWindow:__delete()
    self.OnHideEvent:Fire()
    if self.tweenIdY ~= nil then
        Tween.Instance:Cancel(self.tweenIdY)
        self.tweenIdY = nil
    end
    if self.tweenIdX ~= nil then
        Tween.Instance:Cancel(self.tweenIdX)
        self.tweenIdX = nil
    end
    if self.buttonEffect ~= nil then
        self.buttonEffect:DeleteMe()
        self.buttonEffect = nil
    end
    if self.firstEffect ~= nil then
         self.firstEffect:DeleteMe()
         self.firstEffect = nil
    end

    if self.tweenTimerId ~= nil then
        LuaTimer.Delete(self.tweenTimerId)
        self.tweenTimerId = nil
    end

    if self.desc1Ext ~= nil then
        self.desc1Ext:DeleteMe()
        self.desc1Ext = nil
    end
    if self.desc2Ext ~= nil then
        self.desc2Ext:DeleteMe()
        self.desc2Ext = nil
    end
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    self:AssetClearAll()
end

function ExquisiteShelfShowWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.exquisiteshelfshowwindow))

    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)

    local main = self.transform:Find("Main")

    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)


    self.descArea = main:Find("DescArea").gameObject
    self.desc1Ext = MsgItemExt.New(main:Find("DescArea/Desc1"):GetComponent(Text), 345,16, 18.7)
    self.desc2Ext = MsgItemExt.New(main:Find("DescArea/Desc2"):GetComponent(Text), 345, 16, 18.7)

    self.bg = main:Find("Bg").gameObject
    self.bg1 = main:Find("Bg1").gameObject

    self.showObj = main:Find("ShowGameObject")
    self.showName = main:Find("ShowGameObject/NameText"):GetComponent(Text)
    self.topText = main:Find("TopBg/Text"):GetComponent(Text)
    self.button = main:Find("DescArea/Button"):GetComponent(Button)
    self.button.onClick:AddListener(function() self:AutoNpc() end)

    self.line = main:Find("DescArea/Line").gameObject
    self.line.transform.anchoredPosition = Vector2(0,-40.5)
   self.showBgParent = main:Find("ShowGameObject/BgParent")
   local bigObj = GameObject.Instantiate(self:GetPrefab(AssetConfig.exquisiteshelfshowbg))
   UIUtils.AddBigbg(self.showBgParent,bigObj)

   main:Find("Title"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "TitleBgCamp")
end

function ExquisiteShelfShowWindow:AutoNpc()
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    SceneManager.Instance.sceneElementsModel:Self_PathToTarget("210040_1",false)
    WindowManager.Instance:CloseWindow(self)
end
function ExquisiteShelfShowWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ExquisiteShelfShowWindow:AddListeners()

end

function ExquisiteShelfShowWindow:RemoveListeners()

end

function ExquisiteShelfShowWindow:OnOpen()
    self:AddListeners()
    self.showName.gameObject:SetActive(false)


    self:BeginRoll()

    self.showObj.transform.anchoredPosition = Vector2(0,-17)
    self:BeginRoll()

end

function ExquisiteShelfShowWindow:OnHide()
    self:RemoveListeners()

    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end


function ExquisiteShelfShowWindow:BeginRoll()
    self.topText.text = string.format("正在筛选本日内阁王者")

    self.baseId = ExquisiteShelfManager.Instance.monsterId

    self.descArea.gameObject:SetActive(false)
    self.bg.gameObject:SetActive(false)

    if self.firstEffect == nil then
        self.firstEffect = BibleRewardPanel.ShowEffect(20418, self.showObj.gameObject.transform, Vector3.one, Vector3(0, 12, -400))
    end
    self.firstEffect:SetActive(true)


    if self.timerId == nil then
        self.timerId = LuaTimer.Add(3000, function() self:EndRoll() self.timerId = nil end)
    end
end

function ExquisiteShelfShowWindow:EndRoll()

    self:InitModel()
    self:ReloadDesc()

    if self.tweenIdX ~= nil then
        Tween.Instance:Cancel(self.tweenIdX)
    end
    if self.tweenIdY ~= nil then
        Tween.Instance:Cancel(self.tweenIdY)
    end

    if self.tweenTimerId ~= nil then
        LuaTimer.Delete(self.tweenTimerId)
    end
    self.tweenTimerId = LuaTimer.Add(1000, function()
        self.tweenIdX = Tween.Instance:MoveLocalX(self.showObj.gameObject, -178, 0.6, function()
                self.descArea:SetActive(true)

            end, LeanTweenType.easeOutQuad).id
        self.tweenIdY = Tween.Instance:MoveLocalY(self.showObj.gameObject, -14, 0.6, function() end, LeanTweenType.easeOutQuad).id
    end)
end


function ExquisiteShelfShowWindow:ReloadDesc()

    -- self.desc1Ext:SetData(self.model.modeString[self.model.mode] or "")
    -- self.desc2Ext:SetData(string.format(self.model.battleString, self.model.titleString[self.model.mode] or ""))
    self.topText.text = string.format("本日内阁王者为:<color='#ffff00'>%s</color>",DataUnit.data_unit[self.baseId].name)
    self.showName.text = DataUnit.data_unit[self.baseId].name
    self.bg.gameObject:SetActive(true)
    self.topText.gameObject:SetActive(true)
    self.showName.gameObject:SetActive(true)
    self.desc2Ext:SetData(DataExquisiteShelf.data_message[self.baseId].msg)
    if self.buttonEffect == nil then
        self.buttonEffect = BibleRewardPanel.ShowEffect(20053, self.button.gameObject.transform, Vector3(1.7,0.7,1), Vector3(-55, -15, -400))
    end
    self.buttonEffect:SetActive(true)
end

function ExquisiteShelfShowWindow:InitModel()
     local setting = {
             name = "MonsterShow"
             ,orthographicSize = 0.4
             ,width = 341
             ,height = 341
             ,offsetY = -0.35
             ,offsetX = -0.02
             ,noDrag = true
        }


    local callback = function(composite)
         self:SetRawImage(composite)
    end

    local roledata = RoleManager.Instance.RoleData
    local BaseData = DataUnit.data_unit[self.baseId]
    local modelData = {type = PreViewType.Npc, skinId = BaseData.skin, modelId = BaseData.res, animationId = BaseData.animation_id, scale = 0.8}

    if self.previewComp == nil then
      self.previewComp = PreviewComposite.New(callback,setting,modelData)
    else
      self.previewComp:Reload(modelData,callback)
      self.previewComp:Show()
    end
end

function ExquisiteShelfShowWindow:SetRawImage(composite)
   local rawImage = composite.rawImage
   rawImage.gameObject:SetActive(true)
   rawImage.transform:SetParent(self.showObj)
   rawImage.transform.localPosition = Vector3(12, 29, 0)
   rawImage.transform.localScale = Vector3(1, 1, 1)
   self.rawImageObj = rawImage.gameObject
   self.showObj.gameObject:SetActive(true)
end

