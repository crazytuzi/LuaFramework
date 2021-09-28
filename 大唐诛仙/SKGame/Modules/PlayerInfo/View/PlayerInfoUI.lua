PlayerInfoUI =BaseClass(LuaUI)

function PlayerInfoUI:__init( ... )
	self:RegistUI()
	self:Config()
end

function PlayerInfoUI:Config()
end

function PlayerInfoUI:RegistUI()
	local ui = UIPackage.CreateObject("PlayerInfo","PlayerInfoUI")
	self.ui = ui
	self.bg = ui:GetChild("bg")
	self.verLine = ui:GetChild("verLine")
	self.playerRole = ui:GetChild("playerRole")
	self.expProBar = ui:GetChild("expProBar")
	self.barBg = ui:GetChild("barBg")
	self.playerLevel = ui:GetChild("playerLevel")
	self.playerProp = ui:GetChild("playerProp")
	self.propInfo = ui:GetChild("propInfo")
	self.nameBg = ui:GetChild("nameBg")
	self.playerName = ui:GetChild("playerName")
	self.playerNameGroup = ui:GetChild("playerNameGroup")
	self.btnVipIcon = ui:GetChild("btnVipIcon")
	self.labelPlayerUID = ui:GetChild("labelPlayerUID")

	self.btnVipIcon.visible = not SHENHE

	self.equipListPage = ui:GetChild("equipListPage") -- 装备列表
	self.equipListPage = PlayerEquipListPage.Create(self.equipListPage)
	
	self.playerEquipList = ui:GetChild("playerEquipList") -- 装备部位栏
	self.playerEquipList = PlayerEquipList.Create(self.playerEquipList)

	VipController:GetInstance():C_GetPlayerVip()       --发送获取玩家vip信息请求

	self.touch = self.playerRole
	self.role3D = self.playerRole:GetChild("Role3D")
	self.propInfo = PropInfo.Create(self.propInfo)
	self.model = PlayerInfoModel:GetInstance()
	self.touchId = -1
	self.lastTouchX = 0
	self.playerModel = nil
	self.pos = 0 --当前打开的skepList 的pos
	self:InitEvent()
end

function PlayerInfoUI:InitEvent()
	--旋转模型
	self.touch.onTouchBegin:Add(self.RotationPlayerModel,self)
	self.btnVipIcon.onClick:Add(function ()              --vip按钮点击
		MallController:GetInstance():OpenMallPanel(1,1)
	end,self)
end

--添加事件
function PlayerInfoUI:AddEvent()
	self:RemoveEvent()
	self.handler1 = self.model:AddEventListener(PlayerInfoConst.EventName_OpenEquipList, function ( data ) self:OpenEquipList(data) end) -- 显示装备列表
	self.handler2 = self.model:AddEventListener(PlayerInfoConst.EventName_OpenEquipTips, function ( data ) self:OpenEquipTips(data) end) -- 显示装备tips
	self.handler3 = GlobalDispatcher:AddEventListener(EventName.EQUIPINFO_CHANGE, function ()
		self:Refresh()
		if self.isOpenPartPanel and self.equipListPage then
			self.equipListPage:Update(true)
		end
	end)
	self.handler4 = GlobalDispatcher:AddEventListener(EventName.MAINPLAYER_UPDATE, function (key, value, pre) self:RefreshPlayerInfo(key, value, pre) end)  --刷新主角信息
	self.handler5 = GlobalDispatcher:AddEventListener(EventName.RefershPlayerInfoRedTips , function() self:RefershRedTips() end)

--vip全局事件---------------------------------------------------------
	self.vipChangeHandle = GlobalDispatcher:AddEventListener(EventName.VIPLV_CHANGE, function (lv,time,jhState,playerVipId)
		if playerVipId > 0 then
			self.btnVipIcon.icon = "Icon/Vip/vip"..playerVipId
			self.btnVipIcon.grayed = false
		else
			self.btnVipIcon.icon = "Icon/Vip/vip1"
			self.btnVipIcon.grayed = true
		end 
	end)
	self.vipLoginHandle = GlobalDispatcher:AddEventListener(EventName.GETVIPINFO_CHANGE, function (lv)
		if lv > 0 then
			self.btnVipIcon.icon = "Icon/Vip/vip"..lv
			self.btnVipIcon.grayed = false
		else
			self.btnVipIcon.icon = "Icon/Vip/vip1"
			self.btnVipIcon.grayed = true
		end 
	end)
----------------------------
end

