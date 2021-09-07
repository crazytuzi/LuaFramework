--作者:hzf
--01/04/2017 15:47:30
--功能:子女获取第一步窗口

ChildrenHowToGetPanel = ChildrenHowToGetPanel or BaseClass(BasePanel)
function ChildrenHowToGetPanel:__init(parent)
	self.parent = parent
    self.Mgr = ChildrenManager.Instance
	self.resList = {
		{file = AssetConfig.howtogetchildrenpanel, type = AssetType.Main},
		{file = AssetConfig.ridebg, type = AssetType.Dep},
		{file = AssetConfig.attr_icon, type = AssetType.Dep},
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
	self.currindex = 1
	self.sexicon = {
		[0] = "IconSex0",
        [1] = "IconSex1",
		[2] = "IconSex1",
	}
	self.classType = {
		[1] = "AttrIcon4",
		[2] = "AttrIcon5",
		[3] = "AttrIcon1",
	}
	self.parentClassTo_classType = {
		[1] = 1,
		[2] = 2,
		[3] = 1,
		[4] = 3,
		[5] = 3,
		[6] = 2,
	}
	self.ChildrenData = {
        [1] = BaseUtils.copytab(DataUnit.data_unit[71151]),
        [2] = BaseUtils.copytab(DataUnit.data_unit[71152]),
        [3] = BaseUtils.copytab(DataUnit.data_unit[71153]),
        [4] = BaseUtils.copytab(DataUnit.data_unit[71154]),
        [5] = BaseUtils.copytab(DataUnit.data_unit[71155]),
        [6] = BaseUtils.copytab(DataUnit.data_unit[71156]),
    }
end

function ChildrenHowToGetPanel:__delete()
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end

	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function ChildrenHowToGetPanel:OnHide()

end

function ChildrenHowToGetPanel:OnOpen()

end

function ChildrenHowToGetPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.howtogetchildrenpanel))
	self.gameObject.name = "ChildrenHowToGetPanel"
	UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)

	self.transform = self.gameObject.transform
	self.bg = self.transform:Find("bg")
	self.transform:Find("bg/PreviewBg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.ridebg, "RideBg")
	self.preview = self.transform:Find("preview")
	self.Text1 = self.transform:Find("Desbg/Text1"):GetComponent(Text)
	self.Text1.text = string.format(TI18N("子女是父母贴心的小棉袄，闯荡四方的你是否也想要这种温暖呢？子女养育至成长期后，更能成为父母的得力帮手，代替宠物与你征战天下 "))
	self.Text2 = self.transform:Find("Desbg/Text2"):GetComponent(Text)
	self.Text2.text = string.format(TI18N("1.伴侣双方可通过完成<color='#00ff00'>浓情蜜意</color>任务孕育胎儿 \n2.单身玩家可通过采集精灵圣水浇灌灵花获得孩子"))
	self.Title1Text = self.transform:Find("Title1/Text"):GetComponent(Text)
	self.Title2Text = self.transform:Find("Title2/Text"):GetComponent(Text)
	self.Button = self.transform:Find("Button"):GetComponent(Button)
    self.transform:Find("Button/Text"):GetComponent(Text).text = TI18N("孕育子女")
	self.Button.onClick:AddListener(function()
		self:OnClickButton()
	end)
	-- self.Attention = self.transform:Find("Attention")
	self.AttentionText = self.transform:Find("Attention/Text"):GetComponent(Text)
    self.transform:Find("LButton"):GetComponent(Button).onClick:AddListener(function()
        self:OnLeft()
    end)
    self.transform:Find("RButton"):GetComponent(Button).onClick:AddListener(function()
        self:OnRight()
    end)
    self.currentGo = self.transform:Find("current").gameObject
    self.currentGo:SetActive(false)
    self.currentsex = self.transform:Find("current/sex"):GetComponent(Image)
    self.currentclass = self.transform:Find("current/class"):GetComponent(Image)
    self.currentname = self.transform:Find("current/name"):GetComponent(Text)
    self.TipsPanel = self.transform:Find("TipsPanel")
    self.transform:Find("current"):GetComponent(Button).onClick:AddListener(function()
        self.TipsPanel.gameObject:SetActive(true)
    end)
    self.TipsPanel:GetComponent(Button).onClick:AddListener(function()
        self.TipsPanel.gameObject:SetActive(false)
    end)
    self.TipsPanel:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function()
        self.TipsPanel.gameObject:SetActive(false)
    end)
    local hasNumber = math.max(0,self.Mgr.max_childNum-#self.Mgr.childData)
    print(hasNumber)
	self.AttentionText.text = string.format("当前已孕育%s名子女，还可以孕育%s名<color='#00ff00'>（上限:单身3名,结缘4名）</color>", tostring(#self.Mgr.childData),tostring(hasNumber))

    self:LoadPreview()
end

function ChildrenHowToGetPanel:OnClickButton()
    if (QuestManager.Instance.childPlantData == nil or QuestManager.Instance.childPlantData.unit_id == 0) and (MarryManager.Instance.loverData ~= nil and MarryManager.Instance.loverData.status ~= 3 and MarryManager.Instance.loverData.id ~= 0 and MarryManager.Instance.loverData.status ~= 0) then
        NoticeManager.Instance:FloatTipsByString(TI18N("请完成典礼后再进行任务吧"))
        return
    end
    if MarryManager.Instance.loverData ~= nil then
        ChildrenManager.Instance.model:OpenGetWayPanel()
    else
        if QuestManager.Instance.childPlantData ~= nil and QuestManager.Instance.childPlantData.unit_id ~= 0 then
            ChildrenManager.Instance.model:OpenGetWayPanel()
        else
            local enoughCall = function()
            local item_data = BackpackManager.Instance:GetItemByBaseid(23807)
                BackpackManager.Instance:Use(item_data[1].id, 1, 23807)
                ChildrenManager.Instance.model:OpenGetWayPanel()
            end
            local buyCall = function()
                WindowManager.Instance:OpenWindowById(17805, {4})
            end
            local data = {icon = "target1" ,itemid = 23807, need = 1, title = TI18N("天地灵种"), desc = TI18N("购买天地灵种，开启孕育任务"), btntext = TI18N("开启"), enoughCall = enoughCall, buyCall = buyCall}
            ChildrenManager.Instance.model:OpenNoticeTargetPanel(data)
        end
    end
	ChildrenManager.Instance.model:CloseGetWindow()
end

function ChildrenHowToGetPanel:OnLeft()
	self.currindex = self.currindex - 1
	if self.currindex < 1 then
		self.currindex = #self.ChildrenData
	end
	self:LoadPreview()
end

function ChildrenHowToGetPanel:OnRight()
	self.currindex = self.currindex + 1
	if self.currindex > #self.ChildrenData then
		self.currindex = 1
	end
	self:LoadPreview()
end

function ChildrenHowToGetPanel:LoadPreview()
	local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "ChildrenHowToGetPanel"
        ,orthographicSize = 0.35
        ,width = 280
        ,height = 300
        ,offsetY = -0.28
    }
    local baseData = self.ChildrenData[self.currindex]
    local modelData = {type = PreViewType.Npc, skinId = baseData.skin, modelId = baseData.res, animationId = baseData.animation_id, scale = 1}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
    self.previewComp:Show()
end

function ChildrenHowToGetPanel:SetRawImage(composite)
	local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 74, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    -- self.preview:SetActive(true)
    local childbase = self.ChildrenData[self.currindex]
    self.currentsex.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, self.sexicon[childbase.sex])
    self.currentclass.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, self.classType[self.parentClassTo_classType[childbase.classes]])
    self.currentname.text = childbase.name
	self.currentGo:SetActive(true)
end
