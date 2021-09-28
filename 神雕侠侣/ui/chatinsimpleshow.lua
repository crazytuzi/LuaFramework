require "ui.dialog"
require "utils.mhsdutils"


ChatInSimpleShow = {}
setmetatable(ChatInSimpleShow, Dialog)
ChatInSimpleShow.__index = ChatInSimpleShow

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ChatInSimpleShow.getInstance()
	LogInfo("enter get chatinsimpleshow instance")
    if not _instance then
        _instance = ChatInSimpleShow:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ChatInSimpleShow.getInstanceAndShow()
	LogInfo("enter chatinsimpleshow instance show")
    if not _instance then
        _instance = ChatInSimpleShow:new()
        _instance:OnCreate()
	else
		LogInfo("set chatinsimpleshow visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ChatInSimpleShow.getInstanceNotCreate()
    return _instance
end

function ChatInSimpleShow.DestroyDialog()
	if _instance then 
		LogInfo("destroy chatinsimpleshow")
		_instance:OnClose()
		_instance = nil
	end
end

function ChatInSimpleShow.ToggleOpenClose()
	if not _instance then 
		_instance = ChatInSimpleShow:new() 
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

function ChatInSimpleShow.GetLayoutFileName()
    return "chatinsimpleshow.layout"
end

function ChatInSimpleShow:OnCreate()
	LogInfo("chatinsimpleshow oncreate begin")
    Dialog.OnCreate(self)


	LogInfo("chatinsimpleshow oncreate end")

end

------------------- private: -----------------------------------


function ChatInSimpleShow:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ChatInSimpleShow)
    return self
end

return ChatInSimpleShow
