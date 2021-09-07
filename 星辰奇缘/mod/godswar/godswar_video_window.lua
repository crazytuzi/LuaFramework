-- -----------------------------------
-- 诸神之战录像观战界面
-- hosr
-- -----------------------------------

GodsWarVideoWindow = GodsWarVideoWindow or BaseClass(BaseWindow)

function GodsWarVideoWindow:__init(model)
	self.model = model
  self.windowId = WindowConfig.WinID.godswar_video
	self.resList = {
		{file = AssetConfig.godswarmovie, type = AssetType.Main},
		{file = AssetConfig.godswarres, type = AssetType.Dep},
	}
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.listener = function(list) self:Update(list) end
    self.type = 1
    self.selectListener = function(index) self:ChangeZone(index) end
    self.numberListener = function() self:SetNumber() end
    self.filterName = nil
    self.auto = nil
end

function GodsWarVideoWindow:__delete()
  GodsWarManager.Instance.OnUpdateTime:RemoveListener(self.numberListener)
  if self.tabGroup ~= nil then
    self.tabGroup:DeleteMe()
    self.tabGroup = nil
  end
  EventMgr.Instance:RemoveListener(event_name.godswar_video_update, self.listener)
  EventMgr.Instance:RemoveListener(event_name.godswar_select_update, self.selectListener)
end

function GodsWarVideoWindow:OnShow()
  GodsWarManager.Instance.OnUpdateTime:RemoveListener(self.numberListener)
    GodsWarManager.Instance.OnUpdateTime:AddListener(self.numberListener)
    GodsWarManager.Instance:Send17933()
  if self.openArgs ~= nil then
    self.type = self.openArgs.type or 1
    self.group = self.openArgs.group or GodsWarEumn.Group(RoleManager.Instance.world_lev, RoleManager.Instance.RoleData.lev_break_times)
    self.filterName = self.openArgs.name
    self.auto = self.openArgs.auto
  end

  if self.type == nil then
    self.type = 1
  end

  if self.group == nil then
    self.group = GodsWarEumn.Group(RoleManager.Instance.world_lev, RoleManager.Instance.RoleData.lev_break_times)
  end

  self:Update({})
  self.tabGroup:ChangeTab(self.type)
  if self.auto ~= nil then
     self.LuaTimerId = LuaTimer.Add(1000,function() self:ClickGodsWarChallengeWatch() end)
  end
  --LuaTimer.Add(3000,function() self:ClickGodsWarChallengeWatch() end)


end

function GodsWarVideoWindow:OnHide()
  if self.LuaTimerId ~= nil then
      LuaTimer.Delete(self.LuaTimerId)
      self.LuaTimerId = nil
  end
end

function GodsWarVideoWindow:Close(onCheck)
  self.model:CloseVideo(onCheck)
end

function GodsWarVideoWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.godswarmovie))
    self.gameObject.name = "GodsWarVideoWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    local tabGroupSetting = {
        notAutoSelect = true,
        noCheckRepeat = true,
    }
    self.tabGroup = TabGroup.New(self.transform:Find("Main/TabButtonGroup"), function(index) self:ChangeTab(index) end, tabGroupSetting)
    self.transform:Find("Main/Button"):GetComponent(Button).onClick:AddListener(function() GodsWarManager.Instance.model:OpenSelect(2) end)
    self.buttonTxt = self.transform:Find("Main/Button/Text"):GetComponent(Text)

    self.nothing = self.transform:Find("Main/Container/Nothing").gameObject
    self.nothingTxt = self.transform:Find("Main/Container/Nothing/Text"):GetComponent(Text)
    self.scroll = self.transform:Find("Main/Container/Scroll").gameObject

    self.Container = self.transform:Find("Main/Container/Scroll/Container")
    self.ScrollCon = self.transform:Find("Main/Container/Scroll")
    self.transform:Find("Main/Title/Icon1").transform.anchoredPosition = Vector2(52.5,-3)
    self.numberImg1 = self.transform:Find("Main/Title/Icon1"):GetComponent(Image)
    self.numberImg2 = self.transform:Find("Main/Title/Icon2"):GetComponent(Image)
    self.rank_item_list = {}
    local len = self.Container.childCount
    for i = 1, len do
        local go = self.Container:GetChild(i - 1).gameObject
        local item = GodsWarVideoItem.New(go, self)
        go:SetActive(false)
        table.insert(self.rank_item_list, item)
    end
    self.single_item_height = self.rank_item_list[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.item_con_last_y = self.Container:GetComponent(RectTransform).anchoredPosition.y
    self.scroll_con_height = self.ScrollCon:GetComponent(RectTransform).sizeDelta.y

    self.setting = {
       item_list = self.rank_item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.Container  --item列表的父容器
       ,single_item_height = self.single_item_height --一条item的高度
       ,item_con_last_y = self.item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.vScroll = self.ScrollCon:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting) end)
    BaseUtils.refresh_circular_list(self.setting)

    EventMgr.Instance:AddListener(event_name.godswar_video_update, self.listener)
    EventMgr.Instance:AddListener(event_name.godswar_select_update, self.selectListener)
    self:OnShow()
