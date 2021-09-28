local Util = require "Zeus.Logic.Util"
local UserDataValueExt = require "Zeus.Logic.UserDataValueExt"
local AutoBuyPotion = {}
Util.WrapOOPSelf(AutoBuyPotion)

function AutoBuyPotion.New(settingData, hpEmptyEvtName, mpEmptyEvtName)
    local o = {}
    setmetatable(o, AutoBuyPotion)
    o:_init(settingData, hpEmptyEvtName, mpEmptyEvtName)
    return o
end

function AutoBuyPotion:updateData()
    if self._lastHpCode ~= self._data.hpItemCode then
        self._lastHpCode = self._data.hpItemCode
        self:_resetAlert(true)
    end
    if self._lastMpCode ~= self._data.mpItemCode then
        self._lastMpCode = self._data.mpItemCode
        self:_resetAlert(false)
    end
    if self._autoBuyHp ~= self._data.autoBuyHpItem then
        self._autoBuyHp = self._data.autoBuyHpItem
        self:_resetAlert(true)
    end
    if self._autoBuyMp ~= self._data.autoBuyMpItem then
        self._autoBuyMp = self._data.autoBuyMpItem
        self:_resetAlert(false)
    end
end

function AutoBuyPotion:destroy()
    DataMgr.Instance.UserData.RoleBag:RemoveFilter(self._hpMpFilter)
    self._moneyWatch:stop()
    EventManager.Unsubscribe(self._hpEmptyEvtName, self._self__onEatEmptyHpMp)
    EventManager.Unsubscribe(self._mpEmptyEvtName, self._self__onEatEmptyHpMp)
    
end

function AutoBuyPotion:subscribeEvents()
    if not EventManager.HasSubscribed(self._hpEmptyEvtName, self._self__onEatEmptyHpMp) then
        EventManager.Subscribe(self._hpEmptyEvtName, self._self__onEatEmptyHpMp)
    end
    if not EventManager.HasSubscribed(self._mpEmptyEvtName, self._self__onEatEmptyHpMp) then
        EventManager.Subscribe(self._mpEmptyEvtName, self._self__onEatEmptyHpMp)
    end
end

function AutoBuyPotion:_resetAlert(isHp)
    local isRemoveMoneyWatch = false
    if isHp then
        self._needAlertEmptyHp = true
        self._watchHpMoney.money = 0
        self._watchHpMoney.itemCode = 0
        isRemoveMoneyWatch = self._watchMpMoney.money == 0
    else
        self._needAlertEmptyMp = true
        self._watchMpMoney.money = 0
        self._watchMpMoney.itemCode = 0
        isRemoveMoneyWatch = self._watchHpMoney.money == 0
    end
    if isRemoveMoneyWatch then
        
        
    end
end

function AutoBuyPotion:_init(settingData, hpEmptyEvtName, mpEmptyEvtName)
    self._data = settingData
    self._hpEmptyEvtName = hpEmptyEvtName
    self._mpEmptyEvtName = mpEmptyEvtName
    self._watchHpMoney = {money = 0, itemCode = 0}
    self._watchMpMoney = {money = 0, itemCode = 0}
    self._moneyWatch = UserDataValueExt.New(UserData.NotiFyStatus.GOLD, self._self__onGoldAdd)
    self:updateData()
    self:subscribeEvents()
end

function AutoBuyPotion:isBagFull()
    local roleBag = DataMgr.Instance.UserData.RoleBag
    return roleBag.LimitSize <= roleBag.AllData.Count
end

