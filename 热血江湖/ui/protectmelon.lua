-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_protectMelon = i3k_class("wnd_protectMelon", ui.wnd_base)

local TIMEPOINT = 10


local PAGE = "ui/widgets/baoweixiguat1"
local OBITEM = "ui/widgets/baoweixiguat2"

local SPEED_RATE = 150 -- 背景移动速度
local DELAYTIME = 4 --延迟
local PAGEBOUNDARY = 10 --边界交叉显示距离

--1下，2左，3上，4右
local DIRE_DOWN = 1
local DIRE_LEFT = 2
local DIRE_UP   = 3
local DIRE_RIGHT= 4

function wnd_protectMelon:ctor()
	self._limitTime = 0
	self._timeTick = 0
	self._timeFlag = false
	self._nextPagePositionX = 0 --第二页初始坐标
	self._startPagePositionX = 0
	self._animFlag = false
	self._fingerPos = 0
	self._posKey = 2;
	self._modeSize = nil
	self._obstractSize = nil
	self._nodeSize = 0
	self._id = 0
	self._nodes = {}
	self._row = 0
	self._column = 0 
	
	self._scollDatas = 
	{
		{scoll = nil, visibleDatas = {}},
		{scoll = nil, visibleDatas = {}}
	}	
	
	self._startWorldPosX = 0
end

function wnd_protectMelon:configure()
	self._page1 = nil
	self._page2 = nil
	self._npcMode = nil
	local widgets = self._layout.vars
	self._posRoot = widgets.posRoot
	widgets.close:onClick(self, self.onCloseBt)
	self._timeLabel = widgets.timesLabel
	self._bgContent = widgets.bgContent
	self._remaintimes = widgets.remaintimes
	widgets.npcScroll:onClick(self, self.onTouchBt)
end

function wnd_protectMelon:onShow()
	local widgets = self._layout.vars 
	self._npcPps = {[1] = widgets.pos1:getPositionY(), [2] = widgets.pos2:getPositionY(), [3] = widgets.pos3:getPositionY()}
end

function wnd_protectMelon:onHide()

end

function wnd_protectMelon:refresh(info)
	self._db_protectMeloninfo = i3k_db_findMooncake[info.id]
	self._id = info.id
	self._row = self._db_protectMeloninfo.protectMelonGird.row
	self._column = self._db_protectMeloninfo.protectMelonGird.column
	self._limitTime = self._db_protectMeloninfo.limitTime - DELAYTIME
	self._remaintimes:setText(string.format("剩余次数：%d次", self._db_protectMeloninfo.dayTimes - info.useTimes))
	self._timeLabel:setText("倒数：" .. self._limitTime)
	self._timeLabel:setTextColor(g_i3k_get_cond_color(true))
	self:initNodeAndModel()
	self:setNpcModelPos()
end

function wnd_protectMelon:startCountTime()
	self._timeFlag = true
end

function wnd_protectMelon:onUpdate(dTime)	
	if self._timeFlag then
		local autoCloseTime = self._limitTime
		self:moveOneStepTimer(dTime)
		
		if self._timeTick >= 0 then
			self._timeTick = self._timeTick + dTime
			
			if not self._animFlag then
				self._animFlag = true
			end
		
			local time = math.floor(autoCloseTime - self._timeTick)
			time = time > 0 and time or 0
			self._timeLabel:setText("剩余时间：" .. math.floor(time))
			self._timeLabel:setTextColor(g_i3k_get_cond_color(time > TIMEPOINT))
			
			if time == 0 then
				i3k_sbean.findMooncake_getItems(self._id)
				self._timeFlag = false
			end
		else
			self:gameOver()
		end
	end
end

--游戏结束
function wnd_protectMelon:gameOver()
	self._timeTick = 0
	self._timeFlag = false
	self._animFlag = false
	
	self._npcMode:pushActionList("death", 1) 
	self._npcMode:pushActionList("deathloop", 1)
	self._npcMode:playActionList()
		
	g_i3k_ui_mgr:AddTask(self, {}, function(ui)
		if g_i3k_ui_mgr:GetUI(eUIID_MessageBox2) then
			g_i3k_ui_mgr:CloseUI(eUIID_MessageBox2)
		end 
		
		g_i3k_ui_mgr:OpenUI(eUIID_FindFail) 
	end, 1) 
end

--是否再次尝试
function wnd_protectMelon:ifCountine()
	local callback = function(ok)
		if ok then
			for	k, v in ipairs(self._nodes) do
				self._scollDatas[k].scoll = nil
				self._scollDatas[k].visibleDatas = {}
				self._bgContent:removeChild(v)
			end
					
			i3k_sbean.findMooncake_start(self._id)
		else
			self:onCloseUI()
		end 
	end
	
	if g_i3k_ui_mgr:GetUI(eUIID_MessageBox2) then
		g_i3k_ui_mgr:CloseUI(eUIID_MessageBox2)
	end 
	
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(16503), callback)
end

