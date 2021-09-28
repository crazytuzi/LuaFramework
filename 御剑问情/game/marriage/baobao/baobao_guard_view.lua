BaoBaoGuardView = BaoBaoGuardView or BaseClass(BaseRender)

local EFFECT_CD = 1.8
function BaoBaoGuardView:__init(instance, mother_view)
    self.sprite_level = 0
    self.sprite_index = 0
    self.selectindex = 1
    self:ListenEvent("UpGrade", BindTool.Bind(self.UpGradeClick,false, self))
    self:ListenEvent("AutoUpGrade", BindTool.Bind(self.AutoUpGradeClick, self))
    self:ListenEvent("ClickSpriteAttr", BindTool.Bind(self.ClickSpriteAttr, self))
    self:ListenEvent("ClickSprite1", BindTool.Bind(self.ClickSprite, self, 0))
    self:ListenEvent("ClickSprite2", BindTool.Bind(self.ClickSprite, self, 1))
    self:ListenEvent("ClickSprite3", BindTool.Bind(self.ClickSprite, self, 2))
    self:ListenEvent("ClickSprite4", BindTool.Bind(self.ClickSprite, self, 3))
    self:ListenEvent("ClickSpirteTips",BindTool.Bind(self.ClickSpirteTips,self))
  
    self.cur_level = self:FindVariable("CurLevel")
    self.next_level = self:FindVariable("NextLevel")
    self.capacity = self:FindVariable("Cap")
    self.cap_add = self:FindVariable("CapAdd")
    self.progress_txt = self:FindVariable("ProgressTxt")
    self.progress = self:FindVariable("Progress")
    self.stuff = self:FindVariable("Stuff")
    self.sprite_name = self:FindVariable("SpriteName")
    self.up_btn_gray = self:FindVariable("UpBtnGray")
    self.auto_btn_gray = self:FindVariable("AutoBtnGray")
    self.auto_buy = self:FindObj("AutoBuy")
    self.show_effect = self:FindVariable("ShowEffect")
    self.is_max = self:FindVariable("IsMax")

    self.spritelevel = {}
    self.temp_grade = {}
    for i=1,4 do
        self.spritelevel[i] = self:FindVariable("SpriteLevel"..i)
        self.temp_grade[i] = -1
    end

    self.sprite_cell = ItemCell.New()
    self.sprite_cell:SetInstanceParent(self:FindObj("Sprite"))
    self.sprite_img = self:FindObj("SpriteImg")
    self.sprite_an = self:FindObj("Sprite_an")
    self.sprite_guang = self:FindObj("Sprite_guang")
    self.sprite_shui = self:FindObj("Sprite_shui")
    self.sprite_tu = self:FindObj("Sprite_tu")
    self.attr_content = self:FindObj("AttrContent")
    self.auo_btn_name = self:FindVariable("AuoBtnName")
    self.show_sprite_red = {}
    for i=0,3 do
        self.show_sprite_red[i] = self:FindVariable("ShowSpriteRed" .. i)
    end
    
    self.cell_list = {}
    self.list_view_delegate = self.attr_content.list_simple_delegate
    self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
    self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
end

function BaoBaoGuardView:__delete()
    if nil ~= self.sprite_obj_transform then
        GameObject.Destroy(self.sprite_obj_transform.gameObject)
        self.sprite_obj_transform = nil   
    end

    if self.sprite_cell then
        self.sprite_cell:DeleteMe()
    end
    self.sprite_cell = nil

    for k,v in pairs(self.cell_list) do
        v:DeleteMe()
    end
    self.cell_list = {}

    self.sprite_img = nil
    self.sprite_an = nil
    self.sprite_guang = nil
    self.sprite_shui = nil
    self.sprite_tu = nil
    self.attr_content = nil
    self.auo_btn_name = nil
    self.show_sprite_red = nil
    self.show_effect = nil
    self.spritelevel = nil

    if self.time_quest ~= nil then
        GlobalTimerQuest:CancelQuest(self.time_quest)
        self.time_quest = nil
    end
    if nil ~= self.upgrade_timer_quest then
        GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
        self.upgrade_timer_quest = nil
    end
