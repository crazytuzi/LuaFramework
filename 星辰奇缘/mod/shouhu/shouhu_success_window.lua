ShouhuSuccessWindow  =  ShouhuSuccessWindow or BaseClass(BaseWindow)

function ShouhuSuccessWindow:__init(model)
    self.name  =  "ShouhuSuccessWindow"
    self.model  =  model
    self.resList  =  {
        {file  =  AssetConfig.shouhu_success_win, type  =  AssetType.Main},
        {file  =  AssetConfig.totembg, type  =  AssetType.Dep},
        {file  =  AssetConfig.guard_couplet, type  =  AssetType.Dep}
    }

    self.star_open_lev = 43

    self.isHideMainUI = false
    self.list_item_select_id = 0
    self.shItemList = nil
    self.myData = nil
    self.round_timer = 0.08
    self.round_timer_id = 0
    self.previewComp1 = nil
    self.total_time = 3
    self.timer_id = 0
    self.round_timer_id = 0
    
    return self
end

function ShouhuSuccessWindow:__delete()
    self.is_open  =  false
    self.ImgClasses.sprite = nil
    self:stop_timer()
    -- 记得这里销毁
    if self.previewComp1 ~= nil then
        self.previewComp1:DeleteMe()
        self.previewComp1 = nil
    end


    self:stop_round_timer()
    if self.myData.base_id ~= 1002 and self.myData.base_id ~= 1012 and self.myData.base_id ~= 1018 and self.myData.base_id ~= 1008 then
        -- mod_shouhu.play_shouhu_plot(self.myData.scenario_id)
    end
    self.myData = nil
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function ShouhuSuccessWindow:InitPanel()
    if self.gameObject ~=  nil then --加载回调两次，这里暂时处理
        return
    end
    SoundManager.Instance:Play(272)
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shouhu_success_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "ShouhuSuccessWindow"
    self.transform = self.gameObject.transform
    -- UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)


    self.MainCon = self.transform:FindChild("MainCon").gameObject
    self.light = self.MainCon.transform:FindChild("Light").gameObject

    -- bigbg处理
    -- hosr
    self.MainCon.transform:Find("ImgSec"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.totembg, "ToTemBg")

    self.modelPreviewContainer = self.MainCon.transform:FindChild("Preview").gameObject
    self.ImgName = self.MainCon.transform:FindChild("TxtName"):GetComponent(Text)
    self.BtnConfirm = self.MainCon.transform:FindChild("BtnConfirm"):GetComponent(Button)
    self.BntConfirm_txt = self.BtnConfirm.transform:FindChild("Text"):GetComponent(Text)
    self.ImgClasses = self.MainCon.transform:FindChild("Image"):GetComponent(Image)

    self.TxtDesc = self.MainCon.transform:FindChild("TxtDesc"):GetComponent(Text)
    -- TxtDesc
    self.MaskCon = self.MainCon.transform:FindChild("MaskCon")


    self.BtnConfirm.onClick:AddListener(function() self.model:CloseShouhuSuccessUI() end)

    self.is_open = true
    -- ModelPreview.Instance:Release()
    self:update_data()

    self:stop_round_timer()
    self:star_round_timer()

    self:start_timer()

    SoundManager.Instance:Play(272)
end

--题目展示计时
function ShouhuSuccessWindow:stop_round_timer()
    if self.round_timer_id ~= 0 then
        LuaTimer.Delete(self.round_timer_id)
        self.round_timer_id = 0
        self.round_timer = 0
    end
end

function ShouhuSuccessWindow:star_round_timer()
    self:stop_round_timer()
    self.round_timer_id = LuaTimer.Add(0, 20, function(id) self:tick_round_timer(id) end)
end

function ShouhuSuccessWindow:tick_round_timer(id)
    self.round_timer_id = id
    self.light.transform:RotateAround(self.light.transform.position, self.light.transform.forward, 20 * self.round_timer)
end

-- 招募成功
function ShouhuSuccessWindow:update_data()
    if self.model.has_rec_succs_bid ~= 0 then
        self.myData = self.model:get_sh_base_dat_by_id(self.model.has_rec_succs_bid)
        self.ImgClasses.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(self.myData.classes))

        --名字
        self.ImgName.text = self.myData.name
        self.TxtDesc.text = self.myData.desc_char
        self:update_model(self.myData)

        --播下招募成功音效
        if self.myData.sound_id ~= 0 then
            SoundManager.Instance:PlayCombatChat(self.myData.sound_id)
        end

        local cfgData = DataShouhu.data_guard_base_cfg[self.model.has_rec_succs_bid]
        if cfgData.showCouplet == 1 then
            self.MaskCon.gameObject:SetActive(true)
            self.MaskCon.transform:FindChild("ImgWord"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guard_couplet, self.model.has_rec_succs_bid)
            Tween.Instance:ValueChange(0, 161, 0.7, nil, LeanTweenType.linear, function(val)
                if self.is_open == false then
                    return
                end
                self.MaskCon:GetComponent(RectTransform).sizeDelta = Vector2(34, val)
            end)
        end
    end
end

function ShouhuSuccessWindow:update_model(data)
    local previewComp = nil
    local callback = function(composite)
        self:on_model_build_completed(composite)
    end
    local setting = {
        name = "Shouhu"
        ,orthographicSize = 0.9
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }
    local modelData = {type = PreViewType.Shouhu, skinId = data.paste_id, modelId = data.res_id, animationId = data.animation_id, scale = 1}
    if self.previewComp1 == nil then
        self.previewComp1 = PreviewComposite.New(callback, setting, modelData)

        -- 有缓存的窗口要写这个
        self.OnHideEvent:AddListener(function() self.previewComp1:Hide() end)
        self.OnOpenEvent:AddListener(function() self.previewComp1:Show() end)
    else
        self.previewComp1:Reload(modelData, callback)
    end
end


function ShouhuSuccessWindow:on_model_build_completed(composite)
    if self.is_open  ==  false then
        return
    end
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.modelPreviewContainer.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
end

--开始战斗倒计时
function ShouhuSuccessWindow:start_timer()
    self:stop_timer()
    self.timer_id = LuaTimer.Add(0, 1000, function() self:timer_tick() end)
end

function ShouhuSuccessWindow:stop_timer()
    if self.timer_id ~= 0 then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = 0
        self.total_time = 2
    end
end

function ShouhuSuccessWindow:timer_tick()
    self.total_time = self.total_time - 1
    if self.total_time > -1 then

        self.BntConfirm_txt.text = string.format("%s(%s)", TI18N("确认"), self.total_time)
        if self.total_time <= 0 then
            self.BntConfirm_txt.text = TI18N("确认")
        end
    else
        self.BntConfirm_txt.text = TI18N("确认")
        self:stop_timer()
        self.model:CloseShouhuSuccessUI()
    end
end