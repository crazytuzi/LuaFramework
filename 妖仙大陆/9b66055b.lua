

function start(api,...)
	
	

	
	
	
	

	local cvs_bag = api.UI.FindComponent(103,'cvs_bag')
	local added_btn = api.UI.AddUEButtonTo(cvs_bag)
	
	api.UI.SetSize(added_btn,100,50)
	api.Sleep(2)
	api.UI.SetText(added_btn,'你好')

	local function WaitClick(...)
		api.UI.PointerClick(added_btn)
		api.Wait()
		print('PointerClick------added_btn')
		api.UI.SetText(added_btn,'我好')
	end
	api.AddEvent(WaitClick)
	
	api.Sleep(5)
	api.UI.DoPointerClick(added_btn)

	api.Wait()
	api.Sleep(10)
end
