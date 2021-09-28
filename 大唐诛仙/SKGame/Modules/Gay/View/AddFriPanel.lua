AddFriPanel = BaseClass(BaseView)           --CommonBackGround
function AddFriPanel:__init( ... )

	self.ui = UIPackage.CreateObject("Gay","AddFriPanel");

	
	self.tabCtrl = self.ui:GetController("tabCtrl")
	self.btn_close = self.ui:GetChild("btn_close")
	self.addfriendList = self.ui:GetChild("addfriendList")
	self.tab1btn_addFri = self.ui:GetChild("tab1btn_addFri")
	self.tab2btn_apply = self.ui:GetChild("tab2btn_apply")
	self.btn_recom = self.ui:GetChild("btn_recom")
	self.btn_search = self.ui:GetChild("btn_search")
	self.bg_shuruTxt = self.ui:GetChild("bg_shuruTxt")
	self.txt_input = self.ui:GetChild("txt_input")
	self.btn_clearList = self.ui:GetChild("btn_clearList")
	self.btn_agreeAll = self.ui:GetChild("btn_agreeAll")
	self.redIcon = self.ui:GetChild("redIcon")

	self.tab1btn_addFri.title = "[color=#ffffff]好友添加[/color]"
	self.tab2btn_apply.title = "[color=#2e3341]申请列表[/color]"
	
	self.model = FriendModel:GetInstance()
	self.recItems = {}      --推荐列表内容
	self.applyItems = {}     --申请列表
	self.guideItems = {}	--好友添加引导列表（当玩家接受到好友添加引导任务时，并且此时全服只有玩家一人，即好友推荐列表为空时，手动生成一个好友推荐Item）
	self:InitEvent()
	self:AddEvent()
	FriendController:GetInstance():C_FriendList(3)
	FriendController:GetInstance():C_ApplyMsgList()


end
function AddFriPanel:InitEvent()
	self.btn_close.onClick:Add(function ()
		self:ClosePanel()
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end) 

	self.tabCtrl.onChanged:Add(function ()         --切换好友推荐列表、申请列表
		for i,v in ipairs(self.recItems) do
			v:Destroy()
		end
		for i,v in ipairs(self.applyItems) do
			v:Destroy()
		end
		self.recItems = {}
		self.applyItems = {}
		
	end)

	self.btn_recom.onClick:Add(function ()             --推荐按钮
		for i,v in ipairs(self.recItems) do
			v:Destroy()
		end
		self.recItems = {}
		FriendController:GetInstance():C_FriendList(3)
		self:LoadRecommendList()
	end)

	self.tab1btn_addFri.onClick:Add(function ()        --推荐分页按钮
		self:UpdateList()
		for i,v in ipairs(self.recItems) do
			v:Destroy()
		end
		self.recItems = {}
		FriendController:GetInstance():C_FriendList(3)
		self:LoadRecommendList()
	end)
	self.tab2btn_apply.onClick:Add(function ()        --申请列表分页按钮
		self:UpdateList()
		for i,v in ipairs(self.applyItems) do
			v:Destroy()
		end
		self.applyItems = {}
		FriendController:GetInstance():C_ApplyMsgList()
	end)

	self.btn_search.onClick:Add(function ()        --搜索按钮
		local playerName = self.txt_input.text
		FriendController:GetInstance():C_SerachFriend(playerName)
	end)

	self.btn_clearList.onClick:Add(function ()     --清除列表按钮
		FriendController:GetInstance():C_DeleteAllApply()
		FriendController:GetInstance():C_ApplyMsgList()
		self.model:DispatchEvent(FriendConst.CloseApplyRed)                       --apply关闭红点
	end)

	self.btn_agreeAll.onClick:Add(function ()      --同意全部按钮
		FriendController:GetInstance():C_AgreeAllApply()
		FriendController:GetInstance():C_FriendList(1)
		self.model:DispatchEvent(FriendConst.CloseApplyRed)                       --apply关闭红点
	end)

end

function AddFriPanel:AddEvent()
	self.handler0 = self.model:AddEventListener(FriendConst.RECOMMENDLIST_LOAD, function()  --监听推荐列表消息
		for i,v in ipairs(self.recItems) do
			v:Destroy()
		end
		self.recItems = {}
		self:LoadRecommendList()
	end)
	self.handler1 = self.model:AddEventListener(FriendConst.APPLYLIST_LOAD, function()      --监听申请列表消息
		for i,v in ipairs(self.applyItems) do
			v:Destroy()
		end
		self.applyItems = {}
		if self.tabCtrl.selectedIndex == 1 then
			self:LoadApplyList()
		end
	end)
	self.showRedHandler = self.model:AddEventListener(FriendConst.ApplyRed, function()       --申请列表不为空 显示红点
		self.redIcon.visible = true
	end)
	self.closeRedHandler = self.model:AddEventListener(FriendConst.CloseApplyRed, function() --关闭红点
		self.redIcon.visible = false
	end)
	self.closeRedHandler1 = self.model:AddEventListener(FriendConst.IsNullApplyList, function()
		FriendController:GetInstance():C_ApplyMsgList()
	end)
end

