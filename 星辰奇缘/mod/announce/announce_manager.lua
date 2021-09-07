AnnounceManager = AnnounceManager or BaseClass(BaseManager)

function AnnounceManager:__init()
    if AnnounceManager.Instance ~= nil then
        Log.Error("")
        return
    end
    AnnounceManager.Instance = self
    self:InitHandler()
    self.model = AnnounceModel.New()
end

function AnnounceManager:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end

function AnnounceManager:InitHandler()
    self:AddNetHandler(9920, self.on9920)
    self:AddNetHandler(9921, self.on9921)
    self:AddNetHandler(9922, self.on9922)
    self:AddNetHandler(9923, self.on9923)
    self:AddNetHandler(9924, self.on9924)
    self:AddNetHandler(9934, self.on9934)
end

function AnnounceManager:RemoveHandler()
end

function AnnounceManager:send9920()
    Connection.Instance:send(9920, {})
end
--type = 1; 更新公告
--type = 2; GM补偿
--type = 3; 奖励
--type = 4; 普通
function AnnounceManager:on9920(data)
    -- BaseUtils.dump(data, "<color=#FF0000>9920</color>")
    if #data.board_list ==0 then
        --更新公告
        SettingManager.Instance:onAnnounceManager9920(data)
    else
        local friednMgr = FriendManager.Instance
        local updatenoticeList = {board_list={}}
        local announce_list = {}
        for _,v in pairs(data.board_list) do
            if v.type == 1 then
                v.msg = self.model:TransferString(v.msg)
                v.msg = MessageParser.ReplaceSpace(v.msg)
                table.insert(updatenoticeList.board_list,v)
            else
                table.insert(announce_list, self.model:AnnounceToMail(v))
            end
        end
        -- friednMgr:On13404({mail_list = announce_list})
        --更新公告
        SettingManager.Instance:onAnnounceManager9920(updatenoticeList)
    end
end

function AnnounceManager:on9921(data)
    -- BaseUtils.dump(data, "9921")
    if data.type == 1 then
        --更新公告
        data.msg = self.model:TransferString(data.msg)
        data.msg = MessageParser.ReplaceSpace(data.msg)
        SettingManager.Instance:onAnnounceManager9921(data)
    else
        -- FriendManager.Instance:On13404({mail_list = {self.model:AnnounceToMail(data)}})
    end

end
--删除公告
function AnnounceManager:on9922(data)
    -- BaseUtils.dump(data, "9922")
    if data.type == 1 then
        --更新公告
        SettingManager.Instance:onAnnounceManager9922(data)
    else
        FriendManager.Instance:On13403({result = 1, sess_id = data.id, platform = 0, zone_id = 0, type = 3})
    end

end

function AnnounceManager:send9923(id)
    Connection.Instance:send(9923, {id = id})
end
--阅读公告/领取公告附件
function AnnounceManager:on9923(data)
    -- BaseUtils.dump(data, "9923")
    if data.type == 1 then
        --更新公告
        SettingManager.Instance:onAnnounceManager9923(data)
    else
         if data.flag == 1 then
            FriendManager.Instance:On13402({result = 1, sess_id = data.id, platform = 0, zone_id = 0})
        end
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end

function AnnounceManager:send9924()
    -- Log.Error("send9924")
    Connection.Instance:send(9924, {})
end

function AnnounceManager:on9924(data)
    -- BaseUtils.dump(data, "9924")
    local updatenoticeList = {board_list={}}
    for _,v in pairs(data.board_list) do
        if v.type == 1 then
            v.msg = self.model:TransferString(v.msg)
            v.msg = MessageParser.ReplaceSpace(v.msg)
            table.insert(updatenoticeList.board_list,v)
        end
    end
    if #updatenoticeList.board_list > 0 then
        --更新公告
        SettingManager.Instance:onAnnounceManager9924(updatenoticeList)
    end
end

function AnnounceManager:send9934(type)
    -- Log.Error("send9934")
    Connection.Instance:send(9934, {type = type})
end

function AnnounceManager:on9934(data)
    -- BaseUtils.dump(data,"AnnounceManager:on9934(data)")
    local announce_list = {}
    local newAnnounce_list = {}
    for _,v in pairs(data.board_list) do
        if v.type ~= 1 then
            local mail = self.model:AnnounceToMail(v)
            table.insert(announce_list, mail)
            newAnnounce_list[v.id] = v
        end
    end
    for _,v in pairs(data.all_board_list) do
        if v.type ~= 1 and newAnnounce_list[v.id] == nil then
            local mail = self.model:AnnounceToMail(v)
            mail["status"] = 1
            if #mail["item_list"] > 0 then
                mail["item_list"].get = true
            end
            -- if #mail["item_list"] == 0 then
                table.insert(announce_list, mail)
            -- end
        end
    end
    FriendManager.Instance:On13404({mail_list = announce_list})
end