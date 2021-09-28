require "ui.dialog"
require "utils.tableutil"
require "utils.mhsdutils"

FanfanleRewardDlg = {}
setmetatable(FanfanleRewardDlg, Dialog)
FanfanleRewardDlg.__index = FanfanleRewardDlg 

-- For singleton
local _instance

function FanfanleRewardDlg.getInstance()
    if not _instance then
        _instance = FanfanleRewardDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function FanfanleRewardDlg.getInstanceAndShow()
    if not _instance then
        _instance = FanfanleRewardDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end

    return _instance
end

function FanfanleRewardDlg.getInstanceNotCreate()
    return _instance
end

function FanfanleRewardDlg.DestroyDialog()
	if _instance then
		_instance:OnClose() 
		_instance = nil
	end
end
----/////////////////////////////////////////------

function FanfanleRewardDlg.GetLayoutFileName()
    return "fanfanlereward.layout"
end

function FanfanleRewardDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FanfanleRewardDlg)

    return self
end

function FanfanleRewardDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    self.FFLMgr = FanfanleManager.getInstance()

    self.m_itemGiftA = CEGUI.toItemCell(winMgr:getWindow("fanfanlereward/case1/itemcell0"))
    self.m_itemGiftB = CEGUI.toItemCell(winMgr:getWindow("fanfanlereward/case1/itemcell1"))
    self.m_txtNameA = winMgr:getWindow("fanfanlereward/case1/name0")
    self.m_txtNameB = winMgr:getWindow("fanfanlereward/case1/name1")
    self.m_btnBuy = CEGUI.toPushButton(winMgr:getWindow("fanfanlereward/button"))
    self.m_btnGet = CEGUI.toPushButton(winMgr:getWindow("fanfanlereward/button1"))
    self.m_txtGiftAStep = winMgr:getWindow("fanfanlereward/case1/num0")
    self.m_txtGiftBStep = winMgr:getWindow("fanfanlereward/case1/num01")
    self.m_txtYuanbao = winMgr:getWindow("fanfanlereward/tittletext2")

    self.m_btnBuy:subscribeEvent("Clicked", FanfanleRewardDlg.HandleBuyBtnClicked, self)
    self.m_btnGet:subscribeEvent("Clicked", FanfanleRewardDlg.HandleGetGiftBtnClicked, self)

    local info = self.FFLMgr:GetGreatGiftInfo()
    -- Set items' id, Number and Step
    local itemAbean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(info.giftAID)
    self.m_itemGiftA:SetImage(GetIconManager():GetItemIconByID(itemAbean.icon))
    local itemBbean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(info.giftBID)
    self.m_itemGiftB:SetImage(GetIconManager():GetItemIconByID(itemBbean.icon))
    self.m_itemGiftA:SetTextUnit(info.giftANum)
    self.m_itemGiftB:SetTextUnit(info.giftBNum)
    self.m_itemGiftA:SetCornerImage("MainControl32", "fanfanpintu1")
    self.m_itemGiftB:SetCornerImage("MainControl32", "fanfanpintu2")
    self.m_txtNameA:setText(itemAbean.name)
    self.m_txtNameB:setText(itemBbean.name)

    local useStep = TableUtil.tablelength(self.FFLMgr:GetCardsTable())
    local unuseStep = self.FFLMgr:GetLeftStep()
    local sumStep = useStep+unuseStep
    local yuanbaoNum = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cfanfanleaddtimes"):getRecorder(tonumber(sumStep/5)).yuanbao

    if sumStep == 25 then
        self.m_btnBuy:setEnabled(false)
    end
    if TableUtil.tablelength(self.FFLMgr:GetGiftList()) == 0 then
        GetGameUIManager():AddMessageTipById(145887)
        self.m_btnGet:setEnabled(false)
    end

    local msg = MHSD_UTILS.get_msgtipstring(145845)
    msg = string.gsub(msg,"%$parameter1%$",tostring(yuanbaoNum))
    self.m_txtYuanbao:setText(msg)

    local info = self.FFLMgr:GetGreatGiftInfo()
    self.m_txtGiftAStep:setText(info.giftAStep)
    self.m_txtGiftBStep:setText(info.giftBStep)

    self.m_spGiftList = CEGUI.Window.toScrollablePane(winMgr:getWindow("fanfanlereward/case/huadong"))
    self.m_spGiftList:EnableHorzScrollBar(true)

    local index = 0
    for k,v in pairs(self.FFLMgr:GetGiftList()) do
        if k > 0 then
            local namePrefix = tostring(index)
            local rootWnd = winMgr:loadWindowLayout("fanfanlerewardcell.layout", namePrefix)
            if rootWnd then
                self.m_spGiftList:addChildWindow(rootWnd)
                local width = rootWnd:getPixelSize().width
                local yPos = 1.0
                local xPos = 1.0+(width+1.0)*(index)
                rootWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,xPos),CEGUI.UDim(0.0,yPos)))

                local itemCell = CEGUI.toItemCell(winMgr:getWindow(namePrefix .. "fanfanlerewardcell/itemcell"))
                local itemName = winMgr:getWindow(namePrefix .. "fanfanlerewardcell/text0")

                local itemBean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(k)
                itemCell:SetImage(GetIconManager():GetItemIconByID(itemBean.icon))
                itemCell:SetTextUnit(v)
                itemName:setText(itemBean.name)
            end
            index = index + 1
        end
    end

    if info.giftAStep >= 4 then
        if not GetGameUIManager():IsWindowHaveEffect(self.m_itemGiftA) then
            GetGameUIManager():AddUIEffect(self.m_itemGiftA, MHSD_UTILS.get_effectpath(10413))
        end
        self.m_itemGiftA:Clear()
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
        self.m_itemGiftB:SetTextUnit(info.giftBNum)
        self.m_itemGiftB:SetImage(GetIconManager():GetItemIconByID(itemBbean.icon))
    else
        GetGameUIManager():RemoveUIEffect(self.m_itemGiftB)
    end
end

-- Callback of the gift button
-- @return : no return
function FanfanleRewardDlg:HandleGetGiftBtnClicked(args)
    self.FFLMgr:RequireGetGift()
end

-- Callback of the buy button
-- @return : no return
function FanfanleRewardDlg:HandleBuyBtnClicked(args)
    self.FFLMgr:RequireMoreStep()
end

return FanfanleRewardDlg