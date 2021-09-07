--作者:hzf
--10/10/2016 17:37:59
--功能:联赛小组信息

GuildLeagueGroupInfoPanel = GuildLeagueGroupInfoPanel or BaseClass(BasePanel)
function GuildLeagueGroupInfoPanel:__init(parent, Main)
	self.Mgr = GuildLeagueManager.Instance
	self.parent = parent
    self.Main = Main
	self.resList = {
		{file = AssetConfig.guildleague_groupinfo_panel, type = AssetType.Main},
		{file = AssetConfig.guildleague_texture, type = AssetType.Dep},
		{file = AssetConfig.guild_totem_icon, type = AssetType.Dep},
	}
	self.index1 = 1
	self.OnOpenEvent:Add(function() self:OnOpen() end)
	self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
  self.gradeTips = {
  [1] = TI18N("  预选赛各个小组<color='#ffff00'>前2名</color>将获得<color='#ffff00'>冠军联赛</color>资格！"),
  [2] = TI18N("  预选赛各个小组<color='#ffff00'>前2名</color>将获得<color='#ffff00'>冠军联赛</color>资格！"),
  [3] = TI18N("  预选赛各个小组<color='#ffff00'>前2名</color>将晋级<color='#ffff00'>甲级联赛</color>！"),
  [4] = TI18N("  预选赛各个小组<color='#ffff00'>第1名</color>将晋级<color='#ffff00'>乙级联赛</color>！"),
}
	self.Updatefunc = function() self:UpdateList() end
end

function GuildLeagueGroupInfoPanel:__delete()
    self.Mgr.LeagueRankUpdate:RemoveListener(self.Updatefunc)
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function GuildLeagueGroupInfoPanel:OnHide()
	self.Mgr.LeagueRankUpdate:RemoveListener(self.Updatefunc)

end

function GuildLeagueGroupInfoPanel:OnOpen()
    self.Mgr.LeagueRankUpdate:AddListener(self.Updatefunc)
    self.tabgroup:ChangeTab(self.index1)
end

function GuildLeagueGroupInfoPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildleague_groupinfo_panel))
	self.gameObject.name = "GuildLeagueGroupInfoPanel"

	self.transform = self.gameObject.transform
	UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)

	self.TabButtonGroup = self.transform:Find("TabButtonGroup")

	self.bg = self.transform:Find("bg")
	self.MaskScroll = self.transform:Find("MaskScroll")
	self.NoIMG = self.MaskScroll:Find("NoIMG").gameObject
	self.List = self.transform:Find("MaskScroll/List")
  self.tipsText = self.transform:Find("tipsText"):GetComponent(Text)
	self.rank_item_list = {}
	for i=1, self.List.childCount do
        local go = self.List.transform:GetChild(i - 1).gameObject
        local item = GuildLeagueGroupItem.New(go, self)
        table.insert(self.rank_item_list, item)
    end
    self.single_item_height = self.List.transform:GetChild(0):GetComponent(RectTransform).sizeDelta.y
    self.height_height = self.MaskScroll:GetComponent(RectTransform).sizeDelta.y
    self.item_con_last_y = self.List:GetComponent(RectTransform).anchoredPosition.y

    self.setting_data = {
       item_list = self.rank_item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.List  --item列表的父容器
       ,single_item_height = self.single_item_height --一条item的高度
       ,item_con_last_y = self.item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.height_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    self.MaskScroll:GetComponent(ScrollRect).onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)
	self.Mgr.LeagueRankUpdate:AddListener(self.Updatefunc)
    self.tabgroup = TabGroup.New(self.TabButtonGroup.gameObject, function (tab) self:OnTabChange(tab) end, {notAutoSelect = true})
    if self.Mgr.guild_LeagueInfo.grade ~= 1 then
      self.tabgroup:ChangeTab(self.Mgr.guild_LeagueInfo.grade)
    else
      self.tabgroup:ChangeTab(2)
    end
end

function GuildLeagueGroupInfoPanel:OnTabChange(index)
	self.index1 = index
  if index == 1 then
      self.Main.subArgs = {1, self.Mgr.guild_LeagueInfo.season_id}
      self.Main.tabgroup:ChangeTab(2)
      self.tabgroup:ChangeTab(2)
      return
  end
	self.Mgr:Require17620(self.index1, 2)
  self.tipsText.text = self.gradeTips[index]
end

function GuildLeagueGroupInfoPanel:UpdateList()
	self.setting_data.data_list = self.Mgr.leaguGroupData
	-- BaseUtils.dump(self.Mgr.leaguGroupData)
	self.NoIMG:SetActive(next(self.Mgr.leaguGroupData) == nil)
    -- table.sort(self.setting_data.data_list, self.sortfunc)
    BaseUtils.refresh_circular_list(self.setting_data)
end