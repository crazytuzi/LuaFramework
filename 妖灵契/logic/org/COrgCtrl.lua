local COrgCtrl = class("COrgCtrl", CCtrlBase)

COrgCtrl.HAS_APPLY_ORG = 1

COrgCtrl.Dont_Need_Allow = 0
COrgCtrl.Need_Allow = 1

--拥有权限
COrgCtrl.Has_Power = 1

COrgCtrl.Apply = 1

COrgCtrl.Auto_Appoint = 1

COrgCtrl.Success = 1
COrgCtrl.Fail = 0

COrgCtrl.AgreeApply = 1
COrgCtrl.RejectApply = 0

COrgCtrl.HuiZhangExitTip = 1
COrgCtrl.ChengYuanExitTip = 0

COrgCtrl.BanChat = 1
COrgCtrl.OpenChat = 0

function COrgCtrl.ctor(self)
    CCtrlBase.ctor(self)
    self:ResetCtrl()

    self.m_MemberSortList = {
        default = {"offline", "position", "power", "grade", "org_offer", "active_point"},
        position = {"position", "power"},
        grade = {"grade", "position", "power"},
        power = {"power", "position", "grade"},
        org_offer = {"org_offer", "position", "power"},
        active_point = {"active_point", "position", "power"},
        offline = {"offline", "position", "power"},
    }

    self.m_ApproveSortList = {
        grade = {"grade"},
        power = {"power"},
        apply_time = {"apply_time"},
    }
end

function COrgCtrl.ResetCtrl(self)
    self.m_Org = {}--自己的公会信息
    self.m_OrgList = {}--公会列表
    self.m_ApplyList = {}--审核列表
    self.m_MemberList = {}--成员列表
    self.m_WishList = {}--许愿列表
    self.m_AimDic = {}--公告列表
    self.m_OrgFubenRedDot = true
    self.m_Org.powerlimit = 0
    self.m_Org.needallow = COrgCtrl.Dont_Need_Allow
end

function COrgCtrl.UpdateDay(self)
    if self:HasOrg() and COrgMainView:GetView() then
        printc("刷天了，公会信息")
        netorg.C2GSOrgMainInfo()
    end
end

function COrgCtrl.GetRule(self)
    return data.orgdata.Rule[1]
end

function COrgCtrl.GetPosition(self, posId)
    if data.orgdata.MemberLimit[posId] then
        return data.orgdata.MemberLimit[posId]
    else
        --tzq无导表时默认数据
        printc(string.format("<color=#ff0000>posId:%s不存在,请检查导表org</color>", posId))
        return data.orgdata.MemberLimit[5]
    end
end

function COrgCtrl.GetFlagIcon(self, flagId)
    if data.orgdata.Flag[flagId] then
        return data.orgdata.Flag[flagId].icon
    else
        return ""
    end
end

function COrgCtrl.OpenOrg(self)
    if self:HasOrg() then
        -- netorg.C2GSOrgMainInfo()
        COrgMainView:ShowView()
    else
        netorg.C2GSOrgList()
    end
end

function COrgCtrl.GetDefaultFlagBg(self)
    return data.orgdata.FlagSort[1]
end

function COrgCtrl.ChangeLimit(self, powerLimit, needAllow)
    self.m_TempPowerLimit = powerLimit
    self.m_TempNeedAllow = needAllow
    netorg.C2GSSetApplyLimit(powerLimit, needAllow)
end

function COrgCtrl.OnChangeLimit(self, result)
    if result == COrgCtrl.Success then
        self.m_Org.powerlimit = self.m_TempPowerLimit
        self.m_Org.needallow = self.m_TempNeedAllow
        self:OnEvent(define.Org.Event.OnChangeLimit)
    end
end

function COrgCtrl.ChangeFlag(self, flagBgID, flagName)
    if self.m_Org.info.sflag == flagName and self.m_Org.info.flagbgid == flagBgID then
        g_NotifyCtrl:FloatMsg("没有改动")
    else
        netorg.C2GSUpdateFlagID(flagName, flagBgID)
    end
end

function COrgCtrl.OnReceiveChangeFlag(self, result)
    if result == 1 then
        self:OnEvent(define.Org.Event.ChangeFlag)
        g_NotifyCtrl:FloatMsg("修改成功")
    else
        g_NotifyCtrl:FloatMsg("修改失败")
    end
