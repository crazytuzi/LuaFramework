require "ui.dialog"
SelectRoleDialog = {}
setmetatable(SelectRoleDialog, Dialog)
SelectRoleDialog.__index = SelectRoleDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
local ROLEMAX = 5
function SelectRoleDialog.getInstance()
	print("enter getinstance")
    if not _instance then
        _instance = SelectRoleDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function SelectRoleDialog.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = SelectRoleDialog:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function SelectRoleDialog.getInstanceNotCreate()
    return _instance
end

function SelectRoleDialog.DestroyDialog()
	if _instance then
		GetGameUIManager():RemoveUIEffect(_instance.effect)
		_instance:OnClose()		
		_instance = nil
	end
end

function SelectRoleDialog.ToggleOpenClose()
	if not _instance then 
		_instance = SelectRoleDialog:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function SelectRoleDialog.GetLayoutFileName()
    return "selectrolenewnew.layout"
end
function SelectRoleDialog:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.roles = {}
	self.rolesIcon = {}
	self.rolesName = {}
	self.rolesSchool = {}
	self.rolesNum = {}
	

	for i = 1 , ROLEMAX do 
		self.roles[i] = winMgr:getWindow("selectrolenewnew/back/left/image" .. (i - 1))
		self.roles[i]:setVisible(false)
		self.roles[i]:subscribeEvent("MouseClick",SelectRoleDialog.HandleClicked,self)
		self.roles[i]:setID(i)
		self.roles[i]:setAllChildrenMousePassThroughEnabled(true)
		self.roles[i]:setMousePassThroughEnabled(false)

		self.rolesIcon[i] = winMgr:getWindow("selectrolenewnew/back/left/image/icon" .. (i - 1))
		self.rolesName[i] = winMgr:getWindow("selectrolenewnew/back/left/image/name" .. (i - 1))
		self.rolesSchool[i] = winMgr:getWindow("selectrolenewnew/back/left/image/school" .. (i - 1))
		self.rolesNum[i] = winMgr:getWindow("selectrolenewnew/back/left/image/num" .. (i - 1))
	end

	self.m_pSelectRoleName = winMgr:getWindow("selectrolenewnew/back/name")
	self.m_pSelectRoleIcon = winMgr:getWindow("selectrolenewnew/back/right")
	self.m_pSelectRoleIcon:setProperty("Image","")

	self.m_pReServerBtn = CEGUI.Window.toPushButton( winMgr:getWindow("selectrolenewnew/reservers"))
	self.m_gotoGameBtn = CEGUI.Window.toPushButton( winMgr:getWindow("selectrolenewnew/gotoBtn"))
	self.m_pReServerBtn:subscribeEvent("Clicked",SelectRoleDialog.HandleClicked,self)
	self.m_gotoGameBtn:subscribeEvent("Clicked",SelectRoleDialog.HandleClicked,self)
	self.m_pMainFrame:subscribeEvent("WindowUpdate", SelectRoleDialog.run, self)

	self.effect =  winMgr:getWindow("selectrolenewnew/back/effect")

	self.m_pReServerBtn:setID(101)
	self.m_gotoGameBtn:setID(102)

	self.m_pSelectRoleID = 0

	self.selectImage = "set:MainControl31 image:rolebackselect"
	self.unselectImage = "set:MainControl31 image:rolebacknormal"

	self:OnInit()
end

------------------- private: -----------------------------------
function SelectRoleDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, SelectRoleDialog)
    return self
end




function SelectRoleDialog:HandleClicked(args)
	local id = CEGUI.toWindowEventArgs(args).window:getID()
	if not id then 
		return
	end
	if id == 102 then
		local roleList = GetLoginManager():GetRoleList();
		local roleid = self.m_pSelectRoleID
		if roleList:size() == 0 or roleid == 0 then
			return
		end
		if  not GetNetConnection():IsCanEnterWorld() then
			GetGameUIManager():AddMessageTip(knight.gsp.message.GetCMessageTipTableInstance():getRecorder(143759).msg)
			return
		end
		GetGameApplication():BeginDrawServantIntro()
		GetGameApplication():DrawLoginBar(0)
		GetGameApplication():DrawLoginBar(20)
        GetNetConnection():send(knight.gsp.CEnterWorld(roleid, require("ui.advansettingdlg").GetMaxDisplayPlayerNum()))   
		self.DestroyDialog()
		return true
	elseif id == 101 then
		if GetNetConnection() then
			GetNetConnection():send(knight.gsp.CUserOffline())
			DestroyNetConnection()
		end
		local area = GetGameApplication():GetAreaName()
		local server = GetGameApplication():GetServerName()
		GetLoginManager():ToServerChoose(area,server)
		self.DestroyDialog()
		return true
	else
		if 	self.preselect and 	self.preselect == id then
			return
		end
		if self.rolesList and self.rolesList[id] then
			if	self:SetSelectedRoleInfo(self.rolesList[id]) then
				self.preselect = id
				for i = 1, ROLEMAX do
					self.roles[i]:setProperty("Image",self.unselectImage)
				end
				self.roles[id]:setProperty("Image",self.selectImage) 
			end
		end
		
	end
