-- 远航商人预览面板

ShipWindow = ShipWindow or BaseClass(BaseWindow)

function ShipWindow:__init()
    self.mgr = ShippingManager.Instance
    self.model = ShippingManager.Instance.model
    self.resList = {
        {file = AssetConfig.shipwin, type = AssetType.Main}
    }
    self.name = "ShipWindow"
    self.slotlist = {}
end

function ShipWindow:__delete()
    for k,v in pairs(self.slotlist) do
        v:DeleteMe()
    end
    self.slotlist = {}
end

function ShipWindow:InitPanel(trans)
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.shipwin))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform
    local trans = self.transform
    self.closebtn = trans:Find("Main/CloseButton")
    self.needcon = trans:Find("Main/Con/Con/needcon")
    self.starttitle = trans:Find("Main/Con/StartText")
    self.endtitle = trans:Find("Main/Con/EndText")
    self.startbtn = trans:Find("Main/Con/Button")
    self.closebtn:GetComponent(Button).onClick:AddListener(function () self.model:CloseShipWin()  end)
    self.startbtn:GetComponent(Button).onClick:AddListener(function ()if RoleManager.Instance.RoleData.lev >27 then self.model:StartShipping() else NoticeManager.Instance:FloatTipsByString(TI18N("尚未达到参与远航商人的等级要求，到32级再来找我吧！")) end end)
    self.model.accept_and_open_main = true
    self.mgr:Req13708()
end

function ShipWindow:SetItem()
    for i,v in ipairs(self.mgr.shipinfodata.ids) do
        local slot = self.needcon:Find(string.format("Slot%s", tostring(i)))
        local img = self.needcon:Find(string.format("Slot%s/icon", tostring(i))):GetComponent(Image)
        -- local icon = data_item.data_get[v.item_base_id].icon
        -- self.mgr:SetItemIcon(icon, img)
        -- local slotData=  data_item.data_get[v.item_base_id]
        -- local is_eq = mod_item.is_equip(slotData.type)
        -- local info = {trans = img.gameObject.transform, data = nil, is_equip = is_eq, num_need = 0, show_num = true, is_lock = false, show_name = "", is_new = false, is_select = false, inbag = false, show_tips = true, show_select = true, drop_only = false}
        -- info.data = {}
        -- info.data.base = slotData
        -- event_manager:GetUIEvent(img.gameObject).OnClick:AddListener(function () mod_tips.item_tips(info)  end)
        local slot = self.model:CreatSlot(v.item_base_id, slot, true)
        table.insert(self.slotlist, slot)
    end
    if self.mgr.shipinfodata.flag == 0 then
        self.starttitle.gameObject:SetActive(false)
        self.endtitle.gameObject:SetActive(true)
        self.startbtn:GetComponent(Button).onClick:RemoveAllListeners()
        local timetable = self:GetTimeTo00()
        self.endtitle:GetComponent(Text).text = TI18N("今天的商船已离开港口，明天可以装载货物")
        self.endtitle:Find("TimeText"):GetComponent(Text).text = string.format(TI18N("<color='#FFEF50'>%s小时%s分</color>后重置"), tostring(timetable.h), tostring(timetable.m))
        -- self.startbtn.gameObject:SetActive(false)
        self.startbtn:Find("Text"):GetComponent(Text).text = TI18N("确 定")
        self.startbtn:GetComponent(Button).onClick:RemoveAllListeners()
        self.startbtn:GetComponent(Button).onClick:AddListener(function () self.model:CloseShipWin()  end)
        self.startbtn.gameObject:SetActive(true)
    else
        self.startbtn:Find("Text"):GetComponent(Text).text = TI18N("开 始")
        self.startbtn.gameObject:SetActive(true)
    end
end

function ShipWindow:GetTimeTo00()
    local times = tonumber(os.time({year = os.date("%Y"), month = os.date("%m"), day = os.date("%d"), hour = 4, min = 59, sec = 59})) - tonumber(BaseUtils.BASE_TIME)+86400
    if tonumber(os.date("%H"))<5 then
        times = tonumber(os.time({year = os.date("%Y"), month = os.date("%m"), day = os.date("%d")-1, hour = 4, min = 59, sec = 59})) - tonumber(BaseUtils.BASE_TIME)+86400
    end
    local h = math.floor(times/3600)
    local m = math.ceil(times%3600/60) ~= 60 and math.ceil(times%3600/60) or 59
    return {h = h, m = m}
end