local single = require "ui.singletondialog"
local pagenum = 25
local Depot = {}
setmetatable(Depot, single)
Depot.__index = Depot

local function onClickButton()
  --hide tooltips dialog it
  CToolTipsDlg:GetSingletonDialog():HideToolTipsDialog()
  
  local self = Depot:getInstanceOrNot()
  if not self then
    return true
  end
  if not self.m_pLastSelected then
    return true
  end
  local cell = self.m_pLastSelected.Cell
  local bagid = self.m_pLastSelected.Bagid
  local pos = self.m_pLastSelected.Pos
  if cell:getID() ~= 0 then
    local p = knight.gsp.item.CMoveItem()
    p.srcbagid = bagid
    p.srckey = cell:getID()
    p.number = -1
    p.dstbagid = bagid == knight.gsp.item.BagTypes.BAG and knight.gsp.item.BagTypes.DEPOT or
      (bagid == knight.gsp.item.BagTypes.DEPOT and knight.gsp.item.BagTypes.BAG or nil)
    p.dstpos = -1
    p.page = 0
    p.npcid = self.m_npckey or -1
    if p.dstbagid then
      GetNetConnection():send(p)
      self.m_pLastSelected = nil
    end
  end
end

function Depot.new()
  local self = {}
  setmetatable(self, Depot)
  function self.GetLayoutFileName()
    return "depot.layout"
  end
  require "ui.dialog".OnCreate(self)
  local winMgr = CEGUI.WindowManager:getSingleton()
  self.m_pBagPanel = winMgr:getWindow("Depot/backb")
  self.m_pDepotPanel = winMgr:getWindow("Depot/backb1")
  self.m_pBagBtns = {}
  for i = 1, 4 do
    self.m_pBagBtns[i] = CEGUI.toGroupButton(winMgr:getWindow("Depot/backb/button"..i))
    self.m_pBagBtns[i]:subscribeEvent("SelectStateChanged", self.HandlePageBtnClicked, self)
  end
  self.m_pDepotBtns = {}
  for i = 1, 4 do
    self.m_pDepotBtns[i] = CEGUI.toGroupButton(winMgr:getWindow("Depot/backb/buttond"..i))
    self.m_pDepotBtns[i]:subscribeEvent("SelectStateChanged", self.HandlePageBtnClicked, self)
  end
  
  self.m_pTidyDepot = CEGUI.toPushButton(winMgr:getWindow("Depot/TidyBag"))
  self.m_pTidyBag = CEGUI.toPushButton(winMgr:getWindow("Depot/BagTidy"))
  self.m_pTidyDepot:subscribeEvent("Clicked", self.HandleTidyDepotBtnClicked, self)
  self.m_pTidyBag:subscribeEvent("Clicked", self.HandleTidyBagBtnClicked, self)
  self.m_pCells = {}
  self:initBag(self.m_pBagPanel, knight.gsp.item.BagTypes.BAG)
  self:initBag(self.m_pDepotPanel, knight.gsp.item.BagTypes.DEPOT)
  self.m_pBagBtns[1]:setSelected(true)
  self.m_pDepotBtns[1]:setSelected(true)
  return self
end

function Depot:initBag(parent, bagtype)
  local itemkeys = std.vector_int_()
  GetRoleItemManager():GetItemKeyListByBag(itemkeys, bagtype)
  for i = 0, itemkeys:size() - 1 do
    local pItem = GetRoleItemManager():FindItemByBagAndThisID(itemkeys[i], bagtype)
  end
  local winMgr = CEGUI.WindowManager:getSingleton()
  local width, height = 5, 5
  local d_CellWide = 77
  local d_CellHeight = 77
  local d_offset = 8
  local capacity = GetRoleItemManager():GetBagCapacity(bagtype)
  if capacity == 0 then
    local request = knight.gsp.item.CGetBagInfo()
    request.bagid = bagtype
    request.npcid = 0
    GetNetConnection():send(request)
  end
  self.m_pCells[bagtype] = {}
  for i = 1, height do
    for j = 1, width do
      local name = string.format("%s_ItemCell_%d%d", parent:getName(), i, j)
      local pCell=CEGUI.toItemCell(winMgr:createWindow("TaharezLook/ItemCell",name))
      pCell:setSize(CEGUI.UVector2(CEGUI.UDim(0,d_CellWide),CEGUI.UDim(0,d_CellHeight)))
      pCell:setPosition(CEGUI.UVector2(CEGUI.UDim(0, d_offset + (j - 1)* d_CellWide), CEGUI.UDim(0, d_offset + (i - 1)*d_CellHeight)))
      parent:addChildWindow(pCell)
      local btnstr = bagtype == knight.gsp.item.BagTypes.BAG and require "utils.mhsdutils".get_resstring(3079) or 
        require "utils.mhsdutils".get_resstring(3080)
      require "utils.mhsdutils".SetWindowShowtips4Bag(pCell, bagtype, btnstr, onClickButton)
      pCell:subscribeEvent("MouseClick", self.HandleCellClicked, self)
      pCell:subscribeEvent("TableDoubleClick", self.HandleCellDoubleClicked, self)
      table.insert(self.m_pCells[bagtype], pCell)
   --[[   local pos = (i - 1) * width + (j - 1)
      if pos >= capacity then
        pCell:SetLockState(true)
        pCell:setID(0)
      else
        local pItem = GetRoleItemManager():FindItemByBagIDAndPos(bagtype, pos)
        if pItem then
          local image = GetIconManager():GetItemIconByID(pItem:GetBaseObject().icon)
          pCell:SetImage(image)
          if pItem:GetNum() > 1 then
            pCell:SetTextUnit(pItem:GetNum())
          end
          pCell:setID(pItem:GetThisID())
        else
          pCell:setID(0)
        end
      end--]]
    end
  end
