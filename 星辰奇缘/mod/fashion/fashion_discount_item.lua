FashionDiscountItem = FashionDiscountItem or BaseClass()

function FashionDiscountItem:__init(gameObject,parent,id)
    self.id = id
    self.gameObject = gameObject
    self.parent = parent
    self.resources = {
        {file = AssetConfig.fashion_selection_show_big1, type = AssetType.Dep}   --topBg大图
        ,{file = AssetConfig.fashion_selection_show_big2, type = AssetType.Dep}
        ,{file = AssetConfig.fashion_discount_texture, type = AssetType.Dep}
        ,{file  = AssetConfig.maxnumber_5, type  =  AssetType.Dep}
    }

    self.args = nil


    self.assetWrapper = AssetBatchWrapper.New()
    self.callback = function() self:InitBigBg() end
    --self.extra = {inbag = false, nobutton = true}
    self:InitPanel()


end
function FashionDiscountItem:InitBigBg()
    self.topbg = self.transform:Find("TopBg")
    self.topbg:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.fashion_selection_show_big1, "FashionSelectionTop")
    self.topbg.gameObject:SetActive(true)

end

function FashionDiscountItem:InitPanel()
   self.transform = self.gameObject.transform
   self.assetWrapper:LoadAssetBundle(self.resources,self.callback)
   self.previewParent = self.transform:Find("FashionPreview")
   self.selectionBtn = self.transform:Find("BuyBtn"):GetComponent(Button)
   self.selectionBtn.onClick:AddListener(function() self:ApplyBuyButton() end)
   self.nameText = self.transform:Find("TitleBg/Text"):GetComponent(Text)   --配置读表

   self.SaleTitle = self.transform:Find("SaleTitle/Image"):GetComponent(Image)  --打折img

   --self.panelBtn = self.transform:Find("Panel"):GetComponent(Button)
   --self.panelBtn.onClick:AddListener(function() self:ApplySelectedButton() end)

end


function FashionDiscountItem:__delete()
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.SaleTitle ~= nil then
        BaseUtils.ReleaseImage(self.SaleTitle)
    end

    if self.topbg:GetComponent(Image) ~= nil then
        BaseUtils.ReleaseImage(self.topbg:GetComponent(Image))
    end

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
end

function FashionDiscountItem:OnOpen()
    if self.previewComp ~= nil then
        self.previewComp:Show()
    end
end



function FashionDiscountItem:SetData(data)

    -- local data_list = {}
    -- for k,v in pairs(data.fashion) do
    --     local myData = DataFashion.data_base[v.value]
    --     table.insert(data_list, myData)
    -- end
    --self.myFashionData = data    --第i条时装信息
    --BaseUtils.dump(data,"FashionDiscountItem:SetData")
    self.nameText.text = data.fashion_name  --时装名称
    self.SaleTitle.sprite = PreloadManager.Instance:GetTextures(AssetConfig.maxnumber_5, "Num5_"..tostring(data.discount))  --..data.discount   
    --数据重组
    local data_list = {}
    for k,v in pairs(data.fashion) do
        local myData = DataFashion.data_base[v.value]
        table.insert(data_list, myData)
    end
    self:UpdateLooks(data_list)
end

function FashionDiscountItem:UpdateLooks(data_list)
    --BaseUtils.dump(data_list,"时装信息")

    local myData = SceneManager.Instance:MyData()   --当前模型数据
    local unitData = BaseUtils.copytab(myData)

    self.kvLooks = {}
    for k2,v2 in pairs(unitData.looks) do
        self.kvLooks[v2.looks_type] = v2
    end

    for k,v in pairs(data_list) do
        self.kvLooks[v.type] = {looks_str = "", looks_val = v.model_id, looks_mode = v.texture_id, looks_type = v.type}
    end
    if self.kvLooks[SceneConstData.looktype_wing] ~= nil then
        self.kvLooks[SceneConstData.looktype_wing] = nil
    end

    self:SetPreviewComp(self.kvLooks)
end


function FashionDiscountItem:SetPreviewComp(myLooks)
    local modelData = {type = PreViewType.Role, classes = RoleManager.Instance.RoleData.classes, sex = self.parent.CurrSex, looks = myLooks}

   if modelData ~= nil then
        local callback = function(composite)
            self:SetRawImage(composite)
        end

        -- if modelData.scale == nil then
        --     modelData.scale = 3
        -- else
        --     modelData.scale = modelData.scale * 3
        -- end
        if self.previewComp == nil then
            local setting = {
                name = "previewComp" .. self.id
                ,orthographicSize = 0.6
                ,width = 200
                ,height = 250
                ,offsetY = -0.5
            }
            self.previewComp = PreviewComposite.New(callback, setting, modelData)
        else
            self.previewComp:Reload(modelData, callback)
        end
        self.previewComp:Show()
    end
end

function FashionDiscountItem:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.previewParent)
    rawImage.transform.localPosition = Vector3(0, 37, 0)
    if self.id == 2 then
        rawImage.transform.localScale = Vector3(1.4, 1.4, 1.4)
    else
        rawImage.transform.localScale = Vector3(1.2, 1.2, 1.2)
    end
    
    self.previewParent.gameObject:SetActive(true)
end

function FashionDiscountItem:OnHide()
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
end

function FashionDiscountItem:ApplyBuyButton()
    FashionDiscountManager.Instance.model:OpenDetailWindow({self.parent.CurrSex, self.id})
    --打开detail详情页面
end

function FashionDiscountItem:ApplySelectedButton()
    -- if self.previewComp ~= nil then
    --     self.parent:ApplyNormalStatus()
    --     local rawImage = composite.rawImage
    --     rawImage.transform.localScale = Vector3(1.2, 1.2, 1.2)
    --     self.topbg.gameObject:SetActive(true)
    -- end
end

function FashionDiscountItem:ApplyNormal()
    -- if self.previewComp ~= nil then
    --     local rawImage = composite.rawImage
    --     rawImage.transform.localScale = Vector3(1, 1, 1)
    --     self.topbg.gameObject:SetActive(false)
    -- end
end