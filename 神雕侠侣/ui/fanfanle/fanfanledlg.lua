require "ui.dialog"
require "ui.fanfanle.fanfanlemanager"
require "ui.fanfanle.fanfanlerewarddlg"
require "utils.mhsdutils"

FanfanleDlg = {}
setmetatable(FanfanleDlg, Dialog)
FanfanleDlg.__index = FanfanleDlg 

-- For singleton
local _instance

function FanfanleDlg.getInstance()
    if not _instance then
        _instance = FanfanleDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function FanfanleDlg.getInstanceAndShow()
    if not _instance then
        _instance = FanfanleDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end

    return _instance
end

function FanfanleDlg.getInstanceNotCreate()
    return _instance
end

function FanfanleDlg.DestroyDialog()
    if FanfanleRewardDlg.getInstanceNotCreate() ~= nil then
        FanfanleRewardDlg.DestroyDialog()
    end
	if _instance then
        FanfanleManager.Destroy()
		_instance:OnClose()
		_instance = nil
	end
end

function FanfanleDlg.GetLayoutFileName()
    return "fanfanle.layout"
end

function FanfanleDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FanfanleDlg)

    return self
end

function FanfanleDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    self.FFLMgr = FanfanleManager.getInstance()

    self.m_txtChat = winMgr:getWindow("fanfanle/right/talk/text")
    self.m_txtMain = winMgr:getWindow("fanfanle/right/case/text")

    self.m_txtChat:setText(MHSD_UTILS.get_msgtipstring(145868))
    self.m_txtMain:setText(MHSD_UTILS.get_msgtipstring(145869))

    self.m_vCells = {}
    for i=1, 25, 1 do
        self.m_vCells[i] = {}
        self.m_vCells[i].item = CEGUI.toItemCell(winMgr:getWindow("fanfanle/left/image" .. tostring(i-1) .. "/itemcell"))
        self.m_vCells[i].image = winMgr:getWindow("fanfanle/left/image" .. tostring(i-1))
        self.m_vCells[i].image:setUserString("index", tostring(i))
        self.m_vCells[i].item:setMousePassThroughEnabled(true)
        self.m_vCells[i].image:setMousePassThroughEnabled(true)
        self.m_vCells[i].item:SetTextUnit("-1")
    end
    winMgr:getWindow("fanfanle/left"):subscribeEvent("MouseButtonUp", FanfanleDlg.HandleCardCilcked, self)

    self.m_btnStart = CEGUI.toPushButton(winMgr:getWindow("fanfanle/right/button"))
    self.m_btnGift = CEGUI.toPushButton(winMgr:getWindow("fanfanle/buttonnew"))
    self.m_txtYuanbao = winMgr:getWindow("fanfanle/right/text2")

    self.m_btnStart:subscribeEvent("Clicked", FanfanleDlg.HandleStartBtnClicked, self)
    self.m_btnGift:subscribeEvent("Clicked", FanfanleDlg.HandleGiftBtnClicked, self)

    self.m_itemGiftA = CEGUI.toItemCell(winMgr:getWindow("fanfanle/itemcell0"))
    self.m_itemGiftB = CEGUI.toItemCell(winMgr:getWindow("fanfanle/itemcell1"))

    self.m_txtLeftNum = winMgr:getWindow("fanfanle/text2")

    self.m_vGiftPointA = {}
    self.m_vGiftPointB = {}
    for i=1, 4, 1 do
        self.m_vGiftPointA[i] = winMgr:getWindow("fanfanle/point/image" .. i-1)
        self.m_vGiftPointB[i] = winMgr:getWindow("fanfanle/point1/image" .. i-1)
    end

    -- self:RefreshTopView()
    -- self:RefreshMainView()
    -- self:RefreshRightView()
end

