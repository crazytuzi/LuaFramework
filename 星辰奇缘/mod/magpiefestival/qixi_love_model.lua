QiXiLoveModel = QiXiLoveModel or BaseClass(BaseModel)

function QiXiLoveModel:__init()
    self.loveMatchWin = nil
    self.openArgs = args
end

function QiXiLoveModel:OpenLoveMatchWindow(args)
    ---------------------------------------
    self.loveMatchArgs = args
    QiXiLoveManager.Instance:send17879()
end

function QiXiLoveModel:OpenReallyLoveMatchWindow()
    if self.loveMatchWin == nil then
        self.loveMatchWin = LoveMatchWindow.New(self)
    end
    self.loveMatchWin:Open(args)
end

function QiXiLoveModel:OpenLoveCheckWindow(args)
    if self.loveCheckWin == nil then
        self.loveCheckWin = LoveCheckWindow.New(self)
    end
    self.loveCheckWin:Open(args)
end


function QiXiLoveModel:__delete()
    if self.loveMatchWin ~= nil then
        self.loveMatchWin:DeleteMe()
    end
end

function QiXiLoveModel:ApplyLoveMatch(data)
    -- print("目标玩家队伍状态："..tostring(self.tips_data.team_status))
    local uniqueroleid = BaseUtils.get_unique_roleid(data.roleid,data.zone_id,data.platform)
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        -- 自己是队长的时候的处理
        if TeamManager.Instance:IsInMyTeam(uniqueroleid) then
            NoticeManager.Instance:FloatTipsByString("有缘人已经在队伍中了")
        else
            self.teamCall = function(rid,platform,zone)
                TeamManager.Instance:OrganizeATeam(rid,platform,zone)
                    -- TeamManager.Instance:Send11702(rid, platform, zone)
            end
        end
    else
        -- 自己不是队长的时候
        if TeamManager.Instance:HasTeam() then
            NoticeManager.Instance:FloatTipsByString("请先退出已有队伍")
        else
            self.teamCall = function(rid, platform, zone)
                TeamManager.Instance:OrganizeATeam(rid, platform, zone)
            end
        end
    end

    if self.teamCall ~= nil then
        if RoleManager.Instance.RoleData.id == data.rid and RoleManager.Instance.RoleData.platform == data.platform and RoleManager.Instance.RoleData.zone_id == data.zone_id then
            NoticeManager.Instance:FloatTipsByString("邀请已发送，请耐心等待")
        else
            local sendData = string.format(TI18N("我已经接受你的邀请了哟，一起去领取同心锁吧~{face_1,54}"))
            FriendManager.Instance:SendMsg(data.rid,data.platform,data.zone_id,sendData)
            self.teamCall(data.rid,data.platform,data.zone_id)
        end
    end

    TipsManager.Instance.model:Closetips()
end