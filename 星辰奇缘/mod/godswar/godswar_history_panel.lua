-- 作者:jia
-- 3/31/2017 10:58:58 AM
-- 功能:诸神之战查看历史八强面板

GodsWarHistoryPanel = GodsWarHistoryPanel or BaseClass(BasePanel)
function GodsWarHistoryPanel:__init(parent)
    self.parent = parent
    self.effectPath = "prefabs/effect/20194.unity3d"
    self.resList = {
        { file = AssetConfig.godswarhistorypanel, type = AssetType.Main },
        { file = AssetConfig.rank_textures, type = AssetType.Dep },
        { file = AssetConfig.godswarres, type = AssetType.Dep },
        { file = AssetConfig.guildleague_texture, type = AssetType.Dep},
        {file = self.effectPath, type = AssetType.Main},
    }
    self.OnOpenEvent:Add( function() self:OnShow() end)
    self.OnHideEvent:Add( function() self:OnHide() end)

    self.zoneListener = function(zone) self:ChangeZone(zone) end
    self.historylistener = function() self:Update() end
    self.seasonListener = function(selseason) self:ChangeSeason(selseason) end

    self.round1List = {}
    self.round2List = {}
    self.round3List = {}

    self.light1List = {}
    self.light2List = {}
    self.light3List = {}

    self.dataList1 = {}
    self.dataList2 = {}
    self.dataList3 = {}
    self.dataList4 = {}

    self.selSeason = 1
    self.zone = 1
    self.hasInit = false
end

function GodsWarHistoryPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.godswar_history_update, self.historylistener)
    EventMgr.Instance:RemoveListener(event_name.godswar_select_update, self.zoneListener)
    EventMgr.Instance:RemoveListener(event_name.godswar_his_select_seasom_update, self.seasonListener)
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function GodsWarHistoryPanel:OnHide()

end

function GodsWarHistoryPanel:OnShow()
    self:UpdateMyGroup()
    self:ChangeZone(self.zone)
    self:ChangeSeason(GodsWarManager.Instance.season - 1)
end

function GodsWarHistoryPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarhistorypanel))
	self.gameObject.name = "GodsWarHistoryPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.mainTransform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(0, -100)

	self.Main = self.transform:Find("Main")
    self.button = self.transform:Find("Main/Button"):GetComponent(Button)
    self.button.onClick:AddListener(
        function ()
            GodsWarManager.Instance.model:OpenSelect(3)
        end)
    self.buttonTxt = self.transform:Find("Main/Button/Text"):GetComponent(Text)

    self.btn_season = self.transform:Find("Main/btn_season"):GetComponent(Button)
    self.btn_season.onClick:AddListener(
        function ()
            GodsWarManager.Instance.model:OpenSelect(4)
        end)
    self.txt_btnseason = self.transform:Find("Main/btn_season/Text"):GetComponent(Text)

    local right = self.transform:Find("Main/Right")
    for i = 1, 8 do
        local effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    	local item = GodsWarFightElimintionItem.New(right:Find("Team1" .. i).gameObject, self, effect)
    	table.insert(self.round1List, item)
    end

    for i = 1, 4 do
        local effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    	local item = GodsWarFightElimintionItem.New(right:Find("Team2" .. i).gameObject, self, effect)
    	table.insert(self.round2List, item)
    end

    for i = 1, 4 do
        local effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    	local item = GodsWarFightElimintionItem.New(right:Find("Team3" .. i).gameObject, self, effect)
    	table.insert(self.round3List, item)
    end

    local light = right:Find("Light")
    for i = 1, 8 do
    	table.insert(self.light1List, light:Find("Team1" .. i).gameObject)
    end

    for i = 1, 4 do
    	table.insert(self.light2List, light:Find("Team2" .. i).gameObject)
    end

    for i = 1, 4 do
    	table.insert(self.light3List, light:Find("Team3" .. i).gameObject)
    end

    EventMgr.Instance:AddListener(event_name.godswar_history_update, self.historylistener)
	EventMgr.Instance:AddListener(event_name.godswar_select_update, self.zoneListener)
    EventMgr.Instance:AddListener(event_name.godswar_his_select_seasom_update, self.seasonListener)

    self.finalTxt = self.transform:Find("Main/Right/1/Text"):GetComponent(Text)
    self.finalBtn = self.transform:Find("Main/Right/1"):GetComponent(Button)
    self.thirdTxt = self.transform:Find("Main/Right/3/Text"):GetComponent(Text)
    self.thirdBtn = self.transform:Find("Main/Right/3"):GetComponent(Button)
    self.finalTxt.text = TI18N("冠军")
    self.thirdTxt.text = TI18N("季军")
	self:OnShow()
end

