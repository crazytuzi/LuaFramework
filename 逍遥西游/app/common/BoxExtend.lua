BoxExtend = {}
function BoxExtend.extend(object)
  object.m_BoxData = {}
  object.m_FlushBoxTime = 0
  object.m_BoxTimer = nil
  function object:setBoxData(i_nlnum, i_nlt, i_slnum, i_slt)
    local proTable = {}
    proTable.i_nlnum = i_nlnum
    proTable.i_nlt = i_nlt
    proTable.i_slnum = i_slnum
    proTable.i_slt = i_slt
    if i_nlnum ~= nil then
      object.m_BoxData.i_nlnum = i_nlnum
    end
    if i_nlt ~= nil then
      object.m_BoxData.i_nlt = i_nlt
    end
    if i_slnum ~= nil then
      object.m_BoxData.i_slnum = i_slnum
    end
    if i_slt ~= nil then
      object.m_BoxData.i_slt = i_slt
    end
    local curTime = os.time()
    object.m_BoxData.getDataTime = curTime
    local addTime = math.min(object.m_BoxData.i_slt or 0, object.m_BoxData.i_nlt or 0)
    if addTime == 0 then
      object.m_FlushBoxTime = 0
    else
      object.m_FlushBoxTime = curTime + addTime
    end
    if object.m_BoxTimer == nil then
      object.StartBoxTimer()
    end
    SendMessage(MsgID_BoxDataUpdate, {
      pid = object.m_RoleId,
      pro = proTable
    })
  end
  function object:getBoxData()
    return DeepCopyTable(object.m_BoxData)
  end
  function object:StartBoxTimer()
    if object.m_BoxTimer then
      scheduler.unscheduleGlobal(object.m_BoxTimer)
    end
    object.m_BoxTimer = scheduler.scheduleGlobal(function()
      if object.CheckBoxUpdate then
        object:CheckBoxUpdate()
      end
    end, 1)
  end
  function object:DelBoxTimer()
    if object.m_BoxTimer then
      scheduler.unscheduleGlobal(object.m_BoxTimer)
      object.m_BoxTimer = nil
    end
  end
  function object:CheckBoxUpdate()
    if object.m_FlushBoxTime == nil or object.m_FlushBoxTime == 0 then
    elseif g_DataMgr:getServerTime() >= object.m_FlushBoxTime then
      netsend.netbox.askBoxState()
    end
  end
end
return BoxExtend