end

function COrgCtrl.GetOrgInfo(self, orgid)
    netorg.C2GSGetOrgInfo(orgid)
end

function COrgCtrl.OnReceiveOrgInfo(self, oData, meminfo)
    -- COrgInfoView:ShowView(function (oView)
    --     oView:SetData(oData, meminfo)
    -- end)
end

function COrgCtrl.GetOfflineTime(self, oTime, now)
    if oTime == 0 then
        return "[1b9880]在线"
    else
        local str = self:GetTimeSpace(oTime, now, "")
        if str ~= nil then 
            return "[654a33]" .. str
        else
            return "[db5b4d]刚刚"
        end
    end
end

function COrgCtrl.GetApplyTime(self, oTime, now)
    if oTime == 0 then
        return "刚刚"
    else
        local str = self:GetTimeSpace(oTime, now, "申请")
        if str ~= nil then 
            return str
        else
            return "刚刚"
        end
    end
end

function COrgCtrl.GetTimeSpace(self, oTime, now, headStr)
    local time = now - oTime
    local d = math.floor(time / (3600 * 24))
    if d > 0 then
        return string.format("%s%d天", headStr, d)
    end
    time = time % (3600 * 24)
    local h = math.floor(time / 3600)
    if h > 0 then
        return string.format("%s%d小时", headStr, h)
    end
    time = time % 3600
    local m = math.floor(time / 60)
    if m > 0 then
        return string.format("%s%d分钟", headStr, m)
    end
    return nil
end

function COrgCtrl.GetMaxMember(self, level)
    return self:GetOrgGradeData(level).max_member
end

function COrgCtrl.GetMemberList(self, handleType)
    netorg.C2GSOrgMemberList(handleType)
end

function COrgCtrl.OnReceiveMemberList(self, infos, handleType)
    self.m_MemberList = {}
    for k,v in pairs(infos) do
        self.m_MemberList[v.pid] = self:CopyOrgMember(v)
    end
    if handleType == define.Org.HandleType.OpenMemberView then
        self:OnEvent(define.Org.Event.OnGetMemberList)
    elseif handleType == define.Org.HandleType.OpenTeamInviteView then
        g_TeamCtrl:OnEvent(define.Team.Event.TeamInvitePlayerList)
    elseif handleType == define.Org.HandleType.OpenSocail then
        self:OnEvent(define.Team.Event.OpenSocail)
    end
end

function COrgCtrl.CopyOrgMember(self, oInfo)
    local oMemberInfo = {
        pid = oInfo.pid,
        name = oInfo.name,
        grade = oInfo.grade,
        school = oInfo.school,
        position = oInfo.position,
        power = oInfo.power,
        honor = oInfo.honor,
        offline = oInfo.offline,
        shape = oInfo.shape,
        org_wish = oInfo.org_wish,
        active_point = oInfo.active_point,
        org_offer = oInfo.org_offer,
        has_team = oInfo.has_team,
        inbanchat = oInfo.inbanchat,
        org_wish_equip = oInfo.org_wish_equip,
        school_branch = oInfo.school_branch,
    }
    return oMemberInfo
end

function COrgCtrl.GetOrgDic(self)
    return self.m_OrgList
end

function COrgCtrl.UpdateOrgList(self, infos)
    -- 保存完整列表
    self.m_OrgList = {}
    for k,v in pairs(infos) do
        self.m_OrgList[v.info.orgid] = self:CopyOrgListInfo(v)
    end
    if CJoinOrgView:GetView() ~= nil then
        self:OnEvent(define.Org.Event.OnGetOrgDic)
    else
        CJoinOrgView:ShowView()
    end
end

function COrgCtrl.CopyOrgListInfo(self, oInfo)
    local dInfo = {
        info = self:CopyOrgData(oInfo.info),
        hasapply = oInfo.hasapply,
        powerlimit = oInfo.powerlimit,
        needallow = oInfo.needallow,
    }
    return dInfo
end

function COrgCtrl.UpdateOrgAim(self, orgid, oAim)
    self.m_AimDic[orgid] = oAim
    self:OnEvent(define.Org.Event.GetOrgAim, {orgid = orgid, aim = oAim})
end

function COrgCtrl.GetOrgAim(self, orgid)
    return self.m_AimDic[orgid]
end

