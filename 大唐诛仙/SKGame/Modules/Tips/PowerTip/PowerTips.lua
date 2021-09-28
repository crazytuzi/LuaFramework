PowerTips =BaseClass(LuaUI)
-- Automatic code generation, don't change this function (Constructor) use .New(...)
PowerTips.IconType = {
	[1] = "ui://ixdopynlerysn",  --减战斗力
	[2] = "ui://ixdopynlerysm",   --增加战斗力
}
PowerTips.PowerFont = {
	[1] = "ui://0tyncec1eryse9",
	[2] = "ui://0tyncec1eryse8",
}
function PowerTips:__init(parent)
	self.ui = ui or self.ui or UIPackage.CreateObject("Tips","PowerTips");
	parent:AddChild(self.ui)
	self.isDisable = false
	self.title = self.ui:GetChild("title")
	self.bg = self.ui:GetChild("bg")

	self:Config()
	self.targetPos = Vector3.New(500,-300,0)
	self.startPosAdd = Vector3.New(500,-350,0)
	self.startPosSub = Vector3.New(500,-250,0)
	self.currentTime = 0
	self.tipType = 0
	self.go = self.ui.displayObject.gameObject
end
-- Logic Starting
function PowerTips:Config()

end

function PowerTips:AddPower(num)
	--设置字体
	local tf = self.title.textFormat
	tf.font = UIPackage.GetItemURL("Common" , "num_5")
	self.title.textFormat = tf
	local start1 = 0
	local v = math.abs(num)
	TweenUtils.TweenFloat(start1, v, 0.7, function (value)
		if self.title then
			self.title.text = StringFormat("i+{0}",math.ceil(value))
		end
	end)
end

function PowerTips:SubPower(num)
	local tf = self.title.textFormat
  tf.font = UIPackage.GetItemURL("Common" , "num_4")
  self.title.textFormat = tf
	local start1 = 0
	local v = math.abs(num)
	TweenUtils.TweenFloat(start1, v, 0.7, function (value)
		if self.title then
			self.title.text = StringFormat("i-{0}",math.ceil(value))
		end
	end)
end

function PowerTips:ShowPowerTip(newValue,oldValue)
	local num = newValue - oldValue
	if num > 0 then 
		self:AddPower(num)
		self.tipType = 1 --从下往上飘
		self.go.transform.localPosition = self.startPosAdd
		self.bg.url = PowerTips.IconType[2]
	else
		self:SubPower(num)
		self.tipType = 2 --从上往下飘
		self.go.transform.localPosition = self.startPosSub
		self.bg.url = PowerTips.IconType[1]
	end
	self:OnEnable()
	self:StartEffect()
end

function PowerTips:StartEffect()
	self.isStart = true
	self.deltaTime = 0
	RenderMgr.Add(function() self:Update() end, self)
end

function PowerTips:Update()
	if self.isStart == false then return end
	self.currentTime = self.currentTime + Time.deltaTime
	if self.currentTime >= 1 then
		self.currentTime = 0
		self.go.transform.localPosition = self.targetPos
		self:Release()
	end
	self.go.transform.localPosition = Vector3.Lerp(self.go.transform.localPosition, self.targetPos, 0.1)
end

function PowerTips:OnEnable()
	if self.isDisable then
		self.isDisable = false
		self.ui.visible = true
	end
end

function PowerTips:OnDisable()
	if not self.isDisable then
		self.isDisable = true
		self.ui.position = Vector3.zero
		self.ui.visible = false
	end
end

function PowerTips:Release()
	RenderMgr.Remove(self)
	self:OnDisable()
	CommonModel:GetInstance():DispatchEvent(CommonConst.EventName_PowerTipEnqueue,self)
end

-- Dispose use PowerTips obj:Destroy()
function PowerTips:__delete()
	self.title = nil
	self.bg = nil
end