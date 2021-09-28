module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_steedAutoRefineSetPreview = i3k_class("wnd_steedAutoRefineSetPreview", ui.wnd_base)

function wnd_steedAutoRefineSetPreview:ctor()
	
end

function wnd_steedAutoRefineSetPreview:configure()
	local widget = self._layout.vars
	widget.bg:onClick(self, self.onCloseUI)
end

function wnd_steedAutoRefineSetPreview:refresh(sortRefineCfg, cfg)
	local widget = self._layout.vars
	local wid = {}
	
	local fun = function(c)
		for _, s in ipairs(c) do
			if s > 0 then
				return true
			end
		end
		
		return false
	end
	
	for i = 1, 5 do
		local item = {scoll = widget["scoll" .. i], txt = widget["txt" .. i]}
		table.insert(wid, item)
	end
	
	for i, v in ipairs(cfg) do
		if fun(v) then
			wid[i].txt:hide()
			
			for j, k in ipairs(v) do
				local id = sortRefineCfg[i][j] and sortRefineCfg[i][j].propId or 0 --如果存储多配置少了
				
				if id ~= 0 and k ~= 0 then
					local layer = require("ui/widgets/zqxlt3")()
					local widget = layer.vars
					local attrName = i3k_db_prop_id[id].desc
					widget.txt:setText(attrName)
					local tb = g_i3k_db.i3k_db_get_color_outColor(k)
					widget.txt:setTextColor(tb[1])
					--widget.txt:enableOutline(tb[2])
					wid[i].scoll:addItem(layer)
				end				
			end
		else
			wid[i].txt:show()
		end
	end
end

function wnd_create(layout)
	local wnd = wnd_steedAutoRefineSetPreview.new();
	wnd:create(layout);
	return wnd;
end
