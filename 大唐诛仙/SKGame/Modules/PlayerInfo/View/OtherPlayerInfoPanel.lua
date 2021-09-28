OtherPlayerInfoPanel = BaseClass(LuaUI)
function OtherPlayerInfoPanel:__init( ... )
	resMgr:AddUIAB("PlayerInfo")
	local ui = UIPackage.CreateObject("PlayerInfo","OtherPlayerInfoPanel")
	self.ui = ui
	self.bg = ui:GetChild("bg")
	self.role3D = ui:GetChild("role3D")
	-- self.n1 = ui:GetChild("n1")
	-- self.proListBg = ui:GetChild("proListBg")
	self.equipList = ui:GetChild("equipList")
	-- self.proName = ui:GetChild("proName")
	self.n22 = ui:GetChild("n22")
	self.power = ui:GetChild("power")
	self.n21 = ui:GetChild("n21")
	self.achiveTitle = ui:GetChild("achiveTitle")
	self.nameBg = ui:GetChild("nameBg")
	self.playerName = ui:GetChild("playerName")
	self.n9 = ui:GetChild("n9")
	self.desfsfcName = ui:GetChild("desfsfcName")
	self.proListBg_2 = ui:GetChild("proListBg")
	self.line = ui:GetChild("line")
	self.n35 = ui:GetChild("n35")
	self.sortName = ui:GetChild("sortName")
	self.fdsda21312s = ui:GetChild("fdsda21312s")
	self.groupInName = ui:GetChild("groupInName")
	self.fdsda21s = ui:GetChild("fdsda21s")
	self.level = ui:GetChild("level")
	self.n14 = ui:GetChild("n14")
	self.descName = ui:GetChild("descName")
	self.proListBg_3 = ui:GetChild("proListBg")
	self.propList = ui:GetChild("propList")
	self.touch = ui:GetChild("touch")
	self.btnClose = ui:GetChild("btnClose")
	self.btn_vipIcon = ui:GetChild("btn_vipIcon")  --添加vip显示按钮

	self.btn_vipIcon.visible = not SHENHE

	self.creatLists = nil
	self.touchId = -1
	self.lastTouchX = 0
	self.playerModel = nil

	self:AddEvents()
end

function OtherPlayerInfoPanel:AddEvents()
	self.btnClose.onClick:Add(self.ClosePanel, self)

	self.touch.onTouchBegin:Add(self.RotationPlayerModel,self)

	self.btn_vipIcon.onClick:Add(function ()              --vip按钮点击_+++++++++++++++++++++
		self:ClosePanel()
		MallController:GetInstance():OpenMallPanel(1,1)
	end,self)
end

function OtherPlayerInfoPanel:RemoveEvents()
	self.btnClose.onClick:Remove(self.ClosePanel, self)

	self.touch.onTouchBegin:Remove(self.RotationPlayerModel,self)
end

--旋转角色模型
function OtherPlayerInfoPanel:RotationPlayerModel( context )
	if self.touchId == -1 then
		local evt = context.data
		self.touchId = evt.touchId
		Stage.inst.onTouchMove:Add( self.onTouchMove, self )
		Stage.inst.onTouchEnd:Add( self.onTouchEnd, self )
	end
end

--touchmove
function OtherPlayerInfoPanel:onTouchMove(context)
	if not self.playerModel then log("人物数据模型为nil") return end
	local evt = context.data
	if evt and self.touchId ~= -1 and evt.touchId == self.touchId then
		local evt = context.data
		if self.lastTouchX ~= 0 then
			local rotY = self.playerModel.transform.localEulerAngles.y - (evt.x - self.lastTouchX)
			self.playerModel.transform.localEulerAngles = Vector3.New(0, rotY, 0)
		end
	end
	self.lastTouchX = evt.x
end

--touchend
function OtherPlayerInfoPanel:onTouchEnd( context )
	local evt = context.data
	if evt and self.touchId ~= -1 and evt.touchId == self.touchId then
		self.touchId = -1
		self.lastTouchX = 0
		Stage.inst.onTouchMove:Remove(self.onTouchMove, self)
		Stage.inst.onTouchEnd:Remove(self.onTouchEnd,self)
	end
end

-- --关闭界面
function OtherPlayerInfoPanel:ClosePanel( )
	UIMgr.HidePopup()
end

