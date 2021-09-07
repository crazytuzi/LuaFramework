-- 结缘称号界面
-- ljh 20160829
MarryHonorWindow = MarryHonorWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function MarryHonorWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.marryhonor_window
    self.name = "MarryHonorWindow"
    self.resList = {
        {file = AssetConfig.marryhonor_window, type = AssetType.Main}
        , {file = AssetConfig.marry_textures, type = AssetType.Dep}
    }

    -----------------------------------------
    self.honorItemList = {}

	self.container = nil
	self.headobject = nil

	self.selectdata = nil

    self.okButton = nil

    -----------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self._Update = function() self:Update() end
end

function MarryHonorWindow:__delete()
    self:OnHide()

    self:ClearDepAsset()
end

function MarryHonorWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.marryhonor_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.mainTransform = self.transform:Find("Main")

    self.container = self.mainTransform:FindChild("Bar/mask/Container").gameObject
    self.headobject = self.container.transform:FindChild("Item").gameObject

    self.okButton = self.mainTransform:FindChild("Panel/OkButton").gameObject
    self.okButton:GetComponent(Button).onClick:AddListener(function() self:okButtonClick() end)

    self.tipsButton = self.mainTransform:FindChild("Panel/TipsButton").gameObject
    self.tipsButton:GetComponent(Button).onClick:AddListener(function() self:showTips() end)

    self:OnShow()
end

function MarryHonorWindow:Close()
    self.model.newTalent = {}
    self:OnHide()

    WindowManager.Instance:CloseWindow(self)
    -- self.model:CloseMarryHonorWindow()
end

function MarryHonorWindow:OnShow()
	EventMgr.Instance:AddListener(event_name.lover_data, self._Update)
	if MarryManager.Instance.loverData == nil then
		MarryManager.Instance:Send15014()
	end
    self.model.marry_honor_id = 0
    MarryManager.Instance:Send15027()
end

function MarryHonorWindow:OnHide()
	EventMgr.Instance:RemoveListener(event_name.lover_data, self._Update)
end

function MarryHonorWindow:Update()
    if self.model.marry_honor_id == 0 then
        Log.Error("伴侣称号数据错误，id为0")
        return
    end
	self:Update_Bar()
end

