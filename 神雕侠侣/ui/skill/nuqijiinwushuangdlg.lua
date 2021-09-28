local Dialog = require "ui.dialog"
local NuQiSkillManager = require "ui.skill.nuqiskillmanager"

local NuQiJiinWuShuangDlg = {}
setmetatable(NuQiJiinWuShuangDlg, Dialog)
NuQiJiinWuShuangDlg.__index = NuQiJiinWuShuangDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function NuQiJiinWuShuangDlg.getInstance()
    if not _instance then
        _instance = NuQiJiinWuShuangDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function NuQiJiinWuShuangDlg.getInstanceAndShow()
    if not _instance then
        _instance = NuQiJiinWuShuangDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function NuQiJiinWuShuangDlg.getInstanceNotCreate()
    return _instance
end

function NuQiJiinWuShuangDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function NuQiJiinWuShuangDlg.ToggleOpenClose()
	if not _instance then 
		_instance = NuQiJiinWuShuangDlg:new() 
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

function NuQiJiinWuShuangDlg.GetLayoutFileName()
    return "nuqijiin.layout"
end

function NuQiJiinWuShuangDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_wSkillIcon = CEGUI.toSkillBox(winMgr:getWindow("nuqijiin/item"))
	self.m_wSkillEquipIcon = winMgr:getWindow("nuqijiin/item/zhan")
	self.m_wSkillName = winMgr:getWindow("nuqijiin/txt1")
	self.m_wNuQi = winMgr:getWindow("nuqijiin/txt2/num")
	self.m_wTxt = winMgr:getWindow("nuqijiin/txtback/txt")
	self.m_wUpgrade = CEGUI.Window.toPushButton(winMgr:getWindow("nuqijiin/up"))
	self.m_wEquip = CEGUI.Window.toPushButton(winMgr:getWindow("nuqijiin/cancle"))
	--self.m_wCloseBtn = CEGUI.Window.toPushButton(winMgr:getWindow("nuqijiin/closebn"))
	self.m_wpreSkills = {}
	for i=1, 6 do
		self.m_wpreSkills[i] = winMgr:getWindow("nuqijiin/skill" .. tostring(i))
	end

	-- set window
	self.m_wSkillIcon:SetBackgroundDynamic(true)

	-- subscribe event
	self.m_wUpgrade:subscribeEvent("Clicked", NuQiJiinWuShuangDlg.HandleUpgradeBtn, self)
	self.m_wEquip:subscribeEvent("Clicked", NuQiJiinWuShuangDlg.HandleEquipBtn, self)
	--self.m_wCloseBtn:subscribeEvent("Clicked", NuQiJiinWuShuangDlg.HandleCloseBtn, self)

end

------------------- private: -----------------------------------

function NuQiJiinWuShuangDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, NuQiJiinWuShuangDlg)
    return self
end

function NuQiJiinWuShuangDlg:SetPreSkill(wnd, skillid)
	local SkillTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cnuqi")

	local allskills = NuQiSkillManager.GetAllSkills()
	if  allskills[skillid] then
		local name = SkillTable:getRecorder(skillid).name or "skill not found : T"
		wnd:setText(name)
		if allskills[skillid].level > 0 then
			wnd:setProperty("BorderColour", "FF5F4100")
			wnd:setProperty("TextColours","tl:FFFFFEF1 tr:FFFFFEF1 bl:FFF4D751 br:FFF4D751")
			wnd:setProperty("BorderEnable", "True")
		else
			wnd:setProperty("BorderColour", "FF003454")
			wnd:setProperty("TextColours","tl:FF1A2E4F tr:FF1A2E4F bl:FF1A2E4F br:FF1A2E4F")
			wnd:setProperty("BorderEnable", "False")
		end
	else
		wnd:setText("skill not found!")
	end
	wnd:setVisible(true)
end

function NuQiJiinWuShuangDlg:Refresh(skill)
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

	-- 前置技能
	local preskill = StringBuilder.Split(self.m_Skill.preskill, ",")
	for i=1, 6 do
		if preskill[i] then
			self:SetPreSkill(self.m_wpreSkills[i], tonumber(preskill[i]))
		else
			self.m_wpreSkills[i]:setVisible(false)
		end
	end
end

function NuQiJiinWuShuangDlg:HandleUpgradeBtn(args)
--[[ 服务器已经给提示了，客户端不需要了
	if self.m_Skill.level >= NuQiSkillManager.GetSkillMaxLevel(self.m_Skill.id) then
		GetGameUIManager():AddMessageTipById(146152)
		return
	end
]]
	if self.m_Skill.active == false and self.m_Skill.level == 0 then
		GetGameUIManager():AddMessageTipById(146141)
		return
	end
	local NuQiQueRenDlg = require "ui.skill.nuqiquerendlg"
	NuQiQueRenDlg.getInstanceAndShow():Refresh(self.m_Skill)
end

function NuQiJiinWuShuangDlg:HandleEquipBtn(args)
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

function NuQiJiinWuShuangDlg:HandleCloseBtn(args)
	NuQiJiinWuShuangDlg.DestroyDialog()
end

return NuQiJiinWuShuangDlg
