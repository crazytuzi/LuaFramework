MHSD_UTILS = {
}

function MHSD_UTILS.getColorIntrStrByID(color)
	if color == 0 then
		return MHSD_UTILS.get_resstring(1194)
	end
	return MHSD_UTILS.get_resstring(color + 1193)
end

function MHSD_UTILS.getColorByID(colorid)
	return knight.gsp.item.GetCEquipColorConfigTableInstance():getRecorder(colorid).colorvalue
end

g_red_color = 0XFFFF0000
g_green_color = 0XFF00FF00
g_white_color = 0XFFFFFFFF
g_yellow_color = 0XFFFFFF33

function MHSD_UTILS.get_redcolor()
	return CEGUI.PropertyHelper:stringToColour("FFFF0000")
end

function MHSD_UTILS.get_greencolor()
	return CEGUI.PropertyHelper:stringToColour("FF00FF00")
end 

function MHSD_UTILS.get_whitecolor()
    return CEGUI.PropertyHelper:stringToColour("FFFFFFFF")
end

function MHSD_UTILS.get_yellowcolor()
    return CEGUI.PropertyHelper:stringToColour("FFFFFF33")
end

function MHSD_UTILS.get_resstring(id)
	local xmlmsg = knight.gsp.message.GetCStringResTableInstance():getRecorder(id)
	return xmlmsg.msg
end

function MHSD_UTILS.get_msgtipstring(id)
	local tipmsg = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(id)
	return tipmsg.msg
end

function MHSD_UTILS.get_effectpath(id)
	local effectpath = knight.gsp.EffectPath.GetCEffectPathNoneDramaTableInstance():getRecorder(id)
	return effectpath.Path
end

function MHSD_UTILS.get_effectpathFromCeffectPathTable(id)

    local effectpath = knight.gsp.EffectPath.GetCEffectPathTableInstance():getRecorder(id)
    
    if effectpath and effectpath.id ~= -1 then
        return effectpath.Patn
    end
    
    return ""
end

function MHSD_UTILS.getColourStringByNumber(val)
	print("val="..val)
--[[	local blue = val % 0xff
	val = math.floor(val / 0xff)
	local green = val % 0xff 
	val = math.floor(val / 0xff)
	local red = val % 0xff 
	val = math.floor(val / 0xff)
	local alpha = val % 0xff 
	print(string.format("red=%f, green=%f, blue=%f, alpha=%f", red, green, blue, alpha))
	local ret = CEGUI.PropertyHelper:colourToString(CEGUI.colour(red, green, blue, alpha))]]
	return string.format("%x", val)
end

function MHSD_UTILS.intToDateTime(time)
	local date = os.date("*t", math.floor(time/1000))
	return string.format("%d-%d-%d",  date.year, date.month, date.day)
end

function MHSD_UTILS.intToDateTimeCN(time)
  local date = os.date("*t", math.floor(time/1000))
  return string.format(MHSD_UTILS.get_resstring(1237),  date.year, date.month, date.day)
end

