local netcangku = {}
function netcangku.allCangkuItems(param, ptc_main, ptc_sub)
  print("netcangku.allCangkuItems")
  local player = g_DataMgr:getPlayer()
  for k, v in pairs(param.t_items) do
    local svrPro = {}
    for proK, proV in pairs(v) do
      if proK ~= "i_iid" and proK ~= "i_sid" then
        svrPro[proK] = proV
      end
    end
    player:SetOneCangkuItem(v.i_iid, v.i_sid, svrPro)
  end
end
function netcangku.setOneCangkuItem(param, ptc_main, ptc_sub)
  print("netcangku.setOneCangkuItem")
  local player = g_DataMgr:getPlayer()
  local svrPro = {}
  for proK, proV in pairs(param) do
    if proK ~= "i_iid" and proK ~= "i_sid" then
      svrPro[proK] = proV
    end
  end
  if param.i_iid == nil then
    print("error 物品id为空")
  else
    player:SetOneCangkuItem(param.i_iid, param.i_sid, svrPro)
  end
end
function netcangku.delOneCangkuItem(param, ptc_main, ptc_sub)
  print("netitem.delOneCangkuItem")
  local player = g_DataMgr:getPlayer()
  if param.i_iid == nil then
    print("error 物品id为空")
  else
    player:DelOneCangkuItem(param.i_iid)
  end
end
function netcangku.zhengliCangkuFinished(param, ptc_main, ptc_sub)
  SendMessage(MsgID_ItemInfo_FinishedCangkuZhenli)
end
function netcangku.expendCangku(param, ptc_main, ptc_sub)
  if param then
    local num = param.num
    g_LocalPlayer:SetExpandCangkuGird(num)
  end
end
return netcangku
