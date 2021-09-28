local netbaseptc = {}
function netbaseptc.addexp(i_hid, i_exp)
  NetSend({i_hid = i_hid, i_exp = i_exp}, "base", "P1")
end
function netbaseptc.setheropro(i_hid, i_gg, i_lx, i_ll, i_mj)
  NetSend({
    i_hid = i_hid,
    i_gg = i_gg,
    i_lx = i_lx,
    i_ll = i_ll,
    i_mj = i_mj
  }, "base", "P2")
end
function netbaseptc.setheroname(i_hid, s_name)
  NetSend({i_hid = i_hid, s_name = s_name}, "base", "P3")
end
function netbaseptc.setpetpro(i_hid, i_gg, i_lx, i_ll, i_mj)
  NetSend({
    i_pid = i_hid,
    i_gg = i_gg,
    i_lx = i_lx,
    i_ll = i_ll,
    i_mj = i_mj
  }, "base", "P4")
end
function netbaseptc.setpetname(i_hid, s_name)
  NetSend({i_pid = i_hid, s_name = s_name}, "base", "P5")
end
function netbaseptc.setEquipPet(i_hid, i_pid)
  NetSend({i_hid = i_hid, i_pid = i_pid}, "base", "P6")
end
function netbaseptc.setSkillProficiency(i_snum, i_pnum)
  NetSend({i_snum = i_snum, i_pnum = i_pnum}, "base", "P7")
end
function netbaseptc.setLianYaoPet(i_pid, i_itemId)
  NetSend({i_pid = i_pid, i_itemId = i_itemId}, "base", "P9")
end
function netbaseptc.flushServerTime()
  NetSend({}, "base", "P10")
end
function netbaseptc.requestZuoqi(i_type)
  NetSend({i_type = i_type}, "base", "P11")
end
function netbaseptc.requestZuoqiManagePet(i_zid, i_pid)
  NetSend({i_zid = i_zid, i_pid = i_pid}, "base", "P12")
end
function netbaseptc.requestZuoqiRemovePet(i_zid, i_pid)
  NetSend({i_zid = i_zid, i_pid = i_pid}, "base", "P13")
end
function netbaseptc.requestUpgradeZuoqiSkillPValue(i_zid)
  NetSend({i_zid = i_zid}, "base", "P14")
end
function netbaseptc.requestZuoqiLearnSkill(i_zid, i_skillId)
  NetSend({i_zid = i_zid, i_skillId = i_skillId}, "base", "P15")
end
function netbaseptc.requestZuoqiChangeSkill(i_zid, i_skillId, i_ns)
  NetSend({
    i_zid = i_zid,
    i_skillId = i_skillId,
    i_ns = i_ns
  }, "base", "P16")
end
function netbaseptc.requestDianHuaZuoqi(i_zid)
  NetSend({i_zid = i_zid}, "base", "P17")
end
function netbaseptc.requestBuyArch()
  NetSend({}, "base", "P18")
end
function netbaseptc.resetUpgradeZuoqiSkillPValueCDTime(i_zid)
  NetSend({i_zid = i_zid}, "base", "P19")
end
function netbaseptc.resetFireHero(i_hid)
  NetSend({i_hid = i_hid}, "base", "P20")
end
function netbaseptc.resetFirePet(i_pid)
  NetSend({i_pid = i_pid}, "base", "P21")
end
function netbaseptc.requestAddSkillExp(i_skillNo, i_type)
  NetSend({i_i = i_skillNo, i_type = i_type}, "base", "P22")
end
function netbaseptc.requestAddHeroStarP(i_p, t_p)
  NetSend({i_p = i_p, t_p = t_p}, "base", "P23")
end
function netbaseptc.requestShenShouHuaJing(i_p, i_n, i_cz)
  NetSend({
    i_p = i_p,
    i_n = i_n,
    i_cz = i_cz
  }, "base", "P24")
end
function netbaseptc.requestSetShenShouHJCZ(i_p, i_cz)
  NetSend({i_p = i_p, i_cz = i_cz}, "base", "P25")
end
function netbaseptc.requestLingShouHuaLing(i_p)
  NetSend({i_p = i_p}, "base", "P26")
end
function netbaseptc.requestAutoAddRolePoint(i_id, i_gg, i_lx, i_ll, i_mj)
  NetSend({
    i_id = i_id,
    i_gg = i_gg,
    i_lx = i_lx,
    i_ll = i_ll,
    i_mj = i_mj
  }, "base", "P30")
end
function netbaseptc.cancelAutoAddRolePoint(i_id)
  NetSend({i_id = i_id}, "base", "P31")
end
function netbaseptc.requestAutoAddRolePointInfo(i_id)
  NetSend({i_id = i_id}, "base", "P32")
end
function netbaseptc.requestHeroZS(i_s, s_n)
  NetSend({i_s = i_s, s_n = s_n}, "base", "P33")
end
function netbaseptc.requestPetZS(i_p)
  NetSend({i_p = i_p}, "base", "P34")
end
function netbaseptc.requestSetWingPro(i_t)
  NetSend({i_t = i_t}, "base", "P35")
