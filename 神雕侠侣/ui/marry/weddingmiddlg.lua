require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"
require "manager.beanconfigmanager"

local WeddingMidDialog = {}

setmetatable(WeddingMidDialog, Dialog)
WeddingMidDialog.__index = WeddingMidDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function WeddingMidDialog.getInstance()
    LogInfo("enter get WeddingMidDialog instance")
    if not _instance then
        _instance = WeddingMidDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function WeddingMidDialog.getInstanceAndShow()
    LogInfo("enter WeddingMidDialog instance show")
    if not _instance then
        _instance = WeddingMidDialog:new()
        _instance:OnCreate()
    else
        LogInfo("set WeddingMidDialog visible")
        _instance:SetVisible(true)
    end
    
    return _instance
end

function WeddingMidDialog.getInstanceNotCreate()
    return _instance
end

function WeddingMidDialog.DestroyDialog()
    GetChatManager():SetEnableSystemNotice(true)

    local _blessIns = require "ui.marry.blessdlg".getInstanceNotCreate()
    if _blessIns then
      _blessIns.DestroyDialog()
    end

    if _instance then 
        LogInfo("destroy WeddingMidDialog")
        
        _instance.m_pSprite1:delete()
        _instance.m_pSprite2:delete()
        _instance.m_pSprite3:delete()
        _instance.m_xinlang:getGeometryBuffer():setRenderEffect(nil)
        _instance.m_xinniang:getGeometryBuffer():setRenderEffect(nil)
        _instance.m_yuelao:getGeometryBuffer():setRenderEffect(nil)
        
        _instance:OnClose()
        _instance = nil
    end
end

----/////////////////////////////////////////------
function WeddingMidDialog.GetLayoutFileName()
    return "marrymid.layout"
end

