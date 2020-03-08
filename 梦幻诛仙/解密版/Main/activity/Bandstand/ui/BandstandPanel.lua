local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BandstandPanel = Lplus.Extend(ECPanelBase, "BandstandPanel")
local BandstandMgr = require("Main.activity.Bandstand.BandstandMgr")
local NPCInterface = require("Main.npc.NPCInterface")
local UIModelWrap = require("Model.UIModelWrap")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local ECSoundMan = require("Sound.ECSoundMan")
local FragmentType = require("consts.mzm.gsp.activity4.confbean.FragmentType")
local def = BandstandPanel.define
local instance
def.field("number").activityId = 0
def.field(UIModelWrap)._UIModelWrap = nil
def.field("number").musicId = 0
def.field("number").fragmentIdx = 0
def.field("boolean").isSelected = false
def.field("number").timerId = 0
def.field("number").fragmentStartTime = 0
def.field("number").dialogTimerId = 0
def.static("=>", BandstandPanel).Instance = function()
  if instance == nil then
    instance = BandstandPanel()
  end
  return instance
end
def.method("number").ShowPanel = function(self, activityId)
  if self:IsShow() then
    return
  end
  self.activityId = activityId
  self:CreatePanel(RESPATH.PREFAB_MUSIC_STATION, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Bandstand_Answer_Result, BandstandPanel.OnAnswerResult)
  Event.RegisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Bandstand_Muisc_Start, BandstandPanel.OnMusicStart)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Bandstand_Answer_Result, BandstandPanel.OnAnswerResult)
  Event.UnregisterEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Bandstand_Muisc_Start, BandstandPanel.OnMusicStart)
end
def.static("table", "table").OnAnswerResult = function(p1, p2)
  if not instance or not instance:IsShow() or not _G.IsNil(instance.m_panel) then
  end
end
def.static("table", "table").OnMusicStart = function(p1, p2)
  if instance and instance:IsShow() then
    local Group_Content = instance.m_panel:FindDirect("Img_Bg/Group_Content")
    local Group_Answer = instance.m_panel:FindDirect("Img_Bg/Group_Answer")
    Group_Content:SetActive(true)
    Group_Answer:SetActive(true)
    local bandstandMgr = BandstandMgr.Instance()
    instance.fragmentStartTime = bandstandMgr.startTime
    instance:setMusicInfo(bandstandMgr.curMusicId, bandstandMgr.curFragmentIdx)
  end
end
def.override("boolean").OnShow = function(self, b)
  if b then
    self.fragmentStartTime = _G.GetServerTime()
    local Group_Content = self.m_panel:FindDirect("Img_Bg/Group_Content")
    local Group_Answer = self.m_panel:FindDirect("Img_Bg/Group_Answer")
    Group_Content:SetActive(false)
    Group_Answer:SetActive(false)
    local p = require("netio.protocol.mzm.gsp.bandstand.CStartBandstandReq").new(self.activityId)
    gmodule.network.sendProtocol(p)
    self:setActivityInfo()
    self:setDiglogTip()
  else
    if self.timerId ~= 0 then
      GameUtil.RemoveGlobalTimer(self.timerId)
      self.timerId = 0
    end
    if self.dialogTimerId ~= 0 then
      GameUtil.RemoveGlobalTimer(self.dialogTimerId)
      self.dialogTimerId = 0
    end
    local p = require("netio.protocol.mzm.gsp.bandstand.CEndBandstandReq").new()
    gmodule.network.sendProtocol(p)
    require("Main.Map.MapModule").PlayBgMusic()
    self.isSelected = false
    self.fragmentStartTime = 0
  end
end
def.method().Hide = function(self)
  if self._UIModelWrap then
    self._UIModelWrap:Destroy()
    self._UIModelWrap = nil
  end
  self:DestroyPanel()
