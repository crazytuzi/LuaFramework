-- @Author: lwj
-- @Date:   2019-01-03 11:11:11
-- @Last Modified time: 2019-01-03 11:13:22

require('game.book.RequireBook')
BookController = BookController or class("BookController", BaseController)
local BookController = BookController

function BookController:ctor()
    BookController.Instance = self
    self.model = BookModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function BookController:dctor()
end

function BookController:GetInstance()
    if not BookController.Instance then
        BookController.new()
    end
    return BookController.Instance
end

function BookController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1122_target_pb"
    self:RegisterProtocal(proto.TARGET_INFO, self.HandleBookInfo)
end

function BookController:AddEvents()
    GlobalEvent:AddListener(BookEvent.OpenBookPanel, handler(self, self.HandleOpenPanel))
    GlobalEvent:AddListener(EventName.ChangeSceneEnd, handler(self, self.HandleSceneChange))
    self.model:AddListener(BookEvent.GetTaskReward, handler(self, self.RequestGetTaskReward))
    self.model:AddListener(BookEvent.GetThemeSkill, handler(self, self.RequestGetThemeSkill))
    self.model:AddListener(BookEvent.HandleBossSceneChange, handler(self, self.HandleSceneChange))
end

-- overwrite
function BookController:GameStart()
    local function step()
        self:RequestBookInfo()
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Super)
end

function BookController:RequestBookInfo()
    self:WriteMsg(proto.TARGET_INFO)
end

function BookController:HandleOpenPanel(id)
    self.model:GetCurThemeList()
    --id = id or 1
    if not self.model:IsShowMainIcon() then
        Notify.ShowText("Skill vault is closed")
        return
    end
    if id and (not self.model:IsOpenTheme(id)) then
        local cf = Config.db_target[id]
        local cur_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
        local limit_tbl = String2Table(cf.limit)
        local cur_opdays = LoginModel.GetInstance():GetOpenTime()
        local lv_limit
        local opday_limit
        if type(limit_tbl[1]) == 'table' then
            for _, tbl in pairs(limit_tbl) do
                if tbl[1] == "level" then
                    lv_limit = tbl[2]
                elseif tbl[1] == "open_days" then
                    opday_limit = tbl[2]
                end
            end
        else
            if limit_tbl[1] == "level" then
                lv_limit = limit_tbl[2]
            elseif limit_tbl[1] == "open_days" then
                opday_limit = limit_tbl[2]
            end
        end

        local str = ""
        if cf.pre_id ~= 0 then
            --有前置主题
            local pre_cf = Config.db_target[cf.pre_id]
            local name = pre_cf.name
            str = "The theme is not opened, please finish" .. name
        elseif cur_lv < lv_limit then
            --等级限制
            local lv_str = GetLevelShow(lv_limit)
            str = "this theme first" .. lv_str .. "Unlocks at L.X"
        elseif cur_opdays < opday_limit then
            --开服天数
            str = "This theme will unlock" .. opday_limit .. "on day X after the server launches"
        end
        Notify.ShowText(str)
        return
    end
    if id then
        self.model.isSetDefault = true
        self.model.jump_theme = id
    end
    if table.isempty(self.model.infoList.tasks) then
        self:RequestBookInfo()
    end
    self.model.isSetDefault = true
    lua_panelMgr:GetPanelOrCreate(BookPanel):Open()
end

function BookController:HandleBookInfo()
    local data = self:ReadMsg("m_target_info_toc")
    --dump(data, "<color=#6ce19b>HandleBookInfo   HandleBookInfo  HandleBookInfo  HandleBookInfo</color>")
    self.model:AddTargetInfo(data)
    self:CheckRD()
    self.model:Brocast(BookEvent.UpdateBookPanel)
    if self.model.isGettingReward then
        Notify.ShowText("Claimed")
    end
    local is_show = self:IsCanShowIcon()
    GlobalEvent:Brocast(MainEvent.ChangeRightIcon, 'book', is_show)
end

function BookController:RequestGetTaskReward(id)
    local pb = self:GetPbObject("m_target_get_reward_tos")
    pb.id = id
    self:WriteMsg(proto.TARGET_GET_REWARD, pb)
end

function BookController:RequestGetThemeSkill(id)
    local pb = self:GetPbObject("m_target_get_skill_tos")
    pb.id = id
    self:WriteMsg(proto.TARGET_GET_SKILL, pb)
end

function BookController:HandleSceneChange(sceneId, isIgnore)
    if not self.model.coord then
        return
    end
    if self.model.isOpenBookPanel then
        if not isIgnore then
            local config = Config.db_scene[sceneId]
            if not config then
                return
            end
        end
        local call_back = function()
            if not AutoFightManager:GetInstance():GetAutoFightState() then
                GlobalEvent:Brocast(FightEvent.AutoFight)
            end
        end
        TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
        OperationManager:GetInstance():TryMoveToPosition(nil, nil, { x = self.model.coord[1], y = self.model.coord[2] }, call_back);
        self.model:Brocast(BookEvent.CloseBookPanel)
    end
end

function BookController:CheckRD()
    self.model:CheckRD()
    local is_show = self.model:IsShowMainRD()
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "book", is_show)
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 19, is_show)
end

function BookController:IsCanShowIcon()
    if not OpenTipModel.GetInstance():IsOpenSystem(260, 1) then
        return false
    end
    return self.model:IsShowMainIcon()
end
