local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local MenpaiStarVote = Lplus.Extend(ECPanelBase, "MenpaiStarVote")
local SOccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local MenpaiStarModule = Lplus.ForwardDeclare("MenpaiStarModule")
local def = MenpaiStarVote.define
local instance
def.static("=>", MenpaiStarVote).Instance = function()
  if instance == nil then
    instance = MenpaiStarVote()
  end
  return instance
end
def.const("number").REFRESHLIMIT = 5
def.field("number").menpai = 0
def.field("number").curPage = 1
def.field("number").totalPage = 1
def.field("table").candidateList = nil
def.field("number").refreshTime = 0
def.field("userdata").selectRoleId = nil
def.const("table").Menpai2Sprite = {
  [SOccupationEnum.ALL] = "",
  [SOccupationEnum.GUI_WANG_ZONG] = "Label_GWSX",
  [SOccupationEnum.QIN_GYUN_MEN] = "Label_QYSX",
  [SOccupationEnum.TIAN_YIN_SI] = "Label_TYSX",
  [SOccupationEnum.FEN_XIANG_GU] = "Label_FXSX",
  [SOccupationEnum.HE_HUAN_PAI] = "Label_HHSX",
  [SOccupationEnum.SHENG_WU_JIAO] = "Label_SWSX",
  [SOccupationEnum.CANG_YU_GE] = "Label_CYSX",
  [SOccupationEnum.LING_YIN_DIAN] = "Label_LYSX",
  [SOccupationEnum.YI_NENG_ZHE] = "Label_YNSX",
  [SOccupationEnum.SEN_LUO_DIAN] = "Label_SLSX"
}
def.static("number").ShowMenpaiStarVote = function(menpai)
  local self = MenpaiStarVote.Instance()
  if self:IsShow() then
    if self.menpai ~= menpai then
      self:DestroyPanel()
      self.menpai = menpai
      self:CreatePanel(RESPATH.PERFAB_MENPAISTAR_VOTE, 1)
      self:SetModal(true)
    end
  else
    self.menpai = menpai
    self:CreatePanel(RESPATH.PERFAB_MENPAISTAR_VOTE, 1)
    self:SetModal(true)
  end
end
def.static("=>", "number").GetCurMenpai = function()
  local self = MenpaiStarVote.Instance()
  return self.menpai
end
def.static("table", "number", "number", "userdata").UpdateContent = function(list, curPage, totalPage, roleId)
  if list == nil then
    return
  end
  local self = MenpaiStarVote.Instance()
  self.candidateList = list
  self.curPage = curPage
  self.totalPage = totalPage
  self.selectRoleId = roleId
  if self:IsShow() then
    self:UpdateList()
    self:UpdatePage()
  end
end
def.static("userdata", "number", "boolean").MyPointToRole = function(roleId, point, empty)
  local self = MenpaiStarVote.Instance()
  if self.candidateList and #self.candidateList > 0 then
    local minRank = self.candidateList[1].rank
    for _, v in ipairs(self.candidateList) do
      if v.roleId == roleId then
        v.point = v.point + point
        if empty then
          v.left = 0
          break
        end
        v.left = 0 > v.left - 1 and 0 or v.left - 1
        break
      end
    end
    table.bubblesort(self.candidateList, function(a, b)
      return a.point >= b.point
    end)
    for _, v in ipairs(self.candidateList) do
      v.rank = minRank
      minRank = minRank + 1
    end
    if self:IsShow() then
      self:UpdateList()
    end
  end
  if self:IsShow() then
    self:UpdateMyVote()
  end
end
def.static("userdata", "number", "number").ChangeAwardByRole = function(roleId, award, left)
  local self = MenpaiStarVote.Instance()
  if self.candidateList and #self.candidateList > 0 then
    for _, v in ipairs(self.candidateList) do
      if v.roleId == roleId then
        v.reward = award
        v.left = left
      end
    end
    if self:IsShow() then
      self:UpdateList()
    end
  end
end
def.method("userdata", "=>", "table").GetInfoByRoleId = function(self, roleId)
  if roleId == nil then
    return nil
  end
  if self.candidateList then
    for _, v in ipairs(self.candidateList) do
      if v.roleId == roleId then
        return v
      end
    end
    return nil
  else
    return nil
  end
end
def.override().OnCreate = function(self)
  self:UpdateAll()
end
def.method().UpdateAll = function(self)
  self:UpdateTitle()
  self:UpdateList()
  self:UpdatePage()
  self:UpdateMyVote()
  self:UpdateSelfInfo()
end
def.method().UpdateTitle = function(self)
  local titleSpr = self.m_panel:FindDirect("Img_Bg0/Group_Title/Img_BgTitle/Img_Title")
  local spriteName = MenpaiStarVote.Menpai2Sprite[self.menpai] or ""
  titleSpr:GetComponent("UISprite"):set_spriteName(spriteName)
