


function start(api)
	api.UI.WaitMenuEnter('xmds_ui/deal/deal_main.gui.xml')
	api.Wait()
	sp_show = api.UI.FindComponent('xmds_ui/deal/deal_main.gui.xml','sp_show')
	con = api.UI.FindChild(sp_show)
	con = api.UI.FindChild(con)
	api.Sleep(0.5)
	Helper.WaitCheckFunction(function ()
		local count = api.UI.GetChildrenCount(con)
		return count >= 5
	end)
	api.Wait()
	cvs_goods = api.UI.GetChildAt(con,api.GetUserInfo().pro-1)
	lb_condition = api.UI.FindChild(cvs_goods,'lb_condition')
	api.Wait(Helper.TouchGuide(lb_condition,{textX=-10,textY=-18,text=api.GetText('guide31')}))		
end
