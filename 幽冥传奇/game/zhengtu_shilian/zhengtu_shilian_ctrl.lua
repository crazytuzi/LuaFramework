require("scripts/game/zhengtu_shilian/zhengtu_shilian_data")
require("scripts/game/zhengtu_shilian/shilian_view")
-- require("scripts/game/zhengtu_shilian/zhengtu_view")
require("scripts/game/zhengtu_shilian/shilian_rotary_table_view")
require("scripts/game/zhengtu_shilian/award_everyday")
ZhengtuShilianCtrl = ZhengtuShilianCtrl or BaseClass(BaseController)

function ZhengtuShilianCtrl:__init()
    if ZhengtuShilianCtrl.Instance then
        ErrorLog("[ZhengtuShilianCtrl]:Attempt to create singleton twice!")
    end
    ZhengtuShilianCtrl.Instance = self
    
    self.data = ZhengtuShilianData.New()
    self.sl_view = ShilianView.New(ViewDef.ShiLian)
    self.award_everyday_view = AwardEveryView.New(ViewDef.AwardEveryDay)
    -- self.zt_view = ZhengtuView.New(ViewDef.Zhengtu)
    self.zp_view = ShiLianRotaryTableView.New(ViewDef.ShiLianRotaryTable)
    self:RegisterAllProtocols()

    -- 上线请求
    self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainInfoCallBack, self))
end

function ZhengtuShilianCtrl:__delete()
    self.sl_view:DeleteMe()
    self.sl_view = nil
    
    -- self.zt_view:DeleteMe()
    -- self.zt_view = nil
    
    self.data:DeleteMe()
    self.data = nil
    
    ZhengtuShilianCtrl.Instance = nil
end

-- 上线请求回调
function ZhengtuShilianCtrl:RecvMainInfoCallBack()
    local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) -- 人物等级
    if level >= GameCond.CondId66.RoleLevel then
        self.SendShiLianRotaryTableReq(1)
    end
end

function ZhengtuShilianCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCShiLianRotaryTableResult, "OnShiLianRotaryTableResult")   -- 接收试炼转盘数据
    self:RegisterProtocol(SCShiLianAwardEverydayInfo, "OnShiLianAwardEverydayInfo")   -- 接收试炼转盘每日奖励
end


function ZhengtuShilianCtrl:OnZhengtuShilianGuajiInfo(protocol)
end

-- 接收试炼转盘数据(139, 200)
function ZhengtuShilianCtrl:OnShiLianRotaryTableResult(protocol)
    self.data:SetRotaryTableData(protocol)
end

-- 接收试炼转盘每日奖励(139, 201)
function ZhengtuShilianCtrl:OnShiLianAwardEverydayInfo(protocol)
    self.data:SetShiLianAwardEverydayData(protocol)
end

function ZhengtuShilianCtrl.SendZhengtuShilianGuajiReq()
    local protocol = ProtocolPool.Instance:GetProtocol(CSZhengtuShilianGuajiReq)
    protocol:EncodeAndSend()
end

--请求突破
function ZhengtuShilianCtrl.SendZhengtuUpReq()
    local protocol = ProtocolPool.Instance:GetProtocol(CSEnterPracticeGateReq)
    protocol:EncodeAndSend()
end

--请求试炼转盘数据(139, 209)
function ZhengtuShilianCtrl.SendShiLianRotaryTableReq(type)
    -- local protocol = ProtocolPool.Instance:GetProtocol(CSShiLianRotaryTableReq)
    -- protocol.type = type -- 操作类型, 1抽奖信息, 2单次抽奖
    -- protocol:EncodeAndSend()
end

--请求试炼每日奖励数据(139, 210)
function ZhengtuShilianCtrl.SendShiLianAwardInfoReq()
    local protocol = ProtocolPool.Instance:GetProtocol(CSShiLianAwardInfoReq)
    protocol:EncodeAndSend()
end

function ZhengtuShilianCtrl:GetRemindNum()
    return self.data:GetRewardRemind()
end

-- 请求领取试炼每日奖励(139, 211)
function ZhengtuShilianCtrl.SendSCSShiLianAwardLingQuReq()
    local protocol = ProtocolPool.Instance:GetProtocol(CSShiLianAwardLingQuReq)
    protocol:EncodeAndSend()
end


