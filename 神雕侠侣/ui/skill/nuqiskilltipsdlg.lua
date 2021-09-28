local Dialog = require "ui.dialog"
local NuQiSkillManager = require "ui.skill.nuqiskillmanager"

local NuQiSkillTipsDlg = {}
setmetatable(NuQiSkillTipsDlg, Dialog)
NuQiSkillTipsDlg.__index = NuQiSkillTipsDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function NuQiSkillTipsDlg.getInstance()
    if not _instance then
        _instance = NuQiSkillTipsDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function NuQiSkillTipsDlg.getInstanceAndShow()
    if not _instance then
        _instance = NuQiSkillTipsDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function NuQiSkillTipsDlg.getInstanceNotCreate()
    return _instance
end

function NuQiSkillTipsDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function NuQiSkillTipsDlg.ToggleOpenClose()
	if not _instance then 
		_instance = NuQiSkillTipsDlg:new() 
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

function NuQiSkillTipsDlg.GetLayoutFileName()
    return "skilltipsnuqidialog.layout"
end

function NuQiSkillTipsDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_wSkillIcon = CEGUI.toSkillBox(winMgr:getWindow("skilltipsnuqidialog/skill"))
	self.m_wSkillName = winMgr:getWindow("skilltipsnuqidialog/name")
	self.m_wTxt = CEGUI.Window.toRichEditbox(winMgr:getWindow("skilltipsnuqidialog/richeditbox"))

end

------------------- private: -----------------------------------

function NuQiSkillTipsDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, NuQiSkillTipsDlg)
    return self
end

function NuQiSkillTipsDlg:Refresh(skillid)
	self.m_Skill = NuQiSkillManager.GetAllSkills()[skillid] or self.m_Skill
	local SkillTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cnuqi")

	-- 设置图标
	self.m_wSkillIcon:SetImage(GetIconManager():GetImageByID(self.m_Skill.iconid))

	-- 是否蒙灰
	self.m_wSkillIcon:SetAshy(self.m_Skill.level == 0)

	-- 技能名字
	self.m_wSkillName:setText(NuQiSkillManager.GetSkillName(self.m_Skill.id, self.m_Skill.level))

	-- 技能介绍
	self.m_wTxt:Clear()
	self.m_wTxt:AppendText(CEGUI.String(NuQiSkillManager.GetSkillDescription(self.m_Skill.id, self.m_Skill.level)))
	self.m_wTxt:Refresh()
	self.m_wTxt:HandleTop()

end

return NuQiSkillTipsDlg
