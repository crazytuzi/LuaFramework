-- fanfanlemanager.lua
-- It the a manager for wulinmiji
-- create by wuyao in 2014-3-18
require "utils.tableutil"

FanfanleManager = {}
FanfanleManager.__index = FanfanleManager


-- For singleton
local _instance
function FanfanleManager.getInstance()
    if not _instance then
        _instance = FanfanleManager:new()
    end
    
    return _instance
end

function FanfanleManager.getInstanceNotCreate()
    return _instance
end

function FanfanleManager.Destroy()
    if _instance then 
        _instance = nil
    end
end

function FanfanleManager:new()
    local self = {}
    setmetatable(self, FanfanleManager)

    self.m_vOpenCardList = {}
    self.m_iLeft = 0
    self.m_iGiftAStep = 0
    self.m_iGiftBStep = 0
    self.m_iGiftAID = 0
    self.m_iGiftBID = 0
    self.m_iGiftANum = 0
    self.m_iGiftBNum = 0
    self.m_bHaveGetGift = false
    self.m_bToOpenGift = false
    self.m_iTime = 0

    return self
end

-- Set data when receive data from server
-- @param SFanfanleInfo : SFanfanleInfo protocol
-- @param SDrawItem : SDrawItem protocol
-- @param SUpdateBox : SUpdateBox protocol
-- @param SDrawAward : SDrawAward protocol
-- @return : no return
function FanfanleManager:SetDataFromServer(SFanfanleInfo, SDrawItem, SUpdateBox, SDrawAward)
    if SFanfanleInfo ~= nil then
        self.m_iLeft = SFanfanleInfo.leftturnnum
        self.m_iGiftAStep = SFanfanleInfo.suipiananum
        self.m_iGiftBStep = SFanfanleInfo.suipianbnum
        self.m_iGiftAID = SFanfanleInfo.suipianaid
        self.m_iGiftBID = SFanfanleInfo.suipianbid
        self.m_iGiftANum = SFanfanleInfo.suipianacount
        self.m_iGiftBNum = SFanfanleInfo.suipianbcount
        self.m_vOpenCardList = {}
        for k,v in pairs(SFanfanleInfo.items) do
            self.m_vOpenCardList[v.xpos*5+v.ypos+1] = v
        end
        self.m_bHaveGetGift = false
    end

    if SDrawItem ~= nil then
        self.m_vOpenCardList[SDrawItem.item.xpos*5+SDrawItem.item.ypos+1] = SDrawItem.item
        self.m_iLeft = SDrawItem.leftturnnum
        self.m_iGiftAStep = SDrawItem.suipiananum
        self.m_iGiftBStep = SDrawItem.suipianbnum
        self.m_bHaveGetGift = false
    end

    if SUpdateBox ~= nil then
        self.m_iGiftAID = SUpdateBox.suipianaid
        self.m_iGiftBID = SUpdateBox.suipianbid
        self.m_iGiftANum = SUpdateBox.suipianacount
        self.m_iGiftBNum = SUpdateBox.suipianbcount
        self.m_bHaveGetGift = false
    end

    if SDrawAward ~= nil then
        for k,v in pairs(SDrawAward.items) do
            self.m_vOpenCardList[v.xpos*5+v.ypos+1] = v
        end
        self.m_bHaveGetGift = true
    end
end

-- Require to open card
-- @param index : index of the card
-- @return : no return
function FanfanleManager:RequireOpen(index)
    local req = require "protocoldef.knight.gsp.activity.fanfanle.cdrawitem".Create()
    req.xpos = math.floor((index-1)/5)
    req.ypos = (index-1)%5
    LuaProtocolManager.getInstance():send(req)
end

-- Require refresh gift
-- @return : no return
function FanfanleManager:RequireRefreshGift()
    local req = require "protocoldef.knight.gsp.activity.fanfanle.cupdatebox".Create()
    LuaProtocolManager.getInstance():send(req)
end

-- Require start a new game
-- @return : no return
function FanfanleManager:RequireRefreshGame()
    local req = require "protocoldef.knight.gsp.activity.fanfanle.creqfanfanle".Create()
    LuaProtocolManager.getInstance():send(req)
end

-- Require get gift
-- @return : no return
function FanfanleManager:RequireGetGift()
    local req = require "protocoldef.knight.gsp.activity.fanfanle.cdrawgift".Create()
    LuaProtocolManager.getInstance():send(req)
end

-- Require more step
function FanfanleManager:RequireMoreStep()
    local req = require "protocoldef.knight.gsp.activity.fanfanle.cbuyextracount".Create()
    LuaProtocolManager.getInstance():send(req)
end

-- Return wether game is over
-- @return : return 0 when over, 1 when have step, 2 when have gift
function FanfanleManager:GetGameState()

end

-- Get the main cards table
-- @return : a table with cards data, key is position, valus is info
function FanfanleManager:GetCardsTable()
    return self.m_vOpenCardList
end

-- Get the left step
-- @return : the left step number
function FanfanleManager:GetLeftStep()
    return self.m_iLeft
end

-- Get the end state
-- @return : is the game end
function FanfanleManager:IsEnd()
    return self.m_bHaveGetGift
end

-- Get the great gift info
-- @return : a table with great gift info
function FanfanleManager:GetGreatGiftInfo()
    local result = {}
    result.ableRefresh = TableUtil.tablelength(self.m_vOpenCardList) == 0
    result.giftAStep = self.m_iGiftAStep
    result.giftBStep = self.m_iGiftBStep
    result.giftAID = self.m_iGiftAID
    result.giftBID = self.m_iGiftBID
    result.giftANum = self.m_iGiftANum
    result.giftBNum = self.m_iGiftBNum
    return result
end

-- Get the gift list
-- @return : a table of gift which had been got
function FanfanleManager:GetGiftList()
    local giftList = {}
    local greatGift = self:GetGreatGiftInfo()

    if self.m_iGiftAStep >= 4 then
        giftList[self.m_iGiftAID] = self.m_iGiftANum
    end

    if self.m_iGiftBStep >= 4 then
        giftList[self.m_iGiftBID] = self.m_iGiftBNum
    end

    for k,v in pairs(self.m_vOpenCardList) do
        if v.itemtype == 3 then
            if giftList[v.itemid] ~= nil then
                giftList[v.itemid] = giftList[v.itemid] + v.itemcount
            else
                giftList[v.itemid] = v.itemcount
            end
        end
    end

    return giftList
end

-- Open Gift Dialog in 1s
-- @return : no return
function FanfanleManager:OpenGiftByTime()
    self.m_bToOpenGift = true
end


-- Open Gift Dialog in 1s run
-- @return : no return
function FanfanleManager:run(delta)
    if self.m_bToOpenGift then
        self.m_iTime = self.m_iTime + delta
    end

    if self.m_iTime >= 750 then
        self.m_iTime = 0
        self.m_bToOpenGift = false
        local FFLRewardDlg = require "ui.fanfanle.fanfanlerewarddlg".getInstanceAndShow()
    end
end

return FanfanleManager