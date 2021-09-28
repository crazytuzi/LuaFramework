-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_shen_bing_tongmin = i3k_class("wnd_shen_bing_tongmin", ui.wnd_base)

local ITEMNAME = "ui/widgets/sbtjdmzyt1"

function wnd_shen_bing_tongmin:ctor()
	self.inCDtime = false
end

function wnd_shen_bing_tongmin:configure( )
	local widgets = self._layout.vars
	self.coloseBtn = widgets.close
	self.seeQuickBtn = widgets.seeQuickBtn
	self.findEnemyBtn = widgets.findEnemyBtn
	self.centerBtn = widgets.centerBtn
	self.listScroll = widgets.listScroll
	self.noDChaView = widgets.noDChaView
	self.centerName = widgets.title
	self.centerName2 = widgets.title2
	self.descText = widgets.descText
	self.centerImage = widgets.centerImage
	self.centerImage2 = widgets.centerImage2
	self.cdTimeTxt = widgets.cdTime
	self.mapName = widgets.mapName
	self.progressbar = widgets.progressbar
	self.coloseBtn:onClick(self, self.onCloseUI)	
	self.seeQuickBtn:onClick(self, self.onClickseeQuickBtn)	
	self.findEnemyBtn:onClick(self, self.onClickfindEnemyBtn)	
	self.centerBtn:onClick(self, self.onClickcenterBtn)	
	self:selectTab(1)
end

function wnd_shen_bing_tongmin:onCloseUI()
	g_i3k_ui_mgr:CloseUI(eUIID_ShenshiTongmin)
end

function wnd_shen_bing_tongmin:onHideImpl( )
	self:releaseScheduler()
	self:releaseScheduler2()
end

function wnd_shen_bing_tongmin:refresh(mtype,curdata,res)
	self.listScroll:removeAllChildren()
	self.noDChaView:show()
	self.type = mtype
	if mtype == 1  then
		if curdata.data and curdata.data.targetList and #curdata.data.targetList > 0 then
			self.noDChaView:hide()
			self.cdTime = math.round((i3k_game_get_time() - curdata.data.lastInsightTime)/60)
			local info = i3k_db_shen_bing_unique_skill[g_i3k_game_context:GetSelectWeapon()] or {}
			local curcdtime = 0
			for k,v in pairs(info) do
				if v.uniqueSkillType == 6 then -- 开启洞察功能
					local curparameters = v.parameters
					if g_i3k_game_context:isMaxWeaponStar(g_i3k_game_context:GetSelectWeapon()) then
						curparameters = v.manparameters
					end
					curcdtime = curparameters[1] / 60
					break
				end
			end
			if  self.cdTime < curcdtime  then
				self.cdTimeTxt:setText(i3k_get_string(787,curcdtime - self.cdTime))
			else
				self.cdTimeTxt:setText("")
			end
			self:createDongchaUI(curdata.data.targetList)
			self.centerImage2:setImage(i3k_db_icons[i3k_db_shen_bing[3].imageIconID_dongcha].path)
		else 
			self.centerImage:setImage(i3k_db_icons[i3k_db_shen_bing[3].imageIconID_dongcha].path)
			self.centerName:setText("洞察")
			self.centerName2:setText("点击开始洞察")
			self.descText:setText(i3k_get_string(786))
			if self.centerClick then
				self.centerClick = false
				g_i3k_ui_mgr:PopupTipMessage("没有洞察到资讯，请稍后再来")
			end
		end
	elseif mtype == 2  then
		if curdata.data and curdata.data.targetList and #curdata.data.targetList > 0 then
			self.noDChaView:hide()
			self.cdTime = math.round((i3k_game_get_time() - curdata.data.lastRevengeTime)/60)
			local info = i3k_db_shen_bing_unique_skill[g_i3k_game_context:GetSelectWeapon()] or {}
			local curcdtime = 0
			for k,v in pairs(info) do
				if v.uniqueSkillType == 7 then -- 开启追仇功能
					local curparameters = v.parameters
					if g_i3k_game_context:isMaxWeaponStar(g_i3k_game_context:GetSelectWeapon()) then
						curparameters = v.manparameters
					end
					curcdtime = curparameters[1] / 60
					break
				end
			end
			if  self.cdTime < curcdtime  then
				self.cdTimeTxt:setText(i3k_get_string(789,curcdtime - self.cdTime))
			else
				self.cdTimeTxt:setText("")
			end
			self.mapName:setText("")
			self:createZhuichongUI(curdata.data.targetList)
			self.centerImage2:setImage(i3k_db_icons[i3k_db_shen_bing[3].imageIconID_zhuichou].path)
		else
			self.centerImage:setImage(i3k_db_icons[i3k_db_shen_bing[3].imageIconID_zhuichou].path)
			self.centerName:setText("追仇")
			self.centerName2:setText("点击开始追仇")
			self.descText:setText(i3k_get_string(788))
			if self.centerClick then
				self.centerClick = false
				g_i3k_ui_mgr:PopupTipMessage("您没有仇人")
			end
		end
	end
