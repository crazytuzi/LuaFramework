--[[
怪物头顶血条
]]
_G.classlist['MonsterHeadBoard'] = 'MonsterHeadBoard'
_G.MonsterHeadBoard = {};
MonsterHeadBoard.objName = 'MonsterHeadBoard'
local pos = _Vector3.new()
local starWidth = 14
local starHeight = 14
local pos2d = _Vector2.new()	
local star2d = _Vector2.new()
local name2d = _Vector2.new()
local hp2d = _Vector2.new()
local title2d = _Vector2.new()
local monsterFont = _Font.new("SIMHEI", 10, 0, 1, true)

function MonsterHeadBoard:new(h, npcName, title, titleImage, starLvl, monster_title_edgeColor, monster_title_textcolor)
	local obj = {}
	setmetatable(obj,{__index = MonsterHeadBoard});
	if title and title ~= '' then
		obj.title = "<" .. title .. ">"
	end
	obj.h = h
	obj.starLvl = starLvl
	obj.titleImage = titleImage
	obj.lastX = 0
	obj.lastY = 0
	obj.lastZ = 0

	obj.monster_title_edgeColor = monster_title_edgeColor
	obj.monster_title_textcolor = monster_title_textcolor

	obj.mRateTarget = -1;
	obj.mRateCur = -2;
	obj.frontHp = nil
	obj.middleHp = nil
	obj.backHp =  nil
	obj.npcName = npcName
	obj.pos = _Vector3.new()
	
	obj.starDic = {}
	obj.isRender = true
	obj.loaderList = {}
	if obj.starLvl and obj.starLvl > 0 then
		for	i=1,obj.starLvl do 
			if not obj.starDic[i] then
				local loader = _Loader.new()
				obj.loaderList[i] = loader;
				loader:load("resfile/swf/monsterstarlv.swf")
				loader.lowPriority = false;
				loader:onFinish(function()
					if obj.starDic then
						obj.loaderList[i] = nil;
						obj.starDic[i] = _Image.new("resfile/swf/monsterstarlv.swf") 
					end
				end)
			end
		end
	end
    return obj;
end

function MonsterHeadBoard:LoadSwfEffect(level)
end

function MonsterHeadBoard:Update(monsterId, posX, posY, posZ, currHp, maxHp, showHP)
	if ToolsController.hideUI then return; end
	if not self.isRender then return end
	self:CalculateBoard(monsterId, posX, posY, posZ, currHp, maxHp, showHP)
end

function MonsterHeadBoard:Destory()
	self.isRender = false
	if self.title then self.title = nil end
	self.h = nil
	self.starLvl = nil
	self.titleImage = nil
	self.lastX = 0
	self.lastY = 0
	self.lastZ = 0
	
	self.monster_title_edgeColor = nil
	self.monster_title_textcolor = nil
	
	self.frontHp = nil
	self.middleHp = nil
	self.backHp =  nil
	
	self.nameWidth = nil
	self.realImg = nil
	self.pos = nil
	self.starDic = nil
	self.mRateTarget = -1
	self.mRateCur = -2;
end

function MonsterHeadBoard:DrawHeadBoard(posX,posY,posZ)
	
end

function MonsterHeadBoard:CalculateBoard(monsterId, posX, posY, posZ, currHp, maxHp, showHP)
	pos.x = posX 
	pos.y = posY
	pos.z = posZ + (self.h or 1)

	if RenderConfig.batch == true then
		_rd.batchId = 1
	end

	_rd:projectPoint(pos.x, pos.y, pos.z, pos2d)

	pos2d.x = pos2d.x
	pos2d.y = pos2d.y + 40
	local hpRate =  math.min(1, math.max(0, currHp / maxHp))

	if not self.frontHp or not self.backHp or not self.middleHp then
		self.frontHp = CResStation:GetImage("hp_temp.png")
		self.backHp =  CResStation:GetImage("hp_back_temp.png")
		self.middleHp =  CResStation:GetImage("hp_middle.png")
	end
    if self.frontHp and self.backHp and self.middleHp then
		local fRate = hpRate
		if self.mRateTarget == -1 then
			self.mRateCur = fRate;
		end
		self.mRateTarget = fRate;
		self.backHp:drawImage(pos2d.x - 46, pos2d.y, pos2d.x + 46, pos2d.y + 12)
		if self.mRateCur > self.mRateTarget then
			self.mRateCur = self.mRateCur - 0.05;
		else
			self.mRateCur = fRate
		end
		self.middleHp:drawImage(pos2d.x - 43 , pos2d.y + 2, pos2d.x - 43 + 86 * self.mRateCur , pos2d.y + 10)
		self.frontHp:drawImage(pos2d.x - 43 , pos2d.y + 2, pos2d.x - 43 + 86 * fRate , pos2d.y + 10)






		pos2d.x = pos2d.x
		pos2d.y = pos2d.y - 2
	end

	if self.npcName and self.npcName ~= "" then
		monsterFont.edgeColor = self.monster_title_edgeColor
	    monsterFont.textColor = self.monster_title_textcolor
		monsterFont:drawText(pos2d.x, pos2d.y,
	        pos2d.x, pos2d.y, self.npcName, _Font.hCenter + _Font.vBottom)
		pos2d.x = pos2d.x
		pos2d.y = pos2d.y - 14		
	end

   --北仓界活动怪物头上显示数字
	if ActivityController:GetCurrId() == ActivityConsts.Beicangjie or ActivityController:GetCurrId() == ActivityConsts.Beicangjie2 then
		local x = pos2d.x
		local y = pos2d.y
		local score = t_beicangjiescore[monsterId] and t_beicangjiescore[monsterId].score or 0
		if score > 0 then
			local scoreString = tostring(score)
			local nLen = string.len(scoreString)
			x = x - nLen * 10 / 2
	        for nY = 1, nLen do
	            local szIndex = string.char(scoreString:byte(nY))
	            local img = CResStation:GetImage(ResUtil:GetLingzhiIcon(szIndex))
	            img:drawImage(x , y - 15, x + 10, y)
	            x = x + 10
	        end
	    end
	else
		if self.title and self.title ~= "" then 
		    monsterFont:drawText(pos2d.x, pos2d.y,
		        pos2d.x, pos2d.y, self.title, _Font.hCenter + _Font.vBottom)
		    pos2d.x = pos2d.x
			pos2d.y = pos2d.y - 14
		end

		if self.titleImage and self.titleImage ~= "" then
    		local titleImage = CResStation:GetImage(self.titleImage)
			titleImage:drawImage(pos2d.x - titleImage.w / 2, pos2d.y - titleImage.h, pos2d.x + titleImage.w / 2, pos2d.y)
			pos2d.x = pos2d.x
			pos2d.y = pos2d.y - titleImage.h + 10
		end

		if self.starLvl and self.starLvl > 0 then
			local starStartX = (50 + (starWidth + 8) * (self.starLvl - 1)) / 2
			for	i = 1, self.starLvl do 
				if self.starDic[i] then
					local starImg = self.starDic[i]
					local startX = pos2d.x - starStartX + (i - 1) * (starWidth + 8)
					local staryY = pos2d.y
					starImg:drawImage(startX, staryY - starImg.h, startX + starImg.w, staryY)
				end
			end
		end
	end
	if RenderConfig.batch == true then
		_rd.batchId = 0
	end
end

function MonsterHeadBoard:SetColor(textColor, edgeColor)
	self.monster_title_edgeColor = edgeColor
    self.monster_title_textcolor = textColor
end