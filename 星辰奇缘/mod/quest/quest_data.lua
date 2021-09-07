QuestData = QuestData or BaseClass()

function QuestData:__init()
    -- 协议数据
    self.id = 0 -- 任务id
    self.finish = 0 -- 是否已完成, 0=可接未接取,1=已接未完成，2=已接已完成，3=完成已提交
    self.progress_ser = nil -- 任务进度{id,finish,target,target_val,value,ext_data={key,value}}

    -- 配置数据
    self.name = nil -- 任务名称
    self.lev = nil -- 任务等级
    self.type = nil -- 任务类型
    self.sec_type = nil -- 任务小类型
    self.is_leader_quest = nil -- 是否队长任务
    self.can_giveup = nil -- 是否能放弃
    self.auto_accept = nil -- 是自动接取
    self.is_frame = nil -- 是否弹面板
    self.auto_next = nil -- 是否继续任务
    self.commit_type = nil -- 提交任务方式
    self.npc_accept_battle = nil -- 接受任务NPC战场
    self.npc_accept_id = nil -- 接受任务NPC_ID
    self.npc_accept = nil --接受任务NPC基础ID
    self.npc_commit_battle = nil --提交任务NPC战场
    self.npc_commit_id = nil --提交任务NPC_ID
    self.npc_commit = nil --提交任务NPC基础ID
    self.rewards_accept = nil --接受任务奖励
    self.progress = nil --任务要求
    self.trace_msg = nil --额外描述
    self.rewards_commit = nil --任务奖励
    self.commit_loss = nil --提交任务扣除
    self.talk_accpet = nil --接受对话
    self.talk_process = nil --进行中对话
    self.talk_commit = nil --提交对话
    self.follow = nil --是否追踪
    self.accept_time = 0 --接取时间

    -- 是否显示提交按钮
    self.is_button_commit = 1
    -- 是否显示接受按钮
    self.is_button_accept = 1
end

-- 设置协议数据
function QuestData:SetProto(proto)
    self.id = proto.id
    if proto.finish ~= nil then
        self.finish = proto.finish == 0 and 1 or 2
    end
    if proto.progress ~= nil then
        self.progress_ser = proto.progress
    end
    if proto.accept_time ~= nil then
        self.accept_time = proto.accept_time
    end
end

-- 设置配置数据
function QuestData:SetBase(base)
    for k,v in pairs(base) do
        self[k] = v
    end
end