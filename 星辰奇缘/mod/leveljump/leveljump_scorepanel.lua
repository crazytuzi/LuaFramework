--作者:hzf
--03/14/2017 15:00:29
--功能:卡级评分界面

LevelJumpScorePanel = LevelJumpScorePanel or BaseClass(BasePanel)
function LevelJumpScorePanel:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.leveljumpscorepanel, type = AssetType.Main}
		,{file = AssetConfig.guidetaskicon, type = AssetType.Dep}
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
    self.updateListener = function()
        self:InitList()
    end
end

function LevelJumpScorePanel:__delete()
    ForceImproveManager.Instance.onUpdateForce:RemoveListener(self.updateListener)
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function LevelJumpScorePanel:OnHide()

end

function LevelJumpScorePanel:OnOpen()

end

function LevelJumpScorePanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.leveljumpscorepanel))
	self.gameObject.name = "LevelJumpScorePanel"

	self.transform = self.gameObject.transform
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
	self.transform.localScale = Vector3.one
	self.transform.localPosition = Vector3.zero
	self.Panel = self.transform:Find("Panel")
	self.Panel:GetComponent(Button).onClick:AddListener(function()
		self.model:CloseScorePanel()
	end)
	self.MainCon = self.transform:Find("MainCon")
	self.bg = self.transform:Find("MainCon/bg")
	self.Title = self.transform:Find("MainCon/Title")
	self.Text = self.transform:Find("MainCon/Title/Text"):GetComponent(Text)
	self.ItemCon = self.transform:Find("MainCon/ItemCon")
	self.bg = self.transform:Find("MainCon/ItemCon/bg")
	self.MaskScroll = self.transform:Find("MainCon/ItemCon/MaskScroll")
	self.Layout = self.transform:Find("MainCon/ItemCon/MaskScroll/Layout")

	self.BaseItem = self.transform:Find("MainCon/ItemCon/MaskScroll/Layout/Button").gameObject
	self.BaseItem:SetActive(false)

	local setting1 = {
        column = 2
        ,cspacing = 4
        ,rspacing = 3
        ,cellSizeX = 235
        ,cellSizeY = 72
    }
    self.LayoutObj = LuaGridLayout.New(self.Layout, setting1)

	self.MainText = self.transform:Find("MainCon/Text"):GetComponent(Text)
	self.CloseButton = self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function()
		self.model:CloseScorePanel()
	end)
	self:InitList()
    ForceImproveManager.Instance.onUpdateForce:AddListener(self.updateListener)
    ForceImproveManager.Instance:send10018()
end

function LevelJumpScorePanel:SetItem(item, data)
	local recommendData = ForceImproveManager.Instance.model:GetMyRecommendData(data.id)
    if recommendData == nil then
    	print("没有推荐数据？？")
        return
    end
    local myScore = ForceImproveManager.Instance.model.subTypeList[data.id].myScore
    local serverTop = ForceImproveManager.Instance.model.subTypeList[data.id].serverTop
    -- item:Find("NameText"):GetComponent(Text).text = data.name
    item:Find("NameText"):GetComponent(Text).text = data.jumpname
    item:Find("RateBar/Bar").sizeDelta = Vector2(135.71*(math.min(1, myScore/(recommendData.val * 0.7))), 15)
    -- item:Find("RateText"):GetComponent(Text).text = string.format("%s/%s", myScore, serverTop)
    item:Find("RateText"):GetComponent(Text).text = string.format("%s/%s", myScore, math.ceil(recommendData.val * 0.7))
    item:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guidetaskicon, tostring(data.icon))
    item:Find("Finish").gameObject:SetActive(myScore >= recommendData.val * 0.7)
    item:GetComponent(Button).onClick:RemoveAllListeners()
    item:GetComponent(Button).onClick:AddListener(function()
    	if myScore >= recommendData.val * 0.7 then
    		NoticeManager.Instance:FloatTipsByString(string.format(TI18N("恭喜你<color='#ffff00'>%s</color>已达到标准"), data.name))
	    else
	    	local openArgs = {}
		    local args = StringHelper.Split(data.link, ",")
		    local winId = tonumber(args[1])
		    if winId == 0 then return end

		    for i=2,#args do
		        table.insert(openArgs, tonumber(args[i]))
		    end
		    WindowManager.Instance:OpenWindowById(winId, openArgs)
            self.model:CloseScorePanel()
	    end
    end)
    return myScore >= recommendData.val * 0.7
end

function LevelJumpScorePanel:InitList()
	local datalist = ForceImproveManager.Instance.model.classList
    --BaseUtils.dump(datalist,"datalist")
    local roleData = RoleManager.Instance.RoleData
    local currlev = roleData.lev
    local currBreak = roleData.lev_break_times
	local temp = {}
	for i,typedata in ipairs(datalist) do
        for ii,childdata in ipairs(typedata.subList) do
            if childdata.lev <= roleData.lev then
                table.insert(temp, childdata)
            end
		end
	end
    local sortfunc = function(a, b)
        local myAScore = ForceImproveManager.Instance.model.subTypeList[a.id].myScore
        local ArecommendData = ForceImproveManager.Instance.model:GetMyRecommendData(a.id)
        local myBScore = ForceImproveManager.Instance.model.subTypeList[b.id].myScore
        local BrecommendData = ForceImproveManager.Instance.model:GetMyRecommendData(b.id)
        local af = myAScore >= (ArecommendData.val*0.7)
        local bf = myBScore >= (BrecommendData.val*0.7)
        if af and not bf then
            return false
        elseif not af and bf then
            return true
        elseif af == bf then
            return a.id < b.id
        end
        return false
    end
    table.sort(temp, sortfunc)
    self.LayoutObj:ReSet()
    local unfinish = false
	for i,v in ipairs(temp) do
        if v.jumplev ~= nil and next(v.jumplev) ~= nil then
            local show = false
            for _,lev in pairs(v.jumplev) do
                if lev.item_id == currlev and lev.num == currBreak then
                    show = true
                    break
                end
            end
            if show then
                local go = self.Layout:Find(tostring(v.id))
                if go == nil then
                    go = GameObject.Instantiate(self.BaseItem)
                    go.name = tostring(v.id)
                else
                    go = go.gameObject
                end
        		local gotransform = go.transform
        		if self:SetItem(gotransform, v) then
                else
                    unfinish = true
                end
        		self.LayoutObj:AddCell(go)
            end
        end
	end
    if unfinish then
    else
        self.MainText.text = TI18N("恭喜您<color='#ffff00'>全部达标</color>，可选择<color='#ffff00'>跃升等级</color>")
    end
end