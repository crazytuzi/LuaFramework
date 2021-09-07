-- @author hze
-- @date #2018/11/21#
-- @改成Window了

IntegralObtainPanel = IntegralObtainPanel or BaseClass(BaseWindow)

function IntegralObtainPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "IntegralObtainPanel"

    self.windowId = WindowConfig.WinID.integralobtainwin

    self.itemlist = {}

    self.resList = {
        {file = AssetConfig.integral_obtain_panel, type = AssetType.Main}
        ,{file = AssetConfig.integralexchange_textures, type = AssetType.Dep}
        ,{file = AssetConfig.dailyicon, type = Dep}
    }

    self.questudpatelistener = function() self:LoadItemList() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function IntegralObtainPanel:__delete()
    self.OnHideEvent:Fire()

    if self.layout ~= nil then 
        self.layout:DeleteMe()
    end

    for i,v in ipairs(self.itemlist) do
        if v.headIconloader ~= nil then 
            v.headIconloader:DeleteMe()
        end
        
        if v.loadersIcon ~= nil then 
            v.loadersIcon:DeleteMe()
        end
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function IntegralObtainPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.integral_obtain_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    self.closeBtn = t:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self.model:CloseIntegralObtainPanel() end)

    self.templateItem = t:Find("Main/TemplateItem").gameObject
    self.templateItem:SetActive(false)

    self.campaignRuleTxt = t:Find("Main/RuleTxt"):GetComponent(Text)

    self.layout = LuaGridLayout.New(t:Find("Main/Mask/Container").gameObject,{column = 2,bordertop = 5, borderleft = 8, cspacing = 10,rspacing = 10,cellSizeX = 271,cellSizeY = 94})
end

function IntegralObtainPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function IntegralObtainPanel:OnOpen()
    self:RemoveListeners()
    IntegralExchangeManager.Instance.OnUpdateQuestData:Add(self.questudpatelistener)

    self.campaignData = DataCampaign.data_list[self.model.integralCampId]

    self.campaignRuleTxt.text = self.campaignData.cond_rew

    IntegralExchangeManager.Instance:Send20461()
end

function IntegralObtainPanel:OnHide()
    self:RemoveListeners()
end

function IntegralObtainPanel:RemoveListeners()
    IntegralExchangeManager.Instance.OnUpdateQuestData:Remove(self.questudpatelistener)
end


function IntegralObtainPanel:LoadItemList()
    self.questData = self.model.questData.quest
    table.sort(self.questData, function(a,b) return a.quest_sort < b.quest_sort end )

    self.layout:ReSet()
    for i, v in ipairs(self.questData) do
        local tmp = self.itemlist[i] or {}
        if self.itemlist[i] == nil then 
            tmp.obj = GameObject.Instantiate(self.templateItem)
            tmp.transform = tmp.obj.transform
            tmp.headIconloader = SingleIconLoader.New(tmp.transform:Find("HeadBg/Image").gameObject)
            tmp.nameTxt = tmp.transform:Find("Name"):GetComponent(Text)
            tmp.loadersIcon = SingleIconLoader.New(tmp.transform:Find("Times/gain").gameObject)
            tmp.loadersIcon:SetSprite(SingleIconType.Item, DataItem.data_get[self.campaignData.loss_items[1][1]].icon)
            tmp.timesTxt = tmp.transform:Find("Times"):GetComponent(Text)
            tmp.numTxt = tmp.transform:Find("Times/num"):GetComponent(Text)
            tmp.progBarTxt =  tmp.transform:Find("ImgProg/TxtProgBar"):GetComponent(Text)
            tmp.progbarImg = tmp.transform:Find("ImgProg/ImgProgBar")
            tmp.sellout = tmp.transform:Find("Sellout").gameObject
            self.itemlist[i] = tmp
        end
        
        if self.assetWrapper:GetSprite(AssetConfig.dailyicon, v.icon) == nil then 
            tmp.headIconloader:SetSprite(SingleIconType.Item,tonumber(v.icon))
        else
            tmp.headIconloader:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.dailyicon, v.icon))
        end

        tmp.nameTxt.text = DataQuest.data_get[v.quest_id].name
        tmp.timesTxt.text = TI18N("完成获得")
        tmp.numTxt.text = "x"..v.reward_val
        tmp.progBarTxt.text = string.format("%s/%s",v.value, v.target_val)
        tmp.progbarImg.sizeDelta = Vector2(154 * (v.value / v.target_val),16)
        tmp.sellout.gameObject:SetActive(v.quest_status == 1) 
        BaseUtils.SetGrey(tmp.headIcon,v.quest_status == 1)
        self.layout:AddCell(tmp.obj)
        
    end
end


