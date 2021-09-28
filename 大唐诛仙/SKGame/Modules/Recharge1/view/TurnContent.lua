TurnContent = BaseClass(LuaUI)
function TurnContent:__init(...)
	self.URL = "ui://g35bobp2jui0x";
	self:__property(...)
	self:Config()
	self:InitEvent()
end
function TurnContent:SetProperty(...)
	
end
function TurnContent:Config()
	self.model = RechargeModel:GetInstance()
	self.reqLocking = false
end
function TurnContent:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Welfare","TurnContent");

	self.comTurnBg = self.ui:GetChild("comTurnBg")
	self.items = {}
	for i = 1, RechargeConst.TURN_GOODS_NUM do
		self.items[i] = self.comTurnBg:GetChild("item" .. i)
	end
	self.btnChoujiang = self.ui:GetChild("btnChoujiang")
	self.iconCost = self.ui:GetChild("iconCost")
	self.txtFree = self.ui:GetChild("txtFree")
	self.txtCostNum = self.ui:GetChild("txtCostNum")
	self.listHistory = self.ui:GetChild("listHistory")
	self.contentItemList = {}
end
function TurnContent.Create(ui, ...)
	return TurnContent.New(ui, "#", {...})
end
function TurnContent:__delete()
	if self.bTurning then
		self:StopAc()
	end
	self:Reset()
	self.listHistory.scrollPane.onScrollEnd:Remove(self.OnScrollEndHandler, self)
	if self.model then
		self.model:RemoveEventListener(self._handle1)
		self.model:RemoveEventListener(self._handle2)
		self.model:RemoveEventListener(self._handle3)
		self.model:RemoveEventListener(self._handle4)
	end
end

function TurnContent:InitEvent()
	self.btnChoujiang.onClick:Add(self.OnChoujiangClick, self)
	self.listHistory.scrollPane.onScrollEnd:Add(self.OnScrollEndHandler, self)
	local function OnGetTurntableData()
		self:RefreshUI()
	end
	self._handle1 = self.model:AddEventListener(RechargeConst.E_GetTurntableData, OnGetTurntableData)

	local function OnTurntableDraw(id)
		self.rewardId = self.model:GetRewardIndex(id)
		self:RefreshUI()
		self:StartTurning()
	end
	self._handle2 = self.model:AddEventListener(RechargeConst.E_TurntableDraw, OnTurntableDraw)

	local function OnGetTurnRecList(list)
		self:RefreshHistoryList(list)
	end
	self._handle3 = self.model:AddEventListener(RechargeConst.E_GetTurnRecList, OnGetTurnRecList)

	local function OnResetTurnContent()
		self:Reset()
	end
	self._handle4 = self.model:AddEventListener(RechargeConst.E_ResetTurnContent, OnResetTurnContent)
end

function TurnContent:OnChoujiangClick()
	if self.bTurning then return end
	RechargeController:GetInstance():C_TurntableDraw(self.costType or 3)
end

function TurnContent:RefreshUI()
	local itemsData = self.model:GetItemsData()
	self:RefreshCost()
	self:RefreshItems(itemsData)
end

function TurnContent:RefreshHistoryList(list)
	self.listIndex = 1
	self.rankList = list
	RenderMgr.Add(function () self:RefreshContentInFrame() end, RechargeConst.RefreshContentInFrame)
end

function TurnContent:OnScrollEndHandler(contenxt)
	--wktest
	-- print("111")
	-- print(contenxt.sender.isBottomMost)
	if contenxt.sender.isBottomMost and not self.reqLocking then
		--print("222")
		local start, offset = self.model:GetTurnRetListIdx()
		local newStart = #self.contentItemList + 1
		if newStart <= self.model:GetHistoryMaxNum() then
			--print("newStart ==>> ", newStart)
			self.reqLocking = true
			RechargeController:GetInstance():C_GetTurnRecList(newStart)
		end
	end
end

function TurnContent:RefreshContentInFrame()
	if self.listIndex <= #self.rankList then
		local item = self:GetRankItemFromPool()
		if item then
			self:RefreshListItem(item, self.rankList, self.listIndex)
			self.listHistory:AddChild(item)
		end
		self.listIndex = self.listIndex + 1
	else
		RenderMgr.Remove(RechargeConst.RefreshContentInFrame)
		self.listIndex = nil
		self.reqLocking = false
		local start = self.model:GetTurnRetListIdx()
		if start == RechargeConst.TURN_LIST_START_IDX then
			self.listHistory.scrollPane:ScrollTop()
		else
			self.listHistory.scrollPane:ScrollBottom()
		end
	end
