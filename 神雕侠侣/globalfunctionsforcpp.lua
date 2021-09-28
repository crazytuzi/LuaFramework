local JEWELRY = 6
local function add_element(tab, k, v)
	tab[k] = tab[k] and tab[k] + v or v
end
local function GetScoreConfigIndex(equiptype)
    if equiptype >= 0 and equiptype <= JEWELRY then
        return equiptype
    end
    return -1
end
local function GetSecondType(typeid)
	local n = math.floor(typeid / 0x10)
	return n % 0x10
end
local function GetWeight(effectid, secondtype, weightid) 
    assert(weightid >= 0);
    local scoreConfig = knight.gsp.item.GetCEquipScoreConfigTableInstance():getRecorder(effectid)
    if scoreConfig.id == -1 then
        return 0
    end
    local idx = GetScoreConfigIndex(secondtype);
    if idx == -1 or idx >= scoreConfig.effectscore:size() then
        return 0
    end
    local weights = scoreConfig.effectscore[secondtype]
    for i = 1, weightid do
    	local startIdx = string.find(weights, ";")
    	assert(startIdx)
    	weights = string.sub(weights, startIdx + 1)
    end
    local endIdx = string.find(weights, ";")
    return tonumber(endIdx and string.sub(weights, 0, endIdx - 1) or weights)
end
local function getResult(cfg, type)
	if not cfg then
		return
	end
	if type == 0 then
		return cfg.wuqi
	elseif type == 1 then
		return cfg.huwan
	elseif type == 2 then
		return cfg.xianglian
	elseif type == 3 then
		return cfg.yifu
	elseif type == 4 then
		return cfg.yaodai
	elseif type == 5 then
		return cfg.xiezi
	end
end

local function GetSchoolBuff(attrid, schoolid)
	local schoolid = schoolid or GetDataManager():GetMainCharacterSchoolID()
	local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cjewelryshuxingbuff", attrid)
	if not cfg then
		return 1
	end
	if schoolid == 11 then
		return cfg.gumu / 100
	elseif schoolid == 12 then
		return cfg.gaibang / 100
	elseif schoolid == 14 then
		return cfg.baituo / 100
	elseif schoolid == 15 then
		return cfg.dali / 100
	elseif schoolid == 17 then
		return cfg.taohua / 100
	end
	return 1
end

local function GetJewelryEquipScore(itemid, pobj, schoolid)
	local score = 0
	for i = 1, #pobj.props do
		local dvalue = pobj.props[i]
		local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cjewelryshuxing", dvalue.propkey)
    	if cfg then
    		local value = cfg.value[dvalue.level - 1]
    		value = value * GetSchoolBuff(dvalue.propkey, schoolid)
            if cfg.baifenbi == 1 then
                value = value / 10000
            end
    		score = score + value * GetWeight(dvalue.propkey, JEWELRY, 3)
    	end
	end
	score = math.floor(score/100)
	return score
end
function GetLuaEquipScore(itemid, pobj, secondtype, schoolid)
	if secondtype == JEWELRY then
    	return GetJewelryEquipScore(itemid, pobj, schoolid)
    end
	local score = 0
	local equipColor = 0
    local equipConfig = knight.gsp.item.GetCEquipEffectTableInstance():getRecorder(itemid)
    if equipConfig.id ~= -1 then
        equipColor = equipConfig.equipcolor;
    end
    local realattr = {}
    -- cal baseeffect
    local equip = knight.gsp.item.GetCEquipEffectTableInstance():getRecorder(itemid)
	for i = 0, equip.baseEffect:size() - 1 do
		add_element(realattr, equip.baseEffectType[i], equip.baseEffect[i])
	end
    -- cal crystalnum
    local crystalnum = pobj.crystalnum;
    if crystalnum and crystalnum > 0 then
        local equipstars = knight.gsp.item.GetCequipstarsTableInstance():getRecorder(crystalnum);
        if equipstars.id ~= -1 then
        	for i = 0, equip.baseEffect:size() - 1 do
        		add_element(realattr, equip.baseEffectType[i], equip.baseEffect[i] * equipstars.uprate / 100)
        	end
        end
    end
    -- cal diamonds
    local gemlist = pobj.gemlist
    for i = 1, #gemlist do
    	local gemid = gemlist[i]
    	local gemconfig = knight.gsp.item.GetCGemEffectTableInstance():getRecorder(gemid)
		if gemconfig.id ~= -1 then
			for j= 0, gemconfig.effecttype:size() - 1 do
				add_element(realattr, gemconfig.effecttype[j], gemconfig.effect[j])
			end
		end
    end
    -- cal appendattrs
    local plusEffec = pobj.plusEffec
    for i = 1, #plusEffec do
    	local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cjiachengguanxi", plusEffec[i].attrid)
    	if cfg then
    		--local secondtype = GetSecondType(pItem:GetItemTypeID())
    		local formula = getResult(cfg, secondtype)
    		local variables = {}
			variables["Lv"] = plusEffec[i].attrnum
			local value = require "utils.formula"(formula, variables)
    		score = score + value * GetWeight(plusEffec[i].attrid, secondtype, 3)
    	end
    end

	for k, v in pairs(realattr) do
		score = score + v * GetWeight(k, secondtype, 0)
		score = score + (equipColor + 1) * v  * GetWeight(k, secondtype, 1)/100;
	end
	score = math.floor(score / 100)
	return score
