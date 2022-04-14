---
--- Created by  Administrator
--- DateTime: 2019/11/18 15:36
---
require('game.compete.RequireCompete')
CompeteController = CompeteController or class("CompeteController", BaseController)
local CompeteController = CompeteController

function CompeteController:ctor()
    CompeteController.Instance = self
    self.model = CompeteModel:GetInstance()
    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocol()
end

function CompeteController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function CompeteController:GetInstance()
    if not CompeteController.Instance then
        CompeteController.new()
    end
    return CompeteController.Instance
end

function CompeteController:AddEvents()

    local function call_back()
       -- lua_panelMgr:GetPanelOrCreate(AthleticsPanel):Open(1, 5)
        -- if self.model.isEnroll then
        --     lua_panelMgr:GetPanelOrCreate(AthleticsPanel):Open(1, 5)
        --     return
        -- end
        -- lua_panelMgr:GetPanelOrCreate(CompeteEnrollPanel):Open()
    end
    GlobalEvent:AddListener(CompeteEvent.OpenCompeteNoticePanel,call_back)
    GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.HandleSceneChange));

    local function call_back(id)
        local cfg = Config.db_activity[id]
        if cfg then
            if cfg.key == "compete" then
                local reqs = String2Table(cfg.reqs)
                if not table.isempty(reqs) then
                    local curPeriod = reqs[1][2]
                    if curPeriod == enum.COMPETE_PERIOD.COMPETE_PERIOD_SELECT then --海选阶段
                        local sceneId  = SceneManager:GetInstance():GetSceneId()
                        local config = Config.db_scene[sceneId]
                        if not config then
                            logError("不存在场景配置" .. tostring(sceneId));
                            return false
                        end
                        if config.type == enum.SCENE_TYPE.SCENE_TYPE_CITY or config.type == enum.SCENE_TYPE.SCENE_TYPE_FIELD then
                            GlobalEvent:Brocast(CompeteEvent.OpenCompeteNoticePanel)
                        end

                        self:RequstCompetePanelInfo()
                       -- local isEnroll = self.model.isEnroll
                       -- logError("海选准备时间弹窗")
                    end
                end
            end
        end
    end
    GlobalEvent:AddListener(ActivityEvent.PredictActivity,call_back)


    local function call_back(isShow,id)
        --if not isShow then
        --    return
        --end
        local cfg = Config.db_activity[id]
        if cfg then
            do
                return
            end
            if cfg.key == "compete" then
                self:RequstCompetePanelInfo()
               -- self:CheckRedPoint()
                local reqs = String2Table(cfg.reqs)
                if not table.isempty(reqs) then
                    local curPeriod = reqs[1][2]
                    if curPeriod == enum.COMPETE_PERIOD.COMPETE_PERIOD_ENROLL then --报名阶段
                        -- GlobalEvent:Brocast(CompeteEvent.OpenCompeteNoticePanel)
                        if isShow then
                            local isEnroll = self.model.isEnroll
                            if isEnroll  then --已报名
                                if Constant.IsFirstLanding then --第一次登陆
                                    local sceneId  = SceneManager:GetInstance():GetSceneId()
                                    local config = Config.db_scene[sceneId]
                                    if not config then
                                        logError("不存在场景配置" .. tostring(sceneId));
                                        return false
                                    end
                                    if config.type == enum.SCENE_TYPE.SCENE_TYPE_CITY or config.type == enum.SCENE_TYPE.SCENE_TYPE_FIELD then
                                        GlobalEvent:Brocast(CompeteEvent.OpenCompeteNoticePanel)
                                    end

                                end
                            else
                                local sceneId  = SceneManager:GetInstance():GetSceneId()
                                local config = Config.db_scene[sceneId]
                                if not config then
                                    logError("不存在场景配置" .. tostring(sceneId));
                                    return false
                                end
                                if config.type == enum.SCENE_TYPE.SCENE_TYPE_CITY or config.type == enum.SCENE_TYPE.SCENE_TYPE_FIELD then
                                    GlobalEvent:Brocast(CompeteEvent.OpenCompeteNoticePanel)
                                end
                            end
                            self.model:CheckEnrollRedPoint()
                        end
                    elseif curPeriod == enum.COMPETE_PERIOD.COMPETE_PERIOD_RANK  then --争霸阶段
                        local function call_back()
                            lua_panelMgr:GetPanelOrCreate(CompeteMatchPanel):Open()
                        end
                        GlobalEvent:Brocast(MainEvent.ChangeMidTipIcon, "compete", isShow, call_back, nil, nil, nil)

                        --GlobalEvent:Brocast(CompeteEvent.CompeteShowMacthIcon,isShow) --显示主界面竞猜图标
                    end
                    
                end
            end
        end
    end
    GlobalEvent:AddListener(ActivityEvent.ChangeActivity,call_back)
    --
    --local function call_back()
    --    self.model:CheckEnrollRedPoint()
    --end
    --RoleInfoModel:GetInstance():GetMainRoleData():BindData("wake", call_back)
    --
    --local function call_back(id)
    --    if id == 10002 then
    --        self.model:CheckEnrollRedPoint()
    --    end
    --end
    --GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)

    --GlobalEvent:AddListener(EventName.KeyRelease, handler(self, self.Test))
