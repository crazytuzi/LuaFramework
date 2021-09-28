

  
  
  
  
  
  
local _M = {}
_M.__index = _M

local handPath = '@dynamic_n/effects/hand/hand.xml|hand|hand|0'

local api


function _M.FollowUnit(uid)
	local name = 'FollowUnit'..uid
	api.RemoveTimer(name)
	api.AddTimer(name,function ()
		local x,y = api.World.GetUnitPos(uid)
		api.Camera.SetPosition(x,y)
	end)
end

function _M.AddUnit(id, x, y)
	local t = {
		"Sequence",
		{"LoadTemplate",{id = id}},
		{"Position",{x = x,y = y}},
		{"Birth"}
	}
	local uid = api.World.CreateUnit()
	api.World.RunAction(uid, t) 
	return uid
end


function _M.MoveCamera(fx, fy, tx, ty, dura, ease)
	local t = 0
	local dx = tx - fx
	local dy = ty - fy
	local et,cx,cy
	local move = api.AddPeriodicTimer(0,function(delta)
		t = t + delta / dura
		et = _M.Ease(t,ease)	
		cx = et * dx + fx
		cy = et * dy + fy
		api.Camera.SetPosition(cx,cy)
	end)
	api.Sleep(dura)
	api.RemoveTimer(move)
end


function _M.RotateCamera(fx, fy, fz, tx, ty, tz, dura, ease)
	local t = 0
	local dx = tx - fx
	local dy = ty - fy
	local dz = tz - fz
	local et,cx,cy,cz
	local move = api.AddPeriodicTimer(0,function(delta)
		t = t + delta / dura
		et = _M.Ease(t,ease)	
		cx = et * dx + fx
		cy = et * dy + fy
		cz = et * dz + fz
		api.Camera.SetEulerAngles(cx,cy,cz)
	end)
	api.Sleep(dura)
	api.RemoveTimer(move)
end


function _M.CameraLookAt(fx,fy, fradius, tx,ty,toh, dura, ease)
	local t = 0
	local fax,fay,faz = api.Camera.GetEulerAngles()
	local hc = api.Camera.GetHeight()
	local xc,yc = fx - fradius * math.sin(math.rad(fay)), fy - fradius * math.cos(math.rad(fay))
	local tay = math.deg(math.atan((tx - xc) /(ty - yc)))
	local distance = math.sqrt((tx - xc)*(tx - xc) + (ty - yc)*(ty - yc))
	local tax = math.deg(math.atan((hc - toh)/distance))
	local dax = tax - fax
	local day = tay - fay
	local et,cax,cay
	local move = api.AddPeriodicTimer(0,function(delta)
		t = t + delta / dura
		et = _M.Ease(t,ease)
		cax = et * dax + fax
		cay = et * day + fay
		api.Camera.SetEulerAngles(cax,cay,faz)
	end)
	api.Sleep(dura)
	api.RemoveTimer(move)
end


function _M.LiftCamera(fh, th, dura, ease)
	local t = 0
	local dh = th - fh
	local et,ch
	local move = api.AddPeriodicTimer(0,function(delta)
		t = t + delta / dura
		et = _M.Ease(t,ease)			
		ch = et * dh + fh
		api.Camera.SetHeight(ch)
	end)
	api.Sleep(dura)
	api.RemoveTimer(move)
end


function _M.AroundCamera(ox, oy, oh, fa, ta, fh, th, radius, dura, ease)
	local t = 0
	local da = ta - fa
	local dh = th - fh
	local et,ca,ch
	local cpitch
	local move = api.AddPeriodicTimer(0,function(delta)
		t = t + delta / dura
		et = _M.Ease(t,ease)	
		ca = et * da + fa
		ch = et * dh + fh
		api.Camera.SetPosition(ox + radius * math.sin(ca),oy + radius * math.cos(ca))
		api.Camera.SetHeight(ch)
		cpitch = math.atan((ch - oh) / radius)
		api.Camera.SetEulerAngles(math.deg(cpitch),-math.deg(ca) % 360, 0)
	end)
	api.Sleep(dura)
	api.RemoveTimer(move)
end


