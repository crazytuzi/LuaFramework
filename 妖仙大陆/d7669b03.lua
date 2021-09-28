

local title_path = {
	'#dynamic_n/jjc/jjc_effect.xml|jjc_effect|0',
	'#dynamic_n/jjc/jjc_effect.xml|jjc_effect|3',
	'#dynamic_n/jjc/jjc_effect.xml|jjc_effect|7',
	'#dynamic_n/jjc/jjc_effect.xml|jjc_effect|4',
	'#dynamic_n/jjc/jjc_effect.xml|jjc_effect|2',
	'#dynamic_n/jjc/jjc_effect.xml|jjc_effect|5',
	'#dynamic_n/jjc/jjc_effect.xml|jjc_effect|1',
	'#dynamic_n/jjc/jjc_effect.xml|jjc_effect|6'
}

local MAX_KL = 8

local function get_title(killCount)
	if killCount > 1 and killCount < 9 then
		return title_path[killCount - 1]
	elseif killCount == 9 then
		return title_path[7]
	elseif killCount >= 10 then
		return title_path[8]
	else
		return nil
	end
end

function start(api,killCount)
	
	
	
	local path  = get_title(killCount)
	if not path then return end

	local ui = api.UI.OpenUIByXml('xmds_ui/arena/jjc_effect.gui.xml',false)
	local ib_title = api.UI.FindComponent(ui,'ib_title')
	local ib_kill = api.UI.FindComponent(ui,'ib_kill')

	local kill_parent = api.UI.GetParent(ib_kill)

	local kill_w = api.UI.GetWidth(ib_kill)
	local total_w = api.UI.GetWidth(kill_parent)
	local Duration = 0.3
	local uids = {}
	local len = killCount > MAX_KL and MAX_KL or killCount
	local start_x = 0.5 * (total_w - (len * kill_w))
	for i=1,len do
		local comp
		if i > 1 then
			comp = api.UI.CloneComponent(ib_kill)
			api.UI.AddChild(kill_parent,comp)
		else
			comp = ib_kill
		end	
		api.UI.SetAlpha(comp,0)
		api.UI.SetScale(comp,1.5)
		api.UI.SetPosX(comp, start_x + kill_w*(i-1))
		api.UI.AddAction(comp,'FadeAction',{TargetAlpha=1,Duration=Duration})
		api.UI.AddAction(comp,'ScaleAction',{Scale=1,Duration=Duration})
		table.insert(uids,comp)
	end

	api.UI.SetImage(ib_title,path)
	api.UI.SetAlpha(ib_title,0)
	api.UI.SetScale(ib_title,1.5)
	api.UI.AddAction(ib_title,'FadeAction',{TargetAlpha=1,Duration=Duration})
	api.UI.AddAction(ib_title,'ScaleAction',{Scale=1,Duration=Duration})
	api.Wait()
	api.Sleep(1)

	api.UI.AddAction(ib_title,'FadeAction',{TargetAlpha=0,Duration=1})
	for _,v in ipairs(uids) do
		api.UI.AddAction(v,'FadeAction',{TargetAlpha=0,Duration=1})
	end

	api.Wait()

end
