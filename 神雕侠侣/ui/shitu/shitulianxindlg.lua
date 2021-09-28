require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

local ShitulianxinDialog = {}
setmetatable(ShitulianxinDialog, Dialog)
ShitulianxinDialog.__index = ShitulianxinDialog

local function getLabel()
  return require "ui.label".getLabelById("jianghu")
end

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;

function ShitulianxinDialog.getInstance()
  LogInfo("enter get ShitulianxinDialog instance")
    if not _instance then
        _instance = ShitulianxinDialog:new()
        _instance:OnCreate()
    end
    
    if not getLabel() then
      LabelDlg.InitJianghu()
    end
    
    return _instance
end

function ShitulianxinDialog.getInstanceAndShow()
  LogInfo("enter ShitulianxinDialog instance show")
    if not _instance then
      _instance = ShitulianxinDialog:new()
      _instance:OnCreate()
    else
      LogInfo("set ShitulianxinDialog visible")
      _instance:SetVisible(true)
    end
    
    if not getLabel() then
      LabelDlg.InitJianghu()
    end
    
    return _instance
end

function ShitulianxinDialog.getInstanceNotCreate()
    return _instance
end

function ShitulianxinDialog:OnClose()
  Dialog.OnClose(self)
  _instance = nil
end

function ShitulianxinDialog.DestroyDialog()
  if _instance then
    local dlg = LabelDlg.getLabelById("jianghu")
    if dlg then
      dlg:OnClose()
    end
    if _instance then 
      _instance:OnClose()
    end
  end
end

----/////////////////////////////////////////------
function ShitulianxinDialog.GetLayoutFileName()
    return "shitulianxinmain.layout"
end

function ShitulianxinDialog:OnCreate()
  LogInfo("ShitulianxinDialog oncreate begin")
  Dialog.OnCreate(self)

  local winMgr = CEGUI.WindowManager:getSingleton()
  self.m_shide = winMgr:getWindow("shitulianxinmain/num")
  self.m_shide:setText("0")
  
  self.m_leftPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("shitulianxinmain/left/back"))
  self.m_rightPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("shitulianxinmain/right/main"))

  self.m_pGroupBtn1 = CEGUI.Window.toGroupButton(winMgr:getWindow("shitulianxinmain/tit"))
  self.m_pGroupBtn1:setID(1)
  self.m_pGroupBtn2 = CEGUI.Window.toGroupButton(winMgr:getWindow("shitulianxinmain/tit1"))
  self.m_pGroupBtn2:setID(2)
  
  self.m_itemIndex = 1
  self.m_pGroupBtn1:setSelected(true)
  
  self.m_pGroupBtn1:subscribeEvent("SelectStateChanged", ShitulianxinDialog.HandleSelectedChanged, self);
  self.m_pGroupBtn2:subscribeEvent("SelectStateChanged", ShitulianxinDialog.HandleSelectedChanged, self);
  
  self.m_curwnds = {}
  self.m_chushiwnds = {}
  self.m_rightwnds = {}
  
  self.m_rightIndex = 0
  
  if g_shitu_flag == nil then
    g_shitu_flag = 0
  end
  
  if g_shitu_flag == 0 then
    self:ShowViewForNone()
  end
  
  if g_shitu_flag == 1 then
    self:ShowViewForTudi()
  end
  
  if g_shitu_flag == 2 then
    self:ShowViewForShifu()
  end
  
  self.m_MAX_RECORD = 14
  LogInfo("ShitulianxinDialog oncreate end")
end

------------------- private: -----------------------------------
function ShitulianxinDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ShitulianxinDialog)
    return self
end

function ShitulianxinDialog:ShowViewForShifu()
  local winMgr = CEGUI.WindowManager:getSingleton()
  winMgr:getWindow("shitulianxinmain/right/main/fanhuan"):setVisible(false)
  winMgr:getWindow("shitulianxinmain/right/main/fanhuan1"):setVisible(false)
  winMgr:getWindow("shitulianxinmain/found"):setVisible(false)
end

function ShitulianxinDialog:ShowViewForTudi()
  local winMgr = CEGUI.WindowManager:getSingleton()
  winMgr:getWindow("shitulianxinmain/Line"):setVisible(false)
  winMgr:getWindow("shitulianxinmain/tit1"):setVisible(false)
  winMgr:getWindow("shitulianxinmain/tit"):setVisible(false)
  winMgr:getWindow("shitulianxinmain/left"):setVisible(false)  
  winMgr:getWindow("shitulianxinmain/right"):setVisible(false)  
  
  winMgr:getWindow("shitulianxinmain/right/main"):setVisible(false)
  winMgr:getWindow("shitulianxinmain/found/wuguanxi"):setVisible(false)