end

function BaoBaoGuardView:ResetValue()
    for i=1, 4 do
         self.temp_grade[i] = -1
    end
end

function BaoBaoGuardView:StartAnim()
    if nil ~= self.time_quest then
        GlobalTimerQuest:CancelQuest(self.time_quest)
    end
    self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateAnim,self), 0)
end

function BaoBaoGuardView:UpdateAnim()
    self.sprite_img.transform:Rotate(UnityEngine.Vector3.forward,-0.5)
    local sprite = self.sprite_img.transform
    local an = self.sprite_an.transform.localRotation
    local guang = self.sprite_guang.transform.localRotation
    local shui = self.sprite_shui.transform.localRotation
    local tu = self.sprite_tu.transform.localRotation
    self.sprite_an.transform.localRotation = UnityEngine.Quaternion(an.x,an.y,-sprite.rotation.z,sprite.localRotation.w)
    self.sprite_guang.transform.localRotation = UnityEngine.Quaternion(guang.x,guang.y,-sprite.rotation.z,sprite.localRotation.w)
    self.sprite_shui.transform.localRotation = UnityEngine.Quaternion(shui.x,shui.y,-sprite.rotation.z,sprite.localRotation.w)
    self.sprite_tu.transform.localRotation = UnityEngine.Quaternion(tu.x,tu.y,-sprite.rotation.z,sprite.localRotation.w)
end

function BaoBaoGuardView:CloseCallBack()
    if self.time_quest ~= nil then
        GlobalTimerQuest:CancelQuest(self.time_quest)
        self.time_quest = nil
    end
    if self.is_auto_upgrade then
        self:AutoUpGradeClick()
    end

    if nil ~= self.upgrade_timer_quest then
        GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
        self.upgrade_timer_quest = nil
    end
    self.show_effect:SetValue(false)
end

function BaoBaoGuardView:GetNumberOfCells()
    local all_baby_sprite_list = BaobaoData.Instance:GetAllBabySpiritInfo()
    local baby_select_index = BaobaoData.Instance:GetSelectedBabyIndex()
    local count = 0
    local cur_attr = {}

    if baby_select_index ~= nil and all_baby_sprite_list[baby_select_index-1]
                     and all_baby_sprite_list[baby_select_index-1][self.sprite_index or 0] then
                     self.sprite_index = self.sprite_index or 0

        local spirit_level = all_baby_sprite_list[baby_select_index-1][self.sprite_index].spirit_level or 0
        cur_attr = BaobaoData.Instance:GetBabySpiritAttr(self.sprite_index, spirit_level)
    end

    count = #cur_attr or 0
    return count
end

function BaoBaoGuardView:RefreshView(cell,data_index)
    data_index = data_index +1 
    local attr_cell = self.cell_list[cell]

    if nil == attr_cell then
        attr_cell = SpriteAttrCell.New(cell.gameObject)
        self.cell_list[cell] = attr_cell
    end

    local attribute = CommonStruct.Attribute()
    local all_baby_sprite_list = BaobaoData.Instance:GetAllBabySpiritInfo()
    local baby_select_index = BaobaoData.Instance:GetSelectedBabyIndex()

    if nil ~= baby_select_index and all_baby_sprite_list[baby_select_index-1]
                     and all_baby_sprite_list[baby_select_index-1][self.sprite_index or 0] then
                     self.sprite_index = self.sprite_index or 0

        local spirit_level = all_baby_sprite_list[baby_select_index-1][self.sprite_index].spirit_level
        local cur_attr = BaobaoData.Instance:GetBabySpiritAttr(self.sprite_index, spirit_level)
        attr_cell:SetData(cur_attr[data_index])
    end
end

