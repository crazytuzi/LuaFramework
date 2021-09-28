--LegionHistoryItem.lua

require("app.cfg.corps_news_info")
require("app.cfg.corps_worship_info")
require("app.cfg.corps_dungeon_info")
require("app.cfg.monster_team_info")

local LegionHistoryItem = class("LegionHistoryItem", function ( ... )
	return  CCSItemCellBase:create("ui_layout/legion_HistoryItem.json")
end)


function LegionHistoryItem:ctor( ... )
	local panel = self:getWidgetByName("Panel_content")
	local timeLabel = self:getLabelByName("Label_time")
	if panel and timeLabel then 
		local size = panel:getSize()
		local label1 = CCSRichText:create(size.width, size.height)
    	label1:setFontName(timeLabel:getFontName())
    	label1:setFontSize(timeLabel:getFontSize())
    	label1:setShowTextFromTop(true)
    	label1:setPositionXY(size.width/2, size.height/2)
    	panel:addChild(label1)

    	self._richText = label1
	end
end

function LegionHistoryItem:updateItem( historyData )
	if not historyData then 
		return 
	end

	local text = "" 
	local infoId = historyData.info_id or 0
	local corpNews = corps_news_info.get(infoId)
	if corpNews then 
		text = corpNews.news
	end

	local key1 = historyData.key[1]
	local key2 = historyData.key[2]
	local key3 = historyData.key[3]
	local key4 = historyData.key[4]
	local formatParam = {}
	local worshipId = 0
	--local dungeonIndex = 0
	if key1 then 
		formatParam[key1] = historyData.value[1]
		if key1 == "id" then 
			worshipId = historyData.value[1]
		end
		-- if key1 == "index" then 
		-- 	dungeonIndex = historyData.value[1]
		-- end
	end
	if key2 then 
		formatParam[key2] = historyData.value[2]
		if key2 == "id" then 
			worshipId = historyData.value[2]
		end
		-- if key2 == "index" then 
		-- 	dungeonIndex = historyData.value[2]
		-- end
	end
	if key3 then 
		formatParam[key3] = historyData.value[3]
		if key3 == "id" then 
			worshipId = historyData.value[3]
		end
		-- if key3 == "index" then 
		-- 	dungeonIndex = historyData.value[3]
		-- end
	end
	if key4 then 
		formatParam[key4] = historyData.value[4]
		if key4 == "id" then 
			worshipId = historyData.value[4]
		end
		-- if key4 == "index" then 
		-- 	dungeonIndex = historyData.value[4]
		-- end
	end
	worshipId = toint(worshipId)
	--dungeonIndex = toint(dungeonIndex)
	if (infoId == 1 or infoId == 8) and worshipId > 0 then 
		local worshipInfo = corps_worship_info.get(worshipId)
		if worshipInfo then
			formatParam["name"] = worshipInfo.name
		end
	elseif infoId == 9 then 
		local corpDungeon = corps_dungeon_info.get(worshipId)
		if corpDungeon then 
			formatParam["dungeon_name"] = corpDungeon["dungeon_name_1"] or ""
			formatParam["corps_exp"] = corpDungeon["corps_exp"] or 0
		end
	end
	text = GlobalFunc.formatText(text, formatParam)
	-- if infoId == 1 then 
	-- 	text = GlobalFunc.formatText(text, {
 --                        name = historyData.value[1],
 --                        worship_name = historyData.value[2],
 --                        worship_integral = historyData.value[3],
 --                        })
 --    elseif infoId == 2 or infoId == 3 or infoId == 4 then 
 --    	text = GlobalFunc.formatText(text, {
 --                        name = historyData.value[1]
 --                        })
	-- end
	
	if self._richText then 
		self._richText:clearRichElement()
    	self._richText:appendContent(text, ccc3(255, 255, 255))
    	self._richText:reloadData()
	end

	local t = G_ServerTime:getDateObject(historyData.time)
    --local t = os.date("*t", historyData.time or os.time())
    if t then
    	self:showTextWithLabel("Label_time", G_lang:get("LANG_LEGION_HISTORY_TIME_FORMAT", 
    		{month = t.month, day = t.day, timeValue = string.format("%02d:%02d", t.hour, t.min) }))
    end
end

return LegionHistoryItem

