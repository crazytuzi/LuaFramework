local Dialog = require "ui.dialog"
local NuQiSkillManager = require "ui.skill.nuqiskillmanager"

local NuQiQueRenDlg = {}
setmetatable(NuQiQueRenDlg, Dialog)
NuQiQueRenDlg.__index = NuQiQueRenDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function NuQiQueRenDlg.getInstance()
    if not _instance then
        _instance = NuQiQueRenDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function NuQiQueRenDlg.getInstanceAndShow()
    if not _instance then
        _instance = NuQiQueRenDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function NuQiQueRenDlg.getInstanceNotCreate()
    return _instance
end

function NuQiQueRenDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function NuQiQueRenDlg.ToggleOpenClose()
	if not _instance then 
		_instance = NuQiQueRenDlg:new() 
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

function NuQiQueRenDlg.GetLayoutFileName()
    return "nuqiqueren.layout"
end

function NuQiQueRenDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_wName = winMgr:getWindow("nuqiqueren/jineng2")
	self.m_wTxt = winMgr:getWindow("nuqiqueren/jineng21")
	self.m_wCaiLiao = winMgr:getWindow("nuqiqueren/cailiao11")
	self.m_wMoney = winMgr:getWindow("nuqiqueren/cailiao112")
	self.m_wOk = CEGUI.Window.toPushButton(winMgr:getWindow("nuqiqueren/ok"))
	self.m_wCancel = CEGUI.Window.toPushButton(winMgr:getWindow("nuqiqueren/cancle"))

	-- subscribe event
	self.m_wOk:subscribeEvent("Clicked", NuQiQueRenDlg.HandleOKBtn, self)
	self.m_wCancel:subscribeEvent("Clicked", NuQiQueRenDlg.HandleCancelBtn, self)

end

------------------- private: -----------------------------------

function NuQiQueRenDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, NuQiQueRenDlg)
    return self
end

function NuQiQueRenDlg:Refresh(skill)
	self.m_Skill = skill or self.m_Skill
	local SkillUpTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cnuqiup")

	-- 技能名字
	self.m_wName:setText(NuQiSkillManager.GetSkillName(self.m_Skill.id, self.m_Skill.level +1))

	-- 技能介绍
	self.m_wTxt:setText(NuQiSkillManager.GetSkillDescription(self.m_Skill.id, self.m_Skill.level+1))

	-- 所需材料
	local function getCailiao(skilltype, currentlevel)
		local allids = SkillUpTable:getDisorderAllID()
		for i,v in ipairs(allids) do
			local skillup = SkillUpTable:getRecorder(v)
			if skillup.type == skilltype and skillup.skilllevel == currentlevel+1 then
				return skillup.itemid, skillup.itemnum, skillup.money
			end
		end
		return nil, nil, nil
	end
	local itemid, itemnum, money = getCailiao(self.m_Skill.skilltype,self.m_Skill.level)
	if itemid and itemnum then
		local itemname = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(itemid).name
		self.m_wCaiLiao:setText(itemname .. "*" .. tostring(itemnum))
	end
	if money then
		self.m_wMoney:setText(tostring(money))
	end
end

function NuQiQueRenDlg:HandleOKBtn(args)
	local CUpgradeSpecialskill = require "protocoldef.knight.gsp.skill.specialskill.cupgradespecialskill"
	local req = CUpgradeSpecialskill.Create()
	req.skillid = self.m_Skill.id
	req.skilltype = self.m_Skill.skilltype
	LuaProtocolManager.getInstance():send(req)
	NuQiQueRenDlg.DestroyDialog()
end

function NuQiQueRenDlg:HandleCancelBtn(args)
	NuQiQueRenDlg.DestroyDialog()
end

return NuQiQueRenDlg
