require "ui.dialog"
JingJieTip = {}
setmetatable(JingJieTip, Dialog)
JingJieTip.__index = JingJieTip

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function JingJieTip.getInstance()
    if not _instance then
        _instance = JingJieTip:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function JingJieTip.getInstanceAndShow()
    if not _instance then
        _instance = JingJieTip:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function JingJieTip.getInstanceNotCreate()
    return _instance
end

function JingJieTip.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function JingJieTip.ToggleOpenClose()
	if not _instance then 
		_instance = JingJieTip:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function JingJieTip.GetLayoutFileName()
    return "quackxiuxingtipstupian.layout"
end
function JingJieTip:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.name = winMgr:getWindow("quackxiuxingtipstupian/name")
    self.info = winMgr:getWindow("quackxiuxingtipstupian/info")
	self.progress = CEGUI.Window.toProgressBar(winMgr:getWindow("quackxiuxingtipstupian/bar"))
    self.progress:setProgress(0)

end

------------------- private: -----------------------------------
function JingJieTip:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, JingJieTip)
    return self
end
function JingJieTip:HandleClicked(args)
    local id = CEGUI.toWindowEventArgs(args).window:getID()
end
function JingJieTip:Process()
 

end

function JingJieTip.SetTip(id,score)
    if not id then return end
    self = JingJieTip.getInstanceAndShow()
    if not self then return  self end

    
    local cfg = require("manager.beanconfigmanager").getInstance():GetTableByName("knight.gsp.npc.cxiakepracticerealmconfig"):getRecorder(id)
     local cfg2 = require("manager.beanconfigmanager").getInstance():GetTableByName("knight.gsp.npc.cxiakepracticerealmconfig"):getRecorder(id+1)
  
    if not cfg then return self end
    if not cfg2 then cfg2 = cfg end
    
    self.info:setText(cfg.guideText)
    if score then
        self.progress:setText(tostring(score) .. "/" .. tostring(cfg2.realmValue))
        self.progress:setProgress(score / cfg2.realmValue)
    end
    self.name:setProperty("HoverImage", "set:MainControl43 image:xiakexiuxing" .. id )
    self.name:setProperty("NormalImage", "set:MainControl43 image:xiakexiuxing" .. id )
    self.name:setProperty("PushedImage", "set:MainControl43 image:xiakexiuxing" .. id )
 
    return self
end




return JingJieTip
