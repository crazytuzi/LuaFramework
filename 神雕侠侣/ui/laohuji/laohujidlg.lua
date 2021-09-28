require "ui.dialog"
local LaohujiDlg = {}

setmetatable(LaohujiDlg, Dialog);
LaohujiDlg.__index = LaohujiDlg;

local _instance;

function LaohujiDlg.getInstance()
	if _instance == nil then
		_instance = LaohujiDlg:new();
		_instance:OnCreate();
	end

	return _instance;
end

function LaohujiDlg.getInstanceNotCreate()
	return _instance;
end

function LaohujiDlg.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
		LogInfo("LaohujiDlg DestroyDialog")
	end
end

function LaohujiDlg.getInstanceAndShow()
    if not _instance then
        _instance = LaohujiDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function LaohujiDlg.ToggleOpenClose()
	if not _instance then 
		_instance = LaohujiDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function LaohujiDlg.GetLayoutFileName()
	return "laohuji.layout";
end

function LaohujiDlg:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, LaohujiDlg);
	return zf;
end

------------------------------------------------------------------------------
local sopentiger = require "protocoldef.knight.gsp.activity.gamble.sopentiger"
function sopentiger:process()
	LogInfo("sopentiger process "..self.buttonstate)
	if _instance then return end

	LaohujiDlg.getInstanceAndShow()
	if self.buttonstate == 2 then
		_instance.m_state = _instance.stateFinish
		_instance.m_startBtn:setVisible(false)
		_instance.m_quchuBtn:setVisible(true)
		_instance.m_bonus:setText(tostring(self.earning))
		_instance.m_gotBonus = self.earning
	else
		_instance.m_state = _instance.stateReady
		_instance.m_startBtn:setVisible(true)
		_instance.m_quchuBtn:setVisible(false)
	end
end

local stigerresult = require "protocoldef.knight.gsp.activity.gamble.stigerresult"
function stigerresult:process()
	LogInfo("stigerresult process ")
	if not _instance then return end

	_instance.m_targets = {}
	for i,v in ipairs(self.gridlist) do
		_instance.m_targets[i] = v

		LogInfo("stigerresult "..tostring(v))
	end

	_instance.m_targets.curr = 1
	_instance.m_group1 = self.beilvlist[2] - 3
	_instance.m_group2 = self.beilvlist[1]
	_instance.m_gotBonus = self.earning
end

-------------------------------------------------------------------------------