function BaoBaoGuardView:AutoUpGradeClick()
    self.is_auto_upgrade = not self.is_auto_upgrade
    self:IsMaxValue()
    if self.is_auto_upgrade then
       self:AutoUpGradeOnce()
   end
end

function BaoBaoGuardView:AutoUpGradeOnce()
    local baby_select_index = BaobaoData.Instance:GetSelectedBabyIndex()
    if nil == baby_select_index then return end
    local baby_info = BaobaoData.Instance:GetBabyInfo(baby_select_index)
    if nil == baby_info then return end
    self.selectindex = BaobaoData.Instance:GetSelectedBabyIndex()-- 记录谁被进阶
    local used_item_id = self.used_item_id or 0
    local have_item_num = ItemData.Instance:GetItemNumInBagById(used_item_id)
    if have_item_num < 1 and not self.auto_buy.toggle.isOn then
        -- TipsCtrl.Instance:ShowItemGetWayView(used_item_id)
        self.is_auto_upgrade = false
        self:AutoBuyConfirm(used_item_id)
        return
    end
    
    local jinjie_next_time = 0
    if nil ~= self.upgrade_timer_quest then
        if self.jinjie_next_time >= Status.NowTime then
            jinjie_next_time = self.jinjie_next_time - Status.NowTime
        end
        GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
    end
    if self.is_auto_upgrade then
        self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.UpGradeClick,self,true), jinjie_next_time)
    end
    -- BaobaoCtrl.SendBabyTrainSpiritReq(baby_select_index-1, self.sprite_index,1)
end

function BaoBaoGuardView:UpGradeClick(is_on)
    local baby_select_index = BaobaoData.Instance:GetSelectedBabyIndex()
    if nil == baby_select_index then return end
    local baby_info = BaobaoData.Instance:GetBabyInfo(baby_select_index)
    if nil == baby_info then return end

    local used_item_id = self.used_item_id or 0
    local have_item_num = ItemData.Instance:GetItemNumInBagById(used_item_id)
    if have_item_num < 1 and not self.auto_buy.toggle.isOn then
        -- TipsCtrl.Instance:ShowItemGetWayView(used_item_id)
        self:AutoBuyConfirm(used_item_id)
        return
    end
    local next_time = 0.1
    local all_baby_sprite_list = BaobaoData.Instance:GetAllBabySpiritInfo()
    if all_baby_sprite_list[baby_select_index-1] and all_baby_sprite_list[baby_select_index-1][self.sprite_index] then
        local spirit_level = all_baby_sprite_list[baby_select_index-1][self.sprite_index].spirit_level
        if spirit_level == 0 then
            spirit_level = 1
        end
        local cfg = BaobaoData.Instance:GetBabySpiritAttrCfg(self.sprite_index, spirit_level)
        local is_auto_buy = self.auto_buy.toggle.isOn and 1 or 0
        if cfg.pack_num then
            BaobaoCtrl.SendBabyTrainSpiritReq(baby_select_index-1, self.sprite_index,is_auto_buy,cfg.pack_num)
            self.jinjie_next_time = Status.NowTime + next_time
        end
    end
end

function BaoBaoGuardView:AutoBuyConfirm(item_id)
    local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
    MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
    self.auto_buy.toggle.isOn = is_buy_quick
    end
  
    TipsCtrl.Instance:ShowCommonBuyView(func, item_id, BindTool.Bind2(self.TipsCancelCallback, self), 1)
    return true
end

function BaoBaoGuardView:TipsCancelCallback()
    self.is_auto_upgrade = false
    self.auo_btn_name:SetValue(self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1])
end

function BaoBaoGuardView:OnOperateResult(operate, result, param1, param2)
    if 0 == result then
        if self.is_auto_upgrade then
            self.is_auto_upgrade = false
            self.auo_btn_name:SetValue(self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1])
        end
    elseif 1== result then
        self:AutoUpGradeOnce()    
    elseif 2 == result then
        if self.is_auto_upgrade then
            self.is_auto_upgrade = false
            self.auo_btn_name:SetValue(self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1])
        end
    elseif 3 == result then
        if self.is_auto_upgrade then
            self.is_auto_upgrade = false
        end
        self:FlushView()
    end
