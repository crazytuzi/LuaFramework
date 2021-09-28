require "ui.dialog"
HeroesWaysDlg = {}
setmetatable(HeroesWaysDlg, Dialog)
HeroesWaysDlg.__index = HeroesWaysDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function HeroesWaysDlg.getInstance()
    if not _instance then
        _instance = HeroesWaysDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function HeroesWaysDlg.getInstanceAndShow()
    if not _instance then
        _instance = HeroesWaysDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function HeroesWaysDlg.getInstanceNotCreate()
    return _instance
end

function HeroesWaysDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function HeroesWaysDlg.ToggleOpenClose()
	if not _instance then 
		_instance = HeroesWaysDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function HeroesWaysDlg.GetLayoutFileName()
    return "heroesways.layout"
end
function HeroesWaysDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.button = CEGUI.Window.toPushButton(winMgr:getWindow("heroesways/button"))
	self.button2 = CEGUI.Window.toPushButton(winMgr:getWindow("heroesways/chongchujianghu"))


	self.remain = winMgr:getWindow("heroesways/text/txt")
	self.main = CEGUI.Window.toScrollablePane(winMgr:getWindow("heroesways/main"))
	self.button:subscribeEvent("Clicked",HeroesWaysDlg.HandleClicked,self)
	self.button:setID(0)

	self.button2:subscribeEvent("Clicked",HeroesWaysDlg.ChongchujianghuHandleClicked,self)

	

	local cfg = BeanConfigManager.getInstance():GetTableByName("knight.gsp.task.croadofhero")
	if not cfg then return end
	local ids = cfg:getAllID()
	self.cell = {}
	self.goButton = {}
	self.rewardButton = {}
	self.count = {}
	self.order = {}

	for id = 1 , #ids do
		local foo = cfg:getRecorder(id)
		self.cell[id] = self:CreateNewCell(id)
		self.goButton[id] = CEGUI.Window.toPushButton(winMgr:getWindow(id .. "herosewayscell/main/go"))
		self.rewardButton[id] = CEGUI.Window.toPushButton(winMgr:getWindow(id .. "herosewayscell/main/button"))
		self.count[id] = winMgr:getWindow(id .. "herosewayscell/main/text2")
		if  GetDataManager():GetMainCharacterLevel() < foo.level then
			self.goButton[id]:setID(10000 + id*100 + foo.level)
		else
			self.goButton[id]:setID(id)
		end
		self.rewardButton[id]:setID(100 + id)
		self.goButton[id]:subscribeEvent("Clicked",HeroesWaysDlg.HandleClicked,self)
		self.rewardButton[id]:subscribeEvent("Clicked",HeroesWaysDlg.HandleClicked,self)

		local info = CEGUI.Window.toPushButton(winMgr:getWindow(id .. "herosewayscell/main/info"))
		info:subscribeEvent("Clicked",HeroesWaysDlg.HandleInfoClicked,self)
		info:setID(id)


		local temp = winMgr:getWindow(id .. "herosewayscell/name")
		temp:setText(foo.name)
		temp = winMgr:getWindow(id .. "herosewayscell/main/text")
		temp:setText(foo.goal)
		temp = winMgr:getWindow(id .. "herosewayscell/main/text1")
		temp:setText(foo.award)
		self.order[id] = id
	end	

	local cfg = BeanConfigManager.getInstance():GetTableByName("knight.gsp.task.croadofhero"):getRecorder(0)
	local ENDTIME = cfg.award
	local eyear,emonth,eday,ehour,eminute,esecond,endTime,rday
	eyear,emonth,eday,ehour,eminute,esecond = string.match(ENDTIME,"(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
	endTime = os.time({year=eyear,month=emonth,day=eday,hour=ehour,min=eminute,sec=esecond})
	rday = math.ceil((endTime - GetServerTime() / 1000) / (3600 * 24))
	self.remain:setText(rday)
end

function HeroesWaysDlg:CreateNewCell(id)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local cell = winMgr:loadWindowLayout("herosewayscell.layout",id)
    self.main:addChildWindow(cell)
    cell:setPosition(CEGUI.UVector2(CEGUI.UDim(0,0),CEGUI.UDim(0,cell:getPixelSize().height*(id-1) + 1)))
    return cell
end


function HeroesWaysDlg:RefreshPosition()
	for i = 1,	#self.cell do
		self.cell[i]:setPosition(CEGUI.UVector2(CEGUI.UDim(0,0),CEGUI.UDim(0,self.cell[i]:getPixelSize().height*(self.order[i]-1) + 1)))
	end

end

------------------- private: -----------------------------------
function HeroesWaysDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, HeroesWaysDlg)
    return self
end


function HeroesWaysDlg:ChongchujianghuHandleClicked(args)
	require("manager.luaprotocolmanager"):send(require("protocoldef.knight.gsp.activity.veteran.cveteranreturn"):new())
end

function HeroesWaysDlg:HandleInfoClicked(args)
	local id = CEGUI.toWindowEventArgs(args).window:getID()
	local cfg = BeanConfigManager.getInstance():GetTableByName("knight.gsp.task.croadofhero"):getRecorder(id)

	ActivityDlgInfoCell.getInstanceAndShow():setInfo(nil,cfg.explaination)	
end


