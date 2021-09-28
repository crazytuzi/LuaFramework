local netmission = {}
function netmission.reqComplete(i_type, o_dst, missionId)
  NetSend({
    i_type = i_type,
    o_dst = o_dst,
    i_mid = missionId
  }, "task", "P1")
end
function netmission.reqAccept(i_tid)
  NetSend({i_tid = i_tid}, "task", "P2")
end
function netmission.reqGiveup(i_tid)
  NetSend({i_tid = i_tid}, "task", "P3")
end
function netmission.reqAcceptByType(t, param)
  NetSend({type = t, extra = param}, "task", "P10")
end
function netmission.reqCommitByType(t, taskid, mext)
  NetSend({
    type = t,
    taskid = taskid,
    ext = mext
  }, "task", "P11")
end
function netmission.reqGiveupByType(t, taskid)
  NetSend({type = t, taskid = taskid}, "task", "P12")
end
function netmission.reqFinishByType(t, taskid)
  NetSend({type = t, taskid = taskid}, "task", "P13")
end
function netmission.commitAnser(manswer)
  NetSend({answer = manswer}, "task", "P14")
end
function netmission.commitBusinessTrace(mnpcid, mitemid)
  NetSend({npcid = mnpcid, itemid = mitemid}, "task", "P15")
end
function netmission.reqReSetMissionSJLL(mtype, mtaskid)
  NetSend({type = mtype, taskid = mtaskid}, "task", "P16")
end
function netmission.reqCommitPetList(mtype, mtaskid)
  NetSend({type = mtype, taskid = mtaskid}, "task", "P17")
end
function netmission.reqAcceptZhuaGui()
  netmission.reqAcceptByType(601)
end
function netmission.reqCommitZhuaGui(taskid)
  netmission.reqCommitByType(601, taskid)
end
function netmission.reqGiveupZhuaGui(taskid)
  netmission.reqGiveupByType(601, taskid)
end
function netmission.reqAcceptXiuLuo()
  netmission.reqAcceptByType(1201)
end
function netmission.reqCommitXiuLuo(taskid)
  netmission.reqCommitByType(1201, taskid)
end
function netmission.reqGiveupXiuLuo(taskid)
  netmission.reqGiveupByType(1201, taskid)
end
return netmission