function LaohujiDlg:OnCreate()
	LogInfo("LaohujiDlg OnCreate begin")
	Dialog.OnCreate(self)

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_helpBtn = winMgr:getWindow("laohuji/help")
	self.m_rankBtn = winMgr:getWindow("laohuji/rank")
	self.m_startBtn = winMgr:getWindow("laohuji/start/kaishi")
	self.m_quchuBtn = winMgr:getWindow("laohuji/start/quchu")
	self.m_resetBtn = winMgr:getWindow("laohuji/repick")

	self.m_bonus = winMgr:getWindow("laohuji/get/bonus")
	self.m_bonus:setText("0")
	self.m_yuanbao = winMgr:getWindow("laohuji/get/yuanbao")
	self:refreshYuanbaoNum()


	self.m_startBtn:subscribeEvent("MouseClick", self.HandleStartClicked, self)
	self.m_quchuBtn:subscribeEvent("MouseClick", self.HandleQuchuClicked, self)
	self.m_helpBtn:subscribeEvent("MouseClick", self.HandleHelpClicked, self)
	self.m_rankBtn:subscribeEvent("MouseClick", self.HandleRankClicked, self)
	self.m_resetBtn:subscribeEvent("MouseClick", self.HandleResetClicked, self)


	self.m_touzhu = {}
	for i=1,8 do
		local newTz = {}
		self.m_touzhu[i] = newTz
		newTz.btn = winMgr:getWindow("laohuji/btnback/btn"..i)
		newTz.btn:subscribeEvent("MouseClick", self.HandleTouzhuClicked, self)
		newTz.text = winMgr:getWindow("laohuji/btnback/m"..i)
		newTz.num = 0
		newTz.lastNum = 0
		newTz.text:setText("0")

		newTz.longpressFunc = function ()
			newTz.longpress = not newTz.longpress
		end
		newTz.btn:subscriberEventLongPress(newTz.longpressFunc, newTz)
	end

	self.m_group = {}
	for i=1,2 do
		self.m_group[i] = {}
		for j=1,3 do
			self.m_group[i][j] = winMgr:getWindow("laohuji/btnback/odd"..i.."/o"..j)
		end
		self.m_group[i].select = 1
	end
	self.m_groupLightImage = self.m_group[1][1]:getProperty("Image")
	self.m_groupGrayImage = self.m_group[1][2]:getProperty("Image")
	self:ClearTouzhu()

	self.m_gameItems = {}
	self.m_itemNum = 24
	for i=1,self.m_itemNum do
		self.m_gameItems[i] = winMgr:getWindow("laohuji/gameback/"..i)
	end
	self.m_itemLightImage = self.m_gameItems[22]:getProperty("Image")
	self.m_itemGrayImage = self.m_gameItems[1]:getProperty("Image")
	
	self.m_currItem = 1
	self:grayItem(22)
	self:lightItem(self.m_currItem)

	self.m_targets = {}
	self.m_targets.curr = 1
	self.m_time = 0
	self.m_state = self.stateReady
	self.m_maxItemSpeed = 24
	self.m_minItemSpeed = 1

	self.m_groupTime = 100
	self.m_waitTime = 1000

	self.m_quchuBtn:setVisible(false)
	self.m_startBtn:setVisible(true)

	LogInfo("LaohujiDlg OnCreate finish")
end

function LaohujiDlg:run( delta )
	self:m_state(delta)

	for i,v in ipairs(self.m_touzhu) do
		if v.longpress then
			if self.m_yuanbaoNum < 10 then 
				return 
			end
			v.num = v.num + 10
			v.text:setText(tostring(v.num))
			self.m_yuanbaoNum = self.m_yuanbaoNum - 10
			self.m_yuanbao:setText(tostring(self.m_yuanbaoNum))
		end
	end
end

function LaohujiDlg:stateReady( delta )
	--do nothing
end

function LaohujiDlg:HandleStartClicked()
	if self.m_state == self.stateReady then
		if self.m_yuanbaoNum < 0 then return end
		local has = false
		local p = require "protocoldef.knight.gsp.activity.gamble.ctigerbet":new()
		p.betmap = {}
		for i,v in ipairs(self.m_touzhu) do
			if v.num > 0 then
				p.betmap[(8-i+1)*10] = v.num
				has = true
			end
		end
		if not has then
			self:refreshYuanbaoNum()
			for _,v in ipairs(self.m_touzhu) do
				self.m_yuanbaoNum = self.m_yuanbaoNum - v.lastNum
				v.num = v.lastNum
				v.text:setText(tostring(v.num))
			end
			self.m_yuanbao:setText(tostring(self.m_yuanbaoNum))
			return 
		end
		require "manager.luaprotocolmanager":send(p)	

		self.m_state = self.stateMaxSpeed
		self.m_time = 0
		self.m_move = 0
		self.m_group.time = 0
		self.m_group[1].finish = false
		self.m_group[2].finish = false
	
		self.m_targets = {}
		self.m_targets.curr = 1
	end
end

function LaohujiDlg:HandleQuchuClicked()
	if self.m_state == self.stateFinish then --领取奖励
		self.m_state = self.stateClearBonus
		self.m_time = 0
		self.m_gotBonus = self.m_gotBonus or 0
		self:grayLucky()
		self:ClearTouzhu()
		self.m_quchuBtn:setVisible(false)
		self.m_startBtn:setVisible(true)

		local p = require "protocoldef.knight.gsp.activity.gamble.ctaketigeraward":new()
		require "manager.luaprotocolmanager":send(p)	
	end
end