function MHSD_UTILS.addConfirmDialog(msg, callback, type)
--knight.gsp.message.GetCMessageTipTableInstance():getRecorder(
	local t = type or (MHSD_UTILS.confirm_type and MHSD_UTILS.confirm_type or eConfirmTeamLeaderEnterFuben + 1)
	GetMessageManager():AddConfirmBox(t, msg, callback, 0,
	     CMessageManager.HandleDefaultCancelEvent,CMessageManager,0,0,nil,"","")
	return t
end

function MHSD_UTILS.getLuaBean(beanname, recorderid)
	local tt = BeanConfigManager.getInstance():GetTableByName(beanname)
	return tt:getRecorder(recorderid)
end

local function onItemcellClicked(itemcell, e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local itemcell = CEGUI.toItemCell(mouseArgs.window)
	if itemcell:getID() ~= 0 then
		local Pos = itemcell:GetScreenPos()
		CToolTipsDlg:GetSingletonDialog():RefreshItemTipsByBaseID(itemcell:getID(), Pos.x,Pos.y, false, 0, true)
	end
	return true
end

function MHSD_UTILS.SetWindowShowtips(itemcell)
	itemcell:subscribeEvent("MouseClick", onItemcellClicked, itemcell)
end

local function setTipsBtn(btnstr, btnstr2, callback1, callback2)
    local winMgr = CEGUI.WindowManager:getSingleton()
    local m_pLeft = CEGUI.toPushButton(winMgr:getWindow("ItemTips/delete"))
    local m_pRight = CEGUI.toPushButton(winMgr:getWindow("ItemTips/use"))
    if not m_pLeft or not m_pRight then
      return
    end
    if btnstr and not btnstr2 then
      m_pLeft:setVisible(false)
      m_pRight:setVisible(true)
      m_pRight:setText(btnstr)
      m_pRight:removeEvent("Clicked")
      m_pRight:subscribeEvent("Clicked", callback1)
    end
    if btnstr and btnstr2 then
      m_pLeft:setVisible(true)
      m_pRight:setVisible(true)
      m_pLeft:setText(btnstr)
      m_pRight:setText(btnstr2)
      m_pLeft:removeEvent("Clicked")
      m_pLeft:subscribeEvent("Clicked", callback1)
      m_pRight:removeEvent("Clicked")
      m_pRight:subscribeEvent("Clicked", callback2)
    end
end

local function onItemcellHasItemkeyClicked(itemcell, bagid, btnstr, btnstr2, callback1, callback2)
	if itemcell:getID() ~= 0 then
		local pt = itemcell:GetScreenPos()
		local pItem = GetRoleItemManager():FindItemByBagAndThisID(itemcell:getID(), bagid)
		if pItem then
			CToolTipsDlg:GetSingletonDialog():SetTipsItem(pItem, pt.x, pt.y, true)
			setTipsBtn(btnstr, btnstr2, callback1, callback2)
		--	CToolTipsDlg:GetSingletonDialog():RefreshItemTipsByBaseID(pItem:GetBaseObject().id, Pos.x,Pos.y, false, 0, true)
		end
	end
	return true
end
local function onItemcellClicked(parameter, e)
	onItemcellHasItemkeyClicked(parameter.itemcell, parameter.bagid, 
	 parameter.btnstr, parameter.btnstr2,
	 parameter.callback1, parameter.callback2)
end
--[[
local function onEquipItemcellClicked(parameter, e)
	onItemcellHasItemkeyClicked(parameter.itemcell, knight.gsp.item.BagTypes.EQUIP)
end
--]]
function MHSD_UTILS.SetWindowShowtips4Bag(itemcell, bagid, btnstr, callback1, btnstr2, callback2)
  local parameter = {}
  parameter.itemcell = itemcell
  parameter.btnstr = btnstr
  parameter.btnstr2 = btnstr2
  parameter.callback1 = callback1
  parameter.callback2 = callback2
  parameter.bagid = bagid
  itemcell:subscribeEvent("MouseClick", onItemcellClicked, parameter)
end
function MHSD_UTILS.SetBagWindowShowtips(itemcell, btnstr, callback1, btnstr2, callback2)
  local parameter = {}
  parameter.itemcell = itemcell
  parameter.btnstr = btnstr
  parameter.btnstr2 = btnstr2
  parameter.callback1 = callback1
  parameter.callback2 = callback2
  parameter.bagid = knight.gsp.item.BagTypes.BAG
	itemcell:subscribeEvent("MouseClick", onItemcellClicked, parameter)
end
function MHSD_UTILS.SetEquipWindowShowtips(itemcell)
  local parameter = {}
  parameter.itemcell = itemcell
  parameter.bagid = knight.gsp.item.BagTypes.EQUIP
	itemcell:subscribeEvent("MouseClick", onItemcellClicked, parameter)
end

function MHSD_UTILS.trim(str)
	assert(str)
	str = string.gsub(str, " ", "")
	return str
end

local function getShieldStr(str)
	assert(str)
	local len = string.len(str)
	local size = {}
	for i = 1, len do
		size[i] = '*'
	end
	return table.concat(size)
end

function MHSD_UTILS.ShiedText(inText)
	local shied = false
	if string.len(inText)>0 then
		local banwordids = std.vector_int_()
		local configtable = knight.gsp.chat.GetCBanWordsTableInstance()
		configtable:getAllID(banwordids)
		local num = banwordids:size()
		for i = 0, num-1 do
			local word = configtable:getRecorder(banwordids[i]).BanWords
			word = MHSD_UTILS.trim(word)
			if string.match(inText, word) then
				shied = true
			end
			inText = string.gsub(inText, word, getShieldStr(word))
		end
	end
	return shied, inText
end

function MHSD_UTILS.split_string(source, delimiter)
    local result = {}
    local lenDelim = string.len(delimiter)
    local i = 1-lenDelim
    local j = 1
    local lastI = i
    local indexTailSrc = string.len(source)
    while true do
        lastI = i+lenDelim
        i = string.find(source, delimiter, i+lenDelim)
        if i ~= nil then
            if j <= (i-1) and i >= 2 then
                result[#result+1] = string.sub(source, j, i-1)
            end
            j = i+lenDelim
        else
            break
        end
    end
    
    if lastI < 1 then
        print("____error MHSD_UTILS.split_string")
        lastI = 1
    end
    
    if lastI <= indexTailSrc then
        result[#result+1] = string.sub(source, lastI, indexTailSrc)
    end
    
    return result
end

function MHSD_UTILS.shuffletable(t)
    print("____MHSD_UTILS.shuffletable")
    
    --print("____#t: " .. #t)
    
    math.randomseed(os.time())

    for i = #t, 1, -1 do
        local j = math.random(1, i)
        
        --print("____i: " .. i)
        --print("____j: " .. j)

        local tmp = t[i]
        t[i] = t[j]
        t[j] = tmp
    end
end

function MHSD_UTILS.GetTimeHMSUnit(seconds)
    local hours = math.floor(seconds/3600)
    local leftMinSec = seconds - hours*3600
    
    local mins = math.floor(leftMinSec/60)
    local secs = math.floor(leftMinSec - mins*60)

    if hours < 0 then
        hours = 0
    end
    if mins < 0 then
        mins = 0
    end
    if secs < 0 then
        secs = 0
    end

    return hours, mins, secs
end

function MHSD_UTILS.GetTimeHMSString(seconds)
    local hours = math.floor(seconds/3600)
    local leftMinSec = seconds - hours*3600
    
    local mins = math.floor(leftMinSec/60)
    local secs = math.floor(leftMinSec - mins*60)

    if hours < 0 then
        hours = 0
    end
    if mins < 0 then
        mins = 0
    end
    if secs < 0 then
        secs = 0
    end
    
    local strTime = ""
    if hours > 0 then
        strTime = hours .. ":" .. mins .. ":" .. secs
    else
        strTime = mins .. ":" .. secs
    end
    return strTime
end

return MHSD_UTILS