function wnd_protectMelon:initNodeAndModel()
	for i = 1, 2 do
		self._nodes[i] = require(PAGE)()
		local vas = self._nodes[i].vars
		self._scollDatas[i].scoll = vas.scoll
		self._scollDatas[i].scoll:stateToNoSlip()
		self._bgContent:addChild(self._nodes[i])
	end

	self._page1 = self._nodes[1].vars.page
	self._page2 = self._nodes[2].vars.page
	local msize = self._page1:getSize()
	self._nodeSize = {width = msize.width / 2, height = msize.height / 2}
	self._startPagePositionX = self._page1:getPositionX() 
	self._nextPagePositionX = self._startPagePositionX + msize.width - PAGEBOUNDARY
	self._page2:setPositionX(self._nextPagePositionX)
	self:addObstacle(self._scollDatas[2].scoll, 2)
end

function wnd_protectMelon:randomIndex(index)
	local max = self._row * index 
	local min = max - self._row + 1
	
	return math.random(min, max)
end

function wnd_protectMelon:returnScollColumnIndex(index, scoll, datas)
	local max = index * self._row
	local count = max - self._row + 1
	local items = {}
	
	for i = max, count, -1 do
		datas[i] = nil
		table.insert(items, scoll:getChildAtIndex(i))
	end

	return items
end

function wnd_protectMelon:addObstacle(scoll, typeIndex)
	self._scollDatas[typeIndex].visibleDatas = {}
	local items = scoll:addChildWithCount(OBITEM, self._row, self._column * self._row, true)
	local datas = {}
	local modelID = self._db_protectMeloninfo.imageTotal[1][2]
	local mcfg = i3k_db_models[modelID];
	
	for _, v in ipairs(items) do
		if mcfg then
			local item = v.vars.obstacle
			item:setSprite(mcfg.path)
			item:setSprSize(mcfg.uiscale)
			item:playAction("duobistand")
			table.insert(datas, item)
			
			if self._obstractSize == nil then 
				local msize = item:getSize()
				self._obstractSize = {width = msize.width / 2, height = msize.height / 2}
			end
		end
	end

	for i = 1, self._column do  
		if i % 2 == 0 then
			local itemTable = self:returnScollColumnIndex(i, scoll, datas)
			
			for _, v in pairs(itemTable) do
				v.vars.obstacle:hide()
			end	
		else
			local index = self:randomIndex(i)
			local item = scoll:getChildAtIndex(index)
			item.vars.obstacle:hide()
			datas[index] = nil
		end
	end
	
	self._scollDatas[typeIndex].visibleDatas = datas
end

-- 显示模型
function wnd_protectMelon:setNpcModelPos()
	local widgets = self._layout.vars
	self._npcMode = widgets.model
	local modelID = self._db_protectMeloninfo.imageTotal[1][1]
	local mcfg = i3k_db_models[modelID];
	self._npcMode:setLocalZOrder(99)
	self._posKey = 2
	self._npcMode:setPositionY(self._npcPps[self._posKey])
	
	if mcfg and self._npcMode then
		self._npcMode:setSprite(mcfg.path);
		self._npcMode:setSprSize(mcfg.uiscale);
		self:setNpcFaceDirection(DIRE_RIGHT)
		self._npcMode:playAction("stand")
		local msize = self._npcMode:getSize()
		self._modeSize = {width = msize.width / 2, height = msize.height / 2}
	end
	
	self._startWorldPosX = self._npcMode:getParent():convertToWorldSpace({x = self._startPagePositionX, y = 0}).x
end

-- 1下，2左，3上，4右
function wnd_protectMelon:setNpcFaceDirection(id)
	dir =
	{
		[DIRE_DOWN]  = math.pi / 2,
		[DIRE_LEFT]  = -math.pi,
		[DIRE_UP]    = -math.pi / 2,
		[DIRE_RIGHT] = math.pi / 6
	}

	self._npcMode:setRotation(dir[id], 0)
end

function wnd_protectMelon:moveModle(dir)
	local value = dir == DIRE_UP and -1 or 1
	self._posKey = self._posKey + value
	
	if self._posKey < 1 or self._posKey > 3 then 
		self._posKey = self._posKey - value
		return 
	end
	
	self._npcMode:setPositionY(self._npcPps[self._posKey])
end