function _M.ComplexCamera(fox, foy, foh, tox, toy, toh, fa, ta, fh, th, fr, tr, ft, tt, dura, ease)
	local t = 0
	local dox = tox - fox
	local doy = toy - foy
	local doh = toh - foh
	local da = ta - fa
	local dh = th - fh
	local dt = tt - ft
	local dr = tr - fr
	local et,cox,coy,coh,ca,ch,ct,cr
	local cpitch = 0
	local move = api.AddPeriodicTimer(0,function(delta)
		t = t + delta / dura
		et = _M.Ease(t,ease)	
		ca = et * da + fa
		ch = et * dh + fh
		ct = et * dt + ft
		cr = et * dr + fr
		cox = et * dox + fox
		coy = et * doy + foy
		coh = et * doh + foh
		api.Camera.SetPosition(cox + cr * math.sin(ca), coy + cr * math.cos(ca))
		api.Camera.SetHeight(ch)
		cpitch = math.atan((ch - coh) / cr)
		api.Camera.SetEulerAngles(math.deg(cpitch),-math.deg(ca) % 360, ct)
	end)
	api.Sleep(dura)
	api.RemoveTimer(move)
end

function _M.Ease(n, ease)
	if ease == 1 then
		n = n * n
	elseif ease == 2 then
		n = n * (2 - n)
	elseif ease == 3 then
		n = n * 2
		if n < 1 then 
			n = 0.5 * n * n
		else 
			n = n - 1
			n = 0.5 * (1 - n * (n - 2))
		end
	end
	return n
end


function _M.StopFollowUnit(uid)
	local name = 'FollowUnit'..uid
	api.RemoveTimer(name)
end


function _M.Dead(uid,second)
	local t =  {
		'Sequence',
		{"Animation",{name='f_dead'}},
		{"Delay",{delay=second}},
	}
	return api.World.RunAction(uid, t) 
end


function _M.SetName(uid,name,force)
	local t = {
		'Sequence',
		{'AddInfoBar',{force=force}},
		{'ChangeName',{name=name}}
	}
	api.Wait(api.World.RunAction(uid, t))
end


function _M.MoveToWithAnim(uid,ani_name,x,y,speed)
	local t = {
		'Parallel',
		{'Animation',{name='n_action1',loop=true}},
		{'MoveTo',{x=x,y=y,speed=speed,noAnimation=true}}
	}
	return api.World.RunAction(uid,t)
end

function _M.AddUIArrow(target)
	local arrow = api.UI.AddUEImageTo(target)

	
	
	local isTransform = api.RectTransform.IsTransform(target)
	local target_trans = isTransform and target or api.UI.GetTranform(target)
	api.SetHandAnimation(target_trans)
	
	local w,h = api.UI.GetSize(target)
	api.UI.SetSize(arrow,w,h)	
	return arrow
end

function _M.BlockUITouch(node,alpha)
	local trans = api.UI.GetTranform(node)
	api.SetBlockTouch(true,trans,alpha)
end

function _M.AddCenterTextFrame(text)
	local ui = api.UI.OpenUIByXml('xmds_ui/tips/tips_guide.gui.xml',true)
	local tb_guide = api.UI.FindComponent(ui,'tb_guide')
	local cvs_guide = api.UI.FindComponent(ui,'cvs_guide')
	local root = api.UI.GetParent(cvs_guide)
	local w,h = api.UI.GetSize(cvs_guide)
	local rw,rh = api.UI.GetSize(root)
	
	api.UI.SetTextAnchor(tb_guide,TextAnchor.L_C)
	api.UI.SetText(tb_guide,text)
	api.UI.SetPos(cvs_guide,(rw-w)*0.5,(rh-h)*0.5)
	return ui
end

