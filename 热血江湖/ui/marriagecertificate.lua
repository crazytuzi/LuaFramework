
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_marriageCertificate = i3k_class("wnd_marriageCertificate",ui.wnd_base)

function wnd_marriageCertificate:ctor()
	self.marriageId = 0
	self.otherName = ""
	self.blessingCnt = 0
end

function wnd_marriageCertificate:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	self.blessingNum = widgets.blessingNum
end

function wnd_marriageCertificate:refresh(Data, marriageId)
	self.marriageId = marriageId
	local widgets = self._layout.vars

	local manName = Data.man.overview.name
	local womanName = Data.woman.overview.name
	widgets.bridegroomTxt:setText(manName)
	widgets.brideTxt:setText(womanName)

	if g_i3k_game_context:GetRoleName() == manName then
		self.otherName = womanName
	else
		self.otherName = manName
	end

	widgets.lvlTxt:setText(string.format("姻缘等级：%d", Data.marriage.marriageLevel))
	self.blessingCnt = Data.marriage.singNum
	self.blessingNum:setText(Data.marriage.singNum)

	local marriageTime = Data.marriage.marriageTime
	local curTime = i3k_game_get_time()
	widgets.timeTxt:setText(string.format("铭心时刻：%s", g_i3k_get_YearAndDayTime(marriageTime)))

	--计算婚姻称谓
	local hourTime = math.floor((curTime - marriageTime)/3600)
	local titleName = ""
	local cnt = #i3k_db_marry_levels
	for i ,v in ipairs(i3k_db_marry_levels) do	
		if hourTime <= v.marryTime or i == cnt then
			titleName = v.marryName
			break
		end
	end

	local marryTime = curTime - marriageTime
	local day = math.modf(marryTime/86400)
	local min = math.modf((marryTime%3600)/60)
	local hour = math.modf((marryTime%86400)/3600)
	
	local dayStr = "("
	if day ~= 0 then
		dayStr = dayStr .. string.format("%d天",day)
	end
	if hour ~= 0 then
		dayStr = dayStr .. string.format("%d小时",hour)
	end
	if dayStr == "(" then
		min = min == 0 and 1 or min
		dayStr = dayStr .. string.format("%d分钟）",min)
	else
		dayStr = dayStr..")"
	end
	widgets.titletxt:setText(string.format("携手岁月：%s%s",titleName,dayStr))
	

	local titleId = 0
	for _, cfg in ipairs(i3k_db_marry_title) do
		if curTime >= marriageTime + cfg.time then
			titleId = cfg.id
		end
	end
	if titleId == 0 then
		widgets.titleImg:hide()
		widgets.noTitle:show()
	else
		widgets.noTitle:hide()
		widgets.titleImg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_title_base[titleId].iconbackground))
	end
	
	local bgId = 0
	for i,v in ipairs(i3k_db_marry_card) do
		if curTime - marriageTime >= v.time then
			bgId = v.id
		end
	end		
	widgets.bg:setImage(g_i3k_db.i3k_db_get_icon_path(bgId))

	widgets.blessingBtn:onClick(self, self.blessing)
	if g_i3k_game_context:GetMarriageId() ~= marriageId then
		widgets.shareBtn:hide()
	else
		widgets.shareBtn:onClick(self, self.share)
	end
	
	self:createModule(Data.man, widgets.bridegroomSpr)
	self:createModule(Data.woman, widgets.bridegSpr)
end

function wnd_marriageCertificate:createModule(Data, spr)	--创建模型
	local playerData = Data.overview
	local data = {}
	for k,v in pairs(Data.wear.wearEquips) do
		data[k] = v.equip.id
	end
	self:changeModel(spr,playerData.type, playerData.bwType, playerData.gender, Data.wear.face, Data.wear.hair, data, Data.wear.curFashions, Data.wear.showFashionTypes, Data.wear.wearParts, Data.wear.armor, Data.wear.weaponSoulShownil, Data.wear.soaringDisplay)
end

function wnd_marriageCertificate:changeModel(spr, id, bwType, gender, face, hair, equips,fashions,isshow,equipparts,armor, weaponSoulShow, soaringDisplay)
	local modelTable = {}
	modelTable.node = spr
	modelTable.id = id
	modelTable.bwType = bwType
	modelTable.gender = gender
	modelTable.face = face
	modelTable.hair = hair
	modelTable.equips = equips
	modelTable.fashions = fashions
	modelTable.isshow = isshow
	modelTable.equipparts = equipparts
	modelTable.armor = nil
	modelTable.weaponSoulShow = nil
	modelTable.isEffectFashion = nil
	modelTable.soaringDisplay = soaringDisplay
	self:createModelWithCfg(modelTable)
end

function wnd_marriageCertificate:share()
	local marriageId = g_i3k_game_context:GetMarriageId()
	local msg = string.format("#MR%d,%s#",marriageId,self.otherName)
	g_i3k_ui_mgr:OpenUI(eUIID_ShareMarriageCard)
	g_i3k_ui_mgr:RefreshUI(eUIID_ShareMarriageCard, msg)
end

function wnd_marriageCertificate:blessing()
	if g_i3k_game_context:GetMarriageId() == self.marriageId then
		return
	end
	if g_i3k_game_context:GetCommonItemCanUseCount(i3k_db_common.marriageCardBlessingItemId) <= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16909))  --真言道具
		return false
	end
	local callback = function(isOk)
		if isOk then
			i3k_sbean.marriage_card_signReq(self.marriageId)
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(i3k_get_string(16907), callback)
end

function wnd_marriageCertificate:updateBlessingNum()
	self.blessingCnt = self.blessingCnt + 1
	self.blessingNum:setText(self.blessingCnt)
end

function wnd_create(layout, ...)
	local wnd = wnd_marriageCertificate.new()
	wnd:create(layout, ...)
	return wnd;
end

