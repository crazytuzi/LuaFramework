CrossFinalSemiDlg = {}

setmetatable(CrossFinalSemiDlg, Dialog);
CrossFinalSemiDlg.__index = CrossFinalSemiDlg;

local _instance;

function CrossFinalSemiDlg.getInstance()
	if _instance == nil then
		_instance = CrossFinalSemiDlg:new();
		_instance:OnCreate();
	end

	return _instance;
end

function CrossFinalSemiDlg.getInstanceNotCreate()
	return _instance;
end

function CrossFinalSemiDlg.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
		LogInfo("CrossFinalSemiDlg DestroyDialog")
	end
end

function CrossFinalSemiDlg.getInstanceAndShow()
    if not _instance then
        _instance = CrossFinalSemiDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function CrossFinalSemiDlg.ToggleOpenClose()
	if not _instance then 
		_instance = CrossFinalSemiDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function CrossFinalSemiDlg.GetLayoutFileName()
	return "huashanzhidianfinalsemi.layout";
end

function CrossFinalSemiDlg:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, CrossFinalSemiDlg);

	return zf;
end

------------------------------------------------------------------------------

function CrossFinalSemiDlg:OnCreate()
	LogInfo("CrossFinalSemiDlg OnCreate")

	if CrossXuanZhanDlg and CrossXuanZhanDlg.getInstanceNotCreate() then
		CrossXuanZhanDlg.DestroyDialog()
	end
	if CrossFinalDlg and CrossFinalDlg.getInstanceNotCreate() then
		CrossFinalDlg.DestroyDialog()
	end

	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton();
	self.m_teamBtns = {}
	self.m_teamBtns[1] = winMgr:getWindow("huashanzhidianfinalsemi/back/left/back0");
	self.m_teamBtns[2] = winMgr:getWindow("huashanzhidianfinalsemi/back/left/back1");
	self.m_teamBtns[3] = winMgr:getWindow("huashanzhidianfinalsemi/back/right/back0");
	self.m_teamBtns[4] = winMgr:getWindow("huashanzhidianfinalsemi/back/right/back1");

	for i,v in ipairs(self.m_teamBtns) do
		local funcName = "HandleShowTeam"..tostring(i)
		self[funcName] = function(self)
			self:ShowTeam(i)
		end

		v:subscribeEvent("MouseClick", self[funcName], self)
		v:setText("")
	end

	LogInfo("CrossFinalSemiDlg OnCreate finish")
end

function CrossFinalSemiDlg:SetTeamInfo( teamList )

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

function CrossFinalSemiDlg:modifyImageAndText()
	local colorTable = {"set:MainControl33 image:loadsilver"
					   ,"set:MainControl33 image:loadgreen"
					   ,"set:MainControl33 image:loadred"
					   ,"set:MainControl33 image:loadyellow"
					   ,"set:MainControl33 image:loadpurple"}

	for i = 1, 4 do
		if self.m_teams[i].team16id == 0 then
			self:setBtnImage(self.m_teamBtns[i], colorTable[1])
		else
			local color = require "utils.mhsdutils".getLuaBean( "knight.gsp.game.cteam16", self.m_teams[i].team16id).color
			self:setBtnImage(self.m_teamBtns[i], colorTable[color + 1])
		end
		self.m_teamBtns[i]:setText(self.m_teams[i].servername)
	end
end

function CrossFinalSemiDlg:setBtnImage( btn, image )
	btn:setProperty("NormalImage", image)
	btn:setProperty("HoverImage" , image)
	btn:setProperty("PushedImage", image)
end

function CrossFinalSemiDlg:ShowTeam( index )
	LogInfo("CrossFinalSemiDlg ShowTeam "..tostring(index))
	if (not self.m_teams[index]) or (self.m_teams[index].teamid == 0) then
		return
	end
	
	local p = require "protocoldef.knight.gsp.cross.creqcrossteaminfo" : new()
    p.teamid = self.m_teams[index].teamid
    p.grade = 3
    require "manager.luaprotocolmanager":send(p)
end