-- Refresh the gift view of th top
-- @return : no return
function FanfanleDlg:RefreshTopView()
    local info = self.FFLMgr:GetGreatGiftInfo()
    -- Set items' id, Number, Step and Icon
    local itemAbean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(info.giftAID)
    self.m_itemGiftA:SetImage(GetIconManager():GetItemIconByID(itemAbean.icon))
    local itemBbean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(info.giftBID)
    self.m_itemGiftB:SetImage(GetIconManager():GetItemIconByID(itemBbean.icon))
    self.m_itemGiftA:SetTextUnit(info.giftANum)
    self.m_itemGiftB:SetTextUnit(info.giftBNum)
    self:SetGiftPoint(1, info.giftAStep)
    self:SetGiftPoint(2, info.giftBStep)
    self.m_itemGiftA:SetCornerImage("MainControl32", "fanfanpintu1")
    self.m_itemGiftB:SetCornerImage("MainControl32", "fanfanpintu2")
    self.m_itemGiftA:setID(info.giftAID)
    self.m_itemGiftB:setID(info.giftBID)
    MHSD_UTILS.SetWindowShowtips(self.m_itemGiftA)
    MHSD_UTILS.SetWindowShowtips(self.m_itemGiftB)
    -- Set button state
    self.m_btnGift:setEnabled(info.ableRefresh)
    if info.giftAStep >= 4 then
        if not GetGameUIManager():IsWindowHaveEffect(self.m_itemGiftA) then
            GetGameUIManager():AddUIEffect(self.m_itemGiftA, MHSD_UTILS.get_effectpath(10413))
        end
        self.m_itemGiftA:Clear()
        self.m_itemGiftA:setID(info.giftAID)
        self.m_itemGiftA:SetTextUnit(info.giftANum)
        self.m_itemGiftA:SetImage(GetIconManager():GetItemIconByID(itemAbean.icon))
    else
        GetGameUIManager():RemoveUIEffect(self.m_itemGiftA)
    end

    if info.giftBStep >= 4 then
        if not GetGameUIManager():IsWindowHaveEffect(self.m_itemGiftB) then
            GetGameUIManager():AddUIEffect(self.m_itemGiftB, MHSD_UTILS.get_effectpath(10413))
        end
        self.m_itemGiftB:Clear()
        self.m_itemGiftB:setID(info.giftBID)
        self.m_itemGiftB:SetTextUnit(info.giftBNum)
        self.m_itemGiftB:SetImage(GetIconManager():GetItemIconByID(itemBbean.icon))
    else
        GetGameUIManager():RemoveUIEffect(self.m_itemGiftB)
    end
end

-- Refresh the info view in the ritht
-- @return : no return
function FanfanleDlg:RefreshRightView()
    -- Set Yuanbao number
    self.m_txtYuanbao:setText(GetDataManager():GetYuanBaoNumber())
end

-- Refresh the main view
-- @return : no return
function FanfanleDlg:RefreshMainView()
    local cardList = self.FFLMgr:GetCardsTable()
    -- Set all cards form manager
    for i=1, 25, 1 do
        self.m_vCells[i].item:Clear()
        -- no opened
        if cardList[i] == nil then
            self.m_vCells[i].item:SetTextUnit("")
            self.m_vCells[i].item:setVisible(false)
            self.m_vCells[i].item:setEnabled(true)
            self.m_vCells[i].image:setEnabled(true)
        -- empty opened
        elseif cardList[i].itemid <= 0 and cardList[i].isopen ~= 0 then
            self.m_vCells[i].item:setVisible(true)
            self.m_vCells[i].item:setEnabled(false)
            self.m_vCells[i].image:setEnabled(true)
        -- open in the end
        elseif cardList[i].isopen == 0 and cardList[i].itemtype ~= 3 then
            local itembean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cardList[i].itemid)
            self.m_vCells[i].item:SetImage(GetIconManager():GetItemIconByID(itembean.icon))
            self.m_vCells[i].item:SetTextUnit(tostring(cardList[i].itemcount))
            self.m_vCells[i].item:setVisible(true)
            self.m_vCells[i].item:setEnabled(false)
            if cardList[i].itemtype ~= 3 then
                self.m_vCells[i].item:SetCornerImage("MainControl32", "fanfanpintu" .. cardList[i].itemtype)
            end
            self.m_vCells[i].image:setEnabled(false)
        -- open with item
        elseif cardList[i].isopen == 1 then
            local itembean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cardList[i].itemid)
            self.m_vCells[i].item:SetImage(GetIconManager():GetItemIconByID(itembean.icon))
            self.m_vCells[i].item:SetTextUnit(tostring(cardList[i].itemcount))
            self.m_vCells[i].item:setVisible(true)
            self.m_vCells[i].item:setEnabled(true)
            if cardList[i].itemtype ~= 3 then
                self.m_vCells[i].item:SetCornerImage("MainControl32", "fanfanpintu" .. cardList[i].itemtype)
            end    
            self.m_vCells[i].image:setEnabled(true)
        end
    end
    -- Set left number
    self.m_txtLeftNum:setText(self.FFLMgr:GetLeftStep())
