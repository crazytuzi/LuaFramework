--[[--
	拼大图控件:

	--By: yuqing.zhang
	--2013/12/13
]]

EditBigMap = class('EditBigMap', function () 
	local panel = TFPanel:create()
	panel.textureTable = {}
	panel:setClippingEnabled(false)
	return panel
end)
-- EditBigMap.__index = EditBigMap
-- setmetatable(EditBigMap, require('TFFramework.Editor.EditorBase.EditorBase_LoadMEPanel'))

function EditBigMap:setBigMapTexture(szPrefix, szSuffix, nColumn, nRow)
	print("EditBigMap:setTexture", szPrefix, szSuffix, nColumn, nRow)
	if szPrefix and szSuffix and nColumn and nRow then
		-- self.szPrefix, self.szSuffix, self.nColumn, self.nRow = szPrefix, szSuffix, nColumn, nRow
		if self.nRow and self.nColumn then
			for i = self.nColumn - 1, 0, -1 do
				for j = 0, self.nRow - 1 do
					self.textureTable[i .. "_" .. j]:removeFromParent()
				end
			end
			self:setSize(CCSize(100, 100))
			self:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
			self:setBackGroundColor(ccc3(100, 100, 100))
			self.nRow = nil
			self.nColumn = nil
			self.szPrefix, self.szSuffix, self.nColumn, self.nRow = nil
			self:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
			self:setBackGroundColor(ccc3(100, 100, 100))
			if nColumn == 0 then
				self:setSize(CCSize(100, 100))
				return
			end
		end
		self.textureTable = {}
		self.szPrefix= szPrefix
		self.szSuffix = szSuffix
		self.nRow = nRow
		self.nColumn = nColumn
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
		if nX ~= 0 then
		self:setSize(CCSizeMake(nX, nY))
		self:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
		end
		self:setPosition(self:getPosition())
		if self:getSize().width == 0 then
			self:setSize(CCSizeMake(100, 100))
		end
		local objParent = self:getParent()
		if objParent and EditorUtils:TargetIsContainer(objParent) then
			objParent:doLayout()
		end
	end
end

function EditBigMap:getBigMapTexture()
	return self.szPrefix, self.szSuffix, self.nColumn, self.nRow
end

local function initMEBigMapFundations(obj)
	function obj:clone()
		local objClone = EditBigMap:create()
		initMEBigMapFundations(objClone)
		objClone.bIsBigMap = true
		objClone:copyProperties(self)
		objClone:setBackGroundColorType(TF_LAYOUT_COLOR_NONE)
		objClone:setBackGroundColor(ccc3(100, 100, 100))
		print("----------------------------bIsBigMap clone")
		print(self:getBigMapTexture())
		objClone:setBigMapTexture(self:getBigMapTexture())
		return objClone
	end	
	function obj:getDescription()
		return "TFBigMap"
	end
end

function EditBigMap:copyProperties(objBeCloned)
	self:setEnabled(objBeCloned:isEnabled())
	self:setVisible(objBeCloned:isVisible())
	self:setBright(objBeCloned:isBright())
	self:setTouchEnabled(objBeCloned:isTouchEnabled())
	self:setZOrder(objBeCloned:getZOrder())
	self:setTag(objBeCloned:getTag())
	self:setName(objBeCloned:getName())
	self:setSize(objBeCloned:getSize())
	self:setSizeType(objBeCloned:getSizeType())
	self:setPositionType(objBeCloned:getPositionType())
	self:setSizeType(objBeCloned:getSizeType())
	self:setPositionPercent(objBeCloned:getPositionPercent())
	self:setPosition(objBeCloned:getPosition())
	self:setAnchorPoint(objBeCloned:getAnchorPoint())
	self:setScaleX(objBeCloned:getScaleX())
	self:setScaleY(objBeCloned:getScaleY())
	self:setRotation(objBeCloned:getRotation())
	self:setRotationX(objBeCloned:getRotationX())
	self:setRotationY(objBeCloned:getRotationY())
	self:setFlipX(objBeCloned:isFlipX())
	self:setFlipY(objBeCloned:isFlipY())
	self:setColor(objBeCloned:getColor())
	self:setOpacity(objBeCloned:getOpacity())
	self:setCascadeOpacityEnabled(objBeCloned:isCascadeOpacityEnabled())
	self:setCascadeColorEnabled(objBeCloned:isCascadeColorEnabled())
	
	tLuaDataManager:copyLayoutMsg(self, objBeCloned)
end

function EditBigMap:create()
	local obj = EditBigMap:new()
	initMEBigMapFundations(obj)
	return obj
end

function EditBigMap:initControl(val, parent)
	local obj = EditBigMap:new(val)
	-- obj:initBigMap(val, parent)
	return true, obj
end

return EditBigMap