local _M = {}
_M.__index = _M
local Text = require'Zeus.Logic.Text'
local Helper = require'Zeus.Logic.Helper'
local ItemModel = require 'Zeus.Model.Item'
local cjson = require "cjson"
local ServerTime  = require 'Zeus.Logic.ServerTime'

function split(str,sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end


function _M.reward2item(rewardStr, sep)
    local list = string.split(rewardStr, sep or ':')
    local item = GlobalHooks.DB.Find("Items", list[1])
    return {code = list[1], groupCount = tonumber(list[2]), icon= item.Icon, qColor = item.Qcolor, name=item.Name, static = item}
end

function _M.rewards2items(rewardsStr, sep1, sep2)
    local list = string.split(rewardsStr, sep1 or ';')
    for i,v in ipairs(list) do
        list[i] = _M.reward2item(v)
    end
    return list
end

function _M.checkRecharge(needDiamond, buyCb, closeMenu)
	local diamond = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.DIAMOND)
	if diamond >= needDiamond then
		buyCb()
		return
	end

	GameAlertManager.Instance:ShowAlertDialog(
	    AlertDialog.PRIORITY_NORMAL, 
	    _M.GetText(TextConfig.Type.VIP,"doYouRecharge"),
	    _M.GetText(TextConfig.Type.VIP, "ok"),
	    _M.GetText(TextConfig.Type.VIP, "cancel"),
	    _M.GetText(TextConfig.Type.VIP, "noDiamond"),
	    nil,
	    function()
            if closeMenu then
                closeMenu:Close()
            end
            EventManager.Fire('Event.Goto', {id = "Pay"})
	    	
	    end,
	    nil
	)
end

function _M.checkVip(needVip, cb)
    local vip = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.VIP)
    if vip >= needVip then
        cb()
        return
    end

    GameAlertManager.Instance:ShowAlertDialog(
        AlertDialog.PRIORITY_NORMAL, 
        _M.GetText(TextConfig.Type.VIP,"doYouBuyVip"),
        _M.GetText(TextConfig.Type.VIP, "ok"),
        _M.GetText(TextConfig.Type.VIP, "cancel"),
        _M.GetText(TextConfig.Type.VIP, "notEnoughVIP"),
        nil,
        function()
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIRechargeVip, 0, "vip")
        end,
        nil
    )
end


local function List2Luatable(list)
	if not list then return nil end
  local ret = {}
  local iter = list:GetEnumerator()
  while iter:MoveNext() do
    local item = iter.Current
    table.insert(ret,item)
  end
  return ret
end

local function StringObjDict2LuaTable(dict)
	if not dict then return nil end
  local ret = {}
  local iter = dict:GetEnumerator()
  while iter:MoveNext() do
    local key = iter.Current.Key
    local val = iter.Current.Value
    ret[key] = val
  end
  return ret	
end

local function CreateHZUICompsTable(luamenu,def_tabel,tab)
	local ret = tab or {}
	Helper.each_t(function (args)
		local name = args.val.name
		if not name then return end
		local click = args.val.click
		local comp = luamenu:GetComponent(name)
		if comp then 
			ret[name] = comp
			if click then  
				comp.TouchClick = function (sender)
					click(ret)
				end
			end
		end
	end,def_tabel)
	return ret
end


local function MultiToggleButton(fun,default,tbts,keep_state)
	local last
	for _,val in ipairs(tbts) do
		val:SetBtnLockState(HZToggleButton.LockState.eLockSelect)
		val.Selected = function (sender)
			if sender.IsChecked then
				for _,v in ipairs(tbts) do
					if v ~= val then
						v.IsChecked = false
					end
				end
				fun(sender)





				
			end
		end
		if default == val then
			val.IsChecked = true
		elseif not keep_state then
			val.IsChecked = false
		end
	end
end

local function ChangeMultiToggleButtonSelect(choice,tbts)
    for _,val in ipairs(tbts) do
        val.IsChecked = false
    end
    choice.IsChecked = true
    
end

