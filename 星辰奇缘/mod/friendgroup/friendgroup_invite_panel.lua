--作者:hzf
--02/23/2017 11:07:43
--功能:群组邀请面板 /加入黑名单

FriendGroupInvitePanel = FriendGroupInvitePanel or BaseClass(BasePanel)
function FriendGroupInvitePanel:__init(model,type)
  self.model = model
  self.type = type or 1                            --type 1:群组添加好友  2:黑名单
	self.friendMgr = FriendManager.Instance
	self.groupMgr = FriendGroupManager.Instance
	self.resList = {
		{file = AssetConfig.groupinvitepanel, type = AssetType.Main}
		,{file = AssetConfig.friendtexture, type = AssetType.Dep}
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
	self.selectList = {}
end

function FriendGroupInvitePanel:__delete()
  -- self.model.lastInvited = {}
  for _, item in ipairs(self.Litem_list) do
      item:DeleteMe()
  end

	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function FriendGroupInvitePanel:OnHide()

end

function FriendGroupInvitePanel:OnOpen()

end

function FriendGroupInvitePanel:InitPanel()
  self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.groupinvitepanel))

	self.transform = self.gameObject.transform
	UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
	self.transform:SetSiblingIndex(2)

	self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function()
		self.model:CloseInvitePanel()
	end)
	self.MainCon = self.transform:Find("MainCon")
	self.bg = self.transform:Find("MainCon/bg")
	self.Title = self.transform:Find("MainCon/Title")
	self.Text = self.transform:Find("MainCon/Title/Text"):GetComponent(Text)
	self.HasText = self.transform:Find("MainCon/HasText"):GetComponent(Text)
  
	self.LMask = self.MainCon:Find("LMask")
	self.LCon = self.LMask:Find("LCon")
	self.LList = self.LMask:Find("LCon/List")
  self.LBaseItem = self.LMask:Find("LCon/List/BaseItem")
  self.NoListTxt = self.LCon:Find("NoListTxt"):GetComponent(Text)

	self.RMask = self.MainCon:Find("RMask")
	self.RCon = self.RMask:Find("RCon")
	self.RList = self.RMask:Find("RCon/List")
	self.RBaseItem = self.RMask:Find("RCon/List/BaseItem")

	self.SelectText = self.transform:Find("MainCon/SelectText"):GetComponent(Text)
	self.RemainText = self.transform:Find("MainCon/RemainText"):GetComponent(Text)
	self.Arrow = self.transform:Find("MainCon/Arrow")
  self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function()
      if self.type == 1 then 
        self.model:CloseInvitePanel()
      elseif self.type == 2 then 
        self.model:CloseAddBlackPanel()
      end
  end)
  self.transform:Find("MainCon/BackButton"):GetComponent(Button).onClick:AddListener(function()
      if self.type == 1 then 
        self.model:CloseInvitePanel()
      elseif self.type == 2 then 
        self.model:CloseAddBlackPanel()
      end
	end)
	self.transform:Find("MainCon/InviteButton"):GetComponent(Button).onClick:AddListener(function()
		self:OnOK()
  end)
  
  if self.type == 1 then 
    self.gameObject.name = "FriendGroupInvitePanel"
    self.HasText.gameObject:SetActive(false)
    self.data = self.groupMgr:GetGroupData(self.openArgs[1], self.openArgs[2], self.openArgs[3])
  elseif self.type == 2 then 
    self.gameObject.name = "AddBlackFriendPanel"
    self.Text.text = TI18N("添加黑名单")
    self.HasText.gameObject:SetActive(true)
    self.HasText.text = TI18N("只可屏蔽最近私聊的陌生人")
    self.SelectText.gameObject:SetActive(false)
    self.RemainText.gameObject:SetActive(false)
    self.transform:Find("MainCon/InviteButton/Text"):GetComponent(Text).text = TI18N("确定拉黑")
  end
	self:InitList()
end

