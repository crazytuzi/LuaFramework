--
-- @Author: LaoY
-- @Date:   2019-01-05 14:55:35
-- 运营活动相关

require('game.operate.RequireOperate')

OperateController = OperateController or class("OperateController", BaseController)

function OperateController:ctor()
    OperateController.Instance = self
    self.model = OperateModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function OperateController:dctor()
end

function OperateController:GetInstance()
    if not OperateController.Instance then
    end
    return OperateController.Instance
end

-- overwrite
function OperateController:GameStart()
    local function step()
        self:Request1700001()
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.High)
end

function OperateController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1700_yunying_pb"
    self:RegisterProtocal(proto.YUNYING_LIST, self.Handle1700001)        -- 活动列表
    self:RegisterProtocal(proto.YUNYING_START, self.Handle1700002)        -- 活动开始
    self:RegisterProtocal(proto.YUNYING_STOP, self.Handle1700003)        -- 活动结束
    self:RegisterProtocal(proto.YUNYING_FETCH, self.Handle1700004)        -- 领取奖励
    self:RegisterProtocal(proto.YUNYING_UPDATE, self.Handle1700005)        -- 配置更新
    self:RegisterProtocal(proto.YUNYING_INFO, self.Handle1700006)        -- 奖励状态
    self:RegisterProtocal(proto.YUNYING_GIFT, self.Handle1700007)        -- 0元礼包信息
    self:RegisterProtocal(proto.YUNYING_GIFT_FETCH, self.Handle1700008)        -- 活动日志
    self:RegisterProtocal(proto.YUNYING_LOGS, self.Handle1700009)        -- 返回act_id、活动日志
    self:RegisterProtocal(proto.YUNYING_LOGS_UPDATE, self.Handle1700013)        -- 更新act_id、活动日志
    self:RegisterProtocal(proto.YUNYING_LOTTERY_INFO, self.Handle1700010)        -- 砸蛋信息
    self:RegisterProtocal(proto.YUNYING_LOTTERY_DO, self.Handle1700011)        --砸蛋信息返回
    self:RegisterProtocal(proto.YUNYING_LOTTERY_REFRESH, self.Handle1700012)        -- 蛋池刷新信息
    self:RegisterProtocal(proto.YUNYING_LOTTERY_DRAW, self.Handle1700014)        -- 抽奖返回
    self:RegisterProtocal(proto.YUNYING_LOTOINFO, self.Handle1700015)        -- 转盘数据
    self:RegisterProtocal(proto.YUNYING_LOTO, self.Handle1700016)        -- 转盘结果
    self:RegisterProtocal(proto.YUNYING_LOTO_PROGRESS, self.Handle1700017)        -- 转盘进度更新
    self:RegisterProtocal(proto.YUNYING_SHOP_REWARD_LOG, self.Handle1700020)        -- 跨服购买日志
    self:RegisterProtocal(proto.YUNYING_SHOP_INFO, self.Handle1700018)        -- 跨服购买日志
    self:RegisterProtocal(proto.YUNYING_SHOP_BUY, self.Handle1700019)        -- 跨服商店购买
end

function OperateController:AddEvents()
    GlobalEvent:AddListener(OperateEvent.REQUEST_GET_YY_INFO, handler(self, self.Request1700006))
    GlobalEvent:AddListener(OperateEvent.REQUEST_GET_REWARD, handler(self, self.Request1700004))
    GlobalEvent:AddListener(OperateEvent.REQUEST_FREE_GIFT_INFO, handler(self, self.Request1700007))
    GlobalEvent:AddListener(OperateEvent.REQUEST_FREE_GIFT_REWARD_FETCH, handler(self, self.Request1700008))
    GlobalEvent:AddListener(OperateEvent.REQUEST_YY_LOG, handler(self, self.Request1700009))
    GlobalEvent:AddListener(OperateEvent.REQUEST_LOTTERY_INFO, handler(self, self.Request1700010))
    GlobalEvent:AddListener(OperateEvent.REQUEST_CRACK_EGG, handler(self, self.Request1700011))
    GlobalEvent:AddListener(OperateEvent.REQUEST_REFRESH_EGG, handler(self, self.Request1700012))
    GlobalEvent:AddListener(OperateEvent.REQUEST_FIRE, handler(self, self.Request1700014))
    GlobalEvent:AddListener(OperateEvent.REQUEST_D_INFO, handler(self, self.Request1700015))
    GlobalEvent:AddListener(OperateEvent.REQ_D_TURN, handler(self, self.Request1700016))
    GlobalEvent:AddListener(OperateEvent.REQUEST_SHOP_BOUGHT_RECO, handler(self, self.Request1700020))
    GlobalEvent:AddListener(OperateEvent.REQUEST_SHOP_INFO, handler(self, self.Request1700018))
    GlobalEvent:AddListener(OperateEvent.REQUEST_SHOP_BUY, handler(self, self.Request1700019))
