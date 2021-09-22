local ContainerPigAward = class("ContainerPigAward")

local var = {}

local rate = {
	[1] = 1,
	[2] = 2,
	[3] = 3,
	[4] = 4,
	[5] = 5,
	[6] = 8,}

function ContainerPigAward.initView(event)
	var = {
		xmlPanel = nil,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerPigAward.uif");
	if var.xmlPanel then
		if event.mParam ~= nil then
			var.xmlPanel:getWidgetByName("lbl_pass_section"):setString(event.mParam.pass_title_str)
			var.xmlPanel:getWidgetByName("lbl_exp_total"):setString(event.mParam.exp_str)

			for i = 1, 6 do 
				local btn = var.xmlPanel:getWidgetByName("btn_get"..i)
				btn:setTag(i)
				btn:addClickEventListener(ContainerPigAward.btnGetExpClick)	

				local box = var.xmlPanel:getWidgetByName("box_award"..i)
				local lbl_cost = var.xmlPanel:getWidgetByName("lbl_cost"..i)
				local lbl_exp = var.xmlPanel:getWidgetByName("lbl_exp"..i)
				local exp = event.mParam.exp * rate[i]
				lbl_exp:setString(tostring(exp).."经验")
				local x = lbl_cost:getContentSize().width + 10
				lbl_exp:setPositionX(x)
				local w = x + lbl_exp:getContentSize().width
				box:setContentSize(w, 10)
				box:setPositionX(btn:getPositionX())
			end	
		end
	end
	
	return var.xmlPanel
end

function ContainerPigAward.btnGetExpClick(sender)
	GameSocket:PushLuaTable("npc.task.n018.btnGetAward",GameUtilSenior.encode({actionid = "getAward",params={id = sender:getTag()}}))
end

return ContainerPigAward