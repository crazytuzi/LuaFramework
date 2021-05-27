require("scripts/game/dungeon_cl_and_jy/dungeon_data")
require("scripts/game/dungeon_cl_and_jy/dungeon_view")
require("scripts/game/dungeon_cl_and_jy/lucky_draw/lucky_draw_view")
require("scripts/game/dungeon_cl_and_jy/exp_show_tip_view")
require("scripts/game/dungeon_cl_and_jy/exp_get_reward")
require("scripts/game/dungeon_cl_and_jy/sweep_result_view")
require("scripts/game/dungeon_cl_and_jy/lianyu_guide_reward_view")
require("scripts/game/dungeon_cl_and_jy/lianyu_guide_show_tip_view")

DungeonCtrl = DungeonCtrl or BaseClass(BaseController)

function DungeonCtrl:__init()
    if DungeonCtrl.Instance then
        ErrorLog("[EquipCtrl] Attemp to create a singleton twice !")
    end
    DungeonCtrl.Instance = self
    
    self.view = DungeonView.New(ViewDef.Dungeon)
    self.LuckydrawView = LuckydrawView.New(ViewDef.LuckyDraw)   --幸运抽奖面板
    self.sweep_result = SweepResultView.New(ViewDef.SweepResult) -- 扫荡结果
    
    self.data = DungeonData.New()
    self:RegisterAllProtocols()

    self.exp_view = ExpShowTipView.New(ViewDef.ShowExpTip)
    
    self.exp_reward_view = ExpGetRewardView.New(ViewDef.ShowRewardExp)

    self.lianyu_guide_view = LianYuGuideShowTipView.New(ViewDef.LianyuGuide)

     self.lianyu_reward_view = LianYuRewardView.New(ViewDef.LianyuReward)
end

function DungeonCtrl:__delete()
    DungeonCtrl.Instance = nil
    self.view:DeleteMe()
    self.view = nil

    self.LuckydrawView:DeleteMe()
    self.LuckydrawView = nil

    self.exp_view:DeleteMe()
    self.exp_view = nil

    self.exp_reward_view:DeleteMe()
    self.exp_reward_view = nil

    self.sweep_result:DeleteMe()
    self.sweep_result = nil

     self.lianyu_guide_view:DeleteMe()
     self.lianyu_guide_view = nil 

     self:CancelTimer()
end
function DungeonCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCCailiaoFubenInfo,"OnCailiaoInfoBack")
    self:RegisterProtocol(SCFubenOneKeyCpltResult,"OnOneKeyFubenResult")
    self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))

    self:RegisterProtocol(SCTurntableInfo, "OnLuckTurnbleInfo")
    GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.SendLuckTurnbleDarwNumReq))
    GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.OnSceneLoadingStateEnter, self))
end

function DungeonCtrl:OnRecvMainRoleInfo()
    GlobalTimerQuest:AddDelayTimer(function() DungeonCtrl.EnterFubenReq(3,0,0) end,math.random(1,5))
end
---------------------------------------
-- 请求
---------------------------------------
function DungeonCtrl.EnterFubenReq(enter_type, fuben_id, fuben_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqEnterFuben)
    protocol.enter_type = enter_type
    protocol.enter_fuben_id = fuben_id
    protocol.fuben_index = fuben_index
    if enter_type == 4 then
        protocol.rew_type = 1
    end
	protocol:EncodeAndSend()
end

function DungeonCtrl.ExpFubenAwardReq(fuben_index)
    DungeonCtrl.EnterFubenReq(4, FubenZongGuanCfg.fubens[5].static_id, fuben_index)
end

function DungeonCtrl:OnCailiaoInfoBack(protocol)
    if protocol.fuben_event_id ~= 4 then
        local fuben_info_data = protocol.fuben_info_data
        self.data:UpdateCailiaoData(fuben_info_data)
        self.view:Flush()
    elseif protocol.fuben_event_id ~= 3 then
        --操作完成 请求数据
        DungeonCtrl.EnterFubenReq(3,0,0)
    end
    GlobalEventSystem:Fire(OtherEventType.CAILIAO_INFO_CHANGE)
end

function DungeonCtrl:OnOneKeyFubenResult(protocol)
    local result = protocol.result
    local fuben_index = protocol.fuben_index
 
    if result == 1 then
        local cfg = FubenZongGuanCfg.fubens[fuben_index]
        if nil == cfg then return end
        self:SweepResultOpen(cfg.award, cfg.senceid) 
    end
