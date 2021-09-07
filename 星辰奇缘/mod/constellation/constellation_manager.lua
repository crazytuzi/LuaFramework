-- ------------------------------
-- 星座挑战
-- hosr
-- ------------------------------

ConstellationManager = ConstellationManager or BaseClass(BaseManager)

function ConstellationManager:__init()
    if ConstellationManager.Instance then
        return
    end

    ConstellationManager.Instance = self

    -- 活动状态
    self.status = ConstellationEumn.Status.None
    -- 剩余时间
    self.remainTime = 0
    -- 当前已通关星级
    self.currentLev = 0
    -- 击杀过的星座id列表
    self.killList = {}
    -- 当前星座数据
    self.currentData = ConstellationData.New()
    -- 任务追踪展示
    self.questShow = nil
    self.mainuiload = false
    -- 是对话框请求的查询
    self.isDialog = false
    self.model = ConstellationModel.New()
    self.maintracelistener = function() self:OnMainTraceLoaded() end
    EventMgr.Instance:AddListener(event_name.trace_quest_loaded, self.maintracelistener)

    self:InitHandler()
end

function ConstellationManager:InitHandler()
    self:AddNetHandler(15200, self.On15200)
    self:AddNetHandler(15201, self.On15201)
    self:AddNetHandler(15202, self.On15202)
    self:AddNetHandler(15203, self.On15203)
    self:AddNetHandler(15204, self.On15204)
    self:AddNetHandler(15205, self.On15205)
    self:AddNetHandler(15206, self.On15206)
    self:AddNetHandler(15207, self.On15207)
    self:AddNetHandler(15208, self.On15208)
end

function ConstellationManager:RequestInitData()
    self.status = ConstellationEumn.Status.None
    self.remainTime = 0
    self.currentLev = 0
    self.killList = {}
    self.isDialog = false

    self:Send15200()
    self:Send15201()
    self:Send15205()
end

-- 活动状态
function ConstellationManager:Send15200()
    self:Send(15200, {})
end

function ConstellationManager:Send15206(RoleID,Platform,ZoneID)
    local data = {rid =RoleID, platform = Platform, zone_id = ZoneID};
    self:Send(15206,data);
end

function ConstellationManager:On15206(data)
    if data.flag == 1 then
        local ProfileData = {};
        ProfileData.RoldID = data.id;
        ProfileData.Platform = data.platform;
        ProfileData.ZoneID = data.zone_id;
        ProfileData.Name = data.name;
        ProfileData.CanKill = data.lev;
        ProfileData.TitleLev = data.title_lev;
        ProfileData.Classes = data.classes;
        ProfileData.Sex = data.sex;
        ProfileData.MaxKill = data.max_kill;
        ProfileData.IdNow = data.id_now;
        EventMgr.Instance:Fire(event_name.constellation_profile_update,ProfileData);
    else
         NoticeManager.Instance:FloatTipsByString(data.msg)
         self.model:CloseProfileWin(false)
    end
end

function ConstellationManager:On15200(dat)
    self.status = dat.status
    self.remainTime = dat.timeout
    if self.status == ConstellationEumn.Status.None then
        AgendaManager.Instance:SetCurrLimitID(2013, false)
    else
        AgendaManager.Instance:SetCurrLimitID(2013, true)
    end
end

-- 查看当前状态
function ConstellationManager:Send15201()
    self:Send(15201, {})
end

function ConstellationManager:On15201(dat)
    if self.currentData ~= nil and self.currentData.summoned ~= nil then
        self:RemoveUnit(self.currentData.summoned.base_id)
    end

    self.currentData:Update(dat)

    if self.currentData ~= nil and self.currentData.summoned ~= nil then
        self:CreateUnit(self.currentData.summoned)
    end

    if self.currentLev ~= 0 and dat.lev > self.currentLev and dat.lev < 12 then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Sure
        local nextLev = math.min(dat.lev + 1, 12)
        data.content = string.format(TI18N("挑战成功，获得挑战<color='#ffff00'>%s星</color>资格！"), nextLev)
        data.sureLabel = TI18N("确定")
        NoticeManager.Instance:ConfirmTips(data)
    end
    self.currentLev = dat.lev
    self.killList = {}
    self:QuestShow()
end

function ConstellationManager:Send15202(isDialog)
    self.isDialog = isDialog
    self:Send(15202, {})
end