function COrgCtrl.ApplyJoinOrg(self, orgid)
    if not self:HasOrg() then
        netorg.C2GSApplyJoinOrg(orgid, COrgCtrl.Apply)
    else
        g_NotifyCtrl:FloatMsg("你已有公会")
    end
end

function COrgCtrl.OnReceiveApplyJoinOrg(self, orgid, result)
    if result == COrgCtrl.Success then
        g_NotifyCtrl:FloatMsg("申请成功")
        if self.m_OrgList[orgid] ~= nil then
            self.m_OrgList[orgid].hasapply = COrgCtrl.HAS_APPLY_ORG
            self:OnEvent(define.Org.Event.ApplySuccess, orgid)
        end
    else
        g_NotifyCtrl:FloatMsg("申请失败")
    end
end

function COrgCtrl.OnReceiveOrgMainInfo(self, oInfo)
    self.m_Org.info = self:CopyOrgData(oInfo)
    self:OnEvent(define.Org.Event.GetOrgMainInfo)
end

function COrgCtrl.CopyOrgData(self, oInfo)
    local oTable = {
        mask = oInfo.mask,
        orgid = oInfo.orgid,
        name = oInfo.name,
        level = oInfo.level,
        leadername = oInfo.leadername,
        memcnt = oInfo.memcnt,
        sflag = oInfo.sflag,
        flagbgid = oInfo.flagbgid,
        aim = oInfo.aim,
        cash = oInfo.cash,
        exp = oInfo.exp,
        rank = oInfo.rank,
        prestige = oInfo.prestige,
        sign_degree = oInfo.sign_degree,
        red_packet = oInfo.red_packet,
        active_point = oInfo.active_point,
        apply_count = oInfo.apply_count,
        online_count = oInfo.online_count,
        is_open_red_packet = oInfo.is_open_red_packet,
        red_packet_rest = oInfo.red_packet_rest,
        mail_rest = oInfo.mail_rest,
        spread_endtime = oInfo.spread_endtime,
    }
    if oTable.spread_endtime < g_TimeCtrl:GetTimeS() then
        oTable.spread_endtime = 0
    end
    return oTable
end

function COrgCtrl.GetSpreadTime(self)
    local iTime = self.m_Org.info.spread_endtime - g_TimeCtrl:GetTimeS()
    if iTime < 0 then
        iTime = 0
    end
    return iTime
end

function COrgCtrl.OnReceiveOrgApplyList(self, infos, powerlimit, needallow)
    self.m_ApplyList = {}
    for k,v in pairs(infos) do
        self.m_ApplyList[v.pid] = v
    end
    
    self.m_Org.powerlimit = powerlimit
    self.m_Org.needallow = needallow
    COrgApproveView:ShowView()
end

function COrgCtrl.OnReceiveSetPosition(self, oPid, oPosition)
    if self.m_MemberList[oPid] ~= nil then
        self.m_MemberList[oPid].position = oPosition
    end
    self:OnEvent(define.Org.Event.OnChangePos, {pid = oPid, position = oPosition})
end

function COrgCtrl.UpdateOrgMainInfo(self, info)
    if self.m_Org.info == nil then
        return
    end
    local decode = g_NetCtrl:DecodeMaskData(info, "org")
    for k,v in pairs(decode) do
        self.m_Org.info[k] = v
        if k == "name" then
            self:DelayEvent(define.Org.Event.UpdateOrgName)
        end
    end
    self:DelayEvent(define.Org.Event.UpdateOrgInfo)
end

function COrgCtrl.DelMember(self, iPid)
    self.m_MemberList[iPid] = nil
    self.m_WishList[iPid] = nil
    self:OnEvent(define.Org.Event.DelMember, iPid)
end

function COrgCtrl.AddMember(self, info)
    -- self.m_Org.info.memcnt = self.m_Org.info.memcnt + 1
    -- self.m_MemberList[info.pid] = info
    -- self:OnEvent(define.Org.Event.AddMember, info.pid)
end

function COrgCtrl.OnReceiveOrgDealApply(self, pid, flag)
    if self.m_ApplyList[pid] ~= nil then
        self.m_ApplyList[pid] = nil
    end

    self:OnEvent(define.Org.Event.OnDealApply, pid)
end

function COrgCtrl.OnReceiveWishList(self, wishList)
    self.m_WishList = {}
    for k,v in pairs(wishList) do
        self.m_WishList[v.pid] = v
    end
    COrgWishView:ShowView()