end


function SelectRoleDialog:OnInit()
	local roleList = GetLoginManager():GetRoleList()
	local m_iRoleNum = roleList:size()
	local preroleid = GetLoginManager():GetPreLoginRoleID()
	local preroleindex = 1 


--[[test data

	m_iRoleNum = ROLEMAX-1
	for i = 1 ,m_iRoleNum do
		roleList[i] = {}
		roleList[i].roleid = roleList[0].roleid
		roleList[i].rolename = roleList[0].rolename  .. i
		roleList[i].school = roleList[0].school
		roleList[i].shape = roleList[0].shape
		roleList[i].level = roleList[0].level + i
	end
	]]


	if m_iRoleNum == 0 then
		self.m_gotoGameBtn:setEnabled(false)
	else
		local foo = {}
		for i = 0 ,m_iRoleNum - 1 do
			foo[i+1] = roleList[i]
		end
		table.sort(foo,function (a,b) return a.level > b.level end)
		self.rolesList = foo
		for i = 1,ROLEMAX do
			if i <= m_iRoleNum then
				local headshape = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(foo[i].shape)
			    local path = GetIconManager():GetImagePathByID(headshape.headID):c_str()

				self.roles[i]:setVisible(true)
				self.rolesIcon[i]:setProperty("Image", path) 
				self.rolesName[i]:setText(foo[i].rolename) 
				self.rolesSchool[i]:setText(knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(foo[i].school).name)
				self.rolesNum[i]:setText(foo[i].level)

				if preroleid and foo[i].roleid == preroleid then
					preroleindex = i
				end
			else
				self.roles[i]:setVisible(false)
			end
		end		
--			print("sssssss",foo[preroleindex].roleid,foo[preroleindex].rolename,foo[preroleindex].school,foo[preroleindex].shape,foo[preroleindex].level,"preid:",preroleindex)
		
		self:SetSelectedRoleInfo(foo[preroleindex])
		self.roles[preroleindex]:setProperty("Image",self.selectImage)
		self.preselect = preroleindex
		--unselectImage  selectImage

	end
end



function SelectRoleDialog:SetSelectedRoleInfo(roleinfo)
	if roleinfo.roleid == 0 then
		self.selectRoleName:setText("")
		self.roleImage:setImage(nil)
		self.m_gotoGameBtn:setEnabled(false)
		return true
	else
		local flag
		if not self.runEffect then
			if self.inited then
				self.runEffect = 0
			else
				flag = 0
			end
		else
			return false
		end
		self.m_pSelectRoleID = roleinfo.roleid
		local shapeid = roleinfo.shape % 100
		local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.effect.cselectroles", shapeid)
		if cfg then
			self.cfg = cfg
			GetGameUIManager():RemoveUIEffect(self.effect)
		end
		self.m_pSelectRoleName:setText(roleinfo.rolename)
		self.m_gotoGameBtn:setEnabled(true)	

		if flag then
			self:setPicture()
			self.inited = 0
		end
		return true
	end


end

function SelectRoleDialog:run(args)
	local delta = CEGUI.toUpdateEventArgs(args).d_timeSinceLastFrame
	if self.runEffect then
		self.runEffect = self.runEffect + delta
		if self.runEffect <= 0.5 then
			self.m_pSelectRoleIcon:setAlpha(0.5 - self.runEffect)
		elseif self.runEffect <= 1 then
			if self.hasSetPicture then
				self.m_pSelectRoleIcon:setAlpha((self.runEffect-0.5))
			else
				self.m_pSelectRoleIcon:setProperty("Image",self.cfg.picturelink)
				self.hasSetPicture = 0
			end
		else
			self:setPicture()
			self.runEffect = nil
			self.hasSetPicture = nil
		end

	end

end

function SelectRoleDialog:setPicture()
	if not self.cfg then return end
	if not self.hasSetPicture then
		self.m_pSelectRoleIcon:setProperty("Image",self.cfg.picturelink)
	end
	GetGameUIManager():AddUIEffect(self.effect, self.cfg.effectlink)	
	self.m_pSelectRoleIcon:setAlpha(1.0)
end

return SelectRoleDialog
