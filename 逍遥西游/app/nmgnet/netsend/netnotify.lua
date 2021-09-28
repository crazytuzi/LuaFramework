local netnotify = {}
function netnotify.confirmBoxToServer(i_id, i_btn)
  NetSend({i_id = i_id, i_btn = i_btn}, S2C_NOTIFY, "P1")
end
function netnotify.confirmViewToServer(i_id, buttonId)
  NetSend({id = i_id, buttonid = buttonId}, S2C_NOTIFY, "P2")
end
function netnotify.closeBuyGiftPopView(i_t)
  NetSend({i_t = i_t}, S2C_NOTIFY, "P3")
end
return netnotify
