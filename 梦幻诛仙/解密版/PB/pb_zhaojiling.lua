local Lplus = require("Lplus")
local pb_commoninvite = require("PB.pb_commoninvite")
local ECGame = require("Main.ECGame")
local bit = require("bit")
local band = bit.band
local CommonInvite = require("Protocol.CommonInvite")
local function on_respond(sender, xid, msg)
  local StringTable = require("Data.StringTable")
  local NATION_DATA = require("Social.ECNationData")
  local FACTION_DATA = require("Social.ECFactionData")
  local ECNationMan = require("Social.ECNationMan")
  local baseinfo = msg.baseinfo
  local caller_name = GameUtil.UnicodeToUtf8(baseinfo.src_name)
  local delay_time = baseinfo.delay_time
  local scene_tag = baseinfo.scene_tag
  local _type = baseinfo.type
  local zhaojiling_id = baseinfo.zhaojiling_id
  local position = "Error"
  if baseinfo.src_nation_position > 0 then
    position = NATION_DATA.OFFICER_ID_TO_NAME[baseinfo.src_nation_position]
  elseif 0 <= baseinfo.src_corp_position then
    position = FACTION_DATA.faction_position_to_name[baseinfo.src_corp_position]
  end
  print(LuaUInt64.ToString(baseinfo.src), caller_name, position, baseinfo.src_nation_position, baseinfo.src_corp_position, _type, delay_time, zhaojiling_id, scene_tag)
  if delay_time == 0 then
    delay_time = 60
  end
  if _type == 1 then
    local theGame = ECGame.Instance()
    local Inst = theGame.m_Instance
    if Inst.m_curInstanceId ~= 0 then
      return
    end
    local ECNationWarEffect = require("GUI.ECNationWarEffect")
    local selfnation = ECGame.Instance().m_HostPlayer.InfoData.Nation
    local betnation = baseinfo.param1
    local attack, defend = ECNationMan.Instance():GetAttackAndDefend(selfnation, betnation)
    if attack > 0 and defend > 0 then
      ECNationWarEffect.NationWarOpenEffect():Popup(attack, defend, xid, delay_time)
    else
      ECNationWarEffect.NationWarOpenEffect():Popup(selfnation, betnation, xid, delay_time)
      ECNationMan.Instance():DebugNationStatus()
      ECNationMan.GetNationWarInfo()
      ECNationMan.GetNationInfo()
    end
  elseif _type == 2 then
    do
      local theGame = ECGame.Instance()
      local Inst = theGame.m_Instance
      if Inst.m_curInstanceId ~= 0 then
        return
      end
      local strformat = StringTable.Get(99)
      local showmsg = string.format(strformat, position, caller_name, delay_time)
      MsgBox.ShowMsgBoxEx(nil, showmsg, "", bit.bor(MsgBox.MsgBoxType.MBBT_OKCANCEL, MsgBox.MsgBoxType.MBT_OVERTIME), function(mb, ret)
        local ci = CommonInvite()
        if ret == MsgBox.MsgBoxRetT.MBRT_OVERTIME then
          FlashTipMan.FlashTip(StringTable.Get(76))
          return
        elseif ret == MsgBox.MsgBoxRetT.MBRT_OK then
          ci.retcode = 0
        else
          ci.retcode = 1
        end
        ci.xid = band(xid, 2147483647)
        ECGame.Instance().m_Network:SendProtocol(ci)
        ECNationMan.GetNationWarInfo()
        if ret == MsgBox.MsgBoxRetT.MBRT_OVERTIME then
          local WarStatus = require("Event.WarStatus")
          local selfnation = ECGame.Instance().m_HostPlayer.InfoData.Nation
          local betnation = ECNationMan.Instance():GetNationWarNation()
          local attack, defend = ECNationMan.Instance():GetAttackAndDefend(selfnation, betnation)
          ECGame.EventManager:raiseEvent(nil, WarStatus.new(NATION_DATA.WAR_STATUS.GUO_ZHAN, self.attack, self.defend))
        end
      end, delay_time, function(thebox)
        showmsg = string.format(strformat, position, caller_name, thebox.LifeTime)
        thebox:SetText(showmsg)
      end)
    end
  else
    do
      local strformat = StringTable.Get(60)
      local ttl = baseinfo.delay_time
      if ttl == 0 then
        ttl = 60
      end
      local showmsg = string.format(strformat, position, caller_name, ttl)
      MsgBox.ShowMsgBoxEx(nil, showmsg, nil, MsgBox.MsgBoxType.MBBT_OKCANCEL, function(mb, ret)
        print("ret ", ret)
        local ci = CommonInvite()
        if ret == MsgBox.MsgBoxRetT.MBRT_OK then
          ci.retcode = 0
        else
          ci.retcode = 1
        end
        ci.xid = band(xid, 2147483647)
        ECGame.Instance().m_Network:SendProtocol(ci)
      end, ttl, function(thebox)
        ttl = ttl - 1
        if ttl >= 0 then
          showmsg = string.format(strformat, position, caller_name, ttl)
          thebox:SetText(showmsg)
        end
      end)
    end
  end
end
pb_commoninvite.AddHandler("npt_zhaojiling", on_respond)
