-- @author hze
-- @date #18/03/15#
--成长基金

GrowFundSubPanel = GrowFundSubPanel or BaseClass(BasePanel)

function GrowFundSubPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "GrowFundSubPanel"

    --self.growType = grow_type

    self.resList = {
    	{file  =  AssetConfig.grow_fund_subpanel, type  =  AssetType.Main}
       ,{file = AssetConfig.open_server_textures, type = AssetType.Dep}
    }

    self.itemList = {}


    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GrowFundSubPanel:__delete()

    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end

    if self.itemList ~= nil then
        self.itemList = nil
    end

    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function GrowFundSubPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.grow_fund_subpanel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    t:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function()
        BibleManager.Instance.showgrowEffect:Fire()
        self:Hiden() end)

    local btn = t:Find("Panel"):GetComponent(Button)
    if btn == nil then
        btn = t:Find("Panel").gameObject:AddComponent(Button)
    end
    btn.onClick:AddListener(function()
        BibleManager.Instance.showgrowEffect:Fire()
        self:Hiden() end)

    self.title = t:Find("Main/Title/Text"):GetComponent(Text)
    self.endText = t:Find("Main/EndDesc/Text"):GetComponent(Text)

    self.templateItem = t:Find("Main/Area/TemplateItem").gameObject
    self.templateItem:SetActive(false)
    self.layout = LuaBoxLayout.New(t:Find("Main/Area/Container"),{axis = BoxLayoutAxis.Y, cspacing = 0, border = 0})



end

function GrowFundSubPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GrowFundSubPanel:OnOpen()
    self:RemoveListeners()
    if self.openArgs ~= nil then
        self.type = self.openArgs
    end

    if self.type == 980 then
        self.title.text = TI18N("福利基金")
        self.endText.text = TI18N("880%")
    elseif self.type == 1980 then
        self.title.text = TI18N("豪华基金")
        self.endText.text = TI18N("980%")
    end




    local datalist = BaseUtils.copytab(DataGrowthFund.data_growth)
    for i=1,8 do    --8个档位
        local key = string.format("%s_%s",self.type,i)
        local basedata = datalist[key]
        if self.itemList[i] == nil then
            local obj = GameObject.Instantiate(self.templateItem)
            self.layout:AddCell(obj)
            self.itemList[i] = obj
        end

        if i == 1 then
            self.itemList[i].transform:Find("Text1"):GetComponent(Text).text = TI18N("购买基金")
        else
            self.itemList[i].transform:Find("Text1"):GetComponent(Text).text = string.format(TI18N("%s级"), tostring(basedata.lev))
        end
        self.itemList[i].transform:Find("Text2"):GetComponent(Text).text = basedata.reward[1][2]
        self.itemList[i].transform:Find("Icon"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[basedata.reward[1][1]])
        if i % 2 == 0 then
            self.itemList[i].transform:GetComponent(Image).color = Color(121/255, 166/255, 208/255, 1)
        else
            self.itemList[i].transform:GetComponent(Image).color = Color(161/255, 203/255, 245/255, 1)
        end
    end
end

function GrowFundSubPanel:OnHide()
    self:RemoveListeners()
end

function GrowFundSubPanel:RemoveListeners()
end


