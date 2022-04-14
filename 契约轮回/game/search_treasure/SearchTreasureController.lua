require('game.search_treasure.RequireSearchTreasure')
SearchTreasureController = SearchTreasureController or class("SearchTreasureController", BaseController)
local SearchTreasureController = SearchTreasureController

function SearchTreasureController:ctor()
    SearchTreasureController.Instance = self
    self.model = SearchTreasureModel:GetInstance()
    self.show_resultPanel = true
    self:AddEvents()
    self:RegisterAllProtocal()
end

function SearchTreasureController:dctor()
end

function SearchTreasureController:GetInstance()
    if not SearchTreasureController.Instance then
        SearchTreasureController.new()
    end
    return SearchTreasureController.Instance
end

function SearchTreasureController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1124_searchtreasure_pb"
    self:RegisterProtocal(proto.SEARCHTREASURE_GETINFO, self.HandleGetInfo)
    self:RegisterProtocal(proto.SEARCHTREASURE_SEARCH, self.HandleSearch)
    self:RegisterProtocal(proto.SEARCHTREASURE_GETMESSAGES, self.HandleUpdateRecords)
    self:RegisterProtocal(proto.SEARCHTREASURE_HAVE_RARE, self.HandleHaveRare)
end

function SearchTreasureController:AddEvents()
    -- --请求基本信息
    -- local function ON_REQ_BASE_INFO()
    -- self:RequestLoginVerify()
    -- end
    -- self.model:AddListener(SearchTreasureModel.REQ_BASE_INFO, ON_REQ_BASE_INFO)

    --红点处理 背包物品有变化就显示红点
    local function call_back()
        self:OpenPanel(1)
    end
    GlobalEvent:AddListener(SearchTreasureEvent.OpenSearchPanel, call_back)

    local function call_back()
        self:OpenPanel(2)
    end
    GlobalEvent:AddListener(SearchTreasureEvent.OpenSearchPanelTop, call_back)

    local function call_back()
        self:OpenPanel(3)
    end
    GlobalEvent:AddListener(SearchTreasureEvent.OpenSearchPanelScore, call_back)

    local function call_back()
        self:OpenPanel(4)
    end
    GlobalEvent:AddListener(SearchTreasureEvent.OpenSearchPanelGundam, call_back)

    --寻宝结果处理
    local function call_back(type_id)

        if not self.show_resultPanel then
            self.show_resultPanel = true
            return
        end

        if type_id >=1 and type_id <= 4 then
            --装备寻宝，巅峰寻宝，机甲寻宝，至尊寻宝
            local panel = lua_panelMgr:GetPanel(STResultPanel)
            if not panel then
                panel = lua_panelMgr:GetPanelOrCreate(STResultPanel)
                panel:Open(type_id)
            end
        else

            local panel_class = YYSTResultPanel
            if Config.db_yunying[type_id].panel == "191@1" then
                --限时寻宝活动使用专属的result panel
                panel_class = TimeLimitedTreasureHuntResultPanel
            end

            local panel = lua_panelMgr:GetPanel(panel_class) --运营
            if not panel then
                panel = lua_panelMgr:GetPanelOrCreate(panel_class)
                panel:Open(type_id)
            end
        end


    end
    self.model:AddListener(SearchTreasureEvent.SearchResult, call_back)

    --主题抽奖处理
    local function call_back(key)
        local act_id = OperateModel:GetInstance():GetCurrentAct()
        if act_id then
            lua_panelMgr:GetPanelOrCreate(YYLotteryPanel):Open(act_id)
        else
            Notify.ShowText("No theme lottery is available for now")
        end
    end
    GlobalEvent:AddListener(SearchTreasureEvent.OpenYYLotteryPanel, call_back)

    --运营活动处理
    local function call_back()
        local act_id = OperateModel:GetInstance():GetCurrentAct()
        if act_id then
            local act_info = OperateModel:GetInstance():GetActInfo(act_id) --875@x中的x就是活动id
            if act_info then
                local tasks = act_info.tasks
                local has_reddot = false
                for i = 1, #tasks do
                    if tasks[i].count == 0 then
                        has_reddot = true
                        break
                    end
                    if tasks[i].state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
                        has_reddot = true
                    end
                end
                local key = Config.db_yunying[act_id].panel
                local key_str = GetOpenByKey(key).key_str
                GlobalEvent:Brocast(MainEvent.ChangeRedDot, key_str, has_reddot)
            end
        end
    end
    GlobalEvent:AddListener(OperateEvent.DLIVER_YY_INFO, call_back)
    GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, call_back)

    --变强处理
    local function call_back()
        self:Strongger()
    end
    GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)

    local function callback(bag_id, k, v)

        local item = BagModel.GetInstance():GetBagItemByUid(k)
        if item and item.id == 11014 then
            --限时寻宝icon红点
            local timelimited_treasure_hunt_reddot = self.model:CheckTimelimitedTreasureHuntReddot()
            GlobalEvent:Brocast(MainEvent.ChangeRedDot, "timeLimitedTreasureHunt", timelimited_treasure_hunt_reddot)
        end
        
    end
    GlobalEvent:AddListener(GoodsEvent.UpdateNum, callback)

    --[[GlobalEvent:AddListener(GoodsEvent.UpdateNum, call_back)
    GlobalEvent:AddListener(GoodsEvent.DelItems, call_back)
    GlobalEvent:AddListener(BagEvent.AddItems, call_back)--]]

    --打开限时冲榜界面
    local function call_back(  )
        local panel = lua_panelMgr:GetPanelOrCreate(TimeLimitedRushPanel)
        panel:Open()
        local data = {}
        panel:SetData(data)
    end
    GlobalEvent:AddListener(TimeLimitedRushEvent.OpenTimeLimitedRushPanel, call_back)

    --打开限时寻宝界面
    local function call_back(  )
        local panel = lua_panelMgr:GetPanelOrCreate(TimeLimitedTreasureHuntPanel)
        panel:Open()
        panel:SetData()
    end
    GlobalEvent:AddListener(TimeLimitedTreasureHuntEvent.OpenTimeLimitedTreasureHuntPanel, call_back)