function LaohujiDlg:stateClearBonus( delta )
	self.m_time = self.m_time + delta
	local change = self.m_time / 1000 * self.m_gotBonus + 1
	if self.m_gotBonus < change then
		change = self.m_gotBonus
		self.m_state = self.stateReady
		self.m_time = 0
		self.m_yuanbaoNum = self.m_yuanbaoNum + self.m_gotBonus
		self.m_yuanbao:setText(tostring(self.m_yuanbaoNum))
		self.m_bonus:setText("0")
		return
	end
	change = math.floor(change)
	self.m_yuanbao:setText(tostring(self.m_yuanbaoNum + change))
	self.m_bonus:setText(tostring(self.m_gotBonus - change))
end

function LaohujiDlg:stateMaxSpeed( delta )
	--update item highlight
	self.m_timePerItem = 1000 / self.m_maxItemSpeed
	self.m_time = self.m_time + delta
	local move = math.floor(self.m_time / self.m_timePerItem)

	if move > 0 then
		self:grayItem(self.m_currItem)

		self.m_currItem = move + self.m_currItem
		self.m_time = self.m_time - move * self.m_timePerItem
		self.m_move = self.m_move + move

		self:clampItemIndex()
		self:lightItem(self.m_currItem)
		self:lightLucky()
	end

	--update group highlight
	self.m_group.time = self.m_group.time + delta
	move = math.floor(self.m_group.time / self.m_groupTime)
	if move > 0 then
		for i=1,2 do
			local group = self.m_group[i]
			if not group.finish then
				self:grayGroupCell(i, group.select)
	
				group.select = group.select + move
				group.select = (group.select-1) % 3 + 1
				self.m_group.time = self.m_groupTime - move * self.m_groupTime
	
				self:lightGroupCell(i, group.select)
			end
		end
	end

	--check state change
	local target = self.m_targets[self.m_targets.curr]
	if not target then return end
	if self.m_move > self.m_itemNum then
		if (self.m_currItem < target + 3) and (self.m_currItem > target - 3) then
			self.m_state = self.stateSlowdown
	
			self.m_target = self.m_targets[self.m_targets.curr]
	
			self.m_distance = self.m_target - self.m_currItem + 24
			self.m_time = 0
			self.m_move = 0
		end
	end
end

function LaohujiDlg:stateSlowdown( delta )

	--update item highlight
	local maxTimePerItem = 500
	self.m_time = self.m_time + delta
	local move = math.floor(self.m_time / self.m_timePerItem)

	if move > 0 then
		self:grayItem(self.m_currItem)
		self.m_currItem = move + self.m_currItem
		self.m_time = self.m_time - move * self.m_timePerItem
		self.m_move = self.m_move + move

		if self.m_move >= self.m_distance then
			self.m_move = self.m_distance
			self.m_currItem = self.m_target
			self.m_state = self.stateWait
			self.m_time = 0
		end

		local percent = (self.m_distance - self.m_move + 1) / self.m_distance
		local currSpeed = self.m_maxItemSpeed * percent
		self.m_timePerItem = 1000 / currSpeed
		if self.m_timePerItem > maxTimePerItem then 
			self.m_timePerItem = maxTimePerItem
		end
		self:clampItemIndex()
		self:lightItem(self.m_currItem)
		self:lightLucky()
	end

	--update group highlight
	self.m_group.time = self.m_group.time + delta
	move = math.floor(self.m_group.time / self.m_groupTime)
	if move > 0 then
		for i=1,2 do
			local group = self.m_group[i]
			if not group.finish then

				self:grayGroupCell(i, group.select)
	
				group.select = group.select + move
				group.select = (group.select-1) % 3 + 1
				self.m_group.time = self.m_groupTime - move * self.m_groupTime
	
				self:lightGroupCell(i, group.select)
	
				if group.select == self["m_group"..i] and self.m_timePerItem > 200 then
					group.finish = true
				end

			end
		end
	end
	
end

