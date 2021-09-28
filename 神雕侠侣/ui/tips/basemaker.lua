local maker = {}
setmetatable(maker, maker)
local NO_TYPE = 0
local PET_ITEM = 1
local   PET_AMULET = 161
local FOOD = 2	
local DRUG = 3	
local DIMARM = 4
local	GEM = 5
local	GROCERY = 6	
local	EQUIP_RELATIVE = 7
local	EQUIP = 8 
local	TASK_ITEM = 9 
local PET_SKILL_BOOK = 49
local PET_AMULET = 161
local JEWELRY = 6
local EFFECT_COLOR = "ff96f3a4"
local DESCRIBE_COLOR = "ffffff99"
local function MakeSeparator(m_Tipscontainer)
	m_Tipscontainer:AppendImage(CEGUI.String("MainControl"),CEGUI.String("TipsSeparator"))
    m_Tipscontainer:AppendBreak()
end
local function GetColourRect(str)
	return CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(str))
end
local function petitem(m_Tipscontainer, baseid, pobj)
	m_Tipscontainer:AppendText("");
	m_Tipscontainer:AppendBreak();
	MakeSeparator(m_Tipscontainer)
	local itemconfig = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(baseid)
	if not itemconfig or itemconfig.id < 0 then
		return false
	end
	if (itemconfig.itemtypeid == PET_SKILL_BOOK) then
		m_Tipscontainer:AppendText(require "utils.mhsdutils".get_resstring(146), CEGUI.ColourRect(EFFECT_COLOR))
		local PetItem = knight.gsp.item.GetCPetItemEffectTableInstance():getRecorder(baseid)
		if (PetItem.id ~= -1 and PetItem.petskillid ~= 0) then
			local skillBase = knight.gsp.skill.GetCPetSkillConfigTableInstance():getRecorder(PetItem.petskillid)
			if (skillBase.id ~= -1) then
				m_Tipscontainer:AppendText(skillBase.skillname,CEGUI.ColourRect(EFFECT_COLOR))
			end
		end
		m_Tipscontainer:AppendBreak();
	else
		m_Tipscontainer:AppendText(require "utils.mhsdutils".get_resstring(147)..itemconfig.effectdes,CEGUI.ColourRect(EFFECT_COLOR))
		m_Tipscontainer:AppendBreak()
	end
	MakeSeparator(m_Tipscontainer)
end

function maker.makePetAmuletTips( container, amuletid, pobj, itemkey )
	if not pobj or pobj.bNeedRequireself then
		local p = knight.gsp.item.CItemTips(knight.gsp.item.BagTypes.BAG, itemkey)
		GetNetConnection():send(p)
		return
	end

	local itembean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(amuletid)
	local record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cpetamulet"):getRecorder(amuletid);

	-- self.m_itemcell:SetImage(GetIconManager():GetItemIconByID(itembean.icon))

	container:setVisible(true);
	container:Clear();
	
	container:AppendText(CEGUI.String(" "))
	container:AppendBreak()
	MakeSeparator(container)

	local function appendText(str)
		container:AppendText(CEGUI.String(str), GetColourRect(EFFECT_COLOR))
	end

    -- grade
    appendText(MHSD_UTILS.get_resstring(119))
    appendText(tostring(record.amuletgrade))
    container:AppendBreak()

    -- exp
    appendText(MHSD_UTILS.get_resstring(3082))
    appendText(tostring(pobj.curexp).."/"..record.needexp)
    container:AppendBreak()

    -- description
	appendText(MHSD_UTILS.get_resstring(1379))
	appendText(record.xiaoguomiaoshu)
	container:AppendBreak()
    
    -- diaowen
    local diaowenid = pobj.diaowenid
    appendText(MHSD_UTILS.get_resstring(3083))
    if diaowenid == 0 then
    	appendText(MHSD_UTILS.get_resstring(1663))
    else
    	local dw = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cpetglyoh"):getRecorder(diaowenid)
    	appendText(dw.name.."(1/"..tostring(dw.num)..")")
    end
    container:AppendBreak()

    MakeSeparator(container)

    -- container:Refresh()
end


function maker.makedes(container, itemconfig)
	local describe = itemconfig.destribe
	local idx = string.find(describe, "<T")
	if idx then
		container:AppendParseText(CEGUI.String(describe))
	else
		container:AppendText(CEGUI.String(describe), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(DESCRIBE_COLOR)));
	end
end
local function GetSecondType(typeid)
	local n = math.floor(typeid / 0x10)
	return n % 0x10
end

function maker.make_common(container, attr, pobj, schoolid, itemkey)
	if math.floor(attr.itemtypeid % 0x100) == 0x87 then
		require "ui.tips.jewelrymaterialmaker"(container, attr)
		return 1
	end

	if attr.itemtypeid == 2454 then
		if not pobj then
			return 0
		end
		container:setVisible(true);
		container:Clear();
		
		container:AppendText(CEGUI.String(""))
		container:AppendBreak()
		MakeSeparator(container)
		local grocery = knight.gsp.item.GetCGroceryEffectTableInstance():getRecorder(attr.id)
		local s = require "utils.mhsdutils".get_resstring(154)..grocery.effect
		container:AppendText(CEGUI.String(s), CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(EFFECT_COLOR)))
		container:AppendBreak()
		MakeSeparator(container)
		container:AppendText(CEGUI.String(require "utils.mhsdutils".get_resstring(2986)..pobj.codestr))
		--MakeSeparator(container)
		
		container:AppendText(CEGUI.String(""))
		container:AppendBreak()
		
		return 1
	elseif attr.itemtypeid % 0x10 == EQUIP then
		if not pobj then
			return 0
		end
		if GetSecondType(attr.itemtypeid) == JEWELRY then
			require "ui.tips.jewelrymaker"(container, attr, pobj, schoolid)
		else
			require "ui.tips.equipmaker"(container, attr.id, pobj)
		end
		return 1

	elseif attr.itemtypeid == PET_AMULET then
		maker.makePetAmuletTips(container, attr.id, pobj, itemkey)
		return 1
	end
	return 0
end

local function make_imp(container, bagid, itemkey)
	local pItem = GetRoleItemManager():FindItemByBagAndThisID(itemkey, bagid)
	if not pItem then
		return 0
	end
	local pobj = require "manager.itemmanager".getObject(bagid, itemkey)
	return maker.make_common(container, pItem:GetBaseObject(), pobj, nil, itemkey)
end

function maker.make(container, bagid, itemkey, bmakedes)
	local pItem = GetRoleItemManager():FindItemByBagAndThisID(itemkey, bagid)
	if not pItem then
		return 0
	end
	if make_imp(container, bagid, itemkey) == 1 then
		if bmakedes then
			maker.makedes(container, pItem:GetBaseObject())
		end
		container:AppendBreak()
		container:Refresh()
        container:HandleTop()
        return 1
	end
	return 0
end
return maker