local function HZSetImage(node, path, resize, style, clipsize)
	style = style or (node.Layout and node.Layout.Style) or LayoutStyle.IMAGE_STYLE_BACK_4_CENTER
	clipsize = clipsize or 8
	if string.sub(path,1,1) == '#' then
		node.Layout = XmdsUISystem.CreateLayoutFroXml(path,style,clipsize)
	else
		node.Layout = XmdsUISystem.CreateLayoutFromFile(path,style,clipsize)
	end
	if resize then 
		node.Size2D = node.Layout.PreferredSize
	end
end

local function HZSetImage2(node, path, resize, style, clipsize)
	style = style or (node.Layout and node.Layout.Style) or LayoutStyle.IMAGE_STYLE_BACK_4_CENTER
	clipsize = clipsize or 8
	if string.sub(path,1,1) == '#' then
		if string.match(path, "|%d+$") then
			node.Layout = XmdsUISystem.CreateLayoutFroXml(path,style,clipsize)
		else
			node.Layout = XmdsUISystem.CreateLayoutFroXmlKey(path,style,clipsize)
		end
	else
		node.Layout = XmdsUISystem.CreateLayoutFromFile(path,style,clipsize)
	end
	if resize then 
		node.Size2D = node.Layout.PreferredSize
	end
end


local function SetBoxLayout(box, quality)
	local pathIndex = {5,56,57,58,59}
	HZSetImage(box, "#static_n/func/package.xml|package|" ..pathIndex[quality+1], false)
end

local function SetHeadImgByPro(icon, pro)
	HZSetImage(icon, "static_n/hud/target/" ..pro.. ".png", false)
end

local iconImgID = { 92, 94, 95, 90, 91 }
local function SetIconImagByPro(icon,pro)
	HZSetImage(icon, "#static_n/func/maininterface.xml|maininterface|" .. iconImgID[pro], false, LayoutStyle.IMAGE_STYLE_BACK_4, 8)
end 

local function SetLabelShortText(label, text)
	local maxW = label.Width
	local n = string.utf8len(text)
	label.Text = text
	while label.PreferredSize.x > maxW and n > 0 do
	    n = n - 1
	    label.Text = string.utf8sub(text, 1, n) .. '...'
	end
end

local function SetInputTextShortText(inputText, text)
	local maxW = inputText.Width
	local n = string.utf8len(text)
	local label = HZLabel.CreateLabel()
	inputText:AddChild(label)
	label.Text = text or ""
	while label.PreferredSize.x > 180 and n > 0 do
	    n = n - 1
	    label.Text = string.utf8sub(text, 1, n) .. '...'
	end
	inputText.Input.Text = label.Text
	label:RemoveFromParent(true)
end

local function CSharpStringformat(str,...)
	if select("#", ...) > 0 then
		local args = {...}
		str = string.gsub(str, "{(%d+)}", function(idx)
			return args[idx+1]
		end)
	end
	return str
end












local function GetText(type,key, ...)
	local str = ConfigMgr.Instance.TxtCfg:GetTextByKey(type, key)
	if select("#", ...) > 0 then
        str = _M.Format1234(str, ...)
	end
	return str
end

function _M.Format1234(str, ...)
    local args = {...}
    local str = string.gsub(str, "{(%d+)}", function(idx)
        return args[idx+1]
    end)
    return str
end

local function FormatABCD(format, ...)
	if select('#', ...) == 0 then
		return format
	end
	local args = {...}
	
	local str = string.gsub(format, "{([ABCDabcd])}", function(key)
		local code = string.byte(key) - 96
		if code < 0 then
			code = code + 32
		end
		return args[code]
	end)
	return str
end

local function StringSplit(str, delimiter)
	if str==nil or str=='' or delimiter==nil then
		return nil
	end
	
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

function _M.FormatKV(format, map)
    if not map then return format end
    local str = string.gsub(format, "{([a-zA-Z0-9]+)}", function(key)
        return map[key]
    end)
    return str
end

local function GetJsonText(type,key)
	return ConfigMgr.Instance.TxtCfg:GetJsonTxtByKey(type, key)
