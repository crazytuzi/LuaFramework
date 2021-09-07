ThanksgivingModel = ThanksgivingModel or BaseClass(BaseModel)

function ThanksgivingModel:__init()
    self.receiveNum = 0
end

function ThanksgivingModel:OpenWindow(args)
    local camp = CampaignManager.Instance.campaignTree[CampaignEumn.Type.Thanksgiving]
    if #camp == 1 and camp[CampaignEumn.ThanksgivingType.Exchange] ~= nil then
        self:OpenExchange()
        return
    end
    if self.mainWin == nil then
        self.mainWin = ThanksgivingWindow.New(self)
    end
    self.mainWin:Open(args)
end

-- 直接走WindowManager
function ThanksgivingModel:OpenExchange()
    local datalist = {}
    local lev = RoleManager.Instance.RoleData.lev
    for i,v in pairs(ShopManager.Instance.model.datalist[2][10]) do
        table.insert(datalist, v)
    end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_exchange, {datalist = datalist, title = TI18N("感恩兑换"), extString = "{assets_2, 90028}可在孔明灯会等感恩节活动获得"})
end

