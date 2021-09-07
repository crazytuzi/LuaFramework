ValentineModel = ValentineModel or BaseClass(BaseModel)

function ValentineModel:__init()
end

function ValentineModel:__delete()
end

function ValentineModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = ValentineWindow.New(self)
    end
    self.mainWin:Open(args)
end

function ValentineModel:CloseWindow()
    if self.mainWin ~= nil then
        WindowManager.Instance:CloseWindow(self.mainWin)
    end
end

function ValentineModel:OpenExchange()
    local datalist = {}
    for i,v in pairs(ShopManager.Instance.model.datalist[2][14] or {}) do
        table.insert(datalist, v)
    end

    if self.exchangeWin == nil then
        self.exchangeWin = MidAutumnExchangeWindow.New(self)
        self.exchangeWin.windowId = WindowConfig.WinID.valentine_exchange
    end
    self.exchangeWin:Open({datalist = datalist, title = TI18N("元宵兑换"), extString = ""})
end

function ValentineModel:OpenWish()
    if self.wishWin == nil then
        self.wishWin = LoveWishWindow.New(self)
    end
    self.wishWin:Open()
end

function ValentineModel:CloseWish()
    if self.wishWin ~= nil then
        WindowManager.Instance:CloseWindow(self.wishWin)
        self.wishWin = nil
    end
end

function ValentineModel:OpenWishBack()
    if self.wishBackWin == nil then
        self.wishBackWin = LoveWishBackWindow.New(self)
    end
    if not self.wishBackWin.isOpen then
        self.wishBackWin:Open()
    end
end

function ValentineModel:OpenPossibleReward(desc, rewardList,bottomdesc)
    if self.possibleReward == nil then
        self.possibleReward = SevenLoginTipsPanel.New(self)
    end

    local callBack = function() self:CallBack(self.possibleReward,bottomdesc) end

    self.possibleReward:Show({rewardList,4,nil,desc,nil,nil,callBack})
    -- self.possibleReward:Show
end

function ValentineModel:ClosePossibleReward(desc, rewardList)
    if self.possibleReward ~= nil then
        self.possibleReward:DeleteMe()
        self.possibleReward = nil
    end
end

function ValentineModel:FillData17828(data)
    --BaseUtils.dump(data)
    self.wishCount = data.wish
    self.votiveCount = data.votive
    self.getWishItemCount = data.get
    self.getVotiveItemCount = data.get_votive
end

function ValentineModel:CallBack(table,bottomdesc)

    local gameObject = GameObject.Instantiate(table.noticeText.gameObject)
    table:SetParent(table.objParent, gameObject)
    local rectTransform = gameObject.transform:GetComponent(RectTransform)
    local text = gameObject.transform:GetComponent(Text)
    rectTransform.offsetMin = Vector2(0.5,0.5)
    rectTransform.offsetMax = Vector2(0.5,0.5)
    rectTransform.sizeDelta = Vector2(800,60)

    text.text = bottomdesc


    rectTransform.anchoredPosition = Vector2(0,- table.containerHeight / 2 + 40)
end