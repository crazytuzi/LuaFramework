-- ----------------------------------------------------------
-- 逻辑模块 - 经验瓶
-- ----------------------------------------------------------
ExperienceBottleManager = ExperienceBottleManager or BaseClass(BaseManager)

function ExperienceBottleManager:__init()
    if ExperienceBottleManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

    ExperienceBottleManager.Instance = self

    self.model = ExperienceBottleModel.New()

    self:InitHandler()
end

function ExperienceBottleManager:__delete()
end

function ExperienceBottleManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(10259, self.On10259)
    self:AddNetHandler(10260, self.On10260)
end

function ExperienceBottleManager:RequestInitData()
    self.model.flag = 0
    self.model.val = 0
    self.model.target_val = 0
    self.model:ClearData()
    
    self:Send10259()
end

-------------------------------------------
-------------------------------------------
------------- 协议处理 -----------------
-------------------------------------------
-------------------------------------------

function ExperienceBottleManager:Send10259()
    --print("Send10259")
    Connection.Instance:send(10259, { })
end

function ExperienceBottleManager:On10259(data)
    --BaseUtils.dump(data, "On10259")
    self.model.flag = data.flag
    self.model.val = data.val
    self.model.target_val = data.target_val
    self.model:UpdataQuest()
end

function ExperienceBottleManager:Send10260()
    --print("Send10260")
    Connection.Instance:send(10260, { })
end

function ExperienceBottleManager:On10260(data)
    --BaseUtils.dump(data, "On10260")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end