end

function COrgCtrl.OnUpdateOrgMember(self, memInfo)
    self.m_WishList[memInfo.pid] = memInfo
    if self.m_MemberList[memInfo.pid] then
        self.m_MemberList[memInfo.pid] = self:CopyOrgMember(memInfo)
    end
    self:OnEvent(define.Org.Event.OnUpdateMemberInfo, memInfo)
end

function COrgCtrl.GetOrgMember(self, pid)
    return self.m_MemberList[pid]
end

function COrgCtrl.GetWishList(self)
    return self.m_WishList
end

function COrgCtrl.IsPlayerWishedChip(self)
    return g_AttrCtrl.is_org_wish ~= 0
end

function COrgCtrl.IsPlayerWishedEquip(self)
    return g_AttrCtrl.grade < data.globalcontroldata.GLOBAL_CONTROL.forge_composite.open_grade or g_AttrCtrl.is_equip_wish ~= 0
end

function COrgCtrl.HasOrg(self)
    return g_AttrCtrl.org_id ~= 0
end

function COrgCtrl.OnReceiveRejectAll(self, result)
    if result == COrgCtrl.Success then
        self.m_ApplyList = {}
        self:OnEvent(define.Org.Event.OnRejectAll)
    end
end

function COrgCtrl.GetLog(self)
    netorg.C2GSOrgLog()
end

function COrgCtrl.OnGetLog(self, logInfo)
    self.m_LogInfo = logInfo
    self:OnEvent(define.Org.Event.OnGetLog)
end

--返回按日期分组排序的历史信息
function COrgCtrl.GetLogInfo(self)
    local infoOut = {}
    local infoList = {}
    for k,v in pairs(self.m_LogInfo) do
        table.insert(infoList, v)
    end
    local function sortFunc(v1, v2)
        return v1.time > v2.time
    end
    table.sort(infoList, sortFunc)

    local count = 0
    local timeTemp = nil
    for i,v in ipairs(infoList) do
        local date = os.date("[%Y.%m.%d]", v.time)
        if timeTemp ~= date then
            count = count + 1
            timeTemp = date
            table.insert(infoOut, {date = date, infoList = {}})
        end
        table.insert(infoOut[count].infoList, v)
    end
    return infoOut
end

function COrgCtrl.IsHasRedBag(self)
    if self:IsShouldSendRedBag() then
        return true
    end
    if g_OrgCtrl:GetMyOrgInfo().red_packet_rest <= 0 then
        return false
    end
    local restList = self:GetRestBagList()
    for i, v in ipairs(self:GetRedBagList()) do
        if i > g_OrgCtrl:GetMyOrgInfo().red_packet then
            break
        end
        if v == 0 and restList[i] == 1 then
            return true
        end
    end
    return false
end

function COrgCtrl.IsSendRedBag(self)
    return g_OrgCtrl:GetMyOrgInfo().is_open_red_packet == 1
end

function COrgCtrl.IsShouldSendRedBag(self)
    if self:IsSendRedBag() then
        return false
    end
    if g_AttrCtrl.org_pos ~= 1 and g_AttrCtrl.org_pos ~= 2 then
        return false
    end
    local t = os.date("*t", g_TimeCtrl:GetTimeS())
    if (t["hour"] == 19 or t["hour"] == 20) and g_OrgCtrl:GetMyOrgInfo().sign_degree >= 20 then
        return true
    else
        return false
    end

end

function COrgCtrl.IsHasSignReward(self)
    local orgsignreward = g_AttrCtrl.org_sign_reward
    local orgsignrewarddata = data.orgdata.OrgSignReward
    local idx
    for i,v in ipairs(orgsignrewarddata) do
        if MathBit.andOp(orgsignreward, 2 ^ (i-1)) == 0 then
            idx = i
            break
        end
    end
    if idx then
        local need = orgsignrewarddata[idx].sign_degree
        local orginfo = g_OrgCtrl:GetMyOrgInfo()
        local now = orginfo.sign_degree
        return now >= need, idx
    end
    return false, idx
end

function COrgCtrl.IsHasBuild(self)
    return g_AttrCtrl.org_build_status == define.Org.Build.Status.Not
end

function COrgCtrl.IsHasBuildFinish(self)
    return g_AttrCtrl.org_build_status == define.Org.Build.Status.Finish
