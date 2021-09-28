





function Quest_CanFinish(api, id)
	api.Wait(Helper.QuestHudGuide(id))
end

function Quest_InProgress(api, id)

	step = api.Net.GetStep() 
	if not step and 91001 == api.Scene.GetCurrentSceneID() then
		api.Sleep(3)
		api.Wait(Helper.WaitScriptEnd('test_3'))
		
		api.Net.SendStep('enter')

		ux,uy = api.Scene.GetActorPostion()
		tips = Helper.TouchGuide(nil,{noDestory=true,text=api.GetText('guide24'),textY=140})

		checkId = Helper.WaitCheckFunction(function ()
			ux2,uy2 = api.Scene.GetActorPostion()
			distance = api.GetDistance(ux,uy,ux2,uy2)
			return distance >= 1
		end)

		tx,ty = api.Scene.GetFlagPositon('12')
		api.Scene.ShowNavi(ux,uy,tx,ty)

		effect_path = '/res/effect/50000_state/vfx_location.assetBundles'
		eid = api.Scene.PlayEffect(effect_path,{x=tx,y=ty})

		api.Wait(checkId)
		api.StopEvent(tips)

		Helper.WaitCheckFunction(function ()
			local state = api.Scene.IsCombatState()
			return state
		end)
		
		api.Wait()
	else
		if step == 'enter' then
			Helper.QuestHudGuide(id,{force=true,text=api.GetText('guide25')})
			api.Wait()
			api.UI.WaitMenuEnter('xmds_ui/solo/solo_main.gui.xml')
			tbt_reward = api.UI.FindComponent('xmds_ui/solo/solo_main.gui.xml','tbt_reward')
			Helper.TouchGuide(tbt_reward,{force = true})
			api.Wait()

			cvs_dailyreward = api.UI.FindComponent('xmds_ui/solo/solo_main.gui.xml','cvs_dailyreward')
			btn_dailyreward = api.UI.FindChild(cvs_dailyreward,'btn_dailyreward')
			if not api.UI.IsEnable(btn_dailyreward) then
				return
			end
			Helper.TouchGuide(btn_dailyreward,{force = true})
			api.Wait()

			
			
			
		else
			local function Logic1()
				tb_shouhui = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','tb_shouhui')
				if api.UI.IsChecked(tb_shouhui) then
					api.Wait(Helper.TouchGuide(tb_shouhui,{force=true}))
					api.Sleep(0.2)
				end

				btn_daily = api.UI.FindHudComponent('xmds_ui/hud/mainhud.gui.xml','btn_daily')
				api.Wait(Helper.TouchGuide(btn_daily))
				btn_solo = api.UI.FindHudComponent('xmds_ui/hud/dailyplay.gui.xml','btn_solo')
				api.Wait(Helper.TouchGuide(api.UI.GetTranform(btn_solo),{force=true}))	
				api.UI.WaitMenuEnter('xmds_ui/solo/solo_main.gui.xml')
				api.Wait()		
			end

			local function Logic2()
				api.UI.WaitMenuEnter('xmds_ui/solo/solo_main.gui.xml')
				api.Wait()
			end

			e_id = api.AddEvent(Logic1)
			e_id2 = api.AddEvent(Logic2)

			api.WaitSelects({e_id,e_id2})
			api.Sleep(0.5)
			btn_enter = api.UI.FindComponent('xmds_ui/solo/solo_main.gui.xml','btn_enter')

			Helper.TouchGuide(btn_enter,{force = true,text = api.GetText('guide23')})
			api.PlaySoundByKey('guide23')
			api.Wait()
			api.SetBlockTouch(true)
			api.Sleep(6)
		end
	end
end

function start(api, id)
	s = api.Quest.GetState(id)
	if s == api.Quest.Status.CAN_FINISH then
		Quest_CanFinish(api,id)
	elseif s == api.Quest.Status.IN_PROGRESS then
		Quest_InProgress(api,id)
	end
end
