stFormationElement = {}
stFormationElement.__index = stFormationElement

function stFormationElement:new()
	LogInfo("stFormationElement new")
	local self = {}
	setmetatable(self, stFormationElement)
	return self
end

function stFormationElement:delete()
	LogInfo("stFormationElement delete")
	self = nil
end

local c_nRotate_Speed = 0.002
local eMetal = 0
local eWood = 1
local eEarth = 2
local eWater = 3
local eFire = 4
local eElementMax = 5
local c_fMainCircleRadius = 63
local c_fLittleCircleRadius = 43
local c_fMainCircleCentre = {}
c_fMainCircleCentre.x = 162
c_fMainCircleCentre.y = 179
local c_fLittleCircleCentre = {}
c_fLittleCircleCentre[0] = {}
c_fLittleCircleCentre[0].x = c_fMainCircleCentre.x - ((c_fMainCircleRadius + c_fLittleCircleRadius) * math.cos(math.pi / 2))
c_fLittleCircleCentre[0].y = c_fMainCircleCentre.y - ((c_fMainCircleRadius + c_fLittleCircleRadius) * math.sin(math.pi / 2))
c_fLittleCircleCentre[1] = {}
c_fLittleCircleCentre[1].x = c_fMainCircleCentre.x - ((c_fMainCircleRadius + c_fLittleCircleRadius) * math.cos(9 * math.pi / 10))
c_fLittleCircleCentre[1].y = c_fMainCircleCentre.y - ((c_fMainCircleRadius + c_fLittleCircleRadius) * math.sin(9 * math.pi / 10))
c_fLittleCircleCentre[2] = {}
c_fLittleCircleCentre[2].x = c_fMainCircleCentre.x - ((c_fMainCircleRadius + c_fLittleCircleRadius) * math.cos(- 7 * math.pi / 10))
c_fLittleCircleCentre[2].y = c_fMainCircleCentre.y - ((c_fMainCircleRadius + c_fLittleCircleRadius) * math.sin(- 7 * math.pi / 10))
c_fLittleCircleCentre[3] = {}
c_fLittleCircleCentre[3].x = c_fMainCircleCentre.x - ((c_fMainCircleRadius + c_fLittleCircleRadius) * math.cos(- 3 * math.pi / 10))
c_fLittleCircleCentre[3].y = c_fMainCircleCentre.y - ((c_fMainCircleRadius + c_fLittleCircleRadius) * math.sin(- 3 * math.pi / 10))
c_fLittleCircleCentre[4] = {}
c_fLittleCircleCentre[4].x = c_fMainCircleCentre.x - ((c_fMainCircleRadius + c_fLittleCircleRadius) * math.cos(math.pi / 10))
c_fLittleCircleCentre[4].y = c_fMainCircleCentre.y - ((c_fMainCircleRadius + c_fLittleCircleRadius) * math.sin(math.pi / 10))


function stFormationElement.GetElementTypeByID(itemid)
	LogInfo("stFormationElement get elementtype by id")
	if itemid < 36096 or itemid > 36110 then
		return eElementMax
	elseif itemid <= 36098 then
		return eMetal
	elseif itemid <= 36101 then
		return eWood
	elseif itemid <= 36104 then
		return eWater
	elseif itemid <= 36107 then
		return eFire
	else
		return eEarth
	end
end

function stFormationElement.GetMainElementItem(elementType)
	LogInfo("stFormationElement get main element item")
	if elementType == eMetal then
		return 36096, 0.5 * math.pi	
	elseif elementType == eWood then
		return 36099, 0.9 * math.pi
	elseif elementType == eWater then
		return 36102, 1.7 * math.pi
	elseif elementType == eFire then
		return 36105, 0.1 * math.pi
	elseif elementType == eEarth then
		return 36108, 1.3 * math.pi
	end
end

