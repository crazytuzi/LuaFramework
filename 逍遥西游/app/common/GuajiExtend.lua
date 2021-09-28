GUAJI_STATE_ON = 1
GUAJI_STATE_OFF = 2
GUAJI_AUTOADDBSD_ON = 1
GUAJI_AUTOADDBSD_OFF = 0
GuajiExtend = {}
function GuajiExtend.extend(object)
  object.m_GuajiState = GUAJI_STATE_OFF
  object.m_GuajiAutoFlag = GUAJI_AUTOADDBSD_OFF
  function object:setGuajiState(state)
    state = state or GUAJI_STATE_OFF
    local oldGuajiState = object.m_GuajiState
    object.m_GuajiState = state
    SendMessage(MsgID_GuajiUpdate, {
      pid = object.m_RoleId,
      oldGuajiState = oldGuajiState,
      newGuajiState = state
    })
  end
  function object:getGuajiState()
    return object.m_GuajiState
  end
  function object:setGuajiAutoAddBsd(flag)
    flag = flag or GUAJI_AUTOADDBSD_OFF
    object.m_GuajiAutoFlag = flag
    SendMessage(MsgID_GuajiUpdateAutoAddBsd)
  end
  function object:getGuajiAutoAddBsd()
    return object.m_GuajiAutoFlag
  end
end
return GuajiExtend
