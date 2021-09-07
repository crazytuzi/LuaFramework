-- @author zyh
-- @date 2017年5月4日

SevenLoginTipsPanel = SevenLoginTipsPanel or BaseClass(BasePanel)


function SevenLoginTipsPanel:__init(parent,InitCallBack)
    self.parent = parent
    self.initCallBack = InitCallBack
    self.name = "SevenLoginTipsPanel"
    -- self.Effect = "prefabs/effect/20298.unity3d"
    self.resList = {
        {file = AssetConfig.seven_login_tips, type = AssetType.Main}

    }

    self.itemSlotList = {}
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.floatTimerId = nil

    self.containerWeight = nil
    self.containerHeight = nil

    self.objParent = nil
    self.noticeText = nil
    self.countTime = nil
    self.componentContainer = nil

    self.deleteCallBack = nil

end


function SevenLoginTipsPanel:OnInitCompleted()
    if self.initCallBack ~= nil then
        self.initCallBack(self)
    end
end

function SevenLoginTipsPanel:__delete()
    if self.deleteCallBack ~= nil then
       self.deleteCallBack()
    end

    if self.itemSlotList ~= nil then
        for i,v in ipairs(self.itemSlotList) do
            if v.effect ~= nil then
                v.effect:DeleteMe()
            end
            v:DeleteMe()
        end
        self.itemSlotList = {}
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    self.parent.tipsPanel = nil
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()

end

function SevenLoginTipsPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.seven_login_tips))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.gameObject.name = "SevenLoginTipsPanel"
    -- self.gameObject.transform.anchoredPosition = Vector3(self.gameObject.transform.anchoredPosition.x,self.gameObject.transform.anchoredPosition.y,200)
    self.transform = self.gameObject.transform
    self.panelBtn = self.transform:Find("Panel"):GetComponent(Button):GetComponent(Button)
    self.panelBtn.onClick:AddListener(function() self:DeleteMe() end)

    self.panelImg = self.transform:Find("Panel"):GetComponent(Button):GetComponent(Image)
    self.transform = self.gameObject.transform
    self.transform:SetAsFirstSibling()

    self.objParent = self.transform:Find("MainCon")
    self.itemCon = self.transform:Find("MainCon/ItemSlotTemplte")

    self.itemCon.gameObject:SetActive(false)
    self.mainConTr = self.transform:Find("MainCon")

    self.bgTr = self.transform:Find("MainCon/Bg"):GetComponent(RectTransform)
    self.noticeText = self.transform:Find("MainCon/Text"):GetComponent(Text)
    self.componentContainer = self.transform:Find("MainCon/ComponentContainer")
    self:OnOpen()
end

