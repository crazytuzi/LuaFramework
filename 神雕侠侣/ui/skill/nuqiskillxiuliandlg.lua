local Dialog = require "ui.dialog"
local NuQiSkillManager = require "ui.skill.nuqiskillmanager"
local SkillType = NuQiSkillManager.SkillType

local NuQiSkillXiuLianDlg = {}
setmetatable(NuQiSkillXiuLianDlg, Dialog)
NuQiSkillXiuLianDlg.__index = NuQiSkillXiuLianDlg

NuQiSkillXiuLianDlg.SKILLBOXNUM = 18
NuQiSkillXiuLianDlg.SKILLTYPENUM = 4

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function NuQiSkillXiuLianDlg.getInstance()
    if not _instance then
        _instance = NuQiSkillXiuLianDlg:new()
        _instance:OnCreate()
    end
    return _instance
end

function NuQiSkillXiuLianDlg.getInstanceAndShow()
    if not _instance then
        _instance = NuQiSkillXiuLianDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    return _instance
end

function NuQiSkillXiuLianDlg.getInstanceNotCreate()
    return _instance
end

function NuQiSkillXiuLianDlg.DestroyDialog()
	if _instance then
		if SkillLable.getInstanceNotCreate() then
			SkillLable.getInstanceNotCreate().DestroyDialog()
		else
			NuQiSkillXiuLianDlg.CloseDialog()
		end 
	end 
end

function NuQiSkillXiuLianDlg.CloseDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function NuQiSkillXiuLianDlg.ToggleOpenClose()
	if not _instance then 
		_instance = NuQiSkillXiuLianDlg:new() 
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

function NuQiSkillXiuLianDlg.GetLayoutFileName()
    return "nuqiteji.layout"
end

function NuQiSkillXiuLianDlg:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_wSkillBoxs = {}
	for i=1, NuQiSkillXiuLianDlg.SKILLBOXNUM do
		self.m_wSkillBoxs[i] = {}
		self.m_wSkillBoxs[i].skill = CEGUI.toSkillBox(winMgr:getWindow("nuqiteji/back3/item" .. tostring(i)))
		self.m_wSkillBoxs[i].skill:setVisible(false)
		self.m_wSkillBoxs[i].skill:SetBackgroundDynamic(true)
		self.m_wSkillBoxs[i].equip = winMgr:getWindow("nuqiteji/zhan" .. tostring(i))
		self.m_wSkillBoxs[i].name = winMgr:getWindow("nuqiteji/back3/item1/txt" .. tostring(i))
	end
	self.m_wSkillType = {}
	for i=1, NuQiSkillXiuLianDlg.SKILLTYPENUM do
		self.m_wSkillType[i] = winMgr:getWindow("nuqiteji/back1/buttom" .. tostring(i))
	end
	self.m_wPoints = CEGUI.Window.toProgressBar(winMgr:getWindow("nuqiteji/back4/bar"))
	self.m_wJuQiDan = winMgr:getWindow("nuqiteji/back4/txt2")
	self.m_wBiGuan = CEGUI.Window.toPushButton(winMgr:getWindow("nuqiteji/back4/button"))

	-- subscribe event
	for i=1, NuQiSkillXiuLianDlg.SKILLBOXNUM do
		self.m_wSkillBoxs[i].skill:setID(i)
		self.m_wSkillBoxs[i].skill:subscribeEvent("MouseClick", NuQiSkillXiuLianDlg.HandleSkillClicked, self)
	end
	self.m_wSkillType[1]:setID(SkillType.GongJi)
	self.m_wSkillType[2]:setID(SkillType.FangYu)
	self.m_wSkillType[3]:setID(SkillType.FuZhu)
	self.m_wSkillType[4]:setID(SkillType.WuShuang)
	for i=1, NuQiSkillXiuLianDlg.SKILLTYPENUM do
		self.m_wSkillType[i]:subscribeEvent("SelectStateChanged", NuQiSkillXiuLianDlg.HandleSkillTypeBtn, self)
	end
	self.m_wBiGuan:subscribeEvent("Clicked", NuQiSkillXiuLianDlg.HandleBiGuanBtn, self)

