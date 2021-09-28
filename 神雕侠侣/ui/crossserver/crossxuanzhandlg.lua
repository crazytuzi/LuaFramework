require "ui.crossserver.crosscellfour"
require "ui.crossserver.crosscelltwo"

CrossXuanZhanDlg = {}

setmetatable(CrossXuanZhanDlg, Dialog);
CrossXuanZhanDlg.__index = CrossXuanZhanDlg;

local _instance;

function CrossXuanZhanDlg.getInstance()
	if _instance == nil then
		_instance = CrossXuanZhanDlg:new();
		_instance:OnCreate();
	end

	return _instance;
end

function CrossXuanZhanDlg.getInstanceNotCreate()
	return _instance;
end

function CrossXuanZhanDlg.DestroyDialog()
	if _instance then
		_instance:resetList()
		_instance:OnClose();
		_instance = nil;
		print("CrossXuanZhanDlg DestroyDialog")
	end
end

function CrossXuanZhanDlg.getInstanceAndShow()
    if not _instance then
        _instance = CrossXuanZhanDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end

    return _instance
end

function CrossXuanZhanDlg.ToggleOpenClose()
	if not _instance then 
		_instance = CrossXuanZhanDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function CrossXuanZhanDlg.GetLayoutFileName()
	return "huashanzhidiaxuanzhan.layout"
end

function CrossXuanZhanDlg:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, CrossXuanZhanDlg);
	return zf;
end

------------------------------------------------------------------------------
function CrossXuanZhanDlg:OnCreate()
	print("CrossXuanZhanDlg OnCreate")
	
	--destroy others
	if CrossFinalDlg and CrossFinalDlg.getInstanceNotCreate() then
		CrossFinalDlg.DestroyDialog()
	end
	if CrossFinalSemiDlg and CrossFinalSemiDlg.getInstanceNotCreate() then
		CrossFinalSemiDlg.DestroyDialog()
	end

	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton();

	self.m_lbtn = winMgr:getWindow("huashanzhidiaxuanzhan/left/lbtn")
	self.m_rbtn = winMgr:getWindow("huashanzhidiaxuanzhan/right/rbtn")
	self.m_lbtn:subscribeEvent("MouseClick", self.PrevPage, self)
	self.m_rbtn:subscribeEvent("MouseClick", self.NextPage, self)

	self.m_panelCtn = CEGUI.Window.toScrollablePane(winMgr:getWindow("huashanzhidiaxuanzhan/back/sgp"))
	self.m_panelCtn:EnableHorzScrollBar(true)
	self.m_panelCtn:EnablePageScrollMode(true)
	self:resetList()	

	print("CrossXuanZhanDlg OnCreate finish")
end

function CrossXuanZhanDlg:resetList()
	if self.m_panelCtn then
		self.m_panelCtn:cleanupNonAutoChildren()
		self.m_panels = {}
		self.m_teamBtns = {}
	end
end

