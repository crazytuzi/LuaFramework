--author:zzl
--time:2017.1.5
--获得新套装弹窗
FashionOpenWindow  =  FashionOpenWindow or BaseClass(BasePanel)

function FashionOpenWindow:__init(model)
    self.name  =  "FashionOpenWindow"
    self.model  =  model
    -- self.texture = AssetConfig.getpet_textures
    self.resList  =  {
        {file  =  AssetConfig.fashion_open_win, type  =  AssetType.Main},
        -- {file = self.texture, type = AssetType.Dep},
        {file = AssetConfig.getpethalo1,type = AssetType.Dep},
        {file = AssetConfig.getpetlight1,type = AssetType.Dep},
        {file = AssetConfig.getpetbtn,type = AssetType.Dep},
        {file = AssetConfig.fashionres, type = AssetType.Dep}
    }

    self.star_open_lev = 43

    self.isHideMainUI = false
    self.list_item_select_id = 0
    self.shItemList = nil
    self.myData = nil
    self.round_timer = 0.08
    self.round_timer_id = 0
    self.previewComp = nil
    self.total_time = 3
    self.timer_id = 0
    return self
end

function FashionOpenWindow:__delete()
    self.is_open  =  false
    -- self:stop_timer()
    -- 记得这里销毁
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    self:StopRoundTimer()
    self.myData = nil
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function FashionOpenWindow:InitPanel()
    if self.gameObject ~=  nil then --加载回调两次，这里暂时处理
        return
    end
    SoundManager.Instance:Play(272)
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fashion_open_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "FashionOpenWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseFashionOpenUI() end)

    self.MainCon = self.transform:FindChild("MainCon")
    self.title = self.transform:Find("MainCon/Title").gameObject
    self.CloseButton = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function () self.model:CloseFashionOpenUI()  end)

    self.Halo = self.MainCon:FindChild("Halo").gameObject
    self.Light = self.MainCon:FindChild("Light").gameObject
    self.modelPreviewContainer = self.MainCon:FindChild("Preview")
    self.BtnPuton = self.MainCon:FindChild("BtnPuton"):GetComponent(Button)
    self.TxtName = self.MainCon:FindChild("TxtName"):GetComponent(Text)
    self.TxtAttr = self.MainCon:FindChild("TxtAttr"):GetComponent(Text)
    self.BntConfirm_txt = self.BtnPuton.transform:FindChild("Text"):GetComponent(Text)


    self.Halo.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpethalo1,"GetPetHalo1")
    self.Light.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetlight1,"GetPetLight1")
    self.BtnPuton.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetbtn,"GetPetBtn")
    self.BtnPuton.onClick:AddListener(function()
        BaseUtils.dump(self.openArgs,"self.openArgs_fashionopen")
        local cfgData = DataFashion.data_suit[self.openArgs.base_id]
        local head_id = 0
        local cloth_id = 0
        for i=1,#cfgData.include do
            local suitData = DataFashion.data_base[cfgData.include[i].fashion_id]
            if suitData.type == 2 then
                head_id = suitData.base_id
            elseif suitData.type == 3 then
                cloth_id = suitData.base_id
            end
        end
        FashionManager.Instance:request13201(0, head_id, 0, cloth_id)
    end)

    self.is_open = true
    self:StopRoundTimer()
    self:StarRoundTimer()
    -- self:start_timer()
    self:UpdateData()
    -- WindowManager.Instance:CloseWindow()
    BackpackManager.Instance.mainModel:CloseMain()
end

--题目展示计时
function FashionOpenWindow:StopRoundTimer()
    if self.round_timer_id ~= 0 then
        LuaTimer.Delete(self.round_timer_id)
        self.round_timer_id = 0
        self.round_timer = 0
    end
end

function FashionOpenWindow:StarRoundTimer()
    self:StopRoundTimer()
    self.round_timer_id = LuaTimer.Add(0, 20, function(id) self:TickRoundTimer(id) end)
end

function FashionOpenWindow:TickRoundTimer(id)
    self.round_timer_id = id
    self.Halo.transform:RotateAround(self.Halo.transform.position, self.Halo.transform.forward, 20 * self.round_timer)
end

--移除unitdata里面某个类型时装id
function FashionOpenWindow:RemoveUnitDataFashion(_type, unitData)
    local index = 0
        for i=1, #unitData.looks do
            local look = unitData.looks[i]
            if look.looks_type == _type then
                index = i
            end
        end
        if index ~= 0 then
            table.remove(unitData.looks, index)
        end
end

-- 招募成功
function FashionOpenWindow:UpdateData()
    local myData = SceneManager.Instance:MyData()
    if myData == nil then
        self.model:CloseFashionOpenUI()
        return
    end
    local unitData = BaseUtils.copytab(myData)
    local cfgData = DataFashion.data_suit[self.openArgs.base_id]
    for i=1,#cfgData.include do
        local suitData = DataFashion.data_base[cfgData.include[i].fashion_id]
        self:RemoveUnitDataFashion(suitData.type, unitData) --脱下当前同类型的
        table.insert(unitData.looks, {looks_str = "", looks_mode =  suitData.texture_id, looks_type = suitData.type, looks_val = suitData.base_id})
    end
    self:UpdateModelview(unitData.looks)
    self.TxtName.text = cfgData.name
    self.TxtAttr.text = cfgData.addpoint_str
    self:ShowTitle()
    self:ShowButton()
end

--更新模型
function FashionOpenWindow:UpdateModelview(looks)
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "FashionOpenWindowRole"
        ,orthographicSize = 0.6
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }

    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = looks}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
end


function FashionOpenWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.modelPreviewContainer)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.modelPreviewContainer.gameObject:SetActive(true)
end

function FashionOpenWindow:ShowTitle()
    self.title.transform.localScale = Vector3.one * 0.2
    self.title:SetActive(true)
    Tween.Instance:Scale(self.title, Vector3.one, 1, nil, LeanTweenType.easeOutElastic)
end

function FashionOpenWindow:ShowButton()
    self.BtnPuton.gameObject.transform.localScale = Vector3.one * 3
    self.BtnPuton.gameObject:SetActive(true)
    Tween.Instance:Scale(self.BtnPuton.gameObject, Vector3.one, 1, nil, LeanTweenType.easeOutElastic)
end

function FashionOpenWindow:BeginCountDown()

end

--开始倒计时
-- function FashionOpenWindow:start_timer()
--     self:stop_timer()
--     self.timer_id = LuaTimer.Add(0, 1000, function() self:timer_tick() end)
-- end

-- function FashionOpenWindow:stop_timer()
--     if self.timer_id ~= 0 then
--         LuaTimer.Delete(self.timer_id)
--         self.timer_id = 0
--         self.total_time = 2
--     end
-- end

-- function FashionOpenWindow:timer_tick()
--     self.total_time = self.total_time - 1
--     if self.total_time > -1 then
--         self:stop_timer()
--         self.model:CloseFashionOpenUI()
--     end
-- end