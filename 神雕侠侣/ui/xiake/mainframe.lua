require "ui.dialog"
--require "ui.xiake.xiake_jiuguan"

XiakeMainFrame = {
m_pButton1,
m_pButton2,
m_pButton3,
m_pButton4,
m_pButton5,

kJiuguan = 1,
kWodeXK  = 2,
kBuZhen  = 3,
kQiYuan  = 4
}

setmetatable(XiakeMainFrame, Dialog)
XiakeMainFrame.__index = XiakeMainFrame

local _instance;

function XiakeMainFrame.getInstance()
	if not _instance then
		_instance = XiakeMainFrame:new()
		_instance:OnCreate()
	end

	return _instance
end

function XiakeMainFrame.peekInstance()
	return _instance;
end

function XiakeMainFrame.DestroyDialog()
	local jiuguan = XiakeJiuguan.peekInstance();
	local myxiake = MyXiake_xiake.peekInstance();
	local buzhen =  BuzhenXiake.peekInstance();
    local qiyu    = XiakeQiyu.peekInstance()
	QuackFoundRare.DestroyDialog()

	if _instance then
		_instance:OnClose()
		_instance = nil
	end

	if jiuguan ~= nil then
		jiuguan.DestroyDialog();
	end

	if myxiake ~= nil then
		myxiake.DestroyDialog();
	end

	if buzhen ~= nil then
		buzhen.DestroyDialog();
	end
    
    if qiyu ~= nil then
        qiyu.DestroyDialog()
    end
end

function XiakeMainFrame.GetLayoutFileName()
	return "Lable.layout"
end

function XiakeMainFrame:OnCreate()
	Dialog.OnCreate(self, nil, enumXiakeLabel)

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton1 = winMgr:getWindow(tostring(enumXiakeLabel) .. "Lable/button");
	self.m_pButton2 = winMgr:getWindow(tostring(enumXiakeLabel) .. "Lable/button1");
	self.m_pButton3 = winMgr:getWindow(tostring(enumXiakeLabel) .. "Lable/button2");
	self.m_pButton4 = winMgr:getWindow(tostring(enumXiakeLabel) .. "Lable/button3");
	self.m_pButton5 = winMgr:getWindow(tostring(enumXiakeLabel) .. "Lable/button4");

	self.m_pButton1:setText(knight.gsp.message.GetCStringResTableInstance():getRecorder(2732).msg);
	self.m_pButton2:setText(knight.gsp.message.GetCStringResTableInstance():getRecorder(2733).msg);
	self.m_pButton3:setText(knight.gsp.message.GetCStringResTableInstance():getRecorder(2735).msg);
	self.m_pButton4:setText(knight.gsp.message.GetCStringResTableInstance():getRecorder(2734).msg);

	self.m_pButton5:setVisible(false);
	self.m_pButton1:subscribeEvent("Clicked", XiakeMainFrame.HandleButton1Clicked, self);
	self.m_pButton2:subscribeEvent("Clicked", XiakeMainFrame.HandleButton2Clicked, self);
	self.m_pButton3:subscribeEvent("Clicked", XiakeMainFrame.HandleButton3Clicked, self);
	self.m_pButton4:subscribeEvent("Clicked", XiakeMainFrame.HandleButton4Clicked, self);
end

function XiakeMainFrame:SubscribeEvent(pWnd)
	LogInfo("XiakeMainFrame subscribe event")
	pWnd:subscribeEvent("AlphaChanged", XiakeMainFrame.HandleDlgStateChange, self)
	pWnd:subscribeEvent("Shown", XiakeMainFrame.HandleDlgStateChange, self)
	pWnd:subscribeEvent("Hidden", XiakeMainFrame.HandleDlgStateChange, self)
	pWnd:subscribeEvent("InheritAlphaChanged", XiakeMainFrame.HandleDlgStateChange, self)
	LogInfo("XiakeMainFrame subscribe event end")
