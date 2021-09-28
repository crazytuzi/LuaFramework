socialityDlgExtend_LaBa = {}
function socialityDlgExtend_LaBa.extend(object)
  function object:InitLaBa()
    object.list_laba = object:getNode("list_laba")
    object:resizeList(object.list_laba)
    object:ShowLaBa()
  end
  function object:ShowLaBa()
    if object.m_LaBaBox == nil then
      object.m_LaBaBox = CLaBaChat.new(object.list_laba, handler(object, object.OnClickMessage))
    end
  end
  function object:Clear_LaBaExtend()
    if object.m_LaBaBox then
      object.m_LaBaBox:Clear()
      object.m_LaBaBox = nil
    end
  end
  object:InitLaBa()
end