end

function CompeteController:Test(keyCode)
    if keyCode == InputManager.KeyCode.N then
        lua_panelMgr:GetPanelOrCreate(CompeteVsPanel):Open()
    end
end





function CompeteController:HandleSceneChange(sceneID)
    local config = Config.db_scene[sceneID]
    if not config then
        print2("不存在场景配置" .. tostring(sceneID));
        return
    end

    local curSceneId = SceneManager:GetInstance().last_scene_id
    local lastConfig = Config.db_scene[curSceneId]
    if lastConfig then
        if lastConfig.type == enum.SCENE_TYPE.SCENE_TYPE_ACT and lastConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_COMPETE_BATTLE then
            --local  panel = lua_panelMgr:GetPanel(PeakArenaBattlePanel);
            --if panel then
            --    panel:Close()
            --end
            --lua_panelMgr:GetPanelOrCreate(AthleticsPanel):Open(1, 4);
            self:ShowPanel(true)
        end
    end


    if config.type == enum.SCENE_TYPE.SCENE_TYPE_ACT and config.stype == enum.SCENE_STYPE.SCENE_STYPE_COMPETE_BATTLE then
        --巅峰1v1
       -- lua_panelMgr:GetPanelOrCreate(PeakArenaBattlePanel):Open()
        self:ShowPanel(false)
        --
        --local  panel = lua_panelMgr:GetPanel(PeakArenaReadyPanel);
        --if panel then
        --    panel:Close()
        --end

    end
end

function CompeteController:ShowPanel(isShow)
    local  aPanel = lua_panelMgr:GetPanel(MainUIView)
    if aPanel then
        aPanel.main_top_left:SetVisible(isShow)
      --  aPanel.main_middle_left:SetVisible(isShow)
        aPanel.main_top_right:SetVisible(isShow)
    end
end





function CompeteController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    self.pb_module_name = "pb_1607_compete_pb"
    self:RegisterProtocal(proto.COMPETE_PANEL, self.HandleCompetePanelInfo);
    self:RegisterProtocal(proto.COMPETE_ENROLL, self.HandleCompeteEnroll);
    self:RegisterProtocal(proto.COMPETE_PREPARE, self.HandleCompetePrepareInfo);
    self:RegisterProtocal(proto.COMPETE_BATTLE, self.HandleCompeteBattleInfo)
    self:RegisterProtocal(proto.COMPETE_BUFF, self.HandleCompeteBuffInfo)
    self:RegisterProtocal(proto.COMPETE_STAT, self.HandleCompeteStatInfo)
    self:RegisterProtocal(proto.COMPETE_MATCH, self.HandleCompeteMatchInfo)
    self:RegisterProtocal(proto.COMPETE_GUESS, self.HandleCompeteGuessInfo)
    self:RegisterProtocal(proto.COMPETE_HISTORY, self.HandleCompeteHistoryInfo)
    self:RegisterProtocal(proto.COMPETE_FIGHT, self.HandleCompeteFightInfo)
    self:RegisterProtocal(proto.COMPETE_RANKING, self.HandleCompeteRankInfo)
    self:RegisterProtocal(proto.COMPETE_VERSUS, self.HandleCompeteVersusInfo)




end

-- overwrite
function CompeteController:GameStart()
    local function step()
        self:RequstCompetePanelInfo()
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Super)
end

--面板信息
function CompeteController:RequstCompetePanelInfo()
    local pb = self:GetPbObject("m_compete_panel_tos")
    --logError("面板信息")
    self:WriteMsg(proto.COMPETE_PANEL,pb)
end

function CompeteController:HandleCompetePanelInfo()
    local data = self:ReadMsg("m_compete_panel_toc")
    self.model:DealPanelInfo(data)
    self.model:Brocast(CompeteEvent.CompetePanelInfo,data)
    self.model:CheckRedPoint()
end

--报名
function CompeteController:RequstCompeteEnroll(act_id)
    local pb = self:GetPbObject("m_compete_enroll_tos")
    pb.act_id = act_id
    self:WriteMsg(proto.COMPETE_ENROLL,pb)
end

function CompeteController:HandleCompeteEnroll()
    local data = self:ReadMsg("m_compete_enroll_toc")
    self.model.isEnroll = true
    self.model:Brocast(CompeteEvent.CompeteEnroll,data)
    self.model:CheckEnrollRedPoint()
   -- self.model:CheckRedPoint()