function WeddingMidDialog:OnCreate()
    print("WeddingMidDialog oncreate begin")
    Dialog.OnCreate(self)
    GetChatManager():SetEnableSystemNotice(false)

    self:GetWindow():setModalState(true)

    math.randomseed(os.time())
    
    --remind
    self.m_remind_yinliang = true 
    self.m_remind_yuanbao = true 
    
    --zhufu danmu
    self.m_charHeight = 38
    self.m_screenWidth = CEGUI.System:getSingleton():getGUISheet():getPixelSize().width
    self.m_screenHeigth = CEGUI.System:getSingleton():getGUISheet():getPixelSize().height
    local row = self.m_screenHeigth/self.m_charHeight - 4
    self.m_leftWidth = 20
    self.m_timeCount = 9.9
    self.m_unUsed = {}

    self.m_data = {}
    for i=1, row do
        self.m_data[i] = {data = {}}
    end

    --hongbao
    self.m_hongbaoMargin = 100
    row = self.m_screenWidth/self.m_hongbaoMargin
    self.m_unUsedHongbao = {}
    self.m_hongbaoData = {}
    for i=1, row do
        self.m_hongbaoData[i] = {data = {}}
    end

    local winMgr = CEGUI.WindowManager:getSingleton()
    self.m_wnd = winMgr:getWindow("marrymid/back")
    
    --name label
    self.m_xinlang_name = winMgr:getWindow("marrymid/back/xinlang/name2")
    self.m_xinniang_name = winMgr:getWindow("marrymid/back/xinlang/name21")
    
    --sprites
    self.m_xinlang = winMgr:getWindow("marrymid/back/xinlang")
    self.m_xinniang = winMgr:getWindow("marrymid/back/xinniang")
    self.m_yuelao = winMgr:getWindow("marrymid/back/yuelao")
    
    self.m_pSprite1 = CUISprite:new(6180)
    local pt = self.m_xinlang:GetScreenPosOfCenter()
    local wndHeight = self.m_xinlang:getPixelSize().height
    local loc = XiaoPang.CPOINT(pt.x, pt.y + wndHeight / 2.0)
    self.m_pSprite1:SetUILocation(loc)
    self.m_pSprite1:SetUIDirection(XiaoPang.XPDIR_BOTTOMRIGHT)
    self.m_xinlang:getGeometryBuffer():setRenderEffect(CGameUImanager:createXPRenderEffect(0, WeddingMidDialog.performPostRenderFunctions))
    
    self.m_pSprite2 = CUISprite:new(6181)
    local pt = self.m_xinniang:GetScreenPosOfCenter()
    local wndHeight = self.m_xinniang:getPixelSize().height
    local loc = XiaoPang.CPOINT(pt.x, pt.y + wndHeight / 2.0)
    self.m_pSprite2:SetUILocation(loc)
    self.m_pSprite2:SetUIDirection(XiaoPang.XPDIR_BOTTOMRIGHT)
    self.m_xinniang:getGeometryBuffer():setRenderEffect(CGameUImanager:createXPRenderEffect(0, WeddingMidDialog.performPostRenderFunctions))
    
    self.m_pSprite3 = CUISprite:new(6179)
    local pt = self.m_yuelao:GetScreenPosOfCenter()
    local wndHeight = self.m_yuelao:getPixelSize().height
    local loc = XiaoPang.CPOINT(pt.x, pt.y + wndHeight / 2.0)
    self.m_pSprite3:SetUILocation(loc)
    self.m_pSprite3:SetUIDirection(XiaoPang.XPDIR_BOTTOMRIGHT)
    self.m_yuelao:getGeometryBuffer():setRenderEffect(CGameUImanager:createXPRenderEffect(0, WeddingMidDialog.performPostRenderFunctions))
    
    --speak enable
    self.m_speakEnable = {}
    self.m_speakEnable[1] = false
    self.m_speakEnable[2] = false
    self.m_speakEnable[3] = false
    self.m_speakInterval = {}
    self.m_speakInterval[1] = 2.0
    self.m_speakInterval[2] = 2.0
    self.m_speakInterval[3] = 2.0
    self.m_speakLabel = {}
    self.m_speakLabel[1] = CEGUI.Window.toRichEditbox(winMgr:getWindow("marrymid/back/xinlang/txt"))
    self.m_speakLabel[2] = CEGUI.Window.toRichEditbox(winMgr:getWindow("marrymid/back/xinniang/txt"))
    self.m_speakLabel[3] = CEGUI.Window.toRichEditbox(winMgr:getWindow("marrymid/back/yuelao/txt"))
    self.m_speakLabel[1]:setVisible(false)
    self.m_speakLabel[2]:setVisible(false)
    self.m_speakLabel[3]:setVisible(false)
    
    --read action table
    self.m_actionTable = {}
    local config = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cbaitangconfig")
    local ids = config:getDisorderAllID()
    
    for k,v in pairs(ids) do
      self.m_actionTable[k] = config:getRecorder(v)
      self.m_actionTable[k].done = false
    end
    
    self.m_effectTable = {}
    local config = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cmarryeffect")
    local ids = config:getDisorderAllID()
    
    for k,v in pairs(ids) do
      self.m_effectTable[k] = config:getRecorder(v)
      self.m_effectTable[k].effect = 0
    end
    
    --friend button
    self.m_btnFriend = winMgr:getWindow("marrymid/back/friend")
    self.m_btnFriend:subscribeEvent("Clicked", WeddingMidDialog.HandleClickRestorBtn, self)
    self.m_Notify = winMgr:getWindow("marrymid/back/friend/mark")
    self.m_Notify:setVisible(false)
    
    --zan times
    self.m_times = winMgr:getWindow("marrymid/times")
    self.m_times:setText("0")
    
    --leave time
    self.m_lefttime = winMgr:getWindow("marrymid/back/time1")

    self.m_btnLeave = CEGUI.Window.toPushButton(winMgr:getWindow("marrymid/back/left"))
    self.m_btnLeave:subscribeEvent("Clicked", WeddingMidDialog.HandleLeaveClicked, self)

    self.m_btnHongbao = CEGUI.Window.toPushButton(winMgr:getWindow("marrymid/back/hongbao1"))
    self.m_btnHongbao:subscribeEvent("Clicked", WeddingMidDialog.HandleHongbaoClicked, self)
    self.m_btnHongbao:setVisible(false)

    self.m_btnYuanbao = CEGUI.Window.toPushButton(winMgr:getWindow("marrymid/back/hongbao2"))
    self.m_btnYuanbao:subscribeEvent("Clicked", WeddingMidDialog.HandleYuanbaoClicked, self)
    self.m_btnYuanbao:setVisible(false)

    self.m_btnLike = CEGUI.Window.toPushButton(winMgr:getWindow("marrymid/back/dianzan"))
    self.m_btnLike:subscribeEvent("Clicked", WeddingMidDialog.HandleLikeClicked, self)

    self.m_btnBless = CEGUI.Window.toPushButton(winMgr:getWindow("marrymid/back/wish"))
    self.m_btnBless:subscribeEvent("Clicked", WeddingMidDialog.HandleBlessClicked, self)
    
    WeddingMidDialog.RefreshNotify()
    
    --mengjing effect
    self.mengjingEffect = GetGameUIManager():AddUIEffect(self.m_wnd, MHSD_UTILS.get_effectpath(10091), true)
    self.mengjingEffect:SetLocation(XiaoPang.CPOINT(self.m_screenWidth/2, self.m_screenHeigth/2))
    self.mengjingEffect:SetScale(XiaoPang.FPOINT(self.m_screenWidth/1024.0, self.m_screenHeigth/768.0))
    
    --zhufu effect
    self.m_zhufu = {}
    for i=1,3 do
      self.m_zhufu[i] = {}
      self.m_zhufu[i].label = winMgr:createWindow("TaharezLook/StaticText")
      self.m_zhufu[i].label:setSize(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 1)))
      self.m_zhufu[i].label:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 200), CEGUI.UDim(0, 200)))
      self.m_zhufu[i].label:setProperty("BackgroundEnabled", "False")
      self.m_zhufu[i].label:setProperty("FrameEnabled", "False")
      self.m_wnd:addChildWindow(self.m_zhufu[i].label)
      
      self.m_zhufu[i].curtime = 0.0
      self.m_zhufu[i].counttime = i*3 - 1
    end
    
    --create common effect wnd
    self.m_playeffect_label = winMgr:createWindow("TaharezLook/StaticText")
    self.m_playeffect_label:setSize(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, 1)))
    local x = 1.0 + self.m_screenWidth/2
    local y = 1.0 + self.m_screenHeigth/2
    self.m_playeffect_label:setPosition(CEGUI.UVector2(CEGUI.UDim(0, x), CEGUI.UDim(0, y)))
    self.m_playeffect_label:setProperty("BackgroundEnabled", "False")
    self.m_playeffect_label:setProperty("FrameEnabled", "False")
    self.m_wnd:addChildWindow(self.m_playeffect_label)
      
    self:GetWindow():subscribeEvent("WindowUpdate", WeddingMidDialog.HandleWindowUpdate, self)
    
    LogInfo("WeddingMidDialog oncreate end")
