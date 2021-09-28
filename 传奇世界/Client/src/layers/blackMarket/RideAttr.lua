--坐骑属性
local RideAttr = class("RideAttr")
local Arg = require("src/layers/blackMarket/RideAttrCfg")
local stAttrName = Arg.stAttrName
function RideAttr:ctor(  )
	-- body
	self.m_stAllAttr = {}
end

--设置属性标题
function RideAttr:setTitle( strAttrTitle )
	-- body
	self.m_strAttrTitle = strAttrTitle
end

function RideAttr:getTitle( ... )
	-- body
	return self.m_strAttrTitle
end

--设置所有属性(用作排序)
function RideAttr:setKeys( vKeys )
	-- body
	self.m_vKeys = vKeys
end

function RideAttr:getKeys( ... )
	-- body
	return self.m_vKeys
end

--添加属性key-value
function RideAttr:addKeyValue( strAttr, nValue )
	-- body
	self.m_stAllAttr[strAttr] = nValue
end

--强制设置value
function RideAttr:setValueStr( strValue )
	-- body
	self.m_strValue = strValue
end

--是否为空
function RideAttr:isNull( ... )
	-- body
	if self.m_strValue then
		return false
	end
	local nAttrNum = table.nums(self.m_stAllAttr)
	return nAttrNum < 1
end

--获取值文本
function RideAttr:getValueTxt( ... )
	-- body
	local strRet = ""
	if self.m_strValue then
		strRet = self.m_strValue
	else
		local vKeys = self.m_vKeys
		local nNum = table.nums(self.m_stAllAttr)

		if vKeys then
			for nIndex,strKey in ipairs(vKeys) do
				local nValue = self.m_stAllAttr[strKey]
				print("strKey", nValue)
				if nValue then
					if nIndex > 1 then
						strRet = strRet.." - "
					end
					local strTmpStr = nValue
					--特殊处理一些字符串，例如有的需要显示百分比
					if vKeys[nIndex] == "q_addSpeed" then
						strTmpStr = strTmpStr.."%"
					end

					strRet = strRet..strTmpStr
				end
			end
		else
			for strKey,nValue in pairs(self.m_stAllAttr) do
				if nIndex > 1 then
					strRet = strRet.." - "
				end
				local strTmpStr = nValue
				--特殊处理一些字符串，例如有的需要显示百分比
				if vKeys[nIndex] == "q_addSpeed" then
					strTmpStr = strTmpStr.."%"
				end

				strRet = strRet..strTmpStr
			end
		end
	end
	return strRet
end

--获取最终属性文本
function RideAttr:getTxt( ... )
	-- body
	local strRet = ""
	local strTitle = self.m_strAttrTitle
	strRet = strRet..strTitle
	local strValueTxt = self:getValueTxt()
	strRet = strRet..strValueTxt
	return strRet
end

return RideAttr