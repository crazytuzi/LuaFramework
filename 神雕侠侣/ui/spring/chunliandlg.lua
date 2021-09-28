require "ui.dialog"

ChunLianDlg = {}
setmetatable(ChunLianDlg, Dialog)
ChunLianDlg.__index = ChunLianDlg 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function ChunLianDlg.getInstance()
    if not _instance then
        _instance = ChunLianDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function ChunLianDlg.getInstanceAndShow()
    if not _instance then
        _instance = ChunLianDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end

    return _instance
end

function ChunLianDlg.getInstanceNotCreate()
    return _instance
end

function ChunLianDlg.DestroyDialog()
	if _instance then
		_instance:OnClose() 
		_instance = nil
	end
end

function ChunLianDlg.ToggleOpenClose()
	if not _instance then 
		_instance = ChunLianDlg:new() 
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

function ChunLianDlg.GetLayoutFileName()
    return "chunliandig.layout"
end

function ChunLianDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ChunLianDlg)

    return self
end

function ChunLianDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()

    -- get windows
    self.m_txtRight = winMgr:getWindow("chunliandig/txt1")
    self.m_txtLeft = winMgr:getWindow("chunliandig/txt2")    

end

function ChunLianDlg:ShowText()
    local randomID = math.random(7)
    local chunlianID = randomID * 2 + 145507

    self.m_txtRight:setText(MHSD_UTILS.get_msgtipstring(chunlianID))
    self.m_txtLeft:setText(MHSD_UTILS.get_msgtipstring(chunlianID+1))

    if not GetPlayRoseEffecstManager() then 
        CPlayRoseEffecst:NewInstance()
    end
    if GetPlayRoseEffecstManager() then
        GetPlayRoseEffecstManager():PlayLevelUpEffect(10409, 0) 
    end
end

return ChunLianDlg
