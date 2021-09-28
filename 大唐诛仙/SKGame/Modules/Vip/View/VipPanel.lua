VipPanel = BaseClass(LuaUI)
function VipPanel:__init( ... )

	self.ui = UIPackage.CreateObject("Vip","VipPanel");

	self.tabCtrl = self.ui:GetController("tabCtrl")
	self.vipPanel = self.ui:GetChild("vipPanel")
	self.btnvip_LQ = self.ui:GetChild("btnvip_LQ")
	self.btnvip_jihuo = self.ui:GetChild("btnvip_jihuo")
	self.vipLvchoudai = self.ui:GetChild("vipLvchoudai")
	self.vipTqIcon = self.ui:GetChild("vipTqIcon")
	self.vipLvHead = self.ui:GetChild("vipLvHead")
	self.viptequanDes = self.ui:GetChild("viptequanDes")
	self.bgtitle = self.ui:GetChild("bgtitle")
	self.vipTime = self.ui:GetChild("vipTime")
	self.vipLvIcon = self.ui:GetChild("vipLvIcon")
	self.btnvip_dailyLq = self.ui:GetChild("btnvip_dailyLq")
	self.RedIcon = self.ui:GetChild("RedIcon")  --每日奖励红点
	self.dailyList = self.ui:GetChild("dailyList")
	self.giftConn = self.ui:GetChild("giftConn")
	self.btnvip_firstLQ = self.ui:GetChild("btnvip_firstLQ")
	self.redfirst = self.ui:GetChild("redfirst")
	self.tab0 = self.ui:GetChild("tab0")
	self.tab1 = self.ui:GetChild("tab1")
	self.tab2 = self.ui:GetChild("tab2")
	self.isJhHJ = self.ui:GetChild("isJhHJ")
	self.isJhBY = self.ui:GetChild("isJhBY")
	self.isJhQT = self.ui:GetChild("isJhQT")
	self.redLqYB = self.ui:GetChild("redLqYB")

	self.grayedURL = "ui://zhwzke4oa7c1q"
	self.nograyedFirURL = "ui://0tyncec1gk0nnif"
	self.nograyeddailyURL = "ui://0tyncec1gk0nnie"

	self:InitEvent()
	self.model = VipModel:GetInstance()
	self:AddEvents()
	VipController:GetInstance():C_GetDailyRewardState()       --发送获取每日奖励状态请求
	VipController:GetInstance():C_GetPlayerVip()       		  --发送获取玩家vip信息请求
	VipController:GetInstance():C_GetVipWelfareState()        --发送获取vip每日福利状态
	
	self.vipLv = 3                      --定义变量vip等级
	self.vipId = 303

	self.items = {} 					--权限条目(描述内容)
	self.items2 = {} 			        --权限内容(首次奖励)
	self.rewList = {}					--权限内容(每日奖励)

	self:LoadDailyRewList()
	self:RefreshButton()
	self:RefreshWelfareBtn()
	self:RefreshFirstButton()
	self:Update()
	
	
	self.tab0 = VipLvItem.Create(self.tab0)
	local num = self.model:GetPayNumListData(3)
	self.tab0.resNum.text = num.."元"
	          
	self.tab1 = VipLvItem.Create(self.tab1)
	local num = self.model:GetPayNumListData(2)
	self.tab1.resNum.text = num.."元"

	self.tab2 = VipLvItem.Create(self.tab2)
	local num = self.model:GetPayNumListData(1)
	self.tab2.resNum.text = num.."元"
	
end


