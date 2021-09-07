--2017/10/30
--zyh(宠物选择界面)
RideChooseWindow = RideChooseWindow or BaseClass(BaseWindow)

function RideChooseWindow:__init(model)
    self.model = model
    self.mgr = RideChooseWindow.Instance

    self.resList = {
       {file = AssetConfig.ride_choose_window,type = AssetType.Main,holdTime = 5}
      ,{file = AssetConfig.ride_choose_textures,type = AssetType.Dep}
      ,{file = AssetConfig.ride_choose_bigbg1,type = AssetType.Dep}
      ,{file = AssetConfig.ride_choose_bigbg2,type = AssetType.Dep}
      ,{file = AssetConfig.ride_choose_bigText,type = AssetType.Dep}
    }
    self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.windowId = WindowConfig.WinID.rideChooseWindow

    -- self.refreshData = function() self:RefreshData() end
    self.itemDataList = {}
    self.itemList = {}
    self.previewTrList = {}
    self.previewDataList = {}
    self.myrideList = {}
    self.selectIndex = 1
end

function RideChooseWindow:__delete()
    self:OnHide()
    for k,v in pairs(self.previewDataList) do
        if v ~= nil then
            v:DeleteMe()
            v = nil
        end
    end
     if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
     end
     self:AssetClearAll()

end

function RideChooseWindow:RemoveListeners()

end

function RideChooseWindow:AddListeners()

end

function RideChooseWindow:OnHide()
    self:RemoveListeners()
end

function RideChooseWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ride_choose_window))
    self.gameObject.name = "RideChooseWindow"

    UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)

    local t = self.gameObject.transform
    self.transform = t

    self.transform:Find("Main/LeftPreview"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.ride_choose_bigbg2,"RideGround")
    self.transform:Find("Main/RightPreview"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.ride_choose_bigbg2,"RideGround")
    self.transform:Find("Main/LightBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.ride_choose_bigbg1,"BigLight")
    self.transform:Find("Main/Title"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.ride_choose_bigText,"TI18NChooseRide")

    self.leftButton = self.transform:Find("Main/Left"):GetComponent(Button)
    self.rightButton = self.transform:Find("Main/Right"):GetComponent(Button)

    self.leftButton.onClick:AddListener(function() self:ChooseSelect(1) end)
    self.rightButton.onClick:AddListener(function() self:ChooseSelect(2) end)

    self.leftSelect = self.transform:Find("Main/LeftPreview/SelectImg")
    self.leftSelect.gameObject:SetActive(false)
    self.rightSelect = self.transform:Find("Main/RightPreview/SelectImg")
    self.rightSelect.gameObject:SetActive(false)

    self.leftContainer = self.transform:Find("Main/Left")
    self.rightContainer = self.transform:Find("Main/Right")

    self.leftName = self.transform:Find("Main/Left/Name"):GetComponent(Text)
    self.rightName = self.transform:Find("Main/Right/Name"):GetComponent(Text)

    self.previewTrList[1] = t:Find("Main/Left")
    self.previewTrList[2] = t:Find("Main/Right")

    self.chooseButton = self.transform:Find("Main/Button"):GetComponent(Button)
    self.chooseButton.onClick:AddListener(function() self:ApplyChoose() end)

    self.setting = {
        name = "RideView"
        ,orthographicSize = 1
        ,width = 360
        ,height = 341
        ,offsetY = -0.4
        ,noDrag = true
    }



    -- t:Find("MainCon/CloseButton"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self,false) end)


    self:OnOpen()
end

function RideChooseWindow:OnOpen()
    if self.openArgs ~= nil then
        self.myState = self.openArgs[1]
    else
        self.myState = 0
    end
    self:RemoveListeners()
    self:AddListeners()
    self:RefreshData()
    self:ChooseSelect(1)
end

function RideChooseWindow:ChooseSelect(index)
    if index == 1 then
        self.leftSelect.gameObject:SetActive(true)
        self.rightSelect.gameObject:SetActive(false)
    elseif index == 2 then
        self.leftSelect.gameObject:SetActive(false)
        self.rightSelect.gameObject:SetActive(true)
    end
    self.selectIndex = index
end
function RideChooseWindow:RefreshData()
    local rideList = {}
    for i=1,2 do
        rideList[i] = {}
        rideList[i].sex = RoleManager.Instance.RoleData.sex
        rideList[i].type = 9
        rideList[i].scale = 1
        rideList[i].classes = RoleManager.Instance.RoleData.classes
        rideList[i].effects = {}
        rideList[i].looks = {}
        rideList[i].looks[1] = {}
        rideList[i].looks[1].looks_type = 20
    end

    for k,v in pairs(DataMount.data_ride_new_data) do
        if v.isshow == 1 then
            rideList[v.key_id].looks[1].looks_val = v.base_id
        end
    end
    -- local rideList = {
    -- [1] = {scale = 1,sex = 1,type = 9,
    --     looks = {
    --         [1] = {
    --             looks_val = 2000,
    --             looks_type = 20,
    --         },
    --     },
    --     classes = 1,
    --     effects = {
    --     }
    -- },
    -- [2] = {scale = 1,sex = 1,type = 9,
    --     looks = {
    --         [1] = {
    --             looks_val = 2000,
    --             looks_type = 20,
    --         },
    --     },
    --     classes = 1,
    --     effects = {
    --     }
    -- }
    -- }
    local callbackList = {}


    for i,v in ipairs(rideList) do
        callbackList[i] = function(composite)
            self:SetRawImage(composite,i)
        end

        if self.previewDataList[i] == nil then
            self.setting.name = "RideView" .. i
            self.previewDataList[i] = PreviewComposite.New(callbackList[i],self.setting,v)
        else
            self.previewDataList[i]:Reload(v,callbackList[i])
            self.previewDataList[i]:Show()
        end
        if i == 1 then
            self.leftName.text = DataMount.data_ride_data[v.looks[1].looks_val].name
        elseif i == 2 then
            self.rightName.text = DataMount.data_ride_data[v.looks[1].looks_val].name
        end
    end
end


function RideChooseWindow:SetRawImage(composite,index)
    local rawImage = composite.rawImage
    rawImage.gameObject:SetActive(true)
    rawImage.transform:SetParent(self.previewTrList[index])
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    composite.tpose.transform.localRotation = Quaternion.Euler(355.5,319,4.4)


    self.previewTrList[index].gameObject:SetActive(true)
end

function RideChooseWindow:ApplyChoose()
    if self.myState == 0 then
        RideManager.Instance:Send17026(self.selectIndex)
    elseif self.myState == 1 then
        RideManager.Instance:Send17027(self.selectIndex)
    end
    WindowManager.Instance:CloseWindow(self,false)
end