function _M.AddTextFrame(target,text)
	local ui = api.UI.OpenUIByXml('xmds_ui/tips/tips_guide.gui.xml',true)
	local tb_guide = api.UI.FindComponent(ui,'tb_guide')
	local cvs_guide = api.UI.FindComponent(ui,'cvs_guide')

	api.UI.SetTextAnchor(tb_guide,TextAnchor.L_C)
	api.UI.SetText(tb_guide,text)
	local space = 10
	local x,y = api.UI.ToLocalPostion(target,api.UI.GetParent(cvs_guide))
	if x and y then	
		local guide_w,guide_h = api.UI.GetSize(cvs_guide)
		local w,h = api.UI.GetSize(target)
		if x  > 700 then
			
			x = x-guide_w-space	
		else
			x = x+w+space
		end
		if y > 400 then
			y = y-guide_h-space
		end
		api.UI.SetPos(cvs_guide,x,y)
	end
	return ui
end

function _M.AddQuestHudGuide(id,force,text)
	local name = api.Quest.GetName(id)
	local comp = api.UI.FindHudComponent('xmds_ui/hud/hud_team.gui.xml','sp_task')
	local quest_node = api.UI.FindChild(comp,{Name=name})
	
	_M.AddUIArrow(quest_node)	
	
	
	if text then
		_M.AddTextFrame(quest_node,text)
	end
	if force then
		_M.BlockUITouch(quest_node)
	end
	api.UI.PointerClick(quest_node)
end

local function ScriptEnd(id,script_id)
	if not IsScriptExist(script_id) then
		api.StopEvent()
	end
	api.AddPeriodicTimer(0.3,function ()
		if not IsScriptExist(script_id) then
			api.StopEvent()
		end
	end)
	api.Sleep(9999999)
end

function _M.IsScriptEnd(script_name)
	local id = FindScriptIDByName('quest_10007')
	api.AddEvent(ScriptEnd,id)
end









function _M.WaitCheckFunction(check_fn,sec)
	return api.AddEvent(function ()
		api.SetMyName('WaitCheckFunction')
		api.AddPeriodicTimer(sec or 0.3,function ()
			if check_fn() then
				api.StopEvent()
			end
		end)
		api.Sleep(-1)	
	end)
end



function _M.WaitScriptEnd(script_name)
	return api.AddEvent(function (...)
		local id = FindScriptIDByName(script_name)
		if not id or not IsScriptExist(id) then
			api.StopEvent()
		end
		_M.WaitCheckFunction(function ()
			return not IsScriptExist(id)
		end,0.3)
		api.Wait()
	end)
end


local function OpenGuideXml(api)
	
	
	
	
	
	
	
	
	
	
	
	
	
	local ui = api.UI.AddDramaLayerUI('xmds_ui/tips/tips_guide.gui.xml')
	return ui
end

function _M.ClearTextFrame(ui)
	return api.AddEvent(function ()
		local tb_guide = api.UI.FindComponent(ui,'tb_guide')
		api.UI.SetText(tb_guide,'')		
	end)
end







