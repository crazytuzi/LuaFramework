local KuangHuanModel = {}
KuangHuanModel.allKuanghuangou = {}
KuangHuanModel.missionMap = {}
KuangHuanModel.shopMap = {}
KuangHuanModel.halfShopSurList = {}
function KuangHuanModel:init(kuanghuangou)
  KuangHuanModel.allKuanghuangou = kuanghuangou
end
function KuangHuanModel:getKuangHuanGou()
  return KuangHuanModel.allKuanghuangou
end
function KuangHuanModel:initItem(data)
  local missionMap = {}
  for k, v in pairs(data.missionMap) do
    local missionDayMap = {}
    for i, vs in ipairs(v) do
      missionDayMap[tostring(vs.tag)] = missionDayMap[tostring(vs.tag)] or {}
      table.insert(missionDayMap[tostring(vs.tag)], vs)
    end
    missionMap[k] = missionDayMap
  end
  KuangHuanModel.missionMap = missionMap
  local shopMap = {}
  for k, v in ipairs(data.shopList) do
    shopMap[tostring(v.day)] = shopMap[tostring(v.day)] or {}
    shopMap[tostring(v.day)][tostring(v.tag)] = v
    KuangHuanModel.halfShopSurList[tostring(v.day)] = KuangHuanModel.halfShopSurList[tostring(v.day)] or {}
    KuangHuanModel.halfShopSurList[tostring(v.day)][tostring(v.tag)] = v.topLimit
  end
  KuangHuanModel.shopMap = shopMap
end
function KuangHuanModel:getHalfShopSurList()
  if KuangHuanModel.shopMap ~= nil then
    return KuangHuanModel.halfShopSurList
  else
    return nil
  end
end
function KuangHuanModel:getMissionMap(bigIndex, smallIndex)
  if KuangHuanModel.missionMap ~= nil and KuangHuanModel.missionMap[tostring(bigIndex)] ~= nil and KuangHuanModel.missionMap[tostring(bigIndex)][tostring(smallIndex)] ~= nil then
    return KuangHuanModel.missionMap[tostring(bigIndex)][tostring(smallIndex)]
  end
  return {}
end
function KuangHuanModel:getShopMap(bigIndex, smallIndex)
  if KuangHuanModel.shopMap ~= nil and KuangHuanModel.shopMap[tostring(bigIndex)] ~= nil and KuangHuanModel.shopMap[tostring(bigIndex)][tostring(smallIndex)] ~= nil then
    return KuangHuanModel.shopMap[tostring(bigIndex)][tostring(smallIndex)]
  end
  return nil
end
function KuangHuanModel:enterFestival(param)
  local msg = {
    m = "revelry",
    a = "enterFestival",
    type = param.type
  }
  local function callFun(data)
    self:initItem(data.rtnObj)
    if param.callback ~= nil then
      param.callback(data.rtnObj)
    end
  end
  RequestHelper.request(msg, callFun, param.errback)
end
function KuangHuanModel:halfBuy(param)
  local _callback = param.callback
  local msg = {
    m = "revelry",
    a = "halfBuyAct",
    dayIndex = param.dayIndex,
    type = param.type or 0,
    tag = param.tag
  }
  RequestHelper.request(msg, _callback, param.errback)
end
function KuangHuanModel:getItem(param)
  local _callback = param.callback
  local msg = {
    m = "revelry",
    a = "getawardAct",
    option = param.option,
    dayIndex = param.dayIndex,
    missionId = param.id,
    type = param.type or 0
  }
  RequestHelper.request(msg, _callback, param.errback)
end
return KuangHuanModel