end

function TurnContent:GetRankItemFromPool()
	local item = nil
	if #self.contentItemList < self.model:GetHistoryMaxNum() then
		item = UIPackage.CreateObject("Welfare", "TurnHistoryCell")
		table.insert(self.contentItemList, item)
	end
	return item
end

function TurnContent:DestoryRankItemPool()
	for i = 1, #self.contentItemList do
		destroyUI(self.contentItemList[i])
		--self.contentItemList[i]:Destroy() 
	end
	self.contentItemList = {}
end

function TurnContent:RefreshListItem(item, rankList, listIndex)
	local data = rankList[listIndex]
	if data then
		local txtDesc1 = item:GetChild("txtDesc1")
		local txtDesc2 = item:GetChild("txtDesc2")
		-- StringFormat("恭喜 {0} 获得：", data.playerName)
		local str = StringFormat( [[恭喜 [color=#fad897]{0}[/color] 获得：]], data.playerName)
		txtDesc1.text = str
		local tmp = self.model:GetRewardListById(data.rewardId)
		local vo = GoodsVo.New()
		vo:SetCfg(tmp[1], tmp[2], tmp[3], tmp[4])
		local cfg = GoodsVo.GetCfg(tmp[1], tmp[2])
		local strColor = GoodsVo.RareColor[cfg.rare]
		str = StringFormat(" [color={0}]{1}[/color][color=#ffffff]X{2}[/color]", strColor, vo.cfg.name, vo.num)
		txtDesc2.text = str
	end
end

function TurnContent:Reset()
	RenderMgr.Remove(RechargeConst.RefreshContentInFrame)
	RenderMgr.Remove(RechargeConst.KEY_RENDER_TURNING)
	self:DestoryRankItemPool()
	self.listHistory:RemoveChildren()
end

function TurnContent:RefreshCost()
	local tType, cost, itemId = self.model:GetTurnCost()
	self.costType = tType
	if tType == RechargeConst.TurnCostType.Free then
		self:SetCosts(true, false, false)
	elseif tType == RechargeConst.TurnCostType.Item then
		self:SetCosts(false, true, true)
		local id = GetCfgData("item"):Get(itemId).icon
		self.iconCost.url = "Icon/Goods/" .. id
		self.txtCostNum.text = "X" .. cost
	elseif tType == RechargeConst.TurnCostType.Diamond then
		self:SetCosts(false, true, true)
		self.iconCost.url = "Icon/Goods/diamond"
		self.txtCostNum.text = "X" .. cost
	end
end

function TurnContent:SetCosts(b1, b2, b3)
	self.txtFree.visible = b1
	self.txtCostNum.visible = b2
	self.iconCost.visible = b3
end

function TurnContent:RefreshItems(data)
	if not data or #data <= 0 then return end
	local rewardId = nil
	for i = 1, RechargeConst.TURN_GOODS_NUM do
		local tmp = self.model:GetRewardListById(data[i])
		local vo = GoodsVo.New()
		vo:SetCfg(tmp[1], tmp[2], tmp[3], tmp[4])
		local str = StringFormat("X{0}", vo.num)
		local item = self.items[i]
		if item then
			self:RefreshOneItem(item, GoodsVo.GetIconUrl(tmp[1], tmp[2]), str, false)
		end
	end
end

function TurnContent:RefreshOneItem(item, url, text, visible)
	item:GetChild("icon1").url = url
	item:GetChild("n3").text = text
	item:GetChild("imgXuanzhong").visible = visible
end

function TurnContent:StartTurning()
	self.bTurning = true
    self.bResultShowed = false
    RenderMgr.Remove(RechargeConst.KEY_RENDER_TURNING)
    self.round = 1 * 40
    self.speed = 2
    self.slowAngle = nil
    self.isSlowed = false
    self.isOver = false
    self.slowChacheAngle = 18+2+9
    RenderMgr.Add(function () self:rotationLunPan() end, RechargeConst.KEY_RENDER_TURNING)
end

function TurnContent:rotationLunPan()
	if self.isOver == true then
        self:StopAc()
        return
    end
    if self.ui.visible == false then
    	self:StopAc()
    	return
    end
    local speedHigh = 18
    local speedLow = 2
    local speedLowest = 0
    local currrotation = self.comTurnBg.rotation
    local state = 0
    if self.round > 0 then
        -- start and speed up to high
        self.speed = speedHigh
        local speed = math.floor(self.speed)
        currrotation = currrotation + speed
        self.round = self.round - speed
        currrotation = math.floor(currrotation * 10)
        currrotation = math.mod(currrotation,3600)
        currrotation = currrotation * 0.1
        self.comTurnBg.rotation = currrotation
    else
        if self.slowAngle == nil then
            local angle = ( RechargeConst.TURN_GOODS_NUM - self.rewardId + 1 ) * RechargeConst.UNIT_ANGLE
            angle = math.mod(angle,360)
            currrotation = math.floor(currrotation * 10)
            currrotation = math.mod(currrotation,3600)
            currrotation = currrotation * 0.1
            angle = angle - currrotation + 360
            angle = math.mod(angle,360)
            if angle < 180 then
                angle = angle + 360
            end

            self.slowAngle = angle + 360 + 180
            local v0 = speedLow
            local v = speedHigh 
            local a = (v * v - v0 * v0) / (2* self.slowAngle)
            self.a = a
            self.speed = v
            self.slowAngle = self.slowAngle + 180
        end
        if self.slowAngle and self.slowAngle > 0 then
            -- speed down to low 
            local s = self.speed  - 0.5 * self.a
            self.speed = self.speed - self.a
            if self.isSlowed == false and self.speed < speedLow then
                -- [a] slow down
                self.speed = self.speed + self.a
                local a = self.speed - speedLow
                s = self.speed  - 0.5 * a

                self.isSlowed = true
                local v = speedLow 
                local v0 = speedLowest
                a = (v * v - v0 * v0) / (2* self.slowAngle)
                self.a = a
                self.speed = speedLow
            end
            if self.speed < speedLowest + self.a then
                self.slowAngle = 0
                self.speed = self.speed + self.a
                local a = self.speed - speedLowest
                s = self.speed  - 0.5 * a
                self.speed = speedLowest
                currrotation = currrotation + s
            else
                self.slowAngle = self.slowAngle - s
                currrotation = currrotation + s
            end
            self.comTurnBg.rotation = currrotation
        else
            -- back to end
            self.slowChacheAngle = 0
            if self.slowChacheAngle and self.slowChacheAngle > 0 then
                self.slowChacheAngle = self.slowChacheAngle - self.speed
                currrotation = currrotation - self.speed
            else
                local angle = ( RechargeConst.TURN_GOODS_NUM - self.rewardId + 1 ) * RechargeConst.UNIT_ANGLE
                currrotation = angle
                self.isOver = true
            end
            self.comTurnBg.rotation = currrotation
        end
    end
end

function TurnContent:StopAc()
    RenderMgr.Remove(RechargeConst.KEY_RENDER_TURNING)
    local currrotation = self.comTurnBg.rotation
    local destrotation = self:getDestAngle(currrotation, self.rewardId)
    self:endTurning(destrotation)
    self.bTurning = false
end

function TurnContent:getDestAngle(angle, index)
    local angle = ( RechargeConst.TURN_GOODS_NUM - self.rewardId + 1 ) * RechargeConst.UNIT_ANGLE
    angle = math.mod(angle, 360)
    return angle
end

function TurnContent:endTurning(destrotation)
    self.comTurnBg.rotation = destrotation
    self:ShowReward()
end

function TurnContent:ShowReward()
    self.bResultShowed = true
    local index = self.rewardId
    self.items[index]:GetChild("imgXuanzhong").visible = true
    local rewardId = self.model:GetRewardIdByIndex(index)
    local tmp = self.model:GetRewardListById(rewardId)
	local vo = GoodsVo.New()
	vo:SetCfg(tmp[1], tmp[2], tmp[3], tmp[4])
	local cfg = vo.cfg
    Message:GetInstance():TipsMsg(StringFormat("您获得了 [color={0}]{1}[/color] x {2}个", GoodsVo.RareColor[cfg.rare], cfg.name, vo.num))
	ChatNewController:GetInstance():AddOperationMsgByCfg(cfg.id, vo.num)
	if self.model:CheckNeedBroadcast(rewardId) then
		RechargeController:GetInstance():C_GetTurnRecList(RechargeConst.TURN_LIST_START_IDX, self.model:GetHistoryOnePageNum())
	end
end