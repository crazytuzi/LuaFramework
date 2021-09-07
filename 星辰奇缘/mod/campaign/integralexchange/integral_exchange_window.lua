-- @author hze
-- @date #2018/11/21#

IntegralExchangeWindow = IntegralExchangeWindow or BaseClass(BaseWindow)

function IntegralExchangeWindow:__init(model)
    self.model = model
    self.name = "IntegralExchangeWindow"

    self.windowId = WindowConfig.WinID.integralexchangewindow

    self.resList = {
        {file = AssetConfig.integral_exchange_window, type = AssetType.Main}
        ,{file = AssetConfig.integralexchange_bg1, type = AssetType.Main}
        ,{file = AssetConfig.integralexchange_bg2, type = AssetType.Dep}
        ,{file = AssetConfig.integralexchange_textures, type = AssetType.Dep}
    }

    self.layout_list = {}
    self.itemlist = {}
    self.ItemTypeData = {}

    self.scroll_list = {}
    self.container_list = {}

    self.clickUniqueId = nil 

    self.initflag = true

    self.itemudpatelistener = function() 
        -- if self.initflag then 
            self:LoadItemList() 
        -- else
        --     self:LoadSingleItemList()
        -- end
    end
    self.integraludpatelistener = function() self:UpdateIntegral()  end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function IntegralExchangeWindow:__delete()
    self.OnHideEvent:Fire()

    BaseUtils.ReleaseImage(self.bg2)

    for i = 1, 4 do
        if self.layout_list[i] ~= nil then 
            self.layout_list[i]:DeleteMe()
        end
    end

    for _,val in ipairs(self.itemlist) do
        if val.loadersIcon ~= nil then val.loadersIcon:DeleteMe() end
        if val.itemslot ~= nil then val.itemslot:DeleteMe() end
        if val.itemdata ~= nil then val.itemdata:DeleteMe() end
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function IntegralExchangeWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.integral_exchange_window))
    self.gameObject.name = self.name
    local main = self.gameObject.transform:Find("Main")
    UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)
    UIUtils.AddBigbg(main:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.integralexchange_bg1)))

    self.bg2 = main:Find("Right"):GetComponent(Image)
    self.bg2.sprite = self.assetWrapper:GetSprite(AssetConfig.integralexchange_bg2 , "integralexchange_bg2")

    self.closeBtn = main:Find("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    self.templateItem = main:Find("TemplateItem").gameObject
    self.templateItem:SetActive(false)

    self.left = main:Find("Left")
    self.leftBtn = self.left:Find("Button"):GetComponent(Button)
    self.leftBtn.onClick:AddListener(function()  self.model:OpenIntegralObtainPanel() end)

    self.integralTxt = self.left:Find("IntegralTxt"):GetComponent(Text)
    self.campaignTimeTxt = self.left:Find("TimeTxt"):GetComponent(Text)
    self.campaignTitleTxt = main:Find("Tips"):GetComponent(Text)
    self.campaignRuleTxt = self.left:Find("RuleTxt"):GetComponent(Text)
    self.campaignRuleTxt.transform.sizeDelta = Vector2(210,30)

    self.specailBtn = main:Find("SpecailButton"):GetComponent(Button)
    self.specailBtn.onClick:AddListener(function() self:ClickShowRewardList(1) end)
    self.commonBtn = main:Find("CommonButton"):GetComponent(Button)
    self.commonBtn.onClick:AddListener(function() self:ClickShowRewardList(2) end)

    self.noticeBtn = main:Find("Notice").gameObject:GetComponent(Button)
    self.noticeBtn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {self.campaignData.cond_desc}}) end)

    for i = 1, 4 do
        self.scroll_list[i] = main:Find(string.format("Mask%s",i)):GetComponent(ScrollRect)
        self.container_list[i] = self.scroll_list[i].transform:Find("Container")
        self.scroll_list[i].onValueChanged:AddListener(function() self:OnRectScroll(i) end)
        self.layout_list[i] = LuaBoxLayout.New(self.container_list[i],{axis = BoxLayoutAxis.Y, cspacing = 0, border = 0})
    end

end

function IntegralExchangeWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function IntegralExchangeWindow:OnOpen()
    self:RemoveListeners()
    IntegralExchangeManager.Instance.OnUpdateItemList:Add(self.itemudpatelistener)
    IntegralExchangeManager.Instance.OnUpdateIntegral:Add(self.integraludpatelistener)

    if self.openArgs ~= nil and self.openArgs.campId ~= nil then 
        self.model.integralCampId = self.openArgs.campId
        self.campaignData = DataCampaign.data_list[self.openArgs.campId]
    end
    self.campaignTimeTxt.text = string.format( TI18N("时间：%s月%s日-%s月%s日"), self.campaignData.cli_start_time[1][2],self.campaignData.cli_start_time[1][3],self.campaignData.cli_end_time[1][2],self.campaignData.cli_end_time[1][3])
    self.campaignTitleTxt.text = self.campaignData.reward_title
    self.campaignRuleTxt.text = self.campaignData.content

    self:UpdateIntegral()

    self.initflag = true
    
    IntegralExchangeManager.Instance:Send20460()
end
    

function IntegralExchangeWindow:OnHide()
    self:RemoveListeners()
end

function IntegralExchangeWindow:RemoveListeners()
    IntegralExchangeManager.Instance.OnUpdateItemList:Remove(self.itemudpatelistener)
    IntegralExchangeManager.Instance.OnUpdateIntegral:Remove(self.integraludpatelistener)
