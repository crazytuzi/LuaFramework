local Dialog = require "ui.dialog"
local NuQiSkillManager = require "ui.skill.nuqiskillmanager"

local NuQiHuoDeDlg = {}
setmetatable(NuQiHuoDeDlg, Dialog)
NuQiHuoDeDlg.__index = NuQiHuoDeDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function NuQiHuoDeDlg.getInstance()
    if not _instance then
        _instance = NuQiHuoDeDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function NuQiHuoDeDlg.getInstanceAndShow()
    if not _instance then
        _instance = NuQiHuoDeDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function NuQiHuoDeDlg.getInstanceNotCreate()
    return _instance
end

function NuQiHuoDeDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function NuQiHuoDeDlg.ToggleOpenClose()
	if not _instance then 
		_instance = NuQiHuoDeDlg:new() 
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

function NuQiHuoDeDlg.GetLayoutFileName()
    return "nuqihuode.layout"
end

function NuQiHuoDeDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_wSkillIcon = CEGUI.toSkillBox(winMgr:getWindow("nuqihuode/item"))
	self.m_wSkillName = winMgr:getWindow("nuqihuode/txt2")
	self.m_wCloseBtn = CEGUI.Window.toPushButton(winMgr:getWindow("nuqihuode/ok"))

	-- subscribe event
	self.m_wCloseBtn:subscribeEvent("Clicked", NuQiHuoDeDlg.HandleCloseBtn, self)

end

------------------- private: -----------------------------------

function NuQiHuoDeDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, NuQiHuoDeDlg)
    return self
end

function NuQiHuoDeDlg:Refresh(skillid)
	self.m_SkillId = skillid or self.m_SkillId
	if not self.m_SkillId then
		return
	end
	local skill = NuQiSkillManager.GetAllSkills()[self.m_SkillId]

	-- 设置图标
	self.m_wSkillIcon:SetImage(GetIconManager():GetImageByID(skill.iconid))

	-- 技能名字
	self.m_wSkillName:setText(NuQiSkillManager.GetSkillName(skill.id, 0))

end

function NuQiHuoDeDlg:HandleCloseBtn(args)
	NuQiHuoDeDlg.DestroyDialog()
end

return NuQiHuoDeDlg
