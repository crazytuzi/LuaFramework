GPageResourceLoad = class("GPageResourceLoad", function()
    return display.newScene("GPageResourceLoad")
end)
local game_tips = {

}
local cache_res = {
	"image/icon/safearea_point.png",
	"image/icon/shadow.png",
	"image/icon/cloth_loading.png",
	"image/icon/blood_normal.png",
	"image/icon/blood_yellow.png",
	"image/icon/blood_normal_bg.png",
	-- "image/icon/mon_tombstone.png",
	"ui/image/miss.png",
	"image/typeface/num_3.png",
	"image/typeface/num_37.png",
	"image/typeface/num_6.png",
	-- "effect/1030000.png",
	-- "effect/1031000.png",
	-- "effect/1032000.png",
	-- "effect/1040000.png",
	-- "effect/1041000.png",
	-- "effect/2000300.png",
	-- "effect/2020000.png",
	-- "effect/2020100.png",
	-- "effect/2020200.png",
	-- "effect/2020300.png",
	-- "effect/5000100.png",
	-- "effect/5200000.png",
	-- "cloth/100000.png",
	-- "cloth/100005.png",
	-- "cloth/100013.png",
	-- "weapon/110000.png",
	-- "weapon/210000.png",
	-- "wing/100100.png",
	-- "wing/100104.png",
	-- "mount/200110.png",
	-- "ui/sprite/buff.png",
}

function GPageResourceLoad:ctor()
	self._loadUI = nil
	self._curPage = 0
	self._freshHandle = nil
	self._percent = 0
	self._lastStep = 0
	self._curStep = 0
	self._loaded = false
	self._tick = 0
	self._waiting = false
end

function GPageResourceLoad:stopSchedule()
	if self._freshHandle then
		Scheduler.unscheduleGlobal(self._freshHandle)
		self._freshHandle = nil
	end
end

function GPageResourceLoad:onExit()
	self:stopAllActions()
	self:stopSchedule()

	cc.SpriteManager:getInstance():removeFramesByFile("ui/sprite/GPageResourceLoad")
	cc.CacheManager:getInstance():releaseUnused(false)
end

function GPageResourceLoad:onResEnterGame(event)
	print("GPageResourceLoad:onResEnterGame "..event.result)
	if event.result==100 then
		self._waiting = false
		if GameCCBridge then
			GameCCBridge.doSubmitExtendData(GameCCBridge.TYPE_ENTER_GAME)
		end
	elseif event.result==103 then
		self._waiting = true
		GameUtilSenior.showAlert("提示","当前账号在线",{"再试一次","取消"},function (event)
			if event.buttonIndex == 1 then
				self:runAction(cca.seq({
					cca.delay(5),
					cca.cb(function()
						GameSocket:EnterGame(GameBaseLogic.chrName,GameBaseLogic.seedName)
					end)
				}))
			else
				self:stopSchedule()
				GameBaseLogic.ExitToRelogin()
			end
		end,self)
	else
		if _G.buglyReportLuaException then
	        buglyReportLuaException("enter game error", "error code:"..event.result.." svr:"..GameBaseLogic.lastSvr.name)
	    end
		GameCCBridge.showMsg("角色验证失败，请重试")
		self:stopSchedule()
		GameBaseLogic.ExitToRelogin()
	end
end

function GPageResourceLoad:onPlatformLogout()
	GameBaseLogic.ExitToRelogin()