end



local function GetItemTypeTxt(mainType)
	local key = 'type'..mainType
	return GetText(TextConfig.Type.ITEM,key)
end

local function GetItemSecondTypeTxt(secondType)
	local ret = GlobalHooks.DB.Find('ItemIdConfig',secondType)
	if ret then
		return ret.TypeName
	else
		return ''
	end
end

local function GetProTxt(pro)
	local ret = GlobalHooks.DB.Find('Character',pro)
	return ret.ProName
	
end

local function GetQualityTxt(quality)
	local ret = GlobalHooks.DB.Find('ItemQualityConfig',quality)
	if ret then
		return ret.Name
	else
		return ''
	end
end

local function GetQualityColorRGBAStr(quality)
	local ret = GlobalHooks.DB.Find('ItemQualityConfig',quality)
	if ret then
		local rgba = string.sub(ret.Argb,3)..string.sub(ret.Argb,1,2)
		return rgba
	else
		return nil
	end
end

local function GetQualityColorARGBStr(quality)
	local ret = GlobalHooks.DB.Find('ItemQualityConfig',quality)
	if ret then
		return ret.Argb
	end	
end

local function GetQualityColorRGBA(quality)
	local ret = GlobalHooks.DB.Find('ItemQualityConfig',quality)
	if ret then
		local rgba = string.sub(ret.Argb,3)..string.sub(ret.Argb,1,2)
		return tonumber(rgba,16)
	else
		return 0
	end
end

local function GetQualityColorARGB(quality)
	local ret = GlobalHooks.DB.Find('ItemQualityConfig',quality)
	if ret then
		return tonumber(ret.Argb,16)
	else
		return 0
	end	
end

local function GetQualityConfig(quality)
	return GlobalHooks.DB.Find('ItemQualityConfig',quality) 
end

local function DictionaryToLuaTable(dict)
	if not dict then return {} end
  local params = {}
  local iter = dict:GetEnumerator()
  while iter:MoveNext() do
    local data = iter.Current
    params[data.Key] = data.Value
  end
  dict:Clear()
  return params
end