end

function ShitulianxinDialog:ShowViewForNone()
  local winMgr = CEGUI.WindowManager:getSingleton()
  winMgr:getWindow("shitulianxinmain/Line"):setVisible(false)
  winMgr:getWindow("shitulianxinmain/tit1"):setVisible(false)
  winMgr:getWindow("shitulianxinmain/tit"):setVisible(false)
  winMgr:getWindow("shitulianxinmain/left"):setVisible(false)  
  winMgr:getWindow("shitulianxinmain/right"):setVisible(false)  
  
  winMgr:getWindow("shitulianxinmain/right/main"):setVisible(false)
  winMgr:getWindow("shitulianxinmain/found/tudi"):setVisible(false)
end

function ShitulianxinDialog:CleanPanes()
  
  local winMgr = CEGUI.WindowManager:getSingleton()

  for k, v in pairs(self.m_curwnds) do
    winMgr:destroyWindow(v)
    self.m_leftPane:removeChildWindow(v)
  end
  
  for k, v in pairs(self.m_chushiwnds) do
    winMgr:destroyWindow(v)
    self.m_leftPane:removeChildWindow(v)
  end
  
  for k, v in pairs(self.m_rightwnds) do
    winMgr:destroyWindow(v)
    self.m_rightPane:removeChildWindow(v)
  end
  
  self.m_curwnds = {}
  self.m_chushiwnds = {}
  self.m_rightwnds = {}
  
end

function ShitulianxinDialog:HandleSelectedChanged(args)
  LogInfo("DingQingXinWuDialog HandleSelectedChanged.")
  local winMgr = CEGUI.WindowManager:getSingleton()

  local index = CEGUI.toWindowEventArgs(args).window:getID()
  self.m_itemIndex = index
  
  if index == 1 then
    winMgr:getWindow("shitulianxinmain/right/main/fanhuan"):setVisible(false)
    winMgr:getWindow("shitulianxinmain/right/main/fanhuan1"):setVisible(false)
  else
    winMgr:getWindow("shitulianxinmain/right/main/fanhuan"):setVisible(true)
    winMgr:getWindow("shitulianxinmain/right/main/fanhuan1"):setVisible(true)
  end
  
  if self.m_data then
    self:SetData(self.m_data)
  end
end

