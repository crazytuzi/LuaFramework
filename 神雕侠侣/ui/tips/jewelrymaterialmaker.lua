local LEVEL_COLOR = "ff96f3a4"
local function maketips(m_Tipscontainer, attr)
	m_Tipscontainer:AppendText(CEGUI.String(""))
	m_Tipscontainer:AppendBreak()
	m_Tipscontainer:AppendImage(CEGUI.String("MainControl"),CEGUI.String("TipsSeparator"))
	m_Tipscontainer:AppendBreak()
	
	local MHSD_UTILS = require "utils.mhsdutils"
	m_Tipscontainer:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(152)),
		CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(LEVEL_COLOR)))
	m_Tipscontainer:AppendText(CEGUI.String(tostring(attr.level)), 
		CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(LEVEL_COLOR)))
	m_Tipscontainer:AppendBreak()
	
	local EquipStuff = knight.gsp.item.GetCEquipRelativeTableInstance():getRecorder(attr.id)
	if EquipStuff.id ~= -1 then
		m_Tipscontainer:AppendText(CEGUI.String(MHSD_UTILS.get_resstring(154)..EquipStuff.effectdes),
			CEGUI.ColourRect(CEGUI.PropertyHelper:stringToColour(LEVEL_COLOR)))
		m_Tipscontainer:AppendBreak()
	end
	m_Tipscontainer:AppendImage(CEGUI.String("MainControl"),CEGUI.String("TipsSeparator"))
	m_Tipscontainer:AppendBreak()
--	m_Tipscontainer:Refresh()
end

return maketips