end

--请求 活动列表
function OperateController:Request1700001()
    local pb = self:GetPbObject("m_yunying_list_tos")
    self:WriteMsg(proto.YUNYING_LIST)
end

--返回 活动列表
function OperateController:Handle1700001()
    local data = self:ReadMsg("m_yunying_list_toc")
    self.model:AddActList(data.activities)
end


--返回 活动开始
function OperateController:Handle1700002()
    local data = self:ReadMsg("m_yunying_start_toc")
    self.model:AddAct(data.activity)
    GlobalEvent:Brocast(OperateEvent.ACT_START, data.id)
end

--返回 活动结束
function OperateController:Handle1700003()
    local data = self:ReadMsg("m_yunying_stop_toc")
    self.model:DelAct(data.id)
end

--请求 奖励
function OperateController:Request1700004(id, type, level)
    local pb = self:GetPbObject("m_yunying_fetch_tos")
    pb.act_id = id
    pb.id = type
    pb.level = level
    self:WriteMsg(proto.YUNYING_FETCH, pb)
end

--返回 奖励
function OperateController:Handle1700004()
    local data = self:ReadMsg("m_yunying_fetch_toc")
    self.model:UpdateRewardInfo(data)
    GlobalEvent:Brocast(OperateEvent.SUCCESS_GET_REWARD, data)
end

--返回 配置更新
function OperateController:Handle1700005()
    local data = self:ReadMsg("m_yunying_update_toc")

    -- 修改运营配置要重新请求cdn
    if data.type == 1 or data.type == 3 then
        --  self.model:RequestConfig()
    end

    -- 修改奖励配置
    if data.type == 2 or data.type == 3 then
        self.model:AddRewardConfigList(data.rewards)
    end
end

--请求 活动信息
function OperateController:Request1700006(id)
    local pb = self:GetPbObject("m_yunying_info_tos")
    pb.id = id
    self:WriteMsg(proto.YUNYING_INFO, pb)
end

--返回 活动信息
function OperateController:Handle1700006()
    local data = self:ReadMsg("m_yunying_info_toc")
    --如果act_listi里面没有这个活动，同时不再忽略列表里的 就不需要
    if (not self.model:IsActOpenByTime(data.id)) and (self.model:CheckIsIgnoreLv(data.act_id)) then
        return
    end
    self.model:UpdateInfo(data)
    GlobalEvent:Brocast(OperateEvent.DLIVER_YY_INFO, data)
end

function OperateController:Request1700007()
    self:WriteMsg(proto.YUNYING_GIFT)
end

function OperateController:Handle1700007()
    local data = self:ReadMsg("m_yunying_gift_toc")
    GlobalEvent:Brocast(OperateEvent.DILIVER_FREE_GIFT_INFO, data)
end

function OperateController:Request1700008(act_id, id)
    local pb = self:GetPbObject("m_yunying_gift_fetch_tos")
    pb.act_id = act_id
    pb.id = id
    self:WriteMsg(proto.YUNYING_GIFT_FETCH, pb)
end

function OperateController:Handle1700008()
    local data = self:ReadMsg("m_yunying_gift_fetch_toc")
    GlobalEvent:Brocast(OperateEvent.DILIVER_FREE_GIFT_REWARD_FETCH, data)
end

function OperateController:Request1700009(act_id)
    local pb = self:GetPbObject("m_yunying_logs_tos")
    act_id = act_id or 0
    pb.act_id = act_id
    self:WriteMsg(proto.YUNYING_LOGS, pb)
end

function OperateController:Handle1700009()
    local data = self:ReadMsg("m_yunying_logs_toc")
    GlobalEvent:Brocast(OperateEvent.DELIVER_YY_LOG, data.act_id, data.logs)
end

--单条记录更新
function OperateController:Handle1700013()
    local data = self:ReadMsg("m_yunying_logs_update_toc")
    GlobalEvent:Brocast(OperateEvent.UPDATE_YY_LOG, data.act_id, data.log)
end

--砸蛋
function OperateController:Request1700010(act_id)
    local pb = self:GetPbObject("m_yunying_lottery_info_tos")
    act_id = act_id or 0
    pb.act_id = act_id
    self:WriteMsg(proto.YUNYING_LOTTERY_INFO, pb)
end

function OperateController:Handle1700010()
    local data = self:ReadMsg("m_yunying_lottery_info_toc")
    GlobalEvent:Brocast(OperateEvent.DILIVER_LOTTERY_INFO, data.act_id, data)