end

------------------- private: -----------------------------------
function WeddingMidDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, WeddingMidDialog)
    return self
end

function WeddingMidDialog:HandleClickRestorBtn(args)
  LogInfo("WeddingMidDialog:HandleClickRestorBtn")
  require "ui.friendsdialog"
  if GetFriendsManager() then
    if GetFriendsManager():HasNotShowMsg() then
        GetFriendsManager():PopChatMsg()
    else
        FriendsDialog.getInstanceAndShow()
    end
  else
    FriendsDialog.getInstanceAndShow()
  end

  return true
end

function WeddingMidDialog.RefreshNotify()
  LogInfo("WeddingMidDialog:RefreshNotify")
  if not _instance then 
     return
  end
 _instance.m_Notify:setVisible(false)
  local msgNum=GetFriendsManager():GetNotReadMsgNum()
  
  if msgNum>0 then
     _instance.m_Notify:setVisible(true)
     _instance.m_Notify:setText(tostring(msgNum))
  end
  
end

function WeddingMidDialog.performPostRenderFunctions(id)
  if _instance then
      _instance.m_pSprite1:RenderUISprite()
      _instance.m_pSprite2:RenderUISprite()
      _instance.m_pSprite3:RenderUISprite()
  end
end

function WeddingMidDialog.FormatTimeData(time)
  local minutes = math.floor(time/60)
  local second = math.floor(time) - minutes * 60
  return minutes, second
end

function WeddingMidDialog:SetLeftTime(lefttime, totaltime)
    LogInfo("WeddingMidDialog SetLeftTime clicked.")
    self.m_lefttimeData = lefttime/1000.0
    self.m_currenttime = (totaltime-lefttime)/1000.0
end

function WeddingMidDialog:HandleLeaveClicked(args)
    LogInfo("WeddingMidDialog HandleLeaveClicked clicked.")
    
    require "protocoldef.knight.gsp.marry.cleavewedding"
    local p = CLeaveWedding.Create()
    require "manager.luaprotocolmanager":send(p)
end

function WeddingMidDialog:HandleQiangHongbao(args)
    LogInfo("WeddingMidDialog HandleQiangHongbao clicked.")
    local id = CEGUI.toWindowEventArgs(args).window:getID()
    require "protocoldef.knight.gsp.marry.ccatchgift"
    local p = CCatchGift.Create()
    p.giftid = id
    require "manager.luaprotocolmanager":send(p)
end

