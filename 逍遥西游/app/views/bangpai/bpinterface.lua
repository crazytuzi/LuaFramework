function ShowBangPaiDlg()
  if g_BpMgr:localPlayerHasBangPai() then
    if g_CBpJoinCreateHandler then
      g_CBpJoinCreateHandler:CloseSelf()
    end
    if g_CBpInfoHandler then
      g_CBpInfoHandler:CloseSelf()
    end
    getCurSceneView():addSubView({
      subView = CBpInfo.new(),
      zOrder = MainUISceneZOrder.menuView
    })
  else
    if g_CBpJoinCreateHandler then
      g_CBpJoinCreateHandler:CloseSelf()
    end
    if g_CBpInfoHandler then
      g_CBpInfoHandler:CloseSelf()
    end
    local dlg = getCurSceneView():addSubView({
      subView = CBpJoinCreate.new(),
      zOrder = MainUISceneZOrder.menuView
    })
    dlg:TempHide()
  end
end
