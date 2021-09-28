

function split(str,sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  str:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

function start(api)
	api.Wait(api.AddEvent(function ()
		local btn_name = 'btn_fish'
		local btn_pick = api.UI.FindHudComponent('xmds_ui/hud/Communicat.gui.xml',btn_name)
		local ib_shiqueffect = api.UI.FindHudComponent('xmds_ui/hud/Communicat.gui.xml','ib_shiqueffect')
		Helper.WaitCheckFunction(function ()
			local visible = api.UI.IsVisible(btn_pick) and api.UI.IsVisible(ib_shiqueffect)
			return visible
		end)
		api.Wait()
		api.UI.DoPointerClick(btn_pick)	
		api.Sleep(2)	
		local btn = api.UI.FindComponent('xmds_ui/npc/npc.gui.xml','btn_get')
		if btn and api.UI.IsVisible(btn) then
			api.UI.DoPointerClick(btn)
		end
		StartScript('F6')	
	end))
end
