LoginRoleList = class("LoginRoleList", CcsSceneView)
local MAX_ROLE_NUM = 5
function LoginRoleList:ctor(serverRoleList)
  LoginRoleList.super.ctor(self, "views/login_rolelist.csb")
  local btnBatchListener = {
    btn_returnToLogin = {
      listener = handler(self, self.Btn_ReturnToLogin),
      variName = "btn_returnToLogin"
    },
    btn_startGame = {
      listener = handler(self, self.Btn_StartGame),
      variName = "btn_startGame"
    },
    btn_createRole = {
      listener = handler(self, self.Btn_CreateRole),
      variName = "btn_createRole"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  local btn_back_txt = display.newSprite("views/common/btn/btntxt_back.png")
  self.btn_returnToLogin:addNode(btn_back_txt)
  btn_back_txt:setPosition(ccp(-5, 20))
  local btn_back_start = display.newSprite("views/common/btn/btntxt_enter.png")
  self.btn_startGame:addNode(btn_back_start)
  btn_back_start:setScaleX(-1)
  btn_back_start:setPosition(ccp(-5, 20))
  local btn_add_txt = display.newSprite("views/common/btn/btn_add_2.png")
  self.btn_createRole:addNode(btn_add_txt)
  self.pic_bg = self:getNode("pic_bg")
  local size = self.pic_bg:getContentSize()
  if size.width < display.width or size.height < display.height then
    self:getNode("pic_bg"):setSize(CCSize(display.width, display.height))
  end
  soundManager.playLoginMusic()
  self.m_ServerRoleList = serverRoleList or {}
  self.pic_bg_server = self:getNode("pic_bg_server")
  self.m_HeadIconList = {}
  local posObjList = {}
  local curZS = 0
  local curLV = 0
  self.m_CurSelectId = nil
  self.m_CurSelectIdx = nil
  local totalW = 0
  local roleId_save = getConfigByName("lastChoosedRoleId")
  local isBreakGetRoleId = false
  for i, roleInfo in ipairs(self.m_ServerRoleList) do
    do
      local roleId = roleInfo.i_roleid
      local zs = roleInfo.i_zs or 0
      local lv = roleInfo.i_lv or 0
      if isBreakGetRoleId == false and (roleId == roleId_save or self.m_CurSelectId == nil or curZS < zs or zs == curZS and curLV < lv) then
        self.m_CurSelectId = roleId
        curZS = zs
        curLV = lv
        self.m_CurSelectIdx = i
        if roleId == roleId_save then
          isBreakGetRoleId = true
        end
      end
      local param = {
        roleTypeId = roleInfo.i_rtype,
        clickListener = function()
          self:HeadIconTouched(i, roleId)
        end,
        noBgFlag = false
      }
      local head = createClickHead(param)
      self.pic_bg_server:addChild(head, 100)
      head._roleIdx = i
      head._roleId = roleId
      self.m_HeadIconList[#self.m_HeadIconList + 1] = head
      posObjList[#posObjList + 1] = head
      local name = roleInfo.s_name or ""
      local zs = roleInfo.i_zs or 0
      local lv = roleInfo.i_lv or 0
      local txt = CRichText.new({
        color = ccc3(255, 255, 255),
        font = KANG_TTF_FONT,
        verticalSpace = 5,
        fontSize = 24,
        align = CRichText_AlignType_Center
      })
      txt:addRichText(name)
      txt:newLine()
      txt:addRichText(string.format("%d转%d级", zs, lv))
      head:addChild(txt, 100)
      local headSize = head:getSize()
      local txtSize = txt:getRichTextSize()
      txt:setPosition(ccp((headSize.width - txtSize.width) / 2, -headSize.height / 2 - 16))
      head._infoTxt = txt
      totalW = totalW + headSize.width
    end
  end
  local spaceH = 50
  local bx, by = self.btn_createRole:getPosition()
  if #self.m_ServerRoleList >= MAX_ROLE_NUM then
    self.btn_createRole:setEnabled(false)
  else
    posObjList[#posObjList + 1] = self.btn_createRole
    totalW = totalW + self.btn_createRole:getSize().width
  end
  totalW = totalW + spaceH * (#posObjList - 1)
  dump(posObjList, "posObjList")
  local x = -totalW / 2
  local y = by
  for i, v in ipairs(posObjList) do
    local size = v:getSize()
    if v == self.btn_createRole then
      v:setPosition(ccp(x + size.width / 2, y))
    else
      v:setPosition(ccp(x, y - size.height / 2))
    end
    x = x + spaceH + size.width
  end
  self.m_SelectImg = display.newSprite("views/rolelist/pic_role_selected.png")
  self.pic_bg_server:addNode(self.m_SelectImg, 102)
  self:flushSelect()
end
function LoginRoleList:HeadIconTouched(roleIdx, roleId)
  print("HeadIconTouched:", roleIdx, roleId)
  self.m_CurSelectId = roleId
  self.m_CurSelectIdx = roleIdx
  self:flushSelect()
end
function LoginRoleList:flushSelect()
  if self.m_CurSelectId ~= nil and self.m_CurSelectIdx ~= nil then
    local headObj = self.m_HeadIconList[self.m_CurSelectIdx]
    local x, y = headObj:getPosition()
    local headSize = headObj:getSize()
    self.m_SelectImg:setPosition(ccp(x + headSize.width / 2, y + headSize.height / 2))
  end
end
function LoginRoleList:Btn_ReturnToLogin(obj, t)
  print("==>>LoginRoleList:Btn_ReturnToLogin")
  g_DataMgr:returnToLoginView()
end
function LoginRoleList:Btn_StartGame(obj, t)
  print("==>>LoginRoleList:Btn_StartGame")
  g_DataMgr:EnterGameWithRoleId(self.m_CurSelectId)
end
function LoginRoleList:Btn_CreateRole(obj, t)
  print("==>>LoginRoleList:Btn_CreateRole")
  g_DataMgr:ShowNewRoleView()
end