end

function BaoBaoGuardView:ClickSpriteAttr()
    local baby_list = BaobaoData.Instance:GetListBabyData() or {}
    if #baby_list <= 0 then
        SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.HaveNotBaby)
        return
    end

    local attr_data = BaobaoData.Instance:GetBabyTotalSpriteAttr()
    TipsCtrl.Instance:ShowAttrView(attr_data)
    self:FlushView()
end

function BaoBaoGuardView:ClickSprite(index)
    self.sprite_index = index
    BaobaoData.Instance:SetCurSpiritIndex(index)
    self:FlushView()
    self:UpdateSprite()
    self.attr_content.scroller:RefreshAndReloadActiveCellViews(true)
end

function BaoBaoGuardView:FlushSpriteRed(index)
    local _, red_t = BaobaoData.Instance:SetBaobaoRedPoint(index)
    for i=0,3 do
        self.show_sprite_red[i]:SetValue(red_t[i] == true)
    end
end

function BaoBaoGuardView:UpdateSprite()
    if nil ~= self.sprite_obj_transform then
        GameObject.Destroy(self.sprite_obj_transform.gameObject)
        self.sprite_obj_transform = nil
    end
end

function BaoBaoGuardView:ClickSpirteTips()
    local tip_id = 260
    TipsCtrl.Instance:ShowHelpTipView(tip_id)
end

-- 监听物品变化
function BaoBaoGuardView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
    local cur_cfg = BaobaoData.Instance:GetBabySpiritCfg(self.sprite_index, self.sprite_level + 1)
    if cur_cfg and cur_cfg.consume_item == item_id then
        self:FlushView()
        BaobaoCtrl.Instance:FlushImageViewRed()
    end
end

function BaoBaoGuardView:IsMaxValue()
   return BaobaoData.Instance:GetBabySpiritCfg(self.sprite_index, self.sprite_level + 1) == nil
end

