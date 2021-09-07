-- @author 黄耀聪
-- @date 2016年7月22日

AuctionModel = AuctionModel or BaseClass(BaseModel)

function AuctionModel:__init()
    self.datalist = {
        -- [1] = {item_id = 20009, gold = 1000, idx = 1, gold_once = 100}
        -- , [2] = {item_id = 20010, gold = 1000, idx = 2, gold_once = 100}
        -- , [3] = {item_id = 20011, gold = 1000, idx = 3, gold_once = 100}
        -- , [4] = {item_id = 20012, gold = 1000, idx = 4, gold_once = 100}
        -- , [5] = {item_id = 20013, gold = 1000, idx = 5, gold_once = 100}
    }
    self.mylist = {
        -- [1] = {item_id = 20009, gold = 1000, idx = 1, gold_once = 100}
        -- , [2] = {item_id = 20010, gold = 1000, idx = 2, gold_once = 100}
        -- , [3] = {item_id = 20011, gold = 1000, idx = 3, gold_once = 100}
        -- , [4] = {item_id = 20012, gold = 1000, idx = 4, gold_once = 100}
        -- , [5] = {item_id = 20013, gold = 1000, idx = 5, gold_once = 100}
    }
end

function AuctionModel:__delete()
end

function AuctionModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = AuctionWindow.New(self)
    end
    self.mainWin:Open(args)
end

function AuctionModel:CloseWindow()
    if self.mainWin ~= nil then
        WindowManager.Instance:CloseWindow(self.mainWin)
        self.mainWin = nil
    end
end

function AuctionModel:OpenOperation()
    if self.mainWin ~= nil then
        if self.operationPanel == nil then
            self.operationPanel = AuctionOfferPanel.New(self, self.mainWin)
        end
        self.operationPanel:Show()
    end
end

function AuctionModel:CloseOperation()
    if self.operationPanel ~= nil then
        self.operationPanel:DeleteMe()
        self.operationPanel = nil
    end
end