function _M.TouchGuide(target,params)
	return api.AddEvent(function (...)
		api.SetMyName('TouchGuide')
		params = params or {}
		
		local off_x = 0 + (params.x or 0)
		local off_y = 0 + (params.y or 0)

		local offtext_x,offtext_y = -20, -80
		local space_offset = 0
		offtext_x = (params.textX or 0) + offtext_x
		offtext_y = (params.textY or 0) + offtext_y

		local force = false
		if params.force then
			force = true
		end
		api.SetBlockTouch(force)

		local arrow,ui
		local isTransform = api.RectTransform.IsTransform(target)
		local target_trans = isTransform and target or api.UI.GetTranform(target)

		local function target_ugui_logic()
			local cvs_guide,guide_w,guide_h,guide_parent,guide_parent_trans,s,pivot
			local hasInitDirection = false

			local function CreateGuideUI()
				if not target then return end
				ui = OpenGuideXml(api)
				cvs_guide = api.UI.FindComponent(ui,'cvs_guide')
				guide_w,guide_h = api.UI.GetSize(cvs_guide)
				guide_parent = api.UI.GetParent(cvs_guide)
				guide_parent_trans = api.UI.GetTranform(guide_parent)
				arrow = api.UI.AddUEImageTo(guide_parent)
				api.UI.SetName(arrow,'arrow')
				s = api.RectTransform.GetSize(target_trans)
				pivot = api.RectTransform.GetPivot(target_trans)
				api.UI.SetSize(arrow,s.x,s.y)				
			end

			local function initDirection(x)
				local tb_guide = api.UI.FindComponent(ui,'tb_guide')
				if x > 600 then
					api.UI.SetImage(cvs_guide,'#dynamic_n/guide/Sprite Packer.xml|Sprite Packer|0')
					api.UI.SetPos(tb_guide,200,85)
				else
					api.UI.SetImage(cvs_guide,'#dynamic_n/guide/Sprite Packer.xml|Sprite Packer|1')
					api.UI.SetPos(tb_guide,45,85)
				end
				hasInitDirection = true
			end
			local function SyncPos()
				local wp = api.RectTransform.GetWorldSpace(target_trans)
				local lp = api.RectTransform.WorldSpaceToLoaclSpace(guide_parent_trans,wp)
				lp = api.UI.ToMFUIPosition(lp)
				if lp then
					local x = lp.x - pivot.x * s.x
	        		local y = lp.y - (1 - pivot.y) * s.y
					local target_x = x + off_x
					local target_y = y + off_y
					local pre_x,pre_y = api.UI.GetPos(arrow)
					api.UI.SetPos(arrow,target_x, target_y)
					if params.text then
						local frame_x,frame_y = x,y
						if hasInitDirection == false then
							initDirection(frame_x)
						end
						if frame_x  > 600 then
						
							frame_x = frame_x-guide_w-space_offset+offtext_x
						else
							frame_x = frame_x+s.x+offtext_x+space_offset
						end
						frame_y = frame_y+offtext_y
						if frame_y > 550 then
							frame_y = 550
						elseif frame_y < 0 then
							frame_y = 0
						end
						api.UI.SetPos(cvs_guide,frame_x,frame_y)
					end
					return pre_x ~= target_x or pre_y ~= target_y
				end				
			end

			local function SyncVaild(valid)

				if valid == nil then
					if isTransform then
						valid = api.RectTransform.IsValidTransform(target_trans)
					else
						valid = api.UI.IsValid(target)
					end
					if valid == nil then
						valid = false
					end
				end
				if force then
					if not valid  then
						if api.IsBlockTouch() then
							api.SetBlockTouch(false)
						end
					elseif not api.IsBlockTouch() then
						api.SetBlockTouch(true,target_trans,0)
					end
				end
				if valid and api.UI.IsVisible(ui) == nil then
					CreateGuideUI()
				end
				api.UI.SetVisible(guide_parent,valid)
				return valid
			end

			local function UpdatePos()
				if not params.checkfn or params.checkfn(ui) then
					if SyncVaild() and params.syncPos then
						SyncPos()
					end
				else
					SyncVaild(false)
				end
			end

			CreateGuideUI()
			SyncPos()
			SyncVaild()

			api.SetBlockTouch(force,target_trans,0) 
			api.AddPeriodicTimer(0.2,UpdatePos)
			if isTransform then
				if force then
					local tname = api.RectTransform.GetName(target)
					api.SubscribOnReciveMessage('GuideHighLight.Touch.Up.'..tname)
				end
			else
				api.UI.PointerClick(target)
			end	
		end
		if target then
			target_ugui_logic()

			
			
			
			local arrowIsTransform = api.RectTransform.IsTransform(arrow)
			local arrow_trans = arrowIsTransform and arrow or api.UI.GetTranform(arrow)
			api.SetHandAnimation(arrow_trans)

			if params.scale then
				api.UI.SetScale(arrow,params.scale)
			end
			local cvs_guide = api.UI.FindComponent(ui,'cvs_guide')
			local x1,y1 = api.UI.GetPos(cvs_guide)
			local x2,y2 = api.UI.GetPos(arrow)
			local w1,h1 = api.UI.GetSize(cvs_guide)
			local w2,h2 = api.UI.GetSize(arrow)
			
			
			
			
			

			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			

			
			
			
			

			if params.text then
				
				local tb_guide = api.UI.FindComponent(ui,'tb_guide')
				local cvs_guide = api.UI.FindComponent(ui,'cvs_guide')
				local text = string.format("<f bcolor='ff000000' border= '8'>%s</f>",params.text)
				api.UI.SetTextAnchor(tb_guide,TextAnchor.L_C)
				api.UI.SetText(tb_guide,text)
				api.UI.SetVisible(cvs_guide,true)
			else
				api.UI.SetVisible(cvs_guide,false)
			end

			if params.noArrow then
				api.UI.SetVisible(arrow,false)
			end

		elseif params.text then
			ui = OpenGuideXml(api)
			local tb_guide = api.UI.FindComponent(ui,'tb_guide')
			local cvs_guide = api.UI.FindComponent(ui,'cvs_guide')
			api.UI.SetTextAnchor(tb_guide,TextAnchor.L_C)			
			local text = string.format("<f bcolor='ff000000' border= '8'>%s</f>",params.text)
			api.UI.SetText(tb_guide,text)
			api.UI.SetVisible(cvs_guide,true)	
			
			local w,h = api.UI.GetSize(cvs_guide)
			local root = api.UI.GetUIRoot(cvs_guide)
			local rw,rh = api.UI.GetSize(root)
			local root = api.UI.GetParent(cvs_guide)
			local x,y = (rw-w)*0.5,(rh-h)*0.5
			api.UI.SetPos(cvs_guide,x+offtext_x,y+offtext_y)	
			params.noDestory = true

			
			
			
			
			
			
			
			
		end

		SaveHasRun()
		if params.noDestory then
			api.Sleep(-1)
		else
			api.Wait()
		end
		api.UI.Clear()
		
		api.SetBlockTouch(force)
	end)