-- 参数分别意义为：1.展示的物品列表 2.设置一行的最大个数 3.设置物体的间隔与与边框边缘的间距{x,y,pointx,pointy,isOpenBgButton}(两点间隔特指两点之间),4.显示上层奖励的文字 5.设置奖励背景宽高panel的透明度(默认则为自动设置),6.启动定时器{开始时间，间隔时间,callback}，7.自定义简单组件功能callback}
function SevenLoginTipsPanel:OnOpen()
    local weight = nil
    local height = nil

    local col = 1
    local row = 1

    if self.openArgs[2] ~= nil then
        row = self.openArgs[2]
        col = math.ceil(#self.openArgs[1] / row)
    end

    local borderX = 116
    local borderY = 116
    local topX = 100
    local topY = 130
    if self.openArgs[3] ~= nil then
        borderX = self.openArgs[3][1] or 116
        borderY = self.openArgs[3][2] or 116
        topX = self.openArgs[3][3] or 100
        topY = self.openArgs[3][4] or 130
        if self.openArgs[3][5] == false then
            self.panelBtn.onClick:RemoveAllListeners()
            -- self.panelBtn.transform:GetComponent(Image).color = Color(0,0,0,0)
        end
    end



    local numberI = 1
    local numberII = 1
    if col % 2 == 0 then
        numberII = -1
    else
        numberII = 1
    end


    local list = {}

    for k=1,col do
        numberII = numberII * -1
        local length = 0
        if k ~= col then
            length = row
        else
            length = #self.openArgs[1] % row
            if length == 0 then
                length = row
            end
        end
        for i=1,length do
            numberI = numberI * -1
            local gameObject = GameObject.Instantiate(self.itemCon.gameObject)
            local rectTr = gameObject.transform:GetComponent(RectTransform)
            gameObject.transform:SetParent(self.mainConTr)
            gameObject.transform.localScale = Vector3(1, 1, 1)
            gameObject:SetActive(true)
            if length % 2 == 0 then
                rectTr.anchoredPosition = Vector2(math.floor((i - 1) / 2)*borderX * numberI + numberI * (borderX / 2),0)

            else
                if i == 1 then
                   rectTr.anchoredPosition = Vector2(0,0,0)
                else
                   rectTr.anchoredPosition = Vector2(math.floor((i - 2) / 2)*borderX * numberI + numberI * borderX,0)
                end
            end


            if col % 2 == 0 then
                rectTr.anchoredPosition = Vector2(rectTr.anchoredPosition.x,math.floor((k - 1) / 2) * borderY * numberII + numberII * (borderY / 2))

            else
                if k == 1 then
                    rectTr.anchoredPosition = Vector2(rectTr.anchoredPosition.x,0)
                else
                    rectTr.anchoredPosition = Vector2(rectTr.anchoredPosition.x,math.floor((k - 2) / 2) * borderY *numberII + numberII * borderY)
                end
            end

            local tt = #self.openArgs[1]
            if row*(k-1) + i == tt then

                height = 2 * (math.abs(rectTr.anchoredPosition.y) + topY)
            end

            local weightnum = nil
            if #self.openArgs[1] < row then
                weightnum = #self.openArgs[1]
            else
                weightnum = row
            end
            if i ==  weightnum then
                weight = 2 * (math.abs(rectTr.anchoredPosition.x) + topX)
            end

            --local itemSlotObj = gameObject.transform:Find("ItemSlot").gameObject

            table.insert(list,gameObject)

            --self:CreatSlot(self.openArgs[1][(k-1) * row + i],itemSlotObj,gameObject)
        end
    end


    local function sort_(a, b)
        local r
        local ax = a.transform.position.x
        local bx = b.transform.position.x
        local ay = a.transform.position.y
        local by = b.transform.position.y
        if ay == by then
            r = ax < bx
        else
            r = ay > by
        end
        return r
    end

    table.sort(list,sort_)

    for i=1,#list do
        local itemSlotObj = list[i].transform:Find("ItemSlot").gameObject
        self:CreatSlot(self.openArgs[1][i],itemSlotObj,list[i])
    end

    self.bgTr.sizeDelta = Vector2(weight,height)

    self.containerWeight = weight
    self.containerHeight = height

    self.noticeText.transform:GetComponent(RectTransform).anchoredPosition = Vector2(0,self.bgTr.sizeDelta.y / 2 - 40)

    if self.openArgs[4] ~= nil then
        self.noticeText.text = TI18N(self.openArgs[4])

        self.noticeText.transform:GetComponent(RectTransform).sizeDelta = Vector2(self.noticeText.preferredWidth,self.noticeText.transform:GetComponent(RectTransform).sizeDelta.y)
    end

    if self.openArgs[5] ~= nil then
        if self.openArgs[5][1] ~= nil and self.openArgs[5][2] ~= nil then
            self.bgTr.sizeDelta = Vector2(self.openArgs[5][1],self.openArgs[5][2])
        end

        if self.openArgs[5][3] ~= nil then
            self.panelImg.color = Color(0,0,0,self.openArgs[5][3])
        end
    end

    if self.openArgs[6] ~= nil then
        if self.timerId == nil then
            self.timerId = LuaTimer.Add(self.openArgs[6][1],self.openArgs[6][2], function() self:OnTime() end)
        end
    end

    if self.openArgs[7] ~= nil then
        self.openArgs[7](self.containerHeight)
    end

    if self.openArgs[8] ~= nil then
        self.deleteCallBack = self.openArgs[8]
    end
end

function SevenLoginTipsPanel:CreatSlot(data,gameObject,parentObj)
    local slot
    if data.isface then
        slot = FaceItem.New(gameObject.transform)
        if data.item_id == 114 or data.item_id == 123 or data.item_id == 124 or data.item_id == 125 or data.item_id == 126 or data.item_id == 128 or data.item_id == 135 then
            slot:Show(data.item_id,Vector2(-4,-16),nil,Vector2(70,38))
        else
            slot:Show(data.item_id,Vector2(7.8,-11),nil,Vector2(50,50))
        end
        parentObj.transform:Find("Text"):GetComponent(Text).text = TI18N("<color='#16baf4'>小表情</color>")

    else
        slot = ItemSlot.New(gameObject)
        local id = data.id or data.item_id or data[1]
        local quantity = data.quantity or data[2] or 0
        local num = data.num or data[3]
        local base = DataItem.data_get[id]
        if base == nil then
            Log.Error("道具id配错():[baseid:" .. tostring(data[1]) .. "]")
        end
        local data = DataItem.data_get[id]
        local extra = {inbag = false, nobutton = true}
        slot:SetAll(data,extra)
        slot:SetNum(num)
        parentObj.transform:Find("Text"):GetComponent(Text).text = ColorHelper.color_item_name(DataItem.data_get[id].quality,DataItem.data_get[id].name)
    end

    local effect = (data.is_effet == 1) or false
    -- if effect == true then
    if slot.effect == nil and effect then
         slot.effect = BibleRewardPanel.ShowEffect(20223,slot.gameObject.transform, Vector3(1,1,1), Vector3(0, 2, -355))

    end

    if slot.effect ~=nil then
        slot.effect:SetActive(effect)
    end

    -- else
    --     if slot.effect ~= nil then
    --         slot.effect:SetActive(false)
    --     end
    -- end


    table.insert(self.itemSlotList,slot)

end

function SevenLoginTipsPanel:SetParent(parentObj,bottomOj)
    bottomOj.transform:SetParent(parentObj.transform)
    bottomOj.transform.localScale = Vector3(1,1,1)
    bottomOj.gameObject:SetActive(true)
end


function SevenLoginTipsPanel:OnTime()
    self.openArgs[6][3]()
    self.countTime = self.countTime - 1
end


-- function BibleRechargePanel:CheckIsRechargeRedPoint()
--     if             then
--        BibleManager.Instance.redPointDic[1][23] = true
--     end
-- end


