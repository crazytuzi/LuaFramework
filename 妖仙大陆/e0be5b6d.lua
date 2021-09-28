

function start(api, items, exp)
	if not items and not exp then return end

	local ui = api.UI.OpenUIByXml('xmds_ui/smelting/smelting_get.gui.xml',true)

	local lb_expnum = api.UI.FindComponent(ui,'lb_expnum')
	local cvs_exp = api.UI.FindComponent(ui,'cvs_exp')
	local cvs_center = api.UI.FindComponent(ui,'cvs_center')
	local cvs_goods = api.UI.FindComponent(ui,'cvs_goods')
	local cvs_goods2 = api.UI.FindComponent(ui,'cvs_goods2')
	local cvs_frame = api.UI.FindComponent(ui,'cvs_frame')
	local ib_effect1 = api.UI.FindComponent(ui,'ib_effect1')
	local ib_effect2 = api.UI.FindComponent(ui,'ib_effect2')
	local offset_y = 10
	local total_y = 0
	local y = offset_y

	if items and #items >= 1 then
		if #items == 1 then
			local item = items[1]
			local cvs_icon = api.UI.FindChild(cvs_goods,'cvs_icon')
			local lb_num = api.UI.FindChild(cvs_goods,'lb_num')
			local lb_name = api.UI.FindChild(cvs_goods,'lb_name')
			local static_data = api.GetItemStaticData(item.code)
			local rgba = api.GetQualityColorRGBA(static_data.Qcolor)
			api.UI.SetText(lb_name,static_data.Name,rgba)
			api.UI.SetText(lb_num,'*'..item.groupCount)		
			api.UI.AddItemShowTo(cvs_icon,static_data.Icon,static_data.Qcolor)
			api.UI.SetPosY(cvs_goods,y)
			total_y = api.UI.GetHeight(cvs_goods)
			local cvs_x = api.UI.GetPosX(cvs_goods)
			y = y + total_y + offset_y
			local cvs_w = api.UI.GetWidth(cvs_goods)
			api.UI.SetWidth(cvs_exp,cvs_w)
			api.UI.SetWidth(cvs_frame,cvs_w+74*2)
			api.UI.SetPosX(ib_effect1,276)
		else
			local cvs_item_default = api.UI.FindChild(cvs_goods2,'cvs_item')
			local defaultx,defaulty = api.UI.GetPos(cvs_item_default)
			local w = api.UI.GetWidth(cvs_item_default)
			local x = defaultx
			local cvs_item = cvs_item_default
			for i=1,#items do 
				local item = items[i]
				if not cvs_item then
					cvs_item = api.UI.CloneComponent(cvs_item_default)
					api.UI.AddChild(cvs_goods2,cvs_item)
					x = x + w + 60
					api.UI.SetPos(cvs_item,x,defaulty)
				end

				local cvs_icon = api.UI.FindChild(cvs_item,'cvs_icon1')
				local lb_name = api.UI.FindChild(cvs_item,'lb_name1')
				local static_data = api.GetItemStaticData(item.code)
				local rgba = api.GetQualityColorRGBA(static_data.Qcolor)
				api.UI.SetText(lb_name,static_data.Name,rgba)
				api.UI.SetText(lb_num,'*'..item.groupCount)		
				api.UI.AddItemShowTo(cvs_icon,static_data.Icon,static_data.Qcolor,item.groupCount)
				cvs_item = nil
			end
			api.UI.SetWidth(cvs_goods2,x+w+23)
			api.UI.SetWidth(cvs_exp,x+w+23)
			api.UI.SetWidth(cvs_frame,x+w+23+74*2)
			api.UI.SetPosY(cvs_goods2,y)
			api.UI.SetPosX(ib_effect1,x+w+23+74*2-152)
			total_y = api.UI.GetHeight(cvs_goods2)
			y = y + total_y + offset_y
		end
	end
	api.UI.SetVisible(cvs_goods,items ~= nil and #items == 1)
	api.UI.SetVisible(cvs_goods2,items ~= nil and #items > 1)

	if exp then
		api.UI.SetText(lb_expnum,'+'..exp)
		api.UI.SetPosY(cvs_exp,y)
		total_y = total_y + api.UI.GetHeight(cvs_exp)
		api.UI.AdjustByImageAnchor(cvs_center,ImageAnchor.C_C)
	end
	api.UI.SetVisible(cvs_exp,exp ~= nil)
	total_y = total_y + 2 * offset_y + 5
	api.UI.SetHeight(cvs_frame,total_y)
	api.UI.SetPosY(ib_effect2,total_y-17)
	api.UI.AdjustByImageAnchor(cvs_frame,ImageAnchor.C_C)
	api.UI.SetVisible(cvs_frame,true)
	api.Sleep(3)
	api.UI.SetVisible(cvs_goods,false)
	api.UI.SetVisible(cvs_goods2,false)
	api.UI.SetVisible(cvs_frame,false)
end