end




function _M.PickGuide(params)
	return api.AddEvent(function ()
		params = params or {}
		api.SetMyName('PickGuide')
		local btn_name = params.buttonName or 'btn_pick'
		local btn_pick = api.UI.FindHudComponent('xmds_ui/hud/Communicat.gui.xml',btn_name)
		local ib_shiqueffect = api.UI.FindHudComponent('xmds_ui/hud/Communicat.gui.xml','ib_shiqueffect')
		_M.WaitCheckFunction(function ()
			local visible = api.UI.IsVisible(btn_pick) and api.UI.IsVisible(ib_shiqueffect)
			if params.buttonText then
				visible = visible and api.UI.GetText(btn_pick) == params.buttonText
			end
			if not visible and params.force and not api.Scene.IsSeekState() and api.IsBlockTouch() then
				api.SetBlockTouch(false)
			end
			return visible
		end)
		api.Wait()
		if params.soundKey then
			api.PlaySoundByKey(params.soundKey)
		end
		params.textX = -25
		api.Wait(_M.TouchGuide(btn_pick,params))
	end)
end




function _M.QuestHudGuide(questid,params)
	return api.AddEvent(function ()
		api.SetMyName('QuestHudGuide')
		local name = api.Quest.GetName(questid)
		local comp = api.UI.FindHudComponent('xmds_ui/hud/hud_team.gui.xml','sp_task')
		local quest_node = api.UI.FindChild(comp,{Name=name})
		params.syncPos = true
		api.Wait(_M.TouchGuide(quest_node,params))
		if params and params.force then
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
	
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
		end	
	end)
end





function _M.MoveGuide(flag,target,params)
	return api.AddEvent(function ()
		api.SetMyName('MoveGuide')
		local guide
		if target or params then
			params = params or {}
			
			params.noDestory = true
			if not target then
				params.textY = 100
			end
			guide = _M.TouchGuide(target,params)
		end

		local x,y = api.Scene.GetFlagPositon(flag)
		if not params.hideNavi then
			api.Scene.ShowActorNavi(x,y)
		end
		local effect_path = '/res/effect/50000_state/vfx_location.assetBundles'
		local eid = api.Scene.PlayEffect(effect_path,{x=x,y=y})
		local passTime = -1
		local fx,fy = api.Scene.GetActorPostion()
		_M.WaitCheckFunction(function ()
			local ux,uy = api.Scene.GetActorPostion()
			if passTime >= 0 then
				passTime = passTime + 0.3
			end
			
			if fx and fy then
				local distance = api.GetDistance(fx,fy,ux,uy)
				if distance and distance > 1 then
					api.StopEvent(guide)
					fx = nil
					fy = nil
					if params.loopTime then
						passTime = 0
					end
				end
			end

			if not api.Scene.InRockMove() and params.loopTime and passTime >= params.loopTime then
				guide = _M.TouchGuide(target,params)
				fx,fy = ux,uy
				passTime = -1
			end

			local distance = api.GetDistance(x,y,ux,uy)
			if not params.hideNavi and not api.Scene.IsExistNavi()	then
				api.StopEvent(guide)
				return true
			else
				return distance <= (params.distance or 5)
			end
		end)
		api.Wait()
		if not params.hideNavi then
			api.Scene.HideNavi()
		end
		api.Scene.StopEffect(eid)
	end)