function stFormationElement:InitElement(elementType)
	LogInfo("stFormationElement init element")
	self.rads = c_nRotate_Speed
	self.bstop = true
	self.pElementWindow = {}
	self.degree = 0
	self.targetdegree = 0

    local winMgr = CEGUI.WindowManager:getSingleton()
	self.MainElementType = elementType
	local mainelementID = 0
	mainelementID, self.degree = stFormationElement.GetMainElementItem(self.MainElementType)
	self.pElementWindow = {}
	for i = 0, 2 do
		local wndName = "zhenfachoose/main/back/"
		if elementType == eMetal then
			wndName = wndName .. "jin"
		elseif elementType == eFire then
			wndName = wndName .. "huo"
		elseif elementType == eWater then
			wndName = wndName .. "shui"
		elseif elementType == eWood then
			wndName = wndName .. "mu"
		elseif elementType == eEarth then
			wndName = wndName .. "tu"
		end
		self.pElementWindow[i] = winMgr:getWindow(wndName .. tostring(i + 1))
		local x = c_fLittleCircleCentre[self.MainElementType].x + c_fLittleCircleRadius * math.cos(self.degree - i * 2 * math.pi / 3)
		local y = c_fLittleCircleCentre[self.MainElementType].y	+ c_fLittleCircleRadius * math.sin(self.degree - i * 2 * math.pi / 3)
		self.pElementWindow[i]:setPosition(CEGUI.UVector2(CEGUI.UDim(0, x - self.pElementWindow[i]:getPixelSize().width / 2), CEGUI.UDim(0, y - self.pElementWindow[i]:getPixelSize().height / 2)))
	end
	self:refreshElementImage()
end 

function stFormationElement:SetTargetDegree(itemid)
	LogInfo("stFormationElement set target degree")
	local target = 0
	local mainelementid = 0
	mainelementid,target = stFormationElement.GetMainElementItem(self.MainElementType)
	local id = itemid - mainelementid
	if id == 0 then
		self.targetdegree = target
	elseif id == 1 then
		self.targetdegree = target + 2 * math.pi / 3
	elseif id == 2 then
		self.targetdegree = target + 4 * math.pi / 3
	end
	if self.targetdegree >= 2 * math.pi then
		self.targetdegree = self.targetdegree - 2 * math.pi
	end
	if self.degree > self.targetdegree then
		self.rads = - c_nRotate_Speed
		self.bstop = false
	elseif self.degree < self.targetdegree then
		self.rads = c_nRotate_Speed
		self.bstop = false
	else
		self.rads = 0
		self.bstop = true
	end
end

function stFormationElement:Run(delta)
	if self.bstop then
		return
	end
	if (self.rads > 0 and self.degree > self.targetdegree) or (self.rads < 0 and self.degree < self.targetdegree) then
		self.rads = 0
		self.degree = self.targetdegree
		self.bstop = true	
	else
		self.degree = self.degree + self.rads * delta
	end
	for i = 0, 2 do
		local x = c_fLittleCircleCentre[self.MainElementType].x + c_fLittleCircleRadius * math.cos(self.degree - i * 2 * math.pi / 3)
		local y = c_fLittleCircleCentre[self.MainElementType].y + c_fLittleCircleRadius* math.sin(self.degree - i * 2 * math.pi / 3)
		self.pElementWindow[i]:setPosition(CEGUI.UVector2(CEGUI.UDim(0, x - self.pElementWindow[i]:getPixelSize().width / 2) , CEGUI.UDim(0, y - self.pElementWindow[i]:getPixelSize().height / 2)))
	end
end

function stFormationElement:refreshElementImage()
	LogInfo("stFormationElement refresh element image")
	local mainelementID = 0
	mainelementID = stFormationElement.GetMainElementItem(self.MainElementType)
	for i = 0, 2 do
		if GetRoleItemManager():GetItemNumByBaseID(mainelementID + i) == 0 then
			self.pElementWindow[i]:setProperty("Image", "set:MainControl20 image:Disable" .. tostring(i + 1))
		else
			local path = "set:MainControl20 image:"
			if self.MainElementType == eMetal then
				path = path .. "Jin" .. tostring(i + 1)
			elseif self.MainElementType == eFire then
				path = path .. "Huo" .. tostring(i + 1)
			elseif self.MainElementType == eWater then
				path = path .. "Shui" .. tostring(i + 1)
			elseif self.MainElementType == eWood then
				path = path .. "Mu" .. tostring(i + 1)
			elseif self.MainElementType == eEarth then
				path = path .. "Tu" .. tostring(i + 1)
			end
			self.pElementWindow[i]:setProperty("Image", path)
		end
	end
end


return stFormationElement