local function SetNodesToCenterStyle(w,cw,welt,nodes,change_y,start)
	local offet,pos 
	if welt then
		offet = GameUtil.GetWeltGridOffset(w,cw,start or 0,#nodes)
		pos = start
	else
  	offet = GameUtil.GetCenterGridOffset(w,cw,#nodes)
  	pos = offet
  end
  
  for _,comp in pairs(nodes) do
  	if change_y then
  		comp.Y = pos
  		pos = pos + comp.Bounds.Height + offet
  	else
  		comp.X = pos
  		pos = pos + comp.Bounds.width + offet
  	end
  end
end





local function ShowItemDetailByID(id, text, cb)
	local params = {id = id}
	if text and cb then
		local customBtn = {callback = cb, text = text}
		params.button1 = customBtn
	end
	EventManager.Fire('Event.ShowItemDetail',params)
end


local function ShowItemDetailByTempID(templateId, text, cb)
	local params = {templateId = templateId}
	if text and cb then
		customBtn = {callback = cb, text = text}
		params.button1 = customBtn
	end
	EventManager.Fire('Event.ShowItemDetail',params)
end

local function PomeloItem2ItemData(it)
	local item      = ItemData.Create()
	item.IconId     = it.picId
	item.Type       = it.type
	item.Num        = it.stackNum
	item.TemplateId = it.templateId
	item.Id         = it.id
	item.Quality    = it.quality
	item.IsNew      = (it.isNew == 1)
	item.SecondType = it.secondType
	return item
end

local function GetChildrenWithType(parent,t)
	local list = List2Luatable(XmdsUISystem.GetAllChildren(parent))
	local ret = {}
	for _,node in ipairs(list) do
		if typeof(node) == t then
			table.insert(ret,node)
		end
	end
	return ret
end

local function GetFirstChildWithType(parent, t)
	local list = List2Luatable(XmdsUISystem.GetAllChildren(parent))
	for _,node in ipairs(list) do
		if tostring(typeof(node)) == t then
			return node
		end
	end
	return nil
end

local function ForEachChild(parent,func)
	if not func then return end
	local list = XmdsUISystem.GetAllChildren(parent)
	local t = List2Luatable(list)
	for _,v in ipairs(t) do
		func(v)
	end
end

local function SetChildrenVisible(parent,visible)
	ForEachChild(parent,function (node)
		node.Visible = visible
	end)
end

local function RemoveChildrenWithType(parent,t)
	local its = GetChildrenWithType(parent, t)
	for _,n in ipairs(its) do
		n:RemoveFromParent(true)
	end
end

local function ShowItemShow(parent, icon, quality, num, force_shownum)
	local its = GetChildrenWithType(parent, 'HZItemShow')
	for i=2,#its do
		its[i]:RemoveFromParent(true)
	end
	local itemshow 
	if #its == 0 then
	  itemshow = HZItemShow.New(parent.Width,parent.Height)
	  parent:AddChild(itemshow)
  else
  	itemshow = its[1]
	end
	itemshow:SetItemData(nil)
	itemshow.IconID = icon
	itemshow.Quality = quality
	if num and force_shownum then
		itemshow.ForceNum = num
	else
		itemshow.Num = num or 1
	end
	
	return itemshow
end

local function ShowItemShowFromItemData(parent, it)
	local its = GetChildrenWithType(parent, 'HZItemShow')
	for _,n in ipairs(its) do
		n:RemoveFromParent(true)
	end
	local itemshow = HZItemShow.New(parent.Width,parent.Height)
	itemshow:SetItemData(it)
	parent:AddChild(itemshow)
	return itemshow
end

local function HZClick(node,fun)
	local click_tab = {
	node = node, 
	click = function (sender, e)
      fun(sender,e)
  end} 
 	LuaUIBinding.HZPointerEventHandler(click_tab)
end

local function NumberToShow(number)
    if number / 10^8 >1 then
        number = math.floor(number / 10^6)
        return(string.format("%.2f", number/10^2).._M.GetText(TextConfig.Type.GUILD, "guild_yi"))
    elseif number / 10^5 > 1 then
        number = math.floor(number / 10^2)
        return(string.format("%.2f", number/10^2).._M.GetText(TextConfig.Type.GUILD, "guild_wan"))
    else
        return number
    end
end

local function NumFormat(num,pos,sep)
	local num_str = tostring(num)
	local count = string.len(num_str)
	local ret = ''
	while count > pos do
		local str = string.sub(num_str,count-pos+1,count)
		ret = sep..str..ret
		count = count - pos
	end
	local str = string.sub(num_str,1,count)
	ret = str..ret
	return ret
end

local numFormat2Arr = nil
local numFormat2Arr2 = nil
local function NumFormat2(num)
	if num <= 0 then return tostring(num) end

	if not numFormat2Arr then
		
		local text = _M.GetText(TextConfig.Type.PUBLICCFG, "chinaNum")
		local arr = string.split(text, '|')
		local yi, wan, qian, bai, shi = unpack(arr)
		numFormat2Arr=   {shi, bai, qian, nil, shi, bai, qian, wan, nil, shi, bai, qian, wan}
		numFormat2Arr2 = {nil, nil, nil,  wan, nil, nil, nil, nil,  yi}
	end

	local list = {}
	print("num = ", num)
	for i = 0, #numFormat2Arr do
		local n = num % 10
		if numFormat2Arr2[i] then table.insert(list, numFormat2Arr2[i]) end
		if n > 0 then
			if numFormat2Arr[i] then table.insert(list, numFormat2Arr[i]) end
			table.insert(list, n)
		end
		num = math.floor(num / 10)
		if num <= 0 then break end
	end
	table.reverse(list)
	
	return table.concat(list, '')
end


local function WrapOOPSelf(ClassTable)
	ClassTable.__index = function (t, key)
	    if ClassTable[key] ~= nil then
	        return ClassTable[key]
	    end

	    if string.sub(key, 1, 6) == '_self_' then
	        local funcName = string.sub(key, 7)
	        local func = t[funcName]
	        if type(func) == "function" then
	            t[key] = function(...) return func(t, ...) end
	            return t[key]
	        end
	    end
	end
end

function _M.WrapCreateUI(ClassTable)
	ClassTable.Create = function(tag, params, ...)
	    local ui = {}
	    setmetatable(ui, ClassTable)
	    ui:init(tag, params, ...)
	    return ui
	end
end

local function GetRounding(a)
	local r1, r2 = math.modf(a, 1)
	r2 = r2 >= 0.5 and 1 or 0
	return r1 + r2
end

local uniqueInt = 0
local function GetUniqueInt()
	uniqueInt = uniqueInt + 1
	return uniqueInt
end

local function ShowItemDetailWithCtrl(ctrl, detaildata)
    local menu, obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISimpleDetail, -1,"1")
    obj.autoSide = true
    obj:SetItemDetail(detaildata)
    local cvs = obj.cvs_detailed
    local v = ctrl:LocalToGlobal()
    local v1 = cvs.Parent:GlobalToLocal(v, true)
    v1 = v1 + Vector2.New(ctrl.Width, ctrl.Height)
    if v1.x - ctrl.Width - cvs.Width > 15 then
        cvs.X = v1.x - cvs.Width - ctrl.Width - 10
    else
        cvs.X = v1.x + 10
    end
    cvs.Y = v1.y - cvs.Height
    return menu, obj
end

local function ShowItemDetailTips(itshow,detaildata)
  local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISimpleDetail,-1)
  obj:SetItemDetail(detaildata)

  itshow:SetCustomAttribute('detail_tips','true')	
  local cvs = obj.cvs_detailed
  local v  = itshow:LocalToGlobal()
  
  local v1 = cvs.Parent:GlobalToLocal(v,true) 
	v1 = v1 + Vector2.New(itshow.Width,itshow.Height * 0.5)

	if v1.x - itshow.Width - cvs.Width > 15 then
	  cvs.X = v1.x - cvs.Width - itshow.Width - 10
	else
	  cvs.X = v1.x + 10
	end

	cvs.Y = 150

  return menu,obj
