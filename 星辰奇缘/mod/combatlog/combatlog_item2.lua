-- 战斗录像极道对决Item
-- @author huangzefeng
-- @date 20160517
CombatLogItem2 = CombatLogItem2 or BaseClass()

function CombatLogItem2:__init(gameObject, parent, type)
    self.gameObject = gameObject
    self.type = type
    self.data = nil
    self.model = CombatManager.Instance.WatchLogmodel
    self.parent = parent
    self.item_index = 1
    self.transform = self.gameObject.transform

end

function CombatLogItem2:__delete()

end


function CombatLogItem2:InitPanel(_data)
    self:update_my_self(_data)
end

--设置索引
function CombatLogItem2:set_my_index(_index)
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
function CombatLogItem2:update_my_self(_data, _index)
    self.transform:Find("Index"):GetComponent(Text).text = tostring(_index)
    self.transform:Find("NameCon/name1"):GetComponent(Text).text = _data.atk_name
    self.transform:Find("NameCon/name2"):GetComponent(Text).text = _data.dfd_name
    self.transform:Find("Type"):GetComponent(Text).text = tostring(_data.avg_lev)
    -- local year = os.date("%Y", _data.time)
    -- local month = os.date("%m", _data.time)
    -- local day = os.date("%d", _data.time)
    -- local timeText = string.format("%s-%s-%s", year, month, day)
    self.transform:Find("Day"):GetComponent(Text).text = tostring(_data.round)
    self.transform:Find("Like/Text"):GetComponent(Text).text = tostring(_data.replayed)
    -- local likebtn = self.transform:Find("Like/Button"):GetComponent(Button)
    -- likebtn.onClick:RemoveAllListeners()
    -- if _data.likable == 1 then
    --     likebtn.gameObject:SetActive(true)
    --     likebtn.onClick:AddListener(function()
    --         CombatManager.Instance:Send10752(_data.type, _data.rec_id, _data.platform, _data.zone_id)
    --     end)
    -- else
    --     likebtn.gameObject:SetActive(false)
    -- end
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

function CombatLogItem2:Refresh(args)

end