function MarryHonorWindow:Update_Bar()
	local honorItemList = self.honorItemList
    local headobject = self.headobject
    local container = self.container
    local data

    local selectBtn = nil
	for i = 1, #DataWedding.data_marry_honor do
        data = DataWedding.data_marry_honor[i]
        local honorItem = honorItemList[i]

        if honorItem == nil then
            local item = GameObject.Instantiate(headobject)
            item:SetActive(true)
            item.transform:SetParent(container.transform)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            honorItemList[i] = item
            honorItem = item
        end
        if data ~= nil then
            honorItem.name = tostring(data.id)
            honorItem.transform:FindChild("Text"):GetComponent(Text).text = data.name
            honorItem.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton8")
            if data.male_id == self.model.marry_honor_id or data.female_id == self.model.marry_honor_id then
                honorItem.transform:FindChild("Label").gameObject:SetActive(true)
                honorItem.transform:FindChild("Label"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Tipslabel1")
                honorItem.transform:FindChild("Label/Text"):GetComponent(Text).text = TI18N("使用中")
            else
                if self.model:isMarryHonorActivate(data.male_id) or self.model:isMarryHonorActivate(data.female_id) then
                    honorItem.transform:FindChild("Label").gameObject:SetActive(true)
                    honorItem.transform:FindChild("Label"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Tipslabel3")
                    honorItem.transform:FindChild("Label/Text"):GetComponent(Text).text = TI18N("已激活")
                else
                    honorItem.transform:FindChild("Label").gameObject:SetActive(false)
                end
            end

            local button = honorItem:GetComponent(Button)
            button.onClick:RemoveAllListeners()
            button.onClick:AddListener(function() self:onhonorItemclick(honorItem) end)

            if self.selectdata ~= nil and self.selectdata.id == data.id then selectBtn = honorItem end
        end
    end

    if #DataWedding.data_marry_honor > 0 then
        if selectBtn == nil then
            self:onhonorItemclick(honorItemList[1])
        else
            self:onhonorItemclick(selectBtn)
        end
    end
end

function MarryHonorWindow:Update_Info()
	local maleHonor = DataHonor.data_get_honor_list[self.selectdata.male_id]
	local femaleHonor = DataHonor.data_get_honor_list[self.selectdata.female_id]

	if maleHonor == nil or femaleHonor == nil then
		Log.Error(string.format("称号表没有找到对应配置 %s %s", self.selectdata.male_id, self.selectdata.female_id))
		return
	end

	local male_name = ""
	local female_name = ""
	local roleData = RoleManager.Instance.RoleData
	local loverData = MarryManager.Instance.loverData

	if roleData.sex == 1 then
		male_name = roleData.name
		female_name = loverData.name
	else
		female_name = roleData.name
		male_name = loverData.name
	end

	self.mainTransform:FindChild("Panel/MaleText"):GetComponent(Text).text = string.format(TI18N("%s的%s"), female_name, maleHonor.name)
	self.mainTransform:FindChild("Panel/FemaleText"):GetComponent(Text).text = string.format(TI18N("%s的%s"), male_name, femaleHonor.name)

	self.mainTransform:FindChild("Panel/DescText"):GetComponent(Text).text = self.selectdata.desc


    if self.model:isMarryHonorActivate(self.selectdata.male_id) or self.model:isMarryHonorActivate(self.selectdata.female_id) then
        local cost = self.selectdata.switch[1]
        local color = "#248813"
        if cost[2] > roleData:GetMyAssetById(cost[1]) then
            color = "#ff0000"
        end
        self.mainTransform:FindChild("Panel/ValueText1"):GetComponent(Text).text = string.format("<color='%s'>%s</color>", color, roleData:GetMyAssetById(cost[1]))
        self.mainTransform:FindChild("Panel/ValueText2"):GetComponent(Text).text = tostring(cost[2])
        self.mainTransform:FindChild("Panel/CostImage1"):GetComponent(Image).sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, string.format("Assets%s", cost[1]))
        self.mainTransform:FindChild("Panel/CostImage2"):GetComponent(Image).sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, string.format("Assets%s", cost[1]))

        if self.model.marry_honor_id == self.selectdata.male_id or self.model.marry_honor_id == self.selectdata.female_id then
            self.okButton.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            self.okButton.transform:FindChild("Text"):GetComponent(Text).text = TI18N("使用中")
            self.okButton.transform:FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton1
        else
            self.okButton.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            self.okButton.transform:FindChild("Text"):GetComponent(Text).text = TI18N("切换")
            self.okButton.transform:FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton2
        end
    else
        local cost = self.selectdata.activate[1]
        local color = "#248813"
        if cost[2] > roleData:GetMyAssetById(cost[1]) then
            color = "#ff0000"
        end
        self.mainTransform:FindChild("Panel/ValueText1"):GetComponent(Text).text = string.format("<color='%s'>%s</color>", color, roleData:GetMyAssetById(cost[1]))
        self.mainTransform:FindChild("Panel/ValueText2"):GetComponent(Text).text = tostring(cost[2])
        self.mainTransform:FindChild("Panel/CostImage1"):GetComponent(Image).sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, string.format("Assets%s", cost[1]))
        self.mainTransform:FindChild("Panel/CostImage2"):GetComponent(Image).sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.base_textures, string.format("Assets%s", cost[1]))

        self.okButton.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        self.okButton.transform:FindChild("Text"):GetComponent(Text).text = TI18N("未激活")
        self.okButton.transform:FindChild("Text"):GetComponent(Text).color = ColorHelper.DefaultButton3
    end
end

function MarryHonorWindow:onhonorItemclick(item)
	self.selectdata = DataWedding.data_marry_honor[tonumber(item.name)]

	if self.selectItem ~= nil then
		self.selectItem.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton8")
        self.selectItem.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton8
	end
	self.selectItem = item
    self.selectItem.transform:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton9")
    self.selectItem.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton9

    self:Update_Info()
end

function MarryHonorWindow:okButtonClick()
	-- self:Close()
	-- NoticeManager.Instance:FloatTipsByString("别着急，等协议定好先")
    if self.model.marry_honor_id == self.selectdata.male_id or self.model.marry_honor_id == self.selectdata.female_id then
        NoticeManager.Instance:FloatTipsByString(TI18N("该称谓正在使用中"))
    else
        MarryManager.Instance:Send15028(self.selectdata.id)
    end
end

function MarryHonorWindow:showTips()
    TipsManager.Instance:ShowText({gameObject = self.tipsButton
            , itemData = {
                TI18N("1.激活称谓需要伴侣双方<color=#ffff00>组队</color>前来")
                , TI18N("2.切换至已激活的称谓，需要消耗<color=#00ff00>300{assets_2,90018}</color>")
                }
            })
end