end

--备战信息
function CompeteController:RequstCompetePrepareInfo()
    local pb = self:GetPbObject("m_compete_prepare_tos")

    self:WriteMsg(proto.COMPETE_PREPARE,pb)
end

function CompeteController:HandleCompetePrepareInfo()
    local data = self:ReadMsg("m_compete_prepare_toc")

    self.model:Brocast(CompeteEvent.CompetePrepareInfo,data)
end

--战场信息
function CompeteController:RequstCompeteBattleInfo()
    local pb = self:GetPbObject("m_compete_battle_tos")

    self:WriteMsg(proto.COMPETE_BATTLE,pb)
end

function CompeteController:HandleCompeteBattleInfo()
    local data = self:ReadMsg("m_compete_battle_toc")

    self.model:Brocast(CompeteEvent.CompeteBattleInfo,data)
end


--购买buff
function CompeteController:RequstCompeteBuffInfo(buff_id)
    local pb = self:GetPbObject("m_compete_buff_tos")
    pb.buff_id = buff_id
    self:WriteMsg(proto.COMPETE_BUFF,pb)
end

function CompeteController:HandleCompeteBuffInfo()
    local data = self:ReadMsg("m_compete_buff_toc")

    self.model:Brocast(CompeteEvent.CompeteBuffInfo,data)
end


----结算信息
--function CompeteController:RequstCompeteStatInfo()
--    local pb = self:GetPbObject("m_compete_stat_tos")
--
--    self:WriteMsg(proto.COMPETE_STAT,pb)
--end

function CompeteController:HandleCompeteStatInfo()
    local data = self:ReadMsg("m_compete_stat_toc")
    --logError("结算信息")
    if self.model:IsCompeteReady() or  self.model:IsCompeteDungeon() then
        lua_panelMgr:GetPanelOrCreate(CompeteResultPanel):Open(data)
    end
    self.model:Brocast(CompeteEvent.CompeteStatInfo,data)
end


--匹配信息
function CompeteController:RequstCompeteMatchInfo(type)
    local pb = self:GetPbObject("m_compete_match_tos")
    pb.type = type
    self:WriteMsg(proto.COMPETE_MATCH,pb)
end

function CompeteController:HandleCompeteMatchInfo()
    local data = self:ReadMsg("m_compete_match_toc")
    self.model:DealGruop(data.groups,data.type)
    self.model:Brocast(CompeteEvent.CompeteMatchInfo,data)
    self.model:CheckRedPoint()
end



function CompeteController:RequstCompeteGuessInfo(act_id,group,role,type,rank)
    local pb = self:GetPbObject("m_compete_guess_tos")
    pb.act_id = act_id
    pb.group = group
    pb.role = role
    pb.type = type
    pb.rank = rank
    self:WriteMsg(proto.COMPETE_GUESS,pb)
end

function CompeteController:HandleCompeteGuessInfo()
    local data = self:ReadMsg("m_compete_guess_toc")

    self.model:Brocast(CompeteEvent.CompeteGuessInfo,data)
end

--往期战报
function CompeteController:RequstCompeteHistoryInfo()
    local pb = self:GetPbObject("m_compete_history_tos")

    self:WriteMsg(proto.COMPETE_HISTORY,pb)
end

function CompeteController:HandleCompeteHistoryInfo()
    local data = self:ReadMsg("m_compete_history_toc")

    self.model:Brocast(CompeteEvent.CompeteHistoryInfo,data)
end


--战斗开始时候发
function CompeteController:RequstCompeteFightInfo()
    local pb = self:GetPbObject("m_compete_fight_tos")

    self:WriteMsg(proto.COMPETE_FIGHT,pb)
end



function CompeteController:HandleCompeteFightInfo()
    local data = self:ReadMsg("m_compete_fight_toc")

    self.model:Brocast(CompeteEvent.CompeteFightInfo,data)
end


--排行
function CompeteController:RequstCompeteRankInfo()
    local pb = self:GetPbObject("m_compete_ranking_tos")

    self:WriteMsg(proto.COMPETE_RANKING,pb)
end

function CompeteController:HandleCompeteRankInfo()
    local data = self:ReadMsg("m_compete_ranking_toc")
    self.model:Brocast(CompeteEvent.CompeteRankInfo,data)
end


--匹配到
function CompeteController:HandleCompeteVersusInfo()
    local data = self:ReadMsg("m_compete_versus_toc")
    lua_panelMgr:GetPanelOrCreate(CompeteVsPanel):Open(data)
    --self.model.roleData = data
    --self.model:Brocast(CompeteEvent.CompeteVersusInfo,data)
end