function CrossXuanZhanDlg:onGradeChanged()
	self:resetList()
	local winMgr = CEGUI.WindowManager:getSingleton();

	if self.m_grade == 4 then
		local imageName = {"set:MainControl34 image:1ao"
						  ,"set:MainControl34 image:1shi"
						  ,"set:MainControl34 image:1ba"
						  ,"set:MainControl34 image:1qiang"}
		for i = 1, self.m_groupNum do
			local panel = CrossCellTwo.CreateNewDlg(self.m_panelCtn, i)
			self.m_panels[i] = panel
			panel.pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, panel.pWnd:getPixelSize().width * (i - 1) + 1), CEGUI.UDim(0,0)))
			winMgr:getWindow(tostring(i).."huashanzhidiaxuanzhancell2/back/img/up/zi"):setProperty("Image", imageName[i])

			for j = 1, 2 do
				table.insert(self.m_teamBtns, self.m_panels[i].m_btns[j])
			end
		end

		self.m_lbtn:setVisible(false)
		self.m_rbtn:setVisible(false)
	elseif self.m_grade == 5 then
		local imageName = {"set:MainControl34 image:1tian"
				  		  ,"set:MainControl34 image:1di"
				  		  ,"set:MainControl34 image:1xuan"
				  		  ,"set:MainControl34 image:1huang"}
		for i = 1, self.m_groupNum  do
			local panel = CrossCellFour.CreateNewDlg(self.m_panelCtn, i)
			self.m_panels[i] = panel
			panel.pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, panel.m_width * (i - 1) + 1), CEGUI.UDim(0,0)))
			winMgr:getWindow(tostring(i).."huashanzhidiaxuanzhancell1/back/img/up/zi"):setProperty("Image", imageName[i])

			for j = 1, 4 do
				table.insert(self.m_teamBtns, self.m_panels[i].m_btns[j])
			end
		end

		self.m_lbtn:setVisible(false)
		self.m_rbtn:setVisible(false)
	else -- 6
		for i = 1, self.m_groupNum do
			local panel = CrossCellFour.CreateNewDlg(self.m_panelCtn, i)
			self.m_panels[i] = panel
			panel.pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0, panel.m_width * (i - 1) + 1), CEGUI.UDim(0,0)))
			for j = 1, 4 do
				table.insert(self.m_teamBtns, self.m_panels[i].m_btns[j])
			end
		end
		self.m_lbtn:setVisible(true)
		self.m_rbtn:setVisible(true)
	end
	for i,v in ipairs(self.m_teamBtns) do
		local funcName = "HandleShowTeam"..tostring(i)
		self[funcName] = function(self)
			self:ShowTeam(i)
		end

		v:subscribeEvent("MouseClick", self[funcName], self)
	end
end

function CrossXuanZhanDlg:SetTeamInfo( teamList, grade )
	self.m_teams = {}
	self.m_groupNum = 0
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
		self.m_groupNum = self.m_groupNum + 1
	end
	if self.m_grade ~= grade then
		self.m_grade = grade
		self:onGradeChanged()
	end
	self:modifyImageAndText()
end

function CrossXuanZhanDlg:modifyImageAndText()
	local colorTable = {"set:MainControl33 image:loadsilver"
					   ,"set:MainControl33 image:loadgreen"
					   ,"set:MainControl33 image:loadred"
					   ,"set:MainControl33 image:loadyellow"
					   ,"set:MainControl33 image:loadpurple"}

	for i = 1, #self.m_teams do
		if self.m_teams[i].team16id == 0 then
			self:setBtnImage(self.m_teamBtns[i], colorTable[1])
		else
			local color = require "utils.mhsdutils".getLuaBean( "knight.gsp.game.cteam16", self.m_teams[i].team16id).color
			self:setBtnImage(self.m_teamBtns[i], colorTable[color + 1])
		end
		self.m_teamBtns[i]:setText(self.m_teams[i].servername)
		if self.m_grade ~= 4 then
			self.m_teamBtns[i].m_text:setText(tostring(self.m_teams[i].teamscore))
		end
	end
end

function CrossXuanZhanDlg:setBtnImage( btn, image )
	btn:setProperty("NormalImage", image)
	btn:setProperty("HoverImage" , image)
	btn:setProperty("PushedImage", image)
end

function CrossXuanZhanDlg:ShowTeam( index )
	print("CrossXuanZhanDlg ShowTeam "..tostring(index))
	print("teamid "..tostring(self.m_teams[index].teamid))
	if (not self.m_teams[index]) or (self.m_teams[index].teamid == 0) then
		return
	end

	local p = require "protocoldef.knight.gsp.cross.creqcrossteaminfo" : new()
    p.teamid = self.m_teams[index].teamid
    p.grade = self.m_grade or 6
    require "manager.luaprotocolmanager":send(p)
end

function CrossXuanZhanDlg:PrevPage()
	self.m_panelCtn:setHorizontalScrollPosition(self.m_panelCtn:getHorizontalScrollPosition() - 0.25)
end

function CrossXuanZhanDlg:NextPage()
	self.m_panelCtn:setHorizontalScrollPosition(self.m_panelCtn:getHorizontalScrollPosition() + 0.25)
end







