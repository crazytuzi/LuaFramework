g_MakeTeamNotice = {}
function g_MakeTeamNotice.MakeTeamNotice_Invite(pid, name, zs, level)
  if g_MakeTeamNotice.m_MakeTeamInviteDlg ~= nil then
    for _, info in pairs(g_MakeTeamNotice.m_MakeTeamInvite) do
      if info.pid == pid then
        return
      end
    end
    if g_MakeTeamNotice.m_MakeTeamInviteDlg._playerId == pid then
      return
    end
    local d = {
      pid = pid,
      name = name,
      zs = zs,
      level = level
    }
    g_MakeTeamNotice.m_MakeTeamInvite[#g_MakeTeamNotice.m_MakeTeamInvite + 1] = d
    return
  end
  local _OnConfirmInvite = function(pid)
    print("_OnConfirmInvite", pid)
    g_TeamMgr:send_AgreeInviteToTeam(pid)
  end
  local _OnRefuseInvite = function(pid)
    print("_OnRefuseInvite", pid)
    g_TeamMgr:send_RefuseInviteToTeam(pid)
  end
  local _OnCloseInvite = function()
    g_MakeTeamNotice.m_MakeTeamInviteDlg = nil
    if #g_MakeTeamNotice.m_MakeTeamInvite > 0 then
      local temp = table.remove(g_MakeTeamNotice.m_MakeTeamInvite, 1)
      g_MakeTeamNotice.MakeTeamNotice_Invite(temp.pid, temp.name, temp.zs, temp.level)
    end
  end
  local nameColor = NameColor_MainHero[zs] or ccc3(255, 255, 255)
  g_MakeTeamNotice.m_MakeTeamInviteDlg = CPopWarning.new({
    title = "组队邀请",
    text = string.format("玩家#<r:%d,g:%d,b:%d>%s#(%d转%d级),邀请你加入他的队伍。", nameColor.r, nameColor.g, nameColor.b, name, zs, level),
    confirmFunc = function()
      _OnConfirmInvite(pid)
    end,
    cancelFunc = function()
      _OnRefuseInvite(pid)
    end,
    clearFunc = function()
      _OnCloseInvite()
    end,
    confirmText = "同意",
    cancelText = "拒绝",
    autoCancelTime = 10,
    hideInWar = true
  })
  g_MakeTeamNotice.m_MakeTeamInviteDlg:ShowCloseBtn(false)
  g_MakeTeamNotice.m_MakeTeamInviteDlg._playerId = pid
end
function g_MakeTeamNotice.MakeTeamNotice_CaptainRequest(pid, name, zs, level)
  if g_MakeTeamNotice.m_CaptainRequestDlg ~= nil then
    for _, info in pairs(g_MakeTeamNotice.m_CaptainRequest) do
      if info.pid == pid then
        return
      end
    end
    if g_MakeTeamNotice.m_CaptainRequestDlg._playerId == pid then
      return
    end
    local d = {
      pid = pid,
      name = name,
      zs = zs,
      level = level
    }
    g_MakeTeamNotice.m_CaptainRequest[#g_MakeTeamNotice.m_CaptainRequest + 1] = d
    return
  end
  local _OnConfirmRequest = function(pid)
    print("===>>同意队长申请", pid)
    g_TeamMgr:send_AgreeCaptainRequest(pid)
  end
  local _OnRefuseRequest = function(pid)
    print("===>>拒绝队长申请", pid)
  end
  local _OnCloseRequest = function()
    g_MakeTeamNotice.m_CaptainRequestDlg = nil
    if #g_MakeTeamNotice.m_CaptainRequest > 0 then
      local temp = table.remove(g_MakeTeamNotice.m_CaptainRequest, 1)
      g_MakeTeamNotice.MakeTeamNotice_CaptainRequest(temp.pid, temp.name, temp.zs, temp.level)
    end
  end
  local autoConfirmTime, autoCancelTime
  if g_TeamMgr:getAutoAgreeCaptainRequest() then
    autoConfirmTime = 10
  else
    autoCancelTime = 10
  end
  local nameColor = NameColor_MainHero[zs] or ccc3(255, 255, 255)
  g_MakeTeamNotice.m_CaptainRequestDlg = CPopWarning.new({
    title = "申请队长",
    text = string.format("玩家#<r:%d,g:%d,b:%d>%s#(%d转%d级),申请成为队长。", nameColor.r, nameColor.g, nameColor.b, name, zs, level),
    confirmFunc = function()
      _OnConfirmRequest(pid)
    end,
    cancelFunc = function()
      _OnRefuseRequest(pid)
    end,
    closeFunc = function()
      _OnCloseRequest()
    end,
    confirmText = "同意",
    cancelText = "拒绝",
    autoConfirmTime = autoConfirmTime,
    autoCancelTime = autoCancelTime,
    hideInWar = true
  })
  g_MakeTeamNotice.m_CaptainRequestDlg:ShowCloseBtn(false)
  g_MakeTeamNotice.m_CaptainRequestDlg._playerId = pid
end
function g_MakeTeamNotice.MakeTeamNotice_CallBackTeam(data)
  if g_MakeTeamNotice.m_CallBackDlgView ~= nil then
    return
  end
  local i_flag = data.i_flag
  local i_type = data.i_type
  local _OnConfirmCallBack = function(flag)
    g_TeamMgr:send_ComebackTeam(flag)
  end
  local _OnRefuseCallBack = function()
    print("===>>拒绝归队")
  end
  local _OnCloseCallBack = function()
    g_MakeTeamNotice.m_CallBackDlgView = nil
  end
  local titleTxt, desc
  if i_flag == 1 then
    titleTxt = "队长召回"
    local teamId = g_TeamMgr:getLocalPlayerTeamId()
    local captainName = g_TeamMgr:getTeamCaptainName(teamId)
    local captainId = g_TeamMgr:getTeamCaptain(teamId)
    local zs = g_TeamMgr:getPlayerZhuanSheng(captainId)
    local nameColor = NameColor_MainHero[zs] or ccc3(255, 255, 255)
    desc = string.format("队长#<r:%d,g:%d,b:%d>%s#召唤你回归队伍。\n\n", nameColor.r, nameColor.g, nameColor.b, captainName)
  elseif i_flag == 2 then
    titleTxt = "队长副本进度"
    desc = [[


]]
  end
  if desc ~= nil then
    if i_type == 1 then
      local t_info = data.t_info
      if t_info ~= nil and activity.tianting ~= nil then
        local monsterData = activity.tianting:getMonsterData()
        for k, v in pairs(t_info) do
          local temp = monsterData[k]
          if temp then
            local tId = temp.missionId
            if tId ~= nil then
              local tempData = data_Mission_Activity[tId]
              if tempData then
                local npcName = tempData.mnName
                desc = string.format("%s%s(%d/%d)\n", desc, npcName, v[1] - 1, v[2])
              end
            end
          end
        end
      end
    elseif i_type == 2 then
      local t_info = data.t_info
      if t_info ~= nil then
        for k, v in pairs(t_info) do
          desc = string.format("%s雁塔降妖(%d/%d)\n", desc, v[1], v[2])
        end
      end
    end
    g_MakeTeamNotice.m_CallBackDlgView = CPopWarning.new({
      title = titleTxt,
      text = desc,
      confirmFunc = function()
        _OnConfirmCallBack(i_flag)
      end,
      cancelFunc = function()
        _OnRefuseCallBack()
      end,
      closeFunc = function()
        _OnCloseCallBack()
      end,
      confirmText = "归队",
      cancelText = "取消",
      autoConfirmTime = 6,
      hideInWar = true
    })
    g_MakeTeamNotice.m_CallBackDlgView:ShowCloseBtn(false)
  end
end
function g_MakeTeamNotice.MakeTeamNotice_BackToNewTeam(pid, name, zs, level)
  if g_MakeTeamNotice.m_BackToNewTeamDlg ~= nil then
    return
  end
  local _OnConfirmBackToNewTeam = function()
    print("_OnConfirmBackToNewTeam")
    netsend.netteam.comebackTeam()
  end
  local _OnCloseBackToNewTeam = function()
    g_MakeTeamNotice.m_BackToNewTeamDlg = nil
  end
  local nameColor = NameColor_MainHero[zs] or ccc3(255, 255, 255)
  g_MakeTeamNotice.m_BackToNewTeamDlg = CPopWarning.new({
    title = "立即归队",
    text = string.format("已加入#<r:%d,g:%d,b:%d>%s#的队伍,是否立即归队?", nameColor.r, nameColor.g, nameColor.b, name),
    confirmFunc = function()
      _OnConfirmBackToNewTeam()
    end,
    clearFunc = function()
      _OnCloseBackToNewTeam()
    end,
    confirmText = "归队",
    cancelText = "取消",
    autoConfirmTime = 6,
    hideInWar = true
  })
  g_MakeTeamNotice.m_BackToNewTeamDlg:ShowCloseBtn(false)
end
function g_MakeTeamNotice._init()
  g_MakeTeamNotice.m_MakeTeamInvite = {}
  g_MakeTeamNotice.m_MakeTeamInviteDlg = nil
  g_MakeTeamNotice.m_CaptainRequest = {}
  g_MakeTeamNotice.m_CaptainRequestDlg = nil
  g_MakeTeamNotice.m_CallBackDlgView = nil
  g_MakeTeamNotice.m_BackToNewTeamDlg = nil
end
g_MakeTeamNotice._init()
gamereset.registerResetFunc(function()
  g_MakeTeamNotice._init()
end)