end

function Depot:HandleCellDoubleClicked(e)
  local winArgs = CEGUI.toMouseEventArgs(e)
  local bagid, pos
  for k,v in pairs(self.m_pCells) do
    if bagid then
      break
    end
    for i = 1, #v do
      if v[i] == winArgs.window then
        bagid = k
        pos = i - 1
        break
      end
    end
  end
  if not bagid then
    return true
  end
  local cell = self.m_pCells[bagid][pos + 1]
  if cell:getID() ~= 0 then
    local p = knight.gsp.item.CMoveItem()
    p.srcbagid = bagid
    p.srckey = cell:getID()
    p.number = -1
    p.dstbagid = bagid == knight.gsp.item.BagTypes.BAG and knight.gsp.item.BagTypes.DEPOT or
      (bagid == knight.gsp.item.BagTypes.DEPOT and knight.gsp.item.BagTypes.BAG or nil)
    p.dstpos = -1
    p.page = 0
    p.npcid = self.m_npckey or -1
    if p.dstbagid then
      GetNetConnection():send(p)
      self.m_pLastSelected = nil
    end
  end
end


function Depot:HandleCellClicked(e)
  local winArgs = CEGUI.toMouseEventArgs(e)
  local bagid, pos
  for k,v in pairs(self.m_pCells) do
    if bagid then
      break
    end
    for i = 1, #v do
      if v[i] == winArgs.window then
        bagid = k
        pos = i - 1
        break
      end
    end
  end
  if not bagid then
    return true
  end
  
  local cell = self.m_pCells[bagid][pos + 1]
  if bagid == knight.gsp.item.BagTypes.DEPOT then
    if cell:IsLock() then
      local p = require "protocoldef.knight.gsp.item.cbuydepotyuanbao":new()
      require "manager.luaprotocolmanager":send(p)
      self.m_pLastSelected = nil
      return true
    end
  end

  self.m_pLastSelected = {}
  self.m_pLastSelected.Cell = cell
  self.m_pLastSelected.Bagid = bagid
  self.m_pLastSelected.Pos = pos

  return true
end

function Depot:RefreshItems(bagtype, page)
  local capacity = GetRoleItemManager():GetBagCapacity(bagtype)
  for i = 1, pagenum do
    local pos = pagenum * (page - 1) + i - 1
    local pCell = self.m_pCells[bagtype][i]
    if pos >= capacity then
      pCell:SetImage(nil)
      pCell:SetLockState(true)
      pCell:SetTextUnit("")
      pCell:setID(0)
    else
      pCell:SetLockState(false)
      local pItem = GetRoleItemManager():FindItemByBagIDAndPos(bagtype, pos)
      if pItem then
        local image = GetIconManager():GetItemIconByID(pItem:GetBaseObject().icon)
        pCell:SetImage(image)
        if pItem:GetNum() > 1 then
          pCell:SetTextUnit(pItem:GetNum())
        else
          pCell:SetTextUnit("")
        end
        pCell:setID(pItem:GetThisID())
      else
        pCell:SetImage(nil)
        pCell:SetTextUnit("")
        pCell:setID(0)
      end
    end
  end
end

function Depot:HandlePageBtnClicked(e)
  local winArgs = CEGUI.toMouseEventArgs(e)
  local page, bagtype
  for i = 1, #self.m_pBagBtns do
    if winArgs.window == self.m_pBagBtns[i] and self.m_pBagBtns[i]:isSelected() then
      page = i
      bagtype = knight.gsp.item.BagTypes.BAG
      break
    end
  end
  if not bagtype then
    for i = 1, #self.m_pDepotBtns do
      if winArgs.window == self.m_pDepotBtns[i] and self.m_pDepotBtns[i]:isSelected() then
        page = i
        bagtype = knight.gsp.item.BagTypes.DEPOT
        break
      end
    end
  end

  if not bagtype then
    return false
  end

  self:RefreshItems(bagtype, page)
end