end

------------------- private: -----------------------------------

function NuQiSkillXiuLianDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, NuQiSkillXiuLianDlg)
	self.m_SkillType = SkillType.GongJi
    return self
end

function NuQiSkillXiuLianDlg:ShowSkill(skilltype)
	self.m_SkillType = skilltype or self.m_SkillType
	local BackgroundImage = BeanConfigManager.getInstance():GetTableByName("knight.gsp.skill.cnuqicolor")
	local skills = NuQiSkillManager.GetSkillsByType(self.m_SkillType)
	for i,v in ipairs(skills) do
		GetGameUIManager():RemoveUIEffect(self.m_wSkillBoxs[i].skill)
		self.m_wSkillBoxs[i].skill:SetImage(GetIconManager():GetImageByID(v.iconid))
		self.m_wSkillBoxs[i].skill:SetBackGroundImage(CEGUI.String("BaseControl1"), CEGUI.String("SkillInCell1"))
		self.m_wSkillBoxs[i].skill:SetAshy(true)
		if v.active then
			GetGameUIManager():AddUIEffect(self.m_wSkillBoxs[i].skill, require "utils.mhsdutils".get_effectpath(10084))
		elseif v.level and v.level > 0 then
			self.m_wSkillBoxs[i].skill:SetAshy(false)
			local color = BackgroundImage:getRecorder(v.level)
			if color then
				self.m_wSkillBoxs[i].skill:SetBackGroundImage(CEGUI.String(color.imageset), CEGUI.String(color.image))
			end
		end
		self.m_wSkillBoxs[i].equip:setVisible(v.inuse)
		self.m_wSkillBoxs[i].name:setText(NuQiSkillManager.GetSkillName(v.id))
		self.m_wSkillBoxs[i].skill:setVisible(true)
	end
	for i=#skills+1, NuQiSkillXiuLianDlg.SKILLBOXNUM do
		self.m_wSkillBoxs[i].skill:setVisible(false)
	end
	self:RefreshJuQiDan()
end

function NuQiSkillXiuLianDlg:RefreshPoints()
	local points = NuQiSkillManager.GetPoints()
	self.m_wPoints:setText(tostring(points) .. "/1000")
	self.m_wPoints:setProgress(points/1000)
end

function NuQiSkillXiuLianDlg:RefreshJuQiDan()
	local juqidan = GetRoleItemManager():GetItemNumByBaseID(39990)
	self.m_wJuQiDan:setText(tostring(juqidan))
end

function NuQiSkillXiuLianDlg:HandleSkillClicked(args)
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	local skills = NuQiSkillManager.GetSkillsByType(self.m_SkillType)
	if self.m_SkillType == SkillType.WuShuang then
		local NuQiJiinWuShuangDlg = require "ui.skill.nuqijiinwushuangdlg"
		NuQiJiinWuShuangDlg.getInstanceAndShow():Refresh(skills[id])
	else
		local NuQiJiinNormalDlg = require "ui.skill.nuqijiinnormaldlg"
		NuQiJiinNormalDlg.getInstanceAndShow():Refresh(skills[id])
	end
end

function NuQiSkillXiuLianDlg:HandleSkillTypeBtn(args)
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	self:ShowSkill(id)
end

function NuQiSkillXiuLianDlg:HandleBiGuanBtn(args)
	if self.m_SkillType == SkillType.WuShuang then
		GetGameUIManager():AddMessageTipById(146153)
		return
	end
	local CLearnSpecialskill = require "protocoldef.knight.gsp.skill.specialskill.clearnspecialskill"
	local req = CLearnSpecialskill.Create()
	req.skilltype = self.m_SkillType
	LuaProtocolManager.getInstance():send(req)
end

return NuQiSkillXiuLianDlg
