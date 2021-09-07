-- @author hze
-- @date #2018/11/21#

IntegralExchangemodel = IntegralExchangemodel or BaseClass(BaseModel)

function IntegralExchangemodel:__init()
    self.ItemTypeData = {special_items = {{},{},{},{}}, common_items = {{},{},{},{}}}
    self.questData = {}
    self.integral_min = 99999
    self.exchange_flag = false

    self.integralCampId = 0

    self.last_pos = {0,0,0,0}

    self.mainwin = nil 
    self.integralObtainPanel = nil
end

function IntegralExchangemodel:__delete()
end

function IntegralExchangemodel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = IntegralExchangeWindow.New(self)
    end
    self.mainWin:Open(args)
end

function IntegralExchangemodel:CloseWindow()
    WindowManager.Instance:CloseWindow(self.mainWin)
end

function IntegralExchangemodel:OpenIntegralObtainPanel(args)
    if self.integralObtainPanel == nil then
        self.integralObtainPanel = IntegralObtainPanel.New(self,ctx.CanvasContainer)
    end
    self.integralObtainPanel:Open(args)
end

function IntegralExchangemodel:CloseIntegralObtainPanel(args)
    if self.integralObtainPanel ~= nil then
        self.integralObtainPanel:DeleteMe()
        self.integralObtainPanel = nil 
    end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.integralexchangewindow,{campId = self.integralCampId})
end

function IntegralExchangemodel:LauncherData(dat)
    self.integral_min = 99999
    self.exchange_flag = false

    local sortfun = function(a,b)
        if a.id ~= b.id then
            return a.id < b.id
        end
        return a.order_id < b.order_id
    end

    self.ItemTypeData.special_items = dat.special_items or{}
    table.sort( self.ItemTypeData.special_items, sortfun )

    self.ItemTypeData.common_items = dat.common_items or{}
    table.sort( self.ItemTypeData.common_items, sortfun )

    self:CanExchange()
    
    --得到最小的可兑换积分数 /  
    for k, v in ipairs(self.ItemTypeData.special_items) do
        if v.exchange_num > 0 and v.cost < self.integral_min then 
            self.integral_min = v.cost
        end
    end

    --全部兑换完的标志 /  
    for k, v in ipairs(self.ItemTypeData.special_items) do
        if v.exchange_num > 0 then 
            self.exchange_flag = true
            break
        end
    end
end

--可以兑换的物品
function IntegralExchangemodel:CanExchange()
    self.ItemTypeData.special_items[1].can = true
    for i = 2, #self.ItemTypeData.special_items do
        local v1 = self.ItemTypeData.special_items[i-1]
        local v = self.ItemTypeData.special_items[i]
        if v1.id == v.id then 
            if v1.exchange_num == 0 and v.exchange_num > 0 then 
                v.can = true
            end
        else
            v.can = true
        end
    end
end
