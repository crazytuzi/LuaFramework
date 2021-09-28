












function start(api,need_start)
	step = api.Net.GetStep()

	if (not need_start and not step) or step == "skill_guide_end" then
		return
	end
	
	api.Scene.StopSeek()
	
	if api.UI.EntryMenuOpen() == false then
		btn_menu = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','btn_menu')
		if btn_menu then
			api.Wait(Helper.TouchGuide(btn_menu,{force=true,text=api.GetText('guide_1012_1')}))
		end
		api.Sleep(0.2)
	end

	
	btn_skill = api.UI.FindHudComponent('xmds_ui/hud/newplatform.gui.xml','btn_skill')
	if btn_skill then
		api.Wait(Helper.TouchGuide(btn_skill,{force=true,text=api.GetText('guide_1012_2')}))
	end
	api.Sleep(0.2)

	btn_upskill = api.UI.FindComponent('xmds_ui/skill/skill_main.gui.xml','btn_upskill')
	if btn_upskill then
		api.Wait(Helper.TouchGuide(btn_upskill,{force=true,text=api.GetText('guide_1012_3')}))
	end
	api.Sleep(0.2)
	
	sp_see = api.UI.FindComponent('xmds_ui/skill/skill_main.gui.xml','sp_see')
	con = api.UI.FindChild(sp_see)
	con = api.UI.FindChild(con)
	Helper.WaitCheckFunction(function ()
		local count = api.UI.GetChildrenCount(con)
		return count >= 2
	end)
	api.Wait()
	cvs_list2 = api.UI.GetChildAt(con,1)
	local tbt_skill1 = api.UI.FindChildByCom(cvs_list2,"tbt_skill1")
	if tbt_skill1 then
		api.Wait(Helper.TouchGuide(tbt_skill1,{force=true,text=api.GetText('guide_1012_4')}))
	end

	api.Net.SendStep('skill_guide_end')
end