end
def.method("userdata", "table", "number").FillListItem = function(self, uiGo, info, index)
  local bgName = string.format("Img_BgList%d", index % 2 + 1)
  local bgSprite = uiGo:FindDirect(string.format("Img_Bg1_%d", index))
  bgSprite:GetComponent("UISprite"):set_spriteName(bgName)
  if info.roleId == self.selectRoleId then
    bgSprite:GetComponent("UIToggle").value = true
  else
    bgSprite:GetComponent("UIToggle").value = false
  end
  local rankLbl = uiGo:FindDirect(string.format("Label_Ranking_%d", index))
  local rankSPr = uiGo:FindDirect(string.format("Img_MingCi_%d", index))
  if info.rank > 3 then
    rankLbl:SetActive(true)
    rankLbl:GetComponent("UILabel"):set_text(string.format("%d", info.rank))
    rankSPr:SetActive(false)
  else
    rankLbl:SetActive(false)
    rankSPr:SetActive(true)
    rankSPr:GetComponent("UISprite"):set_spriteName(string.format("Img_Num%d", info.rank))
  end
  local nameLbl = uiGo:FindDirect(string.format("Label_PlayerName_%d", index))
  nameLbl:GetComponent("UILabel"):set_text(info.name)
  local pointLbl = uiGo:FindDirect(string.format("Label_CurPoint_%d", index))
  pointLbl:GetComponent("UILabel"):set_text(info.point)
  local reward = uiGo:FindDirect(string.format("Label_Reward_%d", index))
  reward:GetComponent("UILabel"):set_text(info.reward)
  local numLbl = uiGo:FindDirect(string.format("Label_RestNum_%d", index))
  numLbl:GetComponent("UILabel"):set_text(string.format("%d", info.left))
end
def.method().UpdateList = function(self)
  local count = self.candidateList and #self.candidateList or 0
  local groupHas = self.m_panel:FindDirect("Img_Bg0/Group_RankList")
  local groupNo = self.m_panel:FindDirect("Img_Bg0/Group_NoData")
  if count > 0 then
    groupHas:SetActive(true)
    groupNo:SetActive(false)
    do
      local list = self.m_panel:FindDirect("Img_Bg0/Group_RankList/Group_List")
      local listCmp = list:GetComponent("UIList")
      listCmp:set_itemCount(count)
      listCmp:Resize()
      GameUtil.AddGlobalLateTimer(0.01, true, function()
        if not listCmp.isnil then
          listCmp:Reposition()
        end
      end)
      local items = listCmp:get_children()
      for i = 1, #items do
        local uiGo = items[i]
        local candidate = self.candidateList[i]
        self:FillListItem(uiGo, candidate, i)
        self.m_msgHandler:Touch(uiGo)
      end
    end
  else
    groupHas:SetActive(false)
    groupNo:SetActive(true)
  end
end
def.method().UpdatePage = function(self)
  local pageLbl = self.m_panel:FindDirect("Img_Bg0/Group_Page/Img_BgPage/Label_Page")
  pageLbl:GetComponent("UILabel"):set_text(string.format("%d/%d", self.curPage, self.totalPage))
end
def.method().UpdateMyVote = function(self)
  local timesLbl = self.m_panel:FindDirect("Img_Bg0/Group_Tickets/Label_CurTicketsNum")
  timesLbl:GetComponent("UILabel"):set_text(textRes.Common[1])
  local data = MenpaiStarModule.Instance():GetData()
  data:GetVoteTimes(function(times)
    if self.m_panel and not self.m_panel.isnil then
      local timesLbl = self.m_panel:FindDirect("Img_Bg0/Group_Tickets/Label_CurTicketsNum")
      if times >= 0 then
        timesLbl:GetComponent("UILabel"):set_text(string.format("%d/%d", constant.CMenPaiStarConst.VOTE_NUM - times, constant.CMenPaiStarConst.VOTE_NUM))
      else
        timesLbl:GetComponent("UILabel"):set_text(textRes.Common[1])
      end
    end
  end)
end
def.method().UpdateSelfInfo = function(self)
  local btn = self.m_panel:FindDirect("Img_Bg0/Img_BgBottom/Btn_SetReward")
  local btn2 = self.m_panel:FindDirect("Img_Bg0/Img_BgBottom/Btn_MyPlace")
  btn:SetActive(false)
  btn2:SetActive(false)
  local data = MenpaiStarModule.Instance():GetData()
  data:IsCandidate(function(isCandidate)
    if self.m_panel and not self.m_panel.isnil then
      local btn = self.m_panel:FindDirect("Img_Bg0/Img_BgBottom/Btn_SetReward")
      local btn2 = self.m_panel:FindDirect("Img_Bg0/Img_BgBottom/Btn_MyPlace")
      local heroProp = require("Main.Hero.Interface").GetHeroProp()
      if heroProp and heroProp.occupation == self.menpai then
        if isCandidate then
          btn:SetActive(true)
          btn2:SetActive(true)
        else
          btn:SetActive(false)
          btn2:SetActive(false)
        end
      else
        btn:SetActive(false)
        btn2:SetActive(false)
      end
    end
  end)
