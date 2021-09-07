-- @author ###
-- @date 2018年4月28日,星期六

AnniversaryTyManager = AnniversaryTyManager or BaseClass(BaseManager)

function AnniversaryTyManager:__init()
    if AnniversaryTyManager.Instance ~= nil then
        Log.Error("不可重复实例化")
    end
    AnniversaryTyManager.Instance = self
    self.model = AnniversaryTyModel.New()

    self:InitHandler()

    self.afterGiftShow = EventLib.New()
    self.firstCheck = EventLib.New()
    self.guideCompleted = EventLib.New()
end

function AnniversaryTyManager:__delete()
end

function AnniversaryTyManager:InitHandler()
    self:AddNetHandler(11894, self.On11894)
    self:AddNetHandler(11895, self.On11895)
    self:AddNetHandler(11896, self.On11896)
end

function AnniversaryTyManager:RequestInitData()
    local campId = 0
    for i,v in pairs(DataFriendWish.data_get_camp_theme) do
        if BaseUtils.CheckCampaignTime(v.camp_id) == true then
            campId = v.camp_id
            break
        end
    end
    if campId ~= 0 then
        self:Send11894(campId)    --寄语列表
    end
end

function AnniversaryTyManager:OpenWindow(args)
    self.model:OpenWindow(args)
end

--灯笼寄语列表
function AnniversaryTyManager:Send11894(campid)
    Connection.Instance:send(11894, {camp_id = campid})
end

function AnniversaryTyManager:On11894(data)
    --print("收到11894协议")
    --BaseUtils.dump(data,"On11894")
    if data ~= nil and data.contents ~= nil and next(data.contents) ~= nil then
        self.model.LanternList = data.contents
    end
end

--打开庆典寄语面板  (领奖+记录玩家第一次进入)
function AnniversaryTyManager:Send11895()
    --print("Send11895")
    Connection.Instance:send(11895, {})
end

function AnniversaryTyManager:On11895(data)
    --print("收到11895协议")
    --BaseUtils.dump(data,"On11895")
    if data.flag == 1 then
        self.model.IsInit = false
        --self.firstCheck:Fire()
    end
end


--检测是否是第一次
function AnniversaryTyManager:Send11896()
    --print("Send11896")
    Connection.Instance:send(11896, {})
end

function AnniversaryTyManager:On11896(data)
    --print("收到11896协议")
    --BaseUtils.dump(data,"On11896")
    if data.flag == 1 then
        self.model.IsInit = false
    else
        self.model.IsInit = true
    end
    self.firstCheck:Fire()
end