function GodsWarHistoryPanel:UpdateMyGroup()
    local my = GodsWarManager.Instance.myData
    if my ~= nil and my.tid ~= 0 then
        self.zone = my.lev
    else
        self.zone = GodsWarEumn.Group(RoleManager.Instance.world_lev, RoleManager.Instance.RoleData.lev_break_times)
    end
    self.buttonTxt.text = GodsWarEumn.GroupName(self.zone)
end

function GodsWarHistoryPanel:ChangeZone(zone)
	self.zone = zone
	self.buttonTxt.text = GodsWarEumn.GroupName(self.zone)
	self:Update()
end

function GodsWarHistoryPanel:Update()
    self.finalTxt.text = TI18N("冠军")
    self.thirdTxt.text = TI18N("季军")
    local dataList = GodsWarManager.Instance:GetHisElimintionData(self.selSeason,self.zone) or {}
    self:FormatList(dataList)

    for i,item in ipairs(self.round1List) do
    	item:SetData(self.dataList1[i], true)
    end

    for i,item in ipairs(self.round2List) do
    	item:SetData(self.dataList2[i], true)
    end

    for i,item in ipairs(self.round3List) do
        if i <= 2 then
            item:SetData(self.dataList4[i], true)
        else
            item:SetData(self.dataList3[i - 2], true)
        end
    end

    self:UpdateProgress()
end

function GodsWarHistoryPanel:UpdateProgress()
	for i,v in ipairs(self.round1List) do
		if v.data == nil then
			self.light1List[i]:SetActive(false)
		else
			if v.data.qualification > GodsWarEumn.Quality.Q8 then
				self.light1List[i]:SetActive(true)
			else
				self.light1List[i]:SetActive(false)
			end
		end
	end

	for i,v in ipairs(self.round2List) do
		if v.data == nil then
			self.light2List[i]:SetActive(false)
		else
			if v.data.qualification >= GodsWarEumn.Quality.ChampionPlace then
				self.light2List[i]:SetActive(true)
			else
				self.light2List[i]:SetActive(false)
			end
		end
	end

	for i,v in ipairs(self.round3List) do
		if v.data == nil then
			self.light3List[i]:SetActive(false)
		else
			if i <= 2 then
                if v.data.qualification == GodsWarEumn.Quality.Champion then
                    self.light3List[i]:SetActive(true)
                    self.finalTxt.text = v.data.name
                    self.finalBtn.onClick:RemoveAllListeners()
                    self.finalBtn.onClick:AddListener(function() GodsWarManager.Instance.model:OpenTeam(v.data) end)
                    v:ChangeThirdShow(false)
                elseif v.data.qualification == GodsWarEumn.Quality.Second then
                    self.light3List[i]:SetActive(false)
                    v:ChangeThirdShow(true)
                else
                    v:ChangeThirdShow(false)
                    self.light3List[i]:SetActive(false)
                end
			elseif i >= 3 and v.data.qualification == GodsWarEumn.Quality.Third then
				self.light3List[i]:SetActive(true)
                self.thirdTxt.text = v.data.name
                self.thirdBtn.onClick:RemoveAllListeners()
                self.thirdBtn.onClick:AddListener(function() GodsWarManager.Instance.model:OpenTeam(v.data) end)
			else
				self.light3List[i]:SetActive(false)
			end
		end
	end
end

function GodsWarHistoryPanel:FormatList(list)
    self.dataList1 = {}
    self.dataList2 = {}
    self.dataList3 = {}
    self.dataList4 = {}
    for i,v in ipairs(list) do
        if v.qualification >= GodsWarEumn.Quality.Q8 then
            local key = GodsWarEumn.GroupIndex(v.team_group_64)
            -- table.insert(self.dataList1, v)
            self.dataList1[key] = v
        end
        if v.qualification >= GodsWarEumn.Quality.Q4 then
            -- local key = math.ceil(i / 2)
            local key = GodsWarEumn.GroupIndex2(v.team_group_64)
            self.dataList2[key] = v
        end
        if v.qualification >= GodsWarEumn.Quality.ThirdPlace and v.qualification < GodsWarEumn.Quality.ChampionPlace then
            -- local key = math.ceil(i / 4)
            local key = GodsWarEumn.GroupIndex3(v.team_group_64)
            self.dataList3[key] = v
        end
        if v.qualification >= GodsWarEumn.Quality.ChampionPlace then
            -- local key = math.ceil(i / 4)
            local key = GodsWarEumn.GroupIndex3(v.team_group_64)
            self.dataList4[key] = v
        end
    end
end

function GodsWarHistoryPanel:ChangeSeason(selseason)
    self.selSeason = selseason or 1
    GodsWarManager.Instance.selectSeason = self.selSeason
    if self.selSeason <= 0 then
        self.selSeason = 1
    end
    self.txt_btnseason.text = string.format(TI18N("第%s赛季"),self.selSeason)
    self:Update()
end
