SettingPanel = BaseClass(LuaUI)
function SettingPanel:__init( ... )

	self.ui = UIPackage.CreateObject("Setting","SettingPanel")
	
	self.hpCtrl = self.ui:GetController("hpCtrl")
	self.mpCtrl = self.ui:GetController("mpCtrl")
	self.sound = self.ui:GetChild("sound")
	self.line = self.ui:GetChild("line")
	self.chat = self.ui:GetChild("chat")
	self.line_2 = self.ui:GetChild("line")
	self.cb0 = self.ui:GetChild("cb0")
	self.cb1 = self.ui:GetChild("cb1")
	self.cb2 = self.ui:GetChild("cb2")
	self.cb3 = self.ui:GetChild("cb3")
	self.cb4 = self.ui:GetChild("cb4")
	self.cb5 = self.ui:GetChild("cb5")
	self.cb6 = self.ui:GetChild("cb6")
	self.show = self.ui:GetChild("show")
	self.line_3 = self.ui:GetChild("line")
	self.drinkDrug = self.ui:GetChild("drinkDrug")
	self.selectBox1 = self.ui:GetChild("selectBox1")
	self.blood30 = self.ui:GetChild("blood30")
	self.blood50 = self.ui:GetChild("blood50")
	self.blood80 = self.ui:GetChild("blood80")
	self.selectBox2 = self.ui:GetChild("selectBox2")
	self.mf30 = self.ui:GetChild("mf30")
	self.mf50 = self.ui:GetChild("mf50")
	self.mf80 = self.ui:GetChild("mf80")
	self.bandAccBtn = self.ui:GetChild("bandAccBtn")
	self.callGMBtn = self.ui:GetChild("callGMBtn")
	self.escGameBtn = self.ui:GetChild("escGameBtn")
	-- self.escGameBtn.visible = false
	self:SetXY(199, 126)

	self:Config()
	self:InitEvent()
end

function SettingPanel:Config()
	self.model = SettingModel:GetInstance()
	self.head = HeadUIMgr:GetInstance()

	self.components = {
		self.cb0:GetChild("checkBox"),
		self.cb1:GetChild("checkBox"),
		self.cb2:GetChild("checkBox"),
		self.cb3:GetChild("checkBox"),
		self.cb4:GetChild("checkBox"),
		self.cb5:GetChild("checkBox"),
		self.cb6:GetChild("checkBox")
	}	
end

function SettingPanel:InitEvent()
	SettingCtrl:GetInstance():C_GetPlayerOptional()
	-- self.model:SetCB(2, false)
	-- self.model:SetCB(3, false)
	self.selectBox1.visible = true
	self.selectBox2.visible = false
	self:AddEvent()
	self:SetCBOnClick()
	self:SetCtrlOnChanged()
	self:SetBtnClick()
end

function SettingPanel:AddEvent()
	self.handler = self.model:AddEventListener(StgConst.DATA_CHANGED, function ()
		self:Update()
	end)

	self.contactHandler = self.model:AddEventListener(StgConst.DATA_CONTACT, function ()
		self:SetComuCB()
	end)
end

-- 更新面板
function SettingPanel:Update()
	for i=0, #self.components - 1 do
		local state = self.model:GetCB( i )
		self:SetCBShow( i, state )
	end
	self.cb6:GetChild("checkBox").enabled = false
	self:SetCtrlShow()
end

function SettingPanel:SetComuCB()
	self.cb2:GetChild("checkBox").selected = self.model:GetComuState(1)
	self.cb3:GetChild("checkBox").selected = self.model:GetComuState(2)
end

-- 设置勾
function SettingPanel:SetCBShow( index, state )
	if state == 1 or index == 6 then
		self.components[index + 1].selected = false
	else
		self.components[index + 1].selected = true
	end
end

-- 设置单选
function SettingPanel:SetCtrlShow()
	self.mpCtrl.selectedIndex = self.model:GetCtrl(1)
	self.hpCtrl.selectedIndex = self.model:GetCtrl(0)
end

-- 增加CB监听
function SettingPanel:SetCBOnClick()
	local components = nil
	for i=1, #self.components do
		components = self.components[i]
		components.data = i - 1 
		components.onClick:Add(function ( eve )
			local sender = eve.sender
			local data = sender.data
			self.model:SetCB( data, sender.selected )
		end)
	end
end

-- 增加Ctrl监听
function SettingPanel:SetCtrlOnChanged()
	local index = 1

	self.hpCtrl.onChanged:Add(function ()
		index = self.hpCtrl.selectedIndex
		self.selectBox1.visible = true
		self.selectBox2.visible = false
		self.model:SetBarState(index, 0)
	end)

	self.mpCtrl.onChanged:Add(function ()
		index = self.mpCtrl.selectedIndex
		self.selectBox1.visible = false
		self.selectBox2.visible = true
		self.model:SetBarState(index, 1)
	end)
end

-- 增加Btn监听
function SettingPanel:SetBtnClick()
	self.bandAccBtn.onClick:Add(function ()
		self:OnBandAccountClick()
	end)

	self.callGMBtn.onClick:Add(function ()
		self:OnCallGMBtnClick()
	end)

	self.escGameBtn.onClick:Add(function ()
		self:OnEscBtnClick()
	end)
end

function SettingPanel:OnBandAccountClick()
	WelfareController:GetInstance():OpenWelfarePanel(WelfareConst.WelfareType.BindPhone)
end

-- 打开客服信息框
function SettingPanel:OnCallGMBtnClick()
	local gmiOS =  "0000000000" -- iOS群
	local gmAndroid = "0000000000" -- 安卓群
	UIMgr.Win_Alter("联系客服", StringFormat("官方群-iOS：{0}\n官方群-安卓：{1}", gmiOS, gmAndroid), "确定", nil)
end

-- 退出游戏
function SettingPanel:OnEscBtnClick()
	UIMgr.Win_Confirm("退出登录", "确定要退出登录吗？", "确定", "取消", 
		function ()
			self.model:EscCon()
			GlobalDispatcher:DispatchEvent(EventName.ExitGame)
			self:Destroy()
		end,
		nil)
end

function SettingPanel:__delete()
	if self.model then
		self.model:RemoveEventListener(self.handler)
		self.model:RemoveEventListener(self.contactHandler)
		self.model = nil
	end
	self.head = nil
end