function AutoBuyPotion:_initHpMpFilter()
    if self._hpMpFilter then return end

    self._hpMpFilter = ItemPack.FilterInfo.New()
    self._hpMpFilter.MergerSameTemplateID = true
    self._hpMpFilter.CheckHandle = function(item)
        return item.TemplateId == self._lastHpCode or item.TemplateId == self._lastMpCode
    end
    self._hpMpFilter.NofityCB = function(pack, type, index)
        if type ~= ItemPack.NotiFyStatus.ALLSHOWITEM and type ~= ItemPack.NotiFyStatus.MAXSIZE then
            local itemData = self._hpMpFilter:GetItemDataAt(index)
            if itemData.Num > 0 then
                if self._lastHpCode == itemData.TemplateId then
                    self._needAlertEmptyHp = true
                end
                if self._lastMpCode == itemData.TemplateId then
                    self._needAlertEmptyMp = true
                end
            end
        end
    end


    DataMgr.Instance.UserData.RoleBag:AddFilter(self._hpMpFilter)
end

function AutoBuyPotion:_onGoldAdd(nowGold)
    
    if self._watchHpMoney and self._watchHpMoney.money > 0 then
        if self._watchHpMoney.money <= nowGold then
            self:_resetAlert(true)
        end
    elseif self._watchMpMoney and self._watchMpMoney.money > 0 then
        if self._watchMpMoney.money <= nowGold then
            self:_resetAlert(false)
        end
    end
end

function AutoBuyPotion:_onEatEmptyHpMp(evtName,params)
    self:_initHpMpFilter()
    
    
    local needAlert = nil
    local itemCode = nil
    local watchMoney = nil
    local count = 0
    if self._lastHpCode == self._lastMpCode then
        needAlert = self._needAlertEmptyHp or self._needAlertEmptyMp
        self._needAlertEmptyHp = false
        self._needAlertEmptyMp = false
        itemCode = self._lastMpCode
        watchMoney = self._watchHpMoney
        count = GlobalHooks.DB.Find("Parameters", {ParamName = "Auto.HP.Buy"})[1].ParamValue
    elseif evtName == self._hpEmptyEvtName then
        needAlert = self._needAlertEmptyHp and self._autoBuyHp
        self._needAlertEmptyHp = false
        itemCode = self._lastHpCode
        watchMoney = self._watchHpMoney
        count = GlobalHooks.DB.Find("Parameters", {ParamName = "Auto.HP.Buy"})[1].ParamValue
    elseif evtName == self._mpEmptyEvtName then
        needAlert = self._needAlertEmptyMp and self._autoBuyMp
        self._needAlertEmptyMp = false
        itemCode = self._lastMpCode
        watchMoney = self._watchMpMoney
        count = GlobalHooks.DB.Find("Parameters", {ParamName = "Auto.MP.Buy"})[1].ParamValue
    end

    if needAlert and itemCode and not self:isBagFull() then
        self:buyItem(itemCode, watchMoney, tonumber(count))

        
        
        
        
        
        
        
        
        
        

        
        
        
        
        
        
    end
end

function AutoBuyPotion:buyItem(itemCode, watchMoney, count)
    
    local item = GlobalHooks.DB.Find("Items", itemCode)
    if string.empty(item.WaysID) then return end
    local ways = string.split(item.WaysID, ',')
    local idxs = {}
    for i,v in ipairs(ways) do
        local idx = GlobalHooks.DB.Find("Functions", v).SellIndex
        if not string.empty(idx) then
            for ii, vv in ipairs(string.split(idx, ',')) do
                table.insert(idxs, tonumber(vv))
            end
        end
    end

    
    local extData = XmdsNetManage.PackExtData.New(true, true, nil)
    Pomelo.SaleHandler.autoBuyItemByCodeRequest(idxs,itemCode, count, function(ex, sjson)
        if ex then return end

        local data = sjson:ToData()
        
        if data.s2c_notEnoughGold == 1 then
            if watchMoney then
                watchMoney.money = data.s2c_needGold
                watchMoney.itemCode = itemCode
            end
            self._moneyWatch:start()
            GameAlertManager.Instance:ShowFloatingTips(Util.GetText(TextConfig.Type.PUBLICCFG,"notEnoughGold"))
            
        end
    end, extData)
end


return AutoBuyPotion
