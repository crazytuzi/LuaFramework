-- 家族成员单元
FamilyCell = BaseClass(LuaUI)
function FamilyCell:__init(root)
	self:LayoutUI(root)
	self.model = FamilyModel:GetInstance()
end

function FamilyCell:LayoutUI(root)
	self.ui = UIPackage.CreateObject("Family","FamilyCell");
	root:AddChild(self.ui)
	self.state = self.ui:GetChild("state") -- 是否在线
	self.name = self.ui:GetChild("name") -- 名字
	self.chenghao = self.ui:GetChild("chenghao") -- 称号
	self.lv = self.ui:GetChild("lv") -- 等级
	self.jiaHao = self.ui:GetChild("jiaHao") -- 添加按钮
	self.offTime = self.ui:GetChild("offTime") -- 离线时长
	self.modelConn = self.ui:GetChild("modelConn") -- 模型渲染容器
end

function FamilyCell:Update( data )
	self.data = data
	if self.data then
		self.jiaHao.visible = false
		self.name.text = self.data.playerName
		self.lv.text = StringFormat("等级{0}", self.data.level)
		local index = self.data.familySortId

		if index == 1 then
			self.chenghao.text = "族\n长"
		elseif index == 2 then
			self.chenghao.text = "长\n老"
		elseif index == 3 then
			self.chenghao.text = "掌\n事"
		else
			self.chenghao.text = "族\n人"
		end

		-- 是否在线
		if self.data.online == 1 then -- 在线
			self.state.text = "[COLOR=#5FFF53]在线[/COLOR]"
			self.offTime.visible = false
		else
			self.state.text = "[COLOR=#FFFFFF]离线[/COLOR]"
			-- 离线时长
			self.offTime.text = StringFormat("离线{0}", self:GetOfflineTime(data.exitTime))
			self.offTime.visible = true
		end
		self.modelConn.visible = true
		self.model:ClearFamilyModel()
		self:SetPlayerModel()
	else
		self:Clear()
	end
end

function FamilyCell:Clear()
	self.jiaHao.visible = self.model:IsFamilyLeader()
	self.state.text = ""
	self.name.text = ""
	self.chenghao.text = ""
	self.lv.text = ""
	self.offTime.visible = false
	self.modelConn.visible = false
	self.ui.onClick:Remove(self.SetCallback, self)
end

function FamilyCell:SetAddCallback( cb )
	self.jiaHao.onClick:Add(function ()
		if cb then cb() end
	end)
end

function FamilyCell:SetCallback( cb )
	self.ui.onClick:Add(function (  )
		if cb then cb() end
	end)
end

-- 显示模型
function FamilyCell:SetPlayerModel()
	if self.data then
		if self.gameObject then
			destroyImmediate(self.gameObject)
			self.gameObject = nil
		end
		local cfg = self:GetCfgData(self.data.weaponStyle)
		local playerId = self.data.playerId
		local weaponEftId =  0 
		local weaponStyle = 0
		local wingStyle = self.data.wingStyle or 0
		local dressStyle = self.data.dressStyle or 0

		if cfg then
			if cfg.rare == 4 or cfg.rare ==5 then --品阶为4或者5的武器才能加载武器光效
				weaponEftId = cfg.effect
			end

			weaponStyle = cfg.weaponStyle
			
			CreateModel(function(go)
				if not go then return end
				self.gameObject = go
				local tf = go.transform
				tf.localScale = Vector3.New(200, 200, 200)
				tf.localPosition = Vector3.New(15,-46,160)
				tf.localEulerAngles = Vector3.New(0, 180, 0)
				-- self.modelConn.visible = true
				local familyGo = {
					playerId = self.data.playerId,
					model = self.modelConn
				}
				self:SetFamilyModel(familyGo)
				self.modelConn:SetNativeObject(GoWrapper.New(go)) -- ui 3d对象加入
			end, dressStyle, weaponStyle, wingStyle, weaponEftId)
		end
	end
end

function FamilyCell:SetFamilyModel( go )
	if self.model and not self.model:IsHaveModel(go) then
		self.model:RemoveModel( go.playerId )
		self.model:SetFamilyModel(go)
	end
end

-- 读表
function FamilyCell:GetCfgData( id )
	return GetCfgData("equipment"):Get(tonumber(id))
end

-- 计算时间
function FamilyCell:GetOfflineTime(exitTime)
	local serverTime = TimeTool.GetCurTime()
	local offlineTime = (serverTime - exitTime)/1000
	if offlineTime <= 0 then offlineTime = 0 end
	local s = "";
	if offlineTime < 3600 then -- 小于1小时
		offlineTime = math.modf(offlineTime/60);
		s = StringFormat("{0}分钟", offlineTime)
	elseif offlineTime < 86400 then
		offlineTime = math.modf(offlineTime/3600);
		s = StringFormat("{0}小时", offlineTime)
	else
		offlineTime = math.modf(offlineTime/86400);
		s = StringFormat("{0}天", offlineTime)
	end
	return s
end

function FamilyCell:__delete()
	self.model = nil
end