end

local function NormalItemShowTouchClick(itshow,code,notenough,autoHide)
	if autoHide == nil then 
		autoHide = true
	end
	itshow.EnableTouch = true
	itshow.event_PointerDown = function (sender)
		itshow.IsSelected = true and (autoHide == true)	
		if not notenough then
			local detail = ItemModel.GetItemDetailByCode(code)
			ShowItemDetailTips(itshow,detail)
		end
	end
	itshow.event_PointerUp = function (sender)
		itshow.IsSelected = false
		if not notenough then
			if autoHide == true then
				GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUISimpleDetail)
			end
		else
			GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, code)
		end
	end
  
end

local function ItemShow_MandatoryBindTypeTouchClick(itshow,code, notenough ,changeBindType,detail)
	itshow.EnableTouch = true
    itshow.Enable = true
    itshow.EnableChildren = true
	itshow.event_PointerDown = function (sender)
		itshow.IsSelected = true	
		if not notenough then
			local detail = detail or ItemModel.GetItemDetailByCode(code)
			if detail.bindType then
				detail.bindType = changeBindType
			elseif detail.static.BindType then
				detail.static.BindType = changeBindType
			end
			ShowItemDetailTips(itshow,detail)
		end
	end
	itshow.event_PointerUp = function (sender)
		itshow.IsSelected = false
		if not notenough then
			GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUISimpleDetail)
		else
			GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIItemGetDetail, 0, code)
		end
	end
  
end

