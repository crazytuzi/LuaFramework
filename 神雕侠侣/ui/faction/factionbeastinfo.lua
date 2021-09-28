require "ui.dialog"


FactionBeastInfo = {}
setmetatable(FactionBeastInfo, Dialog)
FactionBeastInfo.__index = FactionBeastInfo

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function FactionBeastInfo.getInstance()
	print("enter get FactionBeastInfo dialog instance")
    	if not _instance then
    	    	_instance = FactionBeastInfo:new()
    	    	_instance:OnCreate()
    	end
    	
    	return _instance
end

function FactionBeastInfo.getInstanceAndShow()
	print("enter FactionBeastInfo dialog instance show")
    	if not _instance then
       		 _instance = FactionBeastInfo:new()
        	_instance:OnCreate()
	else
		print("set FactionBeastInfo dialog visible")
		_instance:SetVisible(true)
    	end
    
    	return _instance
end

function FactionBeastInfo.getInstanceNotCreate()
	return _instance
end

function FactionBeastInfo.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function FactionBeastInfo.ToggleOpenClose()
	if not _instance then 
		_instance = FactionBeastInfo:new() 
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

function FactionBeastInfo.GetLayoutFileName()
	return "bangpaixunshousecond.layout"
end

function FactionBeastInfo:new()
    	local self = {}
    	self = Dialog:new()
    	setmetatable(self, FactionBeastInfo)

    	return self
end

function FactionBeastInfo:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pHead = winMgr:getWindow("bangpaixunshousecond/up/num/head")
	self.m_pName = winMgr:getWindow("bangpaixunshousecond/up/num/head/name")
	self.m_pTalk = winMgr:getWindow("bangpaixunshousecond/up/talk/txt")
	self.m_pTrain = CEGUI.toProgressBar(winMgr:getWindow("bangpaixunshousecond/up/jindu"))
	self.m_pBeastLevel = winMgr:getWindow("bangpaixunshousecond/up/back/num")
	self.m_pEditbox = CEGUI.toRichEditbox(winMgr:getWindow("bangpaixunshousecond/case/shuo"))
	self.m_pEditbox:setReadOnly(true)
end

function FactionBeastInfo:initData(beastlevel,trainlevel,msglist)
	local showTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cgangbeastshow")
	local record = showTable:getRecorder(beastlevel)
	if record then
		local modelid = record.modelID
		local name = record.name
		self.m_pHead:setProperty("Image", "")
		local wndWidth = self.m_pHead:getPixelSize().width
		local wndHeight = self.m_pHead:getPixelSize().height
    		local Sprite = GetGameUIManager():AddWindowSprite(self.m_pHead, modelid, XiaoPang.XPDIR_BOTTOMRIGHT, wndWidth/2.0, wndHeight-20, false)

		self.m_pName:setText(name)
		self.m_pTrain:setText(trainlevel.."/"..record.LvUptraining)
		self.m_pTrain:setProgress(trainlevel/record.LvUptraining)
	else
		self.m_pHead:setProperty("Image", "")
		self.m_pName:setText("")
		self.m_pTrain:setText("")
	end

	local talkTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cgangbeasttalk")
	local ids = talkTable:getAllID()
	self.m_pTalk:setText(talkTable:getRecorder(math.random(1, #ids)).talk)

	self.m_pBeastLevel:setText("LV:"..beastlevel)
	local guard = require "ui.faction.factionbeastdlg"
	guard:initMsgEditbox(self.m_pEditbox,msglist)
end

return FactionBeastInfo
