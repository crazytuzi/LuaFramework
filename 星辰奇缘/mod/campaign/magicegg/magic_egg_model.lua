MagicEggModel = MagicEggModel or BaseClass(BaseModel)

function MagicEggModel:__init()

    self.win = nil
    self.luckydogWin = nil
    self.fullshopwindow = nil

    self.luckydogList = nil  --幸运儿列表
    self.achievebool = false --当天是否领过蛋

    self.cellInfolist = {item_info = {}, rebate_info = {}}
end

function MagicEggModel:__delete()
    if self.win ~= nil then
        self.win:DeleteMe()
    end
end

function MagicEggModel:OpenWindow(args)
    self.openArgs = args

    if self.win == nil then
        self.win = MagicEggWindow.New(self)
    end
    self.win:Open(args)
end

function MagicEggModel:CloseWindow()
    --WindowManager.Instance:CloseWindowById(WindowConfig.WinID.campaign_uniwin)
    WindowManager.Instance:CloseWindow(self.win)
end


function MagicEggModel:OpenLuckyDogWindow(args)
    self.openArgs = args

    if self.luckydogWin == nil then
        self.luckydogWin = LuckyDogWindow.New(self)
    end
    self.luckydogWin:Open(args)
end

function MagicEggModel:CloseLuckyDogWindow(args)
    if self.luckydogWin ~= nil then
        WindowManager.Instance:CloseWindow(self.luckydogWin)
    end
end



function MagicEggModel:SetData(data)
    self.luckydogList = data.lucky_roles
    -- BaseUtils.dump(self.luckydogList,"luckydogListAtModel---")
end


--满减商城活动
function MagicEggModel:OpenFullShopWindow(args)
    if self.fullshopwindow == nil then
        self.fullshopwindow = FullSubtractionShopWindow.New(self)
    end
    self.fullshopwindow:Open(args)
end

function MagicEggModel:CloseFullShopWindow(args)
    if self.fullshopwindow ~= nil then
        WindowManager.Instance:CloseWindow(self.fullshopwindow)
    end
end