end

function GodsWarVideoWindow:Update(list)
    table.sort(list, function(a,b) return a.time > b.time end)
    print("录像长度："..#list)
    local newList = {}
    if self.filterName ~= nil and self.filterName ~= "" then
        for i,v in ipairs(list) do
            if self.filterName == v.atk_name or self.filterName == v.dfd_name then
                table.insert(newList, v)
            end
        end
    end

    self.setting.data_list = newList
    if #newList == 0 and not GodsWarManager.Instance.isHitstory then
        self.setting.data_list = list
    end

    if #list == 0 then
        self.nothing:SetActive(true)
        self.scroll:SetActive(false)
        if self.type == 1 then
            self.nothingTxt.text = TI18N("暂无录像数据")
        else
            self.nothingTxt.text = TI18N("当前没有正在进行的战斗")
        end
    else
        self.nothing:SetActive(false)
        self.scroll:SetActive(true)
    end
    BaseUtils.refresh_circular_list(self.setting)
end


function GodsWarVideoWindow:SetNumber()
    local number1 = nil
    local number2 = nil
    local isNumberDouble = false

    if tonumber(GodsWarManager.Instance.godTimeNumber) >= 10 then

        local i,j,tag,val = string.find(tostring(GodsWarManager.Instance.godTimeNumber),"(%d)(%d)")
       number1 = tostring(tag)
       number2 = tostring(val)
       isNumberDouble = true

    end


    if isNumberDouble == true then
        self.number1 = self.assetWrapper:GetSprite(AssetConfig.godswarres,"Number" .. number1)
        self.number2 = self.assetWrapper:GetSprite(AssetConfig.godswarres,"Number" .. number2)
    else
        self.number1 = self.assetWrapper:GetSprite(AssetConfig.godswarres,"Number" .. GodsWarManager.Instance.godTimeNumber)
        self.number2 = nil
    end

    if self.number1 == nil then
        self.numberImg1.gameObject:SetActive(false)
    else
        self.numberImg1.gameObject:SetActive(true)
        self.numberImg1:SetNativeSize()
        self.numberImg1.sprite = self.number1
    end

    if self.number2 == nil then
        self.numberImg2.gameObject:SetActive(false)
    else
        self.numberImg2.gameObject:SetActive(true)
        self.numberImg2:SetNativeSize()
        self.numberImg2.sprite = self.number2
    end
end

function GodsWarVideoWindow:ChangeTab(index)
  self.type = index
  self.buttonTxt.text = GodsWarEumn.GroupName(self.group)
  local selectSeason = GodsWarManager.Instance.season
  if  GodsWarManager.Instance.isHitstory then
    selectSeason = GodsWarManager.Instance.selectSeason
  end
  GodsWarManager.Instance:Send17928(selectSeason, self.group, self.type)
end

function GodsWarVideoWindow:ChangeZone(zone)
  self.group = zone
  self.buttonTxt.text = GodsWarEumn.GroupName(self.group)
  local  selectSeason = GodsWarManager.Instance.season
  if GodsWarManager.Instance.isHitstory then
    selectSeason = GodsWarManager.Instance.selectSeason
  end
  GodsWarManager.Instance:Send17928(selectSeason,self.group, self.type)
end

function GodsWarVideoWindow:ClickGodsWarChallengeWatch()
    local WatchId = nil
    BaseUtils.dump(self.setting.data_list,"self.setting.data_list")
    for i,v in pairs(self.setting.data_list) do
        if v.match_type == 3 then
            WatchId = v.id
            break
        end
    end
    GodsWarManager.Instance:Send17959(WatchId)
    self:Close(false)
end