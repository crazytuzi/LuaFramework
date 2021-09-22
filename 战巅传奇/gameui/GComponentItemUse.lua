local GComponentItemUse = {}

function GComponentItemUse:initView( extend )
	if self.xmlTips then
		local icon = self.xmlTips:getWidgetByName("icon")
		GUIItem.getItem({
			parent = icon,
			typeId = extend.typeId,
			num = extend.num or 1,
		})
		
		local btns = {"btn_use","btn_close"}
		local function clickBtns( sender )
			local name = sender:getName()
			if name == btns[1] then
				GameSocket:BagUseItem(extend.pos or 0,extend.typeId, extend.num or 1)
			-- elseif name == btns[2] then
			end
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = extend.str})
		end
		
		for k,v in pairs(btns) do
			self.xmlTips:getWidgetByName(v):addClickEventListener(clickBtns)
		end
	end
end

function GComponentItemUse:closeCall()

end
-- GameSocket:dispatchEvent({
-- 	name = GameMessageCode.EVENT_SHOW_TIPS, str = "useItem", typeId = netItem.mTypeID,num = netItem.num,pos = netItem.pos
-- })
return GComponentItemUse