end

function IntegralExchangeWindow:LoadItemList()
    self.ItemTypeData = self.model.ItemTypeData.special_items or{}
    for i = 1, 4 do
        self.layout_list[i]:ReSet()
    end
    
    for k, v in ipairs(self.ItemTypeData) do
        local tmp = self.itemlist[k] or {}
        if self.initflag then   
            if self.itemlist[k] == nil then 
                tmp.obj = GameObject.Instantiate(self.templateItem)
                tmp.itemsell = tmp.obj.transform:Find("ItemSell")
                tmp.itemzhezhao = tmp.itemsell:Find("Zhezhao")
                tmp.nameTxt = tmp.itemsell:Find("Name"):GetComponent(Text)
                tmp.btn = tmp.itemsell:Find("Button"):GetComponent(Button)
                tmp.numTxt = tmp.btn.transform:Find("Text"):GetComponent(Text)
                tmp.numTxt1 = tmp.btn.transform:Find("Text1"):GetComponent(Text)
                tmp.loadersIcon = SingleIconLoader.New(tmp.btn.transform:Find("gain").gameObject)
                tmp.loadersIcon:SetSprite(SingleIconType.Item, DataItem.data_get[self.campaignData.loss_items[1][1]].icon)
                tmp.itemslot = ItemSlot.New()
                UIUtils.AddUIChild(tmp.itemsell:Find("Item").gameObject, tmp.itemslot.gameObject)
                tmp.itemdata = ItemData.New()
                tmp.itemSellOut = tmp.obj.transform:Find("ItemSellOut")
                self.itemlist[k] = tmp
            end
            
            if v.exchange_num ~= 0 then 
                tmp.nameTxt.text = DataItem.data_get[v.item_id].name
                tmp.numTxt.text = v.cost
                tmp.itemdata:SetBase(DataItem.data_get[v.item_id])
                tmp.itemslot:SetAll(tmp.itemdata,{inbag = false, nobutton = true})
                tmp.itemslot:SetNum(v.base_num)
                tmp.itemslot:ShowEffect(v.is_effect == 1,20223)
                tmp.btn.onClick:RemoveAllListeners()
                tmp.btn.onClick:AddListener(function() self:ClickObtainIntegralBtn(v) end)
            end
            tmp.order = (v.id - 1) % 4 + 1
            self.layout_list[tmp.order]:AddCell(tmp.obj)
        end

        tmp.itemsell.gameObject:SetActive(v.exchange_num ~= 0)
        tmp.itemSellOut.gameObject:SetActive(v.exchange_num == 0)
        if v.exchange_num ~= 0 then
            v.can = v.can or false
            tmp.numTxt.transform.gameObject:SetActive(v.can)
            tmp.btn.transform:Find("gain").gameObject:SetActive(v.can)
            
            tmp.numTxt1.transform.gameObject:SetActive(not v.can)
            tmp.itemzhezhao.gameObject:SetActive(not v.can)
        end
    end
    
    self.initflag = false
    for i = 1, 4 do
        self.container_list[i].anchoredPosition = Vector2(0,self.model.last_pos[i])
    end
end

--策划搞事情
function IntegralExchangeWindow:LoadSingleItemList()
    self.ItemTypeData = self.model.ItemTypeData.special_items or{}
    
    for k, v in ipairs(self.ItemTypeData) do
        local _id = string.format( "%s_%s_%s",v.id, v.order_id, v.item_id)
        if self.clickUniqueId == _id then 
            if self.itemlist[k] ~= nil then 
                self.itemlist[k].itemsell.gameObject:SetActive(v.exchange_num ~= 0)
                self.itemlist[k].itemSellOut.gameObject:SetActive(v.exchange_num == 0)
            end
        end
    end
end

function IntegralExchangeWindow:UpdateIntegral()
    self.integralTxt.text = RoleManager.Instance.RoleData:GetMyAssetById(KvData.assets.score_exchange)
end

--type (1为特殊/2为普通)
function IntegralExchangeWindow:ClickShowRewardList(type)
    if type == 1 then 
        self.ItemTypeData = self.model.ItemTypeData.special_items
    elseif type == 2 then 
        self.ItemTypeData = self.model.ItemTypeData.common_items
    end
    self:LoadItemList()
end

function IntegralExchangeWindow:ClickObtainIntegralBtn(dat)
    self.clickUniqueId = string.format( "%s_%s_%s",dat.id, dat.order_id, dat.item_id)
    IntegralExchangeManager.Instance:Send20462(dat.id, dat.order_id, dat.item_id)
end


function IntegralExchangeWindow:OnRectScroll(order)
    self.model.last_pos[order] = self.container_list[order].anchoredPosition.y

    local container = self.container_list[order]
    local top = -container.anchoredPosition.y
    local bottom = top - self.scroll_list[order].transform.sizeDelta.y

    for k,v in pairs(self.itemlist) do
        if v.order == order then 
            local ay = v.obj.transform.anchoredPosition.y - 46
            local sy = v.obj.transform.sizeDelta.y - 46 - 35
            local state = nil
            if ay > top or ay - sy < bottom then
                state = false
            else
                state = true
            end
            if v.itemslot.effect ~= nil then 
                v.itemslot.effect:SetActive(state)
            end
        end
    end
end