function OtherPlayerInfoPanel:Update(data)
	self.data = data
	self.playerName.text =  self.data.playerName
	self.level.text = StringFormat("{0}级",self.data.level)
	local sortId = data.sortId
	if self.data.familyName ~= "" and sortId ~= 0 then
		local sName = ""
		sName = FamilyConst.Job[sortId]
		if self.sortName then self.sortName.text = sName end
		self.groupInName.text = self.data.familyName
	end
	self.power.text =  "i"..self.data.battleValue
	if self.data.vipLevel then	
		if self.data.vipLevel > 0 then
			self.btn_vipIcon.icon = "Icon/Vip/vip"..self.data.vipLevel        --vip显示
			self.btn_vipIcon.touchable = true
		else
			self.btn_vipIcon.icon = " "
			self.btn_vipIcon.touchable = false
		end
	else
		self.btn_vipIcon.icon = " "
		self.btn_vipIcon.touchable = false
	end
	self.creatLists = {}
	for i = 1, #self.data.baseProperty do
		local prop = self.propList:AddItemFromPool()	
		local pName = prop:GetChild("PropName")
		local pValue = prop:GetChild("PropValue")
		local propertyId = self.data.baseProperty[i][1]
		local propertyValue = self.data.baseProperty[i][2]

		if 21 == propertyId or 22 == propertyId or 23 == propertyId then --伤害加深|伤害减免|暴击伤害率
			propertyValue = string.format("%.1f", propertyValue*0.01).."%"
		end

		pName.text = RoleVo.GetPropDefine(propertyId).name
		pValue.text = propertyValue
		table.insert(self.creatLists, prop)
		if i == #self.data.baseProperty then
			prop:GetChild("line").visible = false
		end
	end

	local posOrder = {1, 2, 3, 7, 4, 5, 6, 8}
	for i = 1, #posOrder do
		local cell = nil 
		local pos = posOrder[i]
		if self.data.equipinfoList[pos] then
			local baseVo = GoodsVo.New()
			baseVo:SetCfg(GoodsVo.GoodType.equipment, self.data.equipinfoList[pos].bid, 1, self.data.equipinfoList[pos].isBinding)
			baseVo.equipId = self.data.equipinfoList[pos].id
			baseVo.state = 4

			cell = PkgCell.New(self.equipList)
			cell:SetData(baseVo)
			local data = self.data.equipinfoList[pos]
			data.state = 4
			cell:SetOtherInfo(data)
			cell:OpenTips(true, true)
		else
			cell = PkgCell.New(self.equipList)
			cell:SetIconUrl(self:GetShuiyin(pos))
		end
		table.insert(self.creatLists, cell.ui)
	end

	local cfg = GetCfgData("equipment"):Get(self.data.weaponStyle)
	local weaponEftId = 0 
	local weaponStyle = 0 
	if cfg then
		if cfg.rare == 4 or cfg.rare ==5 then --品阶为4或者5的武器才能加载武器光效
			weaponEftId = cfg.effect
		end

		weaponStyle = cfg.weaponStyle
	end

	self.role3D.visible = true
	CreateModel(function(model)
			self.playerModel = model
			model.transform.localScale = Vector3.New(260, 260, 260)
			model.transform.localPosition = Vector3.New(35,-46,200)
			model.transform.localEulerAngles = Vector3.New(0, 180, 0)
			self.role3D:SetNativeObject(GoWrapper.New(model)) -- ui 3d对象加入
		end, self.data.dressStyle, weaponStyle, self.data.wingStyle, weaponEftId)

	self:CreateFurnace(data.furnaceList)
end
local furnaceIconUrl = "ui://0tyncec1hymbnqd" -- "Common","CustomIconI"
function OtherPlayerInfoPanel:CreateFurnace(furnaceList)
	local furnaceModel = FurnaceModel:GetInstance()
	local ids = FurnaceConst.cfgIds
	local star = 0
	local stage = 0
	for i=1,#ids do
		local id = ids[i]
		local cell = UIPackage.CreateObjectFromURL(furnaceIconUrl)
		self.ui:AddChild(cell)
		cell:SetXY(93+90*(i-1), 496)
		local actived = nil
		for _,v in ipairs(furnaceList) do
			if v.furnaceId == id then
				actived = v
				break
			end
		end
		if actived and actived.stage ~= 0 then
			local vo = furnaceModel:GetCfgItem(actived.stage, actived.star, id)
			cell.icon = "Icon/Goods/"..vo.icon
		else
			local vo = furnaceModel:GetCfgItem(0, 0, id)
			cell.icon = "Icon/Goods/"..vo.icon
			cell.title="未激活"
			cell:GetChild("icon").grayed = true
		end
		cell.data = vo
	end
end

function OtherPlayerInfoPanel:GetShuiyin( pos )
	if pos == 1 then
		return UIPackage.GetItemURL("PlayerInfo", "cap_s")	-- 头盔
	elseif pos == 2 then
		return UIPackage.GetItemURL("PlayerInfo", "clothes_s")	-- 铠甲
	elseif pos == 3 then
		return UIPackage.GetItemURL("PlayerInfo", "shoes_s")	-- 裤子
	elseif pos == 4 then
		return UIPackage.GetItemURL("PlayerInfo", "necklace_s")	-- 项链
	elseif pos == 5 then
		return UIPackage.GetItemURL("PlayerInfo", "wrist_s")	-- 护腕
	elseif pos == 6 then
		return UIPackage.GetItemURL("PlayerInfo", "ring_s")		-- 戒指
	elseif pos == 7 then
		return UIPackage.GetItemURL("PlayerInfo", "sword_s")	-- 主武
	elseif pos == 8 then
		return UIPackage.GetItemURL("PlayerInfo", "shield_s")	-- 盾
	end
end

-- Dispose use OtherPlayerInfoPanel obj:Destroy()
function OtherPlayerInfoPanel:__delete()
	self:RemoveEvents()

	FamilyModel:GetInstance():SetFamilyModelShow(true)
	destroyUIList(self.creatLists)
	self.creatLists = nil
	GlobalDispatcher:DispatchEvent(EventName.PLAYER_MODEL)
end