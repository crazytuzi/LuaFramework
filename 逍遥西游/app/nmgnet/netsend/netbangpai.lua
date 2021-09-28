local netbangpai = {}
function netbangpai.getTotalBpListInfo(i_index)
  NetSend({i_index = i_index}, S2C_BP, "P1")
end
function netbangpai.getBpTenet(i_bpid)
  NetSend({i_bpid = i_bpid}, S2C_BP, "P2")
end
function netbangpai.requestJoinBp(i_bpid)
  NetSend({i_bpid = i_bpid}, S2C_BP, "P3")
end
function netbangpai.requestJoinAllBp()
  NetSend({}, S2C_BP, "P4")
end
function netbangpai.requestTotalBpAmount()
  NetSend({}, S2C_BP, "P5")
end
function netbangpai.createNewBp(s_bpname, s_tenet)
  NetSend({s_bpname = s_bpname, s_tenet = s_tenet}, S2C_BP, "P6")
end
function netbangpai.requestBpBaseInfo()
  NetSend({}, S2C_BP, "P7")
end
function netbangpai.getBpMemberInfo(i_index)
  NetSend({i_index = i_index}, S2C_BP, "P8")
end
function netbangpai.quitBangPai()
  NetSend({}, S2C_BP, "P9")
end
function netbangpai.getBpRequestListInfo(i_index)
  NetSend({i_index = i_index}, S2C_BP, "P10")
end
function netbangpai.getBpRequestAmount()
  NetSend({}, S2C_BP, "P11")
end
function netbangpai.agreeBpJoinRequest(i_pid)
  NetSend({i_pid = i_pid}, S2C_BP, "P12")
end
function netbangpai.clearBpRequest()
  NetSend({}, S2C_BP, "P13")
end
function netbangpai.publishBpNotice(i_id, s_notice)
  NetSend({i_id = i_id, s_notice = s_notice}, S2C_BP, "P14")
end
function netbangpai.getAllBpNotice()
  NetSend({}, S2C_BP, "P15")
end
function netbangpai.closeBpInfoDlg()
  NetSend({}, S2C_BP, "P16")
end
function netbangpai.contributeOffer(i_num)
  NetSend({i_num = i_num}, S2C_BP, "P18")
end
function netbangpai.setBangPaiPlace(i_pid, i_place)
  NetSend({i_pid = i_pid, i_place = i_place}, S2C_BP, "P20")
end
function netbangpai.banWordOfPlayer(i_pid)
  NetSend({i_pid = i_pid}, S2C_BP, "P21")
end
function netbangpai.cancelBanWordOfPlayer(i_pid)
  NetSend({i_pid = i_pid}, S2C_BP, "P22")
end
function netbangpai.kickOutBpMember(i_pid)
  NetSend({i_pid = i_pid}, S2C_BP, "P24")
end
function netbangpai.getBpAchievePoint()
  NetSend({}, S2C_BP, "P25")
end
function netbangpai.setMyMainOrFuTotem(i_flag, i_totemid)
  NetSend({i_flag = i_flag, i_totemid = i_totemid}, S2C_BP, "P26")
end
function netbangpai.getBpTotemInfo()
  NetSend({}, S2C_BP, "P27")
end
function netbangpai.getBanWordTime(i_pid)
  NetSend({i_pid = i_pid}, S2C_BP, "P28")
end
function netbangpai.getBpPlaceNumInfo()
  NetSend({}, S2C_BP, "P30")
end
function netbangpai.deleteBpNotice(i_id)
  NetSend({i_id = i_id}, S2C_BP, "P31")
end
function netbangpai.getTodayBpUnlockTotemTimes()
  NetSend({}, S2C_BP, "P32")
end
function netbangpai.publishTaskToken(i_type)
  NetSend({i_type = i_type}, S2C_BP, "P33")
end
function netbangpai.editBpTenet(s_tenet)
  NetSend({s_tenet = s_tenet}, S2C_BP, "P34")
end
function netbangpai.getTodayBpPaoShangTimes()
  NetSend({}, S2C_BP, "P35")
end
function netbangpai.changeBpLeader(i_pid)
  NetSend({i_pid = i_pid}, S2C_BP, "P36")
end
function netbangpai.getAllFuLeaders()
  NetSend({}, S2C_BP, "P37")
end
function netbangpai.requestRejectBpLeader()
  NetSend({}, S2C_BP, "P38")
end
function netbangpai.voteRejectBpLeader()
  NetSend({}, S2C_BP, "P39")
end
function netbangpai.changeBpName(s_name)
  NetSend({s_name = s_name}, S2C_BP, "P40")
end
return netbangpai