function ShitulianxinDialog:SetData(data)
 self.m_data = data

 local winMgr = CEGUI.WindowManager:getSingleton()
 self.m_shide:setText(tostring(data.shide))
 
  --clear old items
  self:CleanPanes()
  
  if data then
    self.m_curlist = data.prenticelist
    self.m_chushilist = data.chushilist
  end
  
  --tudi
  if self.m_itemIndex == 1 then
    for i=1, #self.m_curlist do
      local v = self.m_curlist[i].prentice
      local roleid = v.roleid
      
      local cellWnd = winMgr:loadWindowLayout("shitulianxinleftcell.layout", tostring(i))
      self.m_leftPane:addChildWindow(cellWnd)
      table.insert(self.m_curwnds, cellWnd)
      
      local headerImage = winMgr:getWindow(tostring(i) .. "shitulianxinleftcell/up/pic")
      local shapeRecord=knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(v.shap)
      local strHead = GetIconManager():GetImagePathByID(shapeRecord.headID):c_str()
      headerImage:setProperty("Image", strHead)
      
      local tudiTxt = winMgr:getWindow(tostring(i) .. "shitulianxinleftcell/up/title")
      tudiTxt:setText(MHSD_UTILS.get_resstring(3153 + i))
      
      local zhenyingImage = winMgr:getWindow(tostring(i) .. "shitulianxinleftcell/up/title/zhenying")
      if v.camp == 1 then
        zhenyingImage:setProperty("Image", "set:MainControl image:campred")  
      elseif v.camp == 2 then
        zhenyingImage:setProperty("Image", "set:MainControl image:campblue")
      else
        zhenyingImage:setVisible(false)
      end
      
      local nameTxt = winMgr:getWindow(tostring(i) .. "shitulianxinleftcell/up/title/name")
      nameTxt:setText(v.rolename)
      
      local levelTxt = winMgr:getWindow(tostring(i) .. "shitulianxinleftcell/up/dengji")
      levelTxt:setText(tostring(v.level))
      
      local schoolTxt = winMgr:getWindow(tostring(i) .. "shitulianxinleftcell/up/menpai")
      schoolTxt:setText(knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(v.school).name)
      
      --for click func callback
      local func_count = #self.m_curlist
      local func_cur = i
      local func = function()
        self.m_rightIndex = func_cur
      
        --unselected other
        for j=1, func_count do
          if func_cur ~= j then
            local btn = CEGUI.toGroupButton(winMgr:getWindow(tostring(j) .. "shitulianxinleftcell/up"))
            btn:setSelected(false)
          end
        end
        
        --clean all archive
        for k, v in pairs(self.m_rightwnds) do
          winMgr:destroyWindow(v)
          self.m_rightPane:removeChildWindow(v)
        end

        self.m_rightwnds = {}
        
        --archive
        local index = 0
        local archive = self.m_curlist[i].achivemap
        local has14 = false
        if #archive == self.m_MAX_RECORD then
          index = 1
          has14 = true
          self:SetAchiveAward(archive[self.m_MAX_RECORD], 1, self.m_MAX_RECORD, roleid, true)
        end
        
        for k, v in pairs(archive) do
          index = index + 1
          if index > self.m_MAX_RECORD then
            break
          end
          if has14 then
            self:SetAchiveAward(v, index, index-1, roleid, false)
          else
            self:SetAchiveAward(v, index, index, roleid, false)
          end
        end
      end
      
      local btn = CEGUI.toGroupButton(winMgr:getWindow(tostring(i) .. "shitulianxinleftcell/up"))
      btn:subscribeEvent("SelectStateChanged", func, self)
      
      --set position
      local y = math.floor((i - 1) * cellWnd:getSize().y.offset) + 1
      cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, y)))
    end
    
    local btn = CEGUI.toGroupButton(winMgr:getWindow(tostring(1) .. "shitulianxinleftcell/up"))
    if btn then
      btn:setSelected(true)
    end
    
  --chushi
  else
    for i=1, #self.m_chushilist do
      local CONST_MAGIC_NUM = 9527
      local index = CONST_MAGIC_NUM + i
      local v =  self.m_chushilist[i]
      
      local cellWnd = winMgr:loadWindowLayout("shitulianxinleftcell.layout", tostring(index))
      self.m_leftPane:addChildWindow(cellWnd)
      table.insert(self.m_chushiwnds, cellWnd)
      
      local headerImage = winMgr:getWindow(tostring(index) .. "shitulianxinleftcell/up/pic")
      local shapeRecord=knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(v.shap)
      local strHead = GetIconManager():GetImagePathByID(shapeRecord.headID):c_str()
      headerImage:setProperty("Image", strHead)
      
      local tudiTxt = winMgr:getWindow(tostring(index) .. "shitulianxinleftcell/up/title")
      tudiTxt:setText(MHSD_UTILS.get_resstring(3158))
      
      local zhenyingImage = winMgr:getWindow(tostring(index) .. "shitulianxinleftcell/up/title/zhenying")
      if v.camp == 1 then
        zhenyingImage:setProperty("Image", "set:MainControl image:campred")  
      elseif v.camp == 2 then
        zhenyingImage:setProperty("Image", "set:MainControl image:campblue")
      else
        zhenyingImage:setVisible(false)
      end
      
      local nameTxt = winMgr:getWindow(tostring(index) .. "shitulianxinleftcell/up/title/name")
      nameTxt:setText(v.rolename)
      
      local levelTxt = winMgr:getWindow(tostring(index) .. "shitulianxinleftcell/up/dengji")
      levelTxt:setText(tostring(v.level))
      
      local schoolTxt = winMgr:getWindow(tostring(index) .. "shitulianxinleftcell/up/menpai")
      schoolTxt:setText(knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(v.school).name)
      
      --unselected other
      local func = function()
        for j=1, #self.m_chushilist do
          local btn = CEGUI.toGroupButton(winMgr:getWindow(tostring(CONST_MAGIC_NUM + j) .. "shitulianxinleftcell/up"))
          btn:setSelected(false)
        end
        
        --open chat dialog
        require "ui.friendchatdialog"
        local chatdlg=FriendChatDialog.getInstanceAndShow()
        chatdlg:SetChatRole(v.roleid,"")
      end
      
      local btn = CEGUI.toGroupButton(winMgr:getWindow(tostring(index) .. "shitulianxinleftcell/up"))
      btn:subscribeEvent("SelectStateChanged", func, self)
      
      --set position
      local y = math.floor((i - 1) * cellWnd:getSize().y.offset) + 1
      cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, y)))
    end
  end