function wnd_protectMelon:onTouchBt()
	local mousePos = self._posRoot:convertToNodeSpace(g_i3k_ui_mgr:GetMousePos())
	local npcPos = self._npcMode:getPosition()
	
	if mousePos.y > npcPos.y + self._modeSize.height then
		self:moveModle(DIRE_UP)
	elseif mousePos.y < npcPos.y - self._modeSize.height then
		self:moveModle(DIRE_DOWN)
	end	
end

function wnd_protectMelon:rectIntersectsRect(rect1, rect2)
	if math.abs(rect1.y - rect2.y) > 100 then return false end
	
	if rect1.x < rect2.x then 
		return rect1.x + rect1.width + rect2.width >= rect2.x
	elseif rect1.x > rect2.x then
		return rect2.x + rect1.width + rect2.width >= rect1.x
	else
		return true
	end
	
	return false
end

function wnd_protectMelon:checkIntersects(typeIndex, rect1, rect2)--1 为mode 2 为 node	
	local items = self._scollDatas[typeIndex].visibleDatas
	local count = self._row * self._column
	
	for	i = self._posKey, count, self._row do
		if items[i] ~= nil then
			local item = items[i]
			local pos = item:getPosition()
			local pos1 = item:getParent():convertToWorldSpace(pos)
			rect2.x = pos1.x
			rect2.y = pos1.y
			
			if self:rectIntersectsRect(rect1, rect2) then
				self._timeTick = -100
				return				
			end
		end
	end
end

function wnd_protectMelon:refreshScollItemAnimation(typeIndex)
	local items = self._scollDatas[typeIndex].visibleDatas
	local count = self._row * self._column
	
	for	i = 1, count do
		if items[i] ~= nil then
			local item = items[i]
			local pos = item:getPosition()
			local pos1 = item:getParent():convertToWorldSpace(pos)
		
			if pos1.x < self._startWorldPosX and not item.aniFlag then
				item.aniFlag = true
				item:pushActionList("duobi", 1) 
				item:pushActionList("duobiloop", 1)
				item:playActionList()			
			end
		end
	end
end

--移动
function wnd_protectMelon:moveOneStepTimer(dTime)
	local pos1 = self._page1:getPosition()
	local pos2 = self._page2:getPosition()
	local pos3 = self._npcMode:getPosition()
	local worldPos3 = self._npcMode:getParent():convertToWorldSpace(pos3)
	local rect1 = {x = worldPos3.x, y = worldPos3.y, width = self._modeSize.width, height = self._modeSize.height}
	local rect2 = {x = 0, y = 0, width = self._obstractSize.width, height = self._obstractSize.height}
	
	if self._timeFlag then
		local offset = SPEED_RATE * dTime
		pos1.x = pos1.x - offset
		pos2.x = pos2.x - offset
		self._page1:setPosition(pos1)
		self._page2:setPosition(pos2)
	end
		
	--判断是否走完一个page
	if pos1.x < pos2.x then -- page1在前
		local pageWoldPos = self._posRoot:convertToWorldSpace(pos1) 
	
		if worldPos3.x > pageWoldPos.x and worldPos3.x - pageWoldPos.x + self._modeSize.width >= self._nodeSize.width then
			self:checkIntersects(2, rect1, rect2)
		else
			self:checkIntersects(1, rect1, rect2)
		end
		
		if self._startPagePositionX - pos1.x >= self._nodeSize.width then
			self:refreshScollItemAnimation(2)
		else
			self:refreshScollItemAnimation(1)
		end
	
		if pos2.x <= self._startPagePositionX then		
			local pos = {x = self._nextPagePositionX - self._startPagePositionX + pos2.x, y = pos1.y}
			self._page1:setPosition(pos)
			self:addObstacle(self._scollDatas[1].scoll, 1)
		end
	else
		local pageWoldPos = self._posRoot:convertToWorldSpace(pos2) 
		
		if worldPos3.x > pageWoldPos.x and worldPos3.x - pageWoldPos.x + self._modeSize.width >= self._nodeSize.width then
			self:checkIntersects(1, rect1, rect2)
		else
			self:checkIntersects(2, rect1, rect2)		
		end
		
		if self._startPagePositionX - pos2.x >= self._nodeSize.width then
			self:refreshScollItemAnimation(1)
		else
			self:refreshScollItemAnimation(2)
		end
		
		if pos1.x <= self._startPagePositionX then
			local pos = {x = self._nextPagePositionX - self._startPagePositionX + pos1.x, y = pos2.y}
			self._page2:setPosition(pos)
			self:addObstacle(self._scollDatas[2].scoll, 2)
		end
	end
end

function wnd_protectMelon:onCloseBt()
	local callback = function(ok)
		if ok then
			self:onCloseUI()
		end 
	end
	
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(16501), callback)
end

function wnd_create(layout, ...)
	local wnd = wnd_protectMelon.new()
	wnd:create(layout, ...)
	return wnd;
end