function WeddingMidDialog:HandleHongbaoClicked(args)
    LogInfo("WeddingMidDialog HandleHongbaoClicked clicked.")
    
    if self.m_remind_yinliang == true then
      local functable = {}
      function functable.acceptCallback()
        self.m_remind_yinliang = false
        GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
        if self.m_master == 1 then
            require "protocoldef.knight.gsp.marry.csendredgift"
            local p = CSendRedGift.Create()
            p.flag = 1 --yinliang
            require "manager.luaprotocolmanager":send(p)
        end
      end
      
      local recorder = nil
      if self.m_isjingdian == true then
        recorder = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cmarryconfig"):getRecorder(2)
      else
        recorder = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cmarryconfig"):getRecorder(3)
      end
      
      local msg = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(146266).msg
      local sb = require "utils.stringbuilder":new()
      sb:Set("parameter1", recorder.repairyinliang or "??")
      local str = sb:GetString(msg)
      sb:delete()
      
      GetMessageManager():AddConfirmBox(eConfirmNormal,
      str,
      functable.acceptCallback,
        functable,
        CMessageManager.HandleDefaultCancelEvent,
        CMessageManager)
      return
    end
    
    if self.m_master == 1 then
        require "protocoldef.knight.gsp.marry.csendredgift"
        local p = CSendRedGift.Create()
        p.flag = 1 --yinliang
        require "manager.luaprotocolmanager":send(p)
    end
end

function WeddingMidDialog:HandleYuanbaoClicked(args)
    LogInfo("WeddingMidDialog HandleYuanbaoClicked clicked.")
    
    if self.m_remind_yuanbao == true then
      local functable = {}
      function functable.acceptCallback()
        self.m_remind_yuanbao = false
        GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
        if self.m_master == 1 then
            require "protocoldef.knight.gsp.marry.csendredgift"
            local p = CSendRedGift.Create()
            p.flag = 2 --yuanbao
            require "manager.luaprotocolmanager":send(p)
        end
      end
      
      local recorder = nil
      if self.m_isjingdian == true then
        recorder = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cmarryconfig"):getRecorder(2)
      else
        recorder = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cmarryconfig"):getRecorder(3)
      end

      local msg = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(146267).msg
      local sb = require "utils.stringbuilder":new()
      sb:Set("parameter1", recorder.repairyuanbao or "??")
      local str = sb:GetString(msg)
      sb:delete()
      
      GetMessageManager():AddConfirmBox(eConfirmNormal,
      str,
      functable.acceptCallback,
        functable,
        CMessageManager.HandleDefaultCancelEvent,
        CMessageManager)
      return
    end
    
    if self.m_master == 1 then
        require "protocoldef.knight.gsp.marry.csendredgift"
        local p = CSendRedGift.Create()
        p.flag = 2 --yuanbao
        require "manager.luaprotocolmanager":send(p)
    end
end

function WeddingMidDialog:HandleLikeClicked(args)
    LogInfo("WeddingMidDialog HandleLikeClicked clicked.")
    --zan
    require "protocoldef.knight.gsp.marry.csubzan"
    local p = CSubzan.Create()
    require "manager.luaprotocolmanager":send(p)
end

function WeddingMidDialog:HandleBlessClicked(args)
    LogInfo("WeddingMidDialog HandleBlessClicked clicked.")
    require "ui.marry.blessdlg".getInstanceAndShow()
end

function WeddingMidDialog:HandleWindowUpdate(eventArgs)
    self:HandleSubTitles(eventArgs)
    self:HandleHongbaos(eventArgs)
    
    local thisTime = CEGUI.toUpdateEventArgs(eventArgs).d_timeSinceLastFrame
    
    --left time tips
    if self.m_lefttimeData ~= nil then
      self.m_lefttimeData = self.m_lefttimeData - thisTime
      local a,b = WeddingMidDialog.FormatTimeData(self.m_lefttimeData)
      if a >=0 and b >=0 then
        self.m_lefttime:setText(string.format("%02d:%02d", a,b))
      end
    end
    
    self:HandleEffects()
    self:HandleSpeakLabel(thisTime)
    self:HandleSpriteAction(thisTime)
    self:HandleZhufuEffect(thisTime)
end

