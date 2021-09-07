-- 战斗录像
-- @author huangzefeng
-- @date 20160517
CombatLogItem = CombatLogItem or BaseClass()

function CombatLogItem:__init(gameObject, parent, type)
    self.gameObject = gameObject
    self.type = type
    self.data = nil
    self.model = CombatManager.Instance.WatchLogmodel
    self.parent = parent
    self.item_index = 1
    self.transform = self.gameObject.transform

end

function CombatLogItem:__delete()

end


function CombatLogItem:InitPanel(_data)
    self:update_my_self(_data)
end

--设置索引
function CombatLogItem:set_my_index(_index)
    self.item_index = _index
    if self.item_index%2 == 0 then
        --偶数
        self.ImgOne.color = ColorHelper.ListItem1
    else
        --单数
        self.ImgOne.color = ColorHelper.ListItem2
    end
end

--更新内容
function CombatLogItem:update_my_self(_data, _index)
    self.transform:Find("Index"):GetComponent(Text).text = tostring(_index)
    self.transform:Find("NameCon/name1"):GetComponent(Text).text = _data.atk_name
    self.transform:Find("NameCon/name2"):GetComponent(Text).text = _data.dfd_name
    self.transform:Find("Type"):GetComponent(Text).text = Combat_Type[_data.combat_type]
    local year = os.date("%Y", _data.time)
    local month = os.date("%m", _data.time)
    local day = os.date("%d", _data.time)
    local timeText = string.format("%s-%s-%s", year, month, day)
    self.transform:Find("Day"):GetComponent(Text).text = timeText
    self.transform:Find("Button1"):GetComponent(Button).onClick:RemoveAllListeners()
    if self.type ~= 3 then
        if self.model:IsKeep(_data.rec_id) then
            -- self.transform:Find("Button1").gameObject:SetActive(self.type == 2)
            self.transform:Find("Button1"):GetComponent(Button).enabled = (self.type == 2)
            self.transform:Find("Button1"):GetComponent(Image).enabled = (self.type == 2)
            if self.type == 1 then
                self.transform:Find("Button1/Text"):GetComponent(Text).text = TI18N("已收藏")
            else
                self.transform:Find("Button1/Text"):GetComponent(Text).text = TI18N("取消收藏")
            end
            self.transform:Find("Button1"):GetComponent(Button).onClick:AddListener(function()
                local data2 = NoticeConfirmData.New()
                data2.type = ConfirmData.Style.Normal
                data2.content = TI18N("是否永久删除该录像？")
                data2.sureLabel = TI18N("删除")
                data2.cancelLabel = TI18N("取消")
                data2.blueSure = true
                data2.sureCallback = function()
                        CombatManager.Instance:Send10751(_data.type, _data.rec_id, _data.platform, _data.zone_id)
                    end
                NoticeManager.Instance:ConfirmTips(data2)
            end)
        else
            self.transform:Find("Button1").gameObject:SetActive(self.type == nil or self.type == 1)
            self.transform:Find("Button1/Text"):GetComponent(Text).text = TI18N("收藏")
            self.transform:Find("Button1"):GetComponent(Button).onClick:AddListener(function()
                CombatManager.Instance:Send10750(_data.type, _data.rec_id, _data.platform, _data.zone_id)
            end)
        end
    else
        if _data.likable == 1 then
            self.transform:Find("Button1/Text"):GetComponent(Text).text = string.format(TI18N("喜欢(%s)"), _data.liked)
            self.transform:Find("Button1"):GetComponent(Button).onClick:AddListener(function()
                CombatManager.Instance:Send10752(_data.type, _data.rec_id, _data.platform, _data.zone_id)
            end)
        else
            self.transform:Find("Button1/Text"):GetComponent(Text).text = TI18N(string.format(TI18N("已赞(%s)"), _data.liked))
            -- self.transform:Find("Button1"):GetComponent(Button).onClick:AddListener(function()
            --     CombatManager.Instance:Send10750(_data.type, _data.rec_id, _data.platform, _data.zone_id)
            -- end)
        end
    end
    self.transform:Find("Button2"):GetComponent(Button).onClick:RemoveAllListeners()
    self.transform:Find("Button2"):GetComponent(Button).onClick:AddListener(function ()
        CombatManager.Instance:Send10744(_data.type, _data.rec_id, _data.platform, _data.zone_id)
    end)
    self.transform:GetComponent(Button).onClick:RemoveAllListeners()
    self.transform:GetComponent(Button).onClick:AddListener(function()
        -- self.model:OpenViewPanel(_data)
        CombatManager.Instance:Send10753(_data.type, _data.rec_id, _data.platform, _data.zone_id)
    end)
end

function CombatLogItem:Refresh(args)

end

