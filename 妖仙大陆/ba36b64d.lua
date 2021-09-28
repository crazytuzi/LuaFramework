

local _M = {}
_M.__index = _M

local Player = require"Zeus.Model.Player"

local StrType = 0

local AllCardInfo = {}
local CardQuality = 0
local CardPos = 0
local LvUPCard = nil
local PreLvUPCard = {}


function _M.CardRegistRequest(c2s_cardTemplateId,cb)
  Pomelo.CardHandler.cardRegisterRequest(c2s_cardTemplateId,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      print (sjson)
      AllCardInfo = msg
      cb()
    end
  end)
end

function _M.CardPreLevelUpRequest(c2s_cardTemplateId,cb) 
  Pomelo.CardHandler.cardPreLevelUpRequest(c2s_cardTemplateId,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      PreLvUPCard = msg
      print (sjson)
      cb()
    end
  end)
end

function _M.CardLevelUpRequest(c2s_cardTemplateId,cb)
  Pomelo.CardHandler.cardLevelUpRequest(c2s_cardTemplateId,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      LvUPCard = msg
      print (sjson)
      cb()
    end
  end)
end

function _M.CardGetAwardRequest(c2s_awardId,cb)
  Pomelo.CardHandler.cardGetAwardRequest(c2s_awardId,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      print (sjson)
      
      cb()
    end
  end)
end

function _M.CardEquipRequest(c2s_cardId,c2s_holePos,cb)
  Pomelo.CardHandler.cardEquipRequest(c2s_cardId,c2s_holePos,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      AllCardInfo = msg
      print (sjson)
      cb()
    end
  end)
end

function _M.CardQueryAllDataRequest(cb)
  Pomelo.CardHandler.cardQueryAllDataRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      AllCardInfo = msg
      cb()
    end
  end)
end

function _M.test1()
    collectgarbage("collect")
    collectgarbage()
    print("now,Lua内存为:",collectgarbage("count")) 
end

function _M.collect1()
    print("now,Lua内存为:",collectgarbage("count"))
    collectgarbage()
    collectgarbage()
    print("now,Lua内存为:",collectgarbage("count"))
    
end

function _M.GetPreLvUPCard()
  return PreLvUPCard
end

function _M.GetLvUPCard()
  return LvUPCard
end

function _M.GetAllCardInfo()
  return AllCardInfo
end

function _M.SetCardPos(Pos)
  CardPos = Pos
end

function _M.GetCardPos()
  return CardPos+0
end

function _M.SetCardQuality(Quality)
  CardQuality = Quality
end

function _M.GetCardQuality()
  return CardQuality+0
end

function _M.SetCardType(type)
  StrType = type
end

function _M.GetCardType()
  return StrType+0
end

function _M.initial()
  print("CardEdit initial")
end

return _M
