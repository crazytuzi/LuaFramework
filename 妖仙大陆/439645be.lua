local _M = {}
_M.__index = _M

local cjson = require "cjson"

local valkyrieDetail = {}  
local valkyrieGifts = {}  
local giftChangeCb = nil


_M.ItemState = {
  noBuy = 0,  
  normal = 1, 
  useing = 2  
}

function _M.RemoveGiftChangeListener()
	giftChangeCb = nil
end

function _M.SetGiftChangeListener(cb)
	giftChangeCb = cb
end

function _M.RequestUnEquipGift(vId, iId, cb)
	Pomelo.GoddessHandler.unEquipGiftRequest(vId, iId, function(ex, sjson)
		print("RequestUnEquipGift")
		
		if ex == nil then
			local param = sjson:ToData()
			local state = param.s2c_state
			if cb ~= nil then
				cb()
			end
		end
	end, nil)
end

function _M.RequestEquipGift(vId, iId, cb)
	Pomelo.GoddessHandler.equipGiftRequest(vId, iId, function(ex, sjson)
		print("RequestEquipGift")
		
		if ex == nil then
			local param = sjson:ToData()
			local state = param.s2c_state
			if cb ~= nil then
				cb()
			end
		end
	end, nil)
end

function _M.RequestBuyGift(vId, iId, cb)
	Pomelo.GoddessHandler.buyGiftRequest(vId, iId, function(ex, sjson)
		print("RequestBuyGifts")
		
		if ex == nil then
			local param = sjson:ToData()
			local state = param.s2c_state
			if cb ~= nil then
				cb()
			end
		end
	end, nil)
end

function _M.RequestValkyrieGifts(id, cb)
	
	
	
	
	
	

	if valkyrieGifts[id] ~= nil then 
		if cb ~= nil then
			cb(valkyrieGifts[id])
		end
		return
	end

	Pomelo.GoddessHandler.getGiftsRequest(id, function(ex, sjson)
		print("RequestValkyrieGifts  "..id)
		
		if ex == nil then
			local param = sjson:ToData()
			valkyrieGifts[id] = param.s2c_gifts
			if cb ~= nil then
				cb(valkyrieGifts[id])
			end
		end
	end, nil)
end

function _M.RequestValkyrieUpIntimacy(id, cb)
	Pomelo.GoddessHandler.upIntimacyRequest(id, 1, function(ex, sjson)
		print("RequestValkyrieUpIntimacy")
		
		if ex == nil then
			if cb ~= nil then
				cb()
			end
		end
	end, nil)
end

function _M.RequestValkyrieUpStar(id, cb)
	Pomelo.GoddessHandler.upStarRequest(id, function(ex, sjson)
		print("RequestValkyrieUpStar")
		
		if ex == nil then
			if cb ~= nil then
				cb()
			end
		end
	end, nil)
end

function _M.RequestValkyrieDetail(id, isForceReq, cb)
	
	
	
	
	
	

	if not isForceReq and valkyrieDetail[id] ~= nil then 
		if cb ~= nil then
			cb(valkyrieDetail[id])
		end
		return
	end

	Pomelo.GoddessHandler.getGoddessDetailRequest(id, function(ex, sjson)
		print("RequestValkyrieDetail")
		
		if ex == nil then
			local param = sjson:ToData()
			local data = param.s2c_goddess
			valkyrieDetail[id] = data
			if cb ~= nil then
				cb(valkyrieDetail[id])
			end
		end
	end, nil)
end

function GlobalHooks.DynamicPushs.OnGiftDynamicPush(ex, json)
  print("---------OnGiftDynamicPush------------")
  
  if ex == nil then
  local param = sjson:ToData()
  local vId = param.s2c_goddessId
  local gifts = param.s2c_data
  for i=1,#gifts do
    local gift = gifts[i]
    for j=1,#valkyrieGifts[vId] do
      local giftOld = valkyrieGifts[vId][j]
      if giftOld.id == gift.id then
        valkyrieGifts[vId][j] = gift
        break
      end
    end
  end
  
  if giftChangeCb ~= nil then
    giftChangeCb(gifts)
  end
end
end

local function InitMock()
	
	local detail = {}
	local basic = {}
	local atts = {}
	local mSkill = {}
	local aSkill = {}
	detail.basic = basic
	detail.upStarItemCur = 12
	detail.upStarItemMax = 20
	detail.nowIntimacy = 33
	detail.needIntimacy = 50
	detail.atts = atts
	detail.mainSkill = mSkill
	detail.assistSkill = aSkill
	
	basic.id = 1
	basic.name = "女武神1"
	basic.state = 1
	basic.star = 3
	basic.intimacy = 4
	basic.intimacyName = 1
	
	for i=1,4 do
		local att = {}
		att.name = "攻防速"
		att.value = 999
		att.addValue = 8
		table.insert(atts, att)
	end
	
	mSkill.name = "主动技能test"
	mSkill.pic = "1001"
	mSkill.des = "主动技能描述test主动技能描述test主动技能描述test主动技能描述test"
	aSkill.name = "被动技能test"
	aSkill.pic = "1001"
	aSkill.des = "被动技能描述test被动技能描述test被动技能描述test被动技能描述test"

	valkyrieDetail[detail.basic.id] = detail

	
	local gifts = {}
	for i=1,20 do
		local gift = {}
		gift.id = i
		gift.state = i % 3
		gift.name = "name"..i
		gift.price = 100*i
		gift.pic = "101001"
		gift.des = "物品描述物品描述物品描述物品描述物品描述物品描述物品描述物品描述"
		table.insert(gifts, gift)
	end
	valkyrieGifts[1] = gifts
end



function _M.InitNetWork()
  
  Pomelo.GameSocket.goddessGiftDynamicPush(GlobalHooks.DynamicPushs.OnGiftDynamicPush)
end

return _M