function BaoBaoGuardView:FlushView()
    self.auo_btn_name:SetValue(self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1])
    self:StartAnim()
    if self.sprite_obj_transform == nil then
        self:UpdateSprite()
    end

    local all_baby_sprite_list = BaobaoData.Instance:GetAllBabySpiritInfo()
    local baby_select_index = BaobaoData.Instance:GetSelectedBabyIndex()
    self:FlushSpriteRed(baby_select_index)
    local max_level = BaobaoData.Instance:GetBabySpiritMaxLevel()
    if nil ~= baby_select_index and all_baby_sprite_list[baby_select_index-1] 
      and all_baby_sprite_list[baby_select_index-1][self.sprite_index or 0] then

        self.sprite_index = self.sprite_index or 0
        local attr = BaobaoData.Instance:GetBabySpiritAttrCfg(self.sprite_index,1)
        local data = {item_id = attr.consume_item}
        self.sprite_cell:SetData(data)
        self.sprite_name:SetValue(ToColorStr(attr.name, BAOBAO_SPRITE_COLOR[self.sprite_index + 1]))
        self.sprite_level = all_baby_sprite_list[baby_select_index-1][self.sprite_index].spirit_level

        local cur_attr = BaobaoData.Instance:GetBabySpiritAttrCfg(self.sprite_index, self.sprite_level)
        local next_attr = BaobaoData.Instance:GetBabySpiritAttrCfg(self.sprite_index, self.sprite_level+1)
        if nil ~= next_attr.consume_item then
            local item_num = ItemData.Instance:GetItemNumInBagById(next_attr.consume_item)
            self.used_item_id = next_attr.consume_item       --记录当前需要消耗的材料id
            local item_name = ItemData.Instance:GetItemName(next_attr.consume_item) or ""
            local color = item_num < 1 and "#ff0000" or "#ffe500"
            local consume_num = 1                            --消耗的精灵材料个数为1(看了下配置表，并没有消耗材料的字段，好像是写死1的)
            self.stuff:SetValue(string.format(Language.Marriage.BaobaoStuff, color,item_num,consume_num))
        else
            self.used_item_id = 0
            local str = Language.Marriage.BaobaoSpriteMaxLevel or ""
            self.stuff:SetValue(str)
        end
        local cur_train_val = all_baby_sprite_list[baby_select_index-1][self.sprite_index].spirit_train
        self.up_btn_gray:SetValue(nil ~= next_attr.train_val)
        self.auto_btn_gray:SetValue(nil ~= next_attr.train_val)

        for i=1,4 do
            if self.sprite_index + 1 == i then
                local cur_level = all_baby_sprite_list[baby_select_index-1][i - 1].spirit_level
                if self.temp_grade[i] ~= - 1 then
                    if self.temp_grade[i] < cur_level then
                        -- 升级特效
                        if not self.effect_cd or self.effect_cd <= Status.NowTime then
                            self.show_effect:SetValue(false)
                            self.show_effect:SetValue(true)
                            self.effect_cd = EFFECT_CD + Status.NowTime
                        end
                    end
                end
                self.temp_grade[i] = cur_level
            end
            self.spritelevel[i]:SetValue(all_baby_sprite_list[baby_select_index-1][i-1].spirit_level)
        end
        self.is_max:SetValue(nil == next_attr.train_val)
        if nil ~= next_attr.train_val then
            local percent = cur_train_val / next_attr.train_val
            self.progress:SetValue(percent)
            self.progress_txt:SetValue(cur_train_val .. "/" .. next_attr.train_val)

        else
            self.progress_txt:SetValue(Language.Common.MaxLv)
            self.auo_btn_name:SetValue(Language.Common.MaxLv)
            self.progress:SetValue(1)
        end

        self.cur_level:SetValue(self.sprite_level)
        self.next_level:SetValue(next_attr.level or self.sprite_level)

        self.capacity:SetValue(CommonDataManager.GetCapability(cur_attr))
        self.cap_add:SetValue(CommonDataManager.GetCapability(next_attr, true, cur_attr))
        
    end

    self.attr_content.scroller:RefreshAndReloadActiveCellViews(true)

    if self.selectindex ~= BaobaoData.Instance:GetSelectedBabyIndex() then
        self.is_auto_upgrade = false
        self.up_btn_gray:SetValue(true)      
        -- self.auo_btn_name:SetValue(self.is_auto_upgrade and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1])
        self.selectindex = BaobaoData.Instance:GetSelectedBabyIndex()
        self:FlushView()
    end
end

--------------------------------------------AttrCell---------------------------------------------------------------
SpriteAttrCell = SpriteAttrCell or BaseClass(BaseCell)

function SpriteAttrCell:__init()
    self.cur_attr = self:FindVariable("cur_attr")
    self.next_attr = self:FindVariable("next_attr")
    self.attr_icon = self:FindVariable("attr_icon")
    self.next_icon = self:FindVariable("next_icon")
end

function SpriteAttrCell:FlushAttr()
    self.cur_attr:SetValue(Language.Common.AttrName[self.data.name].."：".."<size=22>"..self.data.cur_value.."</size>")
    if self.data.next_value > 0 then
        self.next_attr:SetValue("<size=22>"..self.data.next_value.."</size>")
    end
    self.attr_icon:SetAsset(ResPath.GetBaseAttrIcon(self.data.name)) 
    local cur_level = BaobaoData.Instance:GetCurSpiritLevel()
    self.next_icon:SetValue(cur_level ~= BaobaoData.Instance:GetBabySpiritMaxLevel())
end

function SpriteAttrCell:OnFlush()
    self:FlushAttr()
end