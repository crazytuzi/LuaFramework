-- ----------------------------------------------------------
-- 逻辑模块 - 技能
-- ----------------------------------------------------------
ClassesChallengeManager = ClassesChallengeManager or BaseClass(BaseManager)

function ClassesChallengeManager:__init()
    if ClassesChallengeManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	ClassesChallengeManager.Instance = self

    self.model = ClassesChallengeModel.New()

    self.OnUpdateChief = EventLib.New()

    self:InitHandler()
end

function ClassesChallengeManager:__delete()
end

function ClassesChallengeManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(14800, self.On14800)
    self:AddNetHandler(14801, self.On14801)
    self:AddNetHandler(14802, self.On14802)
    self:AddNetHandler(14803, self.On14803)
    self:AddNetHandler(14804, self.On14804)
    self:AddNetHandler(14805, self.On14805)
    self:AddNetHandler(14806, self.On14806)

    self:AddNetHandler(14807, self.On14807)
    self:AddNetHandler(14808, self.On14808)

    self:AddNetHandler(10826, self.On10826)
    self:AddNetHandler(10827, self.On10827)
    self:AddNetHandler(10831, self.On10831)
    self:AddNetHandler(10832, self.On10832)
end

-------------------------------------------
-------------------------------------------
------------- 协议处理 -----------------
-------------------------------------------
-------------------------------------------

function ClassesChallengeManager:Send14800()
    Connection.Instance:send(14800, { })
end

function ClassesChallengeManager:On14800(data)
    self.model:On14800(data)
end

function ClassesChallengeManager:Send14801()
    Connection.Instance:send(14801, { })
end

function ClassesChallengeManager:On14801(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function ClassesChallengeManager:Send14802()
    Connection.Instance:send(14802, { })
end

function ClassesChallengeManager:On14802(data)
	self.model:On14802(data)
end

function ClassesChallengeManager:Send14803(battle_id, id, star)
    Connection.Instance:send(14803, { battle_id = battle_id, id = id, star = star })
end

function ClassesChallengeManager:On14803(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function ClassesChallengeManager:Send14804()
    Connection.Instance:send(14804, { })
end

function ClassesChallengeManager:On14804(data)
    self.model:On14804(data)
end

function ClassesChallengeManager:Send14805()
    Connection.Instance:send(14805, { })
end

function ClassesChallengeManager:On14805(data)
    self.model:On14805(data)
end

function ClassesChallengeManager:Send14807()
  -- print("发送14807")
    Connection.Instance:send(14807, { })
end

function ClassesChallengeManager:On14807(data)
    CampaignManager.Instance.labourModel:On14807(data)
end

function ClassesChallengeManager:Send14806()
  -- print("发送14806")
    Connection.Instance:send(14806, { })
end

function ClassesChallengeManager:On14806(data)
    CampaignManager.Instance.labourModel:On14806(data)
end

function ClassesChallengeManager:Send14808()
  -- print("发送14808")
    Connection.Instance:send(14808, { })
end

function ClassesChallengeManager:On14808(data)
    CampaignManager.Instance.labourModel:On14808(data)
end

function ClassesChallengeManager:Send10826(id)
    Connection.Instance:send(10826, { id = id })
end

function ClassesChallengeManager:On10826(data)
    if data.err_code == 0 then
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end

function ClassesChallengeManager:On10827(data)
    if data.result == 1 then
        data.isChief = true
        GloryManager.Instance.model:OpenConfirm({data})
    end
end

function ClassesChallengeManager:Send10831()
    --print("发送10831")
    Connection.Instance:send(10831, {})
end

function ClassesChallengeManager:On10831(data)
     --BaseUtils.dump(data,"首席信息")
     self.chiefData = data
end

function ClassesChallengeManager:Send10832()
    --print("发送10832")
    Connection.Instance:send(10832, { })
end

function ClassesChallengeManager:On10832(data)
     BaseUtils.dump(data,"已挑战首席")
     self.chiefPassData = data
     self.OnUpdateChief:Fire()
end
-------------------------------------------
-------------------------------------------
------------- 逻辑处理 -----------------
-------------------------------------------
-------------------------------------------

function ClassesChallengeManager:RequestInitData()
    self.model:Clear()
    CampaignManager.Instance.labourModel:Clear()

    self:Send14800()
    self:Send14802()
    self:Send10831()
end

function ClassesChallengeManager:OpenChiefChallengeWindow(args)
    self.model:OpenChiefChallengeWindow(args)
end

function ClassesChallengeManager:CloseChiefChallengeWindow()
    self.model:CloseChiefChallengeWindow()
end