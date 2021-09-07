OpenServerModel = OpenServerModel or BaseClass(BaseModel)

function OpenServerModel:__init()
    self.gold_14095 = 0
    self.mgr = OpenServerManager.Instance
    self.luckyProgress = {}
    self.cardData = nil
    self.receiveNum = 0
    self.isfirst = true

    self.zerobuydata = {}
    self.continuousRechargeData = {}

    self.data20471 = {}   --新开服连充活动固定数据
    self.data20473 = {}   --萌萌喵喵数据
    self.data20477 = {}   --累充数据
end

function OpenServerModel:__delete()
end

function OpenServerModel:OpenWindow(args)
    if self.isfirst then
        local campaignList = DataCampaign.data_list
        local campaignIconId = "7"
        if CampaignManager.Instance.open_srv_time > 1461072064 then
            campaignIconId = "10"
        end
        self.activities = {}
        for k,v in pairs(campaignList) do
            if v.iconid == campaignIconId then
                if self.activities[v.index] == nil then
                    self.activities[v.index] = {index = v.index, name = v.name, subList = {}}
                end
                table.insert(self.activities[v.index].subList, v)
            end
        end

        local sortFunc = function(a,b)
            return a.group_index < b.group_index
        end
        for k,v in pairs(self.activities) do
            table.sort(self.activities[v.index].subList, sortFunc)
        end

        if self.activities[1] ~= nil then self.activities[1].icon = "LuckyMoney" end
        if self.activities[2] ~= nil then
            self.activities[2].name = TI18N("冲榜送大礼")
            self.activities[2].icon = "RankIcon"
        end

        if self.activities[3] ~= nil then
            self.activities[3].icon = "onlinereward"
            self.activities[3].package = AssetConfig.bible_textures
            self.activities[3].data = DataCampaign.data_list[63]
        end

        if self.activities[4] ~= nil then
            self.activities[4].icon = "OpenServer"
            self.activities[4].name = TI18N("神兽热卖")
        end

        self.activities[5] = {name = TI18N("充值返利"), index = 5, icon = "Assets90002", package = AssetConfig.base_textures}
        -- self.activities[6] = {name = "首充返利", index = 6, icon = "WelfareIcon9", package = AssetConfig.bible_textures, data = DataCampaign.data_list[64]}

        self.isfirst = false
    end
    if self.mainWin == nil then
        self.mainWin = OpenServerWindow.New(self)
    end
    self.mainWin:Open(args)
end

function OpenServerModel:CloseWindow()
    if self.mainWin ~= nil then
        WindowManager.Instance:CloseWindow(self.mainWin)
    end
end

function OpenServerModel:GetTherions()
    local therionDic = {}
    local petDic = DataPet.data_pet
    for _,v in pairs(DataPet.data_pet_exchange) do
        local data = petDic[v.base_id]
        if data.genre == 2 or data.genre == 4 then
            table.insert(therionDic, data)
        else
        end
    end
    table.sort(therionDic, function(a,b) return a.genre < b.genre end)
    return therionDic
end

function OpenServerModel:GetData(data)
    local campaignData = DataCampaign.data_list[data.id]

    if campaignData.index == 3 then
        -- 充值送红包
        self.luckyProgress[data.id] = {data.reward_max - data.reward_can,data.reward_max}
        self.mgr.onUpdateLucky:Fire()
    elseif campaignData.index == 2 then
        -- 排行榜
    elseif campaignData.index == 4 then
        -- 神兽兑换
    end
end

function OpenServerModel:OpenBabyGiftTips(args)
    if self.babyTips == nil then
        self.babyTips = OpenServerBabyTipsPanel.New(self, self.mainWin.gameObject)
    end
    self.babyTips:Show(args)
end

function OpenServerModel:CloseBabyGiftTips()
    if self.babyTips ~= nil then
        self.babyTips:Hiden()
    end
end

function OpenServerModel:ToPhoto(roleid, platform, zoneid, photoid)
    local zoneManager = ZoneManager.Instance
    local zoneModel = zoneManager.model
    local thePhoto = zoneModel:LoadLocalPhoto(roleid, platform, zoneid, photoid)
    if thePhoto == nil or BaseUtils.is_null(thePhoto) then
        zoneManager:RequirePhotoQueue(roleid, platform, zoneid, function(photo)
            zoneModel:SaveLocalPhoto(photo, roleid, platform, zoneid, photoid)
            self:toPhoto(photo, roleid, platform, zoneid)
        end)
    else
        self:toPhoto(thePhoto, roleid, platform, zoneid)
    end
end

