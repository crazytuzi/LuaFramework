ChoudiPanel = BaseClass(LuaUI)
function ChoudiPanel:__init( ... )

	self.ui = UIPackage.CreateObject("ChouDi","ChoudiPanel");

	
	self.choudiList = self.ui:GetChild("choudiList")
	self.listNum = self.ui:GetChild("listNum")

	self.model = ChouDiModel:GetInstance()
	self:InitEvent()
	self:AddEvent()
	self.choudiItems = {}
	ChouDiController:GetInstance():C_GetEnemyList()
end
function ChoudiPanel:InitEvent()

end

function ChoudiPanel:AddEvent()
	self.handler0 = self.model:AddEventListener(ChouDiConst.CHOUDILIST_LOAD, function()
		for i,v in ipairs(self.choudiItems) do
			v:Destroy()
		end
		self.choudiItems = {}
		self:LoadChoudiList()
	end)

	self.handler1 = self.model:AddEventListener(ChouDiConst.DELETECHOUDI, function(enemyPlayerId)
		for i,v in ipairs(self.choudiItems) do
			v:Destroy()
		end
		self.choudiItems = {}
		self:LoadChoudiList()
	end)

	self.handler2 = self.model:AddEventListener(ChouDiConst.ZHUIZONG, function()
		local mapText = GetCfgData("mapManger"):Get(self.model.mapId).map_name
		local mapTab = string.split(mapText, "\n")
		local mapName = mapTab[1]
		local explain = StringFormat("仇敌[color=#ffa200]{0}[/color]正在[color=#31b569]{1}[/color]", self.model.playerName, mapText)
		ChatNewController:GetInstance():AddEnemyMsg(self.model.playerName, mapName) 
		UIMgr.Win_Alter("追踪", explain, "确定", function()  end)
	end)
end

function ChoudiPanel:LoadChoudiList()
	local choudiTab = self.model.choudiList
	self.listNum.text = StringFormat("{0}/50", #choudiTab)
	for i, v in ipairs(choudiTab) do
		local itemObj = ChoudiItem.New()
		table.insert(self.choudiItems, itemObj)
		self.choudiList:AddChild(itemObj.ui)
		itemObj.headIcon.icon = "Icon/Head/r1"..v.career 
		itemObj.headIcon.title = v.level
		itemObj.playerName.text = v.enemyPlayerName
		itemObj.iconZhiye.url = "Icon/Head/career_0"..v.career
		itemObj.textZhiye.text = GetCfgData("newroleDefaultvalue"):Get(v.career).careerName
		if string.len(v.familyName) > 0 then
			itemObj.familyName.text = v.familyName
		else
			itemObj.familyName.text = "暂无"       
		end
		if v.isOnline == 0 then
			itemObj.isOnlineTxt.text = "离线"
			itemObj.isOnlineTxt.color = newColorByString("54595e")  
			itemObj.btnZhuizong:GetChild("icon").grayed = true
			itemObj.btnZhuizong.touchable = false
		else
			itemObj.isOnlineTxt.text = "在线"
			itemObj.isOnlineTxt.color = newColorByString("00620e") 
			itemObj.btnZhuizong:GetChild("icon").grayed = false
			itemObj.btnZhuizong.touchable = true
		end         
		itemObj.btnZhuizong.onClick:Add(function ()
			local zhuizongPanel = ZhuizongPanel.New(34001)
			UIMgr.ShowCenterPopup(zhuizongPanel, function()  end)     --UIMGR弹窗方法
			zhuizongPanel.zhuzongText.text = StringFormat("使用追踪功能可以得知仇敌[color=#ffa200]{0}[/color]当前所在地图", v.enemyPlayerName)
			local num = 0
			local icon = PkgCell.New(zhuizongPanel.resGezi)       --设置消耗物品
			if PkgModel:GetInstance():GetGoodsVoByBid(34001) then
				local info = PkgModel:GetInstance():GetGoodsVoByBid(34001)
				zhuizongPanel.btnAddRes.enabled = false
				zhuizongPanel.btnAddRes.alpha = 0
				icon:SetData(info)
				num = info.num
			else
				zhuizongPanel.btnAddRes.enabled = true
				zhuizongPanel.btnAddRes.alpha = 100
			end
			icon:SetNum(0)
			zhuizongPanel.txtResNum.text = StringFormat("([color=#bc1515]{0}/{1}[/color])", 1, num)
			zhuizongPanel.btnQX.onClick:Add(function()
				UIMgr.HidePopup(zhuizongPanel.ui)
			end)
			zhuizongPanel.btnQD.onClick:Add(function() 
				ChouDiController:GetInstance():C_TrackEnemy(v.enemyPlayerId)     --发送追踪请求
				UIMgr.HidePopup(zhuizongPanel.ui)
			end)
		end)
		itemObj.btnDelete.onClick:Add(function ()
			UIMgr.Win_Confirm("温馨提示", "确定要删除仇敌？", "确认", "取消", function()
				ChouDiController:GetInstance():C_DeleteEnemy(v.enemyPlayerId)     --发送删除请求
			end, nil)
		end)
	end
end

-- Dispose use ChoudiPanel obj:Destroy()
function ChoudiPanel:__delete()
	if self.model then
		self.model:RemoveEventListener(self.handler0)
		self.model:RemoveEventListener(self.handler1)
		self.model:RemoveEventListener(self.handler2)
		--GlobalDispatcher:RemoveEventListener()
	end
	if self.choudiItems then
		for i,v in ipairs(self.choudiItems) do
			v:Destroy()
		end
		self.choudiItems = nil
	end
end