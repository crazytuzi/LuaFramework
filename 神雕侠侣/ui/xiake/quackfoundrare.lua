require "ui.dialog"
require "utils.mhsdutils"
require "ui.xiake.mainframe"
require "protocoldef.knight.gsp.xiake.cclickxiake10times"
require "ui.xiake.xiake_manager"
require "utils.scene_common"

QuackFoundRare = {}
setmetatable(QuackFoundRare, Dialog)
QuackFoundRare.__index = QuackFoundRare

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
local outTime = 0.3
function QuackFoundRare.getInstance()
	LogInfo("enter get QuackFoundRare instance")
    if not _instance then
        _instance = QuackFoundRare:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function QuackFoundRare.getInstanceAndShow()
	LogInfo("enter QuackFoundRare instance show")
    if not _instance then
        _instance = QuackFoundRare:new()
        _instance:OnCreate()
	else
		LogInfo("set QuackFoundRare visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function QuackFoundRare.getInstanceNotCreate()
    return _instance
end

function QuackFoundRare.DestroyDialog()
	if _instance then 
		LogInfo("destroy QuackFoundRare")
		_instance:OnClose()
		_instance = nil
	end
end

function QuackFoundRare.ToggleOpenClose()
	if not _instance then 
		_instance = QuackFoundRare:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

----/////////////////////////////////////////------

function QuackFoundRare.GetLayoutFileName()
    return "quackfoundrare.layout"
end

function QuackFoundRare:OnCreate()
	LogInfo("QuackFoundRare oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pXiakeBack = {}
	self.m_pXiakePic = {}
	self.m_pXiakeLevel = {}
	self.m_pXiakeName = {}
	self.m_pXiakeMark = {}
	for i = 0, 9 do
		self.m_pXiakeBack[i] = winMgr:getWindow("quackfoundrare/daditu/back" .. tostring(i))
		self.m_pXiakeBack[i]:setVisible(false)
		self.m_pXiakePic[i] = winMgr:getWindow("quackfoundrare/daditu/kuang" .. tostring(i))
		self.m_pXiakeLevel[i] = winMgr:getWindow("quackfoundrare/daditu/level" .. tostring(i))
		self.m_pXiakeLevel[i]:setText(tostring(GetDataManager():GetMainCharacterLevel()))
		self.m_pXiakeName[i] = winMgr:getWindow("quackfoundrare/daditu/name" .. tostring(i))
		self.m_pXiakeMark[i] = winMgr:getWindow("quackfoundrare/daditu/mark" .. tostring(i))
		self.m_pXiakeMark[i]:setProperty("Image", XiakeMng.eLvImages[1])
	end

	self.m_pEffectWnd = winMgr:getWindow("quackfoundrare/effect")
	self.m_pMyXiakeBtn = CEGUI.Window.toPushButton(winMgr:getWindow("quackfoundrare/ok"))
	self.m_pBackBtn = CEGUI.Window.toPushButton(winMgr:getWindow("quackfoundrare/ok1"))
	self.m_p10TimeBtn = CEGUI.Window.toPushButton(winMgr:getWindow("quackfoundrare/redbutton"))
	
    -- subscribe event
    self.m_pMyXiakeBtn:subscribeEvent("Clicked", QuackFoundRare.HandleMyXiakeClicked, self) 
	self.m_pBackBtn:subscribeEvent("Clicked", QuackFoundRare.HandleBackClicked, self)
	self.m_p10TimeBtn:subscribeEvent("Clicked", QuackFoundRare.Handle10TimeClicked, self)	

	self.m_fTime = 0
	self.m_bOut = true 
	LogInfo("QuackFoundRare oncreate end")
end

------------------- private: -----------------------------------


function QuackFoundRare:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, QuackFoundRare)
    return self
end

function QuackFoundRare:HandleBackClicked(args)
	LogInfo("QuackFoundRare HandleBackClicked")
	QuackFoundRare.DestroyDialog()
	XiakeMainFrame.getInstance():ShowWindow(XiakeMainFrame.kJiuguan)
end

function QuackFoundRare:Handle10TimeClicked(args)
	LogInfo("QuackFoundRare Handle10TimeClicked")
	local req = CClickXiake10Times.Create()
	LuaProtocolManager.getInstance():send(req)
end

function QuackFoundRare:HandleMyXiakeClicked(args)
	LogInfo("QuackFoundRare HandleMyXiakeClicked")
	local myxk = MyXiake_xiake.peekInstance();
	XiakeMainFrame.getInstance():ShowWindow(XiakeMainFrame.kWodeXK);
	QuackFoundRare.DestroyDialog()
end

function QuackFoundRare:InitList(xiakelist)
	LogInfo("QuackFoundRare InitList")
	self.m_lList = xiakelist
	for i = 0, 9 do
		self.m_pXiakeBack[i]:setVisible(false)
		self.m_pXiakeBack[i]:setAlpha(0)
	end
	local i = 0
	for k,v in pairs(xiakelist) do
		local xk = XiakeMng.ReadXiakeData(v)
		self.m_pXiakePic[i]:setProperty("Image", xk.path)
		self.m_pXiakeBack[i]:setProperty("Image", XiakeMng.eXiakeFrames[xk.xkxx.color])
		self.m_pXiakeName[i]:setText(scene_util.GetPetNameColor(xk.xkxx.color) .. xk.xkxx.name)
		i = i + 1
	end

	
	XiakeMainFrame.getInstance():GetWindow():setVisible(false)
	local pEffect = GetGameUIManager():AddUIEffect(self.m_pEffectWnd, MHSD_UTILS.get_effectpath(10394), false)
	local notify = CGameUImanager:createNotify(self.OnEffectEnd)	
	pEffect:AddNotify(notify)
end

function QuackFoundRare.OnEffectEnd()
	LogInfo("QuackFoundRare OnEffectEnd")
	if not _instance then
		return
	end
	XiakeMainFrame.getInstance():GetWindow():setVisible(true)
	for i = 0, 9 do
		_instance.m_pXiakeBack[i]:setVisible(true)
	end
	_instance.m_fTime = 0
	_instance.m_bOut = false
end

function QuackFoundRare:run(elapse)
	if not self.m_bOut then
		self.m_fTime = self.m_fTime + elapse
		if self.m_fTime >= (10 * outTime) then
			self.m_pXiakeBack[9]:setAlpha(1)
			self.m_fTime = 0
			self.m_bOut = true
			GetGameUIManager():RemoveUIEffect(self.m_pXiakeBack[9])
			GetGameUIManager():AddUIEffect(self.m_pXiakeBack[9], MHSD_UTILS.get_effectpath(10393))
			return
		end
		for i = 0, 9 do 
			if (self.m_fTime >= i * outTime) and (self.m_fTime < (i + 1) * outTime) then
				self.m_pXiakeBack[i]:setAlpha((self.m_fTime - i * outTime) / self.m_fTime)
				if i > 0 then
					self.m_pXiakeBack[i - 1]:setAlpha(1)
				end
				break
			end
		end
	end	
end


return QuackFoundRare
