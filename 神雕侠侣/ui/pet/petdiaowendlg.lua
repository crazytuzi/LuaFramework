local PetDiaoWenDlg = {}

setmetatable(PetDiaoWenDlg, Dialog);
PetDiaoWenDlg.__index = PetDiaoWenDlg;

local _instance;

function PetDiaoWenDlg.getInstance()
	if _instance == nil then
		_instance = PetDiaoWenDlg:new();
		_instance:OnCreate();
	end

	return _instance;
end

function PetDiaoWenDlg.getInstanceNotCreate()
	return _instance;
end

function PetDiaoWenDlg.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
		LogInfo("PetDiaoWenDlg DestroyDialog")
	end
end

function PetDiaoWenDlg.getInstanceAndShow()
    if not _instance then
        _instance = PetDiaoWenDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function PetDiaoWenDlg.ToggleOpenClose()
	if not _instance then 
		_instance = PetDiaoWenDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetDiaoWenDlg.GetLayoutFileName()
	return "petdiaowen.layout";
end

function PetDiaoWenDlg:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, PetDiaoWenDlg);

	return zf;
end

------------------------------------------------------------------------------

function PetDiaoWenDlg:OnCreate()
	LogInfo("PetDiaoWenDlg OnCreate ")
	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_diaowen1 = winMgr:getWindow("petdiaowen/left1/txt1")
	self.m_diaowen2 = winMgr:getWindow("petdiaowen/left2/txt1")
	self.m_num11 = winMgr:getWindow("petdiaowen/left1/txt3/num1")
	self.m_num12 = winMgr:getWindow("petdiaowen/left1/txt3/num2")
	self.m_num21 = winMgr:getWindow("petdiaowen/left2/txt3/num1")
	self.m_num22 = winMgr:getWindow("petdiaowen/left2/txt3/num2")
	self.m_description1 = winMgr:getWindow("petdiaowen/left1/txt2")
	self.m_description2 = winMgr:getWindow("petdiaowen/left2/txt2")
	self.m_numArea1 = winMgr:getWindow("petdiaowen/left1/txt3")
	self.m_numArea2 = winMgr:getWindow("petdiaowen/left2/txt3")

	self.m_emptyString = MHSD_UTILS.get_resstring(1663)
	self.m_diaowen1:setText(self.m_emptyString)
	self.m_diaowen2:setText(self.m_emptyString)
	self.m_num11:setText("0")
	self.m_num12:setText("0")
	self.m_num21:setText("0")
	self.m_num22:setText("0")
	self.m_description1:setText(self.m_emptyString)
	self.m_description2:setText(self.m_emptyString)

	self:GetWindow():setAlwaysOnTop(true)
	self:SetTextVisible(false, 1)
	self:SetTextVisible(false, 2)
	LogInfo("PetDiaoWenDlg OnCreate finish")
end

function PetDiaoWenDlg:SetTextVisible( visible, index )
	if index == 1 then
		self.m_diaowen1:setVisible(visible)
		self.m_description1:setVisible(visible)
		self.m_numArea1:setVisible(visible)
	else
		self.m_diaowen2:setVisible(visible)
		self.m_description2:setVisible(visible)
		self.m_numArea2:setVisible(visible)
	end
end

function PetDiaoWenDlg:SetData( index, diaowenid, num )
	self:SetTextVisible(true, index)
	print("PetDiaoWenDlg "..tostring(index)..tostring(diaowenid)..tostring(num))
	local diaowenStr = MHSD_UTILS.get_resstring(1663)
	local dw = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cpetglyoh"):getRecorder(diaowenid)
	diaowenStr = dw.name

	local attrs = {"twodescription", "threedescription", "fourdescription", "fivedescription"}
	if index == 1 then
		self.m_diaowen1:setText(diaowenStr)
		self.m_num11:setText(tostring(num))
		self.m_num12:setText(tostring(dw.num))
		self.m_description1:setText(dw[attrs[num-1]])
	elseif index == 2 then
		self.m_diaowen2:setText(diaowenStr)
		self.m_num21:setText(tostring(num))
		self.m_num22:setText(tostring(dw.num))
		self.m_description2:setText(dw[attrs[num-1]])
	end
end

return PetDiaoWenDlg
