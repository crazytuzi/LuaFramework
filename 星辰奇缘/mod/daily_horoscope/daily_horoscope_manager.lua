DailyHoroscopeManager = DailyHoroscopeManager or BaseClass(BaseManager)

function DailyHoroscopeManager:__init()
    if DailyHoroscopeManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    DailyHoroscopeManager.Instance = self
    self.model = DailyHoroscopeModel.New()
    self:InitHandler()

    self.cur_type = 0
end

function DailyHoroscopeManager:__delete()
    self.model:DeleteMe()
    self.model = nil
end

function DailyHoroscopeManager:InitHandler()
    self:AddNetHandler(15900,self.on15900)
    self:AddNetHandler(15901,self.on15901)
    self:AddNetHandler(15902,self.on15902)
    self:AddNetHandler(15903,self.on15903)

    -- self.on_role_change = function(data)
    --    self:request15900()
    -- end
    -- EventMgr.Instance:AddListener(event_name.role_level_change, self.on_role_change)
end

--------------------------------------协议接收逻辑
--收到 获取每日运势数据
function DailyHoroscopeManager:on15900(data)
    -- print("-------------------------------------收到15900")
    if self.model.info_data == nil then
        self.model.last_index = 1
    else
        self.model.last_index = self.model.info_data.day_best
    end
    self.model.info_data = data
    self.model:update_info()

    BibleManager.Instance.redPointDic[1][10] = self.model:CheckRedPointState()
    BibleManager.Instance.onUpdateRedPoint:Fire()
end

--收到 提升运势
function DailyHoroscopeManager:on15901(data)
    -- print("-------------------------------------收到15901")
    self.model.up_result_msg = data.msg
    if data.errc_ode == 0 then
        -- 失败
        NoticeManager.Instance:FloatTipsByString(data.msg)
    else
        --成功
        self.model:set_show_effect()
        self:request15900()
    end
end

--收到 领取运势奖励
function DailyHoroscopeManager:on15902(data)
    -- print("-------------------------------------收到15902")
    if data.errc_ode == 0 then
        -- 失败
    else
        --成功
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


--刷新运势buff
function DailyHoroscopeManager:on15903(data)
    -- print("-------------------------------------收到15903")
    if data.errc_ode == 0 then
        -- 失败
    else
        --成功
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

------------------------------------协议请求逻辑
--请求每日运势数据
function DailyHoroscopeManager:RequestInitData()
    self:request15900()
end

--请求 获取每日运势数据
function DailyHoroscopeManager:request15900()
    -- print("-------------------------------------请求15900")
    Connection.Instance:send(15900, {})
end

--请求 提升运势
function DailyHoroscopeManager:request15901()
    -- print("-------------------------------------请求15901")
    Connection.Instance:send(15901, {})
end

--请求 领取运势奖励
function DailyHoroscopeManager:request15902()
    -- print("-------------------------------------请求15902")
    Connection.Instance:send(15902, {})
end


--刷新运势buff
function DailyHoroscopeManager:request15903()
    -- print("-------------------------------------请求15903")
    Connection.Instance:send(15903, {})
end