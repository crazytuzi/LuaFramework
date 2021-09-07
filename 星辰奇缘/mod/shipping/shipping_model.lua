ShippingModel = ShippingModel or BaseClass(BaseModel)

function ShippingModel:__init()
    self.mainpanel = nil
    self.help_panel = nil
    self.Mgr = ShippingManager.Instance
    self.accept_and_open_main = false
    self.shipwin = nil
    self.tohelpwin = nil
    self.backfrommarket = function (args)
        self:BackFromMarket(args)
    end
    self.tomarket = function (args)
        self:ToMarketAndBack(args)
    end
    self.fright_data = { num = 0, wave = 1}
    self.beginFcallback = function(type)
        if type == 34 then
            self:OpenShipFrightPanel()
            -- self:UpdateFrightPanel(self.fright_data)
        end
    end
    self.endFcallback = function()
        self:CloseShipFrightPanel()
    end
    -- EventMgr.Instance:RemoveListener(event_name.begin_fight, self.beginFcallback)
    EventMgr.Instance:AddListener(event_name.begin_fight, self.beginFcallback)
    EventMgr.Instance:AddListener(event_name.end_fight, self.endFcallback)
end

function ShippingModel:OpenMain()
    if self.mainpanel == nil then
        self.mainpanel = ShippingWindow.New()
    end
    self.mainpanel:Open()
end

function ShippingModel:CloseMain()
    if self.mainpanel ~= nil then
        WindowManager.Instance:CloseWindow(self.mainpanel)
        -- self.mainpanel = nil
    end
end

function ShippingModel:DestoryMain()
    if self.mainpanel ~= nil then
        self.mainpanel:DeleteMe()
        self.mainpanel = nil
    end
end

function ShippingModel:OpenShipWin()
    if self.Mgr.status ~= 3 and self.Mgr.status ~= 4 then
            -- 远航商人特殊处理
        self:OpenMain()
        return
    end
    if self.shipwin == nil then
        self.shipwin = ShipWindow.New()
    end
    self.shipwin:Open()
end

function ShippingModel:CloseShipWin()
    if self.shipwin ~= nil then
        WindowManager.Instance:CloseWindow(self.shipwin)
    end
end

function ShippingModel:OpenToHelpWin()
    if self.tohelpwin == nil then
        self.tohelpwin = ShipToHelpWindow.New()
    end
    self.tohelpwin:Show()
end

function ShippingModel:CloseToHelpWin()
    if self.tohelpwin ~= nil then
        self.tohelpwin:DeleteMe()
        self.tohelpwin = nil
    end
end

function ShippingModel:OpenQuestPanel(quest_id)
    if self.questpanel == nil then
        self.questpanel = ShipQuestPanel.New(quest_id)
    end
    self.questpanel:Show(quest_id)
end

function ShippingModel:CloseQuestPanel()
    if self.questpanel ~= nil then
        self.questpanel:DeleteMe()
        self.questpanel = nil
    end
end
-- 接任务
function ShippingModel:StartShipping()
    self.accept_and_open_main = true
    self.Mgr:Req13702()

end

-- 自己提交
function ShippingModel:SelfCommit(index)
    self.Mgr:Req13703(index)
end

function ShippingModel:LoadAcceptPanel()
    if self.shipwin then
        self.shipwin:SetItem()
    end
end

function ShippingModel:FriendHelp()
    local data = self.Mgr.shippingmaindata[1].shipping_cell
    if self.Mgr.shippingmaindata[1].help_num > 2 then
        NoticeManager.Instance:FloatTipsByString(TI18N("没有帮助机会啦"))
        return
    end
    local unfinished = 0
    for i=1,#data do
        if data[i].status == 2 then
            unfinished = unfinished + 1
        end
    end
    if unfinished<5 then
        NoticeManager.Instance:FloatTipsByString(TI18N("完成5次提交，才能使用求助"))
        return
    end
    if self.help_panel == nil then
        self.help_panel = ShipHelpWindow.New()
    end
    self.help_panel:Open()
end

function ShippingModel:GuildHelp(cell_id)
    local data = self.Mgr.shippingmaindata[1].shipping_cell
    if self.Mgr.shippingmaindata[1].help_num > 2 then
        NoticeManager.Instance:FloatTipsByString(TI18N("没有帮助机会啦"))
        return
    end
    local unfinished = 0
    for i=1,#data do
        if data[i].status == 2 then
            unfinished = unfinished + 1
        end
    end
    if unfinished<5 then
        NoticeManager.Instance:FloatTipsByString(TI18N("完成5次提交，才能使用求助"))
        return
    end
    self.Mgr:Req13706(cell_id)
end

function ShippingModel:CreatSlot(baseid, parent, nobutton)
    local slot = ItemSlot.New()
    local info = ItemData.New()
    local base = DataItem.data_get[baseid]
    info:SetBase(base)
    -- local extra = {inbag = false, nobutton = true}
    local nobtn = nobutton == true
    local extra = {nobutton = nobtn}
    slot:SetAll(info, extra)
    UIUtils.AddUIChild(parent.gameObject,slot.gameObject)
    return slot
end

function ShippingModel:DeleteTimer()
    if self.shipwin ~= nil then
        self.shipwin:DeleteTimer()
    end
end

function ShippingModel:OpenShipFrightPanel()
    if self.shipFpanel == nil then
        self.shipFpanel = ShipFrightPanel.New()
    end
    self.shipFpanel:Show()
end

function ShippingModel:CloseShipFrightPanel()
    if self.shipFpanel ~= nil then
        self.shipFpanel:DeleteMe()
        self.shipFpanel = nil
    end
end

function ShippingModel:UpdateFrightPanel(data)
    if self.shipFpanel ~= nil then
        self.shipFpanel:Update(data)
    end
end

function ShippingModel:OpenBoxWindow(args)
    if self.boxWindow == nil then
        self.boxWindow = ShipSkillboxWindow.New(self)
    end
    self.boxWindow:Open(args)
end

function ShippingModel:CloseBoxWindow()
     if self.boxWindow ~= nil then
        WindowManager.Instance:CloseWindow(self.boxWindow)
    end
    self.boxWindow = nil
end

function ShippingModel:ShowBoxResult(data)
    if self.boxWindow ~= nil then
        self.boxWindow:StopRoll(data)
    else
        local getData = DataShipping.data_box[data.id]
        -- NoticeManager.Instance:FloatTipsByString(string.format("活动奖励{assets_1,90012,%s}", getData.num))
    end
end