end
function GetEquipScore(bagid, itemkey)
	local pItem = GetRoleItemManager():FindItemByBagAndThisID(itemkey, bagid)
	if not pItem then
		return 0
	end
	local EQUIP = 8 
	if pItem:GetItemTypeID() % 0x10 ~= EQUIP then
		return 0
	end
	local pobj = require "manager.itemmanager".getObject(bagid, itemkey)
	if not pobj then
		return 0
	end
	local itemid = pItem:GetBaseObject().id
    return GetLuaEquipScore(itemid, pobj, GetSecondType(pItem:GetItemTypeID()))
end
function IsNeedRequireData(bagid, itemkey)
	local pItem = GetRoleItemManager():FindItemByBagAndThisID(itemkey, bagid)
	if not pItem then
		return 0
	end
	if pItem:GetBaseObject().itemtypeid == 2454 then
		local pobj = require "manager.itemmanager".getObject(bagid, itemkey)
		if not pobj or pobj.bNeedRequireself then
			return 1
		end
		return 0
	end
	return 0
end

function LuaMakeTips(container, bagid, itemkey, makedes)
	local richeditbox = CEGUI.toRichEditbox(container)
	
	return require "ui.tips.basemaker".make(richeditbox, bagid, itemkey, makedes)
end

function LuaUseItem(itemid, typeid, bagid, itemkey, nouse)
	print("LuaUseItem "..tostring(itemid))
	local pItem = GetRoleItemManager():FindItemByBagAndThisID(itemkey, bagid)
	if bagid == knight.gsp.item.BagTypes.BAG then
		if typeid == 161 then -- pet amulet
			local petnum = GetDataManager():GetPetNum()
			if petnum == 0 then 
				GetGameUIManager():AddMessageTipById(143586)
				return 1
			end
			
			require "ui.pet.petpropertydlg"
			PetPropertyDlg.getInstanceAndShow():ShowGroup(4)

			return 1
		end
	end
	return 0
end

function ShowJewleryTips(data, baseid, x, y)
	LogInsane("ShowJewleryTips.."..type(data))
	local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(baseid)
	local data = tolua.cast(data, "GNET::Marshal::OctetsStream")
	assert(data)
	--	local data = GNET.Marshal.OctetsStream(self.m_tips[id])
	local pobj
	if GetSecondType(attr.itemtypeid) ~= JEWELRY then
	--	local data = GNET.Marshal.OctetsStream(self.m_tips[id])
		--equipObject:MakeTips(data)
		pobj = require "manager.octets2table.equip"(data)
	else
	--	local data = GNET.Marshal.OctetsStream(self.m_tips[id])
		LogInsane("ShowJewleryTips222")
		pobj = require "protocoldef.rpcgen.knight.gsp.item.decorationtipsoctets":new()
		pobj:unmarshal(data)
	end
	local dlg = CToolTipsDlg:GetSingletonDialog()
	local luadlg = require "ui.tips.tooltipsdlg"
	if not luadlg.isPresent() then
		CToolTipsDlg:GetSingletonDialogAndShowIt()
	end
	luadlg.init()
	luadlg.SetTipsItem(attr, pobj, x, y, true)
	if not luadlg.m_pMainFrame:isVisible() then
		luadlg.m_pMainFrame:setVisible(true)
	end
end

function LuaAddSenceNpc(npcbaseid, npcid)
	if npcbaseid == 12198 or npcbaseid == 12199 or npcbaseid == 12448 then
		local CShouxiShape = require "protocoldef.knight.gsp.school.cshouxishape"
		local req = CShouxiShape.Create()
		req.shouxikey = npcid
		LuaProtocolManager.getInstance():send(req)
	end
end

local function QuickBagFunction()
  local p = require "protocoldef.knight.gsp.item.copenvipdepot".new()
  p.bagid = knight.gsp.item.BagTypes.BAG
  require "manager.luaprotocolmanager":send(p)
  --local dlg = require "ui.item.depot":GetSingletonDialogAndShowIt()
end
local function GetQuickBagBtn()
  local winMgr = CEGUI.WindowManager:getSingleton()
  return CEGUI.toPushButton(winMgr:getWindow("MainPackDlg/tidy3"))
end
function LuaNotifyMainPackDlgCreated()
  local btn = GetQuickBagBtn()
  if btn then
    btn:subscribeEvent("Clicked", QuickBagFunction)
  end
end

function LuaNotifyMainPackDlgDestory()
  local btn = GetQuickBagBtn()
end
