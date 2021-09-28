local Dialog = require "ui.dialog"

PetExchangeDlg = {}
setmetatable(PetExchangeDlg, Dialog)
PetExchangeDlg.__index = PetExchangeDlg
------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function PetExchangeDlg.getInstance()
	print("enter get petexchangedlg dialog instance")
    if not _instance then
        _instance = PetExchangeDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function PetExchangeDlg.getInstanceAndShow()
	print("enter petexchangedlg dialog instance show")
    if not _instance then
        _instance = PetExchangeDlg:new()
        _instance:OnCreate()
	else
		print("set petexchangedlg dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function PetExchangeDlg.getInstanceNotCreate()
    return _instance
end

function PetExchangeDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function PetExchangeDlg.ToggleOpenClose()
	if not _instance then 
		_instance = PetExchangeDlg:new() 
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

function PetExchangeDlg.GetLayoutFileName()
    return "petexchange.layout"
end

function PetExchangeDlg:OnCreate()
	print("petexchangedlg dialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_pPetList = CEGUI.Window.toScrollablePane(winMgr:getWindow("petexchange/left/petlist"))
	self.m_PetInfo = {}
	self.m_PetInfo.Skill = {}
	for i=1, 4 do
		self.m_PetInfo.Skill[i] = CEGUI.Window.toSkillBox(winMgr:getWindow("petexchange/right1/Skill" .. i))
	end
	self.m_PetInfo.Name = winMgr:getWindow("petexchange/right/name")
	self.m_PetInfo.Sprite = winMgr:getWindow("petexchange/right/Item")
	self.m_PetInfo.Type = winMgr:getWindow("petexchange/right/style")
	self.m_PetInfo.Text = winMgr:getWindow("petexchange/right/info/text")
	self.m_PetInfo.JingPoNum = CEGUI.Window.toRichEditbox(winMgr:getWindow("petexchange/right/info/num"))
	self.m_PetInfo.Exchange = CEGUI.Window.toPushButton(winMgr:getWindow("petexchange/right/info/exchange"))
	self.m_PetInfo.ShuXing = {}
	self.m_PetInfo.ShuXing.WaiGong_max = winMgr:getWindow("petexchange/right/waigongmax")
	self.m_PetInfo.ShuXing.WaiGong_min = winMgr:getWindow("petexchange/right/waigongmin")
	self.m_PetInfo.ShuXing.FangYu_max  = winMgr:getWindow("petexchange/right/fangyumax")
	self.m_PetInfo.ShuXing.FangYu_min  = winMgr:getWindow("petexchange/right/fangyumin")
	self.m_PetInfo.ShuXing.TiLi_max    = winMgr:getWindow("petexchange/right/tilimax")
	self.m_PetInfo.ShuXing.TiLi_min    = winMgr:getWindow("petexchange/right/tilimin")
	self.m_PetInfo.ShuXing.NeiGong_max = winMgr:getWindow("petexchange/right/neigongmax")
	self.m_PetInfo.ShuXing.NeiGong_min = winMgr:getWindow("petexchange/right/neigongmin")
	self.m_PetInfo.ShuXing.SuDu_max    = winMgr:getWindow("petexchange/right/sudumax")
	self.m_PetInfo.ShuXing.SuDu_min    = winMgr:getWindow("petexchange/right/sudumin")

    -- subscribe event
    self.m_PetInfo.Exchange:subscribeEvent("Clicked", PetExchangeDlg.HandleExchangeBtn, self) 
	for i=1, 4 do
		self.m_PetInfo.Skill[i]:subscribeEvent("MouseClick", PetExchangeDlg.HandleSkillBoxClick, self)
	end

	self.m_PetInfo.Sprite:getGeometryBuffer():setRenderEffect(CGameUImanager:createXPRenderEffect(0, PetExchangeDlg.performPostRenderFunctions))

	print("petexchangedlg dialog oncreate end")
	self:RefreshList()
end

------------------- private: -----------------------------------

function PetExchangeDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, PetExchangeDlg)
	self.m_cells = {}
    return self
end

function PetExchangeDlg:RefreshList()
	local PetExchangeDlgCell = require "ui.pet.petexchangedlgcell"
	for k,v in pairs(self.m_cells) do
		v:OnClose()
	end
	self.m_cells = {}

	local ShenShouTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.pet.cshenshouconfig")
	local ShenShouBaseTable = knight.gsp.pet.GetCPetAttrTableInstance()
	local ShapeTable = knight.gsp.npc.GetCNpcShapeTableInstance()

	local ShenShouIds = ShenShouTable:getAllID()
	for i,v in ipairs(ShenShouIds) do
		local info = ShenShouBaseTable:getRecorder(ShenShouTable:getRecorder(v).shenshouid)
		local shape = ShapeTable:getRecorder(info.modelid)
		local icon = GetIconManager():GetImagePathByID(shape.headID):c_str()

		local cell = PetExchangeDlgCell.CreateNewDlg(self.m_pPetList, v)
		cell:SetInfo(icon, info.name, info.chengzhangleixing)
		self.m_cells[v] = cell

		local y = cell.m_pWnd:getPixelSize().height*(i-1)+1
		cell.m_pWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,1),CEGUI.UDim(0,y)))
	end
	self:SetInfo(ShenShouIds[1])
