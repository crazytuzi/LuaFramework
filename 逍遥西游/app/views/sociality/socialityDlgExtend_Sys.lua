socialityDlgExtend_Sys = {}
function socialityDlgExtend_Sys.extend(object)
  function object:InitSys()
    object.list_sys = object:getNode("list_sys")
    object:resizeList(object.list_sys)
    object:ShowSys()
  end
  function object:ShowSys()
    if object.m_SysBox == nil then
      object.m_SysBox = CSysChat.new(object.list_sys, handler(object, object.OnClickMessage))
    end
  end
  function object:Clear_SysExtend()
    if object.m_SysBox then
      object.m_SysBox:Clear()
      object.m_SysBox = nil
    end
  end
  object:InitSys()
end
