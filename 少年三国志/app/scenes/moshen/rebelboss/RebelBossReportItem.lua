local RebelBossReportItem = class("RebelBossReportItem", function()
	return CCSItemCellBase:create("ui_layout/moshen_RebelBossReportItem.json")
end)

function RebelBossReportItem:ctor()
    
	self._labelTitle = self:getLabelByName("Label_Title")

    self._labelTime1 = self:getLabelByName("Label_time1")
    self._labelTime2 = self:getLabelByName("Label_time2")

    self._richText1 = self:_createRichText(self:getLabelByName("Label_content1"))
    self._richText2 = self:_createRichText(self:getLabelByName("Label_content2"))
end

function RebelBossReportItem:updateContent(tReport)
	if not tReport then
		return
	end

	local tBossTmpl = rebel_boss_info.get(tReport._nBossId)
	local szTitle = G_lang:get("LANG_REBEL_BOSS_BOSS_NAME", {name=tBossTmpl.name, level=tReport._nLevel})
	if szTitle then
		self._labelTitle:setText(szTitle)
		self._labelTitle:createStroke(Colors.strokeBrown, 1)
	else
		assert(false, "error!")
	end

	if tReport._tAward1 then
		self:showWidgetByName("Panel_content1", true)
		local tGoods1 = G_Goods.convert(tReport._tAward1.type, tReport._tAward1.value, tReport._tAward1.size)
		local szTime1 = tReport._nTime1
		local szContent1 = G_lang:get("LANG_REBEL_BOSS_REPORT_1", {name=tReport._szName1, award=tGoods1.name.."x"..tGoods1.size})

		if szTime1 then
			local nH, nM, nS = G_ServerTime:getCurrentHHMMSS(szTime1)
			self._labelTime1:setVisible(true)
			self._labelTime1:setText(G_lang:get("LANG_REBEL_BOSS_GET_TIME_FORMAT", {hour=nH, minute=string.format("%02d", nM)}))
		else
			self._labelTime1:setVisible(false)
		end

		if szContent1 then
			self._richText1:setVisible(true)
			self._richText1:clearRichElement()
	    	self._richText1:appendContent(szContent1, ccc3(255, 255, 255))
	    	self._richText1:reloadData()
	    else
	    	self._richText1:setVisible(false)
		end
	else
		self:showWidgetByName("Panel_content1", false)
	end

	if tReport._tAward2 then
		self:showWidgetByName("Panel_content2", true)
		local tGoods2 = G_Goods.convert(tReport._tAward2.type, tReport._tAward2.value, tReport._tAward2.size)
		local szTime2 = tReport._nTime2
		local szContent2 = G_lang:get("LANG_REBEL_BOSS_REPORT_2", {name=tReport._szName2, award=tGoods2.name.."x"..tGoods2.size})
		assert(tGoods2)

		if szTime2 then
			local nH, nM, nS = G_ServerTime:getCurrentHHMMSS(szTime2)
			self._labelTime2:setVisible(true)
			self._labelTime2:setText(G_lang:get("LANG_REBEL_BOSS_GET_TIME_FORMAT", {hour=nH, minute=string.format("%02d", nM)}))
		else
			self._labelTime2:setVisible(false)
		end

		if szContent2 then
			self._richText2:setVisible(true)
			self._richText2:clearRichElement()
	    	self._richText2:appendContent(szContent2, ccc3(255, 255, 255))
	    	self._richText2:reloadData()
		else
			self._richText2:setVisible(false)
		end
	else
		self:showWidgetByName("Panel_content2", false)
	end
end

function RebelBossReportItem:_createRichText(labelTmpl)
    labelTmpl:setText("")
    local size = labelTmpl:getSize()
    local parent = labelTmpl:getParent()
    
    local labelRichText = CCSRichText:create(size.width + 10, size.height + 10)
    labelRichText:setFontName(labelTmpl:getFontName())
    labelRichText:setFontSize(labelTmpl:getFontSize())
    labelRichText:setShowTextFromTop(true)
    local x, y = labelTmpl:getPosition()
    labelRichText:setPosition(ccp(x, y - 15))
    parent:addChild(labelRichText, 5)

    return labelRichText
end

return RebelBossReportItem