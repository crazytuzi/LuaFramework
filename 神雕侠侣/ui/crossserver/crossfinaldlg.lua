CrossFinalDlg = {}

setmetatable(CrossFinalDlg, Dialog);
CrossFinalDlg.__index = CrossFinalDlg;

local _instance;

function CrossFinalDlg.getInstance()
	if _instance == nil then
		_instance = CrossFinalDlg:new();
		_instance:OnCreate();
	end

	return _instance;
end

function CrossFinalDlg.getInstanceNotCreate()
	return _instance;
end

function CrossFinalDlg.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
		LogInfo("CrossFinalDlg DestroyDialog")
	end
end

function CrossFinalDlg.getInstanceAndShow()
    if not _instance then
        _instance = CrossFinalDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function CrossFinalDlg.ToggleOpenClose()
	if not _instance then 
		_instance = CrossFinalDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function CrossFinalDlg.GetLayoutFileName()
	return "huashanzhidianfinal.layout";
end

function CrossFinalDlg:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, CrossFinalDlg);

	return zf;
end

------------------------------------------------------------------------------

function CrossFinalDlg:OnCreate()
	LogInfo("CrossFinalDlg OnCreate ")

	--destroy others
	if CrossXuanZhanDlg and CrossXuanZhanDlg.getInstanceNotCreate() then
		CrossXuanZhanDlg.DestroyDialog()
	end
	if CrossFinalSemiDlg and CrossFinalSemiDlg.getInstanceNotCreate() then
		CrossFinalSemiDlg.DestroyDialog()
	end

	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton();
	self.m_leftTeam = winMgr:getWindow("huashanzhidianfinal/back/left/back0");
	self.m_rightTeam = winMgr:getWindow("huashanzhidianfinal/back/right/back0");

	self.m_leftTeam:subscribeEvent("MouseClick", self.HandleShowTeam1, self)
	self.m_rightTeam:subscribeEvent("MouseClick", self.HandleShowTeam2, self)

	self.m_leftTeam:setText("")
	self.m_rightTeam:setText("")

	self.m_lText = winMgr:getWindow("huashanzhidianfinal/back/left/up/zi")
	self.m_rText = winMgr:getWindow("huashanzhidianfinal/back/right/up/zi")

	LogInfo("CrossFinalDlg OnCreate finish")
end

function CrossFinalDlg:SetTeamInfo( teamList, grade )
	self.m_grade = grade
	if grade == 1 then
		self.m_lText:setProperty("Image", "set:MainControl34 image:1wu")
		self.m_rText:setProperty("Image", "set:MainControl34 image:1ji")
	else 
		self.m_lText:setProperty("Image", "set:MainControl34 image:1tian")
		self.m_rText:setProperty("Image", "set:MainControl34 image:1di")
	end

	self.m_teams = {}
	for i,v in ipairs(teamList) do
		for ii,vv in ipairs(v.steams) do
			local team = {}
			team.teamscore = vv.teamscore
			team.servername = vv.servername
			team.team16id = vv.team16id
			team.guanjun = vv.guanjun
			team.teamid = vv.teamid
			self.m_teams[#self.m_teams + 1] = team
		end
	end

	self:modifyImageAndText()
end

function CrossFinalDlg:modifyImageAndText()
	local colorTable = {"set:MainControl33 image:loadsilver"
					   ,"set:MainControl33 image:loadgreen"
					   ,"set:MainControl33 image:loadred"
					   ,"set:MainControl33 image:loadyellow"
					   ,"set:MainControl33 image:loadpurple"}
					   
	if self.m_teams[1] then
		if self.m_teams[1].team16id == 0 then
			self:setBtnImage(self.m_leftTeam, colorTable[1])
		else
			local color = require "utils.mhsdutils".getLuaBean( "knight.gsp.game.cteam16", self.m_teams[1].team16id).color
			self:setBtnImage(self.m_leftTeam, colorTable[color + 1])
		end
		self.m_leftTeam:setText(self.m_teams[1].servername)
	end

	if self.m_teams[2] then
		if self.m_teams[2].team16id == 0 then
			self:setBtnImage(self.m_rightTeam, colorTable[1])
		else
			local color = require "utils.mhsdutils".getLuaBean( "knight.gsp.game.cteam16", self.m_teams[2].team16id).color
			self:setBtnImage(self.m_rightTeam, colorTable[color + 1])
		end
		self.m_rightTeam:setText(self.m_teams[2].servername)
	end
end

function CrossFinalDlg:setBtnImage( btn, image )
	btn:setProperty("NormalImage", image)
	btn:setProperty("HoverImage" , image)
	btn:setProperty("PushedImage", image)
end

function CrossFinalDlg:ShowTeam( index )
	LogInfo("CrossFinalDlg ShowTeam "..tostring(index))
	if (not self.m_teams[index]) or (self.m_teams[index].teamid == 0) then
		return
	end

	local p = require "protocoldef.knight.gsp.cross.creqcrossteaminfo" : new()
    p.teamid = self.m_teams[index].teamid
    p.grade = self.m_grade
    require "manager.luaprotocolmanager":send(p)
end

function CrossFinalDlg:HandleShowTeam1()
	self:ShowTeam(1)
end

function CrossFinalDlg:HandleShowTeam2()
	self:ShowTeam(2)
end