function WeddingMidDialog:HandleZhufuEffect(thisTime)
    for i=1, #self.m_zhufu do
      self.m_zhufu[i].curtime = self.m_zhufu[i].curtime + thisTime
      if self.m_zhufu[i].curtime > self.m_zhufu[i].counttime then
        self.m_zhufu[i].curtime = 0.0
        
        if self.m_zhufu[i].effect ~= nil then
          GetGameUIManager():RemoveUIEffect(self.m_zhufu[i].effect)
        end
        
        local x = 80 + math.random(1, self.m_screenWidth - 120)
        local y = 80 + math.random(1, self.m_screenHeigth - 120)
        
        self.m_zhufu[i].label:setPosition(CEGUI.UVector2(CEGUI.UDim(0, x), CEGUI.UDim(0, y)))
        self.m_zhufu[i].effect = GetGameUIManager():AddUIEffect(self.m_zhufu[i].label, MHSD_UTILS.get_effectpath(10449), false)
      end
    end
end

function WeddingMidDialog:HandleSubTitles(eventArgs)
    --handle system item
    if self.systemZhufuItem ~= nil and self.systemZhufuItem.label == nil then
      local config = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.ccolor")
       
      local d = self.systemZhufuItem
      d.x = self.m_screenWidth
      d.y = 2 * self.m_charHeight
      d.countTime = self.m_timeCount
      
      local winMgr = CEGUI.WindowManager:getSingleton()
      d.label = winMgr:createWindow("TaharezLook/StaticText")
      d.label:setFont(config:getRecorder(d.flag).fontsize)
      d.font = d.label:getFont()
      
      local l = d.font:getTextExtent(d.str) + self.m_leftWidth
      d.label:setSize(CEGUI.UVector2(CEGUI.UDim(0, l), CEGUI.UDim(0, self.m_charHeight)))
      d.label:setPosition(CEGUI.UVector2(CEGUI.UDim(0, d.x), CEGUI.UDim(0, d.y)))
      d.label:setProperty("BackgroundEnabled", "False")
      d.label:setProperty("FrameEnabled", "False")

      local txtcolor = config:getRecorder(d.flag).typeface
      local bordercolor = config:getRecorder(d.flag).stroke
      
      d.label:setProperty("TextColours", txtcolor or "tl:FF37EFFF tr:FF37EFFF bl:FF1E90D8 br:FF1E90D8")
      d.label:setProperty("BorderColour", bordercolor or "FFFFFF00")
      d.label:setProperty("DefaultBorderEnable", "False")
      d.label:setProperty("DefaultColourEnable", "False")
      d.label:setProperty("BorderEnable", "True")
      self.m_wnd:addChildWindow(d.label)
      d.label:setText(d.str)
    end

    --insert sub titles item
    local item = nil
    local randIndex = math.random(1, #self.m_data)
    
    if table.getn(self.m_unUsed) > 0 then
        if table.getn(self.m_data[randIndex].data) == 0 then
            item = self.m_unUsed[1]
            table.insert(self.m_data[randIndex].data, self.m_unUsed[1])
            table.remove(self.m_unUsed, 1)
        else
            local beInsert = true
            for i=1, #self.m_data[randIndex].data do
                local d = self.m_data[randIndex].data[i]
                local endPos = d.x + d.font:getTextExtent(d.str) + self.m_leftWidth
                if endPos > self.m_screenWidth then
                    beInsert = false
                    break
                end
            end

            if beInsert then
                item = self.m_unUsed[1]
                table.insert(self.m_data[randIndex].data, self.m_unUsed[1])
                table.remove(self.m_unUsed, 1)
            end
        end
    end

    --craete static text
    if item ~= nil then
      local config = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.ccolor")
      
      local d = item
      d.x = self.m_screenWidth
      d.y = randIndex * self.m_charHeight
      d.countTime = self.m_timeCount
      
      local winMgr = CEGUI.WindowManager:getSingleton()
      d.label = winMgr:createWindow("TaharezLook/StaticText")
      d.label:setFont(config:getRecorder(d.flag).fontsize)
      d.font = d.label:getFont()
      
      local l = d.font:getTextExtent(d.str) + self.m_leftWidth
      d.label:setSize(CEGUI.UVector2(CEGUI.UDim(0, l), CEGUI.UDim(0, self.m_charHeight)))
      d.label:setPosition(CEGUI.UVector2(CEGUI.UDim(0, d.x), CEGUI.UDim(0, d.y)))
      d.label:setProperty("BackgroundEnabled", "False")
      d.label:setProperty("FrameEnabled", "False")
      
      local txtcolor = config:getRecorder(d.flag).typeface
      local bordercolor = config:getRecorder(d.flag).stroke
      
      d.label:setProperty("TextColours", txtcolor or "tl:FF37EFFF tr:FF37EFFF bl:FF1E90D8 br:FF1E90D8")
      d.label:setProperty("BorderColour", bordercolor or "FFFFFF00")
      d.label:setProperty("DefaultBorderEnable", "False")
      d.label:setProperty("DefaultColourEnable", "False")
      d.label:setProperty("BorderEnable", "True")
      self.m_wnd:addChildWindow(d.label)
      d.label:setText(d.str)
    end

    ----------------------------
    local time = CEGUI.toUpdateEventArgs(eventArgs).d_timeSinceLastFrame
    
   --handle system item
    if self.systemZhufuItem ~= nil then
      if self:HandleOneSubTitles(self.systemZhufuItem, time) then
          self.m_wnd:removeChildWindow(self.systemZhufuItem.label)
          self.systemZhufuItem.label = nil
          self.systemZhufuItem = nil
      end
    end

    for i=1, #self.m_data do
        local tmp = {}
        for j=1, #self.m_data[i].data do
          --if true,remove it!
          if self:HandleOneSubTitles(self.m_data[i].data[j], time) then
              self.m_wnd:removeChildWindow(self.m_data[i].data[j].label)
          else
              --save not need removed
              table.insert(tmp, self.m_data[i].data[j])
          end
        end
        self.m_data[i].data = tmp
    end
end

function WeddingMidDialog:HandleOneSubTitles(d, time)
  --LogInfo("WeddingMidDialog HandleOneSubTitles.")
  d.countTime = d.countTime - time
  local distance = d.font:getTextExtent(d.str) + self.m_leftWidth + self.m_screenWidth
  d.x = (d.countTime / self.m_timeCount) * distance
  
  --move
  d.label:setPosition(CEGUI.UVector2(CEGUI.UDim(0, d.x), CEGUI.UDim(0, d.y)))
  
  --need remove
  if d.x <= -(d.font:getTextExtent(d.str) + self.m_leftWidth) then
      return true
  end
  
  return false
end

function WeddingMidDialog:HandleHongbaos(eventArgs)   
    local time = CEGUI.toUpdateEventArgs(eventArgs).d_timeSinceLastFrame
    
    local should_insert = false  
    if self.m_hongbao_time_insert == nil then
      self.m_hongbao_time_insert = 0.314
    end
    
    self.m_hongbao_time_insert = self.m_hongbao_time_insert - time
    if self.m_hongbao_time_insert <= 0.0 then
      self.m_hongbao_time_insert = 0.314
      should_insert = true
    end
    
    --insert hongbao item
    if should_insert then
      local item = nil
      local randIndex = math.random(1, #self.m_hongbaoData)
      
      if table.getn(self.m_unUsedHongbao) > 0 then
          if table.getn(self.m_hongbaoData[randIndex].data) == 0 then
              item = self.m_unUsedHongbao[1]
              table.insert(self.m_hongbaoData[randIndex].data, self.m_unUsedHongbao[1])
              table.remove(self.m_unUsedHongbao, 1)
          else
              local beInsert = true
              for i=1, #self.m_hongbaoData[randIndex].data do
                  local d = self.m_hongbaoData[randIndex].data[i]
                  if d.y < 168 then
                      beInsert = false
                      break
                  end
              end
  
              if beInsert then
                  item = self.m_unUsedHongbao[1]
                  table.insert(self.m_hongbaoData[randIndex].data, self.m_unUsedHongbao[1])
                  table.remove(self.m_unUsedHongbao, 1)
              end
          end
      end
  
      --craete hongbao
      if item ~= nil then
          local d = item
          d.x = (randIndex - 1) * self.m_hongbaoMargin + 40
          d.y = 0
          d.usedTime = 0
  
          local winMgr = CEGUI.WindowManager:getSingleton()
          d.btn = winMgr:createWindow("TaharezLook/ImageButton")
          d.btn:setPosition(CEGUI.UVector2(CEGUI.UDim(0, d.x), CEGUI.UDim(0, d.y)))
          d.btn:setSize(CEGUI.UVector2(CEGUI.UDim(0, 80), CEGUI.UDim(0, 80)))
          if d.flag == 1 then
            d.btn:setProperty("NormalImage", "set:MainControl30 image:yinlianghongbao")
            d.btn:setProperty("HoverImage", "set:MainControl30 image:yinlianghongbao")
            d.btn:setProperty("PushedImage", "set:MainControl30 image:yinlianghongbao")
          elseif d.flag == 2 then
            d.btn:setProperty("NormalImage", "set:MainControl30 image:yuanbaohongbao")
            d.btn:setProperty("HoverImage", "set:MainControl30 image:yuanbaohongbao")
            d.btn:setProperty("PushedImage", "set:MainControl30 image:yuanbaohongbao")
          end

          self.m_wnd:addChildWindow(d.btn)
          
          d.btn:setID(d.id)
          d.btn:subscribeEvent("Clicked", WeddingMidDialog.HandleQiangHongbao, self)
      end
    end
    
    ----------------------------
    for i=1, #self.m_hongbaoData do
        local tmp = {}
        for j=1, #self.m_hongbaoData[i].data do

            --if true,remove it!
            if self:HandleOneHongbao(self.m_hongbaoData[i].data[j], time) then
                self.m_wnd:removeChildWindow(self.m_hongbaoData[i].data[j].btn)
            else
                --save not need removed
                table.insert(tmp, self.m_hongbaoData[i].data[j])
            end
        end
        self.m_hongbaoData[i].data = tmp
    end
end

function WeddingMidDialog:HandleOneHongbao(d, time)
    --LogInfo("WeddingMidDialog HandleOneSubTitles.")
    d.usedTime = d.usedTime + time
    local distance = self.m_screenHeigth + self.m_hongbaoMargin
    d.y = (d.usedTime / 5.0) * distance

    --move
    d.btn:setPosition(CEGUI.UVector2(CEGUI.UDim(0, d.x), CEGUI.UDim(0, d.y)))

    --need remove
    if d.y >= distance then
        return true
    end

    return false
end

--add zhufu item
function WeddingMidDialog:AddZhufuItem(item)
    LogInfo("WeddingMidDialog AddZhufuItem.")
    --[[
        str
        flag, 1,2,3(for normal, gold, system)
    ]]
    
    --handle special system
    if item.flag == 3 then
      if self.systemZhufuItem ~= nil then
        return
      end
      self.systemZhufuItem = item
      return
    end
    
    table.insert(self.m_unUsed, item)
end

--add hongbao item
function WeddingMidDialog:AddHongbaoItem(item)
    LogInfo("WeddingMidDialog AddHongbaoItem.")
    --[[
        flag
        content -- (ids)
    ]]
    for k,v in pairs(item.content) do
        table.insert(self.m_unUsedHongbao, {flag=item.flag,id=v})
    end
end

--remove hongbao item
function WeddingMidDialog:RemoveHongbaoItem(item)
    LogInfo("WeddingMidDialog RemoveHongbaoItem.")
    --[[
        content -- (ids)
    ]]

    function IsInTable(tb, id)
        for i=1,#tb do
            if tb[i] == id then
                return true
            end
        end
        return false
    end

    --remove from unused array
    local tmp = {}
    for i=1, #self.m_unUsedHongbao do
        if not IsInTable(item.content, self.m_unUsedHongbao[i].id) then
            table.insert(tmp, self.m_unUsedHongbao[i])
        end
    end
    self.m_unUsedHongbao = tmp

    --remove from displaying array
    for i=1, #self.m_hongbaoData do
        local tmp = {}
        for j=1, #self.m_hongbaoData[i].data do
            if not IsInTable(item.content, self.m_hongbaoData[i].data[j].id) then
                table.insert(tmp, self.m_hongbaoData[i].data[j])
            else
                --remove it
               self.m_wnd:removeChildWindow(self.m_hongbaoData[i].data[j].btn)
            end
        end
        self.m_hongbaoData[i].data = tmp
    end
end

function WeddingMidDialog:SetMaster(flag, isjingdian, xinlang, xinniang)
    LogInfo("WeddingMidDialog SetMaster.")
    self.m_xinlang_name:setText(xinlang)
    self.m_xinniang_name:setText(xinniang)
    self.m_master = flag
    self.m_isjingdian = isjingdian
    
    if flag == 1 then
        self.m_btnHongbao:setVisible(true)
        self.m_btnYuanbao:setVisible(true)
    end
    
    if isjingdian == true then
      self.m_btnYuanbao:setVisible(false)
    end
end

function WeddingMidDialog:SetZanTimes(t)
    LogInfo("WeddingMidDialog SetTimes.")
    self.m_times:setText(tostring(t))
end

function WeddingMidDialog:HandleOneEffect(e, time_start, time_end)
  e.id = e.effectid
  if self.m_currenttime > time_start and self.m_currenttime < time_end then
    if e.effect == 0 then
      local path = MHSD_UTILS.get_effectpathFromCeffectPathTable(e.id)
      if path == "" then
        path = MHSD_UTILS.get_effectpath(e.id)
      end
      
      if path ~= "" then
        e.effect = GetGameUIManager():AddUIEffect(self.m_playeffect_label, path, true)
        if e.id ~= 10456 then
          local pt = XiaoPang.CPOINT(CEGUI.System:getSingleton():getGUISheet():getPixelSize().width/2, 0)
          e.effect:SetLocation(pt)
        end
      end
    end
  else
    if e.effect ~= 0 then
      GetGameUIManager():RemoveUIEffect(e.effect)
      e.effect = 0
    end
  end
end

function WeddingMidDialog:HandleEffects()
    if self.m_currenttime == nil or self.m_isjingdian == nil then
      return
    end
    
    for k, v in pairs(self.m_effectTable) do
      if self.m_isjingdian == true then
        self:HandleOneEffect(v, v.midstart, v.midend)
      else
        self:HandleOneEffect(v, v.highstart, v.highend)
      end
    end

end

function WeddingMidDialog:HandleSpeakLabel(thisTime)
    --LogInfo("WeddingMidDialog HandleSpeakLabel.")
    for i=1, 3 do
      if self.m_speakEnable[i] then
        self.m_speakInterval[i] = self.m_speakInterval[i] - thisTime
        if self.m_speakInterval[i] < 0 then
          self.m_speakEnable[i] = false
          self.m_speakLabel[i]:setVisible(false)
        end
      end
    end
end

function WeddingMidDialog:HandleSpriteAction(thisTime)
    --LogInfo("WeddingMidDialog HandleSpriteAction.")
    if self.m_currenttime == nil or self.m_isjingdian == nil then
      --debug code ********
      --self.m_currenttime = 600.0
      --self.m_isjingdian = false
      --self.m_master = 1
      --self.m_btnHongbao:setVisible(true)
      --self.m_btnYuanbao:setVisible(true)
      --debug code ********
      return
    end
    
    self.m_currenttime = self.m_currenttime + thisTime
    local curIndex = math.floor(self.m_currenttime)

    for k,v in pairs(self.m_actionTable) do
      local iscurtimepoint = true
      if self.m_isjingdian == true then
        iscurtimepoint = curIndex == v.timepoint
      else
        iscurtimepoint = curIndex == v.htimepoint
      end
      
      if iscurtimepoint and v.done == false then
        v.done = true
        self:ProcessAction(v)
      end
    end
end

function WeddingMidDialog:ProcessAction(action)
  LogInfo("WeddingMidDialog HandleSpriteAction.")
 
   --turn round and do action
  if action.action == 1 then
    self:DoAction(action.npctype, action.direction)
  end
   
  --speak
  if action.action == 2 then
    self:DoSpeak(action.npctype, action.direction, action.talk)
  end
  
  --do nothing, just turn round
  if action.action == 3 then
    self:TurnRound(action.npctype, action.direction)
  end
  
end

function WeddingMidDialog:DoAction(npctype, direction)
  self:TurnRound(npctype, direction)
  --xinlang
  if npctype == 1 then
    self.m_pSprite1:PlayAction(2)
  end
  --xinniang
  if npctype == 2 then
    self.m_pSprite2:PlayAction(2)
  end
  --yuelao
  if npctype == 3 then
    self.m_pSprite3:PlayAction(2)
  end
end

function WeddingMidDialog:DoSpeak(npctype, direction, talk)
  self:TurnRound(npctype, direction)
  
  self.m_speakEnable[npctype] = true
  self.m_speakInterval[npctype] = 2.0

  self.m_speakLabel[npctype]:Clear()
  self.m_speakLabel[npctype]:AppendText(CEGUI.String(talk))
  self.m_speakLabel[npctype]:Refresh()
  local needSize = self.m_speakLabel[npctype]:GetExtendSize()
  needSize.width = needSize.width + 10
  needSize.height = needSize.height + 8
  self.m_speakLabel[npctype]:setSize(CEGUI.UVector2(CEGUI.UDim(0, needSize.width), CEGUI.UDim(0, needSize.height)))
  
  self.m_speakLabel[npctype]:setVisible(true)
end

function WeddingMidDialog:TurnRound(npctype, direction)
  --xinlang
  if npctype == 1 then
    self.m_pSprite1:SetUIDirection(direction)
  end
  --xinniang
  if npctype == 2 then
    self.m_pSprite2:SetUIDirection(direction)
  end
  --yuelao
  if npctype == 3 then
    self.m_pSprite3:SetUIDirection(direction)
  end
end

return WeddingMidDialog