function VipPanel:InitEvent()                      --事件
	self.tabCtrl.onChanged:Add(function ()
		-- print(self.tabCtrl.selectedIndex)          --切换三种vip等级的索引
		for i,v in ipairs(self.items) do
			v:Destroy()
		end
		for i,v in ipairs(self.items2) do
			v:Destroy()
		end
		self.items = {}
		self.items2 = {}
		self:Update(self.model.vipId)
	end)
	self.btnvip_firstLQ.onClick:Add(function ()  
		-- print("领取首次激活奖励")
		if self.btnvip_firstLQ.grayed == false then
			VipController:GetInstance():C_GetVipActReward(self.vipId)
		end
	end)
	self.btnvip_dailyLq.onClick:Add(function ()
		if self.model.vipId == 0 then
			if self.btnvip_dailyLq.grayed == false then
				UIMgr.Win_Confirm("每日福利","VIP奖励双倍","激活VIP","单倍领取", function()  end,function() 
					VipController:GetInstance():C_GetDailyReward()  
					self.RedIcon.visible = false --========================
				end )    --弹出2次确认弹窗
			end
		else
			if self.btnvip_dailyLq.grayed == false then
				VipController:GetInstance():C_GetDailyReward()
				self.RedIcon.visible = false --============================
			end
		end
	end)
	self.btnvip_LQ.onClick:Add(function ()
		VipController:GetInstance():C_GetVipWelfare()
	end)
	
	self.btnvip_jihuo.onClick:Add(function (eve)
		PayModel:GetInstance():OnCellClick(eve)
	end)

end

function VipPanel:AddEvents()
	self.dailystateHandle = self.model:AddEventListener(VipConst.DAILYSTATE_CHANGE, function()
		self:RefreshButton()
	end)
	--监听激活vip等级全局事件
	self.jhChangeVipLvHandle = GlobalDispatcher:AddEventListener(EventName.VIPLV_CHANGE, function(lv,time,jhState,playerVipId)  --全局事件
		self:RefreshUI(playerVipId)
		self:RefreshFirstButton()
		self:RefreshWelfareBtn()
	end)
	self.firstStateHandle = self.model:AddEventListener(VipConst.FIRSTLQ_CHANGE, function (vipId)
		self:RefreshFirstButton()
	end)
	self.getDailyStateHandle = self.model:AddEventListener(VipConst.GETFIRLQSTATE_CHANGE, function ()
		self:RefreshButton()
	end) 
	--监听获取vip信息全局事件
	self.getVipInfoHandle = GlobalDispatcher:AddEventListener(EventName.GETVIPINFO_CHANGE, function(lv)  --全局事件
		self:RefreshUI(lv)
		self:RefreshButton()
		self:RefreshFirstButton()
	end)
	self.getVipWelfareDailyHandler = self.model:AddEventListener(VipConst.GetWelfareDailyChange, function()
		self:RefreshWelfareBtn()
	end)
end

function VipPanel:Update()                  --切换vip等级刷新右边内容
	local idx = self.tabCtrl.selectedIndex
	self.vipTqIcon.url = "Icon/Vip/tequan"..(idx+1)
	self.vipLv = 3-idx
	self.vipId = tonumber("30"..self.vipLv)
	self.btnvip_jihuo.data = self.vipId
	self.vipLvHead.url = "Icon/Vip/vip"..self.vipLv
	self:LoadDesList(self.vipId)
	self:LoadFirstRewList(self.vipId)
	self:RefreshFirstButton()
end

function VipPanel:RefreshFirstButton()            --刷新首次激活奖励领取状态
	local tab = self.model.lqStateTab[self.vipLv]
	if tab == 0 then
		self.btnvip_firstLQ.icon = self.grayedURL
		self.btnvip_firstLQ.touchable = false
		self.btnvip_firstLQ.title = "[color=#2e3341]激活可领取[/color]"
		self.redfirst.visible = false
		self.model.isFirstLq = 0
	elseif tab == 1 then
		self.btnvip_firstLQ.icon = self.nograyedFirURL
		self.btnvip_firstLQ.touchable = true
		self.btnvip_firstLQ.title = "[color=#2e3341]领取[/color]"
		self.redfirst.visible = true
		self.model.isFirstLq = 1
	elseif tab == 2 then
		self.btnvip_firstLQ.icon = self.grayedURL
		self.btnvip_firstLQ.touchable = false
		self.btnvip_firstLQ.title = "[color=#2e3341]已领取[/color]"
		self.redfirst.visible = false
		self.model.isFirstLq = 0
	end
	--self.btnvip_firstLQ.title = tab==2 and "已领取" or "领取"     --***************************
end