end
function netbaseptc.requestNewPet(i_ptype)
  g_NetConnectMgr:showLoadingLayer(1)
  NetSend({i_ptype = i_ptype}, "base", "P36")
end
function netbaseptc.requestPlayerPetInfo(i_playerid, i_pid)
  NetSend({i_playerid = i_playerid, i_pid = i_pid}, "base", "P50")
end
function netbaseptc.requestPlayerPetSkillInfo(i_playerid, i_pid, i_skillid)
  NetSend({
    i_playerid = i_playerid,
    i_pid = i_pid,
    i_skillid = i_skillid
  }, "base", "P51")
end
function netbaseptc.requestSetPetAutoFightData(i_pid, i_auto)
  NetSend({i_pid = i_pid, i_auto = i_auto}, "base", "P52")
end
function netbaseptc.requestSvrOpenLevelInfo()
  NetSend({}, "base", "P60")
end
function netbaseptc.requestExchangeByGold(resid, num, reason)
  NetSend({
    resid = resid,
    num = num,
    reason = reason
  }, "base", "P61")
end
function netbaseptc.requestSetRanColor(t_r)
  NetSend({t_r = t_r}, "base", "P62")
end
function netbaseptc.requestAddPetCloseOnce(i_pid)
  NetSend({i_pid = i_pid}, "base", "P63")
end
function netbaseptc.requestAddPetCloseForOneLevel(i_pid)
  NetSend({i_pid = i_pid}, "base", "P64")
end
function netbaseptc.requestAddZuoqiLvOnce(i_zid)
  NetSend({i_zid = i_zid}, "base", "P65")
end
function netbaseptc.requestAddZuoqiLvAllAch(i_zid)
  NetSend({i_zid = i_zid}, "base", "P66")
end
function netbaseptc.requestUnlockSkillPos(i_pid, superskill)
  NetSend({i_pid = i_pid, superskill = superskill}, "base", "P67")
end
function netbaseptc.requestOpenSkillPos(i_pid, superskill)
  NetSend({i_pid = i_pid, superskill = superskill}, "base", "P68")
end
function netbaseptc.deleteSkillAtPos(i_pid, pos, superskill)
  NetSend({
    i_pid = i_pid,
    pos = pos,
    superskill = superskill
  }, "base", "P69")
end
function netbaseptc.requestLearnSSSkill(i_pid, skillId)
  NetSend({i_pid = i_pid, skillId = skillId}, "base", "P70")
end
function netbaseptc.requestChange6Zuoqi(i_zid, i_oldt, i_newt)
  NetSend({
    i_zid = i_zid,
    i_oldt = i_oldt,
    i_newt = i_newt
  }, "base", "P71")
end
function netbaseptc.requestChangeRace(i_newt)
  NetSend({i_newt = i_newt}, "base", "P72")
end
function netbaseptc.UseTaiXuDanForPet(i_pid, i_skillid)
  NetSend({i_pid = i_pid, i_skillid = i_skillid}, "base", "P73")
end
function netbaseptc.UseTaiXuDan_YJXLForPet(i_pid, i_skillid)
  NetSend({i_pid = i_pid, i_skillid = i_skillid}, "base", "P74")
end
function netbaseptc.setSyncPlayerType(iType)
  NetSend({i_i = iType}, "base", "P80")
end
function netbaseptc.getAllChengwei()
  NetSend({}, "base", "P81")
end
function netbaseptc.setAllChengwei(cwId)
  NetSend({id = cwId}, "base", "P82")
end
function netbaseptc.HideChengwei()
  NetSend({}, "base", "P83")
end
function netbaseptc.ChengweiXuFei(id)
  NetSend({id = id}, "base", "P84")
end
function netbaseptc.SetZhuanShengXiuZheng(i_zs, i_i)
  NetSend({i_zs = i_zs, i_i = i_i}, "base", "P85")
end
function netbaseptc.ChangeWuXingPro(t_wx)
  NetSend({t_wx = t_wx}, "base", "P86")
end
function netbaseptc.UpgradeOneKindSkill(i_i, i_type)
  NetSend({i_i = i_i, i_type = i_type}, "base", "P90")
end
function netbaseptc.GetChongZhiFanliAward(id)
  NetSend({id = id}, "base", "P91")
end
function netbaseptc.setCertainSetting(id, val)
  NetSend({id = id, val = val}, "base", "P92")
end
function netbaseptc.setExtraPetLimitNum()
  NetSend({}, "base", "P93")
end
function netbaseptc.reportPlayer(pid, i_id, msg, jb_msg)
  NetSend({
    pid = pid,
    i_id = i_id,
    msg = msg,
    jb_msg = jb_msg
  }, "base", "P94")
end
function netbaseptc.addPingbiName(mpid)
  NetSend({pid = mpid}, "base", "P95")
end
function netbaseptc.removePingbiName(mpid)
  NetSend({pid = mpid}, "base", "P96")
end
function netbaseptc.checkLoginNotice(issue)
  NetSend({i_i = issue}, "base", "P100")
end
function netbaseptc.rideZuoqi(zqId)
  NetSend({i_zqUID = zqId}, "base", "P117")
end
return netbaseptc
