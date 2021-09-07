-- ----------------------------------------------------------
-- 逻辑模块 - 藏宝图
-- ----------------------------------------------------------
TreasuremapManager = TreasuremapManager or BaseClass(BaseManager)

function TreasuremapManager:__init()
    if TreasuremapManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	TreasuremapManager.Instance = self

    self.model = TreasuremapModel.New()

    self:InitHandler()
end

function TreasuremapManager:__delete()
end

function TreasuremapManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(13600, self.On13600)
    self:AddNetHandler(13601, self.On13601)
    self:AddNetHandler(13602, self.On13602)
    self:AddNetHandler(13603, self.On13603)
    self:AddNetHandler(13604, self.On13604)
end

-------------------------------------------
-------------------------------------------
------------- 协议处理 -----------------
-------------------------------------------
-------------------------------------------

function TreasuremapManager:Send13600()
    Connection.Instance:send(13600, { })
end

function TreasuremapManager:On13600(data)
    self.model:On13600(data)
end

function TreasuremapManager:Send13601()
    Connection.Instance:send(13601, { })
end

function TreasuremapManager:On13601(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TreasuremapManager:Send13602()
    Connection.Instance:send(13602, { })
end

function TreasuremapManager:On13602(data)
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TreasuremapManager:Send13603()
    Connection.Instance:send(13603, { })
end

function TreasuremapManager:On13603(data)
    if self.model.exchange_window ~= nil then
        if self.model.exchange_window.buttonscript ~= nil then
            self.model.exchange_window.buttonscript:ReleaseFrozon()
        end
    end
	NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TreasuremapManager:Send13604()
    Connection.Instance:send(13604, { })
end

function TreasuremapManager:On13604(data)
    if data.result == 1 then
        -- mod_notify.fly_slot_icon2mainui({20053}, 1)
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function TreasuremapManager:RequestInitData()
    self:Send13600()
end