--删除事件
function PlayerInfoUI:RemoveEvent()
	self.model:RemoveEventListener(self.handler1)
	self.model:RemoveEventListener(self.handler2)
	Stage.inst.onTouchMove:Remove(self.onTouchMove, self)
	Stage.inst.onTouchEnd:Remove(self.onTouchEnd,self)
	
	GlobalDispatcher:RemoveEventListener(self.handler3)
	GlobalDispatcher:RemoveEventListener(self.handler4)
	GlobalDispatcher:RemoveEventListener(self.handler5)

	GlobalDispatcher:RemoveEventListener(self.vipChangeHandle)
	GlobalDispatcher:RemoveEventListener(self.vipLoginHandle)
end

--初始化窗口
function PlayerInfoUI:InitPanel()
	local playerVo = SceneModel:GetInstance():GetMainPlayer()
	self.playerLevel.text = StringFormat("{0}级", playerVo.level) --玩家的等级
	self.playerName.text = StringFormat("{0}", playerVo.name) --玩家姓名
	self.labelPlayerUID.text = StringFormat("ID: {0}" , playerVo.eid) --玩家eid


	self:UpdateExp(playerVo)
	self:CreatePlayerModel()
	self.playerEquipList:Init()--初始化玩家装备信息
	self.propInfo:Init(playerVo)--初始化玩家的属性面板
	self:CreateFurnace()
	self:AddEvent()
end

local furnaceIconUrl = "ui://0tyncec1hymbnqd" -- "Common","CustomIconI"
function PlayerInfoUI:CreateFurnace()
	local furnaceModel = FurnaceModel:GetInstance()
	local ids = FurnaceConst.cfgIds
	local star = 0
	local stage = 0
	for i=1,#ids do
		local id = ids[i]
		local cell = UIPackage.CreateObjectFromURL(furnaceIconUrl)
		self.ui:AddChild(cell)
		cell:SetXY(207+100*(i-1), 640)
		local actived = furnaceModel:GetActivedVo(id)
		if actived and actived.stage ~= 0 then
			local vo = furnaceModel:GetCfgItem(actived.stage,actived.star,id)
			cell.icon = "Icon/Goods/"..vo.icon
		else
			local vo = furnaceModel:GetCfgItem(0,0,id)
			cell.icon = "Icon/Goods/"..vo.icon
			cell.title="未激活"
			cell:GetChild("icon").grayed = true
		end
		cell.data = vo
	end
end

--刷新窗口
function PlayerInfoUI:Refresh()
	local playerVo = SceneModel:GetInstance():GetMainPlayer()
	self:CreatePlayerModel()
	self.playerEquipList:Refresh()
	self.propInfo:Init(playerVo)
end

function PlayerInfoUI:UpdateExp(playerVo)
	self.playerLevel.text = StringFormat("{0}级", playerVo.level) --玩家的等级
	local needExp = playerVo:GetLevelExp() --玩家经验
	self.expProBar.value = playerVo.exp
	self.expProBar.max = needExp
	self.expProBar:GetChild("title").text = StringFormat("{0}/{1}", playerVo.exp, needExp)
end

--创建角色3d模型
function PlayerInfoUI:CreatePlayerModel()
	local scene = SceneController:GetInstance():GetScene()
	if not scene then return end
	local mainPlayer = scene:GetMainPlayer()
	if mainPlayer then
		local dressStyle = mainPlayer.vo.dressStyle
		local wingStyle = mainPlayer.vo.wingStyle or 0
		local weaponStyle = mainPlayer:GetWeaponStyle() or 0

		local weaponEftId = mainPlayer:GetWeaponEftId() or 0
		
		local modelName = dressStyle.."_"..wingStyle.."_"..weaponStyle.."_"..weaponEftId
		if self.modelName == nil or (self.modelName and self.modelName ~= modelName) then
			self.modelName = modelName
			if self.playerModel then
				if dressStyle then
					UnLoadPlayer(dressStyle , false)
				end
				destroyImmediate(self.playerModel) 
			end
			self.role3D.visible = true
			CreateModel(function(model)
					self.playerModel = model
					self.playerModel.name = self.modelName
					local tf = model.transform
					tf.localScale = Vector3.New(250, 250, 250)
					tf.localPosition = Vector3.New(35, 151, 1000)
					tf.localEulerAngles = Vector3.New(0, 180, 0)
					self.role3D:SetNativeObject(GoWrapper.New(model)) -- ui 3d对象加入
				end, dressStyle, weaponStyle, wingStyle, weaponEftId)
		end
	end
end

--旋转角色模型
function PlayerInfoUI:RotationPlayerModel( context )
	if self.touchId == -1 then
		local evt = context.data
		self.touchId = evt.touchId
		Stage.inst.onTouchMove:Add( self.onTouchMove, self )
		Stage.inst.onTouchEnd:Add( self.onTouchEnd, self )
	end
end