end
def.method("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  warn("------BandstandPanel onClick:", id)
  local strs = string.split(id, "_")
  if id == "Btn_Close" then
    self:Hide()
  elseif strs[1] == "Group" and strs[2] == "Item" then
    local idx = tonumber(strs[3])
    if idx then
      local bandstandMgr = BandstandMgr.Instance()
      if self.isSelected then
        return
      end
      self.isSelected = true
      local p = require("netio.protocol.mzm.gsp.bandstand.CBandstandAnswerReq").new(self.musicId, self.fragmentIdx, idx)
      gmodule.network.sendProtocol(p)
      warn("========CBandstandAnswerReq:", self.musicId, self.fragmentIdx, idx)
      local Grid = self.m_panel:FindDirect("Img_Bg/Group_Answer/Grid")
      local Group_Item = Grid:FindDirect("Group_Item_" .. idx)
      local Img_Right = Group_Item:FindDirect("Img_Right")
      local Img_Wrong = Group_Item:FindDirect("Img_Wrong")
      local answetList = bandstandMgr:getAnswerList(self.fragmentIdx)
      if answetList and answetList[idx] == 1 then
        Img_Right:SetActive(true)
      else
        Img_Wrong:SetActive(true)
      end
      local musicCfg = BandstandMgr.GetBandstandMusicCfg(self.musicId)
      if musicCfg then
        local fragment = musicCfg.fragments[self.fragmentIdx]
        if fragment and fragment.fragmentType == FragmentType.WITH_LYRIC then
          local answer = fragment.answers[1]
          local Group_Content = self.m_panel:FindDirect("Img_Bg/Group_Content")
          local Label_Lyric = Group_Content:FindDirect("Label_Lyric")
          local colorAnswer = string.format("[00ff00]%s[-] ", answer)
          local str = string.gsub(fragment.lyric, "__+", colorAnswer)
          Label_Lyric:GetComponent("UILabel"):set_text(str)
        end
      end
    end
  end
end
def.method().setDiglogTip = function(self)
  if _G.IsNil(self.m_panel) then
    return
  end
  local Label = self.m_panel:FindDirect("Img_Bg/Group_Texture/Label")
  local len = #textRes.activity.Bandstand.dialogBox
  local idx = math.random(1, len)
  local str = textRes.activity.Bandstand.dialogBox[idx]
  if str then
    Label:GetComponent("UILabel"):set_text(str)
    self.dialogTimerId = GameUtil.AddGlobalTimer(constant.BandstandConsts.WORD_SWITCH_INTERVAL, true, function()
      if _G.IsNil(self.m_panel) then
        return
      end
      self:setDiglogTip()
    end)
  end
end
def.method().setActivityInfo = function(self)
  local bandstandCfg = BandstandMgr.GetBandstandActivityCfg(self.activityId)
  if bandstandCfg then
    local Img_Singer = self.m_panel:FindDirect("Img_Bg/Group_Bg/Img_Singer")
    GUIUtils.FillIcon(Img_Singer:GetComponent("UITexture"), bandstandCfg.halfBodyIconId)
  end
end
def.method("number", "number").setMusicInfo = function(self, musicId, idx)
  if _G.IsNil(self.m_panel) then
    return
  end
  local Group_Content = self.m_panel:FindDirect("Img_Bg/Group_Content")
  local Label_Name = Group_Content:FindDirect("Label_Name")
  local Label_Lyric = Group_Content:FindDirect("Label_Lyric")
  local bandstandMgr = BandstandMgr.Instance()
  local musicCfg = BandstandMgr.GetBandstandMusicCfg(musicId)
  local Point_Effect = self.m_panel:FindDirect("Img_Bg/Point_Effect")
  if musicCfg then
    self.isSelected = false
    self.musicId = musicId
    Label_Name:GetComponent("UILabel"):set_text(musicCfg.musicName .. "-" .. musicCfg.singerName)
    local fragment = musicCfg.fragments[idx]
    if fragment then
      self.fragmentIdx = idx
      self:playMusic(fragment.musicCfgId)
      if self.timerId > 0 then
        GameUtil.RemoveGlobalTimer(self.timerId)
        self.timerId = 0
      end
      do
        local endTime = self.fragmentStartTime + fragment.musicTime / 1000
        local diff = endTime - _G.GetServerTime()
        warn("---------AddGlobalTimer time:", diff, idx)
        self.timerId = GameUtil.AddGlobalTimer(diff, true, function()
          self.timerId = 0
          if _G.IsNil(self.m_panel) then
            return
          end
          local nextIdx = self.fragmentIdx + 1
          self.fragmentStartTime = endTime
          if nextIdx <= musicCfg.fragmentNum then
            warn("------time music change-------:", nextIdx, musicCfg.fragmentNum)
            self:setMusicInfo(self.musicId, nextIdx)
          else
            warn("------time music change start-------:", 1, musicCfg.fragmentNum)
            self:setMusicInfo(self.musicId, 1)
          end
        end)
        if fragment.fragmentType == FragmentType.WITH_LYRIC then
          Point_Effect:SetActive(false)
          Label_Lyric:GetComponent("UILabel"):set_text(fragment.lyric)
        else
          Point_Effect:SetActive(true)
          Label_Lyric:GetComponent("UILabel"):set_text(textRes.activity.Bandstand[1])
        end
        self:setCurAnswer()
      end
    else
      warn("!!!!!!music fragment is nil:", bandstandMgr, curFragmentIdx)
    end
  end
end
def.method().setCurAnswer = function(self)
  local musicCfg = BandstandMgr.GetBandstandMusicCfg(self.musicId)
  local fragment = musicCfg.fragments[self.fragmentIdx]
  local Grid = self.m_panel:FindDirect("Img_Bg/Group_Answer/Grid")
  if musicCfg and fragment then
    local bandstandMgr = BandstandMgr.Instance()
    if fragment.fragmentType == FragmentType.WITH_LYRIC then
      Grid:SetActive(true)
      local answetList = bandstandMgr:getAnswerList(self.fragmentIdx)
      for i = 1, 4 do
        local Group_Item = Grid:FindDirect("Group_Item_" .. i)
        local Label = Group_Item:FindDirect("Label")
        local Img_Right = Group_Item:FindDirect("Img_Right")
        local Img_Wrong = Group_Item:FindDirect("Img_Wrong")
        Img_Right:SetActive(false)
        Img_Wrong:SetActive(false)
        if answetList then
          local idx = answetList[i]
          local answer = fragment.answers[idx]
          Label:GetComponent("UILabel"):set_text(answer)
        end
      end
    else
      Grid:SetActive(false)
    end
  else
    Grid:SetActive(false)
    warn("-------answer is nil:", self.musicId, self.fragmentIdx)
  end
end
def.method("number").playMusic = function(self, music_id)
  local musicPath = require("Sound.SoundData").Instance():GetSoundPath(music_id)
  if musicPath and musicPath ~= "" then
    ECSoundMan.Instance():PlayBackgroundMusicWithCallback(musicPath, false, function(isover)
      warn("-----play end")
    end)
  end
end
return BandstandPanel.Commit()
