local Dialog = require "ui.dialog"
local NuQiSkillManager = require "ui.skill.nuqiskillmanager"

local NuQiJiinNormalDlg = {}
setmetatable(NuQiJiinNormalDlg, Dialog)
NuQiJiinNormalDlg.__index = NuQiJiinNormalDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function NuQiJiinNormalDlg.getInstance()
    if not _instance then
        _instance = NuQiJiinNormalDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function NuQiJiinNormalDlg.getInstanceAndShow()
    if not _instance then
        _instance = NuQiJiinNormalDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function NuQiJiinNormalDlg.getInstanceNotCreate()
    return _instance
end

function NuQiJiinNormalDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function NuQiJiinNormalDlg.ToggleOpenClose()
	if not _instance then 
		_instance = NuQiJiinNormalDlg:new() 
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

function NuQiJiinNormalDlg.GetLayoutFileName()
    return "nuqijiin1.layout"
end

function NuQiJiinNormalDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_wSkillIcon = CEGUI.toSkillBox(winMgr:getWindow("nuqijiin1/item"))
	self.m_wSkillEquipIcon = winMgr:getWindow("nuqijiin1/item/zhan")
	self.m_wSkillName = winMgr:getWindow("nuqijiin1/txt1")
	self.m_wNuQi = winMgr:getWindow("nuqijiin1/txt2/num")
	self.m_wTxt = winMgr:getWindow("nuqijiin1/txtback/txt")
	self.m_wUpgrade = CEGUI.Window.toPushButton(winMgr:getWindow("nuqijiin1/up"))
	self.m_wEquip = CEGUI.Window.toPushButton(winMgr:getWindow("nuqijiin1/cancle"))
	--self.m_wCloseBtn = CEGUI.Window.toPushButton(winMgr:getWindow("nuqijiin1/closebn"))

	-- set window
	self.m_wSkillIcon:SetBackgroundDynamic(true)

	-- subscribe event
	self.m_wUpgrade:subscribeEvent("Clicked", NuQiJiinNormalDlg.HandleUpgradeBtn, self)
	self.m_wEquip:subscribeEvent("Clicked", NuQiJiinNormalDlg.HandleEquipBtn, self)
	--self.m_wCloseBtn:subscribeEvent("Clicked", NuQiJiinNormalDlg.HandleCloseBtn, self)

end

------------------- private: -----------------------------------

function NuQiJiinNormalDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, NuQiJiinNormalDlg)
    return self
end

function NuQiJiinNormalDlg:Refresh(skill)
	self.m_Skill = skill or self.m_Skill
	local SkillTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cnuqi")
	local BackgroundImageTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cnuqicolor")

	-- 设置背景颜色
	local color = BackgroundImageTable:getRecorder(self.m_Skill.level)
	if color then
		self.m_wSkillIcon:SetBackGroundImage(CEGUI.String(color.imageset), CEGUI.String(color.image))
	else
		self.m_wSkillIcon:SetBackGroundImage(CEGUI.String("BaseControl1"), CEGUI.String("SkillInCell1"))
	end

	-- 设置图标
	self.m_wSkillIcon:SetImage(GetIconManager():GetImageByID(self.m_Skill.iconid))

	-- 是否蒙灰
	self.m_wSkillIcon:SetAshy(self.m_Skill.level == 0)

	-- 是否有特效
	if self.m_Skill.active then
		GetGameUIManager():AddUIEffect(self.m_wSkillIcon, require "utils.mhsdutils".get_effectpath(10084))
	else
		GetGameUIManager():RemoveUIEffect(self.m_wSkillIcon)
	end

	-- 是否装备
	self.m_wSkillEquipIcon:setVisible(self.m_Skill.inuse)
	if self.m_Skill.inuse then
		self.m_wEquip:setText(MHSD_UTILS.get_resstring(3140))
	else
		self.m_wEquip:setText(MHSD_UTILS.get_resstring(3139))
	end

	-- 技能名字
	self.m_wSkillName:setText(NuQiSkillManager.GetSkillName(self.m_Skill.id, self.m_Skill.level))

	-- 消耗怒气
	local nuqi = SkillTable:getRecorder(self.m_Skill.id)
	if nuqi then
		self.m_wNuQi:setText(tostring(nuqi.consumption))
	end

	-- 技能介绍
	self.m_wTxt:setText(NuQiSkillManager.GetSkillDescription(self.m_Skill.id, self.m_Skill.level))

end

function NuQiJiinNormalDlg:HandleUpgradeBtn(args)
--[[ 服务器已经给提示了，客户端不需要了
	if self.m_Skill.level >= NuQiSkillManager.GetSkillMaxLevel(self.m_Skill.id) then
		GetGameUIManager():AddMessageTipById(146152)
		return
	end
]]
	if self.m_Skill.level == 0 then
		GetGameUIManager():AddMessageTipById(146154)
		return
	end
	local NuQiQueRenDlg = require "ui.skill.nuqiquerendlg"
	NuQiQueRenDlg.getInstanceAndShow():Refresh(self.m_Skill)
end

function NuQiJiinNormalDlg:HandleEquipBtn(args)
	if self.m_Skill.level == 0 then
		GetGameUIManager():AddMessageTipById(146155)
		return
	end
	local CChangeSpecialskill = require "protocoldef.knight.gsp.skill.specialskill.cchangespecialskill"
	local req = CChangeSpecialskill.Create()
	req.skillid = self.m_Skill.id
	if self.m_Skill.inuse then
		req.opertype = 2
	else
		req.opertype = 1
	end
	LuaProtocolManager.getInstance():send(req)
end

function NuQiJiinNormalDlg:HandleCloseBtn(args)
	NuQiJiinNormalDlg.DestroyDialog()
end

return NuQiJiinNormalDlg
