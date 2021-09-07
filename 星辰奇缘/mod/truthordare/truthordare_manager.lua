 ----------------------------------------------------------
-- 真心话大冒险
-- ----------------------------------------------------------
TruthordareManager = TruthordareManager or BaseClass(BaseManager)

function TruthordareManager:__init()
    if TruthordareManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	TruthordareManager.Instance = self

    self.model = TruthordareModel.New()

    -- 护符熔炼次数
    self.moonTimes = 0
    self.sunTimes = 0

    self:InitHandler()

    self.OnUpdateState = EventLib.New()
    self.OnUpdate = EventLib.New()
    self.OnBoomManChooseNumUpdate = EventLib.New()
    self.OnQuestionInfoUpdate = EventLib.New()
    --self.OnluckydorSelectUpdate = EventLib.New()  --幸运儿界面选择回调
    self.SingleEndUpdate = EventLib.New()
    self.OnluckydorUpdate = EventLib.New()
end

function TruthordareManager:__delete()
    
end

function TruthordareManager:RequestInitData()
    self.model:InitData()

    self:Send19508()
    self:Send19509()
end

function TruthordareManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(19508, self.On19508)
    self:AddNetHandler(19509, self.On19509)
    self:AddNetHandler(19510, self.On19510)
    self:AddNetHandler(19511, self.On19511)
    self:AddNetHandler(19512, self.On19512)
    self:AddNetHandler(19513, self.On19513)
    self:AddNetHandler(19514, self.On19514)
    self:AddNetHandler(19515, self.On19515)
    self:AddNetHandler(19516, self.On19516)
    self:AddNetHandler(19517, self.On19517)
    self:AddNetHandler(19518, self.On19518)
    self:AddNetHandler(19519, self.On19519)
    self:AddNetHandler(19520, self.On19520)
    self:AddNetHandler(19521, self.On19521)
    self:AddNetHandler(19522, self.On19522)
    self:AddNetHandler(19523, self.On19523)
    self:AddNetHandler(19524, self.On19524)
    self:AddNetHandler(19525, self.On19525)
    self:AddNetHandler(19526, self.On19526)
    self:AddNetHandler(19527, self.On19527)
    self:AddNetHandler(19528, self.On19528)
    self:AddNetHandler(19529, self.On19529)
    self:AddNetHandler(19530, self.On19530)
    self:AddNetHandler(19531, self.On19531)
end

-------------------------------------------
-------------------------------------------
------------- 协议处理 -----------------
-------------------------------------------
-------------------------------------------
function TruthordareManager:Send19508()
    Connection.Instance:send(19508, { })
end

function TruthordareManager:On19508(data)
    self.model.openState = data.result

    if self.model.openState == 0 then
        self.model:InitData()
    end
    self.model:UpdateTopPanelMsg()
    self.OnUpdateState:Fire()
end

function TruthordareManager:Send19509()
    Connection.Instance:send(19509, { })
end

function TruthordareManager:On19509(data)
    -- print("真心话当前阶段"..data.state)
    self.model.state = data.state
    self.model.time = data.time
    if not self.model.isBeenGuide then
        self.model:UpdateTopPanelMsg()
    end
    
    self.OnUpdateState:Fire()

    if self.model.state == 0 then
        -- print("真心话大冒险活动准备时间戳: " .. self.model.time)
    end

    if self.model.next_pos_info == nil then
        self:Send19515()
    end

    if self.model.state == 4 or self.model.state == 5 or self.model.state == 6 or self.model.state == 7 then
        if self.model.luckyMan == nil then
            self:Send19521()
        end
    else
        self.model.luckyMan = nil
    end

    if self.model.state == 5 or self.model.state == 6 or self.model.state == 7 then
        if self.model.luckyQuestion == nil then
            self:Send19520()
        end
    else
        self.model.luckyQuestionType = 0
        self.model.luckyQuestion = nil
    end

    if self.model.state == 6 or self.model.state == 7 then
        self:Send19524()
    end
end

function TruthordareManager:Send19510(pos)
    Connection.Instance:send(19510, { pos = pos })
end

