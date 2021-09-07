HonorPreviewWindow  =  HonorPreviewWindow or BaseClass(BasePanel)

function HonorPreviewWindow:__init(model)
    self.name  =  "HonorPreviewWindow"
    self.model  =  model

    self.resList  =  {
        {file  =  AssetConfig.honor_preview_window, type  =  AssetType.Main}
        ,{file  =  AssetConfig.wingsbookbg, type  =  AssetType.Dep}
    }
end

function HonorPreviewWindow:__delete()
    -- 记得这里销毁
    if self.previewComp1 ~= nil then
        self.previewComp1:DeleteMe()
        self.previewComp1 = nil
    end

    self.is_open = false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function HonorPreviewWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.honor_preview_window))
    self.gameObject.name = "HonorPreviewWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.is_open = true
    self.MainCon = self.transform:FindChild("MainCon")
    local CloseBtn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseMainUI() end)

    self.MainCon.transform:Find("PreviewBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")

    self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:CloseMainUI() end)

    self.LeftArrowCon_Btn = self.MainCon:Find("LeftArrowCon"):GetComponent(Button)
    self.RightArrowCon_Btn = self.MainCon:Find("RightArrowCon"):GetComponent(Button)

    self.Preview = self.MainCon:Find("Preview").gameObject
    self.ImgHonor = self.MainCon:Find("ImgHonor"):GetComponent(Image)
    self.TxtHonor = self.MainCon:Find("TxtHonor"):GetComponent(Text)
    self.ImgDescBg = self.MainCon:Find("ImgDescBg").gameObject
    self.TxtDesc1 = self.ImgDescBg.transform:Find("TxtDesc1"):GetComponent(Text)
    self.TxtDesc2 = self.ImgDescBg.transform:Find("TxtDesc2"):GetComponent(Text)
    self.BtnUse = self.MainCon:Find("BtnUse"):GetComponent(Button)

    self.BtnUse.onClick:AddListener(function() self:on_click_use_honor() end)

    self.LeftArrowCon_Btn.onClick:AddListener(function() self:on_click_left() end)
    self.RightArrowCon_Btn.onClick:AddListener(function() self:on_click_right() end)


    self.has_init = true

    self.data_index = 1
    if HonorManager.Instance.model.current_honor_data_list ~= nil and HonorManager.Instance.model.current_data ~= nil then
        for i=1,#HonorManager.Instance.model.current_honor_data_list do
            local temp_data = HonorManager.Instance.model.current_honor_data_list[i]
            if temp_data.id == HonorManager.Instance.model.current_data.id then
                self.data_index = i
                break
            end
        end
    end

    self:update_view(HonorManager.Instance.model.current_data)
end

--称号tips
function HonorPreviewWindow:update_view(info)

    self.my_data = info
    if self.my_data.res_id ~= 0 then
        self.ImgHonor.gameObject:SetActive(true)
        self.TxtHonor.gameObject:SetActive(false)
        self.ImgHonor.sprite = PreloadManager.Instance:GetSprite(AssetConfig.honor_img,tostring(self.my_data.res_id))
        self.ImgHonor:SetNativeSize()
    else
        self.ImgHonor.gameObject:SetActive(false)
        self.TxtHonor.gameObject:SetActive(true)
        self.TxtHonor.text = string.format("<color='#C32DFA'>【%s】</color>", self.my_data.name)
    end

    self.TxtDesc1.text = string.format("%s%s", TI18N("达成条件："), self.my_data.cond_desc)
    local str = ""
    for i=1, #self.my_data.attr_list do
        local da = self.my_data.attr_list[i]
        if da.name >= 51 and da.name<= 62 then
            str = string.format("%s%s+%s%s", str, KvData.attr_name[da.name], da.val, "%")
        else
            str = string.format("%s%s+%s", str, KvData.attr_name[da.name], da.val)
        end
    end
    if str == "" then
        self.TxtDesc2.text = ""
    else
        self.TxtDesc2.text = string.format("%s<color='#FFDC5F'>%s</color>", TI18N("附加属性："), str)
    end

    self.BtnUse.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
    self.BtnUseTxt = self.BtnUse.gameObject.transform:Find("Text"):GetComponent(Text)
    if self.my_data.has then
        if self.my_data.id == self.model.current_honor_id then
            self.BtnUseTxt.text = TI18N("取 消")
        else
            self.BtnUseTxt.text = TI18N("使 用")
        end
    else
        self.BtnUse.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.BtnUseTxt.text = TI18N("未获得")
    end
    --更新模型
    self:update_model()
end

--请求使用称号
function HonorPreviewWindow:on_click_use_honor()
    if self.my_data.has then
        if self.my_data.id == self.model.current_honor_id then
            HonorManager.Instance:request12702(self.my_data.id)
        else
            HonorManager.Instance:request12701(self.my_data.id)
        end
        self.model:CloseMainUI()
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("该称号尚未激活"))
    end
end

--左翻页
function HonorPreviewWindow:on_click_left()
    print('---------------------------------翻左')
    if HonorManager.Instance.model.current_honor_data_list ~= nil then
        self.data_index = self.data_index - 1
        if self.data_index < 1 then
            self.data_index = #HonorManager.Instance.model.current_honor_data_list
        end
        self:update_view(HonorManager.Instance.model.current_honor_data_list[self.data_index])
    end
end

--右翻页
function HonorPreviewWindow:on_click_right()
    -- print("---------------------------------翻右")
    if HonorManager.Instance.model.current_honor_data_list ~= nil then
        self.data_index = self.data_index +1
        if self.data_index > #HonorManager.Instance.model.current_honor_data_list then
            self.data_index = 1
        end
        self:update_view(HonorManager.Instance.model.current_honor_data_list[self.data_index])
    end
end

------------------------------------------更新模型
--更新模型
function HonorPreviewWindow:update_model()
    if self.current_looks ~= nil then
        if BaseUtils.sametab(self.current_looks, SceneManager.Instance:MyData().looks) then
            return
        end
    end
    local previewComp = nil
    local callback = function(composite)
        self:on_model_build_completed(composite)
    end

    local setting = {
        name = "HonorPreviewRole"
        ,orthographicSize = 1
        ,width = 328
        ,height = 341
        ,offsetY = -0.4
    }

    self.current_looks = BaseUtils.copytab(SceneManager.Instance:MyData().looks)

    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, looks = SceneManager.Instance:MyData().looks}
    if self.previewComp1 == nil then
        self.previewComp1 = PreviewComposite.New(callback, setting, modelData)

        -- 有缓存的窗口要写这个
        self.OnHideEvent:AddListener(function() self.previewComp1:Hide() end)
        self.OnOpenEvent:AddListener(function() self.previewComp1:Show() end)
    else
        self.previewComp1:Reload(modelData, callback)
    end
end


--模型完成加载
function HonorPreviewWindow:on_model_build_completed(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.Preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
end