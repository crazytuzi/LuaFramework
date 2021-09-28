-- 队伍目标设置
ZDJoinTarget = BaseClass(LuaUI)
function ZDJoinTarget:__init(...)
	self.ui = UIPackage.CreateObject("Team","ZDJoinTarget")
	self.typeConn = self.ui:GetChild("typeConn")
	self.btnClose = self.ui:GetChild("btnClose")
	self.btnCloseNew = self.ui:GetChild("btnCloseNew")
	self.btnApply = self.ui:GetChild("btnApply")
	self.comboxBtn = self.ui:GetChild("comboxBtn")

	self.activityId = 0
	self.selectedIdx = 0
	self.minLevel = ZDModel:GetInstance().minLevel 
	self.items = {}
	self.isFirst = true
	self:Layout()
	self:InitEvent()
end
function ZDJoinTarget:InitEvent(  )
	self.btnClose.onClick:Add(function (  )
		UIMgr.HidePopup()
	end)
	self.btnCloseNew.onClick:Add(function (  )
		UIMgr.HidePopup()
	end)
	self.btnApply.onClick:Add(function (  )
		ZDModel:GetInstance().minLevel = self.comboxBtn.value
		ZDCtrl:GetInstance():C_ChangeTarget(self.activityId, tonumber(self.comboxBtn.value)	)
		UIMgr.HidePopup()
	end)
	
	-- self.comboxBtn.onChanged:Add(function ()
	-- 	-- print(self.comboxBtn.value, self.comboxBtn.text, self.comboxBtn.selectedIndex)
	-- end)
end
-- 布局UI
function ZDJoinTarget:Layout()
	local res0 = "ui://0tnseunopo2c70"
	local res1 = "ui://0tyncec1ovhpnlp"
	local tabDatas = {}
		
	for i=1,#ZDConst.teamTargets do
		local v = {}
		v.label = ZDConst.bigTypeStr[i]
		v.res0 = res0
		v.res1 = res1
		v.id = ZDConst.teamTargets[i][1]..""
		table.insert(tabDatas, v)
	end

	local defaultIdx = 0
	if self.isFirst then
		self.selectData = self:GetSelectData()
		if self.selectData.bigType then
			defaultIdx = self.selectData.bigType - 1
		end
	end
	self.ctrl, self.tabs = CreateTabbar( self.ui, 0, function ( idx, id )
		self.selectedIdx = idx
		self:Update()
	end, tabDatas, -17, 68, defaultIdx, 80, 40, 80)
	local minLevel = ZDModel:GetInstance().minLevel
	self.comboxBtn.value = minLevel
	if self.comboxBtn.dropdown then
		self.comboxBtn.dropdown.scaleX = GameConst.scaleX
		self.comboxBtn.dropdown.scaleY = GameConst.scaleY
	end
end

function ZDJoinTarget:GetSelectData()
	local ret = {bigType = 1}
	self.model = self.model or ZDModel:GetInstance()
	local curId = self.model:GetActivityId()
	for i = 1, #ZDConst.teamTargets do
		local subType = ZDConst.teamTargets[i][3] or {}
		for j = 1, #subType do
			if subType[j][1] == curId then
				ret.bigType = i
				ret.subType = j
			end
		end
	end
	return ret
end

function ZDJoinTarget:Update()
	local t = self.selectedIdx
	for i,v in ipairs(self.items) do
		v.selected = false
		v:RemoveFromParent()
	end
	self.curItem = nil
	local list = ZDConst.teamTargets[t+1]
	local bigT = list[1]
	local typeList = list[3] or {}

	if self.isFirst then
		local minLevel = ZDModel:GetInstance().minLevel
		self.comboxBtn.value = minLevel
		self.comboxBtn.selectedIndex = minLevel % 10
	end

	local defaultIdx = 1
	for i,v in pairs(typeList) do
		local item = self.items[i]
		if item then
			item.data = v[1]
			item.title = v[2]
		else
			item = UIPackage.CreateObject("Team","ZDTargetItem")
			item.onClick:Add(function ()
				if self.curItem ~= item then
					if self.curItem then
						self.curItem.selected = false
					end
					self.curItem = item
					self:SelectedHandle(item.data)
				end
			end)
			item.data = v[1]
			item.title = v[2]
		end
		if self.isFirst and v[1] and self.selectData and self.selectData.bigType == t + 1 and self.model:GetActivityId() == v[1] then
			self.isFirst = false
			defaultIdx = i
		end
		item:SetXY(0, (i-1)*50)
		self.typeConn:AddChild(item)
		self.items[i] = item
	end
	if self.curItem == nil then
		if #typeList~=0 then
			self.items[defaultIdx].selected = true
			self.curItem = self.items[defaultIdx]
			self:SelectedHandle( self.items[defaultIdx].data )
		else
			self:SelectedHandle( bigT )
		end
	end
end
function ZDJoinTarget:SelectedHandle( id )
	self.activityId = id
end
function ZDJoinTarget:__delete()
	if self.items then
		for i,v in ipairs(self.items) do
			destroyUI(v)
		end
	end
	self.items = nil
end