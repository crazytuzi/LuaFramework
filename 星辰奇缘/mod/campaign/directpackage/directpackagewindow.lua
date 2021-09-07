-- @author hze
-- @date #2018/04/11#
--直购7日礼包

DirectPackageWindow = DirectPackageWindow or BaseClass(BaseWindow)

function DirectPackageWindow:__init(model)
    self.model = model
    self.mgr = SignDrawManager.Instance
    self.name = "DirectPackageWindow"

    self.isRotating = false

    self.windowId = WindowConfig.WinID.directpackagewindow

    self.resList = {
        {file = AssetConfig.directpackageWindow, type = AssetType.Main}
        ,{file = AssetConfig.directpackagebg, type = AssetConfig.Main}
        ,{file = AssetConfig.directpackagetxt, type = AssetConfig.Main}
        ,{ file = AssetConfig.directpackagetextures, type = AssetType.Dep }
    }


    self.itemlist = {}

    self.dayTxtFormatString = TI18N("第%s天")
    self.timeFormatString = TI18N("<color='%s'>%s月%s日-%s月%s日</color>")
    self.sString1 = TI18N("<color='#C0EAFF'>活动时间:</color>%s")
    self.sString2 = TI18N("<color='#FFF100'>领取时间:</color>%s")

    self._updatefunc = function() self:Update() end 
    

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function DirectPackageWindow:__delete()
    self.OnHideEvent:Fire()

    if self.layout ~= nil then 
        self.layout:DeleteMe()
    end

    for k ,v in ipairs(self.itemlist) do
        if v ~= nil then 
            if v.effect ~= nil then 
                v.effect:DeleteMe()
            end
            if v.loadersIcon ~= nil then 
                v.loadersIcon:DeleteMe()
            end
        end
    end

    BaseUtils.ReleaseImage(self.packageImg)

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function DirectPackageWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.directpackageWindow))
    self.gameObject.name = self.name

    UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)
    local Main = self.gameObject.transform:Find("Main")
    
    UIUtils.AddBigbg(Main:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.directpackagebg)))
    UIUtils.AddBigbg(Main:Find("BgTxt"), GameObject.Instantiate(self:GetPrefab(AssetConfig.directpackagetxt)))


    Main:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    self.titleTxt = Main:Find("Title/Text"):GetComponent(Text)
    self.tipsTxt = Main:Find("Tips"):GetComponent(Text)

    self.packageImg = Main:Find("PackageImg"):GetComponent(Image)
    self.cpmbg = Main:Find("Cpm/Cpmbg")
    self.cpmTxt1 = Main:Find("Cpm/Text1"):GetComponent(Text)
    self.cpmTxt2 = Main:Find("Cpm/Text2"):GetComponent(Text)
    self.cpmTxt2.transform.sizeDelta = Vector2(240, 22.8)


    self.scroll = Main:Find("ScrollRect"):GetComponent(ScrollRect)
    self.scroll.onValueChanged:AddListener(function()
        BaseUtils.DealExtraEffect(self.scroll, self.itemlist, {axis = BoxLayoutAxis.X, delta1 = 31, delta2 = 31})
    end)

    self.container = self.scroll.transform:Find("Container")

    self.tempItem = self.container:Find("Item").gameObject
    self.tempItem:SetActive(false)

    self.layout = LuaBoxLayout.New(self.container,{axis = BoxLayoutAxis.X, cspacing = 0, border = 0})

    self.button = Main:Find("Button"):GetComponent(Button)
    self.button.onClick:AddListener(function()         
        if SdkManager.Instance:RunSdk() then
            SdkManager.Instance:ShowChargeView(ShopManager.Instance.model:GetSpecialChargeData(self.model.value), self.model.value / 10, self.model.value / 10 * 10,"8")
        end 
    end)
    self.btnTxt = self.button.transform:Find("Text"):GetComponent(Text)
    self.buttonMark = Main:Find("BtnMark").gameObject
end

function DirectPackageWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function DirectPackageWindow:OnOpen()
    self:RemoveListeners()
    self.mgr.OnUpdateDirectPackage:Add(self._updatefunc)

    self.campId = self.openArgs.campId
    -- BaseUtils.dump(self.campId,"活动ID:")

    local campaignData = DataCampaign.data_list[self.campId]
    local str = string.format(self.timeFormatString, "#20FF45" ,campaignData.cli_start_time[1][2], campaignData.cli_start_time[1][3], campaignData.cli_end_time[1][2],campaignData.cli_end_time[1][3])
    self.cpmTxt1.text = string.format(self.sString1, str)

    self.titleTxt.text = campaignData.name
    self.tipsTxt.text = campaignData.cond_desc

    --界面数据初始化,请求页面数据
    self.mgr:Send20479()
