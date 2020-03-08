local Lplus = require("Lplus")
local RanklistContext = require("Data.RanklistContext")
local NATION_DATA = require("Social.ECNationData")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECRankDataMan = Lplus.Class("RankDataMan")
local s_inst
local _per_page_num = 10
do
  local TopListItem = Lplus.Class()
  do
    local def = TopListItem.define
    def.field("number").index = 0
    def.field("number").tid = 0
    def.field("string").id = ""
    def.field("userdata").name = nil
    def.field("number").level = 0
    def.field("number").profession = 0
    def.field("number").oldrank = 0
    def.field("string").value = ""
    TopListItem.Commit()
  end
  local def = ECRankDataMan.define
  def.field("table").mMyRank = BLANK_TABLE_INIT
  def.field("table").mTidData = BLANK_TABLE_INIT
  def.field("table").mTidPart = BLANK_TABLE_INIT
  def.field("table").mTidSend = BLANK_TABLE_INIT
  def.static("=>", ECRankDataMan).Instance = function()
    return s_inst
  end
  def.method("number", "number", "number").BindTid2Part = function(self, tid, mainpart, subpart)
    self.mTidPart[tid] = {main = mainpart, sub = subpart}
  end
  def.method("number", "=>", "number", "number").Tid2ClassPart = function(self, tid)
    if not self.mTidPart[tid] then
      return 0, 0
    end
    return self.mTidPart[tid].main, self.mTidPart[tid].sub
  end
  def.method("number", "number", "=>", "number").ClassPart2Tid = function(self, mainpart, subpart)
    for k, v in pairs(self.mTidPart) do
      if v.main == mainpart and v.sub == subpart then
        return k
      end
    end
    return 0
  end
  def.method().ClearCache = function(self)
    self.mTidData = {}
    self.mTidSend = {}
  end
  def.method("number").ClearTid = function(self, tid)
    if self.mTidData[tid] then
      self.mTidData[tid] = {}
    end
  end
  def.method("number", "table").AddTidData = function(self, tid, d)
    local data = TopListItem()
    data.tid = tid
    data.id = d.id
    data.name = d.name
    data.level = d.level
    data.profession = d.profession
    data.oldrank = d.oldrank
    data.value = d.value
    if self.mTidData[tid] then
      data.index = #self.mTidData[tid] + 1
      table.insert(self.mTidData[tid], data)
    else
      self.mTidData[tid] = {}
      data.index = 1
      table.insert(self.mTidData[tid], data)
    end
    local needsort = function(tid)
      if tid == RANKLIST_TID.TPN_NATION_KING_MIND or tid == RANKLIST_TID.TPN_NATION_POWER then
        return true
      else
        return false
      end
    end
    if needsort(tid) then
      self:SortTidData(tid)
    end
    self:FillRankIndex(tid)
  end
  def.method("number").SortTidData = function(self, tid)
    if not self.mTidData[tid] then
      return
    end
    local myName = ECGame.Instance().m_HostInfo.name:getStringUnicode()
    local sort_rankdata = function(l, r)
      if not l and r then
        return false
      end
      if l and not r then
        return true
      end
      if not l and not r then
        return false
      end
      local l_col4 = l.value
      local r_col4 = r.value
      l_col4 = LuaUInt64.ToDouble(l_col4)
      r_col4 = LuaUInt64.ToDouble(r_col4)
      if l_col4 > r_col4 then
        return true
      end
      if l_col4 < r_col4 then
        return false
      end
      return false
    end
    table.sort(self.mTidData[tid], sort_rankdata)
  end
  def.method("number").FillRankIndex = function(self, tid)
    if tid == RANKLIST_TID.TPN_NATION_POWER or tid == RANKLIST_TID.TPN_NATION_KING_MIND then
      local nation = ECGame.Instance().m_HostInfo.nation
      for k, v in pairs(self.mTidData[tid]) do
        v.index = k
        if v.profession == nation then
          self.mMyRank[tid] = v
        end
      end
    elseif tid == RANKLIST_TID.TPN_FACTION_INDUSTRY or tid >= RANKLIST_TID.TPN_FACTION_INDUSTRY_N1 and tid <= RANKLIST_TID.TPN_FACTION_INDUSTRY_N6 then
      local factionname = ECGame.Instance().m_HostPlayer.Faction._factionname
      local myName = ECGame.Instance().m_HostInfo.name:getStringUnicode()
      for k, v in pairs(self.mTidData[tid]) do
        v.index = k
        local os = OctetsStream.OctetsStream2(v.name)
        local factionOS = os:unmarshal_Octets()
        local masterOS = os:unmarshal_Octets()
        if factionOS:getStringUnicode() == factionname then
          self.mMyRank[tid] = v
        elseif masterOS:getStringUnicode() == myName then
          self.mMyRank[tid] = v
        end
      end
    else
      for k, v in pairs(self.mTidData[tid]) do
        v.index = k
        if v.id == ECGame.Instance().m_HostInfo.id then
          self.mMyRank[tid] = v
        end
      end
    end
  end
  def.method("number", "=>", "table").GetTidRankList = function(self, tid)
    if self.mTidData[tid] then
      return self.mTidData[tid]
    else
      return {}
    end
  end
  def.method("number", "number", "number", "=>", "table").GetTidRankListEx = function(self, tid, begpos, endpos)
    if self.mTidData[tid] then
      local list = {}
      for i = begpos, endpos do
        list[#list + 1] = self.mTidData[tid][i]
      end
      return list
    else
      return {}
    end
  end
  def.method("number", "=>", "number").GetTidRankListCount = function(self, tid)
    local ret = self:GetTidRankList(tid)
    return #ret
  end
  def.method("number", "=>", "table").GenTidTitle = function(self, tid)
    local main, sub = self:Tid2ClassPart(tid)
    if main == 0 or sub == 0 then
      return {}
    else
      return RanklistContext.GetTitle(main, sub)
    end
  end
  def.method("number", "number", "=>", "boolean").NeedContinue = function(self, tid, pos)
    local has = self:GetTidRankListCount(tid)
    local tmp = self.mTidSend[tid]
    local max = ECRankDataMan.GetTidMaxNum(tid)
    local bResult = max > 0 and has < max and math.fmod(has, _per_page_num) == 0
    if tmp then
      if tmp.status == "send" then
        return false
      elseif tmp.status == "ok" then
        if tmp.len == max then
          return false
        elseif pos == tmp.len then
          return true
        else
          return bResult
        end
      end
    end
    return bResult
  end
  def.static("number", "table", "=>", "table").GenTidData = function(tid, data)
    local ret = {}
    if tid == RANKLIST_TID.TPN_LEVEL or tid == RANKLIST_TID.TPN_FIGHT or tid == RANKLIST_TID.TPN_FLOWER or tid == RANKLIST_TID.TPN_CARD_COLLECT then
      ret[#ret + 1] = tostring(data.index)
      ret[#ret + 1] = data.name:getStringUnicode()
      ret[#ret + 1] = NATION_DATA.NATION_NAME[data.profession]
      ret[#ret + 1] = tostring(LuaUInt64.ToDouble(data.value))
    elseif tid == RANKLIST_TID.TPN_MONEY then
      ret[#ret + 1] = tostring(data.index)
      ret[#ret + 1] = data.name:getStringUnicode()
      ret[#ret + 1] = NATION_DATA.NATION_NAME[data.profession]
      local ECGUITools = require("GUI.ECGUITools")
      ret[#ret + 1] = ECGUITools.SetMoneyString(LuaUInt64.ToDouble(data.value))
    elseif tid == RANKLIST_TID.TPN_FACTION_INDUSTRY then
      ret[#ret + 1] = tostring(data.index)
      local os = OctetsStream.OctetsStream2(data.name)
      local factionOS = os:unmarshal_Octets()
      local masterOS = os:unmarshal_Octets()
      ret[#ret + 1] = factionOS:getStringUnicode()
      ret[#ret + 1] = masterOS:getStringUnicode()
      ret[#ret + 1] = tostring(LuaUInt64.ToDouble(data.value))
    elseif tid >= RANKLIST_TID.TPN_FIGHT_N1 and tid <= RANKLIST_TID.TPN_FIGHT_N6 then
      ret[#ret + 1] = tostring(data.index)
      ret[#ret + 1] = data.name:getStringUnicode()
      ret[#ret + 1] = PROFESSION[data.profession]
      ret[#ret + 1] = tostring(LuaUInt64.ToDouble(data.value))
    elseif tid >= RANKLIST_TID.TPN_FLOWER_WEEK_N1 and tid <= RANKLIST_TID.TPN_FLOWER_WEEK_N6 then
      ret[#ret + 1] = tostring(data.index)
      ret[#ret + 1] = data.name:getStringUnicode()
      ret[#ret + 1] = NATION_DATA.NATION_NAME[data.profession]
      ret[#ret + 1] = tostring(LuaUInt64.ToDouble(data.value))
    elseif tid >= RANKLIST_TID.TPN_FIGHT_PROFESSION_1 and tid <= RANKLIST_TID.TPN_FIGHT_PROFESSION_4 then
      ret[#ret + 1] = tostring(data.index)
      ret[#ret + 1] = data.name:getStringUnicode()
      ret[#ret + 1] = NATION_DATA.NATION_NAME[data.profession]
      ret[#ret + 1] = tostring(LuaUInt64.ToDouble(data.value))
    elseif tid >= RANKLIST_TID.TPN_FACTION_INDUSTRY_N1 and tid <= RANKLIST_TID.TPN_FACTION_INDUSTRY_N6 then
      ret[#ret + 1] = tostring(data.index)
      local os = OctetsStream.OctetsStream2(data.name)
      local factionOS = os:unmarshal_Octets()
      local masterOS = os:unmarshal_Octets()
      ret[#ret + 1] = factionOS:getStringUnicode()
      ret[#ret + 1] = masterOS:getStringUnicode()
      ret[#ret + 1] = tostring(LuaUInt64.ToDouble(data.value))
    elseif tid >= RANKLIST_TID.TPN_DUKE_N1 and tid <= RANKLIST_TID.TPN_DUKE_N6 then
      ret[#ret + 1] = tostring(data.index)
      ret[#ret + 1] = data.name:getStringUnicode()
      ret[#ret + 1] = PROFESSION[data.profession]
      ret[#ret + 1] = tostring(LuaUInt64.ToDouble(data.value))
    elseif tid >= RANKLIST_TID.TPN_DUKE_N1_OLD and tid <= RANKLIST_TID.TPN_DUKE_N6_OLD then
      ret[#ret + 1] = tostring(data.index)
      ret[#ret + 1] = data.name:getStringUnicode()
      ret[#ret + 1] = PROFESSION[data.profession]
      ret[#ret + 1] = tostring(LuaUInt64.ToDouble(data.value))
    elseif tid >= RANKLIST_TID.TPN_NATION_POWER and tid <= RANKLIST_TID.TPN_NATION_KING_MIND then
      ret[#ret + 1] = tostring(data.index)
      ret[#ret + 1] = NATION_DATA.NATION_NAME[data.profession]
      ret[#ret + 1] = data.name:getStringUnicode()
      ret[#ret + 1] = tostring(LuaUInt64.ToDouble(data.value))
    end
    return ret
  end
  def.static("number", "=>", "table").GenTidRequest = function(tid)
    local num = ECRankDataMan.GetTidMaxNum(tid)
    return {
      tid,
      0,
      num
    }
  end
  def.static("number", "number", "number", "=>", "table").GenTidRequestEx = function(tid, pos, len)
    return {
      tid,
      pos,
      len
    }
  end
  def.static("number", "=>", "number").GetTidMaxNum = function(tid)
    if tid == RANKLIST_TID.TPN_FIGHT then
      return 100
    elseif tid == RANKLIST_TID.TPN_LEVEL then
      return 100
    elseif tid == RANKLIST_TID.TPN_MONEY then
      return 100
    elseif tid == RANKLIST_TID.TPN_CARD_COLLECT then
      return 50
    elseif tid == RANKLIST_TID.TPN_FLOWER then
      return 50
    elseif tid == RANKLIST_TID.TPN_FACTION_INDUSTRY then
      return 10
    elseif tid >= RANKLIST_TID.TPN_FIGHT_N1 and tid <= RANKLIST_TID.TPN_FIGHT_N6 then
      return 100
    elseif tid >= RANKLIST_TID.TPN_FLOWER_WEEK_N1 and tid <= RANKLIST_TID.TPN_FLOWER_WEEK_N6 then
      return 10
    elseif tid >= RANKLIST_TID.TPN_FACTION_INDUSTRY_N1 and tid <= RANKLIST_TID.TPN_FACTION_INDUSTRY_N6 then
      return 10
    elseif tid >= RANKLIST_TID.TPN_FIGHT_PROFESSION_1 and tid <= RANKLIST_TID.TPN_FIGHT_PROFESSION_4 then
      return 100
    elseif tid >= RANKLIST_TID.TPN_DUKE_N1 and tid <= RANKLIST_TID.TPN_DUKE_N6 then
      return 100
    elseif tid >= RANKLIST_TID.TPN_DUKE_N1_OLD and tid <= RANKLIST_TID.TPN_DUKE_N6_OLD then
      return 100
    else
      return 0
    end
  end
  def.static("table", "=>", "table").GenMultiTPRequest = function(tids)
    local ret = {}
    for _, v in pairs(tids) do
      local req = ECRankDataMan.GenTidRequest(v)
      ret[#ret + 1] = req
    end
    return ret
  end
  def.static("table", "=>", "table").GenMultiTPRequestEx = function(tids)
    local ret = {}
    for _, v in pairs(tids) do
      local pos = ECRankDataMan.Instance():GetTidRankListCount(v)
      local req = ECRankDataMan.GenTidRequestEx(v, pos, _per_page_num)
      ret[#ret + 1] = req
    end
    return ret
  end
  def.static("number", "=>", "boolean").IsGroup = function(tid)
    if tid == RANKLIST_TID.TPN_NATION_POWER then
      return true
    elseif tid == RANKLIST_TID.TPN_FACTION_INDUSTRY then
      return true
    elseif tid >= RANKLIST_TID.TPN_FACTION_INDUSTRY_N1 and tid <= RANKLIST_TID.TPN_FACTION_INDUSTRY_N6 then
      return true
    else
      return false
    end
  end
  def.method("number", "=>", "table").GetMyRankInfo = function(self, tid)
    return self.mMyRank[tid]
  end
  def.method("table").PrintTest = function(self, data)
    print(("TopListItem tid:%d,id:%s,name:%s,level:%d,profession:%d,oldrank:%d,value:%d"):format(data.tid, LuaUInt64.ToString(data.id), data.name:getStringUnicode(), data.level, data.profession, data.oldrank, LuaUInt64.ToDouble(data.value)))
  end
  def.method("number").DebugTID = function(self, tid)
    if not self.mTidData[tid] then
      warn("no rank data in tid:" .. tid)
      return
    end
    for k, v in pairs(self.mTidData[tid]) do
      self:PrintTest(v)
    end
  end
  def.method("number").DebugMyTID = function(self, tid)
    if not self.mMyRank[tid] then
      warn("you are not in rank for tid:" .. tid)
      return
    end
    local data = self.mMyRank[tid]
    print(("TopListItem tid:%d,index:%d,id:%s,name:%s,level:%d,profession:%d,oldrank:%d,value:%d"):format(data.tid, data.index, LuaUInt64.ToString(data.id), data.name:getStringUnicode(), data.level, data.profession, data.oldrank, LuaUInt64.ToDouble(data.value)))
  end
  def.method().NotifyUpdate = function(self)
    local ECPanelRanklist = require("GUI.ECPanelRanklist")
    ECPanelRanklist.Instance():UpdateUI()
  end
  def.method("number").NotifyUpdateWithTID = function(self, tid)
    local ECPanelRanklist = require("GUI.ECPanelRanklist")
    ECPanelRanklist.Instance():UpdateWithTID(tid)
  end
  local function SendProtocol(p)
    local game = ECGame.Instance()
    game.m_Network:SendProtocol(p)
  end
  local function SendGameData(cmd)
    local game = ECGame.Instance()
    game.m_Network:SendGameData(cmd)
  end
  def.static("number").SendGetRankInfo = function(tid)
    local GetRankInfo = require("Protocol.GetRankInfo")
    local p = GetRankInfo()
    p.roleid = ECGame.Instance().m_HostInfo.id
    p.rank = tid
    p.count = 0
    SendProtocol(p)
  end
  def.static("table").SendGetSelfRank = function(tids)
    local get_self_rank = require("C2S.get_self_rank")
    local cmd = get_self_rank()
    cmd.count = #tids
    cmd.tids = tids
    SendGameData(cmd)
  end
  def.static("number").SendTopListRefresh = function(tid)
    local toplist_refresh = require("C2S.toplist_refresh")
    local cmd = toplist_refresh.new(tid)
    SendGameData(cmd)
  end
  def.static("table", "table").SendGetMultiTopList = function(tids1, tids2)
    if #tids1 == 0 and #tids2 == 0 then
      return
    end
    local RpcDataVector = require("Protocol.RPCData.RpcDataVector")
    local MultiTPRequestItem = require("Protocol.RPCData.MultiTPRequestItem")
    local GetMultiTopList = require("Protocol.GetMultiTopList")
    local requests1 = RpcDataVector.new(MultiTPRequestItem)()
    local requests2 = RpcDataVector.new(MultiTPRequestItem)()
    for k, v in pairs(tids1) do
      local tmp = MultiTPRequestItem()
      tmp.tid = v[1]
      tmp.pos = v[2]
      tmp.len = v[3]
      table.insert(requests1.m_vec, tmp)
      ECRankDataMan.Instance().mTidSend[tmp.tid] = {
        pos = tmp.pos,
        len = tmp.len,
        status = "send"
      }
    end
    for k, v in pairs(tids2) do
      local tmp = MultiTPRequestItem()
      tmp.tid = v[1]
      tmp.pos = v[2]
      tmp.len = v[3]
      table.insert(requests2.m_vec, tmp)
    end
    local p = GetMultiTopList()
    p.roleid = ECGame.Instance().m_HostInfo.id
    p.requests1 = requests1
    p.requests2 = requests2
    SendProtocol(p)
    local tid1 = tids1[1]
  end
  def.static("table").SendGetTopList = function(t)
    local GetTopList = require("Protocol.GetTopList")
    local p = GetTopList()
    p.category = t[1]
    p.tid = t[2]
    p.pos = t[3]
    p.len = t[4]
    p.roleid = ECGame.Instance().m_HostInfo.id
    SendProtocol(p)
  end
  def.method("table").OnPrtc_GetRankInfoRe = function(self, prtc)
  end
  def.method("table").OnPrtc_NoticeSelfRankData = function(self, prtc)
    local role_id = prtc.roleid
    for k, v in pairs(prtc.ranks.m_vec) do
      local tid = v.tid
      local rank = v.rank
      local value = v.value
      if not ECRankDataMan.IsGroup(tid) then
        local data = TopListItem()
        data.index = rank
        data.tid = tid
        data.id = role_id
        data.name = ECGame.Instance().m_HostInfo.name
        data.level = ECGame.Instance().m_HostInfo.level
        data.profession = ECGame.Instance().m_HostInfo.profession
        data.oldrank = 0
        data.value = value
        self.mMyRank[tid] = data
      end
    end
    local ECPanelRanklist = require("GUI.ECPanelRanklist")
    ECPanelRanklist.Instance():UpdateRankValue()
  end
  def.method("table").OnPrtc_GetMultiTopListRe = function(self, prtc)
    local answers1 = prtc.answers1.m_vec
    local answers2 = prtc.answers2.m_vec
    for k, v in pairs(answers1) do
      if v.retcode == 0 then
        local tid = v.tid
        local pos = v.pos
        local len = v.len
        local maxvalue = LuaUInt64.ToDouble(v.maxvalue)
        local minvalue = LuaUInt64.ToDouble(v.minvalue)
        if pos == 0 then
          self:ClearTid(tid)
        end
        if self.mTidSend[tid] then
          self.mTidSend[tid].status = "ok"
          self.mTidSend[tid].len = len
          self.mTidSend[tid].pos = pos
        end
        for _, t in pairs(v.items.m_vec) do
          self:AddTidData(v.tid, t)
        end
        self:NotifyUpdateWithTID(tid)
      else
        warn(("error occured for tid %d retcode %d"):format(v.tid, v.retcode))
      end
    end
  end
  def.method("table").OnPrtc_GetTopListRe = function(self, prtc)
    local retcode = prtc.retcode
    local category = prtc.category
    local tid = prtc.tid
    local pos = prtc.pos
    local len = prtc.len
    local selfrank = prtc.selfrank
  end
  def.method("table").OnPrtc_NationRelations = function(self, prtc)
    local filter = function(nationid)
      if nationid == 2 or nationid == 3 then
        return true
      else
        return false
      end
    end
    self:ClearTid(RANKLIST_TID.TPN_NATION_POWER)
    self:ClearTid(RANKLIST_TID.TPN_NATION_KING_MIND)
    local nation_list = prtc.nation_list
    local GTopListItem = require("Protocol.RPCData.GTopListItem")
    for k, v in pairs(nation_list.m_vec) do
      if filter(v.nation_id) then
        local d = GTopListItem()
        d.id = ZeroUInt64
        d.name = v.king_name
        d.profession = v.nation_id
        d.value = LuaUInt64.FromDouble(v.nation_power)
        self:AddTidData(RANKLIST_TID.TPN_NATION_POWER, d)
      end
      if filter(v.nation_id) then
        local m = GTopListItem()
        m.id = ZeroUInt64
        m.name = v.king_name
        m.profession = v.nation_id
        m.value = LuaUInt64.FromDouble(0)
        self:AddTidData(RANKLIST_TID.TPN_NATION_KING_MIND, m)
      end
    end
    self:NotifyUpdateWithTID(RANKLIST_TID.TPN_NATION_POWER)
    self:NotifyUpdateWithTID(RANKLIST_TID.TPN_NATION_KING_MIND)
  end
end
ECRankDataMan.Commit()
s_inst = ECRankDataMan()
do
  local GetNationRelations_Re = require("Protocol.GetNationRelations_Re")
  ECGame.EventManager:addHandler(GetNationRelations_Re, function(sender, self)
    s_inst:OnPrtc_NationRelations(self)
  end)
end
return ECRankDataMan