end

function OperateController:Request1700011(act_id, pos)
    local pb = self:GetPbObject("m_yunying_lottery_do_tos")
    act_id = act_id or 0
    pb.act_id = act_id
    pb.pos = pos
    self:WriteMsg(proto.YUNYING_LOTTERY_DO, pb)
end

function OperateController:Handle1700011()
    local data = self:ReadMsg("m_yunying_lottery_do_toc")
    GlobalEvent:Brocast(OperateEvent.SUCCESS_CRACK_EGG, data.act_id, data)
end

function OperateController:Request1700012(act_id)
    local pb = self:GetPbObject("m_yunying_lottery_refresh_tos")
    act_id = act_id or 0
    pb.act_id = act_id
    self:WriteMsg(proto.YUNYING_LOTTERY_REFRESH, pb)
end

function OperateController:Handle1700012()
    local data = self:ReadMsg("m_yunying_lottery_refresh_toc")
    GlobalEvent:Brocast(OperateEvent.HANDLE_REFRESH_EGG, data.act_id, data)
end


--节日活动花火
function OperateController:Request1700014(act_id, times)
    local pb = self:GetPbObject("m_yunying_lottery_draw_tos")
    act_id = act_id or 0
    pb.act_id = act_id
    pb.times = times
    self:WriteMsg(proto.YUNYING_LOTTERY_DRAW, pb)
end

function OperateController:Handle1700014()
    local data = self:ReadMsg("m_yunying_lottery_draw_toc")
    GlobalEvent:Brocast(OperateEvent.SUCCESS_FIRE, data.act_id, data.reward_ids)
end

-----运营活动转盘
function OperateController:Request1700015(act_id)
    if (not act_id) or act_id == 0 then
        return
    end
    act_id = act_id or 0
    local pb = self:GetPbObject("m_yunying_lotoinfo_tos")
    pb.act_id = act_id
    self:WriteMsg(proto.YUNYING_LOTOINFO, pb)
end

function OperateController:Handle1700015()
    local data = self:ReadMsg("m_yunying_lotoinfo_toc")
    GlobalEvent:Brocast(OperateEvent.DILIVER_D_INFO, data.act_id, data)
end

function OperateController:Request1700016(act_id)
    if (not act_id) or act_id == 0 then
        return
    end
    act_id = act_id or 0
    local pb = self:GetPbObject("m_yunying_loto_tos")
    pb.act_id = act_id
    self:WriteMsg(proto.YUNYING_LOTO, pb)
end

function OperateController:Handle1700016()
    local data = self:ReadMsg("m_yunying_loto_toc")
    GlobalEvent:Brocast(OperateEvent.DILIVER_TURN_RESULT, data.act_id, data)
end

function OperateController:Handle1700017()
    local data = self:ReadMsg("m_yunying_loto_progress_toc")
    GlobalEvent:Brocast(OperateEvent.UPDATE_D_PRO, data.act_id, data.progress)
end

function OperateController:Request1700020(act_id)
    if (not act_id) or act_id == 0 then
        return
    end
    local pb = self:GetPbObject("m_yunying_shop_reward_log_tos")
    pb.act_id = act_id
    self:WriteMsg(proto.YUNYING_SHOP_REWARD_LOG, pb)
end

function OperateController:Handle1700020()
    local data = self:ReadMsg("m_yunying_shop_reward_log_toc")
    GlobalEvent:Brocast(OperateEvent.DILIVER_SHOP_BOUGHT_RECO, data.act_id, data.logs)
end

function OperateController:Request1700018(act_id)
    if (not act_id) or act_id == 0 then
        return
    end
    local pb = self:GetPbObject("m_yunying_shop_info_tos")
    pb.act_id = act_id
    self:WriteMsg(proto.YUNYING_SHOP_INFO, pb)
end

function OperateController:Handle1700018()
    local data = self:ReadMsg("m_yunying_shop_info_toc")
    GlobalEvent:Brocast(OperateEvent.DILIVER_SHOP_INFO, data.act_id, data)
end

function OperateController:Request1700019(act_id, shop_id, num)
    if (not act_id) or act_id == 0 then
        return
    end
    local pb = self:GetPbObject("m_yunying_shop_buy_tos")
    pb.act_id = act_id
    pb.shop_id = shop_id
    pb.num = num
    self:WriteMsg(proto.YUNYING_SHOP_BUY, pb)
end

function OperateController:Handle1700019()
    local data = self:ReadMsg("m_yunying_shop_buy_toc")
    GlobalEvent:Brocast(OperateEvent.DILIVER_BUY_RESULT, data.act_id, data.shop, data.logs)
end