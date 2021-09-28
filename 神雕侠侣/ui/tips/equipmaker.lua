local s_StarEmotionScale = CEGUI.Vector2(0.6,0.6)
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
local function MakeStar(m_Tipscontainer, crystalnum)
	m_Tipscontainer:SetEmotionScale(s_StarEmotionScale)
    if crystalnum and crystalnum > 0 then
        local starconfig = knight.gsp.item.GetCequipstarsTableInstance():getRecorder(crystalnum)

        local stars = tonumber(starconfig.stars)
        local t = 10000000
        for i = 0, 7 do
        	local starlevel = math.floor(stars / t) % 10
        	if crystalnum <= 64 then
				m_Tipscontainer:AppendEmotion(149 + starlevel)
			else
				m_Tipscontainer:AppendEmotion(699 + starlevel)
			end
            t = math.floor(t / 10);
        end

        m_Tipscontainer:AppendText(CEGUI.String(""))
        m_Tipscontainer:AppendBreak()
        MakeSeparator(m_Tipscontainer)
    end
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
local function GetGemHoleNum(equipObj)
	if equipObj.blesslv > 0 then 
		local tbl = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cequipbless")
		local cfg = tbl:getRecorder(equipObj.blesslv)
		return cfg.gemhole
	else
	    return math.floor(GetDataManager():GetMainCharacterLevel()/20)
	end
end