local function ItemshowExt(it, detail, isEquip)
  local function SetScoreUp(it)
    local pro = DataMgr.Instance.UserData.Pro
    local score_up_conf = it:GetNodeConfig(HZItemShow.CompType.score_up)

    if detail.equip.isIdentfied == 1 and detail.equip.pro == pro then 
      local cmp = ItemModel.GetLocalCompareDetail(detail.itemSecondType)    
      if not cmp then
        score_up_conf.Val = true        
      elseif cmp.equip.isIdentfied == 1 then
        score_up_conf.Val = cmp.equip.baseScore < detail.equip.baseScore
      else
        score_up_conf.Val = false       
      end
    else
      score_up_conf.Val = false
    end
  end
  if not detail then
    it.event_LongPoniterDown = nil
    it.event_PointerUp = nil
    it:RemoveCustomAttribute('detail_tips')
    return 
  end  
  
  

  local pro = DataMgr.Instance.UserData.Pro
  

  local red_limit = false
  local unidentify = false
  local score_up = false
  local bind = false
  if detail then
    if isEquip or (isEquip == nil and detail.equip ~= nil) then
      red_limit = detail.equip.pro ~= pro and detail.equip.pro ~= 0
      unidentify = detail.equip.isIdentfied ~= 1
      score_up = true
    end
    local bindType = detail.bindType or detail.static.BindType 
    bind = bindType == 1
  end

  it:SetNodeConfigVal(HZItemShow.CompType.red_limit,red_limit)
  it:SetNodeConfigVal(HZItemShow.CompType.unidentify,unidentify)
  it:SetNodeConfigVal(HZItemShow.CompType.bind,bind)
  if score_up then
    SetScoreUp(it)
  else
    it:SetNodeConfigVal(HZItemShow.CompType.score_up,score_up)
  end
end

local function GetUpLvTextAndColorRGBA(uplevel)
	local ret = unpack(GlobalHooks.DB.Find('UpLevelExp',{UpOrder=uplevel}))
	local rgba = GetQualityColorRGBA(ret.Qcolor)
	local name = ret.ClassName..ret.UPName
	return name,rgba
end

local function GetUpLvTextAndColorARGB(uplevel)
	local ret = unpack(GlobalHooks.DB.Find('UpLevelExp',{UpOrder=uplevel}))
	local argb = GetQualityColorARGB(ret.Qcolor)
	local name = ret.ClassName..ret.UPName
	return name,argb
end

local function HasBindLua(obj)
	local meta = getmetatable(obj)
	return meta['GetClassType'] ~= nil
end

local function CreateRichTextWithContext(width,fontSize,str)
    local ret = HZTextBox.New()
    ret.Size2D = Vector2.New(width, 80)
    ret.FontSize = fontSize
    ret.UnityRichText = str
    local txtH = ret.TextComponent.RichTextLayer.ContentHeight
    ret.Size2D = Vector2.New(width, txtH)
    return ret
end


function _M.widthString(inputstr)
    
    
    local lenInByte = #inputstr
    local width = 0
    local i = 1
    while
        (i <= lenInByte)
    do
        local curByte = string.byte(inputstr, i)
        local byteCount = 1;
        if curByte > 0 and curByte <= 127 then
            byteCount = 1
            
        elseif curByte >= 192 and curByte < 223 then
            byteCount = 2
            
        elseif curByte >= 224 and curByte < 239 then
            byteCount = 3
            
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4
            
        end

        local char = string.sub(inputstr, i, i + byteCount - 1)
        
        i = i + byteCount
        
        width = width + 1
        
    end
    return width
end




function _M.setMoveAction(displayNode,from,to,easeType,duration,callback)
    local tween = displayNode.UnityObject:GetComponent(typeof(uTools.uTweenPosition))
    if tween == nil then
        tween = displayNode.UnityObject:AddComponent(typeof(uTools.uTweenPosition))
    end
    local function destroy()
        if tween then
            GameObject.Destroy(tween)
            if callback then
                callback()
            end
        end
    end
    tween.form = from
    tween.easeType = easeType
    tween.to = to
    tween.duration = duration
    tween.factor = 0.5
    local finish = UnityEngine.Events.UnityEvent.New()
    local action = LuaUIBinding.UnityAction(destroy)
    finish:AddListener(action)
    tween.onFinished = finish
    tween:Play()
