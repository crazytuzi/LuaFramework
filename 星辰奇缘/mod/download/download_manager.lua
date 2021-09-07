-- ----------------------------------------------------------
-- 逻辑模块 - 下载
-- @ljh 2016.06.12
-- ----------------------------------------------------------
DownLoadManager = DownLoadManager or BaseClass(BaseManager)

function DownLoadManager:__init()
    if DownLoadManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	DownLoadManager.Instance = self

    self.model = DownLoadModel.New()

    self:InitHandler()
end

function DownLoadManager:__delete()
    
end

function DownLoadManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(9929, self.On9929)
    self:AddNetHandler(9930, self.On9930)
end

function DownLoadManager:Send9929()
    Connection.Instance:send(9929, { })
end

function DownLoadManager:On9929(data)
	for i, v in ipairs(data.reward_info) do
		if v.type == 1 then
			if v.result == 1 then
				self.model.hasReward = true
			else
				self.model.hasReward = false
			end
			self.model:update_icon()
		elseif v.type == 2 then
			self.model.hasReward_Type2 = v.result
			EventMgr.Instance:Fire(event_name.download_reward)
		end
	end
end

function DownLoadManager:Send9930(type)
    Connection.Instance:send(9930, { type = type })
end

function DownLoadManager:On9930(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
	if data.type == 1 then
		if data.result == 1 then
			self.model.hasReward = true
		else
			self.model.hasReward = false
		end
		self.model:update_icon()
	elseif data.type == 2 then
		self.model.hasReward_Type2 = data.result
		EventMgr.Instance:Fire(event_name.download_reward)
	end
end

-------------------------------------------
-------------------------------------------
------------- 逻辑处理 -----------------
-------------------------------------------
-------------------------------------------

function DownLoadManager:RequestInitData()
    self:Send9929()
end