function LaohujiDlg:stateWait(delta)
	self.m_time = self.m_time + delta
	if self.m_time < self.m_waitTime then
		return
	end

	if self.m_targets.curr < #self.m_targets then
		self.m_targets.curr = self.m_targets.curr + 1
		self.m_state = self.stateMaxSpeed
		self.m_time = 0
		self.m_move = 0
		self.m_group.time = 0
	else
		self.m_state = self.stateAddBonus
		self.m_time = 0
	end
end

function LaohujiDlg:stateAddBonus( delta )
	if self.m_gotBonus == 0 then
		self.m_time = 0
		self.m_state = self.stateReady
		self.m_gotBonus = self.m_gotBonus or 0
		self:grayLucky()
		self:ClearTouzhu()
	elseif self.m_gotBonus == -1 then
		self.m_bonus:setText("0")
		self.m_quchuBtn:setVisible(true)
		self.m_startBtn:setVisible(false)
		self.m_state = self.stateFinish
		self.m_time = 0
		self.m_gotBonus = 0
	else
		self.m_time = self.m_time + delta
		local change = self.m_time / 1000 * self.m_gotBonus + 1
		if self.m_gotBonus < change then
			change = self.m_gotBonus
			self.m_quchuBtn:setVisible(true)
			self.m_startBtn:setVisible(false)
			self.m_state = self.stateFinish
		end
		change = math.floor(change)
		self.m_bonus:setText(tostring(change))
	end
end

function LaohujiDlg:stateFinish( delta )
	
end

function LaohujiDlg:clampItemIndex()
	self.m_currItem = math.floor((self.m_currItem-1) % self.m_itemNum) + 1
end

function LaohujiDlg:grayItem( index )
	self.m_gameItems[index]:setProperty("Image", self.m_itemGrayImage)	
end

function LaohujiDlg:lightItem( index )
	self.m_gameItems[index]:setProperty("Image", self.m_itemLightImage)
end

function LaohujiDlg:lightLucky()
	for i=1,self.m_targets.curr-1  do
		self:lightItem(self.m_targets[i])
	end
end

function LaohujiDlg:grayLucky()
	for i=1,#self.m_targets-1 do
		self:grayItem(self.m_targets[i])
	end
end

function LaohujiDlg:grayGroupCell( groupid, index )
	self.m_group[groupid][index]:setProperty("Image", self.m_groupGrayImage)	
end

function LaohujiDlg:lightGroupCell( groupid, index )
	self.m_group[groupid][index]:setProperty("Image", self.m_groupLightImage)
end

function LaohujiDlg:refreshYuanbaoNum()
	self.m_yuanbaoNum = GetDataManager():GetYuanBaoNumber()
	self.m_yuanbao:setText(tostring(self.m_yuanbaoNum))
end

function LaohujiDlg:HandleTouzhuClicked( args )
	if self.m_state ~= self.stateReady then return end
	local e = CEGUI.toWindowEventArgs(args)
	for i=1,8 do
		if e.window == self.m_touzhu[i].btn then
			-- if self.m_yuanbaoNum < 10 then 
			-- 	return 
			-- end
			local touzhu = self.m_touzhu[i]
			touzhu.num = touzhu.num + 10
			touzhu.text:setText(tostring(touzhu.num))
			self.m_yuanbaoNum = self.m_yuanbaoNum - 10
			self.m_yuanbao:setText(tostring(self.m_yuanbaoNum))
			return
		end
	end
end

function LaohujiDlg:HandleResetClicked()
	for _,v in ipairs(self.m_touzhu) do
		v.num = 0
		v.text:setText("0")
		self:refreshYuanbaoNum()
	end
end

function LaohujiDlg:HandleHelpClicked()
	require "ui.laohuji.laohujihelp".getInstanceAndShow()
end

function LaohujiDlg:HandleRankClicked()
	require "ui.laohuji.laohujirank".getInstanceAndShow()
end

function LaohujiDlg:ClearTouzhu()
	for _,v in ipairs(self.m_touzhu) do
		v.lastNum = v.num
		v.num = 0
		v.text:setText("0")
	end

	for i=1,2 do
		self:grayGroupCell(i, self.m_group[i].select)
		self.m_group[i].select = 1
	end
end

return LaohujiDlg