end


function _M.showUIEffect(displayNode,index)
    local transform = displayNode.Transform
    local props = GlobalHooks.DB.Find('EffectsConfig',{ID = index})
    if props then
        local prop = props[1]
        GameUtil.ShowUIEffect(transform,"/res"..prop.Path,prop.Scaling)
    end
end

function _M.clearUIEffect(displayNode,index)
    local transform = displayNode.Transform
    local props = GlobalHooks.DB.Find('EffectsConfig',{ID = index})
    if props then
        local prop = props[1]
        GameUtil.HideUIEffect(transform,"/res"..prop.Path)
    end
end

function _M.clearAllEffect(displayNode)
    local transform = displayNode.Transform
    GameUtil.HideAllUIEffect(transform)
end

function _M.getGuildPosition(pos)
    local retJob = GlobalHooks.DB.Find("GuildPosition", {})
    return retJob[pos]
end

function SerializeTab2Str(obj)  
    local lua = ""  
    local t = type(obj)  
    if t == "number" then  
        lua = lua .. obj  
    elseif t == "boolean" then  
        lua = lua .. tostring(obj)  
    elseif t == "string" then  
        lua = lua .. obj 
    elseif t == "table" then  
        local tabLength= 0
        for k, v in pairs(obj) do  
              tabLength = tabLength+1
        end
        local i =0
        for k, v in pairs(obj) do 
             i = i +1
             if i == tabLength then 
                   lua = lua .. SerializeTab2Str(k) .. ":" .. SerializeTab2Str(v)
             else
                   lua = lua .. SerializeTab2Str(k) .. ":" .. SerializeTab2Str(v) ..","
             end
        end
         local metatable = getmetatable(obj)  
            if metatable ~= nil and type(metatable.__index) == "table" then 
            for k, v in pairs(metatable.__index) do  
                lua = lua .. SerializeTab2Str(k) .. ":" .. SerializeTab2Str(v) .. ","  
            end  
        end  
    elseif t == "nil" then  
        return nil  
    else  
        error("不能序列化" .. t .. " type.")  
    end  
    return lua  
end  
  
 local function GetProName(pro)
      local proStr =""
      if pro == 1 then
            proStr = _M.GetText(TextConfig.Type.PUBLICCFG, "Berserker")
      elseif pro == 2 then
            proStr = _M.GetText(TextConfig.Type.PUBLICCFG, "Assassin")
      elseif pro == 3 then
            proStr = _M.GetText(TextConfig.Type.PUBLICCFG, "Magic")
      elseif pro == 4 then
            proStr = _M.GetText(TextConfig.Type.PUBLICCFG, "Hunter")
       else 
            proStr = _M.GetText(TextConfig.Type.PUBLICCFG, "Priest")
      end
      return proStr
 end

local function  GetServerNowDate(t)
    return os.date("%Y-%m-%d",t)
end

local function GetServerNowTime(t)
    return os.date("%H:%M:%S",t)
end

local function GetRealmStr()
    local realmStr = ""
    local num = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.REALM,0)
    num = num == nil and 0 or num
    local curRealm = GlobalHooks.DB.Find("UpLevelExp", {UpOrder = num})[1]
    local realmUpLevel = 0
    if curRealm == nil then
        realmStr = "0_0"
    else   
        realmStr =  curRealm.UpOrder.. "_" .. curRealm.ClassUPLevel
    end
    return realmStr
end

 function _M.GetBiTeamData()
 	local data = {}
    local teamData = DataMgr.Instance.TeamData
    if teamData.HasTeam == true then
        local list = _M.List2Luatable(teamData.TeamList)
        for i=1,#list do
            local mumberData = list[i].name .. "_" .. list[i].pro .. "_" .. list[i].level
            data[i] = mumberData
        end
    end

    return data
 end

 function _M.SendBIData(counter,value,kingdom,phylum,classfield,family,genus)
	BIHelper.SendPlayerData("counter" ,counter , "value" , value , "kingdom" ,kingdom ,"phylum", phylum,"classfield", classfield,"family", tostring(family), "genus", genus)
 end

