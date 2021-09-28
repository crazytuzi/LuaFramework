local netnotify = {}
netnotify.BoxType_QieCuo = 2
CF_MSG_CATCHOGHOST_GONPC = 12
CF_MSG_GHOSTKING_GONPC = 13
CF_MSG_XIULUO_GONPC = 18
function netnotify.msg(param, ptc_main, ptc_sub)
  print("netnotify.msg:", param, ptc_main, ptc_sub)
  local msg = param.s_msg
  if msg then
    if param.filter == 1 then
      msg = filterChatText_DFAFilter(msg)
    end
    msg = CheckStringIsLegal(msg, true, REPLACECHAR_FOR_INVALIDTIP)
    ShowNotifyViews(msg)
  end
end
function netnotify.tips(param, ptc_main, ptc_sub)
  print("netnotify.tips:", param, ptc_main, ptc_sub)
  local msg = param.s_msg
  if msg then
    msg = CheckStringIsLegal(msg, true, REPLACECHAR_FOR_INVALIDTIP)
    ShowNotifyTips(msg, param.i_s)
  end
end
function netnotify.tipsNotShowAfterWar(param, ptc_main, ptc_sub)
  print("netnotify.tipsNotShowAfterWar:", param, ptc_main, ptc_sub)
  local msg = param.s_msg
  if msg then
    msg = CheckStringIsLegal(msg, true, REPLACECHAR_FOR_INVALIDTIP)
    ShowNotifyTipsAfterWar(msg, param.i_s)
  end
end
function netnotify.confirmBox(param, ptc_main, ptc_sub)
  print("netnotify.confirmBox:", param, ptc_main, ptc_sub)
  local msg = param.s_msg
  msg = CheckStringIsLegal(msg, true, REPLACECHAR_FOR_INVALIDTIP)
  local boxId = param.i_id
  local s_title = param.s_title or "提示"
  local s_btns = param.s_btns or {}
  local cancelText = s_btns[1] or "取消"
  local confirmText = s_btns[2] or "确定"
  local i_cb = param.i_cb
  print("boxId:", boxId, type(boxId))
  local autoConfirmTime, autoCancelTime
  local hideInWar = false
  if boxId == netnotify.BoxType_QieCuo then
    if not g_MapMgr:isPlayerInBiwuchang() then
      print("--->>收到切磋请求时，自己已经不在比武场了，所以不显示切磋确认框")
      return
    end
    autoCancelTime = 10
    hideInWar = true
  end
  if CF_MSG_CATCHOGHOST_GONPC == boxId then
    ZhuaGui.popConfirmView(msg)
  elseif CF_MSG_GHOSTKING_GONPC == boxId then
    GuiWang.popConfirmView(msg)
  elseif CF_MSG_XIULUO_GONPC == boxId then
    XiuLuo.popConfirmView(msg)
  else
    local confirmBoxDlg = CPopWarning.new({
      title = s_title,
      text = msg,
      confirmFunc = function()
        netsend.netnotify.confirmBoxToServer(boxId, 2)
      end,
      cancelFunc = function()
        if i_cb ~= nil then
          netsend.netnotify.confirmBoxToServer(boxId, 1)
        end
      end,
      clearFunc = function(obj)
        if obj == netnotify._qiecuoBox then
          netnotify._qiecuoBox = nil
        end
      end,
      cancelText = cancelText,
      confirmText = confirmText,
      autoConfirmTime = autoConfirmTime,
      autoCancelTime = autoCancelTime,
      hideInWar = hideInWar
    })
    confirmBoxDlg:ShowCloseBtn(false)
  end
  if boxId == netnotify.BoxType_QieCuo then
    if netnotify._qiecuoBox ~= nil then
      netnotify._qiecuoBox:OnClose()
      netnotify._qiecuoBox = nil
    end
    netnotify._qiecuoBox = confirmBoxDlg
  end
end
function netnotify.msgNotInWar(param, ptc_main, ptc_sub)
  print("netnotify.msgNotInWar:", param, ptc_main, ptc_sub)
  local msg = param.s_msg
  if msg then
    msg = CheckStringIsLegal(msg, true, REPLACECHAR_FOR_INVALIDTIP)
    ShowNotifyViewsNotInWar(msg)
  end
end
function netnotify.commonView(param, ptc_main, ptc_sub)
  print("netnotify.commonView:", param, ptc_main, ptc_sub)
  if param == nil then
    return
  end
  local id = param.id
  local viewType = param.type
  if viewType == 1 then
    local buttons = param.buttons or {}
    local content = param.content
    local needGold = content.g_num or 0
    local res = content.res or {}
    local items
    if content.items then
      items = {}
      for k, v in pairs(content.items) do
        items[v.itemid] = v.num
      end
    end
    ShowResShortageView(id, param.title, {
      objs = items,
      coin = res[tostring(RESTYPE_COIN)],
      silver = res[tostring(RESTYPE_SILVER)]
    }, needGold, buttons[1])
  end
  PutItemToUpgradePackageZhuangbei()
  PutItemToUpgradeZhuangbei()
  ResetCreateZhuangbei()
end
function netnotify.noticeView(param, ptc_main, ptc_sub)
  local title = param.title
  local content = param.content
  content = CheckStringIsLegal(content, true, REPLACECHAR_FOR_INVALIDTIP)
  local hideInWar = false
  if param.delay ~= nil and param.delay ~= 0 then
    hideInWar = true
  end
  local confirmBoxDlg = CPopWarning.new({
    title = title,
    text = content,
    confirmText = "确定",
    hideInWar = hideInWar
  })
  confirmBoxDlg:OnlyShowConfirmBtn()
  confirmBoxDlg:ShowCloseBtn(false)
end
function netnotify.deleteLoading(param, ptc_main, ptc_sub)
  g_NetConnectMgr:deleteLoadingLayer()
end
function netnotify.showShareView(param, ptc_main, ptc_sub)
  local shareType = param.i_t
  if shareType == 1 then
    ShowShareView_DaShuMovie()
  end
end
function netnotify.showBuyGiftPopView(param, ptc_main, ptc_sub)
  local popType = param.i_t
  if popType ~= nil then
    ShowPopBuyGiftPopView(popType)
  end
end
function netnotify.showClientRechargeView(param, ptc_main, ptc_sub)
  local viewNum = param.i_vn
  local vipLv = param.i_vip
  ShowRechargeView({resType = viewNum}, vipLv)
end
return netnotify
