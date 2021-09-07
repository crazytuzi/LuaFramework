TruthordareModel = TruthordareModel or BaseClass(BaseModel)

function TruthordareModel:__init()
    self.window = nil
    self.editorWindow = nil
    self.ruleWindow = nil

    self.isShowPanel = true


    self.questionsKeyWorldList = {
        ["@1"] = "<color='#225ee7'>@随机一人</color>",
        ["@2"] = "<color='#225ee7'>@随机一人</color>",
        ["@3"] = "<color='#225ee7'>@随机一人</color>",
        ["@4"] = "<color='#225ee7'>@随机一人</color>",
        ["@5"] = "<color='#225ee7'>@随机一人</color>",
        ["@6"] = "<color='#225ee7'>@随机一人</color>",
        ["@7"] = "<color='#225ee7'>@随机一人</color>"
    }
end

function TruthordareModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function TruthordareModel:InitData()
    self.openState = 0
    self.state = 0

    self.time = 0
    self.now_round = 1
    self.max_round = 5
    self.pos_info = nil
    self.next_pos_info = nil
    self.vacancy = 0

    self.question_ver = nil
    self.question_info = {}

    self.min_num = 0
    self.max_num = 100
    self.boomTime = 0
    self.boomMan = nil

    self.luckyMan = nil -- 幸运儿信息

    self.rankFirstThreeList = nil
    self.rankInfo = nil
    self.selfRankData = nil
    self.hisLuckyInfo = nil
    self.isHasPraise = {false,false,false}
    self.isBeenGuide = false  --是否在规则引导界面

    self.luckyQuestionType = 0
    self.luckyQuestion = nil
    self.quest_round = 1

    self.is_pass = nil
    self.flower = 0
    self.egg = 0
    self.watch = 0
    self.flower_list = {}
    self.egg_list = {}
    self.call_list = {}
end

function TruthordareModel:OpenWindow(args)
    if self.window == nil then
        self.window = TruthordareAgendaWindow.New(self)
    end

    self.window:Open(args)
end

function TruthordareModel:CloseWindow()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function TruthordareModel:OpenEditorWindow(args)
    if self.editorWindow == nil then
        self.editorWindow = TruthordareEditorWindow.New(self)
    end

    self.editorWindow:Show(args)
end

function TruthordareModel:CloseEditorWindow()
    if self.editorWindow ~= nil then
        self.editorWindow:DeleteMe()
        self.editorWindow = nil
    end
end

function TruthordareModel:OpenVoteDetailsWindow(args)
    if self.voteDetailsWindow == nil then
        self.voteDetailsWindow = TruthordareVoteDetailsPanel.New(self)
    end

    self.voteDetailsWindow:Show(args)
end

function TruthordareModel:CloseVoteDetailsWindow()
    if self.voteDetailsWindow ~= nil then
        self.voteDetailsWindow:DeleteMe()
        self.voteDetailsWindow = nil
    end
end

function TruthordareModel:OpenSelect()
	if self.selectPanel == nil then
		self.selectPanel = TruthordareLuckydorPanel.New(self, self.window)
	end
	self.selectPanel:Show()
end

function TruthordareModel:CloseSelect()
	if self.selectPanel ~= nil then
		self.selectPanel:DeleteMe()
		self.selectPanel = nil
    end
end
function TruthordareModel:OpenRuleWindow(args)
    if self.ruleWindow == nil then
        self.ruleWindow = TruthordareRulePanel.New(self)
    end

    self.ruleWindow:Show(args)
end

function TruthordareModel:CloseRuleWindow()
    if self.ruleWindow ~= nil then
        self.ruleWindow:DeleteMe()
        self.ruleWindow = nil
    end
end

function TruthordareModel:UpdateTopPanelMsg()
    if self.openState == 0 then
        ChatManager.Instance.model:DeleteTopPanelMsg(1)
    else
        local data = {}
        data.id = 1 -- 真心话大冒险id
        data.panelType = 1 -- 真心话大冒险类型
        data.channelList = { MsgEumn.ChatChannel.Guild }
        data.height = -120
        if self.state == 1 then
            
        else

        end
        ChatManager.Instance.model:AppendTopPanelMsg(data)
    end
    EventMgr.Instance:Fire(event_name.chat_main_top_update)
end

function TruthordareModel:GetPanelType()
    if self.state == 0 then
        return 0
    elseif self.state == 1 or self.state == 2 then
        return 1
    elseif self.state == 3 then
        return 2
    elseif self.state == 4 then
        return 3
    elseif self.state == 5 or self.state == 6 or self.state == 7 then
        return 4
    elseif self.state == 8 or self.state == 9 then
        return 5
    end
    return 0
end