end

function FanfanleDlg:RefreshAllView()
    self:RefreshMainView()
    self:RefreshRightView()
    self:RefreshTopView()
    if self.FFLMgr:GetLeftStep() == 0 then
    end
end

-- Set point of great gift
-- @param gift : which gitf step to change, 1 is left, 2 is right
-- @param step : the step of the gift, 0 to 4
-- @return : no return
function FanfanleDlg:SetGiftPoint(gift, step)
    if step > 4 or step < 0 then
        return
    end

    local winMgr = CEGUI.WindowManager:getSingleton()
    if gift == 1 then
        for i=1, step, 1 do
            self.m_vGiftPointA[i]:setProperty("Image", "set:MainControl32 image:rolepointlight")
        end
        for i=step+1, 4, 1 do
            self.m_vGiftPointA[i]:setProperty("Image", "set:MainControl32 image:rolepointnormal")
        end
    elseif gift == 2 then
        for i=1, step, 1 do
            self.m_vGiftPointB[i]:setProperty("Image", "set:MainControl32 image:rolepointlight")
        end
        for i=step+1, 4, 1 do
            self.m_vGiftPointB[i]:setProperty("Image", "set:MainControl32 image:rolepointnormal")
        end
    end
end

-- Callback of the card cell, use the area rect in the background
-- @return : no return
function FanfanleDlg:HandleCardCilcked(args)
    local e = CEGUI.toMouseEventArgs(args)
    for i=1 ,25 ,1 do
        if self.m_vCells[i].image:getHitTestRect():isPointInRect(e.position) then
            local index = self.m_vCells[i].image:getUserString("index")
            self.FFLMgr:RequireOpen(index) 
        end
    end
    if self.FFLMgr:GetLeftStep() <= 0 and not self.FFLMgr:IsEnd() then
        FanfanleRewardDlg:getInstanceAndShow()
    end
end

-- Callback of the start button
-- @return : no return
function FanfanleDlg:HandleStartBtnClicked(args)
    -- Game is end
    if self.FFLMgr:IsEnd() then
        self.FFLMgr:RequireRefreshGame()
    -- Left step more than 0
    elseif self.FFLMgr:GetLeftStep() ~= 0 then
        local function ClickYes(self, args)
            GetMessageManager():CloseConfirmBox(eConfirmNormal, false)
            if TableUtil.tablelength(self.FFLMgr:GetGiftList()) ~= 0 then
                GetGameUIManager():AddMessageTipById(145839)
                FanfanleRewardDlg.getInstanceAndShow()
            else
                self.FFLMgr:RequireGetGift()
            end            
        end
        local msg = MHSD_UTILS.get_msgtipstring(145840)
        GetMessageManager():AddConfirmBox(eConfirmNormal,msg,ClickYes,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
    -- Have gift
    else
        if TableUtil.tablelength(self.FFLMgr:GetGiftList()) ~= 0 then
            GetGameUIManager():AddMessageTipById(145839)
            FanfanleRewardDlg.getInstanceAndShow()
        else
            self.FFLMgr:RequireGetGift()
        end
    end
end

-- Callback of the gift button
-- @return : no return
function FanfanleDlg:HandleGiftBtnClicked(args)
    self.FFLMgr:RequireRefreshGift()
end

return FanfanleDlg