local function MakeGemsReminder(m_Tipscontainer, maxgem, gempluseffectnum, GemAttributeMap, gemlist)
	if #gemlist <= 0 then
		return
	end
    m_Tipscontainer:AppendText(CEGUI.String(GetResString(125)), 
    	GetColourRect(ATTRIBUTE_COLOR))
    m_Tipscontainer:AppendBreak()
    
	for k, v in pairs(GemAttributeMap) do
		m_Tipscontainer:AppendText(CEGUI.String("  "..GetAttributeDes(k, v)), GetColourRect(EQUIP_GEM_COLOR))
        m_Tipscontainer:AppendBreak()
	end
	if #gemlist >= maxgem then
		m_Tipscontainer:AppendText(CEGUI.String(GetResString(126)..#gemlist..GetResString(127)), 
    	GetColourRect(GEMENOUGH_COLOR))
	else
   		m_Tipscontainer:AppendText(CEGUI.String(GetResString(126)..#gemlist..GetResString(127)), 
    	GetColourRect(GEMNOTENOUGH_COLOR))
    end
    
	m_Tipscontainer:AppendBreak()
	MakeSeparator(m_Tipscontainer)
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
local function MakeGems(m_Tipscontainer, gemmaxnum, gemlist)
    for i=1, gemmaxnum do  
        if i <= #gemlist then
            local gemid = gemlist[i]
            local GemEffect = knight.gsp.item.GetCGemEffectTableInstance():getRecorder(gemid)
            if GemEffect.tipsicon ~= "" then
          --  	m_Tipscontainer:AppendEmotion(150)
                m_Tipscontainer:AppendImage(CEGUI.String("MainControl"), CEGUI.String(GemEffect.tipsicon))
            elseif GemEffect.tipsemotion ~= 0 then
            	m_Tipscontainer:SetEmotionScale(CEGUI.Vector2(0.5, 0.5))
            	m_Tipscontainer:AppendEmotion(GemEffect.tipsemotion)
            else
                m_Tipscontainer:AppendImage(CEGUI.String("MainControl"),CEGUI.String("maleOn"))
            end
        else
            m_Tipscontainer:AppendImage(CEGUI.String("MainControl"),CEGUI.String("stone0"))
        end
 	end
    m_Tipscontainer:AppendBreak();
end
local function maketips(m_Tipscontainer, baseid, pobj)
	if not pobj then
	--	MakeTipsWithoutTips()
		return
	end

	local itemattr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(baseid)
	local blessCfg = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cequipbless"):getRecorder(pobj.blesslv)


	if pobj.blesslv > 0 then
		--play bless effect
		GetGameUIManager():AddUIEffect(m_Tipscontainer, MHSD_UTILS.get_effectpath(blessCfg.tipseffect), true, 
			m_Tipscontainer:getPixelSize().width / 2, 0, true)
		--show bless name
		local winMgr = CEGUI.WindowManager:getSingleton()
		local nameWindow = winMgr:getWindow("ItemTips/name")
		if nameWindow then
			local equipConfig = knight.gsp.item.GetCEquipEffectTableInstance():getRecorder(baseid)
			local colorconfig = knight.gsp.item.GetCEquipColorConfigTableInstance():getRecorder(equipConfig.equipcolor)
			nameWindow:setProperty("TextColours", "FFFFFFFF")
			nameWindow:setText(string.format("[colour='"..colorconfig.colorvalue.."'] "..itemattr.name))
			nameWindow:appendText(string.format("[colour='"..blessCfg.textcolor.."'] "..blessCfg.equipnametext))
		end
	end

	MakeStar(m_Tipscontainer, pobj.crystalnum)
	if GetSecondType(itemattr.itemtypeid) <= 5 then
        local equipConfig = knight.gsp.item.GetCEquipEffectTableInstance():getRecorder(baseid)
        local equipColor = equipConfig.equipcolor
        local colorconfig = knight.gsp.item.GetCEquipColorConfigTableInstance():getRecorder(equipColor)
        local str = GetResString(111)..GetLuaEquipScore(baseid, pobj, GetSecondType(itemattr.itemtypeid))
        m_Tipscontainer:AppendText(CEGUI.String(str), 
        	CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(colorconfig.colorvalue)))
        m_Tipscontainer:AppendBreak()
    end
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
    if equip.baseEffectType:size() ~= 0 then
    	m_Tipscontainer:AppendText(CEGUI.String(GetResString(122)), 
    		GetColourRect(ATTRIBUTE_COLOR))
	    m_Tipscontainer:AppendBreak()
	    local starconfig = knight.gsp.item.GetCequipstarsTableInstance():getRecorder(pobj.crystalnum)
	    local uprate = starconfig.id ~= -1 and starconfig.uprate or 0
	    for i = 0, equip.baseEffectType:size() - 1 do
	    	m_Tipscontainer:AppendText(CEGUI.String("  "..GetAttributeDes(equip.baseEffectType[i], equip.baseEffect[i], true)), 
	    	GetColourRect(EQUIP_ATTRI_COLOR));
	        if uprate > 0 then
	            m_Tipscontainer:AppendText(CEGUI.String("+"..uprate.."%"), GetColourRect(EQUIP_QUENCH_COLOR));
	        elseif uprate < 0 then
	            m_Tipscontainer:AppendText(CEGUI.String("-"..uprate.."%"), GetColourRect(EQUIP_QUENCH_COLOR));
	        end
	        m_Tipscontainer:AppendBreak()
	    end
        have_separator = true
        
    end
    
    if #pobj.plusEffec ~= 0 then
    -- 	local PrefixConfig = knight.gsp.item.GetCEquipPrefixConfigTableInstance():getRecorder(pobj.prefixtype)
     --       MakeExtProperty(PrefixConfig.id == -1? 0 : PrefixConfig.maxrefinetime, pObject->plusEffec);
     	m_Tipscontainer:AppendText(CEGUI.String(GetResString(123)), GetColourRect(ATTRIBUTE_COLOR))
    	m_Tipscontainer:AppendBreak()

    	for i = 1, #pobj.plusEffec do
    		local effect = pobj.plusEffec[i]
    		local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cjiachengguanxi", effect.attrid)
    		if cfg then
	    		local formula = getResult(cfg, GetSecondType(itemattr.itemtypeid))
	    		local variables = {}
				variables["Lv"] = effect.attrnum
				local value = require "utils.formula"(formula, variables)
				if cfg.baifenbi == 1 then
					value = value * 100
				end
	    		m_Tipscontainer:AppendText(CEGUI.String("  "..GetAttributeDes(effect.attrid, value)), 
	    			GetColourRect(EQUIP_ADDED_COLOR))
	        	m_Tipscontainer:AppendText(CEGUI.String(GetResString(124)..effect.attrnum.."/"..tostring(blessCfg.extrarefinelv)), 
	        		GetColourRect(REFINE_NUM_COLOR))
	        	m_Tipscontainer:AppendBreak();
        	end
    	end
        have_separator = true
    end

    if require("ui.shenbingliqidlg").getInstanceNotCreate() then
        local fujiashuxingCount = require "utils.mhsdutils".get_msgtipstring(145822)
        m_Tipscontainer:AppendText(CEGUI.String(fujiashuxingCount), GetColourRect("ff32dc64"))
        m_Tipscontainer:AppendBreak()
    end
    
    

    local EquipMakeUpConfig = knight.gsp.item.GetCEquipMakeUpConfigTableInstance():getRecorder(baseid)
    local gempluseffectnum = EquipMakeUpConfig.gempluseffectnum
    MakeGemsReminder(m_Tipscontainer, GetGemHoleNum(pobj), gempluseffectnum, pobj.GemAttributeMap, pobj.gemlist)
	if #pobj.gemlist ~= 0 then
        MakeGems(m_Tipscontainer, GetGemHoleNum(pobj), pobj.gemlist)
    end
	if have_separator then
		MakeSeparator(m_Tipscontainer)
	end
	
	if string.len(pobj.maker) ~= 0 then
		m_Tipscontainer:AppendText(CEGUI.String(pobj.maker..GetResString(131)), GetColourRect(EQUIP_MAKER_COLOR));
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