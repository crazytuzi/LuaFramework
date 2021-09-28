PetAmuletTips = {}

setmetatable(PetAmuletTips, Dialog);
PetAmuletTips.__index = PetAmuletTips;

local _instance;

function PetAmuletTips.getInstance()
	if _instance == nil then
		_instance = PetAmuletTips:new();
		_instance:OnCreate();
	end

	return _instance;
end

function PetAmuletTips.getInstanceNotCreate()
	return _instance;
end

function PetAmuletTips.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
		LogInfo("PetAmuletTips DestroyDialog")
	end
end

function PetAmuletTips.getInstanceAndShow()
    if not _instance then
        _instance = PetAmuletTips:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function PetAmuletTips.ToggleOpenClose()
	if not _instance then 
		_instance = PetAmuletTips:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function PetAmuletTips.GetLayoutFileName()
	return "petskillhufutipsrich.layout";
end

function PetAmuletTips:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, PetAmuletTips);

	return zf;
end

------------------------------------------------------------------------------

function PetAmuletTips:OnCreate()
	LogInfo("PetAmuletTips OnCreate ")
	Dialog.OnCreate(self);

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_strengthenBtn = winMgr:getWindow("petskilltipsrich/use")
	self.m_deleteBtn = winMgr:getWindow("petskilltipsrich/delete")

	self.m_strengthenBtn:subscribeEvent("MouseClick", self.HandleStrengthenClicked, self)
	self.m_deleteBtn:subscribeEvent("MouseClick", self.HandleDeleteClicked, self)

	-- self.m_tipsContainer = CEGUI.toRichEditbox(winMgr:getWindow("petskilltipsrich/back/description"))

	self.m_itemcell = CEGUI.toItemCell(winMgr:getWindow("petskilltipsrich/back/icon"))
	self.m_nameText = winMgr:getWindow("petskilltipsrich/name")
	self.m_expText = winMgr:getWindow("petskilltipsrich/back/info1")
	self.m_effectNow = winMgr:getWindow("petskilltipsrich/back/info2")
	self.m_effectNext = winMgr:getWindow("petskilltipsrich/back/info3")
	self.m_diaowenText = winMgr:getWindow("petskilltipsrich/back/info4")
	self.m_description = winMgr:getWindow("petskilltipsrich/back/txt4")

	self:GetWindow():setAlwaysOnTop(true)

	LogInfo("PetAmuletTips OnCreate finish")
end

function PetAmuletTips:SetItem( amuletid, diaowenid, exp, cellid, diaowenNum)
	self.m_amuletid = amuletid
	self.m_cellid = cellid
	self.m_diaowenid = diaowenid
	self.m_exp = exp

	local itembean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(amuletid)
	local record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cpetamulet"):getRecorder(amuletid)
	local expStr = tostring(exp).."/"..tostring(record.needexp)
	local effect = record.xiaoguomiaoshu
	local emptyStr = MHSD_UTILS.get_resstring(1663)
	
	local effectNext = emptyStr
	if record.nextamulet ~= 0 then
		local recordNext = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cpetamulet"):getRecorder(record.nextamulet)
		effectNext = recordNext.xiaoguomiaoshu
	end

	local diaowenStr = emptyStr
	if diaowenid ~= 0 then
		local dw = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cpetglyoh"):getRecorder(diaowenid)
		diaowenStr = dw.name.."("..tostring(diaowenNum).."/"..tostring(dw.num)..")"
	end
	self.m_diaowenstr = diaowenStr

	self.m_itemcell:SetImage(GetIconManager():GetItemIconByID(itembean.icon))
	self.m_nameText:setText(record.amuletname)
	self.m_expText:setText(expStr)
	self.m_effectNow:setText(effect)
	self.m_effectNext:setText(effectNext)
	self.m_diaowenText:setText(diaowenStr)
	self.m_description:setText(record.amuletdescription)

end

function PetAmuletTips:SetPetId( petid )
	self.m_petid = petid
end

function PetAmuletTips:HandleStrengthenClicked()
	require "ui.pet.petamuletcompositedlg"
	PetAmuletCompositeDlg:getInstanceAndShow():SetMainAmulet(self.m_amuletid, self.m_cellid, self.m_petid, self.m_diaowenid, self.m_exp)
	PetAmuletTips.DestroyDialog()
end

function PetAmuletTips:HandleDeleteClicked()
	local p = require "protocoldef.knight.gsp.pet.cdeduckpetamulet" : new()
	p.petkey = self.m_petid
	p.grid = self.m_cellid
	require "manager.luaprotocolmanager":send(p)
	PetAmuletTips.DestroyDialog()
end


return PetAmuletTips
