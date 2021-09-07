-- ------------------------------
-- 一闷夺宝
-- hosr
-- ------------------------------

LotteryModel = LotteryModel or BaseClass(BaseModel)

function LotteryModel:__init()

    self.mainWindow = nil
    self.joinPanel = nil
    self.detailPanel = nil
end

function LotteryModel:OpenMain(args)
    if self.mainWindow == nil then
        self.mainWindow = LotteryMainWindow.New(self)
    end
    self.mainWindow:Open(args)
end

function LotteryModel:CloseMain()
    if self.mainWindow ~= nil then
        WindowManager.Instance:CloseWindow(self.mainWindow)
        self.mainWindow = nil
    end
end

function LotteryModel:OpenJoinPanel(args)
    if self.joinPanel == nil then
        self.joinPanel = LotteryJoinPanel.New(self)
    end
    self.joinPanel:Show(args)
end

function LotteryModel:CloseJoinPanel()
    if self.joinPanel ~= nil then
        self.joinPanel:DeleteMe()
        self.joinPanel = nil
    end
end

function LotteryModel:OpenDetail(args)
    if self.detailPanel == nil then
        self.detailPanel = LotteryDetailPanel.New(self)
    end
    self.detailPanel:Show(args)
end

function LotteryModel:CloseDetail()
    if self.detailPanel ~= nil then
        self.detailPanel:DeleteMe()
        self.detailPanel = nil
    end
end

--获取一元夺宝兑换
function LotteryModel:GetExchangeList()
    local list = ShopManager.Instance.model.datalist[2][6]
    return ShopManager.Instance.model.datalist[2][6]
end