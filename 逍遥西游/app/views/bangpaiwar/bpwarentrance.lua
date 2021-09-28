BpwarEntrance = {}
function BpwarEntrance.extend(object)
  function object:InitBpwarEntrance()
    local btnBatchListener = {
      btn_bpwar = {
        listener = handler(object, object.Btn_BpWar),
        variName = "btn_bpwar"
      }
    }
    object:addBatchBtnListener(btnBatchListener)
    object:checkBpWarStateForBtn()
  end
  function object:checkBpWarStateForBtn()
    if g_BpMgr:localPlayerHasBangPai() and g_BpWarMgr:getBpWarState() == BPWARSTATE_READY and not g_MapMgr:IsInBangPaiWarMap() then
      object.btn_bpwar:setVisible(true)
      object.btn_bpwar:setTouchEnabled(true)
      if object.btn_bpwar._action == nil then
        object.btn_bpwar._action = CCRepeatForever:create(transition.sequence({
          CCDelayTime:create(3),
          CCScaleTo:create(0.12, 1.1),
          CCScaleTo:create(0.12, 1),
          CCScaleTo:create(0.1, 1.15),
          CCScaleTo:create(0.1, 1)
        }))
        object.btn_bpwar:runAction(object.btn_bpwar._action)
      end
    else
      object.btn_bpwar:setVisible(false)
      object.btn_bpwar:setTouchEnabled(false)
      if object.btn_bpwar._action ~= nil then
        object.btn_bpwar:stopAction(object.btn_bpwar._action)
        object.btn_bpwar._action = nil
      end
    end
    if object.checkBtnEntrancePos ~= nil then
      object:checkBtnEntrancePos()
    end
  end
  function object:Btn_BpWar(btnObj, touchType)
    if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
      ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
      return
    end
    g_MapMgr:stopLocalPlayerMove()
    g_BpWarMgr:send_gotoWarMap()
  end
  object:InitBpwarEntrance()
end
