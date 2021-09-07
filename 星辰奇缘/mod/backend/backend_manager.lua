-- @author 黄耀聪
-- @date 2016年7月21日
-- 后台活动

BackendManager = BackendManager or BaseClass(BaseManager)

function BackendManager:__init()
    if BackendManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    BackendManager.Instance = self
    self.model = BackendModel.New()

    self.redDic = {}

    self.onReloadTab = EventLib.New()
    self.onTick = EventLib.New()
    self.onCheckRed = EventLib.New()
    self.onRank = EventLib.New()

    self:InitHandler()
end

function BackendManager:__delete()
end

function BackendManager:InitHandler()
    self:AddNetHandler(14050, self.on14050)
    self:AddNetHandler(14051, self.on14051)
    self:AddNetHandler(14052, self.on14052)
    self:AddNetHandler(14053, self.on14053)
    self:AddNetHandler(14054, self.on14054)

    EventMgr.Instance:AddListener(event_name.mainui_btn_init, function() self:CheckMainUIRed() end)
end

function BackendManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

function BackendManager:ShowQuestionaireWindow(bo,args)
    self.model:ShowQuestionaireWindow(bo,args)
end

-- 请求后台活动
function BackendManager:send14050(id)
  -- print("发送14050")
    Connection.Instance:send(14050, {id = id})
end

function BackendManager:on14050(data)
    -- BaseUtils.dump(data, "<color='#00ff00'>接收14050</color>")
    local model = self.model
    model.backendCampaignTab = {}
    for _,camp in pairs(data.camp_web_ico_list) do
        model.backendCampaignTab[camp.id] = model.backendCampaignTab[camp.id] or {}
        local tab = model.backendCampaignTab[camp.id]
        for key,value in pairs(camp) do
            if key == "menu_list" then
                tab.menu_list = tab.menu_list or {}
                for _,menu in pairs(value) do
                    tab.menu_list[menu.id] = {}
                    for k,v in pairs(menu) do
                        if k ~= "camp_list" then
                            tab.menu_list[menu.id][k] = v
                        else
                            tab.menu_list[menu.id][k] = tab.menu_list[menu.id][k] or {}
                            for _,v1 in pairs(v) do
                                tab.menu_list[menu.id][k][v1.n] = v1
                            end
                        end
                    end
                end
            else
                tab[key] = value
            end
        end
    end

    -- BaseUtils.dump(model.backendCampaignTab, "<color='#0000ff'>model.backendCampaignTab</color>")
    -- BaseUtils.dump(model.tabData)
    self:SetIcon()
    -- self:CheckMainUIRed()
end
--根据面板类型，取对应的面板数据
function BackendManager:GetDataByPanelType(panelType)
    local model = self.model
    local menuTemp = nil
    for _,camp in pairs(model.backendCampaignTab) do
        print(camp.id)
        print(camp.menu_list)
        if camp.menu_list ~= nil then
            for _,menu in pairs(camp.menu_list) do
                print(menu.panel_type)
                if menu.panel_type == tostring(panelType) then
                    menuTemp = menu
                    break
                end
            end
        end
        if menuTemp ~= nil then
            break
        end
    end
    return menuTemp
end

-- 删除(关闭)指定总活动
function BackendManager:send14051()
    -- print("发送14051")
    Connection.Instance:send(14051, {})
end

function BackendManager:on14051(data)
    -- BaseUtils.dump(data, "接收14051")
    local model = self.model
    model.backendCampaignTab[data.id] = nil
    EventMgr.Instance:Fire(event_name.backend_campaign_change)
    self:SetIcon()
    -- self:CheckMainUIRed()
end

-- 更新指定活动进度
function BackendManager:send14052()
    -- print("发送14052")
    Connection.Instance:send(14052, {})
end

function BackendManager:on14052(data)
    -- BaseUtils.dump(data, "接收14052")
    local model = self.model
    local list = {}
    for _,camp in pairs(data.camp_web_update_list) do
        local tab = model.backendCampaignTab[camp.total_id].menu_list[camp.menu_id]
        list[camp.total_id] = list[camp.total_id] or {}
        table.insert(list[camp.total_id], camp.menu_id)
        local tab1 = tab.camp_list[camp.n]
        for k1,v1 in pairs(camp) do
            tab1[k1] = v1
        end
    end
    EventMgr.Instance:Fire(event_name.backend_campaign_change, list)
    self:SetIcon()
    -- self:CheckMainUIRed()
end

-- 领取指定活动奖励
function BackendManager:send14053(total_id, menu_id, n, num)
    local dat = {total_id = total_id, menu_id = menu_id, n = n, num = num}
    BaseUtils.dump(dat, "发送14053")
    Connection.Instance:send(14053, dat)
end

function BackendManager:on14053(data)
    -- BaseUtils.dump(data, "接收14053")
end

function BackendManager:RequestInitData()
    -- self:on14050(backendDataExample)
    self:send14050(0)
end

