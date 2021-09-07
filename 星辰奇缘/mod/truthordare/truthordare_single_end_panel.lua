-- ---------------------------------
-- 真心话大冒险，单轮结束界面
-- ljh
-- ---------------------------------
TruthordareSingleEndPanel = TruthordareSingleEndPanel or BaseClass(BaseView)

function TruthordareSingleEndPanel:__init(parent)
    self.parent = parent

    self.resList = {
        {file = AssetConfig.truthordaresingleendwindow, type = AssetType.Main}
        , {file = AssetConfig.truthordare_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

    self.data = nil

    self.firstThreeList = { }
    self.cellObjList = { }

    self._SingleUpdate = function() 
        self:UpdateList()
    end

    self:LoadAssetBundleBatch()
end

function TruthordareSingleEndPanel:__delete()
    self.isDelete = true
    self:SetActive(false)
    TruthordareManager.Instance.SingleEndUpdate:Remove(self._SingleUpdate)

    if self.miniTweenId ~= nil then
        Tween.Instance:Cancel(self.miniTweenId)
        self.miniTweenId = nil
    end

    if self.Layout ~= nil then
        self.Layout:DeleteMe()
        self.Layout = nil
    end
    if self.firstThreeList ~= nil then
        for i,v in pairs(self.firstThreeList) do
            v.headSlot:DeleteMe()
            v.headSlot = nil
        end
        self.firstThreeList = nil 
    end
end

function TruthordareSingleEndPanel:InitPanel()
    if self.isDelete then
        return
    end

	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.truthordaresingleendwindow))
    self.gameObject.name = "TruthordareSingleEndWindow"
    self.transform = self.gameObject.transform

    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.transform:GetComponent(RectTransform).anchoredPosition = Vector2(355, 15)
    self.transform:Find("ExitButton"):GetComponent(Button).onClick:AddListener(function() self.parent:MiniPanel() end)
    self.transform:Find("MiniButton"):GetComponent(Button).onClick:AddListener(function() self.parent:MiniPanel(true) end)

    self.firstThree = self.transform:Find("FristThree")
    for i = 1,3 do
        local temp = {}
        temp.trans = self.firstThree:GetChild(i -1)
        temp.btn = temp.trans:GetComponent(Button)
        temp.btn.onClick:RemoveAllListeners()
        temp.btn.onClick:AddListener(function() self:OnTakePraise(i) end)
        temp.name = temp.trans:Find("Name"):GetComponent(Text)
        temp.goodText = temp.trans:Find("GoodIcon/Text"):GetComponent(Text)
        temp.descText = temp.trans:Find("FlowerNum/DescText"):GetComponent(Text)
        --temp.HeadRect = temp.trans:Find("Head")
        temp.headSlot = HeadSlot.New()
        temp.headSlot:SetRectParent(temp.trans:Find("Head"))
        --temp.Head = temp.trans:Find("Head"):GetComponent(Image)
        temp.goodBtn = temp.trans:Find("GoodIcon"):GetComponent(Button)
        temp.goodBtn.onClick:RemoveAllListeners()
        temp.goodBtn.onClick:AddListener(function() self:OnTakePraise(i) end)
        self.firstThreeList[i] = temp
    end
    self.firstThreeList[1].descText.text = TI18N("公会小花")
    self.firstThreeList[2].descText.text = TI18N("蛋碎一地")
    self.RectScroll = self.transform:Find("List/RectScroll")
    self.infoContainer = self.RectScroll:Find("Container")
    self.cloner = self.RectScroll:Find("Container/Cloner").gameObject
    self.cloner:SetActive(false)
    self.Layout = LuaBoxLayout.New(self.infoContainer, {axis = BoxLayoutAxis.Y, cspacing = 0})
    self.vScroll = self.RectScroll:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.setting_data)
    end)

    self.myRankText = self.transform:Find("Personal"):GetComponent(Text)

    local obj = nil
    for i=1,15 do
        obj = GameObject.Instantiate(self.cloner)
        obj.name = tostring(i)
        self.Layout:AddCell(obj)
        self.cellObjList[i] = TruthordareSingleEndItem.New(self.model, obj, self.assetWrapper)
    end
    

    self.setting_data = {
        item_list = self.cellObjList--放了 item类对象的列表
        ,data_list = {} --数据列表
        ,item_con = self.infoContainer  --item列表的父容器
        ,single_item_height = self.cloner:GetComponent(RectTransform).sizeDelta.y --一条item的高度
        ,item_con_last_y = self.infoContainer:GetComponent(RectTransform).anchoredPosition.y ---父容器改变时上一次的y坐标
        ,scroll_con_height = self.vScroll:GetComponent(RectTransform).sizeDelta.y --显示区域的高度
        ,item_con_height = 0 --item列表的父容器高度
        ,scroll_change_count = 0 --父容器滚动累计改变值
        ,data_head_index = 0  --数据头指针
        ,data_tail_index = 0 --数据尾指针
        ,item_head_index = 1 --item列表头指针
        ,item_tail_index = 0 --item列表尾指针
     }
    --设置数据时
    --self.setting_data.data_list = self.datalist
    --BaseUtils.refresh_circular_list(self.setting_data)
    ----------------------------
    self:SetData(self.data)
    self:ClearMainAsset()