function VipPanel:RefreshUI(lv)             --刷新vip图标
	local iconStr = "Icon/Vip/jihuo"
	if lv == 1 then
		self.isJhQT.url = iconStr
		self.isJhBY.url = nil
		self.isJhHJ.url = nil
	elseif lv == 2 then
		self.isJhQT.url = nil
		self.isJhBY.url = iconStr
		self.isJhHJ.url = nil
	elseif lv == 3 then
		self.isJhQT.url = nil
		self.isJhBY.url = nil
		self.isJhHJ.url = iconStr
	else
		self.isJhQT.url = nil
		self.isJhBY.url = nil
		self.isJhHJ.url = nil
	end
	if lv > 0 then
		self.vipLvIcon.url = "Icon/Vip/vip0"..lv
	end
	self.vipTime.text = self.model.timeStr
end

function VipPanel:RefreshButton()                --刷新每日领取按钮状态
	--每日奖励是否领取
	if self.model.isDailyLQ == 1 then
		self.btnvip_dailyLq.icon = self.grayedURL
		self.btnvip_dailyLq.touchable = false
		self.btnvip_dailyLq.title = "已领取"
		self.RedIcon.visible = false
	else
		self.btnvip_dailyLq.icon = self.nograyeddailyURL
		self.btnvip_dailyLq.touchable = true
		self.btnvip_dailyLq.title = "领取每日福利"
		self.RedIcon.visible = true
	end
end

function VipPanel:RefreshWelfareBtn()
	if self.model.vipId == 0 then
		self.btnvip_LQ.title = "激活领元宝"
		self.btnvip_LQ.enabled = false
		self.redLqYB.visible = false
	else
		if self.model.isWelfareDaily == 0 then
			self.btnvip_LQ.title = "领取元宝"
			self.btnvip_LQ.enabled = true
			self.redLqYB.visible = true
		else
			self.btnvip_LQ.title = "已领取"
			self.btnvip_LQ.enabled = false
			self.redLqYB.visible = false
		end
	end
end

function VipPanel:LoadDesList(lv)                       --加载特权描述列表
	local tab = self.model:GetTequanDesListCfgData(lv)
	for i, v in ipairs(tab) do
		local itemObj = ViptequanDesItem.New()
		table.insert(self.items, itemObj)
		self.viptequanDes:AddChild(itemObj.ui)
		itemObj.tequanDes.text = v
	end
end


function VipPanel:LoadFirstRewList(lv)                  --加载首次激活奖励列表
	local goodsList = self.model:GetFirstRewardCfgData(lv) or {}
	for i, v in ipairs(goodsList) do
		local icon = PkgCell.New(self.giftConn)
		table.insert(self.items2,icon)
		local w, h =89,89
		icon:SetSize(w, h)
		icon:SetXY(w*((i-1)%2),math.floor((i-1)/2)*h)    --**设置位置**
		icon:OpenTips(true,true)
		icon:SetDataByCfg(v[1],v[2],v[3],v[4])
	end

end

function VipPanel:LoadDailyRewList()                           --加载每日奖励列表
	local rewardList = self.model:GetDailyRewardCfgData()
	for i,v in ipairs(self.rewList) do
		v:Destroy()
	end
	self.rewList = {}
	for i = #rewardList , 1, -1  do
		local ico = PkgCell.New(self.dailyList)
		local w, h =89,89
		ico:SetSize(w, h)
		ico:SetXY(i*(-w),0)                          --**设置位置**
		ico:OpenTips(true,true)
		ico:SetDataByCfg(rewardList[i][1],rewardList[i][2],rewardList[i][3],rewardList[i][4])
		self.dailyList:AddChild(ico.ui)
		table.insert(self.rewList,ico)
	end
end

-- Dispose use VipPanel obj:Destroy()
function VipPanel:__delete()
	if self.model then
		self.model:RemoveEventListener(self.dailystateHandle)
		GlobalDispatcher:RemoveEventListener(self.jhChangeVipLvHandle)
		self.model:RemoveEventListener(self.firstStateHandle)
		self.model:RemoveEventListener(self.getDailyStateHandle)
		GlobalDispatcher:RemoveEventListener(self.getVipInfoHandle)
		self.model:RemoveEventListener(self.getVipWelfareDailyHandler)
	end
	if self.items then
		for i,v in ipairs(self.items) do
			v:Destroy()
		end
		self.items = nil
	end
	if self.items2 then
		for i,v in ipairs(self.items2) do
			v:Destroy()
		end
		self.items2 = nil
	end
	if self.rewList then
		for i,v in ipairs(self.rewList) do
			v:Destroy()
		end
		self.rewList = nil
	end
end