end
def.override().OnDestroy = function(self)
  self.menpai = 0
  self.curPage = 1
  self.totalPage = 1
  self.candidateList = nil
  self.selectRoleId = nil
  self.refreshTime = 0
end
def.method("=>", "boolean").IsMeInPage = function(self)
  if self.candidateList then
    local roleId = GetMyRoleID()
    for _, v in ipairs(self.candidateList) do
      if v.roleId == roleId then
        return true
      end
    end
    return false
  else
    return false
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Btn_Next" then
    local next = self.curPage + 1
    if next > self.totalPage then
      Toast(textRes.MenpaiStar[3])
    else
      MenpaiStarModule.Instance():RequestByMenpaiAndPage(self.menpai, next)
    end
  elseif id == "Btn_Back" then
    local prev = self.curPage - 1
    if prev < 1 then
      Toast(textRes.MenpaiStar[4])
    else
      MenpaiStarModule.Instance():RequestByMenpaiAndPage(self.menpai, prev)
    end
  elseif id == "Btn_SetReward" then
    MenpaiStarModule.Instance():ShowSetAward()
  elseif id == "Btn_Tips" then
    require("GUI.GUIUtils").ShowHoverTip(constant.CMenPaiStarConst.VOTE_UI_TIP_ID, 0, 0)
  elseif string.sub(id, 1, 8) == "Img_Bg1_" then
    local index = tonumber(string.sub(id, 9))
    if index and self.candidateList and self.candidateList[index] then
      local info = self.candidateList[index]
      self.selectRoleId = info.roleId
      local uiGo = self.m_panel:FindDirect(string.format("Img_Bg0/Group_RankList/Group_List/RankBaby_%d/%s", index, id))
      uiGo:GetComponent("UIToggle").value = true
    end
  elseif id == "Img_Vote" then
    local info = self:GetInfoByRoleId(self.selectRoleId)
    if info then
      local heroProp = require("Main.Hero.Interface").GetHeroProp()
      if heroProp and heroProp.occupation == self.menpai then
        MenpaiStarModule.Instance():Vote(info.roleId, info.left)
      else
        Toast(textRes.MenpaiStar[45])
      end
    else
      Toast(textRes.MenpaiStar[43])
    end
  elseif id == "Img_Support" then
    do
      local info = self:GetInfoByRoleId(self.selectRoleId)
      if info then
        local btn = self.m_panel:FindDirect("Img_Bg0/Img_BgBottom/Img_Support")
        if btn == nil then
          return
        end
        local position = btn:get_position()
        local screenPos = WorldPosToScreen(position.x, position.y)
        local sprite = btn:GetComponent("UISprite")
        local pos = {
          auto = true,
          sourceX = screenPos.x,
          sourceY = screenPos.y,
          sourceW = sprite:get_width(),
          sourceH = sprite:get_height(),
          prefer = -1
        }
        local btns = {
          {
            name = textRes.MenpaiStar.CanvassOperation[1]
          },
          {
            name = textRes.MenpaiStar.CanvassOperation[2]
          }
        }
        require("GUI.ButtonGroupPanel").ShowPanel(btns, pos, function(index)
          if index == 1 then
            MenpaiStarModule.Instance():CanvassInGang(info.roleId, info.name, info.reward)
          elseif index == 2 then
            MenpaiStarModule.Instance():CanvassInWorld(info.roleId, info.name, info.reward)
          end
        end)
      else
        Toast(textRes.MenpaiStar[43])
      end
    end
  elseif id == "Btn_Refresh" then
    local curTime = GetServerTime()
    if curTime - self.refreshTime >= MenpaiStarVote.REFRESHLIMIT then
      MenpaiStarModule.Instance():RequestByMenpaiAndPage(self.menpai, self.curPage)
      self.refreshTime = curTime
    else
      local left = MenpaiStarVote.REFRESHLIMIT - (curTime - self.refreshTime)
      Toast(string.format(textRes.MenpaiStar[42], left))
    end
  elseif id == "Btn_MyPlace" then
    if self:IsMeInPage() then
      Toast(textRes.MenpaiStar[49])
      self.selectRoleId = GetMyRoleID()
      self:UpdateList()
    else
      MenpaiStarModule.Instance():RequestByRoleId(GetMyRoleID())
    end
  end
end
return MenpaiStarVote.Commit()