function TruthordareModel:GetQuestionList(type)
    local list = {}
    for i,v in ipairs(self.question_info) do
        if v.type == type then
            table.insert(list, v)
        end
    end
    local function sortfun(a,b)
        return a.id < b.id
    end
    table.sort(list, sortfun)
    return list
end

function TruthordareModel:GetInRoom()
    local roleData = RoleManager.Instance.RoleData
    if self.next_pos_info == nil then
        return false
    end
    for k,v in pairs(self.next_pos_info) do
        if v.rid == roleData.id and v.platform == roleData.platform and v.zone_id == roleData.zone_id then
            return true
        end
    end
    return false
end

function TruthordareModel:UpdateExitRoomButton(text, image1, image2)
    if self:GetInRoom() then
        text.text = TI18N("<color='#d3aa43'>退出</color>")
        if image1 ~= nil then image1:SetActive(false) end
        if image2 ~= nil then image2:SetActive(false) end
    else
        if self.vacancy > 0 and self.now_round ~= self.max_round then
            text.text = TI18N("<color='#29aad1'>加入</color>")
            if image1 ~= nil then image1:SetActive(false) end
            if image2 ~= nil then image2:SetActive(true) end
        else
            text.text = TI18N("<color='#79a716'>围观</color>")
            if image1 ~= nil then image1:SetActive(true) end
            if image2 ~= nil then image2:SetActive(false) end
        end
    end
end

function TruthordareModel:ExitRoom()
    if self:GetInRoom() then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal      
        data.content = TI18N("是否要<color='#ffff00'>退出</color>真心话大冒险？\n（大家都在等你一起玩哦）")

        data.sureLabel = TI18N("继续玩")
        data.cancelLabel = TI18N("确认退出")
        data.cancelCallback = function() TruthordareManager.Instance:Send19511() end
        NoticeManager.Instance:ConfirmTips(data)
    else
        local mySex = RoleManager.Instance.RoleData.sex
        local loss = DataGuildTruthDare.data_info[1].loss
        if self.vacancy > 0 and self.now_round ~= self.max_round then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal        
            if mySex == 0 then
                data.content = string.format(TI18N("消耗报名费{assets_1, %s, %s}参与（<color='#ffff00'>妹子减半哦~</color>），活动结束时，将作为公会红包发放"), loss[1][1], loss[1][2])
            else
                data.content = string.format(TI18N("消耗报名费{assets_1, %s, %s}参与，活动结束时，将作为公会红包发放"), loss[1][1], loss[1][2])
            end
            data.sureLabel = TI18N("确认")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function() TruthordareManager.Instance:Send19510(0) end
            NoticeManager.Instance:ConfirmTips(data)
        else

        end
    end
end

function TruthordareModel:GetRoomQueue()
    if self.boomMan == nil or self.pos_info == nil then
        return {}
    end
    local index = 0
    local list = {}
    for k,v in pairs(self.pos_info) do
        table.insert(list, v)
        if self.boomMan.id == v.id and self.boomMan.platform == v.platform and self.boomMan.zone_id == v.zone_id then
            index = #list
        end
    end
    local queue = {}
    for i = index-2, index+3 do
        if list[i] ~= nil then
            table.insert(queue, list[i])
        elseif i < 1 then
            table.insert(queue, list[#list + i])
        elseif i > #list then
            table.insert(queue, list[i - #list])
        end
    end
    return queue
end

function TruthordareModel:IsBoomMan()
    local roleData = RoleManager.Instance.RoleData
    if self.boomMan ~= nil and self.boomMan.rid == roleData.id and self.boomMan.platform == roleData.platform and self.boomMan.zone_id == roleData.zone_id then
        return true
    end
    return false
end

function TruthordareModel:IsLuckyMan()
    local roleData = RoleManager.Instance.RoleData
    if self.luckyMan ~= nil and self.luckyMan.rid == roleData.id and self.luckyMan.platform == roleData.platform and self.luckyMan.zone_id == roleData.zone_id then
        return true
    end
    return false
end

function TruthordareModel:CanVote()
    local roleData = RoleManager.Instance.RoleData
    for i, v in ipairs(self.flower_list) do
        if v.id == roleData.id and v.platform == roleData.platform and v.zone_id == roleData.zone_id then
            return false
        end
    end
    for i, v in ipairs(self.egg_list) do
        if v.id == roleData.id and v.platform == roleData.platform and v.zone_id == roleData.zone_id then
            return false
        end
    end
    for i, v in ipairs(self.call_list) do
        if v.id == roleData.id and v.platform == roleData.platform and v.zone_id == roleData.zone_id then
            return false
        end
    end
    return true
end

function TruthordareModel:GetQuestionsText(questionsText)
    for k, v in pairs(self.questionsKeyWorldList) do
        questionsText = string.gsub(questionsText, k, v)
    end
    return questionsText
end