
CampaignAutumnManager = CampaignAutumnManager or BaseClass(BaseManager)

function CampaignAutumnManager:__init()
    if CampaignAutumnManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    CampaignAutumnManager.Instance = self
    self.model = CampaignAutumnModel.New()
    self:InitHandler()

    self.campaignData = nil
    self.onRefreshData = EventLib.New()
    self.onRefreshOtherData = EventLib.New()
    self.brainNumber = 0
    self.tagetData = nil
end

function CampaignAutumnManager:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end

function CampaignAutumnManager:RequestInitData()
    -- self:on14050(backendDataExample)
    self:Send20400(RoleManager.Instance.RoleData.id,RoleManager.Instance.RoleData.platform,RoleManager.Instance.RoleData.zone_id)
end
function CampaignAutumnManager:InitHandler()
    self:AddNetHandler(20400, self.On20400)
    self:AddNetHandler(20401, self.On20401)
    self:AddNetHandler(20402, self.On20402)
    self:AddNetHandler(20403, self.On20403)
end

function CampaignAutumnManager:Send20400(myId,myPlatform,myZone_id)
    local data = {tar_role_id = myId,platform = myPlatform,zone_id = myZone_id}
    self:Send(20400,data)
end

function CampaignAutumnManager:On20400(data)
    if RoleManager.Instance.RoleData.id == data.tar_role_id and RoleManager.Instance.RoleData.platform == data.platform and RoleManager.Instance.RoleData.zone_id == data.zone_id then
        self.campaignData = data
        self.onRefreshData:Fire()
    else
        self.campaignOtherData = data
        self.onRefreshOtherData:Fire()
    end

end

function CampaignAutumnManager:Send20401(myId,myPlatform,myZone_id)
    local data = {tar_role_id = myId,platform = myPlatform,zone_id = myZone_id}
    self:Send(20401,data)
end

function CampaignAutumnManager:On20401(data)
end

function CampaignAutumnManager:Send20402(myId,myPlatform,myZone_id,name)
    local data = {tar_role_id = myId,platform = myPlatform,zone_id = myZone_id}
    self.tagetData = data
    self.tagetName = name
    self:Send(20402,data)
end

function CampaignAutumnManager:On20402(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        self.brainNumber = data.cut_price
        local sendData = string.format("亲爱的%s,我帮你成功砍掉<color='#ffff00'>%s</color>钻啦！快去剁手买礼包吧~",self.tagetName,self.brainNumber)
        NoticeManager.Instance:FloatTipsByString(string.format("恭喜您成功帮TA砍掉%s{assets_2,90002}",self.brainNumber))
        FriendManager.Instance:SendMsg(self.tagetData.tar_role_id,self.tagetData.platform,self.tagetData.zone_id,sendData)
    end
end

function CampaignAutumnManager:Send20403(myId)
    local data = {item_id = myId}
    self:Send(20403, data)
end

function CampaignAutumnManager:On20403(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function CampaignAutumnManager:OpenHelpWindow(args)
    self.model:OpenHelpWindow(args)
end

function CampaignAutumnManager:OpenFriendWindow(args)
    self.model:OpenFriendWindow(args)
end