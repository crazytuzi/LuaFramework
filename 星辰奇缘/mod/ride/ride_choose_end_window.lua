--2017/10/30
--zyh(宠物选择界面)
RideChooseEndWindow = RideChooseEndWindow or BaseClass(BaseWindow)

function RideChooseEndWindow:__init(model)
    self.model = model
    self.mgr = RideChooseEndWindow.Instance

    self.resList = {
       {file = AssetConfig.ride_choos_end_window,type = AssetType.Main,holdTime = 5}
      ,{file = AssetConfig.ride_choose_textures,type = AssetType.Dep}
      ,{file = AssetConfig.ride_choose_end_bigbg,type = AssetType.Dep}
      ,{file = AssetConfig.ride_choose_end_bigText,type = AssetType.Dep}
      ,{file = AssetConfig.ride_choose_end_bigRabbit,type = AssetType.Dep}
      ,{file = AssetConfig.rolebgnew,type = AssetType.Dep}
    }
    self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.windowId = WindowConfig.WinID.RideChooseEndWindow

    self.extra = {inbag = false, nobutton = true}
    self.effTimerId = nil
end

function RideChooseEndWindow:__delete()
    self:OnHide()

     if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
     end
     self:AssetClearAll()

end

function RideChooseEndWindow:RemoveListeners()

end

function RideChooseEndWindow:AddListeners()

end

function RideChooseEndWindow:OnHide()
    self:RemoveListeners()
     if self.rotationTweenId ~= nil then
        Tween.Instance:Cancel(self.rotationTweenId)
        self.rotationTweenId = nil
     end

    if self.effTimerId ~= nil then
        LuaTimer.Delete(self.effTimerId)
        self.effTimerId = nil
    end
end

function RideChooseEndWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ride_choos_end_window))
    self.gameObject.name = "RideChooseEndWindow"

    UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)

    local t = self.gameObject.transform
    self.transform = t

    self.transform:Find("Main/Top"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.ride_choose_end_bigRabbit,"Rabbit")
    self.transform:Find("Main/ItemSlotBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew,"RoleBgNew")
    self.transform:Find("Main/Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.ride_choose_end_bigbg,"BigBg")

    self.button = self.transform:Find("Main/Button"):GetComponent(Button)
    self.button.onClick:AddListener(function() self:ApplyButton() end)
    self.ItemSlot = ItemSlot.New(self.transform:Find("Main/ItemSlotBg/ItemSlot").gameObject)
    self.rotationBg = self.transform:Find("Main/ItemSlotBg/Flash").transform
    self.rotationBg.transform.anchoredPosition = Vector2(2.1,7.5)



    -- t:Find("MainCon/CloseButton"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    t:Find("Main/Close").gameObject:AddComponent(TransitionButton)

    self:OnOpen()
end

function RideChooseEndWindow:OnOpen()
    -- self:RemoveListeners()
    -- self:AddListeners()
    self:RefreshData()
    self:BeginCircle()

end

function RideChooseEndWindow:OnInitCompleted()
    self.transform:Find("Panel"):GetComponent(Button).onClick:RemoveAllListeners()
end

function RideChooseEndWindow:BeginCircle()
    self.rotationTweenId  = Tween.Instance:ValueChange(0,360,4, function() self.rotationTweenId = nil self:BeginCircle(callback) end, LeanTweenType.Linear,function(value) self:RotationChange(value) end).id
end

function RideChooseEndWindow:RotationChange(value)
   self.rotationBg.localRotation = Quaternion.Euler(0, 0, value)
end

function RideChooseEndWindow:ApplyButton()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.firstrecharge_window, {3})
end
function RideChooseEndWindow:RefreshData()
    local cell = DataItem.data_get[23676]
    local itemdata = ItemData.New()
    itemdata:SetBase(cell)
    self.ItemSlot:SetAll(cell,self.extra)

    if self.effTimerId == nil then
            self.effTimerId = LuaTimer.Add(1000, 3000, function()
               self.button.gameObject.transform.localScale = Vector3(1.1,1.1,1)
               Tween.Instance:Scale(self.button.gameObject, Vector3(1,1,1), 1.2, function() end, LeanTweenType.easeOutElastic)
            end)
    end
end




