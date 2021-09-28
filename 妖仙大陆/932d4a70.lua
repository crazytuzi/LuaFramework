

local _M = {}
_M.__index = _M
local Util = require 'Zeus.Logic.Util'
local __NEW_FLAG__ = 0xff

local function GetComp(e, comp_id)
	return e:GetRootEvent():GetCacheduserdata(comp_id)
end

local function RemoveComp(e, comp_id)
	local node = GetComp(e, comp_id)
	if node and node.UserTag == __NEW_FLAG__ then	
		node:RemoveFromParent(true)
		e:GetRootEvent():RemoveCacheduserdata(comp_id)
	end
end

local function SaveComp(e, comp)
	local id = e:GetRootEvent():AddCacheduserdata(comp,'DisplayNode',{})
	
	return id
end

local function AddChild(parent,comp_id,child)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	comp:AddChild(child)
	child.UserTag = __NEW_FLAG__
	child.Name = 'drama_ui_'..comp_id..'_'..tostring(typeof(child))
	return SaveComp(parent,child)
end


local function SubscribMenuEnterExit(e, listen)
	local r = e:GetRootEvent()
	local menu_enter_exit = r:GetAttribute('menu_enter_exit')
	local function MenuOnEnter(tag)
		for _,v in ipairs(menu_enter_exit.enter_cbs or {}) do
			v(tag)
		end
	end

	local function MenuOnExit(tag)
		for _,v in ipairs(menu_enter_exit.exit_cbs or {}) do
			v(tag)
		end		
	end

	if menu_enter_exit then
		if not listen then
			DramaHelper.UnSubscribMenuEnterExit(menu_enter_exit.id)
			r:SetAttribute('menu_enter_exit',nil)
		end
	elseif listen then
		local id = DramaHelper.SubscribMenuEnterExit(MenuOnEnter,MenuOnExit)
		menu_enter_exit = {id = id}
		r:SetAttribute('menu_enter_exit',menu_enter_exit)
	end
	return menu_enter_exit
end


local function SubscribPointer(e, listen)
	local r = e:GetRootEvent()
	local function OnPointerDown(ename,params)
		r:ForeachCacheduserdata(function (id,obj,type_str,p)
			if type_str == 'DisplayNode' then
				local n = obj:GetAttribute('_Drama_ID_')
				if n and n == params.id and p.PointerDown then
					p.PointerDown()
				end
			end
		end)
	end
	local function OnPointerClick(ename,params)
		r:ForeachCacheduserdata(function (id,obj,type_str,p)
			if type_str == 'DisplayNode' then
				local n = obj:GetAttribute('_Drama_ID_')
				if n and n == params.id and p.PointerClick then
					p.PointerClick()
				end
			end
		end)	
	end

	if r:HasAttribute('event_pointer')  then
		if not listen then
			EventManager.Unsubscribe('Event.DramaHelper.PointerDown',OnPointerDown)
			EventManager.Unsubscribe('Event.DramaHelper.PointerClick',OnPointerClick)
		end
	elseif listen then
		EventManager.Subscribe('Event.DramaHelper.PointerDown',OnPointerDown)
		EventManager.Subscribe('Event.DramaHelper.PointerClick',OnPointerClick)
	end
end

function _M._asyncWaitMenuEnter(self,key,not_opened)
	if not not_opened then
		if (type(key) == 'string' and MenuMgrU.Instance:FindMenuByXml(key)) or
			 (type(key) == 'number' and MenuMgrU.Instance:FindMenuByTag(key)) then
			self:Done()
			return
		end
	end

	local v = SubscribMenuEnterExit(self,true)
	v.enter_cbs	= v.enter_cbs or {}
	table.insert(v.enter_cbs,function (tag)
		if type(key) == 'number' and tag == key then
			self:Done()
		elseif type(key) == 'string' then
			local menu = GlobalHooks.FindUI(tag)
			if menu and menu.XML_PATH == key then
				self:Done()
			end
		end
	end)
	self:Await()
