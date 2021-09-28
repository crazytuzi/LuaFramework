JiuguanExtend = {}
function JiuguanExtend.extend(object)
  object.m_JiuguanHeroList = {}
  object.m_JiuguanData = {}
  object.m_FlushJiuguanTime = 0
  object.m_JiuguanTimer = nil
  object.m_JiuguanOpenList = {}
  function object:setJiuguanOpenList(openList)
    object.m_JiuguanOpenList = openList
    SendMessage(MsgID_JiuguanOpenListUpdate, {
      pid = object.m_RoleId,
      openList = openList
    })
  end
  function object:getJiuguanOpenList()
    return DeepCopyTable(object.m_JiuguanOpenList)
  end
end
return JiuguanExtend