function TruthordareManager:On19510(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TruthordareManager:Send19511()
    Connection.Instance:send(19511, { })
end

function TruthordareManager:On19511(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TruthordareManager:Send19512(pos)
    Connection.Instance:send(19512, { pos = pos })
end

function TruthordareManager:On19512(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TruthordareManager:Send19513(type, question)
    Connection.Instance:send(19513, { type = type, question = question })
end

function TruthordareManager:On19513(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TruthordareManager:Send19514(type, id)
    Connection.Instance:send(19514, { type = type, id = id })
end

function TruthordareManager:On19514(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TruthordareManager:Send19515()
    Connection.Instance:send(19515, { })
end

function TruthordareManager:On19515(data)
    self.model.vacancy = data.vacancy
    -- self.model.begin_time = data.begin_time
    self.model.now_round = data.now_round
    self.model.max_round = data.max_round
    self.model.pos_info = {}
    for i,v in ipairs(data.pos_info) do
        self.model.pos_info[v.pos] = v
    end
    self.model.next_pos_info = {}
    for i,v in ipairs(data.next_pos_info) do
        self.model.next_pos_info[v.pos] = v
    end

    if data.now_round == 1 then
        self.model.isHasPraise = {false,false,false}
    end
    self.OnUpdate:Fire()
end

function TruthordareManager:Send19516(type, id, flag)
    Connection.Instance:send(19516, { type = type, id = id, flag = flag })
end

function TruthordareManager:On19516(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TruthordareManager:Send19517()
    Connection.Instance:send(19517, { })
end

function TruthordareManager:On19517(data)
    self.model.min_num = data.min_num
    self.model.max_num = data.max_num
    self.model.boomTime = data.end_time
    self.model.boomMan = data
    self.model.boomMan.id = data.rid
    self.OnUpdate:Fire()

    if TruthordareManager.Instance.model:IsBoomMan() then
        if not TruthordareManager.Instance.model.isShowPanel then
            self.model:UpdateTopPanelMsg()
        end
        if ChatManager.Instance.model.chatWindow == nil or BaseUtils.isnull(ChatManager.Instance.model.chatWindow.gameObject)
            or (ChatManager.Instance.model.chatWindow ~= nil and not BaseUtils.isnull(ChatManager.Instance.model.chatWindow.gameObject) and ChatManager.Instance.model.chatWindow.baseRect.anchoredPosition == Vector2(0, -2000)) then
            ChatManager.Instance.model:ShowChatWindow({MsgEumn.ChatChannel.Guild})
        end
    end
end

function TruthordareManager:Send19518(num)
    Connection.Instance:send(19518, { num = num })
end

function TruthordareManager:On19518(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TruthordareManager:Send19519(type)
    Connection.Instance:send(19519, { type = type })
end

function TruthordareManager:On19519(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TruthordareManager:Send19520()
    Connection.Instance:send(19520, { })
end

function TruthordareManager:On19520(data)
    self.model.luckyQuestionType = data.type
    self.model.luckyQuestionRoleName = data.role_name
    self.model.luckyQuestion = data.question
    self.model.quest_round = data.quest_round
    self.OnUpdate:Fire()
end

function TruthordareManager:Send19521()
    Connection.Instance:send(19521, { })
end

function TruthordareManager:On19521(data)
    self.model.luckyMan = data
    self.model.luckyMan.id = data.rid
    self.OnUpdate:Fire()
end

function TruthordareManager:Send19522()
    Connection.Instance:send(19522, { })
end

function TruthordareManager:On19522(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TruthordareManager:Send19523(type)
    Connection.Instance:send(19523, { type = type })
end

function TruthordareManager:On19523(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TruthordareManager:Send19524()
    Connection.Instance:send(19524, { })
end

function TruthordareManager:On19524(data)
    self.model.is_pass = data.is_pass
    self.model.flower = data.flower
    self.model.egg = data.egg
    self.model.watch = data.watch
    self.model.flower_list = data.flower_list
    self.model.egg_list = data.egg_list
    self.model.call_list = data.call_list
    self.OnUpdate:Fire()
end

function TruthordareManager:Send19525()
    Connection.Instance:send(19525, { })
end

function TruthordareManager:On19525(data)
    local mark = false 
    if self.model.question_ver ~= data.ver then
        mark = true
    end
    self.model.question_ver = data.ver
    self.model.question_info = data.question_info

    self.OnQuestionInfoUpdate:Fire(mark)
end

function TruthordareManager:Send19526()
    print("Send19526")
    Connection.Instance:send(19526, { })
end

function TruthordareManager:On19526(data)
    --BaseUtils.dump(data,"on17926结算")
    if data ~= nil and next(data) ~= nil then
        self.model.rankFirstThreeList = data.first
        self.model.rankInfo = data.rank_info
        self.model.selfRankData = data.self_rank
    end
    self.SingleEndUpdate:Fire()
end

function TruthordareManager:Send19527()
    Connection.Instance:send(19527, { })
end

function TruthordareManager:On19527(data)
    if data ~= nil and next(data) ~= nil then
        self.model.hisLuckyInfo = data.his_lucky_info
    end
    self.OnluckydorUpdate:Fire()
end

function TruthordareManager:Send19528()
    Connection.Instance:send(19528, { })
end

function TruthordareManager:On19528(data)
    if self.model.boomMan ~= nil and self.model.boomMan.rid == data.rid and self.model.boomMan.platform == data.platform and self.model.boomMan.zone_id == data.zone_id then
        if data.num == data.min_num - 1 then
            self.OnBoomManChooseNumUpdate:Fire(data.num, 1, data.min_num, data.max_num)
        else
            self.OnBoomManChooseNumUpdate:Fire(data.num, 2, data.min_num, data.max_num)
        end
    end
end

function TruthordareManager:Send19529(type)
    Connection.Instance:send(19529, { type = type })
end

function TruthordareManager:On19529(data)
    if data.result == 1 then
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TruthordareManager:Send19530()
    Connection.Instance:send(19530, { })
end

function TruthordareManager:On19530(data)
end

function TruthordareManager:Send19531(flag)
    Connection.Instance:send(19531, { flag = flag })
end

function TruthordareManager:On19531(data)
    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.content = string.format(TI18N("<color='#25EEF6'>%s</color>发起了<color='#ffff00'>跳过你的回合</color>的投票，快醒醒完成任务啦{face_1,7}\n（倒计时结束将<color='#ffff00'>退出活动</color>）"), data.role_name)
    confirmData.sureLabel = TI18N("我在这！")
    confirmData.sureCallback = function() self:Send19531(0) end
    confirmData.cancelLabel = TI18N("确认退出")
    confirmData.cancelCallback = function() self:Send19531(1) end
    confirmData.cancelSecond = data.timeout

    NoticeManager.Instance:ConfirmTips(confirmData)
end