end

function _M._asyncWaitMenuExit(self,key,opened)
	if not opened then
		if (type(key) == 'string' and not MenuMgrU.Instance:FindMenuByXml(key)) or
			 (type(key) == 'number' and not MenuMgrU.Instance:FindMenuByTag(key)) then
			self:Done()
			return
		end
	end

	local v = SubscribMenuEnterExit(self,true)
	v.exit_cbs	= v.exit_cbs or {}
	table.insert(v.exit_cbs,function (tag)
		if type(key) == 'number' and tag == key then
			self:Done()
		elseif type(key) == 'string' then
			local menu = GlobalHooks.FindUI(tag)
			if menu and menu.XML_PATH == key then
				self:Done()
			end
		end
	end)
	self:Await()	
end

function _M.CloneComponent(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	local clone = comp:Clone()
	clone.UserTag = __NEW_FLAG__
	return SaveComp(parent,clone)
end

function _M.AddChild(parent,comp_id,child_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	local child = GetComp(parent,child_id)
	comp:AddChild(child)
end

function _M.RemoveComponent(parent,comp_id)
	RemoveComp(parent,comp_id)
end

function _M.SetName(parent,comp_id, name)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	comp.Name = name
end

function _M.SetImage(parent,comp_id, name)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	comp.Name = name
end

function _M.AddUEButtonTo(parent,comp_id)
	return AddChild(parent,comp_id,HZTextButton.CreateTextButton())
end

function _M.AddUEToggleButtonTo(parent,comp_id)
	return AddChild(parent,comp_id,HZToggleButton.New())	
end

function _M.AddUEImageTo(parent,comp_id)
	return AddChild(parent,comp_id,HZImageBox.New())
end

function _M.AddUETextBoxTo(parent,comp_id)
	return AddChild(parent,comp_id,HZTextBox.New())
end

function _M.AddUELabelTo(parent,comp_id)
	return AddChild(parent,comp_id,HZLabel.CreateLabel())
end

function _M.AddItemShowTo(parent,comp_id,icon,quality,num)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	local itshow = Util.ShowItemShow(comp,icon,quality,num)
	itshow.UserTag = __NEW_FLAG__
	return SaveComp(parent,itshow)
end
function _M.CheckCompValid(parent,comp_id)
	local comp = GetComp(parent,comp_id) 
	return comp ~= nil
end

function _M.SetTextAnchor(parent,comp_id,anchor)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	local name = tostring(typeof(comp))
	if name == 'CommonUnity3D.UGUIEditor.UI.HZLabel' then
		comp.EditTextAnchor = anchor
	elseif name == 'CommonUnity3D.UGUIEditor.UI.HZTextBox' then
		comp.TextComponent.Anchor = anchor
	elseif name == 'CommonUnity3D.UGUIEditor.UI.HZTextBoxHtml' then
		comp.TextComponent.Anchor = anchor
	elseif name == 'CommonUnity3D.UGUIEditor.UI.HZTextButton' then
		com.EditTextAnchor = anchor
	elseif name == 'CommonUnity3D.UGUIEditor.UI.HZToggleButton' then
		com.EditTextAnchor = anchor
	end
end 

function _M.SetText(parent,comp_id,text,rgba)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	local name = tostring(typeof(comp))
  if name == 'CommonUnity3D.UGUIEditor.UI.HZLabel' then
    comp.Text = text
    if rgba then
	    comp.FontColorRGBA = rgba
	  end
  elseif name == 'CommonUnity3D.UGUIEditor.UI.HZTextBoxHtml' or 
  	     name == 'CommonUnity3D.UGUIEditor.UI.HZTextBox' then
    comp.XmlText = string.format("<f>%s</f>",text)
    if rgba then
	    comp.FontColor = GameUtil.RGB2Color(rgba)
	  end
  elseif name == 'CommonUnity3D.UGUIEditor.UI.HZTextButton' or
  			 name == 'CommonUnity3D.UGUIEditor.UI.HZToggleButton' then
    comp.Text = text
    if rgba then
	    comp.FontColor = GameUtil.RGB2Color(rgba)
	    comp.FocuseFontColor = GameUtil.RGB2Color(rgba)
	  end
  end
end














function _M.SetImage(parent,comp_id,img_path)
	local node = GetComp(parent,comp_id)
	if not node then return end
	local style =  (node.Layout and node.Layout.Style) or LayoutStyle.IMAGE_STYLE_BACK_4_CENTER
	local clipsize = (node.Layout and node.Layout.ClipSize) or 8
	if string.sub(img_path,1,1) == '#' then
		node.Layout = XmdsUISystem.CreateLayoutFroXml(img_path,style,clipsize)
	else
		node.Layout = XmdsUISystem.CreateLayoutFromFile(img_path,style,clipsize)
	end
end


function _M.SetAlpha(parent,comp_id,alpha)
	local node = GetComp(parent,comp_id)
	if not node then return end
	node.Alpha = alpha
end

function _M.SetScaleX(parent,comp_id,scale)
	local node = GetComp(parent,comp_id)
	if not node then return end
	node.Scale = Vector2.New(scale,node.Scale.y)
end

function _M.SetScaleY(parent,comp_id,scale)
	local node = GetComp(parent,comp_id)
	if not node then return end
	node.Scale = Vector2.New(node.Scale.x,scale)
end

function _M.SetScale(parent,comp_id,scale)
	local node = GetComp(parent,comp_id)
	if not node then return end
	node.Scale = Vector2.New(scale,scale)
end

function _M.SetVisible(parent,comp_id,visible)
	local comp = GetComp(parent,comp_id)
	if comp and GameUtil.IsGameObjectExists(comp.UnityObject) and visible ~= nil then
		comp.Visible = visible
	end
end

function _M.GetChildrenCount(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	return comp.NumChildren
end

function _M.GetParent(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	if comp.Parent then
		return SaveComp(parent,comp.Parent)
	else
		return nil
	end
end

function _M.GetEditName(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
  return comp.EditName
end

function _M.GetName(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	return comp.Name
end

function _M.GetPosX(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	return comp.X
end

function _M.GetPosY(parent,comp_id,y)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	return comp.Y
end

function _M.GetPos(parent,comp_id,x,y)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	return comp.X,comp.Y
end

function _M.SetPosX(parent,comp_id,x)
	local comp = GetComp(parent,comp_id)
	if not comp then return end
	comp.X = x
end

function _M.GetUserTag(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	return comp.UserTag
end

function _M.GetText(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	if not Util.HasBindLua(comp) then return end
	local str_type = tostring(typeof(comp))
  if str_type == 'CommonUnity3D.UGUIEditor.UI.HZLabel' or
  	str_type == 'CommonUnity3D.UGUIEditor.UI.HZTextButton' or
  	str_type == 'CommonUnity3D.UGUIEditor.UI.HZToggleButton' then
    return comp.Text
  end
end

function _M.GetClassType(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	return tostring(typeof(comp))
end

function _M.SetPosY(parent,comp_id,y)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	comp.Y = y
end

function _M.SetPos(parent,comp_id,x,y)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	if comp and GameUtil.IsGameObjectExists(comp.UnityObject) then
		comp.Position2D = Vector2.New(x,y)
	end
end

function _M.SetWidth(parent,comp_id,w)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	comp.Width = w
end

function _M.SetHeight(parent,comp_id,h)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	comp.Height = h
end

function _M.SetSize(parent,comp_id,w,h)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	comp.Size2D = Vector2.New(w,h)
end

function _M.SetSiblingIndex(parent,comp_id,index)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	comp:SetParentIndex(index)
end
function _M.GetWidth(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	return comp.Width
end

function _M.GetHeight(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	return comp.Height
end

function _M.GetSize(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	return comp.Width,comp.Height
end

function _M.GetTranform(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	local r = parent:GetRootEvent()
	local ret = r:AddCacheduserdata(comp.Transform, 'UnityEngine.RectTransform')
	return ret
end

function _M.IsChecked(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	return comp.IsChecked
end

function _M.IsEnable(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	return comp.Enable
end

function _M.IsVisible(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	return comp.Visible
end

function _M.SetTransformAnchor(parent,comp_id,min,max)
	local comp = GetComp(self,comp_id)
	if not comp then return end 
	comp.Transform.anchorMin = min
	comp.Transform.anchorMax = max
end

function _M.SetTransformOffset(parent,comp_id,min,max)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	comp.Transform.offsetMin = min
	comp.Transform.offsetMax = max
end

function _M.ToLocalPostion(parent,comp_a,comp_b)
	local a = GetComp(parent,comp_a)
	if not a then return end
	local b = GetComp(parent,comp_b)
	
	if a.UnityObject and b.UnityObject then
		local v = XmdsUISystem.ToLocalPostion(a,Vector2.zero,b)
		return v.x,v.y		
	end
end

function _M.ToMFUIPosition(parent,v)
	if not v then return end
	return Vector2.New(v.x, -v.y)
end


function _M.AdjustByImageAnchor(parent,comp_id,anchor,offset)
	local UIUtils = CommonUnity3D.UGUI.UIUtils
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	offset = offset or Vector2.zero
	UIUtils.AdjustAnchor(anchor,comp.Parent,comp,offset)
end


function _M._asyncAddAction(self,comp_id,actName,params)
	local comp = GetComp(self,comp_id)
	if not comp then return end 
	local function CallBack(delta)
		local action 
		if actName == 'FadeAction' then
			action = FadeAction.New()	
			action.TargetAlpha = params.TargetAlpha
			action.ActionFinishCallBack = function(sender)
				self:Done()
			end
		elseif actName == 'MoveAction' then
			action = MoveAction.New()
			action.TargetX = params.TargetX
			action.TargetY = params.TargetY
			action.ActionFinishCallBack = function(sender)
				self:Done()
			end			
		elseif actName == 'ScaleAction' then
			action = ScaleAction.New()
			action.ScaleX = params.ScaleX or params.Scale or 1
			action.ScaleY = params.ScaleY or params.Scale or 1
			local pos = comp.Position2D
			local s = comp.Size2D
			comp.Position2D = Vector2.New(pos.x + s.x * 0.5, pos.y + s.y * 0.5)
			comp.Size2D = Vector2.zero
			action.ActionFinishCallBack = function(sender)
				comp.Position2D = pos
				comp.Size2D = s
				self:Done()
			end
		end

		action.Duration = params.Duration
		comp:AddAction(action)
	end
	self:AddTimer(CallBack,0,true)
	self:Await()
end


function _M.SetAnimation(parent,comp_id,path)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	local ly = XmdsUISystem.CreateLayoutFromCpj(path)
	if ly and comp then
		comp.Layout = ly
	end
end

function _M._asyncPlayAnimation(self,comp_id,loop)
	local comp = GetComp(self,comp_id)
	if not comp then return end 
	local control = comp.Layout.SpriteController
	self:AddTimer(function (delta)
		
		if loop then
			control:PlayAnimate(0, -1, function (sender) end)
			self:Done() 
		else	
			control:PlayAnimate(0, 1, function (sender) 
				self:Done()
			end)		
		end
	end,0,true)	
	self:Await()
end

function _M._asyncShowUIEffect(self,comp_id,effect_id,duration)
	local comp = GetComp(self,comp_id)
	if not comp then return end 
	Util.showUIEffect(comp,effect_id)
	if duration >= 0 then
		self:AddTimer(function (delta)
			Util.clearUIEffect(comp,effect_id)
			self:Done()
		end,duration,true)
	else
		self:Done()
	end
	self:Await()
end

function _M._asyncClearUIEffect(self,comp_id,effect_id)
	local comp = GetComp(self,comp_id)
	if not comp then return end 
	Util.clearUIEffect(comp,effect_id)
	self:Await()
end

function _M.SetActivityEffectId(self,id)
	EventManager.Fire('Event.Activity.PushEffectEvent',{ActivityId = id})
end

local function FindChild(parent,comp, iter,recursive)
	local function check(child,k,v)
		return child[k] == v
	end
	if type(iter) == 'table' then
	 return MenuBaseU.FindComponentAs(comp,function (child)
			for k,v in pairs(iter) do
				local state,ret = pcall(check, child,k,v)
				if not state or not ret then
					return false
				end
			end
			return true
		end,recursive or true)
	elseif type(iter) == 'string' then
		return MenuBaseU.FindChildComponent(comp,iter)
	elseif type(iter) == 'function' then
		return MenuBaseU.FindComponentAs(comp,function (child)
			return iter(SaveComp(parent,child))
		end,true)		
	else
		local list = XmdsUISystem.GetAllChildren(comp)
		local t = Util.List2Luatable(list)
		return t[1]
	end
end

function _M.FindChild(parent,comp_id,iter)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	local child
	parent:AddTimer(function (delta)
		child = FindChild(parent,comp,iter)
	end,0,true)
	parent:Await(0)
	if child then
		return SaveComp(parent,child)
	end
end


local function MatchInTable(a,b)
	for k,v in pairs(b or {}) do
		if type(v) == 'table' then
			if not MatchInTable(a[k],v) then
				return false
			end
		elseif a[k] ~= v then
			return false
		end
	end	
	return true
end


function _M.FindItemShow(parent,comp_id,find_iter)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	local itshow
	parent:AddTimer(function (delta)
		local all = {}
		itshow = MenuBaseU.FindComponentAs(comp,function (child)
			local ret = false
			if tostring(typeof(child)) == 'HZItemShow' then
				if child.LastItemData then
					local detail = child.LastItemData.detail
					if find_iter then
						ret = MatchInTable(detail,find_iter)
					else
						table.insert(all,child)
					end
				end
			end
			return ret
		end,true)
		
		if not find_iter and #all > 0 then
			itshow = all[1]
		end

	end,0,true)
	parent:Await(0)
	if itshow then
		return SaveComp(parent,itshow)
	end
end

function _M.FindFirstItemShow(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	local itshow
	parent:AddTimer(function (delta)
		itshow = MenuBaseU.FindComponentAs(comp,function (child)
			local ret = false
			if tostring(typeof(child)) == 'HZItemShow' then
				if child.LastItemData then
					itshow = child
					ret = true     
				end
			end
			return ret
		end,true)
	end,0,true)
	parent:Await(0)
	if itshow then
		return SaveComp(parent,itshow)
	end
end

function _M.IsItemShowFilled(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end
	if comp.IconID then
		return true
	else
		return false
	end	
end


function _M.IsItemShowSelected(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end
	return comp.IsSelected	
end

function _M.ExistWaitingUI(parent)
	return GameAlertManager.Instance.IsWaiting
end

function _M.FindHudComponent(parent,tag,path)
	local hud = HudManagerU.Instance:FindByXmlName(tag)
	local child = MenuBaseU.FindChildComponent(hud,path)
	if child then
		return SaveComp(parent,child)
	end
end

function _M.EntryMenuOpen(parent)
	return HudManagerU.Instance.HeroInfo.IsEntryMenuOpen
end

function _M.FindCurrencyChild(parent,path)
	local hud = XmdsUISystem.Instance:UILayerFindChildByName("MenuBase - 11003",true)
	local child = MenuBaseU.FindChildComponent(hud,path)
	if child then
		return SaveComp(parent,child)
	end
end

function _M.FindAlertComponent(parent,tag,path)
	local layer = GameAlertManager.Instance:FindByXmlName(tag)
	local child = MenuBaseU.FindChildComponent(layer,path)
	if child then
		return SaveComp(parent,child)
	end
end


function _M.FindComponent(parent,tag,path)
	local menu
	
	if type(tag) == 'number' then
		menu = parent:GetRootEvent():GetCacheduserdata(tag)
	elseif type(tag) == 'string' then
		menu = MenuMgrU.Instance:FindMenuByXml(tag)
	end
	
	if menu then
		local root
		if tostring(typeof(menu)) == 'MenuBaseU' or tostring(typeof(menu)) == 'LuaMenuU' then
			root = menu.mRoot
		else
			root = menu
		end
	  	local comp = MenuBaseU.FindChildComponent(root,path)
	  	if comp then 		
	  		return SaveComp(parent,comp)
	  	end
	end
	return nil
end

function _M.FindChildByCom(parent,comp_id,path)
	local comp = GetComp(parent,comp_id)
	if not comp then return nil end 
	return SaveComp(parent,comp:FindChildByEditName(path, true))
end

function _M.GetUIRoot(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	local p = comp.Parent
	while p do
		if tostring(typeof(p)) == 'CommonUnity3D.UGUIEditor.UI.HZRoot' then
			break
		end
		p = p.Parent
	end
	return SaveComp(parent,p)
end

function _M.GetChildAt(parent,comp_id,index)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	return SaveComp(parent,comp:GetChildAt(index))
end

function _M.IsValid(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	if not comp then return end 
	if GameUtil.IsGameObjectExists(comp.UnityObject) then
		return DramaHelper.CheckGameObjectRaycast(comp.UnityObject)
	end
end

function _M.DoPointerClick(parent,comp_id)
	local comp = GetComp(parent,comp_id)
	DramaHelper.DoPointerClick(comp)
end

function _M._asyncPointerClick(self,comp_id,func)
	local comp,type_str,p = GetComp(self,comp_id)
	if not comp then return end 
	DramaHelper.PointerClick(comp)
	SubscribPointer(self,true)
	p.PointerClick = function ()
		if func then
			func(comp_id)
		end
		p.PointerClick = nil
		self:Done()
	end
	self:Await()
end

function _M._asyncPointerDown(self,comp_id,func)
	local comp,type_str,p = GetComp(self,comp_id)
	if not comp then return end 
	DramaHelper.PointerDown(comp)
	SubscribPointer(self,true)
	p.PointerDown = function ()
		if func then
			func(comp_id)
		end
		p.PointerDown = nil
		self:Done()
	end
	self:Await()	
end














function _M.HasTeam(parent)
    return DataMgr.Instance.TeamData.HasTeam
end

function _M.OpenUIByXml(parent,xml,cache)
	local ui = GlobalHooks.OpenCustomUI(xml,cache)
	local ret = parent:GetRootEvent():AddCacheduserdata(ui.menu,'MenuBaseU')
	
	ui:AddExitEvent(function (self)
		parent:GetRootEvent():RemoveCacheduserdata(ret)
	end)
	return ret
end

function _M.CreateNodeFromXml(parent,xml)
	local root = XmdsUISystem.CreateFromFile(xml)
	if root then
		root.UserTag = __NEW_FLAG__
		return SaveComp(parent,root)
	end
end

function _M.AddDramaLayerUI(parent,xml)
	local root = DramaUIManage.Instance:AddDramaUI(xml)
	if root then
		root.UserTag = __NEW_FLAG__
		return SaveComp(parent,root)
	end
end

function _M.OpenSkinChoiceUI(parent)
	EventManager.Fire('Event.OpenUI.OpenSkinChoiceUI',{})
end

function _M.CloseUI(parent,menu_id)
	local menu,type_str = parent:GetRootEvent():GetCacheduserdata(menu_id)
	if type_str == 'MenuBaseU' then
		menu:Close()
	end
end

function _M.HideUGUI(parent,var)
	local r = parent:GetRootEvent()
	local env = r:GetAttribute('__env')
	if not r:HasAttribute('HideUGUI') and var then	
		env.HideUGUI(true)
		r:SetAttribute('HideUGUI',true)
	elseif not var then
		env.HideUGUI(false)
		r:SetAttribute('HideUGUI',nil)
	end	
end

function _M.HideUGUITextLabel(parent,var)
	local r = parent:GetRootEvent()
	local env = r:GetAttribute('__env')
	if not r:HasAttribute('HideUGUITextLabel') and var then	
		env.HideUGUITextLabel(true)
		r:SetAttribute('HideUGUITextLabel',true)
	elseif not var then
		env.HideUGUITextLabel(false)
		r:SetAttribute('HideUGUITextLabel',nil)
	end	
end

function _M.HideUGUIHpBar(parent,var)
	local r = parent:GetRootEvent()
	local env = r:GetAttribute('__env')
	if not r:HasAttribute('HideUGUIHpBar') and var then	
		env.HideUGUIHpBar(true)
		r:SetAttribute('HideUGUIHpBar',true)
	elseif not var then
		env.HideUGUIHpBar(false)
		r:SetAttribute('HideUGUIHpBar',nil)
	end	
end

function _M.HideAllHud(parent,var)
    HudManagerU.Instance:HideAllHud(var);











end

function _M.HideMFUI(parent,var)
	local r = parent:GetRootEvent()
	local env = r:GetAttribute('__env')
	if not r:HasAttribute('HideMFUI') and var then	
		env.HideMFUI(true)
		r:SetAttribute('HideMFUI',true)
	elseif not var then
		env.HideMFUI(false)
		r:SetAttribute('HideMFUI',nil)
	end
end

function _M.HideAllMenu(parent,var)
	local r = parent:GetRootEvent()
	local env = r:GetAttribute('__env')
	if not r:HasAttribute('HideAllMenu') and var then	
		env.HideAllMenu(true)
		r:SetAttribute('HideAllMenu',true)
	elseif not var then
		env.HideAllMenu(false)
		r:SetAttribute('HideAllMenu',nil)
	end
end

function _M.CloseAllMenu(parent)
	MenuMgrU.Instance:CloseAllMenu()
end

function _M.Clear(parent)

	SubscribPointer(parent,false)
	SubscribMenuEnterExit(parent,false)

	local r = parent:GetRootEvent()

	r:ForeachCacheduserdata(function (id,obj,type_str)
		if type_str == 'MenuBaseU' and obj.Tag >= GlobalHooks.UITAG.GameUICustomStart and obj.IsRunning then
			local lua_obj = obj.LuaTable
			lua_obj:RemoveAllExitEvent()
			obj:Close()
			r:RemoveCacheduserdata(id)
		elseif type_str == 'DisplayNode' then
			if not obj.IsDispose and  obj.UserTag == __NEW_FLAG__ then
				if obj.Parent then
					obj:RemoveFromParent(true)
				else
					obj:Dispose()
				end
				r:RemoveCacheduserdata(id)
			end				
		end
	end)

	local env = r:GetAttribute('__env')
	if r:HasAttribute('HideAllMenu') then
		env.HideAllMenu(false)
	end
	if r:HasAttribute('HideAllHud') then
		env.HideAllHud(false)
	end

	if r:HasAttribute('HideUGUI') then
		env.HideUGUI(false)
	end

	if r:HasAttribute('HideUGUITextLabel') then
		env.HideUGUITextLabel(false)
	end

	if r:HasAttribute('HideUGUIHpBar') then
		env.HideUGUIHpBar(false)
	end

	if r:HasAttribute('HideMFUI') then
		env.HideMFUI(false)
	end	
end

return _M
