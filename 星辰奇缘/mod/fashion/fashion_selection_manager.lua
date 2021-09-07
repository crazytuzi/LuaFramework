FashionSelectionManager = FashionSelectionManager or BaseClass(BaseManager)

function FashionSelectionManager:__init()
    if FashionSelectionManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    FashionSelectionManager.Instance = self;
    self:InitHandler()

    self.model = FashionSelectionModel.New()
    self.onUpdateRoleData = EventLib.New()
    self.onUpdateRoleShowData = EventLib.New()
    self.onUpdateRoleHelpData = EventLib.New()

    self.fashionData = {}
    self.fashionRoleData = nil
    self.fashionLuckyData = {}
    self.luckyRoleData = {}
    self.luckyAllRoleData = {}
end

function FashionSelectionManager:__delete()
    self.model:DeleteMe()
    self.model = nil
end

function FashionSelectionManager:InitHandler()
    self:AddNetHandler(20409,self.on20409)
    self:AddNetHandler(20410,self.on20410)
    self:AddNetHandler(20411,self.on20411)
    self:AddNetHandler(20412,self.on20412)
    self:AddNetHandler(20413,self.on20413)
    self:AddNetHandler(20414,self.on20414)
    self:AddNetHandler(20415,self.on20415)

end

function FashionSelectionManager:RequestInitData()
    self:send20409()
    self:send20410()
end

function FashionSelectionManager:send20409(data)
    Connection.Instance:send(20409, {})

end

function FashionSelectionManager:on20409(data)
    self.fashionData = data
    self.model:InitFashionList()
end

function FashionSelectionManager:send20410(data)
    --print("发送协议20410===================================================================================================================================")
    Connection.Instance:send(20410, {})
end

function FashionSelectionManager:on20410(data)
        -- print("发送协议20410===================================================================================================================================")
    BaseUtils.dump(data,"fdskjfffffffffffffffffffffffffffffffffffffffffffffffff")
    self.fashionRoleData = data
    self.onUpdateRoleData:Fire()
end

function FashionSelectionManager:send20411(groudId)
    print(groudId)
    -- print("发送协议20411===================================================================================================================================")

    Connection.Instance:send(20411, {group_id = groudId})
end

function FashionSelectionManager:on20411(data)
    -- BaseUtils.dump(data,"接收协议20411=====================================================================================================================")

    if data.result == 1 then --成功
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function FashionSelectionManager:send20412(data)
    -- BaseUtils.dump(data,"发送协议20412===================================================================================================================================")

    Connection.Instance:send(20412,data)
end

function FashionSelectionManager:on20412(data)
    -- BaseUtils.dump(data,"接收协议20412=====================================================================================================================")

    if data.result == 1 then
        local fashionId = self.selectionFashionDataGroupId
        local weapModel = self.selectionWeapDataLooks_mode
        local weapVal = self.selectionWeapDataLooks_val



        local sendData = string.format(TI18N("我看到一套心仪的时装，快来帮我投票吧，听说好友互助更容易中奖哟{face_1,54}{fationselection_1,点击帮助,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s}"),fashionId,RoleManager.Instance.RoleData.classes,RoleManager.Instance.RoleData.sex,weapModel,weapVal,RoleManager.Instance.RoleData.id,RoleManager.Instance.RoleData.platform,RoleManager.Instance.RoleData.zone_id,RoleManager.Instance.RoleData.name,RoleManager.Instance.RoleData.lev)
        BaseUtils.dump(RoleManager.Instance.RoleData.sex,"发送的=============================================================================================================")
        FriendManager.Instance:SendMsg(data.f_id,data.f_platform,data.f_zone_id,sendData)
        local data = {id = data.f_id,platform = data.f_platform,zone_id = data.f_zone_id,classes = self.lastSelectFirendData.classes,lev = self.lastSelectFirendData.lev,sex = self.lastSelectFirendData.sex,name = self.lastSelectFirendData.name}
        FriendManager.Instance:TalkToUnknowMan(data)
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)

end

function FashionSelectionManager:send20413(data,isOpen,helpData)
    self.helpData = {} or helpData
    self.isHelpOpen = false or isOpen
-- BaseUtils.dump(data,"发送协议20413===================================================================================================================================")


    Connection.Instance:send(20413, data)
end


function FashionSelectionManager:on20413(data)

    if self.isHelpOpen == true then
        self.helpData.isHelp = result
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.fashion_help_window,data,self.helpData)
    else
        if data.result == 1 then
            local sendData = string.format(TI18N("亲爱的%s,我成功帮你投了一票喲,祝你赢得心仪时装{face_1,9}{panel_2,20505,4,点此查看}"),self.lastSelectFirendData.name)
            FriendManager.Instance:SendMsg(self.lastSelectFirendData.id,self.lastSelectFirendData.platform,self.lastSelectFirendData.zone_id,sendData)
            local data = {id = self.lastSelectFirendData.id,platform = self.lastSelectFirendData.platform,zone_id = self.lastSelectFirendData.zone_id,classes = self.lastSelectFirendData.classes,lev = self.lastSelectFirendData.lev,sex = self.lastSelectFirendData.sex,name = self.lastSelectFirendData.name}
            FriendManager.Instance:TalkToUnknowMan(data)
        end
        NoticeManager.Instance:FloatTipsByString(data.msg)
    end
end


function FashionSelectionManager:send20414(data)
    print("发送协议20414===================================================================================================================================")

    Connection.Instance:send(20414,{})
end

function FashionSelectionManager:on20414(data)
    BaseUtils.dump(data,"接收协议20414=====================================================================================================================")





    self.luckyAllRoleData = data
    for k,v in pairs(self.luckyAllRoleData) do
        if v.group_id == luckyGroupId then
            self.luckyRoleData = v
            break
        end
    end

    table.sort(self.luckyAllRoleData.group,function(a,b)
                if #a.lucky_list ~= #b.lucky_list then
                    return #a.lucky_list > #b.lucky_list
                elseif #a.lucky_list == #b.lucky_list and a.group_id ~= b.group_id then
                    return a.group_id < b.group_id
                else
                    return false
                end
            end)
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.fashion_selection_show_window)
    self.onUpdateRoleShowData:Fire()
end


function FashionSelectionManager:send20415(data)
        -- BaseUtils.dump(data,"接收协议20415=====================================================================================================================")

    Connection.Instance:send(20415,data)
end

function FashionSelectionManager:on20415(data)
        -- BaseUtils.dump(data,"接收协议20415=====================================================================================================================")

    FashionSelectionManager.Instance.haseSurport = data.invite_state
    self.onUpdateRoleHelpData:Fire()
end


function FashionSelectionManager:IsFashionVoteEnd()
    local baseTime = BaseUtils.BASE_TIME
    if baseTime >= self.fashionData.show_start_time then
        return true
    else
        return false
    end
end



