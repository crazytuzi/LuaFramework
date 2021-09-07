--获得新武器时装弹窗
--20170612 ljh
WeaponFashionOpenWindow  =  WeaponFashionOpenWindow or BaseClass(BasePanel)

function WeaponFashionOpenWindow:__init(model)
    self.name  =  "WeaponFashionOpenWindow"
    self.model  =  model
    self.texture = AssetConfig.getpet_textures
    self.resList  =  {
        {file  =  AssetConfig.weapon_fashion_open_win, type  =  AssetType.Main},
        {file = self.texture, type = AssetType.Dep},
        {file = AssetConfig.getpetbtn, type = AssetType.Dep},
        {file = AssetConfig.getpethalo1, type = AssetType.Dep},
        {file = AssetConfig.getpetlight1, type = AssetType.Dep},
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
end

function WeaponFashionOpenWindow:__delete()
    self.is_open  =  false
    -- self:stop_timer()
    -- 记得这里销毁
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    self:StopRoundTimer()
    self.myData = nil
end

function WeaponFashionOpenWindow:InitPanel()
    if self.gameObject ~=  nil then --加载回调两次，这里暂时处理
        return
    end
    SoundManager.Instance:Play(272)
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.weapon_fashion_open_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "WeaponFashionOpenWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)

    local Panel = self.transform:FindChild("Panel"):GetComponent(Button)
    Panel.onClick:AddListener(function() self.model:CloseWeaponFashionOpenUI() end)

    self.MainCon = self.transform:FindChild("MainCon")
    self.title = self.transform:Find("MainCon/Title").gameObject
    self.CloseButton = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function () self.model:CloseWeaponFashionOpenUI()  end)

    self.Halo = self.MainCon:FindChild("Halo").gameObject
    self.light = self.MainCon:FindChild("Light").gameObject
    self.modelPreviewContainer = self.MainCon:FindChild("Preview")
    self.BtnPuton = self.MainCon:FindChild("BtnPuton"):GetComponent(Button)
    self.TxtName = self.MainCon:FindChild("TxtName"):GetComponent(Text)
    self.TxtAttr = self.MainCon:FindChild("TxtAttr"):GetComponent(Text)
    self.BntConfirm_txt = self.BtnPuton.transform:FindChild("Text"):GetComponent(Text)


     self.Halo.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpethalo1,"GetPetHalo1")
    self.light.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetlight1,"GetPetLight1")
    self.BtnPuton.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetbtn,"GetPetBtn")
    self.BtnPuton.onClick:AddListener(function()
        -- local fashionData = DataFashion.data_base[self.openArgs.base_id]
        -- if fashionData ~= nil then
        --     if fashionData.special_mark == 1 then
        --         FashionManager.Instance:request13205(1)
        --     elseif fashionData.special_mark == 2 then
        --         for key, value in pairs(DataBacksmith.data_equip_dianhua) do
        --             if self.openArgs.base_id == value.fashion_id then
        --                 EquipStrengthManager.Instance:request10619(1, value.looks)
        --                 break
        --             end
        --         end
        --     else
        --         FashionManager.Instance:request13205(self.openArgs.base_id)
        --     end
        -- end

        self.model:CloseWeaponFashionOpenUI()
    end)

    self.is_open = true
    self:StarRoundTimer()
    -- self:start_timer()
    self:UpdateData()
    -- WindowManager.Instance:CloseWindow()
    BackpackManager.Instance.mainModel:CloseMain()
end

--题目展示计时
function WeaponFashionOpenWindow:StopRoundTimer()
    if self.round_timer_id ~= 0 then
        LuaTimer.Delete(self.round_timer_id)
        self.round_timer_id = 0
        self.round_timer = 0
    end
end

function WeaponFashionOpenWindow:StarRoundTimer()
    self:StopRoundTimer()
    self.round_timer_id = LuaTimer.Add(0, 20, function(id) self:TickRoundTimer(id) end)
end

function WeaponFashionOpenWindow:TickRoundTimer(id)
    self.Halo.transform:RotateAround(self.Halo.transform.position, self.Halo.transform.forward, 20 * self.round_timer)
end

--移除unitdata里面某个类型时装id
function WeaponFashionOpenWindow:RemoveUnitDataFashion(_type, unitData)
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
function WeaponFashionOpenWindow:UpdateData()
    local myData = SceneManager.Instance:MyData()
    if myData == nil then
        self.model:CloseWeaponFashionOpenUI()
        return
    end
    local unitData = BaseUtils.copytab(myData)
    -- local cfgData = DataFashion.data_suit[self.openArgs.base_id]
    -- for i=1,#cfgData.include do
    --     local suitData = DataFashion.data_base[cfgData.include[i].fashion_id]
    --     self:RemoveUnitDataFashion(suitData.type, unitData) --脱下当前同类型的
    --     table.insert(unitData.looks, {looks_str = "", looks_mode =  suitData.texture_id, looks_type = suitData.type, looks_val = suitData.base_id})
    -- end

    local fashionData = DataFashion.data_base[self.openArgs.base_id]
    if fashionData ~= nil then
        self:RemoveUnitDataFashion(fashionData.type, unitData) --脱下当前同类型的
        table.insert(unitData.looks, {looks_str = "", looks_mode =  self.model:GetWeaponLookModel(fashionData.model_id), looks_type = fashionData.type, looks_val = fashionData.model_id})
    end

    self:UpdateModelview(unitData.looks)
    -- self.TxtName.text = cfgData.name
    -- self.TxtAttr.text = cfgData.addpoint_str
    self.TxtName.text = string.format(TI18N("激活幻化武器：%s"), fashionData.name)

    self:ShowTitle()
    self:ShowButton()
end

--更新模型
function WeaponFashionOpenWindow:UpdateModelview(looks)
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "WeaponFashionOpenWindowRole"
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


function WeaponFashionOpenWindow:SetRawImage(composite)
    if self.modelPreviewContainer ~= nil then
        local rawImage = composite.rawImage
        rawImage.transform:SetParent(self.modelPreviewContainer)
        rawImage.transform.localPosition = Vector3(0, 0, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        self.modelPreviewContainer.gameObject:SetActive(true)

        composite:PlayMotion(FighterAction.BattleStand)
    end
end

function WeaponFashionOpenWindow:ShowTitle()
    self.title.transform.localScale = Vector3.one * 0.2
    self.title:SetActive(true)
    Tween.Instance:Scale(self.title, Vector3.one, 1, nil, LeanTweenType.easeOutElastic)
end

function WeaponFashionOpenWindow:ShowButton()
    self.BtnPuton.gameObject.transform.localScale = Vector3.one * 3
    self.BtnPuton.gameObject:SetActive(true)
    Tween.Instance:Scale(self.BtnPuton.gameObject, Vector3.one, 1, nil, LeanTweenType.easeOutElastic)
end

function WeaponFashionOpenWindow:BeginCountDown()

end

--开始倒计时
-- function WeaponFashionOpenWindow:start_timer()
--     self:stop_timer()
--     self.timer_id = LuaTimer.Add(0, 1000, function() self:timer_tick() end)
-- end

-- function WeaponFashionOpenWindow:stop_timer()
--     if self.timer_id ~= 0 then
--         LuaTimer.Delete(self.timer_id)
--         self.timer_id = 0
--         self.total_time = 2
--     end
-- end

-- function WeaponFashionOpenWindow:timer_tick()
--     self.total_time = self.total_time - 1
--     if self.total_time > -1 then
--         self:stop_timer()
--         self.model:CloseFashionOpenUI()
--     end
-- end