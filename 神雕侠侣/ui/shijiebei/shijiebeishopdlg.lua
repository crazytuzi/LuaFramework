require "ui.dialog"
require "utils.mhsdutils"
require "utils.stringbuilder"

ShijiebeiShopDialog = {}
setmetatable(ShijiebeiShopDialog, Dialog)
ShijiebeiShopDialog.__index = ShijiebeiShopDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ShijiebeiShopDialog.getInstance()
	LogInfo("enter get ShijiebeiShopDialog instance")
    if not _instance then
        _instance = ShijiebeiShopDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ShijiebeiShopDialog.getInstanceAndShow()
	LogInfo("enter ShijiebeiShopDialog instance show")
    if not _instance then
        _instance = ShijiebeiShopDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set ShijiebeiShopDialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ShijiebeiShopDialog.getInstanceNotCreate()
    return _instance
end

function ShijiebeiShopDialog.DestroyDialog()
	require "ui.shijiebei.shijiebeilabel".DestroyDialog()
	if _instance then 
		LogInfo("destroy ShijiebeiShopDialog")
		_instance:OnClose()
		_instance = nil
	end
end

----/////////////////////////////////////////------

function ShijiebeiShopDialog.GetLayoutFileName()
    return "footballguess.layout"
end

function ShijiebeiShopDialog:OnCreate()
	LogInfo("ShijiebeiShopDialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    
    --gonggao
    self.m_pBroadText = CEGUI.toAutoScrollStaticText(winMgr:createWindow("TaharezLook/AutoScrollStaticText"))
    self.m_pBroadText:setSize(CEGUI.UVector2(CEGUI.UDim(0, 526), CEGUI.UDim(0, 30)))
    self.m_pBroadText:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 296), CEGUI.UDim(0, 48)))
    self.m_pBroadText:setProperty("BackgroundEnabled", "False")
    self.m_pBroadText:setProperty("FrameEnabled", "False")
    self.m_pBroadText:setProperty("TextColours", "FFFFE600")
    self.m_pBroadText:setMousePassThroughEnabled(true)
    self.m_pBroadText:setAlwaysOnTop(true)
    self.m_pBroadText:SetStopAtEdge(false)
    self.m_pMainFrame:addChildWindow(self.m_pBroadText)
    
    self.m_BroadIndex = 0
    self.m_pBroadText:setText(MHSD_UTILS.get_resstring(3126 + self.m_BroadIndex))

    --random tips 3108~3111
    self.m_tips = CEGUI.toAnimateText(winMgr:getWindow("footballguess/info/main"))
    self.m_tips:setText(MHSD_UTILS.get_resstring(3108))
    self.m_timeAdd = 0.0
    self.m_tipsIndex = 1

    --buy button
    self.m_btn_buy = winMgr:getWindow("footballguess/imgbtn")
    self.m_img_support = winMgr:getWindow("footballguess/imgbtn/img")
    self.m_btn_buy:subscribeEvent("Clicked", ShijiebeiShopDialog.HandleBuyClicked, self)

    --bencimianfei text
    self.m_bencimianfei = winMgr:getWindow("footballguess/shuoming")

    --main pane
    self.m_main_pane = winMgr:getWindow("footballguess/main")
    local configSjb = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cshijiebeishangcheng")
    local configItem = knight.gsp.item.GetCItemAttrTableInstance()

    self.m_selectedCell  = 0
    self.m_cells = {}
    for i=1, 32 do
        local itemid = configSjb:getRecorder(i).itemid

        local cellWnd = winMgr:loadWindowLayout("footballguesscell.layout", tostring(i))
        self.m_cells[i] = cellWnd
        cellWnd:setID(i)
        self.m_main_pane:addChildWindow(cellWnd)

        --set selectable
        cellWnd:subscribeEvent("MouseClick", ShijiebeiShopDialog.HandleProductCellClicked, self)

        --hide not used controls
        winMgr:getWindow(tostring(i) .. "footballguesscell/yuanjia"):setVisible(false)
        winMgr:getWindow(tostring(i) .. "footballguesscell/vip"):setVisible(false)
        winMgr:getWindow(tostring(i) .. "footballguesscell/name1"):setVisible(false)
        winMgr:getWindow(tostring(i) .. "footballguesscell/buy"):setVisible(false)
        winMgr:getWindow(tostring(i) .. "footballguesscell/num1"):setVisible(false)

        --set item image
        winMgr:getWindow(tostring(i) .. "footballguesscell/name"):setText(configItem:getRecorder(itemid).name)
        local item = CEGUI.toItemCell(winMgr:getWindow(tostring(i) .. "footballguesscell/item"))
        item:setID(itemid)
        item:SetImage(GetIconManager():GetItemIconByID(configItem:getRecorder(itemid).icon))
        item:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
        item:subscribeEvent("TableClick", ShijiebeiShopDialog.HandleProductCellClicked2, self)

        --set position
        local y = math.floor((i-1)/2) * cellWnd:getSize().y.offset
        local x = 0
        if math.mod(i, 2) == 0 then
            x = 0.5
        end
        cellWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(x, 0), CEGUI.UDim(0, y)))
    end

    self:GetWindow():subscribeEvent("WindowUpdate", ShijiebeiShopDialog.HandleWindowUpdate, self)
    
    LogInfo("ShijiebeiShopDialog oncreate end")