end

function DirectPackageWindow:OnHide()
    self:RemoveListeners()
end

function DirectPackageWindow:RemoveListeners()
    self.mgr.OnUpdateDirectPackage:Remove(self._updatefunc)
end

function DirectPackageWindow:Update()
    self.btnTxt.text = string.format( "￥%s", self.model.value/10)
    self.cpmTxt2.text = self:GetDirectPackageBuyTimeString()
    self.button.gameObject:SetActive(not self.model:GetDirectPackageBuyStatus())
    self.buttonMark:SetActive(self.model:GetDirectPackageBuyStatus())
    
    if self:GetDirectPackageBuyTimeString() == "" then 
        self.cpmbg.transform.sizeDelta = Vector2(278,33.7)
    else
        self.cpmbg.transform.sizeDelta = Vector2(517.8,33.7)
    end

    local protoData = self.model.data20479
    table.sort(protoData, function(a,b) return a.id < b.id end )

    self.layout:ReSet()
    for i, v in ipairs(protoData) do
        local tmp = self.itemlist[i] or {}
        if self.itemlist[i] == nil then 
            tmp.gameObject = GameObject.Instantiate(self.tempItem)
            tmp.transform = tmp.gameObject.transform
            tmp.dayTxt = tmp.transform:Find("DayTxt"):GetComponent(Text)
            tmp.icon = tmp.transform:Find("IconImg")
            tmp.loadersIcon = SingleIconLoader.New(tmp.icon.gameObject)
            tmp.mark = tmp.transform:Find("Mark").gameObject
            tmp.effect = BaseUtils.ShowEffect(20119, tmp.icon, Vector3(1.3,1.3,1.3), Vector3(0,0,0))
            tmp.iconbtn = tmp.icon:GetComponent(Button)
            tmp.gameObject:SetActive(true)
            self.itemlist[i] = tmp
        end
        tmp.dayTxt.text = string.format( self.dayTxtFormatString, BaseUtils.NumToChn(v.id))
        tmp.loadersIcon:SetSprite(SingleIconType.Item, DataItem.data_get[v.gift_id].icon)
        tmp.mark:SetActive(v.flag == 1)

        tmp.effectflag = v.flag == 2
        if tmp.effect ~= nil then
            tmp.effect:SetActive(v.flag == 2)
        end 
        
        tmp.iconbtn.onClick:RemoveAllListeners()
        if v.flag == 0 then
            tmp.iconbtn.onClick:AddListener(function() self:ShowGift(v.gift_id) end)
        elseif v.flag == 2 then 
            tmp.iconbtn.onClick:AddListener(function() self.mgr:Send20480(v.id) end)
        end
        
        self.layout:AddCell(tmp.gameObject)
    end
end

--打开礼包
function DirectPackageWindow:ShowGift(gift_id)
    -- print("打开礼包内容,gift_id:" .. gift_id)
    local gift_list = DataItemGift.data_show_gift_list[gift_id]
    
    local callBack = function(myself) myself.gameObject.transform.localPosition = Vector3(myself.gameObject.transform.localPosition.x,myself.gameObject.transform.localPosition.y,200) end

    if self.possibleReward == nil then
        self.possibleReward = SevenLoginTipsPanel.New(self,callBack)
    end
    self.possibleReward:Show({CampaignManager.ItemFilterForItemGift(gift_list),4,{140,140,120,120},TI18N("可获得以下道具")})
end

--获取可领取时间段
function DirectPackageWindow:GetDirectPackageBuyTimeString()
    local str = ""
    if self.model.buy_time > 0 then 
        local opentime = BaseUtils.CurrentZeroTime(self.model.buy_time)
        local endtime = BaseUtils.CurrentZeroTime(opentime + 86400 * (#self.model.data20479 - 1))

        local open_month = os.date("%m", opentime)
        local open_day = os.date("%d", opentime)

        local end_month = os.date("%m", endtime)
        local end_day = os.date("%d", endtime)

        str = string.format(self.timeFormatString, "#FFF100", tonumber(open_month), tonumber(open_day), tonumber(end_month), tonumber(end_day))
        str = string.format(self.sString2, str)
    end
    return str
end