end
function XiakeMainFrame:HandleDlgStateChange(args)
	LogInfo("petlabel handle dlg state change")
	if XiakeJiuguan.peekInstance() then 
		local pWnd = XiakeJiuguan.peekInstance():GetWindow()
		if pWnd:isVisible() and pWnd:getEffectiveAlpha() > 0.95 then
			self:GetWindow():setVisible(true)
			return true
		end
	end
	if MyXiake_xiake.peekInstance() then 
		local pWnd = MyXiake_xiake.peekInstance():GetWindow()
		if pWnd:isVisible() and pWnd:getEffectiveAlpha() > 0.95 then
			self:GetWindow():setVisible(true)
			return true
		end
	end
	if BuzhenXiake.peekInstance() then 
		local pWnd = BuzhenXiake.peekInstance():GetWindow()
		if pWnd:isVisible() and pWnd:getEffectiveAlpha() > 0.95 then
			self:GetWindow():setVisible(true)
			return true
		end
	end
	if XiakeQiyu.peekInstance() then 
		local pWnd = XiakeQiyu.peekInstance():GetWindow()
		if pWnd:isVisible() and pWnd:getEffectiveAlpha() > 0.95 then
			self:GetWindow():setVisible(true)
			return true
		end
	end

	self:GetWindow():setVisible(false)
	return true
end



function XiakeMainFrame:ShowWindow(w)
	local jiuguan = XiakeJiuguan.peekInstance();
	local wode    = MyXiake_xiake.peekInstance();
	local buzhen  = BuzhenXiake.peekInstance();
	local qiyu    = XiakeQiyu.peekInstance();
	QuackFoundRare.DestroyDialog()

	if jiuguan ~= nil then
		jiuguan:SetVisible(false);
	end

	if wode ~= nil then
		wode:SetVisible(false);
	end

	if buzhen ~= nil then
		buzhen:SetVisible(false);
	end

	if qiyu ~= nil then
		qiyu:SetVisible(false);
	end

	if w == self.kJiuguan then
		if jiuguan == nil then 
			jiuguan = XiakeJiuguan.getInstance()	
			self:SubscribeEvent(jiuguan:GetWindow())
		end
		jiuguan:SetVisible(true);
		jiuguan:GetWindow():setAlpha(1)
	elseif w == self.kWodeXK then
		if wode == nil then
			wode = MyXiake_xiake.getInstance()
			self:SubscribeEvent(wode:GetWindow())
		end
		wode:RefreshMyXiakes();
		wode:RefreshCurrentXiake(wode.m_XiakeData);
		wode:SetVisible(true);
		wode:GetWindow():setAlpha(1)
	elseif w == self.kBuZhen then
		if buzhen == nil then
			buzhen = BuzhenXiake.getInstance()
			self:SubscribeEvent(buzhen:GetWindow())
		end
		buzhen:SetVisible(true);
		buzhen:GetWindow():setAlpha(1)
        buzhen:RefreshXiakesKeepOldAddState()
	elseif w == self.kQiYuan then
		if qiyu == nil then 
			qiyu = XiakeQiyu.getInstance() 
			self:SubscribeEvent(qiyu:GetWindow())
		end
		qiyu:SetVisible(true);
		qiyu:GetWindow():setAlpha(1)
	end

	if w == self.kJiuguan and jiuguan ~= nil then
		jiuguan:SetMode(XiakeJiuguan.ModeFind);
	end
    
    SelfChuanGong.DeleteDialog()
    XiakeChuanGong.DeleteDialog()
end

function XiakeMainFrame:HandleButton1Clicked(arg)
	self:ShowWindow(self.kJiuguan);
end

function XiakeMainFrame:HandleButton2Clicked(arg)
	self:ShowWindow(self.kWodeXK);
end

function XiakeMainFrame:HandleButton3Clicked(arg)
	self:ShowWindow(self.kBuZhen);
end

function XiakeMainFrame:HandleButton4Clicked(arg)
	--GetGameUIManager():AddMessageTipById(141470);
	self:ShowWindow(self.kQiYuan);
end

function XiakeMainFrame:ShowById(id)
	LogInfo("XiakeMainFrame ShowById " .. tostring(id))
	if id ==1 then 
		self:ShowWindow(self.kJiuguan)
	elseif id == 2 then
		self:ShowWindow(self.kWodeXK)
	elseif id == 3 then
		self:ShowWindow(self.kBuZhen)
	elseif id == 4 then
		self:ShowWindow(self.kQiYuan)
	end
end

function XiakeMainFrame:new()
	local self={}
	self = Dialog:new()
	setmetatable(self, XiakeMainFrame)
	return self
end

return XiakeMainFrame