function FriendGroupInvitePanel:InitList()
    local list = {}
    if self.type == 1 then 
      list = self:GetOnlineFriend()
    elseif self.type == 2 then 
      list = self.friendMgr:GetSecondSortChatlist()
      self.NoListTxt.transform.gameObject:SetActive(#list == 0)
    end
    list = self:GetShowList(list)
    self.Litem_list = {}
    self.Litem_con = self.LList
    self.Litem_con_last_y = self.Litem_con:GetComponent(RectTransform).anchoredPosition.y
    self.Lsingle_item_height = self.LBaseItem.transform:GetComponent(RectTransform).sizeDelta.y
    self.Lscroll_con_height = self.LMask:GetComponent(RectTransform).sizeDelta.y
    for i=1,8 do
        local go = self.Litem_con:GetChild(i-1).gameObject
        local item = GroupInviteItem.New(go, self, 1)
        table.insert(self.Litem_list, item)
    end
    self.Lsetting_data = {
       item_list = self.Litem_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.Litem_con  --item列表的父容器
       ,single_item_height = self.Lsingle_item_height --一条item的高度
       ,item_con_last_y = self.Litem_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.Lscroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    self.LvScroll = self.LCon:GetComponent(ScrollRect)
    self.LvScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.Lsetting_data)
    end)
    self.Lsetting_data.data_list = list
    BaseUtils.refresh_circular_list(self.Lsetting_data)

    local list = self.selectList
    self.Ritem_list = {}
    self.Ritem_con = self.RList
    self.Ritem_con_last_y = self.Ritem_con:GetComponent(RectTransform).anchoredPosition.y
    self.Rsingle_item_height = self.RBaseItem.transform:GetComponent(RectTransform).sizeDelta.y
    self.Rscroll_con_height = self.RMask:GetComponent(RectTransform).sizeDelta.y
    for i=1,8 do
        local go = self.Ritem_con:GetChild(i-1).gameObject
        local item = GroupInviteItem.New(go, self, 2)
        table.insert(self.Ritem_list, item)
    end
    self.Rsetting_data = {
       item_list = self.Ritem_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.Ritem_con  --item列表的父容器
       ,single_item_height = self.Rsingle_item_height --一条item的高度
       ,item_con_last_y = self.Ritem_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.Rscroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    self.RvScroll = self.RCon:GetComponent(ScrollRect)
    self.RvScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.Rsetting_data)
    end)
    self.Rsetting_data.data_list = list
    BaseUtils.refresh_circular_list(self.Rsetting_data)
    
    if self.type == 1 then 
      local groupdata = self.groupMgr:GetGroupData(self.openArgs[1], self.openArgs[2], self.openArgs[3])
      self.SelectText.text = string.format(TI18N("已选好友：%s"), #self.selectList)
      self.RemainText.text = string.format(TI18N("还可邀请：%s"), 15 - #groupdata.members)
    end
end

function FriendGroupInvitePanel:UpdateList()
    local list = {}
    local max, online = 0, 0
    if self.type == 1 then 
      list, max, online = self:GetOnlineFriend()
    elseif self.type == 2 then 
      list = self.friendMgr:GetSecondSortChatlist()
      self.NoListTxt.transform.gameObject:SetActive(#list == 0)
    end
    list = self:GetShowList(list)
    if self.Lsetting_data == nil then
        return
    end
    for k,v in pairs(self.Litem_list) do
        v.gameObject:SetActive(true)
    end
    self.Lsetting_data.data_list = list
    BaseUtils.static_refresh_circular_list(self.Lsetting_data)
    list = self.selectList

    if self.Rsetting_data == nil then
        return
    end
    for k,v in pairs(self.Ritem_list) do
        v.gameObject:SetActive(true)
    end
    self.Rsetting_data.data_list = list
    BaseUtils.refresh_circular_list(self.Rsetting_data)

    if self.type == 1 then 
      local groupdata = self.groupMgr:GetGroupData(self.openArgs[1], self.openArgs[2], self.openArgs[3])
      self.HasText.text = string.format(TI18N("在线好友：%s/%s"), online, max)
      self.SelectText.text = string.format(TI18N("已选好友：%s"), #self.selectList)
    end
end

function FriendGroupInvitePanel:IsSelected(data)
    for k,v in ipairs(self.selectList) do
        if v.id == data.id and v.platform == data.platform and v.zone_id == data.zone_id then
            return true
        end
    end
    return false
end

function FriendGroupInvitePanel:IsSended(data)
  local list 
  if self.type == 1 then 
    local key = BaseUtils.Key(self.openArgs[1], self.openArgs[2], self.openArgs[3])
    list = self.model.lastInvited[key]
  elseif self.type == 2 then 
    -- list = self.model.last_addBlackList  --黑名单不需要记录
  end

  if list == nil then
    return false
  elseif Time.time - list.time > 60 then
    if self.type == 1 then 
      self.model.lastInvited[key] = nil
    elseif self.type == 2 then 
      -- self.model.last_addBlackList = nil 
    end
    return false
  end
	for k,v in ipairs(list.data) do
		if v.id == data.id and v.platform == data.platform and v.zone_id == data.zone_id then
			return true
		end
	end

	return false
end

function FriendGroupInvitePanel:AddOne(data)
	local index = nil
	for k,v in ipairs(self.selectList) do
		if v.id == data.id and v.platform == data.platform and v.zone_id == data.zone_id then
			index = k
			break
		end
	end
	if index == nil then
		table.insert(self.selectList, data)
		self:UpdateList()
	end
end

function FriendGroupInvitePanel:ReduceOne(data)
	local index = nil
	for k,v in ipairs(self.selectList) do
		if v.id == data.id and v.platform == data.platform and v.zone_id == data.zone_id then
			index = k
			break
		end
	end
	if index ~= nil then
		table.remove(self.selectList, index)
		self:UpdateList()
	end
end

function FriendGroupInvitePanel:OnOK()
  if #self.selectList == 0 then
    NoticeManager.Instance:FloatTipsByString(TI18N("未选择任何玩家"))
  else
    if self.type == 1 then 
      for k,v in pairs(self.selectList) do
        self.groupMgr:Require19003(self.openArgs[1], self.openArgs[2], self.openArgs[3], v.id, v.platform, v.zone_id)
      end
      local key = BaseUtils.Key(self.openArgs[1], self.openArgs[2], self.openArgs[3])
      self.model.lastInvited[key] = {data = self.selectList, time = Time.time}
      self.selectList = {}
		  self:UpdateList()
    elseif self.type == 2 then 
      for k,v in pairs(self.selectList) do
        self.friendMgr:Require11806(v.id, v.platform, v.zone_id)
      end
      self.model:CloseAddBlackPanel()
    end
	end
end

function FriendGroupInvitePanel:GetOnlineFriend()
	local list = self.friendMgr:GetSortFriendList(1)
  local ismygroup = self:IsSelfOwner()
	local temp = {}
	local onlinenum = 0
	local groupdata = self.groupMgr:GetGroupData(self.openArgs[1], self.openArgs[2], self.openArgs[3])
	for i,v in ipairs(list) do
		if v.online == 1 or ismygroup then
			onlinenum = onlinenum + 1
			local has = false
			for _,member in ipairs(groupdata.members) do
				if member.role_rid == v.id and member.role_platform == v.platform and member.role_zone_id == v.zone_id then
					has = true
				end
			end
			if not has then
				table.insert(temp, v)
			end
		end
	end
  local function sort(a,b)
      if a.online > b.online then
          return true
      elseif a.online < b.online then
          return false
      elseif a.intimacy > b.intimacy then
          return true
      elseif a.id > b.id and a.intimacy == b.intimacy then
          return true
      else
          return false
      end
  end
  table.sort( temp, sort)
	return temp, #list, onlinenum
end

function FriendGroupInvitePanel:GetShowList(data_list)
    local temp = {}
    for i,v in ipairs(data_list) do
        if not self:IsSelected(v) then
            table.insert(temp, v)
        end
    end
    return temp
end


function FriendGroupInvitePanel:IsSelfOwner()
  if self.data ~= nil then
    local roleData = RoleManager.Instance.RoleData
    for k,v in pairs(self.data.members) do
      if v.role_rid == roleData.id and v.role_platform == roleData.platform and v.role_zone_id == roleData.zone_id then
        return v.post == 1
      end
    end
    return false
  end
  return false
end