-- 星座怪信息
function ConstellationManager:On15202(data)
    AgendaManager.Instance.model:SetConstellationArea(data)
    MainUIManager.Instance:SetConstellationArea(data)

    if self.isDialog then
        self.isDialog = false
        local content = TI18N("当前星座降临区域：<color='#00ff00'>无</color>，请稍后再来挑战~")
        local maps = ""

        local list = {}
        if #data.constellation_unit > 0 then
            for i,v in ipairs(data.constellation_unit) do
                list[v.map_id] = 1
            end

            for map_id,_ in pairs(list) do
                if maps == "" then
                    maps = string.format("<color='#00ff00'>%s</color>", DataMap.data_list[map_id].name)
                else
                    maps = maps .. "，" .. string.format("<color='#00ff00'>%s</color>", DataMap.data_list[map_id].name)
                end
            end
            content = string.format(TI18N("当前星座降临区域：%s，快去进行挑战吧！"), maps)
        end

        local msg = string.format("%s\n9点~24点逢半点在<color='#ffff00'>圣心城、月痕海岸、飞瀑村、精灵之森、极北之域</color>中的<color='#ffff00'>随机2个</color>会出现十二星座，可以免费挑战他们，并获得丰厚奖励哦", content)
        NoticeManager.Instance:On9910({base_id = 20087, msg = msg})
    end
end

-- 召唤星座
function ConstellationManager:Send15203()
    self:Send(15203, {})
end