end

-- 二次确认的ok按钮
function PetExchangeDlg:HandleConfirmOK(arg)
	LogInfo("PetExchangeDlg:HandleConfirmOK : " .. self.m_PetInfo.Id)
	local CExchangeShenshou = require "protocoldef.knight.gsp.pet.cexchangeshenshou"
	local req = CExchangeShenshou.Create()
	req.id = self.m_PetInfo.Id
	LuaProtocolManager.getInstance():send(req)
	GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end

-- 兑换按钮
function PetExchangeDlg:HandleExchangeBtn(arg)
	local ShenShou = BeanConfigManager.getInstance():GetTableByName("knight.gsp.pet.cshenshouconfig"):getRecorder(self.m_PetInfo.Id)
	if GetRoleItemManager():GetItemNumByBaseID(39346) < ShenShou.needjingpo then
		GetGameUIManager():AddMessageTipById(145475)
		return true
	end
	local ShenShouBase = knight.gsp.pet.GetCPetAttrTableInstance():getRecorder(ShenShou.shenshouid)
	local strBuilder = StringBuilder:new()
	strBuilder:Set("parameter1", ShenShou.needjingpo)
	strBuilder:Set("parameter2", ShenShouBase.name)
	local str = strBuilder:GetString(MHSD_UTILS.get_msgtipstring(145474))
	GetMessageManager():AddConfirmBox(eConfirmNormal, str, PetExchangeDlg.HandleConfirmOK, self, CMessageManager.HandleDefaultCancelEvent,CMessageManager)
	strBuilder:delete()
	return true
end

-- 技能的提示消息
function PetExchangeDlg:HandleSkillBoxClick(arg)
	local e = CEGUI.toWindowEventArgs(arg)
	local id = e.window:getID()
	LogInfo("PetExchangeDlg:HandleSkillBoxClick : " .. id)
--	CSkillBoxControl:HandleShowSkilltips(id, -1)
	if id ~= 0 then
		PetSkillTips.getSingletonDialogAndShow():SetPetkeyAndSkillid(-1, id)
	end
	return true
end