end

------------------- private: -----------------------------------
function ShijiebeiShopDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ShijiebeiShopDialog)
    return self
end

function ShijiebeiShopDialog:SetLeftTimes(used_times, free_times, pay_times)
	LogInfo("ShijiebeiLabel:SetLeftTimes")
    self.m_used_times = used_times
    self.m_free_times = free_times
    self.m_pay_times = pay_times

    if used_times >= free_times then
        self.m_bencimianfei:setVisible(false)
    end

    if used_times >= (free_times + pay_times) then
        self.m_btn_buy:setEnabled(false)
        self.m_img_support:setProperty("Image", "set:MainControl38 image:zhichiblack")
    end
end

function ShijiebeiShopDialog:HandleBuyClicked(args)
    LogInfo("ShijiebeiLabel:HandleBuyClicked")
    if self.m_selectedCell ~= 0 then
        if self.m_used_times >= self.m_free_times then
            local functable = {}
            function functable.acceptCallback()
                GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
                require "protocoldef.knight.gsp.activity.football.cbuyfootballcard"
                local p = CBuyFootballCard.Create()
                p.id = self.m_selectedCell
                p.num = 1
                require "manager.luaprotocolmanager":send(p)
            end

            local configSjb = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cshijiebeishangcheng")
            local itemPrice = configSjb:getRecorder(self.m_selectedCell).price

            local formatstr = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(146178).msg
            local sb = require "utils.stringbuilder":new()
            sb:Set("parameter1", itemPrice or "55")
            local msg = sb:GetString(formatstr)
            sb:delete()
            
            GetMessageManager():AddConfirmBox(eConfirmNormal,
            msg,
            functable.acceptCallback,
            functable,
            CMessageManager.HandleDefaultCancelEvent,
            CMessageManager)
        else
            require "protocoldef.knight.gsp.activity.football.cbuyfootballcard"
            local p = CBuyFootballCard.Create()
            p.id = self.m_selectedCell
            p.num = 1
            require "manager.luaprotocolmanager":send(p)
        end
    else
        if GetChatManager() then
            GetChatManager():AddTipsMsg(146180)
        end
    end
end

function ShijiebeiShopDialog:HandleProductCellClicked(args)
    LogInfo("ShijiebeiLabel:HandleProductCellClicked")
    local mouseArgs = CEGUI.toMouseEventArgs(args)
    self.m_selectedCell = mouseArgs.window:getID()

    for i=1,32 do
        if self.m_selectedCell == i then
            self.m_cells[i]:setProperty("Image", "set:MainControl9 image:shopcellchoose")
        else
            self.m_cells[i]:setProperty("Image", "set:MainControl9 image:shopcellnormal")
        end
    end
end

function ShijiebeiShopDialog:HandleProductCellClicked2(args)
    LogInfo("ShijiebeiLabel:HandleProductCellClicked2")
    local mouseArgs = CEGUI.toMouseEventArgs(args)
    local itemid = mouseArgs.window:getID()

    local configSjb = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cshijiebeishangcheng")
    for i=1, 32 do
        if itemid == configSjb:getRecorder(i).itemid then
            self.m_selectedCell = i
            self.m_cells[i]:setProperty("Image", "set:MainControl9 image:shopcellchoose")
        else
            self.m_cells[i]:setProperty("Image", "set:MainControl9 image:shopcellnormal")
        end
    end
end

function ShijiebeiShopDialog:HandleWindowUpdate(eventArgs)
    self.m_timeAdd = self.m_timeAdd + CEGUI.toUpdateEventArgs(eventArgs).d_timeSinceLastFrame
    if self.m_timeAdd > 10.0 then
        self.m_timeAdd = 0.0
        self.m_tipsIndex = self.m_tipsIndex + 1
        if self.m_tipsIndex == 5 then
            self.m_tipsIndex = 1
        end
        self.m_tips:setText(MHSD_UTILS.get_resstring(3107 + self.m_tipsIndex))
    end
    
    --gonggao
    if self.m_pBroadText:GetTextEndTime() > 0 then
        self.m_BroadIndex = self.m_BroadIndex + 1
        if self.m_BroadIndex > 10 then
          self.m_BroadIndex = 0
        end
        self.m_pBroadText:setText(MHSD_UTILS.get_resstring(3126 + self.m_BroadIndex))
    end
end

return ShijiebeiShopDialog
