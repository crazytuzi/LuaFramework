-- @author xhs
-- @date 2017年12月15日

RealNamePanel = RealNamePanel or BaseClass(BasePanel)

function RealNamePanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "RealNamePanel"

    self.resList = {
        {file = AssetConfig.real_name, type = AssetType.Main},
        {file = AssetConfig.realnamei18n, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
    }

    self.itemList = {}

    self.hideEffect = function ()
        self:HideEffect()
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function RealNamePanel:__delete()
    self.OnHideEvent:Fire()

    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v.slot:DeleteMe()
                v.itemdata:DeleteMe()
            end
        end
        self.itemList = nil
    end

    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end

    if self.btnEffect == nil then
        self.btnEffect:DeleteMe()
        self.btnEffect = nil
    end

    self:AssetClearAll()
end

function RealNamePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.real_name))
    self.gameObject.name = "RealNamePanel"
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t
    UIUtils.AddBigbg(t:Find("BigBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.realnamei18n)))


    self.layout = LuaBoxLayout.New(t:Find("Reward/Scroll/Container"), {axis = BoxLayoutAxis.X, border = 10, cspacing = 10})

    local data = DataAuthSfz.data_reward[1].reward
    self.layout:ReSet()
    local weight = #data*(64+10)+10
    t:Find("Reward/Scroll"):GetComponent(RectTransform).sizeDelta = Vector2(weight,65)

    for i,v in ipairs(data) do
        local tab = self.itemList[i]
        if tab == nil then
            tab = {}
            tab.slot = ItemSlot.New()
            tab.itemdata = ItemData.New()
            self.itemList[i] = tab
        end
        tab.itemdata:SetBase(DataItem.data_get[v[1]])
        tab.slot:SetAll(tab.itemdata)
        tab.slot:SetNum(v[3])
        self.layout:AddCell(tab.slot.gameObject)
    end

    self.jumpBtn = t:Find("JumpBtn"):GetComponent(Button)
    self.jumpBtn.onClick:AddListener(function()
        if SdkManager.Instance.age == 0 then
            SdkManager.Instance:OpenRealNameWindow()
        else
            BibleManager.Instance:send9955()
        end
    end)

    self.btnText = t:Find("JumpBtn/Text"):GetComponent(Text)

    if SdkManager.Instance.age == 0 then
        self.btnText.text = TI18N("前往认证")
    else
        self.btnText.text = TI18N("领取奖励")
    end

    if self.btnEffect == nil then
        self.btnEffect = BaseUtils.ShowEffect(20053, self.jumpBtn.transform, Vector3(1.9,0.75,1), Vector3(-60,-16,-1000))
    end

end

function RealNamePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function RealNamePanel:OnOpen()
    self:AddListeners()

end

function RealNamePanel:OnHide()
    self:RemoveListeners()
end

function RealNamePanel:AddListeners()
    BibleManager.Instance.onRealName:AddListener(self.hideEffect)
end

function RealNamePanel:RemoveListeners()
    BibleManager.Instance.onRealName:RemoveListener(self.hideEffect)
end

function RealNamePanel:HideEffect()
    self.btnText.text = TI18N("已领取")
    self.btnEffect:SetActive(false)
    self.jumpBtn.gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    self.btnText.color =  ColorHelper.DefaultButton4
end

function RealNamePanel:OnReturn()
    self.btnText.text = TI18N("领取奖励")
end