function PetExchangeDlg:SetInfo(id)
	LogInfo("PetExchangeDlg:SetInfo")
	if self.m_PetInfo.Id then
		self.m_cells[self.m_PetInfo.Id]:SetLight(false)
	end
	self.m_PetInfo.Id = id
	self.m_cells[self.m_PetInfo.Id]:SetLight(true)
	local ShenShou = BeanConfigManager.getInstance():GetTableByName("knight.gsp.pet.cshenshouconfig"):getRecorder(self.m_PetInfo.Id)
	local ShenShouBase = knight.gsp.pet.GetCPetAttrTableInstance():getRecorder(ShenShou.shenshouid)
	local SkillConfigTable = knight.gsp.skill.GetCPetSkillConfigTableInstance()
	self.m_PetInfo.Name:setText(ShenShouBase.name)
	self.m_PetInfo.Type:setText(ShenShouBase.chengzhangleixing)
	self.m_PetInfo.Text:setText(ShenShou.des)
	self.m_PetInfo.ShuXing.WaiGong_min:setText(ShenShouBase.attackaptmin)
	self.m_PetInfo.ShuXing.WaiGong_max:setText(ShenShouBase.attackaptmin)
	self.m_PetInfo.ShuXing.FangYu_min:setText(ShenShouBase.defendaptmin)
	self.m_PetInfo.ShuXing.FangYu_max:setText(ShenShouBase.defendaptmin)
	self.m_PetInfo.ShuXing.TiLi_min:setText(ShenShouBase.phyforceaptmin)
	self.m_PetInfo.ShuXing.TiLi_max:setText(ShenShouBase.phyforceaptmin)
	self.m_PetInfo.ShuXing.NeiGong_min:setText(ShenShouBase.magicaptmin)
	self.m_PetInfo.ShuXing.NeiGong_max:setText(ShenShouBase.magicaptmin)
	self.m_PetInfo.ShuXing.SuDu_min:setText(ShenShouBase.speedaptmin)
	self.m_PetInfo.ShuXing.SuDu_max:setText(ShenShouBase.speedaptmin)
	LogInfo("ShenShouBase.skillid:size() = " .. ShenShouBase.skillid:size())
	for i=0, ShenShouBase.skillid:size()-1 do
		local skillinfo = SkillConfigTable:getRecorder(ShenShouBase.skillid[i])
		if skillinfo.id ~= -1 then
			CSkillBoxControl:GetInstance():SetSkillInfo(self.m_PetInfo.Skill[i+1], ShenShouBase.skillid[i])
			self.m_PetInfo.Skill[i+1]:setID(ShenShouBase.skillid[i])
			local bkimageset = CEGUI.String("BaseControl"..(math.floor((skillinfo.color-1)/4)+1))
			local bkimage = CEGUI.String("SkillInCell"..skillinfo.color)
			self.m_PetInfo.Skill[i+1]:SetBackGroundImage(bkimageset, bkimage)
		end
	end
	for i=ShenShouBase.skillid:size()+1, 4 do
		self.m_PetInfo.Skill[i]:setID(0)
		self.m_PetInfo.Skill[i]:SetBackGroundImage(CEGUI.String("BaseControl1"), CEGUI.String("SkillInCell1"))
		CSkillBoxControl:GetInstance():ClearSkillInfo(self.m_PetInfo.Skill[i], false)
	end
	self:RefreshSprite(self.m_PetInfo.Sprite, ShenShouBase.modelid)
	self:RefreshShenShouJingPo()
end

function PetExchangeDlg:RefreshShenShouJingPo()
	local ShenShou = BeanConfigManager.getInstance():GetTableByName("knight.gsp.pet.cshenshouconfig"):getRecorder(self.m_PetInfo.Id)
	local color = "ff00ffff"
	local jingpo = GetRoleItemManager():GetItemNumByBaseID(39346)
	if jingpo < ShenShou.needjingpo then
		color = "ffff0000"
	end
	local text = "<T t=\"" .. ShenShou.needjingpo .. "/\"></T><T t=\"" .. jingpo .. "\" c=\"" .. color .. "\"></T>"
	LogInfo("PetExchangeDlg:RefreshShenShouJingPo : " .. text)
	self.m_PetInfo.JingPoNum:Clear()
	self.m_PetInfo.JingPoNum:AppendParseText(CEGUI.String(text))
	self.m_PetInfo.JingPoNum:Refresh()
end

function PetExchangeDlg.performPostRenderFunctions()
	if PetExchangeDlg.getInstanceNotCreate() then
		PetExchangeDlg.getInstanceNotCreate():HandleDrawPetSprite()
	end
end

function PetExchangeDlg:HandleDrawPetSprite()
	if self.m_PetSprite then
		local pt = self.m_PetInfo.Sprite:GetScreenPosOfCenter()
		local wndHeight = self.m_PetInfo.Sprite:getPixelSize().height
		local loc = XiaoPang.CPOINT(pt.x, pt.y+wndHeight/3.0)
		self.m_PetSprite:SetUILocation(loc)
		self.m_PetSprite:RenderUISprite()
	end
end

function PetExchangeDlg:RefreshSprite(wnd, shapeid)
	if self.m_PetSprite then
		if self.m_PetSprite:GetModelID() ~= shapeid then
			self.m_PetSprite:SetModel(shapeid)
		end
	else
		self.m_PetSprite = CUISprite:new(shapeid)
	end

	local pt = wnd:GetScreenPosOfCenter()
	local wndHeight = wnd:getPixelSize().height
	local loc = XiaoPang.CPOINT(pt.x, pt.y+wndHeight/3.0)
	self.m_PetSprite:SetUILocation(loc)
	self.m_PetSprite:SetUIDirection(XiaoPang.XPDIR_BOTTOMRIGHT)
end

return PetExchangeDlg
