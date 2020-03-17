--[[
掉落物头顶血条
]]
_G.classlist['ItemHeadBoard'] = 'ItemHeadBoard'
_G.ItemHeadBoard = {};
ItemHeadBoard.objName = 'ItemHeadBoard'

function ItemHeadBoard:new(cid, configId, szItemName)
	local obj = {}
	setmetatable(obj,{__index = ItemHeadBoard});
	obj.cid = cid 
	obj.configId = configId
	obj.szItemName = szItemName
	
	obj.lastX = 0
	obj.lastY = 0
	obj.lastZ = 0
	
	obj.nameWidth = nil
	obj.nameHeight = nil
	
	obj.name2dX = nil
	obj.name2dY = nil
	
	obj.textColor = nil
	obj.edgeColor = nil
	
	obj.backimage = nil
	obj.namePos = _Vector3.new()
	obj.isRender = true
    return obj;
end

function ItemHeadBoard:Update(posX,posY,posZ)
	if ToolsController.hideUI then return; end
	if not self.isRender then return end
	self:CalculateBoard(posX,posY,posZ)
	self:DrawHeadBoard(posX,posY,posZ)
end

function ItemHeadBoard:Destory()
	self.isRender = false
	
	self.cid = nil 
	self.configId = nil
	self.szItemName = nil	
	
	self.lastX = 0
	self.lastY = 0
	self.lastZ = 0
	
	self.nameWidth = nil
	self.nameHeight = nil
	
	self.name2dX = nil
	self.name2dY = nil
	
	self.textColor = nil
	self.edgeColor = nil
	self.namePos = nil
	self.backimage = nil
end

local itemFont = _Font.new("SIMHEI", 11, 0, 1, false)
function ItemHeadBoard:DrawHeadBoard(posX,posY,posZ)

	if RenderConfig.batch == true then _rd.batchId = 1 end;
	itemFont.edgeColor = self.edgeColor
    itemFont.textColor = self.textColor

	
    self.backimage:drawImage(self.name2dX - self.nameWidth/2 , self.name2dY - self.nameHeight/2, self.name2dX + self.nameWidth/2, self.name2dY + self.nameHeight/2)
    itemFont:drawText(self.name2dX, self.name2dY,
        self.name2dX, self.name2dY, self.szItemName, _Font.hCenter + _Font.vCenter)

	if RenderConfig.batch == true then _rd.batchId = 0 end;

end

local name2d = _Vector2.new()
function ItemHeadBoard:CalculateBoard(posX,posY,posZ)
	if not self.nameWidth or not self.nameHeight then
		local point = itemFont:stringSize(self.szItemName)
		self.nameWidth = point.x
		self.nameHeight = point.y
		self.nameWidth = self.nameWidth + 6
		self.nameHeight = self.nameHeight + 4
		-- FPrint('ItemHeadBoard:DrawHeadBoard'..self.nameWidth..':'..self.nameHeight)
	end

	if self.lastX ~= posX or self.lastY ~= posY or self.lastZ ~= posZ then
		self.namePos.x = posX + CUICardConfig[0].x
		self.namePos.y = posY + CUICardConfig[0].y
		self.namePos.z = posZ + CUICardConfig[0].z
		
		self.lastX = posX
		self.lastY = posY
		self.lastZ = posZ
		
		-- FPrint('ItemHeadBoard:CalculateBoard(name2d)x:'..self.name2dX..'y:'..self.name2dY)
		-- FPrint('ItemHeadBoard:CalculateBoard(last)x:'..self.lastX..'y:'..self.lastY..'z:'..self.lastZ)
		-- FPrint('ItemHeadBoard:CalculateBoard(pos)x:'..posX..'y:'..posY..'z:'..posZ)
	end
	
	_rd:projectPoint( self.namePos.x, self.namePos.y, self.namePos.z, name2d) --名字位置
	self.name2dX = name2d.x
	self.name2dY = name2d.y
	
	if not self.textColor then
		self.textColor = 0xFFFFFFFF
		local quality = 0
		if t_equip[self.configId] then
			quality = t_equip[self.configId].quality
		elseif t_item[self.configId] then
			if t_item[self.configId].sub == BagConsts.SubT_Tianshenka then
            	quality = NewTianshenUtil:GetShowQuality(NewTianshenUtil:GetTianshenCardZizhi(self.configId))
        	else
				quality = t_item[self.configId].quality
			end
		end
		
		if quality then
			self.textColor = TipsConsts:GetItemQualityColorVal(quality)
		end
	end
	
	if not self.edgeColor then
		self.edgeColor = CUICardConfig[0].edgeColor
	end
	
	if not self.backimage then
		if self.cid == SkillController.targetCid or self.cid == DropItemController.mouseItem then
			self.backimage = CResStation:GetImage("itemnamebg2.png")
		else
			self.backimage = CResStation:GetImage("itemnamebg1.png")
		end
	end
end