function OpenServerModel:toPhoto(photo, roleid, platform, zoneid)
    if #photo == 0 then
        return
    end
    local tex2d = Texture2D(64, 64, TextureFormat.RGB24, false)
    local result = tex2d:LoadImage(photo[1].photo_bin)
    local sprite = nil
    if result then
        sprite  = Sprite.Create(tex2d, Rect(0, 0, tex2d.width, tex2d.height), Vector2(0.5, 0.5), 1)
        OpenServerManager.Instance.onUpdatePhoto:Fire(sprite, roleid, platform, zoneid)
    end
end

function OpenServerModel:OpenPhotoPanel(args)
    if self.photoPanel == nil then
        self.photoPanel = OpenServerPhotoPanel.New(self, self.mainWin.gameObject)
    end
    self.photoPanel:Show(args)
end

function OpenServerModel:ClosePhotoPanel()
    if self.photoPanel ~= nil then
        self.photoPanel:Hiden()
    end
end

-- 判断限时礼包是否买过
function OpenServerModel:idBuy(id)
    if self.rewardData == nil then
        return false
    else
        for k,v in pairs(self.rewardData.list) do
            if v.id == id then
                return true
            end
        end
        return false
    end
end

function OpenServerModel:OpenRewardPanel(args)
    if self.rewaredPanel == nil then
        self.rewaredPanel = OpenServerRewardPanel.New(self)
    end
    self.rewaredPanel:Show(args)
end

function OpenServerModel:CloseRewardPanel()
    if self.rewaredPanel ~= nil then
        self.rewaredPanel:DeleteMe()
        self.rewaredPanel = nil
    end
end

function OpenServerModel:OpenZeroBuyWindow(args)
    if self.ZeroBuyWin == nil then
        self.ZeroBuyWin = OpenServerZeroBuyWindow.New(self)
    end
    self.ZeroBuyWin:Open(args)
end

function OpenServerModel:CloseZeroBuyWindow()
    if self.ZeroBuyWin ~= nil then
        WindowManager.Instance:CloseWindow(self.ZeroBuyWin)
    end
end

-- 得到消费有力的面板数据
function OpenServerModel:GetConsumeReturnDataList()
    local dataList = {}
    local dataItemList = CampaignManager.Instance:GetCampaignDataList(CampaignEumn.Type.OpenServer)
    for i,v in ipairs(dataItemList) do
        local baseData = DataCampaign.data_list[v.id]
        if baseData ~= nil and baseData.index == CampaignEumn.OpenServerType.ConsumeReturn then
            v.baseData = baseData
            table.insert(dataList,v)
        end
    end
    table.sort(dataList,function (a,b)
        return a.baseData.group_index < b.baseData.group_index
    end)
    return dataList
end

function OpenServerModel:OpenRewardViewPanel(args)
    if self.rewardPreviewPanel == nil then
        self.rewardPreviewPanel = RewardPreviewPanel.New(self)
    end
    self.rewardPreviewPanel:Show(args)
end

--连充惊喜   zz服务端
function OpenServerModel:CheckContinuousRechargeRedPointStatus(data)
    if (data or {}).rewarded_list == nil then return false end
    local status = false
    for i = 1, 7 do
        local flag = false
        for k,v in ipairs(data.rewarded_list) do
            if v.day_id == i then 
                flag = true
                break
            end 
        end

        if flag then 
            status = false
        elseif i > data.vision_day then
            status = false
        elseif i <= data.recharged_day then 
            status = true
            break
        elseif i == data.vision_day and i ~= data.recharged_day then 
            status = false
        end
    end
    return status
end

--萌萌喵喵
function OpenServerModel:CheckDirectBuyRedPointStatus(data)
    if (data or {}).camp_info == nil then return false end
    local status = false
    for i, info in pairs(data.camp_info) do
        if info.type == 0 then 
            if data.active_val >= info.need_val and info.time > 0 then 
                status = true
                break
            end
        end
    end
    return status
end

--累充活动
function OpenServerModel:CheckAccumulativeRechargeRedPointStatus(data)
    if (data or {}).reward_info == nil then return false end
    local status = false
    for i, v in pairs(data.reward_info) do
        if v.flag == 2 then 
            status = true
            break
        end
    end
    return status
end

--抽奖活动
function OpenServerModel:CheckToyRewardRedPointStatus(id)
    local campData = DataCampaign.data_list[id]
    --消耗物品
    local toyId = tonumber(campData.camp_cond_client) or 5
    local costId = DataCampTurn.data_turnplate[toyId].cost[1][1]

    local status = false
    if BackpackManager.Instance:GetItemCount(costId) > 0 then 
        status = true
    end
    return status
end