end

function TruthordareSingleEndPanel:MiniPanel(andCloseChatPanel)
    if self.miniTweenId == nil then
        self.miniTweenId = Tween.Instance:Scale(self.gameObject, Vector3.zero, 0.2, 
            function() 
                self.miniMark = true 
                self:SetActive(false) 
                self.miniTweenId = nil 
                if andCloseChatPanel then
                    if ChatManager.Instance.model.chatWindow ~= nil and not BaseUtils.isnull(ChatManager.Instance.model.chatWindow.transform) then
                        ChatManager.Instance.model.chatWindow:ClickShow()
                    end
                end
            end, LeanTweenType.easeOutQuart).id
    end
end

function TruthordareSingleEndPanel:SetData(data)
    self.data = data
    if BaseUtils.isnull(self.gameObject) then
        return
    end
    self:SetActive(true)
end

function TruthordareSingleEndPanel:UpdateList()
    local model = TruthordareManager.Instance.model
    local datalist = model.rankInfo
    self.setting_data.data_list = datalist
    BaseUtils.refresh_circular_list(self.setting_data)
    self:UpdateFirstThree()
end

function TruthordareSingleEndPanel:SetActive(active)
    self.isActive = true
    if not BaseUtils.isnull(self.gameObject) then
        self.gameObject:SetActive(active)
        if active then
            local model = TruthordareManager.Instance.model
            if model.rankInfo ~= nil and model.rankFirstThreeList ~= nil then
                self:UpdateList()
            end
            self.transform.localScale = Vector3.one
            TruthordareManager.Instance.SingleEndUpdate:Remove(self._SingleUpdate)
            TruthordareManager.Instance.SingleEndUpdate:Add(self._SingleUpdate)
            TruthordareManager.Instance:Send19526()
        else
            TruthordareManager.Instance.SingleEndUpdate:Remove(self._SingleUpdate)
        end
    end
end


function TruthordareSingleEndPanel:UpdateFirstThree()
    local model = TruthordareManager.Instance.model
    local firstThreeData = model.rankFirstThreeList
    for i,v in ipairs(firstThreeData) do
        if v ~= nil and self.firstThreeList[i] ~= nil then
            local go = self.firstThreeList[i]
            go.name.text = v.role_name
            --点赞数
            go.goodText.text = v.praise
            go.headSlot.gameObject:SetActive(true)
            go.headSlot:HideSlotBg(true, 0)
            local data = v
            data.id = data.rid
            go.headSlot:SetAll(data, {isSmall = true, clickCallback = function() self:OnTakePraise(i) end})
        end
    end
    if model.selfRankData ~= 0 then
        self.myRankText.text = string.format(TI18N("我的排名:%s"),model.selfRankData)
    else
        self.myRankText.text = TI18N("我的排名:未上榜")
    end
    
end

function TruthordareSingleEndPanel:OnTakePraise(index)
    if not TruthordareManager.Instance.model.isHasPraise[index] then
        TruthordareManager.Instance.model.isHasPraise[index] = true
        TruthordareManager.Instance:Send19529(index)
        if self.firstThreeList[index] ~= nil then
            self.firstThreeList[index].goodText.text = self.firstThreeList[index].goodText.text + 1
        end
        --NoticeManager.Instance:FloatTipsByString(string.format(TI18N("你给%s点了个赞~"),TruthordareManager.Instance.model.rankFirstThreeList[index].role_name))
        
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("你已经点过赞了"))
    end
end