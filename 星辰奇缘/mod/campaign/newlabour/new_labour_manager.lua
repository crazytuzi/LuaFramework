NewLabourManager = NewLabourManager or BaseClass(BaseManager)

NewLabourManager.SYSTEM_ID = 336

function NewLabourManager:__init()
    if NewLabourManager.Instance ~= nil then
        Log.Error("不能重复实例化")
        return
    end
    self.menuId = {
        Type1 = 460,    -- 劳动最光荣
        Type2 = 461,    -- 清扫城市
        Type3 = 462,    -- 顽皮小狐狸
        Back = 572,       -- 返利
        Group = 573,      -- 团购
        Reward = 574,     -- 礼包
    }
    self:ReSortMenu()
    NewLabourManager.Instance = self
    self.model = CampaignManager.Instance.labourModel
    self.redPointDic = {}
    self.redPointEvent = EventLib.New()
    self:InitHandler()

end

function NewLabourManager:ReSortMenu()
    for k,id in pairs(self.menuId) do
        CampaignEumn.NewLahourType[k] = DataCampaign.data_list[id].index
    end
end

function NewLabourManager:InitHandler()
    self:AddNetHandler(17842, self.On17842)
    self:AddNetHandler(17899, self.On17899)
    self:AddNetHandler(20458, self.On20458)


    EventMgr.Instance:AddListener(event_name.welfare_bags_info_update, function() self:CheckRedPoint() end)
    EventMgr.Instance:AddListener(event_name.campaign_change, function() self:CheckRedPoint() end)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, function() self:CheckRedPoint() end)
    self.redPointEvent:AddListener(function() self:CheckRedMainUI() end)
end

function NewLabourManager:__delete()
end

function NewLabourManager:OpenWindow(args)
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewLabour] == nil then
     NoticeManager.Instance:FloatTipsByString(TI18N("活动尚未开启"))
        return
    end
    self.model:OpenWindow(args)
end

function NewLabourManager:SetIcon()
    MainUIManager.Instance:DelAtiveIcon3(NewLabourManager.SYSTEM_ID)
    if CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewLabour] == nil then
        return
    end

    local iconData = DataSystem.data_daily_icon[NewLabourManager.SYSTEM_ID]
    if self.activeIconData == nil then
        self.activeIconData = AtiveIconData.New()
    end
    self.activeIconData.id = iconData.id
    self.activeIconData.iconPath = iconData.res_name
    self.activeIconData.sort = iconData.sort
    self.activeIconData.lev = iconData.lev
    self.activeIconData.clickCallBack = function()
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.newlabourwindow)
        end
    MainUIManager.Instance:AddAtiveIcon3(self.activeIconData)
    -- if self.foxdata == nil then
    --     self:Send17842()
    -- end
    self:CheckRedPoint()
end

function NewLabourManager:CheckRedPoint()
    local redList = {}
    for id,_ in pairs(self.redPointDic) do
        table.insert(redList, id)
    end
    for _,id in pairs(redList) do
        self.redPointDic[id] = nil
    end

    self.redPointDic[460] = NationalDayManager.Instance.model:CheckBalloonRed()

    local campData = (CampaignManager.Instance.campaignTree[CampaignEumn.Type.NewLabour] or {})[CampaignEumn.NewLahourType.Reward] or {}
    for _,sub in pairs(campData.sub or {}) do
        if #DataCampaign.data_list[sub.id].loss_items == 0 and sub.status == CampaignEumn.Status.Finish then
            self.redPointDic[sub.id] = true
        end
    end
    self.redPointEvent:Fire()
end

function NewLabourManager:CheckRedMainUI()
    local status = false
    for _,v in pairs(self.redPointDic) do
        status = status or (v == true)
    end
    local cfg_data = DataSystem.data_daily_icon[NewLabourManager.SYSTEM_ID]
    if MainUIManager.Instance.MainUIIconView ~= nil then
        MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(cfg_data.id, status)
    end
end

function NewLabourManager:Send17842()
    self:Send(17842, {})
end

function NewLabourManager:On17842(data)

    -- local myData = {}
    -- for k,v in pairs(data.camp_unit) do
    --     v.type = 5
    --     table.insert(myData,v)

    -- end
    -- myData.type = 5

    local myData = {}
    for k,v in pairs(data.camp_unit) do
        myData[v.map_id] = myData[v.map_id] or {}
        table.insert(myData[v.map_id],v)
        if myData[v.map_id].type == nil then
            myData[v.map_id].type = 5
        end
    end
    local myNewData = {}
    table.sort(myData,function(a,b)
               if a.map_id ~= b.map_id then
                    return a.map_id < b.map_id
                else
                    return false
                end
            end)

    for k,v in pairs(myData) do
        table.insert(myNewData,v)
    end


    self.foxdata = data
    myNewData.type = 5
    EventMgr.Instance:Fire(event_name.fox_unit_update)

    UnitStateManager.Instance:Update(UnitStateEumn.Type.Cold,myNewData)
end

function NewLabourManager:Send17899()
    self:Send(17899, {})
end

function NewLabourManager:On17899(data)
    local myData = {}
    for k,v in pairs(data.camp_unit) do
        myData[v.map_id] = myData[v.map_id] or { mapid = v.map_id }
        table.insert(myData[v.map_id],v)
        if myData[v.map_id].type == nil then
            myData[v.map_id].type = UnitStateEumn.Type.StarTrial
        end
    end
    local myNewData = {}
    table.sort(myData,function(a,b)
               if a.map_id ~= b.map_id then
                    return a.map_id < b.map_id
                else
                    return false
                end
            end)

    for k,v in pairs(myData) do
        table.insert(myNewData,v)
    end

    myNewData.type = UnitStateEumn.Type.StarTrial

    UnitStateManager.Instance:Update(UnitStateEumn.Type.StarTrial, myNewData)
end

function NewLabourManager:Send20458()
    self:Send(20458, {})
end

function NewLabourManager:On20458(data)
    local myData = {}
    for k,v in pairs(data.map_num) do
        myData[v.map_id] = myData[v.map_id] or { mapid = v.map_id }
        if myData[v.map_id].type == nil then
            myData[v.map_id].type = UnitStateEumn.Type.MoonStar
        end
        for i=1, v.num do -- 这个协议的数据结构跟其他的不太一样，这里整理成一样的结构，用0来替代每个单位的具体信息
            table.insert(myData[v.map_id], 0)
        end
    end
    local myNewData = {}
    table.sort(myData,function(a,b)
               if a.map_id ~= b.map_id then
                    return a.map_id < b.map_id
                else
                    return false
                end
            end)

    for k,v in pairs(myData) do
        table.insert(myNewData,v)
    end

    myNewData.type = UnitStateEumn.Type.MoonStar

    UnitStateManager.Instance:Update(UnitStateEumn.Type.MoonStar, myNewData)
end
------------------------------------------------------------------------------------------