end

function COrgCtrl.SetOrgFubenRedDot(self, b)
     self.m_OrgFubenRedDot = b
    self:OnEvent(define.Org.Event.OnOrgFubenRedDot)
end

function COrgCtrl.IsHasFubenCnt(self)
    return g_AttrCtrl.org_fuben_cnt and g_AttrCtrl.org_fuben_cnt > 0 and self.m_OrgFubenRedDot
end

function COrgCtrl.GetMyOrgInfo(self)
    return self.m_Org.info
end

function COrgCtrl.GetRedBagList(self)
    local x = g_AttrCtrl.org_red_packet
    local resultlist = {}
    for i = 1, 3 do
        local a = MathBit.rShiftOp(x, i-1)
        local b = MathBit.andOp(a, 1)
        table.insert(resultlist, b)
    end
    return resultlist
end

function COrgCtrl.GetRestBagList(self)
    local x = g_OrgCtrl:GetMyOrgInfo().red_packet_rest
    local resultlist = {}
    for i = 1, 3 do
        local a = MathBit.rShiftOp(x, i-1)
        local b = MathBit.andOp(a, 1)
        table.insert(resultlist, b)
    end
    return resultlist
end

function COrgCtrl.GetCash(self)
    if self.m_Org == nil then
        return 0
    end
    return self.m_Org.info.cash
end

function COrgCtrl.GetOrgGradeData(self, grade)
    if data.orgdata.DATA[grade] then
        return data.orgdata.DATA[grade]
    else
        printc(string.format("<color=#ff0000>公会等级level:%s不存在,请检查导表org</color>", grade))
        return data.orgdata.DATA[#data.orgdata.DATA]
    end
end

function COrgCtrl.GetLvUpExpNeed(self, grade)
    return self:GetOrgGradeData(grade).exp_need
end

function COrgCtrl.PromoteOrgLevel(self)
    local oDate = self:GetOrgGradeData(self.m_Org.info.level)
    if data.orgdata.DATA[self.m_Org.info.level + 1] == nil then
        g_NotifyCtrl:FloatMsg("公会已满级")
    elseif self.m_Org.info.exp < oDate.exp_need then
        g_NotifyCtrl:FloatMsg("公会经验不足")
    -- elseif self.m_Org.info.cash < oDate.coin_need then
    --     g_NotifyCtrl:FloatMsg("所需资源不足，升级失败")
    else
        local windowConfirmInfo = {
            msg = string.format("升级公会需要花费%s公会经验，是否升级?", oDate.exp_need),
            okStr = "确定",
            cancelStr = "取消",
            okCallback = function()
                netorg.C2GSPromoteOrgLevel()
            end
        }
        g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)
    end
end

function COrgCtrl.UpdateOrgFBBossList(self, boss_list, left, rest, cost)
    --暂时先不存数据
    local data = {
        boss_list = boss_list,
        left = left,
        rest = rest,
        cost = cost,
    }
    self:OnEvent(define.Org.Event.OnOrgFBBossList, data)
end

function COrgCtrl.UpdateOrgFBBossHP(self, boss_id, hp_max, hp)
    self.m_OrgBossInfo = {
        boss_id = boss_id,
        hp_max = hp_max,
        hp = hp,
        percent = hp / hp_max,
    }
   self:DelayEvent(define.Org.Event.OnOrgFBBossHP, nil, 1) --1秒后再执行
end

function COrgCtrl.GetOrgBossInfo(self)
    return self.m_OrgBossInfo
end

function COrgCtrl.GetMemberSortList(self, conditionList, bReverse)
    local sortList = {}
    for k,v in pairs(self.m_MemberList) do
        table.insert(sortList, v)
    end
    -- table.print(conditionList)
    -- table.print(sortList)
    table.sort(sortList, self:MemberSortFunc(conditionList, bReverse))
    return sortList
end