function ConstellationManager:On15203(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.flag == 1 then
        local notice = NoticeConfirmData.New()
        notice.type = ConfirmData.Style.Sure
        notice.content = data.msg
        NoticeManager.Instance:ConfirmTips(notice)

        local msgData = MessageParser.GetMsgData(data.msg)
        local chat = ChatData.New()
        chat.channel = MsgEumn.ChatChannel.System
        chat.prefix = MsgEumn.ChatChannel.System
        chat.showType = MsgEumn.ChatShowType.System
        msgData.showString = string.format("<color='%s'>%s</color>", MsgEumn.ChannelColor[MsgEumn.ChatChannel.System], msgData.showString)
        chat.msgData = msgData
        ChatManager.Instance.model:ShowMsg(chat)
    end
end

-- 挑战召唤星座
function ConstellationManager:Send15204()
    self:Send(15204, {})
end

function ConstellationManager:On15204(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

-- 星座分布信息
function ConstellationManager:Send15205()
    self:Send(15205, {})
end

function ConstellationManager:On15205(data)
    UnitStateManager.Instance:Update(UnitStateEumn.Type.Star, data)
end

-- 星座首杀
function ConstellationManager:Send15207(battle_id, id)
    print("ConstellationManager:Send15207(battle_id, id)")
    self:Send(15207, { battle_id = battle_id, id = id })
end

function ConstellationManager:On15207(data)
    BaseUtils.dump(data, "function ConstellationManager:On15207(data)")
    self.model.firstKillData = data
    self.model.star13Data = nil

    if data.lev < 13 then
        self:OpenConstellationDialog()
    else
        self:Send15208(self.constellationNpcData.battleid, self.constellationNpcData.id)
    end
end

-- 星座13星
function ConstellationManager:Send15208(battle_id, id)
    self:Send(15208, { battle_id = battle_id, id = id })
    print("ConstellationManager:Send15208(battle_id, id)".. battle_id ..", "..id)
end

function ConstellationManager:On15208(data)
    BaseUtils.dump(data, "function ConstellationManager:On15208(data)")
    self.model.star13Data = data

    self:OpenConstellationDialog()
end

function ConstellationManager:OnMainTraceLoaded()
    EventMgr.Instance:RemoveListener(event_name.trace_quest_loaded, self.maintracelistener)
    self.mainuiload = true
    self:QuestShow()
end

function ConstellationManager:QuestShow()
    if not self.mainuiload then
        return
    end

    if self.questShow ~= nil then
        MainUIManager.Instance.mainuitracepanel.traceQuest:DeleteCustom(self.questShow.customId)
        self.questShow = nil
    end

    if self.currentData.summoned ~= nil then
        if self.questShow == nil then
            self.questShow = MainUIManager.Instance.mainuitracepanel.traceQuest:AddCustom()
        end
        self.questShow.title = TI18N("<color='#61e261'>[挑战]星座召唤</color>")
        self.questShow.Desc = string.format("星座守护降临于<color='#ffff00'>%s</color>", DataMap.data_list[self.currentData.summoned.map].name)
        self.questShow.callback = function() self:FindUnit() end
        self.questShow.countDownDesc = TI18N("剩余时间:")
        self.questShow.countDown = self.currentData.summoned.time

        MainUIManager.Instance.mainuitracepanel.traceQuest:UpdateCustom(self.questShow)
    end
end

function ConstellationManager:CreateUnit(data)
    local baseData = DataUnit.data_unit[data.base_id]
    local info = {
        unit_id = data.base_id,
        battle_id = 0,
        unit_base_id = data.base_id,
        x = data.x,
        y = data.y,
        mapid = data.map,
        msg = string.format("%s星%s", data.lev, tostring(baseData.name)),
    }
    DramaVirtualUnit.Instance:CreateUnit(info)
end

function ConstellationManager:RemoveUnit(unit_id)
    DramaVirtualUnit.Instance:RemoveUnit({unit_id = unit_id})
end

function ConstellationManager:FindUnit()
    local key = string.format("%s_0", self.currentData.summoned.base_id)
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    SceneManager.Instance.sceneElementsModel:Self_PathToTarget(key)
end

function ConstellationManager:GetCurrentLev()
    return math.min(self.currentLev + 1, 14)
end

function ConstellationManager:CheckProfileOpen()
    return self.currentLev > 0;
end

function ConstellationManager:GetConstellationData(npcData, type)
    self.constellationNpcData = npcData
    self.constellationNpcType = type

    -- LuaTimer.Add(1000, function() self:OpenConstellationDialog() end)
    self:Send15207(self.constellationNpcData.battleid, self.constellationNpcData.id)
end

function ConstellationManager:OpenConstellationDialog()
    local extra = {}
    BaseUtils.dump(self.constellationNpcData)
    extra.base = BaseUtils.copytab(DataUnit.data_unit[self.constellationNpcData.baseid])
    extra.base.name = self.constellationNpcData.name
    extra.base.buttons = {
        {button_id = 6,button_args = {1},button_desc = TI18N("开始挑战"),button_show = "[]"}
        ,{button_id = 52,button_args = {},button_desc = TI18N("观看战斗"),button_show = "[]"}
        ,{button_id = 22,button_args = {6,65,1,1},button_desc = TI18N("便捷组队"),button_show = "[]"}
    } 

    extra.base.plot_talk = string.format(TI18N("%s\n\n%s"), extra.base.plot_talk, self:GetConstellationDialogString())
    MainUIManager.Instance.dialogModel:Open(self.constellationNpcData, extra, true)
end

function ConstellationManager:GetConstellationDialogString()
    local string = ""

    if self.model.star13Data ~= nil and #self.model.star13Data.list ~= 0 and self.model.star13Data.list[1].id ~= 0 then
        string = TI18N("当前星座守护者：")

        local getStringWidth = function(textString)
            if MainUIManager.Instance.dialogModel.dramaTalk ~= nil and MainUIManager.Instance.dialogModel.dramaTalk.contentTxt ~= nil then
                MainUIManager.Instance.dialogModel.dramaTalk.contentTxt.text = textString
                return MainUIManager.Instance.dialogModel.dramaTalk.contentTxt.preferredWidth
            end
        end

        local targetWidth = 175
        local spaceWidth =  getStringWidth(TI18N("　"))

        local fixStringWidth = function(textString)
            local offset = targetWidth - getStringWidth(textString)
            local max_count = math.ceil(offset / spaceWidth)
            local result = {}
            for i = 0, max_count do
                local width = math.abs(offset - i * spaceWidth)
                table.insert(result, { width = width, count = i})
            end

            local best_result = nil
            for i=1, #result do
                if best_result == nil then
                    best_result = result[i]
                elseif best_result.width > result[i].width then
                    best_result = result[i]
                end
            end

            if best_result ~= nil then
                for i=1, best_result.count do
                    textString = string.format("%s　", textString)
                end
            end

            return textString
        end

        for i=1, #self.model.star13Data.list do
            local data = self.model.star13Data.list[i]
            local nameString = string.format("<color='#ffff00'>%s：</color>%s", KvData.classes_name[data.classes], data.name)
            if i == 1 then
                nameString = fixStringWidth(nameString)
                string = string.format("%s\n    %s", string, nameString)
            else
                if i % 2 == 1 then
                    nameString = fixStringWidth(nameString)
                    string = string.format("%s\n    %s", string, nameString)
                else
                    string = string.format("%s %s", string, nameString)
                end
            end
        end

        string = string.format("%s\n", string)
    end

    if self.model.firstKillData.lev >= 4 then
        if self.model.firstKillData.status == 0 then
            string = string.format(TI18N("%s<color='#ffff00'>%s第一次降临，首杀荣誉虚位以待</color>\n首杀难度： <color='#00ff00'>%s%%</color>    （难度将随挑战次数降低）\n首杀玩家： 虚位以待"), string, self.constellationNpcData.name, self.model.firstKillData.rate/10)
        else
            local killString = ""
            for i=1, #self.model.firstKillData.list do
                if i == 1 then
                    killString = self.model.firstKillData.list[i].name
                else
                    killString = string.format("%s、%s", killString, self.model.firstKillData.list[i].name)
                end
            end

            if self.model.firstKillData.mtime ~= 0 then
                local year = os.date("%Y", self.model.firstKillData.mtime)
                local month = os.date("%m", self.model.firstKillData.mtime)
                local day = os.date("%d", self.model.firstKillData.mtime)
                string = string.format(TI18N("%s首杀时间：<color='#33ff33'>%s年%s月%s日</color>\n"), string, year, month, day)
            end
            string = string.format(TI18N("%s首杀玩家：<color='#00ffff'>%s</color>"), string, killString)
        end
    end
    return string
end