function Depot:HandleTidyDepotBtnClicked(e)
    local tidy = knight.gsp.item.CArrangeBag()
    tidy.bagid = knight.gsp.item.BagTypes.DEPOT
    tidy.npcid = 0
    GetNetConnection():send(tidy)
end

function Depot:HandleTidyBagBtnClicked(e)
    local tidy = knight.gsp.item.CArrangeBag()
    tidy.bagid = knight.gsp.item.BagTypes.BAG
    tidy.npcid = 0
    GetNetConnection():send(tidy)
end

function Depot:GetCurPage(bagid)
  local btns = bagid == knight.gsp.item.BagTypes.BAG and self.m_pBagBtns or 
    (bagid == knight.gsp.item.BagTypes.DEPOT and self.m_pDepotBtns or nil)
  if not btns then
    return
  end
  for i = 1, #btns do
    if btns[i]:isSelected() then
      return i
    end
  end
end

function Depot:RefreshBag(p)
  local cells = self.m_pCells[p.bagid]
  local capacity = p.baginfo.capacity
  local function hasItem(pos)
    for i = 0, p.baginfo.items:size() - 1 do
      local item = p.baginfo.items[i]
      if item.position == pos then
        return p.baginfo.items[i]
      end
    end
    return false
  end
  local page = self:GetCurPage(p.bagid)
  
  if not page then
    return
  end
 
  for i = 1, pagenum do
    local pos = pagenum * (page - 1) + i - 1
    local pCell = cells[i]
    if pos >= capacity then
      pCell:SetImage(nil)
      pCell:SetLockState(true)
      pCell:SetTextUnit("")
      pCell:setID(0)
    else
      pCell:SetLockState(false)
      
      local item = hasItem(pos)
      if item then
        local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(item.id)
        local image = GetIconManager():GetItemIconByID(attr.icon)
        pCell:SetImage(image)
        if item.number > 1 then
          pCell:SetTextUnit(item.number)
        else
          pCell:SetTextUnit("")
        end
        pCell:setID(item.key)
      else
        pCell:SetImage(nil)
        pCell:SetTextUnit("")
        pCell:setID(0)
      end
    end
  end
end

function Depot:AddItem(p)
  local page = self:GetCurPage(p.bagid)
  if not page then
    return
  end
  local cells = self.m_pCells[p.bagid]
  for i = 0, p.data:size() - 1 do
    local item = p.data[i]
    if item.position >= (page - 1) * pagenum and item.position < page * pagenum then
      local pCell = cells[item.position % pagenum + 1]
      local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(item.id)
      local image = GetIconManager():GetItemIconByID(attr.icon)
      pCell:SetImage(image)
      if item.number > 1 then
        pCell:SetTextUnit(item.number)
      else
        pCell:SetTextUnit("")
      end
      pCell:setID(item.key)
    end
  end
end

function Depot:RemoveItem(p)
  local cells = self.m_pCells[p.bagid]
  for i = 1, #cells do
    local pCell = cells[i]
    if cells[i]:getID() == p.itemkey then
      pCell:SetImage(nil)
      pCell:SetTextUnit("")
      pCell:setID(0)
      break
    end
  end
end

function Depot:ModItemNum(p)
  local cells = self.m_pCells[p.bagid]
  for i = 1, #cells do
    local pCell = cells[i]
    if cells[i]:getID() == p.itemkey then
      pCell:SetTextUnit(p.curnum)
      break
    end
  end
  return true
end

function Depot:ModItemPos(p)
  local cells = self.m_pCells[p.bagid]
  local pItem = GetRoleItemManager():FindItemByBagAndThisID(p.itemkey, p.bagid)
  for i = 1, #cells do
    local pCell = cells[i]
    if cells[i]:getID() == p.itemkey then
      pCell:SetImage(nil)
      pCell:SetTextUnit("")
      pCell:setID(0)
      break
    end
  end
  local newCell = cells[p.pos + 1]
  if newCell and pItem then
    local image = GetIconManager():GetItemIconByID(pItem:GetBaseObject().icon)
     newCell:SetImage(image)
    if pItem:GetNum() > 1 then
      newCell:SetTextUnit(pItem:GetNum())
    else
      newCell:SetTextUnit("")
    end
    newCell:setID(pItem:GetThisID())
  end
  return true
end

function Depot:RefreshDepotCapacity(capacity)
  local page = self:GetCurPage(knight.gsp.item.BagTypes.DEPOT)
  if not page then
    return
  end
  
  local cells  = self.m_pCells[knight.gsp.item.BagTypes.DEPOT]
  
  for i = 1, #cells do
    local idx = (page - 1)*pagenum + (i-1)
    if idx >= capacity then
      break
    end
    local pCell = cells[i]
    if cells[i]:IsLock() then
      cells[i]:SetLockState(false)
    end
  end
end

function Depot:OnClose()
  Dialog.OnClose(self)
  self.m_npckey = nil
end

return Depot
