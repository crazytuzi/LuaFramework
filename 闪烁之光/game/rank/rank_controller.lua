-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-07-25
-- --------------------------------------------------------------------
RankController = RankController or BaseClass(BaseController)

function RankController:config()
    self.model = RankModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function RankController:getModel()
    return self.model
end

function RankController:registerEvents()
end

function RankController:registerProtocals()
    self:RegisterProtocal(12900, "handle_12900")  --排行榜数据
    self:RegisterProtocal(12901, "handle_12901")  --指定排行榜最后更新时间
    self:RegisterProtocal(12902, "handle_12902")  --请求各个排行榜第一数据
    self:RegisterProtocal(12903, "handle_12903")  --请求公会排行榜数据
    self:RegisterProtocal(12904, "handle_12904")  --请求公会排行榜数据
    
    -- self:RegisterProtocal(12904, "handle_12904")  --请求竞技场排行榜数据
    -- self:RegisterProtocal(12905, "handle_12905")  --请求装备评分排行榜数据
    -- self:RegisterProtocal(12906, "handle_12906")  --请求天梯赛排行榜玩家信息
    -- self:RegisterProtocal(12907, "handle_12907")  --请求天梯赛排行榜玩家伙伴信息
    -- self:RegisterProtocal(12908, "handle_12908") -- 七天排行英雄榜数据
    -- self:RegisterProtocal(12909, "handle_12909") -- 七天排行装备榜数据
    -- self:RegisterProtocal(12911, "handle_12911") -- 七天排行觉醒榜数据
    -- self:RegisterProtocal(12912, "handle_12912") -- 七天排行神器榜数据
    -- self:RegisterProtocal(12914, "handle_12914") -- 七天排行神谕榜数据
    
end

--排行榜
function RankController:send_12900( rank_type,start,num ,is_cluster)
    --请求排行榜
    local cluster = 0
    if is_cluster == true then
        cluster = 1
    end
    local protocal = {}
    protocal.type = rank_type
    protocal.start = start or 1
    protocal.num = num or 100
    protocal.is_cluster = cluster
    self:SendProtocal(12900,protocal)
end
function RankController:handle_12900( data )
    if data then
        GlobalEvent:getInstance():Fire(RankEvent.RankEvent_Get_Rank_data,data)
    end
end


--指定排行榜最后更新时间
function RankController:send_12901( type,is_cluster )
    --请求排行榜
    local cluster = 0
    if is_cluster == true then
        cluster = 1
    end
    local protocal = {}
    protocal.type = type
    protocal.is_cluster = cluster
    self:SendProtocal(12901,protocal)
end
function RankController:handle_12901( data )
    GlobalEvent:getInstance():Fire(RankEvent.RankEvent_Get_Time_event,data)
end

--请求各个排行榜第一数据
function RankController:send_12902(is_cluster)
    --请求排行榜
    local cluster = 0
    if is_cluster == true then
        cluster = 1
    end
    local protocal = {}
    protocal.is_cluster = cluster
    self:SendProtocal(12902,protocal)
end
function RankController:handle_12902( data )
    GlobalEvent:getInstance():Fire(RankEvent.RankEvent_Get_First_data,data)
end
--请求公会排行榜数据
function RankController:send_12903(is_cluster)
    --请求排行榜
     local cluster = 0
    if is_cluster == true then
        cluster = 1
    end
    local protocal = {}
    protocal.start = 1
    protocal.num = 100
    protocal.is_cluster = cluster
    self:SendProtocal(12903,protocal)
end
function RankController:handle_12903( data )
    GlobalEvent:getInstance():Fire(RankEvent.RankEvent_Get_Rank_data,data)
end

--请求英雄排行榜数据
function RankController:send_12904( start,num )
    --请求排行榜
    local protocal = {}
    protocal.start = start or 1
    protocal.num = num or 100
    self:SendProtocal(12904,protocal)
end
function RankController:handle_12904( data )
    GlobalEvent:getInstance():Fire(RankEvent.RankEvent_Get_Rank_data,data)
end

--index打开对应的标签页
function RankController:openMainView(bool, index)
    if bool == true then 
        -- 检查是否开启
        if self:checkRankIsShow() then
            if MainuiController:getInstance():checkMainFunctionOpenStatus(MainuiConst.icon.rank, MainuiConst.function_type.other) == false then return end
            if not self.main_view then 
                self.main_view = RankMainWindow.New()
            end
            self.main_view:open(index)
        else
            message(string.format(TI18N("%d级开启"), RankConstant.limit_open_lev))
        end
    else
        if self.main_view then 
            self.main_view:close()
            self.main_view = nil
        end
    end
end

--打开排行榜信息
function RankController:openRankView(bool, index, is_cluster)
    if bool == true then 
        if self:checkRankIsShow() then
            if not self.rank_panel then 
                self.rank_panel = RankWindow.New(index, is_cluster)
            end
            self.rank_panel:open()
        else
            message(string.format(TI18N("%d级开启"), RankConstant.limit_open_lev))
        end
    else
        if self.rank_panel then 
            self.rank_panel:close()
            self.rank_panel = nil
        end
    end
end

function RankController:checkRankIsShow()
    local rolevo = RoleController:getInstance():getModel():getRoleVo()
    if rolevo and rolevo.lev >= RankConstant.limit_open_lev then
        return true
    end
    return false
end

--打开奖励排行榜界面
function RankController:openRankRewardPanel(bool, rank_reward_type)
    if bool == true then 
        if not self.rank_reward_panel then 
            self.rank_reward_panel = RankRewardPanel.New(rank_reward_type)
        end
        self.rank_reward_panel:open()
    else
        if self.rank_reward_panel then 
            self.rank_reward_panel:close()
            self.rank_reward_panel = nil
        end
    end
end

--打开通用单个排行类型的排行榜界面
--@ setting 说明
--@setting.rank_type 
function RankController:openSingleRankMainWindow(bool, setting, view_type)
    if bool == true then 
        local setting = setting or {}
        local title_name = setting.title_name
        local background_path = setting.background_path
        if not self.single_rank_main_window then 
            self.single_rank_main_window = SingleRankMainWindow.New(title_name, background_path)
        end
        self.single_rank_main_window:open(setting, view_type)
    else
        if self.single_rank_main_window then 
            self.single_rank_main_window:close()
            self.single_rank_main_window = nil
        end
    end
end


--打开聊天信息
function RankController:openChatMessage(rid, srv_id, is_robot, touchPos)
    if not rid then return end
    if not srv_id then return end

    local roleVo = RoleController:getInstance():getRoleVo()
    if rid and srv_id and roleVo.rid== rid and roleVo.srv_id == srv_id then 
        message(TI18N("你不认识你自己了么？"))
        return 
    end

    if srv_id and srv_id == "robot" then
        message(TI18N("神秘人太高冷，不给查看"))
        return
    end

    if is_robot and is_robot == 1 then 
        message(TI18N("神秘人太高冷，不给查看"))
        return
    end
    local vo = {rid = rid, srv_id = srv_id}
    local touchPos = touchPos or cc.p(0,0)
    ChatController:getInstance():openFriendInfo(vo, touchPos)
end

function RankController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end