function AddFriPanel:UpdateList()                  --切换列表按钮刷新列表内容 
	local idx = self.tabCtrl.selectedIndex         --0 推荐列表  1 申请列表
	if idx == 0 then
		self.tab1btn_addFri.title = "[color=#ffffff]好友添加[/color]"
		self.tab2btn_apply.title = "[color=#2e3341]申请列表[/color]"
	else
		self.tab1btn_addFri.title = "[color=#2e3341]好友添加[/color]"
		self.tab2btn_apply.title = "[color=#ffffff]申请列表[/color]"		
	end
end

function AddFriPanel:LoadRecommendList()                     --加载推荐列表
	local recommendTab = self.model.recommendList
	if #recommendTab > 0 then
		for i,v in ipairs(recommendTab) do
			local itemObj = AddFriItem.New()
			self.addfriendList:AddChild(itemObj.ui)
			itemObj.headIcon.icon = "Icon/Head/r1"..v.career            --玩家头像
			itemObj.headIcon.title = v.level
			itemObj.txt_playerName.text = v.playerName
			itemObj.icon_zhiye.url = "Icon/Head/career_0"..v.career           --职业图标
			itemObj.txt_zhiye.text = GetCfgData("newroleDefaultvalue"):Get(v.career).careerName
			itemObj.tabCtrlbtn.selectedIndex = 0
			itemObj.btn_addFriend.onClick:Add(function ()        --添加按钮
				FriendController:GetInstance():C_ApplyAddFriend(v.playerId)               
				self.addfriendList:RemoveChild(itemObj.ui)
				local taskId = TaskModel:GetInstance():GetFriendTypeTaskId()
				if taskId ~= 0 then
					TaskController:GetInstance():CompleteTask(taskId)
					GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
				end
				
			end)
			table.insert(self.recItems, itemObj)
		end
	else
		if NewbieGuideModel:GetInstance():IsHasFriendAddGuide() then
			local guideItem = AddFriItem.New()
			self.addfriendList:AddChild(guideItem.ui)
			guideItem.headIcon.icon = "Icon/Head/r11"
			guideItem.headIcon.title = 1
			guideItem.txt_playerName.text = "引导君"
			guideItem.icon_zhiye.url = "Icon/Head/career_01"
			guideItem.txt_zhiye.text = "战士"
			guideItem.tabCtrlbtn.selectedIndex = 0
			guideItem.btn_addFriend.onClick:Add(function()
				self.addfriendList:RemoveChild(guideItem.ui)
				local taskId = TaskModel:GetInstance():GetFriendTypeTaskId()
				if taskId ~= 0 then
					TaskController:GetInstance():CompleteTask(taskId)
					GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
				end
			end)
		end
		table.insert(self.guideItems , guideItem)
	end
end

function AddFriPanel:LoadApplyList()                     --加载申请列表
	local ApplyTab = self.model.applyList
	for i,v in ipairs(ApplyTab) do
		local itemObj = AddFriItem.New()
		self.addfriendList:AddChild(itemObj.ui)
		itemObj.headIcon.icon = "Icon/Head/r1"..v.career            --玩家头像
		itemObj.headIcon.title = v.level
		itemObj.txt_playerName.text = v.playerName
		itemObj.icon_zhiye.url = "Icon/Head/career_0"..v.career           --职业图标
		itemObj.txt_zhiye.text = GetCfgData("newroleDefaultvalue"):Get(v.career).careerName
		itemObj.tabCtrlbtn.selectedIndex = 1
		itemObj.btn_agree.onClick:Add(function ()        --同意按钮
			FriendController:GetInstance():C_ApplyDeal(v.playerId, 1)
			self.addfriendList:RemoveChild(itemObj.ui)
		end)
		itemObj.btn_refuse.onClick:Add(function ()        --拒绝按钮
			FriendController:GetInstance():C_ApplyDeal(v.playerId, 0)
			self.addfriendList:RemoveChild(itemObj.ui)
			FriendController:GetInstance():C_ApplyMsgList()
		end)
		table.insert(self.applyItems, itemObj)
	end

end

function AddFriPanel:ClosePanel()     --关闭panel
	--UIMgr.HidePopup()
	self.ui.visible = false
end

-- 布局UI
function AddFriPanel:Layout()
	self.container:AddChild(self.ui) -- 不改动，注意自行设置self.ui位置
	-- 以下开始UI布局

end

-- Dispose use AddFriPanel obj:Destroy()
function AddFriPanel:__delete()
	if self.model then
		self.model:RemoveEventListener(self.handler0)
		self.model:RemoveEventListener(self.handler1)
		self.model:RemoveEventListener(self.showRedHandler)
		self.model:RemoveEventListener(self.closeRedHandler)
		self.model:RemoveEventListener(self.closeRedHandler1)
		--GlobalDispatcher:RemoveEventListener()
	end
	if self.recItems then
		for i,v in ipairs(self.recItems) do
			v:Destroy()
		end
		self.recItems = nil
	end
	if self.applyItems then
		for i,v in ipairs(self.applyItems) do
			v:Destroy()
		end
		self.applyItems = nil
	end

	if self.guideItems then
		for i , v in pairs(self.guideItems) do
			v:Destroy()
		end
		self.guideItems = nil
	end
end