end
function GPageResourceLoad:showTips()
	if self._loadUI then
		local label = self._loadUI:getWidgetByName("labDesp")
		local random = math.random(1,#GameConst.LoadingTips)
		label:setString(GameConst.LoadingTips[random])
		label:runAction(cca.rep(cca.seq({cca.delay(1),cca.cb(function()
			random = math.random(1,#GameConst.LoadingTips)
			label:setString(GameConst.LoadingTips[random])
		end)}),1000))
	end
end
function GPageResourceLoad:onEnter()

	self.m_handler=cc.EventProxy.new(GameSocket,self)
		:addEventListener(GameMessageCode.EVENT_RES_ENTER_GAME,handler(self,self.onResEnterGame))
		:addEventListener(GameMessageCode.EVENT_PLATFORM_LOGOUT,handler(self, self.onPlatformLogout))

	GameBaseLogic.downLoading=true
	cc.DownManager:getInstance():setAllowDown(GameBaseLogic.downLoading)
	
	cc.AnimManager:getInstance():remAllAnimate()

	self._loadUI = GUIAnalysis.load("ui/layout/GPageResourceLoad.uif")
		:setContentSize(cc.size(display.width, display.height))
		:align(display.CENTER, display.cx, display.cy)
		:addTo(self)

	local sceneBg = self._loadUI:getWidgetByName("seceneBg"):setScale(cc.MAX_SCALE):align(display.CENTER, display.cx, display.cy)
	local bottom = GameConst.bottom(x,y)

	sceneBg:loadTexture("ui/image/resource_load.jpg")

	self._loadUI:getWidgetByName("box_loadingBar"):pos(bottom.x, 0)
	local labPer = self._loadUI:getWidgetByName("labPer"):align(display.CENTER, 605, 16)
	labPer:enableOutline(GameBaseLogic.getColor(0x000000),1)

	local mask = self._loadUI:getWidgetByName("mask")
	local barLight = self._loadUI:getWidgetByName("bar_light"):setVisible(false)
	self:showTips()
	self._percent = 0
	local function runLoading(dt)
		if not GameBaseLogic.chrName or not GameBaseLogic.seedName or tostring(GameBaseLogic.chrName)=="" or tostring(GameBaseLogic.seedName)=="" then
			if _G.buglyReportLuaException then
		        buglyReportLuaException("chrname error", "chrname:"..GameBaseLogic.chrName..":"..GameBaseLogic.seedName.." svr:"..GameBaseLogic.lastSvr.name)
		    end
			GameCCBridge.showMsg("角色信息错误")
			self:stopSchedule()
			GameBaseLogic.ExitToRelogin()
			return
		end

		if self._loaded then
			self._tick=self._tick+1
			if self._waiting and self._tick>=3600 then
				if _G.buglyReportLuaException then
			        buglyReportLuaException("login again error", "chrname:"..GameBaseLogic.chrName..":"..GameBaseLogic.seedName.." svr:"..GameBaseLogic.lastSvr.name)
			    end
				GameCCBridge.showMsg("重试登录超时")
				self:stopSchedule()
				GameBaseLogic.ExitToReSelect()
				return
			end
			if not self._waiting and self._tick>=3600 then
				if _G.buglyReportLuaException then
			        buglyReportLuaException("login first error", "chrname:"..GameBaseLogic.chrName..":"..GameBaseLogic.seedName.." svr:"..GameBaseLogic.lastSvr.name)
			    end
				GameCCBridge.showMsg("服务器连接超时")
				self:stopSchedule()
				GameBaseLogic.ExitToReSelect()
				return
			end
		end

		if self._percent<100 then
			self._percent=self._percent+1
		end
		labPer:setString("加载进度："..math.floor(self._percent).."%")
		if not barLight:isVisible() then
			barLight:setVisible(true)
		end
		local width = math.max(self._percent*936/100, 10)
		mask:size(width + 10,83)
		barLight:setPosition(width-40, 45)

		if self._lastStep == self._curStep then
			self._lastStep=self._lastStep+1

			if self._curStep < #cache_res then
				asyncload_callback(cache_res[self._lastStep], self, function(filepath, texture)
					self._curStep=self._curStep+1
					if self._percent<(40/#cache_res)*self._curStep then self._percent=math.floor((40/#cache_res)*self._curStep) end
				end,true)
			elseif self._curStep==#cache_res then
				asyncload_frames("ui/sprite/GUIMain",".png",function ()
					self._curStep=self._curStep+1
					if self._percent<50 then self._percent=50 end
				end,self)
			elseif self._curStep==#cache_res+1 then
				asyncload_frames("ui/sprite/GUINewMain",".png",function ()
					self._curStep=self._curStep+1
					if self._percent<53 then self._percent=53 end
				end,self)
			elseif self._curStep==#cache_res+2 then
				asyncload_frames("ui/sprite/GUICommon",".png",function ()
					self._curStep=self._curStep+1
					if self._percent<55 then self._percent=55 end
				end,self)
			elseif self._curStep==#cache_res+3 then
				asyncload_frames("ui/sprite/ContainerBg",".png",function ()
					self._curStep=self._curStep+1
					if self._percent<60 then self._percent=60 end
				end,self)
			elseif self._curStep==#cache_res+4 then
				cc.BinManager:getInstance():loadBiz(GROUP_TYPE.CLOTH,"sprite/data/dress.data")
				cc.BinManager:getInstance():loadBiz(GROUP_TYPE.CLOTH,"sprite/data/npc.data")
				self._curStep=self._curStep+1
				if self._percent<65 then self._percent=65 end
			elseif self._curStep==#cache_res+5 then
				cc.BinManager:getInstance():loadBiz(GROUP_TYPE.WEAPON,"sprite/data/arm.data")
				self._curStep=self._curStep+1
				if self._percent<70 then self._percent=70 end
			elseif self._curStep==#cache_res+6 then
				cc.BinManager:getInstance():loadBiz(GROUP_TYPE.WING,"sprite/data/fly.data")
				-- cc.BinManager:getInstance():loadBiz(GROUP_TYPE.MOUNT,"sprite/data/mount.data")
				self._curStep=self._curStep+1
				if self._percent<75 then self._percent=75 end
			elseif self._curStep==#cache_res+7 then
				cc.BinManager:getInstance():loadBiz(GROUP_TYPE.CLOTH,"sprite/data/ai.data")
				cc.BinManager:getInstance():loadDiff(GROUP_TYPE.CLOTH,"sprite/data/ai.dat")
				self._curStep=self._curStep+1
				if self._percent<80 then self._percent=80 end
			elseif self._curStep==#cache_res+8 then
				cc.BinManager:getInstance():loadDiff(GROUP_TYPE.EFFECT,"sprite/data/effect1.dat")
				cc.BinManager:getInstance():loadBiz(GROUP_TYPE.EFFECT,"sprite/data/effect.data")
				cc.BinManager:getInstance():loadBiz(GROUP_TYPE.CLOTH_REVIEW,"image/data/dress.data")
				cc.BinManager:getInstance():loadBiz(GROUP_TYPE.FDRESS_REVIEW,"image/data/fdress.data")
				cc.BinManager:getInstance():loadBiz(GROUP_TYPE.WEAPON_REVIEW,"image/data/arm.data")
				cc.BinManager:getInstance():loadBiz(GROUP_TYPE.CELL_REVIEW,"image/data/cell.data")
				cc.BinManager:getInstance():loadBiz(GROUP_TYPE.TITLE,"image/data/title.data")
				cc.BinManager:getInstance():loadBiz(GROUP_TYPE.WING_REVIEW,"image/data/fly.data")
				self._curStep=self._curStep+1
				if self._percent<85 then self._percent=85 end
			elseif self._curStep==#cache_res+9 then
				-- asyncload_frames("image/typeface/GUINumToast",".png",function ()
				asyncload_frames("ui/sprite/GUITips",".png",function ()
					self._curStep=self._curStep+1
					if self._percent<86 then self._percent=86 end
				end,self)
			elseif self._curStep==#cache_res+10 then
				asyncload_frames("image/typeface/GUINumToast",".png",function ()
					self._curStep=self._curStep+1
					if self._percent<87 then self._percent=87 end
				end,self)
			elseif self._curStep==#cache_res+11 then
					asyncload_frames("ui/sprite/GUIBuffIcon",".png",function ()
						self._curStep = self._curStep+1
						if self._percent<88 then self._percent=88 end
					end,self)
			elseif self._curStep==#cache_res+12 then
					asyncload_frames("ui/sprite/GUINewCommon",".png",function ()
						self._curStep = self._curStep+1
						if self._percent<89 then self._percent=89 end
					end,self)
					asyncload_frames("ui/sprite/V4_ContainerHuoDongAnNiu",".png",function ()
					end,self)
			--elseif self._curStep==#cache_res+13 then
			--		asyncload_frames("ui/sprite/V4_ContainerDengJiShiJie",".png",function ()
			--			self._curStep = self._curStep+1
			--			if self._percent<89 then self._percent=89 end
			--		end,self)
			elseif self._curStep==#cache_res+13 then
				self._curStep=self._curStep+1
				self._loaded = true
			elseif self._curStep>#cache_res+13 then
			
				print("step 14===============")
				if not self._waiting then
					if GameSocket._connected then
						print("step 14 _connected===============",GameSocket.mNetMap.mMapID)
						if GameSocket.mNetMap.mMapID then
							print("step 14 nMapID===============")
							GameMusic.stop("music")
							self:stopSchedule()
							cc.Director:getInstance():replaceScene(cc.SceneGame:create())
							print("step 14 enterMap===============")
							return
						end
					else
						-- if _G.buglyReportLuaException then
					 --        buglyReportLuaException("connect error", "chrname:"..GameBaseLogic.chrName..":"..GameBaseLogic.seedName.." svr:"..GameBaseLogic.lastSvr.name)
					 --    end
						GameCCBridge.showMsg("登陆失败，请重试")
						self:stopSchedule()
						GameBaseLogic.ExitToRelogin()
						return
					end
				end
				self._curStep=self._curStep+1
			end
		end
	end

	GameSetting.setConf("LastChrName",GameBaseLogic.chrName)
	print("EnterGame",GameBaseLogic.chrName,GameBaseLogic.seedName)
	GameSocket:EnterGame(GameBaseLogic.chrName,GameBaseLogic.seedName)

	self._freshHandle = Scheduler.scheduleGlobal(runLoading,1/60)
end

return GPageResourceLoad