end

function SearchTreasureController:OpenPanel(id)
    lua_panelMgr:GetPanelOrCreate(SearchTreasurePanel):Open(id)
    self:ShowRedDot(id)
    if self.model.first_login then
        self.model.first_login = false
        local function call_back2()
            self:ShowRedDot(1)
            self:ShowRedDot(3)
        end
        GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back2)
        --GlobalEvent:AddListener(GoodsEvent.UpdateNum, call_back2)
        --GlobalEvent:AddListener(GoodsEvent.DelItems, call_back2)
        --GlobalEvent:AddListener(BagEvent.AddItems, call_back2)
    end
end

-- overwrite
function SearchTreasureController:GameStart()
    --游戏开始时 显示一下寻宝的红点
    local function call_back()
        GlobalEvent:Brocast(MainEvent.ChangeRedDot, "searchtreasure", true)
    end
    GlobalSchedule:StartOnce(call_back, Constant.GameStartReqLevel.Low)
end

----请求基本信息
function SearchTreasureController:RequestGetInfo(type_id)
    local pb = self:GetPbObject("m_searchtreasure_getinfo_tos")
    pb.type_id = type_id
    self:WriteMsg(proto.SEARCHTREASURE_GETINFO, pb)
end

----接收基本信息
function SearchTreasureController:HandleGetInfo()
    local data = self:ReadMsg("m_searchtreasure_getinfo_toc")
    self.model:UpdateInfo(data)
    self.model:Brocast(SearchTreasureEvent.UpdateInfo)
end

--请求寻宝
function SearchTreasureController:RequestSearch(type_id, count)
    local pb = self:GetPbObject("m_searchtreasure_search_tos")
    pb.type_id = type_id
    pb.count = count
    --logError("请求寻宝 type_id-"..type_id..",count-"..count)
    self:WriteMsg(proto.SEARCHTREASURE_SEARCH, pb)
end

--接收寻宝结果
function SearchTreasureController:HandleSearch()
    local data = self:ReadMsg("m_searchtreasure_search_toc")
    local type_id = data.type_id
    local reward_ids = data.reward_ids
    --logError("请求寻宝返回 type_id-"..type_id)
    self.model:SetSearchResult(reward_ids)
    self.model:Brocast(SearchTreasureEvent.SearchResult, type_id)
end

--请求寻宝记录
function SearchTreasureController:RequestGetRecords(type_id, is_global)
    local pb = self:GetPbObject("m_searchtreasure_getmessages_tos")
    pb.type_id = type_id
    pb.is_global = is_global
    --logError("请求寻宝记录 type_id-"..type_id)
    self:WriteMsg(proto.SEARCHTREASURE_GETMESSAGES, pb)
end

--接收寻宝记录结果
function SearchTreasureController:HandleUpdateRecords()
    local data = self:ReadMsg("m_searchtreasure_getmessages_toc")
    local type_id = data.type_id
    local is_global = data.is_global
    local messages = data.messages
    local is_add_new = data.is_add_new
    --logError("接收寻宝记录 type_id-"..type_id)
    self.model:UpdateMessages(type_id, is_global, messages, is_add_new)

    self.model:Brocast(SearchTreasureEvent.UpdateMessages)
end

--请求一键取出
function SearchTreasureController:RequestFetch()
    local pb = self:GetPbObject("m_searchtreasure_fetch_tos")

    self:WriteMsg(proto.SEARCHTREASURE_FETCH, pb)
end

--请求查询奖励库是否抽到珍稀
function SearchTreasureController:RequestHaveRare(type_id)
    local pb = self:GetPbObject("m_searchtreasure_have_rare_tos")
    pb.type_id = type_id
    self:WriteMsg(proto.SEARCHTREASURE_HAVE_RARE, pb)
end

--处理查询奖励库是否抽到珍稀
function SearchTreasureController:HandleHaveRare()
    local data = self:ReadMsg("m_searchtreasure_have_rare_toc")
    local type_id = data.type_id
    local have_rare = data.have_rare
    self.model:Brocast(SearchTreasureEvent.HaveRare, type_id, have_rare)
end

--显示红点
function SearchTreasureController:ShowRedDot(type_id)
    local id = 0
    if type_id == 1 then
        id = self.model.gold_key_id
    elseif type_id == 2 then
        id = self.model.silver_key_id
    elseif type_id == 3 then
        id = self.model.gundam_key_id
    end
    local num = BagModel:GetInstance():GetItemNumByItemID(id)
    local bag = BagModel:GetInstance():GetBag(BagModel.stHouseId) or {}
    local storage_num = 0
    local items = bag.bagItems or {}
    for k, v in pairs(items) do
        if v ~= 0 then
            storage_num = storage_num + 1 --统计背包里数量不为0的物品
        end
    end
    local show_reddot = (num > 0 or storage_num > 0)
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "searchtreasure", show_reddot)
    self.model:Brocast(SearchTreasureEvent.UpdateSideRD, type_id, num > 0)
end

--变强
function SearchTreasureController:Strongger()
    if OpenTipModel.GetInstance():IsOpenSystem(190, 1) then
        local num = BagModel:GetInstance():GetItemNumByItemID(self.model.gold_key_id)
        GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 15, num > 0)
    end
end
