-- -------------------------------------
-- 获取第一本宠物技能书
-- hosr
-- -------------------------------------
DramaGetPetBook = DramaGetPetBook or BaseClass(BaseDramaPanel)

function DramaGetPetBook:__init(callback)
    self.callback = callback

    self.path = "prefabs/ui/drama/dramagetbook.unity3d"

    self.resList = {
        {file = self.path, type = AssetType.Main},
    }

    self.selectId = 20141 -- 20140
    self.imgLoader = nil
    self.imgLoader1 = nil
end

function DramaGetPetBook:__delete()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end

    if self.imgLoader1 ~= nil then
        self.imgLoader1:DeleteMe()
        self.imgLoader1 = nil
    end

    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
end

function DramaGetPetBook:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject:SetActive(false)
    -- UIUtils.AddUIChild(DramaManager.Instance.model.dramaCanvas, self.gameObject)
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    self.gameObject.transform:SetAsFirstSibling()

    self.transform = self.gameObject.transform
    self.mainObj = self.transform:Find("Main").gameObject
    self.mainTransform = self.mainObj.transform

    self.mainTransform:Find("Button"):GetComponent(Button).onClick:AddListener(function() self:Click() end)

    self.title = self.mainTransform:Find("Title"):GetComponent(Text)
   

    self.mainTransform:Find("Icon"):GetComponent(Button).onClick:AddListener(function() self:Choose(1) end)
    self.iconImg = self.mainTransform:Find("Icon/Icon"):GetComponent(Image)
    self.iconTxt = self.mainTransform:Find("Icon/Text"):GetComponent(Text)
    self.selectImg = self.mainTransform:Find("Icon/Select").gameObject
    self.selectImg:SetActive(true)

    local data = DataItem.data_get[20141]
    self.iconTxt.text = ColorHelper.color_item_name(data.quality, data.name)

    if self.imgLoader == nil then
        local go = self.iconImg.gameObject
        self.imgLoader = SingleIconLoader.New(go)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, data.icon)

    self.mainTransform:Find("Icon1"):GetComponent(Button).onClick:AddListener(function() self:Choose(2) end)
    self.iconImg1 = self.mainTransform:Find("Icon1/Icon"):GetComponent(Image)
    self.iconTxt1 = self.mainTransform:Find("Icon1/Text"):GetComponent(Text)
    self.selectImg1 = self.mainTransform:Find("Icon1/Select").gameObject
    self.selectImg1:SetActive(false)

    local data1 = DataItem.data_get[20140]
    self.iconTxt1.text = ColorHelper.color_item_name(data1.quality, data1.name)
    if self.imgLoader1 == nil then
        local go = self.iconImg1.gameObject
        self.imgLoader1 = SingleIconLoader.New(go)
    end
    self.imgLoader1:SetSprite(SingleIconType.Item, data1.icon)

    self.title.text = string.format(TI18N("请选择想要的宠物技能书，<color='#00ff00'>%s</color>适合法攻宠物，<color='#00ff00'>%s</color>适合物攻宠物"), data.name, data1.name)
end

function DramaGetPetBook:OnInitCompleted()
    DramaManager.Instance.model:ShowJump(false)
end

function DramaGetPetBook:SetData(action)
end

function DramaGetPetBook:Choose(index)
    if index == 1 then
        self.selectImg:SetActive(true)
        self.selectImg1:SetActive(false)
        self.selectId = 20141
        TipsManager.Instance:ShowSkill({gameObject = self.iconImg.gameObject, type = Skilltype.petskill, skillData = DataSkill.data_petSkill["60041_1"]})
    else
        self.selectImg1:SetActive(true)
        self.selectImg:SetActive(false)
        self.selectId = 20140
        TipsManager.Instance:ShowSkill({gameObject = self.iconImg1.gameObject, type = Skilltype.petskill, skillData = DataSkill.data_petSkill["60040_1"]})
    end
end

function DramaGetPetBook:Click()
    Connection.Instance:send(10540, {id = self.selectId})
    if self.callback ~= nil then
        self.callback()
    end
end