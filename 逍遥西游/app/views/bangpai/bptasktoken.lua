BpTaskTokenDlg = {}
function BpTaskTokenDlg.RenWuLing_MuJi(funcId)
  local place = g_BpMgr:getLocalBpPlace()
  if place ~= BP_PLACE_LEADER and place ~= BP_PLACE_FULEADER then
    ShowNotifyTips("你不是帮主或副帮主，我无法为你效劳")
    return false
  end
  local data = data_Org_RenWuLing[funcId] or {}
  local tempPop = CPopWarning.new({
    title = data.Name or "",
    text = data.Desc or "",
    confirmFunc = function()
      BangPaiRenWuLing.reqAcceptTaskToken(TASKTOKEN_MUJI)
    end,
    align = CRichText_AlignType_Left,
    confirmText = "确定"
  })
  tempPop:ShowCloseBtn(false)
  return false
end
function BpTaskTokenDlg.RenWuLing_AnZhan(funcId)
  local place = g_BpMgr:getLocalBpPlace()
  if place ~= BP_PLACE_LEADER and place ~= BP_PLACE_FULEADER then
    ShowNotifyTips("你不是帮主或副帮主，我无法为你效劳")
    return false
  end
  local data = data_Org_RenWuLing[funcId] or {}
  local tempPop = CPopWarning.new({
    title = data.Name or "",
    text = data.Desc or "",
    confirmFunc = function()
      BangPaiRenWuLing.reqAcceptTaskToken(TASKTOKEN_ANZHAN)
    end,
    align = CRichText_AlignType_Left,
    confirmText = "确定"
  })
  tempPop:ShowCloseBtn(false)
  return false
end
function BpTaskTokenDlg.RenWuLing_ChuMo(funcId)
  local place = g_BpMgr:getLocalBpPlace()
  if place ~= BP_PLACE_LEADER and place ~= BP_PLACE_FULEADER then
    ShowNotifyTips("你不是帮主或副帮主，我无法为你效劳")
    return false
  end
  local data = data_Org_RenWuLing[funcId] or {}
  local tempPop = CPopWarning.new({
    title = data.Name or "",
    text = data.Desc or "",
    confirmFunc = function()
      BangPaiRenWuLing.reqAcceptTaskToken(TASKTOKEN_CHUMO)
    end,
    align = CRichText_AlignType_Left,
    confirmText = "确定"
  })
  tempPop:ShowCloseBtn(false)
  return false
end
function BpTaskTokenDlg.RenWuLing_TuiWeiRangXian(funcId)
  local place = g_BpMgr:getLocalBpPlace()
  if place ~= BP_PLACE_LEADER then
    ShowNotifyTips("你不是帮主，我无法为你效劳")
    return false
  end
  local data = data_Org_RenWuLing[funcId] or {}
  local tempPop = CPopWarning.new({
    title = data.Name or "",
    text = data.Desc or "",
    confirmFunc = function()
      g_BpMgr:send_getAllFuLeaders()
    end,
    align = CRichText_AlignType_Left,
    confirmText = "确定"
  })
  tempPop:ShowCloseBtn(false)
  return false
end