function COrgCtrl.MemberSortFunc(self, conditionList, bReverse)
    local func = function(a, b)
        local count = 1
        local v1 = nil
        local v2 = nil
        while conditionList[count] ~= nil do
            v1 = a[conditionList[count]]
            v2 = b[conditionList[count]]
            if conditionList[count] == "position" then
                v1 = -g_OrgCtrl:GetPosition(v1).show_sort
                v2 = -g_OrgCtrl:GetPosition(v2).show_sort
            end
            -- printc(conditionList[count] .. v1 .. "," ..  v2)
            if conditionList[count] == "offline" and v1 ~= v2 then
                if v1 == 0 then
                    return not bReverse
                elseif v2 == 0 then
                    return bReverse
                end
            end
            if v1 > v2 then
                return not bReverse
            elseif v1 < v2 then
                return bReverse
            end
            count = count + 1
        end
        return false
    end
    return func
end

function COrgCtrl.GetApproveSortList(self, conditionList, bReverse)
    local sortList = {}
    for k,v in pairs(self.m_ApplyList) do
        table.insert(sortList, v)
    end
    if conditionList ~= nil then
        table.sort(sortList, self:ApplyListSortFunc(conditionList, bReverse))
    end
    return sortList
end

function COrgCtrl.ApplyListSortFunc(self, conditionList, bReverse)
    local func = function(a, b)
        local count = 1
        local v1 = nil
        local v2 = nil
        while conditionList[count] ~= nil do
            v1 = a[conditionList[count]]
            v2 = b[conditionList[count]]
            if v1 > v2 then
                return not bReverse
            elseif v1 < v2 then
                return bReverse
            end
            count = count + 1
        end
        return false
    end
    return func
end

function COrgCtrl.OnLeaveOrgTips(self, sTip)
    local msgStr = sTip
    local t = {
        msg = msgStr or "",
        hideOk = true,
        hideCancel = true,
        thirdStr = "确定",
        alignment = enum.UILabel.Alignment.Center,
        thirdCallback = callback(self, "AfterLeave"),
        cancelCallback = callback(self, "AfterLeave"),
    }
    g_WindowTipCtrl:SetWindowConfirm(t)
end

function COrgCtrl.AfterLeave(self)
    self:CloseAllOrgView()
    self.m_Org = {}
    self.m_MemberList = {}
end

function COrgCtrl.CloseAllOrgView(self)
    local oViewList = {
        "COrgChangeFlagView",
        "COrgMainView",
        "COrgWishView",
        "COrgChamberView",
        "COrgApproveView",
        "COrgActivityCenterView",
        "COrgFuBenRewardView",
        "COrgRedBagView",
        "COrgShopView",
    }
    for _, viewName in ipairs(oViewList) do
        local oView = g_ViewCtrl:GetViewByName(viewName)
        if oView then
            oView:CloseView()
        end
    end
end

function COrgCtrl.HasApplyList(self)
    return self:GetMyOrgInfo().apply_count > 0
end

function COrgCtrl.IsMainNeedRedDot(self)
    if not self:HasOrg() then
        return false
    end
    if not self:IsPlayerWishedChip() then
        return true
    end
    if not self:IsPlayerWishedEquip() then
        return true
    end
    if not self:GetMyOrgInfo() then
        return true
    end
    if self:IsHasSignReward() or self:IsHasBuild() or self:IsHasBuildFinish() then
        return true
    end
    if self:IsHasFubenCnt() then
        return true
    end
    if self:HasApplyList() and self:GetPosition(g_AttrCtrl.org_pos).agree_reject_join == COrgCtrl.Has_Power then
        return true
    end
    if self:IsHasRedBag() then
        return true
    end

    return false
end

function COrgCtrl.ShowOrgBossWarResult(self, oCmd)
   if oCmd.win then
        COrgFuBenResultView:ShowView(function(oView)
            oView:SetWarID(oCmd.war_id)
            oView:SetWin(true)
            oView:OrgFuBenWarEnd()
            oView:SetDelayCloseView()
        end)
   else
        COrgFuBenResultView:ShowView(function(oView)
            oView:SetWarID(oCmd.war_id)
            oView:SetWin(false)
            oView:OrgFuBenWarEnd()
            oView:SetDelayCloseView()
        end)
   end
end

function COrgCtrl.OnSendMailResult(self, iResult)
    self:OnEvent(define.Org.Event.OnSendMailResult, iResult)
end

function COrgCtrl.ClickRedPacket(self, iHid)
    
end

function COrgCtrl.HasOrgRight(self, iPid, iRight)
    local dMemberData = g_OrgCtrl:GetOrgMember(iPid)
    if dMemberData and dMemberData.position <= iRight then
        return true
    end
    return false
end

return COrgCtrl