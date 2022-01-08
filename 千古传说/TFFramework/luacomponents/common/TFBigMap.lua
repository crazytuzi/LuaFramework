--[[--
	拼大图控件:

	--By: yuqing.zhang
	--2013/12/13
]]

TFBigMap = class('TFBigMap', function () 
	local panel = TFPanel:create()
	panel.textureTable = {}
	panel:setClippingEnabled(false)
	return panel
end)

function TFBigMap:description()
end

function TFBigMap:ctor(configs)
	
end

function TFBigMap:setBigMapTexture(szPrefix, szSuffix, nColumn, nRow)
	print("TFBigMap:setTexture")
	if szPrefix and szSuffix and nColumn and nRow then
		self.szPrefix= szPrefix
		if self.szPrefix[1] == '/' or self.szPrefix[1] == '\\' then 
			self.szPrefix = self.szPrefix['2']
		end
		self.szSuffix = szSuffix
		local nX = 0
		local nY = 0
		local addY
		local addX
		for i = nColumn - 1, 0, -1 do
			nX = 0
			for j = 0, nRow - 1 do
				local fileName = self.szPrefix .. i .. "_" .. j .. "." .. self.szSuffix
				local image = TFImage:create()
				image:setTexture(fileName)
				addX = image:getSize().width
				addY = image:getSize().height
				image:setPosition(ccp(nX + addX / 2, nY + addY / 2))
				self:addChild(image)
				self.textureTable[i .. "_" .. j] = image
				nX = nX + image:getSize().width				
			end
			nY = nY + addY
			self:setSize(CCSizeMake(nX, nY))
		end
	end
end

local function new(val, parent)
	print("TFBigMap new")
	local obj
	obj = TFBigMap:create()
	if parent then
		parent:addChild(obj) 
	end
	return obj
end

function TFBigMap:create()
	local obj = TFBigMap:new()
	return obj
end

function TFBigMap:initControl(val, parent)
	print("TFBigMap")
	local obj = new(val,parent)
	obj.bIsBigMap = true
	obj:initMEBigMap(val, parent)
	return true, obj
end

return TFBigMap