function BackendManager:CheckOpen()
    local model = self.model
    local baseTime = BaseUtils.BASE_TIME
    local isOpen = {}
    local panel_type = nil
    self.redDic = {}
    self.isEasyMerry = false
    for _,camp in pairs(model.backendCampaignTab) do
        local iconId = tonumber(camp.ico)
        self.redDic[iconId] = {}
        local iconData = DataSystem.data_daily_icon[iconId]
        if iconId ~= nil and iconData ~= nil then
            for _,menu in pairs(camp.menu_list) do
                isOpen[iconId] = isOpen[iconId] or (baseTime >= menu.start_time and baseTime <= menu.end_time)
                local red = false
                panel_type = tonumber(menu.panel_type)
                if panel_type == BackendEumn.PanelType.MarryEasy then
                    self.isEasyMerry = self.isEasyMerry or (baseTime >= menu.start_time and baseTime <= menu.end_time)
                end
                if BackendEumn.PanelNoRed[panel_type] ~= true then
                    for _,v in pairs(menu.camp_list) do
                        red = red or (v.status == 1)
                    end
                end
                self.redDic[iconId][menu.id] = red
            end
        end
    end
    self.onCheckRed:Fire()
    return isOpen
end

function BackendManager:SetIcon()
    self:CrazyFunction()
    local model = self.model
    self.currentIconTab = self.currentIconTab or {}

    for _,v in pairs(self.currentIconTab) do
        MainUIManager.Instance:DelAtiveIcon3(v.iconId)
        v.show = false
    end

    local openTab = self:CheckOpen()
    -- BaseUtils.dump(openTab,"openTab========")
    for k,v in pairs(model.backendCampaignTab) do
        local iconId = tonumber(v.ico)
        local iconData = DataSystem.data_daily_icon[iconId]
        self.currentIconTab[iconId] = self.currentIconTab[iconId] or {}
        local tab = self.currentIconTab[iconId]
        if iconId ~= nil and iconData ~= nil then
            if openTab[iconId] == true then
                tab.iconData = tab.iconData or AtiveIconData.New()
                tab.iconData.id = iconId
                tab.iconData.iconPath = iconData.res_name
                tab.iconData.sort = iconData.sort
                tab.iconData.lev = iconData.lev
                tab.iconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.backend, {k}) end
                MainUIManager.Instance:AddAtiveIcon3(tab.iconData)
                tab.show = true
            else
                if tab.iconData ~= nil then
                    tab.iconData:DeleteMe()
                    tab.iconData = nil
                end
            end
        end
    end
    self:CheckMainUIRed()
end

function BackendManager:CheckMainUIRed()
    local model = self.model
    -- BaseUtils.dump(self.redDic, "self.redDic")
    if MainUIManager.Instance.MainUIIconView ~= nil then
        for k,v in pairs(model.backendCampaignTab) do
            local iconId = tonumber(v.ico)
            local iconData = DataSystem.data_daily_icon[iconId]
            if iconId ~= nil and iconData ~= nil then
                local red = false
                local redDic = self.redDic[iconId]
                if redDic ~= nil then
                    for _,v in pairs(redDic) do
                        red = red or (v == true)
                    end
                end
                if MainUIManager.Instance.MainUIIconView ~= nil then
                    MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(iconId, red)
                end
            end
        end
    end
end

-- 不讲道理的坑爹判断全部写这里来
function BackendManager:CrazyFunction()
    local model = self.model
    local backendCampaignTab = model.backendCampaignTab or {}
    local temp = {}
    local temp1 = {}

    -- 寻找需要倒计时的活动, 建议每次使用都需要用local重新索引
    model.countDownTab = model.countDownTab or {}
    for k,_ in pairs(temp) do temp[k] = nil end
    for id,camp in pairs(backendCampaignTab) do
        temp[id] = 1
        model.countDownTab[id] = model.countDownTab[id] or {}
    end
    for id,v in pairs(model.countDownTab) do
        if v ~= nil then
            if temp[id] == nil then model.countDownTab[id] = nil
            else
                for k,_ in pairs(temp1) do temp1[k] = nil end
                for menuId,_ in pairs(model.backendCampaignTab[id].menu_list) do
                    temp1[menuId] = 1
                end
                for menuId,_ in pairs(temp1) do
                    if temp1[menuId] == nil then v[menuId] = nil
                    else
                        if model.backendCampaignTab[id].menu_list[menuId].is_button == BackendEumn.ButtonType.Countdown then
                            if v[menuId] == nil then
                                v[menuId] = BaseUtils.BASE_TIME - model.backendCampaignTab[id].menu_list[menuId].camp_list[1].value
                            end
                        end
                    end
                end
            end
        end
    end
    -- BaseUtils.dump(model.backendCampaignTab, "<color='#ff0000'>model.backendCampaignTab</color>")
end

-- 后台活动排行榜数据
function BackendManager:send14054(type)
    -- print("send14054 " .. tostring(type))
    Connection.Instance:send(14054, {type = type})
end

function BackendManager:on14054(data)
    -- BaseUtils.dump(data, "on14054")
    self.model.rankDataTab[data.type] = data.rank_list
    self.onRank:Fire(data.type)
end

function BackendManager:OpenRank(args)
    self.model:OpenRank(args)
end

