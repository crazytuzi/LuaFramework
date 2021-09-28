--坐骑对象
local RideObj = class("RideObj")
local RideAttr = require("src/layers/blackMarket/RideAttr")
local Arg = require("src/layers/blackMarket/RideAttrCfg")
function RideObj:ctor( nRideId )
	-- body
	if not nRideId then
		return
	end
	local stDB = DB.get("RidingCfg", "q_ID", nRideId)
	self.m_stDb = stDB
	if not self.m_stDb then
		return
	end
	self.m_nBattle = stDB.battle
	self.m_strName = stDB.q_name
	self.m_nPictureId = stDB.q_pictureID
	

	self.m_vAllAttr = {}
	local stAttrPair = Arg.stAttrPair
	local vAttrVector = Arg.vAttrVector
	for _,sKey in ipairs(vAttrVector) do
		--属性对象
		local strTitle = Arg.getPairName(sKey)
		local vAttrs = Arg.getPair(sKey)
		local oRideAttr = RideAttr.new()
		oRideAttr:setTitle(strTitle)
		oRideAttr:setKeys(vAttrs)
		--属性组
		for _,strAttr in ipairs(vAttrs) do
			local nValue = stDB[strAttr]
			print("nValue", strAttr, nValue)
			oRideAttr:addKeyValue(strAttr, nValue)
		end
		
		table.insert(self.m_vAllAttr, oRideAttr)
	end

	--对于全属性的特殊处理
	local nPropPer = stDB.q_propper
	if nPropPer and nPropPer > 0 then
		local t = Arg.getPropper()
		for i,v in ipairs(t) do
			local oRideAttr = RideAttr.new()
			oRideAttr:setTitle(v)
			oRideAttr:setValueStr("^c(green)" .. nPropPer/100 .. "%^")
			table.insert(self.m_vAllAttr, oRideAttr)
		end
	end
end

--战斗力
function RideObj:getBattle( ... )
	-- body
	return self.m_nBattle
end

--名字
function RideObj:getName( ... )
	-- body
	return self.m_strName
end

--纸娃娃id
function RideObj:getPictureId( ... )
	-- body
	return self.m_nPictureId
end

--获取所有属性
function RideObj:getAllAttr( ... )
	-- body
	local vRet = {}
	for _,oAttr in pairs(self.m_vAllAttr) do
		if not oAttr:isNull() then
			table.insert(vRet, oAttr)
		end
	end
	return vRet
end
return RideObj