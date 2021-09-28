local CPlayerInfoOfFriendDlg = class("CPlayerInfoOfFriendDlg", CPlayerInfoOfMapBase)
function CPlayerInfoOfFriendDlg:ctor(pid, info, chatListener)
  CPlayerInfoOfFriendDlg.super.ctor(self, pid, "views/playerInfoOfFriendDlg.json")
  local btnBatchListener = {
    btn_momo = {
      listener = handler(self, self.Btn_MoMo),
      variName = "btn_momo"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local name = info.name or ""
  local race = data_getRoleRace(info.rtype)
  local zs = info.zs or 0
  local lv = info.level or 0
  self:SetInfo(name, race, zs, lv)
  if info.momoUserId ~= nil and false then
    self.m_MoMoUserId = info.momoUserId
    self.btn_momo:setVisible(true)
    self.btn_momo:setTouchEnabled(true)
  else
    self.btn_momo:setVisible(false)
    self.btn_momo:setTouchEnabled(false)
  end
  self:updateSize()
  local arrow = display.newSprite("views/pic/pic_arrow_left.png")
  self:addNode(arrow, 999)
  local bsize = self:getContentSize()
  arrow:setPosition(ccp(-5, bsize.height / 2))
  self.m_Arrrow = arrow
end
function CPlayerInfoOfFriendDlg:updateSize()
  local offy = 0
  offy = self:adjustBtnPos({
    "btn_pvp",
    "btn_watch",
    "btn_kickout"
  }, offy)
  offy = self:adjustBtnPos({
    "btn_maketeam",
    "btn_makecaptain",
    "btn_requestcaptain"
  }, offy)
  offy = self:adjustBtnPos({
    "btn_friend",
    "btn_delfriend"
  }, offy)
  offy = self:adjustBtnPos({"btn_hyd"}, offy)
  offy = self:adjustBtnPos({"btn_chat"}, offy)
  self:adjustBtnPos({
    "bg_2",
    "txt_race",
    "txt_level",
    "txt_name",
    "txt_id",
    "txt_bp",
    "pic_headbg",
    "btn_momo"
  }, offy, false)
  if offy > 0 then
    self.bg = self:getNode("bg")
    local size = self.bg:getSize()
    local w = size.width
    local h = size.height - offy
    self.bg:setSize(CCSize(w, h))
    self.m_UINode:setSize(CCSize(w, h))
  end
end
function CPlayerInfoOfFriendDlg:SetButtons()
  if self.btn_watch == nil then
    local btnBatchListener = {
      btn_watch = {
        listener = handler(self, self.Btn_Watch),
        variName = "btn_watch"
      }
    }
    self:addBatchBtnListener(btnBatchListener)
  end
  CPlayerInfoOfFriendDlg.super.SetButtons(self)
end
function CPlayerInfoOfFriendDlg:Btn_MoMo()
  if self.m_MoMoUserId then
  end
end
return CPlayerInfoOfFriendDlg