end

--是否在材料副本
function DungeonCtrl.IsInCailiaoMap()
    local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
    local fuben_id = main_role_vo.fb_id
    local fbs = FubenZongGuanCfg.fubens;
    for __,v in pairs(fbs) do
        if v.fbid == fuben_id then
            return true
        end
    end
    return false
end

-- 扫荡面板打开
function DungeonCtrl:SweepResultOpen(Award, scene_id)
    if self.sweep_result then
        self.sweep_result:SetData(Award, scene_id)
        ViewManager.Instance:OpenViewByDef(ViewDef.SweepResult)
    end
end


--幸运转盘

function DungeonCtrl:ShowLuckTurnble(static_id)
    self.LuckydrawView:Open()
    self.LuckydrawView:ShowStaticIdDraw(static_id)
end

function DungeonCtrl:OnLuckTurnbleInfo(protocol)
    self.data:SetLuckData(protocol.info_t)

    self.LuckydrawView:Flush(0, "all", {index = protocol.index})
    if protocol.static_id == 5 then
        ViewManager.Instance:FlushViewByDef(ViewDef.Dungeon.Experience)
    else
        ViewManager.Instance:FlushViewByDef(ViewDef.Dungeon.Material)
    end
    self.view:Flush()
    self.LuckydrawView:Flush()
    RemindManager.Instance:DoRemindDelayTime(RemindName.CaiLiaoFBReward)
end


function DungeonCtrl.SendLuckTurnbleDarwNumReq()
    for i = 1, 5 do
        GlobalTimerQuest:AddDelayTimer(BindTool.Bind(DungeonCtrl.SendLuckTurnbleReq, 1, i), i * 0.1)
    end
end

function DungeonCtrl.SendLuckTurnbleDarwReq(id)
    DungeonCtrl.SendLuckTurnbleReq(2, id)
    DungeonCtrl.SendLuckTurnbleReq(1, id)
end

function DungeonCtrl.SendLuckTurnbleGoldDarwReq()
    DungeonCtrl.SendLuckTurnbleReq(3)
end

function DungeonCtrl.SendLuckTurnbleReq(type, static_id)
    local protocol = ProtocolPool.Instance:GetProtocol(CSYBTurntableReq)
    protocol.type = type
    protocol.static_id = static_id
    protocol:EncodeAndSend()
end

--炼狱副本操作
function DungeonCtrl.SendOprateLianYuFubenReq(type, index)
    local protocol = ProtocolPool.Instance:GetProtocol(CSEnterLianYuFuben)
    protocol.operate_type = type
    protocol.reward_index = index or 0
    protocol:EncodeAndSend()
end

-- 请求购买经验副本次数
function DungeonCtrl.SendBuyExpFubenTimeReq()
    local protocol = ProtocolPool.Instance:GetProtocol(CSBuyExpFubenTime)
    protocol:EncodeAndSend()
end

function DungeonCtrl:OnSceneLoadingStateEnter(scene_id, scene_type, fuben_id)

   
    if scene_id == PurgatoryFubenConfig.sceneid and fuben_id == PurgatoryFubenConfig.fbId then
       
    else
        -- 退出试炼地图 或 并非进入试炼地图
        self:CancelTimer()

       
    end
end

function DungeonCtrl:ShowTipsShow( time)
    local count_down_callback =  function (elapse_time, total_time, view) 
            local num = total_time - math.floor(elapse_time)

            -- if self.trial_fuben_info then
            -- if ViewManager.Instance:IsOpen(ViewDef.BabelInfo) then
            --     local daps = self:GetTrialDps()
            --     ViewManager.Instance:FlushViewByDef(ViewDef.BabelInfo, 0, "miaoshao", {daps = daps})
            -- end
        end
    self.time_die = UiInstanceMgr.Instance:AddTimeLeaveView(time, count_down_callback, "vip_boss_tip")
end


function DungeonCtrl:CancelTimer()
   if self.time_die then
        self.time_die:StopTimeDowner()
        self.time_die = nil
    end
end

-- 设置封神面板打开的字面板
function DungeonCtrl.SetViewDefaultChild(def)
    local view_def = ViewDef and ViewDef.Dungeon or {}
    view_def.default_child = def
end