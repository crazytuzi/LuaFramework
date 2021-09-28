ServerItem = class("ServerItem", CcsSubView)
function ServerItem:ctor(serverId, touchListener, isCurr, jsonPath)
  if jsonPath == nil then
    jsonPath = "views/serveritem.json"
  end
  ServerItem.super.ctor(self, jsonPath)
  self.m_IsCurr = isCurr
  if touchListener then
    local clickObj = self:getUINode()
    clickArea_check.extend(self)
    self:click_check_withObj(clickObj, function()
      touchListener(self, self.m_ServerId)
    end)
  end
  self.txt_serverName = self:getNode("txt_serverName")
  self.txt_lvInfo = self:getNode("txt_lvInfo")
  self.m_PlayerHeadIcon = nil
  self.m_serverStatusShow = nil
  self:setServerId(serverId)
end
function ServerItem:ShowPicbgLine(v)
  self:getNode("pic_bg_line"):setVisible(v)
end
function ServerItem:adjustServerNameWith()
  AutoLimitObjSize(self.txt_serverName, 160)
end
function ServerItem:setServerId(serverId)
  self.m_ServerId = serverId
  local mySize = self:getUINode():getSize()
  local serList = g_DataMgr:getServerList()
  local serRoles = g_DataMgr:getServerRoleList()
  local serData = serList[serverId] or {}
  local serverStatus = serData.ss
  local color = ccc3(0, 229, 184)
  local pngPath
  serverStatus = checkint(serverStatus)
  if serverStatus == ServerStatus_Full then
    pngPath = "views/pic/pic_servertype_baoman.png"
  elseif serverStatus == ServerStatus_Recommend then
    color = ccc3(255, 245, 121)
    pngPath = "views/pic/pic_servertype_tuijuan.png"
  elseif serverStatus == ServerStatus_New then
    pngPath = "views/pic/pic_servertype_new.png"
  end
  if self.m_IsCurr then
    color = ccc3(255, 255, 255)
  end
  local serName = serData.name
  if serName then
    self.txt_serverName:setText(serName)
  else
    self.txt_serverName:setText("未知服务器")
  end
  self:adjustServerNameWith()
  if self.m_PlayerHeadIcon then
    self.m_PlayerHeadIcon:removeSelf()
    self.m_PlayerHeadIcon = nil
  end
  local roles
  if serRoles then
    roles = serRoles[serverId]
  end
  if roles and #roles > 0 then
    self.txt_lvInfo:setText(string.format("x%d", #roles))
    self.txt_lvInfo:setVisible(true)
    if self.m_Icon == nil then
      local icon = display.newSprite("views/pic/pic_role_num_icon.png")
      self:addNode(icon, 10)
      self.m_Icon = icon
    end
    local iconSize = self.m_Icon:getContentSize()
    local x, y = self.txt_lvInfo:getPosition()
    self.m_Icon:setPosition(ccp(x - iconSize.width / 2, y))
  else
    self.txt_lvInfo:setVisible(false)
    if self.m_Icon ~= nil then
      self.m_Icon:removeFromParent()
      self.m_Icon = nil
    end
  end
  self.txt_serverName:setColor(color)
  if self.m_serverStatusShow then
    self.m_serverStatusShow:removeSelf()
  end
  if pngPath then
    local sprite = display.newSprite(pngPath)
    self:addNode(sprite, 10)
    local spriteSize = sprite:getContentSize()
    local x, y = self.txt_serverName:getPosition()
    sprite:setPosition(ccp(x - spriteSize.width / 2 - 10, y))
    self.m_serverStatusShow = sprite
  end
end
ServerItemCur = class("ServerItemCur", ServerItem)
function ServerItemCur:ctor(serverId, touchListener, isCurr)
  ServerItemCur.super.ctor(self, serverId, touchListener, isCurr, "views/serveritemcur.json")
end
function ServerItemCur:adjustServerNameWith()
  AutoLimitObjSize(self.txt_serverName, 170)
end