end

function ShitulianxinDialog:SetAchiveAward(award, i, recordid, roleid, hideall)
  local winMgr = CEGUI.WindowManager:getSingleton()
  local cellWnd = winMgr:loadWindowLayout("shitulianxinrightcell.layout", tostring(i))
  self.m_rightPane:addChildWindow(cellWnd)
  table.insert(self.m_rightwnds, cellWnd)
  
  local rec = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cshitulianxinkehuduan"):getRecorder(recordid)
  local name = winMgr:getWindow(tostring(i) .. "shitulianxinrightcell/name")
  name:setText(rec.name)
  
  local des = winMgr:getWindow(tostring(i) .. "shitulianxinrightcell/main/text")
  des:setText(rec.description)
  
  --for 8 type
  if recordid == 8 then
    des:setText(rec.description .. tostring(award.totalnum)) 
  end
  
  local jiangli = winMgr:getWindow(tostring(i) .. "shitulianxinrightcell/main/text12")
  jiangli:setText(tostring(rec.jianglishidezhi))
  
  local proc = CEGUI.Window.toProgressBar(winMgr:getWindow(tostring(i) .. "shitulianxinrightcell/main/wancheng"))
  proc:setProgress(award.currnumber*1.0 / award.totalnum)
  proc:setText(string.format("%d/%d", award.currnumber, award.totalnum))
  --for 8 type
  if recordid == 8 then
    if award.currnumber >= award.totalnum then
      proc:setProgress(1.0)
      proc:setText("1/1")
    else
      proc:setProgress(0.0)
      proc:setText("0/1")
    end
  end
  
  local btnGo = CEGUI.toPushButton(winMgr:getWindow(tostring(i) .. "shitulianxinrightcell/main/go"))
  local btnGet = CEGUI.toPushButton(winMgr:getWindow(tostring(i) .. "shitulianxinrightcell/main/button"))
  
  local funcgo = function()
      require "ui.friendchatdialog"
      local chatdlg=FriendChatDialog.getInstanceAndShow()
      chatdlg:SetChatRole(roleid,"")
  end
  
  local funcget = function()
    require "protocoldef.knight.gsp.master.ctakeachiveaward"
    local p = CTakeAchiveAward.Create()
    p.roleid = roleid
    p.key = recordid
    require "manager.luaprotocolmanager":send(p)
  end
  
  btnGo:subscribeEvent("Clicked", funcgo, self)
  btnGet:subscribeEvent("Clicked", funcget, self)
  
  if award.flag == 0 then
    btnGo:setVisible(true)
    btnGet:setVisible(false)
  elseif award.flag == 1 then
    btnGo:setVisible(false)
    btnGet:setVisible(true)
  else
    btnGo:setVisible(false)
    btnGet:setVisible(true)
    btnGet:setEnabled(false)
  end
  
  if hideall then
    btnGet:setVisible(false)
  end
  
  --set position
  local y = math.floor((i - 1) * cellWnd:getSize().y.offset) + 1
  cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, y)))
end

function ShitulianxinDialog:SetAchiveFresh(data)
  local index = nil
  if self.m_data and self.m_data.prenticelist then
    for k,v in pairs(self.m_data.prenticelist) do
      if v.prentice.roleid == data.roleid then
        self.m_data.prenticelist[k].achivemap[data.key].flag = data.flag
        index = k
        break
      end
    end
  end
  
  if self.m_rightIndex == index then
    local winMgr = CEGUI.WindowManager:getSingleton()
    local indexkey = 0
    if #self.m_data.prenticelist[index].achivemap == self.m_MAX_RECORD then
      indexkey = 1
    end
    
    local btnGet = CEGUI.toPushButton(winMgr:getWindow(tostring(data.key + indexkey) .. "shitulianxinrightcell/main/button"))
    btnGet:setEnabled(false)
  end
  
end

return ShitulianxinDialog
