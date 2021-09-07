NationalSecondManager = NationalSecondManager or BaseClass(BaseManager)

function NationalSecondManager:__init()
    if NationalSecondManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end

    NationalSecondManager.Instance = self

    self:InitHandler()
    self.mainModel = NationalSecondModel.New()
    self.OnUpdateFlowerData = EventLib.New()
    self.OnUpdateFlowerBegin = EventLib.New()
    self.OnUpdateFlowerEnd = EventLib.New()
    self.OnUpdateBoxData = EventLib.New()
    self.OnUpdateGetBox = EventLib.New()
    self.OnUpdateGetOtherBox = EventLib.New()
    self.OnUpdateFlowerRed = EventLib.New()
    self.OnUpdateFlowerFriend = EventLib.New()

    self.flowerAcceptData = nil
    self.flowerGiveData = {}
    self.boxData = nil
end


function NationalSecondManager:__delete()
    if self.mainModel ~= nil then
        self.mainModel:DeleteMe()
        self.mainModel = nil
    end
end

function NationalSecondManager:RequestInitData()
    self:Send17890()
end
function NationalSecondManager:InitHandler()
    self:AddNetHandler(17890, self.On17890)
    self:AddNetHandler(17891, self.On17891)
    self:AddNetHandler(17892, self.On17892)
    self:AddNetHandler(17893, self.On17893)
    self:AddNetHandler(17894, self.On17894)
    self:AddNetHandler(17895, self.On17895)
    self:AddNetHandler(17896, self.On17896)
    self:AddNetHandler(17897, self.On17897)
    self:AddNetHandler(17898, self.On17898)
end

function NationalSecondManager:Send17890()

    self:Send(17890, {})
end

function NationalSecondManager:On17890(data)

    self.flowerAcceptData = data
    self:InitFlowerData()
    self.OnUpdateFlowerData:Fire()
    self.OnUpdateFlowerRed:Fire()
    self.OnUpdateFlowerFriend:Fire()
end

function NationalSecondManager:InitFlowerData()
        local min = 1
        if self.flowerAcceptData.final_reward_state == 0 then
            min = 0
        end
        self.flowerGiveData = {}
        self.flowerGiveFriendData = {}
     table.sort(self.flowerAcceptData.flowers_info,function(a,b)
               if a.index ~= b.index then
                    return a.index < b.index
                else
                    return false
                end
            end)
    for i,v in ipairs(self.flowerAcceptData.flowers_info) do
        if v.num > 0 then

            if v.num > min then
                self.flowerGiveFriendData[#self.flowerGiveFriendData + 1] = {}
                for k2,v2 in pairs(v) do
                    if self.flowerAcceptData.final_reward_state == 1 then
                        self.flowerGiveFriendData[#self.flowerGiveFriendData].num = v.num - 1
                    elseif self.flowerAcceptData.final_reward_state == 0 then
                        self.flowerGiveFriendData[#self.flowerGiveFriendData].num = v.num
                    end
                    self.flowerGiveFriendData[#self.flowerGiveFriendData].id = v.id
                end

            end
            table.insert(self.flowerGiveData,v)
        end
    end
end

function NationalSecondManager:Send17891()
-- print("发送协议17891=============================================================")
    self:Send(17891, {})
end

function NationalSecondManager:On17891(data)
    -- BaseUtils.dump(data,"接收协议17891=============================================================")
    if data.err_code == 1 then
        self.OnUpdateFlowerBegin:Fire(data.index)
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)

end

function NationalSecondManager:Send17892()
-- print("发送协议17892=============================================================")
    self:Send(17892, {})
end

function NationalSecondManager:On17892(data)
    -- BaseUtils.dump(data,"接收协议17892=============================================================")

    if data.err_code == 1 then
        self.OnUpdateFlowerEnd:Fire(data)
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function NationalSecondManager:Send17893()
-- print("发送协议17893=============================================================")
    self:Send(17893, {})
end

function NationalSecondManager:On17893(data)
    -- BaseUtils.dump(data,"接收协议17893=============================================================")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function NationalSecondManager:Send17894()
-- print("发送协议17894=============================================================")
    self:Send(17894, {})
end

function NationalSecondManager:On17894(data)
    -- BaseUtils.dump(data,"接收协议17894=============================================================")
    if data.err_code == 1 then
        self.OnUpdateGetBox:Fire(data)
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


function NationalSecondManager:Send17895()
-- print("发送协议17895=============================================================")
    self:Send(17895, {})
end

function NationalSecondManager:On17895(data)
    -- BaseUtils.dump(data,"接收协议17895=============================================================")
    self.boxData = data.box_info
    table.sort(self.boxData,function(a,b)
       if a.is_get ~= b.is_get then
            return a.is_get < b.is_get
        else
            return a.index <b.index
        end
    end)

    self.OnUpdateBoxData:Fire()
end

function NationalSecondManager:Send17896()
-- print("发送协议17896=============================================================")
    self:Send(17896, {})
end

function NationalSecondManager:On17896(data)
    -- BaseUtils.dump(data,"接收协议17896=============================================================")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function NationalSecondManager:Send17897(myIndex)
-- print("发送协议17897=============================================================" .. myIndex)
    self:Send(17897,{index = myIndex})
end

function NationalSecondManager:On17897(data)
    -- BaseUtils.dump(data,"接收协议17897=============================================================")
    if data.err_code == 1 then
        self.OnUpdateGetOtherBox:Fire(data)
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function NationalSecondManager:Send17898(myIndex)
-- print("发送协议17898=============================================================")
    self:Send(17898, {})
end

function NationalSecondManager:On17898(data)
    -- BaseUtils.dump(data,"接收协议17898=============================================================")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end





