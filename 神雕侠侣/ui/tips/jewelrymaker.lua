local function GetResString(strid)
	return require "utils.mhsdutils".get_resstring(strid)
end
local function GetSecondType(typeid)
	local n = math.floor(typeid / 0x10)
	return n % 0x10
end
local function MakeSeparator(m_Tipscontainer)
	m_Tipscontainer:AppendImage(CEGUI.String("MainControl"),CEGUI.String("TipsSeparator"))
    m_Tipscontainer:AppendBreak()
end
local EQUIP_TYPE_COLOR = "ff96f3a4"
local EQUIP_LEVEL_COLOR = "ff96f3a4"
local ATTRIBUTE_COLOR = "ffffc000"
local EQUIP_QUENCH_COLOR = "ffff6699"
local EQUIP_ATTRI_COLOR = "ffffff99"
local EQUIP_GEM_COLOR = "ff66ccff"
local GEMENOUGH_COLOR	= "ffffff99"	
local GEMENOUGH_ATTR_COLOR = "ffffc000"	
local GEMNOTENOUGH_COLOR =	"ff696969"
local EQUIP_MAKER_COLOR	= "ff00ffFF"
local EQUIP_ADDED_COLOR	= "ffccff33"
local REFINE_NUM_COLOR	= "ffffff00"
local s_StarEmotionScale = CEGUI.Vector2(0.6,0.6)
local function GetColourRect(str)
	return CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(str))
end
local function GetAttributeDes(attrid, attrvalue, basevalue)
	basevalue = basevalue or false
	local des = ""
	local strmsg
	local attrconfig = knight.gsp.item.GetCAttributeDesConfigTableInstance():getRecorder(math.floor(attrid/10)*10)
	if attrconfig.id ~= -1 then
		if basevalue then
			des = attrconfig.numbasevalue;
		else
			if attrid == attrconfig.numid then
				if attrvalue >= 0 then
					des = attrconfig.numpositivedes
				else
					des = attrconfig.numnegativedes
				end
			elseif attrid == attrconfig.percentid then
				if attrvalue >= 0 then
					des = attrconfig.percentpositivedes
				else
					des = attrconfig.percentnegativedes
				end
			else
				des = ""
			end
		end
	else
		des = ""
	end

	local sb = require "utils.stringbuilder":new()
	sb:Set("parameters", tostring(math.abs(attrvalue)))
    local msgstr = sb:GetString(des)
    sb:delete()
	return msgstr
end
local function GetSchoolBuff(attrid, schoolid)
--	local schoolid = schoolid or GetDataManager():GetMainCharacterSchoolID()
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
local function maketips(m_Tipscontainer, itemattr, pobj, schoolid)
	local baseid = itemattr.id
	
    local equipConfig = knight.gsp.item.GetCEquipEffectTableInstance():getRecorder(baseid)
    local equipColor = equipConfig.equipcolor
    local colorconfig = knight.gsp.item.GetCEquipColorConfigTableInstance():getRecorder(equipColor)
    local str = GetResString(111)..GetLuaEquipScore(baseid, pobj, GetSecondType(itemattr.itemtypeid), schoolid)
    m_Tipscontainer:AppendText(CEGUI.String(str), 
    	CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(colorconfig.colorvalue)))
    m_Tipscontainer:AppendBreak()
    
    local strType = knight.gsp.item.GetCItemTypeTableInstance():getRecorder(itemattr.itemtypeid).name
    local str = GetResString(115)..strType 
    m_Tipscontainer:AppendText(CEGUI.String(str),  
    	CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(EQUIP_TYPE_COLOR)))
	m_Tipscontainer:AppendBreak()

	m_Tipscontainer:AppendText(CEGUI.String(GetResString(119)),
		CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(EQUIP_LEVEL_COLOR)))
	local level, needlevel = itemattr.level, itemattr.needLevel
	
    if needlevel > 0 then
    	local color = needlevel > GetDataManager():GetMainCharacterLevel() and
        	 CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour("FFFF0000")) 
        	 or CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(EQUIP_LEVEL_COLOR))
        m_Tipscontainer:AppendText(CEGUI.String(tostring(level)), color)
    else
        m_Tipscontainer:AppendText(CEGUI.String(tostring(level)),
        	CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(EQUIP_LEVEL_COLOR)))
    end
	m_Tipscontainer:AppendBreak()
	MakeSeparator(m_Tipscontainer)
	
	local have_separator = false
	local equip = knight.gsp.item.GetCEquipEffectTableInstance():getRecorder(baseid);
	if #pobj.props ~= 0 then
		m_Tipscontainer:AppendText(CEGUI.String(GetResString(123)), GetColourRect(ATTRIBUTE_COLOR))
	    	m_Tipscontainer:AppendBreak()
		for i = 1, #pobj.props do
			local dvalue = pobj.props[i]
			local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cjewelryshuxing", dvalue.propkey)
	    	if cfg then
	    		local value = cfg.value[dvalue.level - 1]
	    		value = value * GetSchoolBuff(dvalue.propkey, pobj.addvalue)
	    		if cfg.baifenbi == 1 then
	    			value = value / 100
	    		end
	    		m_Tipscontainer:AppendText(CEGUI.String("  "..GetAttributeDes(dvalue.propkey, value)), 
	    			GetColourRect(EQUIP_ADDED_COLOR))
	        	m_Tipscontainer:AppendText(CEGUI.String(GetResString(124)..dvalue.level.."/"..dvalue.maxlevel), 
	        		GetColourRect(REFINE_NUM_COLOR))
	        	m_Tipscontainer:AppendBreak()
	    	end
		end
		have_separator = true
	end
	if have_separator then
		MakeSeparator(m_Tipscontainer)
	end
	m_Tipscontainer:AppendBreak()
	local sexneed = equip.sexNeed
	if sexneed ~=0 then
		local sex = GetDataManager():GetMainCharacterData().sex
		m_Tipscontainer:AppendText(CEGUI.String(sexneed == 1 and GetResString(132) or GetResString(133)),
			sex ~= sexneed and  
			GetColourRect("FFFF0000") or GetColourRect(ATTRIBUTE_COLOR))
		m_Tipscontainer:AppendBreak()
	end
--	m_Tipscontainer:Refresh()
end

return maketips