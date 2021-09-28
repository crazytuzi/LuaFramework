require "ui.dialog"
BingLinChengXiaDlg = {}
setmetatable(BingLinChengXiaDlg, Dialog)
BingLinChengXiaDlg.__index = BingLinChengXiaDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
local battleInfoTable = {}

function BingLinChengXiaDlg.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = BingLinChengXiaDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function BingLinChengXiaDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = BingLinChengXiaDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function BingLinChengXiaDlg.getInstanceNotCreate()
    return _instance
end

function BingLinChengXiaDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function BingLinChengXiaDlg.ToggleOpenClose()
	if not _instance then 
		_instance = BingLinChengXiaDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function BingLinChengXiaDlg.GetLayoutFileName()
    return "binglinchengxia.layout"
end
function BingLinChengXiaDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()

	self.npcPic = winMgr:getWindow("binglinchengxia/up/image")
	self.talk = winMgr:getWindow("binglinchengxia/up/talk/text") 
	self.blood = CEGUI.Window.toProgressBar(winMgr:getWindow("binglinchengxia/up/bar"))
	self.bossinfo = CEGUI.Window.toRichEditbox(winMgr:getWindow("binglinchengxia/down/commoncase/box1"))
	self.battleinfo = CEGUI.Window.toRichEditbox(winMgr:getWindow("binglinchengxia/down/commoncase/box"))
	self.rank = CEGUI.Window.toPushButton(winMgr:getWindow("binglinchengxia/down/button"))
	self.countdown = winMgr:getWindow("binglinchengxia/down/case/text1")
	self.battleStart = CEGUI.Window.toPushButton(winMgr:getWindow("binglinchengxia/down/button1"))
	self.showMyself = CEGUI.Window.toCheckbox(winMgr:getWindow("binglinchengxia/down/commoncase/check"))
	self.bossName = winMgr:getWindow("binglinchengxia/up/name/text")
    self.bossStatus = winMgr:getWindow("binglinchengxia/up/image/tiaozhan")

	self.rank:subscribeEvent("Clicked",BingLinChengXiaDlg.HandleClicked,self) 
	self.battleStart:subscribeEvent("Clicked",BingLinChengXiaDlg.HandleClicked,self) 
	self.showMyself:subscribeEvent("CheckStateChanged" , self.SetAllBattleInfo , self)



	self.rank:setID(1)
	self.battleStart:setID(2)

	self.bossinfo:setTopAfterLoadFont(true)
	self.battleinfo:setTopAfterLoadFont(true)


	self.battleStart:setEnabled(false)

	self:SetAllBattleInfo()


end

------------------- private: -----------------------------------
function BingLinChengXiaDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, BingLinChengXiaDlg)
    return self
end
function BingLinChengXiaDlg:HandleClicked(args)
	local id = CEGUI.toWindowEventArgs(args).window:getID()
	if id == 1 then
		require("manager.luaprotocolmanager"):send(require("protocoldef.knight.gsp.binglinchengxia.creqdamagerank"):new())
	elseif id == 2 then
		require("manager.luaprotocolmanager"):send(require("protocoldef.knight.gsp.binglinchengxia.cfightboss"):new())
	end

end


function BingLinChengXiaDlg:process(bossid,bosshp,lefttime,status)
	self.tick = 0
	if lefttime >= 0 then
		self.count = lefttime
	else
		self.count = nil 	
	end
	local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.game.cbinglinconf", bossid)
	if cfg then
		self.bossName:setText(cfg.npcname)
		local iconPath = GetIconManager():GetImagePathByID(cfg.npcavatar)
		self.npcPic:setProperty("Image", iconPath:c_str())
		self.talk:setText(cfg.npcchat)
	
		if not self.isSetBossInfo then
			self.bossinfo:Clear()
			self.bossinfo:AppendParseText(CEGUI.String(cfg.npcdescription))
			self.bossinfo:Refresh()
			self.bossinfo:HandleTop()
			self.isSetBossInfo = true
		end

		self.blood:setProgress(bosshp/cfg.npchp)
		self.blood:setText(bosshp .. "/" .. cfg.npchp)
        
        if  status == 1 then
            self.bossStatus:setVisible(true)
            self.bossStatus:setProperty("Image", "set:MainControl32 image:tiaozhanchenggong")
        elseif status == 2 then
            self.bossStatus:setVisible(true)
            self.bossStatus:setProperty("Image", "set:MainControl32 image:tiaozhanshibai")
        else
            self.bossStatus:setVisible(false)
        end
	end
end
function BingLinChengXiaDlg:SetAllBattleInfo(args)
	self.battleinfo:Clear()
	if #battleInfoTable == 0 then return end 
	for i = 1,#battleInfoTable do
		self:SetSingleBattleInfo(battleInfoTable[i][1],battleInfoTable[i][2])
	end
end


function BingLinChengXiaDlg:SetSingleBattleInfo(battleinfo,flag)
	if self.showMyself:isSelected() and  flag == 2 or not self.showMyself:isSelected() and flag == 1 then return end		
	local strbuilder = StringBuilder:new()	
	strbuilder:Set("parameter1", battleinfo.rolename)
	strbuilder:Set("parameter2", battleinfo.bosssname)
	strbuilder:Set("parameter3", battleinfo.damage)

	if flag == 1 then
		self.battleinfo:AppendParseText(CEGUI.String(strbuilder:GetString(require("utils.mhsdutils").get_msgtipstring(145792))))
	elseif flag == 2 then
		self.battleinfo:AppendParseText(CEGUI.String(strbuilder:GetString(require("utils.mhsdutils").get_msgtipstring(145849))))
	end
	self.battleinfo:AppendBreak()
	self.battleinfo:Refresh()
	strbuilder:delete()
	

end


function BingLinChengXiaDlg.PushBattleInfo(battleinfo,flag)
	battleInfoTable[#battleInfoTable + 1] = {battleinfo,flag}
	if BingLinChengXiaDlg.getInstanceNotCreate() then
		BingLinChengXiaDlg.getInstanceNotCreate():SetSingleBattleInfo(battleinfo,flag)
	end
end




function BingLinChengXiaDlg:run(delta)
	if not 	self.count then return end
	self.tick = self.tick + delta
	if self.count > 0 then 
		if self.tick > 1000 then
			self.tick  = self.tick - 1000
			self.count = self.count - 1000
			self.countdown:setText(string.format("%02d:%02d", math.floor(self.count / 1000 % 3600 / 60  % 100), math.floor(self.count / 1000 % 3600 % 60)))
			self.battleStart:setEnabled(false)
		end
	else
		self.countdown:setText(string.format("%02d:%02d",0,0))
		self.battleStart:setEnabled(true)
	end
end



return BingLinChengXiaDlg
