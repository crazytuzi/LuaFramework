-- @author hze
-- @date #18/03/15#

OpenServerMonthAndFundPanel = OpenServerMonthAndFundPanel or BaseClass(BasePanel)

function OpenServerMonthAndFundPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "OpenServerMonthAndFundPanel"

    self.resList = {
        {file = AssetConfig.open_server_monthandfund, type = AssetType.Main}
        ,{file = AssetConfig.open_server_textures, type = AssetType.Dep}
    }

    self.NoticeTxtData = {
        [1] = TI18N("购买后立即获得<color='#ffff00'>300</color>{assets_2,90002}\n每天可领<color='#ffff00'>5000</color>{assets_2,90003}(总计15万，<color='#ffff00'>10</color>倍返利)\n<color='#00ff00'>专属福利</color>：<color='#ffff00'>每日前3次洗髓免费</color>\n<color='#00ff00'>贴心特权</color>：饱食度+10、活力上限+200等"),
        [2] = TI18N("65级前专属福利，累计<color='#ffff00'>返利800%</color>\n购买福利基金后<color='#ffff00'>立即获得1980</color>{assets_2,90002}\n每10级可领<color='#ffff00'>海量红钻</color>，累计<color='#ffff00'>14000</color>{assets_2,90026}")
    }


    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function OpenServerMonthAndFundPanel:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function OpenServerMonthAndFundPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_monthandfund))
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    local t = self.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.container = t:Find("Bg/BigRewardContainer")

    self.container:Find("Image"):GetChild(0).anchoredPosition = Vector2(-164,39.1)
    self.container:Find("Image"):GetChild(1).anchoredPosition = Vector2(-164,16.1)
    self.container:Find("Image"):GetChild(2).anchoredPosition = Vector2(-164,-6.9)
    self.container:Find("Image"):GetChild(3).anchoredPosition = Vector2(-164,-28.4)
    self.container:Find("Image"):GetChild(4).anchoredPosition = Vector2(33.1,-25.4)

    self.left = self.container:Find("LeftBg")
    self.right = self.container:Find("RightBg")

    self.noticeTxt = MsgItemExt.New(t:Find("Bg/BigRewardContainer/Image/NoticeText"):GetComponent(Text), 330, 20, 50)

    self.rightSeleted = self.right:Find("Selected").gameObject
    self.leftSeleted = self.left:Find("Selected").gameObject

    self.rightSeleted.transform:Find("Arrow").anchoredPosition = Vector2(0,-132)
    self.leftSeleted.transform:Find("Arrow").anchoredPosition = Vector2(0,-132)

    self.moreBtn = t:Find("Bg/MoreButton"):GetComponent(Button)
    self.moreBtn.transform.anchoredPosition = Vector2(-107.6,-187.6)
    self.moreBtn.onClick:AddListener(function() self:OpenSubPanel() end)

    self.turnBtn = t:Find("Bg/TurnButton"):GetComponent(Button)
    self.turnBtn.onClick:AddListener(function() self:TurnBtnPanel() end)

    self.left:GetComponent(Button).onClick:AddListener(function() self:ChangeTab(1) end)
    self.right:GetComponent(Button).onClick:AddListener(function() self:ChangeTab(2) end)

end

function OpenServerMonthAndFundPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function OpenServerMonthAndFundPanel:OnOpen()
    self:RemoveListeners()
    self:ChangeTab(1)
end

function OpenServerMonthAndFundPanel:OnHide()
    self:RemoveListeners()
end

function OpenServerMonthAndFundPanel:RemoveListeners()
end


function OpenServerMonthAndFundPanel:ChangeTab(type)
    if type == 1 then
        self.currentIndex = 1
        self.moreBtn.gameObject:SetActive(true)
        self.rightSeleted:SetActive(false)
        self.leftSeleted:SetActive(true)
        self.container:Find("Image"):GetChild(3).gameObject:SetActive(true)
    elseif type == 2 then
        self.currentIndex = 2
        self.moreBtn.gameObject:SetActive(false)
        self.rightSeleted:SetActive(true)
        self.leftSeleted:SetActive(false)
        self.container:Find("Image"):GetChild(3).gameObject:SetActive(false)
    end
    self.noticeTxt:SetData(self.NoticeTxtData[type])
end

function OpenServerMonthAndFundPanel:TurnBtnPanel()
    if self.currentIndex == 1 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {4})
    elseif self.currentIndex == 2 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.biblemain, {1,18})
    end
end

function OpenServerMonthAndFundPanel:OpenSubPanel()
    if self.subpanel == nil then
        self.subpanel = OpenServerMonthSubPanel.New(self.model,self.model.mainWin.gameObject)
    end
    self.subpanel:Show()
end