function HeroesWaysDlg:HandleClicked(args)
	local id = CEGUI.toWindowEventArgs(args).window:getID()
	if id == 0 then
		require("manager.luaprotocolmanager"):send(require("protocoldef.knight.gsp.activity.veteran.csummonveteran"):new())
		self.DestroyDialog()
	elseif id > 10000 then
		local taskid = math.floor(id % 10000  / 100)
		local level = id % 10000 % 100
		if taskid == 9 or taskid == 10 or taskid == 11 or taskid == 12 then
			GetGameUIManager():AddMessageTip(knight.gsp.message.GetCMessageTipTableInstance():getRecorder(140434).msg)
		elseif level == 70 then
			GetGameUIManager():AddMessageTip(knight.gsp.message.GetCMessageTipTableInstance():getRecorder(145831).msg)
		elseif level == 80 then 
			GetGameUIManager():AddMessageTip(knight.gsp.message.GetCMessageTipTableInstance():getRecorder(145832).msg)
		end
	elseif id < 100 then
		local cfg = BeanConfigManager.getInstance():GetTableByName("knight.gsp.task.croadofhero"):getRecorder(id)
		if cfg.id == 8 then
			require "ui.skill.skilllable"
			SkillLable.getInstance():ShowOnly(2)
			--	SkillLable.Show(3)
		elseif cfg.id == 9 then
			local CAgreeDrawRole = require "protocoldef.knight.gsp.faction.cagreedrawrole"
			local req = CAgreeDrawRole.Create()
			req.agree = 1
			req.flag = 6 
			LuaProtocolManager.getInstance():send(req)
		elseif cfg.id == 10 then
			GetMainCharacter():FlyOrWarkToPos(1013, 70, 105, 10127)
		elseif cfg.id == 11 then
			GetNetConnection():send(knight.gsp.task.CReqJionActivity(1))
		elseif cfg.id == 12 then
			require "protocoldef.knight.gsp.battle.ccampbattlestart"
			local start = CCampBattleStart:Create()
			LuaProtocolManager.getInstance():send(start)
			GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
		elseif cfg.id == 13 then
			GetNetConnection():send(knight.gsp.task.activelist.CRefreshActivityListFinishTimes())
		elseif cfg.id == 5 then
			local schoolID = GetDataManager():GetMainCharacterSchoolID()
			local i = -1
			repeat
				i = i + 2 
				if i >  #cfg.npcid then break end
			until schoolID == cfg.npcid[i-1] 
			if i <=  #cfg.npcid then self:GoByNPCID(cfg.npcid[i]) end
		elseif cfg.npcid[0]  == 0 and cfg.npcid[1] ~= 0 then
			self:GoByNPCID(cfg.npcid[1])
		end
		self.DestroyDialog()
	else
		id = id % 100
		local p = require("protocoldef.knight.gsp.activity.veteran.cveteranaward"):new()
		p.taskid = id
		require("manager.luaprotocolmanager"):send(p)
	end
end


function HeroesWaysDlg:GoByNPCID(id)
	local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(id)	
	GetMainCharacter():FlyOrWarkToPos(npcConfig.mapid, npcConfig.xPos, npcConfig.yPos, npcConfig.id)
end

function HeroesWaysDlg:processGetAwardNotify(id)
	local foo = {}
	local refoo = {}
	self:keyToValue(self.order,foo)
	local flag = false
	for i = 1 ,#foo do
		if foo[i] == id  then
			flag = true
		end
		if flag and i ~= #foo then
			foo[i] = foo[i+1]
		end
	end
	foo[#foo] = id
	self.rewardButton[id]:setEnabled(false)
	self:keyToValue(foo,self.order)
	self:RefreshPosition()
end

function HeroesWaysDlg:keyToValue(src,des)
	for i,v in pairs(src) do
		des[v] = i
	end
end


function HeroesWaysDlg:process(veteran,tasks)
	self.isOldFriend =  veteran == 1 

	local cfg = BeanConfigManager.getInstance():GetTableByName("knight.gsp.task.croadofhero")
	local ids = cfg:getAllID()
	for id  = 1 , #ids do
		local foo = cfg:getRecorder(id)
		self.count[id]:setText(0 .. "/" .. foo.schedule)
		self.rewardButton[id]:setVisible(false)
		if not foo.portal then
			self.goButton[id]:setVisible(false)
		else
			self.goButton[id]:setVisible(true)
		end


		if foo.actionid ~= 0 then
			require "ui.activity.activitymanager"
			if not ActivityManager.getInstance():isOpened(foo.actionid) or  not ActivityManager.getInstance():isInTime(foo.actionid) then
				self.goButton[id]:setID(10000 + id * 100)
			end
		end


		if tasks then
			for i = 1 , #ids do
				if	tasks[i] and tasks[i].taskid == id then
					self.count[id]:setText(tasks[i].count .. "/" .. foo.schedule)
					if tasks[i].count >= foo.schedule then
						self.goButton[id]:setVisible(false)
                        self.count[id]:setVisible(false)
						self.rewardButton[id]:setVisible(true)
						if tasks[i].reward == 0 then
							self.rewardButton[id]:setEnabled(true)
						else
							self.rewardButton[id]:setEnabled(false)
							self:processGetAwardNotify(id)
						end
					end
					break
				end
			end
		end
	end

end

return HeroesWaysDlg