_M.CreateRichTextWithContext = CreateRichTextWithContext
_M.HasBindLua = HasBindLua

_M.GetUpLvTextAndColorRGBA = GetUpLvTextAndColorRGBA
_M.GetUpLvTextAndColorARGB = GetUpLvTextAndColorARGB
_M.NormalItemShowTouchClick = NormalItemShowTouchClick
_M.ItemShow_MandatoryBindTypeTouchClick = ItemShow_MandatoryBindTypeTouchClick
_M.GetUniqueInt = GetUniqueInt


_M.List2Luatable = List2Luatable


_M.StringObjDict2LuaTable = StringObjDict2LuaTable

_M.ShowItemDetailTips = ShowItemDetailTips

_M.GetQualityConfig = GetQualityConfig
_M.GetQualityColorRGBA = GetQualityColorRGBA
_M.GetQualityColorRGBAStr = GetQualityColorRGBAStr
_M.GetQualityColorARGB = GetQualityColorARGB
_M.GetQualityColorARGBStr = GetQualityColorARGBStr

_M.GetRounding = GetRounding

_M.NumFormat = NumFormat

_M.NumFormat2 = NumFormat2

_M.CreateHZUICompsTable = CreateHZUICompsTable

_M.InitMultiToggleButton = MultiToggleButton
_M.ChangeMultiToggleButtonSelect = ChangeMultiToggleButtonSelect

_M.SetLabelShortText = SetLabelShortText

_M.SetInputTextShortText = SetInputTextShortText











_M.GetText = GetText

_M.CSharpStringformat = CSharpStringformat

_M.GetJsonText = GetJsonText

_M.FormatABCD = FormatABCD

_M.GetItemTypeTxt = GetItemTypeTxt

_M.GetItemSecondTypeTxt = GetItemSecondTypeTxt

_M.GetProTxt = GetProTxt

_M.GetQualityTxt = GetQualityTxt

_M.DictionaryToLuaTable = DictionaryToLuaTable







_M.SetNodesToCenterStyle = SetNodesToCenterStyle


_M.ShowItemDetailByID = ShowItemDetailByID


_M.ShowItemDetailByTempID = ShowItemDetailByTempID

_M.PomeloItem2ItemData = PomeloItem2ItemData


_M.ShowItemShow = ShowItemShow


_M.ShowItemShowFromItemData = ShowItemShowFromItemData

_M.HZSetImage = HZSetImage
_M.HZSetImage2 = HZSetImage2

_M.SetHeadImgByPro = SetHeadImgByPro
_M.SetIconImagByPro = SetIconImagByPro

_M.HZClick = HZClick
_M.StringSplit = StringSplit
_M.ShowItemDetailWithCtrl = ShowItemDetailWithCtrl

_M.ForEachChild = ForEachChild

_M.SetChildrenVisible = SetChildrenVisible

_M.RemoveChildrenWithType = RemoveChildrenWithType

_M.GetFirstChildWithType = GetFirstChildWithType

_M.NumberToShow = NumberToShow


_M.WrapOOPSelf = WrapOOPSelf
_M.ItemshowExt = ItemshowExt
_M.SetBoxLayout = SetBoxLayout
_M.FontColorGreen = GameUtil.RGBA2Color(0x00D600FF)
_M.FontColorWhite = GameUtil.RGBA2Color(0xE7E5D1FF)
_M.FontColorRed   = GameUtil.RGBA2Color(0xFF0000FF)
_M.FontColorBlue  = GameUtil.RGBA2Color(0x0000CCFF)
_M.FontColorOrange   = GameUtil.RGBA2Color(0xEF880EFF)
_M.ARGBGreen = 0xFF00D600
_M.ARGBWhite = 0xFFE7E5D1
_M.ARGBRed   = 0xFFFF0000
_M.RGBAGreen = 0x00D600FF
_M.RGBAWhite = 0xE7E5D1FF
_M.RGBARed   = 0xFF0000FF
return _M