end

function _M.QuestNpcGuide(id, params)
	params = params or {}
	local btn_name = params.buttonName or 'btn_get'
	local btn = api.UI.FindComponent('xmds_ui/npc/npc.gui.xml',btn_name)
	if not (btn and api.UI.IsValid(btn) and api.UI.GetUserTag(btn) == id) then
		local msg_id = api.SubscribOnReciveMessage('Npc.Quest.'..id)
		api.Wait(msg_id,{update=function ()
			if params.force and not api.Scene.IsSeekState() then
				api.SetBlockTouch(false)
			end
		end})
		btn = api.UI.FindComponent('xmds_ui/npc/npc.gui.xml',btn_name)
	end
	params.textX = 0
	params.textY = 0
	params.sx = 92
	api.Wait(_M.TouchGuide(btn,params))
end



function _M.QuestHudNpcGuide(id,params1,params2,waitForce)
	return api.AddEvent(function ()
		params1 = params1 or {}
		params2 = params2 or {}
		local force
		if waitForce ~= nil then
			force = waitForce
		else
		  force = params1.force and params2.force or false
		end
		local btn_name = params2.buttonName or 'btn_get'
		local btn = api.UI.FindComponent('xmds_ui/npc/npc.gui.xml',btn_name)
		api.Sleep(0.1)
		if not btn then
			if api.Scene.IsSeekState() then
				api.SetBlockTouch(force)
				api.Wait(api.Scene.WaitSeekEnd())
				api.Sleep(0.3)
				btn = api.UI.FindComponent('xmds_ui/npc/npc.gui.xml',btn_name)
			end
			if not btn then
				api.Wait(_M.QuestHudGuide(id,params1))
			end
		end
		api.SetBlockTouch(force)
		api.Wait(_M.QuestNpcGuide(id,params2))
	end)
end

function _M.NewGoodEquipGuide(params)
	return api.AddEvent(function ()
		api.Wait(api.UI.WaitMenuEnter('xmds_ui/common/commom_good.gui.xml'))
		local btn_now = api.UI.FindComponent('xmds_ui/common/commom_good.gui.xml','btn_now')
		if params and params.soundKey then
			api.PlaySoundByKey(params.soundKey)
		end
		api.Wait(_M.TouchGuide(btn_now,params))		
	end)
end

function _M.SkillGuide(params)
	
	
	
	
	
	
	
end
function _M.StartScript(script_name,...)
	local p = {...}
	return api.AddEvent(function ()
		StartScript(script_name,unpack(p))
	end)
end


function _M.WaitScriptEndByType(t)
	return api.AddEvent(function ()
		api.Sleep(0.1)
		local all = GetAllScriptNames()
		for _,v in ipairs(all) do
			if t == GetScriptTypeByName(v) then
				_M.WaitScriptEnd(v)
			end
		end
		api.Wait()
	end)
end

function _M.HeroIconTouchGuide(params)
	return api.AddEvent(function ()
		params = params or {}
		local ib_heroicon = api.UI.FindHudComponent('xmds_ui/hud/heroinfo.gui.xml','ib_heroicon')
		local trans = api.UI.GetTranform(ib_heroicon)
		local uid = _M.TouchGuide(trans,{text=params.text,noDestory=true,force=params.force,x=-2,y=8,textX=20,textY=6})
		api.Sleep(0.1)
		api.Wait(api.UI.PointerClick(ib_heroicon))
		api.StopEvent(uid)
		api.Sleep(0.1)
	end)
end









function CreateHelper(cur_api)
	api = cur_api
	return _M
end
