require "ui.dialog"
GuMuMiJingBtn = {}
setmetatable(GuMuMiJingBtn, Dialog)
GuMuMiJingBtn.__index = GuMuMiJingBtn

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function GuMuMiJingBtn.getInstance()
    if not _instance then
        _instance = GuMuMiJingBtn:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function GuMuMiJingBtn.getInstanceAndShow()
    if not _instance then
        _instance = GuMuMiJingBtn:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function GuMuMiJingBtn.getInstanceNotCreate()
    return _instance
end

function GuMuMiJingBtn.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function GuMuMiJingBtn.ToggleOpenClose()
	if not _instance then 
		_instance = GuMuMiJingBtn:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end



function GuMuMiJingBtn.GetLayoutFileName()
    return "gumumijingcell.layout"
end
function GuMuMiJingBtn:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.button = CEGUI.Window.toPushButton(winMgr:getWindow("gumumijingcell/imagebutton"))
	self.button:subscribeEvent("Clicked",GuMuMiJingBtn.HandleClicked,self)
	self.tick = 0

end

------------------- private: -----------------------------------
function GuMuMiJingBtn:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, GuMuMiJingBtn)
    return self
end
function GuMuMiJingBtn:process(args)
    self.left = args
end
function GuMuMiJingBtn:HandleClicked(args)
   require("ui.gumumijing.gumumijingdlg").getInstanceAndShow()
end
function GuMuMiJingBtn:run(delta)
	if not self.left then return end
	if self.left > 0 then
		self.tick = self.tick + delta
		if self.tick >= 1000 then
			self.tick = self.tick - 1000
			self.left = self.left - 1000

			local gumumijingdlg = require("ui.gumumijing.gumumijingdlg").getInstanceNotCreate()
			if gumumijingdlg then
				if  not gumumijingdlg.left then
					gumumijingdlg.left = 60
				end
                if gumumijingdlg.left >= 0 then
                    gumumijingdlg:setDownCountText(gumumijingdlg.left)
                    gumumijingdlg.left = gumumijingdlg.left - 1
                else
                    gumumijingdlg.DestroyDialog()
                end
			end
		end
	else
		self.left = nil
		if require("ui.gumumijing.gumumijingdlg").getInstanceNotCreate() then
			require("ui.gumumijing.gumumijingdlg").getInstanceNotCreate():DestroyDialog()
		else
			require("ui.gumumijing.gumumijingdlg"):GetAward(nil,3)
		end
		self.DestroyDialog()
	end
end
return GuMuMiJingBtn
