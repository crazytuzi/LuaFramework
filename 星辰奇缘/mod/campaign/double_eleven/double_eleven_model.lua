--2016/11/4
--xjlong
--双十一活动数据管理器
DoubleElevenModel = DoubleElevenModel or BaseClass(BaseModel)

function DoubleElevenModel:__init()
    self.mainWin = nil

    --主界面的tab选项卡的手写配置
    self.tabDataList = {
        --btn_str:按钮的名字， iconW:按钮宽度，iconH：按钮高度, iconName:按钮资源名称, sortIndex:排序为
        [1] = {id = 1, btn_str = TI18N("双11聚划算"), iconW = 40, iconH = 40, iconName =  "34", sortIndex = 1, endTime = 0,campId= 378}
        ,[2] = {id = 2, btn_str = TI18N("全民团购日"), iconW = 52, iconH = 52, iconName = "35", sortIndex = 2, endTime = 0,campId= 379}
        ,[3] = {id = 3, btn_str = TI18N("萌萌雪人"), iconW = 32, iconH = 32, iconName = "Cute", sortIndex = 3, endTime = 0,campId= 380, res = AssetConfig.christmas_textures}
        ,[4] = {id = 4, btn_str = TI18N("堆雪人"), iconW = 32, iconH = 32, iconName = "Battle", sortIndex = 4, endTime = 0,campId= 381, res = AssetConfig.christmas_textures}
    }

    self.groupBuyData = {}
    self.reward_base_id = 0
end

----------------------------界面打开关闭逻辑
--打开主界面
function DoubleElevenModel:OpenWindow(args)
    if self.mainWin == nil then
        self.mainWin = DoubleElevenMainWindow.New(self)
    end
    self.mainWin:Open(args)
end

function DoubleElevenModel:CloseWindow()
    if self.mainWin ~= nil then
        WindowManager.Instance:CloseWindow(self.mainWin)
    end
    if self.mainWin == nil then
        -- print("===================self.mainWin is nil")
    else
        -- print("===================self.mainWin is not nil")
    end
end

function DoubleElevenModel:SetGroupBuyData(data)
    self.groupBuyData = {}
    for _,v in ipairs(data.campaign_group_purchase_item) do
        if v.start_time <= BaseUtils.BASE_TIME then
            local groupData = BaseUtils.copytab(v)
            groupData.self_buy_num = 0
            table.insert(self.groupBuyData, groupData)
        end
    end

    local sortfun = function(a,b)
        return a.id < b.id
    end

    table.sort(self.groupBuyData, sortfun)

    for _,v in ipairs(data.buy_list) do
        for _,vTemp in ipairs(self.groupBuyData) do
            if vTemp.id == v.id then
                vTemp.self_buy_num = v.self_buy_num
            end
        end

        if self.groupBuyData[v.id] ~= nil then
        end
    end

    self.reward_base_id = data.reward_base_id
    self.reward_num = data.reward_num
    self.has_reward = data.has_reward
    EventMgr.Instance:Fire(event_name.double_eleven_groupbuy_update)
end

function DoubleElevenModel:UpdateGroupBuyData(data)
    self.has_reward = data.has_reward
    for _,v in ipairs(self.groupBuyData) do
        if v.id == data.id then
            v.discount = data.discount
            v.buy_num = data.buy_num
            v.self_buy_num = data.self_buy_num
            EventMgr.Instance:Fire(event_name.double_eleven_groupbuy_update)
        end
    end
end

-- 打开圣诞萌萌雪人窗口
function DoubleElevenModel:OpenSnowmanWindow(args)
    if self.snowmanWin == nil then
        self.snowmanWin = ChristmasSnowmanWindow.New(self)
    end
    self.snowmanWin:Open(args)
end

function DoubleElevenModel:GetSnowManData(campaign_id)
    local tab = {}
    local reward = DataCampaign.data_list[campaign_id].loss_items
    for i,v in ipairs (reward) do
        if v ~= nil and v[1] ~= nil then
            table.insert(tab,v[1])
        end
    end
    return tab
end
