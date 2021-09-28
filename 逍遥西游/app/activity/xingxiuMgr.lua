local xingxiuMgr = class("xingxiuMgr")
function xingxiuMgr:ctor()
  self.Monsters = {}
  self.MonsterspreDel = {}
end
function xingxiuMgr:startWar(bid)
  netsend.netactivity.sendReqXXWar(bid)
end
function xingxiuMgr:fluchMonsters()
  print(" xingxiuMgr:fluchMonsters  刷新 星宿怪物 ********* ")
  local mapView = g_MapMgr:getMapViewIns()
  local mapId = g_MapMgr:getCurMapId()
  if mapView == nil then
    print("*****************  24 星宿 找不到相关的mapview  或者当前地图与将要刷新的地图不是同一个地图")
    return
  end
  self.m_Monsters = self.m_Monsters or {}
  for k, v in pairs(self.m_Monsters) do
    if mapId ~= k then
      self.m_Monsters[k] = {}
    end
  end
  self.m_Monsters[mapId] = self.m_Monsters[mapId] or {}
  local pid = g_LocalPlayer:getPlayerId()
  for bid, mparam in pairs(self.m_Monsters[mapId]) do
    if mparam == nil or mparam == 0 or mparam.exist == 0 then
      if type(mparam) == "table" and mparam.mid ~= nil then
        local monsterobj = mapView:getMonster(mparam.mid)
        if monsterobj ~= nil then
          mapView:DeleteMonster(mparam.mid)
          self.m_Monsters[mapId][bid] = nil
        end
      end
    else
      local monsterobj = mapView:getMonster(mparam.mid)
      if monsterobj == nil or mparam.mid == nil then
        local bossTb = data_XingXiuNormalBoss[mparam.bossid] or {}
        local bossid = data_getBossForWar(bossTb.WarDataId)
        if bossid ~= nil then
          local sendparam = {pid}
          sendparam.minfo = mparam
          local monsterId = mapView:CreateMonster(bossid, {
            mparam.loc[1],
            mparam.loc[2]
          }, MapPosType_EditorGrid, mparam.loc[3], MapMonsterType_xingxiu, sendparam, bossTb.Name)
          mparam.mid = monsterId
        end
      end
    end
  end
  for bossid, param in pairs(self.m_Monsters[mapId]) do
    if param ~= nil and param.state ~= nil and param.mid ~= nil then
      mapView:updateMonsterHeadState(param.mid, param.state)
    end
  end
end
function xingxiuMgr:getMonsterInfo(mparam)
  print("  xingxiuMgr:getMonsterInfo  刷新的怪物信息   ")
  if mparam == nil then
    return
  end
  self.m_Monsters = self.m_Monsters or {}
  self.m_Monsters[mparam.sceneid] = self.m_Monsters[mparam.sceneid] or {}
  self.m_Monsters[mparam.sceneid][mparam.bossid] = self.m_Monsters[mparam.sceneid][mparam.bossid] or {}
  if mparam ~= nil then
    for k, v in pairs(mparam) do
      self.m_Monsters[mparam.sceneid][mparam.bossid][k] = v
    end
  end
  self.m_Monsters[mparam.sceneid][mparam.bossid].exist = 1
  local mapView = g_MapMgr:getMapViewIns()
  local mapId = g_MapMgr:getCurMapId()
  if mapView ~= nil and mapId ~= nil then
    self:fluchMonsters()
  end
end
function xingxiuMgr:delMoster(mparam)
  if mparam == nil then
    print(" 28 星宿 要删除怪物的 服务器发送数据 为空oooooo ")
    return
  end
  self.m_Monsters = self.m_Monsters or {}
  self.m_Monsters[mparam.sceneid] = self.m_Monsters[mparam.sceneid] or {}
  self.m_Monsters[mparam.sceneid][mparam.bossid] = self.m_Monsters[mparam.sceneid][mparam.bossid] or {}
  if mparam ~= nil then
    for k, v in pairs(mparam) do
      self.m_Monsters[mparam.sceneid][mparam.bossid][k] = v
    end
  end
  self.m_Monsters[mparam.sceneid][mparam.bossid].exist = 0
  local mapView = g_MapMgr:getMapViewIns()
  local mapId = g_MapMgr:getCurMapId()
  if mapView ~= nil and mapId ~= nil then
    self:fluchMonsters()
  end
end
function xingxiuMgr:touchMonster(npcinf)
  print("  xingxiuMgr:touchMonster   ")
  if npcinf == nil then
    return
  end
  local param = npcinf:getParam()
  if param == nil or param.minfo == nil then
    return
  end
  local mtb = data_XingXiuNormalBoss[param.minfo.bossid]
  dump(npcinf)
  CMainUIScene.Ins:ShowMonsterView(npcinf:getMonsterTypeId(), MapMonsterType_xingxiu, function()
    self:startWar(param.minfo.bossid)
  end, mtb.Name, param.minfo.exceedtime)
end
function xingxiuMgr:Clean()
  self.m_Monsters = {}
  self.m_MonstersAdd = {}
  self.m_MonstersDel = {}
end
return xingxiuMgr
