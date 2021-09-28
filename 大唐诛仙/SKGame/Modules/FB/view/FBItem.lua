FBItem =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function FBItem:__init( ... )
	self.URL = "ui://wetrdvlhlgaa1k";
	self:__property(...)
	self:Config()
end

-- Set self property
function FBItem:SetProperty( ... )
	
end

-- Logic Starting
function FBItem:Config()
	self.EnterBtn.onClick:Clear()
	self.EnterBtn.onClick:Add(self.EnterFB,self)
end

function FBItem:RefreshCells(rewardList)
	local startX = -100
	local startY = -100
	for i = 1 ,#rewardList do
		local data = rewardList[i] or {}
		local icon = PkgCell.New(self.rewardConn)
		icon:SetXY(startX + 100 * i, startY)
		icon:OpenTips(true)
		icon:SetDataByCfg(data[1], data[2], data[3], data[4])
		--self.rewardConn:AddChild(icon.ui)
	end
end

function FBItem:Init(vo, idx)
	self.vo = vo
	if vo then
		local mapcfg = GetCfgData("mapManger"):Get(vo.mapId)
		local maxCount = mapcfg.maxCount
		self.bg.url = StringFormat("Icon/FB/{0}",vo.mapIcon)
		self.FbName.text = StringFormat("{0}",vo.mapName)
		self.FbLevel.text = StringFormat("怪物战力: {0}", mapcfg.ability or 0)

		local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
		local openLevel = mapcfg.openLevel
		self:RefreshCells(mapcfg.reward or {})

		if mainPlayer.level < openLevel then
			self.imgGray.visible = true
			self.txtUnlock.visible = true
			self.txtUnlock.text = StringFormat("{0}级解锁", openLevel)
			self.EnterBtn.visible = false
		else
			self.EnterBtn.visible = true
			--如果是未激活
			if vo.isOpen then
				--self.bg.grayed = false
				self.imgGray.visible = false
				self.txtUnlock.visible = false

				if vo.enterCount > 0 then
					self.EnterBtn.enabled = true
					-- self.EnterBtn:GetChild("icon").url = 
					self.EnterBtn:GetChild("title").text = StringFormat("[color=#000000]进入[/color]")
					--self.RefreshLabel.text = StringFormat("[color=#545e6c]剩余次数：[/color][color=#084b0f]{0}/{1}[/color]",vo.enterCount , maxCount)
					--self.Flag.url = "ui://wetrdvlhlgaa1d"
				else
					self.EnterBtn.enabled = false
					-- self.EnterBtn:GetChild("icon").url = 
					self.EnterBtn:GetChild("icon").grayed = true
					self.EnterBtn:GetChild("title").text = StringFormat("[color=#000000]进入[/color]")
					--self.RefreshLabel.text = StringFormat("[color=#bc1515]今日次数已刷完[/color]")--今日次数已经刷完
					--self.Flag.url = "ui://wetrdvlhlgaa1c"
				end
			else
				self.imgGray.visible = true
				self.txtUnlock.text = "未激活"
				self.txtUnlock.visible = true

				--self.bg.grayed = true
				self.EnterBtn.enabled = false	
				-- self.EnterBtn:GetChild("icon").url = 
				self.EnterBtn:GetChild("title").text = StringFormat("[color=#e3e3e3]未激活[/color]")
				--self.RefreshLabel.text = StringFormat("[color=#545e6c]等级不符[/color]")--等级不符
				--self.Flag.url = "ui://wetrdvlhlgaa1b"
			end
		end
		local x, y = FBModel:GetInstance():GetOneFBTimes(vo.mapId)
		self.EnterBtn.text = StringFormat("[color=#000000]进入\n({0}/{1})[/color]", x, y) 
	else

	end
end

function FBItem:Refresh(vo)
	
end

function FBItem:EnterFB()
	--申请进入副本
	local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
	if mainPlayer then
		if mainPlayer.level >= self.vo.openLevel then
			local function cb()
				FBController:GetInstance():RequireEnterInstance(self.vo.mapId)
			end
			local model = PkgModel:GetInstance()
			local now = #model:GetOnGrids() or 0
			local total = model.bagGrid or 0
			local msg = StringFormat("您的背包快满了( [COLOR=#ff0000]{0}[/COLOR]/{1} ) 请尽快清理", now, total)
			local mapcfg = GetCfgData("mapManger"):Get(self.vo.mapId)
			local needBagTip = true
			if mapcfg and mapcfg.rewardType == 0 then
				needBagTip = false
			end
			local function enterCheck()
				if total - now < 8 then
					if needBagTip then
						UIMgr.Win_Confirm("背包提示", msg, "进入副本", "整理背包", cb, function ()
							PkgCtrl:GetInstance():Open()
						end, true)
					else
						cb()
					end
				else
					cb()
				end
			end
			if FBModel:GetInstance():CheckEnterTimes() then
				local zdModel = ZDModel:GetInstance()
				local teamId = zdModel:GetTeamId()
				local num = zdModel:GetMemNum() or 0
				if teamId == 0 or ( teamId ~= 0 and num == 1 ) then
					--FBController:GetInstance():RequireEnterInstance(self.vo.mapId)
					enterCheck()
				else
					local isLeader = zdModel:IsLeader()
					if isLeader then
						--队长判断成员是否在主场景
						local memTab = ZDModel:GetInstance():GetNotInMainMapMember()
						if memTab and #memTab > 0 then
							local nameStr = ZDModel:GetInstance():GetNameTipStr(memTab)
							UIMgr.Win_FloatTip(nameStr)
						end
					end
					FBController:GetInstance():RequireEnterInstance(self.vo.mapId)
				end
			else
				local tipsContent = GetCfgData("game_exception"):Get(1201)
				if not TableIsEmpty(tipsContent) and tipsContent.exceptionMsg then
					Message:GetInstance():TipsMsg(tipsContent.exceptionMsg)
				end
			end
		end
	end
end


-- Register UI classes to lua
function FBItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("FB","FBItem");

	self.bg = self.ui:GetChild("Bg")
	self.line = self.ui:GetChild("line")
	self.FbName = self.ui:GetChild("FbName")
	self.FbLevel = self.ui:GetChild("FbLevel")
	--self.Flag = self.ui:GetChild("Flag")
	--self.RefreshLabel = self.ui:GetChild("RefreshLabel")
	self.EnterBtn = self.ui:GetChild("EnterBtn")

	self.txtUnlock = self.ui:GetChild("txtUnlock")
	self.imgGray = self.ui:GetChild("imgGray")
	self.rewardConn = self.ui:GetChild("rewardConn")
	self.cells = {}
end

-- Combining existing UI generates a class
function FBItem.Create( ui, ...)
	return FBItem.New(ui, "#", {...})
end

-- Dispose use FBItem obj:Destroy()
function FBItem:__delete()
	self.bg = nil
	self.line = nil
	self.FbName = nil
	self.FbLevel = nil
	--self.Flag = nil
	--self.RefreshLabel = nil
	self.EnterBtn = nil
	self:DestroyCells()
end

function FBItem:DestroyCells()
	for _, v in pairs(self.cells) do
		if v then
			v:Destroy()
		end
	end
	self.cells = nil
end