end
-- 备用方法 local children = self.listScroll:addChildWithCount(ITEMNAME,2,#date)
function wnd_shen_bing_tongmin:createZhuichongUI( date )
	for i = 1 , #date do
		local item = require(ITEMNAME)()
		self.listScroll:addItem(item)
		item.vars.desc:setText(date[i].name)
		item.vars.sendAway:onClick(self,self.onSendAway,i-1)
	end
end
function wnd_shen_bing_tongmin:createDongchaUI( date )
	for i = 1 , #date do
		local item = require(ITEMNAME)()
		self.listScroll:addItem(item)
		item.vars.desc:setText(self:getDescTile(date[i]))
		item.vars.sendAway:onClick(self,self.onSendAway,i -1)
		self.mapName:setText(i3k_db_field_map[date[i].mapID].desc)
	end
end

function wnd_shen_bing_tongmin:getDescTile( info )
	--1：世界BOSS，2：精英怪，3：宝箱
	local name = ""
	if info.entityType == 1 then
		name = i3k_db_world_boss[info.id].name
	elseif info.entityType == 2 then
		name = i3k_db_jingying_guai[info.id].name
	elseif info.entityType == 3 then
		name = i3k_db_huodong_kuang[info.id].name
	end
	if info.mapLine == 0 then
		return name.."争夺分线"
	end
	return name..info.mapLine.."线"
end

function wnd_shen_bing_tongmin:onSendAway( sender , index  )
	if self.type == 1 then
		local func = function ()
			i3k_sbean.try_transform_insight(index)
		end
		g_i3k_game_context:CheckMulHorse(func, true)
	elseif self.type == 2 then
		local func = function ()
			i3k_sbean.try_transform_revenge(index)
		end
		g_i3k_game_context:CheckMulHorse(func, true)
	end
end

--[[
	选中列表类型 1 洞察 2追仇
]]
function wnd_shen_bing_tongmin:selectTab(mtype)
	self.centerClick = false
	mtype = mtype or 1
	if mtype == 1 then
		self.seeQuickBtn:stateToPressed()
		self.findEnemyBtn:stateToNormal()
		--self:refresh(false)
		i3k_sbean.try_sync_insight()
	elseif mtype == 2 then
		self.findEnemyBtn:stateToPressed()
		self.seeQuickBtn:stateToNormal()
		--self:refresh(true)
		i3k_sbean.try_sync_revenge()
	end
end

function wnd_shen_bing_tongmin:onClickseeQuickBtn()
	self:selectTab(1)
end

function wnd_shen_bing_tongmin:onClickfindEnemyBtn()
	self:selectTab(2)
end

function wnd_shen_bing_tongmin:releaseScheduler()
	if self._scheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduler)
		self._scheduler = nil
	end

end
function wnd_shen_bing_tongmin:releaseScheduler2()

	if self._scheduler2 then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scheduler2)
		self._scheduler2 = nil
	end
end
function wnd_shen_bing_tongmin:onClickcenterBtn()
	if self.inCDtime then
		return
	end
	self._scheduler=cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
		self:releaseScheduler()
		self.inCDtime = false
	end, 2 , false)
	self.inCDtime = true
	self._scheduler2 = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
		if self.progressbar:getPercent()>=100 then	
			self:releaseScheduler2()
			self.centerClick = true
			if self.type == 1 then
				i3k_sbean.try_open_insight()
			elseif self.type == 2 then
				i3k_sbean.try_open_revenge()
			end
			self.progressbar:setPercent(0.1 )
		else
			self.progressbar:setPercent(self.progressbar:getPercent() + 5 )
		end
	end, 0.05, false)

end

function wnd_create(layout)
	local wnd = wnd_shen_bing_tongmin.new()
	wnd:create(layout)
	return wnd
end


	
