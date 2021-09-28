




ck_skill_name = '暗影之刃'

function split(str,sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function start(api,need_start)
	step = api.Net.GetStep()
	if not need_start and not step then return end
	pro = api.GetProKey()
	pos = 1
	cvs_name = 'cvs_tianfu'..pos
	if pro == '刺客' then
		skill_name = ck_skill_name
	end
	api.Net.SendStep('enter')
	api.Scene.StopSeek()
	api.PlaySoundByKey('guide54')
	api.Wait(Helper.HeroIconTouchGuide({text=api.GetText('guide54'),force=true}))

	
	btn_skill = api.UI.FindHudComponent('newplatform.gui.xml','btn_skill')
	
	api.Wait(Helper.TouchGuide(btn_skill,{textX=20,force=true,text=api.GetText('guide41')}))
	
	api.Wait(api.UI.WaitMenuEnter('xmds_ui/skill_new/skill_main.gui.xml'))
	api.Net.SendStep()
	if skill_name then
		sp_see = api.UI.FindComponent('xmds_ui/skill_new/skill_main.gui.xml','sp_see')
		skill_lable = api.UI.FindChild(sp_see,function (uid)
			return api.UI.GetText(uid) == skill_name
		end)
		skill_cvs = api.UI.GetParent(skill_lable)
		skill_tbt = api.UI.FindChild(skill_cvs,'tbt_skill1')
		api.Wait(Helper.TouchGuide(skill_tbt,{force=true}))
	end
	
	cvs_tianfu1 = api.UI.FindComponent('xmds_ui/skill_new/skill_main.gui.xml',cvs_name)
	btn_up = api.UI.FindChild(cvs_tianfu1,'btn_up')
	lb_num = api.UI.FindChild(cvs_tianfu1,'lb_num')
	
	numText = api.UI.GetText(lb_num)
	tnums = split(numText,'/')
	local num1,num2 = tonumber(tnums[1]), tonumber(tnums[2])
	if num1 and num2 and num1  >= num2 then
		api.PlaySoundByKey('guide42')
		Helper.TouchGuide(btn_up,{textX=14,textY=-20,force=true,text=api.GetText('guide42')})
		
		api.Wait()
		cvs_tianfu1 = api.UI.FindComponent('xmds_ui/skill_new/skill_main.gui.xml',cvs_name)
		btn_activation = api.UI.FindChild(cvs_tianfu1,'btn_activation')
		if api.UI.IsEnable(btn_activation) then
			
			Helper.TouchGuide(btn_activation,{textX=-30,textY=-10,force=true,text=api.GetText('guide43')})
			
			api.Wait()
			btn_close = api.UI.FindComponent('xmds_ui/skill_new/skill_main.gui.xml','btn_close') 
			api.Wait(Helper.TouchGuide(btn_close))
			api.Wait(api.UI.WaitMenuExit('xmds_ui/skill_new/skill_main.gui.xml'))
			ib_heroicon = api.UI.FindHudComponent('xmds_ui/hud/heroinfo.gui.xml','ib_heroicon')
			ib_heroicon_trans = api.UI.GetTranform(ib_heroicon)
			
			Helper.TouchGuide(ib_heroicon_trans,{noDestory=true,x=-2,y=8,textX=20,textY=6,text=api.GetText('guide55')})
			cvs_landscape = api.UI.FindHudComponent('newplatform.gui.xml','cvs_character')
			uid = Helper.WaitCheckFunction(function ()
				local x = api.UI.GetPosX(cvs_landscape)
				return x <= 0
			end)
			api.Wait(uid)
		end
	end
end