--touchmove
function PlayerInfoUI:onTouchMove(context)
	if (not self.playerModel) or ToLuaIsNull(self.playerModel) then log("人物数据模型为nil") return end
	local evt = context.data
	if evt and self.touchId ~= -1 and evt.touchId == self.touchId then
		local evt = context.data
		if self.lastTouchX ~= 0 then
			local tf = self.playerModel.transform
			local rotY = tf.localEulerAngles.y - (evt.x - self.lastTouchX)
			tf.localEulerAngles = Vector3.New(0, rotY, 0)
		end
	end
	self.lastTouchX = evt.x
end

--touchend
function PlayerInfoUI:onTouchEnd( context )
	local evt = context.data
	if evt and self.touchId ~= -1 and evt.touchId == self.touchId then
		self.touchId = -1
		self.lastTouchX = 0
		Stage.inst.onTouchMove:Remove(self.onTouchMove, self)
		Stage.inst.onTouchEnd:Remove(self.onTouchEnd,self)
	end
end
function PlayerInfoUI:Close()
	if self.playerModel then
		local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
		if mainPlayer and mainPlayer.vo then
			UnLoadPlayer(mainPlayer.vo.dressStyle , false)
		end

		destroyImmediate(self.playerModel) 
	end
	self.playerModel = nil
end

function PlayerInfoUI:RefershRedTips()
	self.playerEquipList:SetRedTipsState()
end
--打开装备列表 参数装备位置 pos
function PlayerInfoUI:OpenEquipList(pos)
	local list = PkgModel:GetInstance():GetRoleEquipByType(pos, true)
	if list and #list > 0 then
		self.isOpenPartPanel = true
		self.equipListPage:Show(pos, list)
	else
		self.isOpenPartPanel = false
		self.equipListPage:Hide()
	end
end

--打开装备tips
function PlayerInfoUI:OpenEquipTips(itemVo)
	if itemVo == nil then return end
	-- local height = 105
	local view = nil
	local compareView = nil
	UIMgr.HidePopup()
	if itemVo.state == 2 then --如果是自己的装备，就直接不用判断身上是否有装备
		view = EquipmentInfoTips.New()
		UIMgr.ShowPopupToPos(view,326,121)
		view:Init(itemVo)
	else
		--通过部位获取装备信息
		--如果身上有装备，就打开对比的标签
		local compareItemVo = PkgModel:GetInstance():GetOnEquipByEquipType(itemVo.equipType)
		if compareItemVo then
			view = EquipmentInfoTips.New()
			UIMgr.ShowPopupToPos(view,326+68,121)
			view:Init(itemVo, true, compareItemVo)
			compareView = EquipmentInfoTips.New()
			UIMgr.ShowPopupToPos(compareView, 0,121)
			compareView:Init(compareItemVo)
		else
			view = EquipmentInfoTips.New()
			UIMgr.ShowPopupToPos(view,326,121)
			view:Init(itemVo)
		end
	end
end

function PlayerInfoUI:RefreshPlayerInfo(key, value, pre)
	if key == "exp" then
		local playerVo = SceneModel:GetInstance():GetMainPlayer()
		self:UpdateExp(playerVo)
	end
end

function PlayerInfoUI:OnDisable()
	UIMgr.HidePopup()
	self:RemoveEvent()
end

function PlayerInfoUI:OnHideHanlder()
	self.equipListPage:Hide()
	UIMgr.HidePopup()
end

function PlayerInfoUI:OnOpenHanlder()
	self:Refresh()
end

function PlayerInfoUI:SetVisible(v)
	if v then
		self:OnOpenHanlder()
	else
		self:OnHideHanlder()
	end
	LuaUI.SetVisible(self, v)
end
function PlayerInfoUI:__delete()
	self:RemoveEvent()
	if self.playerModel then	
		local mainPlayer = SceneModel:GetInstance():GetMainPlayer()
		if mainPlayer and mainPlayer.vo then
			UnLoadPlayer(mainPlayer.vo.dressStyle , false)
		end
		destroyImmediate(self.playerModel) 
	end

	self.playerModel = nil
	if self.propInfo then
		self.propInfo:Destroy()
		self.propInfo = nil
	end
	if self.playerEquipList then
		self.playerEquipList:Destroy()
	end
	self.playerEquipList = nil
	if self.equipTipsCompare then
		self.equipTipsCompare:Destroy()
	end
	self.equipTipsCompare = nil
	if self.equipListPage then
		self.equipListPage:Destroy()
	end
	self.equipListPage = nil
	self.pos = 0

	self.bg = nil
	self.verLine = nil
	self.playerRole = nil
	self.expProBar = nil
	self.barBg = nil
	self.playerLevel = nil
	self.playerProp = nil
	self.propInfo = nil
	self.nameBg = nil
	self.playerName = nil
	self.playerNameGroup = nil
end